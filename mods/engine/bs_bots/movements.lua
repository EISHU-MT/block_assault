--  MOVEMENTS
bots.path_to = {}
bots.path_finder_running = {}
bots.CancelPathTo = {}
bots.AbortPathMovementFor = {}

local random = math.random
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local hitbox = function(s)
	if s and s.object then
		return s.object:get_properties().collisionbox
	end
	return nil
end

local vec_dir = vector.direction
local vec_dist = vector.distance

local function dist_2d(pos1, pos2)
	local a = vector.new(pos1.x, 0, pos1.z)
	local b = vector.new(pos2.x, 0, pos2.z)
	return vec_dist(a, b)
end

function bots.CancelPath(self)
	if not bots.CancelPathTo[self.bot_name] then
		bots.CancelPathTo[self.bot_name] = true
	end
end

function bots.is_fordwarding(self)
	return self.object:get_velocity().x ~= 0 and self.object:get_velocity().z ~= 0 and self.object:get_velocity().y ~= 0
end

function bots.is_there_y_difference(pos1, pos2)
	if pos1 and pos2 then
		--local p1 = core.get_node(pos1)
		--local p2 = core.get_node(pos2)
		--local p1p = core.registered_items[p1.name]
		--local p2p = core.registered_items[p2.name]
		--if (p1p and (p1p.walkable or p1p.groups.liquid)) and (p2p and (p2p.walkable or p2p.groups.liquid)) then
		--	return false
		--else
		--	return true
		--end
		return pos1.y > pos2.y
	else
		return false
	end
end

bots.direct_walk = {}
bots.direct_walk_data = {}
bots.direct_walk_cancel = {}

local DirectWalkTime = {}
function bots.assign_direct_walk_to(self, pos, speed, for_)
	-- Block any movement of paths
	--bots.CancelPathTo[self.bot_name] = true
	bots.direct_walk[self.bot_name] = true
	bots.direct_walk_data[self.bot_name] = {speed = speed, pos = pos, end_by_ent = for_}
	DirectWalkTime[self.bot_name] = 10 -- 10s
end

function bots.assign_path_to(self, path, speed, force_cancel_direct_walk)
	--print("ASSIGNED PATH TO: "..self.bot_name)
	if self and path and speed then
		if bots.in_door[self.bot_name] then
			return
		end
		if not force_cancel_direct_walk then
			if bots.direct_walk[self.bot_name] then -- high priority
				return
			end
		end
		if not path[1] then
			return
		end
		if vector.distance(path[1], self.object:get_pos()) > 1 and BsEntities.IsEntityAlive(bots.hunting[self.bot_name]) then
			path = bots.find_path_to(vector.round(self.object:get_pos()), CheckPos(bots.hunting[self.bot_name]:get_pos()), nil, self) -- Reset path if bot are away from last path
			-- dont do anything if interrupted by door act
		elseif (not (vector.distance(path[1], self.object:get_pos()) > 1)) and bots.path_to[self.bot_name].path then
			return
		end
		if path then
			bots.path_to[self.bot_name].timer = #path
			bots.path_to[self.bot_name].path = path
			bots.path_to[self.bot_name].speed = speed
		end
	end
end

bots.FunctionOfDisabledMovements = {}

local latest_jid = {}

local true_var = true

function bots.MovementFunction(self)
	if bots.DontCareAboutMovements[self.bot_name] then return end
	if bs_match.match_is_started then
		if self and bots.direct_walk[self.bot_name] and DirectWalkTime[self.bot_name] then
			DirectWalkTime[self.bot_name] = DirectWalkTime[self.bot_name] - self.dtime
			if DirectWalkTime[self.bot_name] <= 0 then
				bots.direct_walk_cancel[self.bot_name] = nil
				bots.direct_walk_data[self.bot_name] = nil
				bots.direct_walk[self.bot_name] = nil
				BsEntities.AnimateEntity(self, "stand")
				return
			end
			if not self.object:get_pos() then return end
			if bots.direct_walk_data[self.bot_name].pos and self.object:get_pos() then
				local speed = bots.direct_walk_data[self.bot_name].speed or 1.5
				local dir = vector.direction(CheckPos(self.object:get_pos()), bots.direct_walk_data[self.bot_name].pos)
				if dir then
					if (vector.distance(self.object:get_pos(), bots.direct_walk_data[self.bot_name].pos) >= 0.8) and core.line_of_sight(self.object:get_pos(), bots.direct_walk_data[self.bot_name].pos) then
						--calculate if theres a node in front of bot
						local pos_to_look = vector.add(self.object:get_pos(), vector.multiply(bots.calc_dir(self.object:get_rotation()), 1))
						local node = core.get_node(pos_to_look)
						if node.name and (core.registered_items[node.name].walkable or core.registered_items[node.name].walkable == nil) then
							if self.isonground then
								BsEntities.QueueFreeJump(self)
							end
						end
						BsEntities.TurnToYaw(self, core.dir_to_yaw(dir), 10)
						BsEntities.AdvanceHorizontal(self, self.max_speed * speed + 0.1)
						BsEntities.AnimateEntity(self, "walk")
						--print("Doing for "..self.bot_name)
					else
						bots.direct_walk_cancel[self.bot_name] = nil
						bots.direct_walk_data[self.bot_name] = nil
						bots.direct_walk[self.bot_name] = nil
						BsEntities.AnimateEntity(self, "stand")
					end
				end
				if bots.direct_walk_cancel[self.bot_name] then
					bots.direct_walk_cancel[self.bot_name] = nil
					bots.direct_walk_data[self.bot_name] = nil
					bots.direct_walk[self.bot_name] = nil
					BsEntities.AnimateEntity(self, "stand")
				end
			end
			return
		end
		if self and bots.path_to[self.bot_name] and bots.path_to[self.bot_name].path then
			if not bots.AbortPathMovementFor[self.bot_name] then --BsEntities.IsQueueEmpty(self) -- might fix soon
				local path = bots.path_to[self.bot_name].path
				if #path <= 1 then
					bots.path_finder_running[self.bot_name] = false
					bots.path_to[self.bot_name] = {}
					bots.CancelPathTo[self.bot_name] = nil
					BsEntities.AnimateEntity(self, "stand")
					return
				end
				if bots.CancelPathTo[self.bot_name] then
					bots.CancelPathTo[self.bot_name] = nil
					bots.path_finder_running[self.bot_name] = false
					bots.path_to[self.bot_name] = {}
					BsEntities.AnimateEntity(self, "stand")
					return
				end
				local speed = bots.path_to[self.bot_name].speed or 1
				local path_iter = bots.path_to[self.bot_name].timer
				local width = ceil(hitbox(self)[4])
				if not width then
					bots.CancelPathTo[self.bot_name] = nil
					bots.path_finder_running[self.bot_name] = false
					bots.path_to[self.bot_name] = {}
					BsEntities.AnimateEntity(self, "stand")
					return
				end
				if #path >= width then
					path_iter = width
				end
				local pos = BsEntities.GetStandPos(self)
				local tpos = path[path_iter]
				local dir = vector.direction(pos, tpos)
				local total_dist = vec_dist(pos, path[#path])
				if total_dist <= width + 0.5 then
					bots.CancelPathTo[self.bot_name] = nil
					bots.path_finder_running[self.bot_name] = false
					bots.path_to[self.bot_name] = {}
					BsEntities.AnimateEntity(self, "stand")
					return
				end
				if not self.isonground then
					speed = speed * 0.5
				end
				if vec_dist(pos, tpos) <= width + 0.5 or (path[path_iter + 1] and vec_dist(pos, path[path_iter + 1]) <= width + 0.5) then
					table.remove(path, 1)
					bots.path_to[self.bot_name].timer = bots.path_to[self.bot_name].timer - 1
				end
				--[[
				local will_jump = false
				if bots.is_there_y_difference(path[path_iter + 1], path[path_iter]) then
					if (doors.registered_doors[core.get_node(path[path_iter + 1]).name]) or (not core.registered_items[core.get_node(path[path_iter + 1]).name].walkable) then
						local pos_to_look = vector.add(self.object:get_pos(), vector.multiply(bots.calc_dir(self.object:get_rotation()), 1))
						local node = core.get_node(pos_to_look)
						if node.name and ((not core.registered_items[node.name].walkable) or doors.registered_doors[node.name]) then
							if self.isonground then
								BsEntities.QueueFreeJump(self)
							end
						end
					end
				end
				--]]
				local turn_rate = self.turn_rate or 8
				--if vector.distance(pos, tpos) < width + 2 then
				--	turn_rate = turn_rate + 2
				--end
				
				
					--bots.path_to[self.bot_name].timer = bots.path_to[self.bot_name].timer - self.dtime
				
				
				if bots.path_to[self.bot_name].timer <= 0 then
					bots.CancelPathTo[self.bot_name] = nil
					bots.path_finder_running[self.bot_name] = false
					bots.path_to[self.bot_name] = {}
					BsEntities.AnimateEntity(self, "stand")
					return
				end
				
				BsEntities.TurnToYaw(self, core.dir_to_yaw(dir), turn_rate)
				BsEntities.AdvanceHorizontal(self, self.max_speed * speed + 0.1)
				--if will_jump and latest_jid[self.bot_name] ~= path_iter - 1 then
					--if bots.is_there_y_difference(path[path_iter + 1], self.object:get_pos()) then
				--		if self.isonground then
				--			BsEntities.QueueFreeJump(self)
				--		end
					--end
				--end
				BsEntities.AnimateEntity(self, "walk")
				bots.path_finder_running[self.bot_name] = true
				bots.path_to[self.bot_name].path = path
				--print(path_iter)
				--print(bots.path_to[self.bot_name].timer)
				local pos_to_look = vector.add(self.object:get_pos(), vector.multiply(bots.calc_dir(self.object:get_rotation()), 1))
				local node = core.get_node(pos_to_look)
				if node.name and (core.registered_items[node.name].walkable or core.registered_items[node.name].walkable == nil) then
					if self.isonground then
						BsEntities.QueueFreeJump(self)
					end
				end
			end
		else
			--core.log("action", "Waiting a path for "..self.bot_name)
		end
	else
		bots.direct_walk_cancel[self.bot_name] = nil
		bots.direct_walk_data[self.bot_name] = nil
		bots.direct_walk[self.bot_name] = nil
	end
end

bs_match.register_OnEndMatch(function()
	for name in pairs(bots.data) do
		bots.path_to[name] = {}
		DirectWalkTime[name] = nil
		bots.direct_walk[name] = nil
		bots.CancelPathTo[name] = nil
		bots.direct_walk_data[name] = nil
		bots.last_path_endpoint[name] = nil
		bots.direct_walk_cancel[name] = nil
		bots.path_finder_running[name] = {}
		bots.AbortPathMovementFor[name] = nil
		bots.DontCareAboutMovements[name] = nil
	end
end)