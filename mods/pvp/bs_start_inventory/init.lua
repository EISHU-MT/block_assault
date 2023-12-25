bs.cbs.register_OnAssignTeam(function(player, team)
	if team ~= "" then
		if Player(player) and Inv(player) then
			--correct
		else
			core.log("error", "[BA.S Start Inventory] Attempt of crash locked!, attempt to index offline player!")
			return
		end
		if config.ClearPlayerInv.bool then
			Inv(player):set_list("main", {})
			if config.ClearPlayerInv.set_new_inventory_after_inventory_reset then
				if config.GiveDefaultTools.bool then
					if config.GiveDefaultTools.pistol then
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.weapon))
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.ammo))
					end
					if config.GiveDefaultTools.sword then
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.sword))
					end
				end
			end
		else
			if not config.ClearPlayerInv.maintain_last_inventory then
				if config.GiveDefaultTools.bool then
					if config.GiveDefaultTools.pistol then
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.weapon))
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.ammo))
					end
					if config.GiveDefaultTools.sword then
						Inv(player):add_item("main", ItemStack(config.DefaultStartWeapon.sword))
					end
				end
			end
		end
		Inv(player):add_item("main", ItemStack("bs_throwable_snow:snowball 100"))
	end
end)