player_tags = {
	objs = {},
	configs = {
		coords = {x=0, y=18, z=0},
	},
	empty = function() end,
	objs_status = {},
	funcs = {
		hide = function(user)
			if not user then return false end
			local player = Player(user)
			if player and player_tags.objs[player:get_player_name()] and (player_tags.objs_status[player:get_player_name()] ~= true) then
				player_tags.objs[player:get_player_name()]:set_properties({is_visible = false,})
				return true
			end
		end,
		show = function(user)
			if not user then return false end
			local player = Player(user)
			if player and player_tags.objs[player:get_player_name()] and (player_tags.objs_status[player:get_player_name()] == true) then
				player_tags.objs[player:get_player_name()]:set_properties({is_visible = true,})
				return true
			end
		end,
		return_status = function(user)
			if user and Player(user) then player_tags.empty() else return false end
			return player_tags.objs_status[Player(user):get_player_name()] or false
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
	is_nametag = true
})

local function add(player, team)
	-- The hiding nametag is handled by core
	if not team then return end
	
	local entity = core.add_entity(Player(player):get_pos(), "bs_playertag:name")
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
	luaent.attachedto = player:get_player_name()
	player_tags.objs[player:get_player_name()] = entity
end

local function on_leave_player(player)
	if player and type(player_tags.objs[player:get_player_name()]) == "userdata" then
		player_tags.objs[player:get_player_name()]:remove()
		player_tags.objs[player:get_player_name()] = nil
	end
end

local function on_join_team(name, team)
	if name and (team == "" or not team) then
		on_leave_player(Player(name)) -- Delete nametag.
	elseif name and team ~= "" then
		add(Player(name), team)
	end
end

local function on_step()
	for _, player in pairs(core.get_connected_players()) do
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
		if selected_obj then
			if bs.spectator[Name(player)] then
				selected_obj:remove()
			end
		else
			if bs.spectator[Name(player)] ~= true and bs.is_playing[Name(player)] then
				add(player, bs.get_team(player))
			end
		end
	end
end

--core.register_on_joinplayer(on_join_player)
core.register_globalstep(on_step)
core.register_on_leaveplayer(on_leave_player)
--bs.cbs.register_OnAssignTeam(on_join_team)


