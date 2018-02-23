local CircleClip = require("app.ui.CircleClip")

local SeatView = class("SeatView",function()
    return display.newNode()
end)

function SeatView:ctor(ctrl)
	local node, width, height = cc.uiloader:load("seat_view.json")
	self:addChild(node)
	self.root_ = node
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setContentSize(cc.size(width,height))

	self.head_handler = cc.uiloader:seekNodeByName(node,"head_bg")
	self.name_txt = cc.uiloader:seekNodeByName(node,"name_txt")
	self.score_txt = cc.uiloader:seekNodeByName(node,"score_txt")
	self.yinying = cc.uiloader:seekNodeByName(node,"yinying")
	self.offline_icon = cc.uiloader:seekNodeByName(node,"offline_icon")
	
	
	self.mCtrl = ctrl

	self.mScore = 0
	self:clearSeatInfo()
end

function SeatView:isUid(uid)
	print("SeatView:isUid",uid)
	if not self.player then return false end
	print("SeatView:isUid",self.player.uid,uid)
	return tonumber(self.player.uid) == uid
end

function SeatView:getUid()
	if not self.player then return 0 end
	return tonumber(self.player.uid)
end

function SeatView:getPlayer()
	return self.player
end

function SeatView:getPlayerInfo()
	dump(self.pinfo,"SeatView:getPlayerInfo")
	return self.pinfo
end

--用户坐下，设置用户信息
function SeatView:setSeatInfo(info)
	self.player = info 
	self.pinfo  = json.decode(info.pInfo)

	tt.limitStr(self.name_txt,self.pinfo.name,72)

	print('SeatView:setSeatInfo',self.pinfo.img_url)
	tt.asynGetHeadIconSprite(string.urldecode(self.pinfo.img_url or ""),function(sprite)
		if sprite and self and self.head_handler then
			local size = self.head_handler:getContentSize()
			local mask = display.newSprite("dec/fangjianneitouxiang_2.png")
			if self.head_ then
				self.head_:removeSelf()
				self.head_ = nil
			end
			self.head_ = CircleClip.new(sprite,mask)
				:addTo(self.head_handler,99)
				:setPosition(cc.p(0,0))
				:setCircleClipContentSize(size.width,size.height)
		end
	end)
	self.score_txt:setString("0")
	self.yinying:setVisible(true)
end

function SeatView:setScore(score)
	score = tonumber(score) or 0
	if score > 0 then
		self.score_txt:setString("+" .. score)
	else
		self.score_txt:setString(score)
	end
	self.mScore = score
end

function SeatView:setOffline(flag)
	self.offline_icon:setVisible(flag)
end

function SeatView:getScore()
	return self.mScore
end

function SeatView:clearSeatInfo()
	self.name_txt:setString("")
	self.score_txt:setString("")
	self.mScore = 0
	self.player = nil
	self.pinfo = nil
	self.yinying:setVisible(false)
	self.offline_icon:setVisible(false)
	local size = self.head_handler:getContentSize()
	local mask = display.newSprite("dec/fangjianneitouxiang_2.png")
	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end

	local sprite = display.newSprite("dec/morentouxiang.png")
	self.head_ = CircleClip.new(sprite,mask)
		:addTo(self.head_handler,99)
		:setPosition(cc.p(0,0))
		:setCircleClipContentSize(size.width,size.height)
end

return SeatView

