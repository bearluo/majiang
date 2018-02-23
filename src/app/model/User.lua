--
-- Author: shineflag
-- Date: 2017-02-15 11:11:48
--

local K = 1000
local M = 1000 * K
local B = 1000 * M 
local User = class("User")

function User:ctor( ... )
	self.uid_ = 110
	self.nick_ = "真男人"
	self.img_url_ = ""
	self.mGem = 0
	self.sex_ = 0
	self.mJoinSn = 0
	self.mSales = 0
	self.mRole = 1
	self.mIp = ""
end

function User:getUid(  )
	return self.uid_
end

function User:getClientInfo( ... )
	local t = {
		name=self.nick_,
		gem = self.mGem,
		img_url = self.img_url_,
		sex = tonumber(self.sex_),
		uid = self.uid_,
    }
    local cinfo = json.encode(t)
    tt.log.d("User[%d] cinfo[%s]",self.uid_,cinfo)
    return cinfo
end

function User:setName(name)
	self.nick_ = tostring(name) or ""
end

function User:getName()
	return self.nick_
end

function User:getIconUrl()
	return self.img_url_
end

function User:getSex()
	return self.sex_
end

function User:getSexTxt()
	if self.sex_ == 1 then return "男" end
	if self.sex_ == 2 then return "女" end
	return "未知"
end

function User:setGem(num)
	self.mGem = tonumber(num) or 0
end

function User:getGem()
	return self.mGem
end

function User:setJoinSn(num)
	self.mJoinSn = tonumber(num)
end

function User:getJoinSn()
	return self.mJoinSn
end

function User:isJoinSn()
	return self.mJoinSn ~= 0
end

function User:setRole(role)
	self.mRole = tonumber(role)
end

function User:getRole()
	return self.mRole
end

function User:setSales(sales)
	self.mSales = sales
end

function User:getSales()
	return self.mSales
end

function User:setIp(ip)
	self.mIp = ip or ""
end

function User:getIp()
	return self.mIp
end



return User