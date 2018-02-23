local BLDialog = require("app.ui.BLDialog")
local TAG = "InviteDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local InviteDialog = class("InviteDialog", function()
	return BLDialog.new()
end)


function InviteDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("invite_dialog.json")
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
			local ok,ret = tt.platformEventHalper.callEvent(params)
			if ok then
				tt.show_msg("复制成功")
			else
				tt.show_msg("复制失败")
			end
		end)

	self.mInputHandler = cc.uiloader:seekNodeByName(node, "input_handler")

	self.mNumTxt = cc.uiloader:seekNodeByName(node, "num")
    for i=0,9 do
    	cc.uiloader:seekNodeByName(node, "num_btn_"..i)
    		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:onChangeNum(self.mNumTxt:getString() .. i)
			end)
    end

    cc.uiloader:seekNodeByName(node, "num_btn_reset")
    	:onButtonClicked(function()
			tt.play.play_sound("click")
			self:onChangeNum()
		end)

	cc.uiloader:seekNodeByName(node, "num_btn_delete")
    	:onButtonClicked(function()
			tt.play.play_sound("click")
			self:onChangeNum(string.sub(self.mNumTxt:getString(),1,-2))
		end)

    self.mConfirmBtn = cc.uiloader:seekNodeByName(node, "confirm_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			self:addInvite()
		end)
end

function InviteDialog:onChangeNum(num)
	print("InviteDialog:onChangeNum",num)
	local num = tonumber(num)
	if num then
		self.mNumTxt:setString(string.sub(num,1,6))
	else
		self.mNumTxt:setString("")
	end
end

function InviteDialog:addInvite()
	local numStr = self.mNumTxt:getString()
	if #numStr == 0 then return end
	local params = {}
	params.join_sn = numStr
	tt.ghttp.request(tt.cmd.addinvite,params)
	self.mConfirmBtn:setTouchEnabled(false)
end

function InviteDialog:onFail()
	self.mConfirmBtn:setTouchEnabled(true)
end

function InviteDialog:onSuccess()
	self.control_:showShopDialog()
	self:dismiss()
end

function InviteDialog:show()
	BLDialog.show(self)
	self:onChangeNum()
end

function InviteDialog:dismiss()
	BLDialog.dismiss(self)
end

return InviteDialog