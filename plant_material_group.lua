-- Introduce a new custom group "earthbuild_plant_material" to items that can be used as platmaterial in recepies

-- Items in these goups should also be in the earthbuild_plant_material group
plant_material_groups = { 'grass', 'dry_grass', 'leaves' }
plant_material_names = { 'default:papyrus', 'farming:wheat', 'default:junglegrass' }

-- info/verbose don't seem to show up even with loglevel set to verbose
-- don't feel like chasing that down so loglevel is action for now
local LOG_LEVEL = "action"

minetest.register_on_mods_loaded( function()
	-- scan all registered items, set the plant_material_group if needed
	minetest.log( LOG_LEVEL, "Starting plant_material lookup..." )

	for _,plant_name in ipairs( plant_material_names ) do
		local item = minetest.registered_items[ plant_name ]
		if item == nil then
			minetest.log( LOG_LEVEL, "plant_material not found: "..plant_name )
			break
		end
		local groups = item.groups
		minetest.log( LOG_LEVEL, "plant_material name match: "..plant_name )
		groups[ "earthbuild_interact_plant_material" ] = 1
		minetest.override_item( plant_name , { groups = groups } )
	end

	for name, item in pairs( minetest.registered_items ) do

		-- check groups
		local groups = item.groups

		for group,level in pairs( groups ) do
			for _,plant_group in ipairs( plant_material_groups ) do
				if group == plant_group then
					minetest.log( LOG_LEVEL, "plant_material group match: "..name )
					-- add plant_mat to groups, override the original
					groups[ "earthbuild_interact_plant_material" ] = 1
					minetest.override_item( name , { groups = groups } )
				end
			end
		end
	end
	minetest.log( LOG_LEVEL, "Finished plant_material lookup." )
end )
