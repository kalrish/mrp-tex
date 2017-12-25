local load_opentype = require("fontlib.load.opentype.fontforge")
local load_warnings = require("fonts.load_warnings")
local load_errors = require("fonts.load_errors")

return function(otf_path)
	local r1, r2 = load_opentype(otf_path)
	if r1 then
		load_warnings(otf_path, r2)
		
		return r1
	else
		load_errors(r2)
	end
end
