local string_utfvalues = string.utfvalues
local node_new = node.new
local node_hpack = node.hpack
local node_slide = node.slide
local node_tail = node.tail
local node_kerning = node.kerning
local node_ligaturing = node.ligaturing
--local tex_set = tex.set
local tex_linebreak = tex.linebreak

local node_id_disc = node.id("disc")
local node_id_glue = node.id("glue")
local node_id_glyph = node.id("glyph")
local node_id_penalty = node.id("penalty")

local command_noncore = {0x6E, 0x6F, 0x6E, 0x63, 0x6F, 0x72, 0x65}
local command_italic = {0x69, 0x74, 0x61, 0x6C, 0x69, 0x63}
local compare_command = function(provided, against)
	local i = 1
	local cp1 = provided[1]
	local cp2 = against[1]
	
	::again::
		if cp1 ~= cp2 then
			return false
		end
		
		i = i + 1
		cp1 = provided[i]
		cp2 = against[i]
		
		if cp1 then
			if cp2 then
				if cp1 == cp2 then
					goto again
				else
					return false
				end
			else
				return false
			end
		else
			if cp2 then
				return false
			end
		end
	
	return true
end

return function(text, language, hsize, font_id_normal, font_normal, font_id_noncore, font_noncore, style)
	local head, last
	
	--head = node.new("local_par")
	if style == "contentran" then
		local entrysym = node_new(node_id_glyph)
		entrysym.char = 0xBB
		entrysym.font = font_id_normal
		
		head = node_hpack(entrysym)
		
		local space = node_new(node_id_glue)
		space.width = 5 * 65536
		
		head.next = space
		
		last = space
	end
	
	do
		local mode = "inword"
		local skip = false
		local reading_command = false
		local command
		
		local font_id = font_id_normal
		local font = font_normal
		
		for cp in string_utfvalues(text) do
			if skip then
				skip = false
			else
				::start::
				
				if reading_command then
					if cp == 0x3A then
						reading_command = false
						
						if compare_command(command, command_noncore) then
							font_id = font_id_noncore
							font = font_noncore
						elseif compare_command(command, command_italic) then
							font_id = font_id_noncore
							font = font_noncore
						end
					else
						table.insert(command, cp)
					end
				else
					if cp == 0x7B then
						reading_command = true
						command = {}
					elseif cp == 0x7D then
						-- FIXME: proper command deactivation
						font_id = font_id_normal
						font = font_normal
					elseif mode == "inword" then
						if cp == 0x2D then
							local n = node_new(node_id_disc)
							
							local pre = node_new(node_id_glyph)
							pre.char = 0x2D
							pre.font = font_id
							
							n.pre = pre
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
						elseif cp == 0x20 then
							local n = node_new(node_id_glue)
							n.subtype = 13
							n.width = font.parameters.space
							n.shrink = font.parameters.space_shrink
							n.stretch = font.parameters.space_stretch
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
							
							mode = "interword"
						elseif cp == 0x7E then
							local n = node_new(node_id_glue)
							n.subtype = 13
							n.width = font.parameters.space
							n.shrink = font.parameters.space_shrink
							n.stretch = font.parameters.space_stretch
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
							
							mode = "interword"
						elseif cp == 0x2C then
							mode = "comma"
							
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = cp
							n.font = font_id
							n.left = 0x2D
							n.right = 0x2D
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
						elseif cp == 0x3B then
							mode = "semicolon"
							
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = 0x3B
							n.font = font_id
							n.left = 0x2D
							n.right = 0x2D
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
						elseif cp == 0x2E then
							mode = "fullstop"
							
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = cp
							n.font = font_id
							n.left = 0x2D
							n.right = 0x2D
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
						elseif cp == 0x2014 then
							local ls = node_new(node_id_glue)
							ls.width = font.parameters.space * 1.2
							ls.shrink = font.parameters.space_shrink
							ls.stretch = font.parameters.space_stretch * 1.3
							
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = 0x2014
							n.font = font_id
							
							local rs = node_new(node_id_glue)
							rs.width = font.parameters.space * 1.2
							rs.shrink = font.parameters.space_shrink
							rs.stretch = font.parameters.space_stretch * 1.3
							
							last.next = ls
							ls.next = n
							n.next = rs
							
							last = rs
						else
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = cp
							n.font = font_id
							n.left = 0x2D
							n.right = 0x2D
							
							if not head then
								head = n
								last = n
							end
							
							last.next = n
							
							last = n
						end
					elseif mode == "comma" then
						if cp == 0x20 then
							local n = node_new(node_id_glue)
							n.subtype = 13
							n.width = font.parameters.space * 1.1
							n.shrink = font.parameters.space_shrink * 0.9
							n.stretch = font.parameters.space_stretch * 1.1
							
							last.next = n
							last = n
							
							mode = "interword"
						end
					elseif mode == "semicolon" then
						if cp == 0x20 then
							local n = node_new(node_id_glue)
							n.subtype = 13
							n.width = font.parameters.space * 1.15
							n.shrink = font.parameters.space_shrink * 0.85
							n.stretch = font.parameters.space_stretch * 1.2
							
							last.next = n
							last = n
							
							mode = "interword"
						end
					elseif mode == "fullstop" then
						if cp == 0x20 then
							local n = node_new(node_id_glue)
							n.subtype = 13
							n.width = font.parameters.space * 1.2
							n.shrink = font.parameters.space_shrink * 0.8
							n.stretch = font.parameters.space_stretch * 1.3
							
							last.next = n
							last = n
							
							mode = "interword"
						end
					elseif mode == "interword" then
						if cp == 0x2013 then
							local n = node_new(node_id_glyph)
							n.subtype = 0
							n.char = 0x2013
							n.font = font_id
							
							last.next = n
							
							last = n
						else
							mode = "inword"
							goto start
						end
					else
						assert(false)
					end
				end
			end
		end
	end
	
	local penalty = node_new(node_id_penalty, 2)
	penalty.penalty = 10000
	
	local parfillskip = node_new(node_id_glue, 15)
	parfillskip.stretch = 2^16
	parfillskip.stretch_order = 2
	
	last.next = penalty
	penalty.next = parfillskip
	
	node_slide(head)
	
	head = node_kerning(head)
	head = node_ligaturing(head)
	--tex_set("baselineskip", 14 * 65536)
	head = tex_linebreak(head,
		{
			hsize = hsize,
			--protrudechars = 1
		}
	)
	
	return head, node_tail(head)
end