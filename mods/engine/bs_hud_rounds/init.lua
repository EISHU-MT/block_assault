bshud = {
	["red"] = 0,
	["blue"] = 0,
	["yellow"] = 0,
	["green"] = 0,
	["rounds"] = {}
}
local CC = core.colorize
local function get(team) return tostring(bshud[team]) end
local function o(guidanse) return 20 + guidanse end
local function gec(team) return bs.get_team_color(team, "number") end
core.register_on_joinplayer(function(ObjectRef, last_login) -- bs.get_team_color("green", "number")
	ObjectRef:hud_add({
		hud_elem_type = "image",
		position = {x = 0, y = 1},
		text = "hud_rounds_hud.png",
		alignment = {x = "center", y = "up"},
		offset = {x=30,y=-80},
		scale = {x = 1.7, y = 0.8},
	})
	bshud.rounds[Name(ObjectRef)] = {
		red = ObjectRef:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=1},
			offset = {x = o(0), y = -80},
			alignment = {x = "center", y = "up"},
			text = get("red"),
			number = gec("red")
		}),
		blue = ObjectRef:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=1},
			offset = {x = o(20), y = -80},
			alignment = {x = "center", y = "up"},
			text = get("blue"),
			number = gec("blue")
		}),
		yellow = ObjectRef:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=1},
			offset = {x = o(40), y = -80},
			alignment = {x = "center", y = "up"},
			text = get("yellow"),
			number = gec("yellow")
		}),
		green = ObjectRef:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=1},
			offset = {x = o(60), y = -80},
			alignment = {x = "center", y = "up"},
			text = get("green"),
			number = gec("green")
		}),
	}
end)

function UpdateRoundsHud(team)
	if team == "blue" then
		bshud.blue = bshud.blue + 1
	elseif team == "red" then
		bshud.red = bshud.red + 1
	elseif team == "yellow" then
		bshud.red = bshud.yellow + 1
	elseif team == "green" then
		bshud.red = bshud.green + 1
	end
	for _, player in pairs(core.get_connected_players()) do
		for teamm, id in pairs(bshud.rounds[Name(player)]) do
			player:hud_change(id, "text", tostring(get(teamm)))
		end
	end
end

bs_match.register_OnNewMatches(function()
	bshud.blue = 0
	bshud.red = 0
	bshud.green = 0
	bshud.yellow = 0
end)