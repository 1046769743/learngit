
--[[
autor:gaoshuang
时间：2016.12.12
站前选人
]]



FuncTeamFormation= FuncTeamFormation or {}



--阵容对应的阵容id
FuncTeamFormation.formation = 
{
	pve = 1,			--寻仙问清  预设阵容1

	pvp_attack = 2,		--竞技场攻击阵容
	pvp_defend = 7,		--竞技场防守阵型
	trailPve1 = 3,		--试炼1
	trailPve2 = 4,		--试炼2
	trailPve3 = 5,		--试炼3
	towerPve  = 6,		--爬塔
	pve_elite = 8,		--精英副本
	
	pve_tower = 10,     --锁妖塔布阵
	shareBoss = 12,     --共享副本
	missionBattlePvp = 14, --比武切磋
	guildGve = 15,		--仙盟GVE 
	noPve = 9,			--设阵容2  
	lovePve = 11,		--情缘战斗
	check_lineup = 99, 	--查看阵容功能（2015.4.17目前仅作为展示用）
	crossPeak = 16,     --巅峰竞技场
	wonderLand = 17,    --须臾仙境
	guildBoss = 18,     --仙盟副本
	endless = 19,       --无底深渊
	missionBattleMonkey = 24, --六界轶事猴子
	missionBattleFengYao = 25, --六界轶事琼华封妖
	missionBattleTianLei = 26, --六界轶事天雷绝杀
	guildBossGve = 28,    --共闯秘境多人布阵
	guildExplorePve = 30, --仙盟探索布阵  血量需要继承（普通，矿脉，大型建筑）
	guildExploreElite = 31, --仙盟探索布阵  血量不继承（精英）
}



FuncTeamFormation.powerChange = {
	add = 10,
	sub = 11,
}


FuncTeamFormation.btnChange = {
	partner = 1,
	wuxing = 2,
}

FuncTeamFormation.wuxingChange = {
	sub = 1,
	add = 2,
}

FuncTeamFormation.tagType = {
	all = 1,
	attack = 2,
	defend = 3,
	assist = 4,
}

--TODO  得通知策划通过配表配置多语言表
FuncTeamFormation.typeTxt = {
	attack = "攻击",
	defend = "防御",
	assist = "辅助",
	employee = "租赁",
}

FuncTeamFormation.txtColor = {
	red = 1,
	blue = 2,
	green = 3,
}

FuncTeamFormation.showTreasure = {
	treasure = 1,
	attr = 2,
}

FuncTeamFormation.typeForSetPartner1 = {
	"p4", "p6", "p5", "p1", "p3", "p2"
}

FuncTeamFormation.typeForSetPartner2 = {
	"p1", "p2", "p3", "p4", "p5", "p6"
}

FuncTeamFormation.typeForSetPartner3 = {
	"p3", "p5", "p1", "p2", "p6", "p4"
}
--source对应的配置表
local partnerCfg
local enemyInfoCfg
local enemyTreaCfg
local wuxingCfg
local enemyLevelInfo

function FuncTeamFormation.init()
	if wuxingCfg == nil then
		wuxingCfg = Tool:configRequire("spirit.FiveSpirit")
	end
	FuncTeamFormation.chkRequire()
end


function FuncTeamFormation.chkRequire(  )
	if partnerCfg == nil then
		partnerCfg = Tool:configRequire("partner.Partner")
	end

	if enemyInfoCfg == nil then
		enemyInfoCfg = Tool:configRequire("level.EnemyInfo")
	end
	if enemyTreaCfg == nil then
		enemyTreaCfg = Tool:configRequire("level.EnemyTreasure")
	end

	if chatCfg == nil then
		chatCfg = Tool:configRequire("format.Chat")
	end

	if enemyLevelInfo == nil then
		enemyLevelInfo = Tool:configRequire("level.Level")
	end
end





--[[
获取多人布阵中的快捷聊天功能
]]
function FuncTeamFormation.getQuickChatList()
	
	echo("获取多人布阵中的快捷聊天功能")
	FuncTeamFormation.chkRequire()
	
	local data = table.values(chatCfg)
	table.sort( data, function(a,b)
		if tonumber(a.id)<tonumber(b.id) then
			return true
		else
			return false
		end
	end )

	--将多语言文字取出来
	for k,v in pairs(data) do
		v.des = GameConfig.getLanguage(v.tid)
	end
	return data
end


--[[
根据id获取预设聊天的内容
]]
function FuncTeamFormation.getQuickChatContent(id)
	local data = chatCfg
	
	local data = chatCfg[tostring(id)]

	if data then
		return GameConfig.getLanguage(data.tid)
	else
		echoError("不存在的快捷信息---,id",id)
	end
end








--[[
根据玩家id获取spineName  isSelf  字段必须传 用于判断是否是玩家自己
]]

function FuncTeamFormation.getSpineNameByHeroId(heroId, isSelf, skin)
	FuncTeamFormation.chkRequire()
	local sourceId
	if LoginControler:isLogin() then
		if tostring(heroId) == "1" then
			sourceId = GarmentModel:getGarmentSourcrId()
		else
			-- sourceId = PartnerSkinModel:getSkinSourceId(heroId)

			--先判断是机器人还是谁
			if partnerCfg[tostring(heroId)] ~= nil then
				--echo("===============")
				if isSelf then
					sourceId = PartnerSkinModel:getSkinSourceId(heroId)
				else
					if skin and skin ~= "" then
						sourceId = FuncPartnerSkin.getPartnerSkinSourceId(skin)
					else
						sourceId = FuncPartner.getSourceId(heroId)
					end
				end
				
				
			else
				local sid = enemyInfoCfg[tostring(heroId)]["baseTrea"]
				echo("heroId:",heroId, "sourceid:"..sid,"--------------------这是机器人")
				--dump(enemyTreaCfg[tostring(sid)])
				sourceId = enemyTreaCfg[tostring(sid)]["source"]
			end


		end




		return FuncTeamFormation.getSpineName( sourceId ), sourceId
	end


	
	
	if tostring(heroId) == "1" then
		if UserModel:sex() == 2 then
			sourceId = "2"
		else
			sourceId = "1"	
		end
		
	else
		if partnerCfg[tostring(heroId)] ~= nil then
			--echo("===============")
			sourceId = partnerCfg[tostring(heroId)].sourceld
		else
			local sid = enemyInfoCfg[tostring(heroId)]["baseTrea"]
			--echo("sid"..sid,"--------------------")
			--dump(enemyTreaCfg[tostring(sid)])
			sourceId = enemyTreaCfg[tostring(sid)]["source"]
		end
	end
	return FuncTeamFormation.getSpineName( sourceId ), sourceId
end


function FuncTeamFormation.getSpineNameByHeroId2( herodata )
	--echo("heroId",heroId,"========")
	local heroId = herodata.partnerId or herodata.id
	FuncTeamFormation.chkRequire()
	local sourceId
	if tostring(heroId) == "1" then
		-- if UserModel:sex() == 2 then
		-- 	sourceId = "2"
		-- else
		-- 	sourceId = "1"	
		-- end
		if herodata.rid == UserModel:rid() then
			sourceId = UserModel:sex() --FuncChar.getCharSex(TeamFormationMultiModel.mainHero or "101")
		else
			sourceId = FuncChar.getCharSex(TeamFormationMultiModel.otheravatar or "101")
		end	
	else
		if partnerCfg[tostring(heroId)] ~= nil then
			--echo("===============")
			sourceId = partnerCfg[tostring(heroId)].sourceld
		else
			local sid = enemyInfoCfg[tostring(heroId)]["baseTrea"]
			--echo("sid"..sid,"--------------------")
			--dump(enemyTreaCfg[tostring(sid)])
			sourceId = enemyTreaCfg[tostring(sid)]["source"]
		end
	end
	return FuncTeamFormation.getSpineName( sourceId )
end




--[[
获取SpineName
]]
function FuncTeamFormation.getSpineName( sourceId )
	--echo("sourceId",sourceId,"====================")
	FuncTeamFormation.chkRequire(  )
	local spine =  FuncTreasure.getSourceSpine(sourceId,1)
	if spine == nil then
	 	spine= FuncTreasure.getSourceSpine(sourceId,2)
	end 

	return spine
end


--[[
检查某个站位是否开启
]]
function FuncTeamFormation.checkPosIsOpen( pIdx )
	local val = FuncDataSetting.getDataVector("FormatPositionOpen")
	-- dump(val)
	-- echo(pIdx)
	if val["p"..pIdx] <= UserModel:level() then
		return true,val["p"..pIdx]
	end
	return false,val["p"..pIdx]
end

--[[
获取属性对应的攻击  防御  描述
]]
function FuncTeamFormation.getPropTxt(ty)
	if ty == 1 then
		return FuncTeamFormation.typeTxt.attack
	elseif  ty == 2 then
		return FuncTeamFormation.typeTxt.defend
	elseif ty == 3  then
		return FuncTeamFormation.typeTxt.assist
	end
	return FuncTeamFormation.typeTxt.employee
end


--[[
获取台子的属性
]]
function FuncTeamFormation.getPropByTaiZi(index)
	--return math.floor((index-1)/2)+1
	-- red = 1, blue = 2, green = 3
	if index>=1 and index<=2 then
		return FuncTeamFormation.txtColor.blue
	elseif index>=3 and index<=4 then
		return FuncTeamFormation.txtColor.red
	elseif index>=5 and index<=6 then
		return FuncTeamFormation.txtColor.green
	end
	return FuncTeamFormation.txtColor.red
end

--检查开启了几个台子
function FuncTeamFormation.checkPosIsOpenNum()
	local val = FuncDataSetting.getDataVector("FormatPositionOpen")
	local posNum = 0
	for v=1,6 do
		if val["p"..v] <= UserModel:level() then
			posNum = posNum+1
		end
	end
	return posNum
end

--特殊布阵数
function FuncTeamFormation.checkPoshasOpenNum(level)
	local val = FuncDataSetting.getDataVector("TeaminfoOpen")
	-- local tempNum = 17
	local nowNum = 0
	local maxNum = nil
	for k,v in pairs(val) do
		if tonumber(level) >= tonumber(k) then
			if not maxNum then
				maxNum = tonumber(v)
			elseif maxNum < tonumber(v) then
				maxNum = tonumber(v)
			end			
		end
		-- if level >= tonumber(k) then
		-- 	-- if tonumber(tempNum) < tonumber(k) then
		-- 	-- 	tempNum = k 
		-- 	-- end
		-- else
		-- 	if tonumber(tempNum) > tonumber(k) then
		-- 		tempNum = k 
		-- 	end
		-- end
	end
	nowNum = maxNum
	-- local nowNum = val[tostring(tempNum)]
	return nowNum
end

function FuncTeamFormation.checkWuXingPosOpen(level)
	local val = FuncDataSetting.getDataVector("FiveSpiritOpen")
	local tempNum = 0
	for k,v in pairs(val) do
		if level >= tonumber(k) then
			if tonumber(tempNum) < tonumber(k) then
				tempNum = k 
			end	
		end
	end
	local nowNum = 0 
	if tonumber(tempNum) > 0 then
		nowNum = val[tostring(tempNum)]
	end	
	return nowNum,tempNum
end

function FuncTeamFormation.checkMulitWuXingPosOpen(level)
	local val = FuncDataSetting.getDataVector("FiveSpiritManyPeopleOpen")
	local tempNum = 0
	for k,v in pairs(val) do
		if level >= tonumber(k) then
			if tonumber(tempNum) < tonumber(k) then
				tempNum = k 
			end	
		end
	end
	local nowNum = 0 
	if tonumber(tempNum) > 0 then
		nowNum = val[tostring(tempNum)]
	end	
	return nowNum,tempNum
end

function FuncTeamFormation.getNextLevelWuLing(level)
	local val = FuncDataSetting.getDataVector("FiveSpiritOpen")
	local nextLevel = nil
	for k,v in pairs(val) do
		if tonumber(level) < tonumber(k) then
			local tempNum = k
			if not nextLevel then
				nextLevel = tempNum
			elseif tonumber(nextLevel) > tonumber(tempNum) then
				nextLevel = tempNum
			end			
		end
	end
	return nextLevel
end


function FuncTeamFormation.getWuXingData()
	local nowWuXingData = {}
	local emptyWuXing = nil
	for k,v in pairs(wuxingCfg) do
		if tonumber(k)> 0 then
			table.insert(nowWuXingData,v)
		else
			emptyWuXing = v	
		end
	end
	table.sort(nowWuXingData,function(a,b)
		return tonumber(a.id) < tonumber(b.id)
	end)
	-- table.insert(nowWuXingData,emptyWuXing)

	return nowWuXingData
end	

function FuncTeamFormation.getWuXingNum(id,level)
	local wuxingNum = 0
	local wuxingData = wuxingCfg[tostring(id)]
	for k,v in pairs(wuxingData.condition) do
		if level >= v["v"] then
			if wuxingNum <= v["t"] then
				wuxingNum = v["t"]
			end	
		end
	end
	return wuxingNum
end

function FuncTeamFormation.getMultiWuXingNum(id,level)
	local wuxingNum = 0
	local wuxingData = wuxingCfg[tostring(id)]
	for k,v in pairs(wuxingData.conditionPeople) do
		
		if level >= v["v"] then
		    if wuxingNum <= v["t"] then
				wuxingNum = v["t"]
			end	
		end
	end
	return wuxingNum
end

function FuncTeamFormation.getWuXingDataById(id)
	local tempWuXingData = wuxingCfg[tostring(id)]
	return tempWuXingData
end

function FuncTeamFormation.getMulitNextLevelWuLing(level)
	local val = FuncDataSetting.getDataVector("FiveSpiritManyPeopleOpen")
	local nextLevel = nil
	for k,v in pairs(val) do
		if tonumber(level) < tonumber(k) then
			local tempNum = k
			if not nextLevel then
				nextLevel = tempNum
			elseif tonumber(nextLevel) > tonumber(tempNum) then
				nextLevel = tempNum
			end			
		end
	end
	return nextLevel
end

function FuncTeamFormation.isTowerEmployeeById(_npcs, _id)
	-- dump(_npcs, "\n\n_npcs===")
	for k,v in pairs(_npcs) do
		if v.id == tonumber(_id) and v.teamFlag and v.teamFlag == 1 then
			return true
		end
	end
	return false
end

function FuncTeamFormation.partnerSortRule(a, b)
    if a.id == b.id then
        return false
    end

    if a.order > b.order then
    	return true
    elseif a.order < b.order then
    	return false
    end

    --战力
    if a.tempAbility > b.tempAbility then
        return true
    else
        return false
    end

    --星级
    if a.star > b.star then
        return true
    elseif a.star < b.star then
        return false
    end

    --品质
    if a.quality > b.quality then
        return true
    elseif a.quality < b.quality  then
        return false
    end
    
    --等级
    if a.level > b.level then
        return true
    elseif a.level < b.level then
        return false
    end 

    return false  
end

function FuncTeamFormation.filterPvpFormation(_formation)
	local energy = {}
    local index = 1
    local length = table.length(_formation.energy)
    if length > 0 then
        for i = 1, length, 1 do
            for kk,vv in pairs(_formation.partnerFormation) do
                if tostring(_formation.energy[tostring(i)]) == tostring(vv.partner.partnerId) then
                    energy[tostring(index)] = _formation.energy[tostring(i)]
                    index = index + 1
                end
            end
        end
    end
    return energy
end

--通过五灵id来获取对应升级需要的道具
function FuncTeamFormation.getItemIdByFiveSoul(id)
	for k,v in pairs(wuxingCfg) do
		if tostring(id) == tostring(k) then
			return v.itemId
		end
	end
	return nil
end

--根据五灵道具获取对应升级的五灵属性
function FuncTeamFormation.getFiveSoulByItemId(_itemId)
	for k,v in pairs(wuxingCfg) do
		if tostring(_itemId) == tostring(v.itemId) then
			return k
		end
	end
	return 0
end

function FuncTeamFormation.getLevelDataByLevelId(_levelId)
	local levelData = enemyLevelInfo[tostring(_levelId)]
	if not levelData then
		echoError("\n不存在这个levelId对应的关卡数据，levelId=", _levelId)
	end

	return levelData
end

function FuncTeamFormation.getEnemyDataById(_enemyId)
	local enemyData = enemyInfoCfg[tostring(_enemyId)]
	if not enemyData then
		echoError("\n不存在这个_enemyId对应的怪物数据，_enemyId=", _enemyId)
	end
	return enemyData
end

function FuncTeamFormation.getEnemyTreaDataById(_id)
	return enemyTreaCfg[tostring(_id)]
end

--npcInfo, banPartners为锁妖塔专有参数 因为锁妖塔需要保存血量 奇侠还可能被劫持不可用
function FuncTeamFormation.createFormationNpcs(_type, partnerData, tempAbility, tags, notDisplay, npcInfo, banPartners)
	local npcCfg = FuncPartner.getPartnerById(partnerData.id)
	--如果传入的 ty == 0 则为全部奇侠 否则为指定的npc类型
	if _type == 0 or npcCfg.type == _type then 		
		local temp = {}
		temp.id = partnerData.id
		temp.level = partnerData.level
		temp.exp = partnerData.exp
		temp.position = partnerData.position 
		temp.quality = partnerData.quality 
		temp.skills = partnerData.skills 
		temp.star = partnerData.star
		temp.starPoint = partnerData.starPoint
		temp.type = npcCfg.type 
		temp.icon = npcCfg.icon 
		temp.sourceId = npcCfg.sourceld
		temp.dynamic = npcCfg.dynamic
		temp.order = 0
		temp.tempAbility = tempAbility
		--如果有推荐标签需要优先显示 但一键布阵时依然按之前的排序规则上阵 所以一键布阵时notDisplay需要传true
		if tags and not notDisplay then
			local partner_tag = npcCfg.tag
			for ii,vv in ipairs(tags) do
				if partner_tag and tostring(partner_tag[tonumber(vv[1])]) == tostring(vv[2]) then
					temp.order = 1
					temp.recommend = true
					break
				end
			end
		end

		--根据锁妖塔的数据添加血量参数  万分比
		if npcInfo then
            temp.HpPercent = npcInfo.hpPercent or 10000
            temp.fury = npcInfo.energyPercent or 0
        else
            temp.HpPercent =  10000
            temp.fury =  0
        end 

        --如果存在被劫持或者不可用的奇侠 需要添加hasBan参数
        if banPartners then
        	for kk,vv in pairs(banPartners) do
	            if tostring(partnerData.id) == tostring(kk) then
	                temp.hasBan = 1
	                break
	            end
	        end
        end
        
        temp.elements = npcCfg.elements 

		return temp
	end
end
