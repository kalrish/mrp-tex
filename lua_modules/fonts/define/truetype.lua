local find_truetype = require("fonts.find.truetype")
local load_truetype = require("fonts.load.truetype")
local generate = require("fontlib.generate.convert")
local generator = require("fontlib.generator.truetype")
local define = font.define

return function(name, size)
	local tex_name = name
	
	local ttf_path = find_truetype(name)
	if ttf_path then
		local font = load_truetype(ttf_path)
		if font then
			local tex_font_table = generate(font, generator, size)
			
			tex_font_table.name = tex_name
			tex_font_table.type = "real"
			tex_font_table.format = "truetype"
			tex_font_table.filename = ttf_path
			tex_font_table.embedding = "subset"
			tex_font_table.cache = "no"
			
			return define(tex_font_table), tex_font_table
		end
	end
end
