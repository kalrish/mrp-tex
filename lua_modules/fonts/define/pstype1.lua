local find_pstype1 = require("fonts.find.pstype1")
local load_pstype1 = require("fonts.load.pstype1")
local generate = require("fontlib.generate.raw")
local generator = require("fontlib.generator.postscript-type1")
local define = font.define

local output_pdf = tex.get("outputmode") == 1

return function(name, size)
	local tex_name = name
	
	local afm_path, pfx_path = find_pstype1(name)
	if afm_path then
		local font = load_pstype1(afm_path, pfx_path)
		if font then
			local tex_font_table = generate(font, generator, size)
			
			tex_font_table.name = tex_name
			tex_font_table.type = "real"
			tex_font_table.format = "type1"
			tex_font_table.filename = pfx_path
			tex_font_table.embedding = "subset"
			tex_font_table.cache = "no"
			
			if output_pdf and tex_font_table.encodingbytes == 1 then
				pdf_mapline("+" .. name .. " " .. tex_font_table.psname .. " <" .. pfx_path)
			end
			
			return define(tex_font_table), tex_font_table
		end
	end
end
