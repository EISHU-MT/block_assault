------------------
--     INIT     --
------------------

Shop = {
	RegisteredWeapons = {
		smg = {},
		pistol = {},
		shotgun = {},
		rifle = {},
		armor = {},
		sword = {},
	},
	PlayersFormspecActions = {},
	PlayersSelectedWeapon = {},
	Callbacks = {
		OnBuyWeapon = {}
	}
}

------------------
--      API     --
------------------

function Shop.RegisterOnBuyWeapon(func) table.insert(Shop.Callbacks.OnBuyWeapon, func) end

----
--  Formspecs
----
function Shop.ShowFormspec(money)
	return "formspec_version[6]" ..
		"size[14,6.25]" ..
		"box[0,0;8.6,0.6;#FFFFFF]" ..
		"label[0.2,0.3;Shop]" ..
		"box[8.6,0;5.4,0.6;#00DB00]" ..
		"label[8.7,0.3;Money: "..tostring(money).."$]" ..
		"button[0.2,0.8;12,0.8;rifle;Rifles & Snipers]" ..
		"button[0.2,1.7;12,0.8;shotgun;Shotguns]" ..
		"button[0.2,2.6;12,0.8;pistol;Pistols]" ..
		"button[0.2,3.5;12,0.8;armor;Misc & Armor]" ..
		"button[0.2,4.4;12,0.8;smg;Smg]" ..
		"button[0.2,5.3;12,0.8;sword;Swords]" ..
		"button_exit[12.3,0.8;1.6,5.3;quit;Exit]"
end

function Shop.ShowBuyingFormspec(menu_name, money, weapons, index, selected_weapon_data)
	if not selected_weapon_data then
		selected_weapon_data = {
			icon = "blank.png",
			name = "No weapon",
			price = 0
		}
	end
	return "formspec_version[6]" ..
		"size[15,8]" ..
		"box[0,0;10.4,0.5;#FFFFFF]" ..
		"label[0.1,0.2;"..menu_name.."]" ..
		"box[10.4,0;4.7,0.5;#00FF00]" ..
		"label[10.5,0.2;Money: "..tostring(money).."$]" ..
		"textlist[0.2,1.2;8,5.7;weapons;"..table.concat(weapons, ",")..";"..tostring(index)..";false]" ..
		"label[3.4,0.9;Weapons]" ..
		"image[8.5,1.2;3.3,2.6;"..selected_weapon_data.icon.."]" ..
		"label[8.5,4.2;Weapon: "..selected_weapon_data.name.."]" ..
		"label[8.5,4.9;Price: "..tostring(selected_weapon_data.price).."$]" ..
		"button_exit[0.2,7;7.2,0.8;back;Back]" ..
		"button_exit[7.6,7;7.2,0.8;exit;Exit]" ..
		"button[8.5,5.3;6.3,1.4;buy;Buy]"
end

function Shop.ShowBuyFormspec(player, index, menu_name, type_of_guns, override)
	if player then
		local init_table = Shop.GetWeaponsByType(type_of_guns)
		if not index then index = 1 end
		if override then
			Shop.PlayersFormspecActions[Name(player)] = type_of_guns
		end
		core.show_formspec(Name(player), "shop:shop_menu", Shop.ShowBuyingFormspec((menu_name or TransformTextReadable(Shop.PlayersFormspecActions[Name(player)].."s")), bank.return_val(player), init_table, index, Shop.RegisteredWeapons[type_of_guns][index]))
	end
end

----
-- API+
----

function Shop.RegisterWeapon(name, specs)
	if name and specs then
		if Shop.RegisteredWeapons[name] then
			core.log("error", "[BA.S Shop Engine] Could not register \""..name.."\", that appears registered")
			return false
		end
		if Shop.RegisteredWeapons[specs.type] then
			table.insert(Shop.RegisteredWeapons[specs.type], {
				item_name = specs.item or specs.item_name,
				name = name,
				stype = specs.stype or "",
				count_limit = specs.limit or 1,
				exec_on_buy = specs.exec_on_buy or nil,
				price = specs.price or specs.cost,
				icon = specs.icon or specs.texture or ItemStack(specs.item or specs.item_name):get_description().inventory_image,  -- Useful for kill history
				type = specs.type, -- Maybe its smg, shotgun, sword, etc
				ammo = {uses_ammo = specs.uses_ammo, type = specs.ammo_item_string, count = specs.ammo_item_count},
			})
		else
			core.log("error", "[BA.S Shop Engine] Type not found \""..tostring(specs.type).."\"")
			return false
		end
		return true
	else
		core.log("error", "[BA.S Shop Engine] Invalid use of Shop.RegisterWeapon!")
		return false
	end
	return false
end

function Shop.IdentifyWeapon(item_or_name) -- Should be name of the weapon or itemstring
	for typo, data in pairs(Shop.RegisteredWeapons) do
		for index, weapon_data in pairs(data) do
			if weapon_data.name == item_or_name or weapon_data.item_name == item_or_name then
				return weapon_data
			end
		end
	end
	return nil
end

function Shop.GetWeaponsByType(type_to_scan)
	local weapons = table.copy(Shop.RegisteredWeapons[type_to_scan])
	local to_return = {}
	for _, weapon in pairs(weapons) do
		table.insert(to_return, weapon.name)
	end
	return to_return
end

function Shop.GetPlayerWeaponByType(player, type_to_scan)
	local inv = Inv(player)
	if inv and type_to_scan then
		for i, itemstack in pairs(Inv(player):get_list("main")) do
			local item_name = itemstack:get_name()
			local detected_weapon = Shop.IdentifyWeapon(item_name)
			if detected_weapon and detected_weapon.type == type_to_scan then
				return detected_weapon
			end
		end
	end
end

local function get_bombs_count_from_inventory(player)
	local count = 0
	for i, itemstack in pairs(Inv(player):get_list("main")) do
		local item_name = itemstack:get_name()
		if item_name == "grenades:frag" or item_name == "grenades:frag_sticky" or item_name == "grenades:flashbang" or item_name == "bs_molotov:molotov" then
			count = count + itemstack:get_count()
		end
	end
	return count
end

function Shop.BuyWeaponFor(player, weapon_data)
	-- Do check to dont crash game...
	if not player then
		return false
	end
	if not weapon_data then
		return false
	end
	-- First of all, resolve the player info
	player = Player(player)
	local name = Name(player)
	-- Get player balance
	local money = bank.return_val(player)
	-- Check if theres any script on the weapon (It might is armor or misc item)
	if weapon_data.exec_on_buy then
		if money >= weapon_data.price then
			weapon_data.exec_on_buy(player)
			bank.rm_player_value(player, weapon_data.price)
			return true
		end
	end
	-- Proceed to check if theres other weapon with the same class
	local detected_conflict_weapon
	local decline_buy_act
	for i, itemstack in pairs(Inv(player):get_list("main")) do
		local item_name = itemstack:get_name()
		local detected_weapon = Shop.IdentifyWeapon(item_name)
		if detected_weapon and detected_weapon.stype and detected_weapon.stype == "grenade" then
			if (get_bombs_count_from_inventory(player)) >= config.LimitForBombsCount then
				decline_buy_act = true
				Send(player, "[Shop] You reached bombs limit.", "red")
				break
			end
		elseif detected_weapon and detected_weapon.type == weapon_data.type then
			detected_conflict_weapon = detected_weapon
		end
	end
	-- Now drop the weapon
	if decline_buy_act ~= true and money >= weapon_data.price then
		if detected_conflict_weapon then
			core.item_drop(ItemStack(detected_conflict_weapon.item_name), player, player:get_pos())
			Inv(player):remove_item("main", ItemStack(detected_conflict_weapon.item_name))
			if detected_conflict_weapon.ammo.uses_ammo then
				local bool, _, count = FindItem(detected_conflict_weapon.ammo.type)
				if bool then
					if count and detected_conflict_weapon.ammo.count and count > detected_conflict_weapon.ammo.count then
						count = detected_conflict_weapon.ammo.count
					end
					core.item_drop(ItemStack(detected_conflict_weapon.ammo.type.." "..tostring(count)), player, player:get_pos())
					Inv(player):remove_item("main", ItemStack(detected_conflict_weapon.ammo.type.." "..tostring(count)))
				end
			end
		end
		
		-- Proceed to buy the weapon
		Inv(player):add_item("main", ItemStack(weapon_data.item_name))
		if weapon_data.ammo.uses_ammo then
			Inv(player):add_item("main", ItemStack(weapon_data.ammo.type.." "..tostring(weapon_data.ammo.count)))
		end
		Send(player, "-"..tostring(weapon_data.price).."$, From buying "..weapon_data.name, "#00FF00")
		bank.rm_player_value(player, weapon_data.price, true)
		RunCallbacks(Shop.Callbacks.OnBuyWeapon, player, weapon_data)
		return true
	end
	return false
end

function Shop.GetWeapon(item, player, data)
	player = Player(player)
	local name = Name(player)
	local weapon_data = Shop.IdentifyWeapon(item:get_name())
	
	local detected_conflict_weapon
	for i, itemstack in pairs(Inv(player):get_list("main")) do
		local item_name = itemstack:get_name()
		local detected_weapon = Shop.IdentifyWeapon(item_name)
		if weapon_data and detected_weapon and detected_weapon.type == weapon_data.type then
			detected_conflict_weapon = detected_weapon
			break
		end
	end
	
	if detected_conflict_weapon then
		core.item_drop(ItemStack(detected_conflict_weapon.item_name), player, player:get_pos())
		Inv(player):remove_item("main", ItemStack(detected_conflict_weapon.item_name))
		if detected_conflict_weapon.ammo.uses_ammo then
			local bool, _, count = FindItem(detected_conflict_weapon.ammo.type)
			if bool and count and count > detected_conflict_weapon.ammo.count then
				count = detected_conflict_weapon.ammo.count
			end
			core.item_drop(ItemStack(detected_conflict_weapon.ammo.type.." "..tostring(count)), player, player:get_pos())
			Inv(player):remove_item("main", ItemStack(detected_conflict_weapon.ammo.type.." "..tostring(count)))
		end
	end
	--return item -- 6845
	data.ref:remove()
	Inv(player):add_item("main", item)
end

------------------
--     Nodes    --
------------------

minetest.register_node("bs_shop:trading_table", {
	description = "Trading Table",
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.4, -0.5, -0.4, -0.3, 0.4, -0.3 }, -- foot 1
			{ 0.3, -0.5, -0.4, 0.4, 0.4, -0.3 }, -- foot 2
			{ -0.4, -0.5, 0.3, -0.3, 0.4, 0.4 }, -- foot 3
			{ 0.3, -0.5, 0.3, 0.4, 0.4, 0.4 }, -- foot 4
			{ -0.5, 0.4, -0.5, 0.5, 0.5, 0.5 } -- table top
		}
	},
	sunlight_propagates = true,
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	drop = "",
	groups = {immortal=1},
	-- Functions
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_team(name) ~= "" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
})


------------------
-- Formspecs F. --
------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "shop:main" then
		if fields.rifle then
			Shop.ShowBuyFormspec(player, nil, "Rifles", "rifle", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.rifle[1]
		elseif fields.shotgun then
			Shop.ShowBuyFormspec(player, nil, "Shotguns", "shotgun", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.shotgun[1]
		elseif fields.sword then
			Shop.ShowBuyFormspec(player, nil, "Swords", "sword", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.sword[1]
		elseif fields.smg then
			Shop.ShowBuyFormspec(player, nil, "Smg", "smg", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.smg[1]
		elseif fields.armor then
			Shop.ShowBuyFormspec(player, nil, "Armors", "armor", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.armor[1]
		elseif fields.pistol then
			Shop.ShowBuyFormspec(player, nil, "Pistols", "pistol", true)
			Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons.pistol[1]
		end
	elseif formname == "shop:shop_menu" then
		if fields.back then
			if bs_match.match_is_started == false or not bs_match.match_is_started then
				core.show_formspec(Name(player), "shop:main", Shop.ShowFormspec(bank.return_val(player)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
				core.close_formspec(Name(player), "shop:shop_menu")
			end
		elseif fields.weapons then
			local data = core.explode_textlist_event(fields.weapons)
			if data.index then
				if data.index < 1 then
					data.index = 1
				end
				Shop.ShowBuyFormspec(player, data.index, nil, Shop.PlayersFormspecActions[Name(player)])
				Shop.PlayersSelectedWeapon[Name(player)] = Shop.RegisteredWeapons[Shop.PlayersFormspecActions[Name(player)]][data.index]
			end
		elseif fields.buy then
			local data = core.explode_textlist_event(fields.weapons)
			if data.index < 1 then
				data.index = 1
			end
			Shop.BuyWeaponFor(player, Shop.PlayersSelectedWeapon[Name(player)])
			Shop.ShowBuyFormspec(player, data.index, nil, Shop.PlayersFormspecActions[Name(player)])
		end
	end
end)

--[[
-- Example for rifles registering!

Shop.RegisterWeapon("Diamond Sword", {
	item_name = "default:sword_diamond",
	price = 100,
	icon = "default_wood.png",
	type = "sword",
	uses_ammo = false, -- SEE UP LINES!
})
--]]

local function get_sword_price(sword)
	if sword == "default:sword_diamond" then
		return 300
	elseif sword == "default:sword_mese" then
		return 250
	elseif sword == "default:sword_steel" then
		return 200
	elseif sword == "default:sword_bronze" then
		return 200
	elseif sword == "default:sword_stone" then
		return 150
	elseif sword == "default:sword_wood" then
		return 100
	end
end

local function on_load()
	for name, def in pairs(core.registered_tools) do
		if name:find("default:sword") then
			core.registered_tools[name] = def --core.override_item(name, def)
			
			-- Register!
			
			Shop.RegisterWeapon(def.description, {
				item_name = name,
				price = get_sword_price(name),
				icon = def.inventory_image,
				type = "sword",
				uses_ammo = false,
			})
		end
	end
end

local ticks = 0

local function on_prepare_all_map()
	if maps.current_map and maps.current_map.teams then
		for _, data in pairs(maps.current_map.teams) do
			core.set_node(data, {name="bs_shop:trading_table"})
		end
	end
end

local function on_step(dt)
	if config.EnableShopTable then
		ticks = ticks + dt
		if ticks >= 0.4 then
			on_prepare_all_map()
			ticks = 0
		end
	end
end

core.register_globalstep(on_step)

--maps.register_on_load(on_prepare_all_map)
core.register_on_mods_loaded(on_load)

-- Add more ammo to players
bs_match.register_OnEndMatch(function()
	for _, player in pairs(core.get_connected_players()) do
		for _, typo in pairs({"smg", "pistol", "shotgun", "rifle"}) do
			local weapon = Shop.GetPlayerWeaponByType(player, typo)
			if weapon and weapon.ammo then
				if weapon.ammo.uses_ammo then
					if Inv(player) then
						local ammo_item = ItemStack(weapon.ammo.type.." "..weapon.ammo.count)
						Inv(player):add_item("main", ammo_item)
					end
				end
			end
		end
	end
end)















