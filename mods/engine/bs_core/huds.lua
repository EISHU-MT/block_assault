minetest.register_on_joinplayer(function(ObjectRef, last_login)
	local pname = Name(ObjectRef)
	ObjectRef:hud_add({
		hud_elem_type = "image",
		scale = {x = 1.4, y = 3.1},
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 30},
		--size = {x = 2},
		alignment = {x = "center", y = "up"},
		--alignment = {x = 0, y = -1},
		text = "up_hud.png",
		--number = 0xCECECE,
	})
	timehud[pname] = ObjectRef:hud_add({
		hud_elem_type = "text",
		name = "n",
		scale = {x = 1.5, y = 1.5},
		position = {x = 0.5, y = 0},
		offset = {x = 0, y = 20},
		size = {x = 2},
		alignment = {x = "center", y = "up"},
		--alignment = {x = 0, y = -1},
		text = "*00:00*",
		number = 0xCECECE,
	})
end)