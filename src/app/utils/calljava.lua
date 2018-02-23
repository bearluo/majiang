--
-- Author: shineflag
-- Date: 2017-06-02 16:50:14
--


local TAG = "CALLJAVA"

--订单获取成 将调第三方支付
local function purchase( data)
	tt.log.d(TAG, "pinfo[%s] orderid[%s]",data.pinfo,data.orderid)
	local pinfo = json.decode(data.pinfo)

	if device.platform == "windows" then
		local params = {
			gorderid = "gorderid",
			purdata = "purdata",
			signature = "signature",
			orderid = data.orderid,
			pid = data.pid 
		}
		tt.gsocket.request("shop.gconsume",{params= json.encode(params)})  --通知服务器 google支付并消费成功
		return 
	elseif device.platform ~= "android" then
		return
	end

	local args = {
		pinfo.sku,  --google商品id string
		data.orderid     --订单号 string
	}

	local class_name = "com/woyao/gpay/GPayLuaCall"
	local method_name = "Purchase"
	local method_sigs = "(Ljava/lang/String;Ljava/lang/String;)V"  --函数签名

	local ok = luaj.callStaticMethod(class_name,method_name,args,method_sigs)
end

local calljava = {}
calljava.purchase = purchase


return calljava

