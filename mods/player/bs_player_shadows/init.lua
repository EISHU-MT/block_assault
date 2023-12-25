minetest.register_on_joinplayer(function(player)
	player:set_lighting({ shadows = { intensity = config.PlayerLigthingIntensity, saturation = config.PlayerLigthingSaturation } })
	print(config.PlayerLigthingIntensity, config.PlayerLigthingSaturation)
end)
