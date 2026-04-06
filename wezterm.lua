-- Weihao's WezTerm config
-- https://github.com/swyzzwh/dotfiles

local wezterm = require 'wezterm'
local act = wezterm.action

local cfg = {
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
  use_fancy_tab_bar = false,  -- retro bar supports format-tab-title customization

  -- Treat terminal bell as an attention signal (Claude Code rings BEL on
  -- session finished / needs permission / needs action)
  audible_bell = "Disabled",
  visual_bell = {
    fade_in_duration_ms = 0,
    fade_out_duration_ms = 150,
    target = "CursorColor",
  },

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

    -- Copy / paste with plain Ctrl+C / Ctrl+V.
    -- Ctrl+C copies when there's a selection, otherwise sends SIGINT (\x03)
    -- so terminal interrupt behavior is preserved.
    {
      key = "c", mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        local sel = window:get_selection_text_for_pane(pane)
        if sel and #sel > 0 then
          window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
          window:perform_action(act.ClearSelection, pane)
        else
          window:perform_action(act.SendString("\x03"), pane)
        end
      end),
    },
    { key = "v", mods = "CTRL",      action = act.PasteFrom("Clipboard") },
    -- Keep Ctrl+Shift+C/V as an always-copy / always-paste fallback
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- Pane splits: Ctrl+Shift+| vertical divider (left/right), Ctrl+Shift+- horizontal divider (top/bottom)
    { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- Close current pane
    { key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "X", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

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

    -- Jump to tabs 1-9 (Ctrl+number) — cross-platform muscle memory
    { key = "1", mods = "CTRL", action = act.ActivateTab(0) },
    { key = "2", mods = "CTRL", action = act.ActivateTab(1) },
    { key = "3", mods = "CTRL", action = act.ActivateTab(2) },
    { key = "4", mods = "CTRL", action = act.ActivateTab(3) },
    { key = "5", mods = "CTRL", action = act.ActivateTab(4) },
    { key = "6", mods = "CTRL", action = act.ActivateTab(5) },
    { key = "7", mods = "CTRL", action = act.ActivateTab(6) },
    { key = "8", mods = "CTRL", action = act.ActivateTab(7) },
    { key = "9", mods = "CTRL", action = act.ActivateTab(8) },
  },
}

-- Track tabs that have rung the bell. Cleared when the tab becomes active.
-- Using a module-local table keyed by tab_id.
local tab_bell = {}

wezterm.on("bell", function(window, pane)
  -- Find which tab this pane belongs to and mark it
  local mux_win = window:mux_window()
  for _, item in ipairs(mux_win:tabs_with_info()) do
    for _, p in ipairs(item.tab:panes()) do
      if p:pane_id() == pane:pane_id() then
        if not item.is_active then
          tab_bell[item.tab:tab_id()] = true
        end
        return
      end
    end
  end
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  -- Clear the marker if this tab is active (user has seen it)
  if tab.is_active then
    tab_bell[tab.tab_id] = nil
  end

  local title = tab.tab_title
  if title == nil or #title == 0 then
    title = tab.active_pane.title
  end
  local idx = tab.tab_index + 1
  local label = " " .. idx .. ": " .. title .. " "

  -- Show bubble if bell fired OR pane has unseen output (belt and suspenders)
  local needs_attention = tab_bell[tab.tab_id]
    or (not tab.is_active and tab.active_pane.has_unseen_output)

  if needs_attention then
    return {
      { Background = { Color = "#ff3b30" } },
      { Foreground = { Color = "#ffffff" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " ● " },
      "ResetAttributes",
      { Text = label },
    }
  end
  return label
end)

return cfg
