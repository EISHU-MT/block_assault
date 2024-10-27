local BotsTable = {}
BotsTable.DelayToUpdate = {}
if bots then
	ctf.team_that_has_bot_to_attack_other = {
		red = {bot=nil,team="",botname=""},
		blue = {bot=nil,team="",botname=""},
		green = {bot=nil,team="",botname=""},
		yellow = {bot=nil,team="",botname=""},
	}
	ctf.bot_flag_token_up = {}
	local function get_available_teams_to_attack(self)
		local teams_available = {}
		local team_of_bot = bots.data[self.bot_name].team
		for team, data in pairs(bs.team) do
			if data.state == "alive" then
				if team ~= team_of_bot then
					table.insert(teams_available, team)
				end
			end
		end
		return teams_available
	end
	function ctf.BotsLogicFunction(self)
		if self and self.object and self.object:get_yaw() then
			--if not BotsTable.DelayToUpdate[self.bot_name] then
			--	BotsTable.DelayToUpdate[self.bot_name] = 0
			--end
			--BotsTable.DelayToUpdate[self.bot_name] = BotsTable.DelayToUpdate[self.bot_name] - self.dtime
			--if BotsTable.DelayToUpdate[self.bot_name] <= 0 then
			--	BotsTable.DelayToUpdate[self.bot_name] = 0
			--end
			if bs_match.match_is_started then
				-- Properties
				local botname = self.bot_name
				local object = self.object
				local team = bots.data[botname].team
				-- Check teams
				if not ctf.team_that_has_bot_to_attack_other[team].bot then
					-- Make this bot go get the enemy flag.
					local teams = get_available_teams_to_attack(self)
					if teams[1] then -- effective
						ctf.team_that_has_bot_to_attack_other[team] = {bot=self.object,team=teams[1],botname=botname}
						local phares = {"I'll cap "..TransformTextReadable(teams[1]), TransformTextReadable(teams[1]).." will be mine", "I'll get "..TransformTextReadable(teams[1]).." please help"}
						local phare = Randomise("", phares)
						bs.send_to_team(team, "### <"..botname.."> "..phare)
					end
				end
				-- Logic
				if ctf.team_that_has_bot_to_attack_other[team].botname == botname then
					-- Scan enemies in bot view
					local detected = {}
					for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range+50)) do
						if Name(obj) and Name(obj) ~= self.bot_name then
							if obj:get_luaentity() and obj:get_luaentity().bot_name ~= self.bot_name then
								if bots.is_in_bot_view(self, obj) then
									if obj:get_luaentity() and obj:get_luaentity().bot_name then
										if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
											table.insert(detected, obj)
										end
									end
								end
							elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then
								if bots.is_in_bot_view(self, obj) then
									if bots.is_enemy_alive(obj) then
										if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
											table.insert(detected, obj)
										end
									end
								end
							end
						end
					end
					local ent = self.object:get_luaentity()
					ent.detected_enemies = detected -- Shoot on logic will dont be supported anymore
					-- Lookup for flag
					if (not ctf.bot_flag_token_up[botname]) and (not ctf.team_of_p_has_flag_of[team]) then
						local pos = BsEntities.GetStandPos(self)
						local opos = maps.current_map.teams[ctf.team_that_has_bot_to_attack_other[team].team]
						if vector.distance(pos, opos) > 2 then
							--if BsEntities.Timer(self, 2) then
								--if BotsTable.DelayToUpdate[self.bot_name] <= 0 then
									--local path_to_flag = bots.find_path_to(CheckPos(pos), CheckPos(opos), 900, self)--bots.find_path_to(CheckPos(pos), CheckPos(opos))
									local path_to_flag = minetest.find_path(CheckPos(pos), CheckPos(opos), 500, 2, 5, "A*_noprefetch")
									if path_to_flag then
										bots.assign_path_to(self, path_to_flag, 1.9, self)
									end
									--BotsTable.DelayToUpdate[self.bot_name] = 3
									bots.stop_hunter[self.bot_name] = true
									bots.direct_walk[self.bot_name] = nil
								--end
							--end
						else
							if not ctf.team_of_p_has_flag_of[team] then
								ctf.get_flag_from(self.object, ctf.team_that_has_bot_to_attack_other[team].team)
								local phares = {"I got "..TransformTextReadable(ctf.team_that_has_bot_to_attack_other[team].team).." flag, help!", "Got "..TransformTextReadable(ctf.team_that_has_bot_to_attack_other[team].team).." now i'm going to base!", TransformTextReadable(ctf.team_that_has_bot_to_attack_other[team].team).." flag is ours! help meee!"}
								ctf.bot_flag_token_up[botname] = true
								local phare = Randomise("", phares)
								bs.send_to_team(team, "### <"..botname.."> "..phare)
							end
						end
					else
						if not ctf.team_of_p_has_flag_of[team] then
							local pos = BsEntities.GetStandPos(self)
							local opos = maps.current_map.teams[team]
							if vector.distance(pos, opos) > 2 then
								--local path_to_flag = bots.find_path_to(CheckPos(pos), CheckPos(opos), 900, self)--bots.find_path_to(CheckPos(pos), CheckPos(opos))
								local path_to_flag = minetest.find_path(CheckPos(pos), CheckPos(opos), 500, 2, 5, "A*_noprefetch")
								if path_to_flag then
									bots.assign_path_to(self, path_to_flag, 1.9, self)
								end
								--BotsTable.DelayToUpdate[self.bot_name] = 3
								bots.stop_hunter[self.bot_name] = true
								bots.direct_walk[self.bot_name] = nil
							else
								bots.CancelPathTo[botname] = true
								ctf.capture_the_flag(self.object, ctf.team_that_has_bot_to_attack_other[team].team, team)
								ctf.bot_flag_token_up[botname] = nil
							end
						else
							Logic.OldOnStep(self)
						end
					end
				else --bas_ctf:red_flag_taken
					if core.get_node(maps.current_map.teams[team]).name ~= "bas_ctf:"..team.."_flag_taken" then
						Logic.OldOnStep(self)
					else
						-- Find enemy
						--for team, data in pairs(ctf.team_that_has_bot_to_attack_other) do
						--	print(dump(data))
						--	if data and data.bot and data.team == team then
						--		bots.Hunt(self, data.bot, 1.7)
						--		core.chat_send_all("hunting "..Name(data.bot))
						--	end
						--end
						for teamA, obj in pairs(ctf.token_flags) do
							if teamA == team then
								bots.Hunt(self, obj, 1.8, true)
							end
						end
						-- Scan enemies in bot view
						local detected = {}
						for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range+5)) do
							if Name(obj) and Name(obj) ~= self.bot_name then
								if obj:get_luaentity() and obj:get_luaentity().bot_name ~= self.bot_name then
									if bots.is_in_bot_view(self, obj) then
										if obj:get_luaentity() and obj:get_luaentity().bot_name then
											if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
												table.insert(detected, obj)
											end
										end
									end
								elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then
									if bots.is_in_bot_view(self, obj) then
										if bots.is_enemy_alive(obj) then
											if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
												table.insert(detected, obj)
											end
										end
									end
								end
							end
						end
						local ent = self.object:get_luaentity()
						ent.detected_enemies = detected -- Shoot on logic will dont be supported anymore
					end
				end
			end
		else
			if config.UseLogForWarnings then
				core.log("error", "Attempt to do action on a unexistent Bot!")
			end
		end
	end
	BotsCallbacks.RegisterOnKillBot(function(self, killer)
		if self then
			local name = self.bot_name
			local team = bots.data[name].team
			if ctf.team_that_has_bot_to_attack_other[team].botname == name then
				ctf.drop_flag(self.object, ctf.team_that_has_bot_to_attack_other[team].team)
				ctf.team_that_has_bot_to_attack_other[team] = {bot=nil,team="",botname=""}
			end
		end
	end)
end










