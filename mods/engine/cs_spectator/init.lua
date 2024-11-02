--Spectator mode, remastered and copied from CS:MT
Spectator = {
	Players = {
		--Catars = a_player
	},
	PlayersHuds = {
		--[[
			Catars = {
				Background = 0x0,
				PlayerName = 0x1,
				PlayerTeam = 0x2,
				PlayerRifle = 0x3,
				PlayerHP = 0x4,
				PlayerNameSub = 0x5,
				PlayerTeamSub = 0x6,
				PlayerHpSub = 0x7,
				PlayerRifleName = 0x8,
				PlayerRifleNameSub = 0x9,
			}
		--]]
	},
	AlreadyDeletedHud = {},
	I_INDEX = {},
	ActivePlayers = {},
	ActivePlayersCount = 0
}

function Spectator.SetSpectTo(player, obj)
	if Name(obj) then
		if player and Player(player) then
			player:set_attach(obj, "Head")
			Spectator.Players[Name(player)] = Name(obj)
			Spectator.UpdateHud(player)
			core.chat_send_player(Name(player), core.colorize("lightgreen", ">>> Spectating "..Name(obj)))
		end
	end
end

function Spectator.DeAttach(player, no_annouce)
	if player and Player(player) then
		if Spectator.Players[Name(player)] then
			player:set_detach()
			Spectator.Players[Name(player)] = nil
			Spectator.UpdateHud(player, true)
			if not no_annouce then
				core.chat_send_player(Name(player), core.colorize("lightgreen", ">>> Not spectating anymore"))
			end
		else
			if not no_annouce then
				core.chat_send_player(Name(player), core.colorize("lightgreen", ">>> You are not viewing others gameplay"))
			end
		end
	end
end

local function ReturnXByStringLengh(x)
	return x:len()-(x:len()/2)
end

function Spectator.UpdateHud(player, direct_delete_hud)
	if direct_delete_hud then
		if not Spectator.AlreadyDeletedHud[Name(player)] then
			--Background
			player:hud_change(Spectator.PlayersHuds[Name(player)].Background, "text", "")
			--Player Name sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "text", "blank.png")
			--Player Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerName, "text", "")
			--Player Team sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "text", "blank.png")
			--Player Team
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeam, "text", "")
			--Player Rifle
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifle, "text", "")
			--Player Rifle Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleName, "text", "")
			--Player Rifle sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "text", "blank.png")
			--Player Hp
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHp, "text", "")
			--Player Hp sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "text", "blank.png")
			Spectator.AlreadyDeletedHud[Name(player)] = true
		end
		return
	end
	if bs.spectator[Name(player)] then
		if Spectator.Players[Name(player)] and Player(Spectator.Players[Name(player)]) and Player(Spectator.Players[Name(player)]):get_yaw() then
			--player:hud_change(Spectator.PlayersHuds[Name(player)].Background, "text", "hud_centre1.png") --Animated support
			local name = Spectator.Players[Name(player)]
			local team = bs.get_team_force(name) or (bots.data[name] and bots.data[name].team)
			local rifle = (bots and bots.IsLoaded and bots.in_hand_weapon[name]) or Player(Spectator.Players[Name(player)]):get_wielded_item():get_name()
			local rifleI = ItemStack(rifle)
			local rifleN = rifleI:get_short_description()
			--Player Name sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "scale", {x=ReturnXByStringLengh(name), y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "text", "subletter.png")
			--Player Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerName, "text", name)
			--Player Team sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "scale", {x=ReturnXByStringLengh(team), y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "text", "subletter.png")
			--Player Team
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeam, "text", TransformTextReadable(team))
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeam, "number", bs.get_team_color(team, "number"))
			--Player Rifle
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifle, "text", core.registered_items[rifle].inventory_image or core.registered_items[rifle].textures or core.registered_items[rifle].tiles[1])
			--Player Rifle Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleName, "text", TransformTextReadable(rifleN))
			--Player Rifle sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "scale", {x=ReturnXByStringLengh(core.strip_colors(rifleN)), y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "text", "subletter.png")
			--Player Hp
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHp, "text", "HP: "..Player(Spectator.Players[Name(player)]):get_hp())
			--Player Hp sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "scale", {x=ReturnXByStringLengh("HP: "..Player(Spectator.Players[Name(player)]):get_hp()), y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "text", "subletter.png")
			Spectator.AlreadyDeletedHud[Name(player)] = false
		else
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerName, "text", "Press dig button or tap screen\nTo exit spectators press sneak button")
		end
	else
		if not Spectator.AlreadyDeletedHud[Name(player)] then
			--Background
			player:hud_change(Spectator.PlayersHuds[Name(player)].Background, "text", "")
			--Player Name sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerNameSub, "text", "blank.png")
			--Player Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerName, "text", "")
			--Player Team sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeamSub, "text", "blank.png")
			--Player Team
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerTeam, "text", "")
			--Player Rifle
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifle, "text", "")
			--Player Rifle Name
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleName, "text", "")
			--Player Rifle sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerRifleNameSub, "text", "blank.png")
			--Player Hp
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHp, "text", "")
			--Player Hp sub Texture
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "scale", {x=0, y=2})
			player:hud_change(Spectator.PlayersHuds[Name(player)].PlayerHpSub, "text", "blank.png")
			Spectator.AlreadyDeletedHud[Name(player)] = true
		end
	end
end

--bs.cbs.register_OnAssignTeam(function(player, team)
core.register_on_joinplayer(function(player)
	Spectator.PlayersHuds[player:get_player_name()] = {
		Background = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=7,y=7},
			text = "blank.png",
			offset = {x = 0, y = 50},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerNameSub = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=0,y=2},
			text = "blank.png",
			offset = {x = 0, y = -45},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerName = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.75, y = 0.5},
			text = "",
			offset = {x = 0, y = -45},
			alignment = {x = "center", y = "center"},
			number = 0
		}),
		
		PlayerTeamSub = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=0,y=2},
			text = "blank.png",
			offset = {x = 0, y = 10},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerTeam = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.75, y = 0.5},
			text = "",
			offset = {x = 0, y = 10},
			alignment = {x = "center", y = "center"},
			number = 0xFFF
		}),
		
		PlayerHpSub = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=0,y=2},
			text = "blank.png",
			offset = {x = 0, y = 30},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerHp = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.75, y = 0.5},
			text = "",
			offset = {x = 0, y = 30},
			alignment = {x = "center", y = "center"},
			number = 0xFFF
		}),
		
		PlayerRifle = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=3,y=3},
			text = "",
			offset = {x = 0, y = 110},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerRifleNameSub = player:hud_add({
			hud_elem_type = "image",
			position = {x = 0.75, y = 0.5},
			scale = {x=0,y=2},
			text = "blank.png",
			offset = {x = 0, y = 70},
			alignment = {x = "center", y = "center"}
		}),
		
		PlayerRifleName = player:hud_add({
			hud_elem_type = "text",
			position = {x = 0.75, y = 0.5},
			text = "",
			offset = {x = 0, y = 70},
			alignment = {x = "center", y = "center"},
			number = 0xFFF
		}),
	}
	Spectator.AlreadyDeletedHud[Name(player)] = true
end)

local number = 0
local function animation()
	if number == 0 then number = 1 else number = 0 end
	return number
end

local texture_table = {
	[1] = "hud_centre1.png",
	[2] = "hud_centre2.png"
}

local function adjunt_all_players_but(name, sub)
	local players = table.copy(Spectator.ActivePlayers)
	players[name] = nil
	if sub then
		players[sub] = nil
	end
	return players
end

local function update_players_list()
	local players = {}
	local count = 0
	for _, t in pairs({"red","blue","yellow","green"}) do
		local i = 0
		for _, o in pairs(bs.get_team_players(t)) do
			i = _
			if o and Name(o) then
				players[Name(o)] = true
			end
		end
		count = count + i
	end
	Spectator.ActivePlayers = players
	Spectator.ActivePlayersCount = count
end

local PressingTable = {}
local EscapePressingTable = {}
local timer = 0
core.register_globalstep(function(dtime)
	timer = timer+dtime
	if timer>=0.5 then
		timer=0
		--ACT
		local selected = animation()
		if selected == 0 then selected = 2 end
		local text = texture_table[selected]
		for _, p in pairs(core.get_connected_players()) do
			local name = p:get_player_name()
			if bs.spectator[name] then
				if Spectator.Players[name] then
					p:hud_change(Spectator.PlayersHuds[name].Background, "text", text)
					Spectator.UpdateHud(p)
				else
					Spectator.UpdateHud(p, true)
					Spectator.Players[name]=nil
					p:hud_change(Spectator.PlayersHuds[name].PlayerName, "text", "Press dig button or tap screen\nTo exit spectators press sneak button")
				end
			end
		end
		update_players_list()
	end
	for _, p in pairs(core.get_connected_players()) do
		if bs.spectator[p:get_player_name()] then
			local controls = p:get_player_control()
			if controls.dig then
				if not PressingTable[Name(p)] then
					if not Spectator.I_INDEX[Name(p)] then
						Spectator.I_INDEX[Name(p)] = 1
					else
						if not (Spectator.I_INDEX[Name(p)] + 1 > Spectator.ActivePlayersCount) then
							Spectator.I_INDEX[Name(p)] = Spectator.I_INDEX[Name(p)] + 1
						end
					end
					--proceed to change
					local players = adjunt_all_players_but(Name(p))
					local selected_name = ""
					local i = 0
					for nameplayer in pairs(players) do
						i = i + 1
						if i == Spectator.I_INDEX[Name(p)] then
							selected_name = nameplayer
							break
						end
					end
					if Spectator.I_INDEX[Name(p)] >= Spectator.ActivePlayersCount then
						Spectator.I_INDEX[Name(p)] = 1
					end
					Spectator.SetSpectTo(p, Player(selected_name))
					PressingTable[Name(p)] = true
				end
			else
				PressingTable[Name(p)] = false
			end
			if controls.sneak then
				if not EscapePressingTable[Name(p)] then
					EscapePressingTable[Name(p)] = true
					Spectator.DeAttach(p)
					Spectator.I_INDEX[Name(p)] = 1
				end
			else
				EscapePressingTable[Name(p)] = false
			end
			if Spectator.Players[Name(p)] and Player(Spectator.Players[Name(p)]) then
				local obj = Player(Spectator.Players[Name(p)])
				p:set_attach(obj)
				if obj:is_player() then
					local look = obj:get_look_vertical()
					local look_ = obj:get_look_horizontal()
					p:set_look_horizontal(look_)
					p:set_look_vertical(look)
				elseif Name(obj) then
					local yaw = obj:get_yaw()
					if yaw then
						p:set_look_horizontal(yaw)
					end
				else
					if not Spectator.I_INDEX[Name(p)] then
						Spectator.I_INDEX[Name(p)] = 1
					else
						if not (Spectator.I_INDEX[Name(p)] + 1 > Spectator.ActivePlayersCount) then
							Spectator.I_INDEX[Name(p)] = Spectator.I_INDEX[Name(p)] + 1
						end
					end
					--proceed to change
					local players = adjunt_all_players_but(Name(p))
					local selected_name = ""
					local i = 0
					for nameplayer in pairs(players) do
						i = i + 1
						if i == Spectator.I_INDEX[Name(p)] then
							selected_name = nameplayer
							break
						end
					end
					if Spectator.I_INDEX[Name(p)] >= Spectator.ActivePlayersCount then
						Spectator.I_INDEX[Name(p)] = 1
					end
					Spectator.SetSpectTo(p, Player(selected_name))
				end
			end
		else
			Spectator.DeAttach(p, true)
		end
	end
end)

if bots and bots.IsLoaded then
	BotsCallbacks.RegisterOnKillBot(function(self)
		update_players_list()
		for pname, obj_inst in pairs(Spectator.Players) do
			if obj_inst == self.bot_name then
				if not Spectator.I_INDEX[pname] then
					Spectator.I_INDEX[pname] = 1
				else
					if not (Spectator.I_INDEX[pname] + 1 > Spectator.ActivePlayersCount) then
						Spectator.I_INDEX[pname] = Spectator.I_INDEX[pname] + 1
					end
				end
				--proceed to change
				local players = adjunt_all_players_but(pname, self.bot_name)
				local selected_name = ""
				local i = 0
				for nameplayer in pairs(players) do
					i = i + 1
					if i == Spectator.I_INDEX[pname] then
						selected_name = nameplayer
						break
					end
				end
				if Spectator.I_INDEX[pname] >= Spectator.ActivePlayersCount then
					Spectator.I_INDEX[pname] = 1
				end
				Spectator.SetSpectTo(Player(pname), Player(selected_name))
			end
		end
	end, "CS:MT Spectator Mode Reworked")
end

PvpCallbacks.RegisterFunction(function(player)
	update_players_list()
	for pname, obj_inst in pairs(Spectator.Players) do
		if obj_inst == player:get_player_name() then
			if not Spectator.I_INDEX[pname] then
				Spectator.I_INDEX[pname] = 1
			else
				if not (Spectator.I_INDEX[pname] + 1 > Spectator.ActivePlayersCount) then
					Spectator.I_INDEX[pname] = Spectator.I_INDEX[pname] + 1
				end
			end
			--proceed to change
			local players = adjunt_all_players_but(pname, player:get_player_name())
			local selected_name = ""
			local i = 0
			for nameplayer in pairs(players) do
				i = i + 1
				if i == Spectator.I_INDEX[pname] then
					selected_name = nameplayer
					break
				end
			end
			if Spectator.I_INDEX[pname] >= Spectator.ActivePlayersCount then
				Spectator.I_INDEX[pname] = 1
			end
			Spectator.SetSpectTo(Player(pname), Player(selected_name))
		end
	end
end, "CS:MT Spectator Mode Reworked")






















