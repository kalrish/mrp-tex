local load_truetype = require("fontlib.load.truetype.fontforge")
local load_warnings = require("fonts.load_warnings")
local load_errors = require("fonts.load_errors")

return function(ttf_path)
	local r1, r2 = load_truetype(ttf_path)
	if r1 then
		load_warnings(ttf_path, r2)
		
		return r1
	else
		load_errors(r2)
	end
end
