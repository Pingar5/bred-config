package ts_odin

import ts "bred:lib/treesitter/bindings"

when ODIN_OS == .Windows {
    foreign import ts_odin "parser.lib"
} else {
    foreign import ts_odin "parser.a"
}

foreign ts_odin {
    tree_sitter_odin :: proc() -> ts.Language ---
}

FOLDS :: #load("queries/folds.scm", string)

HIGHLIGHTS :: #load("queries/highlights.scm", string)

INDENTS :: #load("queries/indents.scm", string)

INJECTIONS :: #load("queries/injections.scm", string)

LOCALS :: #load("queries/locals.scm", string)
