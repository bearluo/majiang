local IMHelper = require("app.libs.IMHelper")

local RoomControl = class("RoomControl", function()
    return display.newNode()
end)
local top = 1
local left = 2
local bottom = 3
local right = 4

local GAME_STATUS_STOP = 0 -- 游戏停止状态
local GAME_STATUS_PLAYING = 1 -- 游戏进行状态
local GAME_STATUS_WAIT_OPERATE = 2 -- 等待用户操作状态
local GAME_STATUS_WAIT_STOP = 3 -- 游戏准备停止状态


function RoomControl:ctor(scene)
	self.mScene = scene
	self.mIsRoomCtrl = false
 	self.mTableStatus = 0
 	self.isSelfOutAction = false
 	self.mCtrlSeatId = -1
 	self.mIsGameOver = false
 	self.mQuanNum = 0
 	self.mJuNum = 0
 	self.mApplyStatus = {}
 	self.mRecordeds = {} -- 语音消息记录
 	self.mRecords = {} -- 战绩记录
 	self.mRecordCmdCache = {}
 	self.mRecordsPageMaxNum = 0
 	self.mMaxJuNum = 0
end

function RoomControl:loginRoom(tid,level)
	print("RoomControl:loginRoom")
	local params = {}
	params.uid = tt.owner:getUid()
	params.tid = tid
	params.pInfo = tt.owner:getClientInfo()
	dump(params)
	tt.gsocket.request("room.login",params)
end

function RoomControl:onLogin(data)
	dump(data, 6, "RoomControl:onLogin")
	self.mTid = data.tid
	self.mLevel = data.level
	self.mIndex = data.index
	self.mTableStatus = data.table_status
	self.mMajiangNum = data.majiang_num
	self.mIsRoomCtrl = data.room_ctrl_uid == tt.owner:getUid()
	self.mCostNum = data.cost_num
	self.mPayType = data.pay_type
	self.mBalanceType = data.balance_type
	self.mFen = data.fen
	self.mBaseScore = data.base_score
	self.mMaxJuNum = data.max_ju + 1
	self.mMaxQuan = data.max_quan
	self:setCurQuanJu(data.quan_num,data.ju_num)
	self.mActionTime = data.action_time or 10
	self.mScene:setRuleTxt(self.mLevel,self.mMaxQuan,self.mPayType,self.mBalanceType,self.mFen,self.mBaseScore)
	self.mRecordCmdCache = {}

	self.mScene:setRoomIndex(self.mIndex)

	for i=1,4 do
		self.mScene:dismissTiRenBtn(i)
		self:clearSeatInfo(i)
		self.mScene:dismissPlayerReadyIcon(i)
	end

	local play = data.play
	self:setCtrlSeat(play.seat_id)
	self:setSeatInfo(self:s2c(play.seat_id),play)
	self.mScene:setSeatScore(self:s2c(play.seat_id),play.sum_score)

	for _,play in ipairs(data.other_play) do
		self:setSeatInfo(self:s2c(play.seat_id),play)
		self.mScene:setSeatScore(self:s2c(play.seat_id),play.sum_score)
		self.mScene:setOffline(self:s2c(play.seat_id),play.offline == 0)
	end

	self.mFirstCard = true
	self.mScene:dismissRoomOverApply()


	if self:isRunning() then
		self:setDealer(self:s2c(data.dealer))
		self.mScene:showRunningView()
		self.mScene:showTuiChuBtn(false)
		-- tt.voiceRecord.loginGCloudVoice(string.format("level%dtid%dseat%d",self.mLevel,self.mTid,self:c2s(self.mCtrlSeatId)))
		tt.voiceRecord.loginGCloudVoice("woyao")
		self:setSeatCard(self:s2c(play.seat_id),play.hand_cards,play.peng_cards,play.gang_cards,play.zhuan_cards,play.bian_cards,play.discard_cards)
		self.mApplyStatus[self:s2c(play.seat_id)] = play.apply_status


		self.mFirstCard = self.mFirstCard and #play.peng_cards == 0 and #play.gang_cards == 0 and #play.zhuan_cards == 0 and #play.bian_cards == 0 and #play.discard_cards == 0
		for _,play in ipairs(data.other_play) do
			self:setSeatCard(self:s2c(play.seat_id),play.hand_num,play.peng_cards,play.gang_cards,play.zhuan_cards,play.bian_cards,play.discard_cards)
			self.mApplyStatus[self:s2c(play.seat_id)] = play.apply_status
			self.mFirstCard = self.mFirstCard and #play.peng_cards == 0 and #play.gang_cards == 0 and #play.zhuan_cards == 0 and #play.bian_cards == 0 and #play.discard_cards == 0
		end
		if data.last_card == 0 then
			self:countDownStart(self:s2c(data.cur_action_seat_id),self.mActionTime)
		else
			self:countDownStart(self:s2c(data.last_seat_id),self.mActionTime)
		end
		self.mScene:dismissActionBtnViews()
		self.mScene:dismissMulAction()
		self.mScene:setCardsNum(self.mMajiangNum)

		if play.apply_status ~= 0 then
			local params = {}
			params.uid = tt.owner:getUid()
			params.apply_type = 0
			params.total_countdown = play.apply_time
			params.countdown = play.apply_coundtime
			self.mScene:showRoomOverApply(params,self.mApplyStatus)
			self.mApplyStatus = {}
		end
	else
		self.mDealer = self:s2c(data.dealer)
		if self:isNotGameStart() then
			self.mScene:showReadyView()
		else
			self.mScene:showRunningView()
		end

		if not self.mIsRoomCtrl and self:isNotGameStart() then
			self.mScene:showTuiChuBtn(true)
		end
-- .tuichu
		if play.user_status == 0 then
			self.mScene:showReadyBtn()
			self.mScene:dismissPlayerReadyIcon(self:s2c(play.seat_id))
		else
			self.mScene:dismissReadyBtn()
			self.mScene:showPlayerReadyIcon(self:s2c(play.seat_id))
		end
		for _,play in ipairs(data.other_play) do
			local seat_id = self:s2c(play.seat_id)
			if play.user_status == 0 then
				self.mScene:dismissPlayerReadyIcon(seat_id)
			else
				self.mScene:showPlayerReadyIcon(seat_id)
			end
			if self.mIsRoomCtrl and self:isNotGameStart() then
				self.mScene:showTiRenBtn(seat_id)
			end
		end

		self.mFirstCard = false
		self.mScene:dismissActionBtnViews()
		self.mScene:dismissMulAction()
		-- tt.voiceRecord.loginGCloudVoice(string.format("level%dtid%dseat%d",self.mLevel,self.mTid,self:c2s(self.mCtrlSeatId)))
		tt.voiceRecord.loginGCloudVoice("woyao")
		for i=1,4 do
			self.mApplyStatus[i] = 0
		end
	end

end

function RoomControl:logout()
	if not self.mIsGameOver then
		if self.mTableStatus ~= 0 then
			local params = {}
			params.uid = tt.owner:getUid()
			params.action = 0
			tt.gsocket.request("room.roomOverApply",params)
		elseif self.mIsRoomCtrl then
			self.mScene:showChooseDialog("解散房间不扣钻石，是否解散？",nil,function()
					local params = {}
					params.uid = tt.owner:getUid()
					params.action = 0
					tt.gsocket.request("room.roomOverApply",params)
				end)
		else
			self.mScene:showChooseDialog("退出房间不扣钻石，是否退出？",nil,function()
					local params = {}
					params.uid = tt.owner:getUid()
					tt.gsocket.request("room.logout",params)
				end)
		end
	else
		app:enterScene("MainScene")
	end
end

function RoomControl:onRoomOverApply(data)
	self.mApplyStatus[self:getSeatIdByUid(data.uid)] = 1
	self.mScene:showRoomOverApply(data,self.mApplyStatus)
	self.mApplyStatus = {}
end

function RoomControl:onUserRoomOverApply(data)
	self.mScene:userActionRoomOverApply(data.uid,data.apply_type)
end

function RoomControl:actionRoomOverApply(isAgree)
	local params = {}
	params.uid = tt.owner:getUid()
	params.action = isAgree == true and 1 or 2
	tt.gsocket.request("room.roomOverApply",params)
end

function RoomControl:ready()
	if self:isRunning() then return end
	local params = {}
	params.uid = tt.owner:getUid()
	tt.gsocket.request("room.ready",params)
	self.mScene:clearBorad()
end

function RoomControl:onUserReady(data)
	local seat_id = self.mScene:getSeatIdByUid(data.uid)
	self.mScene:showPlayerReadyIcon(seat_id)
end

function RoomControl:isRunning()
	return self.mTableStatus == GAME_STATUS_PLAYING or self.mTableStatus == GAME_STATUS_WAIT_OPERATE
end

function RoomControl:isNotGameStart()
	return self.mTableStatus == GAME_STATUS_STOP
end

function RoomControl:isGameOver()
	return self.mIsGameOver
end

function RoomControl:getRoomIndex()
	return self.mIndex
end

function RoomControl:tiRenAction(seat_id)
	local playerInfo = self.mScene:getPlayerInfoBySeatId(seat_id)
	if playerInfo then
		local params = {}
		params.uid = tt.owner:getUid()
		params.target_uid = playerInfo.uid
		tt.gsocket.request("room.tiRen",params)
	end
end

function RoomControl:onTiRenBroadcast(data)
	dump(data)
	if data.target_uid == tt.owner:getUid() then
		self.mIsGameOver = true
		tt.show_msg("您被房主踢出房间了")
		self:performWithDelay(function()
					app:enterScene("MainScene")
				end, 1)
	else
		local playerInfo = self.mScene:getPlayerInfoByUid(data.target_uid)
		if playerInfo then
			tt.show_msg(string.format("用户%s被房主踢出房间",playerInfo.name))
		else
			tt.show_msg(string.format("用户ID:%d被房主踢出房间",data.target_uid))
		end
	end
end

function RoomControl:onUserJoin(play)
	local seat_id = self:s2c(play.seat_id)
	self:setSeatInfo(seat_id,play)
	if self.mIsRoomCtrl and self:isNotGameStart() then
		self.mScene:showTiRenBtn(seat_id)
	end
end

function RoomControl:onUserLeave(play)
	local seat_id = self:s2c(play.seat_id)
	if not self:isGameOver() then
		self:clearSeatInfo(seat_id)
	end
	if self.mIsRoomCtrl and self:isNotGameStart() then
		self.mScene:dismissTiRenBtn(seat_id)
		self.mScene:dismissPlayerReadyIcon(seat_id)
	end
end

function RoomControl:onStandUpBroadcast(data)
	local seat_id = self:s2c(data.seat_id)
	if not self:isGameOver() then
		self:clearSeatInfo(seat_id)
	end
	if self.mIsRoomCtrl and self:isNotGameStart() then
		self.mScene:dismissTiRenBtn(seat_id)
		self.mScene:dismissPlayerReadyIcon(seat_id)
	end
end

function RoomControl:onUserOfflineBroadcast(data)
	local seat_id = self:getSeatIdByUid(data.uid)
	if seat_id then
		self.mScene:setOffline(seat_id,data.offline == 0)
	end
end

function RoomControl:setCtrlSeat(s_seat_id)
	self.mSeatIdOffset = bottom - (s_seat_id+1)
	self.mCtrlSeatId = self:s2c(s_seat_id)
	self.mScene:setDongFeng(self:s2c(0))
end

function RoomControl:getCtrlSeatId()
	return self.mCtrlSeatId
end

function RoomControl:s2c(s_seat_id)
	local ret = s_seat_id + 1 + self.mSeatIdOffset
	if ret <= 0 then ret = ret + 4 end
	if ret > 4 then ret = ret - 4 end
	return ret
end

function RoomControl:c2s(c_seat_id)
	local ret = c_seat_id - 1 - self.mSeatIdOffset
	if ret < 0 then ret = ret + 4 end
	if ret >= 4 then ret = ret - 4 end
	return ret
end

function RoomControl:setSeatInfo(seat_id,play)
	print("RoomControl:setSeatInfo",seat_id)
	self.mScene:setSeatInfo(seat_id,play)
end

function RoomControl:clearSeatInfo(seat_id)
	print("RoomControl:clearSeatInfo",seat_id)
	self.mScene:clearSeatInfo(seat_id)
end

function RoomControl:setSeatCard(seat_id,hand_cards,peng_cards,gang_cards,zhuan_cards,bian_cards,discard_cards)
	if self.mCtrlSeatId == seat_id then
		self.mScene:setControlBoardCards(hand_cards,false)
		self.mScene:setControlShowCards(peng_cards,gang_cards,zhuan_cards,bian_cards)
	else
		local hand_num = hand_cards
		if hand_num == 2 or hand_num == 5 or hand_num == 8 or hand_num == 11 or hand_num == 14 then
			hand_num = hand_num - 1
		end
		self.mScene:setMajiangBoardCards(seat_id,hand_num)
		if hand_num ~= hand_cards then
			self.mScene:addHandCard(seat_id,0)
		end
		self.mScene:setMajiangBoardShowCards(seat_id,peng_cards,gang_cards,zhuan_cards,bian_cards)
	end
	local discard = {}
	for i,card in ipairs(discard_cards) do
		if card.status ~= 1 then
			table.insert(discard,card.id)
		end
	end
	self.mScene:resetDiscardCards(seat_id,discard)
end

function RoomControl:setDealer(seat_id)
	self.mDealer = seat_id
	self.mScene:setDealer(seat_id)
end


function RoomControl:discard(card_value)
	-- if not self.dapai then return false end
	local params = {}
	params.uid = tt.owner:getUid()
	params.card = card_value
	dump(params)
	tt.gsocket.request("room.discard",params)
	return true
end

function RoomControl:onUserDiscard(data)
	self.mFirstCard = false
	local seat_id = self:getSeatIdByUid(data.uid)
	if seat_id then
		tt.play.play_sound("audio_card_out")
		if seat_id == self.mCtrlSeatId then
			self.isSelfOutAction = false
			local pos = self.mScene:controlBoardDiscard(data.card)
			self.mScene:addDiscard(seat_id,data.card,pos)
			self.mScene:dismissActionBtnViews()
			self.mScene:dismissMulAction()
		else
			self.mScene:addDiscard(seat_id,data.card)
			self.mScene:delHandCard(seat_id)
		end

		local pInfo = self.mScene:getPlayerInfoBySeatId(seat_id)
		dump(pInfo,"RoomControl:onUserDiscard")
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound(string.format("m_0x%02x",data.card))
			else
				tt.play.play_sound(string.format("w_0x%02x",data.card))
			end
		end
	end
end

-- OPE_OUT_CARD 	= 0x001 -- 出牌
-- OPE_RIGHT_CHI 	= 0x002 -- 右吃
-- OPE_MIDDEL_CHI 	= 0x003 -- 中吃
-- OPE_LEFT_CHI 	= 0x004 -- 左吃
-- OPE_PENG = 0x008 -- 碰
-- OPE_GANG = 0x010 -- 碰 杠
-- OPE_HU = 0x040 -- 胡
-- OPE_GANG_HU = 0x080 -- 抢杠胡
-- OPE_AN_GANG = 0x200 -- 暗杠
-- OPE_BU_GANG = 0x400 -- 补杠
-- OPE_ZI_MO = 0x800 -- 自摸	
function RoomControl:onUserAction(data)
	self.mScene:clearActionFailRollBack()
	self.mFirstCard = false
	local seat_id = self:getSeatIdByUid(data.uid)
	local action = data.action
	local isSelf = seat_id == self.mCtrlSeatId
	print("RoomControl:onUserAction",seat_id,action,isSelf)
	if seat_id then
		if isSelf then
			self.mScene:controlBoardOnAction(data.action,data.card)
		else
			self.mScene:majiangBoardOnAction(seat_id,data.action,data.card)
		end
	end

	local pInfo = self.mScene:getPlayerInfoBySeatId(seat_id)
	if OPE_GANG_HU == action then
		if self:s2c(data.card_seat_id) == self.mCtrlSeatId then
			self.mScene:controlBoardDelGang(data.card)
		else
			self.mScene:majiangBoardDelGang(self:s2c(data.card_seat_id),data.card)
		end
	elseif OPE_HU == action then
		self.mScene:delDiscard(self:s2c(data.card_seat_id))
	elseif OPE_GANG == action then
		self.mScene:delDiscard(self:s2c(data.card_seat_id))
	elseif OPE_PENG == action then
		self:countDownStart(seat_id,self.mActionTime)
		self.mScene:delDiscard(self:s2c(data.card_seat_id))
	end

	if OPE_GANG == action or OPE_AN_GANG == action or OPE_BU_GANG == action then
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound("m_gang")
			else
				tt.play.play_sound("w_gang")
			end
		end
	end

	if OPE_PENG == action then
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound("m_peng")
			else
				tt.play.play_sound("w_peng")
			end
		end
	end

	if OPE_MIDDEL_CHI == action then
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound("m_zuan")
			else
				tt.play.play_sound("w_zuan")
			end
		end
	end

	if OPE_RIGHT_CHI == action or OPE_LEFT_CHI == action then
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound("m_bian")
			else
				tt.play.play_sound("w_bian")
			end
		end
	end

	if OPE_HU == action or OPE_GANG_HU == action or OPE_ZI_MO  == action then
		if pInfo then
			if pInfo.sex == 1 then -- 男
				tt.play.play_sound("m_chi_hu")
			else
				tt.play.play_sound("w_chi_hu")
			end
		end
	end
end

function RoomControl:onNoticeAction(data)
	local seat_id = self:getSeatIdByUid(data.uid)
	self:noticeAction(seat_id,data.action,data.card)
end

function RoomControl:countDownStart(seat_id,time)
	print("RoomControl:countDownStart",seat_id,time)
	self.mScene:startCountDownAnim(seat_id,time)
end

function RoomControl:noticeAction(cur_action_seat_id,action_type,action_card)
	print("RoomControl:noticeAction",cur_action_seat_id,action_type,action_card)
	local seat_id = cur_action_seat_id
	local isSelf = seat_id == self.mCtrlSeatId
	local action = action_type
	if OPE_OUT_CARD == bit.band(OPE_OUT_CARD,action) then
		self:countDownStart(cur_action_seat_id,self.mActionTime)
	end

	-- if OPE_OUT_CARD == action then
	-- 	self.mScene:actionCheck(self.mFirstCard)
	-- end

	if not isSelf then return end
	if seat_id then


		if action == 0 then
			if action_card ~= 0 then
				local num = self.mScene:getControlBoardCardNum()
				if num == 2 or num == 5 or num == 8 or num == 11 or num == 14 then
					self.mScene:controlBoardDelCard(action_card)
				end
				self.mScene:controlBoardAddCard(action_card,self.mFirstCard)
				self.isSelfOutAction = true
			else
				self.mScene:onSelfOutAction()
				self.mScene:actionCheck(self.mFirstCard)
				self.isSelfOutAction = true
			end
		end

		-- if action > 0 and action ~= OPE_OUT_CARD then
		-- 	self.mScene:showGuoBtn()
		-- end
		print("OPE_OUT_CARD",bit.band(OPE_OUT_CARD,action))
		if OPE_OUT_CARD == bit.band(OPE_OUT_CARD,action) then
			self.mScene:onSelfOutAction()
			self.mScene:actionCheck(self.mFirstCard)
			self.isSelfOutAction = true
		end
		if OPE_HU == bit.band(OPE_HU,action) then
			self.mScene:showHuBtn(OPE_HU,action_card)
		end
		if OPE_GANG_HU == bit.band(OPE_GANG_HU,action) then
			self.mScene:showHuBtn(OPE_GANG_HU,action_card)
		end
		if OPE_GANG == bit.band(OPE_GANG,action) then
			self.mScene:showGangBtn(OPE_GANG,action_card)
		end
		if OPE_PENG == bit.band(OPE_PENG,action) then
			self.mScene:showPengBtn(action_card)
		end
	end
end

function RoomControl:showActionBtn(actions)
	-- if #actions > 0 then
	-- 	self.mScene:showGuoBtn()
	-- end
	local gang = {}
	for i,action in ipairs(actions) do
		if OPE_RIGHT_CHI == action.action then
			self.mScene:showBianBtn(action.card)
		end
		if OPE_MIDDEL_CHI == action.action then
			self.mScene:showZhuanBtn(action.card)
		end
		if OPE_LEFT_CHI == action.action then
			self.mScene:showBianBtn(action.card)
		end
		if OPE_AN_GANG == action.action then
			table.insert(gang,action)
		end
		if OPE_BU_GANG == action.action then
			table.insert(gang,action)
		end
		if OPE_ZI_MO == action.action then
			self.mScene:showHuBtn(OPE_ZI_MO,action.card)
		end
	end

	if #gang > 0 then
		if #gang == 1 then
			self.mScene:showGangBtn(gang[1].action,gang[1].card)
		else
			self.mScene:showGangBtn(-1,gang)
		end
	end
end

function RoomControl:showMulAction(actions)
	self.mScene:showMulAction(actions)
end

function RoomControl:action(action_id,card_value)
	self.mScene:dismissActionBtnViews()
	self.mScene:dismissMulAction()
	if action_id == 0 and self.isSelfOutAction then
		return
	end
	local params = {}
	params.uid = tt.owner:getUid()
	params.action_id = action_id
	params.card = card_value
	dump(params)
	tt.gsocket.request("room.action",params)
end

function RoomControl:onActionFail(data)
	if data.uid == tt.owner:getUid() then
		self:showPreActionView()
	end
end

function RoomControl:showPreActionView()
	self.mScene:showPreActionView()
end

function RoomControl:setCurQuanJu(quan,ju)
	self.mQuanNum = quan
	self.mJuNum = ju
	self.mScene:setCurQuanJu(quan,ju)
end

function RoomControl:getCurQuanJu()
	return self.mQuanNum,self.mJuNum
end

function RoomControl:getMaxJu()
	return self.mMaxJuNum
end

function RoomControl:getSeatIdByUid(uid)
	return self.mScene:getSeatIdByUid(uid)
end

function RoomControl:getUidBySeatId(seat_id)
	return self.mScene:getUidBySeatId(seat_id)
end

function RoomControl:onStart(data)
	self.mScene:showRunningView()
	self.mScene:showTuiChuBtn(false)
	self.mScene:playDiceAnim(data.dice1,data.dice2)
	self:setDealer(self:getSeatIdByUid(data.cur_dealer_uid))
	self:setCurQuanJu(data.cur_quan,data.cur_ju)
	print("RoomControl:onStart mTableStatus",self.mTableStatus)
	if self.mTableStatus == 0 then
		print("RoomControl:onStart loginGCloudVoice")
		-- tt.voiceRecord.loginGCloudVoice(string.format("level%dtid%dseat%d",self.mLevel,self.mTid,self:c2s(self.mCtrlSeatId)))
		-- tt.voiceRecord.loginGCloudVoice("woyao")
	end
	if self.mFen == 1 then
		self.mMajiangNum = 136
	else
		self.mMajiangNum = 108
	end
	self.mScene:setCardsNum(self.mMajiangNum)
	
	self.mTableStatus = 1
end

function RoomControl:onDeal(data)
	if data.uid == tt.owner:getUid() then
		self.mScene:deal()
		self.mScene:setControlBoardCards(data.cards,true)
		self.mMajiangNum = self.mMajiangNum - #data.cards * 4
		self.mScene:setCardsNum(self.mMajiangNum)
	end
	self.mFirstCard = true
end

function RoomControl:onDealOne(data)
	local seat_id = self:getSeatIdByUid(data.uid)
	if data.uid == tt.owner:getUid() then
		tt.play.play_sound("audio_get_card")
		self.mScene:controlBoardAddCard(data.card,self.mFirstCard)
		if seat_id then
			self:countDownStart(seat_id,self.mActionTime)
		end
		self.isSelfOutAction = true
	else
		if seat_id then
			self:countDownStart(seat_id,self.mActionTime)
			self.mScene:addHandCard(seat_id,0)
		end
	end
	self.mMajiangNum = self.mMajiangNum - 1
	self.mScene:setCardsNum(self.mMajiangNum)

end

function RoomControl:onGameOver(data)
	self.mTableStatus = 4

	local scores = {}
	local hand_cards = {}
	for i=1,4 do
		scores[i] = 0
		hand_cards[i] = {}
	end
	for i,player in ipairs(data.player) do
		local seat_id = self:getSeatIdByUid(player.uid)
		scores[seat_id] = player.cur_score
		hand_cards[seat_id] = player.hand_cards
		self.mScene:setSeatScore(seat_id,player.sum_score)
	end
	local getWinStr = function(winData,hand_cards)
		dump(winData)
		local win_str
		if winData.is_qiang_gang_hu == 1 then
			if win_str then
				win_str = win_str .. ",抢杠胡"
			else
				win_str = "抢杠胡"
			end
		end
		if winData.is_gang_hu == 1 then
			if win_str then
				win_str = win_str .. ",杠上花"
			else
				win_str = "杠上花"
			end
		end
		if winData.is_7_dui_hu == 1 then
			local str = "七对"
			local num = {}
			for i,card in ipairs(hand_cards) do
				num[card] = (num[card] or 0) + 1
				if num[card] == 4 then
					str = "豪七对"
				end
			end
			if win_str then
				win_str = win_str .. "," .. str
			else
				win_str = str
			end
		end
		if winData.is_peng_peng_hu == 1 then
			if win_str then
				win_str = win_str .. ",碰碰胡"
			else
				win_str = "碰碰胡"
			end
		end
		if winData.is_diao_5_wan == 1 then
			if win_str then
				win_str = win_str .. ",吊五万"
			else
				win_str = "吊五万"
			end
		end
		if winData.is_zhuo_5_wan == 1 then
			if win_str then
				win_str = win_str .. ",捉五魁"
			else
				win_str = "捉五魁"
			end
		end
		if winData.is_qing_yi_se == 1 then
			if win_str then
				win_str = win_str .. ",清一色"
			else
				win_str = "清一色"
			end
		end
		if winData.is_yi_tiao_long == 1 then
			if win_str then
				win_str = win_str .. ",一条龙"
			else
				win_str = "一条龙"
			end
		end
		if winData.win_type == 2 then
			if win_str then
				win_str = win_str .. ",自摸"
			else
				win_str = "自摸"
			end
		end
		return win_str
	end
	dump(scores)
	self.mRecords[self.mMaxJuNum] = scores
	self.mMaxJuNum = self.mMaxJuNum + 1
	if data.gameover_type == 1 or data.gameover_type == 2 then
		local winData = data.winData
		local win_seat_id = self:getSeatIdByUid(data.winData.uid)
		local win_str = getWinStr(winData,hand_cards[win_seat_id]) or ""

		-- if winData.win_type == 2 then -- 自摸
			for i,card_id in ipairs(hand_cards[win_seat_id]) do
				if card_id == winData.hu_card_id then
					table.remove(hand_cards[win_seat_id],i)
					break
				end
			end
		-- end

		if winData.pao_uid ~= -1 then
			self.mScene:playFangPaoAnim(win_seat_id,self:getSeatIdByUid(winData.pao_uid))
		end

		self.mScene:showAccountsDialog(self.mDealer,winData.win_type == 2,scores,hand_cards,win_seat_id ,winData.hu_card_id,win_str)
		self.mScene:stopCountDownAnim()
		if data.gameover_type == 2 then
			self.mIsGameOver = true
		end
	elseif data.gameover_type == 0 then
		self.mScene:showAccountsDialog(self.mDealer,false,scores,hand_cards)
		self.mScene:stopCountDownAnim()
	end
end

function RoomControl:showTotalAccountsDialog()
	self.isShowTotalAccountsDialog = true
	if type(self.mTotalAccountsDialogData) == "table" then
		self.mScene:showTotalAccountsDialog(self.mTotalAccountsDialogData)
	end
end

function RoomControl:onTotalAccountsDialog(data,isRoomOverApply)
	isRoomOverApply = isRoomOverApply or false
	dump(data,"RoomControl:onTotalAccountsDialog")
	self.mTotalAccountsDialogData = data

	local saveData = {}
	saveData.playerInfo = {}
	saveData.gameInfo = {}
	for i=1,4 do
		saveData.playerInfo[self:c2s(i)+1] = self.mScene:getPlayer(i)
	end

	for i,player in ipairs(data.players) do
		local seat_id = self:getSeatIdByUid(player.uid)
		saveData.gameInfo[self:c2s(seat_id)+1] = player
		saveData.gameInfo[self:c2s(seat_id)+1].score = self.mScene:getSeatScore(seat_id)
	end

	saveData.start_time = data.start_time
	saveData.rule_txt = str
	saveData.room_index = self:getRoomIndex()
	saveData.quan = quan
	saveData.ju = maxJu
	tt.nativeData.saveHistoryRecord(saveData)

	if self.isShowTotalAccountsDialog or isRoomOverApply then
		self.mIsGameOver = self.mIsGameOver or isRoomOverApply
		self.mScene:showTotalAccountsDialog(self.mTotalAccountsDialogData)
	end
end

function RoomControl:onMsg(data)
	print("RoomControl:onMsg")
	dump(data)
	local msg = data.msg
	if msg.msg_type == IMHelper.VOICE and msg.uid ~= tt.owner:getUid() then
		tt.voiceRecord.downloadRecordedFile(msg.file_id)
		table.insert(self.mRecordeds,msg)
	elseif msg.msg_type == IMHelper.SHORTCUT_MSG and msg.uid ~= tt.owner:getUid() then
		self.mScene:showShortcutMsg(self:getSeatIdByUid(msg.uid),msg.content)
	elseif msg.msg_type == IMHelper.EMOTICON_MSG and msg.uid ~= tt.owner:getUid() then
		self.mScene:showEmoticonMsg(self:getSeatIdByUid(msg.uid),msg.emoticon_id)
	end
end

function RoomControl:sendMsg(str)
	IMHelper.sendMsg(tt.owner:getUid(),str)
	self.mScene:showMsg(self:getSeatIdByUid(tt.owner:getUid()),str)
end

function RoomControl:sendShortcutMsg(str)
	IMHelper.sendShortcutMsg(tt.owner:getUid(),str)
	self.mScene:showShortcutMsg(self:getSeatIdByUid(tt.owner:getUid()),str)
end

function RoomControl:sendEmoticonMsg(id)
	IMHelper.sendEmoticonMsg(tt.owner:getUid(),id)
	self.mScene:showEmoticonMsg(self:getSeatIdByUid(tt.owner:getUid()),id)
end

function RoomControl:onDownloadRecordedFile(params)
	for i=#self.mRecordeds,1,-1 do
		local recorded = self.mRecordeds[i]
		if recorded.file_id == params.fileID then
			self.mScene:speek(self:getSeatIdByUid(recorded.uid),params.filePath)
		end
	end
end

function RoomControl:getJuScore(ju)
	if not self.mRecords[ju] then
		if ju ~= self.mMaxJuNum or self.mTableStatus == 4 then
			self:getRecordsByServer(ju)
		end
		return
	end
	return self.mRecords[ju]
end

function RoomControl:getRecordsByServer(ju)
	if ju <= 0 then return end
	if self.mRecordsPageMaxNum == 0 then
		self:sendGetRecordsCache(1)
		return
	end

	local page = math.floor((ju-1)/self.mRecordsPageMaxNum) + 1
	self:sendGetRecordsCache(page)
end

function RoomControl:sendGetRecordsCache(page)
	if self.mRecordCmdCache[page] then return end
	self.mRecordCmdCache[page] = true
	local params = {}
	params.uid = tt.owner:getUid()
	params.page = page
	tt.gsocket.request("room.getRecord",params)
end

function RoomControl:onGetRecord(data)
	self.mRecordCmdCache[data.cur_page] = false
	local cur_page = data.cur_page
	self.mRecordsPageMaxNum = data.ju_page_num

	local offset = (data.cur_page-1) * self.mRecordsPageMaxNum
	local scores = {}
	for i,player in ipairs(data.players) do
		local seat_id = self:getSeatIdByUid(player.uid)
		for j,record in ipairs(player.records) do
			scores[j] = scores[j] or {}
			scores[j][seat_id] = record.cur_score
		end
	end
	for i,score in ipairs(scores) do
		self.mRecords[i+offset] = score
	end
	self.mScene:updateRecordDialog()
end

function RoomControl:onShowHuTipsViews(tab)
	self.mScene:showHuTipsViews(tab)
end

function RoomControl:onDismissHuTipsViews()
	self.mScene:dismissHuTipsViews()
end


function RoomControl:test()
	self.isTest = true
	self.mTestCard = {}

	function RoomControl:getTestRandomCards()
		local index = math.random(1,#self.mTestCard)
		return table.remove(self.mTestCard,index)
	end

	for j=1,4 do
		for k=1,4 do
			table.insert(self.mTestCard,tonumber(string.format("0x%d%d",3,j),16))
		end
	end

	for j=1,3 do
		for k=1,4 do
			table.insert(self.mTestCard,tonumber(string.format("0x%d%d",4,j),16))
		end
	end


	for i=0,2 do
		for j=1,9 do
			for k=1,4 do
				table.insert(self.mTestCard,tonumber(string.format("0x%d%d",i,j),16))
			end
		end
	end
	local ret = {}
	for i=1,13 do
		table.insert(ret,self:getTestRandomCards())
	end

	for i=1,13 do
		self:getTestRandomCards()
	end

	for i=1,13 do
		self:getTestRandomCards()
	end

	for i=1,13 do
		self:getTestRandomCards()
	end

	self.mScene:setControlBoardCards(ret,true)

	self.mScene:controlBoardAddCard(self:getTestRandomCards())

	self:onStartGame()

	self.testplay_type = 4

	while #self.mTestCard > 0 do
		dump(self.mTestCard)
		self:discard(self:getTestRandomCards())
	end

end
return RoomControl