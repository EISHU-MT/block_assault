local function to_use()
	core.after(0.5, function()
		for team, data in pairs(bs.team) do
			for name in pairs(data.players) do
				bs.allocate_to_team(name, bs.died[name], true, true)
				SpawnPlayerAtRandomPosition(Player(name), team)
			end
		end
	end)
	core.after(0.7, function()
		bs_timer.pause()
		--local id = annouce.publish_to_players("Prepare!", 0xFFFFF, {img = 215, txt = 180})
		--core.after(1.5, make_dissapear_mess, id)
	end)
end

local function to_use_two()
	core.after(0.5, function()
		for team, data in pairs(bs.team) do
			for name in pairs(data.players) do
				bs.allocate_to_team(name, bs.died[name], true, true)
				SpawnPlayerAtRandomPosition(Player(name), team)
			end
		end
		bs.died = {}
	end)
end

if config.UseDefaultMatchEngine then
	bs_match.register_SecondOnEndMatch(to_use)
	bs_match.register_OnMatchStart(to_use_two)
end

-- Clear objects in area
bs_match.register_SecondOnEndMatch(function()
	local objs = core.get_objects_in_area(maps.current_map.pos1, maps.current_map.pos2)
	for _, obj in pairs(objs) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.itemstring then obj:remove() end -- clear items
			print(obj)
		end
	end
end)