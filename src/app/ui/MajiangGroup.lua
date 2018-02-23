local Majiang = require("app.ui.Majiang")

local MajiangGroup = class("MajiangGroup", function()
	return  cc.Node:create() 
end)

MajiangGroup.PENG    = 1
MajiangGroup.GANG    = 2
MajiangGroup.AN_GANG = 3
MajiangGroup.BIAN    = 4
MajiangGroup.ZHUAN   = 5

local top = 1
local left = 2
local bottom = 3
local right = 4

function MajiangGroup:ctor(player_type)
	self.mGroup = {}
	self.mPos = MajiangGroup.POS[player_type]
	self.mPlayerType = player_type
end

function MajiangGroup:setGroup(group_type)
	self.mGroupType = group_type
	if self.mPos then
		self.mPosition = self.mPos[group_type]
		self:resetPosition()
	end
end

function MajiangGroup:resetPosition()
	if not self.mPosition then 
		print("MajiangGroup:resetPosition not mPosition")
		return 
	end
	local maxW,maxH =0,0
	for i,majiang in ipairs(self.mGroup) do
		if self.mPosition[i] then
			local pos,z = unpack(self.mPosition[i])
			local size = majiang:getContentSize()
			local p = majiang:getAnchorPoint()
			majiang:setPosition(cc.p(pos.x+size.width*p.x,pos.y+size.height*p.y))
			majiang:setLocalZOrder(z)

			maxW = math.max(pos.x+size.width,maxW)
			maxH = math.max(pos.y+size.height,maxH)
		end
	end
	self:setContentSize(maxW,maxH)
end

function MajiangGroup:add(value)
	if not self.mPosition then return end
	local i = #self.mGroup + 1
	if self.mPosition[i] then
		local pos,z,mjType = unpack(self.mPosition[i])
		local majiang = Majiang.new(value,mjType + self.mPlayerType - 1)
		local size = majiang:getContentSize()
		local p = majiang:getAnchorPoint()
		majiang:setPosition(cc.p(pos.x+size.width*p.x,pos.y+size.width*p.y))
		majiang:setLocalZOrder(z)
		majiang:addTo(self)
		table.insert(self.mGroup,majiang)
	end
end

function MajiangGroup:del(value)
	for i,majiang in ipairs(self.mGroup) do
		if majiang:getValue() == value then
			table.remove(self.mGroup,i)
			majiang:removeSelf()
			break
		end
	end
end

function MajiangGroup:getValues()
	local ret = {}
	for i,majiang in ipairs(self.mGroup) do
		table.insert(ret,majiang:getValue())
	end
	return ret
end

function MajiangGroup:getGroupType()
	return self.mGroupType
end

MajiangGroup.POS = {}
MajiangGroup.POS[top] = {
	[MajiangGroup.PENG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.GANG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,21),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.AN_GANG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,21),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.BIAN] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(40.5,21),2,Majiang.TOP_ON_HAND_DISMISS},
	},
	[MajiangGroup.ZHUAN] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(40.5,21),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
	},
}
MajiangGroup.POS[left] = {
	[MajiangGroup.PENG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.GANG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(-20,72),4,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.AN_GANG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(-20,72),4,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.BIAN] = {
		{cc.p(0,0),2,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,72),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(-18,36),3,Majiang.TOP_ON_HAND_DISMISS},
	},
	[MajiangGroup.ZHUAN] = {
		{cc.p(0,0),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(-20,36),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),1,Majiang.TOP_ON_HAND_SHOW},
	},
}
MajiangGroup.POS[bottom] = {
	[MajiangGroup.PENG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.GANG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,21),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.AN_GANG] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(162,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,21),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.BIAN] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(40.5,21),2,Majiang.TOP_ON_HAND_DISMISS},
	},
	[MajiangGroup.ZHUAN] = {
		{cc.p(0,0),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(40.5,21),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(81,0),1,Majiang.TOP_ON_HAND_SHOW},
	},
}
MajiangGroup.POS[right] = {
	[MajiangGroup.PENG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.GANG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(20,72),4,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.AN_GANG] = {
		{cc.p(0,0),3,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,72),2,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,144),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(20,72),4,Majiang.TOP_ON_HAND_SHOW},
	},
	[MajiangGroup.BIAN] = {
		{cc.p(0,0),2,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(0,72),1,Majiang.TOP_ON_HAND_DISMISS},
		{cc.p(18,36),3,Majiang.TOP_ON_HAND_DISMISS},
	},
	[MajiangGroup.ZHUAN] = {
		{cc.p(0,0),2,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(20,36),3,Majiang.TOP_ON_HAND_SHOW},
		{cc.p(0,72),1,Majiang.TOP_ON_HAND_SHOW},
	},
}
return MajiangGroup
