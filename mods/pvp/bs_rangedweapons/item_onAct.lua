rangedweapons.is_recharging = {}
rangedweapons.pointing = {}

local function switchP(p)
	if rangedweapons.pointing[Name(p)] then
		rangedweapons.pointing[Name(p)] = false
	else
		rangedweapons.pointing[Name(p)] = true
	end
end

function requestP(p)
	return rangedweapons.pointing[Name(p)]
end

local function onR(itemstack, placer, pointed_thing)
	local player = placer
	if rangedweapons.pointing[Name(player)] and bs_match.match_is_started == false then
		player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_empty_icon.png")
		player:hud_change(scope_huds[Name(placer)], "scale", {x=2,y=2})
		
		local physics = player:get_physics_override()
		
		
		
		player:hud_set_flags({
			crosshair = true,
			wield_item = true
		})
		
		rangedweapons.pointing[Name(player)] = false
		
		if player:get_fov() > 0 then
			player:set_fov(0)
		end
		
		if physics.speed >= 1 then
			return
		end
		
		player:set_physics_override({
			speed = physics.speed + 0.5,
		})
	end
	if bs_match.match_is_started == false then return end
	
	if player:hud_get(scope_huds[Name(placer)]) and (not rangedweapons.pointing[Name(player)] or rangedweapons.pointing[Name(player)] == false ) then
		
		if itemstack:get_name() == "rangedweapons:awp" or itemstack:get_name() == "rangedweapons:svd" or itemstack:get_name() == "rangedweapons:m200" then
			player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_scopehud.png")
			player:hud_change(scope_huds[Name(placer)], "scale", {x=2,y=2})
			
			player:hud_set_flags({
				crosshair = false,
				wield_item = false,
			})
		else
			player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_scopehud_minimal.png")
			player:hud_change(scope_huds[Name(placer)], "scale", {x=0.1,y=0.1})
			player:hud_set_flags({
				crosshair = false,
			})
		end
		
		local physics = player:get_physics_override()
		
		if physics.speed >= 0.7 then
			player:set_physics_override({
				speed = physics.speed - 0.5,
			})
		end
		
		local wpn_zoom = itemstack:get_definition().weapon_zoom
		if wpn_zoom then
			if player:get_properties().zoom_fov ~= wpn_zoom then
				player:set_fov(wpn_zoom)
			end
		else
			player:set_fov(60)
		end
		
		rangedweapons.pointing[Name(player)] = true
	elseif player:hud_get(scope_huds[Name(placer)]) and rangedweapons.pointing[Name(player)] then
		player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_empty_icon.png")
		player:hud_change(scope_huds[Name(placer)], "scale", {x=2,y=2})
		
		local physics = player:get_physics_override()
		
		
		
		player:hud_set_flags({
			crosshair = true,
			wield_item = true
		})
		
		rangedweapons.pointing[Name(player)] = false
		
		if player:get_fov() > 0 then
			player:set_fov(0)
		end
		
		if physics.speed >= 1 then
			return
		end
		
		player:set_physics_override({
			speed = physics.speed + 0.5,
		})
	end
end

local function onuse(item, player, pt)
	--rangedweapons_shoot_gun(item, player)
end

local function on_load()
	for name, def in pairs(core.registered_tools) do
		if name:find("rangedweapon") and def.RW_gun_capabilities then
			def.on_rightclick = onR
			def.on_secondary_use = onR --osu = def.on_secondary_use
			def.on_use = on_use
			core.registered_tools[name] = def --core.override_item(name, def)
		end
	end
end

rangedweapons.is_recharging = {}
rangedweapons.last_pressedAUX = {}
rangedweapons.already_shot = {}
rangedweapons.delays = {} -- Prevent use of meta()
rangedweapons.bullets = {}
rangedweapons.ammo_names = {}
rangedweapons.reload_delays = {}
rangedweapons.cooldown = {}
rangedweapons.aux_delay = {}



local function on_step(dt)
	for _, player in pairs(core.get_connected_players()) do
		
		-- Monitor
		if not rangedweapons.cooldown[Name(player)] then
			rangedweapons.cooldown[Name(player)] = 0
		end
		if not rangedweapons.reload_delays[Name(player)] then
			rangedweapons.reload_delays[Name(player)] = 0
		end
		if not rangedweapons.ammo_names[Name(player)] then
			rangedweapons.ammo_names[Name(player)] = ""
		end
		if not rangedweapons.bullets[Name(player)] then
			rangedweapons.bullets[Name(player)] = 0
		end
		if not rangedweapons.aux_delay[Name(player)] then
			rangedweapons.aux_delay[Name(player)] = 0
		end
		
		
		local item = player:get_wielded_item()
		--local itemstack = item -- HACCCC
		local controls = player:get_player_control()
		if item then
			if item:get_definition().RW_gun_capabilities then
				
				
				if rangedweapons.aux_delay[Name(player)] >= 0.2 then
					if controls.aux1 then
						if rangedweapons.last_pressedAUX[Name(player)] ~= true then
							rangedweapons_reload_gun(item, player)
							rangedweapons.is_recharging[Name(player)] = true
							rangedweapons.last_pressedAUX[Name(player)] = true
						end
					else
						rangedweapons.last_pressedAUX[Name(player)] = nil
						rangedweapons.is_recharging[Name(player)] = nil
					end
					rangedweapons.aux_delay[Name(player)] = 0
				end
				rangedweapons.aux_delay[Name(player)] = rangedweapons.aux_delay[Name(player)] + dt
				
				
				if controls.dig then -- Dont shoot if player is recharging his gun
					if player:get_wielded_item():get_definition().RW_gun_capabilities and player:get_wielded_item():get_definition().RW_gun_capabilities.automatic_gun and player:get_wielded_item():get_definition().RW_gun_capabilities.automatic_gun > 0 then
						rangedweapons_shoot_gun(item, player)
						--player:set_wielded_item(item)
					else
						if rangedweapons.already_shot[Name(player)] ~= true then
							rangedweapons_shoot_gun(item, player)
							--player:set_wielded_item(item)
							rangedweapons.already_shot[Name(player)] = true
						end
					end
				else
					rangedweapons.already_shot[Name(player)] = false
				end
				
				
			end
			do
				rangedweapons.cooldown[Name(player)] = rangedweapons.cooldown[Name(player)] - dt
				
				if rangedweapons.cooldown[Name(player)] > 0.0 then
					--print("mae"..rangedweapons.cooldown[Name(player)])
					rangedweapons.cooldown[Name(player)] = rangedweapons.cooldown[Name(player)] - dt
				end
				
				--minetest.chat_send_all(u_meta:get_float("rw_cooldown"))
				
				if rangedweapons.cooldown[Name(player)] < 0 then
					rangedweapons.cooldown[Name(player)] = 0
				end
				
				if rangedweapons.cooldown[Name(player)] <= 0 then
					--core.chat_send_all("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
					if item:get_definition().loaded_gun ~= nil then
						--error(1)
						local itemstack = player:get_wielded_item()
						
						if player:get_wielded_item():get_definition().loaded_sound ~= nil then
							minetest.sound_play(itemstack:get_definition().loaded_sound, {
								pos = Player(player):get_pos(),
								gain = 0.7,
								max_hear_distance = 32
							})
						end
						if player:get_wielded_item():get_definition().loaded_gun then
							itemstack:set_name(player:get_wielded_item():get_definition().loaded_gun)
							player:set_wielded_item(itemstack)
						end
					end
					
					if item:get_definition().rw_next_reload ~= nil then
						--error(9)
						local itemstack = player:get_wielded_item()
						if itemstack:get_definition().load_sound ~= nil then
							minetest.sound_play(itemstack:get_definition().load_sound, {player})
						end
						gunMeta = itemstack:get_meta()
						rangedweapons.cooldown[Name(player)] = rangedweapons.delays[Name(player)]
						itemstack:set_name(player:get_wielded_item():get_definition().rw_next_reload)
						player:set_wielded_item(itemstack)
					end
				end
			end
		end
	end
end

local function on_death(player)
	if rangedweapons.pointing[Name(player)] then
		
		local placer = player -- The most stupid thing i did.
		
		if scope_huds[Name(player)] then
			player:hud_change(scope_huds[Name(player)], "text", "rangedweapons_empty_icon.png")
			player:hud_change(scope_huds[Name(player)], "scale", {x=2,y=2})
		end
		
		local physics = player:get_physics_override()
		
		
		
		player:hud_set_flags({
			crosshair = true,
			wield_item = true
		})
		
		rangedweapons.pointing[Name(player)] = false
		
		if player:get_fov() > 0 then
			player:set_fov(0)
		end
		
		if physics.speed >= 1 then
			return
		end
		
		player:set_physics_override({
			speed = physics.speed + 0.5,
		})
	end
end

core.register_on_respawnplayer(on_death)
core.register_globalstep(on_step)
core.register_on_mods_loaded(on_load)






--
-- Override other mods!
--


function IsRechargingGun(to_playername)
	return rangedweapons.is_recharging[Name(to_playername)]
end
function IsPointing(to_playername)
	return rangedweapons.pointing[Name(to_playername)]
end


















