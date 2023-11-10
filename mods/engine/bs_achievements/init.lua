--[[
	Bas Achievements
--]]
Achievements = {
	serial_killer = {type = "kills", amount = 100, name = "Serial Killer"},
	newbie = {type = "kills", amount = 10, name = "Getting enemies!"},
	aces = {type = "kills_per_round", kills = 3, deaths = nil, name = "Ace!"},
	my_first_awp = {type = "item_shopt_first_time", item_name = "rangedweapons:awp", name = "My first AWP!"},
	texas_style = {type = "item_shopt_first_time", item_name = "rangedweapons:deagle", name = "Texas Style, Desert Eagle."},
	ninja_style = {type = "kills_per_round", kills = nil, deaths = 0, name = "Ninja Style!"},
	spectator = {type = "player_team_select", team = "", name = "Spectating people"},
	lets_throw_bombs = {type = "item_shopt_first_time", item_name = "grenades:frag", name = "Lets throw bombs at enemy!"}
}
AchievementsApi = {}
AchievementsDatabase = {
	storage = core.get_mod_storage("bs_achievements"),
	add = function(player, achievement)
		if config.TypeOfStorage == "lua" then
			local data = core.deserialize(AchievementsDatabase.storage:get_string("players"))
			if not data then
				data = {}
			end
			if not data[Name(player)] then
				data[Name(player)] = {}
			end
			data[Name(player)][achievement] = true
			AchievementsDatabase.storage:set_string("players", core.serialize(data))
		elseif config.TypeOfStorage == "json" then
			local data = core.parse_json(AchievementsDatabase.storage:get_string("players"))
			if not data then
				data = {}
			end
			if not data[Name(player)] then
				data[Name(player)] = {}
			end
			data[Name(player)][achievement] = true
			AchievementsDatabase.storage:set_string("players", core.write_json(data))
		end
	end,
	reset = function(player)
		if config.TypeOfStorage == "lua" then
			local data = core.deserialize(AchievementsDatabase.storage:get_string("players"))
			if not data then
				data = {}
			end
			data[Name(player)] = {}
			AchievementsDatabase.storage:set_string("players", core.serialize(data))
		elseif config.TypeOfStorage == "json" then
			local data = core.parse_json(AchievementsDatabase.storage:get_string("players"))
			if not data then
				data = {}
			end
			data[Name(player)] = {}
			AchievementsDatabase.storage:set_string("players", core.write_json(data))
		end
	end,
	get = function(player, achievement)
		if config.TypeOfStorage == "lua" then
			if Name(player) then
				local data = core.deserialize(AchievementsDatabase.storage:get_string("players"))
				if not data then
					data = {}
				end
				if not data[Name(player)] then
					data[Name(player)] = {}
				end
				return data[Name(player)]
			else
				return {}
			end
		elseif config.TypeOfStorage == "json" then
			if Name(player) then
				local data = core.parse_json(AchievementsDatabase.storage:get_string("players"))
				if not data then
					data = {}
				end
				if not data[Name(player)] then
					data[Name(player)] = {}
				end
				return data[Name(player)]
			else
				return {}
			end
		end
	end,
}

Shop.RegisterOnBuyWeapon(function(p, w)
	for name, achievement in pairs(Achievements) do
		if achievement.type == "item_shopt_first_time" then
			if achievement.item_name == w.item_name then
				local player_data = AchievementsDatabase.get(p)
				if not player_data[name] then
					AchievementsDatabase.add(p, name)
					core.chat_send_player(Name(p), core.colorize("#009200", "[Achievements] You got: ")..core.colorize("#00FFFF", achievement.name))
				end
			end
		end
	end
end)

bs_match.register_OnEndMatch(function(winner, pk)
	for name, achievement in pairs(Achievements) do
		if achievement.type == "kills_per_round" then
			if pk then
				for pname, data in pairs(pk) do
					local deaths = achievement.deaths or data.deaths
					local kills = achievement.kills or data.kills
					if data.kills >= kills and data.deaths <= deaths then
						if Player(pname) then
							local player_data = AchievementsDatabase.get(Player(pname))
							if not player_data[name] then
								AchievementsDatabase.add(Player(pname), name)
								core.chat_send_player(pname, core.colorize("#009200", "[Achievements] You got: ")..core.colorize("#00FFFF", achievement.name))
							end
						end
					end
				end
			end
		end
	end
end)


































