--
-- Author: shineflag
-- Date: 2017-02-15 18:02:17
--


local proto = require("app.net.byteproto")
local log = require("app.utils.log")
local GameSocket = require("app.net.GameSocket")
local scheduler = require("framework.scheduler")

local gsocket = GameSocket.new(proto)

local TAG = "GSOCKET"
local HEART_TIME = 10
local hearbeat_handler
local timeout = false

local shaked = false --是否握手成功
local RECONECT_TIME = 5
local reconect_time = 0

local function proc(data)

	-- log.d(TAG,"cmd:[%s] ",data.cmd)
	local evt = data
	evt.name = tt.gevt.SOCKET_DATA
	tt.gevt:dispatchEvent(evt)
end

local function request(cmd, data)
	local pkg = proto.create_req(cmd,data)
	if not pkg then
		printError("request cmd[%s] is nil", cmd)
		return 
	end
	printInfo("request cmd[%s] data[%d]",cmd,#pkg)
	if not gsocket:isConnected() and reconect_time > 0 then
		local EVT = {
		} 
		EVT.name = tt.gevt.EVENT_RECONNECTING
		tt.gevt:dispatchEvent(EVT)
	elseif not gsocket:isConnected() then
		local EVT = {
		} 
		EVT.name = tt.gevt.EVENT_RECONNECTING
		tt.gevt:dispatchEvent(EVT)
    	gsocket:reconnect()
	else
		if shaked then
			gsocket:send(pkg)
		end
	end
end

local heart_data = proto.create_req("heart_beat")

local function stopHeartBeat( ... )
    log.d(TAG, "stopHeartBeat");
	if hearbeat_handler then
		scheduler.unscheduleGlobal(hearbeat_handler)
		hearbeat_handler = nil
	end
end

local function onTimeout(  )
    log.d(TAG, "onTimeout");
    gsocket:disconnect()
    reconect_time = RECONECT_TIME
    gsocket:reconnect()
end

local function onHeartBeat( dt )
    log.d(TAG, "onHeartBeat :" .. HEART_TIME);
    if timeout then 
    	onTimeout()
    	stopHeartBeat()
    	return 
    end

    gsocket:send(heart_data)
    timeout = true
    hearbeat_handler = scheduler.performWithDelayGlobal(onHeartBeat,HEART_TIME)
end

local function startHeartBeat()
    log.d(TAG, "startHeartBeat");
    if not hearbeat_handler then
    	timeout = false
    	hearbeat_handler = scheduler.performWithDelayGlobal(onHeartBeat,HEART_TIME)
    end
end

--握手请求验证
local function shake()
	local data = proto.create_req("login.shake",{uid=tt.owner.uid_})
	printInfo("shake data[%d]",#data)
	dump({uid=tt.owner.uid_})
	gsocket:send(data)
end
--服务器验证
local function shake_rep(pack)
	if pack.cmd == "login.shake" then 
		local data = pack.data
		if data.ret == 0 or data.ret == 1 then 
			shaked = true 
			log.d(TAG,"shake ok")
			startHeartBeat()
		end
	end
end

local function onConnected( evt )
	log.d(TAG,"onConnected")
    reconect_time = RECONECT_TIME
	shake()
end

local function onClose( evt )
	log.d(TAG,"onClose reconect_time:" .. reconect_time)
	if reconect_time <= 0 then
		-- tt.show_wait_view("网络不稳定请重新登陆")
		local EVT = {
		} 
		EVT.name = tt.gevt.EVENT_RECONNECT_FAILURE
		tt.gevt:dispatchEvent(EVT)
    	gsocket:disconnect()
	elseif reconect_time == RECONECT_TIME - 1 then
		local EVT = {
		} 
		EVT.name = tt.gevt.EVENT_RECONNECTING
		tt.gevt:dispatchEvent(EVT)
		-- tt.show_wait_view("正在重连中...")
	end
	shaked = false
end

local function onClosed( evt )
	log.d(TAG,"onClosed")
	shaked = false
	stopHeartBeat()
end

local function onConnectFailure( evt )
	log.d(TAG,"onConnectFailure")
	reconect_time = reconect_time - 1
end

local function onData( evt )
	if not evt.data then 
	    gsocket:disconnect()
	    reconect_time = RECONECT_TIME
		shaked = false
		gsocket:reconnect()
		return 
	end
	if not shaked then 
		shake_rep(evt.data)
		-- 未登陆 不接受其他命令
		if evt.data.cmd ~= "login.shake" then
			return
		end
	end
	dump(evt.data,"socket onData")
	if evt.data and evt.data.cmd then 
		if evt.data.cmd == "heart_beat" then
			--log.d(TAG,"receive heart beat!")
			timeout = false
		elseif evt.data.cmd == "login.shake" then
			if evt.data.data.ret == 3 then 
				app:enterScene("LoginScene", {true})
	    		stopHeartBeat()
	    		gsocket:disconnect()
	    		scheduler.performWithDelayGlobal(function()
	    			tt.show_msg("你的账号在其他地方登陆")
	    			end,0.5)
    		end
			proc(evt.data)
		else 
			proc(evt.data)
		end
	else
		log.d(TAG,"Unkonw data")
	end

end


local function addListens(  )
	if gsocket then
		gsocket:addEventListener(GameSocket.EVENT_CONNECTED,onConnected )
		gsocket:addEventListener(GameSocket.EVENT_CLOSE, onClose)
		gsocket:addEventListener(GameSocket.EVENT_CLOSED, onClosed)
		gsocket:addEventListener(GameSocket.EVENT_CONNECT_FAILURE, onConnectFailure)
		gsocket:addEventListener(GameSocket.EVENT_DATA, onData)
	end
end


local function setHeartTime( time )
	HEART_TIME = tonumber(time) or HEART_TIME
end

addListens()
gsocket.request = request
gsocket.setHeartTime = setHeartTime
return gsocket
