--
-- Author: gaoshuang
-- Date: 2016-12-12
-- 站前 站人
--[[
partnerFormation = {
	p1 = {
		partner = {
			partnerId = 5023,
			rid = "00000"
		},
		element = {
			elementId = 1,
			rid = "00000"
		}
	},
	p2 = {
		partner = {
			partnerId = 5023,
			rid = "00000"
		},
		element = {
			elementId = 1,
			rid = "00000"
		}
	},
	p3 = {
		partner = {
			partnerId = 5023,
			rid = "00000"
		},
		element = {
			elementId = 1,
			rid = "00000"
		}
	},
	p4 = {
		partner = {
			partnerId = 5023,
			rid = "00000"
		},
		element = {
			elementId = 1,
			rid = "00000"
		}
	},
	....
	
}

treasureFormation = {
	p1 = "404",
	p2 = "304"
}


partnerFormation2 = {
	p1 = {
		partner = {
			partnerId = 5024,
			rid = "00000"
		},
		element = {
			elementId = 1,
			rid = "00000"
		}
	}
	.....
}

treasureFormation2 = {
	p1 = "404",
	p2 = "304"
}
]]

--[[
站前站人数据
]]
local TeamFormationModel = class("TeamFormationModel",BaseModel)


function TeamFormationModel:init( d )

	TeamFormationModel.super.init(self,d)


	if self.formations == nil then
		self.formations = {}
	end
	
	self.defaultInitTreasure = "404"
	--所有相关的阵容信息 这里不包括精英关卡的信息
	for k,v in pairs(FuncTeamFormation.formation) do
		if v ~= FuncTeamFormation.formation.pve_elite or v ~= FuncTeamFormation.formation.shareBoss then
			self.formations[tostring(v)] = self:initDefaultFmt(v)	
			--self.formations[tostring(v)] = self:allOnFormation(v)	
		end
	end

	self:mergeLocalData()
	self:mergeNetData(d)
	self:chkFmtValid()
	-- echo("合并后的数据=-================")
	-- dump(self.formations["1"],"合并后的数据")
	-- echo("合并后的数据=-================")	
	self:checkFormationRedPoint(true)	
	EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.doSpecialOnFormation, self)
	--主城奇侠按钮可提升特效 因为需要取布阵信息 但是奇侠model初始化在布阵model之前
	PartnerModel:setFormationPartners()
    PartnerModel:dispatchShowApproveAnimEvent()
end

function TeamFormationModel:checkFormationRedPoint(needSendEvent)
	-- local hasIdlePosition = self:hasIdlePosition()
    -- local isWuLingType = WuLingModel:checkRedPoint()
    local tempType = false
    -- if hasIdlePosition then
    --     tempType = true
    -- end
    if needSendEvent then
    	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{redPointType = HomeModel.REDPOINT.DOWNBTN.ARRAY, isShow = tempType})
    end
    return tempType
end

--[[
合并网络数据
]]
function TeamFormationModel:mergeNetData( d )
	
	for k,v in pairs(d) do
		if self.formations[k] then
			self.formations[k].id = k
			if v.partnerFormation then
				for kk,vv in pairs(v.partnerFormation) do
					if vv.partner then
						if vv.partner.partnerId then
							if tostring(vv.partner.partnerId) == "0" then
								self.formations[k].partnerFormation[kk].partner = vv.partner
							else
								self.formations[k].partnerFormation[kk].partner.partnerId = tostring(vv.partner.partnerId)
								if vv.partner.rid then
									self.formations[k].partnerFormation[kk].partner.rid = vv.partner.rid
								end
							end	
						end
					end	
					if vv.element then
						if vv.element.elementId then
							if tostring(vv.element.elementId) == "0" then
								self.formations[k].partnerFormation[kk].element = vv.element
							else	
								self.formations[k].partnerFormation[kk].element.elementId = tostring(vv.element.elementId)
								if vv.element.rid then
									self.formations[k].partnerFormation[kk].element.rid = vv.element.rid
								end	
							end	
						end
					end
				end
			end
			if v.treasureFormation then
				for kk, vv in pairs(v.treasureFormation) do
					self.formations[k].treasureFormation[kk] = tostring(vv)
				end
			end
			if v.energy then
				for kk, vv in pairs(v.energy) do
					self.formations[k].energy[kk] = vv
				end
			end
			if v.bench then
				for kk,vv in pairs(v.bench) do
					self.formations[k].bench[kk] = vv
				end
			end
		end
	end
end


--[[
合并本地数据
保存上次所有的真行数据，不管是不是存在
]]
function TeamFormationModel:mergeLocalData()
	local jsonStr = LS:prv():get(StorageCode.all_team_formation,"")
	local fmtData = {}
	if jsonStr == "" or jsonStr == nil then
		--本地数据为空
		echo("本地数据为空,查找LS:prv()的数据问题")
		return
	end
	fmtData = json.decode(jsonStr)
	--数据合并
	for k,v in pairs(fmtData) do
		if not self.formations[tostring(k)] then
			self.formations[tostring(k)] = {}
		end
		if self.formations[tostring(k)].id == nil then
			self.formations[tostring(k)].id = v.id
		end
		--同步partner
		if self.formations[tostring(k)].partnerFormation == nil then
			self.formations[tostring(k)].partnerFormation = {}
		end
		for kk,vv in pairs(v.partnerFormation) do
			self.formations[tostring(k)].partnerFormation[kk] = vv
		end
		--同步法宝 阵位
		if self.formations[tostring(k)].treasureFormation == nil then
			self.formations[tostring(k)].treasureFormation = {}
		end 
		for kk,vv in pairs(v.treasureFormation) do
			self.formations[tostring(k)].treasureFormation[kk] = vv	
		end
		if tonumber(v.id) == FuncTeamFormation.formation.pvp_attack
			or tonumber(v.id) == FuncTeamFormation.formation.pvp_defend then
			if self.formations[tostring(k)].energy == nil then
				self.formations[tostring(k)].energy = {}
			end

			if v.energy then
				for kk,vv in pairs(v.energy) do
					self.formations[tostring(k)].energy[kk] = vv	
				end
			end
		end

		if tonumber(v.id) == FuncTeamFormation.formation.crossPeak then
			if self.formations[tostring(k)].bench == nil  then
				self.formations[tostring(k)].bench = {}
			end

			if v.bench then
				for kk,vv in pairs(v.bench) do
					self.formations[tostring(k)].bench[kk] = vv	
				end
			end
		end

		if tonumber(v.id) == FuncTeamFormation.formation.endless then
			--同步partner
			if self.formations[tostring(k)].partnerFormation2 == nil then
				self.formations[tostring(k)].partnerFormation2 = {}
			end
			if v.partnerFormation2 then
				for kk,vv in pairs(v.partnerFormation2) do
					self.formations[tostring(k)].partnerFormation2[kk] = vv
				end
			end
			
			--同步法宝 阵位
			if self.formations[tostring(k)].treasureFormation2 == nil then
				self.formations[tostring(k)].treasureFormation2 = {}
			end 
			if v.treasureFormation2 then
				for kk,vv in pairs(v.treasureFormation2) do
					self.formations[tostring(k)].treasureFormation2[kk] = vv
				end
			end
		end
	end
end

--[[
检查阵容的合法性
@因为阵容中的Partner or Treasure 有可能会被分解
]]
function TeamFormationModel:chkFmtValid(  )
	if self.formations then
		for k,v in pairs(self.formations) do
			for kk,vv in pairs(v.partnerFormation) do
				--检查vv 的partner是否存在  先检查是否为锁妖塔中的雇佣兵
				if tostring(v.id) ~= tostring(FuncTeamFormation.formation.crossPeak) and not FuncTower.isConfigEmployee(tostring(vv.partner.partnerId)) and 
					(not PartnerModel:isPartnerExist(vv.partner.partnerId)) and tostring(vv.partner.partnerId) ~= "1" then
					self.formations[k].partnerFormation[kk].partner.partnerId  = "0"
				end
				local isOpen,_ = FuncTeamFormation.checkPosIsOpen(string.sub(kk,2) )
				if not isOpen then
					self.formations[k].partnerFormation[kk].partner.partnerId = "0"
				end
			end

			for kk,vv in pairs(v.treasureFormation) do
				--检查vv 的法宝是否存在
				if TreasureNewModel:getTreasureData(vv) == nil then
					self.formations[k].treasureFormation[kk] = "0"
				end
			end
		end
	end
end


--[[
将数据保存到本地

保存本地数据
将数据保存到本地
]]
function TeamFormationModel:saveLocalData( systemId,fmtIdx )
	--echoError("将sh--------------------------------------------------")
	local sysId = self.tempFormation.id
	if tonumber(sysId) == FuncTeamFormation.formation.pvp_defend
		or tonumber(sysId) == FuncTeamFormation.formation.pvp_attack then
		local energy = FuncTeamFormation.filterPvpFormation(self.tempFormation)
		self.tempFormation.energy = energy
	end
	self.formations[tostring(sysId)] = self.tempFormation
	local jsonStr = json.encode(self.formations)
	LS:prv():set(StorageCode.all_team_formation,jsonStr)
end

--[[
获取主线布阵法宝用于主城战斗力展示
]]
function TeamFormationModel:getOnTreasureId()
	-- local jsonStr = LS:prv():get(StorageCode.all_team_formation,"")
	-- local treasureId = nil
	-- if jsonStr == "" or jsonStr == nil then		 
	-- 	treasureId = self.defaultInitTreasure
	-- else
	-- 	local fmtData = json.decode(jsonStr)
	-- 	treasureId = fmtData["1"].treasureFormation["p1"]
	-- end
	local teamFormation = self:getFormation(FuncTeamFormation.formation.pve)
	local treasureId = teamFormation.treasureFormation["p1"]
	if treasureId == nil or treasureId == "" then
		treasureId = self.defaultInitTreasure
	end
	return treasureId
end

function TeamFormationModel:getTreasueIdByFormation(_formationType)
	local jsonStr = LS:prv():get(StorageCode.all_team_formation,"")
	local treasureId = nil
	if jsonStr == "" or jsonStr == nil then		 
		treasureId = self.defaultInitTreasure
	else
		local fmtData = json.decode(jsonStr)
		treasureId = fmtData[tostring(_formationType)].treasureFormation["p1"]
	end
	return treasureId
end

--[[
更新阵型信息
@params dict 阵型信息的更新状态
]]
function TeamFormationModel:updateData(dict)
	
	self:mergeNetData(dict)

end

--获取竞技场系统的攻击性阵容
function TeamFormationModel:getPVPFormation()
    local _pvp_formation = self:getFormation(FuncTeamFormation.formation.pvp_attack)
    _pvp_formation.treasureFormation = _pvp_formation.treasureFormation or {}
    _pvp_formation.partnerFormation = _pvp_formation.partnerFormation or {}
    return _pvp_formation
end

--获取竞技场的防御阵容
function TeamFormationModel:getPVPDefenceFormation()
    local _pvp_defence = self:getFormation(FuncTeamFormation.formation.pvp_defend) or {}
    _pvp_defence.treasureFormation = _pvp_defence.treasureFormation or {}
    _pvp_defence.partnerFormation = _pvp_defence.partnerFormation or {}
    return _pvp_defence
end

function TeamFormationModel:getCrossPeakFormation()
	local _crossPeak = self:getFormation(FuncTeamFormation.formation.crossPeak) or {}
    _crossPeak.treasureFormation = _crossPeak.treasureFormation or {}
    _crossPeak.partnerFormation = _crossPeak.partnerFormation or {}
    _crossPeak.bench = _crossPeak.bench or {}
    return _crossPeak
end

--[[
初始化一个默认阵容
]]
function TeamFormationModel:initDefaultFmt( systemId,npcs )
	local allNpcs = self:getNPCsByTy(0, nil, true)

	local fmt = {}
    fmt.id = tostring(systemId) 
    
    fmt.treasureFormation = {}
    fmt.partnerFormation = {}
    --初始化要上阵的法宝
    fmt.treasureFormation.p1= tostring(TeamFormationModel:getInitUseTrea())
    fmt.treasureFormation.p2 = "0"
    local index = 1
    fmt.partnerFormation.p2 = {}
    fmt.partnerFormation.p2.partner = {}
    fmt.partnerFormation.p2.element = {}
    fmt.partnerFormation.p2.partner.rid = UserModel:rid()

    fmt.partnerFormation.p2.partner.partnerId = "1"
    fmt.partnerFormation.p2.element.rid = UserModel:rid()
    fmt.partnerFormation.p2.element.elementId = "0"

    if tonumber(systemId) ~= FuncTeamFormation.formation.pve
    	and tonumber(systemId) ~= FuncTeamFormation.formation.crossPeak and tonumber(systemId) ~= FuncTeamFormation.formation.guildBossGve
    	and tonumber(systemId) ~= FuncTeamFormation.formation.guildBoss then
	    for k = 1,6,1 do
	    	if not fmt.partnerFormation["p"..k] then
	    		fmt.partnerFormation["p"..k] = {}
			    fmt.partnerFormation["p"..k].partner = {}
		    	fmt.partnerFormation["p"..k].element = {}
		    	local heroId = "0"
				if allNpcs[index] ~= nil  then
					heroId = tostring(allNpcs[index].id)
					index = index+1
					while tostring(heroId) == "1" do
						if allNpcs[index] == nil then
							break
						end
						heroId = tostring(allNpcs[index].id)
						index = index+1
					end
				end
				if tostring(heroId) == "1" then
					heroId = "0"
				end

		    	fmt.partnerFormation["p"..k].partner.partnerId = heroId
		    	fmt.partnerFormation["p"..k].partner.rid = UserModel:rid()
		    	-- fmt.partnerFormation["p"..k].element.rid = UserModel:rid()
	    		fmt.partnerFormation["p"..k].element.elementId = "0"
	    	end	
	    end
	else
		local rid = nil
		if tonumber(systemId) == FuncTeamFormation.formation.guildBossGve then
			fmt.partnerFormation.p2 = {}
		    fmt.partnerFormation.p2.partner = {}
		    fmt.partnerFormation.p2.element = {}
		    fmt.partnerFormation.p2.partner.rid = nil
		    fmt.partnerFormation.p2.partner.partnerId = "0"
		    fmt.partnerFormation.p2.element.rid = nil
		    fmt.partnerFormation.p2.element.elementId = "0"
		else
			rid = UserModel:rid()
		end

		for k = 1,6,1 do
			local heroId = "0"
			if not fmt.partnerFormation["p"..k]  then	
				fmt.partnerFormation["p"..k] = {}
				fmt.partnerFormation["p"..k].partner = {}
    			fmt.partnerFormation["p"..k].element = {}
				fmt.partnerFormation["p"..k].partner.partnerId = heroId
				fmt.partnerFormation["p"..k].partner.rid = rid
	    		fmt.partnerFormation["p"..k].element.rid = rid
    			fmt.partnerFormation["p"..k].element.elementId = "0"
			end
		end		
	end 

	if tonumber(systemId) == FuncTeamFormation.formation.pvp_attack
		or tonumber(systemId) == FuncTeamFormation.formation.pvp_defend then
		fmt.energy = {}
	end
	--  初始化巅峰竞技场候补阵容
	if tonumber(systemId) == FuncTeamFormation.formation.crossPeak then
	 	if not fmt.bench then
	 		fmt.bench = {}
	 	end
	end

	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		fmt.treasureFormation2 = {}
    	fmt.partnerFormation2 = {}
    	--初始化要上阵的法宝
	    fmt.treasureFormation2.p1= tostring(TeamFormationModel:getInitUseTrea())
	    fmt.treasureFormation2.p2 = "0"

	    for k = 1,6,1 do
			local heroId = "0"
			if not fmt.partnerFormation2["p"..k]  then	
				fmt.partnerFormation2["p"..k] = {}
				fmt.partnerFormation2["p"..k].partner = {}
    			fmt.partnerFormation2["p"..k].element = {}
				fmt.partnerFormation2["p"..k].partner.partnerId = heroId
				fmt.partnerFormation2["p"..k].partner.rid = UserModel:rid()
	    		fmt.partnerFormation2["p"..k].element.rid = UserModel:rid()
    			fmt.partnerFormation2["p"..k].element.elementId = "0"
			end
		end
	end
	
    return fmt
end


--[[
获取用户当前是攻防辅特性
]]
function TeamFormationModel:getPropByPartnerId( pId )
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



--[[
获取当前阵型数据
这个暂时没有使用
此方法替换为六界获取阵容红点使用
]]
function TeamFormationModel:hasIdlePosition()
	if self.formations then
		local teamData = self.formations[tostring(FuncTeamFormation.formation.pve)]["partnerFormation"]
		local partnerNum = PartnerModel:getPartnerNum()+1
		local teamNum = 0
		local nowMaxNum = self:quickHasPosNum()
		for i = 1,6 do
			if teamData["p"..i].partner.partnerId  ~= "0" then
				teamNum = teamNum + 1 
			end
		end 

		if teamNum < nowMaxNum and teamNum ~= partnerNum then
			return true
		end
		return false
	else
	    return false	
	end
	-- return self.formations[tostring(systemId)]["partnerFormation"]
end


function TeamFormationModel:setCurrentTags(_tags)
	self.tags = _tags
end

function TeamFormationModel:getCurrentTags()
	return self.tags
end

function TeamFormationModel:setCurrentSystemId(_systemId)
	self.curSystemId = _systemId
end

function TeamFormationModel:getCurrentSystemId()
	return self.curSystemId
end

--[[
根据攻 防  辅  获取对应的npcs
@params ty == 1 攻 ty==2 防 ty==3 辅


返回的数据可能不全   先这么搞  等有新需求的时候再改  todo modify--
notDisplay  参数  传true是因为一键布阵需要忽略tags 但是不传或者传false表示带tags的order需要更高
]]
function TeamFormationModel:getNPCsByTy(ty, excludeMainHero, notDisplay)
	-- echo("\n\nty",ty,"=============================")
	local playerType = excludeMainHero or false
	local partners = PartnerModel:getAllPartner()
	-- echo("获取当前所有的npcs----")
	-- dump(partners, "\n\npartners===")
	local npcs = {}
	for k,v in pairs(partners) do
		local tempAbility = PartnerModel:getPartnerAbility(v.id)
		local temp = FuncTeamFormation.createFormationNpcs(ty, v, tempAbility, self.tags, notDisplay)
		if temp then
			table.insert(npcs, temp)
		end
	end
	
	local player = {}
	player.id = 1
	player.level = UserModel:level()
	--暂定  todo dev
	player.type = 4
	player.exp = UserModel:exp()
	player.star = UserModel:star()     --默认玩家的星级 1
	player.order = 2
	player.quality = UserModel:quality()
	player.HpPercent = 10000
	player.fury = 0
	local tempData = FuncTreasureNew.getTreasureDataById(self:getCurTreaByIdx(1))
	player.elements = tempData.wuling

	--player.sourceld
	if (ty == 0 or player.type == ty ) then
		if not playerType then	
			table.insert(npcs, player)
		end	
	end
	--dump(npcs)

	--这里应该有一个排序，上阵的，然后是品质，等等  这里进行一次排序，玩家自己放在最前面
	table.sort(npcs, c_func(self.hasNowRule,self))

	return npcs
end

--获取仙界对决的奇侠列表  需要拿到助战的奇侠  然后所有的奇侠主角 等级星级品质均由段位决定
function TeamFormationModel:getCrossPeakNpcs(ty, excludeMainHero)
	local curSystemId = TeamFormationModel:getCurrentSystemId()
	local npcs = {}
	local crossPeakPartners = {}
	if curSystemId and tostring(curSystemId) == tostring(FuncTeamFormation.formation.crossPeak) then
		local currentSegment = CrossPeakModel:getCurrentSegment()
		crossPeakPartners = FuncCrosspeak.getCrossPeakOptionPartnerBySegment(currentSegment)
		local playerType = excludeMainHero or false
		local partners = PartnerModel:getAllPartner()
		for k,v in pairs(partners) do
			if not table.indexof(crossPeakPartners, tostring(v.id)) then
				table.insert(crossPeakPartners, tostring(v.id))
			end			
		end
		local currentSegmentData = FuncCrosspeak.getSegmentDataById(currentSegment)
		local level = currentSegmentData.optionPartnerLevel
		local star = currentSegmentData.optionPartnerStar
		local quality = currentSegmentData.optionPartnerQuality
		for i,v in ipairs(crossPeakPartners) do
			local npcCfg = FuncPartner.getPartnerById(v)
			if ty == 0 or npcCfg.type == ty then 
					--如果传入的 ty ==0 或者指定的npc类型
				local temp = {}
				temp.id = v
				temp.level = level
				temp.quality = quality 
				temp.star = star
				temp.type = npcCfg.type 
				temp.icon = npcCfg.icon 
				temp.sourceId = npcCfg.sourceld
				temp.dynamic = npcCfg.dynamic
				temp.order = 1
				temp.elements = npcCfg.elements
				table.insert(npcs, temp)
			end
		end

		local player = {}
		player.id = 1
		player.level = level
		--暂定  todo dev
		player.type = 4
		player.star = star     --默认玩家的星级 1
		player.order = 2
		player.quality = quality
		local tempData = FuncTreasureNew.getTreasureDataById(self:getCurTreaByIdx(1))
		player.elements = tempData.wuling

		table.insert(crossPeakPartners, tostring(player.id))
		if (ty == 0 or player.type == ty ) then
			if not playerType then	
				table.insert(npcs, player)
			end	
		end

		local sortFunc = function (a, b)
			if a.order > b.order then
				return true
			else
				return false
			end

			if tonumber(a.id) > tonumber(b.id) then
				return true
			else
				return false
			end

			return false
		end
		table.sort(npcs, sortFunc)
	end

	return npcs, crossPeakPartners
end

-- 需要先判断是否为须臾仙境后才能调用该方法    传入systemId是为了做二次过滤
function TeamFormationModel:getWonderLandNpcs(ty, excludeMainHero, systemId)
	local npcs = self:getNPCsByTy(ty,excludeMainHero)
	local wonderLandNpc = {}
	if tonumber(systemId) == FuncTeamFormation.formation.wonderLand then
		if self:getWonderLandStaticNpc() then
			local staticNpcInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", self.wonderLandNpc)
			local temp = {}
			temp.id = tonumber(self.wonderLandNpc)
			temp.icon = staticNpcInfo.icon
			temp.teamFlag = 1
			table.insert(wonderLandNpc,temp)
		end
	end

	for i,v in ipairs(npcs) do
		table.insert(wonderLandNpc, v)
	end
	return wonderLandNpc
end
function TeamFormationModel:hasNowRule(a,b)
    return FuncTeamFormation.partnerSortRule(a, b)
end


--[[
获取玩家的第一个法宝
@ 当玩家首次进入该系统的时候 没有法宝，那么选择一个法宝让其上阵。自动执行的
]]
function TeamFormationModel:getInitUseTrea(  )


	local allTreas = TreasureNewModel:getOwnTreasures()
	--默认法宝405  这里暂时这么写    等待优化
	local treaId = 0
	if allTreas then
		for k,v in pairs(allTreas) do
			treaId = k 
			break
		end
	end
	return toint( treaId)
end








--[[
获取所有的法宝
]]
function TeamFormationModel:getAllTreas(  )
	local treas = {}
	-- local allTreas = TreasuresModel:getAllTreasure()
	local allTreas = TreasureNewModel:getAllTreasure()

	for k,v in pairs(allTreas) do
		local item = {}
		-- item.id = k
		-- item.level = v:level()
		-- item.star = v:star()
		-- item.state = v:state()

		local treasureData = TreasureNewModel:getTreasureData(v)
		if treasureData then
			item.id = v
			item.star = treasureData.star
			item.state = treasureData.state
			item.status = treasureData.status
		end
		
		table.insert(treas,item)
	end
	return treas
end



--[[
布阵内专用法宝获取
]]
function TeamFormationModel:getTreaById( treaId )
	local treas = self:getAllTreas()
	--dump(treas)
	for k,v in pairs(treas) do
		 if tostring(v.id) == tostring(treaId) then
		 	return v
		 end
	end
	return nil
end






--=================================================================================--
-- 						创建临时阵型           用于在关闭的时候向服务器提交阵容
--						由于每个提系统的布阵 都有其特殊不同的逻辑 所以将每一个系统布阵的逻辑拆成一个方法 方便维护
--=================================================================================--
function TeamFormationModel:createTempFormation( systemId,raidId,npcs)
	local fmt = {}
	local fmtKey = tostring(systemId) 
	local isInited = true
	if tonumber(systemId)==FuncTeamFormation.formation.pve_elite then
		--获取本地的阵型信息
		fmtKey = tostring(FuncTeamFormation.formation.pve)

		-- fmtKey = tostring(systemId..raidId)
	end
	
	if tonumber(systemId)==FuncTeamFormation.formation.shareBoss then
		--获取本地的阵型信息
		fmtKey = tostring(systemId..raidId)
	end

	if tonumber(systemId) == FuncTeamFormation.formation.wonderLand then
		fmtKey = tostring(systemId.."_"..raidId)
	end

	fmt = self.formations[fmtKey]

	if tonumber(systemId) == FuncTeamFormation.formation.guildBossGve then
		fmt = self:initDefaultFmt(fmtKey,npcs)
	end
	
	--设置一个变量  因为须臾仙境首次进入需要一键布阵
	local isFirst = false
	if empty(fmt) then
		if tonumber(systemId) == FuncTeamFormation.formation.wonderLand then
			isFirst = true
		end
		fmt = self:initDefaultFmt(fmtKey,npcs)

		isInited = false
	end

	--这里需要deepCopy否则，在更新tempFormation的时候，self.formation中的数据就发生了改变
	self.tempFormation = table.deepCopy(fmt)

	if tonumber(systemId) == FuncTeamFormation.formation.pve_tower then
		self:createTowerTempFormation()
	end

	if tonumber(systemId) == FuncTeamFormation.formation.guildExplorePve then
		self:createGuildExploreTempFormation()
	end

	if tonumber(systemId) == FuncTeamFormation.formation.wonderLand then 
		self:createWonderLandTempFormation()
	end

	if tonumber(systemId) == FuncTeamFormation.formation.wonderLand and isFirst then
		self:allOnFormation({}, systemId)
	end

	if tonumber(systemId) == FuncTeamFormation.formation.crossPeak then
		self:createCrossPeakTempFormation()
	end

	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		self:createEndlessTempFormation()
	end

	if tonumber(systemId) == FuncTeamFormation.formation.guildBoss then
		self:createGuildBossTempFormation()
	end
end

--锁妖塔战斗创建临时阵型时的特殊处理 已阵亡的奇侠需要清除掉
function TeamFormationModel:createTowerTempFormation()
	for k,v in pairs(self.tempFormation.partnerFormation) do
		if tostring(v.partner.partnerId) ~= "0" and 
			(TeamFormationSupplyModel:isPartnerBan(v.partner.partnerId, FuncTeamFormation.formation.pve_tower)
				or TeamFormationSupplyModel:checkIsDead(v.partner.partnerId, FuncTeamFormation.formation.pve_tower)) then

			self.tempFormation.partnerFormation[k].partner.partnerId = "0"
		end
		if tostring(v.partner.partnerId) == "0" then 
			if v.partner.teamFlag then
				self.tempFormation.partnerFormation[k].partner.teamFlag = nil
			end
			self.tempFormation.partnerFormation[k].partner.rid = nil
		end

		if v.partner.teamFlag and tostring(v.partner.partnerId) ~= "0" 
			and (not FuncTower.isConfigEmployee(v.partner.partnerId) or not TowerMainModel:checkEmployeeExist()) then
			self.tempFormation.partnerFormation[k].partner.partnerId = "0"
			self.tempFormation.partnerFormation[k].partner.teamFlag = nil
			self.tempFormation.partnerFormation[k].partner.rid = nil
		end
	end
end

function TeamFormationModel:createGuildExploreTempFormation()
	for k,v in pairs(self.tempFormation.partnerFormation) do
		if tostring(v.partner.partnerId) ~= "0" and 
			(TeamFormationSupplyModel:isPartnerBan(v.partner.partnerId, FuncTeamFormation.formation.guildExplorePve)
				or TeamFormationSupplyModel:checkIsDead(v.partner.partnerId, FuncTeamFormation.formation.guildExplorePve)) then

			self.tempFormation.partnerFormation[k].partner.partnerId = "0"
		end
		if tostring(v.partner.partnerId) == "0" then 
			if v.partner.teamFlag then
				self.tempFormation.partnerFormation[k].partner.teamFlag = nil
			end
			self.tempFormation.partnerFormation[k].partner.rid = nil
		end

		-- if v.partner.teamFlag and tostring(v.partner.partnerId) ~= "0" 
		-- 	and (not FuncTower.isConfigEmployee(v.partner.partnerId) or not TowerMainModel:checkEmployeeExist()) then
		-- 	self.tempFormation.partnerFormation[k].partner.partnerId = "0"
		-- 	self.tempFormation.partnerFormation[k].partner.teamFlag = nil
		-- 	self.tempFormation.partnerFormation[k].partner.rid = nil
		-- end
	end
end

--须臾仙境战斗创建临时阵型时的特殊处理
function TeamFormationModel:createWonderLandTempFormation()
	if self:getWonderLandStaticNpc() then
		local npcId = self:getWonderLandStaticNpc()
		self.tempFormation.partnerFormation["p1"].partner.partnerId = tonumber(npcId)
		self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
		self.tempFormation.partnerFormation["p1"].partner.teamFlag = 1	
	end
end

--仙界对决创建临时阵型时的特殊处理
function TeamFormationModel:createCrossPeakTempFormation()
	local currentSegment = tonumber(CrossPeakModel:getCurrentSegment())
	local fightInStageMax = CrossPeakModel:getFightInStageMax()
	local fightNumMax = CrossPeakModel:getFightNumMax()
	local candidateNum = fightNumMax - fightInStageMax
	local _, crossPeakPartners = self:getCrossPeakNpcs(0, nil)
	local count = 0

	--根据当前的仙界对决的段位  去校验上阵的人数   将多余的奇侠下阵
	for i = 1, 6, 1 do
		local partnerId = tostring(self.tempFormation.partnerFormation["p"..i].partner.partnerId)
		if  partnerId ~= "0" and partnerId ~= 
			FuncCrosspeak.getCrossPeakNpcIdByPlayType(FuncCrosspeak.PLAYMODE.CACTUS, currentSegment) then
			if not table.indexof(crossPeakPartners, tostring(partnerId)) then
				self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
				self.tempFormation.partnerFormation["p"..i].partner.teamFlag = nil
			else
				count = count + 1
				if count > fightInStageMax then
					self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
					self.tempFormation.partnerFormation["p"..i].partner.teamFlag = nil
				end
			end
			
		end
	end

	--将多余的候补奇侠下阵
	for k,v in pairs(self.tempFormation.bench) do
		if tonumber(k) > candidateNum then
			self.tempFormation.bench[k] = nil
		else
			local partnerId = self.tempFormation.bench[k]
			if not table.indexof(crossPeakPartners, tostring(partnerId)) then
				self.tempFormation.bench[k] = nil
			end
		end
	end


	--添加仙界对决  新玩法 仙人掌雇佣兵  段位为2  且为仙人掌玩法时 需要上阵仙人掌
	if tonumber(FuncCrosspeak.getPlayerModel()) == FuncCrosspeak.PLAYMODE.CACTUS and currentSegment > 1 then
		local npcId = FuncCrosspeak.getCrossPeakNpcIdByPlayType(FuncCrosspeak.getPlayerModel(), currentSegment)
		local emptyPos = {}
		local index = 1
		local isNpcExit = false
		for i = 1, 6, 1 do
			local partnerId = tostring(self.tempFormation.partnerFormation["p"..i].partner.partnerId)
			if self.tempFormation.partnerFormation["p"..i].partner.teamFlag then
				if tostring(partnerId) ~= "0" then
					self.tempFormation.partnerFormation["p"..i].partner.partnerId = tonumber(npcId)
					self.tempFormation.partnerFormation["p"..i].partner.rid = UserModel:rid()
					isNpcExit = true
					break
				else
					self.tempFormation.partnerFormation["p"..i].partner.teamFlag = nil
				end
			else
				local partnerId = self.tempFormation.partnerFormation["p"..i].partner.partnerId
				if tostring(partnerId) == "0" then
					emptyPos[index] = i
					index = index + 1
				end
			end
		end
		
		if not isNpcExit then
			local k = emptyPos[1]
			self.tempFormation.partnerFormation["p"..k].partner.partnerId = tonumber(npcId)
			self.tempFormation.partnerFormation["p"..k].partner.rid = UserModel:rid()
			self.tempFormation.partnerFormation["p"..k].partner.teamFlag = 1
		end				
	else
		--如果不是仙人掌玩法期间 需要将布阵中的仙人掌下阵  并将对应位置的雇佣兵标识teamFlag置空
		for i = 1, 6, 1 do
			if self.tempFormation.partnerFormation["p"..i].partner.teamFlag then
				self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
				self.tempFormation.partnerFormation["p"..i].partner.teamFlag = nil
			end
		end	
	end
end

--创建无底深渊临时阵容　 因为不同关卡能上的人数可能不一样 所以需要根据不同的关卡对阵型进行处理
function TeamFormationModel:createEndlessTempFormation()
	local curEndlessId = EndlessModel:getCurChallengeEndlessId()
    local curTeamNum = FuncEndless.getFormationNumByEndlessId(curEndlessId)

    local num1 = 0
    local num2 = 0
    for i = 1, 6, 1 do
    	local partnerId1 = self.tempFormation.partnerFormation["p"..i].partner.partnerId
    	local partnerId2 = self.tempFormation.partnerFormation2["p"..i].partner.partnerId
    	if tostring(partnerId1) ~= "0" then
    		num1 = num1 + 1
    		if num1 > curTeamNum then
    			self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
    			self.tempFormation.partnerFormation["p"..i].partner.rid = nil
    		end
    	end

    	if tostring(partnerId2) ~= "0" then
    		num2 = num2 + 1
    		if num2 > curTeamNum then
    			self.tempFormation.partnerFormation2["p"..i].partner.partnerId = "0"
    			self.tempFormation.partnerFormation2["p"..i].partner.rid = nil
    		end	
    	end
    end

    --当可上阵人数 多余已上阵人数时  将阵容清空 该逻辑已经被干掉了
   --  if num1 < curTeamNum or num2 < curTeamNum then
   --  	for i = 1, 6, 1 do
			-- self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
			-- self.tempFormation.partnerFormation["p"..i].partner.rid = nil
			-- self.tempFormation.partnerFormation["p"..i].element.elementId = "0"
			-- self.tempFormation.partnerFormation["p"..i].element.rid = nil
			-- self.tempFormation.partnerFormation2["p"..i].partner.partnerId = "0"
			-- self.tempFormation.partnerFormation2["p"..i].partner.rid = nil
			-- self.tempFormation.partnerFormation2["p"..i].element.elementId = "0"
			-- self.tempFormation.partnerFormation2["p"..i].element.rid = nil
	  --   end
   --  end
end

function TeamFormationModel:createGuildBossTempFormation()
	local maxTeamNum = FuncDataSetting.getDataByConstantName("GuildBossSingleMax")
	local num1 = 0
	local num2 = 0
    for i = 1, 6, 1 do
    	local partnerId = self.tempFormation.partnerFormation["p"..i].partner.partnerId
    	local elementId = self.tempFormation.partnerFormation["p"..i].element.elementId
    	if tostring(partnerId) ~= "0" then
    		num1 = num1 + 1
    		if num1 > maxTeamNum then
    			self.tempFormation.partnerFormation["p"..i].partner.partnerId = "0"
    			self.tempFormation.partnerFormation["p"..i].partner.rid = nil
    		end
    	end

    	if tostring(elementId) ~= "0" then
    		num2 = num2 + 1
    		if num2 > maxTeamNum then
    			self.tempFormation.partnerFormation["p"..i].element.elementId = "0"
    			self.tempFormation.partnerFormation["p"..i].element.rid = nil
    		end
    	end
    end
end

--[[
	当前布阵的五行现有量
	1-风
	2-雷
	3-水
	4-火
	5-土
	6-空
]]
function TeamFormationModel:createWuXingNum()
	self.chooseWuXingNum = {}
	self.chooseWuXingNum2 = {}
	for k=1,6 do
		if k ==6 then
			self.chooseWuXingNum[k] = 6
			self.chooseWuXingNum2[k] = 6
		else
			self.chooseWuXingNum[k] = FuncTeamFormation.getWuXingNum(k, UserModel:level())
			self.chooseWuXingNum2[k] = FuncTeamFormation.getWuXingNum(k, UserModel:level())
		end
	end
	for k = 1,6,1 do 
		if self.tempFormation.partnerFormation["p"..k].element.elementId ~= "0" then
			local tempWuXing = self.tempFormation.partnerFormation["p"..k].element.elementId
			self.chooseWuXingNum[tonumber(tempWuXing)] = self.chooseWuXingNum[tonumber(tempWuXing)] - 1
		end
	end

	if self.tempFormation.partnerFormation2 then
		for k = 1,6,1 do 
			if self.tempFormation.partnerFormation2["p"..k].element.elementId ~= "0" then
				local tempWuXing = self.tempFormation.partnerFormation2["p"..k].element.elementId
				self.chooseWuXingNum2[tonumber(tempWuXing)] = self.chooseWuXingNum2[tonumber(tempWuXing)] - 1
			end
		end
	end
end

function TeamFormationModel:createMultiWuXingNum()
	self.chooseMultiWuXingNum = {}
	for k=1,6 do
		if k ==6 then
			self.chooseMultiWuXingNum[k] = 3
		else
			self.chooseMultiWuXingNum[k] = FuncTeamFormation.getWuXingNum(k, UserModel:level())
		end
	end
	for k = 1,6,1 do 
		if self.tempFormation.partnerFormation["p"..k].element.elementId ~= "0" 
			and self.tempFormation.partnerFormation["p"..k].element.rid == UserModel:rid() then
			local tempWuXing = self.tempFormation.partnerFormation["p"..k].element.elementId
			self.chooseMultiWuXingNum[tonumber(tempWuXing)] = self.chooseMultiWuXingNum[tonumber(tempWuXing)] - 1
		end
	end
end

--上下阵五灵时 需要更新当前剩余的五灵数组   _isUp传true 表示上阵  false表示下阵
function TeamFormationModel:updateWuXingNum(wuxingId, _isUp)
	local chooseWuXingNum = self.chooseWuXingNum
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		chooseWuXingNum = self.chooseWuXingNum2
	end
	if _isUp then
		chooseWuXingNum[tonumber(wuxingId)] = chooseWuXingNum[tonumber(wuxingId)] - 1
	else
		chooseWuXingNum[tonumber(wuxingId)] = chooseWuXingNum[tonumber(wuxingId)] + 1
	end
end

--获取一键布阵时的奇侠列表
function TeamFormationModel:getAllOnFormationNpcs(hasPamams, systemId)
	local allNpcs ={}
	if tonumber(systemId) == tonumber(FuncTeamFormation.formation.pve_tower) then
		local allNpcs_tower, enabledNpcs_tower = TeamFormationSupplyModel:getNPCsByTy(0, nil, systemId)
		allNpcs = enabledNpcs_tower
	elseif tonumber(systemId) == tonumber(FuncTeamFormation.formation.guildExplorePve) then
		local allNpcs_explore, enabledNpcs_explore = TeamFormationSupplyModel:getNPCsByTy(0, nil, systemId)
		allNpcs = enabledNpcs_explore
 	elseif tonumber(systemId) == tonumber(FuncTeamFormation.formation.crossPeak) then
 		allNpcs = self:getCrossPeakNpcs(0, nil)
	else
		allNpcs = self:getNPCsByTy(0, nil, true)
	end
	return allNpcs
end

--一键布阵前 清理阵型 并获取已占用的位置数量
function TeamFormationModel:getAllOnFormationShowNum(hasPamams, systemId)
	local showNum = 0
	--优先清理一遍所有阵位
	for k = 1,6,1 do 
		self.tempFormation.partnerFormation["p"..k].partner = {}
		self.tempFormation.partnerFormation["p"..k].partner.partnerId = "0"
		self.tempFormation.partnerFormation["p"..k].element = {}
		self.tempFormation.partnerFormation["p"..k].element.elementId = "0"
	end
	
	--如果是无底深渊 还需要清理第二阵型
	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		for k = 1,6,1 do 
			self.tempFormation.partnerFormation2["p"..k].partner = {}
			self.tempFormation.partnerFormation2["p"..k].partner.partnerId = "0"
			self.tempFormation.partnerFormation2["p"..k].element = {}
			self.tempFormation.partnerFormation2["p"..k].element.elementId = "0"
		end
	end

	return showNum
end

--获取可上阵的奇侠总数量 根据不同的系统 做不同的处理
function TeamFormationModel:getAllOnFormationNums(hasPamams, systemId)
	local allNum = self:quickHasPosNum()
	--须臾仙境  第一种类型 姥姥固定在一号位
	if tonumber(systemId) == FuncTeamFormation.formation.wonderLand 
		and self:getWonderLandStaticNpc() then

		local npcId = self:getWonderLandStaticNpc()
		self.tempFormation.partnerFormation["p1"].partner.partnerId = tonumber(npcId)
		self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
		self.tempFormation.partnerFormation["p1"].partner.teamFlag = 1
		allNum = allNum - 1
	end

	--仙界对决  每个段位能上阵的人数不同  且仙人掌玩法需要特殊处理
	if tonumber(systemId) == FuncTeamFormation.formation.crossPeak then
		allNum = CrossPeakModel:getFightInStageMax()
		local currentSegment = tonumber(CrossPeakModel:getCurrentSegment())
		if tonumber(FuncCrosspeak.getPlayerModel()) == FuncCrosspeak.PLAYMODE.CACTUS
			and currentSegment > 1 then
			local npcId = FuncCrosspeak.getCrossPeakNpcIdByPlayType(FuncCrosspeak.getPlayerModel(), currentSegment)
			self.tempFormation.partnerFormation["p1"].partner.partnerId = tonumber(npcId)
			self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
			self.tempFormation.partnerFormation["p1"].partner.teamFlag = 1	
		end
	end

	if tonumber(systemId) == FuncTeamFormation.formation.guildBoss then
		allNum = FuncDataSetting.getDataByConstantName("GuildBossSingleMax")
	end
	
	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		local curEndlessId = EndlessModel:getCurChallengeEndlessId()
        allNum = FuncEndless.getFormationNumByEndlessId(curEndlessId)
	end

	return allNum
end

--根据奇侠类型将奇侠设置在不同的位置
function TeamFormationModel:setPartnerByType(heroType, heroId, partnerFormation)
	if tonumber(heroType) == 1 then
		for i,v in ipairs(FuncTeamFormation.typeForSetPartner1) do
			if tonumber(partnerFormation[v].partner.partnerId) == 0 then
				partnerFormation[v].partner.partnerId = heroId
				partnerFormation[v].partner.rid = UserModel:rid()
				break
			end
		end 
	elseif tonumber(heroType) == 2 then
		for i,v in ipairs(FuncTeamFormation.typeForSetPartner2) do
			if tonumber(partnerFormation[v].partner.partnerId) == 0 then
				partnerFormation[v].partner.partnerId = heroId
				partnerFormation[v].partner.rid = UserModel:rid()
				break
			end
		end 
	elseif tonumber(heroType) == 3 then
		for i,v in ipairs(FuncTeamFormation.typeForSetPartner3) do
			if tonumber(partnerFormation[v].partner.partnerId) == 0 then
				partnerFormation[v].partner.partnerId = heroId
				partnerFormation[v].partner.rid = UserModel:rid()
				break
			end
		end	
	else
		--判断是否需要上主角
		if heroId == "1" then
			self.isHasHero = true
		end					
	end
end

-- 一键布阵设置奇侠阵型
function TeamFormationModel:setAllOnFormationPartners(hasPamams, systemId, allNpcs, allNum, showNum, partnerFormation)
	local index = 1
	local interval = 1
	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		interval = 2
	end
	self.isHasHero = false
	for k = 1, allNum, 1 do
		local heroId = "0"
		local dapType = true
		if allNpcs[index] ~= nil and heroId =="0" then
			heroId = tostring(allNpcs[index].id)
			-- 如果奇侠能上阵  且已上阵数量小于能上阵的数量
			if dapType and showNum < allNum and allNpcs[index] then
				local heroType = allNpcs[index].type
				--如果是锁妖塔雇佣兵  则优先上阵
				if FuncTower.isConfigEmployee(tostring(heroId)) then
					local teamFlag = allNpcs[index].teamFlag
					if tonumber(partnerFormation["p1"].partner.partnerId) == 0 then
						partnerFormation["p1"].partner.partnerId = heroId
						partnerFormation["p1"].partner.rid = UserModel:rid()
						partnerFormation["p1"].partner.teamFlag = teamFlag
					end
				end
				
				self:setPartnerByType(heroType, heroId, partnerFormation)		
				index = index + interval
				showNum = showNum + 1
			end	
		end
	end

	--当前能布阵的最大数目
	local allPosNum = self:quickHasPosNum()
	-- isHasHero==true 时 需要上阵主角
	if self.isHasHero then
		for k = 1, allPosNum, 1 do 
			if tonumber(partnerFormation["p"..k].partner.partnerId) == 0 then
				partnerFormation["p"..k].partner.partnerId = "1"
				partnerFormation["p"..k].partner.rid = UserModel:rid()
				break
			end 
		end
	end

	--仙界对决 布阵特殊处理
	if tonumber(systemId) == FuncTeamFormation.formation.crossPeak then
		local tatolNum = CrossPeakModel:getFightNumMax()
		local candidateNum = tatolNum - allNum
		local index_candidate = 1
		for i = 1, candidateNum, 1 do
			local heroId = "0"
			if allNpcs[index_candidate] ~= nil then
				while self:chkIsInFormation(allNpcs[index_candidate].id) do
					index_candidate = index_candidate + 1
					if allNpcs[index_candidate] == nil then
						break
					end
				end
				if allNpcs[index_candidate] ~= nil then
					heroId = allNpcs[index_candidate].id
				end				
				self.tempFormation.bench[tostring(i)] = tostring(heroId)
				index_candidate = index_candidate + 1
			end
		end
	end
end

--设置一键布阵五灵阵型   因为无底深渊拥有两个partnerFormation   所以通过传参的方式来设置不同的partnerFormation的五灵
function TeamFormationModel:setAllOnFormationWuXing(partnerFormation, systemId)
	local wuXingForPartners = {}
	local tempWuXing = {}
	local index = 1
	for k = 1, 6, 1 do
		wuXingForPartners[k] = {}
		local elementId = 0
		local partnerId = partnerFormation["p"..k].partner.partnerId 
		if tonumber(partnerId) == 0 then
			elementId = 0
		elseif tonumber(partnerId) == 1 then 
            local curTreasure = FuncTreasureNew.getTreasureDataById(TeamFormationModel:getCurTreaByIdx(1))
            elementId = curTreasure.wuling
        else
        	local partnerData = FuncPartner.getPartnerById(partnerId)
        	if partnerData then
        		elementId = partnerData.elements
        	end        	
		end
		wuXingForPartners[k].partnerElem = elementId
		wuXingForPartners[k].curElem = "0"
	end

	--1键五行	
	if FuncCommon.isSystemOpen("fivesoul") then
		local maxWuXingNum = self:wuxingHasPosNum(systemId)
		local tempGroup = WuLingModel:getWuLingGroup()
		for i = 1, maxWuXingNum do
			local count = 0
			for j = 1, 6, 1 do
				if tostring(wuXingForPartners[j].partnerElem) == tostring(tempGroup[i]) then
					if wuXingForPartners[j].curElem == "0" then
						partnerFormation["p"..j].element.elementId = tostring(tempGroup[i])
						partnerFormation["p"..j].element.rid = UserModel:rid()
						wuXingForPartners[j].curElem = tostring(tempGroup[i])
						break
					else
						count = count + 1
					end
				else
					count = count + 1
				end
			end
			if count == 6 then
				tempWuXing[index] = tempGroup[i]
				index = index + 1
			end
		end

		local leftWuXing = {}
		local index_new = 1
		local sameNum = FuncWuLing.getFiveSoulMatrixMethodByLevel(UserModel:level()).same
		if #tempWuXing > 0 then
			for i, v in ipairs(tempWuXing) do
				local level = WuLingModel:getWuLingLevelById(v)
				local isExchange = false
				local index = 0
				local order = 6
				for ii,vv in ipairs(wuXingForPartners) do
					if vv.curElem == "0" then
						if WuLingModel:getWuLingLevelById(vv.partnerElem) == level and 
							self:getSameNumById(vv.partnerElem, partnerFormation) < sameNum then							
							if tonumber(vv.partnerElem) < order then
								order = tonumber(vv.partnerElem)
								index = ii
							end
						end
					end
				end

				if index ~= 0 then
					partnerFormation["p"..index].element.elementId = tostring(order)
					partnerFormation["p"..index].element.rid = UserModel:rid()
					wuXingForPartners[index].curElem = tostring(order)
					isExchange = true
				end
				if isExchange == false then
					leftWuXing[index_new] = v
					index_new = index_new + 1
				end
			end
		end
		
		local lastLeftWuXing = table.deepCopy(leftWuXing)
		if #leftWuXing > 0 then
			for i, v in ipairs(leftWuXing) do
				for ii,vv in ipairs(wuXingForPartners) do
					if vv.curElem == "0" and vv.partnerElem ~= 0 then
						partnerFormation["p"..ii].element.elementId = tostring(v)
						partnerFormation["p"..ii].element.rid = UserModel:rid()
						wuXingForPartners[ii].curElem = tostring(v)
						lastLeftWuXing[i] = 0
						break
					end
				end
			end
		end

		for i,v in ipairs(lastLeftWuXing) do
			if v ~= 0 then
				for ii,vv in ipairs(wuXingForPartners) do
					if vv.curElem == "0" then
						partnerFormation["p"..ii].element.elementId = tostring(v)
						partnerFormation["p"..ii].element.rid = UserModel:rid()
						wuXingForPartners[ii].curElem = tostring(v)
						break
					end
				end
			end
		end
	end
end

function TeamFormationModel:setAllOnSecondFormation(allNpcs, allNum, partnerFormation)
	local index = 2
	local showNum = 0
	for k = 1, allNum, 1 do
		local heroId = "0"
		local dapType = true
		if allNpcs[index] ~= nil and heroId =="0" then
			heroId = tostring(allNpcs[index].id)			
			
			-- 如果奇侠能上阵  且已上阵数量小于能上阵的数量
			if dapType and showNum < allNum and allNpcs[index] then
				local heroType = allNpcs[index].type				
				self:setPartnerByType(heroType, heroId, partnerFormation)		
				index = index + 2
				showNum = showNum + 1
			end	
		end
	end

	self:setAllOnFormationWuXing(partnerFormation)
end

--[[
一键上阵
]]
function TeamFormationModel:allOnFormation(hasPamams,systemId)
	local allNpcs = self:getAllOnFormationNpcs(hasPamams, systemId)
	--已占用的位置数量
	local showNum = self:getAllOnFormationShowNum(hasPamams, systemId)
	--按照每个位置的特定需求上阵伙伴
	local allNum = self:getAllOnFormationNums(hasPamams, systemId)
	
	--设置一键布阵的奇侠阵型
	self:setAllOnFormationPartners(hasPamams, systemId, allNpcs, allNum, showNum, self.tempFormation.partnerFormation)	
	--设置一键布阵五灵阵型
	self:setAllOnFormationWuXing(self.tempFormation.partnerFormation, systemId)

	if tonumber(systemId) == FuncTeamFormation.formation.endless then
		self:setAllOnSecondFormation(allNpcs, allNum, self.tempFormation.partnerFormation2)
	end

	--统计总的五行数
	self:createWuXingNum()
end

function TeamFormationModel:getSameNumById(_elementId, partnerFormation)
	local sameNum = 0
	for i = 1, 6, 1 do
		if tonumber(partnerFormation["p"..i].element.elementId) == tonumber(_elementId)  then
			sameNum = sameNum + 1
		end
	end
	return sameNum
end

--[[
临时阵容
]]
function TeamFormationModel:getTempFormation(  )
	return self.tempFormation
end

function TeamFormationModel:doSpecialOnFormation()
	if UserModel:level() < 24 then
		-- echoError("新手引导特殊自动布阵")
		local nowHasNum = 0

		for i=1,6 do
			if self.formations and self.formations[tostring(FuncTeamFormation.formation.pve)] and 
				tonumber(self.formations[tostring(FuncTeamFormation.formation.pve)].partnerFormation["p"..i].partner.partnerId) ~= 0 then
				nowHasNum= nowHasNum + 1
			end	
		end
		-- if self._hasRequest then
		-- 	return
		-- end
		-- self._hasRequest = true
		local allNums = PartnerModel:getPartnerNum() + 1
		if allNums > nowHasNum and  nowHasNum < FuncTeamFormation.checkPosIsOpenNum() then
			-- echo("____nowHasNum_____=", nowHasNum, allNums)
			self:createTempFormation(FuncTeamFormation.formation.pve)
			self:allOnFormation( {} )
	  		local params = {			
				id = FuncTeamFormation.formation.pve,
				formation = self:getTempFormation(),
			}  		
	  		TeamFormationServer:doFormation(params, function ()
	  				self:saveLocalData(nil, 1)
	  				self:checkFormationRedPoint(true)
	  			end)
  		end
	end
end

--[[
获取阵容信息
]]
function TeamFormationModel:getFormation( systemId,raidId)
	local key = systemId
	if tonumber(systemId) == FuncTeamFormation.formation.pve_elite then
		key = tostring(FuncTeamFormation.formation.pve)
		-- key = systemId .. raidId
	end
	if tonumber(systemId) == FuncTeamFormation.formation.shareBoss then
		key = systemId .. raidId
	end	
	--如果是新手引导期间  则自动上阵处理，并且初始化为预设阵容1
	-- if not TutorialManager.getInstance():isFinishForceGuide() and UserModel:level() < 17 then
	-- echo("\n\nself.needSaveStatus=====", self.needSaveStatus)
	
	return self.formations[tostring(key)]
end

function TeamFormationModel:getPartnerNumBySystemId(_systemId)
	if not _systemId then
		_systemId = FuncTeamFormation.formation.pve
	end

	local formation = TeamFormationModel:getFormation(_systemId)

	local num = 0
	for k,v in pairs(formation.partnerFormation) do
		if tostring(v.partner.partnerId) ~= "0" then
			num = num + 1
		end
	end
	
	return num
end

--[[
获取当前上阵的法宝(npc获取专用)
]]
function TeamFormationModel:getCurTreaByIdx(pIdx)
	if self.tempFormation then
		if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
			return self.tempFormation.treasureFormation2["p"..pIdx]
		else
			return self.tempFormation.treasureFormation["p"..pIdx]
		end	 
	else
		return "404"
	end	
end


--[[
根据位置  获取当前位置的 heroId
]]
function TeamFormationModel:getHeroByIdx(pIdx, isSecondFormation)
	if isSecondFormation then
		return  self.tempFormation.partnerFormation2["p"..pIdx].partner.partnerId,
				self.tempFormation.partnerFormation2["p"..pIdx].partner.teamFlag,
				self.tempFormation.partnerFormation2["p"..pIdx].partner.rid
	else
		return  self.tempFormation.partnerFormation["p"..pIdx].partner.partnerId,
				self.tempFormation.partnerFormation["p"..pIdx].partner.teamFlag,
				self.tempFormation.partnerFormation["p"..pIdx].partner.rid
	end
end

--[[
判断hero是否上阵了
@params :systemId 使用的系统id
@params：hid hero的id 
]]
function TeamFormationModel:chkIsInFormation(hid)
	-- echo("当前的阵容数据")
	-- dump(self.tempFormation)
	-- echo("当前的阵容数据")
	local fmt = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		fmt = self.tempFormation.partnerFormation2
	end

	for k,v in pairs(fmt) do
		if tostring(v.partner.partnerId) == tostring(hid) then
			return true
		end
	end
	
	return false
end

--无底深渊  判断奇侠是否上阵 且返回在哪一波阵型中
function TeamFormationModel:chkIsInWhichFormationWave(partnerId)
	local isInFormation = false
	local formationWave = FuncEndless.waveNum.FIRST

	for k,v in pairs(self.tempFormation.partnerFormation) do
		if tostring(v.partner.partnerId) == tostring(partnerId) then
			isInFormation = true
			return isInFormation, formationWave
		end
	end

	for k,v in pairs(self.tempFormation.partnerFormation2) do
		if tostring(v.partner.partnerId) == tostring(partnerId) then
			isInFormation = true
			formationWave = FuncEndless.waveNum.SECOND
			return isInFormation, formationWave
		end
	end

	return isInFormation
end

-- 判断普通阵型中是否满员
function TeamFormationModel:chkFormationIsFull(_formationNum, _formation)
	-- echo("当前的阵容数据")
	-- dump(self.tempFormation)
	-- echo("当前的阵容数据")
	local fmt = {}
	if _formation and _formation.partnerFormation then
		fmt = _formation.partnerFormation
	end
	local num = 0
	local ignoreId = "0"
	if tonumber(_formation.id) == FuncTeamFormation.formation.crossPeak then
		local currentSegment = tonumber(CrossPeakModel:getCurrentSegment())
		ignoreId = FuncCrosspeak.getCrossPeakNpcIdByPlayType(FuncCrosspeak.PLAYMODE.CACTUS, currentSegment)
	end
	
	for k,v in pairs(fmt) do
		if tostring(v.partner.partnerId) ~= "0" and tostring(v.partner.partnerId) ~= ignoreId then
			num = num + 1
		end
	end
	
	if num < _formationNum then
		return false
	elseif num == _formationNum then
		return true
	else
		-- echoError("该阵容上阵人数超过可上阵人数")
		return false
	end

end

-- 巅峰竞技场用于判断主角是否处于阵型中
function TeamFormationModel:isCharInFormationOrCandidate()
	local isInFormation = self:chkIsInFormation("1")
	local isInCandidate = self:chkIsInCandidate("1")

	return isInFormation or isInCandidate
end

--判断奇侠是否在候补中  只有巅峰竞技场才会调用该方法 调用前需要判断systemId
function TeamFormationModel:chkIsInCandidate(_partnerId)
	-- echo("当前的阵容数据")
	-- dump(self.tempFormation)
	-- echo("当前的阵容数据")
	local fmt = self.tempFormation.bench
	for k,v in pairs(fmt) do
		if tostring(v) == tostring(_partnerId) then
			return true
		end
	end
	return false
end

--判断候补奇侠是否已满  只有巅峰竞技场才会调用该方法 调用前需要判断systemId
function TeamFormationModel:chkCandidateIsFull(_candidateNum, _formation)
	local fmt = {}
	if _formation and _formation.bench then
		fmt = _formation.bench
	end
	for k = 1, _candidateNum, 1 do
		if fmt[tostring(k)] == nil or fmt[tostring(k)] == "0" then
			return false
		end
	end
	return true
end

-- 判断巅峰竞技场阵型是否满员  仅巅峰竞技场可使用
function TeamFormationModel:checkCrossPeakTeamIsFull(_formation)
	if _formation == nil then
		return false
	end

	local fightNumMax = CrossPeakModel:getFightNumMax()
	local fightInStageMax = CrossPeakModel:getFightInStageMax()
	local candidateNum = fightNumMax - fightInStageMax

	local isFormationFull = self:chkFormationIsFull(fightInStageMax, _formation)
	local isCandidateFull = self:chkCandidateIsFull(candidateNum, _formation)

	if isFormationFull and isCandidateFull then
		return true
	end
	return false
end
--[[
判断法宝是否上阵
]]
function TeamFormationModel:chkTreaInFormation(treaId, isSecondWave)
	local trea = self.tempFormation.treasureFormation
	if isSecondWave then
		trea = self.tempFormation.treasureFormation2
	end
	for k,v in pairs(trea) do
		if tostring(v) == tostring(treaId) then
			return true
		end
	end
	return false
end

--[[
更新临时阵容
]]
function TeamFormationModel:updatePartner(pIdx, heroId, rid, teamFlag, isHelper)
	-- echoError("\n\npIdx==", pIdx, "heroId==", heroId, "teamFlag==", teamFlag)
	--dump(self.tempFormation)
	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2		
	end
	if tostring(heroId) == "0" then
		partnerFormation["p"..pIdx].partner = {}
	else
		partnerFormation["p"..pIdx].partner.rid = rid or UserModel:rid()
	end
	partnerFormation["p"..pIdx].partner.partnerId = tostring(heroId)
	partnerFormation["p"..pIdx].partner.teamFlag = teamFlag
	partnerFormation["p"..pIdx].partner.isHelper = isHelper
	-- echo("更新NPC后的信息")
	-- dump(self.tempFormation, "self.tempFormation====")
	-- echo("更新NPC后的信息")
end

--无底深渊 特殊处理  上阵1队的人 能够上阵到2队  并从原队伍中移除
function TeamFormationModel:dischargePartnerByFormationWave(pIdx, _formationWave)
	local partnerFormation = self.tempFormation.partnerFormation
	if _formationWave and _formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2	
	end
	partnerFormation["p"..pIdx].partner = {}
	partnerFormation["p"..pIdx].partner.partnerId = "0"
end

function TeamFormationModel:updateCandidatePartner(_partnerId, _candidateNum)
	local fmt = self.tempFormation.bench
	for k = 1, _candidateNum, 1 do
		if fmt[tostring(k)] == nil or fmt[tostring(k)] == "0" then
			self.tempFormation.bench[tostring(k)] = tostring(_partnerId)
			break
		end
	end
end

function TeamFormationModel:removeCandidatePartner(_index)
	self.tempFormation.bench[tostring(_index)] = "0"
end

--[[
获取自动上阵应该所在的位置
]]
function TeamFormationModel:getAutoPIdx( ty )
	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2
	end
	if tonumber(ty) == 1 then
		if tonumber(partnerFormation["p4"].partner.partnerId) == 0 then
			return 4
		elseif tonumber(partnerFormation["p6"].partner.partnerId) == 0 then 
		 	return 6
		elseif tonumber(partnerFormation["p5"].partner.partnerId) == 0 then  	
			return 5
		elseif tonumber(partnerFormation["p1"].partner.partnerId) == 0 then  	
			return 1
		elseif tonumber(partnerFormation["p3"].partner.partnerId) == 0 then  	
			return 3
		elseif tonumber(partnerFormation["p2"].partner.partnerId) == 0 then  	
			return 2		
		end 

	elseif tonumber(ty) == 2 then
		if tonumber(partnerFormation["p1"].partner.partnerId) == 0 then
			return 1
		elseif tonumber(partnerFormation["p2"].partner.partnerId) == 0 then 
		 	return 2
		elseif tonumber(partnerFormation["p3"].partner.partnerId) == 0 then  	
			return 3
		elseif tonumber(partnerFormation["p4"].partner.partnerId) == 0 then  	
			return 4
		elseif tonumber(partnerFormation["p5"].partner.partnerId) == 0 then  	
			return 5
		elseif tonumber(partnerFormation["p6"].partner.partnerId) == 0 then  	
			return 6		
		end 
	elseif tonumber(ty) == 3 then
		if tonumber(partnerFormation["p3"].partner.partnerId) == 0 then
			return 3
		elseif tonumber(partnerFormation["p5"].partner.partnerId) == 0 then 
		 	return 5
		elseif tonumber(partnerFormation["p1"].partner.partnerId) == 0 then  	
			return 1
		elseif tonumber(partnerFormation["p2"].partner.partnerId) == 0 then  	
			return 2
		elseif tonumber(partnerFormation["p6"].partner.partnerId) == 0 then  	
			return 6
		elseif tonumber(partnerFormation["p4"].partner.partnerId) == 0 then  	
			return 4
		end	
	else
		for k = 1,6,1 do 
			if tonumber(partnerFormation["p"..k].partner.partnerId) == 0 then
				return k
			end 
		end
	end		
end

function TeamFormationModel:getAutoPIdxByWuXingId(_id)
	local index = 0
	local isFirst = true

	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2		
	end
	for i = 1, 6, 1 do
		local curElementId = partnerFormation["p"..i].element.elementId
		local tempElementId = 0
		local partnerId = partnerFormation["p"..i].partner.partnerId 
		if tonumber(partnerId) == 0 then
			tempElementId = 0
		elseif tonumber(partnerId) == 1 then 
            local curTreasure = FuncTreasureNew.getTreasureDataById(TeamFormationModel:getCurTreaByIdx(1))
            tempElementId = curTreasure.wuling
        else
        	local partnerData = FuncPartner.getPartnerById(partnerId)
        	if partnerData then
        		tempElementId = partnerData.elements
        	end        	
		end

		if tonumber(curElementId) == 0 then
			if tonumber(tempElementId) == tonumber(_id) then
				return i
			elseif isFirst then
				index = i
				isFirst = false
			end
		end
	end
	return index
end

--[[
获取heroid所在的阵位阵容
]]
function TeamFormationModel:getPartnerPIdx(heroId, _formationWave)
	local partnerFormation = self.tempFormation.partnerFormation
	if _formationWave and _formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2
	end
	for k,v in pairs(partnerFormation) do
 		if tostring(v.partner.partnerId) == tostring(heroId) then
 			local pIdx = k
 			return toint( string.sub(pIdx,2) )
 		end
 	end
end

--[[
获取阵容中的位置
]]
function TeamFormationModel:getPartnerPos(formation,heroId)
	for k,v in pairs(formation.partnerFormation) do
		if tostring(v.partner.partnerId) == tostring(heroId) then
			return toint( string.sub(k,2) )
		end
	end
end

--[[
更新法宝信息
]]
function TeamFormationModel:updateTrea(pIdx,treaId,isSecondWave)
	if not isSecondWave then
		self.tempFormation.treasureFormation["p"..pIdx] = tostring(treaId)
	else
		self.tempFormation.treasureFormation2["p"..pIdx] = tostring(treaId)
	end
end

function TeamFormationModel:updatePveTrea(treasureId)
	self.formations["1"].treasureFormation["p1"] = treasureId
	local params = {}
    params.id = FuncTeamFormation.formation.pve
    params.formation = self.formations["1"]
    TeamFormationServer:doFormation(params, function ()
    		WindowControler:showTips("佩戴成功")
    		EventControler:dispatchEvent(TreasureNewEvent.DRESS_TREASURE_SUCCESS)
    	end)
end

--[[
获取法宝所在的位置
]]
function TeamFormationModel:getTreaPIdx( treaId )
	for k,v in pairs(self.tempFormation.treasureFormation) do
 		if tostring(v) == tostring(treaId) then
 			local pIdx = k
 			return toint( string.sub(pIdx,2) )
 		end
 	end
end


--获取“查看阵容”功能，阵容
function TeamFormationModel:getLineUpFormation()
    local _lineUpFormation = self:getFormation(FuncTeamFormation.formation.check_lineup) or {}
    _lineUpFormation.treasureFormation = _lineUpFormation.treasureFormation or {}
    _lineUpFormation.partnerFormation = _lineUpFormation.partnerFormation or {}
    return _lineUpFormation
end

--获取当前自己的上阵人数
function TeamFormationModel:hasNowTeamNum(_systemId)
	local nowHasNum = 0
	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2
	end

	for i=1,6 do		
		if tonumber(partnerFormation["p"..i].partner.partnerId) ~= 0 then
			if tonumber(_systemId) == FuncTeamFormation.formation.crossPeak and 
					partnerFormation["p"..i].partner.teamFlag then
				
			else
				nowHasNum = nowHasNum + 1
			end
			
			if self.tempFormation.partnerFormation["p"..i].partner.rid and 
				self.tempFormation.partnerFormation["p"..i].partner.rid ~= UserModel:rid() then
				nowHasNum = nowHasNum - 1
			end
		end	
	end
	return nowHasNum
end

--获取多人布阵的总上阵人数
function TeamFormationModel:hasMultiNowTeamNum(_systemId)
	local nowHasNum = 0
	for i=1,6 do		
		if tonumber(self.tempFormation.partnerFormation["p"..i].partner.partnerId) ~= 0 then
			nowHasNum = nowHasNum + 1
		end	
	end
	return nowHasNum
end



function TeamFormationModel:hasNowCandidateNum()
	local nowCandidateNum = 0
	if self.tempFormation.bench and table.length(self.tempFormation.bench) > 0 then
		for k,v in pairs(self.tempFormation.bench) do
			if v and tostring(v) ~= "0" then
				nowCandidateNum = nowCandidateNum + 1
			end
		end
	end
	return nowCandidateNum
end

--确定当前是否拥有阵位(锁妖塔专用更改)
function TeamFormationModel:getNowEmptyTeamNum()
	local nowHasNum = 0
	for i=1,6 do
		if tonumber(self.tempFormation.partnerFormation["p"..i].partner.partnerId) == 0 then
			nowHasNum= nowHasNum+1
		end	
	end
	if nowHasNum == 6 then
		return true
	end
	return false

end


--取战斗的临时战力
function TeamFormationModel:getTempAbility(_systemId)
    local containHero = false
    local ability = 0
    local teamFormation = {}
    local treasureId 
    if _systemId then
    	teamFormation = self.formations[tostring(_systemId)]
    	treasureId = teamFormation.treasureFormation["p1"]
    else
    	teamFormation = {
    		id = self.tempFormation.id,
			partnerFormation = self.tempFormation.partnerFormation,
			treasureFormation = self.tempFormation.treasureFormation
    	}
    	
    	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
    		teamFormation = {
    			id = self.tempFormation.id,
    			partnerFormation = self.tempFormation.partnerFormation2,
    			treasureFormation = self.tempFormation.treasureFormation2
    		}
    	end

    	treasureId = teamFormation.treasureFormation["p1"]
    end

    local partnerNum, wulingNum = self:getPartnerNumByFormation(teamFormation.partnerFormation)
    if partnerNum == 0 then
    	ability = 0
		return ability
	end

    ability = UserModel:getTeamAbility(treasureId, teamFormation)
	for k,v in pairs(teamFormation.partnerFormation) do
		if tostring(v.partner.partnerId) == "1" then
			containHero = true
			break
		end
	end

	if containHero == false then
		ability = ability - CharModel:getCharAbility(treasureId)
	end

    return ability
end

--多人布阵 阵型战力计算
function TeamFormationModel:getMultiTempAbility()
	local teamFormation = self.tempFormation
	local mateInfo = GuildBossModel:getGuildBossMateInfo()
	local selfInfo = GuildBossModel:getGuildBossSelfInfo()

	local ability = 0
    local charAbility = 0
    local partners = teamFormation.partnerFormation
    local partnerAbility = 0
    local wulingAbility = 0
    local teamMatePartners = {}
    local teamSelfPartners = {}

	-- self.multiTreaOwner, self.multiTreasureId
	for i = 1, 6, 1 do
		local id = partners["p"..i].partner.partnerId
		--上阵的主角战力
		if id and tonumber(id) == 1 then
			if partners["p"..i].partner.rid == UserModel:rid() then
				charAbility = CharModel:getCharAbility(self.multiTreasureId)
			else
				charAbility = self:getCharAbilityByInfo(mateInfo)
			end
		end

		--上阵奇侠战力
		if id and tonumber(id) ~= 1 and tonumber(id) ~= 0 then
			if partners["p"..i].partner.rid == UserModel:rid() then
				partnerAbility = partnerAbility + FuncPartner.getAbilityByAbilityInfo(selfInfo.abilityNew.partners[tostring(id)])
            	table.insert(teamSelfPartners, id)
			else
				partnerAbility = partnerAbility + FuncPartner.getAbilityByAbilityInfo(mateInfo.abilityNew.partners[tostring(id)])
            	table.insert(teamMatePartners, id)
			end		
		end

		local elementId = partners["p"..i].element.elementId 
        -- 上阵五灵战力
        if tostring(elementId) ~= "0" then
            local tempWulingAbility = 0
            local isMate = false
            if partners["p"..i].element.rid == UserModel:rid() then
            	tempWulingAbility = WuLingModel:getTempAbility(elementId)
            else
            	tempWulingAbility = WuLingModel:getTempAbility(elementId, mateInfo.fivesouls)
            	isMate = true
            end
            
            wulingAbility = wulingAbility + tempWulingAbility
            --计算五灵激活时额外提供的战力
            if tonumber(id) == 1 then
                local dataCfg = FuncTreasureNew.getTreasureDataById(self.multiTreasureId)
                local partnerElement = dataCfg.wuling
                local awakenAbility = 0
                if not isMate then
                	awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement, elementId)
                else
                	awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement, elementId, mateInfo.fivesouls)
                end
                
                wulingAbility = wulingAbility + awakenAbility
            elseif tonumber(id) ~= 0 then
                local partnerData = FuncPartner.getPartnerById(id)
                if partnerData then
                    local partnerElement = partnerData.elements
                    local awakenAbility = 0
                    if not isMate then
	                	awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement, elementId)
	                else
	                	awakenAbility = WuLingModel:getTempAwakenAbility(partnerElement, elementId, mateInfo.fivesouls)
	                end
                    wulingAbility = wulingAbility + awakenAbility
                end                
            end
        end
	end

	--计算两个人的神器战力
	local baowuSelfAbility = FuncArtifact.getArtifactAllPower(UserModel:getAbilityUserData(), self.multiTreasureId, teamSelfPartners)
    local baowuMateAbility = FuncArtifact.getArtifactAllPower(UserModel:getAbilityUserData(mateInfo), self.multiTreasureId, teamMatePartners)
    local allTreasAbility = 0
    --只计算上阵了主角的玩家的法宝战力
    if self.multiTreaOwner then
    	if self.multiTreaOwner ~= UserModel:rid() then
	    	allTreasAbility = TreasureNewModel:getAllTreasStarAbility(mateInfo.treasures)
	    else
	    	allTreasAbility = TreasureNewModel:getAllTreasStarAbility()
	    end
	end
     
    --计算两个人的情景卡战力
    local memeryCardSelfAbility = FuncMemoryCard.getPowerByPartnerId(MemoryCardModel:data())
    local memeryCardMateAbility = FuncMemoryCard.getPowerByPartnerId(mateInfo.memorys)

    ability = charAbility + partnerAbility + wulingAbility + baowuSelfAbility + baowuMateAbility + allTreasAbility
    			 + memeryCardSelfAbility + memeryCardMateAbility

    return ability
end

--队友的主角战力计算
function TeamFormationModel:getCharAbilityByInfo(mateInfo)
	local charData = CharModel:getCharData(mateInfo)
	local treasureData = mateInfo.treasures[tostring(self.multiTreasureId)]
	local treasureLevel = mateInfo.level
	local titleData = mateInfo.title
	local garmentIds = FuncGarment.getEnabledGarments(mateInfo.garments or {})
	local lovesData = mateInfo.loves
	local userData = mateInfo
	local level = treasureLevel
	local memory = mateInfo.memorys
	local params = {
        chard = charData,
        trsd = treasureData,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentIds,
        loved = lovesData,
        userd = userData,
        skillLevel = level,
        memory = memory
    }
	local ability = FuncChar.getCharAbility(params,false)
	return ability
end

--获取主角临时战力
function TeamFormationModel:getCharAbility( )
	local charData = CharModel:getCharData()
	local treasureId = self.tempFormation.treasureFormation["p1"]
	-- echo("----主角的 上阵法宝ID === ",treasureId)
	local treasuredata = TreasureNewModel:getTreasureData(tostring(treasureId))
	-- dump(treasuredata,"法宝数据")
	local treasureLevel = UserModel:level()
    local titleData = TitleModel:getHisData()
    local ownGarments = GarmentModel:getAllServerGarments()
    local garmentIds = FuncGarment.getEnabledGarments(ownGarments,true)
    --local artifactData = ArtifactModel:data() -- 宝物不要了
    local userData = UserModel:getUserData()
    local params = {
    	chard = charData,
        trsd = treasuredata,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentIds,
        userd = userData
	}
	local ability = FuncChar.getCharAbility(params)
	echo("主角战力 === ",ability)
	return  math.floor(ability)
end

--获取当前阵位的五行
function TeamFormationModel:getPosWuXingById(pIdx, isSecondFormation)
	local nowWuXingId = self.tempFormation.partnerFormation["p"..pIdx].element.elementId
	local nowWuXingRid = self.tempFormation.partnerFormation["p"..pIdx].element.rid
	if isSecondFormation then
		nowWuXingId = self.tempFormation.partnerFormation2["p"..pIdx].element.elementId
		nowWuXingRid = self.tempFormation.partnerFormation2["p"..pIdx].element.rid
	end
	return nowWuXingId, nowWuXingRid
end

--设定当前阵位五行
function TeamFormationModel:setPosWuXing(pIdx, wuxing, rid)
	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2
	end

	if tostring(wuxing) == "0" then
		partnerFormation["p"..pIdx].element = {}
	else
		self.tempFormation.partnerFormation["p"..pIdx].element.rid = rid or UserModel:rid()	
	end
	partnerFormation["p"..pIdx].element.elementId = tostring(wuxing)
end

--获取当前某个五行的数目
function TeamFormationModel:getWuXingTempNum(id)
	local chooseWuXingNum = self.chooseWuXingNum
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		chooseWuXingNum = self.chooseWuXingNum2
	end
	return chooseWuXingNum[tonumber(id)]
end

--获取当前某个玩家某个五行的已上阵的数目  用于多人布阵
function TeamFormationModel:getWuXingReadyNumByRid(id, _rid)
	local hasNum = 0
    for i=1,6 do
    	if self.tempFormation.partnerFormation["p"..i].element.elementId == id 
    		and _rid == self.tempFormation.partnerFormation["p"..i].element.rid then
            hasNum = hasNum + 1
        end
    end
    return hasNum
end

function TeamFormationModel:getWuXingMultiTempNum(id, _rid)
	local hasNum = self:getWuXingReadyNumByRid(id, _rid)
	local wuxingNum = FuncTeamFormation.getMultiWuXingNum(id, UserModel:level())
	return wuxingNum - hasNum
end

--当前的阵位随等级开启（这里有写死的阵位开启最大等级，如果更改了，需要修改）
function TeamFormationModel:hasPosNum(systemId)
	local nowHasPosNum = FuncTeamFormation.checkPoshasOpenNum(UserModel:level())
    local hasNum = self:hasNowTeamNum(systemId)
    -- if UserModel:level() < 17 then
    --     nowHasPosNum = nowHasPosNum - 1
    -- end

    if systemId == FuncTeamFormation.formation.crossPeak then
    	local currentSegment = CrossPeakModel:getCurrentSegment()
    	local maxPosNum = FuncCrosspeak.getSegmentDataByIdAndKey(currentSegment, "fightInStageMax")
    	if maxPosNum < nowHasPosNum then
    		nowHasPosNum = maxPosNum
    	end
    end

    if systemId == FuncTeamFormation.formation.guildBoss or
    	systemId == FuncTeamFormation.formation.guildBossGve  then
    	nowHasPosNum = FuncDataSetting.getDataByConstantName("GuildBossSingleMax")
    end

    if systemId == FuncTeamFormation.formation.endless then
    	local curEndlessId = EndlessModel:getCurChallengeEndlessId()
        nowHasPosNum = FuncEndless.getFormationNumByEndlessId(curEndlessId)
    end
    
    if hasNum < tonumber(nowHasPosNum) then
        return true
    else
        return false
    end  
end

--当前阵位开启数（也存在写死的阵位最大开启等级）
function TeamFormationModel:quickHasPosNum()
    local nowHasPosNum,nowLevel = FuncTeamFormation.checkPoshasOpenNum(UserModel:level())
    -- if UserModel:level() < 17 then
    --     nowHasPosNum =nowHasPosNum -1
    -- end
    return nowHasPosNum
end

--当前阵容五灵上阵数
function TeamFormationModel:getAllWuXinNum()
	local hasNum = 0
	local partnerFormation = self.tempFormation.partnerFormation
	if self.formationWave and self.formationWave == FuncEndless.waveNum.SECOND then
		partnerFormation = self.tempFormation.partnerFormation2
	end
    for i=1,6 do
    if partnerFormation["p"..i].element.elementId ~= "0" then
            hasNum = hasNum +1
        end
    end
    return hasNum
end

function TeamFormationModel:getWuXingNumByRid(_rid)
	local hasNum = 0
    for i=1,6 do
    if self.tempFormation.partnerFormation["p"..i].element.elementId ~= "0" 
    	and _rid == self.tempFormation.partnerFormation["p"..i].element.rid then
            hasNum = hasNum + 1
        end
    end
    return hasNum
end

--五灵开启数目
function TeamFormationModel:wuxingHasPosNum(systemId)
	local nowWuXingPosNum,nowLevel = FuncTeamFormation.checkWuXingPosOpen(UserModel:level())
	if systemId and tonumber(systemId) == FuncTeamFormation.formation.guildBoss and 
		nowWuXingPosNum > FuncDataSetting.getDataByConstantName("GuildBossSingleMax") then

		nowWuXingPosNum = FuncDataSetting.getDataByConstantName("GuildBossSingleMax")
	end
	return nowWuXingPosNum
end

function TeamFormationModel:wuxingMultiHasPosNum()
	local nowWuXingPosNum,nowLevel = FuncTeamFormation.checkMulitWuXingPosOpen(UserModel:level())
	return nowWuXingPosNum
end

--检测用的获取当前pve阵容
function TeamFormationModel:getNowTeam()
	dump(self.formations["1"],"当前阵容1")
end

--获取当前法宝带来的前中后排加成
function TeamFormationModel:getTreasurePosNature()
	local allTreas = TreasureNewModel:getAllTreasure()
	self.tempFrontRowNature = {}
	self.tempMiddleRowNature = {}
	self.tempBackRowNature = {}
	for k,v in pairs(allTreas) do
		local treasureData = TreasureNewModel:getTreasureData(v)
		if treasureData then
		 	local tempData = FuncTreasureNew.getTreasureDataById(treasureData.id)
		 	local tempType = tempData.site
		 	local star = treasureData.star
		 	local currentSystemId = TeamFormationModel:getCurrentSystemId()
		 	if currentSystemId and tostring(curSystemId) == tostring(FuncTeamFormation.formation.crossPeak) then
		 		local currentSegment = CrossPeakModel:getCurrentSegment()
                local currentSegmentData = FuncCrosspeak.getSegmentDataById(currentSegment)
                star = currentSegmentData.starTreasure
		 	end

		 	for i=1, star do
			    if i <= 6 then
		            -- 获取星级属性加成
		            local _starP = 6
		            if i == treasureData.star then
		                _starP = treasureData.starPoint
		            end
		            local des = FuncTreasureNew.getTreaPermanentAttr(treasureData.id,i,_starP )
			 		local info = {}
					local attrName = FuncBattleBase.getAttributeName(des.key)
					info.value = des.value
					info.name = attrName
					info.key = des.key
					info.mode = des.mode
					if tempType == 1 then
						table.insert(self.tempFrontRowNature,info)
					elseif tempType == 2 then
						table.insert(self.tempMiddleRowNature,info)
					else
						table.insert(self.tempBackRowNature,info)
					end
			    end
			end
		end	
	end
end

--通关type获取当前法宝的前中后阵位加成
function TeamFormationModel:getFrontRowNature(type)
	local tempData = {}
	local finalDara ={}
	local tempNature = nil
	if tonumber(type) == 1 then 
		tempNature = self.tempFrontRowNature
	elseif tonumber(type) == 2 then
		tempNature = self.tempMiddleRowNature
	else
		tempNature = self.tempBackRowNature	
	end

	for k,v in pairs(tempNature) do
		local tempkey = v.name..v.mode
		if tempData[tempkey] then
			tempData[tempkey].value = tempData[tempkey].value + v.value
		else	
			tempData[tempkey] = {}
			tempData[tempkey].name =v.name
			tempData[tempkey].value =v.value
			tempData[tempkey].key = v.key
			tempData[tempkey].mode = v.mode
		end
	end
	for n,m in pairs(tempData) do
		table.insert(finalDara,m)
	end	
	table.sort(finalDara,function (a,b)
		return tonumber(a.key) < tonumber(b.key)
	end)
	if table.length(finalDara) == 0 then
		finalDara = {1}
	end
	return finalDara
end

--法宝加成属性替换
function TeamFormationModel:isCanConVert(key)
	local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
		Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist
    }
    local attrData = FuncBattleBase.getAttributeData(key)
    local typeName = attrData.keyName
    for i=1,#percentKeyArr do
    	if tostring(typeName) == tostring(percentKeyArr[i]) then
    		return false
    	end
    end
    return true
end

--查看当前阵容是否还有活人(锁妖塔专用)
function TeamFormationModel:checkAllDead()
	local allTowerNpcs = TeamFormationSupplyModel:getNPCsByTy(0)
	local deadNum = 0
	for i,v in ipairs(allTowerNpcs) do
		if v.HpPercent <= 0 or v.hasBan then
			deadNum = deadNum + 1
		end
	end

	if deadNum == #allTowerNpcs then
		return true
	end

	return false
	-- for k = 1,6,1 do 
	-- 	if tonumber(self.tempFormation.partnerFormation["p"..k].partner.partnerId) ~= 0 then
	-- 		return false
	-- 	end
	-- end		
	-- return true
end

--特殊一键布阵(引导专用)
function TeamFormationModel:allOnSpecialTeam()
	echo("走了新手引导的特殊布阵")
	local allNpcs ={}
	local trialtype = TrailModel.trialselectType or 1 
    local _type = TrailModel:byTypegetPT( trialtype )
    -- local dataDefend = TeamFormationMultiModel:getNPCsByTy(_type,true)
    allNpcs  = self:getNPCsByTy(0)
    
    --清理阵容
    for k = 1,6,1 do 
		self.tempFormation.partnerFormation["p"..k].partner = {}
		self.tempFormation.partnerFormation["p"..k].partner.partnerId = "0"
		self.tempFormation.partnerFormation["p"..k].element = {}
		self.tempFormation.partnerFormation["p"..k].element.elementId = "0"
	end

	--当前一号阵位
	self.tempFormation.partnerFormation["p1"].partner.partnerId = "1"
	self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()

	local index = 2
	local allNum = self:quickHasPosNum()
	local isHasHero = false
	for k = 2,allNum,1 do
		local heroId = "0"
		if allNpcs[index] ~= nil and heroId =="0" then
			heroId = tostring(allNpcs[index].id)
			heroType = allNpcs[index].type
			if tonumber(heroType) == 1 then
				if tonumber(self.tempFormation.partnerFormation["p2"].partner.partnerId) == 0 then
					self.tempFormation.partnerFormation["p2"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p2"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p4"].partner.partnerId) == 0 then 
				 	self.tempFormation.partnerFormation["p4"].partner.partnerId =heroId
				 	self.tempFormation.partnerFormation["p4"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p6"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p6"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p6"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p5"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p5"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p5"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p1"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p1"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p3"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p3"].partner.partnerId = heroId
					self.tempFormation.partnerFormation["p3"].partner.rid = UserModel:rid()
				end
			elseif tonumber(heroType) == 2 then
				dump(heroId,"防御型")
				if tonumber(self.tempFormation.partnerFormation["p2"].partner.partnerId) == 0 then
					self.tempFormation.partnerFormation["p2"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p2"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p1"].partner.partnerId) == 0 then 
				 	self.tempFormation.partnerFormation["p1"].partner.partnerId =heroId
				 	self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p3"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p3"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p3"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p4"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p4"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p4"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p5"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p5"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p5"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p6"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p6"].partner.partnerId = heroId
					self.tempFormation.partnerFormation["p6"].partner.rid = UserModel:rid()				
				end 
			elseif tonumber(heroType) == 3 then
				dump(heroId,"辅助型")
				if tonumber(self.tempFormation.partnerFormation["p2"].partner.partnerId) == 0 then
					self.tempFormation.partnerFormation["p2"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p2"].partner.rid = UserModel:rid()	
				elseif tonumber(self.tempFormation.partnerFormation["p3"].partner.partnerId) == 0 then 
				 	self.tempFormation.partnerFormation["p3"].partner.partnerId =heroId
				 	self.tempFormation.partnerFormation["p3"].partner.rid = UserModel:rid()	
				elseif tonumber(self.tempFormation.partnerFormation["p5"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p5"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p5"].partner.rid = UserModel:rid()	
				elseif tonumber(self.tempFormation.partnerFormation["p1"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p1"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p1"].partner.rid = UserModel:rid()
				elseif tonumber(self.tempFormation.partnerFormation["p6"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p6"].partner.partnerId =heroId
					self.tempFormation.partnerFormation["p6"].partner.rid = UserModel:rid()	
				elseif tonumber(self.tempFormation.partnerFormation["p4"].partner.partnerId) == 0 then  	
					self.tempFormation.partnerFormation["p4"].partner.partnerId = heroId
					self.tempFormation.partnerFormation["p4"].partner.rid = UserModel:rid()	
				end
			end	
		end	
		index = index+1
	end

end

function TeamFormationModel:setPvpFormationEnergy(_energyOrder, _systemId)
	if tonumber(_systemId) == FuncTeamFormation.formation.pvp_attack
	 	or tonumber(_systemId) == FuncTeamFormation.formation.pvp_defend then
		self.tempFormation.energy = {}
		if _energyOrder then
			self.tempFormation.energy = _energyOrder
		end
	end
end

function TeamFormationModel:setWonderLandStaticNpc(npc)
	self.wonderLandNpc = npc 
end

function TeamFormationModel:getWonderLandStaticNpc()
	return self.wonderLandNpc
end

function TeamFormationModel:isWonderStaticNpc(_systemId, _id)
	if tonumber(_systemId) == FuncTeamFormation.formation.wonderLand and self.wonderLandNpc 
		and tostring(self.wonderLandNpc) == tostring(_id) then
		return true
	end
	return false
end

-- 设置候补框的弹出状态
function TeamFormationModel:setCandidatePanelStatus(_boolean)
	self.candidatePanelStatus = _boolean
end

function TeamFormationModel:getCandidatePanelStatus()
	return self.candidatePanelStatus
end

-- 设置此时正处于关闭候补框状态 用于处理点击到柱子上奇侠时的事件
function TeamFormationModel:setCloseCandidatePanel(_boolean)
	self.isCloseCandidate = _boolean
end

function TeamFormationModel:isCloseCandidatePanel()
	return self.isCloseCandidate
end

--设置属性加成
function TeamFormationModel:setAttrAddition(attr_addition)
	self.attr_addition = attr_addition
end

--获取属性加成
function TeamFormationModel:getAttrAddition()
	return self.attr_addition
end

--设置仙界对决当前时间的模式
function TeamFormationModel:setCurrentCrossPeakPlayMode(_playMode)
	self.currentCrossPeakPlayMode = _playMode
end

--获取仙界对决当前时间的模式
function TeamFormationModel:getCurrentCrossPeakPlayMode()
	return self.currentCrossPeakPlayMode
end

--多人布阵的一些状态的设置
function TeamFormationModel:setIsHost(isHost)
	self.isHost = isHost
end

function TeamFormationModel:getIsHost()
	return self.isHost
end

--多人布阵设置法宝rid
function TeamFormationModel:setMultiTreasureOwnerAndId(rid, id)
	self.multiTreaOwner = rid
	self.multiTreasureId = id
end

function TeamFormationModel:getMultiTreasureOwnerAndId()
	return self.multiTreaOwner, self.multiTreasureId
end

--多人布阵设置准备状态
function TeamFormationModel:setMultiState(isHostPrepared, isMatePrepared)
	self.isHostPrepared = isHostPrepared
	self.isMatePrepared = isMatePrepared
end

function TeamFormationModel:getMultiState()
    return self.isHostPrepared, self.isMatePrepared
end

function TeamFormationModel:hasMultiNowWuXingNum(_systemId)
	if _systemId == FuncTeamFormation.formation.guildBossGve then
		local mateDatas = GuildBossModel:getGuildBossMateInfo()
		local ownNum = FuncTeamFormation.checkMulitWuXingPosOpen(UserModel:level())
		local mateNum = FuncTeamFormation.checkMulitWuXingPosOpen(mateDatas.level)
		return ownNum + mateNum
	end
end

--无底深渊方法  拥有两波布阵 设置当前处于哪一波布阵
function TeamFormationModel:setCurFormationWave(_formationWave)
	self.formationWave = _formationWave
end

--获取无底深渊当前处于哪一波布阵
function TeamFormationModel:getFormationWave()
	return self.formationWave
end

--判断无底深渊能否进入战斗  需要两个队都至少有一个奇侠
function TeamFormationModel:canEnterBattle()
	local num1 = self:getPartnerNumByFormation(self.tempFormation.partnerFormation)
	local num2 = self:getPartnerNumByFormation(self.tempFormation.partnerFormation2)

	if num1 >= 1 and num2 >= 1 then
		return true
	end

	return false
end

function TeamFormationModel:checkEndlessFormationIsFull()
	local curEndlessId = EndlessModel:getCurChallengeEndlessId()
    local curTeamNum = FuncEndless.getFormationNumByEndlessId(curEndlessId)

	local num1 = self:getPartnerNumByFormation(self.tempFormation.partnerFormation)
	local num2 = self:getPartnerNumByFormation(self.tempFormation.partnerFormation2)

	local allPartnerNum = 1 + PartnerModel:getPartnerNum()

	if num1 + num2 < allPartnerNum and (num1 < curTeamNum or num2 < curTeamNum) then
		return false
	end

	return true
end

--根据阵型获取上阵了多少个奇侠  多少五灵
function TeamFormationModel:getPartnerNumByFormation(_partnerFormation)
	local partnerNum = 0
	local wulingNum = 0
	for i = 1, 6, 1 do
		local partnerId = _partnerFormation["p"..i].partner.partnerId
		local elementId = _partnerFormation["p"..i].element.elementId
		if tostring(partnerId) ~= "0" then
			partnerNum = partnerNum + 1
		end

		if tostring(elementId) ~= "0" then
			wulingNum = wulingNum + 1
		end
	end
	return partnerNum, wulingNum
end

--判断奇侠是否已上阵  如果是在布阵界面外面 需要判断某个奇侠是不是在某个类型布阵里需要传入systemId
function TeamFormationModel:isPartnerInFormation(_partnerId, systemId)
	local tempFormation = {}
	if systemId then
		tempFormation = self.formations[tostring(systemId)]
	else
		tempFormation = self.tempFormation
	end

	for k,v in pairs(tempFormation.partnerFormation) do
		if tostring(v.partner.partnerId) == tostring(_partnerId) then
			return true
		end
	end

	if tempFormation.partnerFormation2 then
		for k,v in pairs(self.tempFormation.partnerFormation2) do
			if tostring(v.partner.partnerId) == tostring(_partnerId) then
				return true
			end
		end
	end
	return false
end

--引导开启登仙台时 需要调这个方法  进行登仙台的一键布阵
function TeamFormationModel:allOnTeamFormationForPvp()
	self:createTempFormation(FuncTeamFormation.formation.pvp_defend)
	self:allOnFormation({}, FuncTeamFormation.formation.pvp_defend)
	local params = {			
			id = FuncTeamFormation.formation.pvp_defend,
			formation = self:getTempFormation(),
		}  		
	TeamFormationServer:doFormation(params, function ()
			self:saveLocalData(nil, FuncTeamFormation.formation.pvp_defend)
		end)

	self:createTempFormation(FuncTeamFormation.formation.pvp_attack)
	self:allOnFormation({}, FuncTeamFormation.formation.pvp_attack)		
	self:saveLocalData(nil, FuncTeamFormation.formation.pvp_attack)
end

function TeamFormationModel:allOnTeamFormationForEndless()
	self:createTempFormation(FuncTeamFormation.formation.endless)
	self:allOnFormation({}, FuncTeamFormation.formation.endless)		
	self:saveLocalData(nil, FuncTeamFormation.formation.endless)
end

return TeamFormationModel
