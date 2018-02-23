--
-- Author: shineflag
-- Date: 2017-04-23 17:52:51
--
--  所有常量

kVtime = 0.3  --所的view的进场和出场动画
-- "appstore"
-- "google"
if device.platform == "ios" then
	kChan="appstore"
elseif device.platform == "android" then
	kChan="android"
elseif device.platform == "windows" then
	kChan="windows"
else
	kChan="unknow"
end
kVersion = "1.0.4"
kUpdateUrl = "http://haoyun51.com:8080/update"
-- test = "http://192.168.1.100:8001"
-- test = "http://10.0.0.100:8001"
local dev = "http://maj.woyaohaoyun.com/"
local release = "http://tianyou.woyaohaoyun.com/"
-- local debug = "http://woyaohaoyun.com:8080/api"
kHttpUrl = release

GAME_MODE_DEBUG = true


kSuccess = 1 
kCancel  = 2
kFail    = 3 
kTimeOut = 4

OPE_RIGHT_CHI 	= 0x001 -- 右吃
OPE_MIDDEL_CHI 	= 0x002 -- 中吃
OPE_LEFT_CHI 	= 0x004 -- 左吃
OPE_PENG = 0x008 -- 碰
OPE_GANG = 0x010 -- 碰 杠
OPE_HU = 0x040 -- 胡
OPE_GANG_HU = 0x080 -- 抢杠胡
OPE_AN_GANG = 0x200 -- 暗杠
OPE_BU_GANG = 0x400 -- 补杠
OPE_ZI_MO = 0x800 -- 自摸
OPE_TING = 0x1000 -- 听牌
OPE_OUT_CARD 	= 0x2000 -- 出牌
