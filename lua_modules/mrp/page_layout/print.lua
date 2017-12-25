return function(page_layout, language_no)
	page_layout.page.width = 2 * page_layout.margins.lateral + language_no * page_layout.column.width + ( language_no - 1 ) * page_layout.inter_column_separation
	
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
