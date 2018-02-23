local CircleClip = require("app.ui.CircleClip")

local HistoryRecordItem = class("HistoryRecordItem",function()
    return display.newNode()
end)

function HistoryRecordItem:ctor(ctrl)
	local node, width, height = cc.uiloader:load("history_record_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	self.mCtrl = ctrl

	self.mRoomIdTxt = cc.uiloader:seekNodeByName(node, "room_id_txt")
	self.mQuanNumTxt = cc.uiloader:seekNodeByName(node, "quan_num_txt")
	self.mTimeTxt = cc.uiloader:seekNodeByName(node, "time_txt")

	self.mUsers = {}
	for i=1,4 do
		self.mUsers[i] = cc.uiloader:seekNodeByName(node, "user_"..i)
	end
	self.mUserScores = {}
	for i=1,4 do
		self.mUserScores[i] = cc.uiloader:seekNodeByName(node, "score_"..i)
	end
	self.mShareBtn = cc.uiloader:seekNodeByName(node, "share_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mData then
					self.mCtrl:showTotalAccountsDialog(self.mData)
				end
			end)
	
	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_share) == 0 or tonumber(openConfig.check_status) == 1 then
		self.mShareBtn:setVisible(false)
	end
end

function HistoryRecordItem:setData(data)
	self.mData = data
	self.mRoomIdTxt:setString(string.format("房号:%06d",data.room_index or 0))
	self.mQuanNumTxt:setString(string.format("圈数:%d",data.quan or 0))
	self.mTimeTxt:setString(os.date("时间:%m/%d %H:%M",data.start_time or 0))
	for i=1,4 do
		local score = data.gameInfo[i].score or 0
		if type(data.playerInfo) == "table" then
			local playerInfo = data.playerInfo[i]
			if playerInfo then
				local pinfo  = json.decode(playerInfo.pInfo)
				if type(pinfo) == "table" then
					tt.limitStr(self.mUsers[i],pinfo.name,144)
				end
			end
		end
		if score > 0 then
			self.mUserScores[i]:setString(string.format("+%d",score))
			-- self.mUserScores[i]:setTextColor(cc.c3b(252,3,97))
			self.mUserScores[i]:setColor(cc.c3b(252,3,97))
		else
			self.mUserScores[i]:setString(string.format("%d",score))
			-- if score == 0 then
			-- 	self.mUserScores[i]:setTextColor(cc.c3b(252,3,97))
			-- else
				-- self.mUserScores[i]:setTextColor(cc.c3b(34,168,13))
				self.mUserScores[i]:setColor(cc.c3b(34,168,13))
			-- end
		end
	end
end

return HistoryRecordItem

