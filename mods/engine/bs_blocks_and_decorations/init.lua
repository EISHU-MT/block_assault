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