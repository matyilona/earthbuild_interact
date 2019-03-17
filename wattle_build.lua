-- Levels of wattle with their next level
local wattle_progression = {
	["earthbuild_interact:wattle_25"] = "earthbuild_interact:wattle_50",
	["earthbuild_interact:wattle_50"] = "earthbuild_interact:wattle_75",
	["earthbuild_interact:wattle_75"] = "earthbuild:wattle"
}

-- Helper for registering multiple heights of wattle
local function register_wattle( height, num_sticks )
	top = -0.5 + height
	minetest.register_node('earthbuild_interact:wattle_'..tostring( height*100 ), {
		description = 'Wattle '..tostring( height*100 ),
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/8, -1/2, -1/8, 1/8, top, 1/8}},
			-- connect_bottom =
			connect_front = {{-1/8, -1/2, -1/2,  1/8, top, -1/8}},
			connect_left = {{-1/2, -1/2, -1/8, -1/8, top,  1/8}},
			connect_back = {{-1/8, -1/2,  1/8,  1/8, top,  1/2}},
			connect_right = {{ 1/8, -1/2, -1/8,  1/2, top,  1/8}},
		},
		connects_to = { "group:crumbly", "group:wood", "group:tree", "group:stone", "group:earthbuild_interact_wattle", 'earthbuild:wattle', 'earthbuild:wattle_loose',},
		paramtype = "light",
		tiles = {"earthbuild_wattle_top.png", "earthbuild_wattle_top.png","earthbuild_wattle.png", "earthbuild_wattle.png", "earthbuild_wattle.png", "earthbuild_wattle.png" },
		inventory_image = "earthbuild_wattle.png",
		wield_image = "earthbuild_wattle.png",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 1, earthbuild_interact_wattle = 1},
		on_rightclick = function( pos, node, player, itemstack, pointedthing )
			local item_groups = itemstack:get_definition().groups
			for g,_ in pairs( item_groups ) do
				if g == "earthbuild_interact_wattle_material" then
					--minetest.set_node( pos, { name = next_stage } )
					minetest.set_node( pos, { name = wattle_progression[ minetest.get_node( pos ).name ] } )
					itemstack:take_item()
					return( itemstack )
				end
			end
		end,
		drop = "default:stick "..tostring( math.floor( height*num_sticks ) )
	})
end

-- Registering 4 levels of wattle
register_wattle( .25, 4 )
register_wattle( .5, 4  )
register_wattle( .75, 4 )

-- Make earthbuild:wattle and wattle_and_daub connect to different heights of wattle
-- Also make it drop four sticks and
-- Put cob onto wattle by rightclicking
minetest.register_on_mods_loaded( function()
	local wattle_connects = minetest.registered_items[ "earthbuild:wattle" ].connects_to
	wattle_connects[ #wattle_connects + 1 ] = "group:earthbuild_interact_wattle"
	minetest.override_item( "earthbuild:wattle" , { connects_to = wattle_connects, drop = "default:stick 4",
	on_rightclick = function( pos, node, player, itemstack, pointedthing )
		if itemstack:get_definition().name == "earthbuild:cob" then
			minetest.set_node( pos, { name = "earthbuild:wattle_and_daub" } )
			itemstack:take_item()
			return( itemstack )
		end
	end
	} )
	local daub_connects = minetest.registered_items[ "earthbuild:wattle_and_daub" ].connects_to
	daub_connects[ #daub_connects + 1 ] = "group:earthbuild_interact_wattle"
	minetest.override_item( "earthbuild:wattle_and_daub" , { connects_to = daub_connects, drop = "default:stick 4" } )
end )


-- Sticks start wattle, or build it one lever higher. Cant start new wattle on non-fullheight wattle
minetest.register_on_mods_loaded( function()
	minetest.override_item( "default:stick", { on_place = function( itemstack, placer, pointedthing)
		if pointedthing.type ~= 'node' then
			return
		end
		local node = minetest.get_node_or_nil( pointedthing.above ).name
		local under = minetest.get_node_or_nil( pointedthing.under ).name
		if string.sub( under, 1, 27 ) == "earthbuild_interact:wattle_" then
			minetest.set_node( pointedthing.under, { name = wattle_progression[ under ] } )
			itemstack:take_item()
			return( itemstack )
		elseif node == 'air'  then
			minetest.set_node( pointedthing.above, { name = "earthbuild_interact:wattle_25" } )
			itemstack:take_item()
			return( itemstack )
		end
	end } )
end )

