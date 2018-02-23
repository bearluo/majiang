local net = require("framework.cc.net.init")

local BLDialog = class("BLDialog", function()
	return display.newLayer()
end)


function BLDialog:ctor(control)
	self.control_ = control
    self:setNodeEventEnabled(true)
    self:setVisible(false)
    self.isBLDialogShowing = false
    self:setBackEvent(function()
    		self:dismiss()
    		return true
    	end)
end

function BLDialog:show()
	if self.isBLDialogShowing then return end
	self.isBLDialogShowing = true
	self:setVisible(true)
	self.backEventHandler = tt.backEventManager.registerCallBack(handler(self, self.onKeypadListener))
end

function BLDialog:dismiss()
	if not self.isBLDialogShowing then return end
	self.isBLDialogShowing = false
	self:setVisible(false)
	tt.backEventManager.unregisterCallBack(self.backEventHandler)
end

function BLDialog:isShowing()
	return self.isBLDialogShowing
end

function BLDialog:onKeypadListener(event)
	print("BLDialog event.key:",event.key)
	if device.platform == "android" then
		if event.key == "back" and event.type == "Released" then
			return self._backEvent()
		end
	elseif device.platform == "windows" then
		if event.code == 140 and event.type == "Released" then
			return self._backEvent()
		end
	end
end

function BLDialog:setBackEvent(func)
	self._backEvent = func
end

--[Comment]
-- 进入场景时候触发
function BLDialog:onEnter()
end

--[Comment]
-- 退出场景时候触发
function BLDialog:onExit()
	if self.isBLDialogShowing then 
		self:dismiss()
	end
end

--[Comment]
-- 进入场景而且过渡动画结束时候触发
function BLDialog:onEnterTransitionFinish()
end
--[Comment]
-- 退出场景而且开始过渡动画时候触发
function BLDialog:onExitTransitionStart()
end
--[Comment]
-- 场景对象被清除时候触发
function BLDialog:onCleanup()
end

return BLDialog
