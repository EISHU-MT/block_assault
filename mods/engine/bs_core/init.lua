--[[
	BulletStorm Engine
--]]
local S = core.get_translator("bs_core")
_OID = S("BlockAssault Classic") -- To be overriden by modes
_V  = "Beta V4.5"
_ID = "BlockAssault" -- Real engine name
C = CountTable
bs = {
	team = {
		red = {},
		blue = {},
		yellow = {},
		green = {},
	},
	team_data = {
		red = {color = "#FF0000", code = 0xFF0000},
		blue = {color = "#4E4EFF", code = 0x4E4EFF},
		yellow = {color = "#FFFF00", code = 0xFFFF00},
		green = {color = "#00FF00", code = 0x00FF00},
	},
	player_team = {},
	is_playing = {},
	cbs = {
		OnAssignTeam = {},
		OnDiePlayer = {},
	},
	modpath = core.get_modpath(core.get_current_modname()),
	died = {},
	spectator = {},
	version = 4.5,
}

local to_assign_each_team = {
	players = {},
	count = 0,
	color = "",
	color_code = 0x0,
	state = "neutral",
}

for team, contents in pairs(bs.team) do
	bs.team[team] = table.copy(to_assign_each_team)
	bs.team[team].color = bs.team_data[team].color
	bs.team[team].color_code = bs.team_data[team].code
end

function bs.enemy_team(team)
	if C(maps.current_map.teams) == 2 then -- Is it a 2 team map
		if team == "red" then
			return "blue"
		elseif team == "blue" then
			return "red"
		end
	else
		local teams = {}
		for team_to_return in pairs(bs.team) do
			if team_to_return ~= team then
				table.insert(teams, team_to_return)
			end
		end
		return teams
	end
end

function bs.destroy_team(team) -- Only used for 4 team map
	if C(maps.current_map.teams) > 2 then
		if bs.team[team].state ~= "alive" then
			local players = table.copy(bs.team[team].players)
			for name in pairs(players) do
				bs.allocate_to_spectator(name)
			end
			bs.team[team].state = "neutral"
		end
	end
end

function bs.is_valid_team(team, from_map)
	if from_map then
		if C(maps.current_map.teams) == 2 then
			if team == "red" then
				return true
			elseif team == "blue" then
				return true
			end
			return false
		else
			if team == "red" then
				return true
			elseif team == "blue" then
				return true
			elseif team == "yellow" then
				return true
			elseif team == "green" then
				return true
			end
			return false
		end
	else
		if team == "red" then
			return true
		elseif team == "blue" then
			return true
		elseif team == "yellow" then
			return true
		elseif team == "green" then
			return true
		end
		return false
	end
end

function bs.get_team_color(team, type_to_return)
	if (team and bs.is_valid_team(team)) and type_to_return then
		if type_to_return == "string" then
			return bs.team[team or ""].color or "#FFFFFF"
		elseif type_to_return == "number" then
			return bs.team[team or ""].color_code or 0xFFFFFF
		end
	end
	if type_to_return == "string" then
		return "#FFFFFF"
	elseif type_to_return == "number" then
		return 0xFFFFFF
	end
end

function bs.get_team(to_index)
	local name = Name(to_index)
	if bs.is_playing[name] then
		return bs.player_team[name] or nil
	else
		return nil
	end
	return nil
end

function bs.get_team_force(to_index)
	local name = Name(to_index)
	return bs.player_team[name] or nil
end

function bs.allocate_to_team(to_allocate, teamm, force, use_dead_table, ann) -- Applying this function again to a applied player dont crash
	if not to_allocate then return false end
	if maps.theres_loaded_map or force then
		
		local team = ""
		local player = Player(to_allocate)
		local name = Name(to_allocate)
		
		if not name then return false end
		if not player then return false end
		
		player:set_hp(20)
		
		if use_dead_table then
			if bs.died[name] then
				team = bs.died[name]
			else
				return false
			end
		else
			team = teamm
		end
		
		if not bs.team[team] then return false end
		if bs.team[team].state == "neutral" then return false end
		
		-- We should check if player is on other team.
		for teamm, data in pairs(bs.team) do
			bs.team[teamm].players[name] = nil
			bs.team[teamm].count = C(bs.team[teamm].players)
			bs.player_team[name] = nil
			bs.spectator[name] = nil
		end
		
		if use_dead_table and name then
			bs.team[team].players[name] = true
			bs.team[team].count = C(bs.team[team].players)
			bs.player_team[name] = team
			bs.is_playing[name] = true
			bs.spectator[name] = nil
			RunCallbacks(bs.cbs.OnAssignTeam, player, team)
			player:set_armor_groups({immortal=0,fleshy=100})
			player:set_nametag_attributes({text=nil,color=nil})
			RemovePrivs(player, {"fly", "fast", "noclip", "teleport"})
			SpawnPlayerAtRandomPosition(player, team)
			player:set_hp(20)
			player:hud_set_hotbar_image("gui_hotbar_"..team..".png")
			player:hud_set_hotbar_selected_image("gui_hotbar_select_"..team..".png")
			bs.died[name] = nil
			ResetSkin(player)
			player:hud_set_flags({
				wielditem = true,
				crosshair = true,
				--healthbar = true,
				--breathbar = true,
				hotbar = true,
			})
			player:set_properties({pointable = true, collide_with_objects = true, physical = true, is_visible = true})
			if not ann then
				bs.send_to_team(team, S("### @1 joined on this team!", name))
			end
			return true
		else
			if bs.team[team] and name then
				bs.team[team].players[name] = true
				bs.team[team].count = C(bs.team[team].players)
				bs.player_team[name] = team
				bs.is_playing[name] = true
				player:set_nametag_attributes({text=nil,color=nil})
				bs.spectator[name] = nil
				RunCallbacks(bs.cbs.OnAssignTeam, player, team)
				player:set_armor_groups({immortal=0,fleshy=100})
				RemovePrivs(player, {"fly", "fast", "noclip", "teleport"})
				SpawnPlayerAtRandomPosition(player, team)
				player:set_hp(20)
				player:hud_set_hotbar_image("gui_hotbar_"..team..".png")
				player:hud_set_hotbar_selected_image("gui_hotbar_select_"..team..".png")
				bs.died[name] = nil
				ResetSkin(player)
				player:hud_set_flags({
					wielditem = true,
					crosshair = true,
					--healthbar = true,
					--breathbar = true,
					hotbar = true,
				})
				player:set_properties({pointable = true, collide_with_objects = true, physical = true, is_visible = true})
				if not ann then
					bs.send_to_team(team, S("### @1 joined on this team!", name))
				end
				return true
			end
		end
	else
		SendError(to_allocate, S("Unable to allocate you in @1, map system not started.", teamm))
		core.log("error", "Unable to allocate player in team \""..teamm.."\". There are not loaded map")
		return false
	end
	
end

function bs.get_team_players(team)
	if bs.team[team] then
		local players = {}
		for name, value in pairs(bs.team[team].players) do
			if bs.spectator[name] ~= true and Player(name) then
				table.insert(players, Player(name))
			elseif not Player(name) then
				core.log("error", "A ghost player have been found on team "..team.." name = "..name)
				bs.team[name].players[name] = nil
			end
		end
		return players
	end
end

function bs.get_player_team_css(to_index)
	local name = Name(to_index)
	if bs.is_playing[name] then
		if bs.spectator[name] then
			return ""
		else
			return bs.player_team[name]
		end
	else
		return ""
	end
	return ""
end

function bs.get_team_players_index(team)
	if bs.team[team] then
		local players = {}
		for name, value in pairs(bs.team[team].players) do
			if bs.spectator[name] ~= true and Player(name) then
				table.insert(players, Player(name))
			elseif not Player(name) then
				core.log("error", "A ghost player have been found on team "..team.." name = "..name)
				bs.team[name].players[name] = nil
			end
		end
		return C(players), players
	end
end

function bs.unallocate_team(to_allocate)
	local player = Player(to_allocate)
	local name = Name(to_allocate)
	local team = bs.get_team(name)
	if bs.team[team] then
		bs.team[team].players[name] = nil
		bs.team[team].count = C(bs.team[team].players)
		bs.player_team[name] = nil
		bs.is_playing[name] = nil
		bs.died[name] = nil
		bs.spectator[name] = nil
		AddPrivs(player, {fly=false, fast=false, noclip=false, teleport=false})
		RunCallbacks(bs.cbs.OnAssignTeam, player, "")
	end
end

function bs.allocate_to_spectator(to_allocate, died)
	if maps.theres_loaded_map then
		local player = Player(to_allocate)
		local name = Name(to_allocate)
		core.chat_send_player(name, core.colorize("grey", S("*** Be sure to had noclip on!")))
		player:set_properties({textures = {"blank.png"}, pointable = false, collide_with_objects = false, physical = false, is_visible = false})
		player:set_hp(20)
		player:set_armor_groups({immortal=1})
		--Inv(player):set_list("main", {}) -- Now this job does bs_drops
		AddPrivs(player, {fly=true, fast=true, noclip=true, teleport=true})
		player:hud_set_hotbar_selected_image("blank.png")
		bs.is_playing[name] = false
		bs.spectator[name] = true
		player:hud_set_flags({
			wielditem = false,
			crosshair = false,
			healthbar = false,
			breathbar = false,
			hotbar = false,
		})
		RunCallbacks(bs.cbs.OnAssignTeam, player, "")
		hb.hide_hudbar(player, "breath")
		hb.hide_hudbar(player, "health")
		Inv(player):set_list("main", {})
		if died then
			bs.died[name] = bs.player_team[name]
			player:set_pos(maps.current_map.teams[bs.player_team[name]])
		else
			player:set_pos(maps.current_map.teams.blue)
			-- If he dint die then delete him from all teams.
			for teamm, data in pairs(bs.team) do
				bs.team[teamm].players[name] = nil
				bs.team[teamm].count = C(bs.team[teamm].players)
				bs.player_team[name] = nil
			end
		end
	else
		SendError(to_allocate, S("Unable to allocate you in spectators, map system not started."))
		core.log("error", "Unable to allocate player in \"spectators\". There are not loaded map")
	end
end

config = {
	LoadOnLoginMenu = true,
	LoadOnLeaveScript = true,
	RegisterInitialFunctions = {
		join = true,
		leave = true
	},
	TypeOfAnimation = "bas_default",
	DisableTimer = false,
	ShowMenuToPlayerWhenEndedRounds = {bool = true, func = function() end},
	PvpEngine = {enable = true, func = function() end, FriendShoot = false, CountPlayersKills = true}, -- FriendShoot == true then player teammate can be killed from his own teammate.
	EnableShopTable = true,
	ResetPlayerMoneyOnEndRounds = true,
	UseEngineCurrency = true,
	OverridePlayersSkinForTeams = true,
	UseDefaultMatchEngine = true,
	UsePvpMatchEngine = {bool = true, func = function() end},
	AnnouceWinner = true,
	GiveDefaultTools = {bool = true, pistol = true, sword = true},
	ClearPlayerInv = {bool = true, maintain_last_inventory = false, set_new_inventory_after_inventory_reset = true},
	EnableStatsForPlayers = true, -- New feature
	UseScoreSystem = true,
	UseLogForWarnings = false,
	MedicStandTicksRate = 0.3,
	MedicStandHealPerTick = 3,
	AlwaysShopOpen = false,
	IsDefaultGame = true, -- Only this is true when the game has not modified settings (As here "config") else this is modified.
	GiveMoneyToKillerPlayer = {bool = true, amount = 10},
	DontPunchPlayerWhileMatchNotStarted = true,
	GameClass = "BA Hunt & Kill", -- Classic game of BA.S (Builtin)
	RestorePlayerHPOnEndRounds = true,
	SecondsToWaitToEndMolotovFire = 10,
	LimitForBombsCount = 5,
	EnableDeadBody = true,
	MapsLoadAreaType = "emerge", -- "emerge" or "load_area"; LoadArea: For low-ram mode, Emerge: for high-ram mode.
	PlayerLigthingIntensity = 0.38,
	PlayerLigthingSaturation = 10,
	DefaultStartWeapon = {weapon = "rangedweapons:glock17", ammo = "rangedweapons:9mm 200", sword = "default:sword_steel"},
	TypeOfStorage = "json", -- Json or Lua
	AllowPlayersModifyMaps = false,
	StrictMapgenCheck = true, -- Avoid big lag
	TypeOfPlayerTag = false, -- Classic: true, Modern: false
	ForceUseOfCraftingTable = false,
	RespawnTimer = 6,
}

bs.login_menu = function()
	return "formspec_version[6]" ..
	"size[13.7,9.1]" ..
	"box[0,0;13.7,1.1;#00DB00]" ..
	"label[0.2,0.5;"..S("Welcome to").." "..(config.GameClass or _OID).."!]" ..
	"label[10.6,0.3;".._ID.."]" ..
	"label[11.4,0.8;".._V.."]" ..
	"box[0,1.1;13.7,0.7;#267026]" ..
	"label[4.9,1.4;"..S("Please select a team to join").."]" ..
	"image_button[0.1,2;4.5,3.5;team_red_color.png;red;Red team;false;false]" ..
	"image_button[0.1,5.5;4.5,3.5;team_blue_color.png;blue;Blue Team;false;false]" ..
	"image_button[4.6,2;4.5,3.5;team_yellow_color.png;yellow;Yellow Team;false;false]" ..
	"image_button[4.6,5.5;4.5,3.5;team_green_color.png;green;Green Team;false;false]" ..
	"image_button[9.1,2;4.5,3.5;team_null_color.png;spect;"..S("No team")..";false;false]" ..
	"image_button[9.1,5.5;4.5,3.5;quit.png;exit;"..S("Disconnect")..";false;false]"
end

function bs.send_to_team(team, msg)
	if bots then
		local players = bs_old.get_team_players(team)
		for _, player in pairs(players) do
			core.chat_send_player(bs_old.Name(player), core.colorize(bs.get_team_color(team, "string"), msg))
		end
	else
		local players = bs.get_team_players(team)
		for _, player in pairs(players) do
			core.chat_send_player(Name(player), core.colorize(bs.get_team_color(team, "string"), msg))
		end
	end
end

function bs.auto_allocate_team(player)
	if not bs.is_playing[Name(player)] and bs.spectator[Name(player)] ~= true then
		if C(maps.current_map.teams) == 2 then
			if Name(player) then
				if bs.team.red.count > bs.team.blue.count then
					bs.allocate_to_team(player, "red")
				elseif bs.team.blue.count > bs.team.red.count then
					bs.allocate_to_team(player, "blue")
				elseif bs.team.blue.count == bs.team.red.count then
					local team = Randomise("", {"red", "blue"})
					bs.allocate_to_team(player, team)
				end
			end
		else
			if Name(player) then
				local teams = {"red", "blue", "yellow", "green"}
				table.sort(teams, function(n1,n2) return bs.team[n1].count > bs.team[n2].count end)
				bs.allocate_to_team(player, teams[4]) -- The 4th index is the team with less players
			end
		end
		core.close_formspec(Name(player) or "", "core:menu")
	end
end

local function on_login(player)
	if config.RegisterInitialFunctions.join then
		if config.LoadOnLoginMenu then
			core.after(10, bs.auto_allocate_team, Player(player))
			core.show_formspec(Name(player), "core:menu", bs.login_menu())
		end
	end
end

bs.show_menu_and_expire = on_login

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local team = bs.get_player_team_css(player)
	if team == "" then
		team = "#009200"
	end
	local str = S("*** @1 left the game", core.colorize(team, name))
	core.chat_send_all(str)
end)

local function on_leave(player)
	if config.RegisterInitialFunctions.leave then
		bs.unallocate_team(player)
	end
end

local c = core.colorize

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "core:menu" then
		if fields.red then
			local response = bs.allocate_to_team(player, "red")
			if response == true then
				core.close_formspec(Name(player), "core:menu")
			end
		elseif fields.blue then
			local response = bs.allocate_to_team(player, "blue")
			if response == true then
				core.close_formspec(Name(player), "core:menu")
			end
		elseif fields.yellow then
			if C(maps.current_map.teams) > 2 then
				local response = bs.allocate_to_team(player, "yellow")
				if response == true then
					core.close_formspec(Name(player), "core:menu")
				end
				core.close_formspec(Name(player), "core:menu")
			else
				core.chat_send_player(Name(player), c("#FF0000", S("-!- Current map dont support 2+ teams map.")))
			end
		elseif fields.green then
			if C(maps.current_map.teams) > 2 then
				local response = bs.allocate_to_team(player, "green")
				if response == true then
					core.close_formspec(Name(player), "core:menu")
				end
				core.close_formspec(Name(player), "core:menu")
			else
				core.chat_send_player(Name(player), c("#FF0000", S("-!- Current map dont support 2+ teams map.")))
			end
		elseif fields.spect then
			bs.allocate_to_spectator(player, false)
			core.close_formspec(Name(player), "core:menu")
		elseif fields.exit then
			core.disconnect_player(Name(player), S("Disconnected from GUI"))
		end
	end
end)

if config.RegisterInitialFunctions.join then
	minetest.register_on_joinplayer(on_login)
end
if config.RegisterInitialFunctions.leave then
	minetest.register_on_leaveplayer(on_leave)
end

core.register_chatcommand("t", {
	params = "<msg>",
	description = S("Send a private message to your team"),
	privs = {shout=true},
	func = function(name, params)
		if bots then
			local player_team = bs_old.get_player_team_css(name)
			if player_team ~= "" then
				bs.send_to_team(player_team, "### <"..name.."> "..params)
			end
		else
			local player_team = bs.get_player_team_css(name)
			if player_team ~= "" then
				bs.send_to_team(player_team, "### <"..name.."> "..params)
			end
		end
	end
})

core.register_chatcommand("teams", {
	params = "",
	description = S("Returns a list of all players on each team"),
	func = function(name, params)
		if maps.current_map and maps.theres_loaded_map then
			for team in pairs(maps.current_map.teams) do
				local players = bs.get_team_players(team)
				if players then
					local names = {}
					for _, obj in pairs(players) do
						if Name(obj) and Name(obj) ~= "" then
							table.insert(names, Name(obj))
						end
					end
					local str = table.concat(names, ", ")
					core.chat_send_player(name, core.colorize(team, "("..C(names)..") "..TransformTextReadable(team)..": ")..str)
				end
			end
		end
	end
})

-- Now load other files...
dofile(bs.modpath..DIR_DELIM.."callbacks.lua")
dofile(bs.modpath..DIR_DELIM.."huds.lua")
dofile(bs.modpath..DIR_DELIM.."timer.lua")
dofile(bs.modpath..DIR_DELIM.."match.lua")

--minetest.send_join_message = function() end
minetest.send_leave_message = function() end

















