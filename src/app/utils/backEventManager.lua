local BackEventManager = {}
local queue = {}
local queueIndex = 0

function BackEventManager.registerCallBack(func)
	queueIndex = queueIndex + 1
	queue[queueIndex] = func
	return queueIndex
end

function BackEventManager.unregisterCallBack(index)
	queue[index] = nil
	while queue[queueIndex] == nil and queueIndex > 0 do
		queueIndex = queueIndex - 1
	end
end

function BackEventManager.onCallBackEvent(evt)
	print("BackEventManager.onCallBackEvent",queueIndex)
	dump(evt)
	dump(queue)
	for i=queueIndex,1,-1 do
		if queue[i] then
			if queue[i](evt) then break end
		end
	end
end

function BackEventManager.addBackEventLayer(control)
	local layer = display.newLayer()    
	control:addChild(layer,-1000)  
	layer:addNodeEventListener(cc.KEYPAD_EVENT,BackEventManager.onCallBackEvent) 
	layer:setKeypadEnabled(true)
end

return BackEventManager
