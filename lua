local client, entity, ui, bit = client, entity, ui, bit
local bit_band = bit.band
local client_set_event_callback, client_userid_to_entindex = client.set_event_callback, client.userid_to_entindex
local entity_get_local_player, entity_is_alive, entity_get_prop, entity_get_player_weapon 
= entity.get_local_player, entity.is_alive, entity.get_prop, entity.get_player_weapon
local ui_get, ui_set, ui_new_checkbox, ui_new_slider, ui_new_combobox, ui_new_multiselect, ui_reference, ui_set_visible, ui_set_callback 
= ui.get, ui.set, ui.new_checkbox, ui.new_slider, ui.new_combobox, ui.new_multiselect, ui.reference, ui.set_visible, ui.set_callback
local pairs, print = pairs, print
local table_sort = table.sort

local adaptive_weapons = {
    ["Global"] = {},
    ["Auto"] = {11, 38},
    ["Awp"] = {9},
    ["Scout"] = {40},
    ["Desert Eagle"] = {1},
    ["Revolver"] = {64},
    ["Pistol"] = {2, 3, 4, 30, 32, 36, 61, 63},
    ["Rifle"] = {7, 8, 10, 13, 16, 39, 60},
    
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

local multipoint_hitbox, _, multipoint_level = ui_reference("RAGE", "Aimbot", "Multi-point")

local reference = {
    target_selection = ui_reference("RAGE", "Aimbot", "Target selection"),
    target_hitbox = ui_reference("RAGE", "Aimbot", "Target hitbox"),
    avoid_limbs = ui_reference("RAGE", "Aimbot", "Avoid limbs if moving"),
    avoid_head = ui_reference("RAGE", "Aimbot", "Avoid head if jumping"),
    multipoint_hitbox = multipoint_hitbox,
    multipoint_level = multipoint_level,
    multipoint_scale = ui_reference("RAGE", "Aimbot", "Multi-point scale"),
    dynamic_multipoint = ui_reference("RAGE", "Aimbot", "Dynamic multi-point"),
    stomach_scale = ui_reference("RAGE", "Aimbot", "Stomach hitbox scale"),
    automatic_fire = ui_reference("RAGE", "Aimbot", "Automatic fire"),
    automatic_penetration = ui_reference("RAGE", "Aimbot", "Automatic penetration"),
    silent_aim = ui_reference("RAGE", "Aimbot", "Silent aim"),
    minimum_hitchance = ui_reference("RAGE", "Aimbot", "Minimum hit chance"),
    minimum_damage = ui_reference("RAGE", "Aimbot", "Minimum damage"),
    automatic_scope = ui_reference("RAGE", "Aimbot", "Automatic scope"),
    maximum_fov = ui_reference("RAGE", "Aimbot", "Maximum fov"),
    accuracy_boost = ui_reference("RAGE", "Other", "Accuracy boost"),
    accuracy_options = ui_reference("RAGE", "Other", "Accuracy boost options"),
    quick_stop = ui_reference("RAGE", "Other", "Quick stop"),
    quick_stop_fire = ui_reference("RAGE", "Other", "Quick stop in fire"),
    quick_peek_assist = ui_reference("RAGE", "Other", "Quick peek assist"),
    prefer_baim = ui_reference("RAGE", "Other", "Prefer body aim"),
}

local adaptive = {}
local current_key = "Global"
local cached_key


local function get_menu_items(table)
    local names = {}
    for k in pairs(table) do
        names[#names + 1] = k
    end
    table_sort(names)
    return names
end

local function table_contains(table, item)
    for i=1, #table do
        if table[i] == item then
            return true
        end
    end
    return false
end

local function find_key(value)
    for k, v in pairs(adaptive_weapons) do
        if table_contains(v, value) then
            return k
        end
    end
    return "Global"
end

local menu = {
    adaptive_config = ui_new_checkbox("RAGE", "Other", "Adaptive weapon config"),
    adaptive_options = ui_new_multiselect("RAGE", "Other", "Adaptive options", "Log", "Hide"),
    adaptive_weapons = ui_new_combobox("RAGE", "Aimbot", "Adaptive config", get_menu_items(adaptive_weapons)),
}

local function generate_menu()
    for name in pairs(adaptive_weapons) do
        adaptive[name] = {
            target_selection = ui_new_combobox("RAGE", "Aimbot", name .. " target selection", "Cycle", "Cycle (2x)", "Near crosshair", "Highest damage", "Lowest ping", "Best K/D ratio", "Best hit chance"),
            target_hitbox = ui_new_multiselect("RAGE", "Aimbot", name .. " target hitbox", "Head", "Chest", "Stomach", "Arms", "Legs", "Feet"),
            avoid_limbs = ui_new_checkbox("RAGE", "Aimbot", name .. " avoid limbs if moving"),
            avoid_head = ui_new_checkbox("RAGE", "Aimbot", name .. " avoid head if jumping"),
            multipoint_hitbox = ui_new_multiselect("RAGE", "Aimbot", name .. " multi-point", "Head", "Chest", "Stomach", "Arms", "Legs", "Feet"),
            multipoint_level = ui_new_combobox("RAGE", "Aimbot", name .. " multi-point level", "Low", "Medium", "High"),
            multipoint_scale = ui_new_slider("RAGE", "Aimbot", name .. " multi-point scale", 24, 100, 24, true, "%", 1, multipoint_override),
            dynamic_multipoint = ui_new_checkbox("RAGE", "Aimbot", name .. " dynamic multi-point"),
            stomach_scale = ui_new_slider("RAGE", "Aimbot", name .. " stomach scale", 1, 100, 100, true, "%"),
            automatic_fire = ui_new_checkbox("RAGE", "Aimbot", name .. " automatic fire"),
            automatic_penetration = ui_new_checkbox("RAGE", "Aimbot", name .. " automatic penetration"),
            silent_aim = ui_new_checkbox("RAGE", "Aimbot", name .. " silent aim"),
            minimum_hitchance = ui_new_slider("RAGE", "Aimbot", name .. " minimum hit chance", 0, 100, 50, true, "%", 1, hitchance_override),
            minimum_damage = ui_new_slider("RAGE", "Aimbot", name .. " minimum damage", 0, 126, 0, true, "%", 1, mindamage_override),
            automatic_scope = ui_new_checkbox("RAGE", "Aimbot", name .. " automatic scope"),
            maximum_fov = ui_new_slider("RAGE", "Aimbot", name .. " maximum fov", 1, 180, 180, true, "°"),
            accuracy_boost = ui_new_combobox("RAGE", "Other", name .. " accuracy boost", "Off", "Low", "Medium", "High", "Maximum"),
            accuracy_options = ui_new_multiselect("RAGE", "Other", name .. " accuracy boost options", "Refine shot", "Extended backtrack"),
            quick_stop = ui_new_combobox("RAGE", "Other", name .. " quick stop", "Off", "On", "On + duck", "On + slow motion"),
            quick_stop_fire = ui_new_checkbox("RAGE", "Other", name .. " quick stop in fire"),
            quick_peek_assist = ui_new_checkbox("RAGE", "Other", name .. " quick peek assist"),
            prefer_baim = ui_new_combobox("RAGE", "Other", name .. " prefer body aim", "Off", "Always on", "Moving targets", "Aggressive", "High inaccuracy"),
        }
    end
end

generate_menu()

local function set_config(config)
    if not ui_get(menu.adaptive_config) then
        return
    end
    local active = adaptive[config]
    for name, ref in pairs(reference) do
        ui_set(ref, ui_get(active[name]))
    end
end

local function handle_adaptive_visible()
    local current_config = ui_get(menu.adaptive_weapons)
    local references = adaptive[current_config]
    local hitboxes = ui_get(references.target_hitbox)
    local multipoint = ui_get(references.multipoint_hitbox)
    if #hitboxes == 0 then
        ui_set(references.target_hitbox, "Head")
    end
    if current_config == current_key then
        set_config(current_config)
    end
    local visible = ui_get(menu.adaptive_config) and not table_contains(ui_get(menu.adaptive_options), "Hide")
    -- Special menu item cases
    ui_set_visible(references.avoid_head, visible and table_contains(hitboxes, "Head"))
    ui_set_visible(references.avoid_limbs, visible and (table_contains(hitboxes, "Arms") or table_contains(hitboxes, "Legs") or table_contains(hitboxes, "Feet")))
    ui_set_visible(references.multipoint_level, visible and #multipoint > 0)
    ui_set_visible(references.multipoint_scale, visible and #multipoint > 0)
    ui_set_visible(references.dynamic_multipoint, visible and #multipoint > 0)
    ui_set_visible(references.accuracy_options, visible and ui_get(references.accuracy_boost) ~= "Off")
    ui_set_visible(references.prefer_baim, visible and table_contains(hitboxes, "Head") and #hitboxes > 1)
end

for k, v in pairs(adaptive) do
    for name in pairs(reference) do
        ui_set_callback(v[name], handle_adaptive_visible)
    end
end

local function handle_adaptive()
    local state = ui_get(menu.adaptive_config)
    local current_config = ui_get(menu.adaptive_weapons)
    local options = ui_get(menu.adaptive_options)
    for config, items in pairs(adaptive) do
        local visible = current_config == config and state and not table_contains(options, "Hide")
        local hitboxes = ui_get(items.target_hitbox)
        for name in pairs(reference) do
            ui_set_visible(items[name], visible)
        end
        if #hitboxes == 0 then
            ui_set(items.target_hitbox, "Head")
        end 
        if visible then
            handle_adaptive_visible()
        end
    end
end

handle_adaptive()
ui_set_callback(menu.adaptive_weapons, handle_adaptive)
ui_set_callback(menu.adaptive_options, handle_adaptive)

local function handle_menu()
    local state = ui_get(menu.adaptive_config)
    ui_set_visible(menu.adaptive_weapons, state)
    ui_set_visible(menu.adaptive_options, state)
    handle_adaptive()
end

handle_menu()
ui_set_callback(menu.adaptive_config, handle_menu)

local function update_menu(key)
    ui_set(menu.adaptive_weapons, key)
    handle_adaptive()
end

client_set_event_callback("run_command", function()
    if not ui_get(menu.adaptive_config) then
        return
    end
    local weapon_index = entity_get_player_weapon(entity_get_local_player())
    local item_index = bit_band(65535, entity_get_prop(weapon_index, "m_iItemDefinitionIndex"))
    current_key = find_key(item_index)
    if current_key ~= cached_key then
        if table_contains(ui_get(menu.adaptive_options), "Log") then
            print(current_key, " config loaded")
        end
        set_config(current_key)
        update_menu(current_key)
    end
    cached_key = current_key
end)
