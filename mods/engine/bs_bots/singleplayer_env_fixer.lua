
if core.is_singleplayer() and ffjie then
	core.log("action", "Singleplayer mode detected!")
	loop_time = 0
	core.register_globalstep(function(dtime)
		loop_time = loop_time + dtime
		if loop_time >= 0.5 then
			local player = Player("singleplayer")
			if player then
				local player_team = bs.get_player_team_css(player)
				if player_team ~= "" then
					local enemy_bots = {}
					local is_enemy_team_loaded = true
					for name, data in pairs(bots.data) do
						if data.team ~= player_team then
							if data.object and not data.object:get_yaw() then
								if data.state == "alive" then
									is_enemy_team_loaded = false
								end
							end
						end
					end
					if is_enemy_team_loaded == false then
						core.log("warning", "Restarting bots....")
						bots.restart_bots()
					end
				end
			end
			loop_time = 0
		end
	end)
end