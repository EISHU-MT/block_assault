-- Dont allow players with the same name of a bot enter the server, or it will crash
core.register_on_prejoinplayer(function(name, ip)
	if bots.data[name] then
		core.log("action", "[ServerController] A user tried to access to the game with the name same as bots names.")
		return "Please change your nickname and try to enter again. This name is occupied by BAS Bots"
	end
end)