player_tags = {
	objs_modern = {},
	objs_classic = {},
	configs = {
		coords = {x=0, y=18, z=0},
	},
	empty = function() end,
	objs_status = {},
	funcs = {
		hide = function(user)
			if not user then return false end
			local player = Player(user)
			if player and player_tags.objs_classic[player:get_player_name()] and (player_tags.objs_status[player:get_player_name()] ~= true) then
				player_tags.objs_classic[player:get_player_name()]:set_properties({is_visible = false,})
				return true
			end
		end,
		show = function(user)
			if not user then return false end
			local player = Player(user)
			if player and player_tags.objs_classic[player:get_player_name()] and (player_tags.objs_status[player:get_player_name()] == true) then
				player_tags.objs_classic[player:get_player_name()]:set_properties({is_visible = true,})
				return true
			end
		end,
		return_status = function(user)
			if user and Player(user) then player_tags.empty() else return false end
			return player_tags.objs_status[Player(user):get_player_name()] or false
		end,
		modernise_nametag_of_player = function(obj, player)
			local player = Player(player)
			if bs_match.match_is_started then
				local RifleWeaponName = Shop.GetPlayerWeaponByType(player, "rifle") or {name=""}
				local PistolWeaponName = Shop.GetPlayerWeaponByType(player, "pistol") or {name=""}
				obj:set_nametag_attributes({
					text = Name(player).."\n$"..bank.return_val(Name(player)).."\n"..RifleWeaponName.name.."~"..PistolWeaponName.name,
					color = 0x9CFFFF,
				})
			else
				local RifleWeaponName = Shop.GetPlayerWeaponByType(player, "rifle") or {name=""}
				local PistolWeaponName = Shop.GetPlayerWeaponByType(player, "pistol") or {name=""}
				local concatenate_two_string = ""
				if RifleWeaponName.name ~= "" and PistolWeaponName.name ~= "" then
					concatenate_two_string = "~"
				end
				obj:set_nametag_attributes({
					text = Name(player).."\n"..RifleWeaponName.name..concatenate_two_string..PistolWeaponName.name,
					color = 0x9CFFFF,
				})
			end
		end
	},
}

minetest.register_entity("bs_playertag:name", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=2.16, y=0.18, z=2.16},
		textures = {"invisible.png"},
		pointable = false,
		on_punch = function() return true end,
		physical = false,
		is_visible = true,
		backface_culling = false,
		makes_footstep_sound = false,
		static_save = false,
	},
	timer = 0,
	on_step = function(self, dt)
		self.timer = self.timer + dt
		if self.timer >= 1 then
			local attached = self.object:get_attach()
			if not attached then
				self.object:remove()
			else
				if config.TypeOfPlayerTag then --  Classic
					self.object:set_nametag_attributes({text = ""})
				else -- Modern
					local attached_team = bs.get_player_team_css(attached)
					local players = bs.get_team_players(attached_team)
					local pname = Name(attached)
					players[pname] = nil
					self.object:set_observers(players)
					player_tags.funcs.modernise_nametag_of_player(self.object, players)
				end
			end
			self.timer = 0
		end
	end,
	is_nametag = true
})

minetest.register_entity("bs_playertag:name_tag", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=2.16, y=0.18, z=2.16},
		textures = {"invisible.png"},
		pointable = false,
		on_punch = function() return true end,
		physical = false,
		is_visible = true,
		backface_culling = false,
		makes_footstep_sound = false,
		static_save = false,
	},
	timer = 0,
	on_step = function(self, dt)
		self.timer = self.timer + dt
		if self.timer >= 0.1 then
			local attached = self.object:get_attach()
			if not attached then
				self.object:remove()
			else
			--	if config.TypeOfPlayerTag then --  Classic
					if bs.is_playing[Name(attached)] then
						if bs.spectator[Name(attached)] then
							self.object:remove()
						end
					else
						self.object:remove()
					end
					--print("EXEC")
					local pname = Name(attached)
					if RespawnDelay.players[pname] then
						self.object:set_properties({is_visible = false})
					else
						self.object:set_properties({is_visible = true})
					end
				--end
			end
			self.timer = 0
		end
	end,
	is_nametag = true
})

local function add(player, team)
	-- The hiding nametag is handled by core
	if not team then return end
	--local modern_entity = core.add_entity(Player(player):get_pos(), "bs_playertag:name") -- Modern
	local entity = core.add_entity(Player(player):get_pos(), "bs_playertag:name_tag") -- Classic
	local texture = "tag_bg.png"
	local x = math.floor(134 - ((player:get_player_name():len() * 11) / 2))
	local i = 0
	player:get_player_name():gsub(".", function(char)
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
	entity:set_attach(player, "", player_tags.configs.coords, {x=0, y=0, z=0})
	local luaent = entity:get_luaentity()
	luaent.team = bs.get_player_team_css(player)
	luaent.attachedto = player:get_player_name()
	player_tags.objs_classic[player:get_player_name()] = entity
	--player_tags.objs_modern[player:get_player_name()] = modern_entity
end

local function on_leave_player(player)
	if player and type(player_tags.objs_classic[player:get_player_name()]) == "userdata" then
		player_tags.objs_classic[player:get_player_name()]:remove()
		player_tags.objs_classic[player:get_player_name()] = nil
	end
end

local function on_join_team(name, team)
	local player = Player(name)
	if player and type(player_tags.objs_classic[name]) == "userdata" then
		player_tags.objs_classic[name]:remove()
		player_tags.objs_classic[name] = nil
	end
	if name and (team == "" or not team) then
		on_leave_player(player) -- Delete nametag.
	elseif name and team ~= "" then
		add(player, team)
	end
end

local last_team = {}

local steps = 0

local function on_step(dt)
	steps = steps + dt
	if steps >= 0.5 then
		for _, player in pairs(core.get_connected_players()) do
			
			player:set_nametag_attributes({
				text = " ",
				bgcolor = {a=0},
				color = {a=0},
			})
			
			local objs = player:get_children()
			local selected_obj
			for _, obj in pairs(objs) do
				local ent = obj:get_luaentity()
				if ent then
					if ent.is_nametag then
						selected_obj = obj
						break
					end
				end
			end
			if not selected_obj then
				if bs.spectator[Name(player)] ~= true and bs.is_playing[Name(player)] then
					add(player, bs.get_team(player))
				end
			else
				if bs.spectator[Name(player)] then
					selected_obj:remove()
				end
			end
		end
		steps = 0
	end
end

local function DoFixNametags()
	for _, p in pairs(core.get_connected_players()) do
		local name = Name(p)
		local team = bs.get_player_team_css(name)
		if team ~= "" then
			add(p, team)
		end
	end
end

local function ResetAllNametags()
	for name, obj in pairs(player_tags.objs_classic) do
		player_tags.objs_classic[name]:remove()
		player_tags.objs_classic[name] = nil
	end
	core.after(1, DoFixNametags)
end

--core.register_on_joinplayer(on_join_player)
core.register_on_leaveplayer(on_leave_player)
bs_match.register_OnEndMatch(ResetAllNametags)
bs.cbs.register_OnAssignTeam(on_join_team)


