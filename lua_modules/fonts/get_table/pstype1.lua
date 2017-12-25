local find_pstype1 = require("fonts.find.pstype1")
local load_pstype1 = require("fonts.load.pstype1")
local fontloader_to_table = fontloader.to_table
local fontloader_close = fontloader.close

return function(name)
	local tex_name = name
	
	local afm_path, pfx_path = find_pstype1(name)
	if afm_path then
		local font = load_pstype1(afm_path, pfx_path)
		if font then
			local font_table = fontloader_to_table(font)
			
			fontloader_close(font)
			
			font_table.format = "type1"
			font_table.filename = pfx_path
			
			return font_table
		end
	end
end
