c4.BAI = nil
if config.EnableBots then
	c4.BotsSupport = {
		BombHolderSelectedArea = "",
		BombHolder = "",
		AlreadySaidPhare = false,
		BotsAreaToGo = {},
		AreasChecked = {},
		StopHunterFrom = {},
		AlreadyDefusingBomb = false, --Avoid segmentation fault!
	}
	function c4.BAI(self)
		if self and self.object and self.object:get_yaw() then
			if bs_match.match_is_started then
				--Data
				local team = bots.data[self.bot_name].team
				local obj = self.object
				if team == "red" then
					if self.bot_name == c4.BombData.PlayerName then
						if c4.BotsSupport.BombHolderSelectedArea == "" and c4.BotsSupport.BombHolder == "" then
							local plants = {"a", "b"}
							local irx = math.random(1,2)
							local plant = plants[irx]
							c4.BotsSupport.BombHolderSelectedArea = plant
							core.log("action", "Selected area "..plant.." for BOT-"..self.bot_name)
							c4.BotsSupport.BombHolder = self.bot_name
						end
						if c4.BotsSupport.BombHolderSelectedArea ~= "" and c4.BotsSupport.BombHolder == self.bot_name then
							if not c4.StaticData.Planted then
								local pos = self.object:get_pos()
								local area_pos = maps.current_map.data[c4.BotsSupport.BombHolderSelectedArea] -- will don't crash
								if vector.distance(pos, area_pos) > 7 then
									--print(dump(CheckPos(maps.current_map.data[c4.BotsSupport.BombHolderSelectedArea])))
									local path = bots.find_path_to(CheckPos(pos), CheckPos(maps.current_map.data[c4.BotsSupport.BombHolderSelectedArea]), nil, self)
									bots.assign_path_to(self, path, 1.5)
									bots.stop_hunter[self.bot_name] = true
									c4.BotsSupport.StopHunterFrom[self.bot_name] = true
								else
									c4.PlantBombAt(CheckPos(pos), self.bot_name)
								end
							else
								print("sofhbsi")
							end
						end
					else
						if c4.BombData.IsDropped then
							local pos = self.object:get_pos()
							local pos2 = c4.BombData.Pos
							if pos2 then
								--Generate a path to get the bomb
								if c4.BombData.Obj then
									if vector.distance(pos, pos2) > 1.5 then
										local path = bots.find_path_to(CheckPos(pos), CheckPos(pos2), nil, self)
										bots.assign_path_to(self, path, 1.8)
									else
										c4.BombData.Obj:remove()
										c4.NotifyPickedBomb("BOT "..self.bot_name)
										c4.BombData = {
											IsDropped = false,
											PlayerName = self.bot_name,
											Dropper = nil,
											Pos = vector.new(),
											Obj = nil
										}
									end
								end
							end
						else
							Logic.OldOnStep(self)
							if c4.BotsSupport.StopHunterFrom[self.bot_name] then
								bots.stop_hunter[self.bot_name] = nil
								c4.BotsSupport.StopHunterFrom[self.bot_name] = nil
							end
						end
					end
				else
					if c4.StaticData.Planted then
						--Simulate: Bot searchs place by RANDOM
						if not c4.BotsSupport.BotsAreaToGo[self.bot_name] then
							local plants = {"a", "b"}
							local irx = math.random(1,2)
							local plant = plants[irx]
							c4.BotsSupport.BotsAreaToGo[self.bot_name] = plant
							core.log("action", "Selected area "..plant.." for BOT-"..self.bot_name.." >>>COUNTER=BLUE")
							c4.BotsSupport.AreasChecked[self.bot_name] = {a = false, b = false}
						else
							local pos = self.object:get_pos()
							local area_pos = maps.current_map.data[c4.BotsSupport.BotsAreaToGo[self.bot_name]]
							if vector.distance(pos, area_pos) > 7 then
								local path = bots.find_path_to(CheckPos(pos), CheckPos(maps.current_map.data[c4.BotsSupport.BotsAreaToGo[self.bot_name]]), nil, self)
								bots.assign_path_to(self, path, 1.5)
								bots.stop_hunter[self.bot_name] = true
								c4.BotsSupport.StopHunterFrom[self.bot_name] = true
							else
								if vector.distance(pos, c4.StaticData.Pos) <= 7 then
									if not c4.BotsSupport.AlreadyDefusingBomb then
										--Queue action of defuser in core.after(), also check if bot inst dead "yet"
										local HasDefuser = c4.Defuser[self.bot_name]
										local secs = 8 --default
										if HasDefuser then
											secs = 5
										end
										bots.CancelPath(self)
										core.after(secs, function(name, pos, obj)
											if bots.data[name].state == "alive" then
												if obj:get_yaw() then
													if vector.distance(obj:get_pos(), pos) <= 7 then
														c4.EndMatchFromDefuser("BOT "..name)
													end
												end
											end
										end, self.bot_name, pos, self.object)
										c4.BotsSupport.AlreadyDefusingBomb = true
									end
								else
									--Area has not bomb
									c4.BotsSupport.AreasChecked[self.bot_name][c4.BotsSupport.BotsAreaToGo[self.bot_name]] = true
									local phares = {"Nothing on sector "..c4.BotsSupport.BotsAreaToGo[self.bot_name]:upper(), "Sector "..VersusBombArea(c4.BotsSupport.BotsAreaToGo[self.bot_name]):upper().." has the bomb!"}
									c4.BotsSupport.BotsAreaToGo[self.bot_name] = VersusBombArea(c4.BotsSupport.BotsAreaToGo[self.bot_name])
									local phare = Randomise("", phares)
									bs.send_to_team(team, "### <"..self.bot_name.."> "..phare)
								end
							end
						end
					else
						Logic.OldOnStep(self)
						if c4.BotsSupport.StopHunterFrom[self.bot_name] then
							bots.stop_hunter[self.bot_name] = nil
							c4.BotsSupport.StopHunterFrom[self.bot_name] = nil
						end
					end
				end
			end
		end
	end
end