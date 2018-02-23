local TAG = "HornView"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local HornView = class("HornView", function()
	return display.newNode()
end)


function HornView:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("horn_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.root_:setCascadeOpacityEnabled(true)

	self.content_view = cc.uiloader:seekNodeByName(node,"content_view")
		:setCascadeOpacityEnabled(true)

	self.mMsgList = {}

	self.mMsgView = {}

	self:opacity(0)

	self:setCascadeOpacityEnabled(true)
end

function HornView:show(str)
	printInfo("HornView:show")
	-- self:setVisible(true)
	self:stopAction(self.mFadeAction)
	self.mFadeAction = transition.fadeIn(self, {time = 0.5})

	self:pushMsg(str)
	self:startAnim()
end

function HornView:dismiss()
	printInfo("HornView:dismiss")
	self:stopAction(self.mFadeAction)
	self.mFadeAction = transition.fadeOut(self, {time = 0.5})
	-- self:setVisible(false)
end

function HornView:startAnim()
	if self.mAnimDelay then return end
	local msg = table.remove(self.mMsgList,1)
	if msg then
		local label = display.newTTFLabel({
		    text = msg,
		    size = 25,
		    color = cc.c3b(243, 180, 18), -- 使用纯红色
		    align = cc.TEXT_ALIGNMENT_LEFT,
		    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
		})
		label:addTo(self.content_view)
		local size = self.content_view:getContentSize()
		local tsize = label:getContentSize()
		local width = size.width + tsize.width
		local time = width / 60
		label:setPosition(size.width,20)
		transition.moveBy(label, {x = -width, y = 0, time = time})
		self.mAnimDelay = self:performWithDelay( function()
			self.mAnimDelay = nil
			self:startAnim()
		end ,tsize.width / 60 + 4)

		self:stopAction(self.mDismissAction)

		self.mDismissAction = self:performWithDelay( function()
			self.mDismissAction = nil
			self:dismiss()
		end ,time - 4)
	end
end

function HornView:pushMsg(str)
	table.insert(self.mMsgList,str)
end

return HornView