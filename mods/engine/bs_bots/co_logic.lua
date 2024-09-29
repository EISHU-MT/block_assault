-- fixed doors bug:
bots.doors_toggled = {}
bots.in_door = {}

function bots.co_logic(self, mv)
	if mv.collides then
		for _, collisions in pairs(mv.collisions) do
			if collisions.type == "object" then
				local obj = collisions.object
				if Name(obj) and bots.is_enemy_alive(collisions.object) then
					local player_team = bs.get_player_team_css(obj)
					if player_team ~= "" and player_team ~= bots.data[self.bot_name].team then
						if bots.path_finder_running[self.bot_name] then
							bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].walk_mine, bots.bots_animations[self.bot_name].anispeed, 0)
						else
							bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, bots.bots_animations[self.bot_name].anispeed, 0)
						end
						collisions.object:punch(self.object, nil, {damage_groups = {fleshy = 2}}, nil)
						bots.in_hand_weapon[self.bot_name] = "default:sword_steel"
						if bots.data[self.bot_name].wield_item_obj then
							bots.data[self.bot_name].wield_item_obj:set_properties({
								textures = {"default:sword_steel"},
								visual_size = {x=0.25, y=0.25},
							})
						end
						
						local from = bots.to_2d(self.object:get_pos())
						local to = bots.to_2d(obj:get_pos())
						local offset_to = {
							x = to.x - from.x,
							y = to.y - from.y
						}
						local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
						
						self.object:set_yaw(dir)
						bots.queue_shot[self.bot_name] = 0.4
					end
				end
			elseif collisions.type == "node" then
				local pos = vector.round(collisions.node_pos)
				--if not bots.doors_toggled[self.bot_name] then bots.doors_toggled[self.bot_name] = vector.new() end
				--if (not (bots.doors_toggled[self.bot_name] == pos)) then
				--	local nodedata = minetest.get_node(pos)
				--	local nodename = nodedata.name
				--	if doors.registered_doors[nodename] then
				--		doors.door_toggle(pos, nodedata)
				--		--await
				--		bots.doors_toggled[self.bot_name] = pos
				--	end
				--else
				--	bots.doors_toggled[self.bot_name] = vector.new() -- flush
				--end
				local nodename = core.get_node(pos).name
				if doors.registered_doors[nodename] then
					bots.in_door[self.bot_name] = pos
					--print("Start: "..self.bot_name)
					local door_obj = doors.get(pos)
					local bool = door_obj:open()
					--print("opening")
					if not bool then
						local other_bool = door_obj:close()
						--print("closing")
						if not other_bool then
							doors.door_toggle(pos, core.get_node(pos))
							--print("toggling")
						end
					end
				else
					bots.in_door[self.bot_name] = nil
					--print("Abort: "..self.bot_name)
				end
			end
		end
	end
end