-- BLOCKASSAULT CONFIGURATIONS
local cfg = minetest.settings

local function GetBoolean(config, fallback)
	local from_cfg = cfg:get_bool(config, fallback)
	if not from_cfg then
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

-- Booleans

local PvpEngine = GetBoolean("PvpEngine", true)
local DisableTimer = GetBoolean("DisableTimer", false)
local UseScoreSystem = GetBoolean("UseScoreSystem", true)
local ClearPlayerInv = GetBoolean("ClearPlayerInv", true)
local EnableDeadBody = GetBoolean("EnableDeadBody", true)
local LoadOnLoginMenu = GetBoolean("LoadOnLoginMenu", true)
local GiveDefaultTools = GetBoolean("GiveDefaultTools", true)
local LoadOnLeaveScript = GetBoolean("LoadOnLeaveScript", true)
local UsePvpMatchEngine = GetBoolean("UsePvpMatchEngine", true)
local UseEngineCurrency = GetBoolean("UseEngineCurrency", true)
local StrictMapgenCheck = GetBoolean("StrictMapgenCheck", true)
local PvpEngineFriendShoot = GetBoolean("PvpEngine.FriendShoot", false)
local GiveDefaultToolsSword = GetBoolean("GiveDefaultTools.sword", true)
local AllowPlayersModifyMaps = GetBoolean("AllowPlayersModifyMaps", false)
local GiveDefaultToolsPistol = GetBoolean("GiveDefaultTools.pistol", true)
local GiveMoneyToKillerPlayer = GetBoolean("GiveMoneyToKillerPlayer", false)
local RestorePlayerHPOnEndRounds = GetBoolean("RestorePlayerHPOnEndRounds", true)
local PvpEngineCountPlayersKills = GetBoolean("PvpEngine.CountPlayersKills", true)
local ResetPlayerMoneyOnEndRounds = GetBoolean("ResetPlayerMoneyOnEndRounds", true)
local RegisterInitialFunctionsJoin = GetBoolean("RegisterInitialFunctions.join", true)
local RegisterInitialFunctionsLeave = GetBoolean("RegisterInitialFunctions.leave", true)
local ShowMenuToPlayerWhenEndedRounds = GetBoolean("ShowMenuToPlayerWhenEndedRounds", true)
local DontPunchPlayerWhileMatchNotStarted = GetBoolean("DontPunchPlayerWhileMatchNotStarted", true)
local ClearPlayerInvMaintain_last_inventory = GetBoolean("ClearPlayerInv.maintain_last_inventory", true)
local ClearPlayerInvSet_new_inventory_after_inventory_reset = GetBoolean("ClearPlayerInv.set_new_inventory_after_inventory_reset", true)

-- Strings

local GameClass = Get("GameClass", "BA Hunt & Kill")
local DefaultStartWeaponSword = Get("DefaultStartWeapon.sword", "default:sword_steel")
local DefaultStartWeaponAmmo = Get("DefaultStartWeapon.ammo", "rangedweapons:9mm 200")
local DefaultStartWeaponWeapon = Get("DefaultStartWeapon.weapon", "rangedweapons:glock17")

-- Int, Float

local LimitForBombsCount = GetNumber("LimitForBombsCount", 5)
local PlayerLigthingIntensity = GetNumber("PlayerLigthingIntensity", 0.38)
local PlayerLigthingSaturation = GetNumber("PlayerLigthingSaturation", 10.0)
local SecondsToWaitToEndMolotovFire = GetNumber("SecondsToWaitToEndMolotovFire", 5)
local GiveMoneyToKillerPlayerAmount = GetNumber("GiveMoneyToKillerPlayer.amount", 10)

-- String (2)

local TypeOfStorage = Get("TypeOfStorage", "lua")
local MapsLoadAreaType = Get("MapsLoadAreaType", "emerge")

-- Proccess

config.PvpEngine.enable = PvpEngine
config.DisableTimer = DisableTimer
config.EnableDeadBody = EnableDeadBody
config.UseScoreSystem = UseScoreSystem
config.LoadOnLoginMenu = LoadOnLoginMenu
config.ClearPlayerInv.bool = ClearPlayerInv
config.LoadOnLeaveScript = LoadOnLeaveScript
config.UseEngineCurrency = UseEngineCurrency
config.StrictMapgenCheck = StrictMapgenCheck
config.GiveDefaultTools.bool = GiveDefaultTools
config.UsePvpMatchEngine.bool = UsePvpMatchEngine
config.PvpEngine.FriendShoot = PvpEngineFriendShoot
config.GiveDefaultTools.sword = GiveDefaultToolsSword
config.AllowPlayersModifyMaps = AllowPlayersModifyMaps
config.GiveDefaultTools.pistol = GiveDefaultToolsPistol
config.GiveMoneyToKillerPlayer.bool = GiveMoneyToKillerPlayer
config.RestorePlayerHPOnEndRounds = RestorePlayerHPOnEndRounds
config.PvpEngine.CountPlayersKills = PvpEngineCountPlayersKills
config.ResetPlayerMoneyOnEndRounds = ResetPlayerMoneyOnEndRounds
config.RegisterInitialFunctions.join = RegisterInitialFunctionsJoin
config.RegisterInitialFunctions.leave = RegisterInitialFunctionsLeave
config.ShowMenuToPlayerWhenEndedRounds.bool = ShowMenuToPlayerWhenEndedRounds
config.DontPunchPlayerWhileMatchNotStarted = DontPunchPlayerWhileMatchNotStarted
config.ClearPlayerInv.maintain_last_inventory = ClearPlayerInvMaintain_last_inventory
config.ClearPlayerInv.set_new_inventory_after_inventory_reset = ClearPlayerInvSet_new_inventory_after_inventory_reset




















