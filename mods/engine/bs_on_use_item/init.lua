--NiSep9
-- On Use Item --
bs.latest_used_item = {}
core.log("action", "Loading B.A. OnUse Overrider")
-- Latest used item, to get itemstring, prevent use of player:get_wieldhand_item()
--on_use = function(itemstack, user, pointed_thing)
core.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_items) do
		if name:match("rangedweapons") and not (name:match("_r") or name:match("_u")) then
			if def.on_use then
				local old_onuse = def.on_use
				local function parasite_function(item, user, INF)
					bs.latest_used_item[Name(user)] = item:get_name()
					old_onuse(item, user, INF)
				end
				def.on_use = parasite_function
				core.registered_items[name] = def
				core.log("action", "OverRegistering (Item:"..name..") [OnUse Override]")
			else
				local function parasite_function(item, user, INF)
					bs.latest_used_item[Name(user)] = item:get_name()
				end
				def.on_use = parasite_function
				core.registered_items[name] = def
				core.log("action", "OverRegistering (Item:"..name..") [OnUse Inject]")
			end
		end
		if name:match("sword_") then
			local function parasite_function(item, user, INF)
				bs.latest_used_item[Name(user)] = item:get_name()
			end
			def.on_use = parasite_function
			core.registered_items[name] = def
			core.log("action", "OverRegistering (Item:"..name..") [OnUse Inject]")
		end
	end
end)

function OverrideOnUse(itemName)
	if core.registered_items[itemName] then
		if core.registered_items[itemName].on_use then
			local def = core.registered_items[itemName]
			local old = core.registered_items[itemName].on_use
			local function parasite_function(item, user, INF)
				bs.latest_used_item[Name(user)] = item:get_name()
				old_onuse(item, user, INF)
			end
			def.on_use = parasite_function
			core.registered_items[name] = def
		else
			local def = core.registered_items[itemName]
			local function parasite_function(item, user, INF)
				bs.latest_used_item[Name(user)] = item:get_name()
			end
			def.on_use = parasite_function
			core.registered_items[name] = def
		end
	end
end

