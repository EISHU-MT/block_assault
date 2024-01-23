-- Checks if bots dont exists and the game are on singleplayer mode.

local S = minetest.get_translator("bs_bots_checker")

-- TO FIX!
	config.RegisterInitialFunctions.join = false
local	exit_code = 0

local function return_formspec()
	return "formspec_version[6]" ..
	"size[10.5,3.5]" ..
	"box[0,0;10.6,0.7;#FF7A7A]" ..
	"label[0.1,0.3;"..S("Note").."]" ..
	"label[0.3,1.2;"..S("You are playing right now on singleplayer mode").."\\,]" ..
	"label[0.3,1.7;"..S("and theres no bots for BlockAssault found.").."]" ..
	"label[0.3,2.2;"..S("I recommend you install the bots to enjoy the game").."]" ..
	"button_exit[0.1,2.7;10.3,0.7;ok;Ok]"
end
if core.is_singleplayer() then
	if bots then
		core.log("action", "Bots check exit: successful")
	else
		core.log("action", "Bots check exit: 1 problem")
		steps.FreezeTicks()
		--core.show_formspec("singleplayer", "::bc", return_formspec())
		exit_code = 1
	end
	core.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "::bc" then
			if fields.ok then
				core.after(10, bs.auto_allocate_team, Player(player))
				core.after(0.2, function(player)
					core.show_formspec(Name(player), "core:menu", bs.login_menu())
				end, player)
			else
				core.after(10, bs.auto_allocate_team, Player(player))
				core.after(0.2, function(player)
					core.show_formspec(Name(player), "core:menu", bs.login_menu())
				end, player)
			end
		end
	end)
	minetest.register_on_joinplayer(function()
		if exit_code == 1 then
			core.show_formspec("singleplayer", "::bc", return_formspec())
		else
			core.after(10, bs.auto_allocate_team, Player(player))
			core.after(0.2, function(player)
				core.show_formspec("singleplayer", "core:menu", bs.login_menu())
			end)
		end
	end)
else
	config.RegisterInitialFunctions.join = true
end

