function SetTeamSkin(index, team)
	if config.OverridePlayersSkinForTeams then
		if team ~= "" then
			local player = Player(index)
			if player:get_properties() then
				local textures = player:get_properties().textures
				textures[1] = textures[1].."^player_"..team.."_overlay.png"
				player:set_properties({textures = textures})
			end
		end
	end
end

local peer_time = 0

local function repeater(dt)
	for _, player in pairs(core.get_connected_players()) do
		if config.OverridePlayersSkinForTeams then
			if skinsdb then
					player:set_properties({textures = "blank.png"})
			else
				if bs.get_player_team_css(player) ~= "" and not player:get_properties().textures[1]:match("_overlay") then
					SetTeamSkin(player, bs.get_team(player))
				elseif bs.get_player_team_css(player) == "" then
					player:set_properties({textures = "blank.png"})
				end
			end
		end
		peer_time = peer_time + dt
		if not bs_match.match_is_started then
			if peer_time >= 0.65 then
				peer_time = 0
				local player_team = bs.get_player_team_css(player)
				if player_team ~= "" then
					local to_pos = maps.current_map.teams[player_team]
					if to_pos then
						if vector.distance(player:get_pos(), to_pos) >= 2 then
							player:set_pos(CheckPos(to_pos))
						end
					end
				end
			end
		end
	end
end

core.register_globalstep(repeater)