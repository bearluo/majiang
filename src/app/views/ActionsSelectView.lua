local CircleClip = require("app.ui.CircleClip")

local Majiang = require("app.ui.Majiang")

local ActionsSelectView = class("ActionsSelectView",function()
    return display.newNode()
end)

function ActionsSelectView:ctor(ctrl)
	local node, width, height = cc.uiloader:load("actions_select_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	self.mCtrl = ctrl

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	cc.uiloader:seekNodeByName(node,"cancel_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.mCtrl:showPreActionView()
				self:setVisible(false)
			end)

	self:setVisible(false)
end

function ActionsSelectView:setActions(actions)
	self.mContentBg:removeAllChildren()
	local btns = {}
	for i,action in ipairs(actions) do
		local btn = cc.ui.UIPushButton.new('btn/btn_touming.png')
		local majiang = Majiang.new(action.card,Majiang.SELF_ON_HAND)
		majiang:addTo(btn)
		btn:onButtonClicked(function()
				tt.play.play_sound("click")
				self.mCtrl:action(action.action,action.card)
				self:setVisible(false)
			end)
		local size = majiang:getContentSize()
		local ap = majiang:getAnchorPoint()
		majiang:setPosition(size.width*ap.x,size.height*ap.y)
		btn:setContentSize(width,height)
		btn:scale(0.8)
		btn:addTo(self.mContentBg)  
		table.insert(btns,btn)
	end

	local w = #btns * 150
	local start = 40
	for i,btn in ipairs(btns) do
		btn:setPosition(cc.p(start + (i-1)*150,8))
	end

	self.mContentBg:setContentSize(w,self.mContentBg:getContentSize().height)
end

function ActionsSelectView:show()
	self:setVisible(true)
end

function ActionsSelectView:dismiss()
	self:setVisible(false)
end

return ActionsSelectView

