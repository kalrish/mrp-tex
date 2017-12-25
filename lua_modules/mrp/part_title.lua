local node_copy = node.copy
local node_new = node.new
local node_hpack = node.hpack
local node_vpack = node.vpack
local node_flush_node = node.flush_node

local node_id_glue = node.id("glue")
local node_id_vlist = node.id("vlist")

return function(part_title, page_layout, edition, edition_options)
	local page
	
	if edition == "digital" or edition == "print" or ( edition == "split" and edition_options.page_type == "central" ) then
		local fill = node_new(node_id_glue)
		fill.stretch = 2^16
		fill.stretch_order = 2
		
		fill.next = part_title
		part_title.next = node_copy(fill)
		
		local hpack = node_hpack(fill, page_layout.page.width, "exactly")
		
		fill = node_copy(fill)
		
		fill.next = hpack
		hpack.next = node_copy(fill)
		
		page = node_vpack(fill, page_layout.page.height, "exactly")
	else
		page = node_new(node_id_vlist)
		page.height = page_layout.page.height
		page.width = page_layout.page.width
		
		node_flush_node(part_title)
	end
	
	return page
end