dropondie = {}

local function drop_list(pos, inv, list)
	for _, item in ipairs(inv:get_list(list)) do
		local obj = minetest.add_item(pos, item)
		if obj then
			obj:set_velocity({ x = math.random(-1, 1), y = 5, z = math.random(-1, 1) })
		end
	end
	inv:set_list(list, {})
end

function dropondie.drop_all(player)
	local pos = player:get_pos()
	pos.y = math.floor(pos.y + 0.5)
	drop_list(pos, player:get_inventory(), "main")
end

--minetest.register_on_dieplayer(dropondie.drop_all)

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if player:get_hp() - damage <= 0 then
		dropondie.drop_all(player)
	end
end)

minetest.register_on_leaveplayer(dropondie.drop_all)
