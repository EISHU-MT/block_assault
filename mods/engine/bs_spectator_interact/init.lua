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
	end
end