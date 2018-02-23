
local CircleClip = require("app.ui.CircleClip")


local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor(fromLogin,gotoRoomData)
	self.isFromLogin = fromLogin == true
	self.isShowMyMatchListView = fromLogin == true
	self.isShowMyMatchListViewCash = fromLogin == true
	self:initView()
	self.mGotoRoomData = gotoRoomData
	-- self:test()
end

function MainScene:initView() 

	--背景图	
	local node = display.newClippingRectangleNode()
    node:setClippingRegion(cc.rect(display.cx - 640, display.cy - 360, 1280, 720))
        :addTo(self)

    local scene, width, height = cc.uiloader:load("main_scene.json")
	scene:addTo(node)
    scene:align(display.CENTER,display.cx,display.cy)

    self.scene_ = scene

    self.create_room_btn = cc.uiloader:seekNodeByName(scene, "create_room_btn")
    	:onButtonClicked(function()
				-- tt.play.play_sound("click")
    			self:showCreateRoomDialog()
    		end)
    self.join_room_btn = cc.uiloader:seekNodeByName(scene, "join_room_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showJoinRoomDialog()
    		end)

    self.setting_btn = cc.uiloader:seekNodeByName(scene, "setting_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showSettingDialog()
    		end)

    self.help_btn = cc.uiloader:seekNodeByName(scene, "help_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showHelpDialog()
    		end)

    self.msg_btn = cc.uiloader:seekNodeByName(scene, "msg_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showNoticeDialog()
    		end)

    self.shop_btn = cc.uiloader:seekNodeByName(scene, "shop_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showShopDialog()
    		end)

    self.get_gem_btn = cc.uiloader:seekNodeByName(scene, "get_gem_btn")
    	:onButtonClicked(function()
				tt.play.play_sound("click")
    			self:showShopDialog()
    		end)

	self.userinfo_btn = cc.uiloader:seekNodeByName(scene, "userinfo_btn")
	:onButtonClicked(function()
			local openConfig = tt.nativeData.getOpenConfig()
			if tonumber(openConfig.open_join) == 0 or tonumber(openConfig.check_status) == 1 then
				return
			end 
			tt.play.play_sound("click")
			self:showUserInfoDialog()
		end)


	self.record_btn = cc.uiloader:seekNodeByName(scene, "record_btn")
	:onButtonClicked(function()
			tt.play.play_sound("click")
			self:showHistoryRecordDialog()
		end)


    self.collar_gem_btn = cc.uiloader:seekNodeByName(scene, "collar_gem_btn")
    	:setVisible(false)
    self.collar_gem_anim = cc.uiloader:seekNodeByName(scene, "collar_gem_anim")
    	:setVisible(false)

    self.gem_icon = cc.uiloader:seekNodeByName(scene, "gem_icon")

    self.mNameTxt = cc.uiloader:seekNodeByName(scene, "name_txt")
    self.mUidTxt = cc.uiloader:seekNodeByName(scene, "uid_txt")
    self.mHeadIcon = cc.uiloader:seekNodeByName(scene, "head_icon")
    self.mGemTxt = cc.uiloader:seekNodeByName(scene, "gem_txt")

    self.mAdContent = cc.uiloader:seekNodeByName(scene, "ad_content")

	self.mAdContent:setTouchEnabled(true)
	self.mAdContent:setTouchSwallowEnabled(false)
	local downX,downY =0,0
	local down = false
	self.mAdContent:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    local x,y = event.x,event.y
	    if event.name == "began" then
	    	downX = x
        	downY = y
        	if not self.mAdContent:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then return false end
        	down = true
        	return true
	    elseif event.name ~= "began" and down then
	    	if event.name == "ended" and down then
	    		if self.mAdContent:getCascadeBoundingBox():containsPoint(cc.p(x, y)) then
	    			if  math.abs(downX-x) > 20 then
		    			if downX-x > 0 then
		    				self:nextAd()
		    			else
		    				self:preAd()
		    			end
	    			else
	    				if self.mAds then
	    					local data = self.mAdsDatas[self.mAdIndex]
							if type(data) ~= "table" or data.url == "" then return end
							tt.play.play_sound("click")
							print("url",data.url)
							-- self.mControl:tiRenAction(i)
							self:showActivityDialog(data.url)
	    				end
	    			end
	    		end
	    		return true
	    	end
		end
	end)

 	local view = cc.uiloader:seekNodeByName(scene, "version_view")

 	local version_txt = display.newSprite("fonts/banbenhao.png")
 	local num = tt.getBitmapStrAscii("number/banben_%d.png",kVersion)
 	view:setContentSize(0,0)
 	view:scale(0.95)
 	tt.linearlayout(view,version_txt,-1,20)
 	tt.linearlayout(view,num,-1,20)
end

function MainScene:onEnter()
	tt.log.d(TAG, "MainScene onEnter")	
	tt.gsocket.setHeartTime(10)
	-- tt.show_wait_view()
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),
		tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, handler(self, self.onHttpResp)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.reconnectServering)),
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}
	tt.log.d(TAG,"MainScene gsocket isConnected %s",tt.gsocket:isConnected())
	if tt.gsocket:isConnected() then
		-- self:onShakeOK()
	end
	
	tt.play.resume_music()
	tt.backEventManager.addBackEventLayer(self)
	self.callbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))


	local clip = cc.ClippingNode:create()
	local mask = display.newSprite("dec/hell_saoguangfanwei_mask.png")
	clip:setStencil(mask)
	clip:setAlphaThreshold(0)  --不显示模板的透明区域
	clip:setInverted( false ) --显示模板不透明的部分
	clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
	clip:setPosition(cc.p(0,0))

	self.scene_:addChild(clip)
	clip:setPosition(self.create_room_btn:getPosition())
	-- self.create_room_btn:addChild(clip)
	local animView = display.newSprite("dec/hell_saoguangfanwei.png")
	clip:addChild(animView)
	local sequence = transition.sequence({
	    cc.DelayTime:create(0),
	    cc.MoveTo:create(0, cc.p(-400, 100)),
	    cc.MoveTo:create(2, cc.p(400, 0)),
	    cc.DelayTime:create(1.4),
	})

	
	animView:setBlendFunc(gl.DST_ALPHA, gl.DST_ALPHA)
	animView:setOpacity(128)
	animView:runAction(cc.RepeatForever:create(sequence))


	local sequence = transition.sequence({
	    cc.FadeTo:create(0, 128),
	    cc.DelayTime:create(1.0),
	    cc.FadeTo:create(0.3, 0),
	    cc.DelayTime:create(2.1),
	})

	animView:runAction(cc.RepeatForever:create(sequence))


	local clip = cc.ClippingNode:create()
	local mask = display.newSprite("dec/hell_saoguangfanwei_mask.png")
	clip:setStencil(mask)
	clip:setAlphaThreshold(0)  --不显示模板的透明区域
	clip:setInverted( false ) --显示模板不透明的部分
	clip:setContentSize(mask:getContentSize().width,mask:getContentSize().height)
	clip:setPosition(cc.p(0,0))

	self.scene_:addChild(clip)
	clip:setPosition(self.join_room_btn:getPosition())
	-- self.join_room_btn:addChild(clip)
	local animView = display.newSprite("dec/hell_saoguangfanwei.png")
	animView:setPosition(cc.p(-400, 0))
	clip:addChild(animView)
	local sequence = transition.sequence({
	    cc.DelayTime:create(1.4),
	    cc.MoveTo:create(0, cc.p(-400, 100)),
	    cc.MoveTo:create(2, cc.p(400, 0)),
	    cc.DelayTime:create(0),
	})

	animView:runAction(cc.RepeatForever:create(sequence))

	local sequence = transition.sequence({
	    cc.FadeTo:create(0, 255),
	    cc.DelayTime:create(2.4),
	    cc.FadeTo:create(0.3, 0),
	    cc.DelayTime:create(0.7),
	})

	animView:runAction(cc.RepeatForever:create(sequence))


	self.collar_gem_anim:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 60)))

	local sequence = transition.sequence({
	    cc.FadeTo:create(0.8, 0.2*255),
	    cc.FadeTo:create(0.8, 1*255),
	})
	self.collar_gem_anim:runAction(cc.RepeatForever:create(sequence))


	local sequence = transition.sequence({
	    cc.ScaleTo:create(0.8, 1, 1),
	    cc.ScaleTo:create(0.8, 1.2, 1.2)
	})
	self.collar_gem_anim:runAction(cc.RepeatForever:create(sequence))


	local anim = cc.uiloader:seekNodeByName(self.gem_icon:getParent(), "anim")

	-- anim:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 60)))

	local sequence = transition.sequence({
	    cc.FadeTo:create(0.8, 0.4*255),
	    cc.FadeTo:create(0.8, 1*255),
	})
	anim:runAction(cc.RepeatForever:create(sequence))

	local sequence = transition.sequence({
	    cc.ScaleTo:create(0.8, 0.4, 0.4),
	    cc.ScaleTo:create(0.8, 1, 1)
	})
	anim:runAction(cc.RepeatForever:create(sequence))

	if self.mGotoRoomData then
		-- tt.show_wait_view("登陆房间中...")
		local data = self.mGotoRoomData
		self.mGotoRoomData = nil
		app:enterScene("RoomScene",{data.tid,data.level})
	end

	self:updateUid()
	self:updateName()
	self:updateGem()
	self:updateHeadIcon(tt.owner:getIconUrl())

	local requestShipData = tt.nativeData.getRequestShipData()
	if requestShipData then
	 	for _,params in pairs(requestShipData) do
	 		if params.pmode == 3 then
	 			local data = params
				local param = {}
				param.apple_receipt = data.receipt
				param.orderid = data.orderid
				tt.ghttp.request(tt.cmd.ios_notify,param)
	 		end
	 	end
	end
	 
	tt.play.set_music_vol(1)

	local params = {}
	tt.ghttp.request(tt.cmd.lucky_img,params)
end

function MainScene:updateName()
	self.mNameTxt:setString(tt.owner:getName())
end

function MainScene:updateUid()
	self.mUidTxt:setString("ID:"..tt.owner:getUid())
end

function MainScene:updateGem()
	self.mGemTxt:setString(tt.owner:getGem())
end

function MainScene:onKeypadListener(event)
	if device.platform == "android" then
		if event.key == "back" and event.type == "Released" then
			self:showQuitDialog()
			return true
		end
	elseif device.platform == "windows" then
		if event.code == 140 and event.type == "Released" then
			self:showQuitDialog()
			return true
		end
	end
end

function MainScene:showQuitDialog()
	self:showChooseDialog("是否退出游戏", nil, function()
			os.exit()
		end)
end

function MainScene:onExit()
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end 

	tt.backEventManager.unregisterCallBack(self.callbackHandler)
end

function MainScene:checkRoom(num)
	local params = {}
	params.uid = tt.owner:getUid()
	params.level = 101
	params.index = num
	dump(params)
	tt.gsocket.request("room.check",params)
	tt.show_wait_view("查询中...")
end

function MainScene:updateHeadIcon(url)
	printInfo("MainScene:updateHeadIcon %s", url)
	tt.asynGetHeadIconSprite(url,function(sprite)
		if sprite and self and self.mHeadIcon then
			local size = self.mHeadIcon:getContentSize()
			local mask = display.newSprite("bg/hell_head_bg3.png")
			if self.head_ then
				self.head_:removeSelf()
			end
			self.head_ = CircleClip.new(sprite,mask):addTo(self.mHeadIcon)
				:setCircleClipContentSize(size.width,size.width)
			self.head_:setPosition(cc.p(0,0))
		end
	end)
end

function MainScene:updateName()
	self.mNameTxt:setString(tt.owner:getName())
end

function MainScene:updateUid()
	self.mUidTxt:setString(tt.owner:getUid())
end

function MainScene:startTimeClock()
	self:schedule(function() 
			local time = os.time()
			if time % 2 == 1 then
				self.timeClock:setString(os.date("%H:%M"))
			else
				self.timeClock:setString(os.date("%H %M"))
			end
		end, 1)
end

function MainScene:startBatterypercentageAnim()
	self.electricity_v:setScaleX(8*self:getBatterypercentage()/100)
	self:schedule(function() 
			self.electricity_v:setScaleX(8*self:getBatterypercentage()/100)
		end, 5)
end

function MainScene:getBatterypercentage()
	local ok,ret = tt.platformEventHalper.callEvent(tt.platformEventHalper.cmds.getBatterypercentage)
	print("MainScene:getBatterypercentage",ok,ret)
	if ok then
		return ret
	else
		return 0
	end
end

function MainScene:showJoinRoomDialog()
	if tolua.isnull(self.mJoinRoomDialog) then
		self.mJoinRoomDialog = app:createView("JoinRoomDialog", self)
			:addTo(self.scene_,100)
	end
	self.mJoinRoomDialog:show()
end

function MainScene:showSettingDialog()
	if tolua.isnull(self.mSettingDialog) then
		self.mSettingDialog = app:createView("SettingDialog", self)
			:addTo(self.scene_,100)
	end
	self.mSettingDialog:show()
end

function MainScene:showHelpDialog()
	if tolua.isnull(self.mHelpDialog) then
		self.mHelpDialog = app:createView("HelpDialog", self)
			:addTo(self.scene_,100)
	end
	self.mHelpDialog:show()
end

function MainScene:showNoticeDialog()
	if tolua.isnull(self.mNoticeDialog) then
		self.mNoticeDialog = app:createView("NoticeDialog", self)
			:addTo(self.scene_,100)
	end
	-- self.mNoticeDialog:setNoticeStr("大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒大苏打实打实大撒撒旦撒十大打撒打撒阿斯顿啊实打实的阿斯顿阿斯顿阿斯顿啊的撒")
	self.mNoticeDialog:show()
end

function MainScene:showCreateRoomDialog()
	if tolua.isnull(self.mCreateRoomDialog) then
		self.mCreateRoomDialog = app:createView("CreateRoomDialog", self)
			:addTo(self.scene_,100)
	end
	self.mCreateRoomDialog:show()
end

function MainScene:showChooseDialog(str,cancelClick,confirmClick)
	local view = app:createView("ChooseDialog")
		:addTo(self.scene_,100)
		:setContentStr(str)
		:setOnCancelClick(cancelClick)
		:setOnConfirmClick(confirmClick)
	view:show()
	return view
end

function MainScene:showShopDialog()
	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_join) == 1 and tonumber(openConfig.check_status) == 0 then
		if not tt.owner:isJoinSn() then
			self:showInviteDialog()
			return 
		end
	end 
	if tolua.isnull(self.mShopDialog) then
		self.mShopDialog = app:createView("ShopDialog",self)
			:addTo(self.scene_,100)
	end
	self.mShopDialog:show()

end

function MainScene:showUserInfoDialog()
	print("MainScene:showUserInfoDialog",tt.owner:getRole())
	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_join) == 0 or tonumber(openConfig.check_status) == 1 then
		return
	end 

	if tt.owner:getRole() == 1 then
		if tolua.isnull(self.mUserinfoDialog) then
			self.mUserinfoDialog = app:createView("UserinfoDialog",self)
				:addTo(self.scene_,100)
		end
		self.mUserinfoDialog:show()
	else
		if tolua.isnull(self.mUserinfoWebViewDialog) then
			self.mUserinfoWebViewDialog = app:createView("UserinfoWebViewDialog",self)
				:addTo(self.scene_,100)
		end
		self.mUserinfoWebViewDialog:show()
	end
end

function MainScene:showInviteDialog()
	if tolua.isnull(self.mInviteDialog) then
		self.mInviteDialog = app:createView("InviteDialog",self)
			:addTo(self.scene_,100)
	end
	self.mInviteDialog:show()
end

function MainScene:showHistoryRecordDialog()
	if tolua.isnull(self.mHistoryRecordDialog) then
		self.mHistoryRecordDialog = app:createView("HistoryRecordDialog",self)
			:addTo(self.scene_,100)
	end
	self.mHistoryRecordDialog:show()
end


function MainScene:showTotalAccountsDialog(data)
	dump(data,"MainScene:showTotalAccountsDialog")
	local quan,ju = data.quan,data.ju
	local str = data.rule_txt

	if tolua.isnull(self.mTotalAccountsDialog) then
		self.mTotalAccountsDialog = app:createView("TotalAccountsDialog", self)
			:addTo(self.scene_,100)
		self.mTotalAccountsDialog:setReView(true)
	end

	for i=1,4 do
		self.mTotalAccountsDialog:setUserInfo(i,data.playerInfo[i])
		self.mTotalAccountsDialog:setPlayData(i,data.gameInfo[i],data.gameInfo[i].score)
	end

	self.mTotalAccountsDialog:setStartTime(data.start_time)
	self.mTotalAccountsDialog:setRuleTxt(data.rule_txt)
	self.mTotalAccountsDialog:setRoomIndex(data.room_index)
	self.mTotalAccountsDialog:setCurQuanJu(quan,ju)

	self.mTotalAccountsDialog:show()

end

function MainScene:showWebPayDialog(url)
	if tolua.isnull(self.mWebPayDialog) then
		self.mWebPayDialog = app:createView("WebPayDialog", self)
			:addTo(self.scene_,10000)
	end
	self.mWebPayDialog:show()
	self.mWebPayDialog:loadUrl(url)
end


function MainScene:showActivityDialog(url)
	if tolua.isnull(self.mActivityDialog) then
		self.mActivityDialog = app:createView("ActivityDialog", self)
			:addTo(self.scene_,10000)
	end
	self.mActivityDialog:show(url)
end



function MainScene:showHornView(str)
	if tolua.isnull(self.mHornView) then
		self.mHornView = app:createView("HornView", self)
			:addTo(self.scene_,10)
		local size = self.mHornView:getContentSize()
		self.mHornView:setPosition(cc.p(640-size.width/2,550))
	end
	self.mHornView:show(str)
end

function MainScene:preAd()
	if self.mAds and #self.mAds > 1 then
		local size = self.mAdContent:getContentSize()
		local time = 1
		self.mAds[self.mAdIndex]:stopAllActions()
		self.mAds[self.mAdIndex]:setPosition(cc.p(size.width/2,size.height/2))
		self.mAds[self.mAdIndex]:moveBy(time,size.width, 0)
		self.mAdIndex = self.mAdIndex - 1
		if self.mAdIndex == 0 then self.mAdIndex = #self.mAds end
		self.mAds[self.mAdIndex]:setPosition(cc.p(size.width/2-size.width,size.height/2))
		self.mAds[self.mAdIndex]:stopAllActions()
		self.mAds[self.mAdIndex]:moveBy(time, size.width, 0)
		self.mAds[self.mAdIndex]:setVisible(true)
		self:stopActionByTag(11)
		self.mAdContent:setTouchEnabled(false)
		self.mAdContent:performWithDelay(function()
				self.mAdContent:setTouchEnabled(true)
			end, time)
		self:schedule(function()
				self:nextAd()
			end,5):setTag(11)
	end
end

function MainScene:nextAd()
	if self.mAds and #self.mAds > 1 then
		local size = self.mAdContent:getContentSize()
		local time = 1
		self.mAds[self.mAdIndex]:stopAllActions()
		self.mAds[self.mAdIndex]:setPosition(cc.p(size.width/2,size.height/2))
		self.mAds[self.mAdIndex]:moveBy(time,-size.width, 0)
		self.mAdIndex = self.mAdIndex + 1
		if self.mAdIndex > #self.mAds then self.mAdIndex = 1 end
		self.mAds[self.mAdIndex]:setPosition(cc.p(size.width/2+size.width,size.height/2))
		self.mAds[self.mAdIndex]:stopAllActions()
		self.mAds[self.mAdIndex]:moveBy(time, -size.width, 0)
		self.mAds[self.mAdIndex]:setVisible(true)
		self:stopActionByTag(11)
		self.mAdContent:setTouchEnabled(false)
		self.mAdContent:performWithDelay(function()
				self.mAdContent:setTouchEnabled(true)
			end, time)
		self:schedule(function()
				self:nextAd()
			end,5):setTag(11)
	end
end

function MainScene:showAdAnim(datas)
	self.mAdContent:removeAllChildren()
	self.mAds = {}
	self.mAdsDatas = datas
	for i,data in ipairs(datas) do
		local btn = cc.ui.UIPushButton.new('btn/btn_touming.png')
			:setTouchEnabled(false)
		local loading = display.newSprite("dec/long.png")
        loading:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -360)))

        loading:scale(0.2)
		loading:addTo(btn)
		local size = self.mAdContent:getContentSize()
		btn:addTo(self.mAdContent)

		btn:setButtonSize(size.width,size.height)
		btn:setVisible(false)
		table.insert(self.mAds,btn)
		tt.asynGetHeadIconSprite(string.urldecode(data.img),function(sprite)
			if sprite and not tolua.isnull(btn) then
				local size2 = sprite:getContentSize()
	            local scaleX = size.width/size2.width
	            local scaleY = size.height/size2.height
	            
	            sprite:setScaleX(scaleX)
	            sprite:setScaleY(scaleY)
				btn:addChild(sprite)
	            loading:removeSelf()
			end
		end)
	end

	self.mAdIndex = 1
	local size = self.mAdContent:getContentSize()

	if #self.mAds > 1 then
		self.mAds[self.mAdIndex]:setPosition(cc.p(size.width/2,size.height/2))
		self.mAds[self.mAdIndex]:setVisible(true)
		self:schedule(function()
				self:nextAd()
			end,5):setTag(11)
	else
		if self.mAds[1] then
			self.mAds[1]:setPosition(cc.p(size.width/2,size.height/2))
			self.mAds[1]:setVisible(true)
		end
	end
end

function MainScene:reconnectServering()
	if not self.hallReconnectView then
		self.hallReconnectView = app:createView("HallReconnectView", self)
			:addTo(self.scene_,1000)
	end
	self.hallReconnectView:showReconnectView()
end

function MainScene:reconnectServerFail()
	if not self.hallReconnectView then 
		self.hallReconnectView = app:createView("HallReconnectView", self)
			:addTo(self.scene_,1000)
	end
	self.hallReconnectView:showReconnectfailView()
end

function MainScene:onNativeEvent(evt)
	
	if evt.cmd == tt.platformEventHalper.callbackCmds.webpayCallback then
		local params = json.decode(evt.params)
		if not tolua.isnull(self.mWebPayDialog) then
			self.mWebPayDialog:dismiss()
		end
		if params.ret == 1 then
	 		tt.show_msg("支付成功后，商品将会在3分钟之内到账")
	 	elseif params.ret == 3 then
	 		tt.show_msg("订单信息出错!")
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.payCallback then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			tt.nativeData.saveRequestShipData(params)
			tt.show_msg("支付成功,发货中...")
 			local data = params
			local param = {}
			param.apple_receipt = data.receipt
			param.orderid = data.orderid
			tt.ghttp.request(tt.cmd.ios_notify,param)
	 	elseif params.ret == 2 then
	 		-- 支付取消
	 	elseif params.ret == 3 then
	 		-- 支付失敗
		end
	end
end

function MainScene:onSocketData(evt)
	if evt.cmd == "login.shake" then
		if self.hallReconnectView and self.hallReconnectView:isShowing() then
			self.hallReconnectView:dismiss()
		end
		local data = evt.data
		if data.ret == 0 then
			-- 正常登陆
		elseif data.ret == 1 then
			-- 重连
			tt.show_msg("重连房间")
			self:performWithDelay(function()
					app:enterScene("RoomScene",{data.tid,data.level})
				end, 1)
		elseif data.ret == 2 then
			tt.show_msg("登陆服务器失败")
	    	tt.gsocket:disconnect()
		end
	elseif evt.cmd == "room.create" then 
		local data = evt.data
		if data and data.ret == 0 then
			app:enterScene("RoomScene",{data.tid,data.level})
		else
			tt.show_msg("创建房间失败")
		end
	elseif evt.cmd == "room.check" then
		local data = evt.data
		tt.hide_wait_view()
		if data and data.ret == 0 then
			app:enterScene("RoomScene",{data.tid,data.level})
		else
			if not tolua.isnull(self.mJoinRoomDialog) then
				self.mJoinRoomDialog:showError("您输入的房间号不存在,请重新输入")
			end
		end
	elseif evt.cmd == "server.gemUpdate" then
		if evt.data then
			for i,player in ipairs(evt.data.players) do
				if player.uid == tt.owner:getUid() then
  					tt.owner:setGem(player.gem)
					self:updateGem()
				end
			end
		end
	elseif evt.cmd == "php.broadcast" then
		local data = evt.data
		if data then
			if data.msg_type == 10022 then
				local params = json.decode(data.content)
				tt.owner:setGem(tt.owner:getGem() + tonumber(params.zuan) or 0)
				self:updateGem()
				if params.message and params.message ~= "" then
					tt.show_msg(params.message)
				end
			elseif data.msg_type == 10021 then
				self:showHornView(data.content)
			end
		end
	end
end

function MainScene:onHttpResp(evt)
	if evt.cmd == tt.cmd.get_notice then
		if not tolua.isnull(self.mNoticeDialog) then
			self.mNoticeDialog:onLoadData(evt.data)
		end
	elseif evt.cmd == tt.cmd.get_shop then
		if not tolua.isnull(self.mShopDialog) then
			self.mShopDialog:onLoadData(evt.data)
		end
	elseif evt.cmd == tt.cmd.addinvite then
		if evt.data and evt.data.ret == 0 then
			tt.owner:setJoinSn(evt.data.data.join_sn)
		end
		if not tolua.isnull(self.mInviteDialog) then
			if evt.data and evt.data.ret == 0 then
				self.mInviteDialog:onSuccess()
			else
				tt.show_msg("邀请码错误")
				self.mInviteDialog:onFail()
			end
		end
	elseif evt.cmd == tt.cmd.appuserdetail then
		if not tolua.isnull(self.mUserinfoWebViewDialog) then
			if evt.data and evt.data.ret == 0 then
				self.mUserinfoWebViewDialog:loadData(evt.data.data)
			end
		end
	elseif evt.cmd == tt.cmd.order then
		if evt.data and evt.data.ret == 0 then
			local data = evt.data.data
			dump(data)
			local pay_type = tonumber(data.type)
			if pay_type == 1 then
				if data.errno == 0 then
					-- device.openURL(data.pay_info)
					self:showWebPayDialog(data.pay_info)
				else
					tt.show_msg(string.format("下单失败 errstr:%s",data.errstr or ""))
				end
			elseif pay_type == 2 then
					-- device.openURL(data.pay_info)
				self:showWebPayDialog(data.pay_info)

			elseif pay_type == 3 then
				local params = clone(tt.platformEventHalper.cmds.storekit)
				params.args.productID = data.productID
				params.args.pid = ""
				params.args.orderid = data.orderid
				params.args.pmode = pay_type
				dump(params)
				local ret,error = tt.platformEventHalper.callEvent(params)
				if not ret then
					tt.show_msg(error)
					tt.play.play_sound("action_failed")
				end
			end
		else
			tt.show_msg(string.format("下单失败 errstr:%s","http 请求失败"))
		end
	elseif evt.cmd == tt.cmd.ios_notify then
		if evt.data then
			if evt.data.ret == 0 or evt.data.ret == 1 then
				local data = evt.data.data
				tt.nativeData.clearRequestShipData(data.orderid)
			end
		end
	elseif evt.cmd == tt.cmd.lucky_img then
		if evt.data then
			if evt.data.ret == 0 then
				local data = evt.data.data
				self:showAdAnim(evt.data.data)
			end
		end
	end
end

function MainScene:test()
	local CARD_FACE_TWO      = 0x02
	local CARD_FACE_THERR    = 0x03
	local CARD_FACE_FOUR     = 0x04
	local CARD_FACE_FIVE     = 0x05
	local CARD_FACE_SIX      = 0x06
	local CARD_FACE_SEVEN    = 0x07
	local CARD_FACE_EIGHT    = 0x08
	local CARD_FACE_NINE     = 0x09
	local CARD_FACE_TEN      = 0x0A
	local CARD_FACE_JACK 	 = 0x0B
	local CARD_FACE_QUEEN    = 0x0C
	local CARD_FACE_KING     = 0x0D
	local CARD_FACE_ACE      = 0x0E

	local CARD_SUIT_DIAMOND 	= 0x00  --方片
	local CARD_SUIT_CLUB 		= 0x10  --梅花
	local CARD_SUIT_HEART 		= 0x20  --红桃
	local CARD_SUIT_SPADE 		= 0x30  --黑桃


	local SUIT_WAN 		= 0x00   --万
	local SUIT_TONG    	= 0x10   --筒
	local SUIT_TIAO     = 0x20   --条
	local SUIT_FENG     = 0x30   --风
	local SUIT_ZI     	= 0x40   --字

	local Majiang = require("app.ui.Majiang")
	local MajiangGroup = require("app.ui.MajiangGroup")
	local ActionBtnView = require("app.views.ActionBtnView")
	local ControlBoard = require("app.views.ControlBoard")
	-- local cards = {
	-- 	bit.bor(SUIT_WAN,0x01),
	-- 	bit.bor(SUIT_WAN,0x01),
	-- 	bit.bor(SUIT_WAN,0x03),
	-- 	bit.bor(SUIT_TONG,0x01),
	-- 	bit.bor(SUIT_TONG,0x04),
	-- 	bit.bor(SUIT_TONG,0x05),
	-- 	bit.bor(SUIT_TONG,0x06),
	-- 	bit.bor(SUIT_TIAO,0x01),
	-- 	bit.bor(SUIT_TIAO,0x03),
	-- 	bit.bor(SUIT_TIAO,0x03),
	-- 	bit.bor(SUIT_TIAO,0x06),
	-- 	bit.bor(SUIT_TIAO,0x06),
	-- 	bit.bor(SUIT_TIAO,0x07),
	-- 	bit.bor(SUIT_TIAO,0x03),
	-- }
	-- local keys = {}
	-- local hu = {}
	-- for i,card in ipairs(cards) do
	-- 	keys[card] = (keys[card] or 0) + 1
	-- end

	-- local hu = {}

	-- local function getTingTab(i_keys)
	-- 	local bianCount,zhuanCount = 0,0
	-- 	local ting = {}
	-- 	local keys = clone(i_keys)

	-- 	for j=0x00,0x20,0x10 do
	-- 		for i=0x01,0x09,0x01 do
	-- 			local index = bit.bor(i,j)
	-- 			if ControlBoard:checkHu(keys,index,bianCount,zhuanCount) then
	-- 				table.insert(ting,index)
	-- 			end
	-- 		end
	-- 	end

	-- 	for i=0x31,0x34,0x01 do
	-- 		local index = i
	-- 		if ControlBoard:checkHu(keys,index,bianCount,zhuanCount) then
	-- 			table.insert(ting,index)
	-- 		end
	-- 	end

	-- 	for i=0x41,0x43,0x01 do
	-- 		local index = i
	-- 		if ControlBoard:checkHu(keys,index,bianCount,zhuanCount) then
	-- 			table.insert(ting,index)
	-- 		end
	-- 	end
	-- 	return ting
	-- end
	-- local start = os.clock()
	-- print("start",start)
	-- for j=0x00,0x20,0x10 do
	-- 	for i=0x01,0x09,0x01 do
	-- 		local index = bit.bor(i,j)
	-- 		if keys[index] and keys[index] > 0 then
	-- 			keys[index] = keys[index] - 1
	-- 			local tingTab = getTingTab(keys)
	-- 			if #tingTab > 0 then
	-- 				print(string.format("0x%02x",index))
	-- 				hu[index] = tingTab
	-- 				for _,value in ipairs(tingTab) do
	-- 					print("---------",string.format("0x%02x",value))
	-- 				end
	-- 			end
	-- 			keys[index] = keys[index] + 1
	-- 		end
	-- 	end
	-- end

	-- for i=0x31,0x34,0x01 do
	-- 	local index = i
	-- 	if keys[index] and keys[index] > 0 then
	-- 		keys[index] = keys[index] - 1
	-- 		local tingTab = getTingTab(keys)
	-- 		if #tingTab > 0 then
	-- 			print(string.format("0x%02x",index))
	-- 			hu[index] = tingTab
	-- 			for _,value in ipairs(tingTab) do
	-- 				print("---------",string.format("0x%02x",value))
	-- 			end
	-- 		end
	-- 		keys[index] = keys[index] + 1
	-- 	end
	-- end

	-- for i=0x41,0x43,0x01 do
	-- 	local index = i
	-- 	if keys[index] and keys[index] > 0 then
	-- 		keys[index] = keys[index] - 1
	-- 		local tingTab = getTingTab(keys)
	-- 		if #tingTab > 0 then
	-- 			print(string.format("0x%02x",index))
	-- 			hu[index] = tingTab
	-- 			for _,value in ipairs(tingTab) do
	-- 				print("---------",string.format("0x%02x",value))
	-- 			end
	-- 		end
	-- 		keys[index] = keys[index] + 1
	-- 	end
	-- end
	-- print("use time",os.clock()-start)
	-- local actionBtnView = ActionBtnView.new(self,ActionBtnView.BIAN)
	-- actionBtnView:addTo(self)
	-- actionBtnView:setPosition(cc.p(640,320))
	-- actionBtnView:show()
	-- for i=1,4 do
	-- 	for j=1,5 do
	-- 		local index = 1
	-- 		local mMajiangGroup = MajiangGroup.new(index)
	-- 		mMajiangGroup:addTo(self)
	-- 		mMajiangGroup:setGroup(j)
	-- 		for k=1,4 do
	-- 			mMajiangGroup:add(tonumber(string.format("0x%d%d",2,k),16))
	-- 		end
	-- 		mMajiangGroup:resetPosition()
	-- 		if index % 2 == 1 then
	-- 			mMajiangGroup:setPosition(200 + 1 * 110,-100 + j * 140)
	-- 		else
	-- 			mMajiangGroup:setPosition(200 + j * 130,100 + 1 * 120)
	-- 		end
	-- 	end
	-- end
		local posY = 200
		local posX = 120
		for i=1,21 do
			if i % 10 == 0 then
				posY = posY + 200
				posX = 120
			end
			Majiang.new(tonumber(string.format("0x%d%d",1,9),16),i)
				:setPosition(posX,posY)
				:addTo(self)
				:scale(0.5)
			posX = posX + 100
		end
	-- for i=0,2 do
	-- 	for j=1,9 do
	-- 		Majiang.new(tonumber(string.format("0x%d%d",i,9),16),j%5+1)
	-- 			:setPosition(110*j + 150,120*i + 150)
	-- 			:addTo(self)
	-- 			:setTingValue(11)
	-- 	end
	-- end


	-- for j=1,4 do
	-- 	Majiang.new(tonumber(string.format("0x%d%d",3,j),16),j%5+1)
	-- 		:setPosition(110*j + 150,120*3 + 150)
	-- 		:addTo(self)
	-- end


	-- for j=1,3 do
	-- 	Majiang.new(tonumber(string.format("0x%d%d",4,2),16),j%5+1)
	-- 		:setPosition(110*j + 150,120*4 + 150)
	-- 		:addTo(self)
	-- end

	-- local tl = require("app.utils.texaslogic")
	-- local pc = {
	-- 				bit.bor(CARD_SUIT_SPADE,CARD_FACE_THERR),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_NINE),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_EIGHT),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_JACK),
	-- 				bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_THERR),
	-- 			} 
	-- local s1 = {hands = {	
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_FOUR),
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_ACE),
	-- 					}
	-- 			}
	-- local s2 = {hands = {	
	-- 						bit.bor(CARD_SUIT_DIAMOND,CARD_FACE_QUEEN),
	-- 						bit.bor(CARD_SUIT_CLUB,CARD_FACE_ACE),
	-- 					}
	-- 			}
	-- s1.cardtype,s1.bestcards = tl.make_cards(pc,s1.hands)
	-- s2.cardtype,s2.bestcards = tl.make_cards(pc,s2.hands)
	-- local ret = tl.compare_seat_cards(s1, s2)
	-- tt.log.d(TAG,"seat1 cardtype[%s] handcards[%s]", tl.type_str(s1.cardtype),tl.cards_str(s1.bestcards))
	-- tt.log.d(TAG,"seat2 cardtype[%s] handcards[%s]", tl.type_str(s2.cardtype),tl.cards_str(s2.bestcards))
	-- tt.log.d(TAG,"campare ret[%d]",ret)


 --    local net = require("framework.cc.net.init")
 --    tt.log.d(TAG,"getTime ret[%f]",net.SocketTCP.getTime())
	-- local function onEdit(event, editbox)
 --        if event == "began" then
 --            -- 开始输入
 --        elseif event == "changed" then
 --            -- 输入框内容发生变化
 --        elseif event == "ended" then
 --            -- 输入结束
 --        elseif event == "return" then
 --            -- 从输入框返回
 --        end
 --    end
    
    -- local editbox = cc.ui.UIInput.new({
    --     image = "icon/XJC_AnNiu1.png",
    --     listener = onEdit,
    --     size = CCSize(200, 40)
    -- })
    
    -- editbox:pos(display.cx, display.cy)
    -- editbox:addTo(self)
    -- --------
    -- local editbox2 = cc.ui.UIInput.new({
    --     image = "icon/XJC_AnNiu1.png",
    --     listener = onEdit,
    --     size = CCSize(200, 40)
    -- })
    -- --设置密码输入框
    -- editbox2:setInputFlag(0)
    -- editbox2:pos(display.cx, display.cy/2)
    -- editbox2:addTo(self)
    --------------
-- local MatchResultView = require("app.views.MatchResultView")
-- 	MatchResultView.new(self,{
-- 			mlv = 1,          --比赛场次
-- 			match_id = "1_1_1",     --比赛id
-- 			urank = 1,        --比赛最终名次
-- 			total = 100,      --比赛总人数
-- 			money = 1000,     --比赛结束后的金币
-- 			reward = {money=100},  --奖励
-- 		})
--     	:addTo(self)
--     	:show()

	--引入LuaJavaBridge  
	-- local luaj = require "luaj"  
	-- local className="com/lua/java/Test" --包名/类名  
	-- local args = { "hello android", callbackLua }  
	-- local sigs = "(Ljava/lang/String;I)V" --传入string参数，无返回值  
	 
	--     --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
	--     --luaj.callStaticMethod() 会返回两个值  
	--     --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
	--     --当失败时，第一个值为 false，第二个值是错误代码  
	-- local ok,ret = luaj.callStaticMethod(className,"test",args,sigs)  
	-- if not ok then  
	    
	--     item:setString(ok.."error:"..ret)  
	     
	-- end  

	-- require("app.utils.sutils")
	-- local str = "你y好_*瓜神$g瓜瓜哇卡卡"
	-- print("#######################")
	-- print("str len",string.len(str))
	-- print("utf8 len",string.utf8_len(str))
	-- print(string.utf8_sub(str,2,5))
	-- print(string.utf8_sub(str,2,4))
	-- print(string.utf8_sub_width(str,1,10))
	-- print("#######################")
end

return MainScene
