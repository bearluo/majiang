--
-- Author: shineflag
-- Date: 2017-02-26 11:00:56
--
local platformEventHalper = require("app.utils.platformEventHalper")

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local wait_view_index = 0


local function hide_wait_view()
    local scheduler = require("framework.scheduler")
    wait_view_index = wait_view_index - 1
    if not tolua.isnull(tt.loading) and wait_view_index <= 0 then
        tt.loading.anim_sprite:stopAllActions()
        tt.loading.close_btn:stopAllActions()
        tt.loading:stopAllActions()
        tt.loading:setVisible(false)
    end
end

local function show_wait_view(str)
    local scheduler = require("framework.scheduler")
    str = str or ""
    local run_scene = display.getRunningScene()

    print("show_wait_view",tolua.isnull(tt.loading))
    if tolua.isnull(tt.loading) then
        local node, width, height = cc.uiloader:load("loading_view.json")
        -- local frames = display.newFrames("anim/load/%d.png",1, 8)
        node.anim_sprite = cc.uiloader:seekNodeByName(node, "loading_anim")
        node.lable_txt = cc.uiloader:seekNodeByName(node, "loading_txt")
        node.close_btn = cc.uiloader:seekNodeByName(node, "close_btn")
            :onButtonClicked(hide_wait_view)
        node:setTouchEnabled(true)
        node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                print(event.x,event.y)
                return true 
            end)
        node:setPosition(display.cx- 640,display.cy - 360)
        tt.loading = node
    end
    if run_scene ~= tt.loading:getParent() then
        run_scene:addChild(tt.loading,10000)
    end
    print("show_wait_view",wait_view_index)
    if wait_view_index <= 0 then
        local index = 0
        tt.loading.anim_sprite:schedule(function()
                index = (index + 40) % 360
                tt.loading.anim_sprite:rotation(index)
            end,0.1)
        tt.loading:performWithDelay(function()
                tt.loading:setVisible(true)
            end, 1)
        tt.loading.close_btn:stopAllActions()
        tt.loading.close_btn:setVisible(false)
        tt.loading.close_btn:performWithDelay(function()
                print("show_wait_view performWithDelay",wait_view_index)
                tt.loading.close_btn:setVisible(true)
            end, 3)
    end
    tt.loading.lable_txt:setString( tostring(str) or "")
    wait_view_index = wait_view_index + 1
end

local message_bg = nil
local function show_message(msg)
    if not tolua.isnull(message_bg) then message_bg:removeSelf() end
    local run_scene = display.getRunningScene()


    bg = display.newSprite("bg/ruotishi.png")
    local msize = bg:getContentSize()

    message_bg = display.newClippingRectangleNode()
    message_bg:setClippingRegion(cc.rect(display.cx - 640, display.cy - 360, 1280, 720))
        :addTo(run_scene)
        
    bg:addTo(message_bg)

    local label = display.newTTFLabel({
        text = tostring(msg),
        size = 31,
        x = msize.width/2,
        y = 48,
        color=cc.c3b(0x92,0x19,0x19),
    }):addTo(bg)
    local top = display.cy + 360
    bg:setPosition(display.cx,top + msize.height/2)
    local sequence = transition.sequence({
        cc.MoveTo:create(0.5, cc.p(display.cx, top - msize.height/2+2)),
        cc.DelayTime:create(5),
        cc.MoveTo:create(0.5, cc.p(display.cx, top + msize.height/2)),
        -- cc.FadeOut:create(1),
        cc.CallFunc:create(function() message_bg:removeSelf() end)

    })
    sequence:setTag(1)
    bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            local name, x, y = event.name, event.x, event.y
            -- print('--------------')
            if name == "ended" then
                bg:stopActionByTag(1)
                bg:setTouchEnabled(false)
                local x,y = bg:getPosition()
                -- print(x,y)
                local factor = math.abs((y - top) / (msize.height/2))
                -- print(0.5*factor)
                local sequence = transition.sequence({
                    cc.MoveTo:create(0.5*factor, cc.p(display.cx, top + msize.height/2)),
                    -- cc.FadeOut:create(1),
                    cc.CallFunc:create(function() message_bg:removeSelf() end)
                })
                sequence:setTag(1)
                bg:runAction(sequence)
            end
            return true
        end)
    bg:setTouchEnabled(true)
    bg:setCascadeOpacityEnabled(true)
    bg:runAction(sequence)
end

--全局显示的layer层
local function show_error(msg)
    print('---show_error--',msg)
    if not tt.glayer then
        tt.glayer = display.newLayer():setContentSize(display.width, display.height)
        cc.Director:getInstance():setNotificationNode(tt.glayer)
    end
    if not tt.glabel then
        tt.glabel = display.newTTFLabel({
            text = "",
            size = 18,
            x = display.cx,
            y = display.cy,
            color=cc.c3b(0xff,0x00,0x00),
            dimensions = cc.size(display.width,display.height)
        }):addTo(tt.glayer)
    end
    tt.glabel:setString(tostring(msg))
end


--[[发牌动画
--spos --起始位置
--epos --结束位置
--t    --时间
--f    --结束后执行函数
]]
local function play_coin_fly(spos,epos,t, f)

    local coin_img = display.newSprite("dec/chouma_1.png")
        :setPosition(spos)
    transition.moveTo(coin_img, {x = epos.x, y = epos.y, time = t or 0.2,
        onComplete = function()
            if not tolua.isnull(coin_img) then
                coin_img:removeSelf()
            end
            if f then
                f()
            end
        end})
    tt.play.play_sound("chips")
    return coin_img
end

--[[发牌动画
--spos --起始位置
--epos --结束位置
--t    --时间
--f    --结束后执行函数
]]
local function play_deal_cards(spos,epos,t, f)
    local node = display.newNode()
    local poker_img = display.newSprite("poker/poker_cad81_108/card_back.png")
        :addTo(node)
    local poker_img2 = display.newSprite("poker/poker_cad81_108/card_back.png")
        :addTo(node)
    local time = t or 1
    node:setCascadeOpacityEnabled(true)
    poker_img:setCascadeOpacityEnabled(true)
    poker_img2:setCascadeOpacityEnabled(true)

    poker_img:setScale(0.38)
    poker_img2:setScale(0.38)
    poker_img:setPosition(spos)
    poker_img2:setPosition(spos)
    
    local length = cc.pGetLength(spos,epos)
    local angle = math.abs(length) * 3.6
    local epos2 = cc.pAdd(epos,cc.p(35,-4))
    
    transition.moveTo(poker_img, {
            x=epos.x,
            y=epos.y,
            time=time,
            easing="exponentialOut",
        })

    transition.moveTo(poker_img2, {
            x=epos2.x,
            y=epos2.y,
            time=time,
            easing="exponentialOut",
        })


    poker_img:rotation(100)
    poker_img2:rotation(100)

    transition.rotateTo(poker_img, {
            rotate=angle-15.00,
            time=time,
            easing="exponentialOut",
        })

    transition.rotateTo(poker_img2, {
            rotate=angle+3.00,
            time=time,
            easing="exponentialOut",
        })

    node:fadeOut(time)
    node:performWithDelay(function()
            if not tolua.isnull(node) then
                node:removeSelf()
            end
            if f then
                f()
            end
        end, time)
    return node
end


-- local function decodeURI(s)
--     s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
--     return s
-- end

-- local function encodeURI(s)
--     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
--     return string.gsub(s, " ", "+")
-- end


local function asynGetHeadIconSprite(img_url_,callback)
    printInfo("asynGetHeadIconSprite:%s",img_url_ or "")
    if not img_url_ or img_url_ == "" then
        callback(display.newSprite("dec/morentouxiang.png"))
        return 
    end
    print("asynGetHeadIconSprite",img_url_)
    if string.sub(img_url_,1,7) == "file://" then
        callback(display.newSprite(string.sub(img_url_,8,-1)))
        return 
    end

    if string.sub(img_url_,1,7) == "http://" or string.sub(img_url_,1,8) == "https://" then
        local sprite = tt.imageCacheManager:newCacheSprite(img_url_)
        if not sprite then
            tt.imageCacheManager:downloadImage(img_url_, function(url)
                local sprite = tt.imageCacheManager:newCacheSprite(img_url_)
                if sprite then
                    callback(sprite)
                end
            end)
        else
            callback(sprite)
        end
        return 
    end
    callback(display.newSprite("dec/morentouxiang.png"))
end


local function getNumStr(num)
    local ret = ""
    -- num = 2384788346
    num = tonumber(num) or 0
    if num == 0 then return "0" end

    if num >= 100000000 then
        local f = num % 1000000
        num = (num - f) / 1000000
        ret = string.format(".%02dM",(f-f%10000)/10000)
    end

    while num > 0 do
        local f = num % 1000
        num = (num - f) / 1000
        if num > 0 then
            ret = string.format(",%03d%s",f,ret)
        else
            ret = string.format("%d%s",f,ret)
        end
    end
    return ret
end

local function getBitmapNum(filestr,num)
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local numImg = {}
    local w = 0
    local h = 0

    if num == 0 then 
        local sprite = display.newFilteredSprite(string.format(filestr,num))
        table.insert(numImg, 1,sprite)
    else
        while (num > 0) do
            local index = num % 10
            num = (num - index) / 10
            local sprite = display.newFilteredSprite(string.format(filestr,index))
            table.insert(numImg, 1,sprite)
        end
    end 
    for i,img in ipairs(numImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,numImg
end

local function getBitmapNumStr(filestr,num)
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local numImg = {}
    local w = 0
    local h = 0
    local numStr = getNumStr(num)
    local len = #numStr

    for i=1,len do
        local c = string.sub(numStr,i,i)
        local num
        if c == ',' then
            num = 10
        elseif c == '.' then
            num = 11
        elseif c == 'M' then
            num = 12
        else
            num = tonumber(c)
        end
        if num then
            local sprite = display.newFilteredSprite(string.format(filestr,num))
            table.insert(numImg,sprite)
        end
    end

    for i,img in ipairs(numImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,numImg
end

local function getBitmapStrAscii(filestr,str,offset_w)
    local str = tostring(str) or ""
    local node = display.newNode()
    node:setAnchorPoint(cc.p(0,0))
    local strImg = {}
    local w = 0
    local h = 0
    local len = #str
    offset_w = offset_w or 0
    for i=1,len do
        local c = string.sub(str,i,i)
        local num = string.byte(c)
        print(num)
        if num then
            local sprite = display.newFilteredSprite(string.format(filestr,num))
            table.insert(strImg,sprite)
        end
    end

    for i,img in ipairs(strImg) do
        img:setAnchorPoint(cc.p(0,0))
        :setPosition(cc.p(w,0))
        :addTo(node)
        w = w + img:getContentSize().width - offset_w
        h = img:getContentSize().height
    end
    node:setContentSize(w,h)
    return node,strImg
end


local function linearlayout(view,add,x,y)
    local w = view:getContentSize().width
    x = x or 0
    y = y or 0
    -- printInfo("linearlayout %d", w)
    add:addTo(view)
    local size = add:getContentSize()
    local p = add:getAnchorPoint()
    add:setPosition(cc.p(x+w+size.width*p.x,y+size.height*p.y))

    view:setContentSize(x+w+size.width,view:getContentSize().height)
end

local function makeScreen(callb)
    local net = require("framework.cc.net.init")
    local fileName = string.format("printScreen_%d.png",math.ceil(net.SocketTCP.getTime()*1000)) 

    display.captureScreen(function(succeed, outputFile)  
    if succeed then  
        if callb then
            callb(outputFile)
        end
        os.remove(fileName)
        display.removeSpriteFrameByImageName(fileName)  
    else  
        printError("makeScreen fail")
    end  
  end, fileName)
end

local function makeScreenBlur(callb)
    makeScreen(function ( outfile )
        -- local sprite_photo = cc.FilteredSpriteWithMulti:create(outfile)
        -- -- sprite_photo:setScale(750/display.widthInPixels)
        -- sprite_photo:setFilters({cc.GaussianVBlurFilter:create(3),cc.GaussianHBlurFilter:create(3)})


        local run_scene = display.getRunningScene()
        local maskArgs = {
            -- filters = {"GAUSSIAN_VBLUR", "GAUSSIAN_HBLUR"},
            -- filterParams = { {3}, {3}}
            -- filters = "MOTION_BLUR",
            -- filterParams =  {3, 3} 
            -- filters = "ZOOM_BLUR",
            -- filterParams =  {1, 0.5, 0.5} 
            filters = "CUSTOM",
            filterParams = json.encode({frag = "shaders/example_Blur.fsh",
            shaderName = "blurShader",
            resolution = {display.width,display.height},
            blurRadius = 16,
            sampleNum = 5})
        --     filters={"CUSTOM", "CUSTOM"},
        -- filterParams = {json.encode({frag = "Shaders/example_Blur.fsh",
        --     shaderName = "blurShader",
        --     resolution = {480,320},
        --     blurRadius = 10,
        --     sampleNum = 5}),
        -- json.encode({frag = "Shaders/example_sepia.fsh",
        --     shaderName = "sepiaShader",})},
        }

        local sprite_photo = display.newFilteredSprite(outfile,maskArgs.filters,maskArgs.filterParams)
        sprite_photo:setScale(1/display.contentScaleFactor)

        callb(sprite_photo)
    end)
end


tt.displayWebView = function(x,y,width,height)
    local params = platformEventHalper.cmds.displayWebView
    params.args = {
        x=x*display.contentScaleFactor,
        y=display.heightInPixels-y*display.contentScaleFactor,
        width=width*display.contentScaleFactor,
        height=height*display.contentScaleFactor,
    }
    platformEventHalper.callEvent(params)
end

tt.dismissWebView = function()
    platformEventHalper.callEvent(platformEventHalper.cmds.dismissWebView)
end

tt.webViewLoadUrl = function(url)
    local params = platformEventHalper.cmds.webViewLoadUrl
    params.args = {
        url=url,
    }
    platformEventHalper.callEvent(params)
end

tt.isWebViewVisible = function()
    local ok,ret = platformEventHalper.callEvent(platformEventHalper.cmds.isWebViewVisible)
    if ok then
        return ret
    else
        return false
    end
end

tt.limitStr = function(view,str,width)
    view:setString(str)
    local size = view:getContentSize()
    local addStr = '***'
    while size.width > width and string.utf8_len(str) > 0 do
        print("tt.limitStr",str)
        str = string.utf8_sub(str,1,-2)
        view:setString(str .. addStr)
        size = view:getContentSize()
    end
end

tt.show_error = show_error
tt.dump = dump
tt.show_msg = show_message
tt.play_coin_fly = play_coin_fly
tt.play_deal_cards = play_deal_cards
tt.show_wait_view = show_wait_view
tt.hide_wait_view = hide_wait_view
-- tt.decodeURI = decodeURI
-- tt.encodeURI = encodeURI
tt.asynGetHeadIconSprite = asynGetHeadIconSprite
tt.getBitmapNum = getBitmapNum
tt.getBitmapNumStr = getBitmapNumStr
tt.getBitmapStrAscii = getBitmapStrAscii
tt.linearlayout = linearlayout
tt.makeScreen = makeScreen
tt.makeScreenBlur = makeScreenBlur
tt.getNumStr = getNumStr