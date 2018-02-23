local MajiangGroup = require("app.ui.MajiangGroup")

local MajiangBoard = class("MajiangBoard",function()
    return display.newNode()
end)

local top = 1
local left = 2
local bottom = 3
local right = 4

local default_size_w = 1280
local default_size_h = 720
local default_scale2 = 0.5
local lie = 8
local lie2 = 8

local Majiang = require("app.ui.Majiang")

function MajiangBoard:ctor(ctrl)
	self.mCtrl = ctrl
	self:setContentSize(default_size_w,default_size_h)
	self.mDiscardCards = {}
	self.mHandCards = {}
	self.mHandLastCards = {}
	self.mHandCardsHandlers = {}
	self.mDiscardCardsHandlers = {}
	self.mShowCards = {}
	self.mHandCardsPos = {}


	for i=1,4 do
		self.mShowCards[i] = {}
		self.mHandCardsPos[i] = 0
		self.mHandCardsHandlers[i] = display.newNode()
		:addTo(self)
		self.mDiscardCardsHandlers[i] = display.newNode()
		:addTo(self)
	end


	self:resetBoard()


end

function MajiangBoard:addHandCard(seat_id,card_value)
	if self.mHandLastCards[seat_id] then
		self.mHandLastCards[seat_id]:removeSelf()
		self.mHandLastCards[seat_id] = nil
	end
	local majiang = Majiang.new(0,Majiang.TOP_ON_HAND + seat_id - 1)
	-- if seat_id == top or seat_id == bottom then
		majiang:scale(0.57)
	-- else
	-- 	majiang:scale(1)
	-- end
	majiang:addTo(self.mHandCardsHandlers[seat_id])
	self.mHandLastCards[seat_id] = majiang
	self:resetHandCardsPos(seat_id)
end

function MajiangBoard:delHandCard(seat_id)
	if self.mHandLastCards[seat_id] then
		self.mHandLastCards[seat_id]:removeSelf()
		self.mHandLastCards[seat_id] = nil
	else
		if #self.mHandCards[seat_id] > 0 then
			local card = table.remove(self.mHandCards[seat_id])
			card:removeSelf()
		end
	end
	self:resetHandCardsPos(seat_id)
end

function MajiangBoard:addDiscardCard(seat_id,card_value,pos)
	if not tolua.isnull(self.mTipsIcon) then
		self.mTipsIcon:removeSelf()
		self.mTipsIcon = nil
	end
	local majiang
	if seat_id == top then
		majiang = self:addTopDiscardCards(card_value,pos)
		local x,y = majiang:getPosition()
		self:setDiscardPos(x,y+45)
		self.mTipsIcon:setVisible(false)
	elseif seat_id == left then
		majiang = self:addLeftDiscardCards(card_value,pos)
		local x,y = majiang:getPosition()
		self:setDiscardPos(x-6,y+43)
		self.mTipsIcon:setVisible(false)
	elseif seat_id == bottom then
		majiang = self:addBottomDiscardCards(card_value,pos)
		local x,y = majiang:getPosition()
		self:setDiscardPos(x,y+45)
		self.mTipsIcon:setVisible(false)
	elseif seat_id == right then
		majiang = self:addRightDiscardCards(card_value,pos)
		local x,y = majiang:getPosition()
		self:setDiscardPos(x-6,y+43)
		self.mTipsIcon:setVisible(false)
	end
end

function MajiangBoard:setDiscardPos(x,y)
	if not tolua.isnull(self.mTipsIcon) then
		self.mTipsIcon:removeSelf()
	end
	local view = cc.CSLoader:createNode("anim/zuobiao/zuobiao.csb")--cc.uiloader:load("anim/bian/bian.csb")
	view:setPosition(x,y)
	local action = cc.CSLoader:createTimeline("anim/zuobiao/zuobiao.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,71,true)

	self.mTipsIcon = view
	self.mTipsIcon:addTo(self)
	self.mTipsIcon:setPosition(x,y)
	-- local sequence = transition.sequence({
	--     cc.MoveBy:create(0.4, cc.p(0,10)),
	--     cc.MoveBy:create(0.4, cc.p(0,-10)),
	--     -- cc.DelayTime:create(0.4),
	-- })
	-- self.mTipsIcon:runAction(cc.RepeatForever:create(sequence))
end

function MajiangBoard:delDiscardCard(seat_id)
	if not tolua.isnull(self.mTipsIcon) then
		self.mTipsIcon:removeSelf()
		self.mTipsIcon = nil
	end
	if #self.mDiscardCards[seat_id] > 0 then
		local card = table.remove(self.mDiscardCards[seat_id])
		card:removeSelf()
	end
end

function MajiangBoard:setCards(seat_id, num)
	for _,card in ipairs(self.mHandCards[seat_id] or {}) do
		card:removeSelf()
	end
	self.mHandCards[seat_id] = {}
	for i=1,num do
		local majiang = Majiang.new(0,Majiang.TOP_ON_HAND + seat_id - 1)
		-- if seat_id == top or seat_id == bottom then
			majiang:scale(0.57)
		-- else
		-- 	majiang:scale(1)
		-- end
		majiang:addTo(self.mHandCardsHandlers[seat_id])
		table.insert(self.mHandCards[seat_id],majiang)
	end
	self:resetHandCardsPos(seat_id)
end

function MajiangBoard:setBottomHandCardsVisible(flag)
	self.mHandCardsHandlers[bottom]:setVisible(flag)
end

function MajiangBoard:resetHandCardsPos(seat_id)
	if seat_id == top then
		self:resetTopHandCardsPos()
	elseif seat_id == left then
		self:resetLeftHandCardsPos()
	elseif seat_id == right then
		self:resetRightHandCardsPos()
	elseif seat_id == bottom then
		self:resetBottomHandCardsPos()
	end
end

function MajiangBoard:resetDiscardCards(seat_id,card_values)
	dump(card_values)
	if seat_id == top then
		self:resetTopDiscardCards(card_values)
	elseif seat_id == left then
		self:resetLeftDiscardCards(card_values)
	elseif seat_id == right then
		self:resetRightDiscardCards(card_values)
	elseif seat_id == bottom then
		self:resetBottomDiscardCards(card_values)
	end
end

function MajiangBoard:resetBoard()
	if not tolua.isnull(self.mTipsIcon) then
		self.mTipsIcon:removeSelf()
	end
	for i=1,4 do
		for _,card in ipairs(self.mDiscardCards[i] or {}) do
			card:removeSelf()
		end
		for _,card in ipairs(self.mHandCards[i] or {}) do
			card:removeSelf()
		end
		self.mDiscardCards[i] = {}
		self.mHandCards[i] = {}
		if self.mHandLastCards[i] then
			self.mHandLastCards[i]:removeSelf()
			self.mHandLastCards[i] = nil
		end
		self:releaseShowCards(i)

		-- self:resetHandCardsPos(i)
		-- self:setShowCards(i)
	end
end

function MajiangBoard:resetTopHandCardsPos()
	local startX = 362
	local Y = 626
	local offset = 37

	if self.mHandLastCards[top] then
		self.mHandLastCards[top]:setPosition(cc.p(startX - offset - 12,Y))
		self.mHandLastCards[top]:setLocalZOrder(-Y)
	end

	for _,card in ipairs(self.mHandCards[top]) do
		card:setPosition(cc.p(startX,Y))
		card:setLocalZOrder(-Y)
		startX = startX + offset
	end
	self.mHandCardsPos[top] = startX
	self:resetShowCardsPos(top)
end

function MajiangBoard:resetLeftHandCardsPos()
	local X = 140
	local startY = 210
	local offset = 34

	if self.mHandLastCards[left] then
		self.mHandLastCards[left]:setPosition(cc.p(X,startY-offset-12))
		self.mHandLastCards[left]:setLocalZOrder(-startY+offset+12)
		-- startY = startY + offset + 10
	end

	for _,card in ipairs(self.mHandCards[left]) do
		card:setPosition(cc.p(X,startY))
		card:setLocalZOrder(-startY)
		startY = startY + offset
	end
	self.mHandCardsPos[left] = startY
	self:resetShowCardsPos(left)
end

function MajiangBoard:resetBottomHandCardsPos()
	local startX = 200
	local Y = 100
	local offset = 37

	if self.mHandLastCards[bottom] then
		self.mHandLastCards[bottom]:setPosition(cc.p(startX - offset - 10,Y))
		self.mHandLastCards[bottom]:setLocalZOrder(-Y)
	end

	for _,card in ipairs(self.mHandCards[bottom]) do
		card:setPosition(cc.p(startX,Y))
		card:setLocalZOrder(-Y)
		startX = startX + offset
	end
	self.mHandCardsPos[bottom] = startX
	self:resetShowCardsPos(bottom)
end

function MajiangBoard:resetRightHandCardsPos()
	local X = 1140
	local startY = 624
	local offset = 34

	if self.mHandLastCards[right] then
		self.mHandLastCards[right]:setPosition(cc.p(X,startY + offset + 12))
		self.mHandLastCards[right]:setLocalZOrder(-startY - offset - 12)
	end

	for _,card in ipairs(self.mHandCards[right]) do
		card:setPosition(cc.p(X,startY))
		card:setLocalZOrder(-startY)
		startY = startY - offset
	end
	self.mHandCardsPos[right] = startY
	self:resetShowCardsPos(right)
end

function MajiangBoard:playAddDiscardCardsAnim(seat_id,value,x,y,pos,callback)
	local majiang = Majiang.new(value,Majiang.SELF_ON_HAND)
	majiang:addTo(self)

	-- local startX,startY
	-- if pos then
	-- 	local p = self.mHandCardsHandlers[seat_id]:convertToNodeSpace(pos)
	-- 	startX,startY = p.x,p.y
	-- 	majiang:scale(1)
	-- 	majiang:scaleTo(0.1, 1.2)
	-- elseif self.mHandLastCards[seat_id] then
	-- 	startX,startY = self.mHandLastCards[seat_id]:getPosition()
	-- 	majiang:scale(0)
	-- 	majiang:scaleTo(0.1, 1.2)
	-- else
	-- 	majiang:scale(1.2)
	-- end

	-- if seat_id == top then
	-- 	majiang:setPosition(startX or 643,startY or 574)
	-- 	majiang:moveTo(0.1, 643,574)
	-- elseif seat_id == left then
	-- 	majiang:setPosition(startX or 334,startY or 382)
	-- 	majiang:moveTo(0.1, 334,382)
	-- elseif seat_id == right then
	-- 	majiang:setPosition(startX or 943,startY or 384)
	-- 	majiang:moveTo(0.1, 943,384)
	-- else
	-- 	majiang:setPosition(startX or 648,startY or 225)
	-- 	majiang:moveTo(0.1, 648,225)
	-- end

	-- local sequence = transition.sequence({
	--     cc.DelayTime:create(0.7),
	--     cc.MoveTo:create(0.15, cc.p(x,y)),
	-- })
	-- majiang:runAction(sequence)

	-- local sequence = transition.sequence({
	--     cc.DelayTime:create(0.7),
	--     cc.ScaleTo:create(0.15, 0.5),
	-- })
	-- majiang:runAction(sequence)
	majiang:setVisible(false)
	majiang:performWithDelay(function()
			majiang:removeSelf()
			callback()
		end, 0)--0.85)
end

function MajiangBoard:addTopDiscardCards(value,pos)
	local index = #self.mDiscardCards[top] 
	local x = 784 - index%lie2*41
	local y = 501 + math.floor(index/lie2)*47

	local majiang = Majiang.new(value,Majiang.TOP_ON_BOARD_SHOW)
	majiang:scale(default_scale2)
	majiang:addTo(self.mDiscardCardsHandlers[top])
	majiang:setVisible(false)
	table.insert(self.mDiscardCards[top],majiang)
	majiang:setLocalZOrder(-y)
	majiang:setPosition(cc.p( x, y))

	self:playAddDiscardCardsAnim(top,value, x, y,pos,handler(self, function()
			if not tolua.isnull(majiang) then
				majiang:setVisible(true)
				if not tolua.isnull(self.mTipsIcon) then
					self.mTipsIcon:setVisible(true)
				end
			end
		end))
	return majiang
end

function MajiangBoard:resetTopDiscardCards(card_values)

	for i,card in ipairs(self.mDiscardCards[top]) do
		card:removeSelf()
	end
	self.mDiscardCards[top] = {}

	for i,value in ipairs(card_values) do
		local majiang = Majiang.new(value,Majiang.TOP_ON_BOARD_SHOW)
		majiang:scale(default_scale2)
		majiang:addTo(self.mDiscardCardsHandlers[top])
		table.insert(self.mDiscardCards[top],majiang)
	end
	self:resetTopDiscardCardsPos()
end

function MajiangBoard:resetTopDiscardCardsPos()
	for i,card in ipairs(self.mDiscardCards[top]) do
		local index = i - 1
		local x = 784 - index%lie2*41
		local y = 501 + math.floor(index/lie2)*47
		card:setLocalZOrder(-y)
		card:setPosition(cc.p(x,y))
	end
end

function MajiangBoard:addLeftDiscardCards(value,pos)

	local index = #self.mDiscardCards[left]
	local x = 447 - math.floor(index/lie)*54
	local y = 486 - index%lie*40
	local majiang = Majiang.new(value,Majiang.LEFT_ON_BOARD_SHOW)
	majiang:scale(default_scale2)
	majiang:addTo(self.mDiscardCardsHandlers[left])
	majiang:setVisible(false)
	table.insert(self.mDiscardCards[left],majiang)
	majiang:setLocalZOrder(-y)
	majiang:setPosition(cc.p( x, y))
	self:playAddDiscardCardsAnim(left,value, x, y,pos,handler(self, function()
			if not tolua.isnull(majiang) then
				majiang:setVisible(true)
				if not tolua.isnull(self.mTipsIcon) then
					self.mTipsIcon:setVisible(true)
				end
			end
		end))
	return majiang
end

function MajiangBoard:resetLeftDiscardCards(card_values)

	for i,card in ipairs(self.mDiscardCards[left]) do
		card:removeSelf()
	end
	self.mDiscardCards[left] = {}

	for i,value in ipairs(card_values) do
		local majiang = Majiang.new(value,Majiang.LEFT_ON_BOARD_SHOW)
		majiang:scale(default_scale2)
		majiang:addTo(self.mDiscardCardsHandlers[left])
		table.insert(self.mDiscardCards[left],majiang)
	end
	self:resetLeftDiscardCardsPos()
end

function MajiangBoard:resetLeftDiscardCardsPos()
	for i,card in ipairs(self.mDiscardCards[left]) do
		local index = i - 1
		local x = 447 - math.floor(index/lie)*54
		local y = 486 - index%lie*40
		card:setLocalZOrder(-y)
		card:setPosition(cc.p(x,y))
	end
end

function MajiangBoard:addBottomDiscardCards(value,pos)

	local index = #self.mDiscardCards[bottom]
	local x = 496 + index%lie2*41
	local y = 265 - math.floor(index/lie2)*47

	local majiang = Majiang.new(value,Majiang.BOTTOM_ON_BOARD_SHOW)
	majiang:scale(default_scale2)
	majiang:addTo(self.mDiscardCardsHandlers[bottom])
	majiang:setVisible(false)
	table.insert(self.mDiscardCards[bottom],majiang)
	majiang:setLocalZOrder(-y)

	majiang:setPosition(cc.p( x, y))
	self:playAddDiscardCardsAnim(bottom,value, x, y,pos,handler(self, function()
			if not tolua.isnull(majiang) then
				majiang:setVisible(true)
				if not tolua.isnull(self.mTipsIcon) then
					self.mTipsIcon:setVisible(true)
				end
			end
		end))
	return majiang
end

function MajiangBoard:resetBottomDiscardCards(card_values)

	for i,card in ipairs(self.mDiscardCards[bottom]) do
		card:removeSelf()
	end
	self.mDiscardCards[bottom] = {}

	for i,value in ipairs(card_values) do
		local majiang = Majiang.new(value,Majiang.BOTTOM_ON_BOARD_SHOW)
		majiang:scale(default_scale2)
		majiang:addTo(self.mDiscardCardsHandlers[bottom])
		table.insert(self.mDiscardCards[bottom],majiang)
	end
	self:resetBottomDiscardCardsPos()
end

function MajiangBoard:resetBottomDiscardCardsPos()
	for i,card in ipairs(self.mDiscardCards[bottom]) do
		local index = i - 1
		local x = 496 + index%lie2*41
		local y = 265 - math.floor(index/lie2)*47
		card:setLocalZOrder(-y)
		card:setPosition(cc.p(x,y))
	end
end

function MajiangBoard:addRightDiscardCards(value,pos)

	local index = #self.mDiscardCards[right]
	local x = 850 + math.floor(index/lie)*54
	local y = 272 + index%lie*40

	local majiang = Majiang.new(value,Majiang.RIGHT_ON_BOARD_SHOW)
	majiang:scale(default_scale2)
	majiang:addTo(self.mDiscardCardsHandlers[right])
	majiang:setVisible(false)
	table.insert(self.mDiscardCards[right],majiang)
	majiang:setLocalZOrder(-y)
	majiang:setPosition(cc.p( x, y))

	self:playAddDiscardCardsAnim(right,value, x, y,pos,handler(self, function()
			if not tolua.isnull(majiang) then
				majiang:setVisible(true)
				if not tolua.isnull(self.mTipsIcon) then
					self.mTipsIcon:setVisible(true)
				end
			end
		end))
	return majiang
end

function MajiangBoard:resetRightDiscardCards(card_values)

	for i,card in ipairs(self.mDiscardCards[right]) do
		card:removeSelf()
	end
	self.mDiscardCards[right] = {}

	for i,value in ipairs(card_values) do
		local majiang = Majiang.new(value,Majiang.RIGHT_ON_BOARD_SHOW)
		majiang:scale(default_scale2)
		majiang:addTo(self.mDiscardCardsHandlers[right])
		table.insert(self.mDiscardCards[right],majiang)
	end
	self:resetRightDiscardCardsPos()
end

function MajiangBoard:resetRightDiscardCardsPos()
	for i,card in ipairs(self.mDiscardCards[right]) do
		local index = i - 1
		local x = 850 + math.floor(index/lie)*54
		local y = 272 + index%lie*40
		card:setLocalZOrder(-y)
		card:setPosition(cc.p(x,y))
	end
end

function MajiangBoard:createPeng(seat_id,value)
	local mMajiangGroup = MajiangGroup.new(seat_id)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self.mHandCardsHandlers[seat_id])
	mMajiangGroup:setGroup(MajiangGroup.PENG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function MajiangBoard:createGang(seat_id,value)
	local mMajiangGroup = MajiangGroup.new(seat_id)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self.mHandCardsHandlers[seat_id])
	mMajiangGroup:setGroup(MajiangGroup.GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function MajiangBoard:createAnGang(seat_id,value)
	local mMajiangGroup = MajiangGroup.new(seat_id)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self.mHandCardsHandlers[seat_id])
	mMajiangGroup:setGroup(MajiangGroup.AN_GANG)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function MajiangBoard:createBian(seat_id,value)
	local num = bit.band(value,0x0f)
	local mMajiangGroup = MajiangGroup.new(seat_id)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self.mHandCardsHandlers[seat_id])
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

function MajiangBoard:createZhuan(seat_id,value)
	local mMajiangGroup = MajiangGroup.new(seat_id)
	mMajiangGroup:scale(default_scale2)
	mMajiangGroup:addTo(self.mHandCardsHandlers[seat_id])
	mMajiangGroup:setGroup(MajiangGroup.ZHUAN)
	mMajiangGroup:add(value-1)
	mMajiangGroup:add(value)
	mMajiangGroup:add(value+1)
	mMajiangGroup:resetPosition()
	return mMajiangGroup
end

function MajiangBoard:delGang(seat_id,value)
	for i,group in ipairs(self.mShowCards[seat_id]) do
		if group:getGroupType() == MajiangGroup.GANG and group:getValues()[1] == value then
			group:setGroup(MajiangGroup.PENG)
			group:del(value)
			group:resetPosition()
			break
		end
	end
end

function MajiangBoard:actionPeng(seat_id,value)
	print("MajiangBoard:actionPeng",value)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	table.insert(self.mShowCards[seat_id],1,self:createPeng(seat_id,value))
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:actionGang(seat_id,value)
	print("MajiangBoard:actionGang",value)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	table.insert(self.mShowCards[seat_id],1,self:createGang(seat_id,value))
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:actionBuGang(seat_id,value)
	print("MajiangBoard:actionBuGang",value)
	self:delHandCard(seat_id)
	for i,group in ipairs(self.mShowCards[seat_id]) do
		if group:getGroupType() == MajiangGroup.PENG and group:getValues()[1] == value then
			group:setGroup(MajiangGroup.GANG)
			group:add(value)
			group:resetPosition()
			break
		end
	end
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:actionAnGang(seat_id,value)
	print("MajiangBoard:actionAnGang",value)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	table.insert(self.mShowCards[seat_id],1,self:createAnGang(seat_id,value))
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:actionBian(seat_id,value)
	print("MajiangBoard:actionBian",value)
	local num = bit.band(value,0x0f)
	if num == 7 then
		self:delHandCard(seat_id)
		self:delHandCard(seat_id)
		self:delHandCard(seat_id)
	elseif num == 3 then
		self:delHandCard(seat_id)
		self:delHandCard(seat_id)
		self:delHandCard(seat_id)
	end
	table.insert(self.mShowCards[seat_id],1,self:createBian(seat_id,value))
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:actionZhuan(seat_id,value)
	print("MajiangBoard:actionZhuan",value)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	self:delHandCard(seat_id)
	table.insert(self.mShowCards[seat_id],1,self:createZhuan(seat_id,value))
    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:setShowCards(seat_id,peng_cards,gang_cards,zhuan_cards,bian_cards)
	print("MajiangBoard:setShowCards",seat_id)
	self:releaseShowCards(seat_id)

	-- peng_cards = {
	-- 	1,
	-- }

	for i,card in ipairs(peng_cards) do
		table.insert(self.mShowCards[seat_id],1,self:createPeng(seat_id,card))
	end

	-- gang_cards = {
	-- 	{status = 0, id = 1},
	-- 	{status = 1, id = 1},
	-- }

    for i,card in ipairs(gang_cards) do 
    	if card.status == 0 then
			table.insert(self.mShowCards[seat_id],1,self:createGang(seat_id,card.id))
		elseif card.status == 1 then
			table.insert(self.mShowCards[seat_id],1,self:createAnGang(seat_id,card.id))
		end
    end

	-- zhuan_cards = {
	-- 	1,2,3
	-- }
    for i=2,#zhuan_cards,3 do 
		table.insert(self.mShowCards[seat_id],1,self:createZhuan(seat_id,zhuan_cards[i]))
    end
 --    bian_cards = {
 --    	1,2,3,7,8,9
	-- }
    for i=1,#bian_cards,3 do 
		local num = bit.band(bian_cards[i],0x0f)
		if num == 7 then
			table.insert(self.mShowCards[seat_id],1,self:createBian(seat_id,bian_cards[i]))
		else
			table.insert(self.mShowCards[seat_id],1,self:createBian(seat_id,bian_cards[i+2]))
		end
    end

    self:resetShowCardsPos(seat_id)
end

function MajiangBoard:resetShowCardsPos(seat_id)
	local startPosX = {
		self.mHandCardsPos[top] - 8,
		122,
		self.mHandCardsPos[bottom],
		1120, 
	}
	local startPosY = {
		608,
		self.mHandCardsPos[left] - 10,
		80,
		self.mHandCardsPos[right] + 14,
	}
	local offsetPos = {
		{1,0},
		{0,1},
		{-1,0},
		{0,-1},
	}

	for i,card in ipairs(self.mShowCards[seat_id]) do
		if seat_id == 1 or seat_id == 2 then
			card:setPosition(startPosX[seat_id],startPosY[seat_id])
			card:setLocalZOrder(-startPosY[seat_id])
		end
		local mGroupType = card:getGroupType()
		local offsetX = 0
		local offsetY = 0
		if mGroupType == MajiangGroup.PENG then
			offsetX = 250 * default_scale2
			offsetY = 230 * default_scale2
		elseif mGroupType == MajiangGroup.GANG then
			offsetX = 250 * default_scale2
			offsetY = 230 * default_scale2
		elseif mGroupType == MajiangGroup.AN_GANG then
			offsetX = 250 * default_scale2
			offsetY = 230 * default_scale2
		elseif mGroupType == MajiangGroup.BIAN then
			offsetX = 167 * default_scale2
			offsetY = 150 * default_scale2
		elseif mGroupType == MajiangGroup.ZHUAN then
			offsetX = 167 * default_scale2
			offsetY = 150 * default_scale2
		end
		startPosX[seat_id] = startPosX[seat_id] + offsetX * offsetPos[seat_id][1]
		startPosY[seat_id] = startPosY[seat_id] + offsetY * offsetPos[seat_id][2]

		if seat_id == 3 or seat_id == 4 then
			card:setPosition(startPosX[seat_id],startPosY[seat_id])
			card:setLocalZOrder(-startPosY[seat_id])
		end
    end
end

function MajiangBoard:releaseShowCards(seat_id)
	for i,card in ipairs(self.mShowCards[seat_id]) do
		card:removeSelf()
	end
	self.mShowCards[seat_id] = {}
end

function MajiangBoard:getShowCardData(seat_id)
	local peng_cards = {}
	local gang_cards = {}
	local zhuan_cards = {}
	local bian_cards = {}
	for i,card in ipairs(self.mShowCards[seat_id]) do
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

function MajiangBoard:getDiscardCardsData(seat_id)
	local ret = {}
	for i,card in ipairs(self.mDiscardCards[seat_id]) do
		table.insert(ret,card:getValue())
	end
	return ret
end

return MajiangBoard