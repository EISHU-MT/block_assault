function SetTeamSkin(index, team)
	if config.OverridePlayersSkinForTeams then
		if team ~= "" then
			local player = Player(index)
			local textures = player:get_properties().textures
			textures[1] = textures[1].."^player_"..team.."_overlay.png"
			player:set_properties({textures = textures})
		end
	end
end

local function repeater()
	if config.OverridePlayersSkinForTeams then
		for _, player in pairs(core.get_connected_players()) do
			if skinsdb then
				player:set_properties({textures = "blank.png"})
			else
				if bs.get_team(player) ~= "" and not player:get_properties().textures[1]:match("_overlay") then
					SetTeamSkin(player, bs.get_team(player))
				end
			end
		end
	end
end

core.register_globalstep(repeater)