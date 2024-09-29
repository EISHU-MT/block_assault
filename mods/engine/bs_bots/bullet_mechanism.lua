-- Change shoot mechanism

--[[-- OBJ
local function on_step(self, dtime, mr)
	if self.timer >= 1 then
		self.object:remove()
		return
	end
	if mr.collides == true then
		local collisions = mr.collisions[1]
		if not collisions then
			return
		end
		if collisions.type == "object" then
			local obj = collisions.object
			if type(self.owner) ~= "userdata" then -- avoid crash from this
				self.object:remove()
				return
			end
			if Name(obj) and Name(self.owner) and Name(obj) ~= Name(self.owner) then
				local ObjectTeam = bs.get_player_team_css(collisions.object)
				if ObjectTeam ~= bots.data[Name(self.owner)].team then
					if PlayerArmor and collisions.object:is_player() then
						local enemy_pos = collisions.object:get_pos()
						local bullet_pos = self.object:get_pos()
						if enemy_pos and bullet_pos then
							local upper_enemy_pos = vector.add(enemy_pos, vector.new(0,1.55,0))
							if bullet_pos.y >= upper_enemy_pos.y then
								for name, dmg in pairs(self.damage) do
									--self.damage[name] = dmg + 15 - PlayerArmor.HeadHPDifference[Name(collisions.object)] -- too much.
								end
							else
								for name, dmg in pairs(self.damage) do
									self.damage[name] = dmg - PlayerArmor.DifferenceOfHP[Name(collisions.object)]
								end
							end
						end
						collisions.object:punch(self.owner, nil, {damage_groups = self.damage}, nil)
					else
						collisions.object:punch(self.owner, nil, {damage_groups = self.damage}, nil)
					end
				end
				self.object:remove()
			end
		elseif collisions.type == "node" then
			minetest.add_particle({
				pos = self.object:get_pos(),
				velocity = {x=0, y=0, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 30,
				size = math.random(10,20)/10,
				collisiondetection = false,
				vertical = false,
				texture = "rangedweapons_bullethole.png",
				glow = 0,
			})
			self.object:remove()
			return
		end
		if self.timer >= 2 then
			self.object:remove()
		end
	end
	--print(dump(mr.collisions))
	
	if not mr.collisions[1] then
		return
	end
	self.timer = self.timer + dtime
end

local def = {
	timer = 0,
	initial_properties = {
		physical = true,
		hp_max = 420,
		glow = core.LIGHT_MAX,
		visual = "sprite",
		visual_size = {x=0.4, y=0.4},
		textures = {"bullet2.png"},
		lastpos = {},
		collide_with_objects = true,
		collisionbox = {-0.0025, -0.0025, -0.0025, 0.0025, 0.0025, 0.0025},
		static_save = false,
	},
	owner = {},
	damage = {fleshy = 5}, -- Default
	on_step = on_step
}

core.register_entity("bs_bots:bullet", def)

local bullets_cache = {}

bots.shoot = function(projectiles, dmg, entname, shoot_sound, combined_velocity, data, obj)
	local to_pos = obj:get_pos()
	local pos = data.object:get_pos()
	if not (to_pos or pos) then return end
	local entity = data.object:get_luaentity()
	local dir = bots.calc_dir(data.object:get_rotation())
	local yaw = data.object:get_yaw()
	local random = math.random(0, 23)
	to_pos = vector.subtract(to_pos, vector.new(0,0.3,0))
	local direction = vector.direction(pos, to_pos)
	--local tmpsvertical = data.object:get_rotation().x / (math.pi/2)
	--local svertical = math.asin(direction.y) - (math.pi/2)
	combined_velocity = combined_velocity + 5
	if vector.distance(pos, to_pos) > 3 then
		if pos and dir and yaw then
			minetest.sound_play(shoot_sound, {pos = pos, gain = 0.5, max_hear_distance = 60})
			pos.y = pos.y + 1.45
			projectiles = projectiles or 1
			for i=1,projectiles do
				local spawnpos_x = pos.x
				local spawnpos_y = pos.y
				local spawnpos_z = pos.z
				Pleaselocal obj = minetest.add_entity({x=spawnpos_x,y=spawnpos_y,z=spawnpos_z}, entname)
				local ent = obj:get_luaentity()
				local size = 0.1
				obj:set_properties({
					textures = {"bullet2.png"},
					visual = "sprite",
					visual_size = {x=0.1, y=0.1},
					collisionbox = {-size, -size, -size, size, size, size},
					glow = proj_glow,
				})
				
				ent.owner = data.object
				ent.damage = dmg or {fleshy = bots.default_bullet_damage}
				
				--bullets_cache[FormRandomString(4)] = {obj = obj, time = 2}
				
				obj:set_pos(pos)
				obj:set_velocity({x=direction.x * combined_velocity, y=direction.y * combined_velocity, z=direction.z * combined_velocity})
			end
		end
	--else
		--bots.Hunt(self, obj)
	end
end

local function on_step(dtime)
	for id, data in pairs(bullets_cache) do
		bullets_cache[id].time = bullets_cache[id].time - dtime
		if bullets_cache[id].time <= 0 then
			bullets_cache[id].obj:remove()
			bullets_cache[id] = nil
		end
	end
end

core.register_globalstep(on_step)
--]]

local bullet_api = {}

bullet_api.calc_time_per_dist = function(dist, block_per_sec)
	return (dist / block_per_sec) / 2
end

bullet_api.process = function(ray, user, look_dir, def)
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
				if nodedef.on_ranged_shoot then
					nodedef.on_ranged_shoot(hitpoint.under, node, user, def.type)
				else
					minetest.dig_node(hitpoint.under)
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
						bullet_api.process(bullet_api.bc(hitpoint.intersection_point,vector.add(hitpoint.intersection_point, vector.multiply(look_dir, def.liquid_travel_dist)), true, false), user, look_dir, def)
					end
				end
			end
		elseif hitpoint.type == "object" then
			hitpoint.ref:punch(user, nil, {damage_groups = def.damage})
		end
	end
end

bullet_api.bullet_colbox = {-0.0015,-0.0015,-0.0015,0.0015,0.0015,0.0015}

bullet_api.bc = function(pos1, pos2, objects, liquids)
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

bullet_api.sbc = function(pos1, pos2, objects, liquids, amount)
	local rays = {}
	amount = amount or 1
	if amount > 1 then
		for i = 1, amount do
			rays[i] = bullet_api.bc(pos1, vector.offset(pos2, math.random(-2, 2), math.random(-2, 2), math.random(-2, 2)), objects, liquids)
		end
	else
		return {bullet_api.bc(pos1, pos2, objects, liquids)}
	end
	return rays
end

bullet_api.std = function(player, obj)
	local look_dir = vector.direction(player:get_pos(), obj:get_pos())
	local spawnpos = vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0)
	spawnpos = vector.add(spawnpos, vector.multiply(look_dir, 0.4))
	return spawnpos, look_dir
end

bots.shoot = function(_, dmg, entname, shoot_sound, combined_velocity, data, obj)
	local pos = data.object:get_pos()
	local dir = vector.direction(pos, obj:get_pos())--bots.calc_dir(data.object:get_rotation())
	local yaw = data.object:get_yaw()
	if pos and dir and yaw then
		minetest.sound_play(shoot_sound, {pos = pos, gain = 0.5, max_hear_distance = 60})
		-- BEGIN NEW SHOOT SYSTEM - RAYCAST
		local pos1, lookdir = bullet_api.std(data.object,  obj)
		local pos2 = vector.add(pos1, vector.multiply(lookdir, 100))
		local rays = bullet_api.sbc(pos1, pos2, true, true, (tonumber(projNum) or 1))
		local def = {
			damage = dmg,
			cooldown = bullet_api.calc_time_per_dist(vector.distance(pos1, pos2), combined_velocity)
		}
		for _, ray in pairs(rays) do
			bullet_api.process(ray, data.object, lookdir, def)
		end
	end
end






