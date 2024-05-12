package globals

import "bred:core"

// COMMAND SETS
CMD_EDITOR: int
CMD_FILE_BROWSER: int
CMD_TREE_VIEWER: int

// LAYOUTS
LAYOUT_SINGLE: int
LAYOUT_DOUBLE: int
LAYOUT_TREE_VIEWER: int

// HARPOON
HARPOON_MARKS: [5]struct {
    buffer_id: core.BufferId,
    label:     string,
}
