local BLDialog = require("app.ui.BLDialog")
local RoomReconnectView = class("RoomReconnectView", function(...)
	return BLDialog.new(...)
end)

local TAG = "RoomReconnectView"
local net = require("framework.cc.net.init")

function RoomReconnectView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("room_reconnect_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))


	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")
	self.mContentTxt = cc.uiloader:seekNodeByName(self.mContentBg,"content_txt")

	self.mCloseBtn = cc.uiloader:seekNodeByName(self.mContentBg,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			tt.gsocket:disconnect()
			self:showReconnectfailView()
		end)

	self.mLogoutBtn = cc.uiloader:seekNodeByName(self.mContentBg,"logout_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			app:enterScene("LoginScene", {true})
			tt.gsocket:disconnect()
			self:dismiss()
		end)

	self.mReconnectBtn = cc.uiloader:seekNodeByName(self.mContentBg,"reconnect_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:showReconnectView()
		end)

	self:setBackEvent(function() return true end)
end

function RoomReconnectView:showReconnectView()
	self.mCloseBtn:stopAllActions()
	self.mCloseBtn:performWithDelay(function()
           		self.mCloseBtn:setVisible(true)
           	end, 2)
	self:startReconnectAnim()
	self.mLogoutBtn:setVisible(false)
	self.mReconnectBtn:setVisible(false)
	if not self:isShowing() then
		self.mCloseBtn:setVisible(false)
		self:show()
	end
end

function RoomReconnectView:showReconnectfailView()
	self:stopReconnectAnim()
	self.mCloseBtn:stopAllActions()
	self.mCloseBtn:setVisible(false)

	self.mLogoutBtn:setVisible(true)
	self.mReconnectBtn:setVisible(true)
	self.mContentTxt:align(display.CENTER)
	self.mContentTxt:setPosition(244.5,180)
	self.mContentTxt:setString("重连失败")
	if not self:isShowing() then
		self:show()
	end
end

function RoomReconnectView:startReconnectAnim()
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

function RoomReconnectView:stopReconnectAnim()
	self:stopActionByTag(100)
end

function RoomReconnectView:show()
	BLDialog.show(self)
end

function RoomReconnectView:dismiss()
	BLDialog.dismiss(self)
end

return RoomReconnectView
