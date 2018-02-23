--
-- Author: shineflag
-- Date: 2017-02-23 14:20:23
--

local log = require("app.utils.log")
local gsocket = require("app.net.gsocket")
local scheduler = require("framework.scheduler")
local Majiang = require("app.ui.Majiang")
local ActionBtnView = require("app.views.ActionBtnView")
local CircleClip = require("app.ui.CircleClip")
--local Seat = require("app.views.Seat")
local RoomControl = require("app.scenes.RoomControl")
local IMHelper = require("app.libs.IMHelper")
local EmoticonHelper = require("app.libs.EmoticonHelper")

local TAG = "RoomScene"

local RoomScene = class("RoomScene", function()
    return display.newScene("RoomScene")
end)

local game_z = {
	table   = 50,
	bet 	= 100,
	card 	= 200,
	seat 	= 300,
	ui   	= 400,
	anim    = 500,
	dialog 	= 600,
}
local top = 1
local left = 2
local bottom = 3
local right = 4

local speekTime = 30

function RoomScene:ctor(tid,level)

	self.mControl = RoomControl.new(self)
	self:addChild(self.mControl)
	self.mLevel = level 
	self.mTid = tid
	self.mActionFailRollBack = {}
    self:initView()

end

function RoomScene:initView() 
	--背景图	
	local node = display.newClippingRectangleNode()
    node:setClippingRegion(cc.rect(display.cx - 640, display.cy - 360, 1280, 720))
        :addTo(self)

    local scene, width, height = cc.uiloader:load("room_scene.json")
	scene:addTo(node)
    scene:align(display.CENTER,display.cx,display.cy)

    self.scene_ = scene

	self.mMajiangBoard = app:createView("MajiangBoard", self.mControl)
		:addTo(self.scene_,game_z.ui)

	self:setBottomHandCardsVisible()

	self.mSeatView = {}
	self.mSpeekTipsView = {}
	self.mTiRenBtns = {}
	self.mShortcutMsg = {}
	self.mReadyIcons = {}
	self.mSpeekTipsViewFilePath = {}
	self.mEmoticonViews = {}


	for i=1,4 do
		self.mReadyIcons[i] = display.newSprite('dec/zhunbei.png')
		self.mReadyIcons[i]:addTo(self.scene_,game_z.ui)
		self.mReadyIcons[i]:setVisible(false)
		self.mSeatView[i] = app:createView("SeatView", self.mControl)
		self.mSeatView[i]:addTo(self.scene_,game_z.ui)
		self.mSeatView[i]:setVisible(false)
		self.mSpeekTipsView[i] = display.newSprite("dec/voice_play_bg.png")
		local icons = {}
		for j=1,3 do
			local icon = display.newSprite(string.format("dec/voice_play%d.png",j))
			icon:setName("voice_play_icon"..j)
			icon:addTo(self.mSpeekTipsView[i])
			icons[j] = icon
		end
		if i==bottom or i==left then
			self.mSpeekTipsView[i]:setFlippedX(true)
			icons[1]:setFlippedX(true)
			icons[2]:setFlippedX(true)
			icons[3]:setFlippedX(true)
			icons[1]:setPosition(cc.p(82,28))
			icons[2]:setPosition(cc.p(72,28))
			icons[3]:setPosition(cc.p(62,28))
		else
			icons[1]:setPosition(cc.p(56,28))
			icons[2]:setPosition(cc.p(66,28))
			icons[3]:setPosition(cc.p(76,28))
		end

		self.mSpeekTipsView[i]:addTo(self.scene_,game_z.ui+2)
		self.mSpeekTipsView[i]:setVisible(false)
		self.mTiRenBtns[i] = cc.ui.UIPushButton.new('btn/bt_tichufangjian.png')
			:onButtonClicked(function()
					tt.play.play_sound("click")
					local info = self.mSeatView[i]:getPlayerInfo()
					if info then
						self:showChooseDialog("是否踢出"..info.name, nil, function()
								self.mControl:tiRenAction(i)
							end)
					end
				end)
		self.mTiRenBtns[i]:addTo(self.scene_,game_z.ui)
		self.mTiRenBtns[i]:setVisible(false)

		self.mShortcutMsg[i] = display.newNode()
		local bg = display.newScale9Sprite("dec/liaotiankuang_1.png",0,0,cc.size(236,69),cc.rect(36, 36, 1, 1))
		bg:setName("bg")
		bg:addTo(self.mShortcutMsg[i])
		self.mShortcutMsg[i]:opacity(0)
		self.mShortcutMsg[i]:setCascadeOpacityEnabled(true)
		self.mShortcutMsg[i]:addTo(self.scene_,game_z.ui)
		local label = display.newTTFLabel({
			    text = "大家好！祝大家都有好手气。",
			    size = 20  ,
			    color = cc.c3b(0x00, 0x44, 0x45), -- 使用纯红色
			    align = cc.TEXT_ALIGNMENT_LEFT,
			    valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
			    dimensions = cc.size(254, 54)
			})
		label:setName("msg")
		label:setAnchorPoint(cc.p(0,0))
		label:addTo(self.mShortcutMsg[i])

		self.mEmoticonViews[i] = display.newNode()
		self.mEmoticonViews[i]:addTo(self.scene_,game_z.ui)
	end



	self.mCenterTipsView = cc.uiloader:seekNodeByName(scene, "center_tips_view")
	self.mCenterTipsView:setVisible(false)
	self.mActionTips = {}
	self.mFengTxts = {}
	for i=1,4 do
		self.mActionTips[i] = cc.uiloader:seekNodeByName(self.mCenterTipsView, i .. "_tips")
		self.mFengTxts[i] = cc.uiloader:seekNodeByName(self.mCenterTipsView, i .. "_txt")
	end


	self.mNumTxts = {}
	self.mNumTxts[1] = cc.uiloader:seekNodeByName(self.mCenterTipsView,"num_txt_1")
	self.mNumTxts[2] = cc.uiloader:seekNodeByName(self.mCenterTipsView,"num_txt_2")


	self.mTiRenBtns[bottom]:setPosition(cc.p(639,236))
	self.mTiRenBtns[right]:setPosition(cc.p(1026,356))
	self.mTiRenBtns[top]:setPosition(cc.p(640,466))
	self.mTiRenBtns[left]:setPosition(cc.p(254,356))

    self.mControlBoard = app:createView("ControlBoard", self.mControl)
		:addTo(self.scene_,game_z.ui)

	self.mRoomIndex = cc.uiloader:seekNodeByName(scene, "room_id_txt")
	self.mRoomRuleTxt = cc.uiloader:seekNodeByName(scene, "room_rule_txt")

	cc.uiloader:seekNodeByName(scene, "menu_btn")
		:onButtonClicked(function()
					tt.play.play_sound("click")
					-- self:playPengAnim(3,0x29)
					self.mMenuView:setVisible(true)
				end)

	self.mReadyBtn = cc.uiloader:seekNodeByName(scene, "ready_btn") 
		:onButtonClicked(function()
					tt.play.play_sound("click")
					self.mControl:ready()
					self.mReadyBtn:setTouchEnabled(false)
				end)
	self.mReadyBtn:setVisible(false)

	self.mInviteFriendsBtn = cc.uiloader:seekNodeByName(scene, "invite_friends_btn") 
		:onButtonClicked(function()
				tt.play.play_sound("click")
				local text = string.format("天游麻将-房号:%06d",self.mControl:getRoomIndex())
				local config = tt.nativeData.getGameDownloadUrlConfig()
				local num = 0
				for i=1,4 do
					if self.mSeatView[i]:getUid() ~= 0 then num = num + 1 end
				end
				dump(config)
				local str = {
					"新局等你，坐满就开！\n",
					"位置不多，过时不候！\n",
					"已经三缺一，你来马上开！\n",
					"",
				}
				local ok,errorMsg = tt.WxHelper.shareWebToWx(config.url,text,self.mRoomRuleTxt:getString() .. string.format("。\n坐满就开 三缺一")) 
				if not ok then
					tt.show_msg(errorMsg)
				end
				-- local time = 0
				-- for i=1,4 do
				-- 	for j=1,4 do
				-- 		if i ~= j then
				-- 			self:performWithDelay(function()
				-- 					self:playFangPaoAnim(i,j)
				-- 				end, time);
				-- 			time = time + 1.5
				-- 		end
				-- 	end
				-- end
			end)
	self.mInviteFriendsBtn:setVisible(false)

	cc.uiloader:seekNodeByName(scene, "history_btn") 
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:showRecordDialog()
			end)


	self.mActionsSelectView = app:createView("ActionsSelectView", self.mControl)
		:addTo(self.scene_,game_z.ui)

	self.mCardsNumTxt = cc.uiloader:seekNodeByName(scene, "cards_num")
	self.mQuanJuNumTxt = cc.uiloader:seekNodeByName(scene, "quan_ju_num")

	self.mMenuView = cc.uiloader:seekNodeByName(scene, "menu_view")
	self.mMenuView:setLocalZOrder(game_z.ui+2)
	self.mMenuView:setVisible(false)
	cc.uiloader:seekNodeByName(self.mMenuView, "rule_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if tolua.isnull(self.mHelpDialog) then
					self.mHelpDialog = app:createView("HelpDialog", self)
						:addTo(self.scene_,game_z.dialog)
				end
				self.mHelpDialog:show()
				self.mMenuView:setVisible(false)
			end)

	cc.uiloader:seekNodeByName(self.mMenuView, "setting_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if tolua.isnull(self.mRoomSettingDialog) then
					self.mRoomSettingDialog = app:createView("RoomSettingDialog", self)
						:addTo(self.scene_,game_z.dialog)
				end
				self.mRoomSettingDialog:show()
				self.mMenuView:setVisible(false)
			end)

    cc.uiloader:seekNodeByName(self.mMenuView, "touch_view"):setTouchEnabled(true)
    cc.uiloader:seekNodeByName(self.mMenuView, "touch_view"):addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
			self.mMenuView:setVisible(false)
			return true
    	end)

	self.mLogoutBtn = cc.uiloader:seekNodeByName(self.mMenuView, "logout_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.mControl:logout()
				self.mMenuView:setVisible(false)
			end)
	cc.uiloader:seekNodeByName(self.mMenuView, "cancel_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.mMenuView:setVisible(false)
			end)

	local dianchi_dec = cc.uiloader:seekNodeByName(scene, "dianchi_dec")
	self.mBatterySprite = display.newDrawNode()

	local batteryMask = display.newSprite("dec/dianchixin.png")
	local clip_node = cc.ClippingNode:create()
	batteryMask:setAnchorPoint(cc.p(0,0))
	clip_node:setStencil(batteryMask);
	clip_node:addChild(self.mBatterySprite)
	clip_node:setPosition(cc.p(1, 1));
	clip_node:setAlphaThreshold(0.05)  --不显示模板的透明区域
	clip_node:setInverted( false ) --显示模板不透明的部分
	clip_node:addTo(dianchi_dec,-1)

	self:startTimeClock(cc.uiloader:seekNodeByName(scene, "time_txt"))

	self.mRoomMsgView = app:createView("RoomMsgView", self.mControl)
		:addTo(self.scene_,game_z.ui)

	self.mRoomMsgViewBtn = cc.uiloader:seekNodeByName(scene, "msg_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self.mRoomMsgView:show()
			end)
	self.mRoomMsgViewIcon = cc.uiloader:seekNodeByName(scene, "Image_6_0")

	self.loadView = display.newSprite("majiang/my_hand_1_0x15.png")
		:setPosition(cc.p(640,360))
		:setVisible(false)
	self:addChild(self.loadView)

	self:initActionBtnViews()
	self:initSpeekView()
end

function RoomScene:initSpeekView()
	self.mSpeekBtn = cc.uiloader:seekNodeByName(self.scene_, "speek_btn") 
	if (device.platform == "windows" or device.platform == "mac") and false then
		self.mSpeekBtn:onButtonClicked(function()
				IMHelper.sendMsg(tt.owner:getUid(),"test")
			end)
	else
		local scene = self
		local isSpeeking = false
		self.mSpeekInit = 0
	    self.mSpeekBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self.mSpeekBtn,function(self,event)
				local name, x, y = event.name, event.x, event.y
				-- if not scene.mControl:isRunning() then
				-- 	tt.show_msg("游戏开始后才能聊天哦！")
				-- 	return false
				-- end

				if scene.mSpeekInit ~= 3 then
					tt.show_msg("初始化语音中...")
					if scene.mSpeekInit == 0 then
						scene.mSpeekInit = 1
						tt.voiceRecord.loginGCloudVoice("woyao")
					end
					return false
				end
			    if name == "began" then
			        self.touchBeganX = x
			        self.touchBeganY = y
			        if not self:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
			        self.btn_status = "press"
			        -- 按下
	        		scene.mSpeekView:startSpeek(speekTime)
			        isSpeeking = true
			        return true
			    end

			    -- must the begin point and current point in Button Sprite
			    local touchInTarget = self:getCascadeBoundingBox():containsPoint(cc.p(self.touchBeganX, self.touchBeganY))
			                        and self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
			    if name == "moved" then
			        if touchInTarget and self.btn_status ~= "press" then
			        	self.btn_status = "press"
			        elseif not touchInTarget and self.btn_status ~= "release" then
			        	self.btn_status = "release"
						scene:speek(bottom,tt.voiceRecord.getCurPath())
			    		scene.mSpeekView:stopSpeek()
		        		isSpeeking = false
			        end
			        print(self.btn_status)
			    else
			    	self.btn_status = "release"
			    	if scene.mSpeekView:isVisible() then
				    	self:setTouchEnabled(false)
				    	scene.mSpeekView:setVisible(false)
				    	self:performWithDelay(function()
				    			self:setTouchEnabled(true)
								scene:speek(bottom,tt.voiceRecord.getCurPath())
				    			scene.mSpeekView:stopSpeek()
				    		end, 0.5)
				        if name == "ended" and touchInTarget and isSpeeking then
				        	-- 發送消息
				    		self:performWithDelay(function()
				        		tt.voiceRecord.uploadRecordedFile()
				        	end, 0.5)
				        end
				    end
		        	isSpeeking = false
			    end
			end))
	   	self.mSpeekView = app:createView("SpeekView", self.mControl)
				:addTo(self.scene_,game_z.dialog + 1000)
		self.mSpeekView:setPosition(520,240)
		self.mSpeekView:setOvertimeEvent(function()
				isSpeeking = false
		    	self.mSpeekView:stopSpeek()
				scene:speek(bottom,tt.voiceRecord.getCurPath())
		    	tt.voiceRecord.uploadRecordedFile()
			end)
   	end

end

function RoomScene:showReadyView()
	self:clearBorad()
	self.mCenterTipsView:setVisible(false)
	for i=1,4 do
		self.mSeatView[i]:setVisible(true)
		self.mSeatView[i]:stopAllActionsByTag(1000)
		self.mSpeekTipsView[i]:stopAllActionsByTag(1000)
		self.mShortcutMsg[i]:stopAllActionsByTag(1000)
		self.mTiRenBtns[i]:setVisible(false)
		self.mReadyIcons[i]:setVisible(false)
	end
	local time = 0.2

	self.mSeatView[bottom]:moveTo(time, 640,103):setTag(1000)
	self.mSeatView[right]:moveTo(time, 1173,371):setTag(1000)
	self.mSeatView[top]:moveTo(time, 640,591):setTag(1000)
	self.mSeatView[left]:moveTo(time, 107,371):setTag(1000)
	self.mSeatView[bottom]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[right]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[top]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[left]:scaleTo(time, 1):setTag(1000)


	self.mSpeekTipsView[bottom]:moveTo(time, 707,135):setTag(1000)
	self.mSpeekTipsView[right]:moveTo(time, 1075,392):setTag(1000)
	self.mSpeekTipsView[top]:moveTo(time, 568,623):setTag(1000)
	self.mSpeekTipsView[left]:moveTo(time, 173,391):setTag(1000)


	self.mShortcutMsg[bottom]:moveTo(time, 688,124):setTag(1000)
	self.mShortcutMsg[bottom]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[bottom]:getChildByName("msg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[bottom]:getChildByName("msg"):setPosition(cc.p(35,10))
	self.mShortcutMsg[left]:moveTo(time, 151,397):setTag(1000)
	self.mShortcutMsg[left]:getChildByName("msg"):setPosition(cc.p(35,10))
	self.mShortcutMsg[left]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[left]:getChildByName("msg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[top]:moveTo(time, 587,590):setTag(1000)
	self.mShortcutMsg[top]:getChildByName("bg"):setFlippedX(true)
	self.mShortcutMsg[top]:getChildByName("msg"):setPosition(cc.p(15,10))
	self.mShortcutMsg[top]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[top]:getChildByName("msg"):setAnchorPoint(cc.p(1,0))
	self.mShortcutMsg[right]:moveTo(time, 1099,393):setTag(1000)
	self.mShortcutMsg[right]:getChildByName("bg"):setFlippedX(true)
	self.mShortcutMsg[right]:getChildByName("msg"):setPosition(cc.p(15,10))
	self.mShortcutMsg[right]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[right]:getChildByName("msg"):setAnchorPoint(cc.p(1,0))

	self.mReadyIcons[bottom]:setPosition(cc.p(635,238))
	self.mReadyIcons[right]:setPosition(cc.p(1027,430))
	self.mReadyIcons[top]:setPosition(cc.p(744,579))
	self.mReadyIcons[left]:setPosition(cc.p(254,432))

	self.mEmoticonViews[bottom]:setPosition(cc.p(739,130))
	self.mEmoticonViews[right]:setPosition(cc.p(1138,482))
	self.mEmoticonViews[top]:setPosition(cc.p(541,619))
	self.mEmoticonViews[left]:setPosition(cc.p(104,482))
end

function RoomScene:showRunningView()
	self.mCenterTipsView:setVisible(true)
	for i=1,4 do
		self.mSeatView[i]:setVisible(true)
		self.mSeatView[i]:stopAllActionsByTag(1000)
		self.mSpeekTipsView[i]:stopAllActionsByTag(1000)
		self.mShortcutMsg[i]:stopAllActionsByTag(1000)
		self.mTiRenBtns[i]:setVisible(false)
		self.mReadyIcons[i]:setVisible(false)
	end

	local time = 0.2

	self.mSeatView[bottom]:moveTo(time, 58,277):setTag(1000)
	self.mSeatView[right]:moveTo(time, 1222,441):setTag(1000)
	self.mSeatView[top]:moveTo(time, 1000,603):setTag(1000)
	self.mSeatView[left]:moveTo(time, 58,522):setTag(1000)
	self.mSeatView[bottom]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[right]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[top]:scaleTo(time, 1):setTag(1000)
	self.mSeatView[left]:scaleTo(time, 1):setTag(1000)

	
	self.mSpeekTipsView[bottom]:moveTo(time, 124,311):setTag(1000)
	self.mSpeekTipsView[right]:moveTo(time, 1148,473):setTag(1000)
	self.mSpeekTipsView[top]:moveTo(time, 927,639):setTag(1000)
	self.mSpeekTipsView[left]:moveTo(time, 129,556):setTag(1000)

	self.mShortcutMsg[bottom]:moveTo(time, 107,283):setTag(1000)
	self.mShortcutMsg[bottom]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[bottom]:getChildByName("msg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[bottom]:getChildByName("msg"):setPosition(cc.p(35,10))
	self.mShortcutMsg[left]:moveTo(time, 111,527):setTag(1000)
	self.mShortcutMsg[left]:getChildByName("msg"):setPosition(cc.p(35,10))
	self.mShortcutMsg[left]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[left]:getChildByName("msg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[top]:moveTo(time, 941,577):setTag(1000)
	self.mShortcutMsg[top]:getChildByName("bg"):setFlippedX(true)
	self.mShortcutMsg[top]:getChildByName("msg"):setPosition(cc.p(15,10))
	self.mShortcutMsg[top]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[top]:getChildByName("msg"):setAnchorPoint(cc.p(1,0))
	self.mShortcutMsg[right]:moveTo(time, 1153,433):setTag(1000)
	self.mShortcutMsg[right]:getChildByName("bg"):setFlippedX(true)
	self.mShortcutMsg[right]:getChildByName("msg"):setPosition(cc.p(15,10))
	self.mShortcutMsg[right]:getChildByName("bg"):setAnchorPoint(cc.p(0,0))
	self.mShortcutMsg[right]:getChildByName("msg"):setAnchorPoint(cc.p(1,0))

	self.mReadyIcons[bottom]:setPosition(cc.p(193,303))
	self.mReadyIcons[right]:setPosition(cc.p(1111,480))
	self.mReadyIcons[top]:setPosition(cc.p(881,596))
	self.mReadyIcons[left]:setPosition(cc.p(197,539))

	self.mEmoticonViews[bottom]:setPosition(cc.p(214,199))
	self.mEmoticonViews[right]:setPosition(cc.p(1062,471))
	self.mEmoticonViews[top]:setPosition(cc.p(906,572))
	self.mEmoticonViews[left]:setPosition(cc.p(216,552))

	self.mInviteFriendsBtn:setVisible(false)
end

function RoomScene:showTuiChuBtn(flag)
	if flag then
	    self.mLogoutBtn:setButtonImage("normal", "btn/tuichu.png", true)
	    self.mLogoutBtn:setButtonImage("pressed", "btn/tuichu.png", true)
	    self.mLogoutBtn:setButtonImage("disabled", "btn/tuichu.png", true)
	else
	    self.mLogoutBtn:setButtonImage("normal", "btn/jieshan.png", true)
	    self.mLogoutBtn:setButtonImage("pressed", "btn/jieshan.png", true)
	    self.mLogoutBtn:setButtonImage("disabled", "btn/jieshan.png", true)
	end
end

function RoomScene:showTiRenBtn(seat_id)
	if self.mReadyIcons[seat_id] then
		self.mTiRenBtns[seat_id]:setVisible(true)
	end
end

function RoomScene:dismissTiRenBtn(seat_id)
	if self.mReadyIcons[seat_id] then
		self.mTiRenBtns[seat_id]:setVisible(false)
	end
end

function RoomScene:showPlayerReadyIcon(seat_id)
	if self.mReadyIcons[seat_id] then
		self.mReadyIcons[seat_id]:setVisible(true)
	end
end

function RoomScene:dismissPlayerReadyIcon(seat_id)
	if self.mReadyIcons[seat_id] then
		self.mReadyIcons[seat_id]:setVisible(false)
	end
end

function RoomScene:initActionBtnViews()
	self.mActionBtnView = display.newNode()
		:addTo(self.scene_,game_z.ui)
	self.mActionBtnView:setContentSize(1280,20)
	self.mActionBtnView:setTouchEnabled(true)
	self.mActionBtnView:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			print("mActionBtnView touch")
			return true 
		end
		)
	self.mActionBtnView:setVisible(false)
	self.mActionBtn = {}
	for i=1,6 do
		self.mActionBtn[i] = ActionBtnView.new(self.mControl,i)
		self.mActionBtn[i]:addTo(self.mActionBtnView)
	end
end

function RoomScene:showHuTipsViews(tab)
	self:dismissHuTipsViews()
	self.mHuTipsView = {}

	local table_card_num = {}

	for i,card in ipairs(self.mControlBoard:getCardData()) do
		table_card_num[card] = (table_card_num[card] or 4) - 1
	end
	for i=1,4 do
		local peng_card = {}
		local gang_card = {}
		local zhuan_card = {} 
		local bian_card = {}
		if i== 3 then
			peng_card,gang_card,zhuan_card,bian_card = self.mControlBoard:getShowCardData()
		else
			peng_card,gang_card,zhuan_card,bian_card = self.mMajiangBoard:getShowCardData(i)
		end

		for i,card in ipairs(self.mMajiangBoard:getDiscardCardsData(i)) do
			table_card_num[card] = (table_card_num[card] or 4) - 1
		end
		for i,card in ipairs(peng_card) do
			table_card_num[card] = (table_card_num[card] or 4) - 3
		end
		for i,card in ipairs(gang_card) do
			table_card_num[card.id] = (table_card_num[card.id] or 4) - 4
		end
		for i,card in ipairs(zhuan_card) do
			table_card_num[card] = (table_card_num[card] or 4) - 1
		end
	end

	for i,card_value in ipairs(tab) do
		local node = display.newSprite("dec/hupaitishi.png")
		local majiang = Majiang.new(card_value,Majiang.SELF_ON_HAND)
		local label = display.newTTFLabel({
			    text = string.format("剩%d张",table_card_num[card_value] or 4),
			    size = 21,
			    color = cc.c3b(255, 255, 255), -- 使用纯红色
			})
		node:addTo(self.scene_,game_z.ui)
		majiang:addTo(node)
		label:addTo(node)
		majiang:setPosition(cc.p(66,95))
		majiang:scale(0.8)
		label:setPosition(cc.p(66,30))
		table.insert(self.mHuTipsView,node)
	end
	local length = #self.mHuTipsView
	local flag = 9
	if length > flag then length = flag end
	local offset = 120
	local startX = 640 - length * offset / 2 + offset/2
	local startY = 250
	for i,view in ipairs(self.mHuTipsView) do
		view:setPosition(cc.p(startX,startY))
		startX = startX + offset
		if i%flag == 0 then
			startX = 640 - length * offset / 2 + offset/2
			startY = startY + 150
		end
	end
end

function RoomScene:dismissHuTipsViews()
	if self.mHuTipsView then
		for i,view in ipairs(self.mHuTipsView) do
			view:removeSelf()
		end
		self.mHuTipsView = {}
	end
end

function RoomScene:dismissActionBtnViews()
	self.mActionX = 1200
	self.mActionY = 130
	local actionFailRollBack = {}
	for i=1,6 do
		actionFailRollBack[i] = self.mActionFailRollBack[i] or self.mActionBtn[i]:isVisible()
		self.mActionBtn[i]:dismiss()
	end
	self.mActionFailRollBack = actionFailRollBack
	self.mActionBtnView:setVisible(false)
end

function RoomScene:showPreActionView()
	for i=1,6 do
		if self.mActionFailRollBack[i] then
			self.mActionBtn[i]:actionFail()
		end
	end
	self.mActionBtnView:setVisible(true)
end

function RoomScene:clearActionFailRollBack()
	self.mActionFailRollBack = {}
end

function RoomScene:showLoad()
	if self.loadView:isVisible() then return end
	self.loadView:setVisible(true)
	local index = 0
    self.loadView:schedule(function()
            index = (index + 40) % 360
            self.loadView:rotation(index)
        end,0.1)
end

function RoomScene:hideLoad()
	if not self.loadView:isVisible() then return end
	self.loadView:setVisible(false)
	self.loadView:stopAllActions()
end

function RoomScene:onEnter()
	tt.log.d(TAG, "RoomScene onEnter")	
	tt.gsocket.setHeartTime(10)

	-- tt.play.stop_music()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.reconnectServering)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}

	-- self.mControl:test()
	self.mControl:loginRoom(self.mTid,self.mLevel)

	tt.backEventManager.addBackEventLayer(self)
	self.callbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))
	self:startBatterypercentageAnim()

	tt.play.set_music_vol(0.3)
end

function RoomScene:startBatterypercentageAnim()
	local update = function()
		local w = 39
		local h = 22
		local red = cc.c4f(167/255, 2/255, 2/255, 255/255)
		local yellow = cc.c4f(214/255, 216/255, 7/255, 255/255)
		local green = cc.c4f(31/255, 172/255, 12/255, 255/255)

		local color 
		local batterypercentage = self:getBatterypercentage()/100

		if batterypercentage > 0.6 then
			color = green
		elseif batterypercentage > 0.3 then
			color = yellow
		else
			color = red
		end

		self.mBatterySprite:clear()
		self.mBatterySprite:drawSolidRect(cc.p(0,0),cc.p(w * batterypercentage,h),color)
	end
	update()
	self:schedule(function() 
			update()
		end, 5)
end

function RoomScene:setCardsNum( num )
	self.mCardsNumTxt:setString(string.format("%d" , num))
end

function RoomScene:setCurQuanJu(quan, ju)
	self.mQuanJuNumTxt:setString(string.format("第%d圈 第%d局" , quan,ju))
end

function RoomScene:getBatterypercentage()
	local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.getBatterypercentage)
	print("RoomLayer:getBatterypercentage",ok,ret)
	if ok then
		return ret
	else
		return 0
	end
end

function RoomScene:onKeypadListener(event)
	if device.platform == "android" then
		if event.key == "back" and event.type == "Released" then
			if self.mRoomMsgView:isVisible() then
				self.mRoomMsgView:dismiss()
			else
				self.mMenuView:setVisible(not self.mMenuView:isVisible())
			end
			return true
		end
	elseif device.platform == "windows" then
		if event.code == 140 and event.type == "Released" then
			if self.mRoomMsgView:isVisible() then
				self.mRoomMsgView:dismiss()
			else
				self.mMenuView:setVisible(not self.mMenuView:isVisible())
			end
			return true
		end
	end
end

function RoomScene:reconnectServering()
	if not self.roomReconnectView then
		self.roomReconnectView = app:createView("RoomReconnectView", self.mControl)
			:addTo(self.scene_,game_z.dialog + 50)
	end
	self.roomReconnectView:showReconnectView()
end

function RoomScene:reconnectServerFail()
	if not self.roomReconnectView then
		self.roomReconnectView = app:createView("RoomReconnectView", self.mControl)
			:addTo(self.scene_,game_z.dialog+ 50)
	end
	self.roomReconnectView:showReconnectfailView()
end

function RoomScene:startTimeClock(view)
	local setTime = function() 
		local time = os.time()
		if time % 2 == 1 then
			view:setString(os.date("%H:%M"))
		else
			view:setString(os.date("%H %M"))
		end
	end
	setTime()
	self:schedule(setTime, 1)
end

function RoomScene:setControlBoardCards(tab,needAnim)
	self.mControlBoard:setCards(tab)
	if needAnim then
		self.mControlBoard:reload()
		self.mControlBoard:playSortAnim()
	else
		self.mControlBoard:sortCards()
		self.mControlBoard:reload()
	end
end

function RoomScene:setControlShowCards(peng_cards,gang_cards,zhuan_cards,bian_cards)
	self.mControlBoard:setShowCards(peng_cards,gang_cards,zhuan_cards,bian_cards)
end

function RoomScene:controlBoardAddCard(card_value,isFirst)
	self.mControlBoard:addCard(card_value)
	self.mControlBoard:onActioning()
	self.mControlBoard:actionCheck(isFirst)
end

function RoomScene:actionCheck(isFirst)
	self.mControlBoard:actionCheck(isFirst)
end

function RoomScene:controlBoardDelCard(card_value)
	self.mControlBoard:delCard(card_value)
	self.mControlBoard:reload()
end

function RoomScene:getControlBoardCardNum()
	return self.mControlBoard:getCardNum()
end

function RoomScene:setMajiangBoardShowCards(seat_id,peng_cards,gang_cards,zhuan_cards,bian_cards)
	print("RoomScene:setMajiangBoardShowCards",seat_id)
	self.mMajiangBoard:setShowCards(seat_id,peng_cards,gang_cards,zhuan_cards,bian_cards)
end

function RoomScene:majiangBoardAddCard(seat_id,card_value)
	self.mMajiangBoard:addCard(seat_id,card_value)
end

function RoomScene:deal()
	for i=1,4 do
		self.mMajiangBoard:setCards(i,13)
	end
end

function RoomScene:dismissReadyBtn()
	self.mReadyBtn:setVisible(false)
end

function RoomScene:showReadyBtn()
	self.mReadyBtn:setTouchEnabled(true)
	self.mReadyBtn:setVisible(true)
	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_share) == 1 and tonumber(openConfig.check_status) == 0 and self.mControl:isNotGameStart() then
		self.mInviteFriendsBtn:setVisible(true)
	end
end

function RoomScene:setBottomHandCardsVisible(isVisible)
	self.mMajiangBoard:setBottomHandCardsVisible(isVisible)
end

function RoomScene:addDiscard(seat_id,card_value,pos)
	self.mMajiangBoard:addDiscardCard(seat_id,card_value,pos)
end

function RoomScene:delDiscard(seat_id)
	self.mMajiangBoard:delDiscardCard(seat_id)
end

function RoomScene:setMajiangBoardCards(seat_id,num)
	self.mMajiangBoard:setCards(seat_id,num)
end

function RoomScene:resetDiscardCards(seat_id,card_values)
	self.mMajiangBoard:resetDiscardCards(seat_id,card_values)
end

function RoomScene:clearBorad()
	self.mActionFailRollBack = {}
	self.mMajiangBoard:resetBoard()
	self.mControlBoard:releaseCards()
	local str = {
		"dong",
		"nan",
		"xi",
		"bei",
	}
	for i=1,4 do
		self.mActionTips[i]:setVisible(false)
		local id = self.mDongFengSeatId + i - 1
		if id > 4 then id = id - 4 end
		self.mFengTxts[id]:setTexture( string.format("fonts/%s_white.png",str[i]) )
	end
	self:setShowNum(0)
end

function RoomScene:playDiceAnim(dice1,dice2)
	self.mInviteFriendsBtn:setVisible(false)
	self.mMajiangBoard:resetBoard()
	self.mControlBoard:releaseCards()
	
	tt.play.play_sound("shazi")

	local shazi1 = display.newSprite("shaizi/shaizi.png")
	local shazi2 = display.newSprite("shaizi/shaizi.png")
	shazi1:addTo(self.scene_,game_z.anim)
	shazi2:addTo(self.scene_,game_z.anim)
	shazi1:setPosition(500,420)
	shazi2:setPosition(500,420)
	shazi1:moveTo(0.3, 600, 360)
	shazi2:moveTo(0.2, 680, 360)
	shazi1:scale(2)
	shazi2:scale(2)
	shazi2:performWithDelay(function()
			shazi1:removeSelf()
			shazi2:removeSelf()
			local shaizi_anim = cc.Animation:create()
			shaizi_anim:setDelayPerUnit(1.5/26)
			for i=1,26 do
				shaizi_anim:addSpriteFrameWithFile( string.format("shaizi/shaizi_%d.png",i))
			end
			local shaizi_view = display.newSprite("shaizi/shaizi_1.png") 
			shaizi_view:addTo(self.scene_,game_z.anim)
			shaizi_view:setPosition(640,360)
			shaizi_view:scale(2)
			shaizi_view:playAnimationOnce(shaizi_anim,true, function ()
					local shazi1 = display.newSprite(string.format("shaizi/shaizi_icon_%d.png",dice1))
					local shazi2 = display.newSprite(string.format("shaizi/shaizi_icon_%d.png",dice2))
					shazi1:addTo(self.scene_,game_z.anim)
					shazi2:addTo(self.scene_,game_z.anim)
					shazi1:setPosition(580, 360)
					shazi1:scale(0.8)
					shazi2:setPosition(700, 360)
					shazi2:scale(0.8)
					shazi2:performWithDelay(function()
						shazi1:removeSelf()
						shazi2:removeSelf()
					end,2)
				end)
		end, 0.3)
end

function RoomScene:addHandCard(seat_id,value)
	self.mMajiangBoard:addHandCard(seat_id,value)
end

function RoomScene:delHandCard(seat_id)
	self.mMajiangBoard:delHandCard(seat_id)
end

function RoomScene:setRoomIndex(index)
	self.mRoomIndex:setString( string.format("房间号:%06d",index))
	self:resetTitlePosition()
end
-- 0 平分支付 1房主支付
-- 0发胡，1点炮支付
-- 0不带风，1带风
function RoomScene:setRuleTxt(level,max_quan,pay_type,balance_type,fen,base_score)
	local str = ""
	local temp = ""
	if level and level == 101 then
		str = str .. "沧州麻将"
		temp = "，"
	end

	if balance_type == 0 then
		str = str .. temp .. "发胡"
		temp = "，"
	elseif balance_type == 1 then
		str = str .. temp .. "点炮"
		temp = "，"
	end

	if fen == 0 then
		str = str .. temp .. "不带风"
		temp = "，"
	elseif fen == 1 then
		str = str .. temp .. "带风"
		temp = "，"
	end

	if tonumber(max_quan) then
		str = str .. temp .. string.format("%d圈",tonumber(max_quan))
		temp = "，"
	end

	str = str .. temp .. "底分:" .. base_score
	temp = "，"

	if pay_type == 0 then
		str = str .. temp .. "平均支付"
		temp = "，"
	elseif pay_type == 1 then
		str = str .. temp .. "房主支付"
		temp = "，"
	end


	self.mRoomRuleTxt:setString( str )
	self:resetTitlePosition()
end

function RoomScene:resetTitlePosition()
	local posX = 640
	local size1 = self.mRoomRuleTxt:getContentSize()
	local size2 = self.mRoomIndex:getContentSize()
	local width = size1.width + size2.width + 20

	self.mRoomIndex:setPosition(cc.p(posX-width/2+size2.width,692))
	self.mRoomRuleTxt:setPosition(cc.p(posX+width/2-size1.width/2,692))
end

function RoomScene:setSeatInfo(seat_id,info)
	self.mSeatView[seat_id]:setSeatInfo(info)
end

function RoomScene:getSeatIdByUid(uid)
	for i,seat in ipairs(self.mSeatView) do
		if seat:isUid(uid) then return i end
	end
end

function RoomScene:getPlayerInfoByUid(uid)
	for i,seat in ipairs(self.mSeatView) do
		if seat:isUid(uid) then return seat:getPlayerInfo() end
	end
end

function RoomScene:getPlayerInfoBySeatId(seat_id)
	if self.mSeatView[seat_id] then
		return self.mSeatView[seat_id]:getPlayerInfo()
	end
end

function RoomScene:getUidBySeatId(seat_id)
	return self.mSeatView[seat_id]:getUid()
end

function RoomScene:clearSeatInfo(seat_id)
	self.mSeatView[seat_id]:clearSeatInfo()
end

function RoomScene:setDealer(seat_id)
	if self.mDealer then
		self.mDealer:removeSelf()
		self.mDealer = nil
	end
	self.mDealer = display.newSprite("dec/zhuang.png")
	self.mDealer:setPosition(cc.p(75,130))
	self.mSeatView[seat_id]:addChild(self.mDealer)
end

function RoomScene:setDongFeng(seat_id)
	print("RoomScene:setDongFeng",seat_id)
	self.mDongFengSeatId = seat_id
	for i=1,4 do
		local id = seat_id + i - 1
		if id > 4 then id = id - 4 end
		self.mFengTxts[id]:setTexture( string.format("fonts/feng_%d_1.png",i) )
		self.mFengTxts[id]:setVisible(true)
	end
end

function RoomScene:onSelfOutAction()
	print("onSelfOutAction")
	self.mControlBoard:onActioning()
end

function RoomScene:controlBoardOnAction(action,card_value)
	print("RoomScene:controlBoardOnAction",action,card_value)
	if OPE_RIGHT_CHI == action then
		self.mControlBoard:actionBian(card_value)
		self:playBianAnim(bottom)
	elseif OPE_MIDDEL_CHI == action then
		self.mControlBoard:actionZhuan(card_value)
		self:playZuanAnim(bottom)
	elseif OPE_LEFT_CHI == action then
		self.mControlBoard:actionBian(card_value)
		self:playBianAnim(bottom)
	elseif OPE_PENG == action then
		self.mControlBoard:actionPeng(card_value)
		self:playPengAnim(bottom,card_value)
	elseif OPE_GANG == action then
		self.mControlBoard:actionGang(card_value)
		self:playGangAnim(bottom,card_value)
	elseif OPE_AN_GANG == action then
		self.mControlBoard:actionAnGang(card_value)
		self:playGangAnim(bottom,card_value)
	elseif OPE_BU_GANG == action then
		self.mControlBoard:actionBuGang(card_value)
		self:playGangAnim(bottom,card_value)
	end
end

function RoomScene:controlBoardDelGang(card_value)
	self.mControlBoard:delGang(card_value)
end

function RoomScene:controlBoardDiscard(card_value)
	return self.mControlBoard:onDiscard(card_value)
end


function RoomScene:majiangBoardOnAction(seat_id,action,card_value)
	print("RoomScene:majiangBoardOnAction",seat_id,action,card_value)
	if OPE_RIGHT_CHI == action then
		self.mMajiangBoard:actionBian(seat_id,card_value)
		self:playBianAnim(seat_id)
	elseif OPE_MIDDEL_CHI == action then
		self.mMajiangBoard:actionZhuan(seat_id,card_value)
		self:playZuanAnim(seat_id)
	elseif OPE_LEFT_CHI == action then
		self.mMajiangBoard:actionBian(seat_id,card_value)
		self:playBianAnim(seat_id)
	elseif OPE_PENG == action then
		self.mMajiangBoard:actionPeng(seat_id,card_value)
		self:playPengAnim(seat_id,card_value)
	elseif OPE_GANG == action then
		self.mMajiangBoard:actionGang(seat_id,card_value)
		self:playGangAnim(seat_id,card_value)
	elseif OPE_AN_GANG == action then
		self.mMajiangBoard:actionAnGang(seat_id,card_value)
		self:playGangAnim(seat_id,card_value)
	elseif OPE_BU_GANG == action then
		self.mMajiangBoard:actionBuGang(seat_id,card_value)
		self:playGangAnim(seat_id,card_value)
	end
end

function RoomScene:majiangBoardDelGang(seat_id,card_value)

end

function RoomScene:showMulAction(actions)
	self.mActionsSelectView:setActions(actions)
	self.mActionsSelectView:show()
	self:dismissActionBtnViews()
end

function RoomScene:dismissMulAction()
	self.mActionsSelectView:dismiss()
end

function RoomScene:showPengBtn(card_value)
	self.mActionBtn[ActionBtnView.PENG]:show(card_value)
	self.mActionBtn[ActionBtnView.PENG]:setActionId(OPE_PENG)
	self:showGuoBtn()
end

function RoomScene:showGangBtn(action_id,card_value)
	if action_id == -1 then
		self.mActionBtn[ActionBtnView.GANG]:setShowMul(true)
		self.mActionBtn[ActionBtnView.GANG]:show(card_value)
	else
		self.mActionBtn[ActionBtnView.GANG]:setShowMul(false)
		self.mActionBtn[ActionBtnView.GANG]:show(card_value)
		self.mActionBtn[ActionBtnView.GANG]:setActionId(action_id)
	end
	self:showGuoBtn()
end

function RoomScene:showHuBtn(action_id,card_value)
	self.mActionBtn[ActionBtnView.HU]:show(card_value)
	self.mActionBtn[ActionBtnView.HU]:setActionId(action_id)
	self:showGuoBtn()
end

function RoomScene:showBianBtn(card_value)
	local num = bit.band(card_value,0x0f)
	self.mActionBtn[ActionBtnView.BIAN]:show(card_value)
	if num == 7 then
		self.mActionBtn[ActionBtnView.BIAN]:setActionId(OPE_LEFT_CHI)
	elseif num == 3 then
		self.mActionBtn[ActionBtnView.BIAN]:setActionId(OPE_RIGHT_CHI)
	end
	self:showGuoBtn()
end

function RoomScene:showZhuanBtn(card_value)
	self.mActionBtn[ActionBtnView.ZHUAN]:show(card_value)
	self.mActionBtn[ActionBtnView.ZHUAN]:setActionId(OPE_MIDDEL_CHI)
	self:showGuoBtn()
end

function RoomScene:showGuoBtn()
	self.mActionBtn[ActionBtnView.GUO]:show(0)
	self.mActionBtn[ActionBtnView.GUO]:setActionId(0)
	self:resetActionBtnPos()
end

function RoomScene:resetActionBtnPos()
	local mActionX = 850--950
	local mActionY = 130
	local mActionOffset = 140
	for i=1,6 do
		if self.mActionBtn[i]:isVisible() then
			self.mActionBtn[i]:setPosition(mActionX,mActionY)
			mActionX = mActionX - mActionOffset
			self.mActionBtnView:setVisible(true)
		end
	end
end

function RoomScene:playPengAnim(seat_id,card_value)
	local view = cc.CSLoader:createNode("anim/peng/peng.csb")--cc.uiloader:load("anim/bian/bian.csb")
	view:addTo(self.scene_,game_z.anim)

	local suit_ = Majiang.SUIT(card_value)   --类型
	local rank_ = Majiang.RANK(card_value)   --牌面值

	local fileName = string.format("majiang/my_hand_1_0x%02x.png",bit.bor(suit_,rank_))
	for i=1,3 do
		local icon = display.newSprite(fileName)
		local majiang = view:getChildByName("majiang"..i):addChild(icon)
		icon:scale(1)
		icon:setPosition(cc.p(44,79))
		view:getChildByName("majiang"..i):setVisible(false)
	end
	local action = cc.CSLoader:createTimeline("anim/peng/peng.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,55,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)

	if seat_id == top then
		view:scale(0.8)
		view:setPosition(130,430)
	elseif seat_id == left then
		view:scale(0.8)
		view:setPosition(-224,280)
	elseif seat_id == right then
		view:scale(0.8)
		view:setPosition(505,280)
	elseif seat_id == bottom then
		view:setPosition(15,110)
	end
	return 1.5
end

function RoomScene:playGangAnim(seat_id,card_value)
	local view = cc.CSLoader:createNode("anim/gang/gang.csb")--cc.uiloader:load("anim/bian/bian.csb")
	view:addTo(self.scene_,game_z.anim)
	local suit_ = Majiang.SUIT(card_value)   --类型
	local rank_ = Majiang.RANK(card_value)   --牌面值

	local fileName = string.format("majiang/my_hand_1_0x%02x.png",bit.bor(suit_,rank_))
	for i=1,4 do
		local icon = display.newSprite(fileName)
		local majiang = view:getChildByName("majiang"..i):addChild(icon)
		icon:scale(1)
		icon:setPosition(cc.p(44,79))
		view:getChildByName("majiang"..i):setVisible(false)
	end
	local action = cc.CSLoader:createTimeline("anim/gang/gang.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,55,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)

	if seat_id == top then
		view:scale(0.8)
		view:setPosition(130,430)
	elseif seat_id == left then
		view:scale(0.8)
		view:setPosition(-224,280)
	elseif seat_id == right then
		view:scale(0.8)
		view:setPosition(505,280)
	elseif seat_id == bottom then
		view:setPosition(15,110)
	end
	return 1.5
end

function RoomScene:playZuanAnim(seat_id)
	local x,y = 0,0
	if seat_id == top then
		x = 640
		y = 600
	elseif seat_id == left then
		x = 300
		y = 360
	elseif seat_id == right then
		x = 1000
		y = 360
	elseif seat_id == bottom then
		x = 640
		y = 200
	end
	local view = cc.CSLoader:createNode("anim/zuan/zuan.csb")--cc.uiloader:load("anim/bian/bian.csb")
	view:addTo(self.scene_,game_z.anim)
	view:setPosition(x,y)
	local action = cc.CSLoader:createTimeline("anim/zuan/zuan.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,30,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)
	return 1.5
end

function RoomScene:playBianAnim(seat_id)
	local x,y = 0,0
	if seat_id == top then
		x = 640
		y = 600
	elseif seat_id == left then
		x = 300
		y = 360
	elseif seat_id == right then
		x = 1000
		y = 360
	elseif seat_id == bottom then
		x = 640
		y = 200
	end

	local view = cc.CSLoader:createNode("anim/bian/bian.csb")--cc.uiloader:load("anim/bian/bian.csb")
	view:addTo(self.scene_,game_z.anim)
	view:setPosition(x,y)
	local action = cc.CSLoader:createTimeline("anim/bian/bian.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,30,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)
	return 1.5
end

function RoomScene:playHuAnim(seat_id)
	local view = cc.CSLoader:createNode("anim/hupai/hupai.csb")
	view:addTo(self.scene_,game_z.anim)
	local action = cc.CSLoader:createTimeline("anim/hupai/hupai.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,77,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)
	if seat_id == top then
		view:scale(0.8)
		view:setPosition(130,400)
	elseif seat_id == left then
		view:scale(0.8)
		view:setPosition(-224,240)
	elseif seat_id == right then
		view:scale(0.8)
		view:setPosition(505,240)
	elseif seat_id == bottom then
		view:setPosition(15,93)
	end
	return 1.5
end

function RoomScene:playZiMoAnim(seat_id)
	local view = cc.CSLoader:createNode("anim/zimo/zimo.csb")
	view:addTo(self.scene_,game_z.anim)
	local action = cc.CSLoader:createTimeline("anim/zimo/zimo.csb")
	view:runAction(action)
	action:gotoFrameAndPlay(0,77,false)
	view:performWithDelay(function()
			if not tolua.isnull(view) then
				view:removeSelf()
			end
		end, 1.5)
	if seat_id == top then
		view:scale(0.8)
		view:setPosition(130,380)
	elseif seat_id == left then
		view:scale(0.8)
		view:setPosition(-204,220)
	elseif seat_id == right then
		view:scale(0.8)
		view:setPosition(525,220)
	elseif seat_id == bottom then
		view:setPosition(15,60)
	end
	return 1.5
end

function RoomScene:playFangPaoAnim(source_seat_id,target_seat_id)
	if not self.mSeatView[source_seat_id] or not self.mSeatView[target_seat_id] then return end
	local paodan = display.newSprite("dec/paodan.png")
	local s_pos_x,s_pos_y = self.mSeatView[source_seat_id]:getPosition()
	local t_pos_x,t_pos_y = self.mSeatView[target_seat_id]:getPosition()
	print("playFangPaoAnim",s_pos_x,s_pos_y,t_pos_x,t_pos_y)
	paodan:setPosition(s_pos_x,s_pos_y)
	paodan:moveTo(0.4, t_pos_x, t_pos_y)
	paodan:addTo(self.scene_,game_z.anim)
	paodan:performWithDelay(function()
					if not tolua.isnull(paodan) then
						paodan:removeSelf()
					end
				end, 0.4)
	self:performWithDelay(function()
			local view = cc.CSLoader:createNode("anim/baozha/baozha.csb")--cc.uiloader:load("anim/bian/bian.csb")
			view:addTo(self.scene_,game_z.anim)
			view:setPosition(t_pos_x-628.50, t_pos_y-374.00)
			local action = cc.CSLoader:createTimeline("anim/baozha/baozha.csb")
			view:runAction(action)
			action:gotoFrameAndPlay(0,48,false)
			view:performWithDelay(function()
					if not tolua.isnull(view) then
						view:removeSelf()
					end
				end, 1.5)
		end, 0.4)
end

function RoomScene:startCountDownAnim(seat_id,time)
	self:stopCountDownAnim()

	local str = {
		"dong",
		"nan",
		"xi",
		"bei",
	}

	local fenId = 1
	for i=1,4 do
		local id = self.mDongFengSeatId + i - 1
		if id > 4 then id = id - 4 end
		if id == seat_id then
			fenId = i
			self.mFengTxts[id]:setTexture( string.format("fonts/%s_yellow.png",str[i]) )
		else
			self.mFengTxts[id]:setTexture( string.format("fonts/%s_white.png",str[i]) )
		end
		self.mActionTips[i]:setVisible(false)
	end

	self.mActionTips[seat_id]:setVisible(true)

    if time >= 0 then 
	    self:setShowNum(time)
		self:schedule(function()
	                time = time - 1
	                if time <= 0 then 
	                	-- self:stopCountDownAnim()
	                	-- self.mActionTips[seat_id]:setVisible(true)
	                	time = 0
	                end
	                self:setShowNum(time)
	            end,1):setTag(100)

		self:schedule(function()
					self.mActionTips[seat_id]:setVisible(not self.mActionTips[seat_id]:isVisible())

					if self.mActionTips[seat_id]:isVisible() then
						self.mFengTxts[seat_id]:setTexture( string.format("fonts/%s_yellow.png",str[fenId]) )
					else
						self.mFengTxts[seat_id]:setTexture( string.format("fonts/%s_white.png",str[fenId]) )
					end

	            end,0.5):setTag(101)
	else
		self:setShowNum(0)
	end
end

function RoomScene:setShowNum(num)
	self.mNumTxts[1]:setTexture(string.format("number/room_%d.png",(num-num%10)/10))
	self.mNumTxts[2]:setTexture(string.format("number/room_%d.png",num%10))
end

function RoomScene:stopCountDownAnim()
	self:stopActionByTag(100)
	self:stopActionByTag(101)
end

function RoomScene:setOffline(seat_id,flag)
	self.mSeatView[seat_id]:setOffline(flag)
end

function RoomScene:setSeatScore(seat_id,score)
	self.mSeatView[seat_id]:setScore(score)
end

function RoomScene:getSeatScore(seat_id)
	return self.mSeatView[seat_id]:getScore()
end

function RoomScene:getPlayer(seat_id)
	return self.mSeatView[seat_id]:getPlayer()
end

function RoomScene:showAccountsDialog(dealer,is_zimo,scores,hand_cards,win_seat_id,win_card,win_str)
	self.mControlBoard:setTouchEnabled(false)
	if tolua.isnull(self.mAccountsDialog) then
		self.mAccountsDialog = app:createView("AccountsDialog", self.mControl)
			:addTo(self.scene_,game_z.dialog)
	end
	self.mAccountsDialog:clearPreInfo()
	self.mAccountsDialog:setDealer(self.mControl:c2s(dealer)+1)  
	for i=1,4 do
		self.mAccountsDialog:setUserInfo(self.mControl:c2s(i)+1,self.mSeatView[i]:getPlayer())
	end
	for i=1,4 do  
		self.mAccountsDialog:setScore(self.mControl:c2s(i)+1,scores[i])
	end
	local peng_cards = {}
	local gang_cards = {}
	local zhuan_cards = {} 
	local bian_cards = {}
	for i=1,4 do
		if i== 3 then
			peng_cards[i],gang_cards[i],zhuan_cards[i],bian_cards[i] = self.mControlBoard:getShowCardData()
		else
			peng_cards[i],gang_cards[i],zhuan_cards[i],bian_cards[i] = self.mMajiangBoard:getShowCardData(i)
		end
	end

	for i=1,4 do
		self.mAccountsDialog:setShowCards(self.mControl:c2s(i)+1,peng_cards[i],gang_cards[i],zhuan_cards[i],bian_cards[i])
	end
	for i=1,4 do
		self.mAccountsDialog:setHandCards(self.mControl:c2s(i)+1,hand_cards[i])
	end
	print("RoomScene:showAccountsDialog",win_seat_id,win_card,win_str)
	local config = tt.nativeData.getGameConfig()
	if win_seat_id then
		local time = 0
		if is_zimo then
			time = self:playZiMoAnim(win_seat_id)
		else
			time = self:playHuAnim(win_seat_id)
		end

		self.mAccountsDialog:setWinCards(self.mControl:c2s(win_seat_id)+1,win_card,win_str)
		self:performWithDelay(function()
			self.mAccountsDialog:startCountdown(config.nextgame or 6)
			self.mAccountsDialog:show()
		end, time + 0.5)
	else
		self.mAccountsDialog:startCountdown(config.nextgame or 6)
		self.mAccountsDialog:show()
	end
end

function RoomScene:showTotalAccountsDialog(data)
	dump(data,"RoomScene:showTotalAccountsDialog")
	self.mControlBoard:setTouchEnabled(false)
	local quan,ju = self.mControl:getCurQuanJu()
	local maxJu = self.mControl:getMaxJu()
	local str = self.mRoomRuleTxt:getString()

	if tolua.isnull(self.mTotalAccountsDialog) then
		self.mTotalAccountsDialog = app:createView("TotalAccountsDialog", self.mControl)
			:addTo(self.scene_,game_z.dialog)
	end
	for i=1,4 do
		self.mTotalAccountsDialog:setUserInfo(self.mControl:c2s(i)+1,self.mSeatView[i]:getPlayer())
	end

	for i,player in ipairs(data.players) do
		local seat_id = self:getSeatIdByUid(player.uid)
		self.mTotalAccountsDialog:setPlayData(self.mControl:c2s(seat_id)+1,player,self:getSeatScore(seat_id))
	end

	self.mTotalAccountsDialog:setStartTime(data.start_time)
	self.mTotalAccountsDialog:setRuleTxt(str)
	self.mTotalAccountsDialog:setRoomIndex(self.mControl:getRoomIndex())
	self.mTotalAccountsDialog:setCurQuanJu(quan,maxJu)

	self.mTotalAccountsDialog:show()

end

function RoomScene:showChooseDialog(str,cancelClick,confirmClick)
	local dialog = app:createView("ChooseDialog")
	dialog:addTo(self.scene_,game_z.dialog)
	dialog:setContentStr(str)
	dialog:setOnCancelClick(cancelClick)
	dialog:setOnConfirmClick(confirmClick)
	dialog:show()
	return dialog
end

function RoomScene:showRoomOverApply(data,status)
	if tolua.isnull(self.mRoomOverApplyDialog) then
		self.mRoomOverApplyDialog = app:createView("RoomOverApplyDialog", self.mControl)
			:addTo(self.scene_,game_z.dialog)
	end
	for i=1,4 do
		self.mRoomOverApplyDialog:setUserInfo(self.mControl:c2s(i)+1,self.mSeatView[i]:getPlayer())
	end
	local seat_id = self:getSeatIdByUid(data.uid)
	self.mRoomOverApplyDialog:setApplyInfo(self.mSeatView[seat_id]:getPlayer(),data.total_countdown,data.countdown)

	local sstatus = {}

	for i,value in ipairs(status) do
		sstatus[self.mControl:c2s(i)+1] = value
	end

	self.mRoomOverApplyDialog:reset(sstatus)

	if status[self:getSeatIdByUid(tt.owner:getUid())] == 1 then
		self.mRoomOverApplyDialog:onAgree()
	end

	self.mRoomOverApplyDialog:show()
end

function RoomScene:dismissRoomOverApply()
	if not tolua.isnull(self.mRoomOverApplyDialog) and self.mRoomOverApplyDialog:isShowing() then
		self.mRoomOverApplyDialog:dismiss()
	end
end

function RoomScene:userActionRoomOverApply(uid,apply_type)
	print("RoomScene:userActionRoomOverApply",uid,apply_type)
	local seat_id = self:getSeatIdByUid(uid)
	if not tolua.isnull(self.mRoomOverApplyDialog) and self.mRoomOverApplyDialog:isShowing() then
	print("RoomScene:userActionRoomOverApply",uid,apply_type)
		self.mRoomOverApplyDialog:setUserStatus(self.mControl:c2s(seat_id)+1,apply_type == 1)
		if apply_type == 2 then
			local player = self.mSeatView[seat_id]:getPlayer()
			if player then
				local pinfo  = json.decode(player.pInfo)
				local dialog = self:showChooseDialog(string.format("由于玩家%s拒绝,房间解散失败。\n游戏继续！",pinfo.name), nil, nil)
				dialog:setMode(2)
			else
				local dialog = self:showChooseDialog(string.format("由于玩家拒绝,房间解散失败。\n游戏继续！"), nil, nil)
				dialog:setMode(2)
			end
			self.mRoomOverApplyDialog:dismiss()
		else
			if uid == tt.owner:getUid() then
			print("RoomScene:userActionRoomOverApply",uid,apply_type)
				self.mRoomOverApplyDialog:onAgree()
			end
		end
	end
end

function RoomScene:speek(seat_id,filePath)
	tt.voiceRecord.playRecordedFile(filePath,function()
			self.mSpeekTipsView[seat_id]:setVisible(true)
			self.mSpeekTipsView[seat_id]:stopAllActionsByTag(1)

			local index = 0
			local run = function()
				local view = self.mSpeekTipsView[seat_id]
				if index == 0 then
					view:getChildByName("voice_play_icon1"):setVisible(false)
					view:getChildByName("voice_play_icon2"):setVisible(false)
					view:getChildByName("voice_play_icon3"):setVisible(true)
				elseif index == 1 then
					view:getChildByName("voice_play_icon1"):setVisible(false)
					view:getChildByName("voice_play_icon2"):setVisible(true)
					view:getChildByName("voice_play_icon3"):setVisible(true)
				elseif index == 2 then
					view:getChildByName("voice_play_icon1"):setVisible(true)
					view:getChildByName("voice_play_icon2"):setVisible(true)
					view:getChildByName("voice_play_icon3"):setVisible(true)
				end
				index=(index+1)%3
			end
			run()
			self.mSpeekTipsView[seat_id]:schedule(run,1/3):setTag(1)

			self.mSpeekTipsView[seat_id]:performWithDelay(function()
					self.mSpeekTipsView[seat_id]:setVisible(false)
				end,speekTime):setTag(1)
			self.mSpeekTipsViewFilePath[seat_id] = filePath
		end)
end

function RoomScene:showRecordDialog()
	if tolua.isnull(self.mRecordDialog) then
		self.mRecordDialog = app:createView("RecordDialog", self.mControl)
			:addTo(self.scene_,game_z.dialog)
	end
	for i=1,4 do
		self.mRecordDialog:setUserInfo(self.mControl:c2s(i)+1,self.mSeatView[i]:getPlayer())
	end
	local maxJu = self.mControl:getMaxJu()
	self.mRecordDialog:setCurJu(maxJu)
	self.mRecordDialog:show()
end

function RoomScene:updateRecordDialog()
	if not tolua.isnull(self.mRecordDialog) then
		self.mRecordDialog:updateItems()
	end
end

function RoomScene:showMsg( seat_id,msg )
	if seat_id == bottom then
		self.mRoomMsgViewBtn:setButtonEnabled(false)
		self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing_hui.png")
		self:performWithDelay(function()
				self.mRoomMsgViewBtn:setButtonEnabled(true)
				self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing.png")
			end, 3)
	end

	local label = display.newTTFLabel({
			    text = msg,
			    size = 20  ,
			    color = cc.c3b(0x00, 0x44, 0x45), -- 使用纯红色
			})

	local width = label:getContentSize().width+50
	local max = 300
	if width < max then
		self.mShortcutMsg[seat_id]:getChildByName("bg"):setContentSize(cc.size(width,69))
	else
		self.mShortcutMsg[seat_id]:getChildByName("bg"):setContentSize(cc.size(max,69))
	end
	label:removeSelf()

	if seat_id == top or seat_id == right then
		if width < max then
			self.mShortcutMsg[seat_id]:getChildByName("msg"):setPosition(cc.p(254-width+15,10))
		else
			self.mShortcutMsg[seat_id]:getChildByName("msg"):setPosition(cc.p(254-max+15,10))
		end
	end

	self.mShortcutMsg[seat_id]:stopAllActionsByTag(100)
	self.mShortcutMsg[seat_id]:opacity(0)
	self.mShortcutMsg[seat_id]:fadeIn(0.4):setTag(100)
	self.mShortcutMsg[seat_id]:getChildByName("msg"):setString(msg)
	self.mShortcutMsg[seat_id]:performWithDelay(function()
			self.mShortcutMsg[seat_id]:fadeOut(0.4):setTag(100)
		end, 3):setTag(100)
end

function RoomScene:showShortcutMsg(seat_id,msg)
	local msg_sound = {
		["大家好！祝大家都有好手气。"]=1,
		["出牌啊，这牌你都快看出花了。"]=2,
		["诶哟，好运来了挡不住！"]=3,
		["就是不上牌，没辙！"]=4,
		["你是哪的人啊，咱们加个好友吧。"]=5,
		["今天幸运女神这么眷顾你呀！"]=6,
		["又断线了，今天这网怎么了？"]=7,
		["都别走啊，一会再打两圈。"]=8,
		["刚才在接电话，久等了各位。"]=9,
	}
	if msg_sound[msg] then
		tt.play.play_sound("fix_msg_"..msg_sound[msg])
	end

	local label = display.newTTFLabel({
			    text = msg,
			    size = 20  ,
			    color = cc.c3b(0x00, 0x44, 0x45), -- 使用纯红色
			})

	local width = label:getContentSize().width+50
	local max = 300
	if width < max then
		self.mShortcutMsg[seat_id]:getChildByName("bg"):setContentSize(cc.size(width,69))
	else
		self.mShortcutMsg[seat_id]:getChildByName("bg"):setContentSize(cc.size(max,69))
	end
	label:removeSelf()
	if seat_id == top or seat_id == right then
		if width < max then
			self.mShortcutMsg[seat_id]:getChildByName("msg"):setPosition(cc.p(254-width+15,10))
		else
			self.mShortcutMsg[seat_id]:getChildByName("msg"):setPosition(cc.p(254-max+15,10))
		end
	end

	if seat_id == bottom then
		self.mRoomMsgViewBtn:setButtonEnabled(false)
		self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing_hui.png")
		self:performWithDelay(function()
				self.mRoomMsgViewBtn:setButtonEnabled(true)
				self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing.png")
			end, 3)
	end
	self.mShortcutMsg[seat_id]:stopAllActionsByTag(100)
	self.mShortcutMsg[seat_id]:opacity(0)
	self.mShortcutMsg[seat_id]:fadeIn(0.4):setTag(100)
	self.mShortcutMsg[seat_id]:getChildByName("msg"):setString(msg)
	self.mShortcutMsg[seat_id]:performWithDelay(function()
			self.mShortcutMsg[seat_id]:fadeOut(0.4):setTag(100)
		end, 3):setTag(100)
end

function RoomScene:showEmoticonMsg(seat_id,id)
	local emoticon = EmoticonHelper.createEmoticonById(id)
	if not emoticon then return end
	emoticon.frameSprite:addTo(self.mEmoticonViews[seat_id])
	-- emoticon.frameSprite:scale(0.7)
	local time = emoticon.play()+0.5
	self.mEmoticonViews[seat_id]:performWithDelay(function()
			emoticon.frameSprite:removeSelf()
		end, time)
	
	if seat_id == bottom then
		self.mRoomMsgViewBtn:setButtonEnabled(false)
		self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing_hui.png")
		self:performWithDelay(function()
				self.mRoomMsgViewBtn:setButtonEnabled(true)
				self.mRoomMsgViewIcon:setTexture("btn/bt_biaoqing.png")
			end, time)
	end
end
 
function RoomScene:onSocketData(evt)
	if evt.cmd == "login.shake" then
		if self.roomReconnectView then
			self.roomReconnectView:dismiss()
		end
		local data = evt.data
		if not data then return end   
		if data.ret == 0 then
			-- 正常登陆
			tt.show_msg("房间已解散")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		elseif data.ret == 1 then
			-- 重连
			-- tt.show_msg("重连房间中...")
			self:showLoad()
			self.mControl:loginRoom(data.tid,data.level)
			-- self:performWithDelay(function()
			-- 		app:enterScene("MainScene",{true,{tid=data.tid,level=data.level}})
			-- 	end, 1)
		elseif data.ret == 2 then
			tt.show_msg("登陆服务器失败")
	    	tt.gsocket:disconnect()
			self:performWithDelay(function()
					app:enterScene("LoginScene")
				end, 1)
		end
	elseif evt.cmd == "room.login" then
		local data = evt.data
		if not data then return end
		self:hideLoad()
		dump(data)
		if data.ret == 0 then
			self.mControl:onLogin(data)
		elseif data.ret == 4 then
			tt.show_msg("桌子不存在")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		elseif data.ret == 6 then
			tt.show_msg("桌位已满")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		elseif data.ret == 14 then
			tt.show_msg("钻石不足")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		else
			tt.show_msg("登陆桌子失败")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		end
	elseif evt.cmd == "room.userJoin" then
		if evt.data then
			self.mControl:onUserJoin(evt.data)
		end
	elseif evt.cmd == "room.logout" then
		local data = evt.data
		if data and data.ret == 0 and not self.mControl:isGameOver() then
			print("room.logout",self.mControl:isGameOver())
			app:enterScene("MainScene")
		end
	elseif evt.cmd == "room.userLeave" then
		if evt.data then
			self.mControl:onUserLeave(evt.data)
		end
	elseif evt.cmd == "room.ready" then 
		if evt.data and evt.data.ret == 0 then
			self:dismissReadyBtn()
		else
			tt.show_msg("准备失败")
			self:showReadyBtn()
		end
	elseif evt.cmd == "room.userReady" then 
		if evt.data then
			self.mControl:onUserReady(evt.data)
		end
	elseif evt.cmd == "room.start" then
		if evt.data then
			self.mControl:onStart(evt.data)
		end
	elseif evt.cmd == "room.deal" then
		if evt.data then
			self.mControl:onDeal(evt.data)
		end
	elseif evt.cmd == "room.dealOne" then
		if evt.data then
			self.mControl:onDealOne(evt.data)
		end
	elseif evt.cmd == "room.userDiscard" then
		if evt.data then
			self.mControl:onUserDiscard(evt.data)
		end
	elseif evt.cmd == "room.userAction" then
		if evt.data then
			self.mControl:onUserAction(evt.data)
		end
	elseif evt.cmd == "room.noticeAction" then
		if evt.data then
			self.mControl:onNoticeAction(evt.data)
		end
	elseif evt.cmd == "room.actionFail" then
		if evt.data then
			self.mControl:onActionFail(evt.data)
		end
	elseif evt.cmd == "room.roomClose" then
		if evt.data then
			local ret = evt.data.ret
			if ret == 0 then
				tt.show_msg("游戏未开始，房间解散")
				self:performWithDelay(function()
						app:enterScene("MainScene")
					end, 1)
			elseif ret == 1 then 
				tt.show_msg("房间解散")
				if not self.mControl:isNotGameStart() then
					self.mControl:onTotalAccountsDialog(evt.data,true)
				end
			elseif ret == 2 then 
				-- 整个游戏结束 最后一个庄家垮庄
				self.mControl:onTotalAccountsDialog(evt.data,false)
			end
		end
	elseif evt.cmd == "room.gameOver" then
		if evt.data then
			self.mControl:onGameOver(evt.data)
		end
	elseif evt.cmd == "room.sendMsg" then
		if evt.data then
			self.mControl:onMsg(evt.data)
		end
	elseif evt.cmd == "room.serverError" then
		if evt.data.code == 2 then
			tt.show_msg("服务器异常")
			self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
		end
	elseif evt.cmd == "room.onRoomOverApply" then
		if evt.data then
			self.mControl:onRoomOverApply(evt.data)
		end
	elseif evt.cmd == "room.onUserRoomOverApply" then
		if evt.data then
			self.mControl:onUserRoomOverApply(evt.data)
		end
	elseif evt.cmd == "server.gemUpdate" then
		if evt.data then
			for i,player in ipairs(evt.data.players) do
				if player.uid == tt.owner:getUid() then
					tt.owner:setGem(player.gem)
				end
			end
		end
	elseif evt.cmd == "room.getRecord" then
		if evt.data then
			self.mControl:onGetRecord(evt.data)
		end
	elseif evt.cmd == "room.onTiRenBroadcast" then
		if evt.data then
			self.mControl:onTiRenBroadcast(evt.data)
		end
	elseif evt.cmd == "room.onStandUpBroadcast" then
		if evt.data then
			self.mControl:onStandUpBroadcast(evt.data)
		end
	elseif evt.cmd == "php.broadcast" then
		local data = evt.data
		if data then
			if data.msg_type == 10022 then
				local params = json.decode(data.content)
				tt.owner:setGem(tt.owner:getGem() + tonumber(params.zuan) or 0)
				tt.show_msg(params.message or "支付到账")
			end
		end
	elseif evt.cmd == "room.onUserOfflineBroadcast" then
		if evt.data then
			self.mControl:onUserOfflineBroadcast(evt.data)
		end
	end
end

function RoomScene:onNativeEvent(evt)
	printInfo("RoomScene:onNativeEvent cmd %s params %s", evt.cmd,evt.params)
	if evt.cmd == tt.platformEventHalper.callbackCmds.gCloudVoice then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			if params.method == "OnApplyMessageKey" then
				if params.code == 7 then
					self.mSpeekInit = 3
				else
					self.mSpeekInit = 0
					tt.show_msg("语音聊天初始化失败 code:" .. params.code)
				end
			elseif params.method == "OnPlayRecordedFile" then
				for i=1,4 do
					if self.mSpeekTipsViewFilePath[i] == params.filePath then
						self.mSpeekTipsView[i]:setVisible(false)
					end
				end
				if params.code == 21 then

				else
					tt.show_msg("语音消息播放失败 code:" .. params.code)
				end
			elseif params.method == "OnDownloadFile" then
				if params.code == 13 then
					self.mControl:onDownloadRecordedFile(params)
        			-- audio.playSound(params.filePath, flag or false)
				else
					tt.show_msg("语音消息下载失败 code:" .. params.code)
				end
			elseif params.method == "OnUploadFile" then
				if params.code == 11 then
					IMHelper.sendVoice(tt.owner:getUid(),params.fileID)
					-- tt.voiceRecord.downloadRecordedFile(params.fileID)
				else
					tt.show_msg("语音消息发送失败 code:" .. params.code)
				end
			end
	 	elseif params.ret == 2 then
	 	elseif params.ret == 3 then
		end
	end
end

function RoomScene:onExit()
	tt.play.stop_music()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end
	tt.backEventManager.unregisterCallBack(self.callbackHandler)
	tt.voiceRecord.clearSpeekQueue()
end




return RoomScene
