local generate_raw = require("fonts.generate.raw")
--local generate_convert = require("fonts.generate.convert")

return function(font, metrics, ...)
	return generate_raw(font, metrics, ...)
	--return generate_convert(font, metrics, ...)
end
