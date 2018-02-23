--
-- Author: bearluo
-- Date: 2017-05-27
--
local BLDialog = require("app.ui.BLDialog")
local TotalAccountsDialog = class("TotalAccountsDialog", function(...)
	return BLDialog.new(...)
end)

local TAG = "TotalAccountsDialog"
local net = require("framework.cc.net.init")
local MajiangGroup = require("app.ui.MajiangGroup")
local Majiang = require("app.ui.Majiang")
local CircleClip = require("app.ui.CircleClip")

function TotalAccountsDialog:ctor(control)
	self.mCtrl = control 

	local node, width, height = cc.uiloader:load("accounts_2_dialog.json")
	self:addChild(node)
	self.root_ = node
	self:setContentSize(cc.size(width,height))

	self.mContentBg = cc.uiloader:seekNodeByName(node,"content_bg")

	self.mCancelBtn = cc.uiloader:seekNodeByName(node,"cancel_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				if self.mIsReView then
					self:dismiss()
				else
					self.mCtrl:logout()
				end
			end)
	self.mShareBtn = cc.uiloader:seekNodeByName(node,"share_btn")
		:onButtonClicked(function()
				tt.play.play_sound("click")
				tt.makeScreen(function ( outfile )
					local ok,errorMsg = tt.WxHelper.shareBitmapToWx(outfile,"") 
					if not ok then
						tt.show_msg(errorMsg)
					end
		    	end)
			end)

	local openConfig = tt.nativeData.getOpenConfig()
	if tonumber(openConfig.open_share) == 0 or tonumber(openConfig.check_status) == 1 then
		self.mShareBtn:setVisible(false)
	end

	self.mItems = {}
	for i=1,4 do
		self.mItems[i] = cc.uiloader:seekNodeByName(node,"user_"..i)
	end

	self:setBackEvent(function() return true end)
end

function TotalAccountsDialog:setReView(flag)
	self.mIsReView = flag
end

function TotalAccountsDialog:setUserInfo(seat_id,player)
	if not player then return end
	local view = self.mItems[seat_id]
	local pinfo  = json.decode(player.pInfo)
	local name = cc.uiloader:seekNodeByName(view,"name_txt")
	tt.limitStr(name,pinfo.name,144)
	cc.uiloader:seekNodeByName(view,"id_txt"):setString( string.format("ID:%d",player.uid))
	local head_bg = cc.uiloader:seekNodeByName(view,"head_bg")
	print('TotalAccountsDialog:setSeatInfo',pinfo.img_url)
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

function TotalAccountsDialog:setPlayData(seat_id,playData,score)
	local view = self.mItems[seat_id]
	cc.uiloader:seekNodeByName(view,"zi_mo_txt"):setString(playData.zi_mo_num)
	cc.uiloader:seekNodeByName(view,"jie_pao_txt"):setString(playData.jie_pao_num)
	cc.uiloader:seekNodeByName(view,"dian_pao_txt"):setString(playData.fang_pao_num)
	cc.uiloader:seekNodeByName(view,"gang_pai_txt"):setString(playData.gang_num)
	cc.uiloader:seekNodeByName(view,"hu_pai_txt"):setString(playData.hu_num)

	cc.uiloader:seekNodeByName(view,"sum_score_txt"):removeAllChildren()
	cc.uiloader:seekNodeByName(view,"sum_score_txt"):setContentSize(cc.size(0,0))
	if score > 0 then
		-- local node,imgs = tt.getBitmapStrAscii("number/zongjiesuan_green_%d.png","+"..score)
		local node = display.newTTFLabel({
			    text = "+"..score,
			    size = 72,
			    color = cc.c3b(34,168,13), -- 使用纯红色
			})
		tt.linearlayout(cc.uiloader:seekNodeByName(view,"sum_score_txt"),node,0,-35)
	else
		if score == 0 then
			-- local node,imgs = tt.getBitmapStrAscii("number/zongjiesuan_green_%d.png",""..score)
			local node = display.newTTFLabel({
				    text = ""..score,
				    size = 72,
				    color = cc.c3b(34,168,13), -- 使用纯红色
				})
			tt.linearlayout(cc.uiloader:seekNodeByName(view,"sum_score_txt"),node,0,-35)
		else
			-- local node,imgs = tt.getBitmapStrAscii("number/zongjiesuan_red_%d.png",""..score)
			local node = display.newTTFLabel({
				    text = ""..score,
				    size = 72,
				    color = cc.c3b(252,3,97), -- 使用纯红色
				})
			tt.linearlayout(cc.uiloader:seekNodeByName(view,"sum_score_txt"),node,0,-35)
		end
	end
end

function TotalAccountsDialog:setStartTime(time)
	time = time or 0
	cc.uiloader:seekNodeByName(self.root_,"time_txt"):setString(os.date("%Y/%m/%d/%H:%M",time))
end

function TotalAccountsDialog:setRuleTxt(str)
	str = str or ""
	str = string.gsub(str,"，",",")
	cc.uiloader:seekNodeByName(self.root_,"rule_txt"):setString(str)
end

function TotalAccountsDialog:setRoomIndex(index)
	index = index or 0
	cc.uiloader:seekNodeByName(self.root_,"room_id"):setString(string.format("房号：%06d",index))
end

function TotalAccountsDialog:setCurQuanJu(quan, ju)
	quan = quan or 0
	ju = ju or 0
	cc.uiloader:seekNodeByName(self.root_,"play_quan_ju_txt"):setString(string.format("圈/局：%d圈/%d局",quan, ju))
end

function TotalAccountsDialog:show()
	BLDialog.show(self)
	self.mContentBg:scale(1)
	-- self.mContentBg:stopAllActions()
	-- self.mContentBg:setPosition(640,1080)
	-- transition.execute(self.mContentBg, cc.MoveTo:create(0.4, cc.p(640,360)), {
	-- 	    easing = "In",
	--     })
end

function TotalAccountsDialog:dismiss()
	-- self.mContentBg:stopAllActions()
	-- self.mContentBg:scale(1)
	-- transition.execute(self.mContentBg, cc.MoveTo:create(0.4, cc.p(640,1080)), {
	-- 		easing = "Out",
	-- 	    onComplete = function()
	-- 	    	if not tolua.isnull(self) then
					BLDialog.dismiss(self)
				-- end
		   --  end,
	    -- })
end

return TotalAccountsDialog
