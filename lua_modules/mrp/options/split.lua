return function(languages, options)
	local i = 1
	local language = languages[1]
	repeat
		if language == options.language then
			options.selected_language_index = i
		end
		
		i = i + 1
		language = languages[i]
	until language == nil
	
	local language_no = i - 1
	
	if options.selected_language_index == 1 then
		options.page_type = "left"
	elseif options.selected_language_index == language_no then
		options.page_type = "right"
	elseif options.selected_language_index == math.ceil(language_no / 2) then
		options.page_type = "central"
	else
		options.page_type = "internal"
	end
end
