local socket = require "socket"

local MajiangGroup = require("app.ui.MajiangGroup")

local ControlBoard = class("ControlBoard",function()
    return display.newNode()
end)

local Majiang = require("app.ui.Majiang")

local default_size_w = 1280
local default_size_h = 720
local default_y = 78
local bottom_move_limit = 150
local move_time = 0.1
local startX = 136
local default_scale = 1
local default_scale2 = 0.9
local subX = 75 * default_scale

function ControlBoard:ctor(ctrl)
	self.mCtrl = ctrl
	self.mCards = {}
	self.mShowCards = {}
	self.mLastCard = nil
	self:setContentSize(default_size_w,default_size_h)
	self:setAnchorPoint(cc.p(0,0))
	self:setTouchEnabled(false)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        	return self:onTouch_(event)
    	end)
	self:setTouchSwallowEnabled(false)
	-- self:addChild(display.newRect(cc.rect(0, 0, default_size_w, default_size_h),
 --        {fillColor = cc.c4f(1,0,0,1), borderColor = cc.c4f(0,1,0,1), borderWidth = 5}))
	self.mStartX = startX
end

function ControlBoard:sortCards()
	-- table.sort(self.mCards, function(view1,view2)
	-- 		return view1:getValue() > view2:getValue()
	-- 	end)
	local ret = {}
	while #self.mCards > 0 do
		local index = 1
		for i,card in ipairs(self.mCards) do
			if self.mCards[index]:getValue() < card:getValue() then
				index = i
			end
		end
		table.insert(ret,table.remove(self.mCards,index))
	end
	self.mCards = ret
end

function ControlBoard:reload()
	print("ControlBoard:reload")
	local tmpX = self.mStartX
	for i=#self.mCards,1,-1 do
		local card = self.mCards[i]
		card:setPosition(tmpX,default_y)
		card:setLocalZOrder(i)
		card:stopAllActionsByTag(100)
		tmpX = tmpX + subX
	end
end

function ControlBoard:playSortAnim()
	local delay = 0
	for i,card in ipairs(self.mCards) do
		if i % 4 == 0 then

		end
	end

	self:sortCards()
	self:performWithDelay(function()
			for i,card in ipairs(self.mCards) do
				card:playReverseAnim();
			end
            self:reload()
		end, 0.8)
end

function ControlBoard:setCards(tab)
	for i,card in ipairs(self.mCards) do
		card:removeSelf()
	end
	self.mCards = {}
	for i,v in ipairs(tab) do
		self.mCards[i] = Majiang.new(v,Majiang.SELF_ON_HAND)
		self.mCards[i]:scale(default_scale)
		self.mCards[i]:addTo(self,i)
		-- self.mCards[i]:setVisible(false)
	end
end

function ControlBoard:releaseCards()

	for i,card in ipairs(self.mShowCards) do
		card:removeSelf()
	end
	self.mShowCards = {}

	for i,card in ipairs(self.mCards) do
		card:removeSelf()
	end
	self.mCards = {}

	if not tolua.isnull(self.mLastCard) then
		self.mLastCard:removeSelf()
	end
	self.mLastCard = nil

	self:releaseShowCards()
end

function ControlBoard:addCard(value)
	print("ControlBoard:addCard",value)
	if not tolua.isnull(self.mLastCard) then
		self.mLastCard:removeSelf()
	end
	self.mLastCard = Majiang.new(value,Majiang.SELF_ON_HAND)
	self.mLastCard:scale(default_scale)
	self.mLastCard:setPosition(cc.p(self.mStartX+#self.mCards*subX+30,default_y))
	self.mLastCard:addTo(self,14)
end

function ControlBoard:delCard(value)
	print("ControlBoard:delCard",value)
	for i,card in ipairs(self.mCards) do
		if card:getValue() == value then
			table.remove(self.mCards,i)
			card:removeSelf()
			break
		end
	end
end

function ControlBoard:getCardNum()
	return #self.mCards
end

function ControlBoard:getCardData()
	local ret = {}
	for i,card in ipairs(self.mCards) do
		table.insert(ret,card:getValue())
	end
	if self.mLastCard then
		table.insert(ret,self.mLastCard:getValue())
	end
	return ret
end

function ControlBoard:clearSelectCard()
	if not tolua.isnull(self.mSelectCard) then
		for i=#self.mCards,1,-1 do
			local card = self.mCards[i]
			if self.mSelectCard == card then
				card:setLocalZOrder(i)
				break
			end
		end
		self.mSelectCard:stopAllActionsByTag(1)
		transition.moveTo(self.mSelectCard, {y = default_y, time = move_time}):setTag(1)

		if self.mSelectCard:getTingValue() then
			self.mCtrl:onDismissHuTipsViews()
		end

		self.mSelectCard = nil
	end
end

function ControlBoard:selectCard(card)
	if self.mSelectCard == card then return end
	
	tt.play.play_sound("audio_card_click")

	if not card then return end
	if not tolua.isnull(self.mSelectCard) then
		self:clearSelectCard()
	end
	card:stopAllActionsByTag(1)
	transition.moveTo(card, {y = default_y+30, time = move_time}):setTag(1)

	card:setLocalZOrder(100)
	self.mSelectCard = card

	if card:getTingValue() then
		self.mCtrl:onShowHuTipsViews(card:getTingValue())
	end
end

function ControlBoard:discard()
	if not self.mSelectCard then return false end
	local ret = self.mCtrl:discard(self.mSelectCard:getValue())
	return ret
end

function ControlBoard:onDiscard(value)
	self.mCtrl:onDismissHuTipsViews()
	if self.mSelectCard:getValue() == value then
		local retPos = self:convertToWorldSpace(cc.p(self.mSelectCard:getPosition()))
		if self.mSelectCard == self.mLastCard then
			self.mSelectCard:removeSelf()
			self.mSelectCard = nil
			self.mLastCard = nil
		else
			for i,card in ipairs(self.mCards) do
				if self.mSelectCard == card then
					table.remove(self.mCards,i)
					self.mSelectCard:removeSelf()
					self.mSelectCard = nil
					break
				end
			end  
			if self.mLastCard then
				table.insert(self.mCards,self.mLastCard)
				self:sortCards()
				self:playAddLastAnim(self.mLastCard)
				self.mLastCard = nil
				self:performWithDelay(handler(self, self.playMoveAnim), 0.4)
			else
				self:playMoveAnim()
			end
		end
		return retPos
	end
end

function ControlBoard:playAddLastAnim(card_view)
	print("playAddLastAnim")
	local pos = self:getCardViewPos(card_view)
	local card_pos_x,card_pos_y = card_view:getPosition()
	card_view:setPosition(cc.p(card_pos_x,card_pos_y))
	-- card_view:moveBy(0.4, pos.x - card_pos_x, 0):setTag(100)

	-- local sequence = transition.sequence({
	--     cc.MoveBy:create(0.2, cc.p(0,120)),
	--     cc.DelayTime:create(0.4),
	--     cc.MoveBy:create(0.2, cc.p(0,-120)),
	-- })
	-- card_view:runAction(sequence):setTag(1)

	-- local sequence = transition.sequence({
	--     cc.RotateBy:create(0.2, 10),
	--     cc.DelayTime:create(0.4),
	--     cc.RotateBy:create(0.2, -10),
	-- })
	-- card_view:runAction(sequence):setTag(1)
end

function ControlBoard:getCardViewPos(view)
	local tmpX = self.mStartX
	for i=#self.mCards,1,-1 do
		local card = self.mCards[i]
		if view == card then return cc.p(tmpX,default_y) end
		tmpX = tmpX + subX
	end
	return view:getPosition()
end

function ControlBoard:playMoveAnim()
	print("playMoveAnim")
	local tmpX = self.mStartX
	for i=#self.mCards,1,-1 do
		print("playMoveAnim",tmpX)
		local card = self.mCards[i]
		local card_pos_x,card_pos_y = card:getPosition()
		-- card:moveTo(0.1, tmpX,card_pos_y):setTag(100)
		card:setPosition(cc.p(tmpX,card_pos_y))
		card:setLocalZOrder(i)
		tmpX = tmpX + subX
	end
	if self.mLastCard then
		-- self.mLastCard:moveTo(0.1,self.mStartX+#self.mCards*subX+subX+30,default_y):setTag(100)
		self.mLastCard:setPosition(cc.p(self.mStartX+#self.mCards*subX+subX+30,default_y))
	end
end

function ControlBoard:delHandsCard(value)
	if not tolua.isnull(self.mLastCard) then
		if self.mLastCard:getValue() == value then
			self.mLastCard:removeSelf()
			self.mLastCard = nil
			return 
		end
	end
	for i,card in ipairs(self.mCards) do
		if card:getValue() == value then
			table.remove(self.mCards,i):removeSelf()
			break
		end
	end
end

function ControlBoard:delGang(value)
	for i,group in ipairs(self.mShowCards) do
		if group:getGroupType() == MajiangGroup.GANG and group:getValues()[1] == value then
			mMajiangGroup:setGroup(MajiangGroup.PENG)
			mMajiangGroup:del(value)
			mMajiangGroup:resetPosition()
			break
		end
	end
end

function ControlBoard:actionPeng(value)
	print("ControlBoard:actionPeng",value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	table.insert(self.mShowCards,self:createPeng(value))
    self:resetShowCardsPos()
    self:playMoveAnim()
end

function ControlBoard:actionGang(value)
	print("ControlBoard:actionGang",value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	table.insert(self.mShowCards,self:createGang(value))
    self:resetShowCardsPos()
    self:playMoveAnim()
end

function ControlBoard:actionBuGang(value)
	print("ControlBoard:actionBuGang",value)
	self:delHandsCard(value)
	if self.mLastCard then
		table.insert(self.mCards,self.mLastCard)
		self:sortCards()
		self:playAddLastAnim(self.mLastCard)
		self.mLastCard = nil
		self:playMoveAnim()
		-- self:performWithDelay(handler(self, self.playMoveAnim), 0.4)
	else
		self:playMoveAnim()
	end
	for i,group in ipairs(self.mShowCards) do
		if group:getGroupType() == MajiangGroup.PENG and group:getValues()[1] == value then
			group:setGroup(MajiangGroup.GANG)
			group:add(value)
			group:resetPosition()
			break
		end
	end
    self:resetShowCardsPos()
end

function ControlBoard:actionAnGang(value)
	print("ControlBoard:actionAnGang",value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	self:delHandsCard(value)
	table.insert(self.mShowCards,self:createAnGang(value))
    self:resetShowCardsPos()
	if self.mLastCard then
		table.insert(self.mCards,self.mLastCard)
		self:sortCards()
		self:playAddLastAnim(self.mLastCard)
		self.mLastCard = nil
		self:playMoveAnim()
		-- self:performWithDelay(handler(self, self.playMoveAnim), 0.4)
	else
		self:playMoveAnim()
	end
end

function ControlBoard:actionBian(value)
	print("ControlBoard:actionBian",value)
	local num = bit.band(value,0x0f)
	if num == 7 then
		self:delHandsCard(value)
		self:delHandsCard(value+1)
		self:delHandsCard(value+2)
	elseif num == 3 then
		self:delHandsCard(value)
		self:delHandsCard(value-1)
		self:delHandsCard(value-2)
	end
	table.insert(self.mShowCards,self:createBian(value))
    self:resetShowCardsPos()  
    self:playMoveAnim()
end

function ControlBoard:actionZhuan(value)
	print("ControlBoard:actionZhuan",value)
	self:delHandsCard(value)
	self:delHandsCard(value-1)
	self:delHandsCard(value+1)
	table.insert(self.mShowCards,self:createZhuan(value))
    self:resetShowCardsPos()
    self:playMoveAnim()
end

function ControlBoard:setShowCards(peng_cards,gang_cards,zhuan_cards,bian_cards)
	self:releaseShowCards()
	for i,card in ipairs(peng_cards) do
		table.insert(self.mShowCards,self:createPeng(card))
	end

	-- gang_cards = {
	-- 	{status = 0, id = 1},
	-- 	{status = 1, id = 1},
	-- }

    for i,card in ipairs(gang_cards) do 
    	if card.status == 0 then
			table.insert(self.mShowCards,self:createGang(card.id))
		elseif card.status == 1 then
			table.insert(self.mShowCards,self:createAnGang(card.id))
		end
    end

	-- zhuan_cards = {
	-- 	2,
	-- }
    for i=2,#zhuan_cards,3 do 
		table.insert(self.mShowCards,self:createZhuan(zhuan_cards[i]))
    end
 --    bian_cards = {
 --    	3,7,
	-- }
    for i=1,#bian_cards,3 do 
		local num = bit.band(bian_cards[i],0x0f)
		if num == 7 then
			table.insert(self.mShowCards,self:createBian(bian_cards[i]))
		else
			table.insert(self.mShowCards,self:createBian(bian_cards[i+2]))
		end
    end

    self:resetShowCardsPos()
    self:playMoveAnim()
end

function ControlBoard:resetShowCardsPos()
	local startPos = 40
    print("resetShowCardsPos1",self.mStartX)
	self.mStartX = startX
	for i,card in ipairs(self.mShowCards) do
		card:setPosition(startPos,20)
		local mGroupType = card:getGroupType()
		local offset = 0
		if mGroupType == MajiangGroup.PENG then
			offset = 250 * default_scale2
		elseif mGroupType == MajiangGroup.GANG then
			offset = 250 * default_scale2
		elseif mGroupType == MajiangGroup.AN_GANG then
			offset = 250 * default_scale2
		elseif mGroupType == MajiangGroup.BIAN then
			offset = 167 * default_scale2
		elseif mGroupType == MajiangGroup.ZHUAN then
			offset = 167 * default_scale2
		end
		startPos = startPos + offset
    end
    if #self.mShowCards > 0 then
    	self.mStartX = startPos + 40
    end
    print("resetShowCardsPos2",self.mStartX)
end

function ControlBoard:releaseShowCards()
	for i,card in ipairs(self.mShowCards) do
		card:removeSelf()
	end
	self.mShowCards = {}
	self.mStartX = startX
end

function ControlBoard:getShowCardData()
	local peng_cards = {}
	local gang_cards = {}
	local zhuan_cards = {}
	local bian_cards = {}
	for i,card in ipairs(self.mShowCards) do
		local mGroupType = card:getGroupType()
		if mGroupType == MajiangGroup.PENG then
			table.insert(peng_cards,card:getValues()[1])
		elseif mGroupType == MajiangGroup.GANG then
			table.insert(gang_cards,{status = 0, id = card:getValues()[1]})
		elseif mGroupType == MajiangGroup.AN_GANG then
			table.insert(gang_cards,{status = 1, id = card:getValues()[1]})
		elseif mGroupType == MajiangGroup.BIAN then
			for i,card_id in ipairs(card:getValues()) do
				table.insert(bian_cards,card_id)
			end
		elseif mGroupType == MajiangGroup.ZHUAN then
			for i,card_id in ipairs(card:getValues()) do
				table.insert(zhuan_cards,card_id)
			end
		end
    end
    return peng_cards,gang_cards,zhuan_cards,bian_cards
end


function ControlBoard:createPeng(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self)
	mMajiangGroup:setGroup(MajiangGroup.PENG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function ControlBoard:createGang(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self)
	mMajiangGroup:setGroup(MajiangGroup.GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function ControlBoard:createAnGang(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self)
	mMajiangGroup:setGroup(MajiangGroup.AN_GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function ControlBoard:createBian(value)
	local num = bit.band(value,0x0f)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self)
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

function ControlBoard:createZhuan(value)
	local mMajiangGroup = MajiangGroup.new(3)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self)
	mMajiangGroup:setGroup(MajiangGroup.ZHUAN)
	mMajiangGroup:add(value-1)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value+1)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function ControlBoard:onActioning()
	self:setTouchEnabled(true)
	self:showActionTips()
end

function ControlBoard:onActioned()
	self:setTouchEnabled(false)
	for i,card in ipairs(self.mCards) do
		card:clearTingValue()
	end
	if self.mLastCard then
		self.mLastCard:clearTingValue()
	end
end

function ControlBoard:showActionTips()
	local keys = {}
	local hu = {}
	local start = os.clock()
	print("start",start)
	for i,card in ipairs(self.mCards) do
		keys[card:getValue()] = (keys[card:getValue()] or 0) + 1
		card:clearTingValue()
	end
	if self.mLastCard then
		local last = self.mLastCard:getValue() 
		keys[last] = (keys[last] or 0) + 1
		self.mLastCard:clearTingValue()
	end
	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if keys[index] and keys[index] > 0 then
				keys[index] = keys[index] - 1
				local tingTab = self:getTingTab(keys)
				if #tingTab > 0 then
					hu[index] = tingTab
				end
				keys[index] = keys[index] + 1
			end
		end
	end

	for i=0x31,0x34,0x01 do
		local index = i
		if keys[index] and keys[index] > 0 then
			keys[index] = keys[index] - 1
			local tingTab = self:getTingTab(keys)
			if #tingTab > 0 then
				hu[index] = tingTab
			end
			keys[index] = keys[index] + 1
		end
	end

	for i=0x41,0x43,0x01 do
		local index = i
		if keys[index] and keys[index] > 0 then
			keys[index] = keys[index] - 1
			local tingTab = self:getTingTab(keys)
			if #tingTab > 0 then
				hu[index] = tingTab
			end
			keys[index] = keys[index] + 1
		end
	end
	print("use time",os.clock()-start)

	for i,card in ipairs(self.mCards) do
		if hu[card:getValue()] then
			card:setTingValue(hu[card:getValue()])
		end
	end

	if self.mLastCard then
		local last = self.mLastCard:getValue()
		if hu[last] then
			self.mLastCard:setTingValue(hu[last])
		end
	end
	print("use tupian",os.clock()-start)
end

function ControlBoard:getTingTab(i_keys)
	local ting = {}
	local keys = clone(i_keys)
	local getNum = function(value) return tonumber(value) or 0 end
	-- 边胡
	-- 钻胡
	local bianCount = 0
	local zhuanCount = 0
	for i,group in ipairs(self.mShowCards) do
		if group:getGroupType() == MajiangGroup.BIAN then
    		bianCount = bianCount + 1
		end
		if group:getGroupType() == MajiangGroup.ZHUAN then
    		zhuanCount = zhuanCount + 1
		end
	end

	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if getNum(keys[index]) > 0 or 
				( getNum(keys[index-1]) > 0 and getNum(keys[index-2]) > 0 ) or 
				( getNum(keys[index-1]) > 0 and getNum(keys[index+1]) > 0 ) or
				( getNum(keys[index+1]) > 0 and getNum(keys[index+2]) > 0 ) then
				if self:checkHu(keys,index,bianCount,zhuanCount) then
					table.insert(ting,index)
				end
			end
		end
	end

	for i=0x31,0x34,0x01 do
		local index = i
		if getNum(keys[index]) > 0 or 
			( getNum(keys[index-1]) > 0 and getNum(keys[index-2]) > 0 ) or 
			( getNum(keys[index-1]) > 0 and getNum(keys[index+1]) > 0 ) or
			( getNum(keys[index+1]) > 0 and getNum(keys[index+2]) > 0 ) then
			if self:checkHu(keys,index,bianCount,zhuanCount) then
				table.insert(ting,index)
			end
		end
	end

	for i=0x41,0x43,0x01 do
		local index = i
		if getNum(keys[index]) > 0 or 
			( getNum(keys[index-1]) > 0 and getNum(keys[index-2]) > 0 ) or 
			( getNum(keys[index-1]) > 0 and getNum(keys[index+1]) > 0 ) or
			( getNum(keys[index+1]) > 0 and getNum(keys[index+2]) > 0 ) then
			if self:checkHu(keys,index,bianCount,zhuanCount) then
				table.insert(ting,index)
			end
		end
	end
	return ting
end

function ControlBoard:checkHu(i_keys,last_card,bianCount,zhuanCount)
	local keys = clone(i_keys)
	local last = last_card
	-- 胡
	if bianCount > 0 or zhuanCount > 0 then
		print("边钻胡")
		local num = bit.band(last,0x0f)
	    -- 钻
	    local zhuanAction = nil
	    local bianAction = nil
		if last < 0x30 then
		    if keys[last - 1] and keys[last + 1] and not isFirst then
		    	zhuanAction = {action=OPE_MIDDEL_CHI,card=last}
		    end
		    -- 边
		    if num == 3 or num == 7 then
		        local offset = 1
		        if num == 3 then offset = -1 end
		        if keys[last + offset] and keys[last + offset * 2] and not isFirst then
		            if num == 3 then
		            	bianAction = {action=OPE_RIGHT_CHI,card=last}
		            else
		            	bianAction = {action=OPE_LEFT_CHI,card=last}
		            end
		        end
		    end
		end

		if bianCount == 2 and bianAction then
			if num == 3 then
				keys[last-1] = keys[last-1] - 1
				keys[last-2] = keys[last-2] - 1
			else
				keys[last+1] = keys[last+1] - 1
				keys[last+2] = keys[last+2] - 1
			end
			if Majiang.pingHu(keys) then
				return true
			end
			if num == 3 then
				keys[last-1] = keys[last-1] + 1
				keys[last-2] = keys[last-2] + 1
			else
				keys[last+1] = keys[last+1] + 1
				keys[last+2] = keys[last+2] + 1
			end
		elseif bianCount >= 3 then 
			keys[last] = (keys[last] or 0) + 1
			if Majiang.pingHu(keys) then
				return true
			end
			keys[last] = keys[last] - 1
		end

		if zhuanCount == 2 and zhuanAction then
			keys[last-1] = keys[last-1] - 1
			keys[last+1] = keys[last+1] - 1
			if Majiang.pingHu(keys) then
				return true
			end
			keys[last-1] = keys[last-1] + 1
			keys[last+1] = keys[last+1] + 1
		elseif zhuanCount >= 3 then 
			keys[last] = (keys[last] or 0) + 1
			if Majiang.pingHu(keys) then
				return true
			end
			keys[last] = keys[last] - 1
		end
	else
		keys[last] = (keys[last] or 0) + 1
		if Majiang.pingHu(keys) or Majiang.qixiaodui(keys) then
			return true
		end
		keys[last] = keys[last] - 1
	end
end

function ControlBoard:actionCheck(isFirst)
	local keys = {}
	local actions = {}
	for i,card in ipairs(self.mCards) do
		keys[card:getValue()] = (keys[card:getValue()] or 0) + 1
	end

	if self.mLastCard then
		local last = self.mLastCard:getValue()
    	local num = bit.band(last,0x0f)
	    -- 钻
	    local zhuanAction = nil
	    local bianAction = nil
    	if last < 0x30 then
	        if keys[last + 1] and keys[last - 1] and not isFirst then
		    	zhuanAction = {action=OPE_MIDDEL_CHI,card=last}
				table.insert(actions,zhuanAction)
		    end
		    -- 边
		    if num == 3 or num == 7 then
		        local offset = 1
		        if num == 3 then offset = -1 end
		        if keys[last + offset] and keys[last + offset * 2] and not isFirst then
		            if num == 3 then
		            	bianAction = {action=OPE_RIGHT_CHI,card=last}
		            else
		            	bianAction = {action=OPE_LEFT_CHI,card=last}
		            end
					table.insert(actions,bianAction)
		        end
		    end
		end

	    -- 暗杠
	    if keys[last] and keys[last] == 3 then
        	table.insert(actions,{action=OPE_AN_GANG,card=last})
	    end

	    -- 补杠
	    for i,group in ipairs(self.mShowCards) do
			if group:getGroupType() == MajiangGroup.PENG and group:getValues()[1] == last then
        		table.insert(actions,{action=OPE_BU_GANG,card=last})
				break
			end
		end

		-- 胡

		-- 边胡
		-- 钻胡
		local bianCount = 0
		local zhuanCount = 0
		for i,group in ipairs(self.mShowCards) do
			if group:getGroupType() == MajiangGroup.BIAN then
        		bianCount = bianCount + 1
			end
			if group:getGroupType() == MajiangGroup.ZHUAN then
        		zhuanCount = zhuanCount + 1
			end
		end
		if bianCount > 0 or zhuanCount > 0 then
			print("边钻胡")
			if bianCount == 2 and bianAction then
				if num == 3 then
					keys[last-1] = keys[last-1] - 1
					keys[last-2] = keys[last-2] - 1
				else
					keys[last+1] = keys[last+1] - 1
					keys[last+2] = keys[last+2] - 1
				end
				if Majiang.pingHu(keys) then
					table.insert(actions,{action=OPE_ZI_MO,card=last})
				end
				if num == 3 then
					keys[last-1] = keys[last-1] + 1
					keys[last-2] = keys[last-2] + 1
				else
					keys[last+1] = keys[last+1] + 1
					keys[last+2] = keys[last+2] + 1
				end
			elseif bianCount >= 3 then 
				keys[last] = (keys[last] or 0) + 1
				if Majiang.pingHu(keys) then
					table.insert(actions,{action=OPE_ZI_MO,card=last})
				end
				keys[last] = keys[last] - 1
			end

			if zhuanCount == 2 and zhuanAction then
				keys[last-1] = keys[last-1] - 1
				keys[last+1] = keys[last+1] - 1
				if Majiang.pingHu(keys) then
					table.insert(actions,{action=OPE_ZI_MO,card=last})
				end
				keys[last-1] = keys[last-1] + 1
				keys[last+1] = keys[last+1] + 1
			elseif zhuanCount >= 3 then 
				keys[last] = (keys[last] or 0) + 1
				if Majiang.pingHu(keys) then
					table.insert(actions,{action=OPE_ZI_MO,card=last})
				end
				keys[last] = keys[last] - 1
			end
		else
			print("平胡")
			keys[last] = (keys[last] or 0) + 1
			if Majiang.pingHu(keys) or Majiang.qixiaodui(keys) then
				table.insert(actions,{action=OPE_ZI_MO,card=last})
			end
			keys[last] = keys[last] - 1
		end
	end
	-- 补杠
	for i,card in ipairs(self.mCards) do
		for j,group in ipairs(self.mShowCards) do
			if group:getGroupType() == MajiangGroup.PENG and group:getValues()[1] == card:getValue() then
        		table.insert(actions,{action=OPE_BU_GANG,card=card:getValue()})
				break
			end
		end
	end
    -- 暗杠
    for card,count in pairs(keys) do
    	print(count)
        if count == 4 then
        	table.insert(actions,{action=OPE_AN_GANG,card=card})
        end
    end
    print("ControlBoard:actionCheck")
    dump(actions)
    if #actions then
    	self.mCtrl:showActionBtn(actions)
    end
end

function ControlBoard:onTouch_(event)
	print("ControlBoard:onTouch_")
	dump(event)
    local name, x, y = event.name, event.x, event.y
    local selectCard = nil
    if name == "moved" and self.moveSelectCarding then
		if not tolua.isnull(self.mSelectCard) then
			self.mSelectCard:setPosition(cc.p(x, y))
		end
    	return
    end
	for i,card in ipairs(self.mCards) do
		if card:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			selectCard = card
			break
		end
	end

	if not selectCard and self.mLastCard then
		if self.mLastCard:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
			selectCard = self.mLastCard
		end
	end

    if name == "began" then
    	if not selectCard then 
    		self:clearSelectCard()
    		print()
    		return false 
    	end
    	self.moveSelectCarding = false

    	if self.mClickTime and socket.gettime() - self.mClickTime < 0.5 then
    		if selectCard == self.mSelectCard then
	    		self.doubleClick = true
	    	else
	    		self.doubleClick = false
	    	end
	    else
    		self.doubleClick = false
    	end
    	self:selectCard(selectCard)
 		self.mClickTime = socket.gettime()
    	return true
    elseif name == "moved" then

    	if selectCard ~= self.mSelectCard then
    		self.doubleClick = false
    	end

    	if selectCard == self.mSelectCard or y < bottom_move_limit then
			-- self:selectCard(selectCard)
    	else
    		if not tolua.isnull(self.mSelectCard) then
    			self.mMoveBackX = select(1,self.mSelectCard:getPosition())
    			self.mSelectCard:setPosition(cc.p(x, y))
    			self.moveSelectCarding = true
    			self.doubleClick = false
    		end
    	end
    elseif name == "ended" then
    	if self.moveSelectCarding then
    		if y > bottom_move_limit and self:discard() then
				self:onActioned()
    			-- 出牌
    		else
    			self.mSelectCard:stopAllActionsByTag(1)
				transition.moveTo(self.mSelectCard, {x = self.mMoveBackX,y = default_y+30, time = move_time}):setTag(1)
    		end
    	else
    		if self.doubleClick then
    			if self:discard() then
					self:onActioned()
    			else
    				-- self:clearSelectCard()
    			end
    		else
				-- self:selectCard(selectCard)
    		end
    	end
    end
end

return ControlBoard