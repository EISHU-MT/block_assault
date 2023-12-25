--[[
	This controlls the ticks (On server side)
	to fix lag spikes, as menu not working, maps lagging very bad
--]]
steps = {
	state = true,
	funcs = {},
	old_register = core.register_globalstep,
	cooldowns = {},
}

core.register_globalstep(function(dtime)
	if steps.state then
		for _, func in pairs(steps.funcs) do
			func(dtime)
		end
	end
	for id, sec in pairs(steps.cooldowns) do
		steps.cooldowns[id] = steps.cooldowns[id] - dtime
		if steps.cooldowns[id] <= 0 then
			steps.cooldowns[id] = nil
		end
	end
end)

core.register_globalstep = function(func)
	core.log("action", "Registering GlobalStep function, count: "..#steps.funcs+1)
	table.insert(steps.funcs, func)
end

function steps.FreezeTicks()
	steps.state = false
end

function steps.UnFreezeTicks()
	steps.state = true
end




function steps.register_cooldown()
	return {
		set = function(self, time_sec, id)
			steps.cooldowns[id] = time_sec
		end,
		is_zero = function(self, id)
			if not steps.cooldowns[self.id] then
				return true
			end
		end,
		get_secs = function(self, id)
			if steps.cooldowns[id] then
				return steps.cooldowns[id]
			end
		end,
	}
end
















