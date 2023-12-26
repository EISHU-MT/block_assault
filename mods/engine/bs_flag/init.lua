-- Flags for the hand (if others skins found)
bflag = {}
local teams = {"red", "blue", "green", "yellow"}
for _, team in pairs(teams) do
	core.register_tool("bs_flag:"..team, {
		description = team.." flag",
		inventory_image = "bs_flag_"..team..".png",
	})
end

local location = {
	"Arm_Left",          -- default bone
	{x=0, y=5.5, z=3},    -- default position
	{x=-90, y=225, z=90}, -- default rotation
	{x=0.25, y=0.25},
}

local wield_entity = {
	physical = false,
	collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
	visual = "wielditem",
	textures = {"wield3d:hand"},
	pointable = false,
	timer = 0,
	static_save = false,
}
core.register_entity("bs_flag:entity", wield_entity)

bs.cbs.register_OnAssignTeam(function(i, team)
	local player = Player(i)
	local name = Name(i)
	if team ~= "" then
		if bflag[name] then
			bflag[name]:remove()
			bflag[name] = nil
		end
		local object = minetest.add_entity(player:get_pos(), "bs_flag:entity")
		if object then
			object:set_attach(player, location[1], location[2], location[3])
			object:set_properties({
				textures = {"bs_flag:"..team},
				visual_size = location[4],
			})
			bflag[name] = object
		end
	else
		if bflag[name] then
			bflag[name]:remove()
			bflag[name] = nil
		end
	end
end)