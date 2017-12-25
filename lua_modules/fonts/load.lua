local fontloader_to_table = fontloader.to_table
local fontloader_close = fontloader.close
--local print_table = require("utils.print_table")

local on_raw = false

return function(font, metrics, ...)
	local font_table
	
	if on_raw then
		font_table = font
	else
		font_table = fontloader_to_table(font)
		fontloader_close(font)
	end
	
	--print_table(font_table)
	
	metrics = metrics(font_table, ...)
	
	if on_raw then
		fontloader_close(font)
	end
	
	return metrics
end
