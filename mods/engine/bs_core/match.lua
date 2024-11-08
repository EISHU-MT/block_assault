bs_match = {
	match_is_started = false,
	rounds = 5,
	modes_rounds = 4,
	current_modes_rounds = 0,
	current_rounds = 0,
	cbs = {
		SecondOnEndMatch = {},
		OnMatchStart = {},
		OnNewMatches = {},
		OnEndMatch = {}
	},
}

--
-- CORE
--

function bs_match.reset_rounds()
	bs_match.current_rounds = bs_match.rounds
end

local function QueueCloseForms(int)
	core.after(int or 2, summary.close_all_forms)
end

function bs_match.finish_match(winner, text) -- PlayerKills, it resets every round.
	if config.AnnouceWinner then
		annouce.winner(winner, text)
	end
	UpdateRoundsHud(winner)
	bs_match.current_rounds = bs_match.current_rounds - 1
	RunCallbacks(bs_match.cbs.OnEndMatch, winner, table.copy(PlayerKills))
	if bs_match.current_rounds > 0 then
		bs_match.match_is_started = false
		for name in pairs(bs.team[winner].players) do
			bank.player_add_value(name, 20)
			score.add_score_to(name, 30)
		end
		ResetAllNametags()
		RunCallbacks(bs_match.cbs.SecondOnEndMatch)
		if C(maps.current_map.teams) > 2 then
			bs.team.red.state = "alive"
			bs.team.blue.state = "alive"
			bs.team.green.state = "alive"
			bs.team.yellow.state = "alive"
		else
			bs.team.red.state = "alive"
			bs.team.blue.state = "alive"
		end
	else
		if bs_match.current_modes_rounds > 0 then
			bs_match.current_modes_rounds = bs_match.current_modes_rounds - 1
			RunCallbacks(bs_match.cbs.SecondOnEndMatch)
			bs_match.reset_rounds()
			summary.show_to_all()
			QueueCloseForms(5)
			bs_match.match_is_started = false
			maps.new_map(function()
				core.after(1, function()
					if config.ShowMenuToPlayerWhenEndedRounds.bool then
						for _, player in pairs(core.get_connected_players()) do
							--core.after(10, bs.auto_allocate_team, player)
							--core.show_formspec(Name(player), "core:menu", bs.login_menu())
							bs.show_menu_and_expire(player)
							if config.ResetPlayerMoneyOnEndRounds then
								if bank.player[Name(player)].money then
									bank.player[Name(player)].money = 10 -- Reset his money
									score.add_score_to(name, 5)
								end
							end
							
						end
					else
						config.ShowMenuToPlayerWhenEndedRounds.func() -- Call to the function if it are disabled.
					end
					
					RunCallbacks(bs_match.cbs.OnNewMatches)
					core.after(1, function()
						for _, p in pairs(core.get_connected_players()) do
							if not bs.spectator[Name(p)] then
								PlayerKills[Name(p)] = {kills = 0, deaths = 0, score = 0}
								bank.player[Name(p)].money = 10 -- Reset his money
							end
						end
					end)
				end)
			end)
		else
			-- Make votes
			Modes.DoVotes()
		end
	end
	if config.RestorePlayerHPOnEndRounds then
		for _, p in pairs(core.get_connected_players()) do
			p:set_hp(20)
		end
	end
	core.set_timeofday(0.24)
end

--
-- CALLBACKS
--

bs_match["register_SecondOnEndMatch"] = function(function_to_run) table.insert(bs_match.cbs.SecondOnEndMatch, function_to_run) end
bs_match["register_OnMatchStart"] = function(function_to_run) table.insert(bs_match.cbs.OnMatchStart, function_to_run) end
bs_match["register_OnNewMatches"] = function(function_to_run) table.insert(bs_match.cbs.OnNewMatches, function_to_run) end
bs_match["register_OnEndMatch"] = function(function_to_run) table.insert(bs_match.cbs.OnEndMatch, function_to_run) end

--
-- FUNCTIONS CALL
--

--core.register_on_mods_loaded(function()
--	bs_match.reset_rounds()
--	bs_timer.reset()
--	maps.new_map()
--end)

local AlreadyJoinedAPlayer = false

do
	if core.is_singleplayer() then
		core.register_on_joinplayer(function(p)
			core.after(0.5, function()
				bs_match.reset_rounds()
				bs_timer.reset()
				Modes.DoVotes()
			end)
		end)
	else
		core.after(2, function()
			bs_match.reset_rounds()
			bs_timer.reset()
			Modes.DoVotes()
		end)
	end
end

bs_match.register_OnMatchStart(function() core.set_timeofday(0.24) end)












