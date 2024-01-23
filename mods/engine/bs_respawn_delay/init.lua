-- When PvP mode is '2' then respawn delay should be enabled
-- WARNING: THIS MOD HAS SOME CODE FROM CAPTURE THE FLAG - GAME
local respawn_timer = config.RespawnTimer or 6
local hud = mhud.init()
RespawnDelay = {
	players_respawn_timer = {},
	players_ticks = {},
	players_obj = {},
	players = {},
}
minetest.register_entity("bs_respawn_delay:attach", {
	is_visible = false,
	physical = false,
	makes_footstep_sound = false,
	backface_culling = false,
	static_save = false,
	pointable = false,
	on_punch = function() return true end,
})
function RespawnDelay.DoRespawnDelay(player)
	player = Player(player)
	local name = Name(player)
	if not RespawnDelay.players[name] then
		hud:add(name, "timer_of_respawn", {
			hud_elem_type = "text",
			position = {x = 0.5, y = 0.5},
			alignment = {x = "center", y = "center"},
			text_scale = 3,
			color = 0xA000B3,
		})
		player:hud_set_flags({
			hotbar = false,
			wielditem = false,
			crosshair = false
		})
		RespawnDelay.players[name] = true
		player:set_properties({hp_max = 0})
		DoPhysics[Name(player)] = {jump=0,speed=0,gravity=0}
		local obj = minetest.add_entity(player:get_pos(), "bs_respawn_delay:attach")
		if obj then
			player:set_attach(obj)
			RespawnDelay.players_obj[name] = obj
		end
		core.after(0.3, function(name) minetest.close_formspec(name, "") end, name)
		RespawnDelay.players_respawn_timer[name] = respawn_timer
		RespawnDelay.players_ticks[name] = 0 -- no global ticks on 1 variable
	end
end
function RespawnDelay.RespawnPlayer(player)
	if RespawnDelay.players[Name(player)] then
		RespawnDelay.players[Name(player)] = nil
		if RespawnDelay.players_obj[Name(player)] then
			RespawnDelay.players_obj[Name(player)]:remove()
		end
		RespawnDelay.players_ticks[Name(player)] = nil
		RespawnDelay.players_respawn_timer[Name(player)] = nil
		hud:remove(Name(player), "timer_of_respawn")
		player:set_properties({hp_max = 20, pointable = true})
		player:set_hp(20)
		player:set_armor_groups({immortal=0,fleshy=100})
		DoPhysics[Name(player)] = nil
		player:hud_set_flags({
			hotbar = true,
			wielditem = true,
			crosshair = true
		})
		--if bs.get_team_force(name) then
		--	SpawnPlayerAtRandomPosition(Player(name), bs.get_team_force(name))
		--end
		if bs.get_team_force(player) then
			bs.allocate_to_team(player, bs.get_team_force(player), true, false, true)
			core.after(0.1, function(player)
				SpawnPlayerAtRandomPosition(player, bs.get_team_force(player))
			end, player)
		end
	end
end
core.register_globalstep(function(tick)
	if PvpMode.Mode == 2 then
		for pname in pairs(RespawnDelay.players) do
			RespawnDelay.players_ticks[pname] = RespawnDelay.players_ticks[pname] + tick
			if RespawnDelay.players_ticks[pname] >= 1 then
				RespawnDelay.players_respawn_timer[pname] = RespawnDelay.players_respawn_timer[pname] - 1
				if RespawnDelay.players_respawn_timer[pname] > 0 then
					if hud:exists(pname, "timer_of_respawn") then
						hud:change(pname, "timer_of_respawn", {
							text = string.format("Respawning in %ds", RespawnDelay.players_respawn_timer[pname]),
							color = bs.get_team_color(bs.get_team_force(pname), "number")
						})
						--Player(pname):set_armor_groups({immortal=1})
					end
				else
					RespawnDelay.RespawnPlayer(Player(pname))
					--Player(pname):set_properties({hp_max = 20, pointable = true})
					--Player(pname):set_hp(20)
				end
				RespawnDelay.players_ticks[pname] = 0
			end
		end
	end
end)

core.register_on_respawnplayer(function(player)
	return true
end)

core.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	if RespawnDelay.players[pname] then
		RespawnDelay.players[Name(player)] = nil
		if RespawnDelay.players_obj[Name(player)] then
			RespawnDelay.players_obj[Name(player)]:remove()
		end
		RespawnDelay.players_ticks[Name(player)] = nil
		RespawnDelay.players_respawn_timer[Name(player)] = nil
		player:set_properties({hp_max = 20, pointable = true})
		player:set_hp(20)
		DoPhysics[Name(player)] = nil
	end
end)