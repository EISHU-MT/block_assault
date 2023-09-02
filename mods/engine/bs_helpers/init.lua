function Player(p)
	if type(p) == "userdata" then
		return p
	elseif type(p) == "string" then
		return core.get_player_by_name(p)
	end
end
function Name(p)
	if type(p) == "string" then
		return p
	elseif type(p) == "userdata" then
		return p:get_player_name()
	end
end
function Inv(p)
	return Player(p):get_inventory()
end
function FindItem(player, item)
    if player and type(player) == "userdata" then
        if item then
            local inv = player:get_inventory()
            local list = inv:get_list("main")
            local str2 = ItemStack(item)
            --local units = #list
            for i, string in pairs(list) do
                if string:get_name() == str2:get_name() then
                    return true, "success_true"
                end
                
            end
            return false, "item_dont_exists"
        end
    end
end
function ItemFind(...) FindItem(...) end
function RandomPos(pos, rad)
	--[[local x_sign = math.random() < 0.25 and -0.5 or 0.5
	local z_sign = math.random() < 0.25 and -0.5 or 0.5
	local x_offset = x_sign + math.random(rad) - 0.5
	local z_offset = z_sign + math.random(rad) - 0.5
	pos.x = pos.x + x_offset
	pos.z = pos.z + z_offset--]]
	return pos
end

function Randomise(conditionn, etable) -- Primary AI (Only had table parser with random and `IF`)
	if type(etable) == "table" then
		local numb = #etable
		local selected = math.random(#etable)
		return etable[selected] or ""
	end
end

Randomize = Randomise

function AddPrivs(p, privs) -- name=string, privs=table
	local name = Name(p)
	
	local player_privs = minetest.get_player_privs(name)
	for i, value in pairs(privs) do
		player_privs[i] = value
	end
	minetest.set_player_privs(name, player_privs)
end

function core.get_connected_names()
	local names = {}
	for _, player in pairs(core.get_connected_players()) do
		table.insert(names, Name(player))
	end
	return names
end

function RunCallbacks(tabled, ...)
	if tabled and type(tabled) == "table" then
		for i = 1, #tabled do
			if type(tabled[i]) == "function" then
				tabled[i](...)
			end
		end
	end
end

letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "p", "q", "z", "x", "y", "v", "o", "s", "w", "t", "r", "u", "p"}
numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

function FormRandomString(lengh)
	local string = {}
	if not lengh then
		return
	end
	local ln = #letters
	local nn = #numbers
	for i = 1, lengh do
		local n = math.random(ln)
		table.insert(string, letters[n])
		local n = math.random(nn)
		table.insert(string, numbers[n])
	end
	return table.concat(string, "")
end

function Exists(thing)
	local default_opt = core.global_exists(thing)
	local newest__opt = thing ~= nil
	return default_opt or newest__opt
end




















