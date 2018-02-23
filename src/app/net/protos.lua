
--协议文本
local protos = {}
local readPro = require("app.net.readPro")
local writePro = require("app.net.writePro")

function protos.read(pack,cmd)
	local ret = {}
	if readPro[cmd] then
		ret.data = readPro[cmd](pack)
	end
	return ret
end

function protos.write(pack,cmd,data)
	if writePro[cmd] then
		writePro[cmd](pack,data)
	end
end

return protos