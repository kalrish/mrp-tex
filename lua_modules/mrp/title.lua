local node_new = node.new
local node_copy = node.copy
local node_flush_node = node.flush_node
local join_columns = require("mrp.join_columns")

local node_id_glue = node.id("glue")

return function(titles, page_layout, edition, edition_options)
	if edition == "digital" or edition == "print" then
		return (node.vpack(join_columns(titles, #titles, page_layout), page_layout.page.height, "exactly"))
	elseif edition == "split" then
		local title
		
		do
			local i = 1
			local t = titles[1]
			repeat
				if i == edition_options.selected_language_index then
					title = t
				else
					node_flush_node(t)
				end
				
				i = i + 1
				t = titles[i]
			until t == nil
		end
		
		local head
		
		if edition_options.page_type == "left" or edition_options.page_type == "right" then
			local lmargin = node_new(node_id_glue)
			lmargin.width = page_layout.margins.lateral
			
			local ics = node_new(node_id_glue)
			ics.width = page_layout.inter_column_separation / 2
			
			if edition_options.page_type == "left" then
				head = lmargin
				
				lmargin.next = title
				title.next = ics
			else
				head = ics
				
				ics.next = title
				title.next = lmargin
			end
		elseif edition_options.page_type == "internal" or edition_options.page_type == "central" then
			local ics1 = node_new(node_id_glue)
			ics1.width = page_layout.inter_column_separation / 2
			
			local ics2 = node_copy(ics1)
			
			head = ics1
			
			ics1.next = title
			title.next = ics2
		end
		
		return (node.hpack(head, page_layout.page.width, "exactly")), edition_options.language
	end
end
