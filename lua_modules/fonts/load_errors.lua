return function(errors)
	if type(errors) ~= "table" then
		errors = {
			errors
		}
	end
	
	tex.error("Cannot open or load font file", errors)
end
