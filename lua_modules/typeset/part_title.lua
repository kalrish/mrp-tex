local node_hpack = node.hpack
local mknodes = require("typeset.mknodes")

return function(part_title, height, width, font_id, font)
	--return (node_hpack((mknodes(part_title, font_id, font))))
	return (node_hpack((mknodes(string.upper(part_title), font_id, font))))
	--return (node_hpack((mknodes(string.lower(part_title), font_id, font))))
end
