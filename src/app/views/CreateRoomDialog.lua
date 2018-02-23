--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local CreateRoomDialog = class("CreateRoomDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "CreateRoomDialog"
local net = require("framework.cc.net.init")
local contentTxt = ""
function CreateRoomDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("create_room_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)
	local config = tt.nativeData.getGameConfig()
	self.mQuanBtns = {}
	self.mQuanBtnsData = {}

	dump(config)
	self.mQuanIndex = 2
	for i=1,3 do
		self.mQuanBtnsData[i] = {quan=config["quan"..i] or 0,gem=config["zuan"..i] or 0}
		self.mQuanBtns[i] = cc.uiloader:seekNodeByName(node,"quan_btn_" .. i)
		self.mQuanBtns[i]:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectView(self.mQuanBtns,i)
			self.mQuanIndex = i
		end)
		cc.uiloader:seekNodeByName(self.mQuanBtns[i],"txt"):setString(string.format("%d圈(钻石X%d)",self.mQuanBtnsData[i].quan,self.mQuanBtnsData[i].gem/4))
	end
	self:selectView(self.mQuanBtns,self.mQuanIndex)

	self.mGameTypeBtns = {}
	self.mGameTypeIndex = 1
	self.mGameTypeBtnsData = {
		0,
		1,
	}
	for i=1,2 do
		self.mGameTypeBtns[i] = cc.uiloader:seekNodeByName(node,"game_type_btn_" .. i)
		self.mGameTypeBtns[i]:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectView(self.mGameTypeBtns,i)
			self.mGameTypeIndex = i
		end)
	end
	self:selectView(self.mGameTypeBtns,self.mGameTypeIndex)

	self.mFengBtns = {}
	self.mFengIndex = 1
	self.mFengBtnsData = {
		0,
		1,
	}
	for i=1,2 do
		self.mFengBtns[i] = cc.uiloader:seekNodeByName(node,"feng_btn_" .. i)
		self.mFengBtns[i]:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectView(self.mFengBtns,i)
			self.mFengIndex = i
		end)
	end
	self:selectView(self.mFengBtns,self.mFengIndex)

	self.mPayBtns = {}
	self.mPayIndex = 1
	self.mPayBtnsData = {
		0,
		1,
	}
	for i=1,2 do
		self.mPayBtns[i] = cc.uiloader:seekNodeByName(node,"pay_btn_" .. i)
		self.mPayBtns[i]:onButtonClicked(function()
			tt.play.play_sound("click")
			self:selectView(self.mPayBtns,i)
			self.mPayIndex = i
			for j=1,3 do
				if i == 1 then
					cc.uiloader:seekNodeByName(self.mQuanBtns[j],"txt"):setString(string.format("%d圈(钻石X%d)",self.mQuanBtnsData[j].quan,self.mQuanBtnsData[j].gem/4))
				else
					cc.uiloader:seekNodeByName(self.mQuanBtns[j],"txt"):setString(string.format("%d圈(钻石X%d)",self.mQuanBtnsData[j].quan,self.mQuanBtnsData[j].gem))
				end
			end
		end)
	end
	self:selectView(self.mPayBtns,self.mPayIndex)

	self.mBaseIndex = tt.nativeData.getSelectBaseScoreIndex()
	self.mBaseScore = config.difen or {}
	if not self.mBaseScore[self.mBaseIndex] then self.mBaseIndex = 1 end
	self.mBaseScoreTxt = cc.uiloader:seekNodeByName(node,"base_score_txt")
	self.mBaseScoreTxt:setString(self.mBaseScore[self.mBaseIndex] or 1)
	cc.uiloader:seekNodeByName(node,"add_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			if self.mBaseIndex >= #self.mBaseScore then return end
			self.mBaseIndex = self.mBaseIndex + 1
			tt.nativeData.saveSelectBaseScoreIndex(self.mBaseIndex)
			self.mBaseScoreTxt:setString(self.mBaseScore[self.mBaseIndex])
		end)
	cc.uiloader:seekNodeByName(node,"sub_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			if self.mBaseIndex <= 1 then return end
			self.mBaseIndex = self.mBaseIndex - 1
			tt.nativeData.saveSelectBaseScoreIndex(self.mBaseIndex)
			self.mBaseScoreTxt:setString(self.mBaseScore[self.mBaseIndex])
		end)

	self.mCreateBtn = cc.uiloader:seekNodeByName(node,"create_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:onCreateRoom()
		end)

	self.mGemHandler = cc.uiloader:seekNodeByName(node,"gem_num")
	self:updateGemNum(tt.owner:getGem())
end

function CreateRoomDialog:selectView(views,select_index)
	for i,view in ipairs(views) do
		if i ~= select_index then
			cc.uiloader:seekNodeByName(view,"select_icon"):setVisible(false)
		else
			cc.uiloader:seekNodeByName(view,"select_icon"):setVisible(true)
		end
	end
end

function CreateRoomDialog:onCreateRoom()
	local quanData = self.mQuanBtnsData[self.mQuanIndex]
	local gem = quanData.gem
	local paytype = self.mPayBtnsData[self.mPayIndex]

	if paytype == 0 then
		if gem / 4 > tt.owner:getGem() then
			self.control_:showChooseDialog("钻石不足，请购买钻石",nil,function()
					self:dismiss()
					self.control_:showShopDialog()
				end)
			return 
		else
			local params = {}
			params.uid = tt.owner:getUid()
			params.level = 101
			params.ju = quanData.quan
			params.cost = gem
			params.pay = paytype
			params.balance = self.mGameTypeBtnsData[self.mGameTypeIndex]
			params.fen = self.mFengBtnsData[self.mFengIndex]
			params.base_score = self.mBaseScore[self.mBaseIndex] or 1
			dump(params)
			tt.gsocket.request("room.create",params)
		end
	else
		if gem > tt.owner:getGem() then
			self.control_:showChooseDialog("钻石不足，请购买钻石",nil,function()
					self:dismiss()
					self.control_:showShopDialog()
				end)
			return 
		else
			local params = {}
			params.uid = tt.owner:getUid()
			params.level = 101
			params.ju = quanData.quan
			params.cost = gem
			params.pay = paytype
			params.balance = self.mGameTypeBtnsData[self.mGameTypeIndex]
			params.fen = self.mFengBtnsData[self.mFengIndex]
			params.base_score = self.mBaseScore[self.mBaseIndex] or 1
			dump(params)
			tt.gsocket.request("room.create",params)
		end
	end

end

function CreateRoomDialog:updateGemNum(num)
	self.mGemHandler:removeAllChildren()
	local node = tt.getBitmapNum("number/yellow_%d.png",num)
	self.mGemHandler:addChild(node)
end

function CreateRoomDialog:show()
	BLDialog.show(self)
end

function CreateRoomDialog:dismiss()
	BLDialog.dismiss(self)
end

return CreateRoomDialog
