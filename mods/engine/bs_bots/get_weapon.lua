function bots.GetWeaponForBot(self, bot_weaponHARD, weapon, obj, typo)
	if self and bot_weaponHARD and weapon and obj and typo then
		core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons[typo]))
		local data = table.copy(bot_weaponHARD)
		if data then
			if data.ammo.uses_ammo then
				core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
			end
		end
		bots.data[self.bot_name].weapons[typo] = weapon.item_name
		bots.data[self.bot_name].ammo_of_weapon[typo] = rangedweapons.weapons_data[weapon.item_name].ammo_full
		obj:remove()
		Logic.SwitchBotsFunctions(self, false)
	elseif self and weapon and obj and typo then
		bots.data[self.bot_name].weapons[typo] = weapon.item_name
		bots.data[self.bot_name].ammo_of_weapon[typo] = rangedweapons.weapons_data[weapon.item_name].ammo_full
		obj:remove()
		Logic.SwitchBotsFunctions(self, false)
	end
end
--[[
function bots.GetWeaponForSoft(self, bot_weaponSOFT, weapon, obj)
	if self and bot_weaponSOFT and weapon and obj then
		core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hand_weapon))
		local data = table.copy(bot_weaponSOFT)
		if data then
			if data.ammo.uses_ammo then
				core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
			end
			bots.data[self.bot_name].weapons.hand_weapon = weapon.item_name
			bots.data[self.bot_name].ammo_of_weapon.hand_weapon = rangedweapons.weapons_data[weapon.item_name].ammo
			obj:remove()
			Logic.SwitchBotsFunctions(self, false)
		end
	elseif self and weapon and obj then
		
	end
end--]]
BsEntities.AddFunctionForStepPerBot(function(self, mv)
	if self.object and self.object:get_yaw() then
		if bs_match.match_is_started then
			for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), 12)) do
				if obj:get_luaentity() and obj:get_luaentity().itemstring then
					--print("####88")
					--if not LOCKED then
					if not Logic.OBJ_to_get[self.bot_name] then
						-- It should be a rifle
						local enemydir = vector.round(bots.calc_dir(self.object:get_rotation()))
						local botdir = vector.round(vector.direction(self.object:get_pos(), obj:get_pos()))
						--print("###0")
						if math.acos(enemydir.x*botdir.x + enemydir.y*botdir.y + enemydir.z*botdir.z) <= math.pi/3 then
							--print("DID IT")
							local weapon = Shop.IdentifyWeapon(obj:get_luaentity().itemstring)
							if weapon then
								local value = weapon.price
								if weapon.type == "shotgun" or weapon.type == "rifle" then
									--print("##1")
									local bot_weaponHARD = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hard_weapon)
									if bot_weaponHARD then
										if value >= bot_weaponHARD.price then
											if not Logic.OBJ_to_get[self.bot_name] then
												Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hard_weapon", weapon = weapon}
												Logic.SwitchBotsFunctions(self, true)
											else
												if not BsEntities.IsEntityAlive(Logic.OBJ_to_get[self.bot_name].obj) then
													Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hard_weapon", weapon = weapon}
													Logic.SwitchBotsFunctions(self, true)
												end
											end
										end
									else
										if not Logic.OBJ_to_get[self.bot_name] then
											Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hard_weapon", weapon = weapon}
											Logic.SwitchBotsFunctions(self, true)
										else
											if not BsEntities.IsEntityAlive(Logic.OBJ_to_get[self.bot_name].obj) then
												Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hard_weapon", weapon = weapon}
												Logic.SwitchBotsFunctions(self, true)
											end
										end
									end
							elseif weapon.type == "pistol" or weapon.type == "smg" then
									local bot_weaponSOFT = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hand_weapon)
									if bot_weaponSOFT then
										if value >= bot_weaponSOFT.price then
											if not Logic.OBJ_to_get[self.bot_name] then
												Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hand_weapon", weapon = weapon}
												Logic.SwitchBotsFunctions(self, true)
											else
												if not BsEntities.IsEntityAlive(Logic.OBJ_to_get[self.bot_name].obj) then
													Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hand_weapon", weapon = weapon}
													Logic.SwitchBotsFunctions(self, true)
												end
											end
										end
									else
										if not Logic.OBJ_to_get[self.bot_name] then
											--print("AHHH")
											Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hand_weapon", weapon = weapon}
											Logic.SwitchBotsFunctions(self, true)
										else
											if not BsEntities.IsEntityAlive(Logic.OBJ_to_get[self.bot_name].obj) then
												Logic.OBJ_to_get[self.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name, typo = "hand_weapon", weapon = weapon}
												Logic.SwitchBotsFunctions(self, true)
											end
										end
									end
								end
							end
						end
					end
				end
			end
			if not bots.FunctionOfDisabledMovements[self.bot_name] then
				if Logic.OBJ_to_get[self.bot_name] then
					bots.chat(self, "going_to_get_weapon")
					bots.FunctionOfDisabledMovements[self.bot_name] = function(self)
						if Logic.OBJ_to_get[self.bot_name] then
							if Logic.OBJ_to_get[self.bot_name].obj:get_luaentity() then
								--if value >= bot_weaponSOFT.price then
									local obj = Logic.OBJ_to_get[self.bot_name].obj
									if core.line_of_sight(self.object:get_pos(), obj:get_pos()) then
										if vector.distance(self.object:get_pos(), obj:get_pos()) > 1.3 then
											local dir = vector.direction(CheckPos(self.object:get_pos()), obj:get_pos())
											BsEntities.TurnToYaw(self, core.dir_to_yaw(dir), 10)
											BsEntities.AdvanceHorizontal(self, self.max_speed * 1.6)
											BsEntities.AnimateEntity(self, "walk")
											--Logic.OBJ_to_get[self.object.bot_name] = {obj = obj, price = value, itemstring = weapon.item_name}
										else
											local typo = Logic.OBJ_to_get[self.bot_name].typo
											local bot_weapon = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons[typo])
											bots.GetWeaponForBot(self, bot_weapon, Logic.OBJ_to_get[self.bot_name].weapon, obj, typo)
											bots.chat(self, "got_weapon")
										end
									end
								--end
							else
								Logic.OBJ_to_get[self.bot_name] = nil
								bots.FunctionOfDisabledMovements[self.bot_name] = nil
								bots.DontCareAboutMovements[self.bot_name] = nil
								return true
							end
						else
							bots.FunctionOfDisabledMovements[self.bot_name] = nil
							bots.DontCareAboutMovements[self.bot_name] = nil
							return true
						end
					end
				end
			elseif bots.DontCareAboutMovements[self.bot_name] then
				if Logic.OBJ_to_get[self.bot_name] then
					local obj = Logic.OBJ_to_get[self.bot_name].obj
					if not obj:get_luaentity() then
						Logic.OBJ_to_get[self.bot_name] = nil
						bots.DontCareAboutMovements[self.bot_name] = nil
						bots.FunctionOfDisabledMovements[self.bot_name] = nil
					end
				end
			end
		else
			--if mv.collides then
			--	for _, d in pairs(mv.collisions) do
			--		if d.type == "object" then
				for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), 1.4)) do
					if obj:get_luaentity() and obj:get_luaentity().itemstring then
						--local obj = d.ref
						--if obj:get_luaentity() and obj:get_luaentity().itemstring then
							local weapon = Shop.IdentifyWeapon(obj:get_luaentity().itemstring)
							if weapon then
								local bot_weapon = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons[weapon.type])
								if bot_weapon and bot_weapon ~= "" then
									if weapon.price > bot_weapon.price then
										bots.GetWeaponForBot(self, bot_weapon, weapon, obj, weapon.type)
										bots.chat(self, "got_weapon")
									end
								elseif not bot_weapon then
									bots.GetWeaponForBot(self, nil, weapon, obj, weapon.type)
									bots.chat(self, "got_weapon")
								end
							end
						--end
					end
				end
					--end
				--end
			--end
		end
	end
end)