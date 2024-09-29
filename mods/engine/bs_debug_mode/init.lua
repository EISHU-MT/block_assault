if config.BsDebugMode then
	if core.is_singleplayer() then
		core.register_on_joinplayer(function(player)
			core.after(2, function(player)
				bank.player[player:get_player_name()].money = math.huge
			end, player)
		end)
	end
end