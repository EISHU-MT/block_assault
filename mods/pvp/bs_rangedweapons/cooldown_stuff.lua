
--[[
	Some parts of this file is being moved to 'item_onAct.lua'.
--]]



--[[
scope_users = {}
minetest.register_globalstep(function(dtime, player)
	for _, player in pairs(minetest.get_connected_players()) do

	local controls = player:get_player_control()
	--ans.do_animate_to(player, controls)

	local pwpn = player:get_wielded_item():get_name()

	if pwpn == "rangedweapons:awp" or pwpn == "rangedweapons:svd" or pwpn == "rangedweapons:m200" then
		player:hud_set_flags({
			crosshair = false,
		})
	else
		player:hud_set_flags({
			crosshair = true,
			wield_item = true,
		})
	end

 local w_item = player:get_wielded_item()



if w_item:get_definition().weapon_zoom ~= nil then

	if controls.zoom and scope_users[player:get_player_name()] ~= true and cs_match.commenced_match == true then
		player:hud_change(scope_huds[Name(player)], "text", "rangedweapons_scopehud.png")
		player:hud_set_flags({
			crosshair = false,
			wield_item = false,
		})
		
		local physics = player:get_physics_override()
		player:set_physics_override({
			speed = physics.speed - 0.5,
		})
		scope_users[player:get_player_name()] = true
	elseif cs_match.commenced_match == true and not controls.zoom then
		if scope_users[player:get_player_name()] == true then
			scope_users[player:get_player_name()] = nil
			player:hud_change(scope_huds[Name(player)], "text", "rangedweapons_empty_icon.png")
			local physics = player:get_physics_override()
			if cs_match.commenced_match == true then
				if physics.speed >= 1 then
					return
				end
				player:set_physics_override({
					speed = physics.speed + 0.5,
				})
			end
			--[[player:hud_set_flags({
				crosshair = true,
			})-
		end
	end

local wpn_zoom = w_item:get_definition().weapon_zoom
	if player:get_properties().zoom_fov ~= wpn_zoom and cs_match.commenced_match == true then
		player:set_properties({zoom_fov = wpn_zoom})

	end

end

if w_item:get_definition().weapon_zoom == nil then
player:hud_change(scope_huds[Name(player)], "text", "rangedweapons_empty_icon.png")
	if player:get_inventory():contains_item(
			"main", "binoculars:binoculars") then
		new_zoom_fov = 10
	if player:get_properties().zoom_fov ~= new_zoom_fov then
		player:set_properties({zoom_fov = new_zoom_fov})
	end
	else 
		new_zoom_fov = 0
	if player:get_properties().zoom_fov ~= new_zoom_fov then
		player:set_properties({zoom_fov = new_zoom_fov})
	end
	end
end


local u_meta = player:get_meta()
local cool_down = u_meta:get_float("rw_cooldown") or 0


if u_meta:get_float("rw_cooldown") > 0 then
u_meta:set_float("rw_cooldown", cool_down - dtime)
end

local itemstack = player:get_wielded_item()

if controls.LMB then
if player:get_wielded_item():get_definition().RW_gun_capabilities then
if
player:get_wielded_item():get_definition().RW_gun_capabilities.automatic_gun and player:get_wielded_item():get_definition().RW_gun_capabilities.automatic_gun > 0 then

rangedweapons_shoot_gun(itemstack, player)
player:set_wielded_item(itemstack)
end end

if player:get_wielded_item():get_definition().RW_powergun_capabilities then
if player:get_wielded_item():get_definition().RW_powergun_capabilities.automatic_gun and player:get_wielded_item():get_definition().RW_powergun_capabilities.automatic_gun > 0 then

rangedweapons_shoot_powergun(itemstack, player)
player:set_wielded_item(itemstack)
end end

 end



--minetest.chat_send_all(u_meta:get_float("rw_cooldown"))

if u_meta:get_float("rw_cooldown") <= 0 then
	if player:get_wielded_item():get_definition().loaded_gun ~= nil then
		local itemstack = player:get_wielded_item()

		if player:get_wielded_item():get_definition().loaded_sound ~= nil then
			minetest.sound_play(itemstack:get_definition().loaded_sound, {player})
		end
			itemstack:set_name(player:get_wielded_item():get_definition().loaded_gun)
			player:set_wielded_item(itemstack)
	end 

	if player:get_wielded_item():get_definition().rw_next_reload ~= nil then
		local itemstack = player:get_wielded_item()
		if itemstack:get_definition().load_sound ~= nil then
			minetest.sound_play(itemstack:get_definition().load_sound, {player})
		end
		gunMeta = itemstack:get_meta()
		u_meta:set_float("rw_cooldown",gunMeta:get_float("RW_reload_delay"))
		itemstack:set_name(player:get_wielded_item():get_definition().rw_next_reload)
		player:set_wielded_item(itemstack)
	end
end

end 




end)
--]]

































