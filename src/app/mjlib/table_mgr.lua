local TableMgr = {
    tbl = {},
    eye_tbl = {},
    feng_tbl = {},
    feng_eye_tbl = {}
}

function TableMgr:quickCheck(keys)

end

function TableMgr:init()
    for i=0,8 do
        self.tbl[i] = {}
        self.eye_tbl[i] = {}
        self.feng_tbl[i] = {}
        self.feng_eye_tbl[i] = {}
    end
end

function TableMgr:add(key, gui_num, eye, chi)
    if not chi then
        if eye then
            self.feng_eye_tbl[gui_num][key] = true
        else
            self.feng_tbl[gui_num][key] = true
        end
    else
        if eye then
            self.eye_tbl[gui_num][key] = true
        else
            self.tbl[gui_num][key] = true
        end
    end

end

function TableMgr:check(key, gui_num, eye, chi)
    print("TableMgr:check",key, gui_num, eye, chi)
    if not chi then
        if eye then
            return self.feng_eye_tbl[gui_num][key]
        else
            return self.feng_tbl[gui_num][key]
        end
    else
        if eye then
            return self.eye_tbl[gui_num][key]
        else
            return self.tbl[gui_num][key]
        end
    end
end

function TableMgr:load()
    for i=0,8 do
        local fileUtils = cc.FileUtils:getInstance()
        if device.platform == "ios" then
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/table_%d.txt",i)),"\n"),self.tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/eye_table_%d.txt",i)),"\n"),self.eye_tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/feng_table_%d.txt",i)),"\n"),self.feng_tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/feng_eye_table_%d.txt",i)),"\n"),self.feng_eye_tbl[i])
        else
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/table_%d.txt",i)),"\r\n"),self.tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/eye_table_%d.txt",i)),"\r\n"),self.eye_tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/feng_table_%d.txt",i)),"\r\n"),self.feng_tbl[i])
            self:_load2(string.split(fileUtils:getStringFromFile(string.format("res/tab/feng_eye_table_%d.txt",i)),"\r\n"),self.feng_eye_tbl[i])
        end
        -- print("tbl",json.encode(self.tbl[i]))
        -- print("eye_tbl",json.encode(self.eye_tbl[i]))
        -- print("feng_tbl",json.encode(self.feng_tbl[i]))
        -- print("feng_eye_tbl",json.encode(self.feng_eye_tbl[i]))
    end
end

function TableMgr:dump_table()
    for i=0,8 do
        self:_dump(string.format(device.writablePath .. "res/tab/table_%d.txt", i), self.tbl[i])
        self:_dump(string.format(device.writablePath .. "res/tab/eye_table_%d.txt", i), self.eye_tbl[i])
    end
end

function TableMgr:dump_feng_table()
    for i=0,8 do
        self:_dump(string.format(device.writablePath .. "res/tab/feng_table_%d.txt", i), self.feng_tbl[i])
        self:_dump(string.format(device.writablePath .. "res/tab/feng_eye_table_%d.txt", i), self.feng_eye_tbl[i])
    end
end

function TableMgr:_load2(values,tbl)
    for _,value in ipairs(values) do
        if tonumber(value) then
            tbl[tonumber(value)] = true
        end
    end
end

function TableMgr:_load(file, tbl)
    local num = 0
    local f = io.open(file, "r")
    if not f then return end
    while true do
        local line = f:read()
        if not line then
            break
        end
        num = num + 1
        tbl[tonumber(line)] = true
    end
    f:close()
    --print(file, num)
end

function TableMgr:_dump(file, tbl)
	print(file)
    local f = io.open(file, "w+")
    for k,_ in pairs(tbl) do
        f:write(k.."\n")
    end
    f:close()
end

return TableMgr