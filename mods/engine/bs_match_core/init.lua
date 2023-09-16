if config.UseDefaultMatchEngine then
	bs_match.register_SecondOnEndMatch(function()
		core.after(0.5, function()
			for team, data in pairs(bs.team) do
				for name in pairs(data.players) do
					bs.allocate_to_team(name, "", true, true)
				end
			end
		end)
	end)
end