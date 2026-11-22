-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- Personal input preferences (from ~/code/github/dotfiles/hypr/hyprland.lua).
-- Settings not listed here keep Omarchy's defaults.
hl.config({
  input = {
    kb_layout = "us",

    -- Change speed of keyboard repeat.
    repeat_rate = 25,
    repeat_delay = 300,

    -- Focus follows clicks, not the mouse pointer.
    follow_mouse = 0,
    float_switch_override_focus = 0,

    -- No sensitivity change for mouse/trackpad.
    sensitivity = 0,

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.2,
    },
  },
})

-- Swipe three fingers horizontally to change workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
-- o.window("foot", { scroll_touchpad = 2.0 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
