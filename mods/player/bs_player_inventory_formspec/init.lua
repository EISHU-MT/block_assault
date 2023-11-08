--[[
	Player Inventory Formspec
--]]

local function get_player_names_on_table(players)
	local names = {}
	if players then
		for _, obj in pairs(players) do
			if Name(obj) then
				table.insert(names, Name(obj) or "__error")
			end
		end
	end
	return names
end

local function get_all_players_in_game()
	local names = {}
	for team, data in pairs(bs.team) do
		for pname in pairs(data.players) do
			if bs.spectator[pname] then
				table.insert(names, core.formspec_escape(bs.get_team_color(team, "string").."["..pname.."]"))
			else
				table.insert(names, bs.get_team_color(team, "string")..pname)
			end
		end
		if bots then
			local carried_bot_names = {}
			for name, data in pairs(bots.data) do
				if data.team == team then
					if data.state == "alive" then
						table.insert(names, bs.get_team_color(team, "string")..name)
					else
						table.insert(names, core.formspec_escape(bs.get_team_color(team, "string").."["..name.."]"))
					end
				end
			end
		end
	end
	return names
end

local function get_dead_players_index(team)
	local c_dead_players = 0
	for name, data in pairs(bs.died) do
		if data and data == team then
			c_dead_players = c_dead_players + 1
		end
	end
	return c_dead_players
end

bs_pif = {}
function bs_pif.ReturnFormspec(alive, dead, players, string_color)
	return "formspec_version[6]" ..
		"size[15,8]" ..
		"list[current_player;main;0.4,2.9;8,4;0]" ..
		"box[0,0;10.1,0.6;#00FF00]" ..
		"label[0.1,0.3;Your Team Stats]" ..
		"label[0.6,1.3;Dead: "..dead.."]" ..
		"label[0.6,2;Alive: "..alive.."]" ..
		"box[10.1,0;5,0.6;#00A8E2]" ..
		"label[10.2,0.3;Players:]" ..
		"textlist[10.3,0.9;4.5,6.7;;"..table.concat(players, ",")..";1;false]"
end

function bs_pif.ReturnSpectatorFormspec()
	
	return "formspec_version[6]" ..
	"size[15,8]" ..
	"box[5,4.2;5,3.8;#00FF00]" ..
	"box[0,4.2;5,3.8;#FFFF00]" ..
	"box[0,0;10,0.6;#00FF00]" ..
	"label[0.1,0.3;Teams Stats]" ..
	"box[10,0;5,0.6;#00A8E2]" ..
	"label[10.2,0.3;Players:]" ..
	"textlist[10,0.6;5,7.4;;"..table.concat(get_all_players_in_game(), ",")..";1;false]" ..
	"box[0,0.6;5,3.6;#FF0001]" ..
	"box[5,0.6;5,3.6;#0000FF]" ..
	"label[2.2,0.8;Red]" ..
	"label[7.2,0.8;Blue]" ..
	"label[2,4.4;Yellow]" ..
	"label[7.1,4.4;Green]" ..
	"label[0.4,1.5;R. Dead: "..(get_dead_players_index("red") or "0").."]" ..
	"label[0.4,2.9;R. Alive: "..(bs.get_team_players_index("red") or "0").."]" ..
	"label[0.5,5.3;Y. Dead: "..(get_dead_players_index("red") or "0").."]" ..
	"label[0.5,6.9;Y. Alive: "..(bs.get_team_players_index("yellow") or "0").."]" ..
	"label[5.4,3;B. Alive: "..(bs.get_team_players_index("blue") or "0").."]" ..
	"label[5.4,1.5;B. Dead: "..(get_dead_players_index("red") or "0").."]" ..
	"label[5.6,5.3;Gr. Dead: "..(get_dead_players_index("red") or "0").."]" ..
	"label[5.6,6.9;Gr. Alive: "..(bs.get_team_players_index("green") or "0").."]"
end



local ticks = 0
local function on_step(dtime)
	ticks = ticks + dtime
	if ticks >= 0.1 then
		for _, player in pairs(core.get_connected_players()) do
			local name = Name(player)
			if bs.spectator[name] then
				player:set_inventory_formspec(bs_pif.ReturnSpectatorFormspec())
			else
				local c_dead_players = 0
				for name, data in pairs(bs.died) do
					if data and data == bs.get_player_team_css(player) then
						c_dead_players = c_dead_players + 1
					end
				end
				local c_alive_players = bs.get_team_players_index(bs.get_player_team_css(player))
				player:set_inventory_formspec(bs_pif.ReturnFormspec(c_alive_players or "0", c_dead_players or "0", get_player_names_on_table(bs.get_team_players(bs.get_player_team_css(player))) or {}))
			end
		end
		ticks = 0
	end
end

core.register_globalstep(on_step)