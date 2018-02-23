--
-- Author: shineflag
-- Date: 2017-02-14 15:54:21
--


local net = require("framework.cc.net.init")
local utils = require("framework.cc.utils.init")
local log  =  require("app.utils.log")
local scheduler = require("framework.scheduler")

local SocketTCP = net.SocketTCP

local TAG = "GAME_SOCKET"

local PKG_HEAD_LEN = 4  --目前只能是2和4

GameSocket = class("GameSocket")

GameSocket.EVENT_DATA            = "GAMESOCKET_DATA"
GameSocket.EVENT_CLOSE           = "GAMESOCKET_CLOSE"
GameSocket.EVENT_CLOSED          = "GAMESOCKET_CLOSED"
GameSocket.EVENT_CONNECTED       = "GAMESOCKET_CONNECTED"
GameSocket.EVENT_CONNECT_FAILURE = "GAMESOCKETP_CONNECT_FAILURE"

function GameSocket:ctor(proto)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:createSocket()
	self.host_ = ""
	self.port_ = 0

	self.proto_ = proto
	self.buff_ = ""

end

function GameSocket:createSocket()
	local socket = SocketTCP.new()
	socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
	socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
	socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
	socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
	socket:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.onData))
	self.socket_ = 	socket
	self.connect_ = false
	self.socket_:setReconnTime(1)
	self.socket_:setConnFailTime(10)
end

function GameSocket:releaseSocket()
	if self.socket_ then
		local socket = self.socket_
		socket:removeAllEventListeners()
	end
end

function GameSocket:connect( host,port )
	if host then self.host_ = host end
	if port then self.port_ = port end

	if not self.port_ or not self.host_ then return end

	if self.connect_ or self.mReconnectSchedulerHandler then
		self:reconnect()
		return
	end
	self.socket_:connect(self.host_,self.port_,true)
	log.d(TAG,"connect [%s:%d]",host,port)
end

function GameSocket:reconnect()
	if self.connect_ then
		self.socket_:disconnect()
	end
	if self.mReconnectSchedulerHandler then scheduler.unscheduleGlobal(self.mReconnectSchedulerHandler) self.mReconnectSchedulerHandler = nil end
	self.mReconnectSchedulerHandler = scheduler.performWithDelayGlobal(function()
		self.mReconnectSchedulerHandler = nil
		self:connect(self.host_,self.port_,true)
	end,1)
	print("GameSocket reconect")
end

function GameSocket:disconnect()
	self.socket_:disconnect()
end

function GameSocket:close(  )
	if self.connect_ then
		self.socket_:disconnect()
	else
		log.e(TAG,"already closed")
	end
end

function GameSocket:send( data )
	if self.connect_ then
		self.socket_:send(data)
	else
		self:connect()
		log.d(TAG,"send fail : %s", data)
	end
end

function GameSocket:sendPkg( pkg )
	self:send( pkg:pack() )
end

function GameSocket:onConnected( evt )
	log.d(TAG,"GameSocket:onConnected")
	self.connect_ = true
	local EVT = evt 
	EVT.name = GameSocket.EVENT_CONNECTED
	self:dispatchEvent(EVT)
end

function GameSocket:onClose( evt )
	log.d(TAG,"GameSocket:onClose")
	local EVT = evt 
	EVT.name = GameSocket.EVENT_CLOSE
	self:dispatchEvent(EVT)
end

function GameSocket:onClosed( evt )
	log.d(TAG,"GameSocket:onClosed")
	self.connect_ = false
	local EVT = evt 
	EVT.name = GameSocket.EVENT_CLOSED
	self:dispatchEvent(EVT)
end

function GameSocket:onConnectFailure( evt )
	log.d(TAG,"GameSocket:onConnectFailure")
	self.connect_ = false
	local EVT = evt 
	EVT.name = GameSocket.EVENT_CONNECT_FAILURE
	self:dispatchEvent(EVT)
end

function GameSocket:onData( evt )
	printInfo("GameSocket.onData evt.data[%d]",#evt.data)
	----[[
	self.buff_ = self.buff_  .. evt.data
	while(true)
	do
		local size = #self.buff_
		if size < PKG_HEAD_LEN then
			--log.d(TAG,string.format("data size[%d] less than  PKG_HEAD_LEN %d",size,PKG_HEAD_LEN))
			return
		end
		local pack_len 
		if PKG_HEAD_LEN == 4 then
			_,pack_len = string.unpack(self.buff_,">I")
		elseif PKG_HEAD_LEN == 2 then
			_,pack_len = string.unpack(self.buff_,">H")
		else
			--目前不支持其它类型的长度
			self.buff_ = ""
			printInfo("目前不支持其它类型的长度")
			return
		end

		if size < pack_len then
			--log.d(TAG,string.format("data size[%d] less than  pack_len %d + PKG_HEAD_LEN %d ",size,pack_len,PKG_HEAD_LEN))
			printInfo("data size[%d] less than  pack_len %d + PKG_HEAD_LEN %d ",size,pack_len,PKG_HEAD_LEN)
			return
		end

		local data = self.buff_:sub(1,pack_len)
		self.buff_ = self.buff_:sub(pack_len + 1)
		--log.d(TAG,string.format("buff size[%d] pack_len[%d] head_lend[%d]",size,pack_len,PKG_HEAD_LEN))
		local pdata = self.proto_.unpack(data)
			--dispatch message
		local EVT = evt 
		EVT.name = GameSocket.EVENT_DATA
		EVT.data = pdata
		self:dispatchEvent(EVT)
	end
	--]]
end

function GameSocket:isConnected()
	return self.connect_ == true
end

return GameSocket