local HuHelper = require("app.mjlib.helper")
local band =  bit.band   --bit and 位与运算
local bor = bit.bor
-- mask
local CARD_MASK_SUIT		= 0xF0   --类型 用于求card的suit值
local CARD_MASK_RANK		= 0x0F   --数值 用于求card的rank值


local SUIT_WAN 		= 0x00   --万
local SUIT_TONG    	= 0x10   --筒
local SUIT_TIAO     = 0x20   --条
local SUIT_FENG     = 0x30   --风
local SUIT_ZI     	= 0x40   --字

local Majiang = class("Majiang",function( ... )
	return display.newNode()
end)

Majiang.SELF_ON_HAND = 1

Majiang.TOP_ON_BOARD_SHOW = 2
Majiang.LEFT_ON_BOARD_SHOW = 3
Majiang.BOTTOM_ON_BOARD_SHOW = 4
Majiang.RIGHT_ON_BOARD_SHOW = 5

Majiang.TOP_ON_BOARD_DISMISS = 6
Majiang.LEFT_ON_BOARD_DISMISS = 7
Majiang.BOTTOM_ON_BOARD_DISMISS = 8
Majiang.RIGHT_ON_BOARD_DISMISS = 9

Majiang.TOP_ON_HAND = 10
Majiang.LEFT_ON_HAND = 11
Majiang.BOTTOM_ON_HAND = 12
Majiang.RIGHT_ON_HAND = 13

Majiang.TOP_ON_HAND_SHOW = 14
Majiang.LEFT_ON_HAND_SHOW = 15
Majiang.BOTTOM_ON_HAND_SHOW = 16
Majiang.RIGHT_ON_HAND_SHOW = 17

Majiang.TOP_ON_HAND_DISMISS = 18
Majiang.LEFT_ON_HAND_DISMISS = 19
Majiang.BOTTOM_ON_HAND_DISMISS = 20
Majiang.RIGHT_ON_HAND_DISMISS = 21


function Majiang.SUIT( card )
	return band(card,CARD_MASK_SUIT)
end

function Majiang.RANK( card )
	return band(card, CARD_MASK_RANK)
end

function Majiang:ctor(card_value,card_type)
	print( string.format("0x%x",card_value))
	self.card_value_ = card_value 
	if card_value < 0 or card_value >= 255 then
		self.bg_img_ = display.newSprite("majiang/majiang_1.png")
		self:addChild(self.bg_img_) 
		return self
	end

	if card_type < 1 or card_type > 21 then
		self.bg_img_ = display.newSprite("majiang/majiang_1.png")
		self:addChild(self.bg_img_) 
		return self
	end

	self.bg_img_ = display.newSprite("majiang/majiang_1.png")
	self.bg_img_:addTo(self)

	self.suit_ = Majiang.SUIT(card_value)   --类型
	self.rank_ = Majiang.RANK(card_value)   --牌面值

	local fileName = string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_))

	--print(string.format("rank_num = %s,suit_big = %s",rank_num,suit_big)) 

	--生成图片
	self.rank_img_ = display.newSprite(fileName) 
	self.rank_img_:addTo(self.bg_img_)

	--图片之间的位置关系
	local bg_size = self.bg_img_:getContentSize()
	self:setContentSize(bg_size.width,bg_size.height) 
	self.bg_img_:setAnchorPoint(cc.p(0.5,0.5))
	self.bg_img_:setPosition(cc.p(bg_size.width/2,bg_size.height/2))
	self.rank_img_:setAnchorPoint(cc.p(0.5,0.5))
	self:setAnchorPoint(cc.p(0.5, 0.5))

	self:setMajiangType(card_type)
end

function Majiang:setMajiangType(card_type)
	print("Majiang:setMajiangType",card_type)
	self.card_type = card_type
	self.bg_img_:flipX(false)
	if card_type == Majiang.SELF_ON_HAND then
		self.bg_img_:setTexture("majiang/majiang_7.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(0)
		self.rank_img_:setScale(0.95,0.95)
		self.rank_img_:setPosition(cc.p(bg_size.width/2-1,bg_size.height/2-8))
		self.rank_img_:setVisible(true)
		self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_)))
	elseif card_type == Majiang.TOP_ON_BOARD_SHOW or card_type == Majiang.TOP_ON_HAND_SHOW then
		self.bg_img_:setTexture("majiang/majiang_5.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(0)
		self.rank_img_:setPosition(cc.p(bg_size.width/2-1,bg_size.height/2+11))
		self.rank_img_:setVisible(true)
		if card_type == Majiang.TOP_ON_HAND_SHOW then
			self.rank_img_:setScale(0.95,0.95)
			self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_)))
		else
			self.rank_img_:setScale(1.9,1.9)
			self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x_1.png",bor(self.suit_,self.rank_)))
		end
	elseif card_type == Majiang.LEFT_ON_BOARD_SHOW then
		self.bg_img_:setTexture("majiang/majiang_11.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(90)
		self.rank_img_:setScale(2,2)
		self.rank_img_:setPosition(cc.p(bg_size.width/2,bg_size.height/2+10))
		self.rank_img_:setVisible(true)
		self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x_1.png",bor(self.suit_,self.rank_)))
	elseif card_type == Majiang.LEFT_ON_HAND_SHOW then
		self.bg_img_:setTexture("majiang/majiang_6.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(90)
		self.rank_img_:setScale(0.85,0.85)
		self.rank_img_:setPosition(cc.p(bg_size.width/2-9,bg_size.height/2+2))
		self.rank_img_:setVisible(true)
		self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_)))
	elseif card_type == Majiang.BOTTOM_ON_BOARD_SHOW or card_type == Majiang.BOTTOM_ON_HAND_SHOW then
		self.bg_img_:setTexture("majiang/majiang_5.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(0)
		self.rank_img_:setPosition(cc.p(bg_size.width/2-1,bg_size.height/2+11))
		self.rank_img_:setVisible(true)
		if card_type == Majiang.BOTTOM_ON_HAND_SHOW then
			self.rank_img_:setScale(0.95,0.95)
			self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_)))
		else
			self.rank_img_:setScale(1.9,1.9)
			self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x_1.png",bor(self.suit_,self.rank_)))
		end
	elseif card_type == Majiang.RIGHT_ON_BOARD_SHOW then

		self.bg_img_:setTexture("majiang/majiang_11.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		self.bg_img_:flipX(true)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(-90)
		self.rank_img_:setScale(2,2)
		self.rank_img_:setPosition(cc.p(bg_size.width/2,bg_size.height/2+10))
		self.rank_img_:setVisible(true)
		self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x_1.png",bor(self.suit_,self.rank_)))
	elseif card_type == Majiang.RIGHT_ON_HAND_SHOW then

		self.bg_img_:setTexture("majiang/majiang_9.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		self.rank_img_:rotation(-90)
		self.rank_img_:setScale(0.85,0.85)
		self.rank_img_:setPosition(cc.p(bg_size.width/2+8,bg_size.height/2+2))
		self.rank_img_:setVisible(true)
		self.rank_img_:setTexture(string.format("majiang/my_hand_1_0x%02x.png",bor(self.suit_,self.rank_)))

	elseif card_type == Majiang.TOP_ON_BOARD_DISMISS or card_type == Majiang.TOP_ON_HAND_DISMISS then
		self.bg_img_:setTexture("majiang/majiang_1.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(true)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.LEFT_ON_BOARD_DISMISS or card_type == Majiang.LEFT_ON_HAND_DISMISS then
		self.bg_img_:setTexture("majiang/majiang_8.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.BOTTOM_ON_BOARD_DISMISS  or card_type == Majiang.BOTTOM_ON_HAND_DISMISS then
		self.bg_img_:setTexture("majiang/majiang_1.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.RIGHT_ON_BOARD_DISMISS or card_type == Majiang.RIGHT_ON_HAND_DISMISS then
		self.bg_img_:setTexture("majiang/majiang_10.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(true)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.TOP_ON_HAND then
		self.bg_img_:setTexture("majiang/majiang_4.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(true)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.LEFT_ON_HAND then
		self.bg_img_:setTexture("majiang/majiang_3.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(true)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.BOTTOM_ON_HAND then
		self.bg_img_:setTexture("majiang/majiang_1.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	elseif card_type == Majiang.RIGHT_ON_HAND then
		self.bg_img_:setTexture("majiang/majiang_2.png")
		self.bg_img_:rotation(0)
		self.bg_img_:setScale(1,1)
		-- self.bg_img_:flipX(false)
		local bg_size = self.bg_img_:getContentSize()

		-- self.rank_img_:rotation(0)
		-- self.rank_img_:setScale(1,1)
		-- self.rank_img_:setPosition(cc.p(bg_size.width/2+2,bg_size.height/2-3))
		self.rank_img_:setVisible(false)
	end

	local bg_size = self.bg_img_:getContentSize()
	local scaleX,scaleY = self.bg_img_:getScaleX(),self.bg_img_:getScaleY()
	self:setContentSize(bg_size.width*scaleX,bg_size.height*scaleY) 
end

function Majiang:playReverseAnim(delay)
	if self.card_type == Majiang.SELF_ON_HAND then
		self:setMajiangType(Majiang.BOTTOM_ON_BOARD_DISMISS)
		self:performWithDelay(function()
				self:setMajiangType(Majiang.SELF_ON_HAND)
			end, delay or 0.2)
	end
end

function Majiang:getValue()
	return self.card_value_
end 

function Majiang:setTingValue(tab)
	self.mTingTab = tab
	if tolua.isnull(self.mTingIcon) then
		self.mTingIcon = display.newSprite("dec/ting.png")
		self.mTingIcon:addTo(self.bg_img_)
		self.mTingIcon:setPosition(cc.p(16,90))
	end
end

function Majiang:clearTingValue()
	self.mTingTab = nil
	if not tolua.isnull(self.mTingIcon) then
		self.mTingIcon:removeSelf()
		self.mTingIcon = nil
	end
end

function Majiang:getTingValue()
	return self.mTingTab
end

function Majiang.printT(keys)
	local card_values = {}
	for key,num in pairs(keys) do
		for i=1,num do
			table.insert(card_values,key)
		end
	end
	table.sort(card_values)
	return table.concat(card_values,",")
end

function Majiang.pingHu(keys)
	return HuHelper:checkHu(keys)
	-- local map = {}
	-- for i=0,0x4f do
	-- 	if keys[i] and keys[i] >= 2 then
	-- 		-- print(json.encode(keys))
	-- 		keys[i] = keys[i] - 2
	-- 		-- print(json.encode(keys))
	-- 		if Majiang.hu(keys,map) then
	-- 			return true
	-- 		else
	-- 			map[Majiang.printT(keys)] = false
	-- 		end
	-- 		keys[i] = keys[i] + 2
	-- 	end
	-- end
end

function Majiang.hu(keys,map)
	local tab = clone(keys)
	local map = map or {}
	if map[Majiang.printT(tab)] == false then return false end
	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if tab[index] then
				if tab[index] == 1 then
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 1
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
					else
						return false
					end
				elseif tab[index] == 2 then 
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 1
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
						if Majiang.hu(tab) then 
							return true 
						else
							map[Majiang.printT(tab)] = false
						end
						tab[index] = tab[index] + 1
						tab[index+1] = tab[index+1] + 1
						tab[index+2] = tab[index+2] + 1
					else
						return false
					end
				elseif tab[index] == 3 then
					tab[index] = tab[index] - 3
				elseif tab[index] == 4 then
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 4
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
					else
						return false
					end
				end
			end
		end
	end

	for i=0x31,0x34,0x01 do
		local index = i
		if tab[index] then
			if tab[index] == 1 then
				return false
			elseif tab[index] == 2 then 
				return false
			elseif tab[index] == 3 then
				tab[index] = tab[index] - 3
			elseif tab[index] == 4 then
				return false
			end
		end
	end

	for i=0x41,0x43,0x01 do
		local index = i
		if tab[index] then
			if tab[index] == 1 then
				return false
			elseif tab[index] == 2 then 
				return false
			elseif tab[index] == 3 then
				tab[index] = tab[index] - 3
			elseif tab[index] == 4 then
				return false
			end
		end
	end
	return true
end

function Majiang.qixiaodui(keys)
	local tab = clone(keys)
	local count = 0
	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if tab[index] then
				if tab[index] == 1 then
					return false
				elseif tab[index] == 2 then 
					count = count + 1
				elseif tab[index] == 3 then
					return false
				elseif tab[index] == 4 then
					count = count + 2
				end
			end
		end
	end
	for i=0x31,0x34,0x01 do
		local index = i
		if tab[index] then
			if tab[index] == 1 then
				return false
			elseif tab[index] == 2 then 
				count = count + 1
			elseif tab[index] == 3 then
				return false
			elseif tab[index] == 4 then
				count = count + 2
			end
		end
	end
	for i=0x41,0x43,0x01 do
		local index = i
		if tab[index] then
			if tab[index] == 1 then
				return false
			elseif tab[index] == 2 then 
				count = count + 1
			elseif tab[index] == 3 then
				return false
			elseif tab[index] == 4 then
				count = count + 2
			end
		end
	end
	if count == 7 then
		return true
	end
	return false
end

-- function Majiang.yitiaolong(keys)
-- 	local tab = clone(keys)
-- 	for j=0x00,0x20,0x10 do
-- 		local count = 0
-- 		for i=0x01,0x09,0x01 do
-- 			local index = bit.bor(i,j)
-- 			if tab[index] and tab[index] > 0 then
-- 				count = count + 1
-- 			end
-- 		end
-- 		if count == 9 then return true end
-- 	end
-- 	return false
-- end

return Majiang