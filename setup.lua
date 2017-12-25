local require = require
local tostring = tostring
local type = type
local node_new = node.new
local lua = lua
local tex = tex
local tex_get = tex.get
local tex_sp = tex.sp
local retrieve_code = require("utils.retrieve_code")

local node_id_glue = node.id("glue")
local outputmode = tex_get("outputmode")

local could_load = true

local page_layout = retrieve_code("page_layout")
do
	local node_setglue = node.setglue
	
	local get_glue = function(spec)
		local n = node_new(node_id_glue)
		
		if type(spec) == "table" then
			node_setglue(n, spec.width, spec.stretch, spec.shrink, spec.stretch_order, spec.shrink_order)
		else
			node_setglue(n, spec)
		end
		
		return n
	end
	
	page_layout.after_chapter_title_skip = get_glue(page_layout.after_chapter_title_skip)
	page_layout.after_section_heading_skip = get_glue(page_layout.after_section_heading_skip)
	page_layout.around_section_skip = get_glue(page_layout.around_section_skip)
	page_layout.inter_paragraph_skip = get_glue(page_layout.inter_paragraph_skip)
end

local fonts = {}
local font_id_part_title, font_part_title
local font_id_chapter_title, font_chapter_title
local font_id_chapter_title_unique, font_chapter_title_unique
local font_id_chapter_header, font_chapter_header
local font_id_section_heading, font_section_heading
local font_id_section_symbol
local font_id_paragraph_text, font_paragraph_text
local font_id_paragraph_noncore, font_paragraph_noncore
local font_id_page_number
do
	local tex_definefont = tex.definefont
	local load_pstype1_font = require("fonts.define.pstype1")
	local load_truetype_font = require("fonts.define.truetype")
	local load_opentype_font = require("fonts.define.opentype")
	
	local font_id_lmr10, font_lmr10
	local font_id_lmr10b, font_lmr10b
	local font_id_lmr10i, font_lmr10i
	local font_id_lmrsc10, font_lmrsc10
	local font_id_texgyrepagellab, font_texgyrepagellab
	local font_id_texgyrepagellabi, font_texgyrepagellabi
	
	local metatype1_font_format = outputmode * 0
	if metatype1_font_format == 0 then
		font_id_lmr10, font_lmr10 = load_pstype1_font("lmr10", 10 * 65536)
		font_id_lmr10b, font_lmr10b = load_pstype1_font("lmb10", 10 * 65536)
		font_id_lmr10i, font_lmr10i = load_pstype1_font("lmri10", 10 * 65536)
		font_id_lmrsc10, font_lmrsc10 = load_pstype1_font("lmcsc10", 10 * 65536)
		font_id_texgyrepagellab, font_texgyrepagellab = load_pstype1_font("qplb", 18 * 65536)
		font_id_texgyrepagellabi, font_texgyrepagellabi = load_pstype1_font("qplbi", 18 * 65536)
	else
		font_id_lmr10, font_lmr10 = load_opentype_font("lmroman10-regular", 10 * 65536)
		font_id_lmr10b, font_lmr10b = load_opentype_font("lmroman10-bold", 10 * 65536)
		font_id_lmr10i, font_lmr10i = load_opentype_font("lmroman10-italic", 10 * 65536)
		font_id_lmrsc10, font_lmrsc10 = load_opentype_font("lmromancaps10-regular", 10 * 65536)
		font_id_texgyrepagellab, font_texgyrepagellab = load_opentype_font("texgyrepagella-bold", 18 * 65536)
		font_id_texgyrepagellabi, font_texgyrepagellabi = load_opentype_font("texgyrepagella-bolditalic", 18 * 65536)
	end
	
	tex_definefont("lmrTENr", font_id_lmr10)
	tex_definefont("smallcaps", font_id_lmrsc10)
	
	--local font_id_trajanus, font_trajanus = load_truetype_font("trajanus", 36 * 65536)
	--local font_id_trajanus, font_trajanus = load_pstype1_font("trjnr10", 36 * 65536)
	local font_id_trajanus, font_trajanus = load_opentype_font("Cinzel-Regular", 36 * 65536)
	
	local load_n_store_truetype
	do
		local truetype_gettable = require("fonts.get_table.truetype")
		load_n_store_truetype = function(name)
			local font_table = truetype_gettable(name)
			if font_table then
				fonts[name] = font_table
			else
				could_load = false
			end
		end
	end
	
	local load_n_store_pstype1
	do
		local pstype1_gettable = require("fonts.get_table.pstype1")
		load_n_store_pstype1 = function(name)
			local font_table = pstype1_gettable(name)
			if font_table then
				fonts[name] = font_table
			else
				could_load = false
			end
		end
	end
	
	load_n_store_truetype("Augusta")
	--load_n_store_pstype1("Augusta")
	load_n_store_truetype("AlteSchwabacher")
	--load_n_store_pstype1("AlteSchwabacher")
	
	font_id_part_title = font_id_trajanus
	font_part_title = font_trajanus
	font_id_chapter_title = font_id_texgyrepagellab
	font_chapter_title = font_texgyrepagellab
	font_id_chapter_title_unique = font_id_texgyrepagellabi
	font_chapter_title_unique = font_texgyrepagellabi
	font_id_chapter_header = font_id_lmrsc10
	font_chapter_header = font_lmrsc10
	font_id_section_heading = font_id_lmr10b
	font_section_heading = font_lmr10b
	font_id_section_symbol = font_id_lmr10b
	font_id_paragraph_text = font_id_lmr10
	font_paragraph_text = font_lmr10
	font_id_paragraph_noncore = font_id_lmr10i
	font_paragraph_noncore = font_lmr10i
	font_id_page_number = font_id_lmr10
end

do
	local load_table = require("utils.load_table")
	local document, error_message = load_table(lua.name[1])
	if document then
		local languages = {
			"english",
			"spanish",
			"german"
		}
		local language_no = 3
		
		local edition
		local edition_options
		local shipout_function
		do -- options
			local string_match = string.match
			local tex_set = tex.set
			
			local jobname = tex_get("jobname")
			
			edition = string_match(jobname, "^mrp%-([^%-]+)")
			
			if edition == "digital" then
				shipout_function = require("typeset.shipout.digital")
				
				require("mrp.page_layout.digital")(page_layout, language_no)
				
				tex_set("pagewidth", page_layout.page.width)
				
				if outputmode == 1 then
					require("pdfinfo").setmetadata{
						author = document.author
					}
				end
			else
				if edition == "print" then
					require("mrp.page_layout.print")(page_layout, language_no)
				elseif edition == "split" then
					local language = string_match(jobname, "^mrp%-[^%-]+%-[^%-]+%-([^%-]+)")
					if language then
						edition_options = {
							language = language
						}
					else
						could_load = false
						
						tex.error("Language not specified in \\jobname")
					end
					
					require("mrp.options.split")(languages, edition_options)
					require("mrp.page_layout.split")(page_layout, languages, edition_options)
				end
				
				local stock = string_match(jobname, "^mrp%-[^%-]+%-([^%-]+)")
				if stock then
					stock = retrieve_code("papers")[stock]
					
					local stock_width = stock[1]
					local stock_height = stock[2]
					
					tex_set("pagewidth", stock_width)
					tex_set("pageheight", stock_height)
					
					shipout_function = require("typeset.shipout.print")(stock_width, stock_height)
				else
					could_load = false
					
					tex.error("stock paper not specified in jobname")
				end
			end
		end
		
		if could_load then
			do -- Propagate and infer parameters to complete document structure
				local i = 1
				local part = document.parts[1]
				while part do
					local colseprulewidth = part.output.tex[edition].colseprulewidth
					if colseprulewidth then
						local j = 1
						local chapter = part.chapters[1]
						while chapter do
							chapter.colseprulewidth = tex.sp(colseprulewidth)
							
							j = j + 1
							chapter = part.chapters[j]
						end
					end
					
					i = i + 1
					part = document.parts[i]
				end
			end
			
			local node_copy = node.copy
			local node_copy_list = node.copy_list
			local callback_register = callback.register
			local tex_getcount = tex.getcount
			local tex_setdimen = tex.setdimen
			local tex_getbox = tex.getbox
			local tex_setbox = tex.setbox
			local tex_sprint = tex.sprint
			local set_title = require("mrp.title")
			local set_part_title = require("mrp.part_title")
			local set_chapter = require("mrp.chapter")
			local typeset_part_title = require("typeset.part_title")
			local typeset_chapter_title = require("typeset.chapter_title")
			local typeset_chapter_header = require("typeset.chapter_header")
			local typeset_section_title = require("typeset.section_title")
			local typeset_section_heading = require("typeset.section_heading")
			local typeset_paragraph = require("typeset.paragraph")
			local typeset_footer = require("typeset.footer")
			
			tex_setdimen("paperheight", page_layout.page.height)
			tex_setdimen("columnwidth", page_layout.column.width)
			
			callback_register("define_font", require("fonts.callback")(fonts))
			
			local shipout = require("typeset.shipout.page")(shipout_function)
			
			local t = lua.get_functions_table()
			
			local part_no
			local chapter_no
			local element_no
			
			t[1] = function()
				local titles = {}
				
				do
					local i = 1
					local language = languages[1]
					repeat
						local title = node_copy(tex_getbox(i))
						
						titles[i] = title
						titles[language] = title
						
						tex_setbox(i, nil)
						
						i = i + 1
						language = languages[i]
					until language == nil
				end
				
				local page, used = set_title(titles, page_layout, edition, edition_options)
				
				shipout(page)
				
				part_no = 0
				
				do
					local i = 1
					local part = document.parts[1]
					while part do
						tex_sprint(-1, [[\luafunction4\relax]])
						
						i = i + 1
						part = document.parts[i]
					end
				end
			end
			
			local part
			
			t[4] = function()
				part_no = part_no + 1
				part = document.parts[part_no]
				
				shipout(set_part_title(typeset_part_title(part.name, height, width, font_id_part_title, font_part_title), page_layout, edition, edition_options))
				
				chapter_no = 0
				
				local part_chapters = part.chapters
				local i = 1
				local chapter = part_chapters[1]
				while chapter do
					tex_sprint(-1, [[\luafunction3\relax]])
					
					i = i + 1
					chapter = part_chapters[i]
				end
			end
			
			t[2] = function()
				-- Free allocated nodes
				
				local node_flush_node = node.flush_node
				
				node_flush_node(page_layout.after_chapter_title_skip)
				node_flush_node(page_layout.after_section_heading_skip)
				node_flush_node(page_layout.inter_paragraph_skip)
				node_flush_node(page_layout.around_section_skip)
			end
			
			local chapter
			local paragraphs_to_collect
			local paragraphs_to_collect_index
			
			local process_paragraph = function(paragraph)
				local paragraph_nodes = {}
				paragraph.nodes = paragraph_nodes
				
				local source_text = paragraph.output.text
				local source_tex
				local style
				if paragraph.output.tex then
					source_tex = paragraph.output.tex.code
					style = paragraph.output.tex.style
				end
				
				local call_collector = false
				
				local i = 1
				local language = languages[1]
				repeat
					if source_tex and source_tex[language] then
						tex_sprint(-1, [[\setbox]], tostring(i), [[=\vbox{\hsize=\columnwidth\relax\parsetup\parsetup]] .. language, [[ ]], source_tex[language], [[\par}]])
						call_collector = true
					elseif source_text and source_text[language] then
						paragraph_nodes[i] = typeset_paragraph(source_text[language], language, page_layout.column.width, font_id_paragraph_text, font_paragraph_text, font_id_paragraph_noncore, font_paragraph_noncore, style)
					else
						local inp = node_new(node_id_glue)
						inp.width = 0
						paragraph_nodes[i] = inp
					end
					
					i = i + 1
					language = languages[i]
				until language == nil
				
				if call_collector then
					paragraphs_to_collect_index = paragraphs_to_collect_index + 1
					paragraphs_to_collect[paragraphs_to_collect_index] = paragraph_nodes
					tex_sprint(-1, [[\luafunction5\relax]])
				end
			end
			
			local process_section = function(section)
				local vsize = 0
				local titles = {}
				
				do
					local i = 1
					local language = languages[1]
					repeat
						local section_title
						if section.output and section.output.tex and section.output.tex.title and section.output.tex.title[language] then
							section_title = section.output.tex.title[language]
						else
							section_title = section.title[language]
						end
						
						if section_title then
							section_title = typeset_section_title(section_title, page_layout.column.width, font_id_section_heading, font_section_heading)
							
							local total_height = section_title.height + section_title.depth
							if total_height > vsize then
								vsize = total_height
							end
							
							titles[i] = section_title
						end
						
						i = i + 1
						language = languages[i]
					until language == nil
				end
				
				do
					local i = 1
					local language = languages[1]
					repeat
						local section_title = titles[i]
						if section_title then
							section.title[language] = typeset_section_heading(section_title, page_layout.column.width, vsize, font_id_section_symbol)
						else
							local inp = node_new("vlist")
							inp.width = hsize
							inp.height = vsize
							
							section.title[language] = inp
						end
						
						i = i + 1
						language = languages[i]
					until language == nil
				end
				
				local section_paragraphs = section.paragraphs
				local j = 1
				local subordinate_paragraph = section_paragraphs[1]
				while subordinate_paragraph do
					process_paragraph(subordinate_paragraph)
					
					j = j + 1
					subordinate_paragraph = section_paragraphs[j]
				end
			end
			
			t[3] = function()
				chapter_no = chapter_no + 1
				chapter = part.chapters[chapter_no]
				
				do
					local chapter_name = chapter.name
					if type(chapter_name) == "string" then
						chapter.title = typeset_chapter_title(chapter_name, page_layout.column.width, font_id_chapter_title_unique, font_chapter_title_unique)
						chapter.header = typeset_chapter_header(chapter_name, page_layout.header.height, page_layout.column.width, font_id_chapter_header, font_chapter_header)
					else
						local titles = {}
						chapter.title = titles
						
						local headers = {}
						chapter.header = headers
						
						local i = 1
						local language = languages[1]
						repeat
							titles[i] = typeset_chapter_title(chapter_name[language], page_layout.column.width, font_id_chapter_title, font_chapter_title)
							headers[i] = typeset_chapter_header(chapter_name[language], page_layout.header.height, page_layout.column.width, font_id_chapter_header, font_chapter_header)
							
							i = i + 1
							language = languages[i]
						until language == nil
					end
				end
				
				paragraphs_to_collect = {}
				paragraphs_to_collect_index = 0
				element_no = 0
				
				local chapter_contents = chapter.contents
				local index = 0
				local i = 1
				local element = chapter_contents[1]
				while element do
					if element.type == "paragraph" then
						process_paragraph(element.inside)
					elseif element.type == "section" then
						process_section(element.inside)
					end
					
					i = i + 1
					element = chapter_contents[i]
				end
				
				tex_sprint(-1, [[\luafunction7\relax]])
			end
			
			t[5] = function()
				element_no = element_no + 1
				local paragraph_nodes = paragraphs_to_collect[element_no]
				
				local i = 1
				local language = languages[1]
				repeat
					local box_register_contents = tex_getbox(i)
					if box_register_contents then
						paragraph_nodes[i] = node_copy_list(box_register_contents.head)
						tex_setbox(i, nil)
					end
					
					i = i + 1
					language = languages[i]
				until language == nil
			end
			
			local footerer = function(page, vsize, hsize)
				return typeset_footer(tex_getcount(0)+page, vsize, hsize, font_id_page_number)
			end
			
			t[7] = function()
				local pages = set_chapter(chapter, page_layout, languages, edition, edition_options, footerer)
				
				local i = 1
				local page = pages[1]
				repeat
					shipout(page)
					
					i = i + 1
					page = pages[i]
				until page == nil
			end
		end
	else
		tex.error("Cannot load document",
			{
				error_message
			}
		)
	end
end