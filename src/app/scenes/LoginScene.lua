


local net = require("framework.cc.net.init")

local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

function LoginScene:ctor(isLogout)
	self:initView()
	printInfo("isLogout" .. (isLogout == true and 1 or 2) .. " " .. type(isLogout))
	self.isLogout = isLogout == true
	if self.isLogout then
		tt.statisticsHalper.onProfileSignOff()
	end
	self.mInitConfig = false
	self.mInitDownloadUrl = false
end

function LoginScene:initView() 
	local node, width, height = cc.uiloader:load("login_scene.json")
	node:align(display.CENTER,display.cx,display.cy)
	self:addChild(node)
	self.root_ = node

    local size = cc.size(130,40)
    local x,y = 640,600
	self.nickEdit_ = cc.ui.UIInput.new({
        image = "btn/btn_touming.png",
        UIInputType = 1,
        size = cc.size(200,200),
        x = x,
        y = y,
    })
    self.nickEdit_:setMaxLength(12)
    self.nickEdit_:setFontColor(cc.c3b(0xD4, 0xD4, 0xD4))
    self.nickEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.nickEdit_:addTo(self)
    self.nickEdit_:setText("1")

    self.mYoukeLogin = cc.ui.UIPushButton.new({
    		normal = 'btn/logon_youkedenglu_up.png',
    		pressed = 'btn/logon_youkedenglu_down.png',
    		disabled = 'btn/logon_youkedenglu_down.png',
    	}):onButtonClicked(function()
			tt.play.play_sound("click")
			tt.owner.uid_ = tonumber(self.nickEdit_:getText()) or 1
			tt.nativeData.saveLoginData(2,tt.owner.uid_)
			self.isLogout = false
			self:checkConfig()
		end)
    self.mYoukeLogin:addTo(self)
    self.mYoukeLogin:setPosition(cc.p(640,100))

	if GAME_MODE_DEBUG then

	else
		self.nickEdit_:setVisible(false)
		self.mYoukeLogin:setVisible(false)
	end

	self.wxLoginBtn = cc.uiloader:seekNodeByName(node, "wx_login_btn")
		:onButtonClicked(function()
			tt.play.play_sound("click")
			tt.owner.uid_ = tonumber(self.nickEdit_:getText()) or 1
			
			if device.platform == "windows" or device.platform == "mac" then
				tt.nativeData.saveLoginData(2,tt.owner.uid_)
				self.isLogout = false
				self:checkConfig()
			else
				-- self:loginYouke(tt.owner.uid_)
				local openConfig = tt.nativeData.getOpenConfig()
				if tonumber(openConfig.open_login) == 1 and tonumber(openConfig.check_status) == 0 then
					self:onLoginWx()
				else
					tt.nativeData.saveLoginData(2,tt.getOpenUDID())
					self.isLogout = false
					self:checkConfig()
				end
			end
			-- tt.ghttp.request(tt.cmd.login_wx,...)
			-- tt.gsocket:connect("47.92.136.52","9999");
		end)
	 	-- :setVisible(false)
	-- self.youkeBtn = cc.uiloader:seekNodeByName(node, "youke_btn")
	-- 	:onButtonClicked(function()
	-- 		tt.play.play_sound("click")
	-- 		tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.youkeBtn)
	-- 		self:onLoginYouke()
	-- 	end)
	-- 	:setVisible(false)

	-- -- self.fb_login_bg = cc.uiloader:seekNodeByName(node, "fb_login_bg")
	-- -- self.fb_login_bg:setVisible(false)
	-- self.fb_tips_handler = cc.uiloader:seekNodeByName(node, "fb_tips_handler")
	-- self.fb_tips_handler:setVisible(false)

	self.loading_bg = cc.uiloader:seekNodeByName(node, "loading_bg")
	self.loading_bg:setVisible(false)
	local size = self.loading_bg:getContentSize()
	self.progress = cc.ProgressTimer:create(cc.Sprite:create("dec/loading_tiao.png"))
	    :setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    :setMidpoint(cc.p(0,0))
	    :setBarChangeRate(cc.p(1, 0))
	    :setPosition(size.width/2-4,size.height/2+2)
    	:addTo(self.loading_bg,1)
	self.loading_txt = cc.uiloader:seekNodeByName(node, "loading_txt")
	self.loading_txt:setVisible(false)

	cc.uiloader:seekNodeByName(node, "version_txt"):setString("版本号:"..kVersion)

	-- local label = display.newTTFLabel({
 --        text = 'v' .. kVersion,
 --        size = 20,
 --        x = 800,
 --        y = 35,
 --        color=cc.c3b(0xcb,0xcb,0xcb),
 --    }):addTo(self.root_)

	-- local label = display.newTTFLabel({
 --        text = '問題反饋：gm@woyaoent.com',
 --        size = 20,
 --        x = 600,
 --        y = 35,
 --        color=cc.c3b(0xcb,0xcb,0xcb),
 --    }):addTo(self.root_)

 	self:refreshView()
end

function LoginScene:onEnter()
	print("LoginScene:onEnter")
	self.gevt_handlers_ = {
		tt.gevt:addEventListener(tt.gevt.SOCKET_DATA, handler(self, self.onSocketData)),
		tt.gevt:addEventListener(tt.gevt.NATIVE_EVENT, handler(self, self.onNativeEvent)),

		tt.gevt:addEventListener(tt.gevt.EVT_HTTP_RESP, handler(self, self.onHttpResp)),
		-- tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECTING, handler(self, self.onNativeEvent))
		tt.gevt:addEventListener(tt.gevt.EVENT_RECONNECT_FAILURE, handler(self, self.reconnectServerFail)),
	}
	tt.log.d(TAG,"LoginScene gsocket isConnected %s",tt.gsocket:isConnected())
	
	if tt.gsocket:isConnected() then
		tt.gsocket:disconnect()
	end
	-- dump(tt.game_data)

	if not self.isLogout then
		self:checkVersion()
        -- self:hide_wait_view()
	else
		self:hide_wait_view()
	end
	tt.play.play_music("BGM")
	tt.backEventManager.addBackEventLayer(self)
	self.callbackHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))
					-- app:enterScene("RoomScene",{true})
					-- self:loginWx("open_id", "access_token")
end

function LoginScene:onKeypadListener(event)
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

function LoginScene:showQuitDialog()
	self:showChooseDialog("是否退出游戏", nil, function()
			os.exit()
		end)
end

function LoginScene:checkOpen()
	local params = {}
	tt.ghttp.request(tt.cmd.checkopen,params)
	self:show_wait_view("检查版本数据中...",10,0)
end

function LoginScene:autoLogin()
	dump(tt.game_data)
	if not self.isLogout and tt.game_data.preLoginType and tt.game_data.preLoginParams then
		if tt.game_data.preLoginType == 1 then
			local params = tt.platformEventHalper.cmds.autoLoginWx
			params.args = {
				refresh_token=tt.game_data.preLoginParams.refresh_token,
				transaction = os.time().."",
			}
			local ret,error = tt.platformEventHalper.callEvent(params)
			if not ret then
				tt.show_msg(error)
				self:hide_wait_view()
			else
				self:show_wait_view("微信登录中...",60,30)
			end
		elseif tt.game_data.preLoginType == 2 then
			self:loginYouke(tt.game_data.preLoginParams)
		else
			self:hide_wait_view()
		end
	else
		self:hide_wait_view()
	end
end

function LoginScene:checkConfig()
	if not self.mInitConfig then
		local params = {}
		tt.ghttp.request(tt.cmd.get_config,params)
		self:show_wait_view("检查配置文件中...",30,20)
	end
	if not self.mInitDownloadUrl then
		local params = {}
		tt.ghttp.request(tt.cmd.downloadUrl,params)
		self:show_wait_view("检查配置文件中...",30,20)
	end
	if self:isCanLogin() then
		self:autoLogin()
	end
end

function LoginScene:isCanLogin()
	return self.mInitDownloadUrl and self.mInitConfig
end

function LoginScene:refreshView()
	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_login) == 1 and tonumber(openConfig.check_status) == 0 then
	    self.wxLoginBtn:setButtonImage("normal", "btn/logon_weixindenglu.png", true)
	    self.wxLoginBtn:setButtonImage("pressed", "btn/logon_weixindenglu_anxia.png", true)
	    self.wxLoginBtn:setButtonImage("disabled", "btn/logon_weixindenglu_anxia.png", true)
	else
	    self.wxLoginBtn:setButtonImage("normal", "btn/logon_youkedenglu_up.png", true)
	    self.wxLoginBtn:setButtonImage("pressed", "btn/logon_youkedenglu_down.png", true)
	    self.wxLoginBtn:setButtonImage("disabled", "btn/logon_youkedenglu_down.png", true)
	end
end

function LoginScene:checkVersion()
	-- self:checkConfig()
	-- tt.update_checkver({
	-- 		chan = kChan,
 --    		ver = kVersion,    --版本号
	-- 	})
	local params = {}
	tt.ghttp.request(tt.cmd.checkupdate,params)
	self:show_wait_view("版本检测中...",10,0)
end

function LoginScene:reconnectServerFail()
	tt.show_msg("游戏服务器连接失败")
	self:hide_wait_view()
end


function LoginScene:onLoginWx()
	local params = tt.platformEventHalper.cmds.loginWx
	self.mState = os.time() .. ""
	params.args = {
		state = self.mState,
	}
	local ret,error = tt.platformEventHalper.callEvent(params)
	if not ret then
		tt.show_msg(error)
	else
		self:show_wait_view("微信授权...",10,0)
		self:performWithDelay(function()
		 		tt.show_msg("授权超时")
				self:hide_wait_view()
			end, 5):setTag(100)
	end
end

function LoginScene:onSocketData(evt)
	dump(evt)
	if evt.cmd == "login.shake" then
		local data = evt.data
		if data.ret == 0 then
			-- 正常登陆
			self:show_wait_view("连接服务器中...",100,80)
			self:performWithDelay(function()
					app:enterScene("MainScene",{true})
				end, 1)
		elseif data.ret == 1 then
			-- 重连
			self:show_wait_view("连接服务器中...",100,80)
			self:performWithDelay(function()
					app:enterScene("MainScene",{true,{tid=data.tid,level=data.level}})
				end, 1)
		elseif data.ret == 2 then
			tt.show_msg("登陆服务器失败")
			self:hide_wait_view()
		end
	end
end

function LoginScene:loginWx(open_id,access_token)
	printInfo("LoginScene:loginWx %s",open_id,access_token)
	local params = {}
	params.open_id = open_id
	params.access_token = access_token
	tt.ghttp.request(tt.cmd.login_wx,params)
	-- self:show_wait_view("微信登陆中...",60,30)
end

function LoginScene:loginYouke(open_id)
	printInfo("LoginScene:loginYouke %s",open_id)
	local params = {}
	params.open_id = open_id
	params.access_token = "youke" .. os.time()
	tt.ghttp.request(tt.cmd.login_you,params)
	self:show_wait_view("游客登陆中...",60,30)
end

function LoginScene:onNativeEvent(evt)
	printInfo("LoginScene:onNativeEvent cmd %s params %s", evt.cmd,evt.params)
	if evt.cmd == tt.platformEventHalper.callbackCmds.wxLogin then
		local params = json.decode(evt.params)
		print("wxLogin",params.state,self.mState)
		-- if params.state ~= self.mState then return end
		self:stopActionByTag(100)
		if params.ret == 1 then
			local data = json.decode(params.data)
			dump(data,"wxLogin")
			if data.errcode then
				if data.errcode == 40030 then
		 			tt.show_msg( string.format("微信授权过期"))
				else
		 			tt.show_msg( string.format("登陆失败! errcode:%d errmsg:%s",data.errcode or 0,data.errmsg or ""))
				end 
				self:hide_wait_view()
			else
				-- tt.login_fb(params)
				-- self:loginWx(data.openid,data.access_token)
				-- self:show_wait_view("微信登陆中...",60,30)
				tt.nativeData.saveLoginData(1,data)
				self.isLogout = false
				self:checkConfig()
			end
	 	elseif params.ret == 2 then
	 		tt.show_msg("取消授权")
			self:hide_wait_view()
	 	elseif params.ret == 3 then
	 		tt.show_msg("登陆失败! error:" .. (params.error or ""))
			self:hide_wait_view()
		end
	elseif evt.cmd == tt.platformEventHalper.callbackCmds.wxAutoLogin then
		local params = json.decode(evt.params)
		if params.ret == 1 then
			local data = json.decode(params.data)
			dump(data,"wxAutoLogin")
			if data.errcode then
				if data.errcode == 40030 then
		 			tt.show_msg( string.format("微信授权过期"))
				else
		 			tt.show_msg( string.format("登陆失败! errcode:%d errmsg:%s",data.errcode or 0,data.errmsg or ""))
		 		end
				self:hide_wait_view()
			else
				self:loginWx(data.openid,data.access_token)
				-- self:show_wait_view("微信登陆中...",60,30)
				-- tt.nativeData.saveLoginData(1,data)
				-- self.isLogout = false
				-- self:checkConfig()
			end
	 	elseif params.ret == 3 then
	 		tt.show_msg("登陆失败! error:" .. (params.error or ""))
			self:hide_wait_view()
		end
	end
end

function LoginScene:onHttpResp(evt)
	if evt.cmd == tt.cmd.login_wx then
		if evt.data then
	        local data = evt.data
	        local is_freeze = tonumber(data.is_freeze)

            if tonumber(data.is_maintain) == 1 then
				self:hide_wait_view()
	        elseif is_freeze == 1 then
	           	self:show_wait_view("连接服务器中...",80,60)
	        else
				self:hide_wait_view()
	        end
	    else
			self:hide_wait_view()
	    end
	elseif evt.cmd == tt.cmd.login_you then
		dump(evt.data)
		if evt.data then
	        local data = evt.data
	        local is_freeze = tonumber(data.is_freeze)
	        if tonumber(data.is_maintain) == 1 then
				self:hide_wait_view()
	        elseif is_freeze == 1 then
	           	self:show_wait_view("连接服务器中...",80,60)
	        else
				self:hide_wait_view()
	        end
	    else
			self:hide_wait_view()
	    end
	elseif evt.cmd == tt.cmd.get_config then
		if evt.data then
			local data = evt.data
			if data.ret == 0 then
				local config = data.data
				tt.nativeData.saveGameConfig(config)
				self.mInitConfig = true
				if self:isCanLogin() then
					self:autoLogin()
				end
			else
 				tt.show_msg("游戏配置拉取失败")
				self:hide_wait_view()
			end
		else
			tt.show_msg("游戏配置拉取失败")
			self:hide_wait_view()
		end
	elseif evt.cmd == tt.cmd.downloadUrl then
		if evt.data then
			local data = evt.data
			if data.ret == 0 then
				local config = data.data
				tt.nativeData.saveGameDownloadUrlConfig(config)
				self.mInitDownloadUrl = true
				if self:isCanLogin() then
					self:autoLogin()
				end
			else
				tt.show_msg("游戏配置拉取失败")
				self:hide_wait_view()
			end
		else
			tt.show_msg("游戏配置拉取失败")
			self:hide_wait_view()
		end
	elseif evt.cmd == tt.cmd.checkopen then
		if evt.data then
			local data = evt.data
			dump(data)
			if data.ret == 0 then
				tt.nativeData.saveOpenConfig(data.data)
				self:refreshView()
				if tonumber(data.data.open_login) == 1 then
					self:checkConfig()
					-- self:hide_wait_view()
				else
					self:hide_wait_view()
				end
			else
				local view = self:showChooseDialog("版本数据检测失败,稍后再试!",nil,function()
						self:checkOpen()
					end)
				view:setMode(2)
				view:setBackEvent(function() return true end)
			end
		else
			local view = self:showChooseDialog("版本数据检测失败,稍后再试!",nil,function()
					self:checkOpen()
				end)
			view:setMode(2)
			view:setBackEvent(function() return true end)
		end
	elseif evt.cmd == tt.cmd.checkupdate then 
		if evt.data then
			local data = evt.data
			dump(data)
			if data.ret == 0 then
				if tonumber(data.data.type) == 1 then
					local view = self:showChooseDialog( string.format("版本:%s\n%s",data.data.version or "nil",data.data.info or "版本更新") ,function()
								-- self:addhotupdate()
								self:checkOpen()
							end,function()
							device.openURL(data.data.url)
							return true
						end)
					view:setBackEvent(function() return true end)
				elseif tonumber(data.data.type) == 2 then
					local view = self:showChooseDialog( string.format("版本:%s\n%s",data.data.version or "nil",data.data.info or "版本更新") ,nil,function()
							device.openURL(data.data.url)
							return true
						end)
					view:setMode(2)
					view:setBackEvent(function() return true end)
				else
					-- self:addhotupdate()
					self:checkOpen()
				end
			else
				local view = self:showChooseDialog("版本检测失败,稍后再试!",nil,function()
						self:checkVersion()
					end)
				view:setMode(2)
				view:setBackEvent(function() return true end)
			end
		else
			local view = self:showChooseDialog("版本检测失败,稍后再试!",nil,function()
					self:checkVersion()
				end)
			view:setMode(2)
			view:setBackEvent(function() return true end)
		end
	end
end

function LoginScene:showChooseDialog(str,cancelClick,confirmClick)
	local view = app:createView("ChooseDialog")
		:addTo(self.root_)
		:setContentStr(str)
		:setOnCancelClick(cancelClick)
		:setOnConfirmClick(confirmClick)
	view:show()
	return view
end

function LoginScene:show_wait_view(str,per,startPer)
	print("LoginScene:show_wait_view",str,per,startPer)
	self.loading_bg:setVisible(true)
	self.loading_txt:setVisible(true)
	self.loading_txt:setString(str)


	startPer = startPer or self.progress:getPercentage()
	if startPer > per then per = startPer end
	local action  = cc.ProgressFromTo:create(1, startPer,per)
	action:setTag(1)
	self.progress:stopActionByTag(1)
	self.progress:runAction(action)

	self.wxLoginBtn:setVisible(false)
end

function LoginScene:hide_wait_view()
	print("LoginScene:hide_wait_view")
	self.wxLoginBtn:setVisible(true)
	self.loading_bg:setVisible(false)
	self.loading_txt:setVisible(false)
	self.progress:stopActionByTag(1)
	self.progress:setPercentage(0)
end

function LoginScene:addhotupdate()
	local writablepath = cc.FileUtils:getInstance():getWritablePath()
    local storagepath = writablepath .. "hotupdate/"
	
	--[[
	参数1是读取文件地址。
	参数2是下载的资源储存到哪。
	如果要将 project.manifest 放到 res/version 下的话，
	必须设置优先路径 res/version，否则 project.manifest 只能放在res目录下
	]]

    local am = cc.AssetsManagerEx:create("project.manifest",storagepath)
    am:retain()
	self.am = am 
	self.failedcount = 0
    --获得当前本地版本
    local localManifest = am:getLocalManifest()
    if localManifest:getVersion() ~= kVersion then
    	tt.show_msg( string.format("Manifest version %s is != kVersion %s",localManifest:getVersion(),kVersion))
    end
    print(localManifest:getVersion())
	print("getPackageUrl",localManifest:getPackageUrl())
	print("getManifestFileUrl",localManifest:getManifestFileUrl())
	print("getVersionFileUrl",localManifest:getVersionFileUrl())

    if not am:getLocalManifest():isLoaded() then 
        print("加载本地project.manifest错误.")
        --进登录界面
		-- self:checkOpen()
    else 
        local listener = cc.EventListenerAssetsManagerEx:create(am,function(event)
            self:onUpdateEvent(event)
        end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener,1)
        am:update()
       	self:show_wait_view("检测资源文件中...",60,0)
    end
end

function LoginScene:onUpdateEvent(event)
    local eventCode = event:getEventCode()

	local assetId = event:getAssetId()
    local percent = event:getPercent()
    local percentByFile = event:getPercentByFile()
    local message = event:getMessage()
    printInfo("游戏更新("..eventCode.."):"..", assetId->"..assetId..", percent->"..percent..", percentByFile->"..percentByFile..", message->"..message)
    if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
        print("找不到本地manifest文件.")
		self._perent = 100
		self:checkOpen()
        --进登录界面 
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
		-- self:show_wait_view("正在更新文件 : " .. assetId,event:getPercentByFile())
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
        print("正在更新文件 : ",event:getAssetId())
        --print("更新进度 : ",event:getPercent())
        if event:getAssetId() == cc.AssetsManagerExStatic.VERSION_ID then 
       		self:show_wait_view("检测文件版本中...",event:getPercent(),0)
            --print("文件版本 : ",event:getPercent())
        elseif event:getAssetId() == cc.AssetsManagerExStatic.MANIFEST_ID then
       		self:show_wait_view("检测文件Manifest中...",event:getPercent(),0)
            --print("文件Manifest : ",event:getPercent())
        else 
			self:show_wait_view( string.format("正在更新资源包(%.0f%%)",event:getPercentByFile()),event:getPercentByFile())
            --print("进度条的进度 : ",event:getPercent())
            --跳进度
			self._perent = event:getPercentByFile()
        end
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
        	eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
        print("远程资源清单文件下载失败")
		self._perent = 100
		self:updateFail()
        --print("资源清单文件解析失败 ")
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then 
		print("已经是服务器最新版本ALREADY_UP_TO_DATE")
		self._perent = 100
		self:checkOpen()
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
        print("更新到服务器最新版本UPDATE_FINISHED")
		self._perent = 100
		tt.clearAll()
		app:run()
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
        print("更新过程中遇到错误")
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND  then
        print("发现新版本，开始升级",self.am:getRemoteManifest():getVersion())
        self:show_wait_view("发现新版本，开始升级",0,0)
    elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED  then
		print("更新失败")
		if self.failedcount > 10 then 
			self._perent = 100
			self:updateFail()
		else 
			self.failedcount = self.failedcount + 1 --如果有的文件更新失败,连续更新10次,超过十次还是进游戏
			self.am:downloadFailedAssets() 
		end
    end 
end

function LoginScene:updateFail(str)
	local view = self:showChooseDialog( str or "更新失败,请重试" ,nil,function()
			self:addhotupdate()
			return true
		end)
	view:setMode(2)
	view:setBackEvent(function() return true end)
end

function LoginScene:onExit()
	print("LoginScene:onExit")
	for _, v in pairs(self.gevt_handlers_ ) do 
		tt.gevt:removeEventListener(v)
	end 
	tt.backEventManager.unregisterCallBack(self.callbackHandler)
end

return LoginScene
