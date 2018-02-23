--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local RoomSettingDialog = class("RoomSettingDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "RoomSettingDialog"
local net = require("framework.cc.net.init")

function RoomSettingDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("setting_dialog_2.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.music_btn_status = not (tt.game_data.music_btn_status == false)
	self.music_btn = cc.uiloader:seekNodeByName(node,"music_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.music_btn_status = self:clickFunc(self.music_btn,self.music_btn_status)
			tt.nativeData.saveMusicBtnStatus(self.music_btn_status)
			if self.music_btn_status then 
				tt.play.resume_music()
				print("tt.play.resume_music")
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingMusicBtn,{enable=1})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingMusicBtn,{enable=0})
				print("tt.play.pause_music")
				tt.play.pause_music()
			end
		end)
	self:updateBtnView(self.music_btn,self.music_btn_status)

	self.sound_btn_status = not (tt.game_data.sound_btn_status == false)
	self.sound_btn = cc.uiloader:seekNodeByName(node,"sound_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self.sound_btn_status = self:clickFunc(self.sound_btn,self.sound_btn_status)
			tt.nativeData.saveSoundBtnStatus(self.sound_btn_status)
			if self.sound_btn_status then 
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingSoundBtn,{enable=1})
			else
				tt.statisticsHalper.onEvent(tt.statisticsHalper.cmds.settingSoundBtn,{enable=0})
			end
		end)
	self:updateBtnView(self.sound_btn,self.sound_btn_status)
end

function RoomSettingDialog:updateBtnView(view,flag)
	if flag then
		view:setButtonImage("normal","btn/bt_open_music.png",true)
		view:setButtonImage("pressed","btn/bt_close_music.png",true)
	else
		view:setButtonImage("normal","btn/bt_close_music.png",true)
		view:setButtonImage("pressed","btn/bt_open_music.png",true)
	end
end

function RoomSettingDialog:setIsChangeLogout( flag )
	self.logout_btn:setVisible(flag)
end

function RoomSettingDialog:clickFunc(view,flag)
	self:updateBtnView(view,not flag)
	return not flag
end


function RoomSettingDialog:show()
	BLDialog.show(self)
end

function RoomSettingDialog:dismiss()
	BLDialog.dismiss(self)
end

return RoomSettingDialog
