package user

import "bred:colors"

import glo "user:globals"

register_theme :: proc() {
    colors.register_default_color(glo.WHITE)

    // KEYWORDS
    colors.register_color("include", glo.ORANGE)
    colors.register_color("keyword", glo.ORANGE)
    colors.register_color("storageclass", glo.ORANGE)
    colors.register_color("conditional", glo.ORANGE)
    colors.register_color("repeat", glo.ORANGE)
    colors.register_color("punctuation.special", glo.ORANGE)

    // CONSTANTS
    colors.register_color("namespace", glo.PURPLE)
    colors.register_color("constant", glo.PURPLE)
    colors.register_color("type", glo.PURPLE)
    // colors.register_color("type.builtin", _)
    colors.register_color("preproc", glo.PURPLE)

    // FUNCTIONS
    colors.register_color("function", glo.PEACH)
    colors.register_color("label", glo.PEACH)

    // LITERALS
    colors.register_color("number", glo.BLUE)
    colors.register_color("float", glo.BLUE)
    colors.register_color("boolean", glo.BLUE)
    colors.register_color("constant.builtin", glo.BLUE)

    // STRINGS
    colors.register_color("string", glo.GREEN)
    colors.register_color("character", glo.GREEN)
    colors.register_color("string.escape", glo.PURPLE)

    // OTHER
    colors.register_color("spell", glo.GREY)
    colors.register_color("error", glo.RED)
}
