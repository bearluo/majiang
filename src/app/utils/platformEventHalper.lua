-- Java方法签名中特殊字符/字母含义
-- 特殊字符	数据类型	特殊说明
-- V	void 	一般用于表示方法的返回值
-- Z	boolean	 
-- B	byte	 
-- C	char	 
-- S	short	 
-- I	int	 
-- J	long	 
-- F	float	 
-- D	double	 
-- [	数组	以[开头，配合其他的特殊字符，表示对应数据类型的数组，几个[表示几维数组
-- L全类名;	引用类型	以L开头、;结尾，中间是引用类型的全类名

local android_cmds = {
	loginFacebook = {
		className = "com/tianyou/facebook/FacebookProxy",
		methodName = "loginFacebook",
		args = {},
		keys = {},
		sig  = "()V"
	},
	loginYouke = {
		className = "com/tianyou/youke/YoukeProxy",
		methodName = "loginYouke",
		args = {},
		keys = {},
		sig  = "()V"
	},
	appInvite = {
		className = "com/tianyou/facebook/FacebookProxy",
		methodName = "appInvite",
		args = {},
		keys = {"url"},
		sig  = "(Ljava/lang/String;)V"
	},
	getBatterypercentage = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "getBatterypercentage",
		args = {},
		keys = {},
		sig  = "()I"
	},
	getSignalStrength = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "getSignalStrength",
		args = {},
		keys = {},
		sig  = "()I"
	},
	onProfileSignIn = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "onProfileSignIn",
		args = {},
		keys = {"provider","puid"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	onProfileSignOff = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "onProfileSignOff",
		args = {},
		keys = {},
		sig  = "()V"
	},
	onEvent = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "onEvent",
		args = {},
		keys = {"eventId","jsonStr"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	onEventValue = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "onEventValue",
		args = {},
		keys = {"eventId","jsonStr","value"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;I)V"
	},
	reportError = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "reportError",
		args = {},
		keys = {"error"},
		sig  = "(Ljava/lang/String;)V"
	},
	vibrate = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "vibrate",
		args = {},
		keys = {},
		sig  = "()V"
	},
	startRecord = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "startRecord",
		args = {},
		keys = {"path","what"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V"
	},
	stopRecord = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "stopRecord",
		args = {},
		keys = {},
		sig  = "()V",
	},
	loginWx = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "loginWx",
		args = {},
		keys = {"state"},
		sig  = "(Ljava/lang/String;)V",
	},
	autoLoginWx = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "autoLoginWx",
		args = {},
		keys = {"refresh_token","transaction"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)V",
	},
	loginGCloudVoice = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "loginGCloudVoice",
		args = {},
		keys = {"open_id"},
		sig  = "(Ljava/lang/String;)I"
	},
	startRecording = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "startRecording",
		args = {},
		keys = {"path"},
		sig  = "(Ljava/lang/String;)I",
	},
	stopRecording = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "stopRecording",
		args = {},
		keys = {},
		sig  = "()I",
	},
	uploadRecordedFile = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "uploadRecordedFile",
		args = {},
		keys = {"path"},
		sig  = "(Ljava/lang/String;)I",
	},
	downloadRecordedFile = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "downloadRecordedFile",
		args = {},
		keys = {"file_id","path"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;)I",
	},
	playRecordedFile = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "playRecordedFile",
		args = {},
		keys = {"path"},
		sig  = "(Ljava/lang/String;)I",
	},
	stopPlayFile = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "stopPlayFile",
		args = {},
		keys = {},
		sig  = "()I",
	},
	isWXAppInstalled = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "isWXAppInstalled",
		args = {},
		keys = {},
		sig  = "()I",
	},	
	shareBitmapToWx = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "shareBitmapToWx",
		args = {},
		keys = {"transaction", "bmpPath", "description", "scene"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I",
	},	
	shareTextToWx = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "shareTextToWx",
		args = {},
		keys = {"transaction", "text", "description", "scene"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I",
	},	
	shareWebToWx = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "shareWebToWx",
		args = {},
		keys = {"transaction", "url", "title","description","bmpPath", "scene"},
		sig  = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I",
	},
	copyToClipboard = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "copyToClipboard",
		args = {},
		keys = {"text"},
		sig  = "(Ljava/lang/String;)I",
	},
	displayWebView = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "displayWebView",
		args = {},
		keys = {"x","y","width","height"},
		sig  = "(IIII)V",
	},
	dismissWebView = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "dismissWebView",
		args = {},
		keys = {},
		sig  = "()V",
	},
	webViewLoadUrl = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "webViewLoadUrl",
		args = {},
		keys = {"url"},
		sig  = "(Ljava/lang/String;)V",
	},
	isWebViewVisible = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "isWebViewVisible",
		args = {},
		keys = {},
		sig  = "()I",
	},
	getQueueEvent = {
		className = "com/tianyou/luaevent/LuaEventProxy",
		methodName = "getQueueEvent",
		args = {},
		keys = {},
		sig  = "()V",
	},
}

local ios_cmds = {
	loginFacebook = {
		className = "FacebookHelper",
		methodName = "loginFacebook",
		args = {},
	},
    setLuaCallBackFunc = {
        className = "LuaEventProxy",
        methodName = "setLuaCallBackFunc",
        args = {},
    },
    loginYouke = {
	 	className = "YoukeHelper",
	 	methodName = "loginYouke",
	 	args = {},
    },
    storekit = {
	 	className = "StorekitHelper",
	 	methodName = "buyProduct",
	 	args = {
	 		productID = "",
	 		pid = "",
	 		orderid = "",
	 		pmode = "",
	 	},
    },
    getBatterypercentage = {
	 	className = "LuaEventProxy",
	 	methodName = "getBatterypercentage",
	 	args = {},
	},
	getSignalStrength = {
	 	className = "LuaEventProxy",
	 	methodName = "getSignalStrength",
	 	args = {},
	},
	onProfileSignIn = {
        className = "LuaEventProxy",
        methodName = "onProfileSignIn",
        args = {},
    },
	onProfileSignOff = {
        className = "LuaEventProxy",
        methodName = "onProfileSignOff",
        args = {},
    },
	onEvent = {
        className = "LuaEventProxy",
        methodName = "onEvent",
        args = {},
    },
	onEventValue = {
        className = "LuaEventProxy",
        methodName = "onEventValue",
        args = {},
    },
	reportError = {
        className = "LuaEventProxy",
        methodName = "reportError",
        args = {},
    },
	vibrate = {
		className = "LuaEventProxy",
		methodName = "vibrate",
		args = {},
	},
	startRecord = {
		className = "LuaEventProxy",
		methodName = "startRecord",
		args = {},
	},
	stopRecord = {
		className = "LuaEventProxy",
		methodName = "stopRecord",
		args = {},
	},
	loginWx = {
		className = "LuaEventProxy",
		methodName = "loginWx",
		args = {
			state="",
		},
	},
	autoLoginWx = {
		className = "LuaEventProxy",
		methodName = "autoLoginWx",
		args = {
			refresh_token="",
			transaction="",
		},
	},
	loginGCloudVoice = {
		className = "LuaEventProxy",
		methodName = "loginGCloudVoice",
		args = {
			open_id="",
		},
	},
	startRecording = {
		className = "LuaEventProxy",
		methodName = "startRecording",
		args = {
			path="",
		},
	},
	stopRecording = {
		className = "LuaEventProxy",
		methodName = "stopRecording",
		args = {},
	},
	uploadRecordedFile = {
		className = "LuaEventProxy",
		methodName = "uploadRecordedFile",
		args = {
			path="",
		},
	},
	downloadRecordedFile = {
		className = "LuaEventProxy",
		methodName = "downloadRecordedFile",
		args = {
			file_id="",
			path="",
		},
	},
	playRecordedFile = {
		className = "LuaEventProxy",
		methodName = "playRecordedFile",
		args = {
			path="",
		},
	},
	stopPlayFile = {
		className = "LuaEventProxy",
		methodName = "stopPlayFile",
		args = {},
	},
	isWXAppInstalled = {
		className = "LuaEventProxy",
		methodName = "isWXAppInstalled",
		args = {},
	},	
	shareBitmapToWx = {
		className = "LuaEventProxy",
		methodName = "shareBitmapToWx",
		args = {
			transaction="",
			bmpPath="",
			description="",
			scene=0,
		},
	},	
	shareTextToWx = {
		className = "LuaEventProxy",
		methodName = "shareTextToWx",
		args = { 
			transaction="",
			text="",
			description="",
			scene=0,
		},
	},	
	shareWebToWx = {
		className = "LuaEventProxy",
		methodName = "shareWebToWx",
		args = { 
			transaction="",
			url="",
			title="",
			description="",
			bmpPath="",
			scene=0,
		},
	},
	copyToClipboard = { 
		className = "LuaEventProxy",
		methodName = "copyToClipboard",
		args = {
			text="",
		},
	},
	displayWebView = {
		className = "LuaEventProxy",
		methodName = "displayWebView",
		args = {
			x=0, 
			y=0,
			width=0,
			height=0,
		},
	},
	dismissWebView = {
		className = "LuaEventProxy",
		methodName = "dismissWebView",
		args = {},
	},
	webViewLoadUrl = {
		className = "LuaEventProxy",
		methodName = "webViewLoadUrl",
		args = {
			url="",
		},
	},
	isWebViewVisible = {
		className = "LuaEventProxy",
		methodName = "isWebViewVisible",
		args = {},
	},
}

local window_cmds = {
	-- loginFacebook = {args = {},},
	-- loginYouke = {args = {},},
	-- appInvite = {args = {},},
	-- getBatterypercentage = {args = {},},
	-- getSignalStrength = {args = {},},
	-- storekit = {args = {},},
	-- onProfileSignIn = {args = {},},
	-- onProfileSignOff = {args = {},},
	-- onEvent = {args = {},},
	-- onEventValue = {args = {},},
	-- reportError = {args = {},},
}
local mt = {}
mt.__index = function(table, key)
		table[key] = {args = {},}
		return table[key]
	end

setmetatable(window_cmds,mt)


local callbackCmds = {
	loginFacebook = "loginFacebook",
	loginYouke = "loginYouke",
	gpayConsume = "gpayConsume",
	payCallback = "payCallback",
	voiceRecord = "voiceRecord",
	voiceRecordDecibels = "voiceRecordDecibels",
	wxLogin = "wxLogin",
	wxAutoLogin = "wxAutoLogin",
	gCloudVoice = "gCloudVoice",
	webpayCallback = "webpayCallback",
}



local scheduler = require("framework.scheduler")

local function callAndroidEvent(params)
	printInfo("callAndroidEvent start")
	if params then
		printInfo("callEvent %s %s %s", params.className, params.methodName,params.sig)
		local args = {}
		for i,v in ipairs(params.keys) do
			args[i] = params.args[v]
		end
		dump(args)
		return luaj.callStaticMethod(params.className, params.methodName,args,params.sig)
	end
	return false,"params is nil"
end

local function callIosEvent(params)
	printInfo("callIosEvent start")
	if params then
        if params.args and next(params.args) then
            return luaoc.callStaticMethod(params.className, params.methodName, params.args)
        else
            return luaoc.callStaticMethod(params.className, params.methodName)
        end
	end
	return false,"params is nil"
end

local function callWindowEvent(params)
	printInfo("callWindowEvent start")
	if params then
        if params == window_cmds.loginYouke then
        	scheduler.performWithDelayGlobal(function()
        		native_event(json.encode({
        				cmd="loginYouke",
        				params=json.encode({
        						ret = 1,
						        phone = "18645678901",
						        device_no = "866333026356720",
						        iccid = "89860080191509823650",
						        devicename = "QK3",
						        imsi = "460002606708980",
						        imei = "866333026356720",
						        macid = "18:59:36:11:9f:f0",
						        pixel = "1080x1920",
						        nettype = "WIFI",
						        osversion = "win7",
						        url = "file://hall/head_default_img.png",
        					})
        			}))
        	end,0.5)
        	return true
        elseif params == window_cmds.getBatterypercentage then
        	return true,100
        elseif params == window_cmds.getSignalStrength then
        	return true,5
        elseif params == window_cmds.loginFacebook then
        	scheduler.performWithDelayGlobal(function()
	        	native_event(json.encode({
	        			cmd="loginFacebook",
	        			params='{"ret":1,"id":"101658923773077","gender":"male","fb_token":"EAAD7pmhIvjsBAK9TbI4VyRrGeUz0kSFkGWGwr4fDZCqNv6LOmRpVOpB0zixq4HpqQROXKwsmLIgEyVNmJ7nNF0Ilmc31fxxxQBSUJVJVh0CDvv9ZCKmxvNZAZA2QZA8WaokJnuHi6ZBUZANXRwDLYzycTLAZBRg7sc8szbkPFuRyUBZCahSOPVhKDzyDnE3muZCB2hxr6kfZCAH6AZDZD","name":"LUO HAO"}',
	    			})
	        	)
        	end,0.5)
        	return true
        else
			return false,"window is only youke login"
        end
	end
	return false,"params is nil"
end


local function error()
	printInfo("callEvent platform error")
end

local platformEventHalper = {}

if device.platform == "android" then
	platformEventHalper.callEvent = callAndroidEvent
	platformEventHalper.cmds = android_cmds
	platformEventHalper.callbackCmds = callbackCmds
elseif device.platform == "ios" then
	platformEventHalper.callEvent = callIosEvent
	platformEventHalper.cmds = ios_cmds
	platformEventHalper.callbackCmds = callbackCmds
elseif device.platform == "windows" or device.platform == "mac" then
	platformEventHalper.callEvent = callWindowEvent
	platformEventHalper.cmds = window_cmds
	platformEventHalper.callbackCmds = callbackCmds
else
	platformEventHalper.callEvent = error
	platformEventHalper.cmds = {}
	platformEventHalper.callbackCmds = {}
end

return platformEventHalper
