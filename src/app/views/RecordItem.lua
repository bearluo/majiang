local CircleClip = require("app.ui.CircleClip")

local RecordItem = class("RecordItem",function()
    return display.newNode()
end)

function RecordItem:ctor(ctrl)
	local node, width, height = cc.uiloader:load("record_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))
	self.mCtrl = ctrl

	self.mJuNumTxt = cc.uiloader:seekNodeByName(node, "ju_num_txt")
	self.mUserScores = {}
	for i=1,4 do
		self.mUserScores[i] = cc.uiloader:seekNodeByName(node, "user_"..i)
		self.mUserScores[i]:setString("+1111")
	end
end

function RecordItem:setJu(num)
	self.mJuNumTxt:setString(string.format("第%d局",num))
end

function RecordItem:isHasScore()
	return self.mIsHasScore
end

function RecordItem:setScore(seat_id,score)
	self.mIsHasScore = true
	if score > 0 then
		self.mUserScores[seat_id]:setString("+"..score)
		-- self.mUserScores[seat_id]:setTextColor(cc.c3b(62, 246, 5))
		self.mUserScores[seat_id]:setColor(cc.c3b(62, 246, 5))
	else
		self.mUserScores[seat_id]:setString(score)
		-- self.mUserScores[seat_id]:setTextColor(cc.c3b(252, 3, 97))
		self.mUserScores[seat_id]:setColor(cc.c3b(252, 3, 97))
	end
end

function RecordItem:setNilScore()
	self.mIsHasScore = false
	for i=1,4 do
		self.mUserScores[i]:setString("")
		-- self.mUserScores[i]:setTextColor(cc.c3b(62, 246, 5))
	end
end

return RecordItem

