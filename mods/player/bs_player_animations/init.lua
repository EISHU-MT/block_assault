if config.TypeOfAnimation == "bas_pas" then
	if not minetest.settings then
		error("Mod playeranim requires Minetest 0.4.16 or newer")
	end

	local ANIMATION_SPEED = tonumber(minetest.settings:get("playeranim.animation_speed")) or 2.4
	local ANIMATION_SPEED_SNEAK = tonumber(minetest.settings:get("playeranim.animation_speed_sneak")) or 0.8
	local BODY_ROTATION_DELAY = 0.1
	local BODY_X_ROTATION_SNEAK = tonumber(minetest.settings:get("playeranim.body_x_rotation_sneak")) or 6.0

	local BONE_POSITION, BONE_ROTATION = (function()
		local modname = minetest.get_current_modname()
		local modpath = minetest.get_modpath(modname)
		return dofile(modpath .. "/model.lua")
	end)()

	local get_animation = player_api.get_animation

	-- stop player_api from messing stuff up (since 5.3)
	if player_api then
		minetest.register_on_mods_loaded(function()
			for _, model in pairs(player_api.registered_models) do
				if model.animations then
					for _, animation in pairs(model.animations) do
						animation.x = 0
						animation.y = 0
					end
				end
			end
		end)

		minetest.register_on_joinplayer(function(player)
			player:set_local_animation(nil, nil, nil, nil, 0)
		end)
	end

	local function get_animation_speed(player)
		if player:get_player_control().sneak then
			return ANIMATION_SPEED_SNEAK
		end
		return ANIMATION_SPEED
	end

	local math_deg = math.deg
	local function get_pitch_deg(player)
		return math_deg(player:get_look_vertical())
	end

	players_animation_data = setmetatable({}, {
		__index = {
			init_player = function(self, player)
				self[player] = {
					time = 0,
					yaw_history = {},
					bone_rotations = {},
					bone_positions = {},
					previous_animation = 0,
				}
			end,

			-- time
			get_time = function(self, player)
				return self[player].time
			end,

			increment_time = function(self, player, dtime)
				self[player].time = self:get_time(player) + dtime
			end,

			reset_time = function(self, player)
				self[player].time = 0
			end,

			-- yaw_history
			get_yaw_history = function(self, player)
				return self[player].yaw_history -- Return mutable reference
			end,

			add_yaw_to_history = function(self, player)
				local yaw = player:get_look_horizontal()
				local history = self:get_yaw_history(player)
				history[#history + 1] = yaw
			end,

			clear_yaw_history = function(self, player)
				if #self[player].yaw_history > 0 then
					self[player].yaw_history = {}
				end
			end,

			-- bone_rotations
			get_bone_rotation = function(self, player, bone)
				return self[player].bone_rotations[bone]
			end,

			set_bone_rotation = function(self, player, bone, rotation)
				self[player].bone_rotations[bone] = rotation
			end,

			-- bone_positions
			get_bone_position = function(self, player, bone)
				return self[player].bone_positions[bone]
			end,

			set_bone_position = function(self, player, bone, position)
				self[player].bone_positions[bone] = position
			end,

			-- previous_animation
			get_previous_animation = function(self, player)
				return self[player].previous_animation
			end,

			set_previous_animation = function(self, player, animation)
				self[player].previous_animation = animation
			end,
		}
	})

	minetest.register_on_joinplayer(function(player)
		players_animation_data:init_player(player)
	end)

	local vector_add, vector_equals = vector.add, vector.equals
	local function rotate_bone(player, bone, rotation, position_optional)
		local previous_rotation = players_animation_data:get_bone_rotation(player, bone)
		local rotation = vector_add(rotation, BONE_ROTATION[bone])

		local previous_position = players_animation_data:get_bone_position(player, bone)
		local position = BONE_POSITION[bone]
		if position_optional then
			position = vector_add(position, position_optional)
		end

		if not previous_rotation
		or not previous_position
		or not vector_equals(rotation, previous_rotation)
		or not vector_equals(position, previous_position) then
			player:set_bone_position(bone, position, rotation)
			players_animation_data:set_bone_rotation(player, bone, rotation)
			players_animation_data:set_bone_position(player, bone, position)
		end
	end

	-- Animation alias
	local STAND = 1
	local WALK = 2
	local MINE = 3
	local WALK_MINE = 4
	local SIT = 5
	local LAY = 6
	local RMB = 7
	local RMB_W = 8
	local RMB_R = 11
	local RMB_WR = 12
	local RMB_RD = 13
	local RMB_WRD = 14
	local RMB_P = 15
	local RMB_PW = 16
	local DISABLED = 17

	-- Bone alias
	local BODY = "Body"
	local HEAD = "Head"
	local CAPE = "Cape"
	local LARM = "Arm_Left"
	local RARM = "Arm_Right"
	local LLEG = "Leg_Left"
	local RLEG = "Leg_Right"

	local math_sin, math_cos, math_pi = math.sin, math.cos, math.pi
	local ANIMATIONS = {
		[STAND] = function(player, _time)
			rotate_bone(player, BODY, {x = 0, y = 0, z = 0})
			rotate_bone(player, CAPE, {x = 0, y = 0, z = 0})
			rotate_bone(player, LARM, {x = 0, y = 0, z = 0})
			rotate_bone(player, RARM, {x = 0, y = 0, z = 0})
			rotate_bone(player, LLEG, {x = 0, y = 0, z = 0})
			rotate_bone(player, RLEG, {x = 0, y = 0, z = 0})
		end,

		[LAY] = function(player, _time)
			rotate_bone(player, HEAD, {x = 0, y = 0, z = 0})
			rotate_bone(player, CAPE, {x = 0, y = 0, z = 0})
			rotate_bone(player, LARM, {x = 0, y = 0, z = 0})
			rotate_bone(player, RARM, {x = 0, y = 0, z = 0})
			rotate_bone(player, LLEG, {x = 0, y = 0, z = 0})
			rotate_bone(player, RLEG, {x = 0, y = 0, z = 0})
			rotate_bone(player, BODY, BONE_ROTATION.body_lay, BONE_POSITION.body_lay)
		end,

		[SIT] = function(player, _time)
			rotate_bone(player, LARM, {x = 0,  y = 0, z = 0})
			rotate_bone(player, RARM, {x = 0,  y = 0, z = 0})
			rotate_bone(player, LLEG, {x = 90, y = 0, z = 0})
			rotate_bone(player, RLEG, {x = 90, y = 0, z = 0})
			rotate_bone(player, BODY, BONE_ROTATION.body_sit, BONE_POSITION.body_sit)
		end,

		[WALK] = function(player, time)
			local speed = get_animation_speed(player)
			local sin = math_sin(time * speed * math_pi)

			rotate_bone(player, CAPE, {x = -35 * sin - 35, y = 0, z = 0})
			rotate_bone(player, LARM, {x = -55 * sin,      y = 0, z = 0})
			rotate_bone(player, RARM, {x = 55 * sin,       y = 0, z = 0})
			rotate_bone(player, LLEG, {x = 55 * sin,       y = 0, z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,      y = 0, z = 0})
		end,

		[MINE] = function(player, time)
			local speed = get_animation_speed(player)

			local cape_sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * math.random(0.0, 0.2) * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -5 * cape_sin - 5,     y = 0,             z = 0})
			rotate_bone(player, LARM, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, LLEG, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = 0,                     y = 0,             z = 0})
		end,

		[WALK_MINE] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			rotate_bone(player, LARM, {x = -55 * sin,             y = 0,             z = 0})
			rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, LLEG, {x = 55 * sin,              y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,             y = 0,             z = 0})
		end,
		
		[RMB] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local cape_sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * math.random(0.0, 0.2) * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -5 * cape_sin - 5,     y = 0,             z = 0})
			rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, RARM, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, LLEG, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = 0,                     y = 0,             z = 0})
		end,
		
		[RMB_W] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, RARM, {x = -55 * sin,             y = 0,             z = 0})
			rotate_bone(player, LLEG, {x = 55 * sin,              y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,             y = 0,             z = 0})
		end,
		
		[RMB + 1] = function(player, time)
			local speed = get_animation_speed(player)

			local cape_sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * math.random(0.0, 0.2) * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -5 * cape_sin - 5,     y = 0,             z = 0})
			rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, LLEG, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = 0,                     y = 0,             z = 0})
		end,
		
		[RMB_W + 1] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			rotate_bone(player, LLEG, {x = 55 * sin,              y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,             y = 0,             z = 0})
		end,
		[RMB_R] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)
			
			local ct = Player(player):get_player_control()
			
			local dig = ct.LMB
			

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			rotate_bone(player, LARM, {x = (130),       y = 35,            z = -8})
			
			if dig then
				rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			else
				rotate_bone(player, RARM, {x = 0,                     y = 0,             z = 0})
			end
			
			rotate_bone(player, LLEG, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = 0,                     y = 0,             z = 0})
		end,
		[RMB_WR] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)
			
			local ct = Player(player):get_player_control()
			
			local dig = ct.LMB
			

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			rotate_bone(player, LARM, {x = (130),       y = 35,            z = -8})
			
			if dig then
				rotate_bone(player, RARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			else
				rotate_bone(player, RARM, {x = 0,                     y = 0,             z = 0})
			end
			
			rotate_bone(player, LLEG, {x = 55 * sin,              y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,             y = 0,             z = 0})
		end,
		[RMB_PW] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)
			
			local ct = Player(player):get_player_control()
			
			local rmb = ct.RMB
			

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			
			rotate_bone(player, RARM, {x = 98,                   y = -10,           z = 0})
			
			if rmb then
				rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			else
				rotate_bone(player, LARM, {x = 0,                     y = 0,             z = 0})
			end
			
			rotate_bone(player, LLEG, {x = 55 * sin,              y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = -55 * sin,             y = 0,             z = 0})
		end,
		[RMB_P] = function(player, time)
			local speed = get_animation_speed(player)

			local sin = math_sin(time * speed * math_pi)
			local rarm_sin = math_sin(2 * time * speed * math_pi)
			local rarm_cos = -math_cos(2 * time * speed * math_pi)
			local pitch = 90 - get_pitch_deg(player)
			
			local ct = Player(player):get_player_control()
			
			local rmb = ct.RMB
			

			rotate_bone(player, CAPE, {x = -35 * sin - 35,        y = 0,             z = 0})
			
			rotate_bone(player, RARM, {x = -98,                   y = -10,           z = -math.random(0, 2)})
			
			if rmb then
				rotate_bone(player, LARM, {x = 10 * rarm_sin + pitch, y = math.random(0, 4),             z = 0})
			else
				rotate_bone(player, LARM, {x = 0,                     y = 0,             z = 0})
			end
			
			rotate_bone(player, LLEG, {x = 0,                     y = 0,             z = 0})
			rotate_bone(player, RLEG, {x = 0,                     y = 0,             z = 0})
		end,
	}

	local RMB_W2 = RMB_W + 1
	local RMB2 = RMB + 1

	local function set_animation(player, animation, force_animate)
		local animation_changed
				= (players_animation_data:get_previous_animation(player) ~= animation)

		if force_animate or animation_changed then
			players_animation_data:set_previous_animation(player, animation)
			ANIMATIONS[animation](player, players_animation_data:get_time(player))
		end
	end

	local function rotate_head(player)
		local head_x_rotation = -get_pitch_deg(player)
		rotate_bone(player, HEAD, {x = head_x_rotation, y = 0, z = 0})
	end

	local table_remove, math_deg = table.remove, math.deg
	local function rotate_body_and_head(player)
		local body_x_rotation = (function()
			local sneak = player:get_player_control().sneak
			return sneak and BODY_X_ROTATION_SNEAK or 0
		end)()

		local body_y_rotation = (function()
			local yaw_history = players_animation_data:get_yaw_history(player)
			if #yaw_history > BODY_ROTATION_DELAY then
				local body_yaw = table_remove(yaw_history, 1)
				local player_yaw = player:get_look_horizontal()
				return math_deg(player_yaw - body_yaw)
			end
			return 0
		end)()

		rotate_bone(player, BODY, {x = body_x_rotation, y = body_y_rotation, z = 0})

		local head_x_rotation = -get_pitch_deg(player)
		--if rangedweapons.pointing[Name(player)] then
		--	rotate_bone(player, HEAD, {x = head_x_rotation, y = 6, z = 6.5})
		--else
		--	rotate_bone(player, HEAD, {x = head_x_rotation, y = -body_y_rotation, z = 0})
		--end
	end

	interpretor = {}
	interpretor.sa = set_animation
	interpretor.sb = rotate_bone

	local player_animate = animate_player -- Dont overload memory

	local function animate_player(player, dtime)
		local data = get_animation(player)
		if not data then
			-- Minetest Engine workaround for 5.6.0-dev and older
			-- minetest.register_globalstep may call to this function before the player is
			-- initialized by minetest.register_on_joinplayer in player_api
			return
		end

		local animation = data.animation

		-- Yaw history
		if animation == "lay" or animation == "sit" then
			players_animation_data:clear_yaw_history(player)
		else
			players_animation_data:add_yaw_to_history(player)
		end
		
		if DO_ANIMATION then
			DO_ANIMATION(player, animation, dtime)
		end

		-- Increment animation time
		if animation == "walk"
		or animation == "mine"
		or animation == "walk_mine" then
			players_animation_data:increment_time(player, dtime)
		else
			players_animation_data:reset_time(player)
		end
		
		
		
		

		-- Rotate body and head
		if animation == "lay" then
			-- Do nothing
		elseif animation == "sit" then
			rotate_head(player)
		else
			rotate_body_and_head(player)
		end
	end

	local minetest_get_connected_players = minetest.get_connected_players
	minetest.register_globalstep(function(dtime)
		for _, player in ipairs(minetest_get_connected_players()) do
			animate_player(player, dtime)
		end
	end)
elseif config.TypeOfAnimation == "bas_default" then
	interpretor = {}
	interpretor.sa = function() end
	interpretor.sb = function() end
elseif config.TypeOfAnimation == "default" then
	interpretor = {}
	interpretor.sa = function() end
	interpretor.sb = function() end
end

local last_arm_dir = {}
local speed_players = {}
local is_speed_reset = {}
local get_connected_players = minetest.get_connected_players
local abs = math.abs
local deg = math.deg
local basepos = vector.new(0, 6.35, 0)
local lastdir = {}
DoPhysics = {
	--mao = {speed = 0, jump = 0, gravity = 1}
}
minetest.register_globalstep(function(dtime)
	if config.TypeOfAnimation == "bas_default" then
		for _, player in pairs(get_connected_players()) do
			-- Data
			local control = player:get_player_control()
			-- Head
			local pname = player:get_player_name()
			local ldeg = -deg(player:get_look_vertical())
			if abs((lastdir[pname] or 0) - ldeg) > 4 then
				lastdir[pname] = ldeg
				player:set_bone_position("Head", basepos, {x = ldeg, y = 0, z = 0})
			end
			-- Sneak
			if control.sneak then
				local properties = player:get_properties()
				properties.makes_footstep_sound = false
				player:set_properties(properties)
			else
				local properties = player:get_properties()
				properties.makes_footstep_sound = true
				player:set_properties(properties)
			end
			-- Free hand
			if bs_match.match_is_started then
				if physics then
					if not bs.spectator[Name(player)] then
						if not RespawnDelay.players[Name(player)] then
							local properties = player:get_properties()
							properties.pointable = true
							player:set_properties(properties)
						end
						if not DoPhysics[Name(player)] then
							if IsPointing(player) then
								player:set_physics_override({
									speed = physics.speed - 0.5,
									jump = 0,
									gravity = physics.gravity,
								})
							else
								if not Armor.QueuedToFullHP[Name(player)] then
									local wield_item = player:get_wielded_item()
									local item_name = wield_item:get_name()
									if item_name == ":" or item_name == " " or item_name == "" then
										player:set_physics_override({
											speed = physics.speed + 0.5,
											jump = physics.jump + 0.4,
											gravity = physics.gravity,
										})
									else
										player:set_physics_override({
											speed = physics.speed,
											jump = physics.jump,
											gravity = physics.gravity,
										})
									end
								else
									player:set_physics_override({
										speed = physics.speed - 0.5,
										jump = physics.jump - 0.4,
										gravity = physics.gravity,
									})
								end
							end
						else
							player:set_physics_override(DoPhysics[Name(player)])
						end
					else
						player:set_physics_override({
							gravity = physics.gravity,
							speed = physics.speed,
							jump = physics.jump
						})
					end
				end
			else
				if physics then
					if not bs.spectator[Name(player)] then
						is_speed_reset[Name(player)] = true
						local properties = player:get_properties()
						properties.pointable = false
						player:set_properties(properties)
						player:set_physics_override({
							gravity = physics.gravity,
							speed = physics.speed,
							jump = physics.jump
						})
					else
						player:set_physics_override({
							speed = 1,
							jump = 1
						})
					end
				end
			end
		end
	end
end)
minetest.register_on_leaveplayer(function(player)
	lastdir[player:get_player_name()] = nil
end)