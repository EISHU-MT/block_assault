local function func(dt)
	if maps.current_map and maps.current_map.pos1 and maps.current_map.pos2 then
		if bs_match.match_is_started then
			for _, player in pairs(core.get_connected_players()) do
				if player:get_pos() then
					if not maps.is_on_interior(player:get_pos(), maps.current_map.pos1, maps.current_map.pos2) then--if not area:containsp(player:get_pos()) then
						if (not bs.spectator[Name(player)]) or (not bs.player_team[Name(player)]) then
							if maps.current_map.teams[bs.player_team[Name(player)]] then
								player:set_pos(maps.current_map.teams[bs.player_team[Name(player)]])
							end
						end
					end
				end
			end
		end
	end
end

core.register_globalstep(func)