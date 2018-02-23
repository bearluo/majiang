local gsocket = require("app.net.gsocket")

local IMHelper = {}

IMHelper.VOICE = 0
IMHelper.MSG = 1
IMHelper.SHORTCUT_MSG = 2
IMHelper.EMOTICON_MSG = 3

function IMHelper.sendVoice(uid,fileID)
	local sendData = {}
	sendData.uid = uid
	sendData.msg_type = IMHelper.VOICE
	sendData.file_id = fileID
	gsocket.request("room.sendMsg",sendData)
end

function IMHelper.sendMsg(uid,str)
	local sendData = {}
	sendData.uid = uid
	sendData.msg_type = IMHelper.MSG
	sendData.content = str
	gsocket.request("room.sendMsg",sendData)
end

function IMHelper.sendShortcutMsg(uid,str)
	local sendData = {}
	sendData.uid = uid
	sendData.msg_type = IMHelper.SHORTCUT_MSG
	sendData.content = str
	gsocket.request("room.sendMsg",sendData)
end

function IMHelper.sendEmoticonMsg(uid,id)
	local sendData = {}
	sendData.uid = uid
	sendData.msg_type = IMHelper.EMOTICON_MSG
	sendData.emoticon_id = id
	gsocket.request("room.sendMsg",sendData)
end

return IMHelper
