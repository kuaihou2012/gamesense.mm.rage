local ui_get, ui_set, ui_ref = ui.get, ui.set, ui.reference
local entity_get_local_player = entity.get_local_player
local client_set_event_callback = client.set_event_callback
local renderer_indicator = renderer.indicator
local freestanding, freestanding_key = ui_ref("AA", "Anti-aimbot angles", "Freestanding")

client_set_event_callback("paint", function()
    if entity_get_local_player() == nil then return end

    local bFreezeTime = entity.get_prop(entity.get_game_rules(), "m_bFreezePeriod")
    if (bFreezeTime) == 1 then return end

    if ui_get(freestanding_key) then
        renderer_indicator(124, 195, 13, 255, "FS")
    else 
        return
    end
end)
