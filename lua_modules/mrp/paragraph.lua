return function(paragraph, languages, columns)
	local paragraph_nodes = paragraph.nodes
	
	local i = 1
	local language = languages[1]
	repeat
		assert(paragraph_nodes[i], language)
		columns:append_list(i, paragraph_nodes[i])
		
		i = i + 1
		language = languages[i]
	until language == nil
	
	columns:balance()
end