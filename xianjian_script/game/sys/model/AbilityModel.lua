--
-- Author: xd
-- Date: 2018-06-20 19:24:02
--
--[[
	战力相关model
	treasures = {
		404 = {
			addAbility=  101,
			lvAddAbility = 10,
		}...
	} ,
	--主角战力
	char = {
		initAbility =10,
		ratioAddAbility = 10,
		addAbility = 10,
		initAddAbility =10,
		initLvAbility =10,
		skillAbility = 10,
		baseTotal = 10,
		total = 1000,	--主角总战力
	}
	--伙伴战力
	partners = {
		5001 = {
			x = 10000,
			treaRatioAbility = 0,
			initAbility = 10,
			initLvAbility =10,
			addAbility = 10,
			total =10,		--单个伙伴当前战力
			ratioAddAbility =10,
			skillAbility = 10,
		}
	}...
	formationTotal = 10001, 	--阵容总战力
	maxFormationTotal = 1330


]]
local AbilityModel = class("AbilityModel", BaseModel)


function AbilityModel:init( d )
	AbilityModel.super.init(AbilityModel,d)
end


function AbilityModel:updateData( data )
	local  _old_ability= self:getTotalAbility()

	AbilityModel.super.updateData(self,data)
    
	if data.abilityNew and data.abilityNew.formationTotal ~= nil and (_old_ability ~= data.abilityNew.formationTotal) then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
            {prePower = oldPower, curPower = newPower}); 

        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, 
            {questType = TargetQuestModel.Type.POWER});  
    end

end

--获取当前的总战力
function AbilityModel:getTotalAbility(  )
	return self._data.formationTotal
end


--获取某个伙伴的战力
function AbilityModel:getPartnerAbility( partnerId )
	local partners = self._data.partners
	local info = partners[tostring(partnerId)]
	if not info then
		echoError("战力表里没有这个伙伴:",partnerId)
		return  0
	end

    local total = 0
    for k,v in pairs(info) do
        total = total + v
    end

	return total
end

--获取主角战力
function AbilityModel:getCharAbility()
	if self._data.char and self._data.char[tostring(UserModel:avatar())] then
        local total = 0
        for k,v in pairs(self._data.char[tostring(UserModel:avatar())]) do
            total = total + v
        end

		return total
	end
	return  0
end

--获取阵容战力
function AbilityModel:getFormationAbility( )
	return self._data.formationTotal
end



--根据传入的参数获取战力 如果不传参数,那么直接获取 服务器存储的战力.节省效率
-- 计算总战力
--[[
 local params = {
        treasureId = treasureId,
        team = teamFormation
    }
-- 计算公式：主角[穿戴中的法宝]战力+上阵伙伴战力(pve)+神器系统战力；
-- 先以后端为主
新：包括：主角战力[计算了穿戴法宝提供的技能战力]+
          上阵伙伴战力+
          神器系统战力+
          所有法宝的全局养成战力+
          五灵养成系统提供战力 + 
          情景卡带来的战力
]]

function AbilityModel:getAbility( params )
	if not params then
		return self:getTotalAbility()
	end
	local teamFormation 
    local treasureId = TeamFormationModel:getOnTreasureId()
    if params and params.team then
        teamFormation = params.team
    else
     	teamFormation = TeamFormationModel:getFormation(FuncTeamFormation.formation.pve)
    end
    if params and params.treasureId then
        treasureId = params.treasureId
    end
    -- echo(treasureId,"___AbilityModel:getAbility___")
    local ability = 0
    local charAbility = CharModel:getCharAbility(treasureId)
    local partners = teamFormation.partnerFormation
    local partnerAbility = 0
    local wulingAbility = 0
    local teamPartners = {}
    local  handbookPower =FuncHandbook.getAllHandBookAddition( UserModel:data() )
    -- local expandMap = {handbooks = handbookPower}
    for i = 1,6 do
        local id = partners["p"..i].partner.partnerId
        if id and tonumber(id) ~= 1 and tonumber(id) ~= 0 then
            local partnerData = PartnerModel:getPartnerDataById(tostring(id))
            if partnerData then
                partnerAbility = partnerAbility + FuncPartner.getPartnerAbility(partnerData,UserModel:data(), teamFormation,nil,expandMap)
                table.insert(teamPartners, id)
            end
            
        end
        local elementId = partners["p"..i].element.elementId 
        -- 上阵五灵战力
        if tostring(elementId) ~= "0" and tostring(id) ~= "0" then
            local tempWulingAbility = WuLingModel:getTempAbility(elementId)
            wulingAbility = wulingAbility + tempWulingAbility
            if tonumber(id) == 1 then
                local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
                local partnerElement = dataCfg.wuling
                local awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement,elementId)
                wulingAbility = wulingAbility + awakenAbility
            elseif not FuncPartner.isChar(id) then
                local partnerData = FuncPartner.getPartnerById(id)
                if partnerData then
                    local partnerElement = partnerData.elements
                    local awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement,elementId)
                    wulingAbility = wulingAbility + awakenAbility
                end                
            end
        end   
        -- 五灵激活元素战力
    end
    local baowuAbility = FuncArtifact.getArtifactAllPower( UserModel:getAbilityUserData(),treasureId,teamPartners)

    local allTreasAbility = TreasureNewModel:getAllTreasStarAbility()
    
    local memeryCardAbility = FuncMemoryCard.getPowerByPartnerId( MemoryCardModel:data() )
    
    ability = charAbility + partnerAbility + baowuAbility + allTreasAbility + wulingAbility + 
                memeryCardAbility
    -- echo("上阵法宝ID === ",treasureId)
    -- echo("主角战力 === ",charAbility)
    -- echo("上阵伙伴总战力战力 === ",partnerAbility)
    -- echo("宝物战力 === ",baowuAbility)
    -- echo("法宝加成 == ",allTreasAbility)
    -- echo("wulingAbility = ",wulingAbility)
    -- echo("memeryCardAbility = ",memeryCardAbility)
    -- echo("==============阵容 总战力 ==== ",ability)
    return ability
end

return AbilityModel