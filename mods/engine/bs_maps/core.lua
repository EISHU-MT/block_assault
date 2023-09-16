function maps.update_core()
	for name, def in pairs(maps.reg_maps) do
		if name and def then
			table.insert(maps.maps_name, name)
		end
	end
end
function maps.select_map()
	local maps_numb = #maps.maps_name
	local random_numb = math.random(1, maps_numb)
	if maps.next_map and maps.next_map.name ~= nil then
		return maps.next_map
	else
		local map_name = maps.maps_name[random_numb]
		local map_def = maps.reg_maps[map_name]
		return map_def
	end
end
function maps.place_map(map_def)
	maps.emerge_with_callbacks(nil, map_def.pos1, map_def.pos2, function()
		core.log("info", "Placing map: "..map_def.name)
		local bool = minetest.place_schematic(map_def.pos1, map_def.mcore, map_def.rotation == "z" and "0" or "90")
		assert(bool, "Something failed!: Map core: 'core.mts' dont exist, or may it was corrupted!")
		core.log("info", "ON-PLACE-MAP: Map light areas fix starting")
		local function fix_light(...) core.fix_light(...) core.log("action", "ON-PLACE-MAP: Map light areas fix complete") end
		core.after(5, fix_light, map_def.pos1, map_def.pos2)
	end, nil)
end

function maps.new_map()
	core.after(2, function()
		local def = maps.select_map()
		maps.place_map(def)
		RunCallbacks(maps.on_load, def)
		maps.current_map = def
		maps.update_env()
		
		--maps.current_map.teams[""] = vector.new()
		
		core.set_node(def.teams.blue, {name="air"})
		core.set_node(def.teams.red, {name="air"})
		if def.teams.yellow and def.teams.green then
			core.set_node(def.teams.yellow, {name="air"})
			core.set_node(def.teams.green, {name="air"})
		end
		
		maps.theres_loaded_map = true
	end)
end

function maps.get_team_pos(team)
	return maps.current_map.teams[team or ""]
end

-- Areas control
function maps.is_on_interior(pos, rpos1, rpos2)
	--rpos1 = Minimun coordinates (Depends on Y)
	--rpos2 = Maximun coordinates (Depends on Y)
	-- Forming like corners to form an cube (with different coordinates)
	return pos.x >= rpos1.x and pos.x <= rpos2.x
		and pos.y >= rpos1.y and pos.y <= rpos2.y
		and pos.z >= rpos1.z and pos.z <= rpos2.z
end
function maps.get_status_of_areas()
	return type(maps.current_map.area_status) == "table"
end
function maps.get_name_of_pos(pos)
	if maps.get_status_of_areas() then
		for i, val in pairs(maps.current_map.area_status) do
			if maps.is_on_interior(pos, val.pos1, val.pos2) then
				return val.str or "--"
			end
		end
	else
		return "--"
	end
	return "--"
end

minetest.register_node("bs_maps:ign", {
	description = "Ignore Node.", 
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable     = true,
	pointable    = false,
	diggable     = false,
	buildable_to = false,
	air_equivalent = true,
	groups = {immortal = 1},
})
minetest.register_node("bs_maps:stone", {
	description = "Wall Stone\n ONLY USE IN BARRIERS", 
	tiles = {"bound.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable     = true,
	pointable    = true,
	diggable     = false,
	buildable_to = false,
	air_equivalent = true,
	groups = {immortal = 1},
})
minetest.register_node("bs_maps:ind_glass", {
	description = "Wall Glass\n ONLY USE IN BARRIERS\n ", 
	tiles = {"wall.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable     = true,
	pointable    = true,
	diggable     = false,
	buildable_to = false,
	air_equivalent = true,
	groups = {immortal = 1},
})

