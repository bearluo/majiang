local CircleClip = require("app.ui.CircleClip")

local RoomMsgView = class("RoomMsgView",function()
    return display.newNode()
end)

function RoomMsgView:ctor(ctrl)
	self.mCtrl = ctrl
	local node, width, height = cc.uiloader:load("room_msg_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	node:setTouchEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
			self:dismiss()
			return true
    	end)
    
    cc.uiloader:seekNodeByName(node,"content_bg"):setTouchEnabled(true):addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
			return true
    	end)

    self.mShortcutMsgBtn = cc.uiloader:seekNodeByName(node,"shortcut_msg_btn")
    	:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:select(1)
		end)

    self.mEmoticonBtn = cc.uiloader:seekNodeByName(node,"emoticon_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:select(2)
		end)

	self.mMsgBtn = cc.uiloader:seekNodeByName(node,"msg_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			if self.mEdit then
				local str = string.rtrim(self.mEdit:getText())
				if string.trim(str) ~= "" then
					print("sendMsg",str)
					self:dismiss()
    				self.mEdit:setText("")
					self.mCtrl:sendMsg(str)
				end
			end
		end)

	self.mMsgListview = cc.uiloader:seekNodeByName(node,"msg_listview")
	self.mEmoticonListview = cc.uiloader:seekNodeByName(node,"emoticon_listview")
	self.mEditBg = cc.uiloader:seekNodeByName(node,"edit_bg")
	self.mEditHandler = cc.uiloader:seekNodeByName(node,"edit_handler")

	self:select(1)
	self:initMsgListview()
	self:initEmoticonListview()
	self:initEditView()
	self:setVisible(false)
end

function RoomMsgView:show()
	self:setVisible(true)
end

function RoomMsgView:dismiss()
	self:setVisible(false)
end

function RoomMsgView:select(index)
	if index == 1 then
		self.mShortcutMsgBtn:setButtonEnabled(false)
		self.mEmoticonBtn:setButtonEnabled(true)
		self.mMsgListview:setVisible(true)
		self.mEmoticonListview:setVisible(false)
		self.mEditBg:setVisible(true)
	else
		self.mShortcutMsgBtn:setButtonEnabled(true)
		self.mEmoticonBtn:setButtonEnabled(false)
		self.mMsgListview:setVisible(false)
		self.mEmoticonListview:setVisible(true)
		self.mEditBg:setVisible(false)
	end
end

function RoomMsgView:initMsgListview()
	self.mMsgListview:removeAllItems()
	local datas = {
		"大家好！祝大家都有好手气。",
		"出牌啊，这牌你都快看出花了。",
		"诶哟，好运来了挡不住！",
		"就是不上牌，没辙！",
		"你是哪的人啊，咱们加个好友吧。",
		"今天幸运女神这么眷顾你呀！",
		"又断线了，今天这网怎么了？",
		"都别走啊，一会再打两圈。",
		"刚才在接电话，久等了各位。",
	}
	for i,data in ipairs(datas) do
		local size = cc.size(426,50)
		local content = display.newNode()
		content:setContentSize(size)
		local touch = cc.ui.UIPushButton.new('btn/btn_touming.png')
		touch:setTouchEnabled(true)
		touch:setTouchSwallowEnabled(false)
		local downX,downY =0,0
		local down = false
		touch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		    local x,y = event.x,event.y
		    if event.name == "began" then
		    	downX = x
	        	downY = y
	        	if not touch:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
	        	down = true
	        	return true
		    elseif event.name ~= "began" and down then
		    	if math.abs(downX-x) > 10 or math.abs(downY-y) > 10 then
		    		down = false
		    	end
		    	if event.name == "ended" and down then
					tt.play.play_sound("click")
					print("sendShortcutMsg",data)
					self:dismiss()
					self.mCtrl:sendShortcutMsg(data)
				end
			end
		end)
		touch:setButtonSize(size.width,size.height)
		touch:setPosition(cc.p(size.width/2,size.height/2))
		touch:addTo(content)
		local text = display.newTTFLabel({
			    text = data,
			    size = 25,
			    color = cc.c3b(0xd6, 0xd6, 0xd6),
			})
		text:addTo(content)
		text:setAnchorPoint(cc.p(0,0.5))
		text:setPosition(cc.p(30,size.height/2))
		local dec = display.newSprite("dec/biaoqing_line.png")
		dec:addTo(content)
		dec:setPosition(cc.p(size.width/2,0))

		local item = self.mMsgListview:newItem(content)
		local size = content:getContentSize()
		if i == 1 then
			item:setMargin({left = 0, right = 0, top = 20, bottom = 0})
		else
			item:setMargin({left = 0, right = 0, top = 0, bottom = 0})
		end
		item:setItemSize(size.width,size.height)
		self.mMsgListview:addItem(item) 
	end
	self.mMsgListview:reload()
end

function RoomMsgView:initEmoticonListview()
	self.mEmoticonListview:removeAllItems()
	for i=1,8 do
		local size = cc.size(426,90)
		local content = display.newNode()
		content:setContentSize(size)
		for j=1,4 do
			local id = (i-1)*4 + j
			local touch = cc.ui.UIPushButton.new('btn/btn_touming.png')
				:onButtonClicked(function()
				end)
			touch:setTouchEnabled(true)
			touch:setTouchSwallowEnabled(false)
			local downX,downY =0,0
			local down = false
			touch:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			    local x,y = event.x,event.y
			    if event.name == "began" then
			    	downX = x
		        	downY = y
		        	if not touch:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
		        	down = true
		        	return true
			    elseif event.name ~= "began" and down then
			    	if math.abs(downX-x) > 10 or math.abs(downY-y) > 10 then
			    		down = false
			    	end
			    	if event.name == "ended" and down then
				    	tt.play.play_sound("click")
						print("sendEmoticon",id)
						self:dismiss()
						self.mCtrl:sendEmoticonMsg(id)
					end
				end
			end)
			touch:setButtonSize(size.width/4,size.height)
			touch:addTo(content)
			touch:setPosition(size.width/8+size.width/4*(j-1),size.height/2)
			local icon = display.newSprite(string.format("emoticon/%d/icon.png",id))
			icon:addTo(content)
			icon:setPosition(size.width/8+size.width/4*(j-1),size.height/2)
			-- icon:scale(0.7)
		end
		local item = self.mMsgListview:newItem(content)
		local size = content:getContentSize()
		if i == 1 then
			item:setMargin({left = 0, right = 0, top = 20, bottom = 5})
		elseif i == 8 then
			item:setMargin({left = 0, right = 0, top = 0, bottom = 20})
		else
			item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
		end
		item:setItemSize(size.width,size.height)
		self.mEmoticonListview:addItem(item) 
	end
	self.mEmoticonListview:reload()
end

function RoomMsgView:initEditView()

	local size = self.mEditHandler:getContentSize()
    self.mEdit = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = cc.size(size.width,40),
        x = size.width/2,
        y = size.height/2,
        listener = handler(self, self.onNickEdit_)
    })
    self.mEdit:setPlaceHolder("发送消息...")
    self.mEdit:setMaxLength(12)
    self.mEdit:setFontColor(cc.c3b(0xef, 0xef, 0x9d))
    self.mEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.mEdit:setInputMode(cc.EDITBOX_INPUT_MODE_ANY);  
    self.mEdit:addTo(self.mEditHandler)
    self.mEdit:setText("")
end

-- function RoomMsgView:setText(str)
-- 	print("RoomMsgView.setText",str)
-- 	if str == "" or str == nil then
-- 		self.mEditTxtHandler:setString("发送消息...")
-- 		self.mEditTxtHandler:setTextColor(cc.c3b(0x77,0x77,0x77))
-- 	else
-- 		self.mEditTxtHandler:setString(str)
-- 		self.mEditTxtHandler:setTextColor(cc.c3b(0xef, 0xef, 0x9d))
-- 	end
-- end

function RoomMsgView:onNickEdit_(event)
	print("RoomMsgView.onNickEdit_",event,self.mEdit:getText())
	-- self:setText(self.mEdit:getText())
	if event == "began" then
    elseif event == "changed" then
    elseif event == "ended" then
    elseif event == "return" then
    end
end

return RoomMsgView

