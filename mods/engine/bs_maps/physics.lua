-- This need to handshake with empty-hand stamina
physics = {
	gravity = 1,
	speed = 1,
	jump = 1,
}

maps.register_on_load(function(def)
	if def.physics and type(def.physics) == "table" then
		physics = {
			gravity = def.physics.gravity or 1,
			speed = def.physics.speed or 1,
			jump = def.physics.jump or 1,
		}
	else
		physics = {
			gravity = 1,
			speed = 1,
			jump = 1,
		}
	end
end)