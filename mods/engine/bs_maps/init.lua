maps = {
	reg_maps = {},
	func_maps = {},
	maps_name = {},
	current_map = {},
	next_map = {},
	on_load = {},
	modpath = minetest.get_modpath(minetest.get_current_modname()),
	theres_loaded_map = false
}
local log = core.log
log("action", "Starting Maps core")
dofile(maps.modpath.."/proccesor.lua")
dofile(maps.modpath.."/core.lua")
dofile(maps.modpath.."/essential.lua")
dofile(maps.modpath.."/api.lua")
dofile(maps.modpath.."/physics.lua") -- handshake with empty-hand stamina