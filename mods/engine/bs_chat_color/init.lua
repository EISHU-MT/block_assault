local c = core.colorize

function SendError(pobj, text)
	core.chat_send_player(Name(pobj), c("red", "[ServerError] "..text))
end

function SendAnnouce(pobj, text)
	core.chat_send_player(Name(pobj), c("blue", "[ServerAnnouce] "..text))
end

function SendWarning(pobj, text)
	core.chat_send_player(Name(pobj), c("yellow", "[ServerWarning] "..text))
end

function Send(pobj, text, color)
	core.chat_send_player(Name(pobj), c(color or "white", text))
end