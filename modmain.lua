-- 引入全局变量
local _G = GLOBAL
local TheInput = _G.TheInput

-- BOSS列表及其名称
local BOSS_PREFABS = {
    {id = "deerclops", name = "独眼巨鹿"},
    {id = "moose", name = "鹿角鹅"},
    {id = "bearger", name = "熊獾"},
    {id = "dragonfly", name = "龙蝇"},
    {id = "klaus", name = "克劳斯"},
    {id = "antlion", name = "蚁狮"},
    {id = "minotaur", name = "远古守护者"},
    {id = "beequeen", name = "蜂后"},
    {id = "toadstool", name = "毒菌蟾蜍"},
    {id = "stalker", name = "远古织影者"},
    {id = "stalker_atrium", name = "远古织影者(复活)"},
    {id = "malbatross", name = "邪天翁"},
    {id = "crabking", name = "帝王蟹"},
    {id = "eyeofterror", name = "恐怖之眼"},
    {id = "twinofterror", name = "机械双子"},
    {id = "daywalker", name = "噩梦猪人"},
}

-- 初始化
local boss_kills = {}
local add_mode = false
local clear_mode = false

-- 添加模组配置选项
local AUTO_TRACKING = GetModConfigData("auto_tracking") or false

-- 保存统计数据
local function SaveData()
    local str = _G.json.encode(boss_kills)
    _G.TheSim:SetPersistentString("boss_kills_data", str, false)
end

-- 加载统计数据
local function LoadData()
    _G.TheSim:GetPersistentString("boss_kills_data", function(success, str)
        if success and str and #str > 0 then
            local data = _G.json.decode(str)
            if data then
                boss_kills = data
            end
        end
    end)
end

-- 初始化数据
LoadData()

-- 添加击杀记录
local function AddKill(boss_index)
    local boss = BOSS_PREFABS[boss_index]
    if not boss then return end
    
    local id = boss.id
    boss_kills[id] = (boss_kills[id] or 0) + 1
    SaveData()
    
    if _G.ThePlayer and _G.ThePlayer.components.talker then
        _G.ThePlayer.components.talker:Say("已添加 " .. boss.name .. " 击杀记录，当前: " .. boss_kills[id] .. "次")
    end
end

-- 通过prefab ID添加击杀记录
local function AddKillByPrefabID(prefab_id)
    for i, boss in ipairs(BOSS_PREFABS) do
        if boss.id == prefab_id then
            boss_kills[prefab_id] = (boss_kills[prefab_id] or 0) + 1
            SaveData()
            
            -- 向所有玩家广播击杀信息
            for _, player in ipairs(_G.AllPlayers) do
                if player and player.components.talker then
                    player.components.talker:Say(boss.name .. " 已被击杀，当前记录: " .. boss_kills[prefab_id] .. "次")
                end
            end
            return
        end
    end
end

-- 清零击杀记录
local function ClearKill(boss_index)
    local boss = BOSS_PREFABS[boss_index]
    if not boss then return end
    
    local id = boss.id
    if boss_kills[id] and boss_kills[id] > 0 then
        boss_kills[id] = 0
        SaveData()
        
        if _G.ThePlayer and _G.ThePlayer.components.talker then
            _G.ThePlayer.components.talker:Say("已清零 " .. boss.name .. " 的击杀记录")
        end
    else
        if _G.ThePlayer and _G.ThePlayer.components.talker then
            _G.ThePlayer.components.talker:Say(boss.name .. " 击杀记录已经是0")
        end
    end
end

-- 清零所有击杀记录
local function ClearAllKills()
    boss_kills = {}
    for _, boss in ipairs(BOSS_PREFABS) do
        boss_kills[boss.id] = 0
    end
    SaveData()
    
    if _G.ThePlayer and _G.ThePlayer.components.talker then
        _G.ThePlayer.components.talker:Say("已清零所有BOSS击杀记录")
    end
end

-- 显示击杀统计
local function ShowKillStats()
    if not _G.ThePlayer or not _G.ThePlayer.components.talker then return end
    
    local has_kills = false
    local msg = "BOSS击杀统计："
    
    for _, boss in ipairs(BOSS_PREFABS) do
        local kills = boss_kills[boss.id] or 0
        if kills > 0 then
            has_kills = true
            msg = msg .. "\n" .. boss.name .. ": " .. kills .. "次"
        end
    end
    
    if not has_kills then
        msg = "尚未记录任何BOSS击杀。"
    end
    
    _G.ThePlayer.components.talker:Say(msg)
end

-- 显示BOSS列表(添加模式)
local function ShowBossList()
    if not _G.ThePlayer or not _G.ThePlayer.components.talker then return end
    
    local msg = "选择要添加击杀的BOSS:\n"
    
    -- 数字键1-9对应的BOSS (1-9)
    msg = msg .. "【数字键1-9】:\n"
    for i = 1, 9 do
        if BOSS_PREFABS[i] then
            msg = msg .. i .. ". " .. BOSS_PREFABS[i].name .. "\n"
        end
    end
    
    -- F3-F9对应的BOSS (10-16)
    msg = msg .. "\n【F3-F9键】:\n"
    for i = 10, 16 do
        if BOSS_PREFABS[i] then
            local f_key = i - 7  -- F3对应10, F4对应11, 以此类推
            msg = msg .. "F" .. f_key .. ". " .. BOSS_PREFABS[i].name
            if i < 16 then
                msg = msg .. "\n"
            end
        end
    end
    
    _G.ThePlayer.components.talker:Say(msg)
    add_mode = true
    clear_mode = false
end

-- 显示BOSS列表(清零模式)
local function ShowClearBossList()
    if not _G.ThePlayer or not _G.ThePlayer.components.talker then return end
    
    local msg = "选择要清零击杀记录的BOSS:\n"
    
    -- 数字键1-9对应的BOSS (1-9)
    msg = msg .. "【数字键1-9】:\n"
    for i = 1, 9 do
        if BOSS_PREFABS[i] then
            local kills = boss_kills[BOSS_PREFABS[i].id] or 0
            msg = msg .. i .. ". " .. BOSS_PREFABS[i].name .. ": " .. kills .. "次\n"
        end
    end
    
    -- F3-F9对应的BOSS (10-16)
    msg = msg .. "\n【F3-F9键】:\n"
    for i = 10, 16 do
        if BOSS_PREFABS[i] then
            local kills = boss_kills[BOSS_PREFABS[i].id] or 0
            local f_key = i - 7  -- F3对应10, F4对应11, 以此类推
            msg = msg .. "F" .. f_key .. ". " .. BOSS_PREFABS[i].name .. ": " .. kills .. "次"
            if i < 16 then
                msg = msg .. "\n"
            end
        end
    end
    
    msg = msg .. "\n\n按F11取消"
    
    _G.ThePlayer.components.talker:Say(msg)
    clear_mode = true
    add_mode = false
end

-- 退出添加模式
local function ExitAddMode()
    add_mode = false
    clear_mode = false
    if _G.ThePlayer and _G.ThePlayer.components.talker then
        _G.ThePlayer.components.talker:Say("已成功添加一次击杀记录")
    end
end

-- 退出清零模式
local function ExitClearMode()
    clear_mode = false
    add_mode = false
    if _G.ThePlayer and _G.ThePlayer.components.talker then
        _G.ThePlayer.components.talker:Say("已取消清零操作")
    end
end

-- 添加按键绑定
TheInput:AddKeyHandler(function(key, down)
    if not down then return false end
    
    -- F1键：查看统计
    if key == _G.KEY_F1 then
        ShowKillStats()
        return true
    -- F2键：进入添加模式
    elseif key == _G.KEY_F2 then
        ShowBossList()
        return true
    -- F10键：进入清零模式
    elseif key == _G.KEY_F10 then
        ShowClearBossList()
        return true
    -- F11键：退出各种模式
    elseif key == _G.KEY_F11 then
        if add_mode then
            ExitAddMode()
            return true
        elseif clear_mode then
            ExitClearMode()
            return true
        end
    end
    
    -- 添加模式下的按键
    if add_mode then
        -- 数字键1-9对应BOSS 1-9
        if key >= _G.KEY_1 and key <= _G.KEY_9 then
            local index = key - _G.KEY_1 + 1
            AddKill(index)
            ExitAddMode()
            return true
        -- F3-F9对应BOSS 10-16
        elseif key >= _G.KEY_F3 and key <= _G.KEY_F9 then
            local index = key - _G.KEY_F3 + 10
            AddKill(index)
            ExitAddMode()
            return true
        end
    end
    
    -- 清零模式下的按键
    if clear_mode then
        -- 数字键1-9对应BOSS 1-9
        if key >= _G.KEY_1 and key <= _G.KEY_9 then
            local index = key - _G.KEY_1 + 1
            ClearKill(index)
            clear_mode = false
            return true
        -- F3-F9对应BOSS 10-16
        elseif key >= _G.KEY_F3 and key <= _G.KEY_F9 then
            local index = key - _G.KEY_F3 + 10
            ClearKill(index)
            clear_mode = false
            return true
        end
    end
    
    return false
end)

-- 自动监听BOSS死亡
if AUTO_TRACKING then
    -- 监听实体死亡事件
    AddPrefabPostInit("world", function(inst)
        inst:ListenForEvent("entity_death", function(world, data)
            if data and data.inst then
                local victim = data.inst
                local prefab_name = victim.prefab
                
                -- 检查是否是BOSS
                for _, boss in ipairs(BOSS_PREFABS) do
                    if prefab_name == boss.id then
                        AddKillByPrefabID(prefab_name)
                        break
                    end
                end
            end
        end)
    end)
end

-- 初始文本
_G.StartNextInstance = (function()
    local oldStartNextInstance = _G.StartNextInstance
    return function(...)
        local ret = oldStartNextInstance(...)
        _G.ThePlayer:DoTaskInTime(2, function()
            if _G.ThePlayer and _G.ThePlayer.components.talker then
                local mode_text = AUTO_TRACKING and "自动" or "手动"
                _G.ThePlayer.components.talker:Say("BOSS击杀统计已加载 (" .. mode_text .. "模式)\nF1键查看，F2键添加，F10键清零选择，F11键退出")
            end
        end)
        return ret
    end
end)() 