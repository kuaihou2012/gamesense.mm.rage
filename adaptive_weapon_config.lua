--------------------------------------------------------------------------------
-- Caching common functions
--------------------------------------------------------------------------------
local bit_band, client_delay_call, client_set_event_callback, entity_get_local_player, entity_get_player_weapon, entity_get_prop, print, func, select, table_insert, table_sort, type, ui_get, ui_name, ui_new_checkbox, ui_new_combobox, ui_new_multiselect, ui_reference, ui_set, ui_set_callback, ui_set_visible, xpcall, pairs = bit.band, client.delay_call, client.set_event_callback, entity.get_local_player, entity.get_player_weapon, entity.get_prop, print, func, select, table.insert, table.sort, type, ui.get, ui.name, ui.new_checkbox, ui.new_combobox, ui.new_multiselect, ui.reference, ui.set, ui.set_callback, ui.set_visible, xpcall, pairs

--------------------------------------------------------------------------------
-- Constants and variables
--------------------------------------------------------------------------------
local adaptive_weapons = {
    ["Global"]          = {},
    ["Auto"]            = {11, 38},
    ["Awp"]             = {9},
    ["Scout"]           = {40},
    ["Desert Eagle"]    = {1},
    ["Revolver"]        = {64},
    ["Pistol"]          = {2, 3, 4, 30, 32, 36, 61, 63},
    ["Rifle"]           = {7, 8, 10, 13, 16, 39, 60},
    --["Submachine gun"]  = {17, 19, 24, 26, 33, 34},
    --["Machine gun"]     = {14, 28},
    --["Shotgun"]         = {25, 27, 29, 35},
}

local multipoint_override = {
    [24] = "Auto",
}

local hitchance_override = {
    [0] = "Off",
}

local mindamage_override = {
    [0] = "Auto",
}

for i=1, 26 do
    mindamage_override[100 + i] = "HP + " .. i
end

local adaptive      = {}
local references    = {}
local callbacks     = {}
local active_config = "Global"
local weapon_id_lookup_table
local run_command

--------------------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------------------
local function collect_keys(tbl, sort)
    local keys = {}
    sort = sort or true
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    if sort then
        table_sort(keys)
    end
    return keys
end

local function table_contains(tbl, value)
    for i=1, #tbl do
        if tbl[i] == value then
            return true
        end
    end
    return false
end

local function table_compare(tbl1, tbl2)
    if #tbl1 ~= #tbl2 then
        return false
    end
    for i=1, #tbl1 do
        if tbl1[i] ~= tbl2[i] then
            return false
        end
    end
    return true
end

local function create_lookup_table(tbl)
    local result = {}
    for name, weapon_ids in pairs(tbl) do
        for i=1, #weapon_ids do
            result[weapon_ids[i]] = name
        end
    end
    return result
end

local function set_callback(reference, func)
    if callbacks[reference] == nil then
        callbacks[reference] = {ui_get(reference)}
    end
    table_insert(callbacks[reference], func)
end

local function menu_name(reference)
    return ui_name(reference) or "Multi-point level"
end

local function handle_callbacks()
    for reference, data in pairs(callbacks) do
        local value = ui_get(reference)
        local call
        if type(data[1]) == "table" then
            call = not table_compare(value, data[1])
        else
            call = value ~= data[1]
        end
        if call then
            for i=2, #data do
                xpcall(data[i], client.error_log, reference)
            end
        end
        data[1] = value
    end
    client_delay_call(0.01, handle_callbacks)
end

local function create_item(tab, container, name, arg, func, ...)
    local reference = select(arg, ui_reference(tab, container, name))
    name = menu_name(reference)
    references[name] = reference
    for config in pairs(adaptive_weapons) do
        local item_name = config .. " " .. name:lower()
        if adaptive[config] == nil then
            adaptive[config] = {}
        end
        adaptive[config][name] = func(tab, container, item_name, ...)
        if item_name == config .. " target hitbox" then
            ui_set(adaptive[config][name], {"Head"})
        end
    end
end

--------------------------------------------------------------------------------
-- Menu handling
--------------------------------------------------------------------------------
local adaptive_enabled  = ui_new_checkbox("RAGE", "Other", "Adaptive config")
local adaptive_options  = ui_new_multiselect("RAGE", "Other", "Config options", "Log", "Visible")
local adaptive_config   = ui_new_combobox("RAGE", "Aimbot", "Adaptive config", collect_keys(adaptive_weapons))

local function handle_menu()
    local state = ui_get(adaptive_enabled)
    if state then
        client.set_event_callback("run_command", run_command)
    else
        client.unset_event_callback("run_command", run_command)
    end
    ui_set_visible(adaptive_options, state)
    ui_set_visible(adaptive_config, state)
end

local function handle_config_menu()
    local state = ui_get(adaptive_enabled) and table_contains(ui_get(adaptive_options), "Visible")
    local config_name = ui_get(adaptive_config)
    if not state then
        ui_set(adaptive_config, active_config)
    end
    for config, items in pairs(adaptive) do
        local visible = state and config == config_name
        for name, reference in pairs(items) do
            ui_set_visible(reference, visible)
        end
    end
end

local function handle_adaptive_config()
    local config = ui_get(adaptive_config)
    if config == active_config then
        for name, reference in pairs(adaptive[config]) do
            ui_set(references[name], ui_get(reference))
        end
    end
end

local function update_menu(visible)
    ui_set(adaptive_config, active_config)
    if visible then
        handle_config_menu()
    end
end

--------------------------------------------------------------------------------
-- Config handling
--------------------------------------------------------------------------------
local function update_settings(reference)
    if ui_get(adaptive_enabled) then
        local config_name = ui_get(adaptive_config)
        if config_name == active_config then
            local item_name = menu_name(reference)
            ui_set(adaptive[config_name][item_name], ui_get(reference))
        end
    end
end

local function update_config_settings()
    if ui_get(adaptive_enabled) then
        local config_name = ui_get(adaptive_config)
        local config_items = adaptive[config_name]
        for name, reference in pairs(references) do
            ui_set(reference, ui_get(config_items[name]))
        end
    end
end

--------------------------------------------------------------------------------
-- Game event handling
--------------------------------------------------------------------------------
run_command = function()
    local local_player = entity_get_local_player()
    local weapon_entindex = entity_get_player_weapon(local_player)
    local item_definition_index = bit_band(65535, entity_get_prop(weapon_entindex, "m_iItemDefinitionIndex"))
    local config_name = weapon_id_lookup_table[item_definition_index] or "Global"
    if config_name ~= active_config then
        active_config = config_name
        local options = ui_get(adaptive_options)
        if table_contains(options, "Log") then 
            print(active_config, " config loaded.")
        end
        update_menu(table_contains(options, "Visible"))
        update_config_settings()
    end
end

--------------------------------------------------------------------------------
-- Initialization code
--------------------------------------------------------------------------------
local function init()
    -- Create and reference menu items
    create_item("RAGE", "Aimbot", "Target selection", 1, ui_new_combobox, "Cycle", "Cycle (2x)", "Near crosshair", "Highest damage", "Lowest ping", "Best K/D ratio", "Best hit chance")
    create_item("RAGE", "Aimbot", "Target hitbox", 1, ui_new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    create_item("RAGE", "Aimbot", "Avoid limbs if moving", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Avoid head if jumping", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Multi-point", 1, ui_new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    create_item("RAGE", "Aimbot", "Multi-point", 3, ui_new_combobox, "Low", "Medium", "High")
    create_item("RAGE", "Aimbot", "Multi-point scale", 1, ui.new_slider, 24, 100, 24, true, "%", 1, multipoint_override)
    create_item("RAGE", "Aimbot", "Dynamic multi-point", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Safe point", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Stomach hitbox scale", 1, ui.new_slider, 1, 100, 100, true, "%")
    create_item("RAGE", "Aimbot", "Automatic fire", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Automatic penetration", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Silent aim", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Minimum hit chance", 1, ui.new_slider, 0, 100, 50, true, "%", 1, hitchance_override)
    create_item("RAGE", "Aimbot", "Minimum damage", 1, ui.new_slider, 0, 126, 0, true, "%", 1, mindamage_override)
    create_item("RAGE", "Aimbot", "Automatic scope", 1, ui_new_checkbox)
    create_item("RAGE", "Aimbot", "Maximum FOV", 1, ui.new_slider, 1, 180, 180, true, "°")
    create_item("RAGE", "Other", "Accuracy boost", 1, ui_new_combobox, "Off", "Low", "Medium", "High", "Maximum")
    create_item("RAGE", "Other", "Accuracy boost options", 1, ui_new_multiselect, "Refine shot", "Extended backtrack")
    create_item("RAGE", "Other", "Quick stop", 1, ui_new_combobox, "Off", "On", "On + duck", "On + slow motion")
    create_item("RAGE", "Other", "Quick stop early", 1, ui_new_checkbox)
    create_item("RAGE", "Other", "Quick stop in fire", 1, ui_new_checkbox)
    create_item("RAGE", "Other", "Quick peek assist", 1, ui_new_checkbox)
    create_item("RAGE", "Other", "Prefer body aim", 1, ui_new_checkbox)
    create_item("RAGE", "Other", "Prefer body aim disablers", 1, ui_new_multiselect, "Low inaccuracy", "Target shot fired", "Target resolved", "Safe point headshot", "Low damage")
    create_item("RAGE", "Other", "Delay shot on peek", 1, ui_new_checkbox)

    -- Create the lookup table
    weapon_id_lookup_table = create_lookup_table(adaptive_weapons)

    -- Set custom callbacks for the default menu items
    for name, reference in pairs(references) do
        set_callback(reference, update_settings)
    end

    -- Set callbacks for all of the adaptive menu items
    for config, items in pairs(adaptive) do
        for name, reference in pairs(items) do
            ui_set_callback(reference, handle_adaptive_config)
        end
    end

    -- Call the menu handling functions so that they're handled on load
    handle_menu()
    handle_config_menu()

    -- Set callbacks on the main meun items
    ui_set_callback(adaptive_config, handle_config_menu)
    ui_set_callback(adaptive_options, handle_config_menu)
    ui_set_callback(adaptive_enabled, handle_menu)

    -- Start the callback recursive function
    handle_callbacks()

    -- Event callbacks
    client_set_event_callback("run_command", run_command)
end

init()
