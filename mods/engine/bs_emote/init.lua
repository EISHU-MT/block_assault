-- Emotes for players
emote = {
	player_emote = {}
}
function emote.get(player)
	return emote.player_emote[Name(player)] or nil
end