local node_new = node.new
local string_utfvalues = string.utfvalues

local node_id_glyph = node.id("glyph")

return function(text, font_id)
	local head, last
	
	for cp in string_utfvalues(text) do
		local n = node_new(node_id_glyph)
		n.char = cp
		n.font = font_id
		
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
