--[[
	神器控制器
	lcy 2018.01.17

	用来管理两队的神器

	现在不光承担神器(artifact)法宝数据还承担神力(spirit)数据以及逻辑管理考虑是不是改下类名
    2018.05.17
]]

ArtifactControler = class("ArtifactControler")

ArtifactControler.campArr_1 = nil
ArtifactControler.campArr_2 = nil

ArtifactControler.skillInfo_1 = nil
ArtifactControler.skillInfo_2 = nil

ArtifactControler._spiritArr = nil -- 神力生成数据
ArtifactControler._spiritOrigin = nil -- 神力原始数据

ArtifactControler.isSpAttacking = nil -- 是否正在进行神力攻击

ArtifactControler._artifactSkillQueue = nil -- 需要执行的技能队列

function ArtifactControler:ctor(controler)
	self.controler = controler
	self.logical = controler.logical

	self.campArr_1 = {}
	self.campArr_2 = {}

	self.skillInfo_1 = {}
	self.skillInfo_2 = {}

	self._artifactSkillQueue = {}

	self._spiritArr = {}
	self.__spiritOrigin = nil

	self.isSpAttacking = false
end

function ArtifactControler:insertOneArticat(camp,artifact)
	if not camp or not artifact then return end
	local campArr
	if camp == 1 then
		campArr = self.campArr_1
	else
		campArr = self.campArr_2
	end
	table.insert(campArr,artifact)
end

-- 创建一个神器
function ArtifactControler:createOneArtifact(camp)
	camp = camp or 1
	local posIndex = 1

	local enemyInfo = EnemyInfo.new("artifact",nil,nil,nil)
	enemyInfo.attr.posIndex = posIndex
	-- 修改法宝技能参数 --

	enemyInfo.attr.treasures = {self:getOneTreasure(camp)}
	-- enemyInfo.attr.treasures = self:testTreasure()
	
	-- 修改法宝技能参数 --
	local objHero = ObjectArtifact.new(enemyInfo.hid,enemyInfo.attr)
	local artifact = ModelArtifact.new(self.controler,objHero)
	
	if not Fight.isDummy then
		local x,y = self.controler.reFreshControler:turnPosition(camp,3,2,self.controler.middlePos)
		artifact:setInitPos({x=x,y=y,z=0})

		-- local view = ViewSpine.new(artifact.data.curSpbName,nil,nil,artifact.data.curArmature,nil,artifact.data.sourceData) -- defArmature curArmature
		local view = ViewSpine:getOneEmptySpine() -- defArmature curArmature
		--[[
		去掉测试方块
		-- 测试方块
		local tRect = cc.rect(0,0,40,40)
		local nd = display.newRect(tRect,{fillColor = cc.c4f(0,0,1,1),borderColor = cc.c4f(1,0,0,1)}):addTo(view)
		]]

		artifact:initView(self.controler.layer.a122,view)
		artifact:setPos(x,y,0)
	end

	artifact:setCamp(camp,true)

	artifact.data:setHeroModel(artifact)

	self.controler:insertOneObject(artifact)

	self:insertOneArticat(camp, artifact)
end

-- 技能入队
--[[
	@@params = {
		artifact,
		skill
	}
	@@byArr 表示导入的是队列
]]
function ArtifactControler:artifactSkillEnqueue(params,byArr)
	if byArr then
		for _,info in ipairs(params) do
			table.insert(self._artifactSkillQueue, info)
		end
	else
		table.insert(self._artifactSkillQueue, params)
	end
end

-- 技能出队
function ArtifactControler:artifactSkillDequeue()
	if self:isArtifactSkillQueueEmpty() then return end
	
	local artifact,skill = self._artifactSkillQueue[1][1],self._artifactSkillQueue[1][2]

	table.remove(self._artifactSkillQueue, 1)

	return artifact,skill
end

-- 检查技能队列是否为空
function ArtifactControler:isArtifactSkillQueueEmpty()
	return #self._artifactSkillQueue == 0
end

-- 执行神器技能队列
function ArtifactControler:excuteArtifactSkillQueue(chance, ...)
	if self:isArtifactSkillQueueEmpty() then
		if chance == Fight.artifact_roundStart then
			return self.logical:startSpiritPowerRound(...)
		elseif chance == Fight.artifact_roundEnd then
			return self.logical:endRoundThing(...)
		end
	else
		local artifact,skill = self:artifactSkillDequeue()

		artifact:setAttackCompleteCall(self.excuteArtifactSkillQueue, self, chance, ...)
		return artifact:checkSkill(skill,false,nil)
	end
end

-- 检查神器的时机
--[[
	chance 之后的参数根据调用情况传递
]]
function ArtifactControler:checkArtifactChance(currentCamp, chance, ...)
	local skillInfoArr = self:getSkillArtifact(currentCamp, chance)

	if skillInfoArr then
		self:artifactSkillEnqueue(skillInfoArr, true)
	end

	-- 开始执行队列
	return self:excuteArtifactSkillQueue(chance,...)
end

-- 设置神力技能信息
function ArtifactControler:setSpiritSkills(skillInfo)
	if not skillInfo then return end

	self._spiritOrigin = skillInfo
	-- 初始化神力相关数据
	self:updateSpiritPowerArr()
	-- 构造一份神力技能的数据（不考虑阵营2了，只有阵营1可能有神力技能）
	for _,spirit in ipairs(skillInfo) do
		table.insert(self.skillInfo_1, {
			battleSkillId = spirit.battleSkill,
			hid = spirit.battleSkill,
			lvl = 1,
			skillParams = {0,0,0,0},
			isSpiritSkill = true
		})
	end
end

-- 更新一个神力数据（有old视为使用一个，没有则视为重新初始化）
function ArtifactControler:updateSpiritPowerArr(oldId)
	-- 取随机数组其其权重
	local _getTmpArr = function()
		local dataArr = {}

		for _,v in ipairs(self._spiritOrigin) do
			local isHave = false
			for m,n in ipairs(self._spiritArr) do
				if n.id == v.id then
					isHave = true
					break
				end
			end
			if not isHave then
				table.insert(dataArr,v)
			end
		end
		return dataArr
	end

	if oldId then
		local dataArr = _getTmpArr()
		local randomInt = BattleRandomControl.getOneIndexByGroup(dataArr,"weight")
		
		for _,v in ipairs(self._spiritArr) do
			if v.id == tostring(oldId) then
				v.id = dataArr[randomInt].id
				v.battleSkill = dataArr[randomInt].battleSkill
				v.isRecomend = Fight.spiritPower_normal
				break
			end
		end
	else
		self._spiritArr = {}
		for i=1,3 do
			local dataArr = _getTmpArr()
			local randomInt = BattleRandomControl.getOneIndexByGroup(dataArr,"weight")
			table.insert(self._spiritArr, {
				id = dataArr[randomInt].id,
				battleSkill = dataArr[randomInt].battleSkill,
				isRecomend = Fight.spiritPower_normal,
			})
		end
	end
end
-- 设置使用神力的rid玩家
function ArtifactControler:setUseSpiritUserRid( rid )
	self.__spiritUseRid = rid
end
-- 检查是否是我方在使用神力阶段
function ArtifactControler:checkIsMeUseSpirit( ... )
	return self.__spiritUseRid == self.controler:getUserRid()
end
-- 获取神器信息
function ArtifactControler:getSpiritPowerArr()
	return self._spiritArr
end
-- 更新推荐的神力
function ArtifactControler:updateRecommendSpirit( info )
	for k,v in pairs(self._spiritArr) do
		if v.id == info.sid then
			v.isRecomend = Fight.spiritPower_recomend
		else
			v.isRecomend = Fight.spiritPower_normal
		end
	end
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SPIRIT_RECOMMEND, {id = info.sid})
end
-- 根据神力id获取对应的战斗技能id
function ArtifactControler:getBattleSpiritSkillById(id)
	local skillId = nil
	for k,v in pairs(self._spiritArr) do
		if tostring(v.id) == tostring(id) then
			skillId = v.battleSkill
			break
		end
	end
	if not skillId then
		echoError ("未找到对应的神力技能",id)
	end
	return skillId
end
-- 使用一个神力(刷新当前神力、再使用一个神力)
function ArtifactControler:useOneSpirit( info )
	local skillId = self:getBattleSpiritSkillById(info.sid)
	self:updateSpiritPowerArr(info.sid) --更新神力(上面先获取神力技能再更新神力)
	-- 根据神力获取对应的参数
	local params = {}
	if info.pos then
		params = {camp = info.camp,posIndex = info.pos,heroRid = info.posRid}
	else
		local campArr = self.controler:getCampArr(info.camp)
		local hero = AttackChooseType:findHeroByHeroRid(info.posRid,campArr)
		if not hero then
			echoError ("未找到神力释放的地方角色")
			return
		end
		params.hero = hero
	end
	local othCamp = info.camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
	self:checkSpiritSkill(othCamp,skillId,params )
	-- 程序更新然后调用状态机切换至
	-- 发送事件让UI关闭
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SPIRIT_USE, {id = info.sid})
	if not Fight.isDummy then
		self.controler.viewPerform:hideAllAtkUseEff()
	end
end

-- 设置神器技能信息
function ArtifactControler:setArtifactSkills(camp,skills)
	if not camp or not skills then return end

	local campArr = camp == Fight.camp_1 and self.skillInfo_1 or self.skillInfo_2
	-- 标记一下是神器技能
	for _,skill in ipairs(skills) do
		skill.isArtifactSkill = true
		campArr[#campArr + 1] = skill
	end
end

--[[
	获取释放技能的神器
	@@chance 时机 1 回合开始前 2 回合结束后
]]
function ArtifactControler:getSkillArtifact(currentCamp, chance)
	local result = nil
	local artifact,skill = nil,nil

	-- 使遍历顺序是，当前阵营>另一个阵营，来保证技能的排序进攻方在防守方之前
	local orderArr = {currentCamp, currentCamp % 2 + 1}
	for i=1,2 do
		local camp = orderArr[i]
		-- 目前不考虑多个神器技能会一起作用的问题
		local campArr = camp == Fight.camp_1 and self.campArr_1 or self.campArr_2
		artifact = campArr[1] -- 暂时走单model的方式

		if artifact then
			-- 不能只取自动释放的，因为有的手动释放的也有自动释放的逻辑
			-- local skills = artifact:getArtifactSkill(Fight.atSkill_applyType_auto)
			local skills = artifact:getArtifactSkill()

			for idx,sk in ipairs(skills) do
				if sk:artifactCanUse(Fight.atSkill_applyType_auto, currentCamp, chance) then
					skill = sk
					break
				end
			end
		end

		if skill then
			-- 存一份
			if not result then result = {} end
			table.insert(result, {artifact,skill,camp})
			artifact,skill = nil,nil
		end
	end

	return result
end

--[[
	主动释放神力技能(**注意只针对手动释放的技能)
	@@camp 释放的阵营
	@@skillId 释放技能的Id
]]
function ArtifactControler:checkArtifactSkill(camp, skillId)
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return
	end
	-- 获取技能
	local skill = artifact:getArtifactSkillById(Fight.atSkill_applyType_manual, skillId)
	if not skill then
		echoError("没有技能，检查数据",skillId)
		return
	end

	-- 技能结束直接接logical的onAttackComplete
	artifact:setAttackCompleteCall(self.logical.onAttackComplete,self.logical,artifact,Fight.skillIndex_artifact)

	-- 释放技能
	artifact:checkSkill(skill,false,nil)
end

--[[
	释放神力技能
	@@camp 释放的阵营
	@@skillId 释放技能的Id
	-- @@targetH 目标人物
	@@params 技能需要的参数（type table根据技能而定）
	例{
		hero = model -- 主目标（比较特殊的雾魂神力是两人换位）
	}
]]
function ArtifactControler:checkSpiritSkill(camp, skillId, params)
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return
	end
	-- 获取技能
	local skill = artifact:getSpiritSkillById(skillId)
	if not skill then
		echoError("没有技能，检查数据",skillId)
		return
	end

	-- 需要钦定技能攻击范围（神力技能一定有）
	if not skill.skillExpand then
		echoError("神力技能至少需要指定攻击范围的脚本")
	end

	-- if skill.isSpiritSkill then
	skill:setAppointAtkChooseArr(skill.skillExpand:getSpiritSkillArr(params))
	-- end
	
	artifact:setAttackCompleteCall(self.onSpiritSkillComplete,self)
	
	self.isSpAttacking = true -- 置为神力正在攻击中
	-- 释放技能
	artifact:checkSkill(skill,false,nil)
end

-- 神力技能释放结束
function ArtifactControler:onSpiritSkillComplete()
	self.isSpAttacking = false -- 神力技能攻击置回
	self.logical:endSpiritRound() -- 调用神力技能完成
end
-- 检查是否有人在释放神力技能
function ArtifactControler:cheskIsAttacking(  )
	return self.isSpAttacking
end

-- 获取神力技能释放范围
function ArtifactControler:getSpiritSkillArr(camp, skillId, params)
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return
	end
	-- 获取技能
	local skill = artifact:getSpiritSkillById(skillId)
	if not skill then
		echoError("没有技能，检查数据",skillId)
		return
	end

	-- 需要钦定技能攻击范围（神力技能一定有）
	if not skill.skillExpand then
		echoError("神力技能至少需要指定攻击范围的脚本")
	end

	return skill.skillExpand:getSpiritSkillArr(params)
end

-- 返回是否在神力攻击中
function ArtifactControler:isSpiritAttacking()
	return self.isSpAttacking
end

-- 判断某神器技能是否能够使用（针对手动释放类型）
function ArtifactControler:artifactSkillCanUse(camp, skillId, withenergy )
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return false
	end

	-- 主动释放类型的技能
	local skill = artifact:getArtifactSkillById(Fight.atSkill_applyType_manual, skillId)

	-- 技能条件满足
	if skill and skill:artifactCanUse(Fight.atSkill_applyType_manual) then
		if not withenergy then
			return true
		else
			-- 怒气是否满足
			return self.controler.energyControler:isEnergyEnough(skill:getEnergyCost(),camp)
		end
	end

	return false
end

-- 获取可以释放的手动神力技能（不考虑怒气）
-- withenergy 考虑怒气值
function ArtifactControler:getCanUseManualSkill(camp, withenergy)
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return
	end

	return artifact:getCanUseManualSkill(camp, withenergy)
end

-- 手动释放神力
function ArtifactControler:doArtifactAttackClick(camp, skillId)
	-- 获取神器
	local artifact = self:getArtifactModel(camp)
	if not artifact then
		echoError("没有神器/力技能载体，检查数据",camp)
		return
	end
	self:updateUseSkillId(skillId)
	artifact:doAttackClick(skillId,true)
end
-- 已经点击释放了的神器数组id(为了校验唯一性)、神器只能释放一次
function ArtifactControler:updateUseSkillId(skillId)
	if not self._useSkillIdArr then
		self._useSkillIdArr = {}
	end
	table.insert(self._useSkillIdArr,skillId)
end
-- 获取已经释放的神器id
function ArtifactControler:getUseSkillArr(  )
	return self._useSkillIdArr or {}
end
-- 重置释放的神力id
function ArtifactControler:resetUseSkillArr( )
	self._useSkillIdArr = {}
end
-- 获取神器
function ArtifactControler:getArtifactModel(camp)
	return (camp == Fight.camp_1 and self.campArr_1[1] or self.campArr_2[1])
end

function ArtifactControler:test()
	self:createOneArtifact(Fight.camp_1)
end

-- 构造一个法宝
function ArtifactControler:getOneTreasure(camp, skills)
	if not camp then return end

	skills = skills or (camp == Fight.camp_1 and self.skillInfo_1 or self.skillInfo_2)

	local trs = {}
	trs.partnerId = "artifact"
	trs.hid = "artifact"
	trs.treaType = Fight.treaType_base

	trs.skillInfo = {}

	-- 这个skills不保证顺序，之后再考虑顺序问题
	for _,skill in ipairs(skills) do
		table.insert(trs.skillInfo, skill)
	end

	return trs
end

function ArtifactControler:testTreasure()
	local trs = {}
	trs.partnerId = "artifact"
	trs.hid = "artifact"
	trs.treaType = Fight.treaType_base

	local test = {cimeliaGroups = {}}
	test.cimeliaGroups["501"] = {
		cimelias = {

		},
		id = "501",
		quality = 1,
	}
	test.cimeliaGroups["403"] = {
		cimelias = {

		},
		id = "403",
		quality = 1,
	}

	trs.skillInfo ={
		-- [1] = temp
	}

	local atArr = FuncArtifact.getArtifactDataForBattle(test)
	local temp = nil
	for k,v in pairs(atArr) do
		if v.kind == Fight.artifact_kind3 then
			temp = v.data
			temp.isArtifactSkill = true
			table.insert(trs.skillInfo,temp)
		end
	end

	-- trs.skillInfo ={
	-- 	[1] = temp
	-- }

	return {trs}
end

return ArtifactControler