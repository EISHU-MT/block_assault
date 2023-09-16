-- Unpack
rotate_bone = interpretor.sb
set_animation = interpretor.sa


-- Some variables
is_pointing = {}

local function is_advancing(control)
	return control.up or control.down
end

local function request_player_data(player)
	return player_api.get_animation(player)
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
	local data = request_player_data(player)
	if data then
		local animation = data.animation
		if animation == "sit" then
			return true, animation
		end
		if animation == "lay" then
			return true, animation
		end
	end
end


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

function DO_ANIMATION(player, animation, dtime)
	local control = player:get_player_control()
	
	local speed = get_animation_speed(player)
	local sin = math.sin(players_animation_data:get_time(player) * speed * math.pi)
	local rarm_sin = math.sin(2 * math.random(0.0, 0.2) * speed * math.pi)
	local rarm_cos = -math.cos(2 * players_animation_data:get_time(player) * speed * math.pi)
	local pitch = 90 - get_pitch_deg(player)
	
	local cConflict, typo = check_conflicts(player)
	local WConflicts, wtypo = check_onwalk_conflicts(player)
	
	
	local IsIdle = is_idle(animation)
	
	if IsIdle and not (WConflicts or cConflict) then
		rotate_bone(player, "Body", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Cape", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Arm_Right", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Leg_Left", {x = 0, y = 0, z = 0})
		rotate_bone(player, "Leg_Right", {x = 0, y = 0, z = 0})
	end
	
	if is_advancing(control) and not WConflicts then
		-- Animate legs
		rotate_bone(player, "Leg_Left", {x = 55 * sin, y = 0, z = 0})
		rotate_bone(player, "Leg_Right", {x = -55 * sin, y = 0, z = 0})
		-- Animate hands
		rotate_bone(player, "Arm_Left", {x = -55 * sin,      y = 0, z = 0})
		rotate_bone(player, "Arm_Right", {x = 55 * sin,       y = 0, z = 0})
	elseif not is_advancing(control) then
		if WConflicts and wtypo then
			if wtypo == "lay" then
				rotate_bone(player, "Head", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Cape", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Arm_Right", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Leg_Left", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Leg_Right", {x = 0, y = 0, z = 0})
				rotate_bone(player, "Body", {x = 270, y = 0, z = 0}, {x = 270, y = 0, z = 0})
			elseif wtype == "sit" then
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
	
	if IsPointing(player) then -- Pointing
		rotate_bone(player, "Head", {x = 0, y = 6, z = 6.5})
	else
		rotate_bone(player, "Head", {x = 0, y = 0, z = 0})
	end
	
	if control.LMB then
		if IsPointing(player) then -- Pointing
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = 1, z = 0})
		else
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = math.random(0, 4), z = 0})
		end
	else
		if IsPointing(player) then -- Pointing
			rotate_bone(player, "Arm_Right", {x = 10 * rarm_sin + pitch, y = 1, z = 0})
		else
			if is_advancing(control) then
				rotate_bone(player, "Arm_Right", {x = 55 * sin,       y = 0, z = 0})
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
			rotate_bone(player, "Arm_Left", {x = (60), y = 35, z = -8})
		else
			if is_advancing(control) then
				rotate_bone(player, "Arm_Left", {x = -55 * sin,       y = 0, z = 0})
			else
				rotate_bone(player, "Arm_Left", {x = 0, y = 0, z = 0})
			end
		end
	end
	
	
end

