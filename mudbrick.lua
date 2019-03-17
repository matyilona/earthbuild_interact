-- Wet mud bricks
minetest.register_node('earthbuild_interact:wet_mud_brick', {
	description = 'Wet Mud Brick',
	drawtype = "normal",
	tiles = {"earthbuild_mud_brick.png^[colorize:#3c1f0680"},
	paramtype = "light",
	groups = {crumbly = 2, falling_node = 1},
})

minetest.register_abm({
	label = "earthbuild_interact:mudbrick_drying",
	nodenames = { "earthbuild_interact:wet_mud_brick" },
	-- neighbors = {},
	interval = 2,
	chance = 5,
	action = function( pos, _, _, _ )
		minetest.set_node( pos, { name = "earthbuild:mud_brick" } )
	end
})
