bots.in_hand_weapon = {}
bots.queue_shot = {}

bots.timer = 0
local step = function(dtime)
	--bots.timer = bots.timer + dtime
	--if bots.timer >= 0.1 then
		for name, val in pairs(bots.queue_shot) do
			if val > 0 then
				bots.queue_shot[name] = bots.queue_shot[name] - dtime
			else
				bots.queue_shot[name] = nil
				if bots.path_finder_running[name] then
					bots.data[name].object:set_animation(bots.bots_animations[name].walk, bots.bots_animations[name].anispeed, 0)
				else
					bots.data[name].object:set_animation(bots.bots_animations[name].stand, bots.bots_animations[name].anispeed, 0)
				end
			end
		end
	--	bots.timer = 0
	--end
end

core.register_globalstep(step)