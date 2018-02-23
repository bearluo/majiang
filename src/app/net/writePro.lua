
local writePro = {
	["login.shake"] = function(pack,data)
		-- 用户id	Int	
		-- 版本号	String	
		-- 渠道号	String	
		-- 设备号	Short	1 iphone 2 Android ， 3其他
		pack:writeInt(data.uid)
		pack:writeString(kVersion)
		pack:writeString(kChan)
		if device.platform == "ios" then
			pack:writeShort(1)
		elseif device.platform == "android" then
			pack:writeShort(2)
		else
			pack:writeShort(3)
		end
	end,
	-- 客户端创建房间
	["room.create"] = function(pack,data)
		-- 用户uid	Int	
		-- 房间level	Int	现在使用101
		-- 局数	Int	
		-- 支付方式	Int	0 平分支付 1房主支付
		-- 结算方式	Int	0发胡，1点炮支付
		-- 是否带风	Int	0不带风，1带风
		pack:writeInt(data.uid)
		pack:writeInt(data.level or 101)
		pack:writeInt(data.ju or 1)
		pack:writeInt(data.cost or 0)
		pack:writeInt(data.pay or 0)
		pack:writeInt(data.balance or 0)
		pack:writeInt(data.fen or 0)
		pack:writeInt(data.base_score or 1)
	end,
	-- 用户进房间
	["room.login"] = function(pack,data)
		-- 用户uid	Int	
		-- 桌子id	Int	
		-- 用户个人信息	String	Json 客户端自己定义 server负责透传
		pack:writeInt(data.uid)
		pack:writeInt(data.tid)
		pack:writeString(data.pInfo)
	end,
	["room.check"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeInt(data.level)
		pack:writeInt(data.index)
	end,
	["room.logout"] = function(pack,data)
		pack:writeInt(data.uid)
	end,
	["room.ready"] = function(pack,data)
		pack:writeInt(data.uid)
	end,
	["room.roomOverApply"] = function(pack,data)
		dump(data)
		pack:writeInt(data.uid)
		pack:writeByte(data.action)
	end,
	["room.discard"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeByte(data.card)
	end,
	["room.action"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeInt(data.action_id)
		pack:writeByte(data.card)
	end,
	["room.sendMsg"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeString(json.encode(data))
	end,
	["room.getRecord"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeInt(data.page-1)
	end,
	["room.tiRen"] = function(pack,data)
		pack:writeInt(data.uid)
		pack:writeInt(data.target_uid)
	end,

}



return writePro