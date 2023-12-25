--[[
	[BA.S] Modifier
	
	Modifies players actions
--]]

local function vector_random(pos, rad)
	return {
		x = math.random(pos.x, pos.x + rad),
		y = pos.y,
		z = math.random(pos.z, pos.z + rad),
	}
end

local function do_check_upper_pos(pos)
	pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	if core.get_node(pos).name ~= "air" then
		local returned_pos = CheckPos(pos)
		return returned_pos
	else
		return pos
	end
end

function SpawnPlayerAtRandomPosition(player, team)
	if player and Name(player) then
		player:set_pos(CheckPosForPlayer(vector_random(maps.current_map.teams[team], 2)))
	end
end