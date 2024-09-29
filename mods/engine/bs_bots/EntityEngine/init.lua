-- Bots Entity Engine, used to replace any other API, As Mobkit
--[[
	Entity Ticks controller
	Path Finder PATH resolver
	Entity Basic gravity
	Queues
--]]
core.log("action", "Starting BlockAssault Entity Engine")
BsEntities = {
	Queues = {},
	Ticks = {
		state = true
		-- Bots has own on_step, so 'state' will be there.
	},
}

-- Ticks
function BsEntities.ChangeTicksState(bool)
	if bool then
		BsEntities.Ticks.state = bool
	else
		if BsEntities.Ticks.state then
			BsEntities.Ticks.state = false
		else
			BsEntities.Ticks.state = true
		end
	end
end
function BsEntities.GetTicksState()
	return BsEntities.Ticks.state
end
-- Tools
-- IsEntityAlive: Checks if entity exists on the world
function BsEntities.IsEntityAlive(thing)
	if not thing then return false end
	if type(thing) == 'table' then thing=thing.object end
	if type(thing) == 'userdata' then 
		if thing:is_player() then
			if thing:get_look_horizontal() then return true end 
		else
			--if thing:get_yaw() then return true end
			if thing:get_luaentity() then return true end
		end
	end
end
-- AnimateEntity: Animate entity with saved animations
function BsEntities.AnimateEntity(self, anim)
	if self.animation and self.animation[anim] then
		if self._anim == anim then return end
		self._anim=anim
		
		local aparms = {}
		if #self.animation[anim] > 0 then
			aparms = self.animation[anim][math.random(#self.animation[anim])]
		else
			aparms = self.animation[anim]
		end
		
		aparms.frame_blend = aparms.frame_blend or 0
		
		self.object:set_animation(aparms.range,aparms.speed,aparms.frame_blend,aparms.loop)
	else
		self._anim = nil
	end	
end
-- AdvanceHorizontal: Advance on looking direction
function BsEntities.AdvanceHorizontal(self, speed)
	local y = self.object:get_velocity().y
	local yaw = self.object:get_yaw()
	local vel = vector.multiply(core.yaw_to_dir(yaw),speed)
	vel.y = y
	self.object:set_velocity(vel)
end
-- Rotation to direction
function BsEntities.FromRotationToDirection(rot)
	local dir = core.yaw_to_dir(rot.y)
	dir.y = dir.y+tan(rot.x)*vector.length(dir)
	return vector.normalize(dir)
end
-- Turn to yaw
function BsEntities.TurnToYaw(self, tyaw, rate)
	tyaw = tyaw or 0 --temp
	rate = rate or 6
	local yaw = self.object:get_yaw()
	yaw = yaw+math.pi
	tyaw=(tyaw+math.pi)%(math.pi*2)
	
	local step=math.min(self.dtime*rate,math.abs(tyaw-yaw)%(math.pi*2))
	
	local dir = math.abs(tyaw-yaw)>math.pi and -1 or 1
	dir = tyaw>yaw and dir*1 or dir * -1
	
	local nyaw = (yaw+step*dir)%(math.pi*2)
	self.object:set_yaw(nyaw-math.pi)
	
	if nyaw==tyaw then return true, nyaw-math.pi
	else return false, nyaw-math.pi end
end
-- Timer
function BsEntities.Timer(self, s)
	local t1 = math.floor(self.totaltime)
	local t2 = math.floor(self.totaltime+self.dtime)
	if t2>t1 and t2%s==0 then return true end
end
-- Pos Shift
function BsEntities.PosShift(pos, vec)
	vec.x=vec.x or 0
	vec.y=vec.y or 0
	vec.z=vec.z or 0
	return {
		x = pos.x + vec.x,
		y = pos.y + vec.y,
		z = pos.z + vec.z
	}
end
-- Get Stand Pos
function BsEntities.GetStandPos(thing)
	local pos = {}
	local colbox = {}
	if type(thing) == 'table' then
		pos = thing.object:get_pos()
		if thing.object:get_properties() then
			colbox = thing.object:get_properties().collisionbox
		else
			return vector.zero()
		end
	elseif type(thing) == 'userdata' then
		pos = thing:get_pos()
		if thing:get_properties() then
			colbox = thing:get_properties().collisionbox
		else
			return vector.zero()
		end
	else 
		return false
	end
	if colbox and pos then
		return BsEntities.PosShift(pos,{y=colbox[2]+0.01}), pos
	else
		return vector.zero()
	end
end
-- lq_freejump
-- dont make multiple jumps on one queue!
BsEntities.QueuedJumpsFor = {}
function BsEntities.QueueFreeJump(self)
	local phase = 1
	--print("case")
	if BsEntities.QueuedJumpsFor[self.bot_name] == true then
		return
	else
		BsEntities.QueuedJumpsFor[self.bot_name] = true
	end
	local func = function(self)
		local vel=self.object:get_velocity()
		if not vel then
			BsEntities.QueuedJumpsFor[self.bot_name] = nil
			return true
		end
		if phase == 1 then
			vel.y=vel.y+6
			self.object:set_velocity(vel)
			phase = 2
		else
			if vel.y <= 0.01 then
				BsEntities.QueuedJumpsFor[self.bot_name] = nil
				return true
			end
			local dir = minetest.yaw_to_dir(self.object:get_yaw())
			dir.y=vel.y
			self.object:set_velocity(dir)
		end
	end
	BsEntities.QueueFunction(self, func)
end

BsEntities.FunctionsPerBot = {}

-- Essential
function BsEntities.SetGravityToBot(self)
	self.object:set_acceleration(vector.new(0,-9.81,0))
end
function BsEntities.SetAccelerationToBot(self, vec)
	self.object:set_acceleration(vec)
end
function BsEntities.QueueFunction(self, func)
	table.insert(self.SubMovementsQueue, func)
end
function BsEntities.AddFunctionForStepPerBot(func)
	table.insert(BsEntities.FunctionsPerBot, func)
end

BsEntities.LatestAccAndVelValues = {}

-- Entity
function BsEntities.OnSelfFunction(self, dtime, moveresult)
	self.dtime = dtime
	--if not self.__time then self.__time = 0 end
	--self.__time = self.__time + dtime
	self.totaltime = self.totaltime + dtime
	if BsEntities.Ticks.state then
		--if self.__time >= 0.5 then
		--BsEntities.LatestAccAndVelValues[self.bot_name] = {
			--	velocity = self.object:get_velocity(),
			--	acceleration = self.object:get_acceleration()
			--}
			
			self.isonground = moveresult.touching_ground
			--local standpos = BsEntities.GetStandPos(self)
			--local underpos = vector.subtract(standpos, vector.new(0,1,0))
			--if (core.registered_items[core.get_node(underpos).name].walkable == false) and moveresult.touching_ground then
			--	self.isonground = false
			--end
			if not bots.DontCareAboutMovements[self.bot_name] then
				self.hunter(self)
				self.MovementAct(self)
			else
				if bots.FunctionOfDisabledMovements[self.bot_name] then
					local bool = bots.FunctionOfDisabledMovements[self.bot_name](self)
					if bool then
						bots.FunctionOfDisabledMovements[self.bot_name] = nil
					end
				end
			end
			Logic.DoShootProcess(self)
			if self.SubMovementsQueue then
				for _, func in pairs(self.SubMovementsQueue) do
					if func(self) then
						table.remove(self.SubMovementsQueue, _)
					end
				end
			end
			for _, func in pairs(BsEntities.FunctionsPerBot) do
				func(self, moveresult)
			end
			--if self.__time >= 0.5 then
				Logic.OnStep(self, moveresult)
			--	self.__time = 0
			--end
		--end
	end
end

function BsEntities.OnActFunction(self)
	self.object:set_armor_groups({fleshy=100})
	BsEntities.SetGravityToBot(self)
end

if mobkit then
	core.log("warning", "Mobkit is no longer used in Bots Entity. So, disable it if not using it")
end
















