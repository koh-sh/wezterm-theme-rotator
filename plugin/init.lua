-- WezTerm Theme Rotator Plugin
--
-- A plugin that allows rotating through WezTerm's built-in color schemes
-- with keyboard shortcuts and visual feedback.

local wezterm = require('wezterm')

-- Plugin module
local ThemeRotator = {}

-- Internal state
local state = {
    themes = {},      -- List of available themes
    current_index = 1 -- Current theme index
}

-----------------------------------------------------------
-- Core Functions
-----------------------------------------------------------

-- Build a sorted list of all available color schemes
local function build_theme_list()
    local schemes = wezterm.color.get_builtin_schemes()
    local themes = {}

    for name, _ in pairs(schemes) do
        table.insert(themes, name)
    end

    table.sort(themes)
    return themes
end

-- Find the index of a theme in the theme list
local function find_theme_index(theme_name)
    for i, name in ipairs(state.themes) do
        if name == theme_name then
            return i
        end
    end
    return 1 -- Default to first theme if not found
end

-- Change the color scheme and show notification
local function apply_theme(window, new_index, operation_name)
    state.current_index = new_index
    local theme_name = state.themes[state.current_index]

    window:set_config_overrides({ color_scheme = theme_name })
    window:toast_notification('WezTerm Theme', operation_name .. ': ' .. theme_name, nil, 4000)
end

-----------------------------------------------------------
-- Theme Operations
-----------------------------------------------------------

-- Switch to the next theme
local function next_theme(window)
    local new_index = (state.current_index % #state.themes) + 1
    apply_theme(window, new_index, 'Next theme')
end

-- Switch to the previous theme
local function prev_theme(window)
    local new_index = state.current_index - 1
    if new_index < 1 then
        new_index = #state.themes
    end
    apply_theme(window, new_index, 'Previous theme')
end

-- Switch to a random theme
local function random_theme(window)
    -- Set random seed with integer value
    math.randomseed(os.time())

    -- Ensure we select a different theme than the current one
    local current_theme_index = state.current_index
    local new_index = current_theme_index

    -- Keep trying until we get a different theme
    while new_index == current_theme_index do
        new_index = math.random(1, #state.themes)
    end

    apply_theme(window, new_index, 'Random theme')
end

-- Display debug information
local function show_debug(window)
    local effective_config = window:effective_config()
    local current_theme = effective_config.color_scheme

    local info = string.format(
        'Theme: %s\nIndex: %d\nTotal themes: %d',
        current_theme,
        state.current_index,
        #state.themes
    )

    window:toast_notification('Theme Debug Info', info, nil, 6000)
end

-- Update the right status with current theme information
local function update_status(window, pane)
    local effective_config = window:effective_config()
    local status_text = string.format(
        "%s (%d/%d)",
        effective_config.color_scheme,
        state.current_index,
        #state.themes
    )
    window:set_right_status(status_text)
end

-----------------------------------------------------------
-- Configuration
-----------------------------------------------------------

-- Configure key bindings based on options
local function setup_key_bindings(options)
    local keys = {}

    -- Next theme key binding
    table.insert(keys, {
        key = options.next_theme_key or 't',
        mods = options.next_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            next_theme(window)
        end),
    })

    -- Previous theme key binding
    table.insert(keys, {
        key = options.prev_theme_key or 'b',
        mods = options.prev_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            prev_theme(window)
        end),
    })

    -- Random theme key binding
    table.insert(keys, {
        key = options.random_theme_key or 'r',
        mods = options.random_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            random_theme(window)
        end),
    })

    -- Debug info key binding
    table.insert(keys, {
        key = options.debug_info_key or 'i',
        mods = options.debug_info_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            show_debug(window)
        end),
    })

    return keys
end

-- Initialize theme state based on config
local function initialize_theme_state(config)
    -- Build theme list
    state.themes = build_theme_list()

    -- Set initial theme index
    if config.color_scheme then
        state.current_index = find_theme_index(config.color_scheme)
    else
        -- If no theme is set, select one randomly
        math.randomseed(os.time())
        state.current_index = math.random(#state.themes)
        config.color_scheme = state.themes[state.current_index]
    end
end

-----------------------------------------------------------
-- Public API
-----------------------------------------------------------

-- Apply configuration to WezTerm
function ThemeRotator.apply_to_config(config, options)
    options = options or {}

    -- Initialize theme state
    initialize_theme_state(config)

    -- Setup status bar updater
    wezterm.on('update-right-status', update_status)

    -- Setup key bindings
    local keys = setup_key_bindings(options)

    -- Add key bindings to the configuration
    config.keys = config.keys or {}
    for _, key_entry in ipairs(keys) do
        table.insert(config.keys, key_entry)
    end

    return config
end

return ThemeRotator
