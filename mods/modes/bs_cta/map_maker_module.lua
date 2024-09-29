--[[
	BAM.S Addon
	CTA Addon
	
	Used to set a amount of areas for cta, with the wand.
--]]

ctam = {
	formspec = "formspec_version[6]" .. "size[7,3]" .. "box[0,0;7.1,0.6;#6D6DFF]" .."label[0.1,0.3;CTA Map Editor]" .. "label[0.1,0.9;Remember theres no order of areas.]" .. "label[0.1,1.3;After setting this area\\, this is not removable]" .. "button[0.1,1.5;6.8,0.7;set;Set this area for the game]" .. "button[0.1,2.2;6.8,0.7;cancel;Cancel]",
	areas = {},
	queued_areas_to_save = {
		--["player"] = {rdstr = "5n7a6g4f3", pos = vector}
	}
}

cache = {
	player_act_punch = {},
	player_latest_pos = {},
}

function DoSaveAreas(dtime)
	local data = core.serialize(ctam)
	cta.storage:set_string("data", data)
end

core.register_on_mods_loaded(function()
	local data = cta.storage:get_string("data")
	local data_table = core.deserialize(data)
	if data_table then
		ctam = data
	end
end)

function ctam.save_area(_, player, pointed_thing)
	if not cache.player_latest_pos[Name(player)] then
		cache.player_latest_pos[Name(player)] = vector.zero()
	end
	if cache.player_act_punch[Name(player)] ~= true then
		cache.player_act_punch[Name(player)] = true
		if pointed_thing.type == "node" then
			if #ctam.queued_areas_to_save ~= 0 then
				for _, area in pairs(ctam.queued_areas_to_save) do
					local pos = pointed_thing.above
					
					if cache.player_latest_pos[Name(player)].x ~= pos.x and cache.player_latest_pos[Name(player)].y ~= pos.y and cache.player_latest_pos[Name(player)].z ~= pos.z then
						if vector.distance(pos, area.pos) <= 8 then
							SendError(Name(player), "Pick other area, this territory is occupied.")
							return
						end
						
						local name = FormRandomString(5)
						table.insert(ctam.queued_areas_to_save, {name = name, pos = pos})
						SendAnnouce(Name(player), "This territory is saved! Data: (Name: "..name..", Pos: "..core.pos_to_string(pos)..").")
						DoSaveAreas()
						cache.player_latest_pos[Name(player)] = pos
					else
						cta.LogError("MapMaker: Attempt to set a area in the same pos as the latest pos! This is a bug or a invalid player action.")
					end
				end
			else
				local pos = pointed_thing.above
				if cache.player_latest_pos[Name(player)].x ~= pos.x and cache.player_latest_pos[Name(player)].y ~= pos.y and cache.player_latest_pos[Name(player)].z ~= pos.z then
					local name = FormRandomString(5)
					table.insert(ctam.queued_areas_to_save, {name = name, pos = pos})
					SendAnnouce(Name(player), "This territory is saved! Data: (Name: "..name..", Pos: "..core.pos_to_string(pos)..").")
					DoSaveAreas()
					cache.player_latest_pos[Name(player)] = pos
				else
					cta.LogError("MapMaker: Attempt to set a area in the same pos as the latest pos! This is a bug or a invalid player action.")
					cta.LogError("MapMaker!!: Cache have been overrided by other mod/app!")
				end
			end
		else
			SendError(Name(player), "You pointing at nothing! Point a node.")
		end
	end
end

local function OnStep()
	for _, player in pairs(core.get_connected_players()) do
		if cache.player_act_punch[Name(player)] then
			local controls = player:get_player_control()
			if not controls.dig then
				cache.player_act_punch[Name(player)] = nil -- Avoid spam of clicks.
			end
		end
	end
end

core.register_globalstep(OnStep)

minetest.register_tool(":cta:wand", {
	description = "Areas tool\nUsed to set areas for maps",
	inventory_image = "cta_map_editor.png",
	stack_max = 1,
	liquids_pointable = true,
	on_use = ctam.save_area
})

-- Now its time to use MapMaker's API



CallBacks.register_OnExportMap(function(meta, player)
	-- Check if theres have been set some areas.
	if CountTable(ctam.queued_areas_to_save) <= 3 then
		SendError(Name(player), "You need almost 3 areas to export the map.")
		return false
	end
	-- Now lets set up the map meta
	--local data = core.serialize({uses_cta = true, cta_areas = table.copy(ctam.queued_areas_to_save)})
	local all_data = {uses_cta = true, cta_areas = {}}
	local map_data = GetContext()
	
	for _, area in pairs(ctam.queued_areas_to_save) do
		local pos = vector.subtract(area.pos, map_data.center)
		local name = area.name
		table.insert(all_data.cta_areas, {name = name, pos = pos})
	end
	
	meta:set("data", core.serialize(all_data))
	ctam.queued_areas_to_save = {}
	DoSaveAreas()
	return true
end)













