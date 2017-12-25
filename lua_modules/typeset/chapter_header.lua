local node_new = node.new
local node_copy = node.copy
local node_hpack = node.hpack
local node_vpack = node.vpack
local mkword = require("typeset.mkword")

local node_id_glue = node.id("glue")

return function(footer, vsize, hsize, font_id, font)
	local fill = node_new(node_id_glue)
	fill.stretch = 2^16
	fill.stretch_order = 2
	
	local hpack
	do
		local fill1 = node_copy(fill)
		
		local header = node_hpack((mkword(footer, font_id, font)))
		
		local fill2 = node_copy(fill)
		
		fill1.next = header
		header.next = fill2
		
		hpack = node_hpack(fill1, hsize, "exactly")
	end
	
	local gap = node_new(node_id_glue)
	gap.width = 0
	
	fill.next = hpack
	hpack.next = gap
	
	return (node_vpack(fill, vsize, "exactly"))
end
