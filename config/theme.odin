package user

import "bred:colors"

BG := colors.hex(0x2B2B2B) // bg
WHITE := colors.hex(0xDAE1E8) // fg
ORANGE := colors.hex(0xCC7832) // keyword, delimiter
PURPLE := colors.hex(0x9876AA) // constant
GREY := colors.hex(0x808080) // comment
GREEN := colors.hex(0x6A8759) // string
BLUE := colors.hex(0x6897BB) // number
PEACH := colors.hex(0xFFC66D) // function
RED := colors.hex(0xBC3F3C) // error

register_theme :: proc() {
    colors.register_default_color(WHITE)

    // KEYWORDS
    colors.register_color("include", ORANGE)
    colors.register_color("keyword", ORANGE)
    colors.register_color("storageclass", ORANGE)
    colors.register_color("conditional", ORANGE)
    colors.register_color("repeat", ORANGE)
    colors.register_color("punctuation.special", ORANGE)

    // CONSTANTS
    colors.register_color("namespace", PURPLE)
    colors.register_color("constant", PURPLE)
    colors.register_color("type", PURPLE)
    // colors.register_color("type.builtin", _)
    colors.register_color("preproc", PURPLE)

    // FUNCTIONS
    colors.register_color("function", PEACH)
    colors.register_color("label", PEACH)

    // LITERALS
    colors.register_color("number", BLUE)
    colors.register_color("float", BLUE)
    colors.register_color("boolean", BLUE)
    colors.register_color("constant.builtin", BLUE)

    // STRINGS
    colors.register_color("string", GREEN)
    colors.register_color("character", GREEN)
    colors.register_color("string.escape", PURPLE)

    // OTHER
    colors.register_color("spell", GREY)
    colors.register_color("error", RED)
}
