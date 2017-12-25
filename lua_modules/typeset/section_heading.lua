local string_utfvalues = string.utfvalues
local node_new = node.new
local node_copy = node.copy
local node_hpack = node.hpack
local node_vpack = node.vpack

local node_id_glue = node.id("glue")
local node_id_glyph = node.id("glyph")

return function(title, hsize, vsize, font_id_ss)
	do
		local fill1 = node_new(node_id_glue)
		fill1.stretch = 2^16
		fill1.stretch_order = 2
		
		local fill2 = node_copy(fill1)
		
		fill1.next = title
		title.next = fill2
		
		title = node_vpack(fill1, vsize, "exactly")
	end
	
	do
		local fill1 = node_new(node_id_glue)
		fill1.stretch = 2^16
		fill1.stretch_order = 2
		
		local fill2 = node_copy(fill1)
		
		fill1.next = title
		title.next = fill2
		
		title = node_hpack(fill1, hsize * 0.65, "exactly")
	end
	
	local section_symbol_box_l, section_symbol_box_r
	do
		local section_symbol_box_hsize = hsize * 0.135
		
		do
			local section_symbol = node_new(node_id_glyph)
			section_symbol.char = 0x00A7
			section_symbol.subtype = 1 --256
			section_symbol.font = font_id_ss
			
			local section_symbol_boxie = node_new("hlist", "box")
			section_symbol_boxie.width = section_symbol.width
			section_symbol_boxie.height = section_symbol.height
			section_symbol_boxie.depth = section_symbol.depth
			section_symbol_boxie.head = section_symbol
			section_symbol_boxie.dir = "TLT"
			
			local fill = node_new(node_id_glue)
			fill.stretch = 2^16
			fill.stretch_order = 2
			
			section_symbol_boxie.next = fill
			
			section_symbol_box_l = node_hpack(section_symbol_boxie, section_symbol_box_hsize, "exactly")
			
			
			local fill1 = node_new(node_id_glue)
			fill1.stretch = 2^16
			fill1.stretch_order = 2
			
			local fill2 = node_copy(fill1)
			
			fill1.next = section_symbol_box_l
			section_symbol_box_l.next = fill2
			
			section_symbol_box_l = node_vpack(fill1, vsize, "exactly")
		end
		
		do
			local fill = node_new(node_id_glue)
			fill.stretch = 2^16
			fill.stretch_order = 2
			
			local section_symbol = node_new(node_id_glyph)
			section_symbol.char = 0x00A7
			section_symbol.subtype = 1 --256
			section_symbol.font = font_id_ss
			
			local section_symbol_boxie = node_new("hlist", "box")
			section_symbol_boxie.width = section_symbol.width
			section_symbol_boxie.height = section_symbol.height
			section_symbol_boxie.depth = section_symbol.depth
			section_symbol_boxie.head = section_symbol
			section_symbol_boxie.dir = "TLT"
			
			fill.next = section_symbol_boxie
			
			section_symbol_box_r = node_hpack(fill, section_symbol_box_hsize, "exactly")
			
			
			local fill1 = node_new(node_id_glue)
			fill1.stretch = 2^16
			fill1.stretch_order = 2
			
			local fill2 = node_copy(fill1)
			
			fill1.next = section_symbol_box_r
			section_symbol_box_r.next = fill2
			
			section_symbol_box_r = node_vpack(fill1, vsize, "exactly")
		end
	end
	
	local fill1 = node_new(node_id_glue)
	fill1.stretch = 2^16
	fill1.stretch_order = 2
	
	local fill2 = node_copy(fill1)
	
	fill1.next = section_symbol_box_l
	section_symbol_box_l.next = title
	title.next = section_symbol_box_r
	section_symbol_box_r.next = fill2
	
	return (node_hpack(fill1, hsize, "exactly"))
end