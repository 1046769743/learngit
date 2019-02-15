--
-- Author: gaoshuang
-- Date: 2016-12-12
-- 站前 站人





--[[
站前站人数据
]]
local TeamFormationMultiModel = class("TeamFormationMultiModel",BaseModel)


function TeamFormationMultiModel:init( d )
    TeamFormationMultiModel.super.init(self,d)
    --echoError("绑定消息==============")
    --EventControler:addEventListener("notify_mu_formation_update_formation_4712",self.notifyFormationUpdate,self)

    --EventControler:addEventListener("notify_battle_formation_update_5016",self.notifyFormationHandle,self)
    EventControler:addEventListener("notify_battle_formation_update_5016",self.notifyFormationUpdate,self)
    EventControler:addEventListener("nofify_battle_multi_lockstate_changed_5012",self.formationLockStateChanged,self)

    --EventControler:addEventListener("notify_battle_battleStart_5036",self.notifyStartBattle,self)

end



--[[
加入房间的数据更新，相当于获取了当前玩家的所有的伙伴信息  和初始化阵容信息
]]
function TeamFormationMultiModel:updateData(d)

    -- echo("Push 回来的阵容信息==================")
    -- LogsControler:writeDumpToFile(d)
    --echo("Push 回来的阵容信息==================")
    

    -- dump(d,"匹配数据玩家")
    -- LogsControler:writeDumpToFile(d, 8, 8)


    self.partnersMine = {}
    self.partnersOther = {}

    local data = d.battleUsers
    for k,v in pairs(data) do
        if tostring(v.rid) == UserModel:rid() then
            --玩家自己的BattleUser
            self.rid = v.rid
            self.mainavatar = v.avatar
            local mainHero = {}
            mainHero.avator = v.avatar
            mainHero.level = v.level
            mainHero.name = v.name or UserModel:name()           --玩家自己的名字
            mainHero.quality = v.quality
            mainHero.star = v.star
            mainHero.starInfo = v.starInfo
            mainHero.starLights = v.starLights
            mainHero.states = v.states
            mainHero.talents = v.talents
            mainHero.rid = self.rid
            mainHero.id = 1
            self.mainHeroMine = mainHero
            if empty(self.formationLockState) then
                self.formationLockState = {}
            end
            if empty(self.formationLockState[tostring(self.rid)]) then
                self.formationLockState[tostring(self.rid)] = {}
            end
            self.formationLockState[tostring(self.rid)].lock = v.lock
            self:initPartners(v.partners,self.rid)
            self:initTreasure(v.treasures,self.rid)

        else
            self.otherRid = v.rid
            local mainHero = {}
            self.otheravatar = v.avatar
            mainHero.avator = v.avatar
            mainHero.level = v.level
            mainHero.name = v.name or UserModel:name()           --玩家自己的名字
            mainHero.quality = v.quality
            mainHero.star = v.star
            mainHero.starInfo = v.starInfo
            mainHero.starLights = v.starLights
            mainHero.states = v.states
            mainHero.talents = v.talents
            mainHero.rid = self.otherRid
            mainHero.id = 1
            self.mainHeroOther = mainHero
            self:initPartners(v.partners,self.otherRid)
            self:initTreasure(v.treasures,self.otherRid)
            if v.userExt ~= nil then
                self.othergarmentId = v.userExt.garmentId or ""
            end

        end
    end

    --echo(self.rid)


    -- self:initPartners(data.partners)


    -- self:initTreasure(data.treasures)

    self:initMultiFormation(d.formation)
    self.roomId = d.battleId

    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MULITI_UPDATE_FORMATION)




end


--[[
获取当前的房间id
]]
function TeamFormationMultiModel:getRoomId()
    return self.roomId
end




--[[
阵型信息发生改变
]]
function TeamFormationMultiModel:notifyFormationUpdate(e)
    --echoError("阵型信息发生改变")
    --dump(e.params.params)
    --LogsControler:writeDumpToFile(e.params.params)
    local data = e.params.params.data
    --echo("阵型信息发生改变")
    --self:updateData(data)
    self:initMultiFormation(data.formation)

    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MULITI_UPDATE_FORMATION)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_TREA, {changeHeroType = true})
end



--[[
玩家阵型状态锁定更改
]]
function TeamFormationMultiModel:formationLockStateChanged(e)

    -- local aa = e.params.params
    -- LogsControler:writeDumpToFile(aa,8,8)

    local data = e.params.params.data
    --LogsControler:writeDumpToFile(aa, 8, 8)

    if  empty(self.formationLockState) then
        self.formationLockState = {}
    end
    if empty(self.formationLockState[tostring(data.rid)]) then
        self.formationLockState[tostring(data.rid)] = {}
    end

    self.formationLockState[tostring(data.rid)].lock = data.lock
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MULITI_LOCKSTATE_CHANGED)

end

--[[
获取当前阵型的锁定状态
]]
function TeamFormationMultiModel:getFormationLockState()
    if empty(self.formationLockState) then
        return 0
    end
    if empty(self.formationLockState[tostring(self.rid)]) then
        return 0
    end

    return self.formationLockState[tostring(self.rid)].lock
end


--[[
当前时间超时不能更换位置操作
]]
function TeamFormationMultiModel:setTimeOutLock()
    if empty(self.formationLockState) then
        self.formationLockState = {}
    end
    if empty(self.formationLockState[tostring(self.rid)]) then
        self.formationLockState[tostring(self.rid)] ={}
    end

    self.formationLockState[tostring(self.rid)].lock = 1

end

--[[
重置状态
]]
function TeamFormationMultiModel:resetTimeOut()
    self.formationLockState = {}
end



-- function TeamFormationMultiModel:notifyFormationHandle(e)
--     local data = e.params.data
--     echo("玩家执行的操作")
--     dump(data)
--     echo("玩家执行的操作")
-- end






--[[
初始化伙伴信息
并且保存在当前的TeamFormationMultiMode中
]]
function TeamFormationMultiModel:initPartners(data,rid)


    if empty(data) then
        if tostring(rid) == tostring(self.rid) then
            self.partnersMine = {}
        else
            self.partnersOther = {}
        end
        return
    end

    if tostring(rid) == tostring(self.rid) then
        self.partnersMine = data
    else
        self.partnersOther = data
    end
    --dump(self.partnersMine)


end



--[[
初始化法宝信息
]]
function TeamFormationMultiModel:initTreasure(data,rid)

    --echoError("rid",rid,self.rid, tostring(rid) == tostring(self.rid))
    -- LogsControler:writeDumpToFile("rid",rid,self.rid, tostring(rid) == tostring(self.rid))
    -- LogsControler:writeDumpToFile(data,88,88)
    

    if tostring(rid) == tostring(self.rid) then
        self.treasureMine = data
    else
        --echo("self.treasureOther==============================")
        --dump(data)
        --LogsControler:writeDumpToFile(data,8,8)
        self.treasureOther = data
    end
    
    --dump(self.treasureMine)
end




--[[
初始化阵容信息并且保存  

当前的TeamFormationMultiMode中


]]
function TeamFormationMultiModel:initMultiFormation(data)
    self.formation = data
end


--[[
获取我方上阵法宝
]]
function TeamFormationMultiModel:getCurTreaByIdx(index)
    -- dump(self.formation)
    -- dump(self.treasureMine)
    -- dump(self.treasureOther)

    local trea = self.formation.treasureFormation
    if index == 1 then
        if trea[self.rid] and self.treasureMine then
            local treaId = trea[self.rid]
            local treasure = self.treasureMine[tostring(treaId)]
            return treasure
        end
        return nil
    else
        if trea[self.otherRid] and self.treasureOther then
            local treaId = trea[self.otherRid]
            local treasure = self.treasureOther[tostring(treaId)]
            return treasure
        end
        return nil
    end
end
--伙伴条件排序
function TeamFormationMultiModel:partnerDataPaixu(systemId,partnerData)

    local newtable = {}
    local chardata = nil
    local nottable = {}
    for k,v in pairs(partnerData) do 
        local itemType = self:getPropByPartnerId(v.id)
        if systemId == FuncTeamFormation.formation.trailPve1 and itemType == 2 then
            table.insert(nottable,v)
        elseif systemId == FuncTeamFormation.formation.trailPve2 and itemType == 1 then  
            table.insert(nottable,v)
        elseif systemId == FuncTeamFormation.formation.trailPve3 and itemType ~= 3 and itemType ~= 0 then
            table.insert(nottable,v)
        elseif itemType == 0 then
            chardata = v
        else
            table.insert(newtable,1,v)
        end
    end
    if chardata ~= nil then
        table.insert(newtable,1,chardata)
    end
    nottable = self:tableSort(nottable)
    newtable = self:tableSort(newtable)

    -- for k,v in pairs(nottable) do
    --     table.insert(newtable,v)
    -- end
    for i=1,#nottable do
        table.insert(newtable,nottable[i])
    end
    return newtable
end

--[[
根据  攻防辅的类型  获取当前的伙伴列表
获取伙伴信息肯定都是我方的
]]
function TeamFormationMultiModel:getNPCsByTy(ty, type)
    local partners = self.partnersMine or PartnerModel:getAllPartner()
    local playType = type or false
    local npcs = {}
    for k,v in pairs(partners) do
        local npcCfg = FuncPartner.getPartnerById(v.id)
        if ty == 0 or npcCfg.type == ty or npcCfg.type == TrailModel.partnerType.defense then
            local temp = {}
            temp.id = v.id
            temp.level = v.level
            temp.exp = v.exp
            temp.position = v.position
            temp.quality = v.quality 
            temp.skills = v.skills 
            temp.star = v.star
            temp.starPoint = v.starPoint
            temp.type = npcCfg.type 
            temp.icon = npcCfg.icon 
            temp.sourceId = npcCfg.sourceld
            temp.dynamic = npcCfg.dynamic
            temp.order = 0
            temp.elements = npcCfg.elements
            table.insert(npcs,  temp)
        end
    end
    local player = {}
    player.id = 1
    player.level =  UserModel:level()
    player.type = 0
    --player.exp = UserModel:exp()
    player.star = UserModel:star()
    player.order = 1
    player.quality = UserModel:quality()
    if self.formation then
        local teampData =  FuncTreasureNew.getTreasureDataById(self.formation.treasureFormation[tostring(self.rid)])
        player.elements = teampData.wuling
    end    
    if ty == 0 or playType then
        table.insert(npcs, player)
    end

    self:tableSort(npcs)
    return npcs
end
function TeamFormationMultiModel:byTygetAllNPCs(ty)
    echo("===========ty===========",ty)
    local partners = self.partnersMine or PartnerModel:getAllPartner()
    local playType = type or false
    local npcs = {}
    for k,v in pairs(partners) do
        local npcCfg = FuncPartner.getPartnerById(v.id)
        local tempAbility = PartnerModel:getPartnerAbility(v.id)
        if ty == 0 or npcCfg.type == ty  then
            local temp = {}
            temp.id = v.id
            temp.level = v.level
            temp.exp = v.exp
            temp.position = v.position
            temp.quality = v.quality 
            temp.skills = v.skills 
            temp.star = v.star
            temp.starPoint = v.starPoint
            temp.type = npcCfg.type 
            temp.icon = npcCfg.icon 
            temp.sourceId = npcCfg.sourceld
            temp.dynamic = npcCfg.dynamic
            temp.order = 0
            temp.tempAbility = tempAbility
            table.insert(npcs,  temp)
        end
    end
    local player = {}
    player.id = 1
    player.level =  UserModel:level()
    player.type = 0
    --player.exp = UserModel:exp()
    player.star = UserModel:star()
    player.order = 1
    player.quality = UserModel:quality()

    if ty == 0 then
        table.insert(npcs, player)
    end

    self:tableSort(npcs)
    return npcs
end
function TeamFormationMultiModel:tableSort(arrdata)
    -- dump(arrdata,"111111111111111",8)
   local  newtable = {}
   table.sort(arrdata, c_func(self.hasNowRule, self))
   newtable = arrdata 
   return newtable
end

function TeamFormationMultiModel:hasNowRule(a,b)
    FuncTeamFormation.partnerSortRule(a, b)
end

--[[
一键布阵
]]
function TeamFormationMultiModel:allOnFormation()
    local trialtype = TrailModel.trialselectType or 1 
    local _type = TrailModel:byTypegetPT( trialtype )
    local allNpcs = self:getNPCsByTy(_type,true)
    local tempHeroNum = 0
    local index = 1
    local tempChangeTeam = {}
    tempChangeTeam.battleId = self.roomId
    tempChangeTeam.treasureId = self.formation.treasureFormation[tostring(self.rid)]
    tempChangeTeam.partnerFormation = {}
    local nextBegainNum =1
    local tempWuXingNum = 0
    for k = 1,3 do
        local heroId = "0"
        if allNpcs[k] ~= nil then
            if allNpcs[k] ~= nil and heroId =="0" then
                heroId = allNpcs[k].id
                if allNpcs[k].id == "0" then
                    return
                end
            end
            local tempNum =0
            for v = nextBegainNum,6 do 
                if self.formation.partnerFormation["p"..v]
                    and self.formation.partnerFormation["p"..v].partner.partnerId ~= "0" 
                    and self.formation.partnerFormation["p"..v].partner.rid ~=self.rid then
                else   
                    tempChangeTeam.partnerFormation["p"..v] = {}
                    tempChangeTeam.partnerFormation["p"..v].partner = {}
                    tempChangeTeam.partnerFormation["p"..v].partner.partnerId = heroId
                    tempChangeTeam.partnerFormation["p"..v].partner.rid = UserModel:rid()
                    tempChangeTeam.partnerFormation["p"..v].element = {} 
                    local tempAllWuXing = self:wuxingHasPosNum()
                    if FuncCommon.isSystemOpen("fivesoul") and tempWuXingNum < tempAllWuXing then
                        -- if tonumber(heroId) ~= 1 then
                            tempChangeTeam.partnerFormation["p"..v].element.elementId = tostring(allNpcs[k].elements)
                        -- else
                        --     tempChangeTeam.partnerFormation["p"..v].element.elementId = "0"
                        -- end   
                        tempWuXingNum = tempWuXingNum +1 
                    end    
                    tempChangeTeam.partnerFormation["p"..v].partner.rid = UserModel:rid()
                    -- self.formation.partnerFormation["p"..v].garmentId = self.garmentId
                    nextBegainNum = v+1
                    break
                end
            end 
        else
            
        end
    end

    for v = nextBegainNum,6 do 
        if self.formation.partnerFormation["p"..v]  and self.formation.partnerFormation["p"..v].partner.rid == self.rid then
            self.formation.partnerFormation["p"..v].partnerId = "0"
        end
    end
    TeamFormationServer:doLineUpPartner(tempChangeTeam,nil)
    --     local isOpen,lv = FuncTeamFormation.checkPosIsOpen( k )
    --     if not isOpen then heroId = "0" end
    --     self.tempFormation.partnerFormation["p"..k] = heroId
    -- end
end




--[[
判断当前npc是否上阵了
]]
function TeamFormationMultiModel:chkIsInFormation(id)
    local formation = self.formation.partnerFormation
    --dump(formation)

    for k,v in pairs(formation) do
        if tostring(v.partner.rid) == tostring(self.rid) then
            if tostring(v.partner.partnerId) == tostring(id) then
                return true
            end
        end
    end

    return false

end



--[[
根据hid获取当前在哪个阵位上
]]
function TeamFormationMultiModel:getPartnerPIdx(hid)
    local formation = self.formation.partnerFormation
    --dump(formation)

    for k,v in pairs(formation) do
        if tostring(v.partner.rid) == tostring(self.rid) then
            if tostring(v.partner.partnerId) == tostring(hid) then
                return toint( string.sub(k,2) )
            end
        end
    end
    return 0
end




--[[
获取玩家自己的法宝列表
]]
function TeamFormationMultiModel:getAllTreas()
    local treas = {}
    --dump(self.treasureMine)
    for k,v in pairs(self.treasureMine) do
        table.insert(treas,v)
    end
    return treas
end


--[[
判断当前法宝是否在上阵了
]]
function TeamFormationMultiModel:chkTreaInFormation(id)
local formation =  self.formation.treasureFormation
    if formation[tostring(self.rid)] then
        if tostring(formation[tostring(self.rid)]) == tostring(id) then
            return true
        end
    end
    return false
end


--[[
获取当前位置上的英雄
]]
function TeamFormationMultiModel:getHeroByIdx(pIdx)
    if self.formation.partnerFormation["p"..pIdx] then
        return self.formation.partnerFormation["p"..pIdx]
    end
    local target = {}
    target.partner = {}
    target.partner.partnerId = "0"
    target.partner.rid = "0"
    target.element = {}
    target.element.elementId = "0"
    target.element.rid = ""
    return target
end

--[[
根据类型 获取自动所在的位置
]]
function TeamFormationMultiModel:getAutoPIdx(ty)
    local cnt = self:chkOnFormationCnt()
    if cnt >= 3 then
        return -1
    end


    --这里直接先给他取一个位置  不按照类型来  优化的时候修改

    local formation = self.formation.partnerFormation

    for i=1,6,1 do
        if formation[tostring("p"..i)] == nil or formation[tostring("p"..i)].partner.partnerId == "0" then
            return i
        end
    end

    return -1
end




--[[
检查是否可以移动到目标位置
]]
function TeamFormationMultiModel:chkTargetPos(pIdx)

end


--[[
检查当前位置是否可以进行操作，可以移动
当前的的位置上的任务是可以移动的。玩家再点击任务来判断
]]
function TeamFormationMultiModel:chkSrcPos(pIdx)
    local formation = self.formation.partnerFormation
    if formation[tostring("p"..pIdx)] then
        if tostring( formation[tostring("p"..pIdx)].rid ) == tostring(self.rid) then
            return true
        end
    end
    return false
    -- for k,v in pairs(formation) do
    --     if tostring(v.rid) == tostring(self.rid) then
    --         if tostring(v.partnerId)==tostring(p)
    --     end
    -- end
end


--[[
检测当前玩家上阵的个数
如果玩家上阵的个人大于 三个 则 不能再上阵伙伴
]]
function TeamFormationMultiModel:chkOnFormationCnt()
    local formation = self.formation.partnerFormation
    local cnt = 0
    for k,v in pairs(formation) do
        if tostring(v.rid) == tostring(self.rid) then
            cnt = cnt+1
        end
    end
    return cnt
end


--[[
获取当前伙伴是攻防辅特性
]]
function TeamFormationMultiModel:getPropByPartnerId( pId )
    pId = tostring(pId)
    if pId == "1" then
        return 0
    else
        local allNpcs = self:getNPCsByTy(0)
        for k,v in pairs(allNpcs) do
            if tostring(v.id)  == tostring(pId) then
                return v.type
            end
        end
        return 0
    end
end

function TeamFormationMultiModel:createMultiWuXing()
    self.chooseWuXingNum = {}
    for k=1,6 do
        if k ==6 then
            self.chooseWuXingNum[k] = 6
        else
            self.chooseWuXingNum[k] = FuncTeamFormation.getMultiWuXingNum(k,UserModel:level())
        end
    end
    for k = 1,6,1 do 
        if self.formation.partnerFormation["p"..k].element.elementId ~= "0" and self.formation.partnerFormation["p"..k].element.rid == self.rid and self.formation.partnerFormation["p"..k].element.elementId ~= "" then
            local tempWuXing = self.formation.partnerFormation["p"..k].element.elementId
            self.chooseWuXingNum[tonumber(tempWuXing)] = self.chooseWuXingNum[tonumber(tempWuXing)] - 1
        end
    end
end


function TeamFormationMultiModel:getMultiTempAbility()
    local ability = 0
    local teamFormation = self.formation
    local treasureId = teamFormation.treasureFormation[tostring(self.rid)]
    ability = UserModel:getTeamAbility(treasureId,teamFormation)
    return ability
end

function TeamFormationMultiModel:getCharAbility( )
    local charData = CharModel:getCharData()
    local teamFormation = self.formation
    local treasureId = teamFormation.treasureFormation[tostring(self.rid)]
    echo("----主角的 上阵法宝ID === ",treasureId)
    local treasuredata = TreasureNewModel:getTreasureData(tostring(treasureId))
    dump(treasuredata,"法宝数据")
    local treasureLevel = UserModel:level()
    local titleData = TitleModel:getHisData()
    local ownGarments = GarmentModel:getAllServerGarments()
    local garmentIds = FuncGarment.getEnabledGarments(ownGarments,true)
    --local artifactData = ArtifactModel:data() -- 宝物不要了
    local lovesData = UserModel:loves()
    local userData = UserModel:getUserData()
    local params = {
        chard = charData,
        trsd = treasuredata,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentId,
        loved = lovesData,
        userd = userData
    }
    local ability = FuncChar.getCharAbility(params)
    echo("主角战力 === ",ability)
    return  math.floor(ability)
end

function TeamFormationMultiModel:getMineNowPosNum()
    local tempNum = 0
    for k=1,6 do
        local isCanAdd = true
        if self.formation.partnerFormation["p"..k].partner.rid == self.rid then
            tempNum = tempNum +1
            isCanAdd = false
        end

        if self.formation.partnerFormation["p"..k].element.rid == self.rid and isCanAdd then
            tempNum = tempNum +1
        end
    end
    return tempNum
end

function TeamFormationMultiModel:getNowWuXingDataNum(id)
    return self.chooseWuXingNum[tonumber(id)]
end

function TeamFormationMultiModel:getPosWuXingById(pIdx)
    local nowWuXingId = self.formation.partnerFormation["p"..pIdx].element.elementId
    return nowWuXingId
end

function TeamFormationMultiModel:getAllWuXinNum()
    local hasNum = 0
    for i=1,6 do
    if self.formation.partnerFormation["p"..i].element.elementId ~= "0"  and self.formation.partnerFormation["p"..i].element.rid == self.rid then
            hasNum = hasNum +1
        end
    end
    return hasNum
end

function TeamFormationMultiModel:wuxingHasPosNum()
    local nowWuXingPosNum,nowLevel = FuncTeamFormation.checkMulitWuXingPosOpen(UserModel:level())
    return nowWuXingPosNum
end

function TeamFormationMultiModel:getTempFormation()
   return self.formation
end

return TeamFormationMultiModel
