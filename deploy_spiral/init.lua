--[[

Deploy Nodes for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes
License: GPLv3

SPIRAL

]]--


-- expose api
deploy_spiral = {}


-- deploy
deploy_spiral.deploy =  function(pos,placer,nodename,width,height,spacer)

	-- set the pos to the center of the node
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)

	-- check for space
	if deploy_nodes.check_for_space==true then
		for x=0,width*spacer do
		for y=0,height do
		for z=0,width*spacer do
			if x~=0 or y~=0 or z~=0 then
				local checkpos = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local checknode = minetest.env:get_node(checkpos).name
				if checknode~="air" then
					minetest.chat_send_player(placer:get_player_name(), "[deploy_spiral] no room to build because "..checknode.." is in the way at "..dump(checkpos).."")
					return
				end
			end
		end
		end
		end
	end

	-- remove spiral node
	minetest.env:remove_node(pos)

	-- build the spiral
	-- spiral matrix - http://rosettacode.org/wiki/Spiral_matrix#Lua
	av, sn = math.abs, function(s) return s~=0 and s/av(s) or 0 end
	local function sindex(z, x) -- returns the value at (x, z) in a spiral that starts at 1 and goes outwards
		if z == -x and z >= x then return (2*z+1)^2 end
		local l = math.max(av(z), av(x))
		return (2*l-1)^2+4*l+2*l*sn(x+z)+sn(z^2-x^2)*(l-(av(z)==l and sn(z)*x or sn(x)*z)) -- OH GOD WHAT
	end
	local function spiralt(side)
		local ret, id, start, stop = {}, 0, math.floor((-side+1)/2), math.floor((side-1)/2)
		for i = 1, side do
			for j = 1, side do
				local id = side^2 - sindex(stop - i + 1,start + j - 1)
				ret[id] = {x=i,z=j}
			end
		end
		return ret
	end
	-- connect the joined parts
	local spiral = spiralt(width)
	height = tonumber(height)
	if height < 1 then height = 1 end
	spacer = tonumber(spacer)-1
	if spacer < 1 then spacer = 1 end
	local node = {name=nodename}
	local np,lp
	for y=0,height do
		lp = nil
		for _,v in ipairs(spiral) do
			np = {x=pos.x+v.x*spacer, y=pos.y+y, z=pos.z+v.z*spacer}
			if lp~=nil then
				if lp.x~=np.x then 
					if lp.x<np.x then 
						for i=lp.x+1,np.x do
							minetest.env:add_node({x=i, y=np.y, z=np.z}, node)
						end
					else
						for i=np.x,lp.x-1 do
							minetest.env:add_node({x=i, y=np.y, z=np.z}, node)
						end
					end
				end
				if lp.z~=np.z then 
					if lp.z<np.z then 
						for i=lp.z+1,np.z do
							minetest.env:add_node({x=np.x, y=np.y, z=i}, node)
						end
					else
						for i=np.z,lp.z-1 do
							minetest.env:add_node({x=np.x, y=np.y, z=i}, node)
						end
					end
				end
			end
			lp = np
		end
	end
	
end


-- register
deploy_spiral.register = function(label,name,material,texture)

	-- small
	minetest.register_node("deploy_spiral:"..name.."_small", {
		description = "Small "..label.." Spiral",
		tiles = {texture.."^deploy_spiral_small.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_spiral.deploy(pos,placer,material,5,1,1)
		end,
	})
	minetest.register_craft({
		output = "deploy_spiral:"..name.."_small",
		recipe = {
			{"deploy_spiral:blueprint", material, material},
		},
	})

	-- medium
	minetest.register_node("deploy_spiral:"..name.."_medium", {
		description = "Medium "..label.." Spiral",
		tiles = {texture.."^deploy_spiral_medium.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_spiral.deploy(pos,placer,material,10,3,2)
		end,
	})
	minetest.register_craft({
		output = "deploy_spiral:"..name.."_medium",
		recipe = {
			{"deploy_spiral:blueprint", "deploy_spiral:"..name.."_small", "deploy_spiral:"..name.."_small"},
		},
	})

	-- large
	minetest.register_node("deploy_spiral:"..name.."_large", {
		description = "Large "..label.." Spiral",
		tiles = {texture.."^deploy_spiral_large.png"},
		groups = {dig_immediate=3},
		after_place_node = function(pos,placer)
			deploy_spiral.deploy(pos,placer,material,20,5,3)
		end,
	})
	minetest.register_craft({
		output = "deploy_spiral:"..name.."_large",
		recipe = {
			{"deploy_spiral:blueprint", "deploy_spiral:"..name.."_medium", "deploy_spiral:"..name.."_medium"},
		},
	})

end


-- register spirals
deploy_spiral.register("Dirt","dirt","default:dirt","default_dirt.png")
deploy_spiral.register("Wood","wood","default:wood","default_wood.png")
deploy_spiral.register("Brick","brick","default:brick","default_brick.png")
deploy_spiral.register("Cobble","cobble","default:cobble","default_cobble.png")
deploy_spiral.register("Stone","stone","default:stone","default_stone.png")
deploy_spiral.register("Glass","glass","default:glass","default_glass.png")


-- blueprint
minetest.register_craftitem("deploy_spiral:blueprint", {
	description = "Spiral Blueprint",
	inventory_image = "deploy_spiral_blueprint.png",
})
minetest.register_craft({
	output = "deploy_spiral:blueprint",
	recipe = {
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", "deploy_nodes:blueprint"},
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", ""},
		{"deploy_nodes:blueprint", "deploy_nodes:blueprint", ""},
	},
})

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))
