--[[
	BS Death Body
--]]
bs_db = {}
local body = {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
		visual = "mesh",
		mesh = "character.b3d",
		textures = {"character.png"},
		pointable = false,
		static_save = false,
		visual_size = {x = 1, y = 1},
	},
	on_step = function(self)
		if not bs_match.match_is_started then
			self.object:remove()
		end
	end
}
minetest.register_entity("bs_bots:__dead_body", body)
