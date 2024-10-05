-- CS:MT MODES
Modes = {
	Modes = {
		Classic = {
			Info = "Kill to win the match! Don't allow your enemy stand alive",
			Title = "Hunt 'N' Kill",
			ConfigurationDefinition = {
				PVP_MODE = 1,
				MATCH_MAX_COUNT = 6,
				BS_CONFIG = {
					EnableShopTable = true,
					AllowPlayersModifyMaps = false,
					IsDefaultGame = true
				}
			},
			Functions = {
				IsCompatibleWithMap = function(mapdef)
					return true --Always return true if mode is compatible with every map, used in bs_maps
				end,
				OnJoinPlayer = function(player)
					-- do nothing
				end,
				OnLeavePlayer = function(player)
					--nothing
				end,
				OnNewMatches = function()
				end,
				OnMatchStart = function()
				end,
				OnSetMode = function()
				end,
				BotsLogicEngine = nil, -- Don't touch it until u want to apply a special func.
			},
		},
	},
	ModesSTRING = {
		["Hunt 'N' Kill"] = "Classic",
	},
	CurrentMode = "",
	Formspecs = {
		ReturnSelectMode = function(modename, modeinfo, list, idx)
			return "formspec_version[9]" ..
				"size[10,8]" ..
				"hypertext[3,0.1;6,3;a;<style color=#00CCAA size=30>Select Mode</style>]" ..
				"hypertext[5.5,2;4.3,4;a;<style size=20>" ..
				"<center>"..modename.."</center>"..
				"<center><normal>"..modeinfo.."</normal>" ..
				"</center>" ..
				"</style>]" ..
				"style_type[button;bgcolor=#006699]" ..
				"textlist[0.2,1;5,5.8;MODE;"..list..";"..idx..";false]" ..
				"style[ABSTAIN;bgcolor=red;textcolor=yellow]" ..
				"button_exit[0.2,7;9.7,0.9;ABSTAIN;Abstain;]" ..
				"button_exit[5.4,1;4.5,0.9;SELECT;Select;]"
		end
	},
	Votes = {
		--[[
		Classic = 12
		Abstains = 1
		CaptureTheFlag = 23
		--]]
		Abstains = 0
	},
	PlayersVoting = {
		--Time Out some players
		--Catars = 7s (max) [when a step of a second occurs in server, player vote time is reaching timeout: DTIME_PER_SEC % 1]
		--else if the player has reachen 0 then: the value will be a boolean, false
	},
	-- Make sure if the time when a player joins is vote time
	CurrentlyVoting = false,
	PlayersCurrentSelectedMode = {
		--Catars = TECHNICALNAME:"Classic"
	},
	ModesTableTitle = {}, --cache
	LastTimerState = false,
}

function Modes.SetMode(modename_t)
	if Modes.Modes[modename_t] then
		Modes.CurrentMode = modename_t
		if Modes.Modes[modename_t].Functions.OnSetMode then
			Modes.Modes[modename_t].Functions.OnSetMode()
		end
		-- Now set some custom settings
		local cfg = table.copy(Modes.Modes[modename_t].ConfigurationDefinition)
		if cfg.PVP_MODE then
			PvpMode.Mode = cfg.PVP_MODE
			if cfg.PVP_MODE == 3 then
				PvpMode.ThirdModeFunction = Modes.Modes[modename_t].Function.ThirdModeFunction
			end
		end
		if cfg.MATCH_MAX_COUNT then
			bs_match.rounds = cfg.MATCH_MAX_COUNT
		end
		if cfg.BS_CONFIG then
			for conf, value in pairs(cfg,BS_CONFIG) do
				config[conf] = value
			end
		end
		if Modes.Modes[modename_t].Functions.BotsLogicEngine then
			BotsLogicFunction = Modes.Modes[modename_t].Functions.BotsLogicEngine
		end
	end
end

--[[
	# IGNORE #
	Hacer que el menu de elejir equipo este en ult orden que el menu de votos si el jugador se une
	Hacer que el jugador apenas se una sea pre-espectador
	==
	Written by a 15years old guy
--]]

function Modes.DoVotes()
	--Declare that we're voting
	Modes.LastTimerState = config.DisableTimer
	config.DisableTimer = true
	Modes.CurrentlyVoting = true
	-- Reset timer
	time = default_timer
	--Get modes for voting
	for name, data in pairs(Modes.Modes) do
		table.insert(Modes.ModesTableTitle, data.Title)
	end
	--Prepare tables
	for name in pairs(Modes.Modes) do
		Modes.Votes[name] = 0
	end
	Modes.Votes.Abstains = 0
	--Show to players
	if next(core.get_connected_players()) then
		for _, p in pairs(core.get_connected_players()) do
			local name = p:get_player_name()
			Modes.PlayersCurrentSelectedMode[name] = Modes.ModesSTRING[Modes.ModesTableTitle[1]]
			core.show_formspec(name, "MODES:VOTE", Modes.Formspecs.ReturnSelectMode(Modes.ModesTableTitle[1], Modes.Modes[Modes.ModesSTRING[Modes.ModesTableTitle[1]]].Info, table.concat(Modes.ModesTableTitle, ","), 1))
			Modes.PlayersVoting[p:get_player_name()] = 7
		end
	else
		core.after(0.1, function()
			Modes.CommenceMatchWithSelectedMode("Classic")
			core.log("action", "Starting with Classic mode, no players connected!")
		end)
	end
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "MODES:VOTE" then
		if fields.ABSTAIN then
			Modes.Votes.Abstains = Modes.PlayersVoting.Abstains + 1
			Modes.PlayersVoting[player:get_player_name()] = false
			return
		end
		local list = core.explode_textlist_event(fields.MODE)
		if list then
			if list.type == "CHG" then
				local idx = list.index
				local title = Modes.ModesTableTitle[list.index] --Get from cache
				local tech_name = Modes.ModesSTRING[title]
				local data = Modes.Modes[tech_name]
				--print("B"..title.."-"..tech_name.."-"..data.Title)
				if data then
					--print("A")
					local info = data.Info
					Modes.PlayersCurrentSelectedMode[player:get_player_name()] = tech_name
					core.after(0.2, function(title,info,idx,player)
						core.show_formspec(player:get_player_name(), "MODES:VOTE", Modes.Formspecs.ReturnSelectMode(title, info, table.concat(Modes.ModesTableTitle, ","), idx))
					end,title,info,idx,player)
				end
			end
		end
		if fields.SELECT then
			if Modes.PlayersCurrentSelectedMode[player:get_player_name()] then
				Modes.Votes[Modes.PlayersCurrentSelectedMode[player:get_player_name()]] = Modes.Votes[Modes.PlayersCurrentSelectedMode[player:get_player_name()]] + 1
				Modes.PlayersVoting[player:get_player_name()] = false
				return
			end
		end
		if fields.quit and list then
			if Modes.CurrentlyVoting and Modes.PlayersVoting[player:get_player_name()] then
				--[[local idx
				local i = 0
				for name in pairs(Modes.Modes) do
					i = i + 1
					if name == Modes.PlayersCurrentSelectedMode[player:get_player_name()] then
						
					end
				end--]]
				--local idx = list.index
				--Modes.PlayersCurrentSelectedMode[player:get_player_name()]
				--Modes.ModesTableTitle[list.index] --Get from cache
				print("AH")
				local data = Modes.Modes[Modes.PlayersCurrentSelectedMode[player:get_player_name()]]
				core.show_formspec(player:get_player_name(), "MODES:VOTE", Modes.Formspecs.ReturnSelectMode(data.Title, data.Info, table.concat(Modes.ModesTableTitle, ","), list.index))
			end
		end
	end
end)

function Modes.CommenceMatchWithSelectedMode(MODE__)
	bs_match.current_modes_rounds = bs_match.modes_rounds
	Modes.PlayersCurrentSelectedMode = {}
	Modes.CurrentlyVoting = false
	Modes.ModesTableTitle = {}
	Modes.PlayersVoting = {}
	-- Proceed with select most voted mode, or use the specified mode...
	local modes_t = {}
	if not MODE__ then
		
		for n in pairs(Modes.Modes) do table.insert(modes_t, n) end
		table.sort(modes_t, function (n1, n2) return Modes.Votes[n1] > Modes.Votes[n2] end)
		Modes.SetMode(modes_t[1])
	else
		Modes.SetMode(MODE__)
		modes_t = {[1] = MODE__}
	end
	core.chat_send_all(core.colorize("#00FF81", ">>>> Now playing for the next "..bs_match.rounds*bs_match.modes_rounds.." rounds: ")..core.colorize("#00D5FF", Modes.Modes[modes_t[1]].Title))
	maps.new_map(function()
		config.DisableTimer = Modes.LastTimerState
		core.after(1, function()
			if config.ShowMenuToPlayerWhenEndedRounds.bool then
				for _, player in pairs(core.get_connected_players()) do
					--core.after(10, bs.auto_allocate_team, player)
					--core.show_formspec(Name(player), "core:menu", bs.login_menu())
					bs.show_menu_and_expire(player)
					if config.ResetPlayerMoneyOnEndRounds then
						if bank.player[Name(player)].money then
							bank.player[Name(player)].money = 10 -- Reset his money
							score.add_score_to(name, 5)
						end
					end
					
				end
			else
				config.ShowMenuToPlayerWhenEndedRounds.func() -- Call to the function if it are disabled.
			end
			RunCallbacks(bs_match.cbs.OnNewMatches)
			core.after(1, function()
				for _, p in pairs(core.get_connected_players()) do
					if not bs.spectator[Name(p)] then
						PlayerKills[Name(p)] = {kills = 0, deaths = 0, score = 0}
						bank.player[Name(p)].money = 10 -- Reset his money
					end
				end
			end)
		end)
	end)
end

core.register_globalstep(function(dtime)
	if Modes.CurrentlyVoting then
		for pname, value in pairs(Modes.PlayersVoting) do
			if maps.IsOnline[pname] then
				if value == false then
					Modes.PlayersVoting[pname] = nil --Remove him
					core.close_formspec(pname, "MODES:VOTE")
				else
					Modes.PlayersVoting[pname] = Modes.PlayersVoting[pname] - dtime
					if Modes.PlayersVoting[pname] <= 0 then
						-- not enough time
						Modes.PlayersVoting[pname] = nil
						Modes.Votes.Abstains = Modes.Votes.Abstains + 1
						core.close_formspec(pname, "MODES:VOTE")
					end
				end
			end
		end
		if next(Modes.PlayersVoting) == nil then
			Modes.CommenceMatchWithSelectedMode()
		end
	end
end)

local FIRST_PLAYER_JOINED = false -- Some players joins his games locally for his nametag, so they wont 

core.register_on_joinplayer(function(player)
	if Modes.CurrentlyVoting then
		Modes.PlayersCurrentSelectedMode[player:get_player_name()] = Modes.ModesSTRING[Modes.ModesTableTitle[1]]
		core.show_formspec(player:get_player_name(), "MODES:VOTE", Modes.Formspecs.ReturnSelectMode(Modes.ModesTableTitle[1], Modes.Modes[Modes.ModesSTRING[Modes.ModesTableTitle[1]]].Info, table.concat(Modes.ModesTableTitle, ","), 1))
		Modes.PlayersVoting[player:get_player_name()] = 7
	else
		print(CurrentMode)
		if (not core.is_singleplayer()) and Modes.CurrentMode ~= "" and not FIRST_PLAYER_JOINED then
			local running_mode = Modes.CurrentMode
			if Modes.Modes[running_mode] and Modes.Modes[running_mode].Functions and Modes.Modes[running_mode].Functions.OnJoinPlayer then
				local bool = Modes.Modes[running_mode].Functions.OnJoinPlayer(player)
				if not bool then
					bs.show_menu_and_expire(player)
				end
			else
				bs.show_menu_and_expire(player)
			end
		end
	end
end)

core.register_on_leaveplayer(function(player)
	if Modes.CurrentlyVoting then
		Modes.PlayersCurrentSelectedMode[player:get_player_name()] = nil
		--core.show_formspec(player:get_player_name(), "MODES:VOTE", Modes.Formspecs.ReturnSelectMode(Modes.ModesTableTitle[1], Modes.Modes[Modes.ModesSTRING[Modes.ModesTableTitle[1]]].Info, table.concat(Modes.ModesTableTitle, ","), 1))
		Modes.PlayersVoting[player:get_player_name()] = nil
	else
		local running_mode = Modes.CurrentMode
		if Modes.Modes[running_mode] and Modes.Modes[running_mode].Functions and Modes.Modes[running_mode].Functions.OnLeavePlayer then
			Modes.Modes[running_mode].Functions.OnLeavePlayer(player)
		end
	end
end)

function Modes.RegisterMode(tech_name, def)
	Modes.Modes[tech_name] = def
	Modes.ModesSTRING[def.Title] = tech_name
end

bs_match.register_OnNewMatches(function()
	local rm = Modes.CurrentMode
	if rm and Modes.Modes[rm] then
		if Modes.Modes[rm] and Modes.Modes[rm].Functions and Modes.Modes[rm].Functions.OnNewMatches then
			Modes.Modes[rm].Functions.OnNewMatches()
		end
	end
end)

bs_match.register_OnMatchStart(function()
	local rm = Modes.CurrentMode
	if rm and Modes.Modes[rm] then
		if Modes.Modes[rm] and Modes.Modes[rm].Functions and Modes.Modes[rm].Functions.OnMatchStart then
			Modes.Modes[rm].Functions.OnMatchStart()
		end
	end
end)