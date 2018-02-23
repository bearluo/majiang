local platformEventHalper = require("app.utils.platformEventHalper")
require "lfs"

local function rmdir(path)
    print("os.rmdir:", path)
    if io.exists(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

local VoiceRecord = {}
local what = 0
local tempFile = "voiceRecord_%d.temp"
-- 初始化GameState，存储缓存图片相关信息
function VoiceRecord.init()
	local path = device.writablePath.."voiceRecordCache/" --获取本地存储目录
	tempFile = path .. tempFile
	rmdir(path)
	lfs.mkdir(path) --目录不存在，创建此目录
end

function VoiceRecord.startRecord()
	os.remove(tempFile)
	what = what + 1
	local params = platformEventHalper.cmds.startRecord
	params.args = {
		what=what,
		path=string.format(tempFile,what),
	}
	platformEventHalper.callEvent(params)
	return what
end

function VoiceRecord.stopRecord()
	local params = platformEventHalper.cmds.stopRecord
	params.args = {
	}
	platformEventHalper.callEvent(params)
end

-- function VoiceRecord.play

function VoiceRecord.getRecordData()
	file = io.open(tempFile, "r")
	local ret = io.read("*all")
	file:close()
end


function VoiceRecord.onTouch_(self,event)
	local name, x, y = event.name, event.x, event.y
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        self.btn_status = "press"
        VoiceRecord.startRecord()
        -- 按下
        return true
    end

    -- must the begin point and current point in Button Sprite
    local touchInTarget = self:getCascadeBoundingBox():containsPoint(cc.p(self.touchBeganX, self.touchBeganY))
                        and self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "moved" then
        if touchInTarget and self.btn_status ~= "press" then
        	self.btn_status = "press"
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
        	self.btn_status = "release"
        end
    else
    	self.btn_status = "release"
    	VoiceRecord.stopRecord()
        if name == "ended" and touchInTarget then
        	-- 發送消息
        	audio.playSound(string.format(tempFile,what), flag or false)
        end
    end
end

VoiceRecord.init()
return VoiceRecord