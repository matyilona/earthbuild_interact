-- Wet cob
minetest.register_node('earthbuild_interact:wet_cob', {
	description = 'Cob',
	drawtype = "normal",
	tiles = {"earthbuild_cob.png^[colorize:#3c1f0680"},
	paramtype = "light",
	drop = "default:dirt",
	groups = {crumbly = 3, falling_node = 1},
	on_punch = function( pos, node, player, pointedthing )
		if player:get_wielded_item():get_definition().name == "default:stick" then
			minetest.set_node( pos, { name = "earthbuild_interact:wet_mud_brick" } )
		end
	end
})

minetest.register_abm({
	label = "earthbuild_interact:cob_drying",
	nodenames = { "earthbuild_interact:wet_cob" },
	-- neighbors = {},
	interval = 2,
	chance = 5,
	action = function( pos, _, _, _ )
		minetest.set_node( pos, { name = "earthbuild:cob" } )
	end
})

-- Helper for registering types of mud
local function register_mud( name, desc, base, overlay, visc, is_flowing, source, flowing )
	
	local flowstring = "source"

	if is_flowing then
		flowstring = "flowing"
	end

	local overlaid_tiles = {
			{
				name = "default_water_"..flowstring.."_animated.png^"..overlay,
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2.0,
				},
			},
			{
				name = "default_water_"..flowstring.."_animated.png^"..overlay,
				backface_culling = true,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2.0,
				},
			},
		}

	local param2 = nil
	local drawtype = "liquid"
	local flowstring = "source"
	local tiles = overlaid_tiles
	local specialtiles = nil
	if is_flowing then
		param2 = "flowingliquid"
		drawtype = "flowingliquid"
		flowstring = "flowing"
		tiles = nil
		specialtiles = overlaid_tiles
	end

	minetest.register_node("earthbuild_interact:"..name, {
		description = desc,
		tiles = tiles,
		special_tiles = specialtiles,
		drawtype = drawtype,
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = param2,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		liquidtype = flowstring,
		liquid_renewable = false,
		liquid_alternative_flowing = "earthbuild_interact:"..flowing,
		liquid_alternative_source = "earthbuild_interact:"..source,
		liquid_viscosity = visc,
		liquid_range = 1,
		groups = {liquid = 3, cools_lava = 1},
	})
	end

-- Registering muds
register_mud( "thickmud_source", "Thick Mud", "earthbuild_interact_mud.png", "earthbuild_interact_thickmud_overlay_animated.png", 8, false, "thickmud_source", "thickmud_flowing" )
register_mud( "thickmud_flowing", "Thick Mud (Flowing)", "earthbuild_interact_mud.png", "earthbuild_interact_thickmud_overlay_animated.png", 8, true, "thickmud_source", "thickmud_flowing" )

register_mud( "mud_source", "Mud", "earthbuild_interact_mud.png", "earthbuild_interact_mud_overlay_animated.png", 4, false, "mud_source", "mud_flowing" )
register_mud( "mud_flowing", "Mud (Flowing)", "earthbuild_interact_mud.png", "earthbuild_interact_mud_overlay_animated.png", 4, true, "mud_source", "mud_flowing" )

-- Mud clearing and spreading ABMs
minetest.register_abm({
	label = "earthbuild_interact:mud_cleaning_and_spreading",
	nodenames = { "earthbuild_interact:mud_source" },
	-- neighbors = {},
	interval = 10,
	chance = 5,
	action = function( pos, _, _, _ )
		local spread = 0
		for i = -1,1 do
			for j = -1,1 do
				local neigh_pos = { x=pos.x+i, y=pos.y, z=pos.z+j }
				local neigh = minetest.get_node_or_nil( neigh_pos )
				if neigh ~= nil then
					if neigh.name == "default:water_source" and ( math.random(1,100) < 11 ) then
						minetest.set_node( neigh_pos, { name = "earthbuild_interact:mud_source" } )
						spread = spread + 1
					end
				end
			end
		end
		if math.random(1,100) < 80+4*spread then 
			minetest.set_node( pos, { name = "default:water_source" } )
		end
	end
})

minetest.register_abm({
	label = "earthbuild_interact:thickmud_cleaning_and_spreading",
	nodenames = { "earthbuild_interact:thickmud_source" },
	-- neighbors = {},
	interval = 2,
	chance = 2,
	action = function( pos, _, _, _ )
		for i = -1,1 do
			for j = -1,1 do
				local neigh_pos = { x=pos.x+i, y=pos.y, z=pos.z+j }
				local neigh = minetest.get_node_or_nil( neigh_pos )
				if neigh ~= nil then
					if neigh.name == "default:water_source" and ( math.random(1,100) < 70 ) then
						minetest.set_node( neigh_pos, { name = "earthbuild_interact:mud_source" } )
					elseif neigh.name == "earthbuild_interact:mud_source" and ( math.random(1,100) < 5 ) then
						minetest.set_node( neigh_pos, { name = "earthbuild_interact:thickmud_source" } )
					end
				end
			end
		end
		if math.random(1,100) < 40 then 
			minetest.set_node( pos, { name = "earthbuild_interact:mud_source" } )
		end
	end
})

-- Adding dropped item based mud crafting
local reaction_time = 1000
local reaction_time_random = 800
local function passivize( pos, time )
	-- make node at pos unreactive for some time
	local meta = minetest.get_meta( pos )
	meta:set_int( "earthbuild_interact_is_reactive", 1 )
	minetest.after( time/1000,
	function( position )
		minetest.get_voxel_manip():read_from_map( position, position )
		local meta_data = minetest.get_meta( position )
		meta_data:set_int( "earthbuild_interact_is_reactive", 0 )
	end, pos )
end

local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {

	set_item = function(self, itemstring)
		builtin_item.set_item(self, itemstring)

		local stack = ItemStack(itemstring)
		if minetest.registered_items[ stack:get_name() ].groups[ "earthbuild_interact_plant_material" ] ~= nil then
			self.is_plantmat = true
			self.reaction_timer = reaction_time
		end
		if stack:get_name() == "default:dirt" then
			self.is_dirt = true
		end
	end,

	on_step = function(self, dtime)
		builtin_item.on_step(self, dtime)

		if self.is_dirt or self.is_plantmat then

			local pos = vector.round( self.object:get_pos() )
			local node = minetest.get_node_or_nil( pos )
			if not node then
				return
			end

			local reacting = false
			local meta = minetest.get_meta( pos )
			if meta:get_int( "earthbuild_interact_is_reactive" ) == 0 then 
				if node.name == "default:water_source" and self.is_dirt then
					minetest.set_node( pos, { name = "earthbuild_interact:mud_source" } )
					reacting = true
				elseif node.name == "earthbuild_interact:mud_source" and self.is_dirt then
					minetest.set_node( pos, { name = "earthbuild_interact:thickmud_source" } )
					meta = minetest.get_meta( pos )
					reacting = true
				elseif node.name == "earthbuild_interact:thickmud_source" and self.is_plantmat then
					minetest.set_node( self.object:get_pos(), { name = "default:water_source" } )
					minetest.spawn_item( pos, "earthbuild_interact:wet_cob 3" )
					reacting = true
				end
			end

			if reacting then
				passivize( pos, reaction_time + math.random( 1, reaction_time_random ) )
				minetest.add_particlespawner({
					amount = 3,
					time = 0.1,
					minpos = {x = pos.x - 0.1, y = pos.y + 0.1, z = pos.z - 0.1 },
					maxpos = {x = pos.x + 0.1, y = pos.y + 0.2, z = pos.z + 0.1 },
					minvel = {x = 0, y = 2.5, z = 0},
					maxvel = {x = 0, y = 2.5, z = 0},
					minacc = {x = -0.15, y = -0.02, z = -0.15},
					maxacc = {x = 0.15, y = -0.01, z = 0.15},
					minexptime = 1,
					maxexptime = 1.5,
					minsize = 2,
					maxsize = 4,
					collisiondetection = true,
					texture = "default_item_smoke.png^[colorize:#3c1f06aa"
				})
				local stack = ItemStack( self.itemstring )
				stack:take_item( 1 )
				if stack:is_empty() then
					self.object:remove()
					return
				end
				builtin_item.set_item( self, stack )
			end
		end
	end,
}

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, builtin_item)
minetest.register_entity(":__builtin:item", item)
