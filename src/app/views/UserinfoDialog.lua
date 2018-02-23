local BLDialog = require("app.ui.BLDialog")
local TAG = "UserinfoDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local UserinfoDialog = class("UserinfoDialog", function()
	return BLDialog.new()
end)


function UserinfoDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("userinfo_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	cc.uiloader:seekNodeByName(node, "copy_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			local params = tt.platformEventHalper.cmds.copyToClipboard
			params.args = {
				text = "xuleiqweasd123",
			}
			dump(params)
			local ok,ret = tt.platformEventHalper.callEvent(params)
			if ok then
				tt.show_msg("复制成功")
			else
				tt.show_msg("复制失败")
			end
		end)

	self.mHeadBg = cc.uiloader:seekNodeByName(node, "head_bg")
	self.mNameTxt = cc.uiloader:seekNodeByName(node, "name_txt")
	self.mIdTxt = cc.uiloader:seekNodeByName(node, "id_txt")
	self.mIpTxt = cc.uiloader:seekNodeByName(node, "ip_txt")
end

function UserinfoDialog:updateView()
	self.mNameTxt:setString(string.format("昵称:%s",tt.owner:getName()))
	self.mIdTxt:setString(string.format("ID:%s",tt.owner:getUid()))
	self.mIpTxt:setString(string.format("IP:%s",tt.owner:getIp()))

	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end
	print('UserinfoDialog:updateView',tt.owner:getIconUrl())
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

function UserinfoDialog:show()
	BLDialog.show(self)
	self:updateView()
end

function UserinfoDialog:dismiss()
	BLDialog.dismiss(self)
end

return UserinfoDialog