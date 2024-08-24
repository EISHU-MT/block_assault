
-- Might this need fix:


rangedweapons = {}
scope_huds = {} -- Table containing all players huds
hits = {} -- Same as scope_huds

local modpath = minetest.get_modpath(minetest.get_current_modname())
minetest.register_node("rangedweapons:antigun_block", {
	description = "" ..core.colorize("#35cdff","Anti-gun block\n")..core.colorize("#FFFFFF", "Prevents people from using guns, in 10 node radius to each side from this block"),
	tiles = {"rangedweapons_antigun_block.png"},
	groups = {choppy = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_wood_defaults(),
})

----
---- gun_funcs
----

local make_sparks = function(pos)
	minetest.sound_play("rengedweapons_ricochet", {pos = pos, gain = 0.75, max_hear_distance = 22}) -- LOOOL
	for i=1,9 do
		minetest.add_particle({
			pos = pos, 
			velocity = {x=math.random(-6.0,6.0),y=math.random(-10.0,15.0),z=math.random(-6.0,6.0)},
			acceleration = {x=math.random(-9.0,9.0), y=math.random(-15.0,-3.0), z=math.random(-9.0,9.0)},
			expirationtime = 1.0,
			size = math.random(1,2),
			collisiondetection = true,
			vertical = false,
			texture = "rangedweapons_spark.png",
			glow = 25,
		})
	end
end

rangedweapons.make_sparks = make_sparks
rangedweapons_gain_skill = function() end -- *sigh*
rangedweapons.bullets_max = {}

rangedweapons_reload_gun = function(itemstack, player)
	local GunCaps = itemstack:get_definition().RW_gun_capabilities
	if GunCaps ~= nil then
		gun_unload_sound = GunCaps.gun_unload_sound or ""
	end
	minetest.sound_play(gun_unload_sound, {pos = player:get_pos(), gain = 0.3, max_hear_distance = 20})
	local gun_reload = 0.25
	if GunCaps ~= nil then
		gun_reload = GunCaps.gun_reload or 0.25
	end
	local playerMeta = player:get_meta()
	local gunMeta = itemstack:get_meta()
	rangedweapons.delays[Name(player)] = gun_reload or 0.2
	rangedweapons.cooldown[Name(player)] = gun_reload
	local player_has_ammo = 0
	local clipSize = 0
	local reload_ammo = ""
	if GunCaps.suitable_ammo ~= nil then
		local inv = player:get_inventory()
		for i = 1,inv:get_size("main") do
			for _, ammo in pairs(GunCaps.suitable_ammo) do
				if inv:get_stack("main",i):get_name() == ammo[1] then
					reload_ammo = inv:get_stack("main",i)
					clipSize = ammo[2]
					player_has_ammo = 1
					break
				end
			end
			if player_has_ammo == 1 then
				break
			end
		end
	end
	if player_has_ammo == 1 then
		local gun_icon = "rangedweapons_emergency_gun_icon.png"
		if GunCaps.gun_icon ~= nil then
			gun_icon = GunCaps.gun_icon
		end
		local ammo_icon = "rangedweapons_emergency_ammo_icon.png"
		if reload_ammo:get_definition().inventory_image ~= nil then
			ammo_icon = reload_ammo:get_definition().inventory_image
		end
		--hb.change_hudbar(player, "ammo", nil, nil, gun_icon, nil, nil)
		local gunMeta = itemstack:get_meta()
		local ammoCount = rangedweapons.bullets[Name(player)]
		local ammoName = rangedweapons.ammo_names[Name(player)]
		local inv = player:get_inventory()
		inv:add_item("main",ammoName.." "..ammoCount)
		if inv:contains_item("main",reload_ammo:get_name().." "..clipSize) then
			inv:remove_item("main",reload_ammo:get_name().." "..clipSize)
			rangedweapons.bullets[Name(player)] = clipSize
		else
			rangedweapons.bullets[Name(player)] = reload_ammo:get_count()
			inv:remove_item("main",reload_ammo:get_name().." "..reload_ammo:get_count())
		end
		rangedweapons.ammo_names[Name(player)] = reload_ammo:get_name()
		--hb.change_hudbar(player, "ammo", rangedweapons.bullets[Name(player)], rangedweapons.bullets[Name(player)])
		rangedweapons.bullets_max[Name(player)] = clipSize
		if rangedweapons.hud_bars[player:get_player_name()] and rangedweapons.hud_bars[player:get_player_name()].fi then
			player:hud_change(rangedweapons.hud_bars[player:get_player_name()].fi, "number", ((rangedweapons.bullets[Name(player)]/rangedweapons.bullets_max[Name(player)]) * 20))
			player:hud_change(rangedweapons.hud_bars[player:get_player_name()].tx, "text", "Ammo: "..rangedweapons.bullets[Name(player)].."/"..rangedweapons.bullets_max[Name(player)])
		end
		if GunCaps.gun_magazine ~= nil then
			local pos = player:get_pos()
			local dir = player:get_look_dir()
			local yaw = player:get_look_horizontal()
			if pos and dir and yaw then
				pos.y = pos.y + 1.4
				local obj = minetest.add_entity(pos,"rangedweapons:mag")
				if obj then
					obj:set_properties({textures = {GunCaps.gun_magazine}})
					obj:set_velocity({x=dir.x*2, y=dir.y*2, z=dir.z*2})
					obj:set_acceleration({x=0, y=-5, z=0})
					obj:set_rotation({x=0,y=yaw,z=0})
				end
			end
		end
		if GunCaps.gun_unloaded ~= nil then
			itemstack:set_name(GunCaps.gun_unloaded)
			player:set_wielded_item(itemstack)
		end
	end
end

rangedweapons_single_load_gun = function(itemstack, player)
	local GunCaps = itemstack:get_definition().RW_gun_capabilities
	if GunCaps ~= nil then
		gun_unload_sound = GunCaps.gun_unload_sound or ""
	end
	minetest.sound_play(gun_unload_sound, {pos = player:get_pos(), gain = 0.3, max_hear_distance = 20})
	local gun_reload = 0.25
	if GunCaps ~= nil then
		gun_reload = GunCaps.gun_reload or 0.25
	end
	local playerMeta = player:get_meta()
	local gunMeta = itemstack:get_meta()
	rangedweapons.reload_delays[Name(player)] = gun_reload
	rangedweapons.cooldown[Name(player)] = gun_reload
	local player_has_ammo = 0
	local clipSize = 0
	local reload_ammo = ""
	if GunCaps.suitable_ammo ~= nil then
		local inv = player:get_inventory()
		for i = 1,inv:get_size("main") do
			for _, ammo in pairs(GunCaps.suitable_ammo) do
				if inv:get_stack("main",i):get_name() == ammo[1] then
					reload_ammo = inv:get_stack("main",i)
					clipSize = ammo[2]
					player_has_ammo = 1
					break
				end
			end
			if player_has_ammo == 1 then
				break
			end
		end
	end
	if player_has_ammo == 1 then
		local gun_icon = "rangedweapons_emergency_gun_icon.png"
		if GunCaps.gun_icon ~= nil then
			gun_icon = GunCaps.gun_icon
		end
		local ammo_icon = "rangedweapons_emergency_ammo_icon.png"
		if reload_ammo:get_definition().inventory_image ~= nil then
			ammo_icon = reload_ammo:get_definition().inventory_image
		end
		--hb.change_hudbar(player, "ammo", nil, nil, gun_icon, nil, nil)
		local gunMeta = itemstack:get_meta()
		local ammoCount = rangedweapons.bullets[Name(player)]
		local ammoName = rangedweapons.ammo_names[Name(player)]
		local inv = player:get_inventory()
		if ammoName ~= reload_ammo:get_name() then
			inv:add_item("main",ammoName.." "..ammoCount)
			rangedweapons.bullets[Name(player)] = 0
		end
		if inv:contains_item("main",reload_ammo:get_name()) and rangedweapons.bullets[Name(player)] < clipSize then
			inv:remove_item("main", reload_ammo:get_name())
			rangedweapons.bullets[Name(player)] = rangedweapons.bullets[Name(player)] + 1
		end
		rangedweapons.ammo_names[Name(player)] = reload_ammo:get_name()
		rangedweapons.bullets_max[Name(player)] = clipSize
		--hb.change_hudbar(player, "ammo", rangedweapons.bullets[Name(player)], rangedweapons.bullets[Name(player)])
		if rangedweapons.hud_bars[player:get_player_name()] and rangedweapons.hud_bars[player:get_player_name()].fi then
			player:hud_change(rangedweapons.hud_bars[player:get_player_name()].fi, "number", ((rangedweapons.bullets[Name(player)]/rangedweapons.bullets_max[Name(player)]) * 20))
			player:hud_change(rangedweapons.hud_bars[player:get_player_name()].tx, "text", "Ammo: "..rangedweapons.bullets[Name(player)].."/"..rangedweapons.bullets_max[Name(player)])
		end
		if GunCaps.gun_unloaded ~= nil then
			itemstack:set_name(GunCaps.gun_unloaded)
		end
	end
end

rangedweapons_yeet = function(itemstack, player)
	if minetest.find_node_near(player:getpos(), 10,"rangedweapons:antigun_block") then
		minetest.chat_send_player(player:get_player_name(), "" ..core.colorize("#ff0000","throwable weapons are prohibited in this area!"))
	else
		local ThrowCaps = itemstack:get_definition().RW_throw_capabilities
		local playerMeta = player:get_meta()
		if ThrowCaps ~= nil then
			throw_cooldown = ThrowCaps.throw_cooldown or 0
		end
		if rangedweapons.cooldown[Name(player)] <= 0 then
			rangedweapons.cooldown[Name(player)] = throw_cooldown
			local throw_damage = {fleshy=1}
			local throw_sound = "rangedweapons_throw"
			local throw_velocity = 20
			local throw_accuracy = 100
			local throw_cooling = 0
			local throw_crit = 0
			local throw_critEffc = 1
			local throw_mobPen = 0
			local throw_nodePen = 0
			local throw_dps = 0
			local throw_gravity = 0
			local throw_door_breaking = 0
			local throw_skill = ""
			local throw_skillChance =0
			local throw_smokeSize =0
			local throw_ent = "rangedweapons:shot_bullet"
			local throw_visual = "wielditem"
			local throw_texture = "rangedweapons:shot_bullet_visual"
			local throw_glass_breaking = 0
			local throw_particles = {}
			local throw_sparks = 0
			local throw_bomb_ignite = 0
			local throw_size = 0
			local throw_glow = 0
			if ThrowCaps ~= nil then
				throw_damage = ThrowCaps.throw_damage or {fleshy=1}
				throw_sound = ThrowCaps.throw_sound or "rangedweapons_glock"
				throw_velocity = ThrowCaps.throw_velocity or 20
				throw_accuracy = ThrowCaps.throw_accuracy or 100
				throw_cooling = ThrowCaps.throw_cooling or itemstack:get_name()
				throw_crit = ThrowCaps.throw_crit or 0
				throw_critEffc = ThrowCaps.throw_critEffc or 1
				throw_projectiles = ThrowCaps.throw_projectiles or 1
				throw_mobPen = ThrowCaps.throw_mob_penetration or 0
				throw_nodePen = ThrowCaps.throw_node_penetration or 0
				throw_dps = ThrowCaps.throw_dps or 0
				throw_gravity = ThrowCaps.throw_gravity or 0
				throw_door_breaking = ThrowCaps.throw_door_breaking or 0
				throw_ent = ThrowCaps.throw_entity or "rangedweapons:shot_bullet"
				throw_visual = ThrowCaps.throw_visual or "wielditem"
				throw_texture = ThrowCaps.throw_texture or "rangedweapons:shot_bullet_visual"
				throw_glass_breaking = ThrowCaps.throw_glass_breaking or 0
				throw_particles = ThrowCaps.throw_particles or nil
				throw_sparks = ThrowCaps.throw_sparks or 0
				throw_bomb_ignite = ThrowCaps.ignites_explosives or 0
				throw_size = ThrowCaps.throw_projectile_size or 0
				throw_glow = ThrowCaps.throw_projectile_glow or 0
				OnCollision = ThrowCaps.OnCollision or function()end
				if ThrowCaps.throw_skill ~= nil then
					throw_skill = ThrowCaps.throw_skill[1] or ""
					throw_skillChance = ThrowCaps.throw_skill[2] or 0
				else
					throw_skill = ""
					throw_skillChance = 0
				end
			end
			if throw_skillChance > 0 and throw_skill ~= "" then
				rangedweapons_gain_skill(player,throw_skill,throw_skillChance)
			end
			if throw_skill ~= "" then
				skill_value = playerMeta:get_int(throw_skill)/100
			else
				skill_value = 1
			end
			rangedweapons_launch_projectile(player,throw_projectiles,throw_damage,throw_ent,throw_visual,throw_texture,throw_sound,throw_velocity,throw_accuracy,skill_value,OnCollision,throw_crit,throw_critEffc,throw_mobPen,throw_nodePen,0,"","","",throw_dps,throw_gravity,throw_door_breaking,throw_glass_breaking,throw_particles,throw_sparks,throw_bomb_ignite,throw_size,0,itemstack:get_wear(),throw_glow)
			itemstack:take_item()
		end
	end
end

rangedweapons_shoot_gun = function(itemstack, player)
	if not bs_match.match_is_started then return end
	if minetest.find_node_near(player:getpos(), 10,"rangedweapons:antigun_block") then
		minetest.sound_play("rangedweapons_empty", {pos = player:get_pos(), gain = 0.3, max_hear_distance = 60})
		minetest.chat_send_player(player:get_player_name(), "" ..core.colorize("#ff0000","Guns are prohibited in this area!"))
	else
		local gun_cooldown = 0
		local GunCaps = itemstack:get_definition().RW_gun_capabilities
		local gun_ammo_save = 0
		if GunCaps ~= nil then
			gun_cooldown = GunCaps.gun_cooldown or 0
			gun_ammo_save = GunCaps.ammo_saving or 0
		end
		local gunMeta = itemstack:get_meta()
		local playerMeta = player:get_meta()
		if rangedweapons.bullets[Name(player)] and rangedweapons.cooldown[Name(player)] and rangedweapons.bullets[Name(player)] > 0 and rangedweapons.cooldown[Name(player)] <= 0 then
			rangedweapons.cooldown[Name(player)] = gun_cooldown
			rangedweapons.bullets[Name(player)] = rangedweapons.bullets[Name(player)] - 1
			--hb.change_hudbar(player, "ammo", rangedweapons.bullets[Name(player)])
			if rangedweapons.hud_bars[player:get_player_name()] and rangedweapons.hud_bars[player:get_player_name()].fi then
				player:hud_change(rangedweapons.hud_bars[player:get_player_name()].fi, "number", ((rangedweapons.bullets[Name(player)]/rangedweapons.bullets_max[Name(player)]) * 20))
				player:hud_change(rangedweapons.hud_bars[player:get_player_name()].tx, "text", "Ammo: "..rangedweapons.bullets[Name(player)].."/"..rangedweapons.bullets_max[Name(player)])
			end
			local gun_icon = "rangedweapons_emergency_gun_icon.png"
			if GunCaps.gun_icon ~= nil then
				gun_icon = GunCaps.gun_icon
			end
			--hb.change_hudbar(player, "ammo", nil, nil, gun_icon, nil, nil)
			local OnCollision = function() end
			local bulletStack = ItemStack({name = rangedweapons.ammo_names[Name(player)]})
			local AmmoCaps = bulletStack:get_definition().RW_ammo_capabilities
			local gun_damage = {fleshy=1}
			local gun_sound = "rangedweapons_glock"
			local gun_velocity = 20
			local gun_accuracy = 100
			local gun_cooling = 0
			local gun_crit = 0
			local gun_critEffc = 1
			local gun_mobPen = 0
			local gun_nodePen = 0
			local gun_shell = 0
			local gun_durability = 0
			local gun_dps = 0
			local gun_gravity = 0
			local gun_door_breaking = 0
			local gun_skill = ""
			local gun_skillChance =0
			local gun_smokeSize =0
			local bullet_damage = {fleshy=0}
			local bullet_velocity = 0
			local bullet_ent = "rangedweapons:shot_bullet"
			local bullet_visual = "wielditem"
			local bullet_texture = "rangedweapons:shot_bullet_visual"
			local bullet_crit = 0
			local bullet_critEffc = 0
			local bullet_projMult = 1
			local bullet_mobPen = 0
			local bullet_nodePen = 0
			local bullet_shell_ent = ""
			local bullet_shell_visual = "wielditem"
			local bullet_shell_texture = "rangedweapons:shelldrop"
			local bullet_dps = 0
			local bullet_gravity = 0
			local bullet_glass_breaking = 0
			local bullet_particles = {}
			local bullet_sparks = 0
			local bullet_bomb_ignite = 0
			local bullet_size = 0
			local bullet_glow = 20
			if GunCaps ~= nil then
				gun_damage = GunCaps.gun_damage or {fleshy=1}
				gun_sound = GunCaps.gun_sound or "rangedweapons_glock"
				gun_velocity = GunCaps.gun_velocity or 20
				gun_accuracy = GunCaps.gun_accuracy or 100
				gun_cooling = GunCaps.gun_cooling or itemstack:get_name()
				gun_crit = GunCaps.gun_crit or 0
				gun_critEffc = GunCaps.gun_critEffc or 1
				gun_projectiles = GunCaps.gun_projectiles or 1
				gun_mobPen = GunCaps.gun_mob_penetration or 0
				gun_nodePen = GunCaps.gun_node_penetration or 0
				gun_shell = GunCaps.has_shell or 0
				gun_durability = GunCaps.gun_durability or 0
				gun_dps = GunCaps.gun_dps or 0
				gun_ammo_save = GunCaps.ammo_saving or 0
				gun_gravity = GunCaps.gun_gravity or 0
				gun_door_breaking = GunCaps.gun_door_breaking or 0
				gun_smokeSize = GunCaps.gun_smokeSize or 0
				if GunCaps.gun_skill ~= nil then
					gun_skill = GunCaps.gun_skill[1] or ""
					gun_skillChance = GunCaps.gun_skill[2] or 0
				else
					gun_skill = ""
					gun_skillChance = 0
				end
			end
			if gun_skillChance > 0 and gun_skill ~= "" then
				rangedweapons_gain_skill(player,gun_skill,gun_skillChance)
			end
			local ammo_icon = "rangedweapons_emergency_ammo_icon.png"
			if bulletStack:get_definition().inventory_image ~= nil then
				ammo_icon = bulletStack:get_definition().inventory_image
			end
			if AmmoCaps ~= nil then
				OnCollision = AmmoCaps.OnCollision or function()end
				bullet_damage = AmmoCaps.ammo_damage or {fleshy=1}
				bullet_velocity = AmmoCaps.ammo_velocity or 3
				bullet_ent = AmmoCaps.ammo_entity or "rangedweapons:shot_bullet"
				bullet_visual = AmmoCaps.ammo_visual or "wielditem"
				bullet_texture = AmmoCaps.ammo_texture or "rangedweapons:shot_bullet_visual"
				bullet_crit = AmmoCaps.ammo_crit or 0
				bullet_critEffc = AmmoCaps.ammo_critEffc or 0
				bullet_projMult = AmmoCaps.ammo_projectile_multiplier or 1
				bullet_mobPen = AmmoCaps.ammo_mob_penetration or 0
				bullet_nodePen = AmmoCaps.ammo_node_penetration or 0
				bullet_shell_ent = ""
				bullet_shell_visual = AmmoCaps.shell_visual or "wielditem"
				bullet_shell_texture = AmmoCaps.shell_texture or "rangedweapons:shelldrop"
				bullet_dps = AmmoCaps.ammo_dps or 0
				bullet_gravity = AmmoCaps.ammo_gravity or 0
				bullet_glass_breaking = AmmoCaps.ammo_glass_breaking or 0
				bullet_particles = AmmoCaps.ammo_particles or nil
				bullet_sparks = AmmoCaps.has_sparks or 0
				bullet_bomb_ignite = AmmoCaps.ignites_explosives or 0
				bullet_size = AmmoCaps.ammo_projectile_size or 0.0025
				bullet_glow = AmmoCaps.ammo_projectile_glow or 20
			end
			local combined_crit = gun_crit + bullet_crit
			local combined_critEffc = gun_critEffc + bullet_critEffc
			local combined_velocity = gun_velocity + bullet_velocity * 2
			local combined_projNum = math.ceil(gun_projectiles * bullet_projMult)
			local combined_mobPen = gun_mobPen + bullet_mobPen
			local combined_nodePen = gun_nodePen + bullet_nodePen
			local combined_dps = gun_dps + bullet_dps
			local combined_dmg = {}
			local combined_gravity = gun_gravity + bullet_gravity
			for _, gunDmg in pairs(gun_damage) do
				if bullet_damage[_] ~= nil then
					combined_dmg[_] = gun_damage[_] + bullet_damage[_]
				else
					combined_dmg[_] = gun_damage[_]
				end
			end
			for _, bulletDmg in pairs(bullet_damage) do
				if gun_damage[_] == nil then
					combined_dmg[_] = bullet_damage[_]
				end
			end
			rangedweapons_launch_projectile(player,combined_projNum,combined_dmg,bullet_ent,bullet_visual,bullet_texture,gun_sound,combined_velocity,gun_accuracy,skill_value,OnCollision,combined_crit,combined_critEffc,combined_mobPen,combined_nodePen,gun_shell,bullet_shell_ent,bullet_shell_texture,bullet_shell_visual,combined_dps,combined_gravity,gun_door_breaking,bullet_glass_breaking,bullet_particles,bullet_sparks,bullet_bomb_ignite,bullet_size,gun_smokeSize,0,bullet_glow)
		end
	end
end

rangedweapons.calc_time_per_dist = function(dist, block_per_sec)
	return (dist / block_per_sec) / 2
end

rangedweapons.process = function(ray, user, look_dir, def)
	local hitpoint = ray:hit_object_or_node({
		node = function(ndef)
			return (ndef.walkable == true and ndef.pointable == true) or ndef.groups.liquid
		end,
		object = function(obj)
			return obj ~= user
		end
	})
	if hitpoint then
		if hitpoint.type == "node" then
			local node = minetest.get_node(hitpoint.under)
			local nodedef = minetest.registered_nodes[node.name]
			if nodedef.on_ranged_shoot or nodedef.groups.snappy or (nodedef.groups.oddly_breakable_by_hand or 0) >= 3 then
				if not minetest.is_protected(hitpoint.under, user:get_player_name()) then
					if nodedef.on_ranged_shoot then
						nodedef.on_ranged_shoot(hitpoint.under, node, user, def.type)
					else
						minetest.dig_node(hitpoint.under)
					end
				end
			else
				if nodedef.walkable and nodedef.pointable then
					minetest.add_particle({
						pos = vector.subtract(hitpoint.intersection_point, vector.multiply(look_dir, 0.04)),
						velocity = vector.new(),
						acceleration = {x=0, y=0, z=0},
						expirationtime = def.bullethole_lifetime or 3,
						size = 1,
						collisiondetection = false,
						texture = "rangedweapons_bullethole.png",
					})
				elseif nodedef.groups.liquid then
					minetest.add_particlespawner({
						amount = 10,
						time = 0.1,
						minpos = hitpoint.intersection_point,
						maxpos = hitpoint.intersection_point,
						minvel = {x=look_dir.x * 3, y=4, z=-look_dir.z * 3},
						maxvel = {x=look_dir.x * 4, y=6, z= look_dir.z * 4},
						minacc = {x=0, y=-10, z=0},
						maxacc = {x=0, y=-13, z=0},
						minexptime = 1,
						maxexptime = 1,
						minsize = 0.5,
						maxsize = 1,
						collisiondetection = false,
						glow = 3,
						node = {name = nodedef.name},
					})
					if def.liquid_travel_dist then
						rangedweapons.process(rangedweapons.bc(hitpoint.intersection_point,vector.add(hitpoint.intersection_point, vector.multiply(look_dir, def.liquid_travel_dist)), true, false), user, look_dir, def)
					end
				end
			end
		elseif hitpoint.type == "object" then
			hitpoint.ref:punch(user, nil, {damage_groups = def.damage})
		end
	end
end

rangedweapons.bullet_colbox = {-0.0015,-0.0015,-0.0015,0.0015,0.0015,0.0015}

rangedweapons.bc = function(pos1, pos2, objects, liquids)
	minetest.add_particle({
		pos = pos1,
		velocity = vector.multiply(vector.direction(pos1, pos2), 400),
		acceleration = {x=0, y=0, z=0},
		expirationtime = 0.1,
		size = 1,
		collisiondetection = true,
		collision_removal = true,
		object_collision = objects,
		texture = "rangedweapons_bullet_fly.png",
		glow = 0
	})
	local raycast = minetest.raycast(pos1, pos2, objects, liquids)
	local bulletcast = {
		raycast = raycast,
		hit_object_or_node = function(self, options)
			if not options then
				options = {}
			end
			for hitpoint in self.raycast do
				if hitpoint.type == "node" then
					if not options.node or options.node(minetest.registered_nodes[minetest.get_node(hitpoint.under).name]) then
						return hitpoint
					end
				elseif hitpoint.type == "object" then
					if not options.object or options.object(hitpoint.ref) then
						return hitpoint
					end
				end
			end
		end,
	}
	setmetatable(bulletcast, {
		__index = function(table, key)
			local not_raycast_func = rawget(table, key)
			if not_raycast_func then
				return not_raycast_func
			else
				return function(self, ...)
					local sraycast = rawget(self, "raycast")
					return sraycast[key](sraycast, ...)
				end
			end
		end,
		__call = function(table, ...)
			return rawget(table, "raycast")(...)
		end
	})
	return bulletcast
end

rangedweapons.sbc = function(pos1, pos2, objects, liquids, amount)
	local rays = {}
	amount = amount or 1
	if amount > 1 then
		for i = 1, amount do
			rays[i] = rangedweapons.bc(pos1, vector.offset(pos2, math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)), objects, liquids)
		end
	else
		return {rangedweapons.bc(pos1, pos2, objects, liquids)}
	end
	return rays
end

rangedweapons.std = function(player)
	local look_dir = player:get_look_dir()
	local spawnpos = vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0)
	spawnpos = vector.add(spawnpos, player:get_eye_offset())
	spawnpos = vector.add(spawnpos, vector.multiply(look_dir, 0.4))
	return spawnpos, look_dir
end

rangedweapons_launch_projectile = function(player,projNum,projDmg,projEnt,visualType,texture,shoot_sound,combined_velocity,accuracy,skill_value,ColResult,projCrit,projCritEffc,mobPen,nodePen,has_shell,shellEnt,shellTexture,shellVisual,dps,gravity,door_break,glass_break,bullet_particles,sparks,ignite,size,smokeSize,proj_wear,proj_glow)
	local pos = player:get_pos()
	local dir = player:get_look_dir()
	local yaw = player:get_look_yaw()
	local svertical = player:get_look_vertical()
	--combined_velocity = combined_velocity + 5
	if pos and dir and yaw then
		minetest.sound_play(shoot_sound, {pos = player:get_pos(), gain = 0.5, max_hear_distance = 60})
		-- BEGIN NEW SHOOT SYSTEM - RAYCAST
		local pos1, lookdir = rangedweapons.std(player)
		local pos2 = vector.add(pos1, vector.multiply(lookdir, 100))
		local rays = rangedweapons.sbc(pos1, pos2, true, true, (tonumber(projNum) or 1))
		local def = {
			damage = projDmg,
			cooldown = rangedweapons.calc_time_per_dist(vector.distance(pos1, pos2), combined_velocity)
		}
		for _, ray in pairs(rays) do
			rangedweapons.process(ray, player, lookdir, def)
		end
	end
end



eject_shell = function(itemstack,player,rld_item,rld_time,rldsound,shell)
	itemstack:set_name(rld_item)
		local meta = player:get_meta()
		rangedweapons.cooldown[Name(player)] = rld_time

local gunMeta = itemstack:get_meta()

local bulletStack = ItemStack({name = rangedweapons.ammo_names[Name(player)]})

minetest.sound_play(rldsound, {pos = player:get_pos(), gain = 0.5, max_hear_distance = 20})
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		local yaw = player:get_look_yaw()
		if pos and dir and yaw then
			pos.y = pos.y + 1.6
			

if AmmoCaps and bulletStack ~= "" then
AmmoCaps = bulletStack:get_definition().RW_ammo_capabilities

local bullet_shell_visual = "wielditem"
local bullet_shell_texture = "rangedweapons:shelldrop"

bullet_shell_visual = AmmoCaps.shell_visual or "wielditem"
bullet_shell_texture = AmmoCaps.shell_texture or "rangedweapons:shelldrop"

--obj:set_properties({textures = {bullet_shell_texture}})
--obj:set_properties({visual = bullet_shell_visual})

end
			if obj then
--obj:set_velocity({x=dir.x*-10, y=dir.y*-10, z=dir.z*-10})
--obj:set_acceleration({x=dir.x*-5, y=-10, z=dir.z*-5})
	--obj:set_yaw(yaw + math.pi)
	end end end
---------------------------------------------------


dofile(modpath.."/item_onAct.lua")
dofile(modpath.."/settings.lua")
dofile(modpath.."/cooldown_stuff.lua")
dofile(modpath.."/skills.lua")
dofile(modpath.."/misc.lua")
dofile(modpath.."/bullet_knockback.lua")
dofile(modpath.."/ammo.lua")
dofile(modpath.."/crafting.lua")

if rweapons_shurikens == "true" then
	dofile(modpath.."/shurikens.lua")
end

if rweapons_handguns == "true" then
	dofile(modpath.."/makarov.lua")
	dofile(modpath.."/luger.lua")
	dofile(modpath.."/beretta.lua")
	dofile(modpath.."/m1991.lua")
	dofile(modpath.."/glock17.lua")
	dofile(modpath.."/deagle.lua")
end

if rweapons_forceguns == "true" then
	dofile(modpath.."/forcegun.lua")
end

if rweapons_javelins == "true" then
	dofile(modpath.."/javelin.lua")
end

if rweapons_power_weapons == "true" then
	dofile(modpath.."/generator.lua")
	dofile(modpath.."/laser_blaster.lua")
	dofile(modpath.."/laser_rifle.lua")
	dofile(modpath.."/laser_shotgun.lua")
end

if rweapons_machine_pistols == "true" then
	dofile(modpath.."/tmp.lua")
	dofile(modpath.."/tec9.lua")
	dofile(modpath.."/uzi.lua")
	dofile(modpath.."/kriss_sv.lua")
end
if rweapons_shotguns == "true" then
	dofile(modpath.."/remington.lua")
	dofile(modpath.."/spas12.lua")
	dofile(modpath.."/benelli.lua")
end
if rweapons_auto_shotguns == "true" then
	dofile(modpath.."/jackhammer.lua")
	dofile(modpath.."/aa12.lua")
end
if rweapons_smgs == "true" then
	dofile(modpath.."/mp5.lua")
	dofile(modpath.."/ump.lua")
	dofile(modpath.."/mp40.lua")
	dofile(modpath.."/thompson.lua")
end
if rweapons_rifles == "true" then
	dofile(modpath.."/awp.lua")
	dofile(modpath.."/svd.lua")
	dofile(modpath.."/m200.lua")
end
if rweapons_heavy_machineguns == "true" then
	dofile(modpath.."/m60.lua")
	dofile(modpath.."/rpk.lua")
	dofile(modpath.."/minigun.lua")
end
if rweapons_revolvers == "true" then
	dofile(modpath.."/python.lua")
	dofile(modpath.."/taurus.lua")
end
if rweapons_assault_rifles == "true" then
	dofile(modpath.."/m16.lua")
	dofile(modpath.."/g36.lua")
	dofile(modpath.."/ak47.lua")
	dofile(modpath.."/scar.lua")
end

if rweapons_explosives == "true" then
	dofile(modpath.."/explosives.lua")
	dofile(modpath.."/m79.lua")
	dofile(modpath.."/milkor.lua")
	dofile(modpath.."/rpg.lua")
	dofile(modpath.."/hand_grenade.lua")
end


if rweapons_glass_breaking == "true" then
	dofile(modpath.."/glass_breaking.lua")
end

rangedweapons.hud_bars = {}

local position = {x=0.75,y=1}
local offset = {x=0,y=-30}
minetest.register_on_joinplayer(function(player)
	--hb.init_hudbar(player, "ammo", 0, 150, false)
	hits[Name(player)] = player:hud_add({
		hud_elem_type = "image",
		text = "invisible.png",
		scale = {x = 2, y = 2},
		position = {x = 0.5, y = 0.5},
		offset = {x = 0, y = 0},
		alignment = {x = 0, y = 0}
	})
	scope_huds[Name(player)] = player:hud_add({
		hud_elem_type = "image",
		position = { x=0.5, y=0.5 },
		scale = { x=2.5, y=2.5},
		text = "invisible.png",
	})
end)
bs.cbs.register_OnAssignTeam(function(player, team)
	-- hud bars ammo
	if not rangedweapons.hud_bars[player:get_player_name()] then
		rangedweapons.hud_bars[player:get_player_name()] = {
			bg = player:hud_add({
				hud_elem_type = "statbar",
				position = position,
				scale = {x=1,y=1},
				text = (team == "" and "") or "ammo_bar_bg.png",
				number = 20,
				alignment = {x=-1,y=-1},
				offset = offset,
				direction = 0,
				size = {x = 23, y = 23},
			}),
			fi = player:hud_add({
				hud_elem_type = "statbar",
				position = position,
				text = (team == "" and "") or "ammo_bar.png",
				number = 0,
				alignment = {x=-1,y=-1},
				offset = offset,
				direction = 0,
				size = {x = 23, y = 23},
			}),
			tx = player:hud_add({
				hud_elem_type = "text",
				scale = {x = 1.5, y = 1.5},
				position = position,
				offset = {x = 60, y = -17},
				alignment = {x = "center", y = "up"},
				text = (team == "" and "") or "Ammo: 0/0",
				number = 0xFFFFFF,
			})
		}
	else
		if team == "" then
			player:hud_change(rangedweapons.hud_bars[Name(player)].bg, "text", "blank.png")
			player:hud_change(rangedweapons.hud_bars[Name(player)].fi, "text", "blank.png")
			player:hud_change(rangedweapons.hud_bars[Name(player)].tx, "text", " ")
		else
			player:hud_change(rangedweapons.hud_bars[Name(player)].bg, "text", "ammo_bar_bg.png")
			player:hud_change(rangedweapons.hud_bars[Name(player)].fi, "text", "ammo_bar.png")
			player:hud_change(rangedweapons.hud_bars[Name(player)].tx, "text", "Ammo: 0/0")
		end
	end
end)

--[[
	local timer = 0
minetest.register_globalstep(function(dtime, player)
	timer = timer + dtime;
	if timer >= 1.0 then
	for _, player in pairs(minetest.get_connected_players()) do
player:hud_change(hits[Name(player)], "text", "rangedweapons_empty_icon.png")
	timer = 0
			end
			end
				end)
--]]


