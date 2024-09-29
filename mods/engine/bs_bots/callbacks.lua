BotsCallbacks = {}
BotsCallbacks.RegisteredOnKillBot = {}
BotsCallbacks.RegisteredOnHurtBot = {}
BotsCallbacks.RegisteredOnRespawnBots = {}

function BotsCallbacks.RegisterOnKillBot(func)
	table.insert(BotsCallbacks.RegisteredOnKillBot, func)
end

function BotsCallbacks.RegisterOnHurtBot(func)
	table.insert(BotsCallbacks.RegisteredOnHurtBot, func)
end

function BotsCallbacks.RegisterOnRespawnBots(func)
	table.insert(BotsCallbacks.RegisteredOnRespawnBots, func)
end