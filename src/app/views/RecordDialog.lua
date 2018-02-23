local BLDialog = require("app.ui.BLDialog")
local TAG = "RecordDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local RecordDialog = class("RecordDialog", function()
	return BLDialog.new()
end)


function RecordDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("record_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mRecordListview = cc.uiloader:seekNodeByName(node, "record_listview")
	self.mRecordListview:onTouch(handler(self, self.onRecordListviewTouch))
	self.mRecordListItems = {}

	self.mUserItems = {}
	for i=1,4 do
		self.mUserItems[i] = cc.uiloader:seekNodeByName(node, "user_" .. i)
	end
end

function RecordDialog:setUserInfo(seat_id,player)
	if not player then return end
	local view = self.mUserItems[seat_id]
	local pinfo  = json.decode(player.pInfo)
	cc.uiloader:seekNodeByName(view,"name_txt"):setString(pinfo.name)
	cc.uiloader:seekNodeByName(view,"id_txt"):setString(string.format("ID:%d",player.uid))
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

function RecordDialog:setCurJu(ju)
	self.mRecordListview:removeAllItems()
	self.mRecordListItems = {}
	for i=1,ju do
		local content = app:createView("RecordItem", self.control_)
		content:setJu(i)
		local item = self.mRecordListview:newItem(content)
		local size = content:getContentSize()
		item:setItemSize(size.width,size.height)
		self.mRecordListview:addItem(item, 1) 
		self.mRecordListItems[i] = content
	end
	self.mRecordListview:reload()
	self:updateItems()
end

function RecordDialog:onRecordListviewTouch(event)
	self:updateItems()
end

function RecordDialog:updateItems()
	local len = #self.mRecordListItems
	for i,item in ipairs(self.mRecordListItems) do
		if not item:isHasScore() and self.mRecordListview:isItemInViewRect(len - i + 1) then
			local scores = self.control_:getJuScore(i)
			if scores then
				for j,score in ipairs(scores) do
					print("RecordDialog:updateItems",self.control_:s2c(j)+1,score)
					item:setScore(self.control_:c2s(j)+1,score)
				end
			else
				item:setNilScore()
			end
		end
	end
end

function RecordDialog:show()
	BLDialog.show(self)
end

function RecordDialog:dismiss()
	BLDialog.dismiss(self)
end  


return RecordDialog