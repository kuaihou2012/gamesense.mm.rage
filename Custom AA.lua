local client_latency, client_log, client_draw_rectangle, client_draw_circle_outline, client_userid_to_entindex, client_draw_indicator, client_draw_gradient, client_set_event_callback, client_screen_size, client_eye_position = client.latency, client.log, client.draw_rectangle, client.draw_circle_outline, client.userid_to_entindex, client.draw_indicator, client.draw_gradient, client.set_event_callback, client.screen_size, client.eye_position
local client_draw_circle, client_color_log, client_delay_call, client_draw_text, client_visible, client_exec, client_trace_line, client_set_cvar = client.draw_circle, client.color_log, client.delay_call, client.draw_text, client.visible, client.exec, client.trace_line, client.set_cvar
local client_world_to_screen, client_draw_hitboxes, client_get_cvar, client_draw_line, client_camera_angles, client_draw_debug_text, client_random_int, client_random_float = client.world_to_screen, client.draw_hitboxes, client.get_cvar, client.draw_line, client.camera_angles, client.draw_debug_text, client.random_int, client.random_float
local entity_get_local_player, entity_is_enemy, entity_hitbox_position, entity_get_player_name, entity_get_steam64, entity_get_bounding_box, entity_get_all, entity_set_prop = entity.get_local_player, entity.is_enemy, entity.hitbox_position, entity.get_player_name, entity.get_steam64, entity.get_bounding_box, entity.get_all, entity.set_prop
local entity_is_alive, entity_get_player_weapon, entity_get_prop, entity_get_players, entity_get_classname = entity.is_alive, entity.get_player_weapon, entity.get_prop, entity.get_players, entity.get_classname
local globals_realtime, globals_absoluteframetime, globals_tickcount, globals_curtime, globals_mapname, globals_tickinterval, globals_framecount, globals_frametime, globals_maxplayers = globals.realtime, globals.absoluteframetime, globals.tickcount, globals.curtime, globals.mapname, globals.tickinterval, globals.framecount, globals.frametime, globals.maxplayers
local ui_new_slider, ui_new_combobox, ui_reference, ui_set_visible, ui_is_menu_open, ui_new_color_picker, ui_set_callback, ui_set, ui_new_checkbox, ui_new_hotkey, ui_new_button, ui_new_multiselect, ui_get = ui.new_slider, ui.new_combobox, ui.reference, ui.set_visible, ui.is_menu_open, ui.new_color_picker, ui.set_callback, ui.set, ui.new_checkbox, ui.new_hotkey, ui.new_button, ui.new_multiselect, ui.get
local math_ceil, math_tan, math_log10, math_randomseed, math_cos, math_sinh, math_random, math_huge, math_pi, math_max, math_atan2, math_ldexp, math_floor, math_sqrt, math_deg, math_atan, math_fmod = math.ceil, math.tan, math.log10, math.randomseed, math.cos, math.sinh, math.random, math.huge, math.pi, math.max, math.atan2, math.ldexp, math.floor, math.sqrt, math.deg, math.atan, math.fmod
local math_acos, math_pow, math_abs, math_min, math_sin, math_frexp, math_log, math_tanh, math_exp, math_modf, math_cosh, math_asin, math_rad = math.acos, math.pow, math.abs, math.min, math.sin, math.frexp, math.log, math.tanh, math.exp, math.modf, math.cosh, math.asin, math.rad
local table_maxn, table_foreach, table_sort, table_remove, table_foreachi, table_move, table_getn, table_concat, table_insert = table.maxn, table.foreach, table.sort, table.remove, table.foreachi, table.move, table.getn, table.concat, table.insert
local string_find, string_format, string_rep, string_gsub, string_len, string_gmatch, string_dump, string_match, string_reverse, string_byte, string_char, string_upper, string_lower, string_sub = string.find, string.format, string.rep, string.gsub, string.len, string.gmatch, string.dump, string.match, string.reverse, string.byte, string.char, string.upper, string.lower, string.sub
 
local client_set_event_callback = client.set_event_callback
local client_draw_text = client.draw_text
local client_get_cvar = client.get_cvar
local client_screensize = client.screen_size
local client_exec = client.exec
 

local antiaims = {}
 
antiaims.ui_get, ui_set = ui.get, ui.set
antiaims.pitch = ui.reference("AA", "Anti-aimbot angles", "Pitch")
antiaims.yawbase = ui.reference("AA", "Anti-aimbot angles", "Yaw base")
antiaims.yaw, antiaims.yaw_slider = ui.reference("AA", "Anti-aimbot angles", "Yaw")
antiaims.yawjitter, antiaims.yawjitter_slider = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
antiaims.fakeyaw, antiaims.fakeyaw_slider = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
antiaims.freestandbodyyaw = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")
antiaims.lowerbodyyaw = ui.reference("AA", "Anti-aimbot angles", "Lower body yaw target")
antiaims.fakeyawlimit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit")
antiaims.edgeyaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw")
antiaims.freestanding = ui.reference("AA", "Anti-aimbot angles", "Freestanding")
antiaims.freestanding_duck = ui.reference("AA", "Anti-aimbot angles", "Freestanding ignore duck")
antiaims.ref_fakewalk, antiaims.ref_fakewalk_key = ui_reference("AA", "Other", "Slow motion")
 
menu_fakeyaw_ref, menu_fakeyaw_offset_ref = ui.reference("AA", "Anti-aimbot angles", "Body yaw")
 

local to_number = tonumber
local math_floor = math.floor
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove
local table_size = table.getn
local string_format = string.format
local delay_time = 0
 

local interface = {
    ref = ui.reference,
    visible = ui.set_visible,
    callback = ui.set_callback,
    multiselect = ui.new_multiselect,
    checkbox = ui.new_checkbox,
    slider = ui.new_slider,
    hotkey = ui.new_hotkey,
    combobox = ui.new_combobox,
    colorpicker = ui.new_color_picker
}
 
local cl = {
    log = client.log,
    indicator = client.draw_indicator,
    circle_outline = client.draw_circle_outline,
    circle = client.draw_circle,
    eye_pos = client.eye_position,
    camera_angles = client.camera_angles
}

local selector = interface.combobox("Lua", "A", "State", "Standing", "Moving", "Jumping", "Slow motion", "Crouching")

local standpitch = interface.combobox("Lua", "A", "Stand: Pitch", "Off", "Default", "Up", "Down", "Minimal", "Random")
local standyawbase = interface.combobox("Lua", "A", "Stand: Yaw base", "Local view", "At targets")
local standyaw = interface.combobox("Lua", "A", "Stand: Yaw", "Off", "180", "Spin", "Static", "180 Z", "Crosshair")
local standyawslider = interface.slider("Lua", "A", "Stand: Yaw angle", -180, 180, 0, true)
local standyawjitter = interface.combobox("Lua", "A", "Stand: Yaw jitter", "Off", "Offset", "Center", "Random")
local standyawjitter_slider = interface.slider("Lua", "A", "Stand: Yaw jitter range", -180, 180, 0, true)
local standfakeyaw = interface.combobox("Lua", "A", "Stand: Body yaw", "Off", "Opposite", "Jitter", "Static")
local standfakeyaw_slider = interface.slider("Lua", "A", "Stand: Body yaw angle", -180, 180, 0, true)
local standfreestandbodyyaw = interface.checkbox("Lua", "A", "Stand: Freestanding body yaw")
local standlowerbodyyaw = interface.combobox("Lua", "A", "Stand: Lower body yaw target", "Off", "Sway", "Opposite", "Eye yaw")
local standfakelimit = interface.slider("Lua", "A", "Stand: Fake yaw limit", 0, 60, 60, true)
local standedgeyaw = interface.combobox("Lua", "A", "Stand: Edge yaw", "Off", "Static")

local movepitch = interface.combobox("Lua", "A", "Move: Pitch", "Off", "Default", "Up", "Down", "Minimal", "Random")
local moveyawbase = interface.combobox("Lua", "A", "Move: Yaw base", "Local view", "At targets")
local moveyaw = interface.combobox("Lua", "A", "Move: Yaw", "Off", "180", "Spin", "Static", "180 Z", "Crosshair")
local moveyawslider = interface.slider("Lua", "A", "Move: Yaw angle", -180, 180, 0, true)
local moveyawjitter = interface.combobox("Lua", "A", "Move: Yaw jitter", "Off", "Offset", "Center", "Random")
local moveyawjitter_slider = interface.slider("Lua", "A", "Move: Yaw jitter range", -180, 180, 0, true)
local movefakeyaw = interface.combobox("Lua", "A", "Move: Body yaw", "Off", "Opposite", "Jitter", "Static")
local movefakeyaw_slider = interface.slider("Lua", "A", "Move: Body yaw angle", -180, 180, 0, true)
local movefreestandbodyyaw = interface.checkbox("Lua", "A", "Move: Freestanding body yaw")
local movelowerbodyyaw = interface.combobox("Lua", "A", "Move: Lower body yaw target", "Off", "Sway", "Opposite", "Eye yaw")
local movefakelimit = interface.slider("Lua", "A", "Move: Fake yaw limit", 0, 60, 60, true)
local moveedgeyaw = interface.combobox("Lua", "A", "Move: Edge yaw", "Off", "Static")

local jumppitch = interface.combobox("Lua", "A", "Jump: Pitch", "Off", "Default", "Up", "Down", "Minimal", "Random")
local jumpyawbase = interface.combobox("Lua", "A", "Jump: Yaw base", "Local view", "At targets")
local jumpyaw = interface.combobox("Lua", "A", "Jump: Yaw", "Off", "180", "Spin", "Static", "180 Z", "Crosshair")
local jumpyawslider = interface.slider("Lua", "A", "Jump: Yaw angle", -180, 180, 0, true)
local jumpyawjitter = interface.combobox("Lua", "A", "Jump: Yaw jitter", "Off", "Offset", "Center", "Random")
local jumpyawjitter_slider = interface.slider("Lua", "A", "Jump: Yaw jitter range", -180, 180, 0, true)
local jumpfakeyaw = interface.combobox("Lua", "A", "Jump: Body yaw", "Off", "Opposite", "Jitter", "Static")
local jumpfakeyaw_slider = interface.slider("Lua", "A", "Jump: Body yaw angle", -180, 180, 0, true)
local jumpfreestandbodyyaw = interface.checkbox("Lua", "A", "Jump: Freestanding body yaw")
local jumplowerbodyyaw = interface.combobox("Lua", "A", "Jump: Lower body yaw target", "Off", "Sway", "Opposite", "Eye yaw")
local jumpfakelimit = interface.slider("Lua", "A", "Jump: Fake yaw limit", 0, 60, 60, true)
local jumpedgeyaw = interface.combobox("Lua", "A", "Jump: Edge yaw", "Off", "Static")

local slowmotionpitch = interface.combobox("Lua", "A", "Slow motion: Pitch", "Off", "Default", "Up", "Down", "Minimal", "Random")
local slowmotionyawbase = interface.combobox("Lua", "A", "Slow motion: Yaw base", "Local view", "At targets")
local slowmotionyaw = interface.combobox("Lua", "A", "Slow motion: Yaw", "Off", "180", "Spin", "Static", "180 Z", "Crosshair")
local slowmotionyawslider = interface.slider("Lua", "A", "Slow motion: Yaw angle", -180, 180, 0, true)
local slowmotionyawjitter = interface.combobox("Lua", "A", "Slow motion: Yaw jitter", "Off", "Offset", "Center", "Random")
local slowmotionyawjitter_slider = interface.slider("Lua", "A", "Slow motion: Yaw jitter range", -180, 180, 0, true)
local slowmotionfakeyaw = interface.combobox("Lua", "A", "Slow motion: Body yaw", "Off", "Opposite", "Jitter", "Static")
local slowmotionfakeyaw_slider = interface.slider("Lua", "A", "Slow motion: Body yaw angle", -180, 180, 0, true)
local slowmotionfreestandbodyyaw = interface.checkbox("Lua", "A", "Slow motion: Freestanding body yaw")
local slowmotionlowerbodyyaw = interface.combobox("Lua", "A", "Slow motion: Lower body yaw target", "Off", "Sway", "Opposite", "Eye yaw")
local slowmotionfakelimit = interface.slider("Lua", "A", "Slow motion: Fake yaw limit", 0, 60, 60, true)
local slowmotionedgeyaw = interface.combobox("Lua", "A", "Slow motion: Edge yaw", "Off", "Static")

local crouchpitch = interface.combobox("Lua", "A", "Crouch: Pitch", "Off", "Default", "Up", "Down", "Minimal", "Random")
local crouchyawbase = interface.combobox("Lua", "A", "Crouch: Yaw base", "Local view", "At targets")
local crouchyaw = interface.combobox("Lua", "A", "Crouch: Yaw", "Off", "180", "Spin", "Static", "180 Z", "Crosshair")
local crouchyawslider = interface.slider("Lua", "A", "Crouch: Yaw angle", -180, 180, 0, true)
local crouchyawjitter = interface.combobox("Lua", "A", "Crouch: Yaw jitter", "Off", "Offset", "Center", "Random")
local crouchyawjitter_slider = interface.slider("Lua", "A", "Crouch: Yaw jitter range", -180, 180, 0, true)
local crouchfakeyaw = interface.combobox("Lua", "A", "Crouch: Body yaw", "Off", "Opposite", "Jitter", "Static")
local crouchfakeyaw_slider = interface.slider("Lua", "A", "Crouch: Body yaw angle", -180, 180, 0, true)
local crouchfreestandbodyyaw = interface.checkbox("Lua", "A", "Crouch: Freestanding body yaw")
local crouchlowerbodyyaw = interface.combobox("Lua", "A", "Crouch: Lower body yaw target", "Off", "Sway", "Opposite", "Eye yaw")
local crouchfakelimit = interface.slider("Lua", "A", "Crouch: Fake yaw limit", 0, 60, 60, true)
local crouchedgeyaw = interface.combobox("Lua", "A", "Crouch: Edge yaw", "Off", "Static")


function Standing()
 
    ui_set(antiaims.pitch, ui_get(standpitch))
    ui_set(antiaims.yawbase, ui_get(standyawbase))
    ui_set(antiaims.yaw, ui_get(standyaw))
    ui_set(antiaims.yaw_slider, ui_get(standyawslider))
    ui_set(antiaims.yawjitter, ui_get(standyawjitter))
    ui_set(antiaims.yawjitter_slider, ui_get(standyawjitter_slider))
    ui_set(antiaims.fakeyaw, ui_get(standfakeyaw))
    ui_set(antiaims.fakeyaw_slider, ui_get(standfakeyaw_slider))
    ui_set(antiaims.fakeyawlimit, ui_get(standfakelimit))
    ui_set(antiaims.edgeyaw, ui_get(standedgeyaw))
    ui_set(antiaims.freestandbodyyaw, ui_get(standfreestandbodyyaw))
    ui_set(antiaims.lowerbodyyaw, ui_get(standlowerbodyyaw))
   
end
 
function Moving()
 
    ui_set(antiaims.pitch, ui_get(movepitch))
    ui_set(antiaims.yawbase, ui_get(moveyawbase))
    ui_set(antiaims.yaw, ui_get(moveyaw))
    ui_set(antiaims.yaw_slider, ui_get(moveyawslider))
    ui_set(antiaims.yawjitter, ui_get(moveyawjitter))
    ui_set(antiaims.yawjitter_slider, ui_get(moveyawjitter_slider))
    ui_set(antiaims.fakeyaw, ui_get(movefakeyaw))
    ui_set(antiaims.fakeyaw_slider, ui_get(movefakeyaw_slider))
    ui_set(antiaims.lowerbodyyaw, ui_get(movelowerbodyyaw))
    ui_set(antiaims.fakeyawlimit, ui_get(movefakelimit))
    ui_set(antiaims.edgeyaw, ui_get(moveedgeyaw))
   
end
 
function Jumping()
   
    ui_set(antiaims.pitch, ui_get(jumppitch))
    ui_set(antiaims.yawbase, ui_get(jumpyawbase))
    ui_set(antiaims.yaw, ui_get(jumpyaw))
    ui_set(antiaims.yaw_slider, ui_get(jumpyawslider))
    ui_set(antiaims.yawjitter, ui_get(jumpyawjitter))
    ui_set(antiaims.yawjitter_slider, ui_get(jumpyawjitter_slider))
    ui_set(antiaims.fakeyaw, ui_get(jumpfakeyaw))
    ui_set(antiaims.fakeyaw_slider, ui_get(jumpfakeyaw_slider))
    ui_set(antiaims.lowerbodyyaw, ui_get(jumplowerbodyyaw))
    ui_set(antiaims.fakeyawlimit, ui_get(jumpfakelimit))
    ui_set(antiaims.edgeyaw, ui_get(jumpedgeyaw))
   
end
 
function Slowmotion()
       
    ui_set(antiaims.pitch, ui_get(slowmotionpitch))
    ui_set(antiaims.yawbase, ui_get(slowmotionyawbase))
    ui_set(antiaims.yaw, ui_get(slowmotionyaw))
    ui_set(antiaims.yaw_slider, ui_get(slowmotionyawslider))
    ui_set(antiaims.yawjitter, ui_get(slowmotionyawjitter))
    ui_set(antiaims.yawjitter_slider, ui_get(slowmotionyawjitter_slider))
    ui_set(antiaims.fakeyaw, ui_get(slowmotionfakeyaw))
    ui_set(antiaims.fakeyaw_slider, ui_get(slowmotionfakeyaw_slider))
    ui_set(antiaims.lowerbodyyaw, ui_get(slowmotionlowerbodyyaw))
    ui_set(antiaims.fakeyawlimit, ui_get(slowmotionfakelimit))
    ui_set(antiaims.edgeyaw, ui_get(slowmotionedgeyaw))
   
end
 
function Crouching()
       
    ui_set(antiaims.pitch, ui_get(crouchpitch))
    ui_set(antiaims.yawbase, ui_get(crouchyawbase))
    ui_set(antiaims.yaw, ui_get(crouchyaw))
    ui_set(antiaims.yaw_slider, ui_get(crouchyawslider))
    ui_set(antiaims.yawjitter, ui_get(crouchyawjitter))
    ui_set(antiaims.yawjitter_slider, ui_get(crouchyawjitter_slider))
    ui_set(antiaims.fakeyaw, ui_get(crouchfakeyaw))
    ui_set(antiaims.fakeyaw_slider, ui_get(crouchfakeyaw_slider))
    ui_set(antiaims.lowerbodyyaw, ui_get(crouchlowerbodyyaw))
    ui_set(antiaims.fakeyawlimit, ui_get(slowmotionfakelimit))
    ui_set(antiaims.edgeyaw, ui_get(slowmotionedgeyaw))
   
end
 

local function while_timings()
    info_antiaim_status = "Unknown"
    local function fl_onground(ent)
        local flags = entity_get_prop(ent, "m_fFlags")
        local flags_on_ground = bit.band( flags, 1 )
   
        if flags_on_ground == 1 then
            return true
        end
        return false
    end
 
    local function fl_induck(ent)
        local flags = entity_get_prop(ent, "m_fFlags")
        local flags_induck = bit.band(flags, 2)
   
        if flags_induck == 2 then
            return true
        end
        return false
    end
 
    local vel_x, vel_y = entity_get_prop(entity_get_local_player(), "m_vecVelocity")
    local vel_real = math_floor(math_min(10000, math_sqrt(vel_x*vel_x + vel_y*vel_y) + 0.5 ))
    local fakewalk_enabled = ui_get(antiaims.ref_fakewalk) and ui_get(antiaims.ref_fakewalk_key)

-- IF STANDING <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
 
    if fl_onground(entity_get_local_player()) and not fl_induck(entity_get_local_player()) and not fakewalk_enabled then
 
        info_antiaim_status = "Standing"
       
        if adaptive_default ~= "Off" and fl_onground(entity_get_local_player()) and not fl_induck(entity_get_local_player()) and not fakewalk_enabled then
            Standing()
        end
    end
   
-- IF RUNNING <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
 
    if fl_onground (entity_get_local_player()) and not fakewalk_enabled and not fl_induck(entity_get_local_player()) and vel_real> 1.0 then
        info_antiaim_status = "Moving"
       
        if adaptive_running ~= "Off" and fl_onground (entity_get_local_player()) and not fakewalk_enabled and not fl_induck(entity_get_local_player()) and vel_real> 1.0 then
            Moving()
        end
    end
 
-- IF JUMPING <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
 
    if fl_onground (entity_get_local_player()) == false then
        info_antiaim_status = "Jumping"
       
        if adaptive_jumping ~= "Off" and fl_onground(entity_get_local_player()) == false then
            Jumping()
        end
    end
 
-- IF CROUCHING <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
   
    if fl_onground(entity_get_local_player()) and fl_induck(entity_get_local_player()) then
        info_antiaim_status = "Crouching"
       
        if adaptive_crouching ~= "Off" and fl_onground(entity_get_local_player()) and fl_induck(entity_get_local_player())then
            Crouching()
        end
    end
   
-- IF SLOWMOTION <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
 
    if fl_onground(entity_get_local_player()) and fakewalk_enabled then
        info_antiaim_status = "Slow motion"
       
        if adaptive_fake ~= "Off" and fl_onground(entity_get_local_player()) and fakewalk_enabled then
            Slowmotion()
        end    
    end
end
 

local function StandVisibility()
    if ui_get(selector) == "Standing" then
        if ui_get(standyaw) == "Off" then
            ui_set_visible(standyawslider, false)
        else
            ui_set_visible(standyawslider, true)
        end

        if ui_get(standyawjitter) == "Off" then
            ui_set_visible(standyawjitter_slider, false)
        else
            ui_set_visible(standyawjitter_slider, true)
        end

        if ui_get(standfakeyaw) == "Off" or ui_get(standfakeyaw) == "Opposite" then
            ui_set_visible(standfakeyaw_slider, false)
        else
            ui_set_visible(standfakeyaw_slider, true)
        end

        if ui_get(standlowerbodyyaw) == "Off" or ui_get(standfakeyaw) == "Off" then
            ui_set_visible(standfakelimit, false)
        else
            ui_set_visible(standfakelimit, true)
        end

        ui_set_visible(standpitch, true)
        ui_set_visible(standyawbase, true)
        ui_set_visible(standyaw, true)
        ui_set_visible(standyawjitter, true)
        ui_set_visible(standfakeyaw, true)
        ui_set_visible(standedgeyaw, true)
        ui_set_visible(standfreestandbodyyaw, true)
        ui_set_visible(standlowerbodyyaw, true)
    else
        ui_set_visible(standpitch, false)
        ui_set_visible(standyawbase, false)
        ui_set_visible(standyaw, false)
        ui_set_visible(standyawslider, false)
        ui_set_visible(standyawjitter, false)
        ui_set_visible(standyawjitter_slider, false)
        ui_set_visible(standfakeyaw, false)
        ui_set_visible(standfakeyaw_slider, false)
        ui_set_visible(standfakelimit, false)
        ui_set_visible(standedgeyaw, false)
        ui_set_visible(standfreestandbodyyaw, false)
        ui_set_visible(standlowerbodyyaw, false)
    end
end

local function MoveVisibility()
    if ui_get(selector) == "Moving" then
        if ui_get(moveyaw) == "Off" then
            ui_set_visible(moveyawslider, false)
        else
            ui_set_visible(moveyawslider, true)
        end

        if ui_get(moveyawjitter) == "Off" then
            ui_set_visible(moveyawjitter_slider, false)
        else
            ui_set_visible(moveyawjitter_slider, true)
        end

        if ui_get(movefakeyaw) == "Off" or ui_get(movefakeyaw) == "Opposite" then
            ui_set_visible(movefakeyaw_slider, false)
        else
            ui_set_visible(movefakeyaw_slider, true)
        end

        if ui_get(movelowerbodyyaw) == "Off" or ui_get(movefakeyaw) == "Off" then
            ui_set_visible(movefakelimit, false)
        else
            ui_set_visible(movefakelimit, true)
        end

        ui_set_visible(movepitch, true)
        ui_set_visible(moveyawbase, true)
        ui_set_visible(moveyaw, true)
        ui_set_visible(moveyawjitter, true)
        ui_set_visible(movefakeyaw, true)
        ui_set_visible(movefreestandbodyyaw, true)
        ui_set_visible(movelowerbodyyaw, true)
        ui_set_visible(moveedgeyaw, true)
    else
        ui_set_visible(movepitch, false)
        ui_set_visible(moveyawbase, false)
        ui_set_visible(moveyaw, false)
        ui_set_visible(moveyawslider, false)
        ui_set_visible(moveyawjitter, false)
        ui_set_visible(moveyawjitter_slider, false)
        ui_set_visible(movefakeyaw, false)
        ui_set_visible(movefakeyaw_slider, false)
        ui_set_visible(movefreestandbodyyaw, false)
        ui_set_visible(movelowerbodyyaw, false)
        ui_set_visible(movefakelimit, false)
        ui_set_visible(moveedgeyaw, false)
    end
end

local function JumpVisibility()
    if ui_get(selector) == "Jumping" then
        if ui_get(jumpyaw) == "Off" then
            ui_set_visible(jumpyawslider, false)
        else
            ui_set_visible(jumpyawslider, true)
        end

        if ui_get(jumpyawjitter) == "Off" then
            ui_set_visible(jumpyawjitter_slider, false)
        else
            ui_set_visible(jumpyawjitter_slider, true)
        end

        if ui_get(jumpfakeyaw) == "Off" or ui_get(jumpfakeyaw) == "Opposite" then
            ui_set_visible(jumpfakeyaw_slider, false)
        else
            ui_set_visible(jumpfakeyaw_slider, true)
        end

        if ui_get(jumplowerbodyyaw) == "Off" or ui_get(jumpfakeyaw) == "Off" then
            ui_set_visible(jumpfakelimit, false)
        else
            ui_set_visible(jumpfakelimit, true)
        end

        ui_set_visible(jumppitch, true)
        ui_set_visible(jumpyawbase, true)
        ui_set_visible(jumpyaw, true)
        ui_set_visible(jumpyawjitter, true)
        ui_set_visible(jumpfakeyaw, true)
        ui_set_visible(jumpfreestandbodyyaw, true)
        ui_set_visible(jumplowerbodyyaw, true)
        ui_set_visible(jumpedgeyaw, true)
    else
        ui_set_visible(jumppitch, false)
        ui_set_visible(jumpyawbase, false)
        ui_set_visible(jumpyaw, false)
        ui_set_visible(jumpyawslider, false)
        ui_set_visible(jumpyawjitter, false)
        ui_set_visible(jumpyawjitter_slider, false)
        ui_set_visible(jumpfakeyaw, false)
        ui_set_visible(jumpfakeyaw_slider, false)
        ui_set_visible(jumpfreestandbodyyaw, false)
        ui_set_visible(jumplowerbodyyaw, false)
        ui_set_visible(jumpfakelimit, false)
        ui_set_visible(jumpedgeyaw, false)
    end
end

local function SlowmotionVisibility()
    if ui_get(selector) == "Slow motion" then
        if ui_get(slowmotionyaw) == "Off" then
            ui_set_visible(slowmotionyawslider, false)
        else
            ui_set_visible(slowmotionyawslider, true)
        end

        if ui_get(slowmotionyawjitter) == "Off" then
            ui_set_visible(slowmotionyawjitter_slider, false)
        else
            ui_set_visible(slowmotionyawjitter_slider, true)
        end

        if ui_get(slowmotionfakeyaw) == "Off" or ui_get(slowmotionfakeyaw) == "Opposite" then
            ui_set_visible(slowmotionfakeyaw_slider, false)
        else
            ui_set_visible(slowmotionfakeyaw_slider, true)
        end

        if ui_get(slowmotionlowerbodyyaw) == "Off" or ui_get(slowmotionfakeyaw) == "Off" then
            ui_set_visible(slowmotionfakelimit, false)
        else
            ui_set_visible(slowmotionfakelimit, true)
        end

        ui_set_visible(slowmotionpitch, true)
        ui_set_visible(slowmotionyawbase, true)
        ui_set_visible(slowmotionyaw, true)
        ui_set_visible(slowmotionyawjitter, true)
        ui_set_visible(slowmotionfakeyaw, true)
        ui_set_visible(slowmotionfreestandbodyyaw, true)
        ui_set_visible(slowmotionlowerbodyyaw, true)
        ui_set_visible(slowmotionedgeyaw, true)
    else
        ui_set_visible(slowmotionpitch, false)
        ui_set_visible(slowmotionyawbase, false)
        ui_set_visible(slowmotionyaw, false)
        ui_set_visible(slowmotionyawslider, false)
        ui_set_visible(slowmotionyawjitter, false)
        ui_set_visible(slowmotionyawjitter_slider, false)
        ui_set_visible(slowmotionfakeyaw, false)
        ui_set_visible(slowmotionfakeyaw_slider, false)
        ui_set_visible(slowmotionfreestandbodyyaw, false)
        ui_set_visible(slowmotionlowerbodyyaw, false)
        ui_set_visible(slowmotionfakelimit, false)
        ui_set_visible(slowmotionedgeyaw, false)
    end
end

local function CrouchVisibility()
    if ui_get(selector) == "Crouching" then
        if ui_get(crouchyaw) == "Off" then
            ui_set_visible(crouchyawslider, false)
        else
            ui_set_visible(crouchyawslider, true)
        end

        if ui_get(crouchyawjitter) == "Off" then
            ui_set_visible(crouchyawjitter_slider, false)
        else
            ui_set_visible(crouchyawjitter_slider, true)
        end

        if ui_get(crouchfakeyaw) == "Off" or ui_get(crouchfakeyaw) == "Opposite" then
            ui_set_visible(crouchfakeyaw_slider, false)
        else
            ui_set_visible(crouchfakeyaw_slider, true)
        end

        if ui_get(crouchlowerbodyyaw) == "Off" or ui_get(crouchfakeyaw) == "Off" then
            ui_set_visible(crouchfakelimit, false)
        else
            ui_set_visible(crouchfakelimit, true)
        end

        ui_set_visible(crouchpitch, true)
        ui_set_visible(crouchyawbase, true)
        ui_set_visible(crouchyaw, true)
        ui_set_visible(crouchyawjitter, true)
        ui_set_visible(crouchfakeyaw, true)
        ui_set_visible(crouchfreestandbodyyaw, true)
        ui_set_visible(crouchlowerbodyyaw, true)
        ui_set_visible(crouchedgeyaw, true)
    else
        ui_set_visible(crouchpitch, false)
        ui_set_visible(crouchyawbase, false)
        ui_set_visible(crouchyaw, false)
        ui_set_visible(crouchyawslider, false)
        ui_set_visible(crouchyawjitter, false)
        ui_set_visible(crouchyawjitter_slider, false)
        ui_set_visible(crouchfakeyaw, false)
        ui_set_visible(crouchfakeyaw_slider, false)
        ui_set_visible(crouchfreestandbodyyaw, false)
        ui_set_visible(crouchlowerbodyyaw, false)
        ui_set_visible(crouchfakelimit, false)
        ui_set_visible(crouchedgeyaw, false)
    end 
end


local showflags = ui_new_checkbox("Lua", "A", "Display current state")

local function on_paint(ctx)
    local screen_width, screen_height = client_screen_size()
    --local r, g, b, a = ui_get(color_picker)
    if ui_get(showflags, true) then
        client_draw_text(ctx, screen_width / 2 - 55, screen_height / 2 + 20, 0, 200, 0, 255, "", 0, "Current state: ")
        client_draw_text(ctx, screen_width / 2 + 20, screen_height / 2 + 20, 0, 200, 0, 255, "", 0, info_antiaim_status)
    end
end
 
 
client.set_event_callback("run_command", while_timings)
client.set_event_callback("paint", on_paint)
client.set_event_callback('paint', StandVisibility)
client.set_event_callback('paint', MoveVisibility)
client.set_event_callback('paint', JumpVisibility)
client.set_event_callback('paint', SlowmotionVisibility)
client.set_event_callback('paint', CrouchVisibility)
