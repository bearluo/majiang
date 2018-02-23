local CircleClip = require("app.ui.CircleClip")

local SpeekView = class("SpeekView",function()
    return display.newNode()
end)

function SpeekView:ctor(ctrl)
	self.mCtrl = ctrl
	local node, width, height = cc.uiloader:load("speek_view.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mView1 = cc.uiloader:seekNodeByName(node,"view_1")
	self.mView2 = cc.uiloader:seekNodeByName(node,"view_2")
	self.mView3 = cc.uiloader:seekNodeByName(node,"view_3")

	self.mCountdownTxt = cc.uiloader:seekNodeByName(node,"countdown_txt")
	self.mView1:setVisible(true)
	self.mView2:setVisible(true)
	self.mView3:setVisible(false)
	self.mCountdownTxt:setVisible(false)

	self:setVisible(false)
end

function SpeekView:startCountdown(time)
	if time <= 0 then time = 0 end
	self:stopCountdown()
	local update = function()
		self.mCountdownTxt:setString(time)
		if time<=10 then
			self:showCountdownView()
		end

		if time <= 0 then
			self:stopCountdown()
			if self.mOvertimeEvent then
				self.mOvertimeEvent()
			end
			return 
		end
		time = time - 1
	end
	update()
	self:schedule(function()
			update()
		end,1):setTag(100)
end

function SpeekView:stopCountdown()
	self:stopActionByTag(100)
end

function SpeekView:startSpeek(time)
	self:setVisible(true)
	self:startCountdown(time)
    tt.voiceRecord.startRecord()
end

function SpeekView:stopSpeek()
	self:stopCountdown()
	self:setVisible(false)
	self.mView1:setVisible(true)
	self.mView2:setVisible(true)
	self.mView3:setVisible(false)
	self.mCountdownTxt:setVisible(false)
	tt.voiceRecord.stopRecord()
end

function SpeekView:showCountdownView()
	self.mView1:setVisible(false)
	self.mView2:setVisible(false)
	self.mView3:setVisible(true)
	self.mCountdownTxt:setVisible(true)
end

function SpeekView:setOvertimeEvent(func)
	self.mOvertimeEvent = func
end

return SpeekView

