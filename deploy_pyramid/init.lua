--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

Shape based on WorldEdit mod by Temperest: http://minetest.net/forum/viewtopic.php?id=2398

PYRAMID

]]--


-- expose api
deploy_pyramid = {}


-- deploy
deploy_pyramid.deploy =  function(pos,placer,nodename,height)

	-- check for space
	if deploy_nodes.check_for_space==true then
		for x=-height*0.5,height*0.5 do
		for y=0,height do
		for z=-height*0.5,height*0.5 do
			if x~=0 or y~=0 or z~=0 then
				local checkpos = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local checknode = minetest.env:get_node(checkpos).name
				if checknode~="air" then
					minetest.chat_send_player(placer:get_player_name(), "[deploy_pyramid] no room to build because "..checknode.." is in the way at "..dump(checkpos).."")
					return
				end
			end
		end
		end
		end
	end

	-- remove pyramid node
	minetest.env:remove_node(pos)

	-- build the pyramid
	local pos1 = {x=pos.x-height, y=pos.y, z=pos.z-height}
	local pos2 = {x=pos.x+height, y=pos.y+height, z=pos.z+height}
	local np = {x=0, y=pos1.y, z=0}
	local node = {name=nodename}
	while np.y <= pos2.y do --each vertical level of the pyramid
		np.x = pos1.x
		while np.x <= pos2.x do
			np.z = pos1.z
			while np.z <= pos2.z do
				minetest.env:add_node({x=np.x-height*0.5,y=np.y,z=np.z-height*0.5}, node)
				np.z = np.z + 1
			end
			np.x = np.x + 1
		end
		np.y = np.y + 1
		pos1.x, pos2.x = pos1.x + 1, pos2.x - 1
		pos1.z, pos2.z = pos1.z + 1, pos2.z - 1
	end

end


-- register
deploy_pyramid.register = function(label,name,material,texture)

	-- small
	minetest.register_node("deploy_pyramid:"..name.."_small", {
		description = "Small "..label.." Pyramid",
		tiles = {texture.."^deploy_pyramid_small.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_pyramid.deploy(pos,placer,material,3,1,1)
		end,
	})
	minetest.register_craft({
		output = "deploy_pyramid:"..name.."_small",
		recipe = {
			{"deploy_pyramid:blueprint", material, material},
		},
	})

	-- medium
	minetest.register_node("deploy_pyramid:"..name.."_medium", {
		description = "Medium "..label.." Pyramid",
		tiles = {texture.."^deploy_pyramid_medium.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_pyramid.deploy(pos,placer,material,6,2,2)
		end,
	})
	minetest.register_craft({
		output = "deploy_pyramid:"..name.."_medium",
		recipe = {
			{"deploy_pyramid:blueprint", "deploy_pyramid:"..name.."_small", "deploy_pyramid:"..name.."_small"},
		},
	})

	-- large
	minetest.register_node("deploy_pyramid:"..name.."_large", {
		description = "Large "..label.." Pyramid",
		tiles = {texture.."^deploy_pyramid_large.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_pyramid.deploy(pos,placer,material,12,4,3)
		end,
	})
	minetest.register_craft({
		output = "deploy_pyramid:"..name.."_large",
		recipe = {
			{"deploy_pyramid:blueprint", "deploy_pyramid:"..name.."_medium", "deploy_pyramid:"..name.."_medium"},
		},
	})

end


-- register pyramids
deploy_pyramid.register("Dirt","dirt","default:dirt","default_dirt.png")
deploy_pyramid.register("Wood","wood","default:wood","default_wood.png")
deploy_pyramid.register("Brick","brick","default:brick","default_brick.png")
deploy_pyramid.register("Cobble","cobble","default:cobble","default_cobble.png")
deploy_pyramid.register("Stone","stone","default:stone","default_stone.png")
deploy_pyramid.register("Glass","glass","default:glass","default_glass.png")


-- blueprint
minetest.register_craftitem("deploy_pyramid:blueprint", {
	description = "Pyramid Blueprint",
	inventory_image = "deploy_nodes_blueprint.png^deploy_pyramid_blueprint.png",
})
minetest.register_craft({
	output = "deploy_pyramid:blueprint",
	recipe = {
		{"", "deploy_nodes:blueprint", ""},
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", "deploy_nodes:blueprint"},
	},
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
