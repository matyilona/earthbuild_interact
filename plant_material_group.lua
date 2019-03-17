-- info/verbose don't seem to show up even with loglevel set to verbose
-- don't feel like chasing that down so loglevel is action for now
local LOG_LEVEL = "action"

local function register_custom_group( new_group, names, original_groups )
	minetest.register_on_mods_loaded( function()
		-- scan all registered items, set the plant_material_group if needed
		minetest.log( LOG_LEVEL, "Starting "..new_group.." lookup..." )

		for _,name in ipairs( names ) do
			local item = minetest.registered_items[ name ]
			if item == nil then
				minetest.log( LOG_LEVEL, new_group.." not found: "..name )
				break
			end
			local groups = item.groups
			minetest.log( LOG_LEVEL, new_group.." name match: "..name )
			groups[ new_group ] = 1
			minetest.override_item( name , { groups = groups } )
		end

		for name, item in pairs( minetest.registered_items ) do

			-- check groups
			local groups = item.groups

			for group,level in pairs( groups ) do
				for _,original_group in ipairs( original_groups ) do
					if group == original_group then
						minetest.log( LOG_LEVEL, new_group.." group match: "..name )
						-- add plant_mat to groups, override the original
						groups[ new_group ] = 1
						minetest.override_item( name , { groups = groups } )
					end
				end
			end
		end
		minetest.log( LOG_LEVEL, "Finished "..new_group.." lookup." )
	end )
end

-- Introduce a new custom group "earthbuild_plant_material" to items that can be used as plantmaterial in cob and other recepies
-- Items in this goups should also be in the earthbuild_plant_material group
local plant_material_groups = { 'grass', 'dry_grass', 'leaves' }
local plant_material_names = { 'default:papyrus', 'farming:wheat', 'default:junglegrass' } 
register_custom_group( "earthbuild_interact_plant_material", plant_material_names, plant_material_groups )

-- Items that can be used to make wattle higher. Wattle can only be started with sticks
local wattle_material_groups = { 'leaves', 'sapling' }
local wattle_material_names = { 'default:stick', 'default:papyrus' }
register_custom_group( "earthbuild_interact_wattle_material", wattle_material_names, wattle_material_groups )
