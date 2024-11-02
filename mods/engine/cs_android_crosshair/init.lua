--[[
player:hud_add({
		hud_elem_type = "image",
		position = { x=0.5, y=0.5 },
		scale = { x=2.5, y=2.5},
		text = "invisible.png",
	})
--]]
Crosshair = {
	Huds = {},
	Textures = {
		[1] = "crosshair.png",
		[2] = "crosshair_type2.png",
		[3] = "crosshair_type3.png",
		[4] = "crosshair_type4.png",
	},
}

core.register_on_joinplayer(function(P)
	Crosshair.Huds[P:get_player_name()] = P:hud_add({
		hud_elem_type = "image",
		position = { x=0.5, y=0.5 },
		scale = { x=2.5, y=2.5},
		text = Crosshair.GetCrosshair(P),
	})
	P:hud_set_flags({
		crosshair = false,
	})
end)

function Crosshair.GetCrosshair(player)
	local meta = player:get_meta()
	if meta then
		local int = meta:get_int("crosshair_text_id")
		local selected = 1
		if (not int) or int == 0 then
			selected = 1
		elseif int == 512 then --Disable
			return "blank.png", 0
		elseif int > 0 then
			selected = int
		end
		local text = Crosshair.Textures[int]
		if text then
			return text, int
		else
			core.log("warning", "Error at getting player selected crosshair")
			return Crosshair.Textures[1], 1
		end
	end
	return Crosshair.Textures[1], 1
end

function Crosshair.SetCrosshair(player, numb)
	local meta = player:get_meta()
	if meta then
		meta:set_int("crosshair_text_id", numb)
		--update
		player:hud_change(Crosshair.Huds[Name(player)], "text", Crosshair.Textures[numb])
	end
end

function Crosshair.Exists(I)
	return Crosshair.Textures[I]
end

core.register_chatcommand("set_crosshair", {
	params = "<number>",
	description = "Set crosshair to your preferred selection",
	func = function(name, params)
		local param = params:split(" ")
		if param[1] then
			if Player(name) then
				local numb = tonumber(param[1])
				if numb then
					if Crosshair.Exists(numb) then
						Crosshair.SetCrosshair(Player(name), numb)
						core.chat_send_player(name, core.colorize("lightgreen", ">>> Done."))
					else
						core.chat_send_player(name, core.colorize("lightred", ">>> That crosshair ID don't exists"))
						core.chat_send_player(name, core.colorize("lightred", ">>> Crosshairs: 1 - "..#Crosshair.Textures))
					end
				else
					core.chat_send_player(name, core.colorize("lightred", ">>> You need to specify a number"))
				end
			else
				return true, ">>>> You must be connected!"
			end
		end
	end
})

core.register_chatcommand("get_crosshair", {
	description = "Get your crosshair ID",
	func = function(name, params)
		local param = params:split(" ")
		if param[1] then
			if Player(name) then
				local crosshair_text, ID = Crosshair.GetCrosshair(Player(name))
				if ID and ID ~= 0 then
					core.chat_send_player(name, core.colorize("lightgreen", ">>> Your current crosshair ID: "..ID..", technical texture: "..crosshair_text))
				else
					core.chat_send_player(name, core.colorize("lightred", ">>> You have disabled your crosshair"))
				end
			else
				return true, ">>>> You must be connected!"
			end
		end
	end
})













