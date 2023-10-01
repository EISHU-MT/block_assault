annouce = {}
function make_dissapear_mess(ID)
	for name, data in pairs(annouce.huds) do
		if Player(name) then
			for id_to_remove, contents in pairs(data) do
				if id_to_remove == ID then
					Player(name):hud_remove(contents)
					annouce.huds[name][ID] = nil
				end
			end
		end
	end
end

minetest.register_on_joinplayer(function(player)
	annouce.huds[Name(player)] = {}
end)

minetest.register_on_leaveplayer(function(player)
	annouce.huds[Name(player)] = nil
end)

function annouce.publish_to_players(msg, colored)
	local ID = FormRandomString(10)
	for ee, player in pairs(core.get_connected_players()) do
		if player then
			annouce.huds[Name(player)][ID] = player:hud_add({
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
	return ID
end

annouce.huds = {}

function annouce.transform(str)
	local asus = string.sub(str, 1, 1)
	local usus = string.sub(str, 2)
	local isus = string.upper(asus)
	local esus = isus..usus
	return esus
end

function annouce.winner(team, str)
	if team and not str then
		local color = bs.get_team_color(team, "number")
		local id = annouce.publish_to_players(annouce.transform(team).." wins!", color)
		core.after(2, make_dissapear_mess, id)
	elseif team and str then
		local color = bs.get_team_color(team, "number")
		local id = annouce.publish_to_players(annouce.transform(team)..str, color)
		core.after(2, make_dissapear_mess, id)
	end
	
	
end