local node_new = node.new
local node_copy = node.copy
local node_dimensions = node.dimensions
local node_hpack = node.hpack

local node_id_glue = node.id("glue")
local node_id_rule = node.id("rule")

return function(columns, column_no, page_layout, seprulewidth)
	local head = node_new(node_id_glue)
	head.width = page_layout.margins.lateral
	
	do
		local sepruleheight
		local sepruledepth
		do
			sepruleheight = columns[1].height
			sepruledepth = columns[1].depth
		end
		
		local tail = head
		local i = 1
		
		::again::
			local column = columns[i]
			
			tail.next = column
			tail = column
			
			i = i + 1
			
			if i <= column_no then
				if seprulewidth then
					local ics1 = node_new(node_id_glue)
					ics1.width = page_layout.inter_column_separation / 2 - seprulewidth / 2
					
					local rule = node_new(node_id_rule)
					rule.width = seprulewidth
					rule.height = sepruleheight
					rule.depth = sepruledepth
					
					local ics2 = node_copy(ics1)
					
					tail.next = ics1
					ics1.next = rule
					rule.next = ics2
					
					tail = ics2
				else
					local ics = node_new(node_id_glue)
					ics.width = page_layout.inter_column_separation
					
					tail.next = ics
					tail = ics
				end
				
				goto again
			elseif i > column_no then
				local margin_lateral = node_new(node_id_glue)
				margin_lateral.width = page_layout.margins.lateral
				
				tail.next = margin_lateral
			end
	end
	
	return (node_hpack(head, page_layout.page.width, "exactly"))
end
