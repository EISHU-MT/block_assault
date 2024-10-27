--[[
	This is used to reset players skin
	Useful when a spectator turns into playable player
	The intention of this mod is being overrided by others mod, like skins mod. (SkinsDB)
--]]

function ResetSkin(player)
	if not skinsdb then
		player:set_properties({textures = {"character.png"}})
	end
	SetTeamSkin(player, bs.get_team(player))
end