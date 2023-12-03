--[[
	This controlls the ticks (On server side)
	to fix lag spikes, as menu not working, maps lagging very bad
--]]
steps = {
	state = true,
	funcs = {}
}

core.register_globalstep(function(dtime)
	if steps.state then
		for _, func in pairs(steps.funcs) do
			func(dtime)
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






















