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
		if p:is_player() then
			return p:get_player_name()
		else
			return nil
		end
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
                    local count = string:get_count()
                    return true, "success_true", count
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
		local numb = CountTable(etable)
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

function RemovePrivs(p, privs) -- name=string, privs=table
	local name = Name(p)
	
	local player_privs = minetest.get_player_privs(name)
	for _, i in pairs(privs) do
		player_privs[i] = nil
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

function GetConfig(type_of_config, name, fallback)
	if type_of_config == "boolean" then
		return core.settings:get_bool(name, fallback)
	elseif type_of_config == "number" then
		return tonumber(core.settings:get(name, fallback))
	elseif type_of_config == "string" then
		return tostring(core.settings:get(name, fallback))
	end
	return nil
end

local positions = {
	vector.new(1, 0, 0),
	vector.new(0, 0, 1),
	vector.new(0, 1, 0),
	vector.new(1, 0, 1),
	vector.new(1, 1, 0),
	vector.new(1, 1, 1),
	vector.new(0, 1, 1),
	vector.new(0, 0, 0)
}

local function sum(p1, p2)
	return vector.add(p1, p2)
end

function CheckPos(pos)
	local node = core.get_node(pos)
	if node.name ~= "air" then
		for _, position in pairs(positions) do
			local vector_to_use = sum(pos, position)
			local Cnode = core.get_node(vector_to_use)
			if Cnode.name == "air" then
				return vector_to_use
			end
		end
		return vector.new(pos.x, pos.y + 2, pos.z)
	else
		return pos
	end
end

function CheckPosForPlayer(pos)
	local node = core.get_node(pos)
	if node.name ~= "air" then
		for _, position in pairs(positions) do
			local vector_to_use = sum(pos, position)
			local second_vector_to_use = sum(pos, sum(position, vector.new(0,1,0)))
			local Cnode = core.get_node(vector_to_use)
			local SecondCnode = core.get_node(second_vector_to_use)
			if Cnode.name == "air" and SecondCnode.name == "air" then
				return vector_to_use
			end
		end
		return vector.new(pos.x, pos.y + 2, pos.z)
	else
		return pos
	end
end

RadiusToArea = function(center, r)
	return {
		x = center.x - r,
		y = center.y - r,
		z = center.z - r
	}, {
		x = center.x + r,
		y = center.y + r,
		z = center.z + r
	}
end

function GetFloorPos(pos)
	local floor_to_sum = 0
	local pos2 = table.copy(pos)
	repeat
		pos2 = vector.add(pos2, vector.new(0,1,0))
		local Cnode = core.get_node(pos2)
	until Cnode.name == "air"
	return pos2
end

function IsTableEmpty(table_to_check)
	if #table_to_check <= 0 then
		return true
	end
	return false
end

function GetFirstIndex(data)
	if type(data) == "table" then
		return data[1]
	elseif type(data) == "string" then
		return data
	else
		return tostring(data)
	end
end

function CountTable(to_index) -- Some tables dont return his counted things, like #table = table = { red = {}. blue = {} } returns 0
	if to_index and type(to_index) == "table" then
		local i = 0
		for _ in pairs(to_index) do 
			i = i + 1 -- Count table contents in i
		end
		return i -- return i
	end
end

function GetIndex(table_to_index, number)
	-- Usually this is used to controll tables which has {["example"]} and not {[1]}
	local to_count = 0
	for d1, d2 in pairs(table_to_index) do
		to_count = to_count + 1
		if to_count == number then
			return d1, d2
		end
	end
end

function ReturnOnlyNames(table_to_convert)
	local to_return = {}
	for name in pairs(table_to_convert) do
		table.insert(to_return, name)
	end
	return to_return
end

function TransformTextReadable(str)
	local asus = string.sub(str, 1, 1)
	local usus = string.sub(str, 2)
	local isus = string.upper(asus)
	local esus = isus..usus
	return esus
end




