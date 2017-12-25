local loadfile = loadfile

local empty_ENV = setmetatable(
	{},
	{
		__newindex = function() end
	}
)

return function(path)
	local rv, err = loadfile(path, "b", empty_ENV)
	if rv then
		return rv()
	else
		return nil, err
	end
end
