-- BLOCKASSAULT CONFIGURATIONS
local cfg = minetest.settings

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

-- Booleans

local PvpEngine = GetBoolean("PvpEngine", true)
local DisableTimer = GetBoolean("DisableTimer", false)
local UseScoreSystem = GetBoolean("UseScoreSystem", true)
local ClearPlayerInv = GetBoolean("ClearPlayerInv", true)
local EnableDeadBody = GetBoolean("EnableDeadBody", true)
local AlwaysShopOpen = GetBoolean("AlwaysShopOpen", false)
local EnableShopTable = GetBoolean("EnableShopTable", true)
local LoadOnLoginMenu = GetBoolean("LoadOnLoginMenu", true)
local TypeOfPlayerTag = GetBoolean("TypeOfPlayerTag", false)
local GiveDefaultTools = GetBoolean("GiveDefaultTools", true)
local LoadOnLeaveScript = GetBoolean("LoadOnLeaveScript", true)
local UsePvpMatchEngine = GetBoolean("UsePvpMatchEngine", true)
local UseEngineCurrency = GetBoolean("UseEngineCurrency", true)
local StrictMapgenCheck = GetBoolean("StrictMapgenCheck", true)
local UseLogForWarnings = GetBoolean("UseLogForWarnings", false)
local PvpEngineFriendShoot = GetBoolean("PvpEngine.FriendShoot", false)
local GiveDefaultToolsSword = GetBoolean("GiveDefaultTools.sword", true)
local AllowPlayersModifyMaps = GetBoolean("AllowPlayersModifyMaps", false)
local GiveDefaultToolsPistol = GetBoolean("GiveDefaultTools.pistol", true)
local GiveMoneyToKillerPlayer = GetBoolean("GiveMoneyToKillerPlayer", true)
local ForceUseOfCraftingTable = GetBoolean("ForceUseOfCraftingTable", false)
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

local RespawnTimer = GetNumber("RespawnTimer", 6)
local LimitForBombsCount = GetNumber("LimitForBombsCount", 5)
local MedicStandTicksRate = GetNumber("MedicStandTicksRate", 0.3)
local MedicStandHealPerTick = GetNumber("MedicStandHealPerTick", 3)
local PlayerLigthingIntensity = GetNumber("PlayerLigthingIntensity", 0.38)
local PlayerLigthingSaturation = GetNumber("PlayerLigthingSaturation", 10.0)
local SecondsToWaitToEndMolotovFire = GetNumber("SecondsToWaitToEndMolotovFire", 5)
local GiveMoneyToKillerPlayerAmount = GetNumber("GiveMoneyToKillerPlayer.amount", 10)

-- String (2)

local TypeOfStorage = Get("TypeOfStorage", "lua")
local MapsLoadAreaType = Get("MapsLoadAreaType", "emerge")
local TypeOfAnimation = Get("TypeOfAnimation", "bas_default")

-- Proccess

config.RespawnTimer = RespawnTimer
config.DisableTimer = DisableTimer
config.PvpEngine.enable = PvpEngine
config.TypeOfStorage = TypeOfStorage
config.EnableDeadBody = EnableDeadBody
config.UseScoreSystem = UseScoreSystem
config.AlwaysShopOpen = AlwaysShopOpen
config.LoadOnLoginMenu = LoadOnLoginMenu
config.EnableShopTable = EnableShopTable
config.TypeOfPlayerTag = TypeOfPlayerTag
config.TypeOfAnimation = TypeOfAnimation
config.MapsLoadAreaType = MapsLoadAreaType
config.ClearPlayerInv.bool = ClearPlayerInv
config.UseLogForWarnings = UseLogForWarnings
config.LoadOnLeaveScript = LoadOnLeaveScript
config.UseEngineCurrency = UseEngineCurrency
config.StrictMapgenCheck = StrictMapgenCheck
config.LimitForBombsCount = LimitForBombsCount
config.GiveDefaultTools.bool = GiveDefaultTools
config.MedicStandTicksRate = MedicStandTicksRate
config.UsePvpMatchEngine.bool = UsePvpMatchEngine
config.PvpEngine.FriendShoot = PvpEngineFriendShoot
config.MedicStandHealPerTick = MedicStandHealPerTick
config.GiveDefaultTools.sword = GiveDefaultToolsSword
config.AllowPlayersModifyMaps = AllowPlayersModifyMaps
config.GiveDefaultTools.pistol = GiveDefaultToolsPistol
config.PlayerLigthingIntensity = PlayerLigthingIntensity
config.ForceUseOfCraftingTable = ForceUseOfCraftingTable
config.PlayerLigthingSaturation = PlayerLigthingSaturation
config.GiveMoneyToKillerPlayer.bool = GiveMoneyToKillerPlayer
config.RestorePlayerHPOnEndRounds = RestorePlayerHPOnEndRounds
config.PvpEngine.CountPlayersKills = PvpEngineCountPlayersKills
config.ResetPlayerMoneyOnEndRounds = ResetPlayerMoneyOnEndRounds
config.RegisterInitialFunctions.join = RegisterInitialFunctionsJoin
config.SecondsToWaitToEndMolotovFire = SecondsToWaitToEndMolotovFire
config.RegisterInitialFunctions.leave = RegisterInitialFunctionsLeave
config.GiveMoneyToKillerPlayer.amount = GiveMoneyToKillerPlayerAmount
config.ShowMenuToPlayerWhenEndedRounds.bool = ShowMenuToPlayerWhenEndedRounds
config.DontPunchPlayerWhileMatchNotStarted = DontPunchPlayerWhileMatchNotStarted
config.ClearPlayerInv.maintain_last_inventory = ClearPlayerInvMaintain_last_inventory
config.ClearPlayerInv.set_new_inventory_after_inventory_reset = ClearPlayerInvSet_new_inventory_after_inventory_reset




















