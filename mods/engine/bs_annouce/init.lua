annouce = {}
function make_dissapear_mess()
	for name, value in pairs(annouce.huds) do
		if name then
			local player = Player(name)
			local pname  = Name(name)
			if player then
				player:hud_remove(value)
			end
		end
	end
end

function annouce.publish_to_players(msg, colored)
	for ee, player in pairs(core.get_connected_players()) do
		if player then
			annouce.huds[Name(player)] = player:hud_add({
			hud_elem_type = "text",
			scale = {x = 100.6, y = 20.6},
			position = {x = 0.485, y = 0.21},
			offset = {x = 30, y = 100},
			size = {x = 2},
			alignment = {x = 0, y = -1},
			text = msg,
			number = colored,
			})
		end
	end
end

annouce.huds = {}

function annouce.transform(str)
	local asus = string.sub(str, 1, 1)
	local usus = string.sub(str, 2)
	local isus = string.upper(asus)
	local esus = isus..usus
	return esus
end

function annouce.winner(team)
	if team and skill then
		local color = bs.get_team_color(team, "number")
		annouce.publish_to_players(annouce.transform(team).." wins!", color)
	end
	
	core.after(5, make_dissapear_mess)
end