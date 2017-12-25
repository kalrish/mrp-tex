local node_new = node.new
local node_copy = node.copy
local node_hpack = node.hpack
local mknodes = require("typeset.mknodes")

local node_id_glue = node.id("glue")

return function(chapter_title, hsize, font_id, font)
	local fill = node_new(node_id_glue)
	fill.stretch = 2^16
	fill.stretch_order = 1
	
	local title = node_hpack((mknodes(chapter_title, font_id, font)))
	--[[
	print(" ")
	print(chapter_title)
	print(title.height)
	print(title.depth)
	print(title.height + title.depth)
	]]
	title.height = 850000
	title.depth = 314000
	
	fill.next = title
	title.next = node_copy(fill)
	
	return (node_hpack(fill, hsize, "exactly"))
end
