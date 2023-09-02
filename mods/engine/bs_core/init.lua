--[[
	BulletStorm Engine
--]]
_OID = "BlockAssault" -- To be overriden by modes
_V  = "Beta V0.1"
_ID = "BlockAssault" -- Real engine name
bs = {
	team = {
		red = {},
		blue = {},
		yellow = {},
		green = {},
	},
	team_data = {
		red = {color = "#FF0000", code = 0xFF0000},
		blue = {color = "#0000FF", code = 0x0000FF},
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
	if #maps.current_map.teams == 2 then -- Is it a 2 team map
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

function bs.get_team_color(team, type_to_return)
	if team and type_to_return then
		if type_to_return == "string" then
			return bs.team[team or ""].color
		elseif type_to_return == "number" then
			return bs.team[team or ""].color_code
		end
	end
	return ""
end

function bs.get_team(to_index)
	local name = Name(to_index)
	if bs.is_playing[name] then
		return bs.player_team[name] or nil
	else
		return ""
	end
end

function bs.allocate_to_team(to_allocate, team)
	if maps.theres_loaded_map then
		local player = Player(to_allocate)
		local name = Name(to_allocate)
		if bs.team[team] then
			bs.team[team].players[name] = true
			bs.team[team].count = #bs.team[team].players
			bs.player_team[name] = team
			bs.is_playing[name] = true
			RunCallbacks(bs.cbs.OnAssignTeam, player, team)
			AddPrivs(player, {fly=false, fast=false, noclip=false, teleport=false})
			
			player:set_pos(maps.current_map.teams[team])
			player:set_hp(20)
			return true
		end
	else
		SendError(to_allocate, "Unable to allocate you in "..team..", map system not started.")
		core.log("error", "Unable to allocate player in team \""..team.."\". There are not loaded map")
		return false
	end
end

function bs.unallocate_team(to_allocate)
	local player = Player(to_allocate)
	local name = Name(to_allocate)
	local team = bs.get_team(name)
	if bs.team[team] then
		bs.team[team].players[name] = false
		bs.team[team].count = #bs.team[team].players
		bs.player_team[name] = nil
		bs.is_playing[name] = false
		RunCallbacks(bs.cbs.OnAssignTeam, player, "")
	end
end

function bs.allocate_to_spectator(to_allocate, died)
	if maps.theres_loaded_map then
		local player = Player(to_allocate)
		local name = Name(to_allocate)
		player:set_properties({textures = {"blank.png"}})
		player:set_hp(20)
		player:set_armor_groups({immortal=1})
		Inv(player):set_list("main", {})
		AddPrivs(player, {fly=true, fast=true, noclip=true, teleport=true})
		bs.spectator[name] = true
		if died then
			bs.died[name] = bs.get_team(name)
		end
	else
		SendError(to_allocate, "Unable to allocate you in spectators, map system not started.")
		core.log("error", "Unable to allocate player in \"spectators\". There are not loaded map")
	end
end

config = {
	LoadOnLoginMenu = true,
	LoadOnLeaveScript = true,
	RegisterInitialFunctions = {
		join = true,
	},
	DisableTimer = false,
	ShowMenuToPlayerWhenEndedRounds = {bool = true, func = function() end},
	PvpEngine = {enable = true, func = function() end, FriendShoot = false, CountPlayersKills = true}, -- FriendShoot == true then player teammate can be killed from his own teammate.
	ResetPlayerMoneyOnEndRounds = true,
	UseEngineCurrency = true,
	OverridePlayersSkinForTeams = true,
}

bs.login_menu = "formspec_version[6]" ..
	"size[13.7,9.1]" ..
	"box[0,0;13.7,1.1;#00DB00]" ..
	"label[0.2,0.5;Welcome to ".._OID.."!]" ..
	"label[10.6,0.3;".._ID.."]" ..
	"label[11.4,0.8;".._V.."]" ..
	"box[0,1.1;13.7,0.7;#267026]" ..
	"label[4.9,1.4;Please select a team to join]" ..
	"image_button[0.1,2;4.5,3.5;team_red_color.png;red;Red team;false;false]" ..
	"image_button[0.1,5.5;4.5,3.5;team_blue_color.png;blue;Blue Team;false;false]" ..
	"image_button[4.6,2;4.5,3.5;team_yellow_color.png;yellow;Yellow Team;false;false]" ..
	"image_button[4.6,5.5;4.5,3.5;team_green_color.png;green;Green Team;false;false]" ..
	"image_button[9.1,2;4.5,3.5;team_null_color.png;spect;No team;false;false]" ..
	"image_button[9.1,5.5;4.5,3.5;quit.png;exit;Disconnect;false;false]"

function bs.auto_allocate_team(player)
	if not bs.is_playing[Name(player)] and bs.spectator[Name(player)] ~= true then
		if #maps.current_map.teams == 2 then
			if bs.team.red.count > bs.team.blue.count then
				bs.allocate_to_team(player, "red")
			elseif bs.team.blue.count > bs.team.red.count then
				bs.allocate_to_team(player, "blue")
			elseif bs.team.blue.count == bs.team.red.count then
				local team = Randomise("", {"red", "blue"})
				bs.allocate_to_team(player, team)
			end
		else
			local teams = {"red", "blue", "yellow", "green"}
			table.sort(teams, function(n1,n2) return bs.team[n1].count > bs.team[n2].count end)
			bs.allocate_to_team(player, teams[4]) -- The 4th index is the team with less players
		end
		core.close_formspec(Name(player), "core:menu")
	end
end

local function on_login(player)
	if config.RegisterInitialFunctions.join then
		if config.LoadOnLoginMenu then
			core.after(10, bs.auto_allocate_team, Player(player))
			core.show_formspec(Name(player), "core:menu", bs.login_menu)
		end
	end
end

bs.show_menu_and_expire = on_login

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
			if #maps.current_map.teams > 2 then
				local response = bs.allocate_to_team(player, "yellow")
				if response == true then
					core.close_formspec(Name(player), "core:menu")
				end
				core.close_formspec(Name(player), "core:menu")
			else
				core.chat_send_player(Name(player), c("#FF0000", "-!- Current map dont support 2+ teams map."))
			end
		elseif fields.green then
			if #maps.current_map.teams > 2 then
				local response = bs.allocate_to_team(player, "green")
				if response == true then
					core.close_formspec(Name(player), "core:menu")
				end
				core.close_formspec(Name(player), "core:menu")
			else
				core.chat_send_player(Name(player), c("#FF0000", "-!- Current map dont support 2+ teams map."))
			end
		elseif fields.spect then
			bs.allocate_to_spectator(player, false)
		end
	end
end)

if config.RegisterInitialFunctions.join then
	minetest.register_on_joinplayer(on_login)
end
if config.RegisterInitialFunctions.leave then
	minetest.register_on_leaveplayer(on_leave)
end

-- Now load other files...
dofile(bs.modpath..DIR_DELIM.."callbacks.lua")
dofile(bs.modpath..DIR_DELIM.."huds.lua")
dofile(bs.modpath..DIR_DELIM.."timer.lua")
dofile(bs.modpath..DIR_DELIM.."match.lua")




