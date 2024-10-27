-- BAS SUMMARY
summary = {
	string_format = "%s, with %d of score, %d kills and %d deaths",
	--[[panel = {
		name = "bas_panel", --0.265
		player = "",
		position = { x = 0.5, y = 0.40 },
		alignment = { x = 0, y = 1 },
		bg = "gui_formbg.png",
		bg_scale = { x = 2.6, y = 0 },
		bg_position = { x = 0.5, y = 0.45 },
		title = "CS:MT",
		title_alignment = { x = 0, y = -1.2 },
		title_offset = { x = 0, y = -180},
		title_color = 0xFFFFFF,
		sub_txt_elems = {
			--[[up = {
				alignment = { x = 0, y = -2 },
				offset = {x = 0, y = -130},
				scale = {x = 14.2, y = 10},
				size = {x = 2},
				text = "CS:MT",
			}
		},
		sub_img_elems = {
			
		}
	},--]] -- panel_lib no longer used. Too buggy
	shown_players_panel = {},
	is_from_match = {},
	Huds = {},
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
--[[
function summary.return_sub_elements(players, auth_player)
	table.sort(players, function (n1, n2) return PlayerKills[n1].score > PlayerKills[n2].score end)
	local elements = {}
	local i = 0
	local y_level = 0.35
	local sub_y_scale_level = 2
	for _, pname in ipairs(players) do
		elements[FormRandomString(5)] = {
			alignment = { x = 0, y = 1 },
			offset = {x = 0, y = 10+(i-1)*18},
			text = summary.string_format:format(pname, PlayerKills[pname].score, PlayerKills[pname].kills, PlayerKills[pname].deaths),
			number = bs.get_team_color(bs.get_team_force(pname), "number")
		}
		i = i + 1
		y_level = 0 -- calc form
		sub_y_scale_level = sub_y_scale_level 
	end
	return elements, y_level, sub_y_scale_level
end--]]

--[[
	-- Include Bots
	for botname, data in pairs(bots.data) do
		table.insert(players, botname)
		summary.IsBot[botname] = true
	end
--]]

summary.IsBot = {}

function summary.return_players()
	local players = {}
	for pname, data in pairs(PlayerKills) do
		if Player(pname) and (bots.data[pname] or (bs.died[pname] or bs.get_team_force(pname))) then
			table.insert(players, pname)
		end
	end
	return players
end

function summary.show_to_player(player)
	player = Player(player)
	local nameP = Name(player)
	if not summary.shown_players_panel[nameP] then
		--[[local panel = table.copy(summary.panel)
		panel.player = name
		local players = summary.return_players()
		local sub_elements, y_level, sub_y_scale_level = summary.return_sub_elements(players)
		panel.sub_txt_elems = sub_elements
		panel.bg_position = {x = panel.bg_position.x, y = y_level}
		panel.bg_scale = {x = panel.bg_scale.x, y = sub_y_scale_level}
		summary.shown_players_panel[name] = Panel:new(name, panel)--]]
		if summary.Huds[nameP] then
			--Data
			local Players = summary.return_players()
			table.sort(Players, function (n1, n2) return PlayerKills[n1].score > PlayerKills[n2].score end)
			--Title (GameClass)
			player:hud_change(summary.Huds[nameP].GameClass, "text", "CS:MT - "..config.GameClass)
			--Background
			player:hud_change(summary.Huds[nameP].Background, "text", "gui_formbg.png")
			player:hud_change(summary.Huds[nameP].Background, "scale", {x=2,y=((#Players / 4) - (#Players / 10) + 0.1)})
			--List
			for i, name in ipairs(Players) do
				if not bots.data[name] then
					table.insert(summary.Huds[nameP].SubHuds, player:hud_add({
						hud_elem_type = "text",
						position = {x = 0.5, y = 0},
						offset = {x = 0, y = 48 + (i - 1) * 18},
						text = summary.string_format:format(name, PlayerKills[name].score, PlayerKills[name].kills, PlayerKills[name].deaths),
						alignment = {x = 0, y = 1},
						scale = {x = 100, y = 100},
						number = bs.get_team_color(bs.get_team_force(name), "number")
					}))
				else
					table.insert(summary.Huds[nameP].SubHuds, player:hud_add({
						hud_elem_type = "text",
						position = {x = 0.5, y = 0},
						offset = {x = 0, y = 48 + (i - 1) * 18},
						text = summary.string_format:format("BOT "..name, PlayerKills[name].score, PlayerKills[name].kills, PlayerKills[name].deaths),
						alignment = {x = 0, y = 1},
						scale = {x = 100, y = 100},
						number = bs.get_team_color(bots.data[name].team, "number")
					}))
				end
			end
			summary.shown_players_panel[nameP] = true
		end
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
						player:hud_change(summary.Huds[Name(player)].Background, "text", "blank.png")
						player:hud_change(summary.Huds[Name(player)].GameClass, "text", "")
						for _, ID in pairs(summary.Huds[Name(player)].SubHuds) do
							player:hud_remove(ID)
						end
						summary.shown_players_panel[Name(player)] = nil
					end
				end
			else
				if controls.aux1 then
					summary.show_to_player(player)
				else
					if summary.shown_players_panel[Name(player)] and summary.Huds[Name(player)] then
						player:hud_change(summary.Huds[Name(player)].GameClass, "text", "")
						for _, ID in pairs(summary.Huds[Name(player)].SubHuds) do
							player:hud_remove(ID)
						end
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
			--obj:remove()
			do
				local player = Player(pname)
				player:hud_change(summary.Huds[Name(player)].Background, "text", "blank.png")
				player:hud_change(summary.Huds[Name(player)].GameClass, "text", "")
				for _, ID in pairs(summary.Huds[Name(player)].SubHuds) do
					player:hud_remove(ID)
				end
			end
			summary.shown_players_panel[pname] = nil
			summary.is_from_match[pname] = nil
		else
			summary.shown_players_panel[pname] = nil
			summary.is_from_match[pname] = nil
		end
	end
end

core.register_globalstep(summary.OnStep)

core.register_on_joinplayer(function(player)
	-- Initialize huds
	summary.Huds[player:get_player_name()] = {
		Background = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.5, y = 0},
			offset = {x = 0, y = 20},
			text = "blank.png", --always blank
			alignment = {x = 0, y = 1},
			scale = {x = 2, y = 1},
			number = 0xFFFFFF,
		}),
		--GameClass
		GameClass = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.5, y = 0},
			offset = {x = 0, y = 26},
			text = "",  --always blank
			alignment = {x = 0, y = 1},
			number = 0xFFFFFF,
		}),
		-- No text.
		-- Just a table!
		SubHuds = {}
	}
end)













