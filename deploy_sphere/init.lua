--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

Shape based on Multinode mod by mauvebic: http://minetest.net/forum/viewtopic.php?id=2398

SPHERE

]]--


-- expose api
deploy_sphere = {}


-- deploy
deploy_sphere.deploy =  function(pos,placer,nodename,radius)

	-- set the pos to the center of the node
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)

	-- check for space
	if deploy_nodes.check_for_space==true then
		for x=-radius,radius do
		for y=-radius,radius do
		for z=-radius,radius do
			if x*x+y*y+z*z <= radius * radius + radius then
				if x~=0 or y~=radius*-1 or z~=0 then
					local checkpos = {x=pos.x+x,y=pos.y+y+radius,z=pos.z+z}
					local checknode = minetest.env:get_node(checkpos).name
					if checknode~="air" then
						minetest.chat_send_player(placer:get_player_name(), "[deploy_sphere] no room to build because "..checknode.." is in the way at "..dump(checkpos).."")
						return
					end
				end
			end
		end
		end
		end
	end

	-- remove sphere node
	minetest.env:remove_node(pos)

	-- build the sphere
	local hollow = 1
	for x=-radius,radius do
	for y=-radius,radius do
	for z=-radius,radius do
		if x*x+y*y+z*z >= (radius-hollow) * (radius-hollow) + (radius-hollow) and x*x+y*y+z*z <= radius * radius + radius then
			minetest.env:add_node({x=pos.x+x,y=pos.y+y+radius,z=pos.z+z},{name=nodename})
		end
	end
	end
	end
	
end


-- register
deploy_sphere.register = function(label,name,material,texture)

	-- small
	minetest.register_node("deploy_sphere:"..name.."_small", {
		description = "Small "..label.." Sphere",
		tiles = {texture.."^deploy_sphere_small.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_sphere.deploy(pos,placer,material,3)
		end,
	})
	minetest.register_craft({
		output = "deploy_sphere:"..name.."_small",
		recipe = {
			{"", material, ""},
			{material, material, material},
			{"", material, ""},
		},
	})

	-- medium
	minetest.register_node("deploy_sphere:"..name.."_medium", {
		description = "Medium "..label.." Sphere",
		tiles = {texture.."^deploy_sphere_medium.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_sphere.deploy(pos,placer,material,6)
		end,
	})
	minetest.register_craft({
		output = "deploy_sphere:"..name.."_medium",
		recipe = {
			{"", "deploy_sphere:"..name.."_small", ""},
			{"deploy_sphere:"..name.."_small", "deploy_sphere:"..name.."_small", "deploy_sphere:"..name.."_small"},
			{"", "deploy_sphere:"..name.."_small", ""},
		},
	})

	-- large
	minetest.register_node("deploy_sphere:"..name.."_large", {
		description = "Large "..label.." Sphere",
		tiles = {texture.."^deploy_sphere_large.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_sphere.deploy(pos,placer,material,12)
		end,
	})
	minetest.register_craft({
		output = "deploy_sphere:"..name.."_large",
		recipe = {
			{"", "deploy_sphere:"..name.."_medium", ""},
			{"deploy_sphere:"..name.."_medium", "deploy_sphere:"..name.."_medium", "deploy_sphere:"..name.."_medium"},
			{"", "deploy_sphere:"..name.."_medium", ""},
		},
	})

end


-- register spheres
deploy_sphere.register("Dirt","dirt","default:dirt","default_dirt.png")
deploy_sphere.register("Wood","wood","default:wood","default_wood.png")
deploy_sphere.register("Brick","brick","default:brick","default_brick.png")
deploy_sphere.register("Cobble","cobble","default:cobble","default_cobble.png")
deploy_sphere.register("Stone","stone","default:stone","default_stone.png")
deploy_sphere.register("Glass","glass","default:glass","default_glass.png")


-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
