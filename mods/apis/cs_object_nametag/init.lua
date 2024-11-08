cs_nametag = {
	Objs = {
		--5g7s9g8s = OBJ
	},
	PlayerNametag = {},
	OBJ_Name___ = {},
}
-- Nametags which can be seen by a certain players
local def = {
	initial_properties = {
			hp_max = 500,
			physical = false,
			collide_with_objects = false,
			collisionbox = { -0.05, -0.05, -0.05, 0.05, 0.05, 0.05 },
			selectionbox = { -0.05, -0.05, -0.05, 0.05, 0.05, 0.05, rotate = false },
			pointable = false,
			textures = {"blank.png"},
			use_texture_alpha = false,
			static_save = false,
			show_on_minimap = false,
	},
	on_step = function(self)
		local obj = self.object
		if obj then
			if obj:get_yaw() then
				if not obj:get_attach() then
					if self.ID and cs_nametag.Objs[self.ID] then
						cs_nametag.Objs[self.ID] = nil
					end
					obj:remove()
				end
			end
		end
	end,
	is_nametag = true,
	ID = nil
}
core.register_entity("cs_object_nametag:obj", def)

function cs_nametag.ApplyNametag(obj, playerslist, text)
	if Versions.Is5100 then
		local name = Name(obj)
		if name then
			if cs_nametag.OBJ_Name___[name] then
				if cs_nametag.Objs[cs_nametag.OBJ_Name___[name]] and cs_nametag.Objs[cs_nametag.OBJ_Name___[name]]:get_yaw() then
					cs_nametag.Objs[cs_nametag.OBJ_Name___[name]]:set_observers(playerslist)
					if text then
						cs_nametag.Objs[cs_nametag.OBJ_Name___[name]]:set_properties({
							nametag = text
						})
					end
				else
					cs_nametag.Objs[cs_nametag.OBJ_Name___[name]] = nil
					local object = core.add_entity(obj:get_pos(), "cs_object_nametag:obj")
					if object then
						object:set_observers(playerslist)
						object:set_properties({
							nametag = text
						})
						object:set_attach(obj, "", {x=0,y=15,z=0})
						-- Adquire a ID
						local ID = FormRandomString(4)
						-- Apply a ID to the main object
						if name then
							cs_nametag.OBJ_Name___[name] = ID
						else
							if obj:is_player() then
								cs_nametag.PlayerNametag[Name(obj)] = ID
							end
						end
						local ent_ = object:get_luaentity()
						if ent_ then
							ent_.ID = ID
						end
						--Save
						cs_nametag.Objs[ID] = object
					end
				end
			else
				local object = core.add_entity(obj:get_pos(), "cs_object_nametag:obj")
				if object then
					object:set_observers(playerslist)
					object:set_properties({
						nametag = text
					})
					object:set_attach(obj, "", {x=0,y=15,z=0})
					-- Adquire a ID
					local ID = FormRandomString(4)
					-- Apply a ID to the main object
					if name then
						cs_nametag.OBJ_Name___[name] = ID
					else
						if obj:is_player() then
							cs_nametag.PlayerNametag[Name(obj)] = ID
						end
					end
					local ent_ = object:get_luaentity()
					if ent_ then
						ent_.ID = ID
					end
					--Save
					cs_nametag.Objs[ID] = object
				end
			end
	
		end
	end
end

function cs_nametag.RemoveNametag(obj)
	if rangedweapons.Version590 then
		local ent = obj:get_luaentity()
		if ent.NametagID and cs_nametag.Objs[ent.NametagID] then
			cs_nametag.Objs[ent.NametagID]:remove()
			return true
		else
			return false
		end
	end
end