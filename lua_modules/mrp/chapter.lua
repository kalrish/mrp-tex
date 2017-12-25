local assert = assert
local math_ceil = math.ceil
local type = type
local node = node
local node_copy = node.copy
local node_new = node.new
local node_next = node.next
local node_hpack = node.hpack
local node_vpack = node.vpack
local node_free = node.free
local node_flush_node = node.flush_node
local node_get_attribute = node.get_attribute
local tex_setbox = tex.setbox
local tex_splitbox = tex.splitbox
local parcolumns_new = require("mrp.parcolumns").new
local set_paragraph = require("mrp.paragraph")
local set_section = require("mrp.section")
local join_columns = require("mrp.join_columns")

local node_id_glue = node.id("glue")
local node_id_hlist = node.id("hlist")
local node_id_vlist = node.id("vlist")

local width_plus_depth = function(n)
	return n.height + n.depth
end

local compute_node_height_methods = setmetatable(
	{
		[node_id_glue] = function(n)
			return n.width
		end,
		[node_id_hlist] = width_plus_depth,
		[node_id_vlist] = width_plus_depth
	},
	{
		__index = function(n)
			error("unhandled node type (id: " .. tostring(n.id) .. ", " .. node.type(n.id) .. ")")
		end
	}
)

local compute_node_height = function(n)
	return compute_node_height_methods[n.id](n)
end

local find_last_which_fits = function(n, height)
	local acc = 0
	
	local lastgood
	repeat
		local acc_with_this_one = acc + compute_node_height(n)
		
		if acc_with_this_one > height then
			return lastgood, acc, n
		end
		
		acc = acc_with_this_one
		
		lastgood = n
		n = node_next(n)
	until n == nil
	
	assert(acc < height)
	
	return lastgood, acc
end

local split_off_column = function(head, height)
	local last, cth = find_last_which_fits(head, height)
	
	local diff = height - cth
	
	local nexthead = node_next(last)
	if nexthead and nexthead.id == node_id_glue and ( nexthead.subtype == 2 or node.get_attribute(nexthead, 1) == 1 ) then
		nexthead = node_free(nexthead)
	end
	
	local fill = node_new(node_id_glue)
	fill.width = diff
	
	last.next = fill
	
	if nexthead and nexthead.id == node_id_glue then
		nexthead.width = nexthead.width - diff
		diff = 0
	end
	
	return nexthead, head, fill, diff
end

local break_columns = function(column_heads, page_layout)
	local columns = {}
	
	do
		local page = 1
		local column_no
		local column_width = page_layout.column.width
		
		do
			local height = page_layout.chapter.first.column.height
			
			local i = 1
			local column_head = column_heads[1]
			repeat
				local column_tail, column_height, new_head = find_last_which_fits(column_head, height)
				
				local diff = height - column_height
				
				local fill = node_new(node_id_glue)
				fill.width = diff
				
				column_tail.next = fill
				
				columns[i] = {}
				columns[i][page] = node_vpack(column_head, height, "exactly")
				
				if new_head then
					if new_head.id == node_id_glue and node_get_attribute(new_head, 1) ~= 2 then
						new_head = node_free(new_head)
					end
					
					column_heads[i] = new_head
				else
					column_heads[i] = nil
				end
				
				i = i + 1
				column_head = column_heads[i]
			until column_head == nil
			
			column_no = i - 1
		end
		
		do
			local height = page_layout.chapter.rest.column.height
			
			::another_page::
				local more = false
				
				page = page + 1
				
				local cols = parcolumns_new(column_no)
				
				do
					local j
					repeat
						j = column_no
						
						for i = 1, column_no do
							local column_head = column_heads[i]
							
							::start::
								if column_head then
									if node_get_attribute(column_head, 1) == 2 then
										column_heads[i] = node_free(column_head)
									else
										more = true
										
										local n = column_head
										
										::again::
											local nn = node_next(n)
											
											n.next = nil
											cols:append_node(i, n)
											
											n = nn
											
											if n then
												if node_get_attribute(n, 1) == 2 then
													n = node_free(n)
												else
													goto again
												end
											else
												j = j - 1
											end
										
										column_heads[i] = n
									end
								else
									j = j - 1
									
									column_heads[i] = nil
								end
						end
						
						if more then
							cols:balance()
						end
					until j <= 0
				end
				
				if more then
					column_heads = cols.heads
					
					for i = 1, column_no do
						local column_head = column_heads[i]
						if column_head then
							local column_tail, column_height, new_head = find_last_which_fits(column_head, height)
							
							local diff = height - column_height
							
							local fill = node_new(node_id_glue)
							fill.width = diff
							
							column_tail.next = fill
							
							local column = node_vpack(column_head, height, "exactly")
							column.width = column_width
							columns[i][page] = column
							
							if new_head then
								if new_head.id == node_id_glue and node_get_attribute(new_head, 1) ~= 2 then
									new_head = node_free(new_head)
								end
								
								column_heads[i] = new_head
							else
								column_heads[i] = nil
							end
						else
							columns[i][page] = false
						end
					end
					
					goto another_page
				end
		end
	end
	
	return columns
end

return function(chapter, page_layout, languages, edition, edition_options, footerer)
	local language_no = #languages
	
	local columns = parcolumns_new(language_no)
	
	do
		local chapter_title = chapter.title
		if type(chapter_title) == "table" then
			local i = 1
			local title = chapter_title[1]
			repeat
				columns:append_node(i, title)
				
				i = i + 1
				title = chapter_title[i]
			until title == nil
		else
			local center_column = math_ceil(language_no / 2)
			
			for i = 1, center_column-1 do
				local inp = node_new(node.id("hlist"))
				inp.width = page_layout.column.width
				columns:append_node(i, inp)
			end
			
			columns:append_node(center_column, chapter_title)
			
			for i = center_column+1, language_no do
				local inp = node_new(node.id("hlist"))
				inp.width = page_layout.column.width
				columns:append_node(i, inp)
			end
		end
	end
	
	columns:balance()
	
	do
		local after_chapter_title_skip = page_layout.after_chapter_title_skip
		for i = 1, language_no do
			columns:append_node(i, node_copy(after_chapter_title_skip))
		end
	end
	
	do
		local chapter_contents = chapter.contents
		
		local element = chapter_contents[1]
		if element then
			local last_was_sect
			
			if element.type == "paragraph" then
				set_paragraph(element.inside, languages, columns)
				last_was_sect = false
			elseif element.type == "section" then
				set_section(element.inside, page_layout, languages, columns)
				last_was_sect = true
			end
			
			local i = 2
			element = chapter_contents[2]
			local around_section_skip = page_layout.around_section_skip
			local inter_paragraph_skip = page_layout.inter_paragraph_skip
			while element do
				if element.type == "paragraph" then
					if last_was_sect then
						for j = 1, language_no do
							columns:append_node(j, node_copy(around_section_skip))
						end
						last_was_sect = false
					else
						for j = 1, language_no do
							columns:append_node(j, node_copy(inter_paragraph_skip))
						end
					end
					set_paragraph(element.inside, languages, columns)
				elseif element.type == "section" then
					for j = 1, language_no do
						columns:append_node(j, node_copy(around_section_skip))
					end
					set_section(element.inside, page_layout, languages, columns)
					last_was_sect = true
				end
				
				i = i + 1
				element = chapter_contents[i]
			end
		end
	end
	
	columns:balance()
	
	if edition == "digital" then
		local columns_t = columns.heads
		do
			local i = 1
			local column = columns_t[1]
			repeat
				columns_t[i] = node_vpack(column)
				
				i = i + 1
				column = columns_t[i]
			until column == nil
		end
		
		do
			local chapter_header = chapter.header
			if type(chapter_header) == "table" then
				local i = 1
				local language = languages[1]
				repeat
					node_flush_node(chapter_header[i])
					
					i = i + 1
					language = languages[i]
				until language == nil
			else
				node_flush_node(chapter_header)
			end
		end
		
		local topmargin = node_new(node_id_glue)
		topmargin.width = page_layout.margins.top
		
		local hpack = join_columns(columns_t, language_no, page_layout, nil)
		
		local bottommargin = node_new(node_id_glue)
		bottommargin.width = page_layout.margins.bottom
		
		topmargin.next = hpack
		hpack.next = bottommargin
		
		return {
			(node_vpack(topmargin))
		}
	elseif edition == "print" then
		local headers
		do
			local chapter_header = chapter.header
			if type(chapter_header) == "table" then
				headers = chapter_header
			else
				headers = {}
				
				local inplace = node_new(node_id_glue)
				inplace.width = page_layout.column.width
				
				local center = math_ceil(language_no / 2)
				
				for i = 1, center-1 do
					headers[i] = node_copy(inplace)
				end
				
				headers[center] = chapter_header
				
				for i = center+1, language_no do
					headers[i] = node_copy(inplace)
				end
				
				node_flush_node(inplace)
			end
		end
		
		local cols = break_columns(columns.heads, page_layout)
		
		local add_headers = false
		local page = 1
		local pages = {}
		
		::again::
			local columns_t = {}
			local more = false
			
			for i = 1, language_no do
				local column = cols[i][page]
				if column then
					columns_t[i] = column
					
					more = true
				else
					local inplace = node_new(node_id_glue)
					inplace.width = page_layout.column.width
					
					columns_t[i] = inplace
				end
			end
			
			if more then
				local topmargin = node_new(node_id_glue)
				topmargin.width = page_layout.margins.top
				
				local textcols = join_columns(columns_t, language_no, page_layout, chapter.colseprulewidth)
				
				local footskip = node_new(node_id_glue)
				footskip.width = page_layout.footskip
				
				local footer = footerer(page, page_layout.footer.height, page_layout.page.width)
				
				local bottommargin = node_new(node_id_glue)
				bottommargin.width = page_layout.margins.bottom
				
				local fill = node_new(node_id_glue)
				fill.stretch = 2^16
				fill.stretch_order = 2
				
				if add_headers then
					local headers_t = {}
					
					for i = 1, language_no do
						headers_t[i] = node_copy(headers[i])
					end
					
					local header = join_columns(headers_t, language_no, page_layout)
					
					local headsep = node_new(node_id_glue)
					headsep.width = page_layout.headsep
					
					topmargin.next = header
					header.next = headsep
					headsep.next = textcols
				else
					topmargin.next = textcols
				end
				
				textcols.next = footskip
				footskip.next = footer
				footer.next = bottommargin
				bottommargin.next = fill
				
				pages[page] = (node_vpack(topmargin, page_layout.page.height, "exactly"))
				
				page = page + 1
				add_headers = true
				
				goto again
			end
		
		for i = 1, language_no do
			node_flush_node(headers[i])
			node_flush_node(columns_t[i])
		end
		
		return pages
	elseif edition == "split" then
		local header
		do
			local chapter_header = chapter.header
			if type(chapter_header) == "table" then
				local i = 1
				local language = languages[1]
				repeat
					if language == edition_options.language then
						header = chapter_header[i]
					else
						node_flush_node(chapter_header[i])
					end
					
					i = i + 1
					language = languages[i]
				until language == nil
			else
				if edition_options.page_type == "central" then
					header = chapter_header
				else
					header = node_new(node_id_glue)
					header.width = page_layout.header.height
					
					node_flush_node(chapter_header)
				end
			end
		end
		
		local cols = break_columns(columns.heads, page_layout)
		
		local selected_language_index = edition_options.selected_language_index
		
		do
			for i = 1, selected_language_index-1 do
				local langcols = cols[i]
				
				local j = 1
				local page = langcols[1]
				repeat
					node_flush_node(page)
					
					j = j + 1
					page = langcols[j]
				until page == nil
			end
			for i = selected_language_index+1, language_no do
				local langcols = cols[i]
				
				local j = 1
				local page = langcols[1]
				repeat
					node_flush_node(page)
					
					j = j + 1
					page = langcols[j]
				until page == nil
			end
		end
		
		cols = cols[selected_language_index]
		
		local page = 1
		local pages = {}
		local column = cols[1]
		
		local add_headers = false
		
		::again::
			if edition_options.page_type == "central" then
				local footskip = node_new(node_id_glue)
				footskip.width = page_layout.footskip
				
				local footer = footerer(page, page_layout.footer.height, page_layout.column.width)
				
				column.next = footskip
				footskip.next = footer
				
				column = node_vpack(column)
			end
			
			if add_headers then
				local header = node_copy(header)
				
				local headsep = node_new(node_id_glue)
				headsep.width = page_layout.headsep
				
				header.next = headsep
				headsep.next = column
				
				column = node_vpack(header)
			end
			
			local text_hpack
			do
				local head
				
				if edition_options.page_type == "left" or edition_options.page_type == "right" then
					local lmargin = node_new(node_id_glue)
					lmargin.width = page_layout.margins.lateral
					
					local ics = node_new(node_id_glue)
					ics.width = page_layout.inter_column_separation / 2
					
					if edition_options.page_type == "left" then
						head = lmargin
						
						lmargin.next = column
						column.next = ics
					else
						head = ics
						
						ics.next = column
						column.next = lmargin
					end
				elseif edition_options.page_type == "internal" or edition_options.page_type == "central" then
					local ics = node_new(node_id_glue)
					ics.width = page_layout.inter_column_separation / 2
					
					head = ics
					
					ics.next = column
					column.next = node_copy(ics)
				end
				
				text_hpack = node_hpack(head, page_layout.page.width, "exactly")
			end
			
			local topmargin = node_new(node_id_glue)
			topmargin.width = page_layout.margins.top
			
			local bottommargin = node_new(node_id_glue)
			bottommargin.width = page_layout.margins.bottom
			
			local fill = node_new(node_id_glue)
			fill.stretch = 2^16
			fill.stretch_order = 2
			
			topmargin.next = text_hpack
			text_hpack.next = bottommargin
			bottommargin.next = fill
			
			pages[page] = (node_vpack(topmargin, page_layout.page.height, "exactly"))
			
			add_headers = true
			
			page = page + 1
			column = cols[page]
			
			if column then
				goto again
			end
		
		node_flush_node(header)
		
		return pages
	end
end