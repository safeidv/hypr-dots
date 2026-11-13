-- Input configuration

hl.config({
    input = {
		-- accel_profile = 'flat',
		-- sensitivity = -0.00,
		force_no_accel = true,
		kb_layout = "us,ru",
		kb_options = "grp:caps_toggle",
		repeat_rate = 35,
		repeat_delay = 350,
		follow_mouse = 2,
    hl.device({
        name = "at-translated-set-2-keyboard",
        enabled = false
    }),
    hl.device({
    	name = "etps/2-elantech-touchpad",
    	enabled = false
	}),
	hl.device({
	    name = "elan0412:01-04f3:3240-mouse",
	    enabled = false
	})

},
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})



hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
