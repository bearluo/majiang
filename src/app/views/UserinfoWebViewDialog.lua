local BLDialog = require("app.ui.BLDialog")
local TAG = "UserinfoWebViewDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local UserinfoWebViewDialog = class("UserinfoWebViewDialog", function()
	return BLDialog.new()
end)


function UserinfoWebViewDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("userinfo_webview_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.mHeadBg = cc.uiloader:seekNodeByName(node, "head_bg")
	self.mNameTxt = cc.uiloader:seekNodeByName(node, "name_txt")
	self.mIdTxt = cc.uiloader:seekNodeByName(node, "id_txt")
	self.mInviteIdTxt = cc.uiloader:seekNodeByName(node, "invite_id_txt")
	self.mInfoTxt = cc.uiloader:seekNodeByName(node, "info_txt")

	self.mTimeTxt = cc.uiloader:seekNodeByName(node, "time_txt")
	self.mCurDayTxt = cc.uiloader:seekNodeByName(node, "cur_day_txt")
	self.mCurMouthTxt = cc.uiloader:seekNodeByName(node, "cur_mouth_txt")
	self.mSumTxt = cc.uiloader:seekNodeByName(node, "sum_txt")
	self.mWebviewHandler = cc.uiloader:seekNodeByName(node, "webview_handler")
end

function UserinfoWebViewDialog:updateView()
	self.mNameTxt:setString(string.format("昵称:%s",tt.owner:getName()))
	self.mIdTxt:setString(string.format("ID:%s",tt.owner:getUid()))

	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end
	print('UserinfoWebViewDialog:updateView',tt.owner:getIconUrl())
	tt.asynGetHeadIconSprite(string.urldecode(tt.owner:getIconUrl()),function(sprite)
		if sprite and self and self.mHeadBg then
			local size = self.mHeadBg:getContentSize()
			local mask = display.newSprite("dec/touxiang_dec.png")
			if self.head_ then
				self.head_:removeSelf()
				self.head_ = nil
			end
			self.head_ = CircleClip.new(sprite,mask)
				:addTo(self.mHeadBg,99)
				:setPosition(cc.p(0,0))
				:setCircleClipContentSize(size.width,size.height)
		end
	end)
end

function UserinfoWebViewDialog:loadData(data)
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
	self.mSumTxt:setString(string.format("总收入:%s",data.all_profits))
end

function UserinfoWebViewDialog:show()
	BLDialog.show(self)
	local p = self.mWebviewHandler:convertToWorldSpace(cc.p(0,0))
	local size = self.mWebviewHandler:getContentSize()
	dump(p)
	tt.displayWebView(p.x,p.y+size.height,size.width,size.height)
	tt.webViewLoadUrl(string.format("%s/App/Mahjong/userdetail?user_id=%d",kHttpUrl,tt.owner:getUid()))
	self:updateView()
	local params = {}
	tt.ghttp.request(tt.cmd.appuserdetail,params)
end

function UserinfoWebViewDialog:dismiss()
	BLDialog.dismiss(self)
	tt.dismissWebView()
end

return UserinfoWebViewDialog