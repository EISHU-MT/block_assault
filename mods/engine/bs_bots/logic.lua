--[[
	Bot Brain
--]]

bbp = {}
Logic = {}
loaded_bots = {} -- Need to flush when a match starts

bots.logics = {} -- a, b, c

function bbp.WhileOnPrepareTime(self)
	local LuaEntity = self
	if self and self.bot_name and (self.object and self.object:get_yaw()) and LuaEntity and LuaEntity.bot_name and bots.data[LuaEntity.bot_name] then
		-- Check if this script is runned
		if not loaded_bots[LuaEntity.bot_name] then
			--Set PlayerKills table
			if not PlayerKills[self.bot_name] then
				PlayerKills[self.bot_name] = {kills = 0, deaths = 0, score = 0}
			end
			loaded_bots[LuaEntity.bot_name] = true
			-- Load All Data!
			local Money = bots.data[LuaEntity.bot_name].money
			local FavoriteWeapons = table.copy(bots.favorite_weapons[LuaEntity.bot_name])
			local BotName = LuaEntity.bot_name
			local Object = self.object
			-- We should do buy weapons
			local HardWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hard_weapon)
			local HandWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hand_weapon)
			local HardUsedWeapon = bots.data[self.bot_name].hard_weapon
			local HandUsedWeapon = bots.data[self.bot_name].hand_weapon
			if HardWeaponData and HandWeaponData then
				-- Buy Hard Weapon
				if HardWeaponData.item_name ~= HardUsedWeapon then
					if HardWeaponData.price <= Money then
						if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
							local WeaponData = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hard_weapon)
							if WeaponData and WeaponData.price < HardWeaponData.price then
								core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hard_weapon))
								bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HardWeaponData.price
								bots.data[self.bot_name].weapons.hard_weapon = HardWeaponData.item_name
								--local ammo = ItemStack(HardWeaponData.item_name):get_definition().RW_gun_capabilities.suitable_ammo[1][2] -- ammo
								bots.data[self.bot_name].ammo_of_weapon.hard_weapon = 0--ammo
								core.log("action", "Bot "..BotName.." did buy: "..HardWeaponData.item_name)
							end
						else
							local ammo = ItemStack(HardWeaponData.item_name):get_definition().RW_gun_capabilities.suitable_ammo[1][2] -- ammo
							bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HardWeaponData.price
							bots.data[self.bot_name].weapons.hard_weapon = HardWeaponData.item_name
							bots.data[self.bot_name].ammo_of_weapon.hard_weapon = ammo
							core.log("action", "Bot "..BotName.." did buy: "..HardWeaponData.item_name)
						end
					end
				end
				-- Buy Soft Weapon
				if HandWeaponData.item_name ~= HandUsedWeapon then
					if HandWeaponData.price <= Money then
						if bots.data[self.bot_name].weapons.hand_weapon ~= "" then
							local WeaponData = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hand_weapon)
							if WeaponData and WeaponData.price < HandWeaponData.price then
								core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hand_weapon))
								--local ammo = ItemStack(HandWeaponData.item_name):get_definition().RW_gun_capabilities.suitable_ammo[1][2]
								bots.data[self.bot_name].ammo_of_weapon.hand_weapon = 0--ammo
								bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HandWeaponData.price
								bots.data[self.bot_name].weapons.hand_weapon = HandWeaponData.item_name
								core.log("action", "Bot "..BotName.." did buy: "..HandWeaponData.item_name)
							end
						else
							--bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HandWeaponData.price
							--bots.data[self.bot_name].weapons.hard_weapon = HandWeaponData.item_name
							--core.log("action", "Bot "..BotName.." did buy: "..HandWeaponData.item_name)
						end
					else
						--might set up all
						if bots.data[self.bot_name].weapons.hand_weapon ~= "" then
							--set up his default weapon if not hading one
							bots.data[self.bot_name].weapons.hand_weapon = config.DefaultStartWeapon.weapon
						end
					end
				end
			else
				error("A bot was registered without weapons data!\nData:\nBotName: "..BotName)
			end
			-- Prepare any visual thing for Bot
			-- First of all, Wield Item (Uses wield3d API)
			if bots.data[BotName].wield_item_obj then
				bots.data[BotName].wield_item_obj:remove()
				bots.data[BotName].wield_item_obj = nil
			end
			local WieldObject = core.add_entity(Object:get_pos(), "bs_bots:wield_item")
			local WieldObjectEntity = WieldObject:get_luaentity()
			WieldObjectEntity.holder = self.bot_name
			bots.data[BotName].wield_item_obj = WieldObject
			WieldObject:set_attach(Object, "Arm_Right", {x=0, y=5.5, z=3}, {x=-90, y=225, z=90})
			local to_be_seen = ""
			if bots.data[BotName].weapons.hard_weapon ~= "" then
				to_be_seen = bots.data[BotName].weapons.hard_weapon
			else
				to_be_seen = bots.data[BotName].weapons.hand_weapon
			end
			WieldObject:set_properties({
				textures = {to_be_seen or "wield3d:hand"},
				visual_size = {x=0.25, y=0.25},
			})
			-- Prepare Nametag
			bots.add_nametag(Object, bots.data[BotName].team, BotName)
			self.object:set_animation(bots.bots_animations[self.bot_name].stand, bots.bots_animations[self.bot_name].anispeed, 0)
			
		end
	else
		core.log("error", "~BS BOTS: Unknown Object Found!")
	end
end

local C = CountTable

function Logic.Shoot(self, obj)
	if not (obj:is_player() or obj:get_yaw()) then
		return
	end
	local name = self.bot_name
	if bots.path_finder_running[self.bot_name] then
		bots.data[name].object:set_animation(bots.bots_animations[name].walk_mine, bots.bots_animations[name].anispeed, 0)
	else
		bots.data[name].object:set_animation(bots.bots_animations[name].mine, bots.bots_animations[name].anispeed, 0)
	end
	local to_use = ""
	local typew = "hard_weapon"
	if bots.data[name].weapons.hard_weapon and bots.data[name].weapons.hard_weapon ~= "" then
		to_use = bots.data[name].weapons.hard_weapon
		typew = "hard_weapon"
	elseif bots.data[name].weapons.hand_weapon and bots.data[name].weapons.hand_weapon ~= "" then
		to_use = bots.data[name].weapons.hand_weapon
		typew = "hand_weapon"
	else 
		to_use = "rangedweapons:glock17"
	end
	local itemstack = ItemStack(to_use)
	if itemstack and itemstack ~= "" and itemstack:get_name() ~= "" then
		if not bots.queue_shot[name] then
			bots.in_hand_weapon[self.bot_name] = to_use
			if bots.data[self.bot_name].ammo_of_weapon[typew] > 0 then
				local from = bots.to_2d(self.object:get_pos())
				local to = bots.to_2d(obj:get_pos())
				local offset_to = {
					x = to.x - from.x,
					y = to.y - from.y
					}
				
				local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
				
				local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage
				local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
				local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
				local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
				bots.shoot(1, damage or {fleshy=5}, "bs_bots:bullet", sound, velocity, self, obj)
				bots.data[self.bot_name].ammo_of_weapon[typew] = bots.data[self.bot_name].ammo_of_weapon[typew] - 1
				if cooldown then
					bots.queue_shot[name] = cooldown
				else
					bots.queue_shot[name] = 0.4
				end
				if bots.data[name].wield_item_obj then
					bots.data[name].wield_item_obj:set_properties({
						textures = {itemstack:get_name()},
						visual_size = {x=0.25, y=0.25},
					})
				end
				self.object:set_yaw(dir)
			else
				if not bots.currently_recharging_gun[self.bot_name] then -- dont recharge multiple times at the same second
					Logic.DoReloadGun(self, typew)
				end
			end
		end
	else
		bots.in_hand_weapon[name] = "default:sword_steel"
		bots.queue_shot[name] = 0.4
		bots.data[self.bot_name].wield_item_obj:set_properties({
			textures = {"default:sword_steel"},
			visual_size = {x=0.25, y=0.25},
		})
	end
end

bots.currently_recharging_gun = {}

function Logic.DoReloadGun(self, typ)
	local gun = bots.data[self.bot_name].weapons[typ]
	local item = ItemStack(gun)
	if item and item:get_name() ~= "" then
		if not bots.currently_recharging_gun[self.bot_name] then
			bots.data[self.bot_name].cache_weapon_to_recharge = item:get_definition().RW_gun_capabilities.gun_unloaded
			self.cooldown = item:get_definition().RW_gun_capabilities.gun_reload
			bots.currently_recharging_gun[self.bot_name] = true
			Logic.QueueReloadGun(self, typ)
			if item:get_definition().RW_gun_capabilities.gun_magazine ~= nil then
				local pos = self.object:get_pos()
				local dir = bots.calc_dir(self.object:get_rotation())--player:get_look_dir()
				local yaw = self.object:get_yaw()--player:get_look_horizontal()
				if pos and dir and yaw then
					pos.y = pos.y + 1.4
					local obj = minetest.add_entity(pos,"rangedweapons:mag")
					if obj then
						obj:set_properties({textures = {item:get_definition().RW_gun_capabilities.gun_magazine}})
						obj:set_velocity({x=dir.x*2, y=dir.y*2, z=dir.z*2})
						obj:set_acceleration({x=0, y=-5, z=0})
						obj:set_rotation({x=0,y=yaw,z=0})
					end
				end
			end
		end
	end
end

function Logic.QueueReloadGun(self, type_of_gun)
	local func = function(self) -- return true
		if not self.cooldown then
			self.cooldown = 0
		end
		self.cooldown = self.cooldown - self.dtime
		if self.cooldown < 0 then
			self.cooldown = 0
		end
		if self.cooldown <= 0 then
			if bots.data[self.bot_name].cache_weapon_to_recharge and bots.data[self.bot_name].cache_weapon_to_recharge ~= "" then
				local item = ItemStack(bots.data[self.bot_name].cache_weapon_to_recharge)
				if item and item:get_name() ~= "" then
					if item:get_definition().loaded_gun ~= nil then
						local itemstack = ItemStack(bots.data[self.bot_name].cache_weapon_to_recharge)
						if item:get_definition().loaded_sound ~= nil then
								minetest.sound_play(itemstack:get_definition().loaded_sound, {
								pos = self.object:get_pos(),
								gain = 0.5,
								max_hear_distance = 32
							})
						end
						if item:get_definition().loaded_gun then
							bots.data[self.bot_name].cache_weapon_to_recharge = item:get_definition().loaded_gun
						end
					end
					if item:get_definition().rw_next_reload ~= nil then
						local itemstack = ItemStack(bots.data[self.bot_name].cache_weapon_to_recharge)
						if itemstack:get_definition().load_sound ~= nil then
							minetest.sound_play(itemstack:get_definition().load_sound, {pos=self.object:get_pos(), gain=0.6, max_hear_distance=32})
						end
						if ItemStack(bots.data[self.bot_name].weapons[type_of_gun]):get_definition() and ItemStack(bots.data[self.bot_name].weapons[type_of_gun]):get_definition().RW_gun_capabilities then
							self.cooldown = ItemStack(bots.data[self.bot_name].weapons[type_of_gun]):get_definition().RW_gun_capabilities.gun_reload
						end
						bots.data[self.bot_name].cache_weapon_to_recharge = item:get_definition().rw_next_reload or bots.data[self.bot_name].weapons[type_of_gun]
					end
				end
				if bots.data[self.bot_name].cache_weapon_to_recharge == bots.data[self.bot_name].weapons[type_of_gun] then
					bots.data[self.bot_name].ammo_of_weapon[type_of_gun] = ItemStack(bots.data[self.bot_name].weapons[type_of_gun]):get_definition().RW_gun_capabilities.suitable_ammo[1][2]
					self.cooldown = nil
					bots.data[self.bot_name].cache_weapon_to_recharge = nil
					bots.currently_recharging_gun[self.bot_name] = nil
					bots.chat(self, "recharged_weapon")
					return true
				end
			end
		end
	end
	BsEntities.QueueFunction(self, func)
end

function Logic.DoShootProcess(self)
	if not self.chance_to_shoot then self.chance_to_shoot = 20 end
	if self.detected_enemies then
		for _, obj in pairs(self.detected_enemies) do
			if Name(obj) == bots.hunting[self.bot_name] then
				Logic.Shoot(self, obj)
			else
				if math.random(1, self.chance_to_shoot) >= 14 then
					Logic.Shoot(self, obj)
				end
			end
		end
	end
end

function Logic.ReturnAliveEnemies(tablee)
	local enemies = {}
	for _, o in pairs(tablee) do
		if bots.is_enemy_alive(o) then
			table.insert(enemies, o)
		end
	end
	return enemies
end

bots.DontCareAboutMovements = {}
function Logic.SwitchBotsFunctions(self, boolean)
	if (boolean == true) or (boolean == false) then
		bots.DontCareAboutMovements[self.bot_name] = boolean
		return
	end
	local bool = bots.DontCareAboutMovements[self.bot_name]
	if not bool then
		bots.DontCareAboutMovements[self.bot_name] = true
	else
		bots.DontCareAboutMovements[self.bot_name] = nil
	end
end


Logic.OBJ_to_get = {}
function Logic.OldOnStep(self)
	if bs_match.match_is_started then
		if self and self.object and self.object:get_yaw() then
			loaded_bots = {}
			-- Hunt logic
			if self.isonground then
				if not bots.hunting[self.bot_name] then
					if C(maps.current_map.teams) > 2 then
						local team_enemies = bs.enemy_team(bots.data[self.bot_name].team)
						if team_enemies and C(team_enemies) >= 1 then
							local selected = team_enemies[1]
							if selected and bs.team[selected].state == "alive" then
								local enemies = Logic.ReturnAliveEnemies(bs.get_team_players(selected))
								local enemy = enemies[math.random(1, C(enemies))]
								if enemy then
									bots.Hunt(self, enemy)
								end
							end
						end
					else
						local team_enemy = bs.enemy_team(bots.data[self.bot_name].team)
						if team_enemy and team_enemy ~= "" and bs.team[team_enemy].state == "alive" then
							local enemies = Logic.ReturnAliveEnemies(bs.get_team_players(team_enemy))
							local enemy = enemies[math.random(1, C(enemies))]
							if enemy then
								bots.Hunt(self, enemy)
							end
						end
					end
				end
			end
			-- In Bot View logic
			local detected = {}
			for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range)) do
				if Name(obj) and Name(obj) ~= self.bot_name then
					if vector.distance(obj:get_pos(), self.object:get_pos()) < 10 or ((vector.distance(obj:get_pos(), self.object:get_pos())/2) <= math.random(1, vector.distance(obj:get_pos(), self.object:get_pos()))) then
						--print("success")
						if obj:get_luaentity() and obj:get_luaentity().bot_name and obj:get_luaentity().bot_name ~= self.bot_name then -- Make sure that is not the scanning bot
							if --[[(vector.distance(obj:get_pos(), self.object:get_pos()) < 2 and vector.distance(obj:get_pos(), self.object:get_pos()) > 0) or--]] bots.is_in_bot_view(self, obj) then
								if obj:get_luaentity() and obj:get_luaentity().bot_name then
									local enemydir = vector.round(bots.calc_dir(self.object:get_rotation()))
									local botdir = vector.round(vector.direction(self.object:get_pos(), obj:get_pos()))
									if math.acos(enemydir.x*botdir.x + enemydir.y*botdir.y + enemydir.z*botdir.z) <= math.pi/3 then
										if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
											table.insert(detected, obj)
											--print("Added "..Name(obj))
										end
									end
								end
							end
						elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then--bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team
							if --[[(vector.distance(obj:get_pos(), self.object:get_pos()) < 2 and vector.distance(obj:get_pos(), self.object:get_pos()) > 0) or--]] bots.is_in_bot_view(self, obj) then
								local enemydir = vector.round(bots.calc_dir(self.object:get_rotation()))
								local botdir = vector.round(vector.direction(self.object:get_pos(), obj:get_pos()))
								if math.acos(enemydir.x*botdir.x + enemydir.y*botdir.y + enemydir.z*botdir.z) <= math.pi/3 then
									if bots.is_enemy_alive(obj) then
										if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
											table.insert(detected, obj)
										end
									end
								end
							end
						end
					end
				end
			end
			-- In Bot Weapons
			local ent = self.object:get_luaentity()
			ent.detected_enemies = detected -- Shoot on logic will dont be supported anymore
		else
			core.log("warning", "Unknown bot info - the bot might got deleted on Logic Function")
		end
	end
end

--Logic.BotsData = {} -- Avoid more than 1 bot per registered bot

--for bn in pairs(bots.data) do
--	Logic.BotsData[bn] = {}
--end

Logic.Clock = {}

function Logic.OnStep(self)
	if not (maps.current_map and maps.current_map.teams) then return end
	if self then
		if not Logic.Clock[self.bot_name] then Logic.Clock[self.bot_name] = 0 end
		Logic.Clock[self.bot_name] = Logic.Clock[self.bot_name] + self.dtime
		if Logic.Clock[self.bot_name] >= 0.5 then
			if Modes.Modes[Modes.CurrentMode] and Modes.Modes[Modes.CurrentMode].TeamsSkinsTextures and Modes.Modes[Modes.CurrentMode].TeamsSkinsTextures[bots.data[self.bot_name].team] then
				-- Set skins according to mode
				self.object:set_properties({textures = {Modes.Modes[Modes.CurrentMode].TeamsSkinsTextures[bots.data[self.bot_name].team]}})
			end
			if self.id ~= bots.data[self.bot_name].id then
				self.object:remove()
			end
			if bs_match.match_is_started then
				if BotsLogicFunction then
					BotsLogicFunction(self)
				else
					Logic.OldOnStep(self)
				end
			else
				bbp.WhileOnPrepareTime(self)
				bots.CancelPathTo[self.bot_name] = true
				local bot_pos = self.object:get_pos()
				if bot_pos then
					if vector.distance(bot_pos, maps.current_map.teams[bots.data[self.bot_name].team]) > 3 then
						self.object:set_velocity(vector.new(0,0,0))
					end
					local from = bots.to_2d(self.object:get_pos())
					local to = bots.to_2d(maps.current_map.teams[bots.data[self.bot_name].team])
					local offset_to = {
						x = to.x - from.x,
						y = to.y - from.y
					}
					local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
					self.object:set_yaw(dir)
				end
				-- Make bot recharge his gun
				local hard_recharged = false
				if time >= 4 and time <= 5 then
					-- recharge first weapon, the massive
					if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
						if bots.data[self.bot_name].ammo_of_weapon.hard_weapon and bots.data[self.bot_name].ammo_of_weapon.hard_weapon <= 0 then
							hard_recharged = true
							Logic.DoReloadGun(self, "hard_weapon")
						end
					end
				end
				if (time >= 3 and time <= 4) or (hard_recharged == false and time <= 5) then
					-- now the soft weapon
					if bots.data[self.bot_name].ammo_of_weapon.hand_weapon and bots.data[self.bot_name].ammo_of_weapon.hand_weapon <= 0 then
						Logic.DoReloadGun(self, "hand_weapon")
					end
				end
			end
			Logic.Clock[self.bot_name] = 0
		else
			if not bs_match.match_is_started then
				bbp.WhileOnPrepareTime(self)
				bots.CancelPathTo[self.bot_name] = true
				local bot_pos = self.object:get_pos()
				if bot_pos then
					if vector.distance(bot_pos, maps.current_map.teams[bots.data[self.bot_name].team]) > 3 then
						self.object:set_velocity(vector.new(0,0,0))
					end
					local from = bots.to_2d(self.object:get_pos())
					local to = bots.to_2d(maps.current_map.teams[bots.data[self.bot_name].team])
					local offset_to = {
						x = to.x - from.x,
						y = to.y - from.y
					}
					local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
					self.object:set_yaw(dir)
				end
			end
		end
	end
end



