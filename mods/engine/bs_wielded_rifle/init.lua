local function get_wieldhand_entity(player)
	for _, obj in pairs(Player(player):get_children()) do
		if obj:get_luaentity() and obj:get_luaentity().wield_hand then
			return obj
		end
	end
end

local def = {
	initial_properties = {
			name = "wieled_rifle",
			hp_max = 500,
			physical = true,
			collide_with_objects = false,
			collisionbox = { -0.05, -0.05, -0.05, 0.05, 0.05, 0.05 },
			selectionbox = { -0.05, -0.05, -0.05, 0.05, 0.05, 0.05, rotate = false },
			pointable = false,
			visual = "wielditem",
			visual_size = {x = 0.2, y = 0.2},
			textures = {"bs_wielded_rifle:invisible"},
			colors = {},
			use_texture_alpha = false,
			is_visible = true,
			makes_footstep_sound = false,
			automatic_face_movement_dir = false,
			static_save = false,
			damage_texture_modifier = "^[brighten",
			shaded = true,
			show_on_minimap = true,
			dtimer1 = 0,
			dtimer2 = 0,
	},
	on_step = function(self)
		local attached = self.object:get_attach()
		if attached and attached:is_player() then
			
			if bs.get_team(attached) == "" then
				self.object:remove()
				return
			end
			
			-- Check if player has a rifle or not
			-- With all rifle types
			for _, item in pairs(rangedweapons.weapon_types.rifle) do
				if FindItem(attached, item) then -- This wont crash if itemstring
					local stack = ItemStack(item)
					local hstac = attached:get_wielded_item()
					if stack:get_name() == hstac:get_name() then
						self.object:set_properties({textures = {"bs_wielded_rifle:invisible"}}) -- If the player has a rifle in his hand then hide
						local obj = get_wieldhand_entity(attached)
						if obj then
							obj:set_properties({textures = {hstac:get_name()}})
						end
					else
						
						self.object:set_properties({textures = {stack:get_name()}})
					end
					return
				end
			end
			-- Now with shotgun types
			for _, item in pairs(rangedweapons.weapon_types.shotgun) do
				if FindItem(attached, item) then -- This wont crash if itemstring
					local stack = ItemStack(item)
					local hstac = attached:get_wielded_item()
					if stack:get_name() == hstac:get_name() then
						self.object:set_properties({textures = {"bs_wielded_rifle:invisible"}}) -- If the player has a rifle in his hand then hide
						local obj = get_wieldhand_entity(attached)
						if obj then
							obj:set_properties({textures = {hstac:get_name()}})
						end
					else
						
						self.object:set_properties({textures = {stack:get_name()}})
					end
					return
				end
			end
			self.object:set_properties({textures = {"bs_wielded_rifle:invisible"}})
		else
			self.object:remove()
		end
	end,
	animated_rifle = true,
}

minetest.register_tool("bs_wielded_rifle:invisible", {
	wield_scale = {x=0, y=0, z=0},
	description = "Invisible item",
	inventory_image = "blank.png",
})
core.register_entity(":bs_shop:animated_rifle", def)

local function on_step(id, team)
	for _, id in pairs(core.get_connected_players()) do
		local team = bs.get_player_team_css(id)
		if team ~= "" then
			-- Check if the player dont had the same entity
			local player = Player(id)
			if player then
				local is_obj_detected = false
				for i, obj in pairs(player:get_children() or {}) do
					if obj:get_luaentity() then
						local ent = obj:get_luaentity()
						if ent.animated_rifle then
							--obj:remove() -- May it is useless
							is_obj_detected = true
						end
					end
				end
				if is_obj_detected ~= true then
					core.add_entity(player:get_pos(), "bs_shop:animated_rifle"):set_attach(player, "", vector.new(-0.9, 9, -1.6), vector.new(0,0,-45))
				end
			end
		end
	end
end

--bs.cbs.register_OnAssignTeam(on_join)
core.register_globalstep(on_step)

















