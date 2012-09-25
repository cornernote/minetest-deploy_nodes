----------------------------------
Deploy Nodes for Minetest
----------------------------------

Copyright (C) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-deploy_nodes

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


----------------------------------
Description
----------------------------------

Provides craftable nodes that when placed turn into shapes or structures.

Features:
- easy to use - no chat commands, just nice easy structures that you can build by crafting and placing nodes
- lightweight - there are no ABMs, the nodes are created using after_place_node() in the node definitions
- grief-resistant - before nodes deploy a check is run to ensure that only air exists in the new area
- server friendly - all players can create impressive structures easily


----------------------------------
Crafts
----------------------------------
 
Spheres:

-M-   M=dirt/wood/brick/cobble/stone/glass
MMM   make bigger spheres by using small spere as the material
-M-


Cylinder Y:

-M-  M=dirt/wood/brick/cobble/stone/glass
M-M  make bigger cylinders by using small cylinders as the material
-M-


Mazes:

MMM  M=dirt/wood/brick/cobble/stone/glass
-MM  make bigger mazes by using small mazes as the material
MM-


Buildings:

S-S Small
WGW S=stone, W=wood, G=glass
WWW

S-S Medium/Large
WGW S=stone, W=wood, G=glass
MMM M=small/medium building


----------------------------------
How To Add New Stuff
----------------------------------

New Shapes:

Shapes should be deployed in their own mod folder as follows:

-- init.lua --
deploy_your_mod = {}
deploy_your_mod.deploy =  function(pos,placer)
	-- check for space
	if deploy_nodes.check_for_space==true and not enough_space then return end
	-- remove node
	minetest.env:remove_node(pos)
	-- build the thing
	-- ... your code here ...
end
minetest.register_node("deploy_your_mod:your_node", {
	after_place_node = deploy_your_mod.deploy,
})

-- depends.txt --
deploy_nodes


New Buildings:

Simply drop them into deploy_building/buildings/[large|medium|small].  The mod will detect them automatically as long as they have a ".we" extension.


----------------------------------
Credits
----------------------------------

mauvebic - author of multinode which provided code for spheres and cylinders
Echo - author of maze which provided code for spheres
neko259 - author of livehouse which inspired building spawning
