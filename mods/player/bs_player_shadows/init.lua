minetest.register_on_joinplayer(function(player)
	player:set_lighting({ shadows = { intensity = config.PlayerLigthingIntensity, saturation = config.PlayerLightingSaturation } })
end)
