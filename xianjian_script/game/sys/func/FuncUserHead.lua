--
--Author:      zhuguangyuan
--DateTime:    2018-01-27 20:47:30
--Description: 玩家头像静态函数代码整理
--

FuncUserHead = FuncUserHead or {}

local UserHead = nil
local headFrame =nil

-- 玩家头像类型
FuncUserHead.userHeadType = {
    DEFAULT = "1",        -- 主角默认头像
    PARTNER = "2",        -- 伙伴头像
    PARTNER_SKIN = "3",   -- 伙伴皮肤头像
    CHAR_GARMENT = "4",   -- 主角时装头像
    ACTIVITY = "5",       -- 活动头像
}

FuncUserHead.userHeadType.isDebug = false


function FuncUserHead.init()
	UserHead = Tool:configRequire("user.Head");
    headFrame = Tool:configRequire("user.HeadFrame");
end


function FuncUserHead.getAllConfigUserHead()
    return UserHead
end

-- 传入头像id 和性别avatar
-- 找不到头像id时返回性别对应的默认头像
function FuncUserHead.getHeadIcon(id,avater)
    if id == 0 or id == "" or not id then
        id = FuncUserHead.getDefaultIcon(avater)
    end
    local data = UserHead[tostring(id)]
    return data.png
end

-- 获取解锁头像的条件
function FuncUserHead.getHeadCondition(id)
    local data = UserHead[tostring(id)]
    return data.condition
end

-- 根据id 获取头像类型
function FuncUserHead.getHeadType(id)
    local condition = FuncUserHead.getHeadCondition(id)
    local str = condition[1]
    str = string.split(str,",")
    -- echo("ID ==== "..id .. " _type === "..str[1].." _value === "..str[2])
    if tonumber(str[1]) == 4 then
        return tonumber(str[1]),str[2],str[3]
    else
        return tonumber(str[1]),str[2]
    end
end

-- 获取男主女主默认头像
function FuncUserHead.getDefaultIcon(avater)
    if tostring(avater) == "101" then
        return "101"
    else
        return "106"
    end
end




-- function FuncUserHead.getHeadFrame()
--     return headFrame
-- end

function FuncUserHead.getDefaultHeadFrame()
    return "101"
end

function FuncUserHead.getHeadFramById(id)
    if id == "" or not id then
        id = FuncUserHead.getDefaultHeadFrame()
    end
    return headFrame[tostring(id)]
end

function FuncUserHead.getHeadFramIcon(id)
    if (id == "") or (id == 0) or (not id) then
        id = FuncUserHead.getDefaultHeadFrame()
    end
    local data = headFrame[tostring(id)]
    return data.Png
end

-- 获取头像框特效 
function FuncUserHead.getHeadFramSpecial(id)
    if id == "" or not id then
        id = FuncUserHead.getDefaultHeadFrame()
    end
    return headFrame.special
end

function FuncUserHead.getHeadFrameName(id)
    if id == "" or not id then
        id = FuncUserHead.getDefaultHeadFrame()
    end
    local name = GameConfig.getLanguage(headFrame[tostring(id)].headFrameName)
    return name
end

function FuncUserHead.getHeadFrameDes(id)
    if id == "" or not id then
        id = FuncUserHead.getDefaultHeadFrame()
    end
    local des = GameConfig.getLanguage(headFrame[tostring(id)].headFrameDescrip)
    return des
end
