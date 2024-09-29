local function get_puncher_hand_item(obj)
	if obj and type(obj) == "userdata" then
		if obj:is_player() then
			return bs.latest_used_item[Name(obj)]
		else
			local entity = obj:get_luaentity()
			if entity then
				local name = entity.bot_name
				return bots.in_hand_weapon[name]
			end
		end
	end
end

return function(self, puncher, _, _, _, damage)
	local puncher_team = bs.get_player_team_css(puncher)
	if puncher_team ~= "" then
		RunCallbacks(BotsCallbacks.RegisteredOnHurtBot, self, puncher, damage)
		if puncher_team ~= bots.data[self.bot_name].team then
			local from = bots.to_2d(self.object:get_pos())
			local to = bots.to_2d(puncher:get_pos())
			local offset_to = {
				x = to.x - from.x,
				y = to.y - from.y
			}
			local weapon = get_puncher_hand_item(puncher)
			if weapon then
				if weapon:match("rangedweapons") then
					if vector.distance(self.object:get_pos(), puncher:get_pos()) >= 8 then
						return -- dont look, make he dont know
					end
				else
					--check distance
					if vector.distance(self.object:get_pos(), puncher:get_pos()) <= 5 then
						-- HUNT HIM!
						bots.Hunt(self, puncher, 1.5, true)
						local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
						self.object:set_yaw(dir)
					else
						return -- MEH
					end
				end
			end
		else
			bots.chat(self, "send_warning_to_teammate", Name(puncher))
		end
	else
		self.object:set_hp(self.object:get_hp() + damage)
	end
end