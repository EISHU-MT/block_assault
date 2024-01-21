-- MOLOTOV FOR BLOCKASSAULT
local molotov_entity = {
	initial_properties = {
		physical = false,
		collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
		automatic_rotate = 0.01,
		visual = "wielditem",
		textures = {"fire:permanent_flame"},
		pointable = false,
		static_save = false,
		visual_size = {x = 2.5, y = 2.5},
		light_source = 10,
	},
	timer = 0,
	timer_to_check = 0,
	center_light_node_pos = {x=0,y=0,z=0},
	dropper = nil,
	is_fire = true,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= config.SecondsToWaitToEndMolotovFire then
			core.set_node(self.center_light_node_pos, {name="air"})
			self.object:remove()
		end
		local self_stand_pos = self.object:get_pos()
		self.timer_to_check = self.timer_to_check + dtime
		if self.timer_to_check >= 0.8 then
			if self_stand_pos then
				for _, obj in pairs(core.get_objects_inside_radius(self_stand_pos, 5)) do
					local has_no_error = true
					if obj:get_luaentity() then
						if obj:get_luaentity().is_fire then
							has_no_error = false
						end
					end
					if has_no_error then
						if obj:get_pos() and self.object:get_pos() then
							local ray_view = minetest.raycast(self.object:get_pos(), obj:get_pos(), true, true)
							if ray_view then
								local view = ray_view:next()
								local did_has_errors = false
								while view do
									if view.type == "node" then
										local node_data = core.get_node(view.under)
										if not (core.registered_nodes[node_data.name] and core.registered_nodes[node_data.name].walkable) then
											did_has_errors = true
											break
										end
									elseif view.type == "object" then
										if view.ref:get_properties() and not view.ref:get_properties().pointable then
											did_has_errors = true
											break
										end
									end
									view = ray_view:next()
								end
								if Name(obj) then
									if self.dropper then
										obj:punch(self.dropper, nil, {damage_groups = {fleshy=4}}, nil)
									end
								end
							end
						end
					end
				end
			end
			self.timer_to_check = 0
		end
	end,
}
minetest.register_entity("bs_molotov:entity", molotov_entity)
minetest.register_node("bs_molotov:node", {
	description = "Invisible Molotov Node\nUsed to do light in a area for molotov",
	drawtype = "glasslike_framed_optional",
	tiles = {"blank.png"},
	pointable = false,
	light_source = 10,
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	groups = {immortal=1},
})

grenades.register_grenade("bs_molotov:molotov", {
	description = "Molotov (Kill enemies near fire area)",
	image = "grenades_molotov.png",
	on_collide = function()
		return true
	end,
	on_explode = function(def, obj, pos, name)
		local obj = core.add_entity(pos, "bs_molotov:entity")
		local ent = obj:get_luaentity()
		ent.dropper = Player(name)
		local pos_to_place = CheckPos(pos)
		core.set_node(pos_to_place, {name = "fire:permanent_flame"})
		ent.center_light_node_pos = pos_to_place
	end,
})

Shop.RegisterWeapon("Molotov", {
	item_name = "bs_molotov:molotov",
	price = 30,
	icon = "grenades_molotov.png",
	count_limit = 5,
	stype = "grenade",
	type = "armor",
	uses_ammo = false,
})













