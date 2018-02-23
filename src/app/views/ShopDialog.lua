--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local ShopDialog = class("ShopDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "ShopDialog"
local net = require("framework.cc.net.init")
local contentTxt = ""
function ShopDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("shop_dialog.json")
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


	self.mGoodDatas = {}
	self:selectPayType(1)

	-- local test = {}
	-- for i=1,20 do
	-- 	test[i] = {}
	-- 	test[i].num = i
	-- 	test[i].price = i
	-- 	test[i].cy = "$"
	-- end
	-- self:resetContentView(test)
end

function ShopDialog:selectPayType(payType)
	self:resetContentView(self.mGoodDatas)
end

function ShopDialog:resetContentView(datas)
	local node = self.content_scroll:getScrollNode()
	node:removeAllChildren()
	local startX = 0
	local startY = 486
	
	for i,data in ipairs(datas) do
		local view = self:getItemView(data)
		view:addTo(node)
		view:setPosition(cc.p(startX,startY))
		startX = startX + 390

		if i % 2 == 0 then
			startY = startY - 230
			startX = 0
		end

		local touch_event = view:getChildByName("touch_event")
		touch_event:setTouchSwallowEnabled(false)
		-- touch_event:onButtonClicked(function()
		-- 		tt.play.play_sound("click")
		--     	print("shop pay")
		-- 		local params = {}
		-- 		params.meal_id = data.meal_id
		-- 		params.type = data.type
		-- 		dump(params)
		-- 		tt.ghttp.request(tt.cmd.order,params)
		-- 	end)

		view:setTouchEnabled(true)
		view:setTouchSwallowEnabled(false)
		local downX,downY =0,0
		local down = false
		view:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		    local x,y = event.x,event.y
		    if event.name == "began" then
		    	downX = x
	        	downY = y
	        	if not view:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
	        	down = true
	        	return true
		    elseif event.name ~= "began" and down then
		    	if math.abs(downX-x) > 10 or math.abs(downY-y) > 10 then
		    		down = false
		    	end
		    	if event.name == "ended" and down then
			    	tt.play.play_sound("click")
			    	print("shop pay")
					local params = {}
					params.meal_id = data.meal_id
					params.type = data.type
					dump(params)
					tt.ghttp.request(tt.cmd.order,params)
					-- self.control_:showWebPayDialog("http://kcttest.kuaicaitong.com/h5_pay/redirect.html?redirect=https://payh5.bbnpay.com/browserh5/paymobile.php?data=%7B%22app%22%3A%222722017091185845%22%2C%22backurl%22%3A%22http%3A%2F%2Fkcttest.kuaicaitong.com%2Fwxpay%2Fredirect.html%3Fredirect%3Dtianyoumajiang%3A%2F%2Fwebpaycallback%22%2C%22transid%22%3A%220008581505377606635468511973%22%7D%0A&sign=d51dd44276446fcb1a13af6b3df68b16&signtype=MD5")
				end
			end
		end)
	end
end

function ShopDialog:getItemView(data)
	local node = display.newSprite("btn/btn_touming.png")
	local bg = cc.ui.UIPushButton.new({
			normal='bg/gem_bg_up.png',
			pressed='bg/gem_bg_down.png',
			disabled='bg/gem_bg_down.png',
		})--display.newSprite("bg/gem_bg.png")

	local icon = display.newSprite("dec/gem.png")
	local x = display.newSprite("dec/add.png")
	local num = tt.getBitmapNum("number/yellow_%d.png",tonumber(data.zuan_num))
	-- local price = display.newTTFLabel({
	-- 		    text = string.format("%s%d","￥",data.pay),
	-- 		    size = 37,
	-- 		    color = cc.c3b(255, 255, 255), -- 使用纯红色
	-- 		    align = cc.TEXT_ALIGNMENT_LEFT,
	-- 		    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	-- 		    -- dimensions = cc.size(400, 200)
	-- 		})
	local yuan = display.newSprite("number/gem_yuan.png")
	local price = tt.getBitmapStrAscii("number/gem_%d.png",string.format("%d",data.pay))

	dump(size)
	node:setContentSize(372,208)
	node:setAnchorPoint(cc.p(0,1))


	local size = yuan:getContentSize()
	local size2 = price:getContentSize()
	yuan:addTo(price)
	yuan:setPosition(cc.p(-size.width/2,size.height/2))

	local btn = display.newSprite("btn/bt_buy_gem.png")
	bg:addTo(node)
	bg:setPosition(cc.p(105,84))
	bg:setName("touch_event")

	local move_node = display.newNode()
	move_node:addTo(bg)
	move_node:setPosition(cc.p(-180,-100))

	btn:addTo(move_node)
	btn:setPosition(cc.p(268,54))
	price:addTo(move_node)
	price:setPosition(cc.p( 268 - (size.width + size2.width)/2 + size.width,36))

	icon:addTo(move_node)
	icon:setPosition(cc.p(100,114))
	x:addTo(move_node)
	x:setPosition(cc.p(150,129))
	x:scale(1.2)
	num:addTo(move_node)
	num:setPosition(cc.p(165,111))
	num:scale(1.2)

	local label = tonumber(data.label)
	local chuxiao
	if label == 1 then
		chuxiao = display.newSprite("dec/zuihuobao.png")
		chuxiao:addTo(bg)
		chuxiao:setPosition(cc.p(44-180,175-100))
	elseif label == 2 then
		chuxiao = display.newSprite("dec/zuihuasuan.png")
		chuxiao:addTo(bg)
		chuxiao:setPosition(cc.p(44-180,175-100))
	end

	bg:onButtonPressed(function()
			move_node:setPosition(cc.p(-180,-100-5))
		end)

	bg:onButtonRelease(function()
			move_node:setPosition(cc.p(-180,-100))
		end)


	return node
end

function ShopDialog:onLoadData(params)
	dump(params)
	if not params.data or params.ret ~= 0 then return end
	self.mGoodDatas = {}

	for i,data in ipairs(params.data) do
		table.insert(self.mGoodDatas,data)
	end
	self:resetContentView(self.mGoodDatas)
end

function ShopDialog:show()
	BLDialog.show(self)
	self.content_scroll:scrollTo(115, 20)

	local params = {}
	tt.ghttp.request(tt.cmd.get_shop,params)
end

function ShopDialog:dismiss()
	BLDialog.dismiss(self)
end

return ShopDialog
