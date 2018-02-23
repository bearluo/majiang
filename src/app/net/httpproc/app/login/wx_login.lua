-- wx_login 登录
local proc = {}

function proc.request(cmd,params)
    local data = {
        openid = params.open_id, 
        access_token = params.access_token, 
        version = kVersion, --token
    }
    tt.ghttp.post(cmd,data)
    print("login.wx");
end

function proc.response(ret, params )
	print("login.wx init response：",ret, json.encode(params))
    if ret ~= 200 then
        if ret ~= 0 then
            tt.show_msg( string.format("登陆失败 ret %d  error %s",ret,str))
        end
        return
    else
        tt.http_conf.sid = 101
        local data = json.decode(params.data)

        if params.ret ~= 0 then
            tt.show_msg( string.format("登陆失败 ret %d  error %s",params.ret or -1,params.msg or ""))
        else
            --local data = rep.data
            tt.owner.uid_ = tonumber(data.user_id)
            tt.owner.nick_ = data.wx_name
            tt.owner.img_url_ = string.urldecode(data.wx_avatar)
            tt.owner.sex_ = tonumber(data.sex)
            tt.owner:setGem(tonumber(data.diamond))
            tt.owner:setJoinSn(tonumber(data.join_sn))
            tt.owner:setSales(tonumber(data.sales))
            tt.owner:setRole(tonumber(data.role))
            tt.owner:setIp(data.ip)
            local is_freeze = tonumber(data.is_freeze)
            if tonumber(data.is_maintain) == 1 then
                if data.message and data.message ~= "" then
                    tt.show_msg(data.message)
                else
                    tt.show_msg("服务器维护中")
                end
            elseif is_freeze == 1 then
                local host = data.service_ip
                local port = data.service_port 
                print("server host:", host , "port:", port);
                tt.gsocket:connect(host,port);
            else
                tt.show_msg("您的賬號已經被封，請聯係GM" )
            end
        end
        return data
    end

end

return proc