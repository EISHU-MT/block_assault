score = {
	enable_current_status = config.UseScoreSystem,
}
local storage = core.get_mod_storage("bs_score")

-- Check
do
	local strs = storage:get_string("score")
	if strs == "" or strs == " " or strs == nil then
		local newtable = {
					__null = 0
				}
		local sr = core.serialize(newtable)
		storage:set_string("score", sr)
	end
end

local function get_data() return core.deserialize(storage:get_string("score")) or {} end
local function save_dataTO(p, v)
	local data = get_data()
	data[p] = v
	storage:set_string("score", core.serialize(data))
end

local function annouce(player, val, bool)
	local s = tostring(val)
	if bool then
		core.chat_send_player(Name(player), core.colorize("#00B600", "+"..s)..core.colorize("#00DBDB", " score"))
	else
		core.chat_send_player(Name(player), core.colorize("#DB0000", "-"..s)..core.colorize("#00DBDB", " score"))
	end
end


local function check(player)
	local name = Name(player)
	if get_data()[name] then
		return tonumber(get_data()[name]) or 0
	end
end

local function add2(p, v)
	if score.enable_current_status == false then
		return
	end
	if PlayerKills[p] and PlayerKills[p].score then
		PlayerKills[p].score = PlayerKills[p].score + v
	end
end
local function rmv2(p, v)
	if score.enable_current_status == false then
		return
	end
	if PlayerKills[p] and PlayerKills[p].score then
		PlayerKills[p].score = PlayerKills[p].score + v
	end
end

local function sum(player, v, bool)
	local name = Name(player)
	if get_data()[name] then
		save_dataTO(name, get_data()[name] + v)
		if bool then
			annouce(player, v, true)
		end
		add2(name, v)
		return true
	end
end

local function rmv(player, v, bool)
	local name = Name(player)
	if get_data()[name] then
		save_dataTO(name, get_data()[name] - v)
		if bool then
			annouce(player, v, false)
		end
		rmv2(name, v)
		return
	end
end

local function empty() end

do -- Now, define.
	if config.UseScoreSystem then
		score.get_score_of = check
		score.add_score_to = sum
		score.get_storedDA = get_data
		score.rmv_score_to = rmv
		score.raw_modifyTO = save_dataTO
	else
		score.get_score_of = empty
		score.add_score_to = empty
		score.get_storedDA = empty
		score.rmv_score_to = empty
		score.raw_modifyTO = empty
	end
end

-- Callbacks

PvpCallbacks.RegisterFunction(function(data)
	if type(data.killer) ~= "string" then
		score.add_score_to(data.killer, 10)
	end
end, "Score System")

core.register_on_joinplayer(function(player)
	if not score.get_storedDA()[Name(player)] then
		save_dataTO(Name(player), 0)
	end
end)




