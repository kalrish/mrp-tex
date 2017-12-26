tex.enableprimitives("",
	{
		"pdfextension"
	}
)

pdf.setminorversion(7)
pdf.setcompresslevel(9)
pdf.setobjcompresslevel(9)
pdf.setinclusionerrorlevel(1)
pdf.setdecimaldigits(7)

local read_file = require("utils.read_file")

do
	local pk_resolution_base10 = read_file("pk_resolution")
	if pk_resolution_base10 then
		pdf.setpkresolution(tonumber(pk_resolution_base10), 1)
	end
end
