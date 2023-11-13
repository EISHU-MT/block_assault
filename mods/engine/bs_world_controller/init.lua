-------------------------
--        MAPGEN        -
-------------------------
core.register_on_mods_loaded(function()
	if config.StrictMapgenCheck then
		local params = core.get_mapgen_params()
		if params.mgname ~= "singlenode" then
			error("Unable to join in your world. Please make sure this world mapgen is the correct!\nCurrent Mapgen: "..params.mgname.."\nRequired for the game: singlenode")
		end
	end
end)

function core.is_protected(pos, name)
	if bs.spectator[name] then
		if Player(name) then
			hud_events.new(Player(name), {
				text = "You cant interact while you are a spectator",
				color = "warning",
				quick = false,
			})
		end
		return true
	else
		if config.AllowPlayersModifyMaps then
			return false
		else
			return true
		end
	end
end