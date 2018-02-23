local BLDialog = require("app.ui.BLDialog")
local TAG = "ChooseDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local ChooseDialog = class("ChooseDialog", function()
	return BLDialog.new()
end)


function ChooseDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("choose_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")
	self.content_txt = cc.uiloader:seekNodeByName(node, "content_txt")
	self.cancel_btn = cc.uiloader:seekNodeByName(node, "cancel_btn")
		:onButtonClicked(handler(self, self.onCancelBtnClick))
	self.confirm_btn = cc.uiloader:seekNodeByName(node, "confirm_btn")
		:onButtonClicked(handler(self, self.onConfirmBtnClick))
end

function ChooseDialog:setMode(flag)
	if flag == 1 then
		self.cancel_btn:setVisible(true)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(200)
	elseif flag == 2 then
		self.cancel_btn:setVisible(false)
		self.confirm_btn:setVisible(true)
		self.confirm_btn:setPositionX(360)
	end
end

function ChooseDialog:show()
	BLDialog.show(self)
end

function ChooseDialog:dismiss()
	BLDialog.dismiss(self)
end

function ChooseDialog:setContentStr(str)
	self.content_txt:setString(str)
	return self
end

function ChooseDialog:setOnCancelClick(func)
	self.cancelClick = func
	return self
end

function ChooseDialog:setOnConfirmClick(func)
	self.confirmClick = func
	return self
end

function ChooseDialog:onCancelBtnClick()
	tt.play.play_sound("click")
	if type(self.cancelClick) == "function" and self.cancelClick() then
		return
	end
	self:dismiss()
end

function ChooseDialog:onConfirmBtnClick()
	tt.play.play_sound("click")
	if type(self.confirmClick) == "function" and self.confirmClick() then
		return
	end
	self:dismiss()
end


return ChooseDialog