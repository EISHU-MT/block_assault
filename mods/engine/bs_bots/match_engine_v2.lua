--[[
	This probably replace in 100% the actual match engine.
	Or will help the actual match engine. But will shutdown some parts of PVP Engine
--]]

--local switcher = false

function TheEnd(dtime)
	--if bs_match.match_is_started and switcher == false then
	--	switcher = true
		local red_count = bs.get_team_players_index("red")
		local blue_count = bs.get_team_players_index("blue")
		local yellow_count = bs.get_team_players_index("yellow")
		local green_count = bs.get_team_players_index("green")
		
		if #maps.current_map.teams < 4 then
			if red_count <= 0 then
				bs_match.finish_match("blue")
			elseif blue_count <= 0 then
				bs_match.finish_match("red")
			end
		else
			if red_count <= 0 then
				bs_match.finish_match("blue")
			elseif blue_count <= 0 then
				bs_match.finish_match("red")
			elseif yellow_count <= 0 then
				bs_match.finish_match("yellow")
			elseif green_count <= 0 then
				bs_match.finish_match("green")
			end
		end
	--elseif not bs_match.match_is_started then
	--	switcher = false
	--end
end

function End()
	bs = {}
	bots = {}
end