-- Helmet & Kevlar Vest
-- 2 things, big update.
PlayerArmor = {
	AlreadyArmoredPlayers = {},
	DifferenceOfHP = {},
	HeadHPDifference = {},
	PerDoubleUse = {},
	Huds = {}
}
function PlayerArmor.AddArmorToPlayer(player, typo)
	if Name(player) and typo then
		if typo == "helmet" then
			if PlayerArmor.AlreadyArmoredPlayers[Name(player)].helmet ~= true or PlayerArmor.HeadHPDifference[Name(player)] < 10 then
				Send(player, "-45$, From buying Helmet", "#00FF00")
				PlayerArmor.HeadHPDifference[Name(player)] = 10
				PlayerArmor.AlreadyArmoredPlayers[Name(player)] = {helmet = true, kevlar = PlayerArmor.AlreadyArmoredPlayers[Name(player)].kevlar}
				PlayerArmor.SetHelmetSkin(player)
			else
				Send(player, "You cant buy a new helmet!", "#FFB600")
				bank.player_add_value(Name(player), 45, true)
			end
		elseif typo == "kevlar" then
			if PlayerArmor.AlreadyArmoredPlayers[Name(player)].kevlar ~= true or PlayerArmor.DifferenceOfHP[Name(player)] < 10 then
				Send(player, "-40$, From buying Kevlar", "#00FF00")
				PlayerArmor.DifferenceOfHP[Name(player)] = 10
				PlayerArmor.AlreadyArmoredPlayers[Name(player)] = {kevlar = true, helmet = PlayerArmor.AlreadyArmoredPlayers[Name(player)].helmet}
				PlayerArmor.SetKevlarSkin(player)
			else
				Send(player, "You cant buy a new kevlar!", "#FFB600")
				bank.player_add_value(Name(player), 40, true)
			end
		end
		PlayerArmor.UpdateHud(Name(player))
	end
end

function PlayerArmor.OnDamagePlayer(player)
	for typo, value in pairs(PlayerArmor.AlreadyArmoredPlayers[Name(player)]) do
		if typo == "kevlar" and value then
			PlayerArmor.PerDoubleUse[Name(player)] = PlayerArmor.PerDoubleUse[Name(player)] + 1
			if PlayerArmor.PerDoubleUse[Name(player)] >= 2 then
				PlayerArmor.PerDoubleUse[Name(player)] = 0
				PlayerArmor.DifferenceOfHP[Name(player)] = PlayerArmor.DifferenceOfHP[Name(player)] - 1
			end
			if PlayerArmor.DifferenceOfHP[Name(player)] <= 0 then
				PlayerArmor.AlreadyArmoredPlayers[Name(player)].kevlar = false
			end
		end
		if typo == "helmet" and value then
			PlayerArmor.HeadHPDifference[Name(player)] = PlayerArmor.HeadHPDifference[Name(player)] - 1
			if PlayerArmor.HeadHPDifference[Name(player)] <= 0 then
				PlayerArmor.AlreadyArmoredPlayers[Name(player)].helmet = false
			end
		end
	end
end

core.register_on_joinplayer(function(player, last_login)
	PlayerArmor.AlreadyArmoredPlayers[Name(player)] = {helmet = false, kevlar = false}
	PlayerArmor.HeadHPDifference[Name(player)] = 0
	PlayerArmor.DifferenceOfHP[Name(player)] = 0
	PlayerArmor.PerDoubleUse[Name(player)] = 0
	PlayerArmor.Huds[Name(player)] = {
		kevlar = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.01, y = 0.94},
			offset = {x=50, y = 1},
			scale = {x = 100, y = 100},
			text = "Kevlar: 0%",
			number = 0xFFFFFF,
		}),
		helmet = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.01, y = 0.98},
			offset = {x=50, y = 1},
			scale = {x = 100, y = 100},
			text = "Helmet: 0%",
			number = 0xFFFFFF,
		}),
	}
	PlayerArmor.UpdateHud(Name(player))
end)

core.register_on_leaveplayer(function(player, timed_out)
	PlayerArmor.AlreadyArmoredPlayers[Name(player)] = nil
	PlayerArmor.HeadHPDifference[Name(player)] = nil
	PlayerArmor.DifferenceOfHP[Name(player)] = nil
	PlayerArmor.PerDoubleUse[Name(player)] = nil
	PlayerArmor.Huds[Name(player)] = nil
end)

-- VISUALS

function PlayerArmor.SetHelmetSkin(player)
	local player_properties = player:get_properties()
	if player_properties and player_properties.textures and player_properties.textures[1]:match("armor_helmet.png") == nil then
		player:set_properties({textures = {player_properties.textures[1].."^armor_helmet.png"}})
	end
end

function PlayerArmor.SetKevlarSkin(player)
	local player_properties = player:get_properties()
	if player_properties and player_properties.textures and player_properties.textures[1]:match("armor_kevlar.png") == nil then
		player:set_properties({textures = {player_properties.textures[1].."^armor_kevlar.png"}})
	end
end

-- HUDS
function PlayerArmor.GetColorFromArmorStatus(pname)
	local pname = Name(pname)
	if pname then
		local difference = PlayerArmor.DifferenceOfHP[pname]
		local head = PlayerArmor.HeadHPDifference[pname]
		local difference_color = 0xFFFFFF
		local head_color = 0xFFFFFF
		if difference <= 0 then
			difference_color = 0xFF6262
		elseif difference <= 5 then
			difference_color = 0xFF7926
		elseif difference <= 7 then
			difference_color = 0xFFE500
		elseif difference <= 10 then
			difference_color = 0x7CFF00
		end
		if head <= 0 then
			head_color = 0xFF6262
		elseif head <= 5 then
			head_color = 0xFF7926
		elseif head <= 7 then
			head_color = 0xFFE500
		elseif head <= 10 then
			head_color = 0x7CFF00
		end
		return {
			kevlar = difference_color,
			helmet = head_color,
		}
	end
end

function PlayerArmor.UpdateHud(pname)
	local data = PlayerArmor.Huds[pname]
	if data and Player(pname) then
		-- Strings
		Player(pname):hud_change(data.kevlar, "text", "Kevlar: "..tostring(PlayerArmor.DifferenceOfHP[pname] * 10).."%")
		Player(pname):hud_change(data.helmet, "text", "Helmet: "..tostring(PlayerArmor.HeadHPDifference[pname] * 10).."%")
		-- Colors
		Player(pname):hud_change(data.kevlar, "number", PlayerArmor.GetColorFromArmorStatus(pname).kevlar)
		Player(pname):hud_change(data.helmet, "number", PlayerArmor.GetColorFromArmorStatus(pname).helmet)
	else
		PlayerArmor.Huds[pname] = nil
	end
end

--core.register_globalstep(on_step)

-- SHOP

Shop.RegisterWeapon("Helmet", {
	item_name = ":",
	exec_on_buy = function(player) PlayerArmor.AddArmorToPlayer(player, "helmet") end,
	price = 45,
	icon = "helmet_icon.png",
	type = "armor",
	uses_ammo = false,
})

Shop.RegisterWeapon("Kevlar Vest", {
	item_name = ":",
	exec_on_buy = function(player) PlayerArmor.AddArmorToPlayer(player, "kevlar") end,
	price = 40,
	icon = "kevlar_icon.png",
	type = "armor",
	uses_ammo = false,
})

-- CALLBACKS from PVP

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	PlayerArmor.OnDamagePlayer(player)
	if player:get_hp() - damage <= 0 then
		PlayerArmor.AlreadyArmoredPlayers[Name(player)] = {helmet = false, kevlar = false}
		PlayerArmor.HeadHPDifference[Name(player)] = 0
		PlayerArmor.DifferenceOfHP[Name(player)] = 0
		PlayerArmor.PerDoubleUse[Name(player)] = 0
	end
	PlayerArmor.UpdateHud(Name(player))
end)















