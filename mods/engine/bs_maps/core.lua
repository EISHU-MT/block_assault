--
-- - CENTRAL -
--
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

maps.used_load_area = false

function maps.place_map(map_def)
	if config.MapsLoadAreaType == "emerge" then
		core.log("action", "Using \"Emerge\" type.")
		steps.FreezeTicks()
		maps.emerge_with_callbacks(nil, map_def.pos1, map_def.pos2, function()
			core.log("info", "Placing map: "..map_def.name)
			local bool = minetest.place_schematic(map_def.pos1, map_def.mcore, map_def.rotation == "z" and "0" or "90")
			assert(bool, "Something failed!: Map core: 'core.mts' dont exist, or may it was corrupted!")
			core.log("info", "ON-PLACE-MAP: Map light areas fix starting")
			local function fix_light(...) core.fix_light(...) core.log("action", "ON-PLACE-MAP: Map light areas fix complete") end
			core.after(5, fix_light, map_def.pos1, map_def.pos2)
			steps.UnFreezeTicks()
		end, nil)
	elseif config.MapsLoadAreaType == "load_area" then -- Only in singlenode mapgen
		core.log("action", "Using \"LoadArea\" type. This might glitch map if mapgen wanst singlenode!")
		core.load_area(map_def.pos1, map_def.pos2)
		core.log("info", "Placing map: "..map_def.name)
		local bool = minetest.place_schematic(map_def.pos1, map_def.mcore, map_def.rotation == "z" and "0" or "90")
		assert(bool, "Something failed!: Map core: 'core.mts' dont exist, or may it was corrupted!")
		core.log("info", "ON-PLACE-MAP: Map light areas fix starting")
		local function fix_light(...) core.fix_light(...) core.log("action", "ON-PLACE-MAP: Map light areas fix complete") end
		core.after(5, fix_light, map_def.pos1, map_def.pos2)
		maps.used_load_area = true
	end
end

function maps.new_map()
	core.log("action", "Searching a map for the game....")
	core.after(0.5, function()
		local def = maps.select_map()
		--print(dump(def))
		maps.place_map(def)
		maps.current_map = def
		maps.update_env()
		
		if not maps.used_load_area then
			core.load_area(def.pos1, def.pos2)
		end
		
		--maps.current_map.teams[""] = vector.new()
		-- Clear objects
		core.after(2, function(def)
			core.log("action", "Going to remove unused objects....")
			local objs = minetest.get_objects_in_area(def.pos1, def.pos2)
			for _, obj in pairs(objs) do
				local ent = obj:get_luaentity()
				if ent and obj then
					if (not ent.wield_hand) and (not ent.is_nametag) and (not ent.bot_name) then
						core.log("action", "Removing obj "..tostring(obj).." on ClearNewMapArea")
						obj:remove()
					end
				end
			end
		end, def)
		
		core.set_node(def.teams.blue, {name="air"})
		core.set_node(def.teams.red, {name="air"})
		
		bs.team.red.state = "alive"
		bs.team.blue.state = "alive"
		
		if def.teams.yellow and def.teams.green then
			core.set_node(def.teams.yellow, {name="air"})
			core.set_node(def.teams.green, {name="air"})
			bs.team.yellow.state = "alive"
			bs.team.green.state = "alive"
		end
		
		maps.theres_loaded_map = true
		core.after(1, function(def)
			RunCallbacks(maps.on_load, def)
		end, def)
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


