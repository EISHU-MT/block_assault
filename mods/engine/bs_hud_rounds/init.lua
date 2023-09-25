bshud = {
	red = 0,
	blue = 0,
}
rhud_round = {}
bhud_round = {}
minetest.register_on_joinplayer(function(ObjectRef, last_login)
	local pname = Name(ObjectRef)
	bhud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.51, y = 0.047},
		offset = {x = 0, y = 20},
		size = {x = 2},
		alignment = {x = "center", y = "up"},
		text = " ",
		number = bs.get_team_color("blue", "number"),
	})
	local null = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.5, y = 0.047},
		offset = {x = 0, y = 20},
		size = {x = 2},
		alignment = {x = "center", y = "up"},
		text = "/",
		number = 0x000000,
	})
	rhud_round[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "hud_rounds",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.49, y = 0.047},
		offset = {x = 0, y = 20},
		size = {x = 2},
		alignment = {x = "center", y = "up"},
		text = " ",
		number = bs.get_team_color("red", "number"),
	})
end)

bs_match.register_OnEndMatch(function(team)
	if team == "blue" then
		bshud.blue = bshud.blue + 1
	elseif team == "red" then
		bshud.red = bshud.red + 1
	end
end)

bs_match.register_OnNewMatches(function()
	bshud.blue = 0
	bshud.red = 0
end)


minetest.register_globalstep(function(dtime)
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