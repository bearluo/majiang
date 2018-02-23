local BLDialog = require("app.ui.BLDialog")
local TAG = "JoinRoomDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local JoinRoomDialog = class("JoinRoomDialog", function()
	return BLDialog.new()
end)


function JoinRoomDialog:ctor(ctrl)
	self.mCtrl = ctrl 

	local node, width, height = cc.uiloader:load("join_room_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.close_btn = cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	for i=0,9 do
		cc.uiloader:seekNodeByName(node, "num_btn_" .. i)
			:onButtonClicked(function()
				tt.play.play_sound("click")
				self:addNum(i)
			end)
	end

	cc.uiloader:seekNodeByName(node, "num_btn_reset")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:resetNum()
			end)
 
	cc.uiloader:seekNodeByName(node, "num_btn_delete")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:delNum()
			end)

	self.error_tip_txt = cc.uiloader:seekNodeByName(node, "error_tip_txt")
	self:resetNum()
end

function JoinRoomDialog:resetNum()
	self.mInputIndex = 0
	self.mInputStr = ""
	for i=1,6 do
		cc.uiloader:seekNodeByName(self.root_, "input_txt_" .. i)
			:setString("")
	end
	self.error_tip_txt:setString("")
end

function JoinRoomDialog:delNum()
	if self.mInputIndex > 0 then
		cc.uiloader:seekNodeByName(self.root_, "input_txt_" .. self.mInputIndex)
			:setString("")
		self.mInputIndex = self.mInputIndex - 1
		self.mInputStr = string.sub(self.mInputStr,1,-2)
		self.error_tip_txt:setString("")
	end
end

function JoinRoomDialog:addNum(num)
	if self.mInputIndex < 6 then
		self.mInputIndex = self.mInputIndex + 1
		cc.uiloader:seekNodeByName(self.root_, "input_txt_" .. self.mInputIndex)
				:setString(num)
		self.mInputStr = self.mInputStr .. num
		if self.mInputIndex == 6 then
			self.mCtrl:checkRoom(tonumber(self.mInputStr))
		end
	end
end

function JoinRoomDialog:showError(msg)
	self.error_tip_txt:setString(msg)
end

function JoinRoomDialog:show()
	BLDialog.show(self)
end

function JoinRoomDialog:dismiss()
	BLDialog.dismiss(self)
	self:resetNum()
end

return JoinRoomDialog