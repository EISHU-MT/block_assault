-- Random Messages
bs_rms = {
	"While shooting to a enemy, aim to his head, to be more effective your kill",
	"Camping is sometimes good, but if spawn-killing then no",
	"Training aim is good!",
	"Take care about things and health, use shift to walk without noise and keep your hand empty to walk more fast",
	"Doing team up will do better kills",
	"Being coward is not good, be brave and go kill them!",
	"If your aim is not good, i recommend you to buy a rifle, not scout",
	"Dont waste all your money for good rifles and shotguns! With skills and good aim you can kill a entire team with a Glock17!",
	"If you think about it, don't kill your teammates",
	"Better skills make better kills!",
	"Be stealthy because if they discover you they will kill you",
	"Using \"hacks\" will do a permaban",
	"Enjoy the disasters!",
	"If you see a hacker, report it!",
	"Want to join us on Discord? Heres the link!: https://discord.gg/32hc5eRtHT",
	"Please share this project! That would be a action of love :)",
	"Remember to kill your enemies, never kill your teammates.",
	"Also play CTF!", -- Might be removed soon if they dont publish this game too.
	"Here we dont use crafts, we use Shops!",
	"To see your team stats open your inventory",
	"Good players don't hack",
	"To chat only to your team use /t",
	"When finished a match, remember to buy things befores time runs out!",
}
local time_to_say = 80
local rmtime = 0
local last_msg = ""
core.register_globalstep(function(dtime)
	rmtime = rmtime + dtime
	if rmtime >= time_to_say then
		local msg = bs_rms[math.random(1, #bs_rms)]
		if last_msg ~= msg then
			core.chat_send_all(core.colorize("#1BE22A", msg))
			last_msg = msg
		end
		rmtime = 0
	end
end)