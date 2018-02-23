local BLDialog = require("app.ui.BLDialog")
local TAG = "WebPayDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local WebPayDialog = class("WebPayDialog", function()
	return BLDialog.new()
end)


function WebPayDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("web_pay_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.mWebviewHandler = cc.uiloader:seekNodeByName(node, "handler_view")
end


function WebPayDialog:loadData(data)
	dump(data)
	self.mInviteIdTxt:setString(string.format("邀请码:%s",data.join_sn))
	if tonumber(data.role) == 2 then
		self.mInfoTxt:setString(string.format("玩家人数:%s",data.user_num .. ""))
	elseif tonumber(data.role) == 3 then
		self.mInfoTxt:setString(string.format("玩家人数:%s    代理人数:%s",data.user_num .. "", data.agent_num .. ""))
	end

	self.mTimeTxt:setString(data.time)
	self.mCurDayTxt:setString(string.format("当日收入:%s",data.day_profits))
	self.mCurMouthTxt:setString(string.format("当月收入:%s",data.mon_profits))
	self.mSumTxt:setString(string.format("当月收入:%s",data.all_profits))
end

function WebPayDialog:show()
	BLDialog.show(self)
	local p = self.mWebviewHandler:convertToWorldSpace(cc.p(0,0))
	local size = self.mWebviewHandler:getContentSize()
	tt.displayWebView(p.x,p.y+size.height,size.width,size.height)
end

function WebPayDialog:loadUrl(url)
	tt.webViewLoadUrl(url)
	if device.platform == "windows" or device.platform == "mac" then
		device.openURL(url)
	end
end

function WebPayDialog:dismiss()
	BLDialog.dismiss(self)
	tt.dismissWebView()
end

return WebPayDialog