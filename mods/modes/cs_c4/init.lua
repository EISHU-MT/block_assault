--CS:MT C4 mode (Terrorist & Counters)
local modpath = core.get_modpath(minetest.get_current_modname())
c4 = {}
dofile(modpath.."/bomb_item.lua")
dofile(modpath.."/bomb_api.lua")
dofile(modpath.."/bots_ai.lua")

--Register Mode

Modes.RegisterMode("c4", {
	Info = "Don't allow reds plant the bomb! Otherwise disable it before it explodes!",
	Title = "C4",
	ConfigurationDefinition = {
		PVP_MODE = 1,
		MATCH_MAX_COUNT = 6,
		BS_CONFIG = {
			GameClass = "C4",
			EnableShopTable = true,
			AllowPlayersModifyMaps = true,
			IsDefaultGame = false,
			EnableFourTeams = false
		}
	},
	Functions = {
		IsCompatibleWithMap = function(mapdef)
			if mapdef.data and mapdef.data.bomb_areas_bool then
				return true
			else
				return false
			end
		end,
		OnJoinPlayer = function(player)
			return
		end,
		OnLeavePlayer = function(player)
			if c4.BombData.PlayerName == Name(player) then
				c4.BombData.IsDropped = true
				c4.BombData.PlayerName = nil
				c4.NotifyDroppedBomb(pos, drp:get_player_name())
				core.item_drop(ItemStack("cs_c4:bomb"), player, vector.add(player:get_pos(), vector.new(0,1,0)))
			end
		end,
		OnNewMatches = function() end,
		OnMatchStart = function()
			if c4.StaticData.Planted then
				c4.Reset()
			end
			if not c4.BombData.PlayerName then
				local players = bs.get_team_players("red")
				local idx = #players
				local rmd = math.random(1, idx)
				if players[rmd] then
					local obj = players[rmd]
					if obj:is_player() then
						c4.BombData.PlayerName = Name(obj)
						Inv(obj):add_item("main", "cs_c4:bomb")
						core.log("action", "Bomb Holder: "..Name(obj))
					else
						local n = Name(obj)
						if n then
							c4.BombData.PlayerName = n
							core.log("action", "Bomb Holder: "..n)
						end
					end
				end
			end
		end,
		OnSetMode = function() end,
		OnLoadMap = function(mapdef)
			--Make map be reliable
			core.after(1, function(mapdef)
				if mapdef.data and mapdef.data.bomb_areas_bool then
					for name, content in pairs(maps.current_map.data.bomb_areas) do
						--Apply offset
						if content.pos and content.name then
							maps.current_map.data[content.name] = vector.add(maps.current_map.offset, content.pos)
							core.log("action", "[Cs C4] Offset set to '"..content.name.."': "..core.pos_to_string(content.pos).." => "..core.pos_to_string(vector.add(maps.current_map.offset, content.pos)))
							maps.current_map.data.bomb_areas[name].pos = vector.add(maps.current_map.offset, content.pos)
						end
					end
				end
			end, mapdef)
		end,
		OnEndMatch = function()
			core.after(2, function()
				--if config.EnableBots then
					local players = bs.get_team_players("red")
					local idx = #players
					local rmd = math.random(1, idx)
					if players[rmd] then
						local obj = players[rmd]
						if obj:is_player() then
							c4.BombData.PlayerName = Name(obj)
							Inv(obj):add_item("main", "cs_c4:bomb")
							core.log("action", "Bomb Holder: "..Name(obj))
						else
							local n = Name(obj)
							if n then
								c4.BombData.PlayerName = n
								core.log("action", "Bomb Holder: "..n)
							end
						end
					end
				--end
				c4.StaticData = {
					Timer = 0,
					Pos = vector.new(),
					Player = "",
					Planted = false
				}
				-- Check inventories
				for _, p in pairs(core.get_connected_players()) do
					local inv = p:get_inventory()
					if inv then
						local name = p:get_player_name()
						if name then
							if c4.BombData.PlayerName ~= name then
								local list_data = inv:get_list("main")
								if list_data then
									for i, itemst in pairs(list_data) do
										if itemst:get_name() == "cs_c4:bomb" then
											itemst:clear()
										end
									end
									inv:set_list("main", list_data)
								end
							end
						end
					end
				end
			end)
			c4.Reset()
			c4.BombData = {
				IsDropped = false,
				PlayerName = nil,
				Dropper = nil,
				Pos = vector.new(),
			}
			for _, p in pairs(core.get_connected_players()) do
				local name = p:get_player_name()
				if c4.Huds[name] then
					p:hud_remove(c4.Huds[name])
				end
			end
			c4.BotsSupport = {
				BombHolderSelectedArea = "",
				BombHolder = "",
				AlreadySaidPhare = false,
				BotsAreaToGo = {},
				AreasChecked = {},
				StopHunterFrom = {},
				AlreadyDefusingBomb = false
			}
		end,
		BotsLogicEngine = c4.BAI
	},
})

bs.cbs.register_OnAssignTeam(function(player, team)
	if Modes.CurrentMode == "c4" then
		if team == "red" then --red is assigned as a terrorist
			if (not c4.BombData.PlayerName) and c4.BombData.IsDropped == false then
				Inv(player):add_item("main", "cs_c4:bomb")
				c4.BombData.PlayerName = Name(player)
			end
			-- Check if bomb is dropped somewhere, to add in da hud
			if c4.BombData.IsDropped then
				c4.Huds[Name(player)] = player:hud_add({
					hud_elem_type = "waypoint",
					number = 0xFF6868,
					name = "Dropped bomb is here! dropt by ".. c4.BombData.Dropper,
					text = "m",
					world_pos = c4.BombData.Pos
				})
			end
		else
			if team == "" then
				-- If hes dead and has the hud, then remove it
				if c4.Huds[Name(player)] then
					player:hud_remove(c4.Huds[Name(player)])
				end
			end
		end
	end
end)

if config.EnableBots then
	BotsCallbacks.RegisterOnKillBot(function(self)
		local name = self.bot_name
		if bots.data[name] and bots.data[name].team == "red" then
			if c4.BombData.PlayerName == name then
				-- Drop the bomb
				c4.BombData.IsDropped = true
				c4.BombData.PlayerName = nil
				c4.NotifyDroppedBomb(self.object:get_pos(), name)
				c4.BombData.Obj = core.add_item(self.object:get_pos(), ItemStack("cs_c4:bomb"))
				c4.BotsSupport.BombHolderSelectedArea = ""
				c4.BotsSupport.BombHolder = ""
			end
		end
	end)
end
















