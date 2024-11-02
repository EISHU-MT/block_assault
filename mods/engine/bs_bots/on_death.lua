bots.dead_body = {}
return function(self, killer)
	if PvpMode.Mode == 1 then
		bots.data[self.bot_name].state = "dead"
		-- clear his set
		bots.direct_walk_cancel[self.bot_name] = nil
		bots.direct_walk_data[self.bot_name] = nil
		bots.direct_walk[self.bot_name] = nil
		bots.CancelPathTo[self.bot_name] = nil
		bots.path_finder_running[self.bot_name] = nil
		bots.last_path_endpoint[self.bot_name] = nil
		bots.path_to[self.bot_name] = {}
		for n, d in pairs(bots.direct_walk_data) do
			if d.end_by_ent and d.end_by_ent == self.bot_name then
				bots.direct_walk[n] = nil
				--print("DEAD! "..n)
			end
		end
		-- Assign a space for bot.
		PlayerKills[self.bot_name].deaths = PlayerKills[self.bot_name].deaths + 1
		local killer_team = bs.get_player_team_css(killer)
		local killer_name = Name(killer)
		local killer_weapon = ""
		local image = "hand_kill.png"
		if killer:is_player() then
			killer_weapon = killer:get_wielded_item():get_name()
			if killer_team ~= bots.data[self.bot_name].team or config.PvpEngine.FriendShoot then
				bank.player_add_value(killer, 10)
				if PlayerKills[Name(killer)] and PlayerKills[Name(killer)].kills then
					PlayerKills[Name(killer)].kills = PlayerKills[Name(killer)].kills + 1
				end
				score.add_score_to(killer, 10)
				stats.kills.add_to(Name(killer))
			end
		else
			local bot_info = killer:get_luaentity()
			if bot_info then
				local name = bot_info.bot_name
				if bots.in_hand_weapon[name] then
					killer_weapon = bots.in_hand_weapon[name]
				else
					if bots.data[name].weapons.hard_weapon ~= "" then
						killer_weapon = bots.data[name].weapons.hard_weapon
					else
						killer_weapon = bots.data[name].weapons.hand_weapon
					end
				end
				bots.data[name].money = bots.data[name].money + 10
				PlayerKills[bot_info.bot_name].kills = PlayerKills[bot_info.bot_name].kills + 1
				PlayerKills[bot_info.bot_name].score = PlayerKills[bot_info.bot_name].score + 10
			end
		end
		
		if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
			core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hard_weapon))
			local data = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hard_weapon)
			if data then
				if data.ammo.uses_ammo then
					core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
				end
				bots.data[self.bot_name].weapons.hard_weapon = ""
			end
		end
		
		if bots.data[self.bot_name].weapons.hand_weapon ~= "" or bots.data[self.bot_name].weapons.hand_weapon ~= config.DefaultStartWeapon.weapon then
			core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hand_weapon))
			local data = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hand_weapon)
			if data then
				if data.ammo.uses_ammo then
					core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
				end
				bots.data[self.bot_name].weapons.hand_weapon = config.DefaultStartWeapon.weapon
			end
		end
		
		RunCallbacks(BotsCallbacks.RegisteredOnKillBot, self, killer)
		
		local player_look = self.object:get_yaw()
		local obj = core.add_entity(self.object:get_pos(), "bs_bots:__dead_body")
		obj:set_yaw(player_look)
		obj:set_properties({
			textures = self.object:get_properties().textures
		})
		obj:set_animation({x = 162, y = 166}, 15, 0)
		obj:set_acceleration(vector.new(0,-9.81,0))
		
		local hand_item = ItemStack(killer_weapon)
		local desc = hand_item:get_definition()
		if desc.RW_gun_capabilities then
				image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
		else
			if desc.inventory_image and desc.inventory_image ~= "" then
				image = desc.inventory_image
			end
		end
		
		--register chat by chance
		local rnd = math.random(1, 20)
		if rnd >= 14 then
			bots.chat(self, "send_death_message", killer_name)
		end
		
		TheEnd()
		
		if bs.get_player_team_css(killer_name) == "" then
			return
		end
		
		KillHistory.RawAdd(
			{text = killer_name, color = bs.get_team_color(bs.get_player_team_css(killer_name), "number")},
			image,
			{text = self.bot_name , color = bs.get_team_color(bots.data[self.bot_name].team, "number") or 0xFFF}
		)
		UpdateTeamHuds()
	elseif PvpMode.Mode == 2 then
		bots.data[self.bot_name].state = "dead"
		local killer_team = bs.get_player_team_css(killer)
		local killer_name = Name(killer)
		local killer_weapon = ""
		local image = "hand_kill.png"
		bots.direct_walk_cancel[self.bot_name] = nil
		bots.direct_walk_data[self.bot_name] = nil
		bots.direct_walk[self.bot_name] = nil
		bots.CancelPathTo[self.bot_name] = nil
		bots.path_finder_running[self.bot_name] = nil
		bots.last_path_endpoint[self.bot_name] = nil
		bots.path_to[self.bot_name] = {}
		for n, d in pairs(bots.direct_walk_data) do
			if d.end_by_ent and d.end_by_ent == self.bot_name then
				bots.direct_walk[n] = nil
				--print("DEAD! "..n)
			end
		end
		-- Assign a space for bot.
		PlayerKills[self.bot_name].deaths = PlayerKills[self.bot_name].deaths + 1
		if killer:is_player() then
			killer_weapon = killer:get_wielded_item():get_name()
			if killer_team ~= bots.data[self.bot_name].team or config.PvpEngine.FriendShoot then
				
				bank.player_add_value(killer, 10)
				if PlayerKills[Name(killer)] and PlayerKills[Name(killer)].kills then
					PlayerKills[Name(killer)].kills = PlayerKills[Name(killer)].kills + 1
				end
				score.add_score_to(killer, 10)
				stats.kills.add_to(Name(killer))
			end
		else
			local bot_info = killer:get_luaentity()
			if bot_info then
				local name = bot_info.bot_name
				if bots.in_hand_weapon[name] then
					killer_weapon = bots.in_hand_weapon[name]
				else
					if bots.data[name].weapons.hard_weapon ~= "" then
						killer_weapon = bots.data[name].weapons.hard_weapon
					else
						killer_weapon = bots.data[name].weapons.hand_weapon
					end
				end
				bots.data[name].money = bots.data[name].money + 10
				PlayerKills[bot_info.bot_name].kills = PlayerKills[bot_info.bot_name].kills + 1
				PlayerKills[bot_info.bot_name].score = PlayerKills[bot_info.bot_name].score + 10
			end
		end
		
		RunCallbacks(BotsCallbacks.RegisteredOnKillBot, self, killer)
		
		local hand_item = ItemStack(killer_weapon)
		local desc = hand_item:get_definition()
		local s = 1.5
		if desc.RW_gun_capabilities then
				image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
			s = 1
		else
			if desc.inventory_image and desc.inventory_image ~= "" then
				image = desc.inventory_image
			end
		end
		
		local player_look = self.object:get_yaw()
		local obj = core.add_entity(self.object:get_pos(), "bs_bots:__dead_body")
		obj:set_yaw(player_look)
		obj:set_properties({
			textures = {"character.png^player_"..bots.data[self.bot_name].team.."_overlay.png"}
		})
		obj:set_animation({x = 162, y = 166}, 15, 0)
		obj:set_acceleration(vector.new(0,-9.81,0))
		bots.dead_body[self.bot_name] = obj
		
		KillHistory.RawAdd(
			{text = killer_name, color = bs.get_team_color(bs.get_player_team_css(killer_name), "number")},
			image,
			{text = self.bot_name , color = bs.get_team_color(bots.data[self.bot_name].team, "number") or 0xFFF},
			s
		)
		
		if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
			core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hard_weapon))
			local data = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hard_weapon)
			if data then
				if data.ammo.uses_ammo then
					core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
				end
				bots.data[self.bot_name].weapons.hard_weapon = ""
			end
		end
		
		if bots.data[self.bot_name].weapons.hand_weapon ~= "" and bots.data[self.bot_name].weapons.hand_weapon ~= config.DefaultStartWeapon.weapon then
			core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hand_weapon))
			local data = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hand_weapon)
			if data then
				if data.ammo.uses_ammo then
					core.add_item(CheckPos(self.object:get_pos()), ItemStack(data.ammo.type.." "..data.ammo.count))
				end
				bots.data[self.bot_name].weapons.hand_weapon = config.DefaultStartWeapon.weapon
			end
		end
		
		core.after(6, function(self)
			bots.data[self.bot_name].state = "alive"
			local obj = core.add_entity(maps.current_map.teams[bots.data[self.bot_name].team], bots.data[self.bot_name].object_name)
			bots.restart_bot_id(obj:get_luaentity())
			bots.data[self.bot_name].object = obj
			SpawnPlayerAtRandomPosition(bots.data[self.bot_name].object, bots.data[self.bot_name].team)
			bots.data[self.bot_name].object:set_armor_groups({fleshy=100, immortal=0})
			bots.add_nametag(bots.data[self.bot_name].object, bots.data[self.bot_name].team, self.bot_name)
			bots.direct_walk_cancel[self.bot_name] = nil
			bots.direct_walk_data[self.bot_name] = nil
			bots.direct_walk[self.bot_name] = nil
			bots.CancelPathTo[self.bot_name] = nil
			bots.path_finder_running[self.bot_name] = nil
			bots.path_to[self.bot_name] = {}
			bots.last_path_endpoint[self.bot_name] = nil
			UpdateTeamHuds()
			if bots.dead_body[self.bot_name] then
				bots.dead_body[self.bot_name]:remove()
				bots.dead_body[self.bot_name] = nil
			else
				bots.dead_body[self.bot_name] = nil
			end
			self.object:remove()
		end, self)
	end
end