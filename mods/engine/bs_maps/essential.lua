-- Map emerge funcs
function emergeblocks_callback(pos, action, num_calls_remaining, ctx)
	if ctx.total_blocks == 0 then
		ctx.total_blocks = num_calls_remaining + 1
		ctx.current_blocks = 0
	end
	ctx.current_blocks = ctx.current_blocks + 1
	if ctx.current_blocks == ctx.total_blocks then
		if ctx.name then
			minetest.chat_send_player(ctx.name,
				string.format("Finished emerging %d blocks in %.2fms.",
				ctx.total_blocks, (os.clock() - ctx.start_time) * 1000))
		end
		ctx:callback()
	elseif ctx.progress then
		ctx:progress()
	end
end

function maps.emerge_with_callbacks(name, pos1, pos2, callback, progress)
	local context = {
		current_blocks = 0,
		total_blocks = 0,
		start_time = os.clock(),
		name = name,
		callback = callback,
		progress = progress,
	}
	minetest.emerge_area(pos1, pos2, emergeblocks_callback, context)
	--callback()
end
--[[Skybox
local function update_skybox(player)
	if maps.current_map.skybox then
		local prefix = maps.current_map.dirname .. "/textures/" .. "skybox_"
		local skybox_textures = {
			prefix .. "1.png",  -- up
			prefix .. "2.png",  -- down
			prefix .. "3.png",  -- east
			prefix .. "4.png",  -- west
			prefix .. "5.png",  -- south
			prefix .. "6.png"   -- north
		}
		player:set_sky(0xFFFFFFFF, "skybox", skybox_textures, false)
	else
		player:set_sky(0xFFFFFFFF, "regular", {}, true)
	end
end--]]
--Physics
local function update_physics(player)
	if type(maps.current_map.physics) ~= "table" then return end
	player:set_physics_override({
		speed = maps.current_map.physics.speed   or 1,
		jump = maps.current_map.physics.jump or 1,
		gravity = maps.current_map.physics.gravity or 1
	})
end
--Initials
function maps.update_env()
	if not maps.current_map then return end
	for _, player in pairs(core.get_connected_players()) do
		--update_skybox(player)
		update_physics(player)
	end
end

minetest.register_on_joinplayer(function(player)
	--update_skybox(player)
	update_physics(player)
end)















