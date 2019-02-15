--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--

local levelCfg = require("level.Level")
local mappingCfg = require("mission.MissionMapping")
local energyRuleCfg = require("level.EnergyRules")
local parnterShowCfg = require("level.ParnterShow")
local RefreshCfg = require("level.RefreshEnemy")
local BattleBuffCfg = require("level.BattleBuff")
local CountLevelCfg = require("level.CountLevel")

ObjectLevel = class("ObjectLevel")
local Fight = Fight
-- local BattleControler = BattleControler

ObjectLevel.staticData = nil

--怪物配置数据
ObjectLevel._killSpecInfo = nil -- 胜利条件：消灭特殊怪物
ObjectLevel._winType = nil 	-- 胜利的条件
ObjectLevel._lastTime = nil -- 胜利条件：坚持的时间
ObjectLevel._tutorial = nil -- 战斗新手引导

ObjectLevel.cacheObjectHeroArr = nil 	--缓存的objectHero数组
ObjectLevel.cacheArtifact = nil -- 缓存神器需要加载的相关资源

ObjectLevel.campData1 = nil 		--阵营1的基础数据
ObjectLevel.waveDatas = nil 			--对方波数数据

ObjectLevel.maxWaves =  1 			--最大波数
ObjectLevel.dropArr = nil 			--战斗中掉落
ObjectLevel.gameMode = nil 			--游戏模式
ObjectLevel.randomSeed = nil 		--随机种子
ObjectLevel.buffInfo = nil 		--额外buff 信息 针对爬塔

ObjectLevel.aiOrderArr = nil 		--ai出手顺序数组 
ObjectLevel.monsterCount = 0 		--锁妖塔当前关卡总怪物(获取怪物总血量百分比用，在GameControlerEx中赋值)
-- 战斗背景音乐
ObjectLevel.bgMusic = nil

ObjectLevel.elementFormation = nil -- 五行阵位信息

-- 站前板子对话信息
ObjectLevel.startRoundPlot = nil
-- 巅峰竞技场后补伙伴信息
ObjectLevel.benchData = nil 

-- 大招出手顺序
ObjectLevel.maxSkillAiOrder = nil

function ObjectLevel:ctor( hid,gameMode,battleInfo)
	hid = tostring(hid)
	self.hid = hid
	self.staticData = levelCfg[hid]	
	--总战力
	self.totalAbility = 0
	-- dump(levelCfg[hid],"@@@ 战斗关卡数据 @@@")
	if not self.staticData then
		echoError("找策划,没有这个关卡id数据,暂时用10101代替,hid:",hid)
		hid = "10101"
		self.hid = hid
		self.staticData = levelCfg[hid]	
	end
	self.gameMode = gameMode
	self.waveDatas = {}
	self.cacheObjectHeroArr = {}
	self.cacheArtifact = {}
	self.bgMusic = {}
	self.benchData = {{},{}}--巅峰竞技场根据team存储的

	self.enterType = {}
	self.maxWaves = table.nums(self.staticData)

	for wave=1,2 do
		local waveData = self.staticData[tostring(wave)]
		self.enterType[wave] = waveData and waveData.enter or 0
	end

	self.battleInfo = battleInfo
	self.buffInfo = nil
	self.monsterCount = 0
	self.__artfactInfo = {}
	self.maxSkillAiOrder = {}
	-- 初始化结构
	self:initElementInfo()
	self:getLevelInfo()
	self:checkEnemy()
	--存储刷新怪物
	self:initRefreshEnemy()
	self:initAiOrder()
	self:checkEnergy()
	self:initSomethingInfo()
	self:initRoundStartPlotInfo()
	-- 缓存战中换装和换法宝对应的资源
	self:cacheBattleChangeRes()
	self:initEnergyRuleCfg()
	-- self:initElementInfo()
	-- 设置巅峰竞技场阵营
	self:setCrossPeakInfo()

	-- 初始化神力相关数据
	self:initSpiritPowerArr()

	-- 去重
	self.cacheArtifact = array.toSet(self.cacheArtifact)

	for k,v in pairs(self.campData1) do
		self.totalAbility = self.totalAbility + (v.ability or 10)
	end

	echo("关卡id:",self.hid,"_最大波数:",self.maxWaves)
end
-- 初始化板子对话逻辑
function ObjectLevel:initRoundStartPlotInfo()
	local dialog = self.staticData["1"].dialog
	self.startRoundPlot = {}
	-- 对信息做一下解析

	for wave=1,self.maxWaves do
		local waveData = self.staticData[tostring(wave)]
		local dialog = waveData.dialog
		if dialog then
			for _,v in ipairs(dialog) do
				local info = string.split(v, "#")
				local key = string.format("%s_%s",wave,info[1])
				local steps = info[2]
				if key and steps then
					steps = string.split(steps, "_")

					self.startRoundPlot[key] = steps
				end
			end
		end
	end
end

-- 初始化神器给予的光环、换灵、初始怒气 和五行阵型中的五灵相关数据
function ObjectLevel:initSomethingInfo()
	-- 先去配置表中读取我方五行阵的数据
	--[[
	我方不考虑配表信息
	if self.staticData["1"].elementsFriendPosition then
		for pos,element in ipairs(self.staticData["1"].elementsFriendPosition) do
			self.elementFormation.camp1[pos] = {element = element}
		end
	end
	]]
	--神器相关数据 energyInfo:怒气 artfact:光环 huanling:换灵数据
	-- {[1]={energyInfo={},artfact = {}}}

	for i,userInfo in pairs(self.battleInfo.battleUsers) do
		local camp = userInfo.team or toint(i)
		if userInfo.fivesouls and userInfo.formation then
			local fiveSouls = FuncWuLing.getWuLingZhenForBattle(userInfo.fivesouls)
			-- 使用玩家的五灵数据
			for i=1,6 do
				-- 我的阵容五行数据
				local fId = tonumber(userInfo.formation.partnerFormation["p"..i].element.elementId)
				-- 不为0证明已经开启
				if fId ~= 0 then
					-- 当有布阵信息没有养成信息的时候，可能是没有进行过养成，还没有初始化，此时默认给1级
					local soulInfo = table.copy(fiveSouls[fId] or FuncWuLing.getWuLingChange(fId,1))
					if camp == 1 then
						self.elementFormation["camp"..camp][i] = soulInfo
					else
						-- 走到这里是竞技场的情况直接初始化到第一波的信息里
						self.elementFormation["camp"..camp][1][i] = soulInfo
					end
				end
			end
		end
		-- 神器处理、多人未做处理
		if self.gameMode == Fight.gameMode_pve or self.gameMode == Fight.gameMode_pvp  then
			if not self.__artfactInfo[camp] then
				self.__artfactInfo[camp] = {}
			end
			local campArr = self.__artfactInfo[camp]
			--[[
				-- 测试用数据
				userInfo.cimeliaGroups = {}
				userInfo.cimeliaGroups["402"] = {
					cimelias = {

					},
					id = "402",
					quality = 1,
				}
				userInfo.cimeliaGroups["501"] = {
					cimelias = {

					},
					id = "501",
					quality = 1,
				}
			]]
			local atArr = FuncArtifact.getArtifactDataForBattle(userInfo)
			for k,v in pairs(atArr) do
				-- artifact_kind1、artifact_kind2、artifact_kind3等的光环未做处理
				if v.kind == Fight.artifact_kind4 then
					-- 怒气相关
					campArr.energyInfo = v.data
				elseif v.kind == Fight.artifact_kind5 then
					-- 换灵相关数值
					campArr.huanling = v.data
				elseif v.kind == Fight.artifact_kind3 then
					-- 带有技能的类型
					if not campArr.skills then campArr.skills = {} end

					table.insert(campArr.skills, v.data)
				end
			end

			local artRes = FuncArtifact.getArtifactResForBattle(userInfo)
			for id,res in pairs(artRes) do
				for _,name in ipairs(res) do
					table.insert(self.cacheArtifact, name)
				end
			end
		end
	end

	-- 去重
	-- self.cacheArtifact = array.toSet(self.cacheArtifact)

	-- 测试的五灵
	-- if not LoginControler:isLogin() then
	-- 	local fiveSoul = {}
	--     for i=1,5 do
	--         local data = {}
	--         data.element = i -- 五行属性
	--         data.exLv = 1 -- 技能强化等级，便于扩展
	--         data.exDef = 100 -- 属性防御力，便于扩展

	--         fiveSoul[i] = data
	--     end
	-- 	self.__artfactInfo[1].huanling =fiveSoul
	-- end
	-- dump(self.__artfactInfo,"self.__artfactInfo")
	-- echoError("看看五灵的信息")
	-- dump(self.elementFormation, "self.elementFormation")
end

-- 初始化五行阵位相关信息
--[[
	{
		camp1 = {
			pos = {
				element = Fight.element_non,
    			exLv = Fight.element_ex_lv, -- 技能强化等级，便于扩展
    			exDef = Fight.element_reduce_rate, -- 属性防御力，便于扩展
			}
		}
		camp2 = {
			wave = {
				pos = {
				element = Fight.element_non,
	    			exLv = Fight.element_ex_lv, -- 技能强化等级，便于扩展
	    			exDef = Fight.element_reduce_rate, -- 属性防御力，便于扩展
				}
			}
		}
	}
]]
-- 测试数据
local TEST_ELEMENT_1 = {
	[1] = {
		element = Fight.element_non,
	},
	[2] = {
		element = Fight.element_non,
	},
	[3] = {
		element = Fight.element_non,
	},
	[4] = {
		element = Fight.element_non,
	},
	[5] = {
		element = Fight.element_non,
	},
	[6] = {
		element = Fight.element_non,
	},
}
-- 初始化五行结构
function ObjectLevel:initElementInfo()
	-- 初始化基础结构
	self.elementFormation = {
		camp1 = {},
		camp2 = {},
	} 
	-- 阵营1
	for pos=1,6 do
		self.elementFormation.camp1[pos] = {
			element = Fight.element_non,
			exLv = Fight.element_ex_lv,
			exDef = Fight.element_reduce_rate,
		}
	end
	-- 阵营2（比阵营1多一层）
	self.elementFormation.camp2[1] = {}
	self.elementFormation.camp2[2] = {}

	for pos=1,6 do
		self.elementFormation.camp2[1][pos] = {
			element = Fight.element_non,
			exLv = Fight.element_ex_lv,
			exDef = Fight.element_reduce_rate,
		}
		self.elementFormation.camp2[2][pos] = {
			element = Fight.element_non,
			exLv = Fight.element_ex_lv,
			exDef = Fight.element_reduce_rate,
		}
	end

	-- pve 初始化表里敌人的数据
	-- 玩家数据不考虑表里数据，因为是否要这个功能又不一定了
	if self.gameMode == Fight.gameMode_pve then
		for i=1,self.maxWaves do
			local waveData = self.staticData[tostring(i)]
			local ePosition = waveData.elementsEnemyPosition
			local posDef = waveData.elementsEnemyInfo
			-- self.elementFormation.camp2[i] = {}
			if ePosition then
				for pos,element in ipairs(ePosition) do
					self.elementFormation.camp2[i][pos].element = element
					-- 位置的防御值
					if posDef and posDef[pos] then
						self.elementFormation.camp2[i][pos].exDef = posDef[pos]
					end
				end
			end
		end
	end
end

--初始化出手顺序
function ObjectLevel:initAiOrder(  )
	self.aiOrderArr = {}
	for i=1,self.maxWaves do
		local waveData = self.staticData[tostring(i)]
		if waveData.aiOrder then
			self.aiOrderArr[i] = waveData.aiOrder
			--做一下检查 不允许有重复的顺序 而且不需是 1 2 3 4 5 6 
			local tempArr = {}
			for i,v in ipairs(waveData.aiOrder) do
				if v > 6 or v < 0 then
					echoError("_找策划,关卡出手顺序错误,关卡id:",self.hid)
				end
				if not tempArr[v] then
					tempArr[v] = true
				else
					echoError("_找策划,关卡出手顺序错误,关卡id:",self.hid)
				end
			end

		else
			self.aiOrderArr[i] = {1,2,3,4,5,6}
		end
	end
end

--获取初始怒气
function ObjectLevel:checkEnergy()
	-- 我方初始怒气
	self.__initEnergy = {}
	self.__initEnergy[1] = {}
	-- 敌方初始怒气
	self.__initEnergy[2] = {}

	for i=1,self.maxWaves do
		local waveData = self.staticData[tostring(i)]
		if waveData.initEnergyFriend then
			self.__initEnergy[1][i] = waveData.initEnergyFriend[1]
		end
		if waveData.initEnergyEnemy then
			self.__initEnergy[2][i] = waveData.initEnergyEnemy[1]
		end
		-- 满怒开关，直接给满怒气
		if Fight.debugFullEnergy then
			self.__initEnergy[1][i] = {entire = Fight.maxEntireEnergy,piece = Fight.maxPieceEnergy, rate = Fight.maxP2E_Rate}
			self.__initEnergy[2][i] = {entire = Fight.maxEntireEnergy,piece = Fight.maxPieceEnergy, rate = Fight.maxP2E_Rate}
		end
	end
end

--获取地方出手顺序
function ObjectLevel:getAiOrder( wave )
	return self.aiOrderArr[wave]
end

-- 判定胜利条件
function ObjectLevel:getLevelInfo()
	-- loadingId
	self.__loadType = self.staticData["1"].loadId
	-- 结算类型
	self.__rstType = self.staticData["1"].resultType

	-- 使用法宝的数目
	self.__userTreaNum = self.staticData["1"].useTsrNum
	-- 显示法宝的数目
	self.__showTreaNum = self.staticData["1"].showTsrNum
	-- 星级评价
	self.__starInfo = table.copy(self.staticData["1"].starTime or {})
	-- 关卡的中心点
	self.__midPos = table.copy(self.staticData["1"].midPos or {1000,750+300 , 750 + 600})

	-- self.__midPos = { 1000,750+300 , 750 + 600	}

	self.__mapId = self.staticData["1"].map

	local expLr = self.staticData["1"].dynamicLevelRevise
	if expLr and expLr == 1 then
		local uInfo = self.battleInfo.battleUsers[1]
		if uInfo then
			local a = 1
			local bLabel = BattleControler:getBattleLabel()
			if bLabel == GameVars.battleLabels.exploreElite or
				bLabel == GameVars.battleLabels.exploreBuild then
				a = self.battleInfo.battleParams.guildAbility
			elseif bLabel == GameVars.battleLabels.exploreMonster or 
				bLabel == GameVars.battleLabels.exploreMine then
				a = uInfo.abilityNew.maxFormationTotal or 1
			end
			local tmpRevise = FuncGuildExplore.getLevelRevise(a,uInfo.level)
			echo ("新的修正系数====",tmpRevise)
			local lr = table.copy(self.staticData["1"].levelRevise)
			lr[1] = tmpRevise
			self.__levelRevise = lr
		end
	else
		self.__levelRevise = self.staticData["1"].levelRevise
	end

	-- 胜利判定方式
	self._winType = Fight.levelWin_killAll

	-- 杀死特定的怪物
	local killSpec = clone(self.staticData["1"].killSpec)
	if killSpec then
		self._killSpecInfo = killSpec[1]
		self._winType = Fight.levelWin_killSpec
	end
end
-- 根据波数获取对应的随机的buff
function ObjectLevel:getBattleBuffByRound(round)
	local bBuff = self.staticData["1"].battleBuff
	if bBuff and BattleBuffCfg[tostring(bBuff)] then
		local bBCfg = BattleBuffCfg[tostring(bBuff)]
		if bBCfg[tostring(round)] then
			return table.deepCopy(bBCfg[tostring(round)])
		end
	end
	return nil
end
-- 检查是否有buff刷新
function ObjectLevel:chkIsHaveBattleBuff( ... )
	if self.staticData["1"].battleBuff then
		return true
	end
	return false
end
function ObjectLevel:chkIsWaveRefresh(  )
	local rfAi = self.__refreshAi
	if rfAi and rfAi.type and (rfAi.type == Fight.refresh_wave) then
		return true
	end
	return false
end
-- 根据波数获取显示总血条数目
function ObjectLevel:getPveBossHpInfo(wave)
	if (not wave) or (not self.staticData[tostring(wave)]) then
		return nil
	end
	return self.staticData[tostring(wave)].isTotleHp
end

-- 获取刷怪ai
function ObjectLevel:getRefreshAi( )
	return self.__refreshAi
end
-- 根据刷怪ai初始化刷怪的数据
function ObjectLevel:initRefreshEnemy( )
	self.__refreshAi = {enemyArr = {}}
	local _eArr = self.__refreshAi.enemyArr
	local _addRefreshEnemyInfo = function(v,idx,wave)
		local enemyInfo  =  EnemyInfo.new(v,self.__levelRevise,tlvRevise)
		if wave then
			-- NOTE：这个数组不是连续的
			if not _eArr[wave] then
				_eArr[wave] = {}
			end
			_eArr[wave][idx] = enemyInfo.attr
		else
			_eArr[idx] = enemyInfo.attr
		end
		if not Fight.isDummy  then
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(self.cacheObjectHeroArr, objHero)			--这个为了缓存资源
		end
	end
	local refreshId = self.staticData["1"].refreshAi
	if refreshId and RefreshCfg[refreshId]  then
		local dataCfg = RefreshCfg[refreshId]
		self.__refreshAi.id = dataCfg.refeshid
		self.__refreshAi.type = dataCfg.type
		self.__refreshAi.isLoop = dataCfg.isLoop
		self.__refreshAi.isFinish = dataCfg.isFinish
		local tlvRevise = self:getTowerBattleLevelRevise()
		for k,v in ipairs(dataCfg.enemyArr) do
			if dataCfg.type == Fight.refresh_wave then
				local waveArr = string.split(v,",")
				for kk,vv in pairs(waveArr) do
					if vv and vv ~= "" then
						_addRefreshEnemyInfo(vv,kk,k)
					end
				end
			else
				_addRefreshEnemyInfo(v,k)
			end
		end
	end
end

-- 初始化一个阵形
function ObjectLevel:initOneFormation(partnerFormation, formation,user,camp)
	local posArr = Fight.formation_arr
	local waveData = self.staticData[tostring(1)]
	local isMPve = BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve
	local isMapping = (IS_SISSION_MAPPING and BattleControler:checkIsWorldPVE() )

	local rid  = user.rid or user._id
	for pos,info in pairs(partnerFormation) do
		--必须是满足条件的位置
		local posIndex = table.indexof(posArr, pos)
		if posIndex then
			-- 伙伴id
			local partnerId = info.partner.partnerId
			-- 阵位
			local elementId = info.element.elementId or 0
			-- 是否是雇佣兵 
			local teamFlag = info.partner.teamFlag
			local wNpc = waveData["npc"..posIndex]
			local heroInfo
			-- 用配表里面的映射
			if self.useNpc == 3 then
				if wNpc then
					partnerId = wNpc
					-- 如果是剧情映射、则需要将主角的位置填充在wNpc == 0 的地方
					if toint(partnerId) == 0 then
						heroInfo = self:createEnemyInfo(user.avatar, camp, posIndex, true, user,false, user,formation)
					else
						local enemyData = EnemyInfo.new(partnerId)
						heroInfo = self:createEnemyInfo(partnerId, camp, posIndex, false,nil,false, enemyData,formation)
					end
				end
			else
				-- 是我方的伙伴、并且有值
				if rid == info.partner.rid and partnerId ~= "0" and (self.useNpc ~= 2 or (not wNpc)) then
					-- 主角
					if toint(partnerId) == 1 then
						if isMPve or isMapping then
							-- 获取法宝id
							local treasureId = "0"
							if formation.treasureFormation then
								treasureId = formation.treasureFormation["p1"]
							end
							heroInfo = self:getMappingHeroInfo(user, camp, posIndex,formation,nil)
							if treasureId ~= "0" then
								local battleTrsId = FuncTreasureNew.getBattleTreasureId(treasureId,user.avatar)
								heroInfo:resetTreasure(battleTrsId)
							end
						else
							heroInfo = self:createEnemyInfo(user.avatar, camp, posIndex, true, user,false, user,formation)
						end
					elseif toint(partnerId) ~= 0 then
						if teamFlag then
							-- 雇佣兵
							if teamFlag == Fight.teamFlag_robot then
								heroInfo = self:createEnemyInfo(partnerId, camp, posIndex, false,nil,false, user,formation,Fight.teamFlag_robot)
							elseif teamFlag == Fight.teamFlag_user then
								-- TODO:真实玩家数据未做
							end
						else
							if isMPve or isMapping then
								heroInfo = self:getMappingHeroInfo(nil, camp, posIndex,formation,partnerId,skinId)
								
								local skinId
								if user.partners and user.partners[tostring(partnerId)] then
									skinId = user.partners[tostring(partnerId)].skin
								end
								if user.partnerSkins and user.partnerSkins[tostring(partnerId)] then
									skinId = user.partnerSkins[tostring(partnerId)]
								end
								-- 检查伙伴是否有时装
						        if skinId and skinId ~= "" then
						        	local skinData = FuncPartnerSkin.getPartnerSkinById(skinId)
						        	heroInfo:resetTreasure(skinData.treasureId,Fight.treaType_base)
						        	heroInfo.attr.garmentId = skinId
						        	heroInfo.attr.partnerId = partnerId
						        end
							else
								--如果是伙伴或者npc,判断伙伴数据库里是否有这个id
								local staticData = FuncPartner.getPartnerById(partnerId)
								if not staticData then
									heroInfo = self:createEnemyInfo(partnerId, camp, posIndex, false,nil,false, user,formation)  --EnemyInfo.new(v)
								else
									local heroData = user.partners[tostring(partnerId)]
									if not heroData then
										echoError("这个阵容里没有对应的伙伴数据:",partnerId)
									else
										heroInfo = self:createEnemyInfo(partnerId, camp, posIndex, false, heroData,false, user,formation) 
									end
								end
							end
						end
					end
				end
			end
			
			--如果伙伴数据有了
			if heroInfo then
				
				local exArr = {
					rid =heroInfo.hid.."_"..posIndex.."_"..camp,--暂定第一个人是主角
					characterRid = rid,--记录 每个英雄属于哪个伙伴
					teamFlag = teamFlag,--雇佣兵处理
				}
				heroInfo:setExAttr(exArr)

				if not Fight.isDummy  then
					local objHero = ObjectHero.new(heroInfo.hid,heroInfo.attr)
					table.insert(self.cacheObjectHeroArr,objHero )
				end
				
				
				--如果是阵营2 那么存到campDatas里面去
				if camp == 2 then
					self:insertOneWaveDataAttr(1,heroInfo.attr)
				else
					table.insert(self.campData1, heroInfo.attr)
				end
			end
			--[[
			不在这里处理了，在后面统一处理了
			if rid == info.element.rid then
				local camp = user.team or toint(ii)
				if camp == 2 then
					-- 默认放在第一波
					self.elementFormation["camp" .. camp][1][posIndex].element = tonumber(elementId)
				else
					self.elementFormation["camp" .. camp][posIndex].element = tonumber(elementId)
				end
			end
			]]
		end
	end
end

-- ###############仙界对决拓展-------start------------
-- 初始化仙界对决数据
function ObjectLevel:initCrossPeakData( )
	-- 仙界对决额外信息：最高段位、主角性别、各阵营的战前上阵次数、战前当前上人阵营、rid
	self._crosspeakData = {
		avatar={[Fight.camp_1]="101",[Fight.camp_2]="101"},
		seg=1,
		upNum={[Fight.camp_1]=0,[Fight.camp_2]=0},
		changeCamp = nil,
		rid = {[Fight.camp_1]="1",[Fight.camp_2]="1"},
		cp = {},
	}
	self._bpData = {[Fight.camp_1]={},[Fight.camp_2] ={}}
	self._normalData = {[Fight.camp_1]={},[Fight.camp_2] ={}} --初始阵营数据(自选卡玩法一开始上阵的奇侠数据)
end
-- 加载主角资源
function ObjectLevel:loadCharacterRes(user )
	--初始化的时候先加载主角的资源，然后最后选择的时候替换其法宝
	local mId,seg,avatar
	if user.userBattleType == Fight.battle_type_robot then
		mId = user.rid or user._id
		local robotData = FuncCrosspeak.getRobotDataById(mId)
		mId = robotData.charInfo
		seg = FuncCrosspeak.getCurrentSegment(robotData.score)
		avatar = robotData.avatar
	else
		seg = FuncCrosspeak.getCurrentSegment(user.crossPeak.score)
		if user.userExt and user.userExt.garmentId and user.userExt.garmentId ~= "" then
			mId = user.avatar .."_"..seg.."_"..user.userExt.garmentId
		else
			mId = user.avatar .."_"..seg
		end
		avatar = user.avatar
	end
	self._crosspeakData.rid[user.team] = user.rid or user._id
	self._crosspeakData.avatar[user.team]= avatar
	if user.crossPeak then
		self._crosspeakData.cp[user.team] = table.deepCopy(user.crossPeak)
	end
	if self._crosspeakData.seg < tonumber(seg) then
		self._crosspeakData.seg = tonumber(seg)
	end
	local hero = self:createOneHero(user.team,mId,true,false)
	return hero
end
-- 自选卡模式
function ObjectLevel:initNormalModeData( )
	local _addPickUpHero = function(partnerId,camp,posIndex,isObstacle)
		local hero = self:getBechHeroInfo(partnerId,camp,posIndex,isObstacle)
		self:updateCrossPeakUpData(camp,partnerId,Fight.change_up)
		table.insert(self._normalData[camp],hero.attr)
	end
	local posArr = Fight.formation_arr
	for k,u in pairs(self.battleInfo.battleUsers) do
		local camp = u.team
		if u.userBattleType == Fight.battle_type_robot then
			-- 如果是仙人掌模式，机器人需要加一个仙人掌
			local posCount = 1 --主角上2号位
			if self:getCrosspeakPlayType() == Fight.crosspeak_obstacle then
				local posIndex,monsterId = FuncDataSetting.getCrossPeakObstaclePlay()
				_addPickUpHero(monsterId,camp,posIndex,true)
				posCount = posCount + 1
			end
			local rData = FuncCrosspeak.getRobotData(u.rid)
			self:updateCrossPeakTreasureData(camp,rData.selfTreasure)
			-- 加载主角数据(放里面是因为机器人需要换法宝)
			self:loadCharacterRes(u)

			-- 加载机器人阵型(主角+2上阵奇侠)
			_addPickUpHero("1",camp,posCount)
			posCount = posCount + 1

			if rData.selfPartner  then
				for k,v in pairs(rData.selfPartner) do
					self:createOneHero(camp,v,false,false)
					_addPickUpHero(v,camp,posCount)
					posCount = posCount + 1
				end
			end
			-- 加载机器人替补阵容
			if rData.benchPartner  then
				for k,v in pairs(rData.benchPartner) do
					self:createOneHero(camp,v,false,false)
				end
			end
		else
			local formation = u.formation
			-- 更新法宝
			self:updateCrossPeakTreasureData(camp,formation.treasureFormation.p1)
			-- 加载主角数据
			self:loadCharacterRes(u)
			for pos,info in pairs(formation.partnerFormation) do
				local posIndex = table.indexof(posArr, pos)
				local partnerId = info.partner.partnerId
				if partnerId ~= "0" then
					-- 仙人掌
					if info.partner.teamFlag then
						_addPickUpHero(partnerId,camp,posIndex,true)
					else
						if partnerId == "1" then
							_addPickUpHero(partnerId,camp,posIndex)
						else
							-- 加载角色资源
							local m = FuncCrosspeak.getPartnerMappingByPartnerId(partnerId,self._crosspeakData.seg)
							self:createOneHero(camp,m.partnerTemplateId,false,false)
							_addPickUpHero(m.partnerTemplateId,camp,posIndex)
						end
					end
				end
			end
			-- 替补阵容
			for _,v in pairs(formation.bench) do
				if v ~= "1" then --主角的资源已经加载过了，
					local m = FuncCrosspeak.getPartnerMappingByPartnerId(v,self._crosspeakData.seg)
					self:createOneHero(camp,m.partnerTemplateId,false,false)
				end
			end
		end
	end
end
-- 获取自选卡模式上阵奇侠数据
function ObjectLevel:getCrossPeakNormalModeData( )
	return self._normalData
end
-- 初始化仙界对决选角
function ObjectLevel:initSelectCardData( )
	for k,u in pairs(self.battleInfo.battleUsers) do
		self:loadCharacterRes(u)
	end
	-- 检查卡牌中是否有皮肤(需要检查2方都没有时装)
	for i=1,2 do
		local campArr = self:getCartListByCamp(i)
		for k,v in pairs(campArr) do
			if v.cardType == Fight.battle_card_hero then
				local skinId
				for j=1,2 do
					skinId = self:getPartnerSkinId(j,v.cardId)
					if skinId and skinId ~= ""  then
						-- echoError ("youpifu===",i,j,v.cardId)
						break
					end
				end
				if not skinId or skinId == ""  then
					self:createOneHero(nil,v.cardId,false,false)
				else
					self:createOneHero(nil,v.cardId,false,false,true)
					-- 有时装，不加载art、
					-- echoError ("======",j,v.cardId)
				end
			end
		end
	end
end
function ObjectLevel:checkCrossPeakPlayType( )
	-- 如果是仙人掌模式，需要加载仙人掌的缓存数据
	if self:getCrosspeakPlayType() == Fight.crosspeak_obstacle then
		local posIndex,monsterId = FuncDataSetting.getCrossPeakObstaclePlay()
		local hero = EnemyInfo.new(tostring(monsterId))
		local objHero = ObjectHero.new(tostring(monsterId),hero.attr)
		table.insert(self.cacheObjectHeroArr, objHero)
	end
end
-- 仙界对决获取是否有对应的伙伴
function ObjectLevel:getCrossPeakPartnerById(parnterId,camp)
	for k,u in pairs(self.battleInfo.battleUsers) do
		if u.team == camp and u.partners and u.partners[tostring(parnterId)] then
			return u.partners[tostring(parnterId)]
		end
	end
	return nil
end
-- 获取仙界对决额外数据
function ObjectLevel:getCrossPeakOtherData( )
	return self._crosspeakData
end
-- 每有人选完人，更新战前上阵阵营
function ObjectLevel:updateCrossPeakChangeCamp(camp)
	self._crosspeakData.changeCamp = camp
	-- 更新战前上阵次数
	self._crosspeakData.upNum[camp] = self._crosspeakData.upNum[camp] + 1
end
-- 初始化仙界对决映射的玩家数据
function ObjectLevel:createCrossPeakEnemyInfo(camp,cardId,isChar)
	local enemyInfo
	local mapping = FuncCrosspeak.getPartnerMapping(cardId)
	--映射等级、阶级
	local exArr = {star = mapping.star,quality = mapping.quality}
	if isChar then
		local hid = mapping.partnerId
		enemyInfo = EnemyInfo.new(hid)
		exArr.isCharacter = true
		local tData = self:getCrossPeakTreasure()
		-- 有法宝则重置其法宝信息
		if tData then
			local cData = self._crosspeakData
			local tId = FuncCrosspeak.getTreasureMapping(cData.seg,tData[camp],cData.avatar[camp])
			local tmpArr = FuncCrosspeak.getTreasureMappingExtAttr(cData.seg,tData[camp])
			enemyInfo:resetTreasure(tId) --主角重置其法宝信息
			-- 更新法宝修改后对映射主角值的变化
			for k,v in pairs(tmpArr) do
				exArr[k] = v
			end
		end	
	else
		enemyInfo = EnemyInfo.new(cardId)
	end
	enemyInfo:setExAttr(exArr) --额外属性值修改
	if camp then
		if not isChar then
			-- 处理伙伴时装
			local skinId = self:getPartnerSkinId(camp,cardId)
			-- 检查伙伴是否有时装
	        if skinId and skinId ~= "" then
	        	local skinData =FuncPartnerSkin.getPartnerSkinById(skinId)
	        	enemyInfo:resetTreasure(skinData.treasureId,Fight.treaType_base)
	        end
		end
	end
	return enemyInfo
end
-- 获取角色时装id
function ObjectLevel:getPartnerSkinId(camp,cardId)
	local mapping = FuncCrosspeak.getPartnerMapping(cardId)
	for k,v in pairs(self.battleInfo.battleUsers) do
		if v.team == camp then
			if v.partners and v.partners[tostring(mapping.partnerId)] then
				return v.partners[tostring(mapping.partnerId)].skin
			end
		end
	end
	return nil
end
-- 初始化一个角色(先处理其为可上阵状态，然后加载资源)
-- isChar:是否是主句 isLoad:是否立即加载资源 ignore:忽略加载立绘
function ObjectLevel:createOneHero(camp,cardId,isChar,isLoad,ignoreCacheArt)
	local mapping = FuncCrosspeak.getPartnerMapping(cardId)
	local enemyInfo = self:createCrossPeakEnemyInfo(camp,cardId,isChar)
	local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
	if isChar then
		objHero.__cardId = "1" --这个用于发送消息用、主角的时候是1
		objHero.__charHid = mapping.partnerId
		objHero.__mappingId = cardId
	else
		objHero.__cardId = cardId --这个用于发送消息用
	end
	objHero.__isUp = Fight.partner_notUp -- 代表没有上阵过
	if camp then
		table.insert(self._bpData[camp],objHero) --显示头像等用、加载资源用
	end
	if not isLoad then
		if not Fight.isDummy then
			objHero.__ignoreCacheArt = ignoreCacheArt
			table.insert(self.cacheObjectHeroArr, objHero)
		end
	end
	return objHero
end
-- 获取仙界对决我方角色
function ObjectLevel:getAllHeroByCamp(camp )
	return self._bpData[camp]
end
-- 根据camp获取对应需要翻牌的伙伴hid
function ObjectLevel:getBPPartnerByCampIndex(camp )
	local campArr = self:getCartListByCamp(camp)
	-- 检查该卡是否已经选过
	local _findHeroIsBP = function(cardId)
		-- 需要检索两个阵营这个伙伴选过没有
		for k,v in pairs(self._bpData) do
			for m,n in pairs(v) do
				if n.__cardId and n.__cardId == cardId then
					return true
				end
			end
		end
		return false
	end
	for i,v in ipairs(campArr) do
		if v.cardType == Fight.battle_card_hero then
			if not _findHeroIsBP(v.cardId) then
				if campArr[i] and campArr[i+1] then
					return {campArr[i],campArr[i+1]}
				end
			end
		end
	end
	return nil
end
-- 根据阵营获取对应的bp数据
function ObjectLevel:getCartListByCamp(camp)
	local cartArr = self.battleInfo.battleParams.selectCardList
	if not cartArr then
		echoError ("没有选的神器数据")
		return {}
	end
	return cartArr["team"..camp]
end
-- 检查是否需要翻神器
function ObjectLevel:getBPTreasureByCampIndex(camp )
	local campArr = self:getCartListByCamp(camp)
	-- 已经有过法宝数据
	if self._bptData then
		return nil
	end
	for i,v in ipairs(campArr) do
		if v.cardType == Fight.battle_card_treasure then
			if campArr[i] and campArr[i+1] then
				return {campArr[i],campArr[i+1]}
			end
		end
	end
	return nil
end
-- 获取神器数据
function ObjectLevel:getCrossPeakTreasure()
	return self._bptData
end
-- 根据阵营获取主角
function ObjectLevel:getCharHero(camp)
	local allArr = self:getAllHeroByCamp(camp)
	for k,v in pairs(allArr) do
		if v.__cardId == "1" then
			return v
		end
	end
end
-- 选完角色后，需要给角色、神器设置阵营
-- 并且分帧加载角色对应资源
function ObjectLevel:updateBPData( info )
	if not info or not info.selectList then
		echoError ("数据格式错误")
		return
	end
	local heroArr = {}
	-- 检查牌是否已经加载过
	local _findByCardId = function(camp,cardId)
		for k,v in pairs(self._bpData[camp]) do
			if v.__cardId == "1" then
				if v.__mappingId == cardId then
					return true
				end
			else
				if v.__cardId == cardId then
					return true
				end
			end
		end
		return false
	end
	for k,v in pairs(info.selectList) do
		if v.cardType == Fight.battle_card_hero then
			if not _findByCardId(v.team,v.cardId) then
				local hero = self:createOneHero(v.team,v.cardId,false,true)
				hero.__selectTeamId = info.team --选的队伍
				table.insert(heroArr,hero)
			end
		else
			self:updateCrossPeakTreasureData(v.team,v.cardId)
			-- 因为主角的法宝重新选择了，所以需要重新new一个ObjectHero 返回然后加载其资源
			local oHro = self:getCharHero(v.team)
			local enemyInfo = self:createCrossPeakEnemyInfo(v.team,oHro.__mappingId,true)
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(heroArr,objHero)
		end
	end
	return heroArr
end
-- 更新仙界对决玩家法宝数据
function ObjectLevel:updateCrossPeakTreasureData(camp,cardId )
	if not self._bptData then
		self._bptData = {}
	end
	self._bptData[camp] = cardId
end
-- 更新仙界对决奇侠上下阵数据
function ObjectLevel:updateCrossPeakUpData(camp,cardId,ctype)
	for k,v in pairs(self._bpData[camp]) do
		if v.__cardId == cardId then
			v.__isUp = ctype
		end
	end
end
-- 获取为上阵奇侠个数
function ObjectLevel:getUnUpPartnerCount(camp)
	local count = 0
	for k,v in pairs(self._bpData[camp]) do
		if v.__isUp == Fight.partner_notUp then
			count = count + 1
		end
	end
	return count
end
-- ###############仙界对决拓展-------end------------
-- 获取对应的HeroAttrInfo 数据
function ObjectLevel:getBechHeroInfo(hid,camp,posIndex,isObstacle)
	local charHero = self:getCharHero(camp)
	local isChar = false
	if hid == "1" then
		isChar = true
		hid = charHero.__mappingId
	end
	local enemyInfo
	if isObstacle then
		-- 仙人掌
		enemyInfo = EnemyInfo.new(hid)
	else
		enemyInfo = self:createCrossPeakEnemyInfo(camp,hid,isChar)
	end
	enemyInfo.attr.posIndex = posIndex
	local oData = self:getCrossPeakOtherData()
	enemyInfo.attr.characterRid = oData.rid[camp]
	enemyInfo.attr.rid = hid.."".."_"..camp
	return enemyInfo
end
--[[
初始化主角的数据
]]
function ObjectLevel:initUserData(  )
	if not self.battleInfo then
		return
	end

	-- dump(self.battleInfo,"___self.battleInfo")

	if tostring(self.hid) == Fight.xvzhangParams.xuzhang then
		return
	end
	if not self.battleInfo.battleUsers then
		echoError("没有战斗的用户数据====")
		return
	end
	for i,userInfo in pairs(self.battleInfo.battleUsers) do
		local camp = userInfo.team or toint(i)
		-- 跑环任务检查是否有雇佣兵、有的话替换我方的奇侠属性
		-- 这种写法其实不好，当能够上相同奇侠时候就有问题了
		if userInfo.userBattleType == Fight.battle_type_robot then
			self:initRobootInfo(userInfo,camp,1)
		else
			local partnerFormation = userInfo.formation.partnerFormation 
			self:initOneFormation(partnerFormation,userInfo.formation,userInfo,camp)
			-- 大招出手顺序，目前只有竞技场有
			self.maxSkillAiOrder[camp] = userInfo.formation.energy
		end
	end
end


--初始化robootInfo  userInfo._id  是排行
function ObjectLevel:initRobootInfo( userInfo,camp ,wave)
	wave = wave or 1
	local robootId = FuncPvp.genRobotRid(userInfo._id)
	local robootData = FuncPvp.getRobotById(robootId)
	local charPosIndex = robootData.charPos or 1

	echo("__初始化机器人信息",self.gameMode,robootId)
	for i=1,6 do

		local info = robootData["showPart"..i] 
		local attrData = robootData["initAttrPart"..i]
		if info and attrData then
			local isChar = false
			local enemyInfo 
			if charPosIndex == i then
				isChar = true
				local charId = robootData.charInfo
				attrData = robootData.initAttrChar
				-- 机器人时装
				local tempTreasure = {}
				for i,v in ipairs(robootData.treasures) do
					tempTreasure[v.id] = v
				end
				-- local userData = {avatar = userInfo.avatar,garmentId = robootData.garmentId}
				local heroData = {
					avatar = robootData.avatar,
					userExt = {garmentId = robootData.garmentId}, 
					hid = charId,
					propData = attrData, 
					level = info[2], 
					treasures = tempTreasure,
					quality = tonumber(info[4]),
					star = tonumber(info[3])
				}
			    --角色的直接拿enemyinfo数据
				enemyInfo = self:createEnemyInfo(robootData.avatar, camp, i,true,heroData,true,heroData)
				enemyInfo.attr.lv = info[2] --这里要修改一下主角等级
				enemyInfo.attr.isCharacter = true
			else
				--伙伴的还需要转换一道
				--echo("iiiiiiiiiiii",i,"===================")
				--local info = robootData["showPart"..i]
				-- dump(robootData)
				-- dump(info)
				-- echoError("==================")
				--local attrData = robootData["initAttrPart"..i]
				local heroData = {hid = info[1],propData = attrData,
					level = info[2],skilllvl = info[5],
					quality = tonumber(info[4]),star = tonumber(info[3])}
				local hid = info[1]
				enemyInfo = self:createEnemyInfo(hid, camp, i, false,heroData,true)
			end
				
			enemyInfo.attr.rid = enemyInfo.hid.."_"..i.."_"..camp
			--定义机器人的rid
			enemyInfo.attr.characterRid = robootData.id

			if camp == 2 then
				self:insertOneWaveDataAttr(wave,enemyInfo.attr)
			else
				table.insert(self.campData1, enemyInfo.attr)
			end
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(self.cacheObjectHeroArr,objHero )
		end

	end

end

-- 插入一个attr至阵营列表中
function ObjectLevel:insertOneWaveDataAttr(wave,attr)
	if not self.waveDatas[wave] then
		self.waveDatas[wave] = {}
	end
	table.insert(self.waveDatas[wave],attr)
end




function ObjectLevel:checkEnemy()
	self.campData1 = {}
	--我放人员应该是从后端返回的数据  这里相当于写死的数据
	local hidArr = {
	}

	--判断是否配了npc1
	local waveData = self.staticData[tostring(1)]

	self.useNpc = waveData.useNpc
	-- 如果不是首次通关，则使用玩家真实数据
	if self.battleInfo.battleParams and 
		self.battleInfo.battleParams.first == 0 then
		self.useNpc = nil
	end



	if BattleControler:checkIsCrossPeak() then
		self:initCrossPeakData() --初始化数据
		-- 仙界对决双方阵容
		if BattleControler:checkIsCrossPeakModeBP() then
			self:initSelectCardData()
		else
			self:initNormalModeData()
		end
		self:checkCrossPeakPlayType() --检查模式
		return
	end
	-- 当开启了角色替换开关的时候、用PartnerMapping 替换掉伙伴数据
	local isBattlePve = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve)
	if (IS_SISSION_MAPPING and BattleControler:checkIsWorldPVE()) or isBattlePve  then
		echo("六界玩法启用NPC填充我方对应的伙伴")
		self.useNpc = 1
		self:initUserData()
	else
		if waveData.useNpc == 1 and self.gameMode ~= Fight.gameMode_gve then
		else
			-- 1 表示完全使用level里面的npc数据
			self:initUserData()
		end
	end

	for i=1,6 do
		if waveData["npc"..i] then
			hidArr[i] = {pos = i,hid = waveData["npc"..i] }
		end
	end
	--如果是pvp 而且已经登入了
	if self.gameMode == Fight.gameMode_pvp  then
		--如果登入了
		if #self.campData1 >= 1 then
			return
		end
	elseif self.gameMode == Fight.gameMode_pve  and 
		tostring(self.hid)~=Fight.xvzhangParams.xuzhang
	then
		--如果我方 已经有数据了 而且不是做合并的
		if #self.campData1 >= 1 and waveData.useNpc ~= 2 then
			hidArr = {}
		end
	elseif self.gameMode == Fight.gameMode_gve  then
		hidArr = {}
	end
	-- 当开启替换伙伴的时候，不再使用npc测试数据
	local isBattlePve = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve)
	if (IS_SISSION_MAPPING and BattleControler:checkIsWorldPVE()) or isBattlePve  then
		hidArr = {}
	end
	-- 不在处理表中的配置了
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve then
		return
	end


	--判断是否有这个位置的伙伴了
	local checkHasHero = function (campData,pos  )
		for i,v in ipairs(campData) do
			if v.posIndex == pos then
				return true
			end
		end
		return false
	end

	local function getEnemyInfo(hid, pos)
		local enemyInfo  = self:createEnemyInfo(hid,1,pos,false) 
		--暂定第一个人是主角
		enemyInfo.attr.rid = enemyInfo.hid.."_"..pos
		if self.battleInfo.userRid then
			enemyInfo.attr.characterRid = self.battleInfo.userRid
		else
			enemyInfo.attr.characterRid = UserModel:rid()
		end
		--佩戴了多个法宝的 就算是主角
		if  #enemyInfo.attr.treasures >=2  then
			enemyInfo.attr.isCharacter = true
			
		end

		return enemyInfo
	end

	-- 关卡10303 龙幽特殊入场
	if tostring(self.hid) == Fight.xvzhangParams.level_splongyou then
		local enemyInfo = getEnemyInfo(Fight.xvzhangParams.longyouHid_303, 6)
		self.longyoushuaxin = enemyInfo.attr
		if not Fight.isDummy then
			-- 做这个操作只是为了提前加载资源
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(self.cacheObjectHeroArr,objHero )
		end
	end

	-- 关卡10205 将主角换掉
	if tostring(self.hid) == Fight.xvzhangParams.level_spzhaolinger then
		-- 走到这里一定有此数据
		local uInfo = self.battleInfo.battleUsers[1]
		-- 根据男女换人
		local changeId = FuncChar.getCharSexByAvatar(uInfo.avatar) == 1 and "102074" or "102075"
		-- UserModel:sex() == 1 and "102074" or "102075"
		local posIndex = 1
		for i,info in ripairs(self.campData1) do
			if info.isCharacter then
				-- 删掉这一条插一条新的
				table.remove(self.campData1, i)
				posIndex = info.posIndex
			end
		end

		local enemyInfo = getEnemyInfo(changeId, posIndex)
		if not Fight.isDummy then
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(self.cacheObjectHeroArr,objHero )
		end

		table.insert(self.campData1, enemyInfo.attr)

		-- 加载资源
		local enemyInfo = getEnemyInfo(Fight.xvzhangParams.zhaolingerHid, 6)
		self.zhaolingershuaxin = enemyInfo.attr
		if not Fight.isDummy then
			-- 做这个操作只是为了提前加载资源
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
			table.insert(self.cacheObjectHeroArr,objHero )
		end
	end

	-- 关卡10201 将李逍遥换掉5003
	if tostring(self.hid) == Fight.xvzhangParams.level_splixiaoyao then
		-- 找李逍遥
		local posIndex = nil
		for i,info in ripairs(self.campData1) do
			if info.hid == "5003" then
				-- 删掉
				table.remove(self.campData1, i)
				posIndex = info.posIndex
			end
		end
		-- 找到了李逍遥
		if posIndex then
			local enemyInfo = getEnemyInfo(Fight.xvzhangParams.lixiaoyaoHid, posIndex)
			table.insert(self.campData1, enemyInfo.attr)
		end
	end

	for ii,vv in pairs(hidArr) do
		-- 序章第二关换女主
		--先必须保证对应位置没有人
		if not checkHasHero(self.campData1,vv.pos) then
			local enemyInfo = getEnemyInfo(vv.hid, vv.pos)
			if not Fight.isDummy then
				local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
				table.insert(self.cacheObjectHeroArr,objHero )
			end
			
			table.insert(self.campData1, enemyInfo.attr)
		end
	end

	--目前暂定写死几个怪物
	if not self.waveDatas then
		self.waveDatas = {}
	end
		
	for i=1,self.maxWaves do
		if not self.waveDatas[i] then
			self.waveDatas[i] = {}
		end

		local waveData = self.staticData[tostring(i)]
		local posRandom = waveData.posRandom or 0
		local ePosition = waveData.elementsEnemyPosition
		-- 添加背景音乐
		if waveData.music then
			self.bgMusic[i] = waveData.music
		end
		--拿敌人数据
		local checkPosTab={}
		for ii=1,6 do
			local hid = waveData["e"..ii]
			if hid then
				local enemyInfo  = self:createEnemyInfo(hid,2,ii,false) 
				--定义rid
				enemyInfo.attr.rid = enemyInfo.hid.."_"..ii .."_"..i

				--佩戴了多个法宝的 就算是主角
				if  #enemyInfo.attr.treasures >=2  then
					enemyInfo.attr.isCharacter = true
				end

				--对应的角色rid 
				enemyInfo.attr.characterRid = self.hid
				self:insertOneWaveDataAttr(i,enemyInfo.attr)
				if not Fight.isDummy then
					local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
					table.insert(self.cacheObjectHeroArr,objHero )
				end
				

			end
			-- 阵位
			--[[
			敌方在前面统一赋值
			local element = ePosition and ePosition[ii] and tonumber(ePosition[ii]) or 0
			self.elementFormation.camp2[i][ii] = {
				element = element,
			}
			]]
		end

		--随机位置
		self:randomPos(self.waveDatas[i],posRandom)


	end
end
--随机waveDatas
function ObjectLevel:randomPos( waveData,posRandom )
	if not posRandom or  posRandom == 0 then
		return
	end

	local tempArr = {}
	for k,v in pairs(waveData) do
		--必须是小体型怪 而且不是boss
		if v.figure  == 1 and v.peopleType ~= Fight.people_type_boss  then
			table.insert(tempArr, {pos = v.posIndex,attr = v})
		end
	end

	local length = #tempArr
	-- local arr = table.copy (waveData)
	--如果是 在现有的格子上随机
	if posRandom == 1 then
		local randomArr = BattleRandomControl.randomOneGroupArr(tempArr)
		
		for i=1,length do
			local info1 = randomArr[i]
			local infoOld = tempArr[i]
			--直接修改posIndex 就可以了
			info1.attr.posIndex = infoOld.pos
		end
	--可以从空位上随机
	elseif posRandom == 2 then

		--找可以换位的空位
		local posGroups = {1,2,3,4,5,6}
		--先找空位
		for k,v in pairs(waveData) do
			--如果是大体型 或者是boss 那么就从数组就排除
			if v.figure ~=1 or v.peopleType == Fight.people_type_boss  then
				--那么移除这些
				for i=v.posIndex,v.posIndex + v.figure -1 do
					table.removebyvalue(posGroups, i)
				end

			end			
		end

		local randomIndexArr = BattleRandomControl.randomOneGroupArr(posGroups)

		for i=1,length do
			local infoOld = tempArr[i]
			--直接修改posIndex 就可以了
			infoOld.attr.posIndex = randomIndexArr[i]
		end

	end


end



--创建英雄信息
function ObjectLevel:createEnemyInfo( hid,camp,posIndex ,isChar,heroData,isRoboot,useData,formation,teamFlag)
	local enemyInfo
	if heroData then
		enemyInfo = HeroAttrInfo.new(heroData,hid,camp,isChar,isRoboot,useData,formation)
	else
		local tR = self:getTowerBattleLevelRevise()
		local lR = self.__levelRevise
		--雇佣兵不受锁妖塔系数、关卡修正系数影响
		if teamFlag and teamFlag == Fight.teamFlag_robot then
			tR = self:getTowerBattleFloor() --雇佣兵受层级修正系数影响
			lR = nil
		end
		enemyInfo = EnemyInfo.new(hid,lR,tR,useData)
	end
	-- 标记是主角
	local isMPve = BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve
	if isChar and (isMPve or (IS_SISSION_MAPPING and BattleControler:checkIsWorldPVE())) then
		enemyInfo.attr.isCharacter = isChar
	end
	enemyInfo.attr.posIndex = posIndex


	-- echo(hid,camp,posIndex,"___aaaaaaaaaa_a",isChar)

	local checkPosTab = {}
	local checkCfg = function ( hid,val )
		for k,v in pairs(checkPosTab) do
			if val == v then
				echoWarn(hid.."配置的pos错误和figure冲突")
				break
			end
		end
		table.insert(checkPosTab,val)
	end

	if IS_CHECK_CONFIG then
		if enemyInfo.attr.figure==1 then
			--table.insert(checkPosTab,vv.pos)
			checkCfg(hid,enemyInfo.attr.posIndex)
		elseif enemyInfo.attr.figure ==2 then
			if not ( enemyInfo.attr.posIndex ==1 or enemyInfo.attr.posIndex ==3 or enemyInfo.attr.posIndex == 5) then
				echoError("找策划",hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
			else 
				checkCfg(hid,enemyInfo.attr.posIndex)
				checkCfg(hid,enemyInfo.attr.posIndex+1)
			end
		elseif enemyInfo.attr.figure == 4 then
			if not ( enemyInfo.attr.posIndex ==1 or enemyInfo.attr.posIndex ==3 ) then
				echoError("找策划",hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
			else
				checkCfg(hid,enemyInfo.attr.posIndex)
				checkCfg(hid,enemyInfo.attr.posIndex+1)
				checkCfg(hid,enemyInfo.attr.posIndex+2)
				checkCfg(hid,enemyInfo.attr.posIndex+3)
			end
		elseif enemyInfo.attr.figure == 6 then
			if enemyInfo.attr.posIndex~=1 then
				echoError("找策划",hid.."配置的pos错误和figure冲突",enemyInfo.attr.figure,enemyInfo.attr.posIndex)
			else
				for i=0,5 do
					checkCfg(hid,enemyInfo.attr.posIndex+i)
				end
			end
		end
	end
	return enemyInfo
end


function ObjectLevel:sta_starTime()
	return self.__starInfo
end


-- 根据波数获取战中变换数据、这里的数据应该也需要缓存的(目前暂时未做)
function ObjectLevel:getBattleChange(wave)
	if self.staticData[tostring(wave)] then
		return self.staticData[tostring(wave)].battleChange
	end
	echoWarn ("这个没有获取到对应的变装数据",wave)
	return nil
end
-- 废弃不在使用
-- function ObjectLevel:sta_beforeDialogue(wave)
-- 	if Fight.no_dialog then
-- 		return nil
-- 	end
-- 	return self.staticData[tostring(wave)].battleDialog1
-- end

-- function ObjectLevel:sta_lastDialogue(wave)
-- 	if Fight.no_dialog then
-- 		return nil
-- 	end
-- 	return self.staticData[tostring(wave)].battleDialog2
-- end

function ObjectLevel:sta_storyPlot( wave )
	if Fight.no_dialog then
		return nil
	end
	
	local waveData = self.staticData[tostring(wave)]
	if waveData then
		return  waveData.storyPlot
	end
	echo(wave,"__storyPlot_传入的 wave超过关卡配置的了,hid:",self.hid)
	return nil
end

--判断游戏胜利 失败 结束 前提是已经是最后一波
function ObjectLevel:checkGameResult(controler)

	--有一些一定会失败的
	local campArr1 = controler.campArr_1
	local diedArr1 = controler.diedArr_1
	local campArr2 = controler.campArr_2
	local diedArr2 = controler.diedArr_2
	if #campArr1 == 0 and #diedArr1 ==0 or not controler:chkLiveHero(campArr1) then
		-- 共享副本、仙盟探索、试炼是肯定战斗胜利的
		if BattleControler:checkIsShareBossPVE() or
		BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossPve or
		BattleControler:checkIsTrail() ~= Fight.not_trail
		 then
			return Fight.result_win
		end
		return Fight.result_lose
	end
	--如果敌方死光了  那么直接胜利
	if #campArr2 == 0 and #diedArr2 == 0 or not controler:chkLiveHero(campArr2) then
		if (BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve or
			BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve)
		 and 
			controler.reFreshControler:getRefreshCount() > 0 then
			return Fight.result_none
		else
			-- 如果是车轮战,还有可刷的怪还没有出结果
		    if self:chkIsRefreshType() and 
		    controler.reFreshControler:getRefreshCount() > 0  then
		    	return Fight.result_none
		    end
			return Fight.result_win
		end
	end
	local specInfo = self._killSpecInfo
	--如果有特殊条件
	if specInfo then
		if specInfo.type == 1 then
			return  Fight.result_none
		--如果是杀死boss后直接胜利
		elseif specInfo.type == 3 then
			local hasBoss = false
			for i,v in ipairs(campArr2) do
				if v:checkIsMainHero() then
					hasBoss = true
				end
			end

			for i,v in ipairs(diedArr2) do
				if v:checkIsMainHero() then
					hasBoss = true
				end
			end

			--如果没有boss了
			if not hasBoss then
				return Fight.result_win  
			end
		end

	end

	return Fight.result_none
end

--判断是否进功能攻击队列
function ObjectLevel:checkEnterQueneGroup( camp,wave )
	if camp == 1 then
		return true
	end
	local waveData = self.staticData[tostring(wave)]
	local queCamera = waveData.queCamera
	if queCamera then
		--1 是不需要进队列
		if queCamera[1] == 1 then
			return false
		end
	end
	return true
end

--判断是否需要摄像头移动
function ObjectLevel:checkCampCamera( camp,wave )
	if camp == 1 then
		return true
	end
	local waveData = self.staticData[tostring(wave)]
	local queCamera = waveData.queCamera
	if queCamera then
		--1 是不需要摄像头运动
		if queCamera[2] == 1 then
			return false
		end
	end
	return true
end


--获取先手值
function ObjectLevel:getUphandle( wave )
	local data = self.staticData[tostring(wave)]
	if not data then
		return 1
	end
	return data.uphandle or 1
end
function ObjectLevel:getArtfactInfo( camp )
	local eArr = nil
	if self.__artfactInfo[camp] then
		eArr = self.__artfactInfo[camp]
	end
	return eArr
end
-- 
function ObjectLevel:setCrossPeakInfo( )
	-- local camp = 1
	local rid = self.battleInfo.userRid
	if BattleControler:checkIsCrossPeak() then
		for i,u in pairs(self.battleInfo.battleUsers) do
			local id = u.rid or u._id
			if id == rid then
				-- camp = u.team
			    BattleControler:setTeamCamp(u.team)
			else
				self._otherRid = id
				-- break
			end
		end
	end
    -- BattleControler:setTeamCamp(camp)
end
function ObjectLevel:getCrossPeakOtherRid( )
	return self._otherRid
end
-- 获取仙界对决玩法类型
function ObjectLevel:getCrosspeakPlayType(  )
	return self.battleInfo.battleParams.playType
end
-- -- 巅峰竞技场 另外伙伴数据
-- function ObjectLevel:getBenchData(camp )
-- 	return self.benchData[camp]
-- end
-- 缓存战中换怪和换法宝的资源
function ObjectLevel:cacheBattleChangeRes( )
	if  Fight.isDummy then
		return
	end
	for wave=1,self.maxWaves do
		local bChange = self:getBattleChange(wave)
		if bChange then
			for i,v in ipairs(bChange) do
				-- 换怪
				if v.cType == 1 then
					-- 备注：这里换的一定是怪，是enemyInfo里面的模板
					local enemyInfo  =  EnemyInfo.new(v.newId)
					local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
					table.insert(self.cacheObjectHeroArr, objHero)
				elseif v.cType == 2 then
					-- 换法宝
					for m,n in pairs(self.cacheObjectHeroArr) do
						if n.hid == v.changeId then
							local trs = {hid = v.newId,treaType = Fight.treaType_normal}
							n:addExTreasuresCache(trs)
						end
					end
				end
			end
		end
	end
end

function ObjectLevel:getMappingDataById(mapId )
	local mData = mappingCfg[tostring(mapId)]
	if not mData then
		echoError ("六界轶事比武切磋未找到对应的映射id:",mapId,"使用默认id：101 代替")
		mData = mappingCfg["101"]
	end
	return mData
end
-- 获取映射的heroInfo
function ObjectLevel:getMappingHeroInfo(userInfo,camp,posIndex,formation,partnerId)
	local heroInfo
	if not partnerId then
		-- 主角带入时装
		local mappingId
		if userInfo.userExt and 
			userInfo.userExt.garmentId and userInfo.userExt.garmentId ~= "" then
			mappingId = userInfo.avatar.."_"..userInfo.userExt.garmentId
		else
			mappingId = userInfo.avatar
		end
		-- 映射开启或者是六界比武切磋
		local mMaping = self:getMappingDataById(mappingId)
		local enemyData = EnemyInfo.new(mMaping.mapping)
		heroInfo = self:createEnemyInfo(mMaping.mapping, camp, posIndex, true,nil,false, enemyData,formation)
	else
		local mMaping =self:getMappingDataById(partnerId)
		local enemyData = EnemyInfo.new(mMaping.mapping)
		heroInfo = self:createEnemyInfo(mMaping.mapping, camp, posIndex, false,nil,false, enemyData,formation)
	end
	return heroInfo
end
-- 根据玩法获取对应的怒气机制
function ObjectLevel:initEnergyRuleCfg( )
	local bLabel = BattleControler:getBattleLabel()
	self._EnergyRules = nil
	for k,v in pairs(energyRuleCfg) do
		if v.hid == bLabel then
			self._EnergyRules=v
		end
	end
	if not self._EnergyRules then
		echoWarn("玩法未在EnergyRules表中配置相应的怒气机制，使用默认机制",bLabel)
		self._EnergyRules = energyRuleCfg['1']
	end
end
-- 获取怒气机制
function ObjectLevel:getBattleEnergyRule(  )
	return self._EnergyRules
end
-- 设置共享副本的结果
function ObjectLevel:setLevelDeadData(heroAttr )
	if not self._deadData then
		self._deadData = {}
	end
	table.insert(self._deadData,heroAttr)
end
function ObjectLevel:getLevelDeadData( )
	return self._deadData or {}
end
-- 获取关卡玩法类型
function ObjectLevel:getLevelType( )
	return self.staticData["1"].levelType
end
-- 是否是车轮战
function ObjectLevel:chkIsRefreshType( )
    local lvType = self:getLevelType()
    if lvType and lvType == Fight.levelType_refresh then
    	return true
    end
    return false
end
-- 是否是答题模式
function ObjectLevel:chkIsAnswerType()
    local lvType = self:getLevelType()
    if lvType and lvType == Fight.levelType_Answer then
    	return true
    end
    return false
end
-- 获取需要答题的题库
function ObjectLevel:getRefreshQuestions( ... )
	local cfgData
	if self:chkIsAnswerType() then
		if not CountLevelCfg[self.hid] then
			echoError ("找策划、关卡填了答题模式，但是没有配题库,随机使用了一个题库")
			for k,v in pairs(CountLevelCfg) do
				if not cfgData then
					cfgData = table.deepCopy(v)
					break
				end
			end
		else
			cfgData = CountLevelCfg[self.hid]
		end
		local tmpCfg = {}
		for k,v in pairs(cfgData) do
			table.insert(tmpCfg,v)
		end
		table.sort(tmpCfg,function(a,b)
			return a.questions < b.questions
		end)
		cfgData = tmpCfg
	end
	return cfgData
end
-- 获取对方的数据(用于展示头像用)
function ObjectLevel:getCrossPeakOtherCampData( ... )
	for i,u in pairs(self.battleInfo.battleUsers) do
		if u.team == BattleControler:getOtherCamp() then
			return u
		end
	end
	return nil
end
-- 获取仙界对决伤害加成对应的buff
function ObjectLevel:getCrossPeakBuff( )
	if not self._cpBuff then
		local data = FuncDataSetting.getDataByHid("CrossPeakNullBuff")
		if not data then
			echoError ("未获取到仙界对决加成表现buff，使用默认buffID:1100001")
			data = {str = "1100001"}
		end
		self._cpBuff = data.str
	end
	return self._cpBuff
end
-- 是否有奇侠展示数据
function ObjectLevel:chkParnterShowData( ... )
	local pData = {}
	for k,v in pairs(parnterShowCfg) do
		if v.levelId == self.hid then
			table.insert(pData,table.deepCopy(v))
		end
	end
	if #pData == 0 then
		return false
	end
	self.__parnterShowData = pData
	return true
end
-- 获取奇侠展示数据
function ObjectLevel:getParnterShowData(  )
	return self.__parnterShowData
end

function ObjectLevel:getGameTypeByBattleLabel(_battleLabel)
	local energyRule_data = energyRuleCfg[tostring(_battleLabel)]
	if not energyRule_data then
		return "pve"
	end
	return energyRule_data.loadingType or "pve"
end

-- 获取锁妖塔战斗层数系数修正(万分比)
function ObjectLevel:getTowerBattleFloor()
	if not self.__flvRevise then
		if BattleControler:checkIsTower() then
			local towerFloor = self.battleInfo.battleParams.towerInfo.floor or 1
			local flvRevise = FuncTower.getOneFloorData(towerFloor).floorLevelRevise or 100
			echo("锁妖塔战斗层数系数修正",flvRevise)
			self.__flvRevise = flvRevise * 100
		else
			self.__flvRevise = 10000
		end
	end
	return self.__flvRevise
end
-- 获取锁妖塔怪物、npc战斗难度系数修正(百分比)
function ObjectLevel:getTowerBattleLevelRevise()
	if not self.__tlvRevise then
		local tlvRevise = 100
		if self.battleInfo.towerLevelRevise then
			local flvRevise = self:getTowerBattleFloor()
			tlvRevise = self.battleInfo.towerLevelRevise * (flvRevise/10000)
			echo("怪物难度系数额外修正",tlvRevise)
		end
		self.__tlvRevise = tlvRevise
	end
	return self.__tlvRevise
end
------------ ######### 神力技能相关
-- 初始化神力技能
function ObjectLevel:initSpiritPowerArr()
	if BattleControler:getBattleLabel() ~= GameVars.battleLabels.guildBossGve then
		return 
	end

	self._spiritPower = {}
	local _id = self.battleInfo.battleParams.guildBossInfo.bossId
	local bData = FuncGuildBoss.getBossDataById(_id)
	for _,v in ipairs(bData.ConcertSkill) do
		local csData = FuncGuildBoss.getConcertSkillDataById(v.skill)
		table.insert(self._spiritPower, {
			id = v.skill,
			weight = v.weight,
			battleSkill = csData.mapSkill,
		})
		local res = FuncGuildBoss.getSpiritResForBattle(v.skill)
		-- 顺便初始化神力资源列表 
		if res then
			for _,name in ipairs(res) do
				table.insert(self.cacheArtifact,name)
			end
		end
	end
end

-- 获取神力技信息
function ObjectLevel:getSpiritPowerInfo()
	return self._spiritPower
end

-- 获取多人另外一人的rid
function ObjectLevel:getOtherRid( )
	if self._otherRid then
		return self._otherRid
	end
	local rid = self.battleInfo.userRid
	if BattleControler:checkIsMultyBattle() then
		for i,u in pairs(self.battleInfo.battleUsers) do
			local id = u.rid or u._id
			if id ~= rid then
				self._otherRid = id
			end
		end
	end
	return self._otherRid
end
-- 获取战斗数据
function ObjectLevel:getBattleInfo( )
	return self.battleInfo
end

return  ObjectLevel
