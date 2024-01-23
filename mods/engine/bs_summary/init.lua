-- BAS SUMMARY
summary = {
	string_format = "%s, with %d of score, %d kills and %d deaths",
	panel = {
		name = "bas_panel", --0.265
		player = "",
		position = { x = 0.5, y = 0.35 },
		alignment = { x = 0, y = 0 },
		bg = "summary_transparent.png",
		bg_scale = { x = 45, y = 28 },
		bg_position = { x = 0.5, y = 0.45 },
		title = "BlockAssault Summary",
		title_alignment = { x = 0, y = -1.2 },
		title_offset = { x = 0, y = -180},
		title_color = 0xFFFFFF,
		sub_txt_elems = {},
		sub_img_elems = {
			up = {
				alignment = { x = 0, y = -2 },
				offset = {x = 0, y = -130},
				scale = {x = 14.2, y = 10},
				text = "summary_line.png",
			}
		}
	},
	shown_players_panel = {},
	is_from_match = {}
}

-- ids: table with only "str" = data {st1 = true, st2 = true} to {"st1", "st2"}
local function get_names(index)
	local names = {}
	for name in pairs(index) do
		table.insert(names, name)
	end
	return names
end

local function recount_for_scale(int)
	local initial = 0.1
end


function summary.return_sub_elements(players, auth_player)
	table.sort(players, function (n1, n2) return PlayerKills[n1].score > PlayerKills[n2].score end)
	local elements = {}
	local i = -2
	local y_level = 0.35
	local sub_y_scale_level = 28
	for _, pname in pairs(players) do
		i = i + 1.5
		elements[FormRandomString(5)] = {
			alignment = { x = 0, y = i + 0.5 },
			offset = {x = 0, y = -130},
			text = summary.string_format:format(pname, PlayerKills[pname].score, PlayerKills[pname].kills, PlayerKills[pname].deaths),
			number = bs.get_team_color(bs.get_team_force(pname), "number")
		}
		y_level = y_level + 0.05 -- calc form
		sub_y_scale_level = sub_y_scale_level + 5
	end
	return elements, y_level, sub_y_scale_level
end

function summary.return_players()
	local players = {}
	for pname, data in pairs(PlayerKills) do
		if bs.died[pname] or bs.get_team_force(pname) then
			table.insert(players, pname)
		end
	end
	return players
end

function summary.show_to_player(player)
	player = Player(player)
	local name = Name(player)
	if not summary.shown_players_panel[name] then
		local panel = table.copy(summary.panel)
		panel.player = name
		local players = summary.return_players()
		local sub_elements, y_level, sub_y_scale_level = summary.return_sub_elements(players)
		panel.sub_txt_elems = sub_elements
		panel.bg_position = {x = panel.bg_position.x, y = y_level}
		panel.bg_scale = {x = panel.bg_scale.x, y = sub_y_scale_level}
		summary.shown_players_panel[name] = Panel:new(name, panel)
	end
end

function summary.OnStep(dt)
	for _, player in pairs(core.get_connected_players()) do
		local controls = player:get_player_control()
		if not summary.is_from_match[Name(player)] then
			if not bs.spectator[Name(player)] then
				if controls.aux1 and controls.sneak then
					summary.show_to_player(player)
				elseif (not controls.aux1) and (not controls.sneak) then
					if summary.shown_players_panel[Name(player)] then
						summary.shown_players_panel[Name(player)]:remove()
						summary.shown_players_panel[Name(player)] = nil
					end
				end
			else
				if controls.aux1 then
					summary.show_to_player(player)
				else
					if summary.shown_players_panel[Name(player)] then
						summary.shown_players_panel[Name(player)]:remove()
						summary.shown_players_panel[Name(player)] = nil
					end
				end
			end
		end
	end
end

function summary.show_to_all()
	for _, player in pairs(core.get_connected_players()) do
		summary.show_to_player(player)
		summary.is_from_match[Name(player)] = true
	end
end

function summary.close_all_forms()
	for pname, obj in pairs(summary.shown_players_panel) do
		if Player(pname) then
			obj:remove()
			summary.shown_players_panel[pname] = nil
			summary.is_from_match[pname] = nil
		else
			summary.shown_players_panel[pname] = nil
			summary.is_from_match[pname] = nil
		end
	end
end

core.register_globalstep(summary.OnStep)















