--
-- Author: shineflag
-- Date: 2017-02-15 11:18:54
--
--全局的事件分发机制
local evt = {
	EVT_HTTP_RESP = "EVT_HTTP_RESP",

	SOCKET_CONNECTED = "SOCKET_CONNECTED",
	SOCKET_DATA = "SOCKET_DATA",

	NATIVE_EVENT = "NATIVE_EVENT",

	EVENT_RECONNECTING = "EVENT_RECONNECTING",
	EVENT_RECONNECT_FAILURE = "EVENT_RECONNECT_FAILURE",
}
cc(evt):addComponent("components.behavior.EventProtocol"):exportMethods()

return evt 
