local find_opentype = require("fonts.find.opentype")
local load_opentype = require("fonts.load.opentype")
local fontloader_to_table = fontloader.to_table
local fontloader_close = fontloader.close

return function(name)
	local tex_name = name
	
	local otf_path = find_opentype(name)
	if otf_path then
		local font = load_opentype(otf_path)
		if font then
			local font_table = fontloader_to_table(font)
			
			fontloader_close(font)
			
			font_table.format = "opentype"
			font_table.filename = otf_path
			
			return font_table
		end
	end
end
