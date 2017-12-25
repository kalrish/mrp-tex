local node_copy = node.copy
local set_paragraph = require("mrp.paragraph")

return function(section, page_layout, languages, columns)
	local nof_languages = #languages
	
	do
		local page_layout_column_width = page_layout.column.width
		local page_layout_after_section_heading_skip = page_layout.after_section_heading_skip
		
		local i = 1
		local language = languages[1]
		repeat
			columns:append_node(i, section.title[language])
			columns:append_node(i, node_copy(page_layout_after_section_heading_skip))
			
			i = i + 1
			language = languages[i]
		until language == nil
	end
	
	columns:balance()
	
	do
		local page_layout_inter_paragraph_skip = page_layout.inter_paragraph_skip
		
		local i = 1
		local paragraphs = section.paragraphs
		local paragraph = paragraphs[1]
		if paragraph then
			::set_paragraph::
				set_paragraph(paragraph, languages, columns)
				
				i = i + 1
				paragraph = paragraphs[i]
				
				if paragraph then
					for j = 1, nof_languages do
						columns:append_node(j, node_copy(page_layout_inter_paragraph_skip))
					end
					
					goto set_paragraph
				end
		end
	end
	
	columns:balance()
end