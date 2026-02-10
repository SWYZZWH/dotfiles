-- Weihao's WezTerm config
-- https://github.com/swyzzwh/dotfiles

local wezterm = require 'wezterm'
local act = wezterm.action

return {
  -- Visuals
  font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "Symbols Nerd Font" }),
  font_size = 13.0,
  color_scheme = "Tokyo Night",
  window_background_opacity = 0.90,
  macos_window_background_blur = 20,

  -- Keep glass effect in fullscreen (don't create separate macOS Space)
  native_macos_fullscreen_mode = false,

  -- Tabs
  enable_tab_bar = true,
  use_fancy_tab_bar = true,

  -- Window chrome
  window_decorations = "RESIZE",

  -- Keybindings
  keys = {
    -- Fullscreen (glass stays)
    { key = "F11", mods = "",        action = act.ToggleFullScreen },

    -- Maximize window
    {
      key = "F10", mods = "",
      action = wezterm.action_callback(function(window, _)
        window:maximize()
      end),
    },

    -- New/close tab (Mac muscle memory)
    { key = "t", mods = "CMD",       action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CMD",       action = act.CloseCurrentTab({ confirm = true }) },

    -- Tab switching
    { key = "Tab", mods = "CTRL",        action = act.ActivateTabRelative(1)  },
    { key = "Tab", mods = "CTRL|SHIFT",  action = act.ActivateTabRelative(-1) },
    { key = "]",   mods = "CMD|ALT",     action = act.ActivateTabRelative(1)  },
    { key = "[",   mods = "CMD|ALT",     action = act.ActivateTabRelative(-1) },

    -- Jump to tabs 1-9 (Cmd+number)
    { key = "1", mods = "CMD", action = act.ActivateTab(0) },
    { key = "2", mods = "CMD", action = act.ActivateTab(1) },
    { key = "3", mods = "CMD", action = act.ActivateTab(2) },
    { key = "4", mods = "CMD", action = act.ActivateTab(3) },
    { key = "5", mods = "CMD", action = act.ActivateTab(4) },
    { key = "6", mods = "CMD", action = act.ActivateTab(5) },
    { key = "7", mods = "CMD", action = act.ActivateTab(6) },
    { key = "8", mods = "CMD", action = act.ActivateTab(7) },
    { key = "9", mods = "CMD", action = act.ActivateTab(8) },
  },
}
