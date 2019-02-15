--张强 2018-03-20


local MemoryCardModel = class("MemoryCardModel", BaseModel);

function MemoryCardModel:init(data)
    MemoryCardModel.super.init(self, data)
    -- dump(self._data,"情景卡self.___data = ")

    self.lightChips = {}

    -- 道具
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.MemoryRedChange, self)
    -- 碎片点亮
    EventControler:addEventListener(MemoryEvent.MEMORY_CHIP_LIGHT_EVENT, 
        self.MemoryRedChange, self)
    -- 卡片激活
    EventControler:addEventListener(MemoryEvent.MEMORY_CARD_JIHUO_EVENT, 
        self.MemoryRedChange, self)

    self:MemoryRedChange()
    -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{ redPointType = FuncCommon.SYSTEM_NAME.MEMORYCARD, isShow = self:checkRedPointShow() } )
   
end

function MemoryCardModel:MemoryRedChange()
        -- EventControler:dispatchEvent(MemoryEvent.MEMORY_CARD_RED_EVENT)
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{ redPointType = FuncCommon.SYSTEM_NAME.MEMORYCARD, isShow = self:checkRedPointShow() } )
   
    
end


function MemoryCardModel:updateData(data)
    MemoryCardModel.super.updateData(self, data)
    dump(self._data,"情景卡self.___data = ")
    EventControler:dispatchEvent(MemoryEvent.MEMORY_CARD_JIHUO_EVENT)
    self:MemoryRedChange()
end

-- 判断系统是否开启
function MemoryCardModel:memorySysOpen( )
    local T = self:getShowMemoryT()
    if table.length(T) > 0 then
        return true
    end
    return false
end

-- 情景卡红点
function MemoryCardModel:checkRedPointShow()
    local memorys = MemoryCardModel:getShowMemoryT()
    for i,v in pairs(memorys) do
        if self:checkMemoryShowRedById(v.id) then
            return true
        end
    end
    return false
end
-- 判断系列是否有红点显示
function MemoryCardModel:checkMemoryShowRedById(id)
    local memoryData = FuncMemoryCard.getMemoryDataById(id)
    local cards = memoryData.pictureId
    for ii,vv in pairs(cards) do
        -- 判断是否可激活
        if self:checkCardCanJiHuo(vv) then
            return true
        end
        -- 再判断 情景卡内 碎片是否可点亮
        -- if self:checkCardRedShow( vv ) then
        --     return true
        -- end
    end
    return false
end

---------------------------------------------------------
---------------- 情景卡提供的属性------------------------
---------------------------------------------------------
function MemoryCardModel:getMemoryAllAttr( )
    local attr = {}
    attr["0"] = {}
    attr["1"] = {}
    attr["2"] = {}
    attr["3"] = {}

    local func = function( T,data )
        for i,v in pairs(T) do
            if v.key == data.key and v.mode == data.mode then
                v.value = v.value + data.value
                return
            end
        end
        table.insert(T,data)
    end
    -- 激活的系列带来的属性
    local jihuoMemory = MemoryCardModel:getFinishMemoryT()
    for i,v in pairs(jihuoMemory) do
        local id = v.id
        local data = table.deepCopy(FuncMemoryCard.getMemoryDataById(id))
        local targets = data.target
        for m,n in pairs(targets) do
            for key,value in pairs(data.initAttr) do
                func(attr[n],value)  
                -- table.insert(attr[n],value)
            end
        end
    end
    -- 激活的情景卡带来的属性
    for i,v in pairs(self._data) do
        local cardData = table.deepCopy(FuncMemoryCard.getMemoryCardDataById(i))
        local targets = cardData.target
        for m,n in pairs(targets) do
            for key,value in pairs(cardData.initAttr) do
                func(attr[n],value)  
               -- table.insert(attr[n],value)
            end
        end
    end
    -- dump(attr["0"], "sssss", 4)
    local _attr = {}
    for i,v in pairs(attr) do
        _attr[i] = FuncBattleBase.formatAttribute(v)
    end
    return _attr
end

-- 战力
function MemoryCardModel:getMemoryPower( )
    local power = 0
    -- 激活的系列
    local jihuoMemory = MemoryCardModel:getFinishMemoryT()
    for i,v in pairs(jihuoMemory) do
        power = power + FuncMemoryCard.getMemoryPowerById( v.id )
    end
    -- 激活的情景卡带来的属性
    for i,v in pairs(self._data) do
        power = power + FuncMemoryCard.getMemoryCardPowerById( i )
    end
    
    return power
end

----------------------------------------------------------
------------------------系列------------------------------
----------------------------------------------------------

-- 获取已激活的系列
function MemoryCardModel:getFinishMemoryT()
    local data = FuncMemoryCard.getMemoryData()
    local T = {}
    for i,v in pairs(data) do
        local cards = v.pictureId
        local isFinish = true
        for ii,vv in pairs(cards) do
            if not self:checkCardFinishJiHuo(vv) then
                isFinish = false
                break
            end
        end
        if isFinish then
            table.insert(T,v)
        end
    end
    return T
end
-- 获取可显示的系列
function MemoryCardModel:getShowMemoryT()
    local data = FuncMemoryCard.getMemoryData()
    local T = {}
    for i,v in pairs(data) do
        if self:checkMemoryShowById(v.id) then
            table.insert(T,v)
        end
    end
    return T
end

-- 判断系列是否 已点亮
function MemoryCardModel:checkMemoryFinishById(id)
    local data = FuncMemoryCard.getMemoryDataById(id)
    local cards = data.pictureId
    for i,v in pairs(cards) do
        if not self:checkCardFinishJiHuo(v) then
            return false
        end
    end
    
    return true
end


-- 判断系列是否要显示 
--[[ 系列中的情景卡都没有碎片，此系列不显示]]
function MemoryCardModel:checkMemoryShowById(id)
    local data = FuncMemoryCard.getMemoryDataById(id)
    local cards = data.pictureId
    for i,v in pairs(cards) do
        -- 判断是否激活
        if self:checkCardFinishJiHuo(v) then
            return true
        end
        local cardData = FuncMemoryCard.getMemoryCardDataById(v)
        local cardPieceIds = cardData.pieceId
        for ii,vv in pairs(cardPieceIds) do
            -- 是否点亮
            if self:checkChipLightById(vv,v) then
                return true
            end
            if MemoryCardModel:checkHasChipById( vv ) then
                return true
            end
        end
    end
    
    return false
end

-----------------------------------------------------------
----------------------情景卡-------------------------------
-----------------------------------------------------------

-- 判断情景卡是否已激活
function MemoryCardModel:checkCardFinishJiHuo(id)
    if self._data then
        if self._data[id] then
            return true
        end
    end
    
    return false
end
-- 判断情景卡是否已领取分享奖励
function MemoryCardModel:checkCardFinishShare(id)
    if self._data[id] and self._data[id] == 2 then
        return true
    end
    return false
end

-- 判断情景卡是否可 激活
-- 全部碎片点亮或者可点亮 就可以激活
function MemoryCardModel:checkCardCanJiHuo(id)
    if MemoryCardModel:checkCardFinishJiHuo(id) then
        return false
    end
    local cardData = FuncMemoryCard.getMemoryCardDataById(id)
    local chips = cardData.pieceId
    local canLightT = {}
    for i,v in pairs(chips) do
        local isLight = MemoryCardModel:checkChipLightById(v,id)
        if not isLight then
            local hasChip = MemoryCardModel:checkHasChipById(v)
            if not hasChip then
                return false
            else
                table.insert(canLightT,v)
            end
        end
    end
    return true,canLightT
end
-- 判断情景卡是否有可点亮的碎片
function MemoryCardModel:checkCardRedShow( id )
    local cardData = FuncMemoryCard.getMemoryCardDataById(id)
    local chips = cardData.pieceId
    for i,v in pairs(chips) do
        local isLight = MemoryCardModel:checkChipLightById(v,id)
        local hasChip = MemoryCardModel:checkHasChipById(v)
        if (not isLight) and hasChip then
            return true
        end
    end

    return false
end

-- 判断情景卡是否是否 可显示
function MemoryCardModel:checkCardCanShow(id)
    -- 判断是否已激活
    if self:checkCardFinishJiHuo(id) then
        return true
    end
    local cardData = FuncMemoryCard.getMemoryCardDataById(id)
    local chips = cardData.pieceId
    for i,v in pairs(chips) do
        local isLight = MemoryCardModel:checkChipLightById(v,id)
        if isLight then
            return true
        end
        local hasChip = MemoryCardModel:checkHasChipById(v)
        if hasChip then
            return true
        end
    end

    return false
end

-- 情景卡点亮进度
function MemoryCardModel:getCardLightProgress(cardId)
    local cardData = FuncMemoryCard.getMemoryCardDataById(cardId)
    local chips = cardData.pieceId 
    local allNum = #chips
    local proNum = 0
    for i,v in pairs(chips) do
        local isLight = MemoryCardModel:checkChipLightById(v,cardId)
        if isLight then
            proNum = proNum + 1
            break
        end
        local hasChip = MemoryCardModel:checkHasChipById(v)
        if hasChip then
            proNum = proNum + 1
            break
        end
    end

    return proNum,allNum
end

-- 判断是否拥有此碎片 
function MemoryCardModel:checkHasChipById( chipId ) 
    local num = ItemsModel:getItemNumById(chipId)
    if num > 0 then
        return true
    else
        return false
    end
    
end
-- 判断此碎片是否已点亮
-- 碎片点亮的逻辑存本地
function MemoryCardModel:checkChipLightById(chipId,cardId)
    if self:checkCardFinishJiHuo(cardId) then
        return true
    end
    local state = FuncMemoryCard.getChipLightState(chipId)
    return state
end
function MemoryCardModel:setChipLightById(chipId)
    FuncMemoryCard.setChipLightState(chipId,true)
    WindowControler:globalDelayCall(c_func(function()
        EventControler:dispatchEvent(MemoryEvent.MEMORY_CHIP_LIGHT_EVENT,chipId)
    end),0.5)
    
end


-- 打开情景卡UI
function MemoryCardModel:showMemoryCardView( )
    local allData = MemoryCardModel:getShowMemoryT()
    if table.length(allData) > 0 then
        WindowControler:showWindow("MemoryCardMainView")
    else
        WindowControler:showTips("没有数据------无碎片")
    end
end


--传入一个点 获取这个点 落在 哪个区域
-- pointsArr  里面 是N组多边形, 点数据结构: 点可以是 数组{[1] = 10,[2] = 10}, 也可以是 {x=10,y=10}.建议用数组
--[[
   1 = {        { x1,y1 },{x2,y2},...    },
   2 = {        { x1,y1 },{x2,y2},...    },
]]
-- 备注:坐标x,y是相对于(0,0)点计算的,需要系统自己去转化一次.返回0 表示 落在区域外边了
function MemoryCardModel:getAreaByPos( x,y, pointsArr  )
    for k, v  in pairs( pointsArr ) do
        if Equation.checkPosInPolygon( {x=x,y=y},v ) then
            return k
        end
    end

    return 0
end


--测试代码参考测试flash
-- local pointArr = {
--     { 
--         { 181 , -99 },      { 71 , 9 },     { 72 , 41 },        { 24 , 40 },
--      },
--     { 
--         { 71 , 9 },     { 115 , 9 },        { 115 , 44 },       { 72 , 41 },
--      },
--     { 
--         { 115 , 9 },        { 153 , 11 },       { 191 , 50 },       { 153 , 47 },       { 115 , 44 },
--      },

-- }

-- local nuns = MemoryCardModel:getAreaByPos( 92,28, pointArr  )


return MemoryCardModel;

