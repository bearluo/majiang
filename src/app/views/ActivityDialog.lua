local BLDialog = require("app.ui.BLDialog")
local TAG = "ActivityDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local ActivityDialog = class("ActivityDialog", function()
	return BLDialog.new()
end)


function ActivityDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("activity_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.mWebviewHandler = cc.uiloader:seekNodeByName(node, "webview_handler")
end

function ActivityDialog:show(url)
	BLDialog.show(self)
	local p = self.mWebviewHandler:convertToWorldSpace(cc.p(0,0))
	local size = self.mWebviewHandler:getContentSize()
	dump(p)
	dump(size)
	tt.displayWebView(p.x,p.y+size.height,size.width,size.height)
	tt.webViewLoadUrl(url)

	if device.platform == "windows" or device.platform == "mac" then
		device.openURL(url)
	end
end

function ActivityDialog:dismiss()
	BLDialog.dismiss(self)
	tt.dismissWebView()
end

return ActivityDialog