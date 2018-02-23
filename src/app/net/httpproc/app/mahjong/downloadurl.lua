-- downloadurl
local proc = {}

function proc.request(cmd,params)
    local data = {
        user_id = tt.owner:getUid(), 
    }
    dump(data)
    tt.ghttp.post(cmd,data)
    print("downloadurl");
end

function proc.response(ret, params )
	print("downloadurl init response：",ret, json.encode(params))
    if ret ~= 200 then
        if ret ~= 0 then
            -- tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return
    else
        local data = params
        data.data = json.decode(params.data)

        return data
    end

end

return proc