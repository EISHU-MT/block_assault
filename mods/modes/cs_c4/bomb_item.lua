-- Registers bomb
local S = minetest.get_translator("cs_c4")
core.register_craftitem("cs_c4:bomb", {
	description = S("C4"),
	inventory_image = "cs_media_bomb_item.png",
	on_use = function(item, player)
		local inf = {pos = player:get_pos(), name = player:get_player_name(), inv = player:get_inventory()}
		local pos = inf.pos
		if maps.current_map.data.bomb_areas_bool then
			local is_near_any_area = false
			--for a,b in pairs(maps.current_map.data.bomb_areas) do print(dump(a), dump(b)) end
			for name, content in pairs(maps.current_map.data.bomb_areas) do
				if content.name and content.pos then
					if vector.distance(pos, content.pos) <= 7 then
						c4.PlantBombAt(inf.pos, player:get_player_name())
						inf.inv:remove_item("main", item)
						is_near_any_area = true
						break
					end
				end
			end
			if not is_near_any_area then
				hud_events.new(player, {
					text = S("(!) The bomb cant be placed here!"),
					color = "warning",
					quick = true,
				})
			end
		else
			hud_events.new(player, {
				text = S("(!) Planting bomb is disabled!"),
				color = "danger",
				quick = true,
			})
		end
	end,
	on_drop = function(itm, drp, pos)
		if not c4.BombData.IsDropped then
			c4.BombData.IsDropped = true
			c4.BombData.PlayerName = nil
			c4.NotifyDroppedBomb(pos, drp:get_player_name())
			--core.item_drop(itm, drp, pos)
			c4.BombData.Obj = core.add_item(pos, ItemStack("cs_c4:bomb"))
			return ItemStack("")
		end
	end,
	on_pickup = function(_, lname, table)
		if not c4.BombData.PlayerName then
			c4.BombData.IsDropped = false
			c4.NotifyPickedBomb(Name(lname))
			c4.BombData.PlayerName = Name(lname)
			bs.StringTo[Name(lname)] = core.colorize("orange", "<Bomb>")
			ReSetNametags("red")
		end
		return ItemStack("")
	end,
})

--C4 Node
core.register_node("cs_c4:c4", {
	description = S("C4 Node"),
	tiles = {"cs_media_bomb_texture.png"},
	groups = {choppy=3, falling_node = 1},
	drawtype = "mesh",
	visual_scale = 0.5,
	paramtype = "light",
	paramtype2 = "facedir",
	mesh = "cs_media_bomb.obj",
	on_dig = function(pos, node, digger)
		local name = Name(digger)
		if name then
			if bs.spectator[name] then return false end
			if not bs.team.blue.players[name] then
				return false
			else
				bs_match.finish_match("blue", name.." has defused the bomb!")
			end
		end
	end
})

