local node_new = node.new
local string_utfvalues = string.utfvalues

local node_id_glue = node.id("glue")
local node_id_glyph = node.id("glyph")

return function(text, font_id, font)
	local head, last
	
	for cp in string_utfvalues(text) do
		local n
		if cp == 0x20 then
			n = node_new(node_id_glue)
			n.width = font.parameters.space
			n.shrink = font.parameters.space_shrink
			n.stretch = font.parameters.space_stretch
		else
			n = node_new(node_id_glyph)
			n.char = cp
			n.font = font_id
		end
		
		if not head then
			head = n
		end
		
		if last then
			last.next = n
		end
		
		last = n
	end
	
	return head, last
end