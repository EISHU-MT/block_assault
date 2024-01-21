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
		rangedweapons.pointing_weapon[Name(placer)] = nil
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
	
	if player:hud_get(scope_huds[Name(placer)]) and (not rangedweapons.pointing[Name(player)]) then
		
		if itemstack:get_name() == "rangedweapons:awp" or itemstack:get_name() == "rangedweapons:svd" or itemstack:get_name() == "rangedweapons:m200" then
			player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_scopehud.png")
			player:hud_change(scope_huds[Name(placer)], "scale", {x=2,y=2})
			
			player:hud_set_flags({
				crosshair = false,
				wield_item = false,
			})
		else
			rangedweapons.pointing_weapon[Name(placer)] = itemstack:get_name()
			player:hud_change(scope_huds[Name(placer)], "text", "rangedweapons_scopehud_minimal.png")
			player:hud_change(scope_huds[Name(placer)], "scale", {x=0.15,y=0.15})
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
		rangedweapons.pointing_weapon[Name(placer)] = nil
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

local function calculateWeaponPrice(accuracy, dps, velocity)
	local ACCURACY_WEIGHT = 0.4
	local DPS_WEIGHT = 0.3
	local VELOCITY_WEIGHT = 0.3
	local normalizedAccuracy = accuracy / 100
	local normalizedDPS = dps / 1000
	local normalizedVelocity = velocity / 200
	local weaponPrice = ACCURACY_WEIGHT * normalizedAccuracy + DPS_WEIGHT * normalizedDPS + VELOCITY_WEIGHT * normalizedVelocity
	weaponPrice = weaponPrice * 200  -- Adjust as needed
	weaponPrice = math.max(1, weaponPrice)
	return math.floor(weaponPrice)  -- Round down to an integer
end

local types = {
	--Rifle
	["rangedweapons:m16"] =        "rifle",
	["rangedweapons:scar"] =       "rifle",
	["rangedweapons:svd"] =        "rifle",
	["rangedweapons:ak47"] =       "rifle",
	["rangedweapons:g36"] =        "rifle",
	["rangedweapons:awp"] =        "rifle",
	["rangedweapons:m200"] =       "rifle",
	--Shotguns
	["rangedweapons:remington"] =  "shotgun",
	["rangedweapons:spas12"] =     "shotgun",
	["rangedweapons:benelli"] =    "shotgun",
	["rangedweapons:jackhammer"] = "shotgun",
	["rangedweapons:aa12"] =       "shotgun",
	--SMGs
	["rangedweapons:kriss_sv"] =   "smg",
	["rangedweapons:tmp"] =        "smg",
	["rangedweapons:tec9"] =       "smg",
	["rangedweapons:uzi"] =        "smg",
	--Pistols
	["rangedweapons:deagle"] =     "pistol",
	["rangedweapons:glock17"] =    "pistol",
	["rangedweapons:luger"] =      "pistol",
	["rangedweapons:m1991"] =      "pistol",
	["rangedweapons:beretta"] =    "pistol",
	["rangedweapons:makarov"] =    "pistol",
}

local snipers = {
	["rangedweapons:awp"] =    true,
	["rangedweapons:svd"] =    true,
	["rangedweapons:m200"] =   true,
}

rangedweapons.weapon_types = {}
for weapon_name, weapon_type in pairs(types) do
	if not rangedweapons.weapon_types[weapon_type] then
		rangedweapons.weapon_types[weapon_type] = {}
	end
	table.insert(rangedweapons.weapon_types[weapon_type], weapon_name)
end

local function on_load()
	for name, def in pairs(core.registered_tools) do
		if name:find("rangedweapon") and def.RW_gun_capabilities then
			--def.on_rightclick = onR
			def.on_secondary_use = onR
			def.on_pickup = Shop.GetWeapon -- Should override everything....
			core.registered_tools[name] = def --core.override_item(name, def)
			
			if types[name] then
				Shop.RegisterWeapon(ItemStack(name):get_short_description(), {
					item_name = name,
					price = calculateWeaponPrice(def.RW_gun_capabilities.gun_accuracy, def.RW_gun_capabilities.gun_damage.fleshy, def.RW_gun_capabilities.gun_velocity),
					icon = def.inventory_image,
					type = types[name],
					uses_ammo = true,
					ammo_item_string = def.RW_gun_capabilities.suitable_ammo[1][1],
					ammo_item_count = def.RW_gun_capabilities.suitable_ammo[1][2] * 90,
				})
			end
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
rangedweapons.pointing_weapon = {}


local function on_step(dt)
	for _, player in pairs(core.get_connected_players()) do
		
		
		local cancel_pointing_act = false
		local item_obj
		
		if rangedweapons.pointing[Name(player)] then
			local hand_item = player:get_wielded_item()
			if hand_item:get_name():match("rangedweapons") then
				cancel_pointing_act = false
				item_obj = hand_item
			else
				cancel_pointing_act = true
			end
		end
		
		if cancel_pointing_act then
			onR(item_obj, player)
		end
		
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
					if bs_match.match_is_started then
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
					end
				else
					rangedweapons.already_shot[Name(player)] = false
				end
				
				
			end
			do
				rangedweapons.cooldown[Name(player)] = rangedweapons.cooldown[Name(player)] - dt
				
				--if rangedweapons.cooldown[Name(player)] > 0.0 then
					--print("mae"..rangedweapons.cooldown[Name(player)])
				--	rangedweapons.cooldown[Name(player)] = rangedweapons.cooldown[Name(player)] - dt
				--end
				
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
								gain = 0.5,
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


















