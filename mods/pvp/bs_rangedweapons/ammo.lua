forbidden_ents = {
"",
}


minetest.register_alias("rangedweapons:726mm", "rangedweapons:762mm")

bullet_particles = bullet_particles or "rangedweapons_bullet_fly.png"


minetest.register_craftitem("rangedweapons:shot_bullet_visual", {
	wield_scale = {x=0.5,y=0.5,z=0.5},
	inventory_image = "rangedweapons_bulletshot.png",
})



---
--- actual mags
---

---
--- visual drop mags
---

minetest.register_craftitem("rangedweapons:drum_mag", {
	wield_scale = {x=1.0,y=1.0,z=1.5},
	inventory_image = "rangedweapons_drum_mag.png",
})

minetest.register_craftitem("rangedweapons:handgun_mag_black", {
	wield_scale = {x=0.6,y=0.6,z=0.8},
	inventory_image = "rangedweapons_magazine_handgun.png",
})
local rangedweapons_mag = {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.3, y=0.3},
		textures = {"rangedweapons:handgun_mag_black"},
		collisionbox = {0, 0, 0, 0, 0, 0},
	},
	lastpos= {},
	timer = 0,
	on_step = function(self, dtime, pos)
		self.timer = self.timer + dtime
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		if self.lastpos.y ~= nil then
			if minetest.registered_nodes[node.name] ~= nil then
			if minetest.registered_nodes[node.name].walkable then
		local vel = self.object:get_velocity()
		local acc = self.object:get_acceleration()
		self.object:set_velocity({x=0, y=0, z=0})
		self.object:set_acceleration({x=0, y=0, z=0})
				end end
		end
		if self.timer > 2.0 then
			self.object:remove()

		end
		self.lastpos= {x = pos.x, y = pos.y, z = pos.z}
	end
}
minetest.register_entity("rangedweapons:mag", rangedweapons_mag)

minetest.register_craftitem("rangedweapons:handgun_mag_white", {
	wield_scale = {x=0.6,y=0.6,z=0.8},
	inventory_image = "rangedweapons_handgun_mag_white.png",
})

minetest.register_craftitem("rangedweapons:machinepistol_mag", {
	wield_scale = {x=0.6,y=0.6,z=0.8},
	inventory_image = "rangedweapons_machinepistol_mag.png",
})

minetest.register_craftitem("rangedweapons:assaultrifle_mag", {
	wield_scale = {x=0.6,y=0.6,z=0.8},
	inventory_image = "rangedweapons_assaultrifle_mag.png",
})

minetest.register_craftitem("rangedweapons:rifle_mag", {
	wield_scale = {x=0.6,y=0.6,z=0.8},
	inventory_image = "rangedweapons_rifle_mag.png",
})

minetest.register_craftitem("rangedweapons:9mm", {
	stack_max= 500,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff","9x19mm Parabellum\n")..core.colorize("#FFFFFF", "Bullet damage: 1 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.25 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 1% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 25 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 1 \n")   ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_9mm.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=1,knockback=1},
		ammo_critEffc = 0.25,
		ammo_crit = 1,
		ammo_velocity = 25,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	}
})
minetest.register_craftitem("rangedweapons:45acp", {
	stack_max= 450,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff",".45ACP catridge\n")..core.colorize("#FFFFFF", "Bullet damage: 2 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.50 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 2% \n")
..core.colorize("#FFFFFF", "Bullet velocity: 20 \n") 
..core.colorize("#FFFFFF", "Bullet knockback: 2 \n") ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_45acp.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=2,knockback=1},
		ammo_critEffc = 0.50,
		ammo_crit = 1,
		ammo_velocity = 20,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})
minetest.register_craftitem("rangedweapons:10mm", {
	stack_max= 400,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff","10mm Auto\n")..core.colorize("#FFFFFF", "Bullet damage: 2 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency:0.30 \n") ..core.colorize("#FFFFFF", "Bullet velocity: 25 \n") 
..core.colorize("#FFFFFF", "Bullet knockback: 1 \n")  ..core.colorize("#FFFFFF", "Bullet crit chance: 1% \n") ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_10mm.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=2,knockback=1},
		ammo_critEffc = 0.3,
		ammo_crit = 1,
		ammo_velocity = 25,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shell_whitedrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	}
})


minetest.register_craftitem("rangedweapons:357", {
	stack_max= 150,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff",".357 magnum round\n")..core.colorize("#FFFFFF", "Bullet damage: 4 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.6 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 3% \n") ..core.colorize("#FFFFFF", "Bullet knockback: 5 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 5%\n") ..core.colorize("#FFFFFF", "Bullet velocity: 45 \n")    ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_357.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=4,knockback=5},
		ammo_critEffc = 0.6,
		ammo_crit = 3,
		ammo_velocity = 45,
		ammo_glass_breaking = 1,
		ammo_mob_penetration = 5,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	}
})

minetest.register_craftitem("rangedweapons:50ae", {
	stack_max= 100,
	wield_scale = {x=0.6,y=0.6,z=1.5},
		description = "" ..core.colorize("#35cdff",".50AE catridge\n")..core.colorize("#FFFFFF", "Bullet damage: 8 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.9 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 6% \n") ..core.colorize("#FFFFFF", "Bullet knockback: 10 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 15%\n") ..core.colorize("#FFFFFF", "Bullet velocity: 55 \n")    ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_50ae.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=8,knockback=10},
		ammo_critEffc = 0.9,
		ammo_crit = 6,
		ammo_velocity = 55,
		ammo_glass_breaking = 1,
		ammo_mob_penetration = 15,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	}
})

minetest.register_craftitem("rangedweapons:44", {
	stack_max= 150,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff",".44 magnum round\n")..core.colorize("#FFFFFF", "Bullet damage: 4 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.7 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 4% \n") ..core.colorize("#FFFFFF", "Bullet knockback: 6 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 6%\n") ..core.colorize("#FFFFFF", "Bullet velocity: 50 \n")  ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_44.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=4,knockback=6},
		ammo_critEffc = 0.7,
		ammo_crit = 4,
		ammo_velocity = 50,
		ammo_glass_breaking = 1,
		ammo_mob_penetration = 6,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	}
})
minetest.register_craftitem("rangedweapons:762mm", {
	stack_max= 250,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff","7.62mm round\n")..core.colorize("#FFFFFF", "Bullet damage: 4 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.5 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 2% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 40 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 4 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 5%\n")   ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_762mm.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=4,knockback=4},
		ammo_critEffc = 0.5,
		ammo_crit = 2,
		ammo_velocity = 40,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_mob_penetration = 5,
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})
minetest.register_craftitem("rangedweapons:556mm", {
	stack_max= 300,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff","5.56mm round\n")..core.colorize("#FFFFFF", "Bullet damage: 3 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.4 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 2% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 35 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 3 \n")    ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_556mm.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=3,knockback=3},
		ammo_critEffc = 0.4,
		ammo_crit = 2,
		ammo_velocity = 35,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_projectile_size = 0.0025,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})
minetest.register_craftitem("rangedweapons:shell", {
	stack_max= 50,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff","12 Gauge shell\n")..core.colorize("#FFFFFF", "Bullet damage: 2 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.15 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 1% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 20 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 4 \n") ..core.colorize("#FFFFFF", "Bullet gravity: 5 \n")  ..core.colorize("#FFFFFF", "Bullet projectile multiplier: 1.5x\n")   ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_shell.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=2,knockback=4},
		ammo_projectile_multiplier = 1.5,
		ammo_critEffc = 0.15,
		ammo_crit = 1,
		ammo_velocity = 20,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "sprite",
		ammo_texture = "rangedweapons_buckball.png",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shell_shotgundrop",
		ammo_gravity = 5,
		ammo_projectile_size = 0.00175,
		ammo_projectile_glow = 0,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})
minetest.register_craftitem("rangedweapons:308winchester", {
	stack_max= 75,
	wield_scale = {x=0.4,y=0.4,z=1.2},
		description = "" ..core.colorize("#35cdff",".308 winchester round\n")..core.colorize("#FFFFFF", "Bullet damage: 8 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.75 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 4% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 60 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 10 \n") ..core.colorize("#FFFFFF", "Damage gain over 1 sec of flight time: 40 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 20%\n") ..core.colorize("#FFFFFF", "Bullet node Penetration: 10%\n")      ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_308winchester.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=8,knockback=10},
		ammo_critEffc = 0.75,
		ammo_crit = 2,
		ammo_velocity = 60,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_mob_penetration = 20,
		ammo_node_penetration = 10,
		ammo_projectile_size = 0.0025,
		ammo_dps = 40,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})

minetest.register_craftitem("rangedweapons:408cheytac", {
	stack_max= 40,
	wield_scale = {x=0.65,y=0.65,z=1.5},
		description = "" ..core.colorize("#35cdff",".408 chey tac\n")..core.colorize("#FFFFFF", "Bullet damage: 10 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 0.8 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 5% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 70 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 15 \n") ..core.colorize("#FFFFFF", "Damage gain over 1 sec of flight time: 80 \n") ..core.colorize("#FFFFFF", "Bullet enemy Penetration: 45%\n") ..core.colorize("#FFFFFF", "Bullet node Penetration: 20%\n")      ..core.colorize("#FFFFFF", "Ammunition for some guns"),
	inventory_image = "rangedweapons_408cheytac.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=10,knockback=15},
		ammo_critEffc = 0.8,
		ammo_crit = 5,
		ammo_velocity = 70,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "wielditem",
		ammo_texture = "rangedweapons:shot_bullet_visual",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shelldrop",
		ammo_mob_penetration = 45,
		ammo_node_penetration = 20,
		ammo_projectile_size = 0.0025,
		ammo_dps = 80,
		has_sparks = 1,
		ignites_explosives = 1,
	},
})

minetest.register_craftitem("rangedweapons:40mm", {
	stack_max= 25,
	wield_scale = {x=0.8,y=0.8,z=2.4},
		description = "" ..core.colorize("#35cdff",".40mm grenade\n")..core.colorize("#FFFFFF", "Bullet damage: 10 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 1.0 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 1% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 15 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 10 \n") ..core.colorize("#FFFFFF", "Bullet gravity: 5 \n")  ..core.colorize("#FFFFFF", "explodes on impact with a radius of 2\n")  ..core.colorize("#FFFFFF", "Ammunition for grenade launchers"),
	inventory_image = "rangedweapons_40mm.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=10,knockback=15},
		ammo_critEffc = 1.0,
		ammo_crit = 1,
		ammo_velocity = 15,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "sprite",
		ammo_texture = "rangedweapons_rocket_fly.png",
		shell_entity = "rangedweapons:empty_shell",
		shell_visual = "wielditem",
		shell_texture = "rangedweapons:shell_grenadedrop",
		ammo_projectile_size = 0.15,
		has_sparks = 1,
		ammo_gravity = 5,
		ignites_explosives = 1,

OnCollision = function(player,bullet,target)
	tnt.boom(bullet.object:get_pos(), {radius = 2})
end,
ammo_particles = {
	velocity = {x=1,y=1,z=1},
	acceleration = {x=1,y=1,z=1},
	collisiondetection = true,
	lifetime = 1,
	texture = "tnt_smoke.png",
	minsize = 50,
	maxsize = 75,
	pos_randomness = 50,
	glow = 20,
	gravity = 10,
	amount = {1,1}
},
},
})

minetest.register_craftitem("rangedweapons:rocket", {
	stack_max= 15,
	wield_scale = {x=1.2,y=1.2,z=2.4},
		description = "" ..core.colorize("#35cdff","rocket\n")..core.colorize("#FFFFFF", "Bullet damage: 15 \n") ..core.colorize("#FFFFFF", "Bullet crit efficiency: 1.0 \n") ..core.colorize("#FFFFFF", "Bullet crit chance: 1% \n") ..core.colorize("#FFFFFF", "Bullet velocity: 20 \n") ..core.colorize("#FFFFFF", "Bullet knockback: 20 \n") ..core.colorize("#FFFFFF", "Bullet gravity: 5 \n")  ..core.colorize("#FFFFFF", "explodes on impact with a radius of 3\n")  ..core.colorize("#FFFFFF", "Ammunition for rocket launchers"),
	inventory_image = "rangedweapons_rocket.png",
	RW_ammo_capabilities = {
		ammo_damage = {fleshy=15,knockback=20},
		ammo_critEffc = 1.0,
		ammo_crit = 1,
		ammo_velocity = 20,
		ammo_glass_breaking = 1,
		ammo_entity = "rangedweapons:shot_bullet",
		ammo_visual = "sprite",
		ammo_texture = "rangedweapons_rocket_fly.png",
		ammo_projectile_size = 0.15,
		has_sparks = 1,
		ignites_explosives = 1,

OnCollision = function(player,bullet,target)
	tnt.boom(bullet.object:get_pos() , {radius = 3})
end,
ammo_particles = {
	velocity = {x=1,y=1,z=1},
	acceleration = {x=1,y=1,z=1},
	collisiondetection = true,
	lifetime = 1,
	texture = "tnt_smoke.png",
	minsize = 50,
	maxsize = 75,
	pos_randomness = 50,
	glow = 20,
	gravity = 10,
	amount = {1,1}
},
},
})
