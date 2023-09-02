if config.OverridePlayersSkinForTeams then
	bs.cbs.register_OnAssignTeam(function(index, team)
		if team ~= "" then
			local player = Player(index)
			local textures = player:get_properties().textures
			textures[1] = textures[1].."^player_"..team.."_overlay.png"
			player:set_properties({textures = textures})
		end
	end)
end
