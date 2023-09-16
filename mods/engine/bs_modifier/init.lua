--[[
	[BA.S] Modifier
	
	Modifies players actions
--]]

local function vector_random(pos, rad)
	return {
		x = math.random(pos.x, pos.x + rad),
		y = GetFloorPos(pos).y,
		z = math.random(pos.z, pos.z + rad),
	}
end

function SpawnPlayerAtRandomPosition(player, team)
	player:set_pos(CheckPos(vector_random(maps.current_map.teams[team], 3)))
end