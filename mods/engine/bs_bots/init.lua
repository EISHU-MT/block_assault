--[[
	Bots Framework For BAS
	
	This might make conflict with bs_tweaks if not good configuration.
	This will override the entire BA engine for compatibility
--]]

--Should we load bots
if not config.EnableBots then
	return
end

dofile(core.get_modpath(core.get_current_modname()).."/EntityEngine/init.lua")

local switcher = false
bots = {
	dead_bots = {},
	callbacks = {OnSpawnBots = {}, OnDieBot = {}, OnBotBuyWeapon = {}},
	weapon_location = { -- Wield item for bots
		"Arm_Right",
		{x=0, y=5.5, z=3},
		{x=-90, y=225, z=90},
		{x=0.25, y=0.25},
	},
	data = {
		--[[Example:
		Carl = {
			object = <obj> or nil,
			name = "Carl",
			weapons = {hand_weapon = "", hard_weapon = ""} -- Those things need to be string, Never use a sword!
			team = "",
			wield_item_obj = <obj or nil>
			state = "dead" or "alive"
			money = 200,
			nametag = <obj>
		}
		--]]
	},
	bots_body = {
		initial_properties = {
			name = "",
			hp_max = 20,
			physical = true,
			collide_with_objects = true,
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
			selectionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
			pointable = true,
			visual = "mesh",
			visual_size = {x = 1, y = 1, z = 1},
			mesh = "character.b3d",
			textures = "",
			colors = {},
			use_texture_alpha = false,
			is_visible = true,
			makes_footstep_sound = true,
			stepheight = 0.6,
			automatic_face_movement_dir = false,
			nametag = "",
			--infotext = "BOT "..def.bot_name,
			static_save = false,
			damage_texture_modifier = "^[brighten",
			shaded = true,
			show_on_minimap = true,
		},
		on_activate = BsEntities.OnActFunction,
		on_step = function(self, dtime, mv) BsEntities.OnSelfFunction(self, dtime, mv) bots.co_logic(self, mv) end,
		view_range = 20,
		jump_height = 1,
		max_speed = 2,
		attack={range=4, damage_groups = {fleshy = 10}},
		armor_groups = {fleshy = 100, immortal = 0},
		totaltime = 0,
	},
	bots_animations = {
		--[[Carl = { -- Animations
			stand = {x = 0, y = 79},
			lay = {x = 162, y = 166},
			walk = {x = 168, y = 187},
			mine = {x = 189, y = 198},
			walk_mine = {x = 200, y = 219},
			sit = {x = 81, y = 160},
		}--]]
	},
	favorite_weapons = {
		--[[Carl = {
			hand_weapon = "",
			hard_weapon = "",
		}--]]
	},
	modpath = core.get_modpath(core.get_current_modname()),
	wield_entity = {
		initial_properties = {
			physical = false,
			collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
			visual = "wielditem",
			textures = {"wield3d:hand"},
			pointable = false,
			wielder = nil,
			static_save = false,
		},
		holder = nil,
		wield_hand = true,
		on_step = function(self)
			local obj = self.object:get_attach()
			if obj then
				local name = Name(obj)
				if name then
					self.object:set_properties({textures = {bots.in_hand_weapon[name] or config.DefaultStartWeapon.weapon}})
				else
					self.object:remove()
				end
			else
				self.object:remove()
			end
		end,
	},
	to_2d = function(pos)
		if pos then
			return {x = pos.x, y = pos.z}
		else
			return {x=0,y=0}
		end
	end,
	restart_bots = function() -- Only in Prepare time! This just restarts the bots objects.
		for name, data in pairs(bots.data) do
			if data.object then
				data.object:remove()
				bots.data[name].object = nil
			end
			if maps.current_map and maps.current_map.teams and CountTable(maps.current_map.teams) < 4 then
				if data.team == "blue" or data.team == "red" then
					bots.data[name].object = core.add_entity(maps.current_map.teams[data.team], data.object_name)
					SpawnPlayerAtRandomPosition(bots.data[name].object, data.team)
					bots.data[name].object:set_armor_groups({fleshy=100, immortal=0})
					bots.add_nametag(bots.data[name].object, data.team, name)
					bots.restart_bot_id(data)
					bots.data[name].state = "alive"
				end
			else
				bots.data[name].object = core.add_entity(maps.current_map.teams[data.team], data.object_name)
				SpawnPlayerAtRandomPosition(bots.data[name].object, data.team)
				bots.data[name].object:set_armor_groups({fleshy=100, immortal=0})
				bots.add_nametag(bots.data[name].object, data.team, name)
				bots.restart_bot_id(data)
				bots.data[name].state = "alive"
			end
		end
	end,
	restart_bot_id = function(self)
		local id = FormRandomString(3)
		self.id = id
		self.object:get_luaentity().id = id
		bots.data[self.bot_name or self.name].id = id
	end,
	calc_dir = function(rotation)
		-- Calculate the look direction based on the rotation
		local yaw = rotation.y
		local pitch = rotation.x
		-- Calculate the components of the look direction vector
		local directionX = -math.sin(yaw) * math.cos(pitch)
		local directionY = math.sin(pitch)
		local directionZ = math.cos(yaw) * math.cos(pitch)
		-- Return the look direction as a vector
		return {x = directionX, y = directionY, z = directionZ}
	end,
}

local OnDeath = dofile(bots.modpath.."/on_death.lua")
local OnHurt = dofile(bots.modpath.."/on_hurt.lua")
dofile(bots.modpath.."/logic.lua")

dofile(bots.modpath.."/callbacks.lua")

dofile(bots.modpath.."/BAS_Overrider.lua")
dofile(bots.modpath.."/Tools.lua")
dofile(bots.modpath.."/bullet_mechanism.lua")
dofile(bots.modpath.."/Hunter.lua")
dofile(bots.modpath.."/BotsView.lua")
dofile(bots.modpath.."/movements.lua")
dofile(bots.modpath.."/chat.lua")
dofile(bots.modpath.."/match_engine_v2.lua")
dofile(bots.modpath.."/shoot_queue.lua")
dofile(bots.modpath.."/server_controller.lua")
dofile(bots.modpath.."/dead_body.lua")
dofile(bots.modpath.."/co_logic.lua")
dofile(bots.modpath.."/bots_respawner.lua")
dofile(bots.modpath.."/singleplayer_env_fixer.lua")
dofile(bots.modpath.."/get_weapon.lua")

function bots.register_bot(def)
	if def.name and def.team and def.favorite_weapons then
		bots.bots_animations[def.name] = table.copy(def.animations)
		bots.favorite_weapons[def.name] = table.copy(def.favorite_weapons)
		bots.in_hand_weapon[def.name] = config.DefaultStartWeapon.weapon
		bots.data[def.name] = {
			name = def.name,
			object = nil,
			weapons = {hand_weapon = config.DefaultStartWeapon.weapon, hard_weapon = ""},
			team = def.team,
			wield_item_obj = nil,
			object_name = "bs_bots:"..def.name,
			state = "dead",
			money = 20,
			ammo_of_weapon = {hard_weapon=0,hand_weapon=0},
			cache_weapon_to_recharge = "", -- special
		}
		local bot_body_data = table.copy(bots.bots_body)
		bot_body_data.textures = {"character.png^player_"..def.team.."_overlay.png"}
		bot_body_data.infotext = "BOT "..def.name
		bot_body_data.name = {"bs_bots:"..def.name}
		bot_body_data.bot_name = def.name
		bot_body_data.animation = {
			walk = {range = def.animations.walk, speed = def.animations.speed, loop = true},
			attack = {range = def.animations.mine, speed = def.animations.speed, loop = true},
			stand = {range = def.animations.stand, speed = def.animations.speed, loop = true}
		}
		bot_body_data.hunter = bots.GetHuntFunction
		bot_body_data.MovementAct = bots.MovementFunction
		bot_body_data.logic = Logic.OnStep
		bot_body_data.on_punch = OnHurt
		bot_body_data.on_death = OnDeath
		bot_body_data.SubMovementsQueue = {}
		bot_body_data.__time = 0
		core.register_entity("bs_bots:"..def.name, bot_body_data)
		bots.path_to[def.name] = {}
	end
end

core.register_entity("bs_bots:wield_item", bots.wield_entity)

-- NameTag

core.register_entity("bs_bots:nametag", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=2.16, y=0.18, z=2.16},
		textures = {"blank.png"},
		pointable = false,
		on_punch = function() return true end,
		physical = false,
		is_visible = true,
		backface_culling = false,
		makes_footstep_sound = false,
		static_save = false,
	},
	is_nametag = true,
	on_step = function(self)
		local attach = self.object:get_attach()
		if not attach then
			self.object:remove()
		end
	end
})

function bots.add_nametag(obj, team, name)
	-- The hiding nametag is handled by core
	if bots.data[name].nametag then
		bots.data[name].nametag:remove()
		bots.data[name].nametag = nil
	end
	if not team then return end
	
	local entity = core.add_entity(obj:get_pos(), "bs_bots:nametag")
	if entity then
		local texture = "tag_bg.png"
		local x = math.floor(134 - ((name:len() * 11) / 2))
		local i = 0
		name:gsub(".", function(char)
			local n = "_"
			if char:byte() > 96 and char:byte() < 123 or char:byte() > 47 and char:byte() < 58 or char == "-" then
				n = char
			elseif char:byte() > 64 and char:byte() < 91 then
				n = "U" .. char
			end
			texture = texture.."^[combine:84x14:"..(x+i)..",0=W_".. n ..".png"
			i = i + 11
		end)
		texture = texture.."^[colorize:"..bs.get_team_color(team, "string")..":255"
		entity:set_properties({ textures={texture} })
		entity:set_attach(obj, "", player_tags.configs.coords, {x=0, y=0, z=0})
		bots.data[name].nametag = entity
	end
end

-- Heres the magic occurs.
local function step()
	if maps.current_map and maps.current_map.teams then
		if bs_match.match_is_started == false and switcher == false then
			bots.restart_bots()
			switcher = true
			
			-- Reset all variables
			for name, d in pairs(bots.data) do
				bots.stop_hunter[name] = nil
				bots.hunting[name] = nil
				bots.CancelPathTo[name] = nil
				bots.path_finder_running[name] = nil
				d.object:set_velocity(vector.zero())
			end
		elseif bs_match.match_is_started == true then
			switcher = false
		end
	end
end

core.register_globalstep(step)

minetest.register_on_shutdown(function()
	for bot, btd in pairs(bots.data) do
		if btd and btd.object then
			btd.object:remove()
		end
	end
end)

bots.register_bot({
	name = "Claude",
	team = "blue",
	favorite_weapons = {hard_weapon = "rangedweapons:g36", hand_weapon = "rangedweapons:luger"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})

bots.register_bot({
	name = "Karl",
	team = "red",
	favorite_weapons = {hard_weapon = "rangedweapons:ak47", hand_weapon = "rangedweapons:deagle"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})

bots.register_bot({
	name = "Eugene",
	team = "red",
	favorite_weapons = {hard_weapon = "rangedweapons:m16", hand_weapon = "rangedweapons:beretta"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})

bots.register_bot({
	name = "Tsar",
	team = "blue",
	favorite_weapons = {hard_weapon = "rangedweapons:scar", hand_weapon = "rangedweapons:luger"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})

bots.register_bot({
	name = "Tiago",
	team = "red",
	favorite_weapons = {hard_weapon = "rangedweapons:ak47", hand_weapon = "rangedweapons:m1991"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})

bots.register_bot({
	name = "Juan",
	team = "blue",
	favorite_weapons = {hard_weapon = "rangedweapons:g36", hand_weapon = "rangedweapons:makarov"},
	animations = {
		stand = {x = 0, y = 79},
		lay = {x = 162, y = 166},
		walk = {x = 168, y = 187},
		mine = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit = {x = 81, y = 160},
		speed = 30
	}
})