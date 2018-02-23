local BLDialog = require("app.ui.BLDialog")
local HallReconnectView = class("HallReconnectView", function(...)
	return BLDialog.new(...)
end)

local TAG = "HallReconnectView"
local net = require("framework.cc.net.init")

function HallReconnectView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("hall_reconnect_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")
	self.mContentTxt = cc.uiloader:seekNodeByName(self.mContentBg,"content_txt")

	self.mCloseBtn = cc.uiloader:seekNodeByName(self.mContentBg,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.gsocket:disconnect()
			self:dismiss()
		end)

	self:setBackEvent(function() return true end)
end

function HallReconnectView:showReconnectView()
	self.mCloseBtn:stopAllActions()
	self.mCloseBtn:performWithDelay(function()
           		self.mCloseBtn:setVisible(true)
           	end, 2)
	self:startReconnectAnim()
	if not self:isShowing() then
		self.mCloseBtn:setVisible(false)
		self:show()
	end
end

function HallReconnectView:showReconnectfailView()
	self:stopReconnectAnim()
	self.mContentTxt:align(display.CENTER)
	self.mContentTxt:setPosition(244.5,120)
	self.mContentTxt:setString("重连失败")
	if not self:isShowing() then
		self:show()
	end
end

function HallReconnectView:startReconnectAnim()
	self:stopReconnectAnim()
	local index = 0
	local x,y = self.mContentTxt:getPosition()
	self.mContentTxt:align(display.LEFT_CENTER)
	self.mContentTxt:setString("断线重连中···")
	self.mContentTxt:setPosition(cc.p(120,120))

	self:schedule(function()
			index = (index + 1)%4
			if index == 0 then
				self.mContentTxt:setString("断线重连中···")
			elseif index == 1 then
				self.mContentTxt:setString("断线重连中")
			elseif index == 2 then
				self.mContentTxt:setString("断线重连中·")
			else
				self.mContentTxt:setString("断线重连中··")
			end
		end,0.4):setTag(100)
end

function HallReconnectView:stopReconnectAnim()
	self:stopActionByTag(100)
end

function HallReconnectView:show()
	BLDialog.show(self)
end

function HallReconnectView:dismiss()
	BLDialog.dismiss(self)
end

return HallReconnectView
