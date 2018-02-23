local ActionBtnView = class("ActionBtnView",function()
    return display.newNode()
end)

ActionBtnView.PENG 	= 6
ActionBtnView.BIAN 	= 5
ActionBtnView.ZHUAN = 4
ActionBtnView.GANG 	= 3
ActionBtnView.HU 	= 2
ActionBtnView.GUO 	= 1

function ActionBtnView:ctor(ctrl,view_id)
	local node, width, height = cc.uiloader:load("action_btn_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mCtrl = ctrl

	self.anim_bg = cc.uiloader:seekNodeByName(node,"anim_bg")
	self.action_btn = cc.uiloader:seekNodeByName(node,"action_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mShowMul then
					self.mCtrl:showMulAction(self.mCardValue)
					return 
				end
				if not self.mCardValue or not self.mId then return end
				self.mCtrl:action(self.mId,self.mCardValue)
			end)

	if view_id == ActionBtnView.BIAN then
		self.anim_bg:setTexture("btn/bian_1.png")
	    self.action_btn:setButtonImage("normal", "btn/bian_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/bian_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/bian_2.png", true)
	elseif view_id == ActionBtnView.ZHUAN then
		self.anim_bg:setTexture("btn/zuan_1.png")
	    self.action_btn:setButtonImage("normal", "btn/zuan_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/zuan_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/zuan_2.png", true)
	elseif view_id == ActionBtnView.GANG then
		self.anim_bg:setTexture("btn/gang_1.png")
	    self.action_btn:setButtonImage("normal", "btn/gang_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/gang_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/gang_2.png", true)
	elseif view_id == ActionBtnView.HU then
		self.anim_bg:setTexture("btn/hu_1.png")
	    self.action_btn:setButtonImage("normal", "btn/hu_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/hu_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/hu_2.png", true)
	elseif view_id == ActionBtnView.PENG then
		self.anim_bg:setTexture("btn/peng_1.png")
	    self.action_btn:setButtonImage("normal", "btn/peng_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/peng_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/peng_2.png", true)
	elseif view_id == ActionBtnView.GUO then
		self.anim_bg:setTexture("btn/guo_1.png")
	    self.action_btn:setButtonImage("normal", "btn/guo_2.png", true)
	    self.action_btn:setButtonImage("pressed", "btn/guo_2.png", true)
	    self.action_btn:setButtonImage("disabled", "btn/guo_2.png", true)
	end

	self:setVisible(false)
end

function ActionBtnView:setActionId(id)
	self.mId = id
end

function ActionBtnView:getCardValue()
	return self.mCardValue
end

function ActionBtnView:getActionId()
	return self.mId
end

function ActionBtnView:setShowMul(isShowMul)
	self.mShowMul = isShowMul
end

function ActionBtnView:actionFail()
	self:showAnim()
end

function ActionBtnView:showAnim()
	self:setVisible(true)

	self.anim_bg:stopAllActions()
	local sequence = transition.sequence({
	    cc.ScaleTo:create(0, 0.8),
	    cc.DelayTime:create(0.2),
	    cc.ScaleTo:create(0.8,1.1),
	})

	self.anim_bg:runAction(cc.RepeatForever:create(sequence))


	local sequence = transition.sequence({
	   	cc.FadeTo:create(0, 1*255),
	    cc.DelayTime:create(0.6),
	    cc.FadeTo:create(0.4, 0.2*255),
	})

	self.anim_bg:runAction(cc.RepeatForever:create(sequence))
end

function ActionBtnView:show(card_value)
	self.mCardValue =  card_value
	self:showAnim()
end

function ActionBtnView:dismiss()
	self:setVisible(false)
	self.anim_bg:stopAllActions()
end

return ActionBtnView

