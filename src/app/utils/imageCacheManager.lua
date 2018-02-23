--[[
	下载图片的缓存管理器
	@author xujh
]]
require "lfs"

local function rmdir(path)
    print("os.rmdir:", path)
    if io.exists(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

local net = require("framework.cc.net.init")

local ImageCacheManager = {}

local function getCurrentMillis()
	return net.SocketTCP.getTime()
end

-- 图片缓存信息表，包括下载图片URL对应的md5值和最后更新时间
local cacheData = tt.game_data.cacheData

-- 初始化GameState，存储缓存图片相关信息
function ImageCacheManager:init()
	local path = device.writablePath.."cache/" --获取本地存储目录

	if table.nums(cacheData) <= 0 then
		rmdir(path)
	end

	if not io.exists(path) then
		lfs.mkdir(path) --目录不存在，创建此目录
	end
end

--[[
	根据图片的md5值判断是否存在在缓存表中
	@param 图片的md5值
	@return 存在：true以及所在的位置，不存在：false
]]
function ImageCacheManager:exist(md5)
	local path = device.writablePath.."cache/" --获取本地存储目录
	for i = 1, #cacheData do
		if cacheData[i].md5 == md5 then
			if io.exists(path..md5..".png") then
				return true, i
			else
				table.remove(cacheData, i)
				return false
			end
		end
	end
	return false
end

--[[
	修改图片在缓存表中的最后更新时间
	@param md5:图片的md5值, position:图片在缓存表中的位置
]]
function ImageCacheManager:updateCacheTime(md5, position)
	if cacheData[position].md5 == md5 then
		table.remove(cacheData, position)
		self:insertCacheData(md5)
		-- dump(cacheData, "update")
	else
		print("ImageCacheManager updateCacheTime ERROR!")
	end
end

--[[
	根据缓存目录里的图片来创建精灵
	@param url 缓存图片的URL地址
		   x:精灵横向坐标值，y:精灵纵向坐标值
	@return 若缓存表中存在对应的md5值，返回创建的精灵对象
]]
function ImageCacheManager:newCacheSprite(url, x, y)
	local md5 = crypto.md5(url, false)
	local isExist, position = self:exist(md5)
	if isExist then
		self:updateCacheTime(md5, position)
		local filename = device.writablePath .. "cache/" .. md5 .. ".png"

		local inp = assert(io.open(filename, "rb"))
		local str = inp:read("*all")
		local data = {string.byte(str,1,5)}
		if data[1] == 71 and data[2] == 73 and data[3] == 70 and (data[5] == 55 or data[5] == 57) then
			-- gif
		else
			return display.newSprite(filename, x, y)
		end
	end
end

--[[
	向图片缓存表中插入数据
	@param 图片的md5值
]]
function ImageCacheManager:insertCacheData(md5)
	local data = {}
	data.time = getCurrentMillis()
	data.md5 = md5
	while table.nums(cacheData) > 100 do
		-- 超过缓存上限，清除第一个元素（通常最久未更新时间戳）
		local rem = table.remove(cacheData, 1)
		os.remove(device.writablePath .. "cache/" .. rem.md5 .. ".png")
	end
	table.insert(cacheData, data)
	tt.nativeData.saveCacheDownImageData(cacheData)
end

--[[
	下载缓存图片
	@param url 下载图片的URL地址
		   callback 调用下载处的回调函数地址
]]
function ImageCacheManager:downloadImage(url, callback)
	local md5 = crypto.md5(url, false)
	if not self:exist(md5) then
		local request = network.createHTTPRequest(function (event)
			local ok = (event.name == "completed")
			local request = event.request
			if not ok then
				if request:getErrorCode() ~= 0 then
					printInfo("%s %s",request:getErrorCode(), request:getErrorMessage())
				end
        		return
			end
			local code = request:getResponseStatusCode()
    		if code ~= 200 then
        		-- 请求结束，但没有返回 200 响应代码
        		print(code)
        		return
    		end
    		local filename = md5 .. ".png"
    		local path = device.writablePath .. "cache/" .. filename
    		printInfo("saveResponseData:%s",path)
    		request:saveResponseData(path)
			local isExist, position = self:exist(md5)
			if isExist then
				self:updateCacheTime(md5, position)
			else
				self:insertCacheData(md5)
			end
			if callback then callback(url) end
		end, url, "GET")
		request:setTimeout(20)
		request:start()
	else
		printInfo("The %s has downloaded.", url)
	end
end


--[[
	根据需要删除缓存图片，释放存储空间
]]
function ImageCacheManager:gcCache()
	for i = #cacheData, 1, -1 do
		local recordTime = cacheData[i].time
		local currentTime = getCurrentMillis()
		if currentTime - recordTime > 7*24*3600 then
			os.remove(device.writablePath .. "cache/" .. cacheData[i].md5 .. ".png")
			table.remove(cacheData, i)
		end
	end
	tt.nativeData.saveCacheDownImageData(cacheData)
end

return ImageCacheManager