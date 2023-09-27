local function request_offset(id, to_multiply)
	local amount = to_multiply or 250
	local a = amount * id
	return vector.new(a, a, a)
end

local add = vector.add

function process_meta(content)
	if type(content) ~= "table" then
		core.log("error", "Could not load a map!")
		return {failed = true}, {}
	end
	content.offset = request_offset(#maps.maps_name + 1)
	local r = tonumber(content.meta:get("r"))
	local h = tonumber(content.meta:get("h"))
	local map = {
		mcore = content.dirname.."/core.mts",
		dirname = content.dirname,
		name = content.name,
		r = tonumber(content.meta:get("r")),
		h = tonumber(content.meta:get("h")),
		rotation = content.meta:get("rotation"),
		author = content.meta:get("author"),
		offset = content.offset,
		physics = core.deserialize(content.meta:get("physics")) or {jump = 1, speed = 1, gravity = 1},
		teams = {
			red = add(content.offset, core.string_to_pos(content.meta:get("team.red"))),
			blue = add(content.offset, core.string_to_pos(content.meta:get("team.blue"))),
		},
		failed = false,
		pos1 = vector.add(content.offset, { x = -r, y = -h / 2, z = -r }),
		pos2 = vector.add(content.offset, { x = r, y = h / 2, z = r }),
		data = core.deserialize(content.meta:get("data")), -- Data for mods/game. Used from external overriders to determine map.
	}
	
	if content.meta:get("team.yellow") and content.meta:get("team.green") then
		map.teams.yellow = add(content.offset, core.string_to_pos(content.meta:get("team.yellow")))
		map.teams.green = add(content.offset, core.string_to_pos(content.meta:get("team.green")))
	end
	return map
end