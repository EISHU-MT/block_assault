--
-- BAS Top Players
--
Top = {
	space_to_use = 50,
}
function Top.GetFormspec(players)
	return "formspec_version[6]" ..
	"size[12,11]" ..
	"box[0,0;12,0.5;#00FFFF]" ..
	"label[0.1,0.2;Top Players Score]" ..
	"textlist[0.1,0.6;11.8,9.7;list;#00FF50Player                                                   Score,"..table.concat(players, ",")..";1;false]" ..
	"button_exit[0.1,10.4;11.8,0.5;;Exit]"
end

local function GetOnlyNames(to_parse)
	local to_return = {}
	for str in pairs(to_parse) do
		table.insert(to_return, str)
	end
	return to_return
end

function Top.GetPlayers(pname)
	local data = score.get_storedDA()
	if data then
		local names = GetOnlyNames(data)
		local table_to_be_indexed = {}
		table.sort(names, function (n1, n2) return data[n1] > data[n2] end)
		for _, name in pairs(names) do
			if name ~= "__null" then
				local len = name:len() * 2
				local to_use = Top.space_to_use - len
				local str = name
				for i = 1, to_use do
					str = str .. " "
				end
				if pname == name then
					if _ == 2 then
						str = "#0000FF"..tostring(_ - 1)..". ".. str .. tostring(data[name])
					else
						str = "#00FFFF"..tostring(_ - 1)..". ".. str .. tostring(data[name])
					end
				else
					str = tostring(_ - 1)..". ".. str .. tostring(data[name])
				end
				table.insert(table_to_be_indexed, str)
			end
		end
		return table_to_be_indexed
	else
		core.log("error", "Could not get players score!, maybe score system have been reset or its disabled.")
	end
	return {"#FF0000Could not get players index!,#FF0000Check in logs please."}
end

function Top.ShowToPlayer(ind)
	local name = Name(ind)
	if name then
		core.show_formspec(name, "top_players", Top.GetFormspec(Top.GetPlayers(name)))
	end
end

core.register_chatcommand("top", {
	description = "Top players, by score",  -- Full description
	func = Top.ShowToPlayer,
})










