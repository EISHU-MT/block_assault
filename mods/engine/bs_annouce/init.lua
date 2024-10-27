annouce = {}
function make_dissapear_mess(ID)
	for name, data in pairs(annouce.huds) do
		if Player(name) then
			for id_to_remove, contents in pairs(data) do
				if id_to_remove == ID then
					Player(name):hud_remove(contents.text)
					Player(name):hud_remove(contents.image)
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

annouce.huds_turns = {}

function annouce.publish_to_players(msg, colored, ypos)
	local ID = FormRandomString(10)
	ypos.imgYscaler = ypos.imgYscaler or 0
	for ee, player in pairs(core.get_connected_players()) do
		if player then
			annouce.huds[Name(player)][ID] = {
				image = player:hud_add({
					hud_elem_type = "image",
					scale = {x = 50, y = 1 + ypos.imgYscaler},
					position = {x = 0.5, y = 0},
					offset = {x = 0, y = ypos.img},
					alignment = {x = 0, y = -1},
					text = "hud_bar.png",
				}),
				text = player:hud_add({
					hud_elem_type = "text",
					position = {x = 0.5, y = 0},
					offset = {x = 0, y = ypos.txt},
					size = {x = 2},
					alignment = {x = 0, y = -1},
					text = msg,
					number = colored,
				})
			}
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
		local id = annouce.publish_to_players(annouce.transform(team).." wins!", color, {img = 175, txt = 140})
		core.after(2, make_dissapear_mess, id)
	elseif team and str then
		local color = bs.get_team_color(team, "number")
		local id = annouce.publish_to_players(annouce.transform(team).."\n"..str, color, {img = 175, txt = 140, imgYscaler = 0.5})
		core.after(2, make_dissapear_mess, id)
	end
end