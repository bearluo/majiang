local Prop = class("Prop")

function Prop:ctor()
	self.mName = ""
	self.mTimeLimit = {}
	self.mTimeLimit.startT = 0
	self.mTimeLimit.endT = 0	
	self.mDec = "test"
	self.mNum = 1
	self.mIconUrl = "file://dec/meiyuan_.png"
end

function Prop:getPropDec()
	return self.mDec
end

function Prop:getTimeLimit()
	return self.mTimeLimit
end

function Prop:isCanUse()
	return false
end

function Prop:getIconUrl()
	return self.mIconUrl
end

return Prop