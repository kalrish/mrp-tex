local find_truetype = require("fonts.find.truetype")
local load_truetype = require("fonts.load.truetype")
local fontloader_to_table = fontloader.to_table
local fontloader_close = fontloader.close

return function(name)
	local tex_name = name
	
	local ttf_path = find_truetype(name)
	if ttf_path then
		local font = load_truetype(ttf_path)
		if font then
			local font_table = fontloader_to_table(font)
			
			fontloader_close(font)
			
			font_table.format = "truetype"
			font_table.filename = ttf_path
			
			return font_table
		end
	end
end
