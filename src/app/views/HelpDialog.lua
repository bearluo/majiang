--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local HelpDialog = class("HelpDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "HelpDialog"
local net = require("framework.cc.net.init")
local contentTxt = ""
function HelpDialog:ctor(control)
	self.control_ = control 

	local node, width, height = cc.uiloader:load("help_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.back_btn = cc.uiloader:seekNodeByName(node,"close_btn")
		:onButtonClicked(function ()
			tt.play.play_sound("click")
			self:dismiss()
		end)

	self.content_scroll = cc.uiloader:seekNodeByName(node,"content_scroll")
	-- self.content_scroll:setLayoutPadding(20,10,20,10)
	local node = display.newNode()
	local y = 440
	for i,str in ipairs(contentTxt) do
		local color = cc.c3b(146, 25, 25)
		local size = 28
		if i == 1 or i == 3 or i == 7 or i == 9 or i == 12 or i == 24 or i == 28 then
			-- local view = display.newSprite("bg/rule_bg1.png")
			y = y - 20
			-- view:setAnchorPoint(cc.p(0,1))
			-- view:setPosition(0,y+5)
			-- node:addChild(view)
			-- color = cc.c3b(255, 255, 255)
			size = 31
		end
		local view = display.newTTFLabel({
		    text = str,
		    size = size,
		    color = color,
		    align = cc.TEXT_ALIGNMENT_LEFT,
		    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		    dimensions = cc.size(780, 0)
		})
		view:setAnchorPoint(cc.p(0,1))
		view:setPosition(30,y)
		y = y - view:getContentSize().height
		node:addChild(view)
		if i == 1 or i == 3 or i == 7 or i == 9 or i == 12 or i == 24 or i == 28 then
			y = y - 20
		end
	end
	node:setContentSize(cc.size(850, 440))

	self.content_scroll:addScrollNode(node)
end

function HelpDialog:show()
	BLDialog.show(self)
	self.content_scroll:scrollTo(29, 48)
end

function HelpDialog:dismiss()
	BLDialog.dismiss(self)
end

local text = {
	'一丶简介',
	'    沧州麻将分带风和不带风，带风136张包括一万到九万，各四张；一条到九条，各四张；一筒到九筒，各四张；不带风没有东南西北中发白。',
	'二丶基本规则',
	'    1.起张牌数：庄家14张，闲家13张',
	'    2.操作：可摸牌，可碰，可杠，可钻，可胡；不可吃',
	'    3.定庄：从东风开始，逆时针顺序移动。庄家胡牌或荒庄，庄家不移动，连庄',
	'三丶胡牌和结算规则',
	'    沧州麻将分为小胡和清湖，发胡向其他三家收分；点炮，放炮玩家包赔三家。',
	'四丶算分规则',
	'    每个人的积分独立计算输赢分数 = (底分+胡牌分)*胡牌方式+杠分',
	'    底分：庄家为1分，闲家为0分',
	'五丶胡牌分',
	'    1.小胡：不是清湖中的任何一种，1分',
	'    2.清湖：',
	'         七对：七对两张一样的牌。开杠后的牌不算在手牌里，不能胡七对，2分。当有四个相同牌时，称为豪7对，再加2分。每多一个豪7对，加2分。',
	'         碰碰胡：由4副刻子（或杠），将牌组成的胡牌，1分。明杠和暗杠都算碰碰胡。',
	'         吊五万：手上有一张五万，得到一张五万可以胡牌，1分。',
	'         捉五魁：手上有四万六万，得到一张五万可以胡牌，1分。',
	'         清一色：由一种花色（饼条筒）的序数牌组成的胡牌，4分。',
	'         一条龙：由任意123456789条万筒组成的龙牌，其他牌不计，2分。',
	'         钻：摸到一张牌，手上由上下相邻的牌，即可钻牌。只有钻，则必须凑够至少三幅钻才能胡牌。每幅钻牌1分。',
	'         边：手上有1、2时，边3；手上有8、9时，边7；边牌要扣住。只要边，则必须凑够三幅边才能胡牌。每幅边牌2分。',
	'\n         庄家摸的第一张牌，不能钻也不能边。',
	'六丶胡牌方式',
	'    1.自摸：听牌后，自己摸到所听之牌，从而使自己胡牌。 x2',
	'    2.杠上胡（杠上开花），杠后刚好从后面补上要胡的牌，属于自摸。 x2',
	'    3.抢杠胡，其他人明杠时，杠的牌是其他玩家的胡牌，既可以抢杠胡，属于自摸。x2',
	'七丶杠分',
	'    发胡模式：',
	'        直杠：得杠+3，其余每人-1',
	'        补杠：得杠+3，其余每人-1',
	'        暗杠：得杠+6，其余每人-2',
	'    点炮模式：',
	'        直杠：得杠+3，放杠-3',
	'        补杠：得杠+3，其余每人-1',
	'        暗杠：得杠+6，其余每人-2',
}

contentTxt = text

return HelpDialog
