package user

import "core:log"
import "core:strings"

import "bred:builtin/commands"
import "bred:builtin/components/file_editor"
import "bred:core"
import "bred:core/buffer"
import "bred:core/command"
import "bred:core/font"
import "bred:core/layout"
import "bred:core/portal"
import "bred:lib/treesitter/viewer"

import "user:components/file_browser"
import "user:components/status_bar"
import glo "user:globals"
import "user:parsers"

create_file_portal :: proc(rect: core.Rect) -> (p: core.Portal) {
    p = file_editor.create_file_portal(rect)
    p.command_set_id = glo.CMD_EDITOR
    return
}

create_tree_viewer :: proc(rect: core.Rect) -> (p: core.Portal) {
    p = viewer.create_tree_viewer(rect, 0)
    p.command_set_id = glo.CMD_TREE_VIEWER
    return
}

build_layouts :: proc(state: ^core.EditorState) {
    FILE := core.PortalDefinition(create_file_portal)
    STATUS_BAR := core.PortalDefinition(status_bar.create_status_bar)
    TREE_VIEWER := core.PortalDefinition(create_tree_viewer)

    single_file := layout.create_absolute_split(.Left, status_bar.WIDTH, FILE, STATUS_BAR)

    double_file := layout.create_absolute_split(
        .Left,
        status_bar.WIDTH,
        layout.create_percent_split(.Right, 50, FILE, FILE),
        STATUS_BAR,
    )

    glo.LAYOUT_SINGLE = layout.register_layout(state, single_file)
    glo.LAYOUT_DOUBLE = layout.register_layout(state, double_file)
    glo.LAYOUT_TREE_VIEWER = layout.register_layout(
        state,
        layout.create_absolute_split(
            .Left,
            status_bar.WIDTH,
            layout.create_percent_split(.Right, 50, FILE, TREE_VIEWER),
            STATUS_BAR,
        ),
    )
}

switch_layouts :: proc(state: ^core.EditorState, wildcards: []core.WildcardValue) -> bool {
    command.validate_wildcards(wildcards, {.Num}, "switch_layouts") or_return

    layout_id := wildcards[0].(int)
    if layout_id >= len(state.layouts) {
        log.errorf("%d is not a valid layout id", layout_id)
        return false
    }

    primary_buffer := state.portals[0].buffer

    layout.activate_layout(state, layout_id)

    switch layout_id {
    case 0:
        state.portals[0].buffer = primary_buffer
    case 1:
        state.portals[0].buffer = primary_buffer
        state.portals[1].buffer = {}
    }

    return true
}

open_file_browser :: proc(state: ^core.EditorState, _: []core.WildcardValue) -> bool {
    browser := file_browser.create_file_browser(state)
    state.portals[state.active_portal] = browser
    return true
}

init :: proc(state: ^core.EditorState) {
    register_theme()
    parsers.register_parsers()

    buffer_id: core.BufferId
    {     // Open testing buffer
        ref: ^core.Buffer
        buffer_id, ref = buffer.create(state)
        ok := buffer.load_file(ref, strings.clone("F:\\GitHub\\bred\\.build\\test.odin"))
        assert(ok, "Failed to load test file")
    }

    build_layouts(state)

    font.load("CodeNewRomanNerdFontMono-Regular.otf", 24)

    glo.CMD_EDITOR = command.register_command_set(state)
    glo.CMD_FILE_BROWSER = command.register_command_set(state)

    {
        factory := command.factory_create(state, command.GLOBAL_SET)
        factory->register({.ESCAPE}, commands.clear_modifiers)
        factory->register({.L, .Num}, switch_layouts, {.Alt})
        
        factory.modifiers = {.Ctrl}
        factory->register({.LEFT}, commands.previous_portal)
        factory->register({.RIGHT}, commands.next_portal)
        factory->register({.O}, open_file_browser)
        factory->register({.PERIOD}, commands.repeat_command, keep_as_last_motion = false)
    
        factory->register({.SPACE, .Char}, open_harpoon_mark)
        factory->register({.SPACE, .Char}, set_harpoon_mark, {.Shift})
    }

    {     // File Editor Commands
        factory := command.factory_create(state, glo.CMD_EDITOR)
        factory->register({.Char}, commands.insert_character)
        factory->register({.LEFT}, file_editor.move_cursor_left)
        factory->register({.RIGHT}, file_editor.move_cursor_right)
        factory->register({.UP}, file_editor.move_cursor_up)
        factory->register({.DOWN}, file_editor.move_cursor_down)

        factory->register({.ENTER}, commands.insert_line)
        factory->register({.BACKSPACE}, commands.delete_behind)
        factory->register({.DELETE}, commands.delete_ahead)
        factory->register({.END}, commands.jump_to_line_end)
        factory->register({.HOME}, commands.jump_to_line_start)
        factory->register({.PAGE_UP}, file_editor.page_up)
        factory->register({.PAGE_DOWN}, file_editor.page_down)

        factory.modifiers = {.Shift}
        factory->register({.Char}, commands.insert_character)
        factory->register({.ENTER}, commands.insert_line_above)

        factory.modifiers = {.Ctrl}
        factory->register({.F, .Char}, file_editor.jump_to_character)
        factory->register({.F, .Char}, file_editor.jump_to_character, {.Shift})
        factory->register({.T, .Char}, file_editor.jump_back_to_character)
        factory->register({.T, .Char}, file_editor.jump_back_to_character, {.Shift})
        factory->register({.H}, file_editor.move_cursor_left)
        factory->register({.L}, file_editor.move_cursor_right)
        factory->register({.K}, file_editor.move_cursor_up)
        factory->register({.J}, file_editor.move_cursor_down)
        factory->register({.Num, .H}, file_editor.move_cursor_left)
        factory->register({.Num, .L}, file_editor.move_cursor_right)
        factory->register({.Num, .K}, file_editor.move_cursor_up)
        factory->register({.Num, .J}, file_editor.move_cursor_down)
        factory->register({.ENTER}, commands.insert_line_below)
        factory->register({.D, .D}, commands.delete_lines_below)
        factory->register({.D, .Num, .D}, commands.delete_lines_below)
        factory->register({.S}, commands.save)
        factory->register({.V}, commands.paste_from_system_clipboard)
        factory->register({.C}, commands.copy_line_to_system_clipboard)
        factory->register({.Z}, commands.undo)
        factory->register({.W}, commands.close)

        factory.modifiers = {.Ctrl, .Shift}
        factory->register({.ENTER}, commands.insert_line_above)
        factory->register({.D, .Num, .D}, commands.delete_lines_above)
        factory->register({.Z}, commands.redo)
    }

    {     // File Browser Commands
        factory := command.factory_create(state, glo.CMD_FILE_BROWSER)
        factory->register({.Char}, file_browser.insert_character)
        factory->register({.LEFT}, file_browser.move_cursor_left)
        factory->register({.RIGHT}, file_browser.move_cursor_right)
        factory->register({.UP}, file_browser.move_cursor_up)
        factory->register({.DOWN}, file_browser.move_cursor_down)
        factory->register({.BACKSPACE}, file_browser.delete_behind)
        factory->register({.DELETE}, file_browser.delete_ahead)
        factory->register({.ENTER}, file_browser.submit)

        factory.modifiers = {.Shift}
        factory->register({.Char}, file_browser.insert_character)
    }

    {     // Tree Viewer Commands
        command.register(state, glo.CMD_TREE_VIEWER, {}, {.UP}, viewer.move_cursor_up)
        command.register(state, glo.CMD_TREE_VIEWER, {}, {.DOWN}, viewer.move_cursor_down)
    }

    layout.activate_layout(state, glo.LAYOUT_SINGLE)
    state.portals[0].buffer = buffer_id
}

set_harpoon_mark :: proc(state: ^core.EditorState, wildcards: []core.WildcardValue) -> bool {
    command.validate_wildcards(wildcards, {.Char}, "set_harpoon_mark") or_return
    active_portal := portal.get_active_portal(state)

    MARK_BINDS :: "hjkl;"
    mark_index := strings.index_byte(MARK_BINDS, wildcards[0].(byte))

    if mark_index == -1 do return false

    mark := &glo.HARPOON_MARKS[mark_index]

    active_buffer, buffer_exists := buffer.get_buffer(state, active_portal.buffer)
    if buffer_exists {
        mark.buffer_id = active_portal.buffer

        first_character_index := strings.last_index(active_buffer.file_path, "\\") + 1
        mark.label = active_buffer.file_path[first_character_index:first_character_index + 1]
    } else {
        mark.buffer_id = 0
        mark.label = ""
    }

    return true
}

open_harpoon_mark :: proc(state: ^core.EditorState, wildcards: []core.WildcardValue) -> bool {
    command.validate_wildcards(wildcards, {.Char}, "set_harpoon_mark") or_return
    active_portal := portal.get_active_portal(state)

    MARK_BINDS :: "hjkl;"
    mark_index := strings.index_byte(MARK_BINDS, wildcards[0].(byte))

    if mark_index == -1 do return false

    mark := &glo.HARPOON_MARKS[mark_index]

    if mark.buffer_id != 0 {
        active_portal.buffer = mark.buffer_id
        file_editor.center_cursor(state, active_portal)
    } else {
        open_file_browser(state, nil)
    }


    return true
}
