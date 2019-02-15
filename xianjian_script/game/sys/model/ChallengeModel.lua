--zq

local ChallengeModel = class("ChallengeModel");

ChallengeModel.KEYS = {
    TOWER = "tower",
    TRIAL = "trial",
    PVP = "pvp",
    YIMENG = "elite",
    CROSSPEAK  = "crossPeak",
    WONDERLAND = "wonderLand",
    SHAREBOSS = "shareBoss", --共享副本
    ENDLESS = "endless",
    PVE =  "pve", --旧的回忆 
    MISSION = "mission"  --六界轶事
}
ChallengeModel.indexKeys = {
    [1] = "pvp",
    [2] = "trial",
    [3] = "tower",
}
ChallengeModel.buttonData = {}
function ChallengeModel:ctor()

end

function ChallengeModel:init()
    
end

function ChallengeModel:isSystemOpen(typeID)
    local value = FuncChallenge.getOpenLevelByitemId(typeID)
    local isopen ,values = FuncCommon.isSystemOpen(typeID)
    if isopen == false then
        return false,values
    end
    return UserModel:checkCondition( value )
end

function ChallengeModel:getOpenLevel(typeID)
    local value =  FuncCommon.getSysOpenValue(typeID, "condition")  --FuncChallenge.getOpenLevelByitemId(typeID)
    return value[1].v
end

function ChallengeModel:getDayTimesBySystemId(typeID)
    if typeID == ChallengeModel.KEYS.TOWER then
        -- return TowerNewModel:getTowerResetLeftCount()
        -- TODO by ZhangYanguang
        return TowerMainModel:getResetNum()
    elseif typeID == ChallengeModel.KEYS.PVP then
        --购买的挑战次数
        local buyCount = CountModel:getPVPBuyChallengeCount()
        --已经挑战的次数
        local callengeCount = CountModel:getPVPChallengeCount()
        local firstTime = PVPModel:firstTime()
        local left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
        return left
    elseif typeID == ChallengeModel.KEYS.TRIAL then 
        local num = TrailModel:getAllCountNum()
        return num
    elseif typeID == ChallengeModel.KEYS.DEFENDER then
        return DefenderModel:getDefenderResetLeftCount()  ---TODO
    end
    
end

function ChallengeModel:getIconsBySystemId(typeID)
    local itemIds = FuncChallenge.getIconByitemId(typeID)
    return itemIds
end


function ChallengeModel:checkShowRed(  )
    --试炼
    local isopen = self:isSystemOpen(ChallengeModel.KEYS.TRIAL)
    if isopen == nil then
        if TrailModel:showChallengTrailMainRed() then   --试炼
            return true
        end
    end
    -- if PVPModel:isRedPointShow() then --pvp  登仙台
    --     return true
    -- end
    if WorldModel:showEliteRedPoint() then    -- 忆梦
        return true
    end

    -- if MissionModel:isShowRed() then  --六界轶事
    --     return true
    -- end
    if EndlessModel:updateRedPointStatus() then  --无底生渊
        return true
    end

    --Author:      zhuguangyuan
    --DateTime:    2018-04-16 15:52:27
    --Description: 修改锁妖塔红点逻辑 
    -- 三测以前的锁妖塔红点 只判断是否有重置次数
    -- 三测版本更新:领取主界面宝箱与否 有重置次数与否 搜刮红点
    -- if TowerMainModel:getResetNum() > 0 then
    --     return true
    -- end
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TOWER) and TowerMainModel:checkTowerAllRedPoint() then  --锁妖塔
        return true 
    end

    if WonderlandModel:shoehomeRed() then   --须于仙境
        return true
    end

    return false
end

-- function ChallengeModel:setButtonData(button)
--     -- {view = view,typeId = typeId}
--     local typeId = button.typeId
--     if typeId ~= nil then
--         if #self.buttonData ~= 0 thenChallengeModel:setButtonData(
--             local ishave = false
--             for i=1,#self.buttonData do
--                 if self.buttonData[i].typeId == typeId then
--                     ishave = true
--                 end
--             end
--             if not ishave then
--                 table.insert(self.buttonData,button)
--             end
--         else
--             table.insert(self.buttonData,button)
--         end 
--     end
    
-- end
--
function ChallengeModel:getChallengeSystemPos(systemName)
    local challengeView = WindowControler:getWindow("ChallengeView") 
    if not challengeView then
        return nil 
    end
    --跳转到对应的位置
    local groupIndex = challengeView:todoView(systemName)
    local _viewArr = challengeView.scroll_1:getAllView()
    for i=1,#_viewArr do
        if i == groupIndex then
            local box = _viewArr[i]:getContainerBox()
            local cx = box.x + box.width/2
            local cy = box.y + box.height/2
            turnPos = _viewArr[i]:convertToWorldSpaceAR(cc.p(cx,cy))
            echo("========系统位置  x   y  =========",turnPos.x,turnPos.y)
            return  turnPos
        end
    end

    --获取按钮的位置
    -- for i=1,#self.buttonData do
    --     local buttonData = self.buttonData[i]
    --     local panel = buttonData.view
    --     local name = buttonData.typeId
    --     if name == systemName then
    --         local box = panel:getContainerBox()
    --         local cx = box.x + box.width/2
    --         local cy = box.y + box.height/2
    --         turnPos = panel:convertToWorldSpaceAR(cc.p(cx,cy))
    --         echo("========系统位置  x   y  =========",turnPos.x,turnPos.y)
    --         return  turnPos
    --     end
    -- end
    return nil
end


function ChallengeModel:getChallengModelData()
    local config_challenge = FuncChallenge.getPveSystemData()
    local newArr = {}
    for k,v in pairs(config_challenge) do
        table.insert(newArr,v) 
    end
    table.sort( newArr, function (a,b)
        return a.order < b.order
    end )
    return newArr
end








return ChallengeModel;





















