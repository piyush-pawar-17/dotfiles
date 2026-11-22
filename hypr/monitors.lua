-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
-- Monitor settings copied from ~/code/github/dotfiles/hypr/hyprland.lua

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = "1",
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",
	position = "1920x0",
	scale = "1",
})

-- Start cursor (and initial focus) on the BenQ on login
hl.config({ cursor = { default_monitor = "HDMI-A-1", no_warps = true } })

-- Workspace 1 lives on the BenQ (only applies while it's attached)
hl.workspace_rule({
	workspace = "1",
	monitor = "HDMI-A-1",
	default = true,
})

-- GDK scale is GDK_SCALE, the factor GTK draws its own UI at. GTK only honors
-- whole numbers, so use the nearest integer to the monitor scale.
local omarchy_gdk_scale = 1
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
