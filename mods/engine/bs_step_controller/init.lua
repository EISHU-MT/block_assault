-- Steps Controller
-- HandShake with bs_ticks
hooks = {
	hooks = {},
}
function hooks.register_hook(func, timer, opt_table, ...) -- opt_table = {repeat = 5, name = "administration", cancel_true_event = true}
	local id = FormRandomString(3)
	hooks.hooks[id] = {
		func = func,
		args = ... or {},
		timer = timer or 1,
		fdata = opt_table or {repeat_time = -30, name = id, cancel_true_event = true},
		cache_time = 0, -- SPECIAL
	}
	core.log("action", "StepController: Registered "..(opt_table.name or id).." to repeat every "..(timer or 1).." sec.")
end

core.register_globalstep(function(dt)
	for id, hook in pairs(hooks.hooks) do
		hooks.hooks[id].cache_time = hooks.hooks[id].cache_time + dt
		if hooks.hooks[id].cache_time >= hook.timer then
			local doexec = true
			hooks.hooks[id].cache_time = 0
			local res = hook.func(hook.args)
			if res == true and hook.fdata.cancel_true_event then
				hooks.hook[id] = nil
				core.action("action", "StepController: Stopped "..hook.fdata.name..", function return:true")
				doexec = false
			end
			if doexec then
				if hook.fdata.repeat_time > 0 then
					hooks.hooks[id].fdata.repeat_time = hooks.hooks[id].fdata.repeat_time - 1
				end
				if hook.fdata.repeat_time <= 0 and not (hook.fdata.repeat_time <= -10) then
					hooks.hooks[id] = nil
					core.action("action", "StepController: Stopped "..hook.fdata.name..", Repeat time expired")
					do_cancel = true
				end
			end
		end
	end
end)