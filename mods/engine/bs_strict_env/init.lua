local getinfo, rawget, rawset = debug.getinfo, rawget, rawset

function core.global_exists(name)
	if type(name) ~= "string" then
		return false
	end
	return rawget(_G, name) ~= nil
end

local enable_log = config.UseLogForWarnings
local meta = {}
local declared = {}
local warned = {}

function meta:__newindex(name, value)
	rawset(self, name, value)
	if declared[name] then
		return
	end
	if enable_log then
		local info = getinfo(2, "Sl")
		local desc = ("%s:%d"):format(info.short_src, info.currentline)
		local warn_key = ("%s\0%d\0%s"):format(info.source, info.currentline, name)
		if not warned[warn_key] then -- %q, %s Assignment to undeclared global %q inside a function at %s.
			core.log("warning", ("Attempt to declare global \"%q\" at %s. status: Success"):format(name, desc))
			warned[warn_key] = true
		end
	end
	declared[name] = true
end
function meta:__index(name)
	if declared[name] then
		return
	end
	if enable_log then
		local info = getinfo(2, "Sl")
		local warn_key = ("%s\0%d\0%s"):format(info.source, info.currentline, name)
		if not warned[warn_key] then --Undeclared global variable %q accessed at %s:%s
			core.log("warning", ("Attempt to access global variable \"%q\" at %s line: \"%s\""):format(name, info.short_src, info.currentline))
			warned[warn_key] = true
		end
	end
end

setmetatable(_G, meta)