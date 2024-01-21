-- Medic stand for BlockAssault - Inspired by TF2 Medic on base

medic_stand = {
	to_heal = {},
	hp_to_heal = config.MedicStandHealPerTick,
	ticks = config.MedicStandTicksRate,
	box = {-0.55, -0.55, -0.55,
		  0.55,  0.6 ,  0.55}
}

local S = core.get_translator("bs_medic_stand")

minetest.register_node("bs_medic_stand:medic_stand", {
	drawtype = "mesh",
	mesh = "medic.obj",
	paramtype = "light",
	node_box = {type = "fixed", fixed=medic_stand.box},
	selection_box = {type = "fixed", fixed=medic_stand.box},
	tiles = {"medic.png"},
	visual_scale = 0.5,
	pointable = true,
	sunlight_propagates = true,
	diggable = true,
	--light_source = 8,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local name = Name(clicker)
		if clicker:get_hp() < 20 then
			hud_events.new(clicker, {
				text = S("Healing!"),
				color = "info",
				quick = false,
			})
			medic_stand.to_heal[name] = true
		else
			hud_events.new(clicker, {
				text = S("You has full HP!"),
				color = "info",
				quick = false,
			})
		end
	end,
})

local used_timer = 0

local function step(dtime)
	used_timer = used_timer + dtime
	if used_timer >= medic_stand.ticks then
		if maps.theres_loaded_map and maps.current_map and maps.current_map.teams then
			for team, pos in pairs(maps.current_map.teams) do
				for _, obj in pairs(minetest.get_objects_inside_radius(pos, 5)) do
					if obj:is_player() then
						local obj_team = bs.get_player_team_css(obj)
						if obj_team == team then
							local obj_hp = obj:get_hp()
							if obj_hp < 20 then
								if medic_stand.to_heal[Name(obj)] then -- not so fast
									obj_hp = obj_hp + medic_stand.hp_to_heal
									if obj_hp > 20 then
										obj_hp = 20
										hud_events.new(obj, {
											text = S("Heal complete!"),
											color = "success",
											quick = false,
										})
									end
								end
								obj:set_hp(obj_hp)
							end
							if obj:get_hp() >= 20 then
								medic_stand.to_heal[Name(obj)] = nil
							end
						end
					end
				end
			end
		end
		used_timer = 0
	end
end

core.register_globalstep(step)

medic_stand.random_pos = function(pos, rad)
	return {
		x = math.random(pos.x, pos.x + rad),
		y = pos.y,
		z = math.random(pos.z, pos.z + rad),
	}
end

maps.register_on_load(function()
	core.after(2, function()
		for team, pos in pairs(maps.current_map.teams) do
			local mpos = medic_stand.random_pos(pos, 3)
			local cpos = CheckPos(mpos)
			if cpos then
				core.set_node(cpos, {name = "bs_medic_stand:medic_stand"})
			elseif mpos then
				core.set_node(mpos, {name = "bs_medic_stand:medic_stand"})
			elseif pos then
				core.set_node(pos, {name = "bs_medic_stand:medic_stand"})
			else
				if config.UseLogForWarnings then
					core.log("error", "Unable to get position for medic stand! TeamName: "..team)
				end
			end
		end
	end)
end)




