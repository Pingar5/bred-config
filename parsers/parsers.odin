package parsers

import ts "bred:lib/treesitter"

import "odin"

register_parsers :: proc() {
    ODIN, _ := ts.add_language(odin.tree_sitter_odin(), odin.HIGHLIGHTS, odin.LOCALS, odin.INJECTIONS)
    ts.register_extension(ODIN, "odin")
}
