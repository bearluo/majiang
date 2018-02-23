--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local AccountsDialog = class("AccountsDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "AccountsDialog"
local net = require("framework.cc.net.init")
local MajiangGroup = require("app.ui.MajiangGroup")
local Majiang = require("app.ui.Majiang")
function AccountsDialog:ctor(control)
	self.mCtrl = control 

	local node, width, height = cc.uiloader:load("accounts_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.mContinueBtn = cc.uiloader:seekNodeByName(node,"continue_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:onContinueClick()
			end)


	self.mShareBtn = cc.uiloader:seekNodeByName(node,"share_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.makeScreen(function ( outfile )
					local ok,errorMsg = tt.WxHelper.shareBitmapToWx(outfile,"") 
					if not ok then
						tt.show_msg(errorMsg)
					end
		    	end)
			end)

	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_share) == 0 or tonumber(openConfig.check_status) == 1 then
		self.mShareBtn:setVisible(false)
	end

	self.mItemViews = cc.uiloader:seekNodeByName(node,"item_views")

	self.mItems = {}
	local h = self.mItemViews:getContentSize().height
	for i=1,4 do
		local item = app:createView("AccountsItem", control)
		item:setPosition(0,h-i*125)
		item:addTo(self.mItemViews)
		self.mItems[i] = item
	end
	self:setBackEvent(function() return true end)
end

function AccountsDialog:onContinueClick()
	self:dismiss()
	if self.mCtrl:isGameOver() then
		self.mCtrl:showTotalAccountsDialog()
	else
		self.mCtrl:ready()
	end
end

function AccountsDialog:startCountdown(time)
	self:stopCountdown()
	time = tonumber(time) or 0
	self:setCountdown(time)
	local action = self:schedule(function()
			time = time - 1
			self:setCountdown(time)
			if time <= 0 then
				self:stopCountdown()
				self:onContinueClick()
			end
		end, 1)
	action:setTag(1)
end

function AccountsDialog:stopCountdown()
	self:stopActionByTag(1)
end

function AccountsDialog:setCountdown(num)
	if not tolua.isnull(self.mCountdownView) then
		self.mCountdownView:removeSelf()
	end

	if num > 15 then
	    self.mContinueBtn:setButtonImage("normal", "btn/bt_jixu_1.png", true)
	    self.mContinueBtn:setButtonImage("pressed", "btn/bt_jixu_1.png", true)
	    self.mContinueBtn:setButtonImage("disabled", "btn/bt_jixu_1.png", true)
		return 
	else
	    self.mContinueBtn:setButtonImage("normal", "btn/bt_jixu.png", true)
	    self.mContinueBtn:setButtonImage("pressed", "btn/bt_jixu.png", true)
	    self.mContinueBtn:setButtonImage("disabled", "btn/bt_jixu.png", true)
	end
	self.mCountdownView = display.newNode()
	self.mCountdownView:setAnchorPoint(cc.p(0.5,0.5))
	local node = display.newNode()
	local num = display.newTTFLabel({
		    text = num,
		    size = 52,
		    color = cc.c3b(236, 225, 44), -- 使用纯红色
		})

	local s = display.newTTFLabel({
		    text = "秒",
		    size = 39,
		    color = cc.c3b(236, 225, 44), -- 使用纯红色
		})

	tt.linearlayout(node,num,0,-6)
	tt.linearlayout(node,s)
	self.mCountdownView:addChild(node)
	self.mCountdownView:setContentSize(node:getContentSize())
	self.mCountdownView:setPosition(cc.p(72,-16))
	self.mCountdownView:addTo(self.mContinueBtn)
end

function AccountsDialog:setUserInfo(seat_id,player)
	self.mItems[seat_id]:setUserInfo(player)
end

function AccountsDialog:setDealer(seat_id)
	self.mItems[seat_id]:setDealer()
end

function AccountsDialog:setScore(seat_id,score)
	self.mItems[seat_id]:setScore(score)
end

function AccountsDialog:createPeng(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:setGroup(MajiangGroup.PENG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function AccountsDialog:createGang(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:setGroup(MajiangGroup.GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function AccountsDialog:createAnGang(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:setGroup(MajiangGroup.AN_GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function AccountsDialog:createBian(value)
	local num = bit.band(value,0x0f)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:setGroup(MajiangGroup.BIAN)
	if num == 7 then
		mMajiangGroup:add(value)
		mMajiangGroup:add(value+1)
		mMajiangGroup:add(value+2)
	elseif num == 3 then
		mMajiangGroup:add(value-2)
		mMajiangGroup:add(value-1)
		mMajiangGroup:add(value)
	end
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function AccountsDialog:createZhuan(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:setGroup(MajiangGroup.ZHUAN)
	mMajiangGroup:add(value-1)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value+1)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function AccountsDialog:setShowCards(seat_id,peng_cards,gang_cards,zhuan_cards,bian_cards)
	print("AccountsDialog:setShowCards",seat_id)
	-- peng_cards = {
	-- 	1,
	-- }

	for i,card in ipairs(peng_cards) do
		self.mItems[seat_id]:addShowCardView(self:createPeng(card),5,0)
	end

	-- gang_cards = {
	-- 	{status = 0, id = 1},
	-- 	{status = 1, id = 1},
	-- }

    for i,card in ipairs(gang_cards) do 
    	if card.status == 0 then
			self.mItems[seat_id]:addShowCardView(self:createGang(card.id),5,0)
		elseif card.status == 1 then
			self.mItems[seat_id]:addShowCardView(self:createAnGang(card.id),5,0)
		end
    end
	-- zhuan_cards = {
	-- 	1,2,3
	-- }
    for i=2,#zhuan_cards,3 do 
		self.mItems[seat_id]:addShowCardView(self:createZhuan(zhuan_cards[i]),5,0)
    end
 --    bian_cards = {
 --    	1,2,3,7,8,9
	-- }
    for i=1,#bian_cards,3 do 
		local num = bit.band(bian_cards[i],0x0f)
		if num == 7 then
			self.mItems[seat_id]:addShowCardView(self:createBian(bian_cards[i]),5,0)

		else
			self.mItems[seat_id]:addShowCardView(self:createBian(bian_cards[i+2]),5,0)
		end
    end
end

function AccountsDialog:setHandCards(seat_id,card_ids)
	for i,card_id in ipairs(card_ids) do
		local majiang = Majiang.new(card_id,Majiang.SELF_ON_HAND)
		if i == 1 and #card_ids < 13 then
			self.mItems[seat_id]:addShowCardView(majiang,10,0)
		else
			self.mItems[seat_id]:addShowCardView(majiang,-3,0)
		end
	end
end

function AccountsDialog:setWinCards(seat_id,card_id,win_card_type_str)
	self.mItems[seat_id]:setWin(card_id,win_card_type_str)
end

function AccountsDialog:clearPreInfo()
	for i=1,4 do
		self.mItems[i]:clearInfo()
	end
end

function AccountsDialog:show()
	BLDialog.show(self)
end

function AccountsDialog:dismiss()
	self:stopCountdown()
	BLDialog.dismiss(self)
end

return AccountsDialog
