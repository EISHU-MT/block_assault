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
		status = core.deserialize(content.meta:get("status")),
		teams = {
			red = add(content.offset, core.string_to_pos(content.meta:get("team.red"))),
			blue = add(content.offset, core.string_to_pos(content.meta:get("team.blue"))),
		},
		failed = false,
		pos1 = vector.add(content.offset, { x = -r, y = -h / 2, z = -r }),
		pos2 = vector.add(content.offset, { x = r, y = h / 2, z = r }),
		area_status = {},
	}
	
	if content.meta:get("team.yellow") and content.meta:get("team.green") then
		map.teams.yellow = add(content.offset, core.string_to_pos(content.meta:get("team.yellow")))
		map.teams.green = add(content.offset, core.string_to_pos(content.meta:get("team.green")))
	end
	
	if type(map.status) == "table" then
		for name, value in pairs(map.status) do
			if name and type(value) == "table" and value.pos and type(value.pos) == "table" and value.str then
				core.log("action", "Registering "..name.." for Area names....")
				if type(map.area_status[name]) ~= "table" then
					map.area_status[name] = {}
				end
				local pos1 = add(content.offset, core.string_to_pos(value.pos.p1))
				local pos2 = add(content.offset, core.string_to_pos(value.pos.p2))
				
				if pos1.y > pos2.y then
					up_pos = pos1
					down_pos = pos2
				elseif pos2.y > pos1.y then
					up_pos = pos2
					down_pos = pos1
				elseif pos2.y == pos1.y then
					up_pos = pos1
					down_pos = pos2
				elseif not pos2 or not pos1 then
					core.log("BsMaps engine Failed!: On searching non_radius areas: attempt to get a non existent value!: (pos1 and pos2)")
				end
				
				map.area_status[name].pos1 = up_pos
				map.area_status[name].pos2 = down_pos
				map.area_status[name].str = value.str
			end
		end
	end
	return map
end