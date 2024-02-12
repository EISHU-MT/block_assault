-- BY EISHU
bs_tsh = {
	red = {},
	blue = {},
	green = {},
	yellow = {}
}

minetest.register_on_joinplayer(function(player)
	bs_tsh.red[Name(player)] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0.05},
		offset = {x=-100, y = 20},
		scale = {x = 100, y = 100},
		text = "Reds: "..bs.get_team_players_index("red"),
		number = bs.get_team_color("red", "number"),
	})
	bs_tsh.blue[Name(player)] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0.075},
		offset = {x=-100, y = 20},
		scale = {x = 100, y = 100},
		text = "Blues: "..bs.get_team_players_index("blue"),
		number = bs.get_team_color("blue", "number"),
	})
	bs_tsh.green[Name(player)] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0},
		offset = {x=-100, y = 20},
		scale = {x = 100, y = 100},
		text = "Greens: "..bs.get_team_players_index("green"),
		number = bs.get_team_color("green", "number"),
	})
	bs_tsh.yellow[Name(player)] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0.025},
		offset = {x=-100, y = 20},
		scale = {x = 100, y = 100},
		text = "Yellows: "..bs.get_team_players_index("yellow"),
		number = bs.get_team_color("yellow", "number"),
	})
end)

local function update_frames()
	for team, value in pairs(bs_tsh) do
		if bs.team[team].state == "alive" then
			for player_name, id in pairs(value) do
				if Player(player_name) then
					Player(player_name):hud_change(id, "text", TransformTextReadable(team)..": "..bs.get_team_players_index(team))
				else
					bs_tsh[team][player_name] = nil
				end
			end
		else
			for player_name, id in pairs(value) do
				if Player(player_name) then
					Player(player_name):hud_change(id, "text", "")
				else
					bs_tsh[team][player_name] = nil
				end
			end
		end
	end

end
--bs.cbs.register_OnAssignTeam(update_frames)
UpdateTeamHuds = update_frames
hooks.register_hook(update_frames, 1, {repeat_time = -10, name = "Update Teams Hud", cancel_true_event = false})