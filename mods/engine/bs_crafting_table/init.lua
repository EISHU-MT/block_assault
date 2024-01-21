-- This mod was specially made for BlockAssault CTF & config:AllowPlayerModifyMap
local S = minetest.get_translator(minetest.get_current_modname())
workbench = {
	formspec = "formspec_version[6]" ..
	"size[10.5,10]" ..
	"label[0.2,0.4;"..S("Crafting table").."]" ..
	"list[current_player;craft;1.1,0.9;3,3;0]" ..
	"list[current_player;main;0.4,4.9;8,4;0]" ..
	"list[current_player;craftpreview;6.6,2.1;1,1;0]" ..
	"label[5,2.6;==>]",
}

minetest.register_node("bs_crafting_table:workbench", {
	description = S("Crafting Table"),
	is_ground_content = false,
	tiles = { "crafting_workbench_top.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png", "default_wood.png" },
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			minetest.show_formspec(player:get_player_name(), "main", workbench.formspec)
		end
	end,
	sounds = default.node_sound_wood_defaults(),
})

bs.cbs.register_OnAssignTeam(function(n, t)
	if config.AllowPlayersModifyMaps or config.ForceUseOfCraftingTable then
		local player = Player(n)
		if t ~= "" then
			Inv(player):add_item("main", "bs_crafting_table:workbench")
		end
	end
end)

-- blacklist crafting table
dropondie.blacklist_item("bs_crafting_table:workbench")