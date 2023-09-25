core.register_on_chat_message(function(player, message)
	local checked = false
	if checked == false or checked == nil then
		if bs.died[Name(player)] then
			local med = core.colorize("#FFD900", "[DIED]")
			core.chat_send_all(med.." <"..Name(player).."> "..message)
		elseif bs.spectator[Name(player)] then
			local med = core.colorize("#FFD900", "[SPECT]")
			core.chat_send_all(med.." <"..Name(player).."> "..message)
		elseif bs.get_team(Name(player)) and bs.get_team(Name(player)) ~= "" then
			local med = core.colorize(bs.get_team_color(bs.get_team(Name(player)), "string"), "<"..Name(player)..">")
			core.chat_send_all(med.." "..message)
		else
			core.chat_send_all("<"..Name(player).."> "..message)
		end
	end
	return true
end)