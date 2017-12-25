return function(page_layout, languages, options)
	if options.page_type == "left" or options.page_type == "right" then
		page_layout.page.width = page_layout.margins.lateral + page_layout.column.width + page_layout.inter_column_separation / 2
	elseif options.page_type == "central" or options.page_type == "internal" then
		page_layout.page.width = page_layout.column.width + page_layout.inter_column_separation
	end
	
	page_layout.chapter = {
		first = {
			column = {
				height = page_layout.page.height - page_layout.margins.top - page_layout.footskip - page_layout.footer.height - page_layout.margins.bottom
			}
		},
		rest = {
			column = {
				height = page_layout.page.height - page_layout.margins.top - page_layout.header.height - page_layout.headsep - page_layout.footskip - page_layout.footer.height - page_layout.margins.bottom
			}
		}
	}
end
