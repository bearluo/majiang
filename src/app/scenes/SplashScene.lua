

local net = require("framework.cc.net.init")

local SplashScene = class("SplashScene", function()
    return display.newScene("SplashScene")
end)

function SplashScene:ctor()
	self:initView()
end

function SplashScene:initView() 
	local node, width, height = cc.uiloader:load("splash_scene.json")
	node:align(display.CENTER,display.cx,display.cy)
	self:addChild(node)
	self.root_ = node
end

function SplashScene:onEnter()
	self:performWithDelay(function()
    		app:enterScene("LoginScene")
		end, 3)
end

return SplashScene
