
if skins then
	function ResetSkin() end
		bs.cbs.register_OnAssignTeam(function(i, team)
		local player = Player(i)
		if player then
			player:set_properties({textures = {"blank.png"}})
		end
	end)
end
