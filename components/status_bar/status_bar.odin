package status_bar

import "core:strings"
import rl "vendor:raylib"

import "bred:colors"
import "bred:core"
import "bred:core/buffer"
import "bred:core/font"
import "bred:util"

import glo "user:globals"

WIDTH :: 21

@(private)
draw_modifier :: proc(mod: core.ModifierState, mod_str: string, rect: core.Rect) {
    fg: rl.Color = glo.GREY
    if mod.enabled || mod.held {
        bg := mod.locked ? glo.ORANGE : glo.BLUE
        fg = colors.TEXT
        rl.DrawRectangle(i32(rect.left), i32(rect.top), i32(rect.width), i32(rect.height), bg)
    }

    font.write_free_centered({f32(rect.left + rect.width / 2), f32(rect.top)}, mod_str, fg)
}

create_status_bar :: proc(rect: core.Rect) -> core.Portal {
    render_status_bar :: proc(self: ^core.Portal, state: ^core.EditorState) {
        font.draw_bg_rect(self.rect, colors.STATUS_BAR_BACKGROUND)

        screen_rect := font.font_rect_to_screen(self.rect)


        {     // Modifier Line
            modifier_width := (screen_rect.width - 2) / 3
            text_height := int(font.ACTIVE_FONT.size)
            modifier_rect := core.Rect {
                components = {
                    screen_rect.left,
                    screen_rect.top + screen_rect.height - text_height,
                    modifier_width,
                    text_height,
                },
            }

            draw_modifier(state.motion_buffer.ctrl, "CTRL", modifier_rect)
            modifier_rect.left += modifier_width
            draw_modifier(state.motion_buffer.shift, "SHIFT", modifier_rect)
            modifier_rect.left += modifier_width
            modifier_rect.width = (screen_rect.width - 2) - modifier_rect.left
            draw_modifier(state.motion_buffer.alt, "ALT", modifier_rect)
        }

        {     // Motion Line
            motion_buffer := &state.motion_buffer
            if motion_buffer.keys_length > 0 {
                for key_idx in 0 ..< motion_buffer.keys_length {
                    key := motion_buffer.keys[key_idx]
                    key_str := util.key_to_str(key)

                    font.write(
                        self.rect.start + {self.rect.width / 2, self.rect.height - 2},
                        key_str,
                        glo.WHITE,
                        .Center,
                    )
                }
            }
        }

        {     // File Path Line
            active_buffer, ok := buffer.get_active_buffer(state)

            if ok {
                file_name := active_buffer.file_path[strings.last_index(
                    active_buffer.file_path,
                    "\\",
                ) +
                1:]

                color := glo.ORANGE if active_buffer.is_dirty else glo.WHITE
                
                font.write(self.rect.start + {self.rect.width / 2, 0}, file_name, color, .Center)
            }
        }

        // Draw Border
        rl.DrawRectangle(
            i32(screen_rect.left + screen_rect.width - 2),
            i32(screen_rect.top),
            2,
            i32(screen_rect.height),
            glo.GREY,
        )
    }

    return {type = "status_bar", rect = rect, render = render_status_bar}
}
