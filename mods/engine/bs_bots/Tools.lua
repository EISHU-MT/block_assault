function bots.line_of_sight(pos1, pos2)
	local ray = minetest.raycast(pos1, pos2, true, true)
	local thing = ray:next()
	while thing do
		if thing then
			if thing.type == "node" then
				local name = minetest.get_node(thing.under).name
				if minetest.registered_items[name] and (minetest.registered_items[name].walkable or minetest.registered_items[name].groups.liquid) then
					return false
				end
			end
			thing = ray:next()
		end
	end
	return true
end

function bots.is_in_bot_view(self, obj)
	local team = ""
	if obj:is_player() then
		team = bs_old.get_player_team_css(obj)
	elseif obj:get_luaentity() and obj:get_luaentity().bot_name then
		team = bots.data[obj:get_luaentity().bot_name].team
	end
	if bots.data[self.bot_name].team ~= team then
		if BsEntities.IsEntityAlive(obj) then
			local enemy_pos = vector.add(CheckPos(BsEntities.GetStandPos(obj)), vector.new(0,1,0))
			local self_pos = vector.add(CheckPos(BsEntities.GetStandPos(self.object)), vector.new(0,1,0))
			local raycast = minetest.raycast(self_pos, enemy_pos, false, false)
			local ray = raycast:next()
			local has_error = false
			if ray then
				while ray do
					if ray then
						if ray.type == "node" then
							local nodename = minetest.get_node(ray.under).name
							if core.registered_items[nodename] and not doors.registered_doors[nodename] then
								if core.registered_items[nodename].walkable ~= false then
									has_error = true
									break
								end
							end
						end
						ray = raycast:next()
					end
				end
			end
			if has_error then
				return false
			else
				return true
			end
		end
	else
		return false
	end
end

function bots.find_near_enemy(self)
	if not self then return nil end
	local self_pos = BsEntities.GetStandPos(self)
	local self_team = bots.data[self.bot_name].team
	if self_pos then
		local enemies = {}
		for _, obj in pairs(core.get_objects_inside_radius(self_pos, self.view_range+50)) do
			local team = bs.get_player_team_css(obj)
			if Name(obj) and (team ~= "" or team ~= nil) then
				if team ~= self_team then
					return obj
				end
			end
		end
	end
end











function bots.is_pos1_not_near_from_pos2(p1, p2)
	return vector.distance(p1, p2) >= 3
end

-- Lightweight Pathfinder

local random = math.random
local abs = math.abs
local ceil = math.ceil
local floor = math.floor

local vec_dir = vector.direction
local vec_dist = vector.distance

local function dist_2d(pos1, pos2)
	local a = vector.new(pos1.x, 0, pos1.z)
	local b = vector.new(pos2.x, 0, pos2.z)
	return vec_dist(a, b)
end

local function can_fit(pos, width, single_plane)
	local pos1 = vector.new(pos.x - width, pos.y, pos.z - width)
	local pos2 = vector.new(pos.x + width, pos.y, pos.z + width)
	for x = pos1.x, pos2.x do
		for y = pos1.y, pos2.y do
			for z = pos1.z, pos2.z do
				local p2 = vector.new(x, y, z)
				local node = minetest.get_node(p2)
				if minetest.registered_nodes[node.name].walkable then
					local p3 = vector.new(p2.x, p2.y + 1, p2.z)
					local node2 = minetest.get_node(p3)
					if minetest.registered_nodes[node2.name].walkable then
						return false
					end
					if single_plane then return false end
				end
			end
		end
	end
	return true
end

local function move_from_wall(pos, width)
	local pos1 = vector.new(pos.x - width, pos.y, pos.z - width)
	local pos2 = vector.new(pos.x + width, pos.y, pos.z + width)
	for x = pos1.x, pos2.x do
		for y = pos1.y, pos2.y do
			for z = pos1.z, pos2.z do
				local p2 = vector.new(x, y, z)
				if can_fit(p2, width) and vec_dist(pos, p2) < width then
					return p2
				end
			end
		end
	end
	return pos
end

local function exec_on_mods()
	bots.walkable_nodes = {}
	for nodename, node in pairs(core.registered_nodes) do
		if node.walkable then
			table.insert(bots.walkable_nodes, nodename)
		end
	end
end

core.register_on_mods_loaded(exec_on_mods)

bots.last_path_endpoint = {}

function bots.find_path_to_F(pos, tpos, width, self)
	if not self then
		core.log("error", "(Overrider of bs_bots | Special functions) is old, please update or contact maintainer of the overrider: At bots.find_path_to_F(1,2,3, self)")
		core.log("error", "Cancelling request and returning nothing")
		return
	end
	width = width or 1
	
	pos = CheckPos(pos)
	
	--if vector.distance(pos, tpos) < 10 then
	--	return minetest.find_path(pos, tpos, 500, 2, 5, "A*_noprefetch")
	--end
	
	if bots.last_path_endpoint[self.bot_name] then
		if (vector.distance(bots.last_path_endpoint[self.bot_name].endpoint, tpos) < 3) then
			return bots.last_path_endpoint[self.bot_name].path
		else
			bots.last_path_endpoint[self.bot_name] = nil
		end
	end
	local raw
	--[[
	if not minetest.registered_nodes[minetest.get_node(vector.new(pos.x, pos.y - 1, pos.z)).name].walkable then
		local min = vector.subtract(pos, width + 1)
		local max = vector.add(pos, width + 1)
		local index_table = minetest.find_nodes_in_area_under_air(min, max, bots.walkable_nodes)
		for _, i_pos in pairs(index_table) do
			if minetest.registered_nodes[minetest.get_node(i_pos).name].walkable then
				pos = vector.new(i_pos.x, i_pos.y + 1, i_pos.z)
				break
			end
		end
	end
	if not minetest.registered_nodes[minetest.get_node(vector.new(tpos.x, tpos.y - 1, tpos.z)).name].walkable then
		local min = vector.subtract(tpos, width)
		local max = vector.add(tpos, width)
		local index_table = minetest.find_nodes_in_area_under_air(min, max, bots.walkable_nodes)
		for _, i_pos in pairs(index_table) do
			if minetest.registered_nodes[minetest.get_node(i_pos).name].walkable then
				tpos = vector.new(i_pos.x, i_pos.y + 1, i_pos.z)
				break
			end
		end
	end
	--]]
	local path = minetest.find_path(pos, tpos, 500, 2, 5, "A*_noprefetch")
	if not path then return end
	table.remove(path, 1)
	for i = #path, 1, -1 do
		if not path then return end
		--if vec_dist(pos, path[i]) <= width + 1 then
		--	for _i = 3, #path do path[_i - 1] = path[_i] end
		--end
		--if not can_fit(path[i], width + 1) then
		--	local clear = move_from_wall(path[i], width + 1)
		--	if clear and can_fit(clear, width) then path[i] = clear end
		--end
		if minetest.get_node(path[i]).name == "default:snow" then
			path[i] = vector.new(path[i].x, path[i].y + 1, path[i].z)
		end
		raw = path
		if #path > 3 then
			--if vec_dist(pos, path[i]) < width then
			--	table.remove(path, i)
			--end
			local pos1 = path[i - 2]
			local pos2 = path[i]
			-- Handle Diagonals
			if pos1 and pos2 and pos1.x ~= pos2.x and pos1.z ~= pos2.z then
				if minetest.line_of_sight(pos1, pos2) then
					if can_fit(pos, width) then
						table.remove(path, i - 1)
					end
				end
			end
			-- Reduce Straight Lines
			if pos1 and pos2 and pos1.x == pos2.x and pos1.z ~= pos2.z  then
				if bots.line_of_sight(pos1, pos2) then
					if can_fit(pos, width) then
						table.remove(path, i - 1)
					end
				end
			elseif pos1 and pos2 and pos1.x ~= pos2.x and pos1.z == pos2.z  then
				if bots.line_of_sight(pos1, pos2) then
					if can_fit(pos, width) then
						table.remove(path, i - 1)
					end
				end
			end
			
			
		end
	end
	bots.last_path_endpoint[self.bot_name] = {endpoint = tpos, path = path}
	return path, raw
end

bs_match.register_SecondOnEndMatch(function()
	-- Reset all
	bots.last_path_endpoint = {}
end)

function bots.path_engine_do(v1, v2, dist, wut, idk, typo, self)
	-- use ordinary
	return bots.find_path_to_F(v1, v2, nil, self)--core.find_path(v1, v2, dist, wut, idk, typo)
end

local max_lengh = 160
function bots.find_path_to(start_pos, end_pos, len, self)
	--Sometimes start_pos can be nil so check from self
	if not start_pos then
		start_pos = CheckPos(self.object:get_pos())
	end
	--check if any node that is walkable is there
	-- example: door
	local name = core.get_node(start_pos).name
	if name:match("doors") then
		local vector_one = vector.add(vector.round(table.copy(start_pos)), vector.new(0,1,0))
		local name2 = core.get_node(start_pos).name
		if name2 == "air" then
			local path = bots.path_engine_do(vector_one, CheckPos(end_pos), 500, 1, 5, "A*_noprefetch", self)
			return path
		end
	end
	local path = bots.path_engine_do(start_pos, CheckPos(end_pos), 500, 1, 5, "A*_noprefetch", self)
	return path
end