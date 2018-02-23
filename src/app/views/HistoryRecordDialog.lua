local BLDialog = require("app.ui.BLDialog")
local TAG = "HistoryRecordDialog"
local net = require("framework.cc.net.init")
local CircleClip = require("app.ui.CircleClip")

local HistoryRecordDialog = class("HistoryRecordDialog", function()
	return BLDialog.new()
end)


function HistoryRecordDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("history_record_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node, "content_bg")

	cc.uiloader:seekNodeByName(node, "close_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				self:dismiss()
			end)

	self.mRecordListview = cc.uiloader:seekNodeByName(node, "history_record_list")
	self.mRecordListItems = {}
end

function HistoryRecordDialog:resetView()
	self.mRecordListview:removeAllItems()
	self.mRecordListItems = {}
	local datas = tt.nativeData.getHistoryRecords()
	dump(datas)
	for i,data in ipairs(datas) do
		local content = app:createView("HistoryRecordItem", self.control_)
		content:setData(data)
		local item = self.mRecordListview:newItem(content)
		local size = content:getContentSize()
		if i == #datas then
			item:setMargin({left = 0, right = 0, top = 20, bottom = 5})
		else
			item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
		end
		item:setItemSize(size.width,size.height)
		self.mRecordListview:addItem(item, 1) 
		self.mRecordListItems[i] = content
	end
	self.mRecordListview:reload()
end

function HistoryRecordDialog:show()
	BLDialog.show(self)
	self.mContentBg:scale(1)
	self:resetView()
end

function HistoryRecordDialog:dismiss()
	BLDialog.dismiss(self)
end  


return HistoryRecordDialog