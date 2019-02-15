local TeamFormationSupplyModel = class("TeamFormationSupplyModel",BaseModel)


function TeamFormationSupplyModel:init( d )
    TeamFormationSupplyModel.super.init(self,d)
end    

function TeamFormationSupplyModel:getTeamData(systemId)
    return 
end

--因为仙盟探索布阵与锁妖塔布阵 都需要继承血量 所以添加systemId 用以扩展该方法
function TeamFormationSupplyModel:getNPCsByTy(ty, excludeMainHero, systemId)
    local systemId = systemId
    if not systemId then
        systemId = FuncTeamFormation.formation.pve_tower
    end

    --echo("ty",ty,"=============================")
    local partners = PartnerModel:getAllPartner()
    local partnersSupply, banPartners = nil

    if systemId == FuncTeamFormation.formation.pve_tower then
        partnersSupply, banPartners = TowerMainModel:getTowerTeamFormation()
    elseif systemId == FuncTeamFormation.formation.guildExplorePve then
        partnersSupply, banPartners = GuildExploreModel:getGuildExploreTeamFormation()
    end

    -- echo("获取当前所有的npcs----")
    -- dump(partners)
    -- echo("获取当前所有的npcs----")
    local npcs = {}
    --可用的奇侠列表
    local enabledNpcs = {}
    --被劫持的奇侠列表
    local banNpcs = {}
    --已阵亡的奇侠列表
    local deadNpcs = {}
    for k,v in pairs(partnersSupply) do
        if v.teamFlag and v.teamFlag == 1 then
            local temp = {}
            local enemyInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", v.hid)
            temp.id = tonumber(v.hid)
            temp.teamFlag = v.teamFlag 
            temp.icon = enemyInfo.icon 
            temp.order = 2
            temp.tempAbility= 100
            temp.star = 1
            temp.quality= 1
            temp.level = 1
            temp.HpPercent = v.hpPercent or 10000
            if temp.HpPercent <= 0 then

            else    
                table.insert(enabledNpcs, temp)
            end 
        end
    end
    for k,v in pairs(partners) do
        local tempAbility = PartnerModel:getPartnerAbility(v.id)
        local npcInfo = partnersSupply[tostring(v.id)]
        local temp = FuncTeamFormation.createFormationNpcs(ty, v, tempAbility, nil, nil, npcInfo, banPartners)
        if temp then
            if temp.hasBan then
                table.insert(banNpcs,temp)
            elseif temp.HpPercent <= 0 then
                table.insert(deadNpcs,temp)
            else
                table.insert(enabledNpcs,temp)
            end
        end    
    end
    
    local playHid = UserModel:getCharId()
    local playInfo = partnersSupply[tostring(playHid)]
    local player = {}
    player.id = 1
    player.level = UserModel:level()
    --暂定  todo dev
    player.type = 4
    player.exp = UserModel:exp()
    player.star = UserModel:star()
    if not excludeMainHero then
        player.order = 1
    else
        player.order = 0
    end
    player.quality = UserModel:quality()
    if playInfo then
        player.HpPercent = playInfo.hpPercent
        player.fury = playInfo.energyPercent
    else
        player.HpPercent = 10000
        player.fury = 0
    end
    local tempData = FuncTreasureNew.getTreasureDataById(TeamFormationModel:getCurTreaByIdx(1))
    player.elements = tempData.wuling    

    --player.sourceld
    if (ty == 0 or player.type == ty) then
        if player.HpPercent <= 0 then
            table.insert(deadNpcs,player)
        else    
            table.insert(enabledNpcs,player)
        end    
    end

    --这里应该有一个排序，上阵的，然后是品质，等等  这里进行一次排序，玩家自己放在最前面
    table.sort(enabledNpcs, c_func(self.hasNowRule,self))
    table.sort(deadNpcs, c_func(self.hasNowRule,self))
    table.sort(banNpcs, c_func(self.hasNowRule,self))

    for i,v in ipairs(enabledNpcs) do
        npcs[#npcs + 1] = v
    end

    for i,v in ipairs(banNpcs) do
        npcs[#npcs + 1] = v
    end

    for i,v in ipairs(deadNpcs) do
        npcs[#npcs + 1] = v 
    end

    return npcs, enabledNpcs
end

function TeamFormationSupplyModel:hasNowRule(a,b)
    return FuncTeamFormation.partnerSortRule(a, b)
end

-- 判断一个奇侠是否被劫持  需要先判断是否是锁妖塔布阵中
function TeamFormationSupplyModel:isPartnerBan(partnerId, systemId)
    local systemId = systemId
    if not systemId then
        systemId = FuncTeamFormation.formation.pve_tower
    end

    local banPartners = nil
    if systemId == FuncTeamFormation.formation.pve_tower then
        _, banPartners = TowerMainModel:getTowerTeamFormation()
    elseif systemId == FuncTeamFormation.formation.guildExplorePve then
        _, banPartners = GuildExploreModel:getGuildExploreTeamFormation()
    end

    for k,v in pairs(banPartners) do
        if tostring(partnerId) == tostring(k) then
            return true
        end
    end
    return false
end

function TeamFormationSupplyModel:checkIsDead(_id, systemId)
    local systemId = systemId
    if not systemId then
        systemId = FuncTeamFormation.formation.pve_tower
    end

    local partnersSupply = nil

    if systemId == FuncTeamFormation.formation.pve_tower then
        partnersSupply = TowerMainModel:getTowerTeamFormation()
    elseif systemId == FuncTeamFormation.formation.guildExplorePve then
        partnersSupply = GuildExploreModel:getGuildExploreTeamFormation()
    end

    local partnersData =nil
    if tonumber(_id) == 0 then
        return false
    end

    if tonumber(_id) == 1 then
        local playHid = UserModel:getCharId()
        partnersData = partnersSupply[tostring(playHid)]
    else
        partnersData = partnersSupply[tostring(_id)]
    end
    if partnersData then
        if tonumber(partnersData.hpPercent) <= 0 then
            return true
        end
    end    
    return false
end


return TeamFormationSupplyModel