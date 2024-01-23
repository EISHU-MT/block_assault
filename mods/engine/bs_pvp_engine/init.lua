-- BlockAssault Player VS Player Engine
--[[
	This can be overrided by any mod, being modified from bs_core ==> init.lua ==> configs
--]]

PvpMode = {Mode = 1, ThirdModeFunction = function(player) end}
PvpCallbacks = {
	RegisterFunction = function(func, name)
		if func and type(func) == "function" then
			table.insert(PvpCallbacks.Callbacks, func)
			core.log("action", "[PVP ENGINE] Registering callback "..(name or "no_name").."...")
		else
			core.log("error", "[PVP ENGINE] Unable to register \""..(name or "no_name").."\"")
		end
	end,
	Callbacks = {}
}

FriendShootCallbacks = {
	RegisterFunction = function(func, name)
		if func and type(func) == "function" then
			table.insert(FriendShootCallbacks.Callbacks, func)
			core.log("action", "[PVP ENGINE FS] Registering callback "..(name or "no_name").."...")
		else
			core.log("error", "[PVP ENGINE FS] Unable to register \""..(name or "no_name").."\"")
		end
	end,
	Callbacks = {}
}

PlayerKills = {}

bs.cbs.OnAssignTeam[1 + CountTable(bs.cbs.OnAssignTeam)] = function(thing, team)
	if team ~= "" then
		local player = Player(thing)
		if not PlayerKills[Name(player)] then
			PlayerKills[Name(player)] = {kills = 0, deaths = 0, score = 0}
		end
	end
end

--[[
	Modes:
	1 = When a player gets killed, it respawns as spectator
	2 = When a player dies, respawns with no being spectator
	3 = When a player dies, respawns being spectator or not, depending on the overrider (Mod)
	ThirdModeFunction should return:
	true: Make dead player be spectator
	false: Respawn dead player
	nil: *crash*
--]]

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

--This function should handle "FriendShoot" feature.
function OnPunchPlayer(player, hitter, _,_,_, damage)
	if bs.spectator[Name(hitter)] or bs.spectator[Name(player)] then -- Dont allow spectators do damage.
		return true
	end
	
	if not bs.player_team[Name(player)] then
		return true -- Avoid hitting player without team.
	end
	
	-- Should dont hit other players when match inst started
	if config.DontPunchPlayerWhileMatchNotStarted then
		if bs_match.match_is_started == false then
			
			hud_events.new(hitter, {
				text = "You cant do damage to others player while in no match.",
				color = "warning",
				quick = true,
			})
			
			return true
		end
	end
	
	local HitterTeam = bs.get_team(hitter)
	local VictimTeam = bs.get_team(player)
	if HitterTeam == VictimTeam then
		if config.PvpEngine.FriendShoot then
			RunCallbacks(FriendShootCallbacks.Callbacks, player, hitter, damage, config.PvpEngine)
			return false
		else
			RunCallbacks(FriendShootCallbacks.Callbacks, player, hitter, damage, config.PvpEngine)
			return true
		end
	end
end

function OnPlayerGetHurt(player, hp, reason)
	local damage = get_damage_from_hp(hp)
	if reason and reason.object and reason.object:is_player() then
		if config.PvpEngine.enable then
			if player:get_hp() - damage <= 0 then
				if PvpMode.Mode == 1 then
					if reason.object then
						local hitter = reason.object
						local HitterTeam = bs.get_team(hitter)
						local VictimTeam = bs.get_team(player)
						if HitterTeam == VictimTeam then
							-- This is handled in on_punchplayer
							core.log("action", "Player "..Name(player).." punched his teammate "..Name(hitter))
						else
							if PlayerKills[Name(player)] and PlayerKills[Name(hitter)] then
								PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
								PlayerKills[Name(hitter)].kills = PlayerKills[Name(hitter)].kills + 1
								RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(hitter)}})
								bs.allocate_to_spectator(player, true)
								if config.GiveMoneyToKillerPlayer.bool then
									bank.player_add_value(Name(hitter), config.GiveMoneyToKillerPlayer.amount)
								end
							end
						end
					elseif reason.type == "fall" or reason.type == "node_damage" or reason.type == "drown" then
						if PlayerKills[Name(player)] then
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
							bs.allocate_to_spectator(player, true)
						end
					end
				elseif PvpMode.Mode == 2 then
					if reason.object then
						local hitter = reason.object
						local HitterTeam = bs.get_team(hitter)
						local VictimTeam = bs.get_team(player)
						if HitterTeam == VictimTeam then
							-- This is handled in on_punchplayer
							core.log("action", "Player "..Name(player).." punched his teammate "..Name(hitter))
						else
							if PlayerKills[Name(player)] and PlayerKills[Name(hitter)] then
								PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
								PlayerKills[Name(hitter)].kills = PlayerKills[Name(hitter)].kills + 1
								RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(hitter)}})
								if config.GiveMoneyToKillerPlayer.bool then
									bank.player_add_value(Name(hitter), config.GiveMoneyToKillerPlayer.amount)
								end
								--player:set_pos(maps.current_map.teams[bs.get_team(player)])
								RespawnDelay.DoRespawnDelay(player)
							end
						end
					else
						if PlayerKills[Name(player)] then
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
							--player:set_pos(maps.current_map.teams[bs.get_team(player)])
							RespawnDelay.DoRespawnDelay(player)
						end
					end
				elseif PvpMode.Mode == 3 then
					if reason.object then
						local hitter = reason.object
						local HitterTeam = bs.get_team(hitter)
						local VictimTeam = bs.get_team(player)
						if HitterTeam == VictimTeam then
							-- This is handled in on_punchplayer
							core.log("action", "Player "..Name(player).." punched his teammate "..Name(hitter))
						else
							if PlayerKills[Name(player)] and PlayerKills[Name(hitter)] then
								PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
								PlayerKills[Name(hitter)].kills = PlayerKills[Name(hitter)].kills + 1
								RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = hitter, teams = {died = bs.get_team(player), killer = bs.get_team(hitter)}})
								if config.GiveMoneyToKillerPlayer.bool then
									bank.player_add_value(Name(hitter), config.GiveMoneyToKillerPlayer.amount)
								end
								local response = PvpMode.ThirdModeFunction(player, reason.object)
								if response == true then
									bs.allocate_to_spectator(player, true)
								elseif response == false then
									player:set_pos(maps.current_map.teams[bs.get_team(player)])
									player:set_hp(20) -- This is here because this is not handled by 1st callback function
								else
									error("\nPvP Engine:\nOn getting response of ThirdModeFunction:\nCannot find boolean in response.\n")
								end
							end
						end
					elseif reason.type == "fall" or reason.type == "node_damage" or reason.type == "drown" then
						if PlayerKills[Name(player)] then
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
							local response = PvpMode.ThirdModeFunction(player, reason.object)
							if response == true then
								bs.allocate_to_spectator(player, true)
							elseif response == false then
								player:set_pos(maps.current_map.teams[bs.get_team(player)])
								player:set_hp(20) -- This is here because this is not handled by 1st callback function
							else
								error("\nPvP Engine:\nOn getting response of ThirdModeFunction:\nCannot find boolean in response.\n")
							end
						end
					elseif reason.type == "set_hp" then
						if PlayerKills[Name(player)] then
							PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
							RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
							bs.allocate_to_spectator(player, true)
						end
					end
				end
			end
		else
			if config.PvpEngine.func then
				if type(config.PvpEngine.func) == "function" then
					config.PvpEngine.func(player, damage, reason)
				else
					error("\nPvP Engine:\nOn Calling external function [config.PvpEngine.func]:\nInvalid type of variable: "..type(config.PvpEngine.func)..".\n")
				end
			else
				error("\nPvP Engine:\nOn Calling external function [config.PvpEngine.func]:\nVariable is nil.\n")
			end
		end
	elseif reason.type and reason.type ~= "set_hp" then
		if reason.object and not reason.object:is_player() then return end -- no infinity respawns
		if player:get_hp() - damage <= 0 then
			if PvpMode.Mode == 1 then
				if PlayerKills[Name(player)] then
					PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
					RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
					bs.allocate_to_spectator(player, true)
				end
			elseif PvpMode.Mode == 2 then
				if PlayerKills[Name(player)] then
					PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
					RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
					RespawnDelay.DoRespawnDelay(player)
				end
			elseif PvpMode.Mode == 3 then
				if PlayerKills[Name(player)] then
					PlayerKills[Name(player)].deaths = PlayerKills[Name(player)].deaths + 1
					RunCallbacks(PvpCallbacks.Callbacks, {died = player, killer = reason.type, teams = {died = bs.get_team(player), killer = nil}})
					local response = PvpMode.ThirdModeFunction(player, reason.object)
					if response == true then
						bs.allocate_to_spectator(player, true)
					elseif response == false then
						player:set_pos(maps.current_map.teams[bs.get_team(player)])
						player:set_hp(20) -- This is here because this is not handled by 1st callback function
					else
						error("\nPvP Engine:\nOn getting response of ThirdModeFunction:\nCannot find boolean in response.\n")
					end
				end
			end
		end
	end
end

PvpCallbacks.RegisterFunction(function(data)
	if config.UsePvpMatchEngine.bool then
		if PvpMode.Mode == 1 then
			if CountTable(maps.current_map.teams) == 2 then
				local players_index = bs.get_team_players_index(data.teams.died)
				core.after(0.3, function(data)
					local players_index = bs.get_team_players_index(data.teams.died)
					if players_index <= 0 then
						bs_match.finish_match(GetFirstIndex(bs.enemy_team(data.teams.died)))
					end
				end, data)
			else
				core.after(0.3, function(data)
					local players_index = bs.get_team_players_index(data.teams.died)
					if players_index <= 0 then
						bs.destroy_team(data.teams.died)
					end
				end, data)
			end
		elseif PvpMode.Mode == 2 then --bs_respawn_delay
			--bs.allocate_to_team(data.died, data.teams.died, true, false)
		end
	end
end, "Match Shared Function")

-- Register everything
core.register_on_punchplayer(OnPunchPlayer)
core.register_on_player_hpchange(OnPlayerGetHurt)



