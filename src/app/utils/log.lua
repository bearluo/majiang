--
-- Author: shineflag
-- Date: 2016-12-04 15:45:35
--
local Logger = {}
Logger.LV_ERROR = 1 
Logger.LV_NOTICE = 2 
Logger.LV_WARN = 3 
Logger.LV_DEBUG = 4 


local log_level = Logger.LV_DEBUG

local function log_write_stdout(...)
    io.write(...)
end

local function log_write_stderr(...)
    io.stderr:write(...)
end


local function print_msg(msg)
    release_print(msg)
end



local function format_msg(lv,tag, ... )
    local time_info = os.date("%X",os.time())
    local debug_info = debug.getinfo(3)

    local msg 
    if select("#", ...) > 1 then
    	msg = string.format(...)
    else
        msg = tostring(...)
    end

    return string.format("%s:%s[%d] lv%d %s [%s] --> %s\n",debug_info.source, debug_info.name, debug_info.currentline, lv,tag, time_info, msg)

end

local function log_error(tag, ...)
    if log_level >= Logger.LV_ERROR then
        local info = format_msg(Logger.LV_ERROR,tag,...)
        printError(info)
    end
end

local function log_notice(tag, ... )
    if log_level >= Logger.LV_NOTICE then
        local info = format_msg(Logger.LV_NOTICE,tag, ...)
        print_msg(info)
    end
end

local function log_warn(tag, ...)
    if log_level >= Logger.LV_WARN then
        local info = format_msg(Logger.LV_WARN,tag,...)
        print_msg(info)
    end
end

function log_debug(tag, ...)
    if log_level >= Logger.LV_DEBUG then
        local info = format_msg(Logger.LV_DEBUG,tag, ...)
        print_msg(info)
    end
end



Logger.e = log_error
Logger.n = log_notice
Logger.w = log_warn
Logger.d = log_debug

return Logger
