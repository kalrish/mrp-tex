local tex_set = tex.set
local shipout_node = require("typeset.shipout.node")

return function(n)
	tex_set("pageheight", n.height + n.depth)
	
	shipout_node(n)
end