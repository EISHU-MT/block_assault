spect_time_hud = {}
bs.cbs.register_OnAssignTeam(function(ObjectRef, team)
	local pname = Name(ObjectRef)
	if not timehud[pname] then
		spect_time_hud[pname] = ObjectRef:hud_add({
			hud_elem_type = "image",
			position = {x = 0, y = 1},
			text = "blank.png",
			alignment = {x = "center", y = "up"},
			offset = {x=30,y=-30},
			scale = {x = 2, y = 1.3},
		})
		timehud[pname] = ObjectRef:hud_add({
			hud_elem_type = "text",
			name = "n",
			scale = {x = 1.5, y = 1.5},
			position = {x = 0.5, y = 1},
			offset = {x = 0, y = -80},
			size = {x = 2},
			alignment = {x = "center", y = "up"},
			text = "",
			number = 0xCECECE,
		})
	end
	if team ~= "" then
		ObjectRef:hud_change(timehud[pname], "position", {x=0.5,y=1})
		ObjectRef:hud_change(timehud[pname], "offset", {x=0,y=-80})
		ObjectRef:hud_change(spect_time_hud[pname], "text", "blank.png")
	else
		ObjectRef:hud_change(timehud[pname], "position", {x=0,y=1})
		ObjectRef:hud_change(timehud[pname], "offset", {x=55,y=-30})
		ObjectRef:hud_change(spect_time_hud[pname], "text", "hud_rounds_hud.png")
	end
end)