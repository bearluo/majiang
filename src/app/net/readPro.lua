local readPro = {
	["login.shake"] = function(pack)
		-- 返回码	Byte	0成功， 1表需要重连和tid同时使用， 2登录错误, 3异地登录
		-- 座子id	Int	Tid 不为0， 表示需要重连
		-- Ip	String	内部使用
		-- Port	Int	内部使用
		-- Level	Short	
		local ret = {}
		ret.ret = pack:readByte()
		if ret.ret == 1 then
			ret.tid = pack:readInt()
			ret.ip = pack:readString()
			ret.port = pack:readInt()
			ret.level = pack:readShort()
		end
		return ret
	end,
	-- 客户端创建房间
	["room.create"] = function(pack)
		-- 返回码	Byte	0成功，-1 没有创建成功 
		-- 座子id	Int	Tid 不为0， 表示需要重连
		-- Index	Int	房间号索引
		-- Ip	String	内部使用
		-- Port	Int	内部使用
		-- Level	Short
		local ret = {}
		ret.ret = pack:readByte()
		if ret.ret == 0 then
			ret.tid = pack:readInt()
			ret.level = pack:readInt()
			ret.index = pack:readInt()
			ret.ip = pack:readString()
			ret.port = pack:readInt()
		end
		return ret
	end,
	-- 用户进房间
	["room.login"] = function(pack)	
		local ret = {}
		ret.ret = pack:readByte()
		if ret.ret == 0 then
			ret.tid = pack:readInt()
			ret.index = pack:readInt()
			ret.level = pack:readInt()
			ret.table_status = pack:readInt()
			local seat_id = pack:readInt()
			local room_card = pack:readInt64()
			local diamond = pack:readInt64()
			local user_status = pack:readInt()
			ret.dealer = pack:readInt()
			local sum_score = pack:readInt()
			ret.majiang_num = pack:readInt()
			ret.quan_num = pack:readInt()
			ret.ju_num = pack:readInt()
			ret.max_ju = pack:readInt()
			ret.max_quan = pack:readInt()
			ret.room_ctrl_uid = pack:readInt()
			ret.cost_num = pack:readInt()
			ret.pay_type = pack:readInt()
			ret.balance_type = pack:readInt()
			ret.fen = pack:readInt()
			ret.base_score = pack:readInt()
			ret.action_time = pack:readInt()

			ret.play = {}
			ret.play.uid = tt.owner:getUid()
			ret.play.seat_id = seat_id
			ret.play.room_card = room_card
			ret.play.diamond = diamond
			ret.play.user_status = user_status
			ret.play.pInfo = tt.owner:getClientInfo()
			ret.play.sum_score =sum_score

			ret.play.hand_num = pack:readByte()
			ret.play.hand_cards = {}
			for i=1,ret.play.hand_num do
				ret.play.hand_cards[i] = pack:readByte()
			end
			ret.play.peng_num = pack:readByte()
			ret.play.peng_cards = {}
			for i=1,ret.play.peng_num do
				ret.play.peng_cards[i] = pack:readByte()
			end

			ret.play.gang_num = pack:readByte()
			ret.play.gang_cards = {}
			for i=1,ret.play.gang_num do
				ret.play.gang_cards[i] = {}
				ret.play.gang_cards[i].id = pack:readByte()
				ret.play.gang_cards[i].status = pack:readByte()
			end

			ret.play.zhuan_num = pack:readByte()
			ret.play.zhuan_cards = {}
			for i=1,ret.play.zhuan_num do
				ret.play.zhuan_cards[i] = pack:readByte()
			end

			ret.play.bian_num = pack:readByte()
			ret.play.bian_cards = {}
			for i=1,ret.play.bian_num do
				ret.play.bian_cards[i] = pack:readByte()
			end

			ret.play.discard_num = pack:readByte()
			ret.play.discard_cards = {}
			for i=1,ret.play.discard_num do
				ret.play.discard_cards[i] = {}
				ret.play.discard_cards[i].id = pack:readByte()
				ret.play.discard_cards[i].status = pack:readByte()
			end

			ret.play.apply_status = pack:readInt()
			ret.play.apply_time = pack:readInt()
			ret.play.apply_coundtime = pack:readInt()
			
			ret.other_play_num = pack:readByte()
			ret.other_play = {}
			for j=1,ret.other_play_num do
				ret.other_play[j] = {}
				ret.other_play[j].uid = pack:readInt()
				ret.other_play[j].seat_id = pack:readInt()
				ret.other_play[j].room_card = pack:readInt64()
				ret.other_play[j].diamond = pack:readInt64()
				ret.other_play[j].user_status = pack:readInt()
				ret.other_play[j].pInfo = pack:readString()
				ret.other_play[j].sum_score = pack:readInt()
				ret.other_play[j].offline = pack:readByte()

				ret.other_play[j].hand_num = pack:readInt()

				ret.other_play[j].peng_num = pack:readByte()
				ret.other_play[j].peng_cards = {}
				for i=1,ret.other_play[j].peng_num do
					print(i,ret.other_play[j].peng_num)
					ret.other_play[j].peng_cards[i] = pack:readByte()
				end
				ret.other_play[j].gang_num = pack:readByte()
				ret.other_play[j].gang_cards = {}
				for i=1,ret.other_play[j].gang_num do
					ret.other_play[j].gang_cards[i] = {}
					ret.other_play[j].gang_cards[i].id = pack:readByte()
					ret.other_play[j].gang_cards[i].status = pack:readByte()
				end

				ret.other_play[j].zhuan_num = pack:readByte()
				ret.other_play[j].zhuan_cards = {}
				for i=1,ret.other_play[j].zhuan_num do
					ret.other_play[j].zhuan_cards[i] = pack:readByte()
				end

				ret.other_play[j].bian_num = pack:readByte()
				ret.other_play[j].bian_cards = {}
				for i=1,ret.other_play[j].bian_num do
					ret.other_play[j].bian_cards[i] = pack:readByte()
				end

				ret.other_play[j].discard_num = pack:readByte()
				ret.other_play[j].discard_cards = {}
				for i=1,ret.other_play[j].discard_num do
					ret.other_play[j].discard_cards[i] = {}
					ret.other_play[j].discard_cards[i].id = pack:readByte()
					ret.other_play[j].discard_cards[i].status = pack:readByte()
				end
				ret.other_play[j].apply_status = pack:readInt()
			end

			if ret.table_status == 1 or ret.table_status == 2 then
				-- ret.action_type = pack:readInt()
				-- ret.action_card = pack:readByte()
				ret.dice1 = pack:readInt()
				ret.dice2 = pack:readInt()
				ret.cur_action_seat_id = pack:readInt()
				ret.last_card = pack:readInt()
				ret.last_seat_id = pack:readInt()
			end
		end
		return ret
	end,
	["room.check"] = function(pack)
		-- 返回码	Byte	0成功，-1 没有创建成功 
		-- 座子id	Int	Tid 不为0， 表示需要重连
		-- Index	Int	房间号索引
		-- Ip	String	内部使用
		-- Port	Int	内部使用
		-- Level	Short
		local ret = {}
		ret.ret = pack:readByte()
		if ret.ret == 0 then
			ret.tid = pack:readInt()
			ret.level = pack:readInt()
			ret.index = pack:readInt()
			ret.ip = pack:readString()
			ret.port = pack:readInt()
		end
		return ret
	end,
	["room.userJoin"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.seat_id = pack:readInt()
		ret.room_card = pack:readInt64()
		ret.diamond = pack:readInt64()
		ret.pInfo = pack:readString()
		return ret
	end,
	["room.logout"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.ret = pack:readByte()
		return ret
	end,
	["room.ready"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.ret = pack:readByte()
		return ret
	end,
	["room.userReady"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.uid = pack:readInt()
		return ret
	end,
	["room.userLeave"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.uid = pack:readInt()
		ret.seat_id = pack:readInt()
		return ret
	end,
	["room.start"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.cur_quan = pack:readInt()
		ret.cur_ju = pack:readInt()
		ret.cur_dealer_uid =pack:readInt()
		ret.dice1 = pack:readInt()
		ret.dice2 = pack:readInt()
		return ret
	end,
	["room.deal"] = function(pack)
		-- 返回码	Byte	0成功
		local ret = {}
		ret.uid = pack:readInt()
		ret.cur_dealer =pack:readInt()
		ret.num =pack:readInt()
		ret.cards = {}
		for i=1,ret.num do
			ret.cards[i] = pack:readByte()
		end
		return ret
	end,
	["room.dealOne"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.card =pack:readByte()
		ret.isFirst =pack:readInt()
		return ret
	end,
	["room.userDiscard"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.card =pack:readByte()
		ret.pre_action =pack:readInt()
		return ret
	end,
	["room.userAction"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.action =pack:readInt()
		ret.card =pack:readByte()
		ret.card_seat_id =pack:readInt()
		return ret
	end,
	["room.noticeAction"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.action =pack:readInt()
		ret.card =pack:readByte()
		return ret
	end,
	["room.actionFail"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.action =pack:readInt()
		ret.card =pack:readByte()
		return ret
	end,
	["room.roomClose"] = function(pack)
		local ret = {}
		ret.ret = pack:readByte()
		ret.start_time = pack:readInt()
		ret.player_num = pack:readInt()
		ret.players = {}
		for i=1,ret.player_num do
			local player = {}
			player.uid = pack:readInt()
			player.zi_mo_num = pack:readInt()
			player.jie_pao_num = pack:readInt()
			player.fang_pao_num = pack:readInt()
			player.gang_num = pack:readInt()
			player.hu_num = pack:readInt()
			ret.players[i] = player
		end
		return ret
	end,
	["room.gameOver"] = function(pack)
		local ret = {}
		ret.gameover_type = pack:readByte()
		ret.player_num = pack:readInt()
		ret.player = {}
		for i=1,ret.player_num do
			local player = {}
			player.uid = pack:readInt()
			player.hand_num = pack:readByte()
			player.hand_cards = {}
			for i=1,player.hand_num do
				player.hand_cards[i] = pack:readByte()
			end

			player.an_gang_score = pack:readInt()
			player.ming_gang_score = pack:readInt()
			player.bu_gang_score = pack:readInt()
			player.sum_score = pack:readInt()
			player.cur_score = pack:readInt()

			player.zi_mo_num = pack:readInt()
			player.jie_pao_num = pack:readInt()
			player.fang_pao_num = pack:readInt()
			player.gang_num = pack:readInt()
			player.hu_num = pack:readInt()

			ret.player[i] = player
		end
		if ret.gameover_type == 1 or ret.gameover_type == 2 then
			local winData = {}
			winData.uid = pack:readInt()
			winData.win_type = pack:readByte() -- 1放炮胡，2自摸胡
			winData.is_qiang_gang_hu = pack:readByte() -- 1是，0不是
			winData.is_gang_hu = pack:readByte() -- 1是，0不是
			winData.hu_card_id = pack:readByte() -- 1是，0不是
			winData.pao_uid = pack:readInt() -- 没有就是-1
			winData.zuan_num = pack:readInt() -- 
			winData.bian_num = pack:readInt() -- 
			winData.is_7_dui_hu = pack:readByte() -- 1是，0不是
			winData.is_peng_peng_hu = pack:readByte() -- 1是，0不是
			winData.is_diao_5_wan = pack:readByte() -- 1是，0不是
			winData.is_zhuo_5_wan = pack:readByte() -- 1是，0不是
			winData.is_qing_yi_se = pack:readByte() -- 1是，0不是
			winData.is_yi_tiao_long = pack:readByte() -- 1是，0不是
			ret.winData = winData
		end
		return ret
	end,
	["room.sendMsg"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.msg = json.decode(pack:readString())
		return ret
	end,
	["room.serverError"] = function(pack)
		local ret = {}
		ret.code = pack:readInt()
		return ret
	end,
	["room.onRoomOverApply"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.total_countdown = pack:readInt()
		ret.countdown = pack:readInt()
		return ret
	end,
	["room.onUserRoomOverApply"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.apply_type = pack:readByte()
		return ret
	end,
	["php.broadcast"] = function(pack)
		local ret = {}
		ret.content = pack:readString()
		ret.msg_type = pack:readInt()
		return ret
	end,
	["server.gemUpdate"] = function(pack)
		local ret = {}
		ret.player_num = pack:readInt()
		ret.players = {}
		for i=1,ret.player_num do
			local player = {}
			player.uid = pack:readInt()
			player.gold = pack:readInt64()
			player.change_gold = pack:readInt64()
			player.gem = pack:readInt64()
			player.change_gem = pack:readInt64()
			ret.players[i] = player
		end
		return ret
	end,
	["room.getRecord"] = function(pack)
		local ret = {}
		ret.cur_page = pack:readInt() + 1
		ret.ju_page_num = pack:readInt() -- 最大数
		ret.max_page = pack:readInt()
		ret.user_num = pack:readInt()
		dump(ret)
		ret.players = {}
		for i=1,ret.user_num do
			local player = {}
			player.uid = pack:readInt()
			local record_num = pack:readInt()
			player.records = {}
			for j=1,record_num do
				local record = {}
				record.an_gang_score = pack:readInt()
				record.ming_gang_score = pack:readInt()
				record.bu_gang_score = pack:readInt()
				record.cur_score = pack:readInt()

				record.zuan_num = pack:readInt() -- 
				record.bian_num = pack:readInt() -- 
				record.is_7_dui_hu = pack:readByte() -- 1是，0不是
				record.is_peng_peng_hu = pack:readByte() -- 1是，0不是
				record.is_diao_5_wan = pack:readByte() -- 1是，0不是
				record.is_zhuo_5_wan = pack:readByte() -- 1是，0不是
				record.is_qing_yi_se = pack:readByte() -- 1是，0不是
				record.is_yi_tiao_long = pack:readByte() -- 1是，0不是
				record.is_fang_pao = pack:readByte() -- 1是，0不是

				player.records[j] = record
			end

			ret.players[i] = player
		end
		return ret
	end,
	["room.tiRen"] = function(pack)
		local ret = {}
		ret.ret = pack:readByte() -- 0成功，1不是房主，2此人不存在，3游戏已经开始不能踢人了
		ret.uid = pack:readInt()
		ret.target_uid = pack:readInt()
		return ret
	end,
	["room.onTiRenBroadcast"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.target_uid = pack:readInt()
		return ret
	end,
	["room.onStandUpBroadcast"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.seat_id = pack:readInt()
		return ret
	end,
	["room.onUserOfflineBroadcast"] = function(pack)
		local ret = {}
		ret.uid = pack:readInt()
		ret.offline = pack:readByte()
		return ret
	end,

}


return readPro