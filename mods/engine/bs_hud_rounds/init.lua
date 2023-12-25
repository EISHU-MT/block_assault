bshud = {
	["red"] = 0,
	["blue"] = 0,
	["yellow"] = 0,
	["green"] = 0,
}
rhud_round = {}
bhud_round = {}
yhud_round = {}
ghud_round = {}
minetest.register_on_joinplayer(function(ObjectRef, last_login)
	local pname = Name(ObjectRef)
	ghud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.53, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.5},
		alignment = {x = "center", y = "up"},
		text = tostring(bshud.green),
		number = bs.get_team_color("green", "number"),
	})
	ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.52, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.8},
		alignment = {x = "center", y = "up"},
		text = "\\",
		number = 0x000000,
	})
	bhud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.51, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.5},
		alignment = {x = "center", y = "up"},
		text = tostring(bshud.blue),
		number = bs.get_team_color("blue", "number"),
	})
	ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.5, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.8},
		alignment = {x = "center", y = "up"},
		text = "|",
		number = 0x000000,
	})
	rhud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.49, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.5},
		alignment = {x = "center", y = "up"},
		text = tostring(bshud.red),
		number = bs.get_team_color("red", "number"),
	})
	ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.48, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.8},
		alignment = {x = "center", y = "up"},
		text = "/",
		number = 0x000000,
	})
	yhud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.47, y = 0.040},
		offset = {x = 0, y = 20},
		size = {x = 1.5},
		alignment = {x = "center", y = "up"},
		text = tostring(bshud.yellow),
		number = bs.get_team_color("yellow", "number"),
	})
end)

bs_match.register_OnEndMatch(function(team)
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
		local pname = player:get_player_name()
		if pname then
			if rhud_round[pname] and bhud_round[pname] then
				player:hud_change(bhud_round[pname], "text", tostring(bshud.blue))
				player:hud_change(rhud_round[pname], "text", tostring(bshud.red))
			end
		end
	end
end)

bs_match.register_OnNewMatches(function()
	bshud.blue = 0
	bshud.red = 0
	bshud.green = 0
	bshud.yellow = 0
end)