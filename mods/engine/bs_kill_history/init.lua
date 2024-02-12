--[[
This is not a own code of EISHU, this code was made by LandarVargan (Copy) of his ctf_kill_history (v3)



--]]
KillHistory = {}

local hud = mhud.init()

local KILLSTAT_REMOVAL_TIME = 30

local MAX_NAME_LENGTH = 19
local HUD_LINES = 6
local HUD_LINE_HEIGHT = 20
local HUDNAME_FORMAT = "kill_list:%d,%d"

local HUD_DEFINITIONS = {
	{
		hud_elem_type = "text",
		position = {x = 0.6, y = 0.3},
		offset = {x = MAX_NAME_LENGTH*10, y = 0},
		alignment = {x = "left", y = "center"},
		color = 0xFFF,
	},
	{
		hud_elem_type = "image",
		position = {x = 0.6, y = 0.3},
		image_scale = 1.5,
		offset = {x = (MAX_NAME_LENGTH*10) + 28, y = 0},
		alignment = {x = "center", y = "center"},
	},
	{
		hud_elem_type = "text",
		position = {x = 0.6, y = 0.3},
		offset = {x = (MAX_NAME_LENGTH*10) + 54, y = 0},
		alignment = {x = "right", y = "center"},
		color = 0xFFF,
	},
}

local kill_list = {}

local function update_hud_line(player, idx, new)
	idx = HUD_LINES - (idx-1)

	for i=1, 4, 1 do
		local hname = string.format(HUDNAME_FORMAT, idx, i)
		local phud = hud:get(player, hname)

		if new then
			if phud then
				if i <= 3 then
					hud:change(player, hname, {
						text = (new[i].text or new[i] or ""),
						color = new[i].color or 0xFFF
					})
				else
					if i == 4 then
						hud:change(player, hname, {
							--text = (new[i].text or new[i] or ""),
							--color = new[i].color or 0xFFF
							image_scale = new[i]
						})
					end
					print("took")
				end
			else
				if i <= 3 then
					local newhud = table.copy(HUD_DEFINITIONS[i])
					newhud.offset.y = -(idx-1)*HUD_LINE_HEIGHT
					newhud.text = new[i].text or new[i]
					newhud.color = new[i].color or 0xFFF
					hud:add(player, hname, newhud)
				end
			end
		elseif phud then
			--if i <= 3 then
				hud:change(player, hname, {
					text = ""
				})
			--end
		end
	end
end

local function update_kill_list_hud(player)
	for i=1, HUD_LINES, 1 do
		update_hud_line(player, i, kill_list[i])
	end
end

local globalstep_timer = 0
function KillHistory.RawAdd(x, y, z, s)
	table.insert(kill_list, 1, {x, y, z, s})

	if #kill_list > HUD_LINES then
		table.remove(kill_list)
	end

	for _, p in pairs(minetest.get_connected_players()) do
		update_kill_list_hud(p)
	end

	globalstep_timer = 0
end

minetest.register_globalstep(function(dtime)
	globalstep_timer = globalstep_timer + dtime

	if globalstep_timer >= KILLSTAT_REMOVAL_TIME then
		globalstep_timer = 0

		table.remove(kill_list)

		for _, p in pairs(minetest.get_connected_players()) do
			update_kill_list_hud(p)
		end
	end
end)

bs_match.register_OnMatchStart(function()
	kill_list = {}
	hud:clear_all()
end)

minetest.register_on_joinplayer(function(player)
	update_kill_list_hud(player)
end)

function KillHistory.add(killer, victim, weapon_image, comment, color, imgS)
	local s = imgS or 1.5
	KillHistory.RawAdd(
		{text = killer, color = color or bs.get_team_color(bs.get_team(killer), "number")},
		weapon_image or "hand_kill.png",
		{text = victim .. (comment or ""), color = bs.get_team_color(bs.get_team(victim), "number") or 0xFFF},
		s
	)
end


-- Callbacks

PvpCallbacks.RegisterFunction(function(data)
	-- First of all, load images and killer/player data.
	local image = "hand_kill.png"
	local killer_name = ""
	local color
	local s
	if type(data.killer) == "string" then -- Think that was a suicide attempt
		if data.killer == "fall" then
			image = "fall.png"
			killer_name = "(fell)"
			color = 0x00FFFF
		elseif data.killer == "node_damage" then
			image = "suicide.png"
			killer_name = "(by block)"
			color = 0x00FFFF
		elseif data.killer == "drown" then
			image = "bubble.png"
			killer_name = "(drowned)"
			color = 0x00FFFF
		elseif data.killer == "set_hp" then
			image = "killed_by_system.png"
			killer_name = "(suicide ~ system)"
			color = 0x00FFFF
		end
	elseif type(data.killer) == "userdata" then
		-- Extreme code beggining
		if data.killer:is_player() then
			local hand_item = bs.latest_used_item[Name(data.killer)] or data.killer:get_wielded_item()
			local desc = hand_item:get_definition()
			if desc.RW_gun_capabilities then
				image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
			else
				if desc.inventory_image and desc.inventory_image ~= "" then
					image = desc.inventory_image
				end
			end
			s = 1
			killer_name = Name(data.killer)
		else
			local ent = data.killer:get_luaentity()
			if ent.bot_name then
				local hand_item = ItemStack(bots.in_hand_weapon[ent.bot_name])
				local desc = hand_item:get_definition()
				if desc.RW_gun_capabilities then
					image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
				else
					if desc.inventory_image and desc.inventory_image ~= "" then
						image = desc.inventory_image
					end
				end
				s = 1
				killer_name = ent.bot_name
			end
		end
	end
	KillHistory.add(killer_name, Name(data.died), image, "", color, s)
end, "BA.S Kill History System")
