--
-- Author: shineflag
-- Date: 2017-04-04 19:01:27
--

local GameState = require("framework.cc.utils.GameState")
local function load_data()
    local file_key = "abcd" 
    GameState.init(function(param)

        local encrypt = "abcd" 
    	local return_val = nil 

    	if param.errorCode then
    		print("error:", param.errorCode)
    	else
    		--cryto 
            -- dump(param.values,14,14)
    		if param.name == "save" then 
    			local str  = json.encode(param.values)
                if str == nil then print("false") end
                if encrypt then 
    			    str=crypto.encryptXXTEA(str, encrypt)
                end
    			return_val = {data = str}
    		elseif param.name == "load" then 
    			local str = param.values.data 
                if encrypt then 
                    str = crypto.decryptXXTEA( str , encrypt)
                end
    			print("load:",str)
    			return_val = json.decode(str)
    		end
        end
        return return_val
    end,"data.dat",file_key)

    tt.game_data = GameState.load() or  {}
    -- dump(tt.game_data)
    tt.game_data.request_ship_data = tt.game_data.request_ship_data or {}
    tt.game_data.cacheData = tt.game_data.cacheData or {}
    tt.game_data.game_config = tt.game_data.game_config or {}
    tt.game_data.game_download_url_config = tt.game_data.game_download_url_config or {}
    tt.game_data.open_config = tt.game_data.open_config or {}
    tt.game_data.history_records = tt.game_data.history_records or {}
    tt.imageCacheManager = require("app.utils.imageCacheManager")
    tt.imageCacheManager.init()
end

local function save_data()
	return GameState.save(tt.game_data)
end

load_data()

local NativeData = {}

function NativeData.saveOpenUDID(id)
    tt.game_data.openUdid = id
    save_data()
end

function NativeData.saveLoginData(loginType,params)
    tt.game_data.preLoginType = loginType
    tt.game_data.preLoginParams = params
    save_data()
end

function NativeData.saveRequestShipData(params)
    tt.game_data.request_ship_data[params.orderid .. ""] = params
    save_data()
end

function NativeData.clearRequestShipData(orderid)
    tt.game_data.request_ship_data[orderid .. ""] = nil
    save_data()
end

function NativeData.getRequestShipData()
    return tt.game_data.request_ship_data
end

function NativeData.saveShopInfo(version,data)
    tt.game_data.shop_info = data
    tt.game_data.shop_ver = version
    save_data()
end

function NativeData.saveCacheDownImageData(data)
    tt.game_data.cacheData = data
    save_data()
end

function NativeData.saveMusicBtnStatus(status)
    tt.game_data.music_btn_status = status
    save_data()
end

function NativeData.saveSoundBtnStatus(status)
    tt.game_data.sound_btn_status = status
    save_data()
end

function NativeData.saveShockBtnStatus(status)
    tt.game_data.shock_btn_status = status
    save_data()
end

function NativeData.savePushBtnStatus(status)
    tt.game_data.push_btn_status = status
    save_data()
end

function NativeData.saveGameConfig(config)
    tt.game_data.game_config = config
    save_data()
end

function NativeData.getGameConfig()
    return tt.game_data.game_config
end

function NativeData.saveGameDownloadUrlConfig(config)
    tt.game_data.game_download_url_config = config
    save_data()
end

function NativeData.getGameDownloadUrlConfig()
    return tt.game_data.game_download_url_config
end

function NativeData.saveSelectBaseScoreIndex(index)
    tt.game_data.base_score_index = index
    save_data()
end

function NativeData.getSelectBaseScoreIndex()
    return tt.game_data.base_score_index or 1
end

function NativeData.saveOpenConfig(config)
    tt.game_data.open_config = config
    save_data()
end

function NativeData.getOpenConfig()
    return tt.game_data.open_config
end


function NativeData.saveHistoryRecord(data) 
    local uid = tt.owner:getUid() .. ""
    if not tt.game_data.history_records[uid] then tt.game_data.history_records[uid] = {} end
    table.insert(tt.game_data.history_records[uid],data)
    while #tt.game_data.history_records[uid] > 20 do
        table.remove(tt.game_data.history_records[uid],1)
    end
    save_data()
end

function NativeData.getHistoryRecords()
    local uid = tt.owner:getUid() .. ""
    return tt.game_data.history_records[uid] or {}
end

return NativeData