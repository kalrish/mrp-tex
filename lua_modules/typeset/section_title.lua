local string_utfvalues = string.utfvalues
local node_new = node.new
local node_hpack = node.hpack
local node_vpack = node.vpack
--local node_kerning = node.kerning
local node_ligaturing = node.ligaturing

local node_id_glue = node.id("glue")
local node_id_glyph = node.id("glyph")

return function(text, hsize, font_id, font)
	local first_line, last_line
	local line_head, line_tail
	
	-- FIXME: do kerning
	
	for cp in string_utfvalues(text) do
		if cp == 0x20 then
			local n = node_new(node_id_glue)
			n.width = font.parameters.space
			--n.shrink = font.parameters.space_shrink
			--n.stretch = font.parameters.space_stretch
			
			assert(line_head)
			assert(line_tail)
			
			line_tail.next = n
			line_tail = n
		elseif cp == 0x0A then
			--line_head = node_kerning(line_head)
			line_head = node_ligaturing(line_head)
			local line = node_hpack(line_head)
			line.height = 12 * 65536
			
			if last_line then
				last_line.next = line
				last_line = line
			else
				first_line = line
				last_line = line
			end
			
			line_head = nil
			line_tail = nil
		else
			local n = node_new(node_id_glyph)
			n.char = cp
			n.font = font_id
			
			if not line_head then
				line_head = n
			end
			
			if line_tail then
				line_tail.next = n
			end
			
			line_tail = n
		end
	end
	
	do
		--line_head = node_kerning(line_head)
		line_head = node_ligaturing(line_head)
		local line = node_hpack(line_head)
		line.height = 12 * 65536
		
		if last_line then
			last_line.next = line
		else
			first_line = line
		end
	end
	
	return (node_vpack(first_line))
end
