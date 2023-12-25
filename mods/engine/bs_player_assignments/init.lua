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
	end
end

--core.register_globalstep(repeater)