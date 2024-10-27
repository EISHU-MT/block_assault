minetest.register_node(":bas:wall_block", {
	description = ("Wall of maps\nBA.S Block\nUsed to fill free space in non-walkable area"),
	tiles = {
		[1] = "default_tin_block.png",
	},
	is_ground_content = false,
	sunlight_propagates = true,
	groups = {immortal = 1},
})

minetest.register_node(":bas:ceiling_block", {
	description = ("Ceiling Block for maps\nBA.S Block\nUsed to fill free space in non-walkable area"),
	tiles = {"default_glass.png"},
	is_ground_content = false,
	groups = {immortal = 1},
	sunlight_propagates = true,
	paramtype = "light",
	drawtype = "glasslike_framed",
})

minetest.register_node(":bas:fillblock", {
	description = ("FillBlock\nBA.S Block\nUsed to fill free space in non-walkable area"),
	tiles = {"fillblock.png"},
	is_ground_content = false,
	groups = {immortal = 1},
	sunlight_propagates = true,
	paramtype = "light",
	drawtype = "glasslike_framed",
})

minetest.register_node(":bas:kill", {
	description = "KillNode\nBA.S Block\nUsed to do (fill/traps) to areas\nDamage: 40PS", 
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false,
	air_equivalent = true,
	damage_per_second = 40,
	tiles = {"blank.png"},
	groups = {immortal = 1},
})

minetest.register_node(":bas:lightsource", {
	description = "LightSource\nBA.S Block\nUsed to put full light in areas",
	inventory_image = "blank.png",
	paramtype = "light",
	tiles = { "blank.png" },
	walkable = false,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	pointable = false, -- no mapmaking!
})

minetest.register_node(":bas:blocker", {
	description = "Blocker\nBA.S Block\nUsed to block water/lava flows, this allow player walk in",
	inventory_image = "blank.png",
	paramtype = "light",
	tiles = { "blank.png" },
	walkable = false,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	pointable = false
})

-- Letters

minetest.register_node(":csgo:sign_a", {
	description = "(<= A) sign",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	tiles = { "cs_files_a1.png" },
	use_texture_alpha = true,
	walkable = false,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	visual_scale = 1.5
})
minetest.register_node(":csgo:sign_b", {
	description = "(<= B) sign",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	tiles = { "cs_files_b1.png" },
	walkable = false,
	use_texture_alpha = true,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	visual_scale = 1.5
})
minetest.register_node(":csgo:sign_a2", {
	description = "(A) sign",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	tiles = { "cs_files_a2.png" },
	walkable = false,
	groups = { immortal = 1 },
	use_texture_alpha = true,
	sunlight_propagates = true,
	visual_scale = 1.5
})
minetest.register_node(":csgo:sign_a3", {
	description = "(A) sign",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	tiles = { "cs_files_a3.png" },
	walkable = false,
	groups = { immortal = 1 },
	use_texture_alpha = true,
	sunlight_propagates = true,
	visual_scale = 1.5
})
minetest.register_node(":csgo:sign_b2", {
	description = "(B) sign",
	drawtype = "signlike",
	paramtype = "light",
	use_texture_alpha = true,
	paramtype2 = "wallmounted",
	tiles = { "cs_files_b2.png" },
	walkable = false,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	visual_scale = 1.5
})
minetest.register_node(":csgo:sign_b3", {
	description = "(B) sign",
	drawtype = "signlike",
	paramtype = "light",
	use_texture_alpha = true,
	paramtype2 = "wallmounted",
	tiles = { "cs_files_b3.png" },
	walkable = false,
	groups = { immortal = 1 },
	sunlight_propagates = true,
	visual_scale = 1.5
})

-- Register automatic door

cdoor = {}
function cdoor.scan_for_players(pos) 
	local a = minetest.get_objects_inside_radius(pos, 1.5)
	if next(a) == nil then
		return false
	end
	for _, obj in pairs(a) do
		if obj:is_player() then
			local name = obj:get_player_name()
			if not bs.spectator[name] then
				return true
			end
		else
			if Name(obj) then
				return true
			end
		end
	end
end

doors.register("door_auto", {
	tiles = {"cs_files_door.png"},
	description = ("Automatic door"),
	inventory_image = "cs_files_door_inv.png",
	groups = {node = 1, cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
})

minetest.register_abm({
	nodenames = {"doors:door_auto_c"},
	interval = 0.1,
	chance = 0.1,
	action = function(pos)
		if not cdoor.scan_for_players(pos) then
			local door = doors.get(pos)
			door:close()
		end
	end,
})
minetest.register_abm({
	nodenames = {"doors:door_auto_a"},
	interval = 0.1,
	chance = 0.1,
	action = function(pos)
		if cdoor.scan_for_players(pos) then
			local door = doors.get(pos)
			door:open()
		end
	end,
})

-- Backwards compactibility

core.register_alias("cs_map:stone", "bas:wall_block")
core.register_alias("cs_map:ind_glass", "bas:ceiling_block")
core.register_alias("cs_core:terrorists", "air")
core.register_alias("cs_core:counters", "air")
core.register_alias("map_maker:area", "air")
core.register_alias("csgo:trap", "bas:kill")