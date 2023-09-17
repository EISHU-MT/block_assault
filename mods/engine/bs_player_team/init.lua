--[[local def = {
	initial_properties = {
			name = "team_r",
			hp_max = 65535,
			physical = false,
			collide_with_objects = false,
			collisionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1 },
			selectionbox = { -0.1, -0.1, -0.1, 0.1, 0.1, 0.1, rotate = false },
			pointable = false,
			visual = "mesh",
			visual_size = {x = 1.6, y = 1.6, z = 1.6},
			mesh = "character.b3d",
			textures = {"blank.png"},
			colors = {},
			use_texture_alpha = false,
			--spritediv = {x = 1, y = 1},
			is_visible = true,
			makes_footstep_sound = true,
			--automatic_rotate = 0,
			automatic_face_movement_dir = false,
			--automatic_face_movement_max_rotation_per_sec = -1,
			--backface_culling = false,
			--nametag = "Bomb <Unknown>",
			static_save = false,
			damage_texture_modifier = "",
			shaded = true,
			show_on_minimap = true,
			dtimer1 = 0,
			dtimer2 = 0,
			
	},
	is_player_teamtag = true,
	on_step = function(self)
		local attached = self.object:get_attach()
		if attached then
			local attached_team = bs.get_team(attached)
			if attached_team ~= "" then
				local texture = "player_"..attached_team.."_overlay.png"
				print('iefnsifnbsofibse')
				self.object:set_properties({textures = {texture}})
			else
				core.log("warning", "[BA.S TeamTag System] for now the teamtag will be removed! For: "..Name(attached))
				print("aeaeaeaeae")
				self.object:remove()
			end
		end
		self.object:set_properties({nametag = ""})
	end,
}
core.register_entity(":teamtag", def)
bs.cbs.OnAssignTeam[CountTable(bs.cbs.OnAssignTeam) + 1] = function(player, team)
	if team ~= "" or team ~= nil then
		entity_to_use = core.add_entity(player:get_pos(), "teamtag")
		entity_to_use:set_attach(player, "", vector.new(1, 9, -1.6))
	end
end
--]]









