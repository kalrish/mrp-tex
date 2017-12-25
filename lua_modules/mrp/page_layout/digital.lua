return function(page_layout, language_no)
	page_layout.page.width = 2 * page_layout.margins.lateral + language_no * page_layout.column.width + ( language_no - 1 ) * page_layout.inter_column_separation
end
