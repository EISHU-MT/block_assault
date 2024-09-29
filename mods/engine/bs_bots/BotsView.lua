-- Bots Eye
--[[
	To dont use get_objects_in_radius, use this. (raycast used.)
--]]
function GetObjectsInBotView(self, filter_enemy, vr)
	vr = vr or self.view_range
	local obj = self.object
	local __obj = core.get_objects_inside_radius(obj:get_pos(), vr)
	local objs = {}
	for _, obj in pairs(__obj) do
		local lua_entity = obj:get_luaentity()
		if lua_entity and lua_entity["bot_name"] and lua_entity["bot_name"] ~= self.bot_name then
			table.insert(objs, obj)
		end
	end
	-- Filter objects
	local FilteredObjects = {}
	for i, Fobj in pairs(objs) do
		local AddThisObject = true
		local res = bots.line_of_sight(Fobj:get_pos(), obj:get_pos())
		local obj_info = Fobj:get_properties()
		local obj_entity = Fobj:get_luaentity()
		if obj_entity then -- may is a player
			if obj_entity.bot_name then
				AddThisObject = true
			else
				AddThisObject = false -- dont add non-competitive objects
			end
		elseif Fobj:is_player() then
			local pname = Name(Fobj)
			if bs.get_player_team_css(pname) ~= "" then
				AddThisObject = true
			else
				AddThisObject = false
			end
		end
		if AddThisObject then
			table.insert(FilteredObjects, Fobj)
		end
	end
	local EnemyFilteredObjects = {}
	if filter_enemy then
		if bots.data[self.bot_name] then
			local team = bots.data[self.bot_name].team
			for _, objs in pairs(FilteredObjects) do
				local obj_team = bs.get_player_team_css(objs)
				if obj_team ~= team then
					table.insert(EnemyFilteredObjects, objs)
				end
			end
		else
			error("Internal Error!\nBot data not found!\nThis error should not appear!, MT memory got overriden.")
		end
		return EnemyFilteredObjects
	end
	return FilteredObjects
end

function GetObjectsNearBot(self, filter_enemy, vr)
	vr = vr or self.view_range
	local obj = self.object
	local __obj = core.get_objects_inside_radius(obj:get_pos(), vr)
	local objs = {}
	for _, obj in pairs(__obj) do
		local lua_entity = obj:get_luaentity()
		if lua_entity and lua_entity["bot_name"] and lua_entity["bot_name"] ~= self.bot_name then
			table.insert(objs, obj)
		end
	end
	-- Filter objects
	local FilteredObjects = {}
	for i, Fobj in pairs(objs) do
		local AddThisObject = true
		local res = true--bots.line_of_sight(Fobj:get_pos(), obj:get_pos()) -- Noclip used. For pathfinder
		local obj_info = Fobj:get_properties()
		local obj_entity = Fobj:get_luaentity()
		if obj_entity then -- may is a player
			if obj_entity.bot_name then
				AddThisObject = true
			else
				AddThisObject = false -- dont add non-competitive objects
			end
		elseif Fobj:is_player() then
			local pname = Name(Fobj)
			if bs.get_player_team_css(pname) ~= "" then
				AddThisObject = true
			else
				AddThisObject = false
			end
		end
		if AddThisObject then
			table.insert(FilteredObjects, Fobj)
		end
	end
	local EnemyFilteredObjects = {}
	if filter_enemy then
		if bots.data[self.bot_name] then
			local team = bots.data[self.bot_name].team
			for _, objs in pairs(FilteredObjects) do
				local obj_team = bs.get_player_team_css(objs)
				if obj_team ~= team then
					table.insert(EnemyFilteredObjects, objs)
				end
			end
		else
			error("Internal Error!\nBot data not found!\nThis error should not appear!, MT memory got overriden.")
		end
		return EnemyFilteredObjects
	end
	return FilteredObjects
end