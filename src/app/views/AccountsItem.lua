local CircleClip = require("app.ui.CircleClip")

local AccountsItem = class("AccountsItem",function()
    return display.newNode()
end)

local Majiang = require("app.ui.Majiang")

function AccountsItem:ctor(ctrl)
	local node, width, height = cc.uiloader:load("accounts_item.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.head_handler = cc.uiloader:seekNodeByName(node,"head_bg")
	self.name_txt = cc.uiloader:seekNodeByName(node,"nick_txt")
	self.id_txt = cc.uiloader:seekNodeByName(node,"id_txt")
	self.sum_score_txt = cc.uiloader:seekNodeByName(node,"sum_score_txt")
	self.card_type_txt = cc.uiloader:seekNodeByName(node,"card_type_txt")

	self.win_icon = cc.uiloader:seekNodeByName(node,"win_icon")
	self.win_icon:setVisible(false)
	self.zhuang_icon = cc.uiloader:seekNodeByName(node,"zhuang_icon")
	self.zhuang_icon:setVisible(false)
	
	self.show_card_view = cc.uiloader:seekNodeByName(node,"show_card_view")
	self.show_card_view:setContentSize(cc.size(0,0))
	self.show_card_view:scale(0.55)
	local x,y = self.show_card_view:getPosition()
	self.show_card_view:setPosition(x,y-6)
	self.mCtrl = ctrl
end

function AccountsItem:setUserInfo(info)
	if not info then return end
	self.player = info 
	self.pinfo  = json.decode(info.pInfo)

	tt.limitStr(self.name_txt,self.pinfo.name,108)

	self.id_txt:setString( string.format("ID:%d",self.player.uid))
	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end
	print('AccountsItem:setSeatInfo',self.pinfo.img_url)
	tt.asynGetHeadIconSprite(string.urldecode(self.pinfo.img_url or ""),function(sprite)
		if sprite and self and self.head_handler then
			local size = self.head_handler:getContentSize()
			local mask = display.newSprite("dec/touxiangzhezhao.png")
			if self.head_ then
				self.head_:removeSelf()
				self.head_ = nil
			end
			self.head_ = CircleClip.new(sprite,mask)
				:addTo(self.head_handler,99)
				:setPosition(cc.p(0,0))
				:setCircleClipContentSize(size.width,size.width)
		end
	end)
end

function AccountsItem:addShowCardView(view,offsetX,offsetY)
	tt.linearlayout(self.show_card_view,view,offsetX,offsetY)
end

function AccountsItem:setWin(card_id,win_card_type_str)
	print("AccountsItem:setWin",card_id,win_card_type_str)
	self.win_icon:setVisible(true)
	self.card_type_txt:setString(win_card_type_str)

	local majiang = Majiang.new(card_id,Majiang.SELF_ON_HAND)
	local icon = display.newSprite("dec/hu.png")
	icon:addTo(majiang)
	icon:scale(1.55)
	icon:setPosition(cc.p(40,130))
	self:addShowCardView(majiang,10,-0)
end

function AccountsItem:setDealer()
	self.zhuang_icon:setVisible(true)
end

function AccountsItem:setScore(score)
	print("AccountsItem:setScore",score)
	if score > 0 then
		-- self.sum_score_txt:setTextColor(cc.c3b(252,3,97))
		self.sum_score_txt:setColor(cc.c3b(252,3,97))
		self.sum_score_txt:setString(string.format("+%d",score))
	else
		-- self.sum_score_txt:setTextColor(cc.c3b(34,168,13))
		self.sum_score_txt:setColor(cc.c3b(34,168,13))
		self.sum_score_txt:setString(score)
	end
end

function AccountsItem:clearInfo()
	self.card_type_txt:setString("")
	self.name_txt:setString("")
	self.id_txt:setString("")
	self.sum_score_txt:setString("")
	self.win_icon:setVisible(false)
	self.zhuang_icon:setVisible(false)
	if self.head_ then
		self.head_:removeSelf()
		self.head_ = nil
	end
	self.show_card_view:removeAllChildren()
	self.show_card_view:setContentSize(cc.size(0,0))
end

return AccountsItem

