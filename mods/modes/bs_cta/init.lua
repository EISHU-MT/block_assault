--[[
	BlockAssault Capture The Areas
	
	~ CTA ~
	
	Capture the areas before the enemy gets it!
--]]

cta = {
	-- Config
	Modpath = minetest.get_modpath(minetest.get_current_modname()),
	AreaRadius = 5,
	DelayToCapture = 10, -- Seconds
	DelayToSubstract = 0.5, -- If a player joins in a capturing area, (from the same team) to substract delay.
	UseCTAEngine = true, -- Dynamic switch.
	-- Log functions
	LogError = function(str) core.log("error", "[CTA]"..str) end,
	LogAction = function(str) core.log("action", "[CTA]"..str) end,
	-- Cache
	used_areas = {
		--1d6g7a6 = true -- EXAMPLE
	},
	current_area = nil,
	player_huds = {},
	storage = minetest.get_mod_storage(),
	EngineIsStarted = false,
}

--[[
	This game overrides:
	- MapMaker
	- BAS
--]]

-- If mapmaker engine exists only start the map maker module. for no crash.
if MapMaker then
	dofile(cta.Modpath.."/map_maker_module.lua")
	return
end

function cta.InitMapAreas()
	if maps.current_map.data and maps.current_map.data.uses_cta == true then
		local areas = table.copy(maps.current_map.data.cta_areas)
		maps.current_map.data.cta_areas = {}
		for _, area in pairs(areas) do
			local pos = vector.add(maps.current_map.offset, area.pos)
			table.insert(maps.current_map.data.cta_areas, {name = area.name, pos = pos})
		end
		cta.EngineIsStarted = true
	else
		cta.EngineIsStarted = false
	end
end

-- Maps functionality
function cta.get_any_area()
	if cta.EngineIsStarted then
		if maps.current_map.data and maps.current_map.data.uses_cta == true then
			local areas = table.copy(maps.current_map.data.cta_areas)
			local selected_area
			for _, area in pairs(areas) do -- Should be: {name = "5b19s8f", pos = vector}
				if not cta.used_areas[area.name] then
					selected_area = area
					cta.used_areas[area.name] = true
					cta.current_area = area
					break
				end
			end
			return selected_area
		else
			cta.LogError("The current map cant be used with CTA!")
		end
	end
end

function cta.get_current_area()
	return cta.current_area
end

function cta.SetMarker(pos)
	local text, stext
	if bs_match.match_is_started then
		text = "Get This Area!"
		stext = "Area!"
	else
		text = false
		stext = "Area!"
	end
	for _, player in pairs(core.get_connected_players()) do
		if bs.get_player_team_css(player) ~= "" then
			if not cta.player_huds[Name(player)] then
				if text == false then
					-- nothing
				else
					cta.player_huds[Name(player)] = player:hud_add({
						hud_elem_type = "waypoint",
						number = bs.get_team_color(cta.get_team_of_area_by_players_counted_team(cta.current_area), "number"),
						name = text,
						text = "m",
						world_pos = pos
					})
				end
			else
				if text == false then
					player:hud_remove(cta.player_huds[Name(player)])
				else
					player:hud_change(cta.player_huds[Name(player)], "number", bs.get_team_color(cta.get_team_of_area_by_players_counted_team(cta.current_area), "number"))
					player:hud_change(cta.player_huds[Name(player)], "name", text)
					player:hud_change(cta.player_huds[Name(player)], "world_pos", pos)
				end
			end
		else
			if not cta.player_huds[Name(player)] then
				if stext == false then
					
				else
					cta.player_huds[Name(player)] = player:hud_add({
						hud_elem_type = "waypoint",
						number = bs.get_team_color(cta.get_team_of_area_by_players_counted_team(cta.current_area), "number"),
						name = stext,
						text = "m",
						world_pos = pos
					})
				end
			else
				if stext == false then
					player:hud_remove(cta.player_huds[Name(player)])
				else
					player:hud_change(cta.player_huds[Name(player)], "number", bs.get_team_color(cta.get_team_of_area_by_players_counted_team(cta.current_area), "number"))
					player:hud_change(cta.player_huds[Name(player)], "text", text)
					player:hud_change(cta.player_huds[Name(player)], "world_pos", pos)
				end
			end
		end
	end
end

function cta.get_team_of_area_by_players_counted_team(area) -- Ignore the funcion name. Should return: team name
	local objs = core.get_objects_inside_radius(area.pos, cta.AreaRadius)
	-- Save only players
	local players = {}
	for _, obj in pairs(objs) do
		if obj:is_player() then
			table.insert(players, obj)
		end
	end
	-- Now proccess all players
	local t = {}
	
	t.red = {}
	t.blue = {}
	t.green = {}
	t.yellow = {}
	
	for _, player in pairs(players) do
		local player_team = bs.get_player_team_css(player)
		if player_team ~= "" then
			table.insert(t[player_team], player)
		end
	end
	
	-- Get all teams ranks
	
	local teams = {"red", "blue", "yellow", "green"}
	
	table.sort(teams, function (n1, n2) return #t[n1] > #t[n2] end)
	
	-- Proccess
	
	local team = teams[1]
	
	if team then
		if bs.get_team_players_index(team) ~= 0 and #t[team] ~= 0 then
			return team, t[team]
		else
			return "" -- dont return any team, so be blank!
		end
	else
		error("[CTA] Could not get team!")
	end
end

function cta.is_there_players_in_area(area)
	local objs = core.get_objects_inside_radius(area.pos, cta.AreaRadius)
	-- Save only players
	local players = {}
	for _, obj in pairs(objs) do
		if obj:is_player() then
			table.insert(players, obj)
		end
	end
	-- Ignore spectators
	local player_list = {}
	for _, player in pairs(players) do
		if bs.get_player_team_css(player) ~= "" then
			table.insert(player_list, player)
		end
	end
	if player_list[1] then
		return true, player_list
	else
		return false, player_list
	end
	return false, player_list
end

function cta.OnStep(dtime) -- Central logic proccessor.
	if cta.UseCTAEngine and cta.EngineIsStarted and Modes.CurrentMode == "cta" then
		if not cta.get_current_area() then
			cta.get_any_area()
		end
		cta.SetMarker(cta.get_current_area().pos)
		-- Decoration
		core.set_node(vector.add(cta.get_current_area().pos, vector.new(0,5,0)), {name="cta:show_node"})
		-- Logic
		local winner_team, players = cta.get_team_of_area_by_players_counted_team(cta.get_current_area())
		local is_there_players, list = cta.is_there_players_in_area(cta.get_current_area())
		if bs_match.match_is_started then
			if is_there_players and winner_team and winner_team ~= "" then
				local to_substract = 0
				for i, p in pairs(players) do -- Select players with more count
					to_substract = to_substract + 0,300
				end
				
				cta.DelayToCapture = (cta.DelayToCapture - dtime) - to_substract
			else
				if cta.DelayToCapture < 10 then
					cta.DelayToCapture = cta.DelayToCapture + dtime -- Add if none are there.
				end
			end
			
			for _, team in pairs({"red", "green", "blue", "yellow"}) do
				if team == winner_team then
					for i, p in pairs(bs.get_team_players(team)) do
						if Player(p):is_player() then
							hb.change_hudbar(Player(p), "cta", math.floor(cta.DelayToCapture), 10, "blank.png")
						end
					end
				else
					for i, p in pairs(bs.get_team_players(team)) do
						if Player(p):is_player() then
							hb.change_hudbar(Player(p), "cta", math.floor(cta.DelayToCapture), 10, nil, nil, nil, nil, bs.get_team_color(winner_team, "number"))
						end
					end
				end
			end
		else
			cta.DelayToCapture = 10
			for _, team in pairs({"red", "green", "blue", "yellow"}) do
				for i, p in pairs(bs.get_team_players(team)) do
					if Player(p):is_player() then
						hb.change_hudbar(Player(p), "cta", math.floor(cta.DelayToCapture), 10, "blank.png")
					end
				end
			end
		end
		if cta.DelayToCapture <= 0 then
			annouce.winner(winner_team, " has gained a area!")
			for name in pairs(bs.team[winner_team].players) do
				bank.player_add_value(name, 15)
			end
			core.set_node(cta.current_area.pos, {name="air"})
			local res = cta.get_any_area()
			if not res then -- Restart round
				bs_match.finish_match(winner_team)
				cta.used_areas = {}
				cta.current_area = nil
				
				for name, id in pairs(cta.player_huds) do
					if name and Player(name) then
						Player(name):hud_remove(id)
					end
				end
				cta.player_huds = {}
			end
			for i, p in pairs(bs.get_team_players(winner_team)) do
				hb.change_hudbar(Player(p), "cta", 10, 10, "blank.png")
			end
			cta.DelayToCapture = 10
		end
	else -- Poweroff all!
		cta.used_areas = {}
		cta.current_area = nil
		cta.DelayToCapture = 10
		for name, id in pairs(cta.player_huds) do
			if name and Player(name) then
				Player(name):hud_remove(id)
			end
		end
		cta.player_huds = {}
	end
end

core.register_globalstep(cta.OnStep)

hb.register_hudbar("cta", 0xFFFFFF, ("CTA"), { bar = "grey_bar.png", icon = "blank.png"}, 10, 10, false, ("@1, Remains: @2"), { order = { "label", "value" }}) --, ("@1, Remains: @2"), { order = { "label", "value" }}
--[[
-- Modify BlockAssault config
config.GameClass = "Capture The Areas"
config.IsDefaultGame = false
PvpMode.Mode = 2

-- Decorations for area.
--]]
local x = cta.AreaRadius
core.register_node(":cta:show_node", {
	--tiles = {"blank.png", "blank.png", "cta_barrier.png", "cta_barrier.png", "cta_barrier.png", "cta_barrier.png"},
	tiles = {"blank.png"},
	use_texture_alpha = "clip",
	walkable = false,
	light_source = 5,
	drawtype = "nodebox",
	--node_box = {
	---	type = "fixed",
	--	fixed = {
	--		{-(0.5+x), -(0.5+x), -(0.5+x), x+0.5, x+0.5, x+0.5}
	--	}
	--},
	visual_scale = x*2,
	paramtype = "light",
	groups = {dig_immediate = 3, not_in_creative_inventory = 1},
	drop = "",
	pointable = false,
})
--[[
bs_match.register_OnMatchStart(function()
	cta.InitMapAreas()
end)

bs_match.register_OnNewMatches(function()
	cta.used_areas = {}
	cta.current_area = {}
	cta.EngineIsStarted = false
end)

local function on_join_player(player)
	hb.init_hudbar(player, "cta", 0, 10, false)
end
core.register_on_joinplayer(on_join_player)

--]]

Modes.RegisterMode("cta", {
	Info = "Capture the area, don't allow your enemy gain territory!",
	Title = "Capture The Area",
	ConfigurationDefinition = {
		PVP_MODE = 2,
		MATCH_MAX_COUNT = 6,
		BS_CONFIG = {
			GameClass = "Capture The Area",
			EnableShopTable = true,
			AllowPlayersModifyMaps = false,
			IsDefaultGame = false
		}
	},
	Functions = {
		IsCompatibleWithMap = function(mapdef)
			if mapdef.data and mapdef.data.uses_cta then
				return true
			end
		end,
		OnJoinPlayer = function(player)
			hb.init_hudbar(player, "cta", 0, 10, false)
		end,
		OnLeavePlayer = function(player)
			--nothing
		end,
		OnNewMatches = function()
			cta.used_areas = {}
			cta.current_area = {}
			cta.EngineIsStarted = false
		end,
		OnMatchStart = function()
			cta.InitMapAreas()
		end,
		OnSetMode = function()
			for _, p in pairs(core.get_connected_players()) do
				hb.init_hudbar(player, "cta", 0, 10, false)
			end
		end
	},
})



















