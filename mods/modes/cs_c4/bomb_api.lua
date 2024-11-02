c4.BombData = {
	IsDropped = false,
	PlayerName = nil,
	Dropper = nil,
	Pos = vector.new(),
	Obj = nil
}
c4.Huds = {}
c4.StaticData = {
	Timer = 0,
	Pos = vector.new(),
	Player = "",
	Planted = false
}
c4.Defuser = {}
function c4.NotifyDroppedBomb(pos, dropper)
	for PlayerName in pairs(bs.team.red.players) do
		local player = Player(PlayerName)
		if player then
			c4.Huds[PlayerName] = player:hud_add({
				hud_elem_type = "waypoint",
				number = 0xFF6868,
				name = "Dropped bomb is here! dropt by ".. dropper,
				text = "m",
				world_pos = pos
			})
			if Name(dropper) ~= PlayerName then
				hud_events.new(Player(PlayerName), {
					text = ("(!) The bomb is being dropped!"),
					color = "warning",
					quick = false,
				})
			end
		else
			core.log("error", "Unknown player in red team: "..PlayerName)
		end
	end
	c4.BombData.Dropper = dropper
	c4.BombData.Pos = pos
end

function c4.NotifyPickedBomb(picker)
	for PlayerName in pairs(bs.team.red.players) do
		local player = Player(PlayerName)
		if player then
			if c4.Huds[PlayerName] then
				player:hud_remove(c4.Huds[PlayerName])
			end
			if Name(dropper) ~= PlayerName then
				hud_events.new(Player(PlayerName), {
					text = ("(#) The bomb was picked by "..picker.."!"),
					color = "info",
					quick = false,
				})
			else
				hud_events.new(Player(PlayerName), {
					text = ("(!) You picked the bomb"),
					color = "warning",
					quick = false,
				})
			end
		else
			core.log("error", "Unknown player in red team: "..PlayerName)
		end
	end
end

function c4.PlantBombAt(pos, pname)
	if pos and pname then
		core.after(1, function(pos)
			--Check node in Y-1 coordinate
			local pos_ = vector.subtract(pos, vector.new(0,1,0))
			local node = core.get_node(pos_)
			local central_node = core.get_node(pos)
			if node.name == "air" then
				pos = pos_
			else
				if central_node.name == "air" then
					pos = pos
				else
					pos = vector.new(pos, vector.new(0,1,0))
				end
			end
			--Place Bomb
			core.set_node(pos, {name="cs_c4:c4", param1=1, param2=1})
			--Notify
			for _, p in pairs(core.get_connected_players()) do
				hud_events.new(p, {
					text = ("(!) The bomb is planted!"),
					color = "warning",
					quick = false,
				})
			end
		end, pos)
		--Set Variables
		time = 120
		c4.StaticData.Pos = pos
		c4.StaticData.Planted = true
		c4.StaticData.Player = pname
		bs.StringTo[pname] = nil
		c4.BombData = {
			IsDropped = false,
			PlayerName = nil,
		}
		--Set player stats
		if Player(pname) and Player(pname):is_player() then
			bank.player_add_value(pname, 50)
			score.add_score_to(pname, 60, true)
		else
			--Assign as a bot
			if Player(pname) then --double check
				PlayerKills[pname].score = PlayerKills[pname].score + 60
				bots.data[pname].money = bots.data[pname].money + 50
			end
		end
	end
end

function c4.Reset()
	core.set_node(c4.StaticData.Pos, {name="air"})
	c4.StaticData.Pos = vector.new()
	c4.StaticData.Player = ""
	c4.StaticData.Planted = false
end

function c4.Bomb()
	if c4.StaticData.Planted then
		if Player(c4.StaticData.Player) and Player(c4.StaticData.Player):is_player() then
			bank.player_add_value(c4.StaticData.Player, 50)
			score.add_score_to(c4.StaticData.Player, 60, true)
		else
			--Assign as a bot
			if Player(c4.StaticData.Player) then --double check
				PlayerKills[c4.StaticData.Player].score = PlayerKills[c4.StaticData.Player].score + 60
				bots.data[c4.StaticData.Player].money = bots.data[c4.StaticData.Player].money + 50
			end
		end
		core.add_particlespawner({
			amount = 300*2,
			time = 0.1,
			minpos = vector.subtract(c4.StaticData.Pos, 60),
			maxpos = vector.add(c4.StaticData.Pos, 60),
			minvel = {x=0, y=0, z=0},
			maxvel = {x=0, y=0, z=0},
			minacc = {x=-0.5, y=5, z=-0.5},
			maxacc = {x=0.5, y=5, z=0.5},
			minexptime = 0.5,
			maxexptime = 3,
			minsize = 40,
			maxsize = 95,
			collisiondetection = false,
			texture = "smoke.png",
		})
		for _, obj in pairs(minetest.get_objects_inside_radius(c4.StaticData.Pos, 70)) do
			if Player(obj) then
				local dist = vector.distance(obj:get_pos(), c4.StaticData.Pos)
				local HP = (60/dist)*3
				obj:set_hp(HP)
			end
		end
	end
end

local clock = 0
local time_to = 1
core.register_globalstep(function(dtime)
	if Modes.CurrentMode == "c4" then
		if c4.StaticData.Planted then
			clock = clock + dtime
			if time > 90 and time < 120 then
				time_to = 0.8
			end
			if time > 60 and time < 100 then
				time_to = 0.7
			end
			if time > 30 and time < 50 then
				time_to = 0.5
			end
			if time > 10 and time < 30 then
				time_to = 0.3
			end
			if time > 5 and time < 10 then
				time_to = 0.1
			end
			if time > 120 then
				time_to = 1
			end
			if not time_to then
				time_to = 0.9
			end
			
			if clock >= time_to then
				clock = 0
				c4.PlaySound()
			end
		else
			time_to = 1
		end
	end
end)

function c4.PlaySound()
	for _, player in pairs(core.get_objects_inside_radius(c4.StaticData.Pos, 32)) do
		if player:get_player_name() ~= "" or player:get_player_name() ~= " " then
			local dist = vector.distance(player:get_pos(), c4.StaticData.Pos)
			local gain = (32 - dist) / 32
			local gain_value = gain * 1.0
			if not (gain <= 0) then
				core.sound_play({name = "cs_files_beep"}, {to_player = Name(player), gain = gain_value})
			end
		end
	end
end

function VersusBombArea(str)
	if str then
		if str == "a" then
			return "b"
		else
			return "a"
		end
	end
end

function c4.EndMatchFromDefuser(pname)
	if pname then
		if bs_match.match_is_started then
			--RESTORED FROM CSMT LIKE - DEVSTATE
			local phares = {pname.." did his job!", pname.." has defused the bomb!"}
			local phare = Randomise("", phares)
			bs_match.finish_match("blue", phare)
		end
	end
end











