-- Stats for cs:mt
local start = config.EnableStatsForPlayers
local storage = core.get_mod_storage("bs_stats")

if start ~= true then
	core.log("warning", "Stats is disabled, the current kills of players & players deaths will dont be saved!")
	return
end

stats = {
	deaths = {
		add_to = function(player)
			if player and player ~= "" then
				local strs =  core.deserialize(storage:get_string("deaths"))
				if not strs[player] then
					strs[player] = 0
				end
				strs[player] = strs[player] + 1
				local sr = core.serialize(strs)
				storage:set_string("deaths", sr)
			end
		end,
	},
	kills = {
		add_to = function(player)
			if player and player ~= "" then
				local strs =  core.deserialize(storage:get_string("kills"))
				if not strs[player] then
					strs[player] = 0
				end
				strs[player] = strs[player] + 1
				local sr = core.serialize(strs)
				storage:set_string("kills", sr)
			end
		end,
	},
	player = {
		calculate_kd = function(player)
			local function empty() end
			if player and player ~= "" then empty() else return 0 end
			local kill = core.deserialize(storage:get_string("kills"))
			local death = core.deserialize(storage:get_string("deaths"))
			local kn = kill[player] or 0
			local dn = death[player] or 0
			local to_return = kn / dn or 0
			return to_return or 0
		end,
		get_deaths = function(player)
			local function empty() end
			if player and player ~= "" then empty() else return 0 end
			local death = core.deserialize(storage:get_string("deaths"))
			local dn = death[player] or 0
			return dn
		end,
		get_kills = function(player)
			local function empty() end
			if player and player ~= "" then empty() else return 0 end
			local kill = core.deserialize(storage:get_string("kills"))
			local kn = kill[player] or 0
			return kn
		end,
	},
}

-- If storage dont had saved the kills and deaths, this starts a new table with `__null`
do
	local strs = storage:get_string("kills")
	if strs == "" or strs == " " or strs == nil then
		local newtable = {
					__null = 0
				}
		local sr = core.serialize(newtable)
		storage:set_string("kills", sr)
	end
	strs = storage:get_string("deaths")
	if strs == "" or strs == " " or strs == nil then
		local newtable = {
					__null = 0
				}
		local sr = core.serialize(newtable)
		storage:set_string("deaths", sr)
	end
end

PvpCallbacks.RegisterFunction(function(data)
	local victim = Name(data.died)
	local killer = Name(data.killer)
	if victim and victim ~= "" then
		stats.deaths.add_to(victim)
		if type(data.killer) == "userdata" and data.killer:is_player() and killer and killer ~= "" then
			stats.kills.add_to(killer)
		end
	end
end, "BA.S Stats engine")
-- Commands

--[[
	{
		params = "<name> <privilege>",  -- Short parameter description
		description = "Remove privilege from player",  -- Full description
		privs = {privs=true},  -- Require the "privs" privilege to run
		func = function(name, param),
	}
--]]

s = core.chat_send_player
c = core.colorize

local rank_definition = {
		params = "<name>",
		description = "Get rank of a player or yourself",
		func = function(name, param)
			if param and param ~= "" then
				local kn = stats.player.get_kills(param)
				local dn = stats.player.get_deaths(param)
				local kd = stats.player.calculate_kd(param)
				local ss = score.get_score_of(param) or "-!-"
				local n = tostring
				
				if kn and dn and kd and ss then
					-- correct
				else
					--core.chat_send_player(name, "Something Failed for that request :/ !")
					SendError(name, "Something Failed for that request :/ !\nMaybe you arent in the BA database.")
					return
				end
				
				s(name, c("#42BE00", "=====Player  Stats====="))
				s(name, c("#42BE00", "Kills: ")..c("#FF3A3A", n(kn)))
				s(name, c("#42BE00", "Deaths: ")..c("#FF3A3A", n(dn)))
				s(name, c("#42BE00", "K/D: ")..c("#FF3A3A", n(kd)))
				s(name, c("#42BE00", "Score: ")..c("#FF3A3A", n(ss)))
				s(name, c("#42BE00", "==End of Player Stats=="))
			else
				local kn = stats.player.get_kills(name)
				local dn = stats.player.get_deaths(name)
				local kd = stats.player.calculate_kd(name)
				local ss = score.get_score_of(name) or "-!-"
				local n = tostring
				
				if kn and dn and kd and ss then
					-- correct
				else
					--core.chat_send_player(name, "Something Failed for that request :/ !")
					SendError(name, "Something Failed for that request :/ !\nMaybe you arent in the BA database.")
					return
				end
				
				s(name, c("#42BE00", "=====Player  Stats====="))
				s(name, c("#42BE00", "Kills: ")..c("#FF3A3A", n(kn)))
				s(name, c("#42BE00", "Deaths: ")..c("#FF3A3A", n(dn)))
				s(name, c("#42BE00", "K/D: ")..c("#FF3A3A", n(kd)))
				s(name, c("#42BE00", "Score: ")..c("#FF3A3A", n(ss)))
				s(name, c("#42BE00", "==End of Player Stats=="))
			end
		end,
	}

minetest.register_chatcommand("r", rank_definition)
minetest.register_chatcommand("rank", rank_definition)
























