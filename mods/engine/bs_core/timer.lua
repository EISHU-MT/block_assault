bs_timer = {}
local timed = 0
timehud = {}
time = 0

default_timer = 20

function bs_timer.disp_time(time)
	local days = math.floor(time/86400)
	local remaining = time % 86400
	local hours = math.floor(remaining/3600)
	remaining = remaining % 3600
	local minutes = math.floor(remaining/60)
	remaining = remaining % 60
	local seconds = remaining
	if (hours < 10) then
		hours = "0" .. tostring(hours)
	end
	if (minutes < 10) then
		minutes = "0" .. tostring(minutes)
	end
	if (seconds < 10) then
		seconds = "0" .. tostring(seconds)
	end
	answer = tostring(minutes..':'..seconds)
	return answer
end

function bs_timer.reset()
	time = default_timer
	color = 0xFFFFFF
end

function bs_timer.pause(m)
	time = default_timer
	bs_match.match_is_started = false
end

bs_timer.color = 0xFFFFFF

local function reg_glb(dtime)
	if config.DisableTimer then
		return
	end
	timed = timed + dtime
	if timed >= 1 then
		if bs_match.match_is_started == false then
			time = time - 1
			if time < 10 then
				bs_timer.color = 0xFF5454
			end
			if time == 0 then
				bs_match.match_is_started = true
				RunCallbacks(bs_match.cbs.OnMatchStart)
				bs_timer.color = 0xFFFFFF
				local id = annouce.publish_to_players("Match Starts now!", 0xFFFFFF)
				core.after(1.5, make_dissapear_mess, id)
				time = 300
			end
		end
		if bs_match.match_is_started ~= false then
			if time then
				time = time - 1
				if time < 60 then
					bs_timer.color = 0xFF5454
				end
				if time == 0 then
					if #maps.current_map.teams > 2 then
						local teams = {"red", "blue", "yellow", "green"}
						local team = Randomise("", teams)
						bs_match.finish_match(team)
					else
						local team = Randomise("", {"red", "blue"})
						bs_match.finish_match(team)
					end
				end
			else
				time = default_timer
			end
		end
		for _, player in pairs(core.get_connected_players()) do
			if time ~= -1 and (timehud) and time and color then
				player:hud_change(timehud[player:get_player_name()], "text", bs_timer.disp_time(time)) -- Time
				player:hud_change(timehud[player:get_player_name()], "number", bs_timer.color)  -- Color
			end
		end
	timed = 0
	end
end
minetest.register_globalstep(reg_glb)
















