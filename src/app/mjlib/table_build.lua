local mgr = require("app.mjlib.table_mgr")

local path = device.writablePath .. "res/tab/"
local TableBuild = {}

function TableBuild.run()
	TableBuild.printTable()
	TableBuild.printEyeTable()
	TableBuild.printFengTable()
	TableBuild.printFengEyeTable()
	TableBuild.BuildGui("table_%d.txt")
	TableBuild.BuildGui("eye_table_%d.txt")
	TableBuild.BuildGui("feng_table_%d.txt")
	TableBuild.BuildGui("feng_eye_table_%d.txt")
end

function TableBuild.BuildGui(fileFormat)
 	for i=1,8 do
 		local tbl = {}
 		local save_tbl = {}
 		mgr:_load(path..string.format(fileFormat,i-1), tbl)
 		for key,v in pairs(tbl) do
 			local str = string.reverse(tostring(key))
 			local offset = 1
 			for cindex=1,#str do
 				local c = string.sub(str,cindex,cindex)
 				local num = tonumber(c)
 				if num > 0 then
 					save_tbl[key-offset] = true
 				end
 				offset = offset * 10
 			end
 		end
 		mgr:_dump(path..string.format(fileFormat,i), save_tbl)
 	end
end

-- 减枝表
local kmap = {}
--输出不带将顺子胡
function TableBuild.printTable()
	local majiang={}
	local writer = io.open(path .. "table_0.txt","w")
	local hand = {}
	for i=0x01,0x09 do
		hand[i] = 0
	end
	local search
	local hash_map = {}
	search = function(hand_cards,index,cards_num)
		if cards_num == 3 or cards_num == 6 or cards_num == 9 or cards_num == 12 then
			if TableBuild.hu(hand_cards,kmap) then
				local str = TableBuild.printNumT(hand_cards)
				if not hash_map[str] then
					hash_map[str] = true
	    			writer:write(str,'\n')
	    			-- writer:write(TableBuild.printT(hand_cards),'\n')
    			end
			end
		end
		if index > 0x09 or cards_num > 12 then return end
		for num=1,4 do
			hand_cards[index] = num
			search(hand_cards,index+1,cards_num+num)
		end
		hand_cards[index] = 0
		search(hand_cards,index+1,cards_num)
	end
	search(hand,0x01,0)
	writer:flush()
	writer:close()
end
--输出带将顺子胡
function TableBuild.printEyeTable()
	local majiang={}
	local writer = io.open(path .. "eye_table_0.txt","w")
	local hand = {}
	for i=0x01,0x09 do
		hand[i] = 0
	end
	local search
	local hash_map = {}
	search = function(hand_cards,index,cards_num)
		if cards_num == 2 or cards_num == 5 or cards_num == 8 or cards_num == 11 or cards_num == 14 then
			if TableBuild.pingHu(hand_cards,kmap) then
    			local str = TableBuild.printNumT(hand_cards)
				if not hash_map[str] then
					hash_map[str] = true
	    			writer:write(str,'\n')
	    			-- writer:write(TableBuild.printT(hand_cards),'\n')
    			end
			end
		end
		if index > 0x09 or cards_num > 14 then return end
		for num=1,4 do
			hand_cards[index] = num
			search(hand_cards,index+1,cards_num+num)
		end
		hand_cards[index] = 0
		search(hand_cards,index+1,cards_num)
	end
	search(hand,0x01,0)
	writer:flush()
	writer:close()
end

--输出不带将风顺子胡
function TableBuild.printFengTable()
	local majiang={}
	local writer = io.open(path .. "feng_table_0.txt","w")
	local hand = {}
	for i=0x31,0x37 do
		hand[i] = 0
	end
	local search
	local hash_map = {}
	search = function(hand_cards,index,cards_num)
		if cards_num == 3 or cards_num == 6 or cards_num == 9 or cards_num == 12 then
			if TableBuild.hu(hand_cards,kmap) then
				local params = {}
				for i,v in pairs(hand_cards) do
					params[i-0x30] = v
				end
				local str = TableBuild.printNumT(params)
				if not hash_map[str] then
					hash_map[str] = true
	    			writer:write(str,'\n')
	    			-- writer:write(TableBuild.printT(hand_cards),'\n')
    			end
			end
		end
		if index > 0x37 or cards_num > 12 then return end
		for num=1,4 do
			hand_cards[index] = num
			search(hand_cards,index+1,cards_num+num)
		end
		hand_cards[index] = 0
		search(hand_cards,index+1,cards_num)
	end
	search(hand,0x31,0)
	writer:flush()
	writer:close()
end
--输出带将顺子胡
function TableBuild.printFengEyeTable()
	local majiang={}
	local writer = io.open(path .. "feng_eye_table_0.txt","w")
	local hand = {}
	for i=0x31,0x37 do
		hand[i] = 0
	end
	local search
	local hash_map = {}
	search = function(hand_cards,index,cards_num)
		if cards_num == 2 or cards_num == 5 or cards_num == 8 or cards_num == 11 or cards_num == 14 then
			if TableBuild.pingHu(hand_cards,kmap) then
				local params = {}
				for i,v in pairs(hand_cards) do
					params[i-0x30] = v
				end
				local str = TableBuild.printNumT(params)
				if not hash_map[str] then
					hash_map[str] = true
	    			writer:write(str,'\n')
	    			-- writer:write(TableBuild.printT(hand_cards),'\n')
    			end
			end
		end
		if index > 0x37 or cards_num > 14 then return end
		for num=1,4 do
			hand_cards[index] = num
			search(hand_cards,index+1,cards_num+num)
		end
		hand_cards[index] = 0
		search(hand_cards,index+1,cards_num)
	end
	search(hand,0x31,0)
	writer:flush()
	writer:close()
end

function TableBuild.printNumT(keys)
	return tonumber(table.concat(keys,""))
end

function TableBuild.printT(keys)
	local card_values = {}
	for key,num in pairs(keys) do
		for i=1,num do
			table.insert(card_values,key)
		end
	end
	table.sort(card_values)
	return table.concat(card_values,",")
end

function TableBuild.pingHu(keys,map)
	local map = map or {}
	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if keys[index] and keys[index] >= 2 then
				keys[index] = keys[index] - 2
				if TableBuild.hu(keys,map) then
					keys[index] = keys[index] + 2
					return true
				else
					map[TableBuild.printT(keys)] = false
				end
				keys[index] = keys[index] + 2
			end
		end
	end

	for i=0x31,0x37,0x01 do
		local index = i
		if keys[index] and keys[index] >= 2 then
			keys[index] = keys[index] - 2
			if TableBuild.hu(keys,map) then
				keys[index] = keys[index] + 2
				return true
			else
				map[TableBuild.printT(keys)] = false
			end
			keys[index] = keys[index] + 2
		end
	end
end

function TableBuild.hu(keys,map)
	local tab = clone(keys)
	local map = map or {}
	if map[TableBuild.printT(tab)] == false then return false end
	for j=0x00,0x20,0x10 do
		for i=0x01,0x09,0x01 do
			local index = bit.bor(i,j)
			if tab[index] and tab[index] > 0 then
				if tab[index] == 1 then
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 1
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
					else
						return false
					end
				elseif tab[index] == 2 then 
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 1
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
						if TableBuild.hu(tab) then 
							return true 
						else
							map[TableBuild.printT(tab)] = false
						end
						tab[index] = tab[index] + 1
						tab[index+1] = tab[index+1] + 1
						tab[index+2] = tab[index+2] + 1
					else
						return false
					end
				elseif tab[index] == 3 then
					tab[index] = tab[index] - 3
				elseif tab[index] == 4 then
					if tab[index+1] and tab[index+1] > 0 and tab[index+2] and tab[index+2] > 0 then
						tab[index] = tab[index] - 4
						tab[index+1] = tab[index+1] - 1
						tab[index+2] = tab[index+2] - 1
					else
						return false
					end
				end
			end
		end
	end

	for i=0x31,0x37,0x01 do
		local index = i
		if tab[index] then
			if tab[index] == 1 then
				return false
			elseif tab[index] == 2 then 
				return false
			elseif tab[index] == 3 then
				tab[index] = tab[index] - 3
			elseif tab[index] == 4 then
				return false
			end
		end
	end
	return true
end

return TableBuild