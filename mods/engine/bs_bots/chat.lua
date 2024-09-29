--[[
	Chat
	
	By chance
	
	Max chance 2, min 1
--]]
ToSay = {
	send_warning_to_teammate = {
		"Stop it!",
		"Dont hurt me!",
		"I aint your enemy %s!",
		"Would someone stop %s please?"
	},
	send_death_message = {
		"Aaaah! Get %s!",
		"Get %s please.... *dies*",
	},
	send_on_no_moving_teammate = {
		"Cmon %s, Move!!",
		"Go kill your enemy %s!",
		"Cmonnnn.. Dont be lazy %s"
	},
	recharged_weapon = {
		"I recharged my weapon, dont pay attention at me!",
		"Got my weapon at full ammo, don't care about it..",
	},
	got_weapon = {
		"Oh! I got a new weapon!!",
		"New weapon for me :)"
	},
	going_to_get_weapon = {
		"Am going to get that dropped weapon!",
		"Running for weapon",
	},
	send_on_killed_teammate = {
		{"Lets pay attention in our ways before we get killed", 2} -- {TEXT, CHANCE}
	},
	got_enemy = {
		"I got %s",
		"Got %s",
		"%s was killed"
	}
}
function bots.chat(self, typo, txt)
	if ToSay[typo] then
		local team = bots.data[self.bot_name].team
		local c = math.random(1, #ToSay[typo])
		if type(ToSay[typo][c]) == "table" then
			local chance = ToSay[typo][c][2]
			local text = ToSay[typo][c][1]
			if math.random(1, 2) == chance then
				bs.send_to_team(team, "### <"..self.bot_name.."> "..string.format(ToSay[typo][c][1], txt))
			end
		else
			bs.send_to_team(team, "### <"..self.bot_name.."> "..string.format(ToSay[typo][c], txt))
		end
	end
end