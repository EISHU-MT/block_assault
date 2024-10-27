--
-- - CENTRAL -
--

-- Vote engine
function maps.return_formspec(MapsData)
	return "formspec_version[9]" ..
	"size[10,3.7]" ..
	"position[0.5,0.2]" ..
	"hypertext[0,0;6,3;a;<style color=#00CCAA size=30>Select Map</style>]" ..
	"style[disconnect;bgcolor=red;textcolor=white]" ..
	"button_exit[6.8,0.1;3,0.7;disconnect;Disconnect]" ..
	"image_button[0.3,0.9;3,2.3;"..MapsData.FirstMap.IMG..";"..MapsData.FirstMap.TMN..";"..MapsData.FirstMap.MVP.."]" ..
	"label[0.4,3.45;"..MapsData.FirstMap.TXT.."]" ..
	"image_button[3.6,0.9;3,2.3;"..MapsData.SecondMap.IMG..";"..MapsData.SecondMap.TMN..";"..MapsData.SecondMap.MVP.."]" ..
	"label[3.7,3.45;"..MapsData.SecondMap.TXT.."]" ..
	"image_button[6.8,0.9;3,2.3;"..MapsData.ThirdMap.IMG..";"..MapsData.ThirdMap.TMN..";"..MapsData.ThirdMap.MVP.."]" ..
	"label[6.9,3.45;"..MapsData.ThirdMap.TXT.."]"
end

maps.Votes = {
	CurrentlyVoting = false,
	Votes = {},
	PlayersVoting = {}, -- Explained on cs_modes_registry
	PlayersVotingInt = 0,
	CurrentMapData = {}, -- cache
	WinnerMap = "",
	CACHE_FUNC = function() end,
	HasVoted = {},
}

maps.OverriderOfLoserMap = "^[colorizehsl:0:0:10"

function maps.update_core()
	for name, def in pairs(maps.reg_maps) do
		if name and def then
			local available_to_register = true
			for _,n in pairs(maps.maps_name) do
				if n == name then
					available_to_register = false -- Don't multiply maps on every reload!
				end
			end
			if available_to_register then
				table.insert(maps.maps_name, name)
			end
		end
	end
end

maps.to_be_used_maps = {}
function maps.update_cache_maps(func__)
	--maps.to_be_used_maps = table.copy(maps.maps_name)
	for _, mapname in pairs(maps.maps_name) do
		if func__(maps.reg_maps[mapname]) then
			table.insert(maps.to_be_used_maps, mapname)
		end
	end
	table.shuffle(maps.to_be_used_maps)
end

function maps.DoVotes()
	--From modes, get available map.....
	local func_for_cache = function() return true end
	local RunningMode = Modes.CurrentMode
	if RunningMode then
		if Modes.Modes[RunningMode].Functions and Modes.Modes[RunningMode].Functions.IsCompatibleWithMap then
			func_for_cache = Modes.Modes[RunningMode].Functions.IsCompatibleWithMap
		end
	end
	--Get Available Maps
	if not next(maps.to_be_used_maps) then maps.update_cache_maps(func_for_cache) end -- If cache is empty fill with loaded maps, so we will use that.
	--process
	core.after(0.3, function()
		-- Get first 3 maps
		local first_map_name = maps.to_be_used_maps[1] or ""
		local second_map_name = maps.to_be_used_maps[2] or ""
		local third_map_name = maps.to_be_used_maps[3] or ""
		-- Get they definition
		-- i m a g e s
		local f_img = "no_map.png"
		local s_img = "no_map.png"
		local t_img = "no_map.png"
		if first_map_name ~= "" then
			f_img = maps.reg_maps[first_map_name].image or "no_map.png"
		end
		if second_map_name ~= "" then
			s_img = maps.reg_maps[second_map_name].image or "no_map.png"
		end
		if third_map_name ~= "" then
			t_img = maps.reg_maps[third_map_name].image or "no_map.png"
		end
		-- n a m e s
		local f_txt = "No Map"
		local s_txt = "No Map"
		local t_txt = "No Map"
		if first_map_name ~= "" then
			f_txt = maps.reg_maps[first_map_name].name or "No Name"
		end
		if second_map_name ~= "" then
			s_txt = maps.reg_maps[second_map_name].name or "No Name"
		end
		if third_map_name ~= "" then
			t_txt = maps.reg_maps[third_map_name].name or "No Name"
		end
		-- Now, into table
		local mtable = {
			FirstMap = {
				IMG = f_img,
				TXT = f_txt,
				MVP = "0%",
				TMN = first_map_name
			},
			SecondMap = {
				IMG = s_img,
				TXT = s_txt,
				MVP = "0%",
				TMN = second_map_name
			},
			ThirdMap = {
				IMG = t_img,
				TXT = t_txt,
				MVP = "0%",
				TMN = third_map_name
			},
		}
		for _, d in pairs(mtable) do
			maps.Votes.Votes[d.TMN] = 0
		end
		maps.Votes.CurrentMapData = table.copy(mtable)
		if next(core.get_connected_players()) then
			for _,p in pairs(core.get_connected_players()) do
				local name = p:get_player_name()
				if name then
					core.show_formspec(name, "MAPS:VOTE", maps.return_formspec(mtable))
					maps.Votes.PlayersVoting[name] = 7
				end
			end
			maps.Votes.PlayersVotingInt = #core.get_connected_players()
		else
			maps.Votes.WinnerMap = mtable.FirstMap.TMN -- Has to do.
			maps.Votes.CurrentlyVoting = false
			maps.ProceedWithNewMap(maps.Votes.CACHE_FUNC)
			return
		end
		maps.Votes.CurrentlyVoting = true
	end)
end

time_of_timedout = nil -- idk how to name it
core.register_globalstep(function(dtime)
	if maps.Votes.CurrentlyVoting then
		for pname, val in pairs(maps.Votes.PlayersVoting) do
			if maps.IsOnline[pname] then
				if val == false then
					maps.Votes.PlayersVoting[pname] = nil
				else
					maps.Votes.PlayersVoting[pname] = maps.Votes.PlayersVoting[pname] - dtime
					if maps.Votes.PlayersVoting[pname] <= 0 then
						maps.Votes.PlayersVoting[pname] = nil
						-- Random select
						local t = {"FirstMap", "SecondMap", "ThirdMap"}
						--Classificate unknown maps
						for _, d in pairs(maps.Votes.CurrentMapData) do
							if d.TMN == "" then
								for __, STR in pairs(t) do
									if STR == _ then
										t[__] = nil
									end
								end
							end
						end
						--Select map by random
						local selected_map_number = math.random(1, #t)
						local selected_typo = t[selected_map_number]
						local mapdata = maps.Votes.CurrentMapData[selected_typo]
						local mapname = mapdata.TMN
						maps.Votes.Votes[mapname] = maps.Votes.Votes[mapname] + 1
						maps.Votes.HasVoted[pname] = true
					end
				end
			else
				maps.Votes.PlayersVoting[pname] = nil
			end
		end
		if next(maps.Votes.PlayersVoting) == nil then
			if not time_of_timedout then
				time_of_timedout = 5
			end
			-- For now, show results
			-- Check if winner is on cache, or not..
			if maps.Votes.WinnerMap == "" then
				local mapss = {}
				for _, d in pairs(maps.Votes.CurrentMapData) do 
					if d.TMN ~= "" then
						table.insert(mapss, d.TMN)
					end
				end
				table.sort(mapss, function (n1, n2) return maps.Votes.Votes[n1] > maps.Votes.Votes[n2] end)
				if mapss[1] then
					for map__, data in pairs(maps.Votes.CurrentMapData) do
						if data.TMN ~= mapss[1] then
							maps.Votes.CurrentMapData[map__].IMG = maps.Votes.CurrentMapData[map__].IMG..maps.OverriderOfLoserMap
						end
						maps.Votes.CurrentMapData[map__].MVP = math.floor((maps.Votes.Votes[data.TMN]*10/maps.Votes.PlayersVotingInt)*10).."%"
					end
					maps.Votes.WinnerMap = mapss[1]
				end
			end
			if time_of_timedout >= 0.5 then
				for _,p in pairs(core.get_connected_players()) do
					core.show_formspec(p:get_player_name(), "MAPS:VOTE", maps.return_formspec(maps.Votes.CurrentMapData))
				end
			end
			-- Close all formspecs and commence start map when timedout reaches 0
			time_of_timedout = time_of_timedout - dtime
			if time_of_timedout <= 0 then
				for _, p in pairs(core.get_connected_players()) do
					core.close_formspec(p:get_player_name(), "MAPS:VOTE")
				end
				maps.Votes.CurrentlyVoting = false
				local map, maut = maps.ProceedWithNewMap(maps.Votes.CACHE_FUNC)
				core.chat_send_all(core.colorize("#00FF81", ">>>> Now playing for the next "..bs_match.rounds.." rounds: ")..core.colorize("#00D5FF", map))
				core.chat_send_all(core.colorize("#00FF81", ">>>> Map made by: ")..core.colorize("#00D5FF", maut)..core.colorize("#00FF81", ". Enjoy!!"))
			end
		else
			time_of_timedout = nil
		end
	end
end)

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "MAPS:VOTE" then
		if not maps.Votes.HasVoted[player:get_player_name()] then
			for map_sector, map_data in pairs(maps.Votes.CurrentMapData) do
				if fields[map_data.TMN] and map_data.TMN ~= "" then
					maps.Votes.Votes[map_data.TMN] = maps.Votes.Votes[map_data.TMN] + 1
					maps.Votes.PlayersVoting[player:get_player_name()] = nil
					maps.Votes.HasVoted[player:get_player_name()] = true
				elseif fields.disconnect then
					core.kick_player(player:get_player_name())
				end
			end
			--core.after(0.1, function()
				-- Update hud
				for map__, data in pairs(maps.Votes.CurrentMapData) do
					maps.Votes.CurrentMapData[map__].MVP = math.floor((maps.Votes.Votes[data.TMN]*10/maps.Votes.PlayersVotingInt)*10).."%"
				end
				--if time_of_timedout and time_of_timedout >= 0.5 then
					core.after(0.1, function()
						for _, p in pairs(core.get_connected_players()) do
							local name = p:get_player_name()
							if name then
								core.show_formspec(name, "MAPS:VOTE", maps.return_formspec(maps.Votes.CurrentMapData))
							end
						end
					end)
				--end
			--end)
		end
	end
end)

maps.IsOnline = {}
core.register_on_joinplayer(function(p)
	maps.IsOnline[p:get_player_name()] = true
	if maps.Votes.CurrentlyVoting then
		local name = p:get_player_name()
		if name then
			core.show_formspec(name, "MAPS:VOTE", maps.return_formspec(maps.Votes.CurrentMapData))
			maps.Votes.PlayersVoting[name] = 7
			maps.Votes.PlayersVotingInt = #core.get_connected_players()
		end
	end
end)
core.register_on_leaveplayer(function(p)
	maps.IsOnline[p:get_player_name()] = nil
	maps.Votes.PlayersVoting[p:get_player_name()] = nil
end)

-- Obsolete function.
function maps.select_map()
	if maps.to_be_used_maps[1] ~= nil then
		local selected_map_number = math.random(1, #maps.to_be_used_maps)
		local name = maps.to_be_used_maps[selected_map_number]
		table.remove(maps.to_be_used_maps, selected_map_number)
		return maps.reg_maps[name]
	else
		maps.update_cache_maps()
		return maps.reg_maps[maps.maps_name[1]]
	end
end

maps.used_load_area = false

function maps.place_map(map_def)
	if not map_def then return end
	if config.MapsLoadAreaType == "emerge" then
		core.log("action", "Using \"Emerge\" type.")
		--steps.FreezeTicks()
		maps.emerge_with_callbacks(nil, map_def.pos1, map_def.pos2, function()
			core.log("info", "Placing map: "..map_def.name)
			local bool = minetest.place_schematic(map_def.pos1, map_def.mcore, map_def.rotation == "z" and "0" or "90")
			assert(bool, "Something failed!: Map core: 'core.mts' dont exist, or may it was corrupted!")
			core.log("info", "ON-PLACE-MAP: Map light areas fix starting")
			local function fix_light(...) core.fix_light(...) core.log("action", "ON-PLACE-MAP: Map light areas fix complete") end
			core.after(5, fix_light, map_def.pos1, map_def.pos2)
			--steps.UnFreezeTicks()
			-- replace the shop table
			PlaceAllTradingTables()
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
		PlaceAllTradingTables()
	end
end

function maps.re_place_current_map()
	maps.place_map(maps.current_map)
end

function maps.ProceedWithNewMap(func)
	core.log("action", "Selected Map: "..maps.Votes.WinnerMap)
	--core.after(0.5, function()
		local def = maps.reg_maps[maps.Votes.WinnerMap]
		local to_return = def.name
		local map_author = def.author
		maps.place_map(def)
		maps.current_map = def
		maps.update_env()
		
		if not maps.used_load_area then
			core.load_area(def.pos1, def.pos2)
		end
		
		core.after(2, function(def)
			core.log("action", "Going to remove unused objects....")
			local objs = minetest.get_objects_in_area(def.pos1, def.pos2)
			for _, obj in pairs(objs) do
				local ent = obj:get_luaentity()
				if ent and obj then
					if (not ent.wield_hand) and (not ent.is_nametag) and (not ent.bot_name) and (not ent.dont_remove) then
						core.log("action", "Removing obj "..tostring(obj).." on ClearNewMapArea")
						obj:remove()
					end
				end
			end
		end, def)
		
		local nodename = "air"
		if config.EnableShopTable then nodename = "bs_shop:trading_table" end
		
		core.set_node(def.teams.blue, {name=nodename})
		core.set_node(def.teams.red, {name=nodename})
		
		bs.team.red.state = "alive"
		bs.team.blue.state = "alive"
		
		if def.teams.yellow and def.teams.green then
			core.set_node(def.teams.yellow, {name=nodename})
			core.set_node(def.teams.green, {name=nodename})
			bs.team.yellow.state = "alive"
			bs.team.green.state = "alive"
		end
		
		maps.theres_loaded_map = true
		core.after(1, function(def)
			RunCallbacks(maps.on_load, def)
		end, def)
		
		if maps.queued_function then
			maps.queued_function()
			maps.queued_function = nil
		end
		if func then
			func()
		end
	--end)
	core.log("action", "Clearing Votes cache...")
	maps.Votes = {
		CurrentlyVoting = false,
		Votes = {},
		PlayersVoting = {}, -- Explained on cs_modes_registry
		PlayersVotingInt = 0,
		CurrentMapData = {}, -- cache
		WinnerMap = "",
		CACHE_FUNC = function() end,
		HasVoted = {},
	}
	return to_return, map_author
end


function maps.new_map(func)
	maps.Votes.CACHE_FUNC = func
	maps.DoVotes()
end

function maps.LoadAfterMapPlaced(func)
	maps.queued_function = func
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


