local table_mgr = require("app.mjlib.table_mgr")
local hulib = require("app.mjlib.hulib")
local table_build = require("app.mjlib.table_build")
local helper = {}

local SUIT_WAN 		= 0x00   --万
local SUIT_TONG    	= 0x10   --筒
local SUIT_TIAO     = 0x20   --条
local SUIT_FENG     = 0x30   --风
local SUIT_ZI     	= 0x40   --字

local index2key = {
	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,
	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,
	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,
	0x31,0x32,0x33,0x34,
	0x41,0x42,0x43,
}

local key2index = {}
for index,key in ipairs(index2key) do
	key2index[key]=index
end

local function test_one()
    -- 6万6万6万4筒4筒4筒4条4条5条5条6条6条发发
    local t = {
        2,3,0,   0,0,0,   0,0,0,
        0,0,0,   1,1,1,   0,0,0,
        0,0,0,   0,1,1,   1,0,0,
        0,0,0,0, 0,0,0}
    if not hulib.get_hu_info(t, 0) then
        print("测试失败")
    end
end

function helper:test()
    -- local start = os.time()
    -- math.randomseed(os.time())
    -- local count = 1
    -- for i=1,count do
    -- 	print(i)
    --     test_one()
    -- end
    -- print("测试",count,"次,耗时",os.time() - start)
    -- table_build.run()
end


function helper:checkHu(keys,gui_key)
	local t = {
        0,0,0,   0,0,0,   0,0,0,
        0,0,0,   0,0,0,   0,0,0,
        0,0,0,   0,0,0,   0,0,0,
        0,0,0,0, 
        0,0,0,
    }
	for key,num in pairs(keys) do
		t[key2index[key]] = num
	end
	return hulib.get_hu_info(t, key2index[gui_key] or 0)
end

function helper:init()
    table_mgr:init()
    table_mgr:load()
end
helper:init()
return helper