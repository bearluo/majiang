--
-- Author: shineflag
-- Date: 2017-02-15 18:04:23
--
-- @see http://underpop.free.fr/l/lua/lpack/
require("pack")
require("app.utils.sutils")

local Protos = require("app.net.protos")
local Pack = require("app.net.BoyaaQE1")

local c2s = {
	["heart_beat"] 	= 0x1000, -- 心跳
	["login.shake"] = 0x1001, -- 客户端登录大厅
	["room.create"] = 0x1002, -- 客户端创建房间
	["room.check"] 	= 0x1003, -- 用户进房间验证
	["room.login"] 	= 0x2001, -- 用户进房间
	["room.userJoin"] = 0x3005, -- 广播用户进入房间和坐下
	["room.logout"] = 0x2002; -- 用户离开房间
	["room.userLeave"] = 0x200E, -- 广播用户离开
	["room.ready"] = 0x2015, -- 用户准备
	["room.userReady"] = 0x3011, -- 广播用户准备
	["room.start"] = 0x3012, -- 广播游戏开始，摇骰子点数
	["room.deal"] = 0x3004, -- 服务器发牌
	["room.dealOne"] = 0x3006, -- 广播玩家抓牌
	["room.userAction"] = 0x3009, -- 广播用户进行了什么操作
	["room.noticeAction"] = 0x3013,-- 服务器告诉客户端可以进行什么操作，抢杠胡会出现这个，可以胡牌了
	["room.discard"] = 0x2016,-- 用户主动出牌操作
	["room.userDiscard"] = 0x3008,-- 广播出牌操作
	["room.action"] = 0x2017,-- 用户执行操作
	["room.actionFail"]  = 0x3002,-- 返回无效操作 只有包头
	["room.gameOver"] = 0x3003,-- 广播胡牌和一局结算
	["room.roomOverApply"] = 0x2018,-- 玩家解散房间申请和同意
	["room.onRoomOverApply"] = 0x3015,-- 广播玩家申请解散房间通知
	["room.onUserRoomOverApply"] = 0x3018,-- 广播玩家选择申请解散结果
	["room.roomClose"] = 0x3014,-- 房间游戏解散房间通知
	["room.sendMsg"] = 0x2003,-- 用户聊天及返回和广播
	["room.serverError"] = 0x200F,-- server异常关闭，客户端退出房间进大厅
	["php.broadcast"] = 0x7002,-- server转发广播给客户端
	["server.gemUpdate"] = 0x3016,-- server广播用户金币钻石发生变化
	["room.getRecord"] = 0x2019,-- 获取历史结算牌局信息
	["room.tiRen"] = 0x201A,-- 房主踢人
	["room.onTiRenBroadcast"] = 0x3017,-- 广播踢人
	["room.onStandUpBroadcast"] = 0x300b,-- 广播用户站起
	["room.onUserOfflineBroadcast"] = 0x2005,-- 广播用户掉线
	
}

local s2c = {}
for key,value in pairs(c2s) do
	s2c[tonumber(value)] = key
end

local function _unpack(data,uncrypt)
	local pack = Pack.new()
	pack:unpack(data)
	if not uncrypt then
		pack:decrypt()
	end
	local cmd = pack:getCmd()
	printInfo("unpack cmd[0x%x]", cmd)
	cmd = s2c[cmd] or cmd
	local data = Protos.read(pack,cmd) or {}
	data.cmd = cmd
	printInfo("unpack cmd[%s]", cmd)
	dump(data)
	return data
end

--创建一个请求的包
local function create_req(cmd,args,uncrypt)
	local pack = Pack.new()
	if not c2s[cmd] then 
		printError("create_req cmd[%s] is not define", cmd)
		return 
	end
	printInfo("create_req cmd[0x%x]", c2s[cmd])
	pack:writeBegin(c2s[cmd])
	Protos.write(pack,cmd,args)
	pack:writeEnd()
	if not uncrypt then
		pack:encrypt()
	end
	return pack:pack() 
end

local proto = {}
proto.create_req = create_req
proto.unpack = _unpack 
return proto