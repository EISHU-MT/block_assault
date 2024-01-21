-- Armors, like bandage, healing, etc
Armor = {
	heal_hp = 3, -- HP heal per click.
	heal_hp_per_second = 2, -- HP heal per second
	QueuedToFullHP = {},
	Timer = 0,
}

function Armor.BandageHealToOther(_, player, pointed_thing)
	if bs.get_player_team_css(player) ~= "" then
		if pointed_thing.type == "object" then
			if pointed_thing.ref:is_player() and bs.get_player_team_css(player) == bs.get_player_team_css(pointed_thing.ref) then
				local player_hp = pointed_thing.ref:get_hp()
				if pointed_thing.ref:get_properties() then
					if player_hp == pointed_thing.ref:get_properties().hp_max then
						hud_events.new(player, {
							text = Name(pointed_thing.ref).." has full hp! ("..tostring(player_hp)..")",
							color = "warning",
							quick = true,
						})
					else
						local sum_hp = Armor.heal_hp + player_hp
						-- Check for no overhp
						if sum_hp > pointed_thing.ref:get_properties().hp_max then
							sum_hp = pointed_thing.ref:get_properties().hp_max
						end
						-- Do it.
						pointed_thing.ref:set_hp(sum_hp)
						hud_events.new(player, {
							text = "+5 score!",
							color = "info",
							quick = true,
						})
						score.add_score_to(player, 5)
					end
				end
			end
		end
	end
end

function Armor.HealPlayer(stack, player, pointed_thing)
	if bs.get_player_team_css(player) ~= "" then
		if player:get_properties() then
			if player:get_hp() ~= player:get_properties().hp_max then
				if Armor.QueuedToFullHP[Name(player)] then
					hud_events.new(player, {
						text = "Stopped healing.",
						color = "warning",
						quick = true,
					})
					Armor.QueuedToFullHP[Name(player)] = nil
				else
					hud_events.new(player, {
						text = "Healing!, stand with your medkit in your hand!",
						color = "info",
						quick = true,
					})
					Armor.QueuedToFullHP[Name(player)] = true
					stack:set_count(stack:get_count() - 1) -- By stacks, not per itemstack.
				end
			end
		end
	end
end

function Armor.OnGlobalStep(dtime)
	Armor.Timer = Armor.Timer + dtime
	if Armor.Timer >= 1 then
		for player_name, bool in pairs(Armor.QueuedToFullHP) do
			if player_name and Player(player_name) then
				local hp = Player(player_name):get_hp()
				if Player(player_name):get_properties() then
					local player_wield_item = Player(player_name):get_wielded_item()
					if player_wield_item:get_name() == "Armor:heal_pack" then
						if hp >= Player(player_name):get_properties().hp_max then
							Armor.QueuedToFullHP[player_name] = nil
							hud_events.new(Player(player_name), {
								text = "Healing Complete!",
								color = "info",
								quick = true,
							})
							Player(player_name):set_physics_override({speed=physics.speed})
						else
							local to_verify = hp + Armor.heal_hp_per_second
							local hp_to_add = 0
							if to_verify > Player(player_name):get_properties().hp_max then
								hp_to_add = Player(player_name):get_properties().hp_max
							else
								hp_to_add = to_verify
							end
							Player(player_name):set_hp(hp_to_add or 0)
							Player(player_name):set_physics_override({speed=physics.speed - 0.5})
						end
					else
						Armor.QueuedToFullHP[player_name] = nil
						hud_events.new(Player(player_name), {
							text = "Healing Failed!\nYou must need to had the healing kit in your hand!",
							color = "warning",
							quick = true,
						})
						Player(player_name):set_physics_override({speed=physics.speed})
					end
				end
			end
		end
		Armor.Timer = 0
	end
end

core.register_tool(":Armor:heal_pack", {
	stack_max = 20,
	description = "Heal kit",
	range = 0,
	inventory_image = "bandage_for_player.png",
	
	on_use = Armor.HealPlayer
})

core.register_tool(":Armor:heal_bandage", {
	stack_max = 20,
	description = "Heal bandage",
	range = 0,
	inventory_image = "bandage.png",
	
	on_use = Armor.BandageHealToOther
})

Shop.RegisterWeapon("Heal Kit", {
	item_name = "Armor:heal_pack 2",
	price = 40,
	icon = "bandage_for_player.png",
	type = "armor",
	uses_ammo = false,
})

Shop.RegisterWeapon("Heal Bandage", {
	item_name = "Armor:heal_bandage",
	price = 45,
	icon = "bandage.png",
	type = "armor",
	uses_ammo = false,
})

core.register_globalstep(Armor.OnGlobalStep)