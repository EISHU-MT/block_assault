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
	body_owner = nil,
	on_step = function(self)
		if not bs_match.match_is_started or bs_db.is_alive(self) then
			self.object:remove()
		end
	end
}
minetest.register_entity("bs_dead_body:body", body)

function bs_db.is_alive(obj)
	if type(obj) ~= "userdata" then
		return false
	end
	if obj:is_player() then
		return bs.get_player_team_css(obj) ~= ""
	elseif obj:get_luaentity() then
		local ent = obj:get_luaentity()
		if ent.bot_name then
			return bots.data[ent.bot_name].state == "alive"
		end
	end
	return false
end

PvpCallbacks.RegisterFunction(function(data)
	if config.EnableDeadBody then
		if PvpMode.Mode == 1 then
			local player_look = data.died:get_look_horizontal()
			local obj = core.add_entity(data.died:get_pos(), "bs_dead_body:body")
			local ent = obj:get_luaentity()
			ent.body_owner = data.died
			obj:set_yaw(player_look)
			obj:set_properties({
				textures = {"character.png^player_"..bs.player_team[Name(data.died)].."_overlay.png"}
			})
			obj:set_animation({x = 162, y = 166}, 15, 0)
			obj:set_acceleration(vector.new(0,-9.81,0))
		end
	end
end, "BS Dead Body")
