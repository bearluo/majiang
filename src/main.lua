
local function display_error(msg)
	if tt then 
		print('----display_error-----',GAME_MODE_DEBUG)
		if GAME_MODE_DEBUG then
			tt.statisticsHalper.reportError(msg)
			return tt.show_error(msg)
		else
			tt.statisticsHalper.reportError(msg)
		end
	else
		print(msg)
	end
end

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
   	display_error("DISPLAY ERROR: " .. tostring(errorMessage) .. "\n" .. debug.traceback("", 2))
end


package.path = package.path .. ";src/?.lua;src/framework/protobuf/?.lua"
cc.FileUtils:getInstance():setPopupNotify(false)

require("appentry")
