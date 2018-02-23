require("config")
require("cocos.init")
require("framework.init")

local PokerApp = class("PokerApp", cc.mvc.AppBase)

function PokerApp:ctor()
    PokerApp.super.ctor(self)
end

function PokerApp:run()
    cc.Director:getInstance():setProjection(0)  --2D投射
    local writePath = cc.FileUtils:getInstance():getWritablePath() 
	cc.FileUtils:getInstance():addSearchPath(writePath .. "hotupdate/res/")
	cc.FileUtils:getInstance():addSearchPath("res/")
	require("app.mjlib.helper"):test()
	if tt then
		tt.clearAll()
	end
	if device.model == "iphone" and jit.arch == "arm64" then
		cc.LuaLoadChunksFromZIP("game64.zip")
	else
		cc.LuaLoadChunksFromZIP("game.zip")
	end
	require("app.init")
	cc.FileUtils:getInstance():purgeCachedEntries()
	display.DEFAULT_TTF_FONT        = "woyao"
	if device.platform == "android" or device.platform == "windows" then
    	self:enterScene("SplashScene")
	else
    	self:enterScene("LoginScene")
	end
end

function PokerApp:onEnterBackground()
	print("PokerApp:onEnterBackground")
	PokerApp.super.onEnterBackground(self)
	-- tt.play.pause_music()
	-- tt.play.set_sounds_vol(0)
end

function PokerApp:onEnterForeground()
	print("PokerApp:onEnterForeground")
	PokerApp.super.onEnterForeground(self)
	-- tt.play.resume_music()
	-- tt.play.set_sounds_vol(1)
end

return PokerApp
	