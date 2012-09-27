--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

Shape based on Multinode mod by mauvebic: http://minetest.net/forum/viewtopic.php?id=2398

CYLINDER Y

]]--


-- expose api
deploy_cylinder_y = {}


-- deploy
deploy_cylinder_y.deploy =  function(pos,placer,nodename,radius,height)

	-- set the pos to the center of the node
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
	
	-- check for space
	if deploy_nodes.check_for_space==true then
		for y=0,height do
		for x=-radius,radius do
		for z=-radius,radius do
			if x*x+z*z <= radius * radius + radius then
				if x~=0 or y~=0 or z~=0 then
					local checkpos={x=pos.x+x,y=pos.y+y,z=pos.z+z}
					local checknode = minetest.env:get_node(checkpos).name
					if checknode~="air" then
						minetest.chat_send_player(placer:get_player_name(), "[deploy_cylinder_y] no room to build because "..checknode.." is in the way at "..dump(checkpos).."")
						return
					end
				end
			end
		end
		end
		end
	end

	-- remove cylinder node
	minetest.env:remove_node(pos)

	-- build the cylinder
	local hollow = 1
	for y=0,height do
	for x=-radius,radius do
	for z=-radius,radius do
		if x*x+z*z >= (radius-hollow) * (radius-hollow) + (radius-hollow) and x*x+z*z <= radius * radius + radius then
			minetest.env:add_node({x=pos.x+x,y=pos.y+y,z=pos.z+z},{type="node",name=nodename})
		end
	end
	end
	end

end


-- register
deploy_cylinder_y.register = function(label,name,material,texture)

	-- small
	minetest.register_node("deploy_cylinder_y:"..name.."_small", {
		description = "Small "..label.." Cylinder",
		tiles = {texture.."^deploy_cylinder_y_small.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_cylinder_y.deploy(pos,placer,material,3,6)
		end,
	})
	minetest.register_craft({
		output = "deploy_cylinder_y:"..name.."_small",
		recipe = {
			{"deploy_cylinder_y:blueprint", material, material},
		},
	})

	-- medium
	minetest.register_node("deploy_cylinder_y:"..name.."_medium", {
		description = "Medium "..label.." Cylinder",
		tiles = {texture.."^deploy_cylinder_y_medium.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_cylinder_y.deploy(pos,placer,material,6,12)
		end,
	})
	minetest.register_craft({
		output = "deploy_cylinder_y:"..name.."_medium",
		recipe = {
			{"deploy_cylinder_y:blueprint", "deploy_cylinder_y:"..name.."_small", "deploy_cylinder_y:"..name.."_small"},
		},
	})

	-- large
	minetest.register_node("deploy_cylinder_y:"..name.."_large", {
		description = "Large "..label.." Cylinder",
		tiles = {texture.."^deploy_cylinder_y_large.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_cylinder_y.deploy(pos,placer,material,12,24)
		end,
	})
	minetest.register_craft({
		output = "deploy_cylinder_y:"..name.."_large",
		recipe = {
			{"deploy_cylinder_y:blueprint", "deploy_cylinder_y:"..name.."_medium", "deploy_cylinder_y:"..name.."_medium"},
		},
	})

end


-- register cylinders
deploy_cylinder_y.register("Dirt","dirt","default:dirt","default_dirt.png")
deploy_cylinder_y.register("Wood","wood","default:wood","default_wood.png")
deploy_cylinder_y.register("Brick","brick","default:brick","default_brick.png")
deploy_cylinder_y.register("Cobble","cobble","default:cobble","default_cobble.png")
deploy_cylinder_y.register("Stone","stone","default:stone","default_stone.png")
deploy_cylinder_y.register("Glass","glass","default:glass","default_glass.png")

-- blueprint
minetest.register_craftitem("deploy_cylinder_y:blueprint", {
	description = "Cylinder Y Blueprint",
	inventory_image = "deploy_nodes_blueprint.png^deploy_cylinder_y_blueprint.png",
})
minetest.register_craft({
	output = "deploy_cylinder_y:blueprint",
	recipe = {
		{"", "deploy_nodes:blueprint", ""},
		{"deploy_nodes:blueprint", "", "deploy_nodes:blueprint"},
		{"", "deploy_nodes:blueprint", ""},
	},
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
