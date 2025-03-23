# WezTerm Theme Rotator

A plugin for WezTerm that allows you to easily switch between all built-in themes using keyboard shortcuts.

<https://wezterm.org/config/plugins.html>

<https://github.com/user-attachments/assets/b34ec3f1-eee4-41f3-8af6-275c9353574c>

## Features

- Cycle through all built-in WezTerm themes sequentially
- Apply random themes
- Switch back to your default theme with a single keystroke
- Display theme information in the status bar (theme name and index)
- Customizable key bindings

## Installation

### Install as a Plugin

Add the following code to your `wezterm.lua` file:

```lua
local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Load the theme rotator plugin
local theme_rotator = wezterm.plugin.require 'https://github.com/koh-sh/wezterm-theme-rotator'

-- Apply the plugin
theme_rotator.apply_to_config(config)

return config
```

### How It Works

This configuration adds key bindings to your `config.keys` for theme switching, allowing you to rotate through WezTerm's built-in themes with keyboard shortcuts.

## Usage

By default, the following keyboard shortcuts are available:

- `Super+Shift+N`: Switch to the next theme (on macOS, `Cmd+Shift+N`)
- `Super+Shift+P`: Switch to the previous theme (on macOS, `Cmd+Shift+P`)
- `Super+Shift+R`: Apply a random theme (on macOS, `Cmd+Shift+R`)
- `Super+Shift+D`: Switch back to the default theme (on macOS, `Cmd+Shift+D`)

The status bar in the upper right corner displays the current theme name and theme number (e.g., `Adventure (14/1079)`).

## Theme Inheritance

If you have already specified a theme in your existing configuration, the plugin will respect that setting and start from that theme.
For example, if `color_scheme` is already defined as follows:

```lua
config.color_scheme = 'Adventure'
theme_rotator.apply_to_config(config)
```

When the plugin is applied, it will start from "Adventure" and allow you to cycle through themes from there. The initial theme will also be set as the default theme, which you can return to by pressing `Super+Shift+D`.

If no theme is set in your configuration, the first theme will be used as the starting and default theme.

## Random Theme Selection

When you use the random theme feature (`Super+Shift+R`), the plugin randomly selects one theme from all available themes. This makes it easy to explore themes and discover new looks for your terminal.

## Customizing Key Bindings (Optional)

You can customize the key bindings in your `wezterm.lua` file as follows:

```lua
-- Custom configuration example
local theme_rotator = wezterm.plugin.require 'https://github.com/koh-sh/wezterm-theme-rotator'

-- Plugin configuration (customize key bindings)
theme_rotator.apply_to_config(config, {
  -- Customize "Next Theme" key
  next_theme_key = 'n',
  next_theme_mods = 'SUPER|SHIFT',

  -- Customize "Previous Theme" key
  prev_theme_key = 'p',
  prev_theme_mods = 'SUPER|SHIFT',

  -- Customize "Random Theme" key
  random_theme_key = 'r',
  random_theme_mods = 'SUPER|SHIFT',

  -- Customize "Default Theme" key
  default_theme_key = 'd',
  default_theme_mods = 'SUPER|SHIFT'
})
```

## Updating the Plugin

To update the plugin, you can use the Lua REPL in WezTerm's debug overlay or pull the repository updates:

<https://wezterm.org/troubleshooting.html#debug-overlay>

```lua
-- Run from the WezTerm console
wezterm.plugin.update_all()
```
