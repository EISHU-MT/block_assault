bs_old = {
	get_player_team_css = bs.get_player_team_css,
	get_team_players = bs.get_team_players,
	get_team_players_index = bs.get_team_players_index,
	get_team = bs.get_team,
	Name = Name,
	Player = Player,
	OnPlayerGetHurt = OnPlayerGetHurt,
}

function bs.get_player_team_css(to_index)
	if type(to_index) == "string" then
		if bots.data[to_index] then
			return bots.data[to_index].team or ""
		elseif bs_old.Player(to_index) then
			return bs_old.get_player_team_css(to_index)
		end
	elseif type(to_index) == "userdata" then
		local lua_entity = to_index:get_luaentity()
		if lua_entity then
			if lua_entity.bot_name then
				if bots.data[lua_entity.bot_name] then
					return bots.data[lua_entity.bot_name].team or ""
				end
			end
		elseif bs_old.Name(to_index) then
			return bs_old.get_player_team_css(to_index)
		end
	end
	return ""
end

function bs.get_team_players(team)
	-- Commence with bots
	local botss = {}
	for name, data in pairs(bots.data) do
		if data and data.team == team then
			if data.state == "alive" then
				table.insert(botss, data.object)
			end
		end
	end
	-- Now with players
	local players = bs_old.get_team_players(team)
	-- Add
	local bots_and_players = {}
	for _, obj in pairs(botss or {}) do
		table.insert(bots_and_players, obj)
	end
	for _, obj in pairs(players or {}) do
		table.insert(bots_and_players, bs_old.Player(obj))
	end
	return bots_and_players
end

function bs.get_team_players_index(team)
	local i = 0
	for name, data in pairs(bots.data) do
		if data.team == team then
			if data.state == "alive" then
				i = i + 1
			end
		end
	end
	local pi = 0
	if bs_old.get_team_players(team) then
		pi = #bs_old.get_team_players(team)
	end
	return pi + i
end

function bs.get_team(to_index)
	if type(to_index) == "string" then
		if bots.data[to_index] then
			return bots.data[to_index].team
		elseif bs_old.Player(to_index) then
			return bs_old.get_player_team_css(to_index)
		end
	else
		local lua_entity = to_index:get_luaentity()
		if lua_entity then
			if lua_entity.bot_name then
				if bots.data[to_index] then
					return bots.data[lua_entity.bot_name].team
				end
			end
		elseif bs_old.Name(to_index) then
			return bs_old.get_player_team_css(to_index)
		end
	end
	return
end

function Name(thing)
	if thing then
		if type(thing) == "string" then
			return thing
		else
			
			if thing:is_player() then
				return bs_old.Name(thing)
			elseif thing:get_luaentity() and thing:get_luaentity().bot_name then
				return thing:get_luaentity().bot_name
			end
		end
	end
	return 
end

function Player(thing)
	if thing then
		if type(thing) == "string" then
			if bots.data[thing] then
				return bots.data[thing].object
			elseif bs_old.Player(thing) then
				return bs_old.Player(thing)
			end
		else
			return thing
		end
	end
end

local function get_damage_from_hp(damage)
	if not damage then
		return 0
	end
	local a1 = tostring(damage)

	if not a1:find("-") then
		return 0
	end

	local a2 = string.sub(a1, 2)

	local a3 = tonumber(a2)

	return a3
end

core.register_on_player_hpchange(function(player, hp, reason)
	local damage = get_damage_from_hp(hp)
	if reason and reason.object then
		local L = reason.object:get_luaentity()
		if L and not reason.object:is_player() then
			local bot_name = L.bot_name
			if bot_name and bots.data[bot_name] then
				local bot_team = bots.data[bot_name].team
				local player_team = bs_old.get_player_team_css(player)
				if bot_team ~= player_team then
					if player:get_hp() - damage <= 0 then
						if PvpMode.Mode == 1 then
							if bs.get_team_players_index(player_team) <= 0 then
								bs_match.finish_match(bot_team)
							else
								local hitter = reason.object
								PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
								RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
								bs.allocate_to_spectator(player, true)
								stats.deaths.add_to(Name(player))
							end
						elseif PvpMode.Mode == 2 then	
							local hitter = reason.object
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
							stats.deaths.add_to(Name(player))
							--player:set_pos(maps.current_map.teams[bs.get_team(player)])
							RespawnDelay.DoRespawnDelay(player)
						elseif PvpMode.Mode == 3 then
							local hitter = reason.object
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
							stats.deaths.add_to(Name(player))
							local response = PvpMode.ThirdModeFunction(player, reason.object)
							if response == true then
								bs.allocate_to_spectator(player, true)
							elseif response == false then
								player:set_pos(maps.current_map.teams[bs.get_team(player)])
								player:set_hp(20)
							else
								error("\nPvP Engine:\nOn getting response of ThirdModeFunction:\nCannot find boolean in response.\n")
							end
						end
					end
				else
					core.log("warning", "Error: A bot punched his teammate. This error should not appear.")
					if player:get_hp() - damage <= 0 then
						if PvpMode.Mode == 1 then
							local hitter = reason.object
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
							bs.allocate_to_spectator(player, true)
							stats.deaths.add_to(Name(player))
						elseif PvpMode == 2 then
							local hitter = reason.object
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
							stats.deaths.add_to(Name(player))
						elseif PvpMode == 3 then
							local hitter = reason.object
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(reason.object)}})
							stats.deaths.add_to(Name(player))
							local response = PvpMode.ThirdModeFunction(player, reason.object)
							if response == true then
								bs.allocate_to_spectator(player, true)
							elseif response == false then
								player:set_pos(maps.current_map.teams[bs.get_team(player)])
								player:set_hp(20)
							else
								error("\nPvP Engine:\nOn getting response of ThirdModeFunction:\nCannot find boolean in response.\n")
							end
						end
					end
				end
			else
				core.log("error", "Attempt of crash blocked!: Bot data dont exists, this maybe is a bug or its a mod making conflicts.")
			end
		end
	end
end)



























