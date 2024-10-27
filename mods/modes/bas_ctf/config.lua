local cfg = minetest.settings
local ctfcfg = {}

local function GetBoolean(config, fallback)
	local from_cfg = cfg:get_bool(config, fallback)
	if from_cfg == nil then
		from_cfg = fallback
	end
	return from_cfg
end

local function Get(config, fallback)
	local from_cfg = cfg:get(config)
	if not from_cfg or from_cfg == "" then
		from_cfg = fallback
	end
	return from_cfg
end

local function GetNumber(config, fallback)
	local from_cfg = tonumber(cfg:get(config))
	if not from_cfg  then
		from_cfg = fallback
	end
	return from_cfg
end

-- Strings

ctfcfg.PlayerNameTagColor = Get("bctf_PlayerNameTagColor", "#00FFFF")
ctfcfg.FlagColBox = {
	{-0.2, -0.5, -0.2, 0.2, 2.1, 0.2}, -- Pole
	{-1.2,  1.2, -0.1, 0.2, 2.1, 0.1} -- Flag
}
ctfcfg.TakenFlagColBox = {
	{-0.2, -0.5, -0.2, 0.2, 2.1, 0.2}, -- Pole
}

-- Return Data

return ctfcfg