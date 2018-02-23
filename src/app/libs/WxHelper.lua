local platformEventHalper = require("app.utils.platformEventHalper")
local WXSceneSession = 0;
local WXSceneTimeline = 1;
local WXSceneFavorite = 2;

local WxHelper = {}

local index = os.time()

-- ios transaction 无用
function WxHelper.isWXAppInstalled()
	local ok,ret = platformEventHalper.callEvent(platformEventHalper.cmds.isWXAppInstalled)
print("WxHelper.isWXAppInstalled",ok,ret)
print("WxHelper.isWXAppInstalled",type(ok),type(ret))
	if ok then
print("is ok")
		if ret == 0 then
			return false,"请先安装微信客户端"
		end
		return true
	else
print("is not ok")
		return false,"JNI 调用失败"
	end
end

function WxHelper.shareBitmapToWx(bmpPath,description)
	local flag,msg = WxHelper.isWXAppInstalled()
	if not flag then
		return flag,msg
	end
	index = index + 1
	local params = platformEventHalper.cmds.shareBitmapToWx
	params.args = {
		transaction=index,
		bmpPath=bmpPath,
		description=description,
		scene=WXSceneSession,
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		if ret == 0  then
			return false,"微信调起失败 分享失败"
		end
		return index
	else
		return false,"JNI 调用失败"
	end
end

function WxHelper.shareTextToWx(text,description)
	local flag,msg = WxHelper.isWXAppInstalled()
	if not flag then
		return flag,msg
	end
	index = index + 1
	local params = platformEventHalper.cmds.shareTextToWx
	params.args = {
		transaction=index,
		text=text,
		description=description,
		scene=WXSceneSession,
	}
	local ok,ret = platformEventHalper.callEvent(params)
print("WxHelper.shareTextToWx",ok,ret)
print("WxHelper.shareTextToWx",type(ok),type(ret))
	if ok then 
		if ret == 0 then
			return false,"微信调起失败 分享失败"
		end
		return index
	else
		return false,"JNI 调用失败"
	end
end

function WxHelper.shareWebToWx(url,title,description)
	local flag,msg = WxHelper.isWXAppInstalled()
	if not flag then
		return flag,msg
	end
	index = index + 1
	local params = platformEventHalper.cmds.shareWebToWx
	params.args = {
		transaction=index,
		url=url,
		title=title,
		bmpPath= cc.FileUtils:getInstance():fullPathForFilename("icon/share_icon.png"),
		description=description,
		scene=WXSceneSession,
	}
	local ok,ret = platformEventHalper.callEvent(params)
print("WxHelper.shareWebToWx",ok,ret)
print("WxHelper.shareWebToWx",type(ok),type(ret))
	if ok then 
		if ret == 0 then
			return false,"微信调起失败 分享失败"
		end
		return index
	else
		return false,"JNI 调用失败"
	end
end



return WxHelper



