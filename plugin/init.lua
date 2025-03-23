-- WezTerm Theme Rotator Plugin
-- Simplified version
local wezterm = require('wezterm')

-- Plugin module
local M = {}

-- Theme list (stored within the module, not as a global variable)
local theme_list = {}
local current_index = 1

-- Debug log function
local function log(message)
    wezterm.log_info("[theme-rotator] " .. message)
end

-- Create a list of themes
local function build_theme_list()
    local schemes = wezterm.color.get_builtin_schemes()
    local themes = {}

    for name, _ in pairs(schemes) do
        table.insert(themes, name)
    end

    table.sort(themes)
    log("Number of themes: " .. #themes)
    return themes
end

-- Switch to the next theme
local function next_theme(window)
    current_index = (current_index % #theme_list) + 1
    local new_theme = theme_list[current_index]
    log("Switching to the next theme: " .. new_theme .. " (" .. current_index .. "/" .. #theme_list .. ")")

    window:set_config_overrides({ color_scheme = new_theme })
    window:toast_notification('Wezterm', 'Next theme: ' .. new_theme, nil, 4000)
end

-- Switch to the previous theme
local function prev_theme(window)
    current_index = current_index - 1
    if current_index < 1 then
        current_index = #theme_list
    end

    local new_theme = theme_list[current_index]
    log("Switching to the previous theme: " .. new_theme .. " (" .. current_index .. "/" .. #theme_list .. ")")

    window:set_config_overrides({ color_scheme = new_theme })
    window:toast_notification('Wezterm', 'Previous theme: ' .. new_theme, nil, 4000)
end

-- Switch to a random theme
local function random_theme(window)
    math.randomseed(os.time())
    current_index = math.random(1, #theme_list)
    local new_theme = theme_list[current_index]
    log("Switching to a random theme: " .. new_theme)

    window:set_config_overrides({ color_scheme = new_theme })

    window:toast_notification('Wezterm', 'Random theme: ' .. new_theme, nil, 4000)
end

-- Display debug information
local function show_debug(window)
    local effective_config = window:effective_config()
    local current_theme = effective_config.color_scheme

    log("Displaying debug information: " .. current_theme)

    local info = 'Theme: ' .. current_theme ..
        '\nIndex: ' .. current_index ..
        '\nTotal themes: ' .. #theme_list

    window:toast_notification('Debug', info, nil, 6000)
end

-- Function to apply to configuration
function M.apply_to_config(config, options)
    options = options or {}

    -- Create a list of themes
    theme_list = build_theme_list()

    -- If a current theme is set, find its index
    if config.color_scheme then
        for i, theme_name in ipairs(theme_list) do
            if theme_name == config.color_scheme then
                current_index = i
                log("Using existing theme: " .. theme_name .. " (index: " .. i .. ")")
                break
            end
        end
    else
        -- If no theme is set, select one randomly
        local seed = os.time() % #theme_list + 1
        current_index = seed
        config.color_scheme = theme_list[current_index]
        log("Setting random theme: " .. config.color_scheme .. " (index: " .. current_index .. ")")
    end

    -- Display theme information in the status bar
    wezterm.on('update-right-status', function(window, pane)
        local effective_config = window:effective_config()
        window:set_right_status(effective_config.color_scheme .. " (" .. current_index .. "/" .. #theme_list .. ")")
    end)

    -- Configure key bindings
    local keys = {}

    -- Next theme (Cmd+Shift+T)
    table.insert(keys, {
        key = options.next_theme_key or 't',
        mods = options.next_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            next_theme(window)
        end),
    })

    -- Previous theme (Cmd+Shift+B)
    table.insert(keys, {
        key = options.prev_theme_key or 'b',
        mods = options.prev_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            prev_theme(window)
        end),
    })

    -- Random theme (Cmd+Shift+R)
    table.insert(keys, {
        key = options.random_theme_key or 'r',
        mods = options.random_theme_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            random_theme(window)
        end),
    })

    -- Debug information (Cmd+Shift+I)
    table.insert(keys, {
        key = options.debug_info_key or 'i',
        mods = options.debug_info_mods or 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            show_debug(window)
        end),
    })

    -- Add key bindings to the configuration
    config.keys = config.keys or {}
    for _, key_entry in ipairs(keys) do
        table.insert(config.keys, key_entry)
    end

    log("Theme rotator plugin initialized")
    return config
end

return M
