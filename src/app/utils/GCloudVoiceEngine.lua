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

local GCloudVoiceEngine = {}
local upWhat = 0
local downWhat = 0
local tempFile = "voiceRecord_%d.temp"
local dowpFile = "downvoiceRecord_%d.temp"
local isLogin = false
local status = "idle"
local speekQueue = {}
local speekInit = 0
function GCloudVoiceEngine.init()
	local path = device.writablePath.."voiceRecordCache/" --获取本地存储目录
	tempFile = path .. tempFile
	dowpFile = path .. dowpFile
	rmdir(path)
	lfs.mkdir(path) --目录不存在，创建此目录
    tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, GCloudVoiceEngine.onNativeEvent)
end

function GCloudVoiceEngine.onNativeEvent(evt)
    printInfo("RoomScene:onNativeEvent cmd %s params %s", evt.cmd,evt.params)
    if evt.cmd == tt.platformEventHalper.callbackCmds.gCloudVoice then
        local params = json.decode(evt.params)
        if params.ret == 1 then
            if params.method == "OnApplyMessageKey" then
                if params.code == 7 then
                    speekInit = 3
                else
                    speekInit = 0
                    -- tt.show_msg("语音聊天初始化失败 code:" .. params.code)
                end
            elseif params.method == "OnPlayRecordedFile" then
                status = "idle"
                tt.play.resume_music()
                tt.play.set_sounds_vol(1.0)
                GCloudVoiceEngine.autoPlay()
                if params.code == 21 then
                else
                    -- tt.show_msg("语音消息播放失败 code:" .. params.code)
                end
            elseif params.method == "OnDownloadFile" then
                if params.code == 13 then
                else
                    -- tt.show_msg("语音消息下载失败 code:" .. params.code)
                end
            elseif params.method == "OnUploadFile" then
                if params.code == 11 then
                else
                    -- tt.show_msg("语音消息发送失败 code:" .. params.code)
                end
            end
        elseif params.ret == 2 then
        elseif params.ret == 3 then
        end
    end
end

function GCloudVoiceEngine.loginGCloudVoice(open_id)
	print("GCloudVoiceEngine.loginGCloudVoice",open_id)
	local params = platformEventHalper.cmds.loginGCloudVoice
	params.args = {
		open_id=open_id,
	}
	platformEventHalper.callEvent(params)
    speekInit = 1
end

function GCloudVoiceEngine.startRecord()
    tt.play.pause_music()
    tt.play.set_sounds_vol(0)
    if status ~= "idle" and status ~= "recording" then
        GCloudVoiceEngine.stopPlayFile(status)
    end
	upWhat = upWhat + 1
	local params = platformEventHalper.cmds.startRecording
	params.args = {
		path=string.format(tempFile,upWhat),
	}
	platformEventHalper.callEvent(params)
    status = "recording"
end

function GCloudVoiceEngine.stopRecord(startFunc)
    tt.play.resume_music()
    tt.play.set_sounds_vol(1.0)
	local params = platformEventHalper.cmds.stopRecording
	params.args = {
	}
	platformEventHalper.callEvent(params)
    status = "idle"
    GCloudVoiceEngine.autoPlay()
end

function GCloudVoiceEngine.getCurPath()
    return string.format(tempFile,upWhat)
end

function GCloudVoiceEngine.uploadRecordedFile()
	local params = platformEventHalper.cmds.uploadRecordedFile
	params.args = {
		path=string.format(tempFile,upWhat),
	}
	platformEventHalper.callEvent(params)
end

function GCloudVoiceEngine.downloadRecordedFile(fileId)
	downWhat = downWhat + 1
	local params = platformEventHalper.cmds.downloadRecordedFile
	params.args = {
		file_id = fileId,
		path=string.format(dowpFile,downWhat),
	}
	platformEventHalper.callEvent(params)
end

function GCloudVoiceEngine.playRecordedFile(dPath,startFunc)
    local func = function()
        local params = platformEventHalper.cmds.playRecordedFile
        params.args = {
            path=dPath,
        }
        platformEventHalper.callEvent(params)
        if startFunc then
            startFunc()
        end
        return dPath
    end
    table.insert(speekQueue,func)
    GCloudVoiceEngine.autoPlay()
end

function GCloudVoiceEngine.stopPlayFile(dPath)
	local params = platformEventHalper.cmds.stopPlayFile
	params.args = {
		path=dPath,
	}
	platformEventHalper.callEvent(params)
    status = "idle"
end

function GCloudVoiceEngine.clearSpeekQueue()
    if status ~= "idle" and status ~= "recording" then
        GCloudVoiceEngine.stopPlayFile(status)
    end
    speekQueue = {}
end

function GCloudVoiceEngine.autoPlay()
    if status == "idle" then
        if #speekQueue > 0 then
            local func = table.remove(speekQueue,1)
            status = func()
            tt.play.pause_music()
            tt.play.set_sounds_vol(0)
        end
    end
end

function GCloudVoiceEngine.onTouch_(self,event)
	local name, x, y = event.name, event.x, event.y
    if name == "began" then
        self.touchBeganX = x
        self.touchBeganY = y
        if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        self.btn_status = "press"
        GCloudVoiceEngine.startRecord()
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
    	GCloudVoiceEngine.stopRecord()
        if name == "ended" and touchInTarget then
        	-- 發送消息
        	GCloudVoiceEngine.uploadRecordedFile()
        end
    end
    return self.btn_status
end

GCloudVoiceEngine.init()
return GCloudVoiceEngine