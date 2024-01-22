-- Unpack
rotate_bone = interpretor.sb
set_animation = interpretor.sa


-- Some variables
is_pointing = {}

local function is_advancing(control)
	return control.up or control.down or control.left or control.right
end

local function request_player_data(player)
	--return player_api.get_animation(player) --using this is deprecated
	-- THIS WILL DEPEND BAS EMOTES!
	return emote.get(player)
end

local function get_animation_speed(player)
	if player:get_player_control().sneak then
		return 0.8
	end
	return 2.4
end

local function check_conflicts(player)
	if false_variable then
		return true, "pointing"
	end
	if false_variable then
		return true, "recharging"
	end
	return false
end

local function check_onwalk_conflicts(player)
	local animation = request_player_data(player)
	if animation then
		if animation == "sit" then
			return true, animation
		end
		if animation == "lay" then
			return true, animation
		end
	end
	return false, ""
end

local abs = math.abs
local deg = math.deg
local basepos = vector.new(0, 6.35, 0)
local lastdir = {}


local function only_first_argument(func, ...)
	local toreturn = func(...)
	return toreturn
end

local function is_idle(animation)
	return animation == "stand"
end

local function get_pitch_deg(player)
	return math.deg(player:get_look_vertical())
end

local last_arm_dir = {}
local speed_players = {}
local is_speed_reset = {}

function DO_ANIMATION(player, animation, dtime)
	local control = player:get_player_control()
	
	if not control then return end
	
	local speed = get_animation_speed(player)
	local sin = math.sin(players_animation_data:get_time(player) * speed * math.pi)
	local rarm_sin = math.sin(2 * math.random(0.0, 0.2) * speed * math.pi)
	local rarm_cos = -math.cos(2 * players_animation_data:get_time(player) * speed * math.pi)
	local pitch = 90 - get_pitch_deg(player)
	
	local cConflict, typo = check_conflicts(player)
	local WConflicts, wtypo = check_onwalk_conflicts(player)
	
	local IsIdle = is_idle(animation)
	
	if IsIdle and not WConflicts then
		rotate_bone(player, "Body", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Cape", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Arm_Right", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Leg_Left", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Leg_Right", {x = 0, y = 0, z = 0})
	end
	
	if is_advancing(control) then
		if not WConflicts then
			-- Animate legs
			rotate_bone(player, "Leg_Left", {x = 55 * sin, y = 0, z = 0})
			rotate_bone(player, "Leg_Right", {x = -55 * sin, y = 0, z = 0})
			-- Animate hands
			rotate_bone(player, "Arm_Left", {x = -55 * sin,      y = 0, z = 0})
			rotate_bone(player, "Arm_Right", {x = 55 * sin,       y = 0, z = 0})
		end
	else	
		if WConflicts and wtypo then
			if wtypo == "lay" then
				rotate_bone(player, "Head", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Cape", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Arm_Right", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Leg_Left", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Leg_Right", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Body", {x = 270, y = 0, z = 0}, {x = 270, y = 0, z = 0})
				return
			elseif wtypo == "sit" then
				rotate_bone(player, "Arm_Left", {x = 0,  y = 0, z = 0})
				rotate_bone(player, "Arm_Right", {x = 0,  y = 0, z = 0})
				rotate_bone(player, "Leg_Left", {x = 90, y = 0, z = 0})
				rotate_bone(player, "Leg_Right", {x = 90, y = 0, z = 0})
				rotate_bone(player, "Body", {x = 0,   y = 0, z = 0}, {x = 0,   y = 0, z = 0})
			end
		else
			rotate_bone(player, "Leg_Left", {x = 0, y = 0, z = 0})
			rotate_bone(player, "Leg_Right", {x = 0, y = 0, z = 0})
		end
	end
	
	local pname = player:get_player_name()
	local ldeg = -deg(player:get_look_vertical() or 0)
	if abs((lastdir[pname] or 0) - ldeg) > 4 then
		lastdir[pname] = ldeg
	end
	
	if control.sneak then
		local properties = player:get_properties()
		properties.makes_footstep_sound = false
		player:set_properties(properties)
	else
		local properties = player:get_properties()
		properties.makes_footstep_sound = true
		player:set_properties(properties)
	end
	
	if bs_match.match_is_started then
		if physics and DoPhysics then
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
	
	if IsPointing(player) then -- Pointing
		rotate_bone(player, "Head", {x = ldeg, y = 6, z = 6.5})
	else
		rotate_bone(player, "Head", {x = ldeg, y = 0, z = 0})
	end
	
	if control.LMB then
		if IsPointing(player) then -- Pointing
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = 1, z = 0})
		else
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = 0, z = 0})
		end
	else
		if IsPointing(player) then -- Pointing
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = 1, z = 0})
		else
			if is_advancing(control) then
				if bs_match.match_is_started then
					rotate_bone(player, "Arm_Right", {x = 55 * sin,       y = 0, z = 0})
				end
			else
				rotate_bone(player, "Arm_Right", {x = 0, y = 0, z = 0})
			end
		end
	end
	
	if control.RMB then
		if IsRechargingGun(player) ~= true then
			rotate_bone(player, "Arm_Left", {x = 10 * rarm_sin + pitch, y = math.random(0, 4), z = 0})
		end
		
	else
		if IsRechargingGun(player) then
			rotate_bone(player, "Arm_Left", {x = (65), y = 35, z = -8})
		else
			if is_advancing(control) then
				if bs_match.match_is_started then
					rotate_bone(player, "Arm_Left", {x = -55 * sin,       y = 0, z = 0})
				end
			else
				rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
			end
		end
	end
	
	
end

