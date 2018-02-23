local platformEventHalper = require("app.utils.platformEventHalper")

local statisticsHalper = {}

statisticsHalper.cmds = {
	facebookLoginBtn = "facebookLoginBtn",
	youkeBtn = "youkeBtn",
	selectUpdateCancelBtn = "selectUpdateCancelBtn",
	selectUpdateConfirmBtn = "selectUpdateConfirmBtn",
	userinfoBtn = "userinfoBtn",
	addCoinBtn = "addCoinBtn",
	mallBtn = "mallBtn",
	myMatchBtn = "myMatchBtn",
	announcementBtn = "announcementBtn",
	setBtn = "setBtn",
	cashBtn = "cashBtn",
	matchBtn = "matchBtn",
	cashLevelChange = "cashLevelChange",
	cashStartBtn = "cashStartBtn",
	cashBuyMoneyBtn = "cashBuyMoneyBtn",
	cashCancelBtn = "cashCancelBtn",
	matchSignBtn = "matchSignBtn",
	matchUnSignBtn = "matchUnSignBtn",
	matchUnSignSureBtn = "matchUnSignSureBtn",
	infoViewBtn = "infoViewBtn",
	blindViewBtn = "blindViewBtn",
	userViewBtn = "userViewBtn",
	roomUserHeadBtn = "roomUserHeadBtn",
	roomMenuBtn = "roomMenuBtn",
	roomRuleBtn = "roomRuleBtn",
	roomAddCoinBtn = "roomAddCoinBtn",
	roomBlindInfoBtn = "roomBlindInfoBtn",
	roomFoldBtn = "roomFoldBtn",
	roomCheckBtn = "roomCheckBtn",
	roomRaiseBtn = "roomRaiseBtn",
	roomMinBtn = "roomMinBtn",
	room3BBBtn = "room3BBBtn",
	roomHalfBtn = "roomHalfBtn",
	roomPotBtn = "roomPotBtn",
	roomMaxBtn = "roomMaxBtn",
	roomAddBtn = "roomAddBtn",
	roomSubBtn = "roomSubBtn",
	roomMenuContinueBtn = "roomMenuContinueBtn",
	roomMenuBackBtn = "roomMenuBackBtn",
	roomMenuStandBtn = "roomMenuStandBtn",
	roomMenuOfflineBtn = "roomMenuOfflineBtn",
	roomMenuSettingBtn = "roomMenuSettingBtn",
	roomMenuBackBtnCancel = "roomMenuBackBtnCancel",
	roomMenuBackBtnConfirm = "roomMenuBackBtnConfirm",
	roomMenuStandBtnCancel = "roomMenuStandBtnCancel",
	roomMenuStandBtnConfirm = "roomMenuStandBtnConfirm",
	roomInfoViewBtn = "roomInfoViewBtn",
	roomBlindViewBtn = "roomBlindViewBtn",
	roomUserViewBtn = "roomUserViewBtn",
	matchList = "matchList",
	settingMusicBtn = "settingMusicBtn",
	settingPushBtn = "settingPushBtn",
	settingShockBtn = "settingShockBtn",
	settingSoundBtn = "settingSoundBtn",
	settingLogoutBtn = "settingLogoutBtn",
	userInfoAddMoney = "userInfoAddMoney",
	userInfoChangeName = "userInfoChangeName",
}

local function onProfileSignIn(ID,provider)
	ID = tostring(ID) or ""
	provider = tostring(provider) or ""
	local params = platformEventHalper.cmds.onProfileSignIn
	params.args = {
		provider=provider,
		puid=ID,
	}
	platformEventHalper.callEvent(params)
end

local function onProfileSignOff()
	local params = platformEventHalper.cmds.onProfileSignOff
	platformEventHalper.callEvent(params)
end

local function onEvent(eventId,map)
	local params = platformEventHalper.cmds.onEvent
	params.args = {
		eventId=eventId,
		jsonStr=json.encode(map),
	}
	platformEventHalper.callEvent(params)
end

local function onEventValue(eventId,map,value)
	local params = platformEventHalper.cmds.onEventValue
	params.args = {
		eventId=eventId,
		jsonStr=json.encode(map),
		value=value,
	}
	platformEventHalper.callEvent(params)
end

local function reportError(error)
	local params = platformEventHalper.cmds.reportError
	params.args = {
		error=error,
	}
	platformEventHalper.callEvent(params)
end

statisticsHalper.onProfileSignIn = onProfileSignIn
statisticsHalper.onProfileSignOff = onProfileSignOff
statisticsHalper.onEvent = onEvent
statisticsHalper.onEventValue = onEventValue
statisticsHalper.reportError = reportError

return statisticsHalper