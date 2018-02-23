local BLDialog = require("app.ui.BLDialog")
local TAG = "RoomOverApplyDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local RoomOverApplyDialog = class("RoomOverApplyDialog", function()
	return BLDialog.new()
end)


function RoomOverApplyDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("room_over_apply_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	self.mCancelBtn = cc.uiloader:seekNodeByName(node, "cancel_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:actionRoomOverApply(false)
			end)
	self.mConfirmBtn = cc.uiloader:seekNodeByName(node, "confirm_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:actionRoomOverApply(true)
			end)

	self.mTip1Txt =	cc.uiloader:seekNodeByName(node, "tip_1_txt")
	self.mTip2Txt =	cc.uiloader:seekNodeByName(node, "tip_2_txt")
	self.mTip3Txt =	cc.uiloader:seekNodeByName(node, "tip_3_txt")
		

	self.mUserItems = {}
	for i=1,4 do
		self.mUserItems[i] = cc.uiloader:seekNodeByName(node, "user_" .. i)
	end
	self:setBackEvent(function() return true end)
end

function RoomOverApplyDialog:reset(status)
	for i=1,4 do
		if status[i] == 1 then
			self:setUserStatus(i,true)
		else
			cc.uiloader:seekNodeByName(self.mUserItems[i], "status_txt"):setString("等待中")
			-- cc.uiloader:seekNodeByName(self.mUserItems[i], "status_txt"):setTextColor(cc.c3b(146,25,25))
			cc.uiloader:seekNodeByName(self.mUserItems[i], "status_txt"):setColor(cc.c3b(146,25,25))
		end
	end
	self.mTip3Txt:setVisible(false)
	self.mCancelBtn:setVisible(true)
	self.mConfirmBtn:setVisible(true)
	self.mCancelBtn:setTouchEnabled(true)
	self.mConfirmBtn:setTouchEnabled(true)
end

function RoomOverApplyDialog:setUserStatus(seat_id,isAgree)
	if isAgree then
		cc.uiloader:seekNodeByName(self.mUserItems[seat_id], "status_txt"):setString("同意")
	else
		cc.uiloader:seekNodeByName(self.mUserItems[seat_id], "status_txt"):setString("拒绝")
	end
	-- cc.uiloader:seekNodeByName(self.mUserItems[seat_id], "status_txt"):setTextColor(cc.c3b(0,152,14))
	cc.uiloader:seekNodeByName(self.mUserItems[seat_id], "status_txt"):setColor(cc.c3b(0,152,14))
end

function RoomOverApplyDialog:setApplyInfo(player,total_countdown,countdown)
	if not player then
		self.mTip1Txt:setString("玩家申请解散房间,等待其他玩家选择")
	else
		local pinfo  = json.decode(player.pInfo)
		tt.limitStr(self.mTip1Txt,pinfo.name,142)
		self.mTip1Txt:setString( string.format("玩家%s申请解散房间,等待其他玩家选择",self.mTip1Txt:getString()))
	end
	self:startCountdown(total_countdown,countdown)
end

function RoomOverApplyDialog:startCountdown(totaltime,time)
	if time <= 0 then time = 0 end
	self:stopCountdown()
	local update = function()
		local timeStr = ""
		if totaltime >= 60 then
			local second = totaltime % 60
			timeStr = (totaltime-second)/60 .. "分钟"
			if second > 0 then
				timeStr = timeStr .. second .. "秒"
			end
		else
			timeStr = totaltime .. "秒"
		end

		self.mTip2Txt:setString( string.format("(超过%s未作选择,则默认同意) %ds",timeStr,time))
		if time <= 0 then
			self:stopCountdown()
			self:actionRoomOverApply(true)
			return 
		end
		time = time - 1
	end
	update()
	self:schedule(function()
			update()
		end,1):setTag(100)
end

function RoomOverApplyDialog:stopCountdown()
	self:stopActionByTag(100)
end

function RoomOverApplyDialog:actionRoomOverApply(isAgree)
	self.control_:actionRoomOverApply(isAgree)
	self.mCancelBtn:setTouchEnabled(false)
	self.mConfirmBtn:setTouchEnabled(false)
end

function RoomOverApplyDialog:onAgree()
	self.mTip3Txt:setVisible(true)
	self.mCancelBtn:setVisible(false)
	self.mConfirmBtn:setVisible(false)
end

function RoomOverApplyDialog:setUserInfo(seat_id,player)
	if not player then return end
	local view = self.mUserItems[seat_id]
	local pinfo  = json.decode(player.pInfo)
	tt.limitStr(cc.uiloader:seekNodeByName(view,"name_txt"),pinfo.name,98)

	local head_bg = cc.uiloader:seekNodeByName(view,"head_bg")
	head_bg:removeAllChildren()
	print('RoomOverApplyDialog:setUserInfo',pinfo.img_url)
	tt.asynGetHeadIconSprite(string.urldecode(pinfo.img_url or ""),function(sprite)
		if sprite and head_bg then
			local size = head_bg:getContentSize()
			local mask = display.newSprite("dec/settlement_heat.png")
			head_bg:removeAllChildren()
			CircleClip.new(sprite,mask)
				:addTo(head_bg,99)
				:setPosition(cc.p(1,1))
				:setCircleClipContentSize(size.width-2,size.width-2)
		end
	end)
end

function RoomOverApplyDialog:show()
	BLDialog.show(self)
end

function RoomOverApplyDialog:dismiss()
	self:stopCountdown()
	BLDialog.dismiss(self)
end

return RoomOverApplyDialog