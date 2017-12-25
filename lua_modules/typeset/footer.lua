local number2string = tostring
local node_new = node.new
local node_copy = node.copy
local node_hpack = node.hpack
local node_vpack = node.vpack
local mkword = require("typeset.mkword")

local node_id_glue = node.id("glue")

--[[
local string_upper = string.upper
local tex_romannumeral = tex.romannumeral
local number2string = function(n)
	return string_upper(tex_romannumeral(n))
end
]]

return function(n, vsize, hsize, font_id)
	local fill = node_new(node_id_glue)
	fill.stretch = 2^16
	fill.stretch_order = 2
	
	local hpack
	do
		local fill1 = node_copy(fill)
		
		local number = node_hpack((mkword(number2string(n), font_id)))
		
		local fill2 = node_copy(fill)
		
		fill1.next = number
		number.next = fill2
		
		hpack = node_hpack(fill1, hsize, "exactly")
	end
	
	local gap = node_new(node_id_glue)
	gap.width = 0
	
	fill.next = hpack
	hpack.next = gap
	
	return (node_vpack(fill, vsize, "exactly"))
end
