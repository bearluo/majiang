local table_mgr = require("app.mjlib.table_mgr")

local Hulib = {}

function Hulib.get_hu_info(cards, gui_index)
    local hand_cards = {}
    for i,v in ipairs(cards) do
        hand_cards[i] = v
    end
    local gui_num = 0
    if gui_index > 0 then
        gui_num = hand_cards[gui_index]
        hand_cards[gui_index] = 0
    end

    return Hulib.check(hand_cards, gui_num)
end

function Hulib.check(cards, gui_num)
	local total_need_gui = 0
	local eye_num = 0
	for i=0,3 do
		local from = i*9 + 1
		local to = from + 8
		if i == 3 then
			to = from + 6
		end
		
		local need_gui, eye = Hulib.get_need_gui(cards, from, to, i~=3, gui_num)
		print("need_gui, eye",i , need_gui, eye)
		if need_gui == -1 then
			if eye > 0 then 
				return false
			end
		else
			if need_gui then
				total_need_gui = total_need_gui + need_gui
			end
			if eye then
				eye_num = eye_num + 1
			end
		end
	end
	print("total_need_gui, eye_num, gui_num", total_need_gui, eye_num, gui_num)
	if eye_num == 0 then
		return total_need_gui + 2 <= gui_num
	elseif eye_num == 1 then
		return total_need_gui <= gui_num
	else
		return total_need_gui + eye_num - 1 <= gui_num
	end
end

function Hulib.get_need_gui(cards, from, to, chi, gui_num)
	local num = 0
	local key = 0
	for i=from,to do
		key = key * 10 + cards[i]
		num = num + cards[i]
	end
	print("get_need_gui",key)
    for i=0, gui_num do
        local yu = (num + i)%3
        if yu ~= 1 then
            local eye = (yu == 2)
            if table_mgr:check(key, i, eye, chi) then
            	print("table_mgr:check return true",i, eye)
                return i, eye
            end
            print("table_mgr:check return false")
        end
    end
    return -1,num
end

return Hulib
