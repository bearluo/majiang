--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local NoticeDialog = class("NoticeDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "NoticeDialog"
local net = require("framework.cc.net.init")
local contentTxt = ""
function NoticeDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("notice_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.content_scroll = cc.uiloader:seekNodeByName(node,"content_scroll")
	-- self.content_scroll:setLayoutPadding(20,10,20,10)
	local node = display.newNode()
	node:setContentSize(cc.size(570, 374))
	self.content_scroll:addScrollNode(node)
end

function NoticeDialog:setNoticeStr(str)
	local node = self.content_scroll:getScrollNode()
	node:removeAllChildren()
	local view = display.newTTFLabel({
	    text = str,
	    size = 28,
	    color = cc.c3b(146, 25, 25),
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	    dimensions = cc.size(570, 0)
	})
	view:setAnchorPoint(cc.p(0,1))
	view:setPosition(0,374)
	node:addChild(view)
end

function NoticeDialog:onLoadData(params)
	if not params or not params.data or params.ret ~= 0 then return end
 -- {"adcontent":"灌灌灌灌过",//公告内容"adtitle":"反反复复",//标题"adtime":"1545534523"//添加时间}
 	self:setNoticeStr(params.data.adcontent)
end


function NoticeDialog:show()
	BLDialog.show(self)
	self.content_scroll:scrollTo(156, 52)

	local params = {}
	tt.ghttp.request(tt.cmd.get_notice,params)
end

function NoticeDialog:dismiss()
	BLDialog.dismiss(self)
end

return NoticeDialog
