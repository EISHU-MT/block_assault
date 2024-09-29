bs_match.register_OnMatchStart(bots.restart_bots)
bs_match.register_OnEndMatch(function()
	core.clear_objects({mode = "quick"})
end)
if config.ReCheckAliveBots then
	--bots.dead = {}
	local clock = 0
	core.register_globalstep(function(dt)
		clock = clock + dt
		if clock >= 2 then
			if bs_match.match_is_started then
				--print("sss")
				for _, data in pairs(bots.data) do
					if bots.data[_].state == "alive" then -- (not bots.dead[_])
						if (not data.object) or (not data.object:get_yaw()) then
							bots.data[_].object = core.add_entity(maps.current_map.teams[data.team], data.object_name)
							SpawnPlayerAtRandomPosition(bots.data[_].object, data.team)
							bots.data[_].object:set_armor_groups({fleshy=100, immortal=0})
							bots.add_nametag(bots.data[_].object, data.team, _)
							bots.restart_bot_id(data)
							--bots.data[_].state = "alive"
							--print("reviv ".._)
							if config.UseLogForWarnings then
								core.log("warning", "Respawning ".._..", reason: de-spawned from world (By Core)")
							end
						end
					end
				end
			end
			clock = 0
		end
	end)
	--BotsCallbacks.RegisterOnKillBot(function(self)
	--	bots.dead[self.bot_name] = true
	--end)
end














