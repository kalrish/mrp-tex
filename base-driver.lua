local jobname = tex.get("jobname")

local edition, format = string.match(jobname, "^base%-([^-]+)-([^-]+)$")
if edition and format then
	tex.sprint(-1, {
			[[\input{base-]],
			format,
			[[.ini.tex}\input{base-]],
			edition,
			[[.ini.tex}\input{base-]],
			edition,
			[[-]],
			format,
			[[.ini.tex}]]
		}
	)
else
	tex.error("Cannot parse edition and format out of \\jobname")
end
