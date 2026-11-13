-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,
        border_size = 3,
        resize_on_border = false,
        col = {
            active_border = {
                colors = { CACHYLGREEN, CACHYDGREEN },
                angle = 45,
            },
            inactive_border = CACHYGRAY,
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.97,
        inactive_opacity = 0.9,
        fullscreen_opacity = 1,
        blur = {
            enabled = false,
            size = 4,
            passes = 2,
            special = false,
            new_optimizations = true,
        },
        wobble = {
            enabled = true
        },
    },
})
