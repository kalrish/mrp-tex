return function(name)
	local fd, error_message = io.open(name, "rb")
	if fd then
		local contents = fd:read("*a")
		
		fd:close()
		
		if contents then
			contents = string.gsub(contents, "\r\n", "")
		else
			tex.error("Cannot read from file",
				{
					name
				}
			)
		end
		
		return contents
	else
		if not error_message then
			error_message = name
		end
		
		tex.error("Cannot open file for reading",
			{
				error_message
			}
		)
	end
end
