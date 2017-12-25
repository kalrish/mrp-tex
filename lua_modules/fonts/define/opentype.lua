local find_opentype = require("fonts.find.opentype")
local load_opentype = require("fonts.load.opentype")
local generate = require("fontlib.generate.convert")
local generator = require("fontlib.generator.opentype")
local define = font.define

return function(name, size)
	local tex_name = name
	
	local otf_path = find_opentype(name)
	if otf_path then
		local font = load_opentype(otf_path)
		if font then
			local tex_font_table = generate(font, generator, size)
			
			tex_font_table.name = tex_name
			tex_font_table.type = "real"
			tex_font_table.format = "opentype"
			tex_font_table.filename = otf_path
			tex_font_table.embedding = "subset"
			tex_font_table.cache = "no"
			
			return define(tex_font_table), tex_font_table
		end
	end
end
