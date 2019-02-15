--
-- Author: Your Name
-- Date: 2014-03-19 17:45:18
--具备生命的对象的基类
--
local Fight = Fight
-- local BattleControler = BattleControler
ModelCreatureBasic = class("ModelCreatureBasic", ModelFrameBasic)
local table = table

ModelCreatureBasic.actionExTarget = nil -- 为了身外的法宝

ModelCreatureBasic._footRootPos  = nil 		--脚下骨头坐标 为了绑定附着在人身上的 所有特效和影子等等

--[[
	{
		样式id:对应的次数 如果为0 表示取消样式
	}	
]]
ModelCreatureBasic.filterStyleInfo = nil 		--滤镜样式管理器

--存储中的每个技能的暴击闪避等
--[[
	{
	[attacker.hid .. skill.hid] = attackResult

	}
	

]]
ModelCreatureBasic.damageResultInfo = nil
--[[
	存储自己（对他人）造成的伤害
	{
		[defender.data.posIndex .. skill.hid] = dmgInfo
	}

	dmgInfo = {
		atkDatas = {[atkData.hid] = true}
		dmg = 10
	}
]]
ModelCreatureBasic.recordDmgInfo = nil
--复活阶段 0表示正常状态 1表示将要复活 2表示复活成功 已经复活过的人不能被再次复活 3 表示将作为傀儡的方式复活
ModelCreatureBasic.reliveState = 0
ModelCreatureBasic.reliveParams = nil -- 复活参数
-- 伤害显示的实例
ModelCreatureBasic.effectNum = nil
-- 是否是置暗状态
ModelCreatureBasic._isDark = false
-- 标记将要释放死亡技（延缓做删除）
ModelCreatureBasic.willDieSkill = false

function ModelCreatureBasic:ctor( ...)
	
	self.hitBorderAble = true

	--具有生命的 对象 深度排列id为3
	self.depthType =  3
	self._footRootPos = {x=0,y=0}
	self.filterStyleInfo = {
		[Fight.filterStyle_fire] = 0,
		[Fight.filterStyle_ice] = 0,
		[Fight.filterStyle_hide ] = 0,
		[Fight.filterStyle_big ] = 0,
		[Fight.filterStyle_small ] = 0,
		[Fight.filterStyle_kuilei ] = 0,
	}

	self:resetDamageResultInfo()
	self:resetRecordDmgInfo()
	self.effectNum = nil
	ModelCreatureBasic.super.ctor(self,...)
end




function ModelCreatureBasic:initView(...)
	ModelCreatureBasic.super.initView(self,...)

	self.myView:playLabel(self.data.sourceData[self.label])
	
	-- 创建血条
	-- local kind = 2  -- 1 主角 2 除了小怪和召唤物 3 小怪
	-- if self.data.isCharacter then
	-- 	kind = 1
	-- end

	-- local peopleType = self.data:peopleType()
	-- if peopleType == Fight.people_type_monster then
	-- 	kind = 3
	-- end
	return self
end


function ModelCreatureBasic:controlEvent()
	ModelCreatureBasic.super.controlEvent(self)	

	if self.data.updateFrame then
		self.data:updateFrame()
	end
end


function ModelCreatureBasic:realPos()
	ModelCreatureBasic.super.realPos(self)

	if  self.myView then
		if self.myState ~= "stand" or self.pos.x ~= self._initPos.x then
			--需要计算scale
			self:countScale()
		end
		

		local isExist = self.myView:isBoneExist("foot")
		if isExist then
			self._footRootPos = self.myView:getBonePos("foot")
			self._footRootPos.x = self._footRootPos.x * Fight.wholeScale 
			self._footRootPos.y = self._footRootPos.y * Fight.wholeScale 
		end
	end
end


--重写setWay
function ModelCreatureBasic:setWay( way )
	self.way = way
	self:countScale()
end



--检测攻击   
--withoutHp 不考虑血量 2017.12.22加入 需要在人物死亡的时候做攻击包，目前看没什么问题
function ModelCreatureBasic:checkAttack(atkData,skill,attTarget,withoutHp)
	if not withoutHp and self.data:hp() <= 0 then
		return 
	end

	--如果攻击行为附带召唤
	if atkData:sta_summon() then
		echo("_____开始召唤-----------------------------",self.data.hid)
		self:doSummonAtkData(atkData)
		return
	end
	-- 通过选择类型来选择人
	local chooseArr = nil

	-- 格子类型的攻击包
	if atkData:sta_doLattice() then
		chooseArr = AttackChooseType:atkLatticeChooseByType(self, atkData, self.controler.formationControler, skill)
	else
		chooseArr = AttackChooseType:atkChooseByType(self, atkData,attTarget,self.campArr,self.toArr,skill)
	end

	--如果没达到人
	if not chooseArr or #chooseArr == 0 then
		-- echoWarn("在对方没有人的情况下 还检测攻击了----skillHid:",skill.hid,atkData.hid,self.logical.roundCount,#self.toArr)
		return
	end

	-- 攻击包是否是子弹攻击包
	if atkData.bulletParams and not Fight.isDummy then
		local bulletParams = atkData.bulletParams
		self:pushOneCallFunc(bulletParams.moveFrame, "doRealAttack", {chooseArr,atkData,skill})
		
		for i,v in ipairs(chooseArr) do
			local bullet = ModelBullet.new(self.controler)

			bulletParams.attacker = self
			bulletParams.defender = v
			bullet:initBullet(bulletParams)
			bullet:startMove()
		end
	else
		self:doRealAttack(chooseArr, atkData, skill)
	end
end

function ModelCreatureBasic:doRealAttack( chooseArr, atkData, skill )
	--判断是否有助攻特效
	local hasZhugong = false
	for i=1,#chooseArr do
		local model = chooseArr[i]
		self:sureAttackObj(model,atkData,skill)
		if model.camp == self.camp and model ~= self  then
			hasZhugong = true
		end
	end

	-- 显示技能总伤
	if skill.showTotalDamage and atkData.atkIndex then 
		local damage = StatisticsControler:getRidDamage(self.data.rid, self.atkTimes)
		-- 伤害攻击包有伤害，且没有被免疫
		if atkData:sta_dmg() and damage > 0 then
			self.effectNum = ModelEffectNum:createTotalDamage(damage)
		end
	end
	if skill.skillIndex == Fight.skillIndex_max and self:isNotPlayMaxSkill() then
		self:setHasPlayMaxSkill(false)
		-- echo ("角色释放大招了")
	end

	-- local atkIndex = atkData.atkIndex
	-- if skill.showTotalDamage and atkIndex and self.camp == 1  then
	-- -- if atkIndex then
	-- 	local damage = StatisticsControler:getRidDamage(self.data.rid, self.atkTimes)
	-- 	--[[
	-- 	local chance 
	-- 	--如果是1 
	-- 	if atkIndex ==1 then
	-- 		chance = 1
	-- 	elseif atkIndex == #skill.attackInfos then
	-- 		chance = 3
	-- 	else
	-- 		chance = 2
	-- 	end
	-- 	if atkIndex == #skill.attackInfos and atkIndex == 1  then
	-- 		chance = 4
	-- 	end
	-- 	if damage > 0 then
	-- 		-- echo(atkIndex,chance,#skill.attackInfos,"__播放技能总伤害")
			
	-- 	else
	-- 		-- echo(atkIndex,chance,#skill.attackInfos,"__还没有伤害",info[3].hid)
	-- 	end
	-- 	]]
	-- 	if atkData:sta_dmg() and damage > 0 then
	-- 		self.effectNum = ModelEffectNum:createSkillDamage(damage,chance)
	-- 	end
		
	-- end
end

--执行挨打函数
function ModelCreatureBasic:runBeHitedFunc(attacker,atkData,skill)

	--如果已经死了 那么不应该执行挨打函数
	if self._isDied then
		return
	end
	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end
	if BattleControler:checkIsTower() then
		-- 锁妖塔、如果第一次攻击的时候，则需要打醒所有沉睡的怪物
		self.controler:removeTowerSleepBuff()
	end
	--因为现在可以鞭尸 所以需要取消这个判断
	-- if self.data:hp() <= 0 then
	-- 	return
	-- end

	-- self:checkDamageResult(attacker,atkData,skill)
	-- 显示五行防御情况（五行护盾的效果）
	if atkData:sta_dmg() then
		local fControler = self.controler.formationControler
		local tElement = attacker:getHeroElement()
		if fControler:isHeroEnhanceDef(self, tElement) then
			self:createEff(Fight.elementDefEff[tElement], 0, 50, 1, nil,false,true)
			-- 如果是第一次受击（第一个攻击包）
			if not attacker:getHasHit(self.data.posIndex) then
				self:insterEffWord({1,Fight.wenzi_elementDef[tElement],Fight.buffKind_hao })
			end
		end
		-- 如果是第一次受击（第一个攻击包）
		if not attacker:getHasHit(self.data.posIndex) then
			-- 判断免疫相关的飘字
			local immune,reason = self.data:isImmnueDmg(skill.atkType,skill.skillIndex)
			-- 因为buff而免疫
			if immune and reason.buffType then
				self:insterEffWord({1, Fight.buffMapFlowWordHao[reason.buffType], Fight.buffKind_hao})
			end

			self:checkBuffBeforeHit(attacker,atkData,skill)
		end
		-- 记录攻击者rid
		self:saveAttackerRid(attacker)
	end

	-- 根据attack计算效果
	AttackUseType:expand(attacker, self, atkData, skill)

	-- 震屏
	local sk = atkData:sta_shake()
	if sk and not self._isDied then
		self:shake(sk[1],sk[2],sk[3])
	end
	
end

--初始化判定伤害结果
function ModelCreatureBasic:checkDamageResult(attacker,atkData,skill  )
	--根据伤害判定是否有过闪避暴击
	local hidKey = skill:getSkillHidHeroRid()

	--如果没有伤害行为 那么不能被暴击
	-- if not atkData:sta_dmg() then
	-- 	result = Fight.damageResult_normal 
	-- 	return
	-- end
	local isFirstAtk = false
	local resultInfo = self.damageResultInfo[hidKey]
	if not resultInfo then
		local specialSkill = attacker.data:getSpecialSkill()
		
		--整个攻击过程只判定一次
		if skill.skillExpand and specialSkill ~= skill then
			skill.skillExpand:onBeforeDamageResult(attacker, self, skill, atkData)
		end

		if specialSkill and  specialSkill.skillExpand and specialSkill ~= skill then
			specialSkill.skillExpand:onBeforeDamageResult(attacker, self, skill, atkData) 
		end
		
		local result = Formula:countDamageResult(attacker,self,skill)
		--记录本次受击的第一个攻击包
		self.damageResultInfo[hidKey] = {result =result }

		resultInfo = self.damageResultInfo[hidKey]
		-- 非伤害技能不可格挡2017.7.3
		-- if result == Fight.damageResult_gedang  or result == Fight.damageResult_baojigedang  then
		-- 	self:insterEffWord( {1,Fight.wenzi_gedang,Fight.buffKind_hao  })
		-- end
		-- self.logical:doChanceFunc({camp = self.camp,attacker = attacker,chance = Fight.chance_defStart,defender = self})
	end
	-- echo(atkData:sta_dmg(),"atkData:sta_dmg()")
	--如果是带伤害的攻击包
	if atkData:sta_dmg() then
		--如果是没攻击包的
		if not resultInfo.atk then
			resultInfo.atk = atkData
			-- 非伤害技能不可格挡2017.7.3
			-- 格挡文字效果
			if resultInfo.result == Fight.damageResult_gedang  or resultInfo.result == Fight.damageResult_baojigedang  then
				self:insterEffWord( {1,Fight.wenzi_gedang,Fight.buffKind_hao  })
			end
			
			local specialSkill = attacker.data:getSpecialSkill() 

			--整个攻击过程只判定一次
			if skill.skillExpand and specialSkill ~= skill then
				skill.skillExpand:onBeforeAttack(attacker, self, skill, atkData)
			end
			if specialSkill and  specialSkill.skillExpand and specialSkill ~= skill then
				specialSkill.skillExpand:onBeforeAttack(attacker, self, skill, atkData) 
			end

			--受击方 判断是否有特殊技
			local specialSkill_def = self.data:getSpecialSkill() 
			if specialSkill_def and  specialSkill_def.skillExpand then
				--做挨打前的判断
				specialSkill_def.skillExpand:onBeforeHited(self,attacker,  skill, atkData)
			end

			-- 受击前记录一下自己当前的一些信息，以供使用
			self.data:setDataBeforeHited()

			--这个时候 需要计算技能能造成的伤害
			local dmg = Formula:skillDamage(attacker,self,skill,false,resultInfo.result)
			--同时需要修正伤害
			resultInfo.dmg = dmg

			if skill.skillExpand then
				dmg = skill.skillExpand:onCheckAttack(attacker, self, skill, atkData,dmg) or dmg
			end
			if specialSkill and  specialSkill.skillExpand and specialSkill ~= skill then
				dmg = specialSkill.skillExpand:onCheckAttack(attacker, self, skill, atkData,dmg) or dmg
			end

			if specialSkill_def and specialSkill_def.skillExpand then
				-- 做伤害判定
				dmg = specialSkill_def.skillExpand:onCheckBeAttack(attacker, self, skill, atkData,dmg) or dmg
			end
			
			--如果伤害大于我自身的血量了 那么就 发送一个有英雄将要死亡的时间, denfeder  是我自己
			--2017.10.9这个方法不能用，因为人会不会死不仅仅受技能的纯伤害影响
			if dmg >= self.data:hp() then
				self.logical:doChanceFunc({camp = 0,chance = Fight.chance_onHeroWillDied ,defender = self,damage = dmg	})
			end

			-- 庇护
			if self.data:checkHasOneBuffType(Fight.buffType_bihu) then
				local buffObj = self.data:getBuffsByType(Fight.buffType_bihu)[1]
				local ratio = buffObj.value
				if ratio > BattleRandomControl.getOneRandomInt(10001,1) then
					echo("庇护触发,伤害降低至1",self.camp,self.data.posIndex)
					dmg = 1
					buffObj:doBuffTriggerFunc(self)
					-- 生效特效
					buffObj:showUseEff()
					self.data:useBuffsByType(Fight.buffType_bihu)
				end
			end
			
			-- 根据自己的职业类型决定挨打获得多少怒气
			-- local pro = tonumber(self:getHeroProfession())
			-- local energy = Fight.beHitedEnergy[pro] or Fight.beHitedEnergyDefault
			-- 加怒气
			-- if self.controler.energyControler:addEnergy(Fight.energy_piece, energy, self) then

			-- end

			resultInfo.dmg = dmg
		end
	end

	return 
end

--判断是否是第一个被攻击的攻击包
function ModelCreatureBasic:checkIsFirstBeAtk(attacker,atkData,skill )
	local hidKey = skill:getSkillHidHeroRid(hid)
	return self.damageResultInfo[hidKey].atk == atkData

end

--获取技能伤害
function ModelCreatureBasic:getAtkDamage(attacker, atkData,skill )
	local hidKey = skill:getSkillHidHeroRid()
	local dmgResInfo = self.damageResultInfo[hidKey]
	local dmg = dmgResInfo.dmg
	
	if not dmgResInfo.singleDmgs then
		dmgResInfo.singleDmgs = {}
	end
	--记录单次伤害，再取不重新计算，否则会重复计算出现错误
	if dmgResInfo.singleDmgs[atkData] then
		dmg = dmgResInfo.singleDmgs[atkData]
	else
		if type(atkData.dmgRatio) == "function" then
			-- 累计伤害
			local accuDmg = dmgResInfo.accuDmg or 0
			dmg,accuDmg = atkData.dmgRatio(dmg, accuDmg)
			dmgResInfo.accuDmg = accuDmg

			dmgResInfo.singleDmgs[atkData] = dmg
		else
			-- 兼容以前的脚本(只搜到zhaoligner 暂不处理)
			return dmg * atkData.dmgRatio
		end
	end

	return dmg
end

--获取技能的总伤害
function ModelCreatureBasic:getSkillDamage(attacker,skill)
	local hidKey = skill:getSkillHidHeroRid()
	if not self.damageResultInfo[hidKey] then
		return  nil
	end
	local dmg = self.damageResultInfo[hidKey].dmg
	return dmg 
end


--获取伤害结果
function ModelCreatureBasic:getDamageResult( attacker,skill )
	local hidKey = skill:getSkillHidHeroRid()
	-- 做一下兼容
	if (not hidKey) or (not self.damageResultInfo[hidKey]) then
		return Fight.damageResult_normal
	end
	return self.damageResultInfo[hidKey].result or Fight.damageResult_normal 
end

--改变生命值
--[[
	@@hero 伤害变化的来源理论上有可能为空
]]
function ModelCreatureBasic:checkHealth(hero)
	local curhp = self.data:hp()
	if curhp <= 0 then

		if not self.hasHealthDied then
			self.hasHealthDied = true
			-- 主要处理buff也有可能杀死人，所以要加怒气
			if hero and hero.camp then
				local energyInfo = self.controler.levelInfo:getBattleEnergyRule()
				local energyControler = self.controler.energyControler
				-- 屏蔽加怒
				if energyControler:addEnergy(Fight.energy_entire, energyInfo.killEnergyResume, nil, hero.camp) then
					--创建击杀获得怒气特效
					if not hero._isDied then
						hero:createEff("eff_mannuqi_zishen", 0, 0, 1, nil,nil,true,nil,nil,nil,hero)
					end
				end
			end

			self.controler:oneHeroeHealthDied(self, hero)

			-- 死亡函数中可能会将复活状态置为1,那么久不再做死亡
			if self:checkWillBeRelive() or self:checkWillDieSkill() then
				return
			end

			--如果是在空中的 那么不执行
			if self.myState == "jump" then
				return
			end
			self:initStand()
			self:justFrame(Fight.actions.action_die, nil, true)
		end
	else
		-- 重新站立一下，加血有可能导致姿势改变
		-- 如果是在空中的 那么不执行
		-- if self.myState == "jump" then
		-- 	return
		-- end
		-- 如果在攻击中 也不执行
		if self.isAttacking then
			return
		end
		-- 2017.12.05 pangkangning 添加moveType(moveType_moveByJump=3)跳跃击飞类型
		-- 修复贫血状态被加血回来后显示站立的动作
		-- 站立状态并且没有在移动
		if self.myState == Fight.state_stand and self.moveType == 0 then
		-- if self.myState == Fight.state_stand and self.moveType ~= 0 then
			self:gotoFrame(Fight.actions.action_stand)
		end
	end
end

--召唤一个目标
function ModelCreatureBasic:summonOneTarget( targetInfo)
	local pos = targetInfo.pos
	--必须判定对应位置上没人,而且没有将要复活的人
	local originHero = self.logical:findHeroModel(self.camp,pos,true)
	if not originHero then
		local id = targetInfo.id
		local lvRevise = self.controler.levelInfo.__levelRevise
		local tlvRevise = self.controler.levelInfo:getTowerBattleLevelRevise()
		local enemyInfo  =  EnemyInfo.new(id,lvRevise,tlvRevise) --添加关卡修正系数
		local exArr = {
			rid = enemyInfo.hid.."_".. pos.."_"..  self.controler.__currentWave,
			posIndex = pos,
			characterRid = self.data.characterRid,
		}
		enemyInfo:setExAttr(exArr)
		local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
		local hero = self.controler.reFreshControler:createHeroes(objHero,self.camp,pos,Fight.enterType_summon )
		hero:setIsSummon(true) --设置是否是召唤物
		hero.data:initAure() --初始化光环
		hero:doHelpSkill() -- 做协助技
		return hero
	end
end

--做召唤行为
function ModelCreatureBasic:doSummonAtkData( atkData )
	if self.currentSkill and self.currentSkill.skillExpand then
		self.currentSkill.skillExpand:onDoSummon(self, atkData)
	else
		local summonInfo = atkData:sta_summon()
		for i,v in ipairs(summonInfo) do
			local hero = self:summonOneTarget(v)
			if hero and atkData:sta_aniArr() then
				hero:createEffGroup(atkData:sta_aniArr(),false,nil,self)
			end
		end
		--然后排序
		self.logical:sortCampPos(self.camp)
	end
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--从数组移除的时候 做的事情
function ModelCreatureBasic:onRemoveCamp(  )
	--清除所有的负面buff
	self.data:clearBuffByKind(Fight.buffKind_huai )
	--隐藏buff特效
	self:showOrHideBuffAni(false)
end


--判断动作最后一帧死亡,彻底清除
-- @@onblowup 击飞落地后的死亡
function ModelCreatureBasic:alreadyDead(onblowup)
	--如果自身已经挂了
	if self._isDied then
		return
	end
	if self.healthBar then
		self.healthBar:setVisible(false)
	end

	-- 死亡的最终入口，如果将被复活为宠物，则不做下面的事情
	if self.__willBPet then 
		self:beComePet()
		return 
	end

	-- 宠物一同干掉
	self:removeOnePet()

	if Fight.isDummy or self.controler:isQuickRunGame() then
		self:stopFrame()
		self:deleteMe()
		return
	end

	if onblowup then
		self:startDoDiedFunc(Fight.diedType_delayalphades)
	else
		self:startDoDiedFunc(Fight.diedType_alphades)
	end
	self:stopFrame()
end

--[[
	假死
	死亡不消失（逻辑上真死了，视图不消失，虚弱待机）
]]
function ModelCreatureBasic:feignDie()
	if self.healthBar then
		self.healthBar:setVisible(false)
	end
	self:movetoInitPos()
end
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-------------------- 创建buff部分    -----------------------------------------------
------------------------------------------------------------------------------------

--判断是否需要创建buff动画
function ModelCreatureBasic:checkCreateBuff( buffHid,attacker,skill )
	attacker = attacker or self
	skill = skill or attacker.currentSkill
	skill = skill or attacker.data:getSkillByIndex(Fight.skillIndex_small)
	-- if skill == nil then
	-- 	echo("------------skill为空--------")
	-- end
	local buffObj = ObjectBuff.new(buffHid,skill)

	self:checkCreateBuffByObj(buffObj,attacker,skill )
	-- Author: pangkangning
	-- Date: 2017-07-31
	-- 添加返回buffObj、在试炼中做对应的判定
	return buffObj
end

-- 使用object创建buff
function ModelCreatureBasic:checkCreateBuffByObj( buffObj,attacker,skill )
	attacker = attacker or self
	skill = skill or attacker.currentSkill
	skill = skill or attacker.data:getSkillByIndex(Fight.skillIndex_small)

    local kind = buffObj.kind
    local buffType = buffObj.type
    --记录buff的skillIndex
    -- echoError(buffObj.skillIndex,"==========")
    -- echoError(skill.skillIndex,"111111111111")
    buffObj.skillIndex  = skill.skillIndex
    --如果血量为0了 那么不设置buff了
    if self.data:hp() <= 0 and buffType ~= Fight.buffType_relive  then
    	return 
    end

    if not self.data:chkBuffCanBeUse(buffObj) then
        echo("buff:",buffObj.type,"被规则过滤掉，不能被添加")
        return 
    end

    if self.data:chkBuffBeImmune(buffObj) then
    	-- 被免疫过滤掉，飘免疫
    	self.data:doBuffFlowEff(buffObj, false, true)
    	return
    end

    -- 判断命中
	local random = BattleRandomControl.getOneRandomFromArea(0,10000)
	local ratio = buffObj.ratio
	
	if buffObj:needChkResist() then
		-- 判断命中和抵抗
	    local buffHit = attacker.data:getAttrByKey(Fight.value_buffHit)
	    local buffResist = self.data:getAttrByKey(Fight.value_buffResist)
	    ratio = math.round(buffObj.ratio * (10000 + buffHit) / (10000 + buffResist))
	end
	-- 没命中
	if random > ratio then
		-- 因为抵抗而没有命中
		if random < buffObj.ratio then
			-- 飘抵抗
	    	self.data:doBuffFlowEff(buffObj, true)
		end
		return
	end

    --如果是复活
   	if buffObj.type == Fight.buffType_relive  then
   		echo(self.reliveState,"____复活state_")
   		--如果已经复活过了 那么不不执行
   		if self.reliveState ~= 0 then
   			return
   		end
   	end

	-- 所有技能ai都有可能会阻止加buff
	local mySkills = self.data:getAllSkills()
	for i,tSkill in ipairs(mySkills) do
		if tSkill.skillExpand and skill ~= tSkill then
			local flag = tSkill.skillExpand:onBeforeUseBuff(self,attacker,skill,buffObj)
			if not flag then
				return
			end
		end
	end

	-- 当有人被作用buff时
	self.logical:doChanceFunc({
		camp = 0,
		chance = Fight.chance_onOneBeUseBuff,
		defender = self,
		attacker = attacker,
		skill = skill,
		buffObj = buffObj,
	})

	--记录buff的释放着 是攻击方
	buffObj.hero = attacker
	-- 备份rid和camp 用于当attacker死亡时候，统计数据无传入参数
	buffObj._backupHero = {data={rid=attacker.data.rid},camp=attacker.camp,atkTimes=1}
	--buff的作用着  是自己
	buffObj.useHero = self
	if skill then
		--攻击（伤害）类型与技能一致
		buffObj.atkType = skill.atkType
	end
	-- 如果buff有上下限设定，则先计算出上下限的值
	if buffObj.valueLimit then
		local limitArr = buffObj.valueLimit
    	buffObj.limitValue = Formula:_getAttrValue(buffObj,limitArr)
	end

	local time = buffObj:sta_time() or  0

	--如果是复活技能 而且是清掉buff的
	if buffObj.type == Fight.buffType_relive  then
		if buffObj.expandParams[5] == 0 then
			--清除所有buff
			self.data:clearBuffByKind(Fight.buffKind_hao )
			self.data:clearBuffByKind(Fight.buffKind_huai )
			echo("_清除所有buff")
		end
		--标记为复活状态 在回合前判定
		self.reliveState = 1
		self.reliveParams = buffObj.expandParams
		self.reliveParams.hid = buffObj.hid
	end

	local flag = self.data:setBuff(buffObj)

	-- 如果buff没有被成功添加不做下面的事情
	if not flag then return end

	--buffObj 特效数组
	local buffAniArr
	local enterAniArr
	--如果有出场的
	if buffObj:sta_enterAni() then
		enterAniArr = self:createEffGroup(buffObj:sta_enterAni(), false,true,attacker)
	end

	if buffObj:sta_aniArr() then
		buffAniArr = self:createEffGroup(buffObj:sta_aniArr(), true,true,attacker)
		buffObj.aniArr = buffAniArr
		--如果有出场动画的 先隐藏掉循环动画
		if enterAniArr then

			for i,v in ipairs(buffAniArr) do
				v:stopFrame()
				v.myView.currentAni:visible(false)
			end

			local tempFunc = function (  )
				if buffObj.aniArr then
					for i,v in ipairs(buffObj.aniArr) do
						v:playFrame()
						v.myView.currentAni:visible(true)
					end
				end
			end

			enterAniArr[1]:setCallFunc(tempFunc)
		end
	end

	if buffType == Fight.buffType_xuanyun  then
		self:checkXuanyun()
	end

	--获取被种buff的特殊技能
	local specialSkill = self.data:getSpecialSkill()
	if specialSkill and specialSkill.skillExpand then
		specialSkill.skillExpand:onBeUseBuff(self,attacker,skill,buffObj)
	end
	self:buffIconMoveAction(buffObj)
end
-- 各种玩法进战斗前对初始属性的修改 attrName：修改的属性名字、value:值、changeType:修改类型，1数值，2比例
-- TODO：特效表现未做、比如血条旁边加buff图标
function ModelCreatureBasic:changeDataValue(attrName,value,changeType )
    if changeType == Fight.valueChangeType_num  then
        self.data:changeValue(attrName, value,changeType)
    else
        self.data:changeValue(attrName, value/10000 ,changeType)
    end
end

--判断是否将要被复活
function ModelCreatureBasic:checkWillBeRelive(  )
	return self.reliveState == 1 or self.reliveState == 3
end



--一个buff消失, 这儿一定会传送一个buffObj过来
function ModelCreatureBasic:oneBuffClear( buffType,buffObj )  
	echo("buff消失---",buffType)
end

-- 判断是否将要释放死亡技
function ModelCreatureBasic:checkWillDieSkill()
	return self.willDieSkill
end



--帧事件-----

--击飞相关-----------------------
--击飞相关-----------------------
--击飞相关-----------------------

--击飞开始之后 进入击飞循环 如果没有跳跃 那么直接进入击飞起身
function ModelCreatureBasic:enterBlowMiddle(  )
	--如果是跳跃状态 才进入击飞循环
	if self.myState  == "jump" then
		self:stopFrame()
	else
		self:justFrame(Fight.actions.action_stand )
		self:onBlowUp()
	end
end

--落地以后做的事情
function ModelCreatureBasic:checkLandStopMove(  )
	if self.label ==Fight.actions.action_blow1 then
		self:justFrame(Fight.actions.action_blow3,nil,true)
	else
		self:justFrame(Fight.actions.action_stand )
	end
	self:initStand()
end

--击飞落地
function ModelCreatureBasic:onBlowUp(  )
	if self.data:hp()> 0 then
		self:movetoInitPos(2)
	else
		if self.data:feigndie() == 1 then
			self:feignDie()
		else
			--那么执行死亡事件 停止动画
			--判断是否从队列里面移除了 同时判断是否是复活状态
			--必须不是复活状态
			if not self:checkWillBeRelive() and not self:checkWillDieSkill() then
				if not table.indexof(self.campArr, self) then
					self:alreadyDead(true)
				end
			end
			-- self:stopFrame()
		end
	end
end


--身上的滤镜效果样式相关
function ModelCreatureBasic:changeFilterStyleNums( style,value )
	if Fight.isDummy then
		return
	end
	self.filterStyleInfo[style] =  self.filterStyleInfo[style] + value
	if self.filterStyleInfo[style] < 0 then
		echoWarn("不应该存在小于0的样式:",style,value,"hid:",self.data.hid)
		self.filterStyleInfo[style] = 0
	end
	echo("添加滤镜===",style,value,self.filterStyleInfo[style])
	-- 追进度的时候不做滤镜处理，但是需要滤镜的样式
	if self.controler:isQuickRunGame() then
		return
	end
	-- echo(style,value,"_________冰冻效果----------")
	self:checkUseFilterStyle()
	
end

--判断滤镜效果
function ModelCreatureBasic:checkUseFilterStyle(  )
	
	if Fight.isDummy or self.controler:isQuickRunGame() then
		return
	end
	local styleMapFilterParams = {
		[Fight.filterStyle_fire] = FilterTools.colorMatrix_fire,
		[Fight.filterStyle_ice] = FilterTools.colorMatrix_ice,
		[Fight.filterStyle_kuilei] = FilterTools.colorMatrix_kuilei,
	}

	local paramsArr = {}
	--开始使用滤镜
	for i,v in pairs(self.filterStyleInfo) do
		if v > 0  then
			table.insert(paramsArr, styleMapFilterParams[i])
		end
	end
	--如果没有滤镜效果
	if #paramsArr ==0 then
		-- 战力状态才恢复，击飞中恢复会打断一些动作
		if self.myState == "stand" then
			--恢复动画播放
			self:playFrame()
		end
		FilterTools.clearFilter(self.myView,10)
	else
		--这里需要判断优先级
		--判断顺序冰火毒
		if self.filterStyleInfo[Fight.filterStyle_ice] > 0 then
			FilterTools.setViewFilter(self.myView,FilterTools.colorMatrix_ice,10)
			--必须是站立状态 才 停帧 因为可能这个时候被击飞了
			if self.myState == "stand" then
				if self.pos.x == self._initPos.x then
					self:stopFrame()
				else
					echo("__不再初始位置 不能冰冻")
				end
				
			end
			-- echo("上冰冻滤镜",self.data.hid,self.posIndex,self.data.camp)
		elseif self.filterStyleInfo[Fight.filterStyle_fire] > 0 then
			FilterTools.setViewFilter(self.myView,FilterTools.colorMatrix_fire,10)
		end
		-- 傀儡不会受其他滤镜影响（不会被攻击）
		if self.filterStyleInfo[Fight.filterStyle_kuilei] > 0 then
			--恢复动画播放
			self:playFrame()
			FilterTools.clearFilter(self.myView,10)
			FilterTools.setViewFilter(self.myView,styleMapFilterParams[Fight.filterStyle_kuilei],10)
		end
	end
	--如果没有隐藏style的
	if self.filterStyleInfo[Fight.filterStyle_hide] == 0 then
		self:setVisible(true)
	else
		self:setVisible(false)
	end

	local bigFrme = 21
	local bigScale = 0.2
	if self.filterStyleInfo[Fight.filterStyle_big] == 0 then
		-- 目前放大系数写死bigScale
		local scale = self._viewScale + self.filterStyleInfo[Fight.filterStyle_big] * bigScale
		self:setViewScale(scale, bigFrme)
	else
		-- 目前放大系数写死bigScale
		local scale = self._viewScale + self.filterStyleInfo[Fight.filterStyle_big] * bigScale
		self:setViewScale(scale, bigFrme)
	end

end

--判断是否有滤镜样式
function ModelCreatureBasic:checkHasFilterStyle( style )
	for k,v in pairs(self.filterStyleInfo) do
		if not style then
			if v > 0 then
				return true
			end
		else
			if v> 0 and k == style then
				return true
			end
		end
		
	end
	return false
end


--判断对方是否没人了
function ModelCreatureBasic:checkIsNoPerson(  )
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve 
		or BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve 
		or self.controler.levelInfo:chkIsRefreshType() 
	then
		-- 这几种玩法都要跑回去，不然可能人在原地怪却刷出来
		return false
	end

	return #self.toArr == 0 and #self.toDiedArr == 0
end

--当技能黑屏的时候 需要同步zorder显示
function ModelCreatureBasic:onSkillBlack(zorder  )
	if self._isDied then return end
	if Fight.isDummy then return end

	zorder = zorder or Fight.zorder_blackChar
	self.myView:zorder(self.__zorder + zorder)
	if self.healthBar then
		self.healthBar:zorder(self.__zorder + zorder + Fight.zorder_health)
		if self.talkBubble then
			self.talkBubble:zorder(self.__zorder + zorder + Fight.zorder_health)
		end
	end

	if not empty(self._pet) then
		for _,pet in ipairs(self._pet) do
			pet:onSkillBlack(zorder)
		end
	end
end

-- 恢复某人的zorder
function ModelCreatureBasic:resumeZorder()
	if self._isDied then return end
	if Fight.isDummy then return end

	self.myView:zorder(self.__zorder)
	if self.healthBar then
		self.healthBar:zorder(self.__zorder + Fight.zorder_health)
		if self.talkBubble then
			self.talkBubble:zorder(self.__zorder + Fight.zorder_health)
		end
	end
end

--显示或者隐藏buffaini
function ModelCreatureBasic:showOrHideBuffAni( value )
	--如果是buff的
	if value then
		for k,v in pairs(self.data.buffInfo) do
			self.data:useLastBuffAni(k)
		end
	else
		for k,v in pairs(self.data.buffInfo) do
			self.data:hideOneBuffAni(k)
		end
	end

end

--让与我相关的特效 都变暗或者恢复
function ModelCreatureBasic:tinyToColor( time,color ,tweenColor)
	if Fight.isDummy  then
		return
	end
	--如果是复原
	if color == 255 then
		--隐藏被攻击选择特效
		if self._beAttackedChooseEff then
			self._beAttackedChooseEff:stopFrame()
			self._beAttackedChooseEff.myView:visible(false)
		end
		self._isDark = false
	else
		self._isDark = true
	end

	if tweenColor then
		if not self._beAttackedChooseEff then
			self._beAttackedChooseEff = self:createEff("UI_zhandou_jihuomubiao", 0, 0, -2, 1, nil, true, true,nil,nil,self)
		end
		if self._beAttackedChooseEff then
			self._beAttackedChooseEff:playFrame()
			self._beAttackedChooseEff.myView:visible(true)
		end
	else 
		--隐藏被攻击选择特效
		if self._beAttackedChooseEff then
			self._beAttackedChooseEff:stopFrame()
			self._beAttackedChooseEff.myView:visible(false)
		end
	end

	self.myView.currentAni:stopAllActions()
	local atcTint1 = cc.TintTo:create(time,color,color,color)
	if tweenColor then

		local atcTint1 = cc.TintTo:create(time,color,color,color)
		local atcTint2 = cc.TintTo:create(time,tweenColor,tweenColor,tweenColor)

		local seq = cc.Sequence:create(atcTint1,atcTint2)

		local repeatAct =cc.RepeatForever:create(seq)

		self.myView.currentAni:runAction(repeatAct)
	else
		self.myView.currentAni:runAction(atcTint1)
	end
	
	local mul = color/255
	if mul == 1 then
		FilterTools.clearFilter(self.healthBar._rootNode)
	else
		FilterTools.setColorTransForm(self.healthBar._rootNode,mul,mul,mul,1,0,0,0,0)
	end
	

	if self.ani_lightSkill1 then
		-- self.ani_lightSkill1.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill1.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill1.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end
	if self.ani_lightSkill2 then
		-- self.ani_lightSkill2.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill2.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill2.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end
	if self.ani_lightSkill22 then
		-- self.ani_lightSkill22.myView.currentAni:stopAllActions()
		-- self.ani_lightSkill22.myView.currentAni:tintTo(time, color,color,color)
		FilterTools.setColorTransForm(self.ani_lightSkill22.myView.currentAni,mul,mul,mul,1,0,0,0,0)
	end

	for k,v in pairs(self.data.buffInfo) do
		for ii,vv in ipairs(v) do
			if vv.aniArr then
				for iii,vvv in ipairs(vv.aniArr) do
					FilterTools.setColorTransForm(vvv.myView.currentAni,mul,mul,mul,1,0,0,0,0)
				end
			end
		end
	end

	if not empty(self._pet) then
		for _,pet in ipairs(self._pet) do
			if not pet._isDied then
				pet:tinyToColor(time,color ,tweenColor)
			end
		end
	end
end



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- --一些set方法-------------------------------------------------------------

-- 法宝的model
function ModelCreatureBasic:setActionExTarget(target)
	-- 如果原先有一个法宝
    if self.actionExTarget then
        self.actionExTarget:deleteMe()
    end
    self.actionExTarget = target
end

--[[
	重置 damageResultInfo
	@@attacker @@skill有则清某个Id没有则清所有
]]
function ModelCreatureBasic:resetDamageResultInfo( attacker, skill)
	local hidKey = nil

	if attacker and skill then
		hidKey =  skill:getSkillHidHeroRid()
	end

	if hidKey then
		self.damageResultInfo[hidKey] = nil
	else
		self.damageResultInfo = {}
	end
end

--[[
	重置敌方身上自己本回合的伤害记录（在重置攻击的时候有用）
]]
function ModelCreatureBasic:resetCurEnemyDmgInfo()
	-- local hidKey = nil
	-- if self.currentSkill then
	-- 	hidKey = self.data.rid.. self.currentSkill.hid
	-- end
	for i=1,#self.toArr do
		local defender = self.toArr[i]
		defender:resetDamageResultInfo(self, self.currentSkill)
	end
end

--[[
	重置 recordDmgInfo
	@@defender @@skill有则清某个Id没有则清所有
]]
function ModelCreatureBasic:resetRecordDmgInfo( defender, skill )
	local hidKey = nil
	if defender and skill then
		hidKey = string.format("%s_%s", defender.data.posIndex, skill.hid)
	end

	if hidKey then
		self.recordDmgInfo[hidKey] = nil
	else
		self.recordDmgInfo = {}
	end
end

--[[
	记录伤害信息
]]
function ModelCreatureBasic:setRecordDmgInfo( defender, atkData, skill )
	local hidKey = defender.data.posIndex.."_"..skill.hid --string.format("%s_%s", defender.data.posIndex, skill.hid)

	if not self.recordDmgInfo[hidKey] then 
		self.recordDmgInfo[hidKey] = {
			atkDatas = {},
			dmg = 0,
		}
	end

	local info = self.recordDmgInfo[hidKey]

	-- table.insert(info.atkDatas, atkData)
	info.atkDatas[atkData.hid] = true

	if atkData:sta_dmg() then
		local dmg = defender:getAtkDamage(self, atkData, skill)
		info.dmg = info.dmg + dmg
	end
end

--[[
	获取伤害信息
	@@defender @@skill有则获取某个Id没有则获取所有
]]
function ModelCreatureBasic:getRecordDmgInfo( defender, skill )
	local hidKey = nil
	if defender and skill then
		hidKey = defender.data.posIndex.."_"..skill.hid 
		--string.format("%s_%s", defender.data.posIndex, skill.hid)
	end

	local result = nil

	if hidKey then
		result = self.recordDmgInfo[hidKey]
	else
		result = self.recordDmgInfo
	end

	return result
end

--[[
	获取消耗的怒气值
	返回值
	消耗怒气量,消耗类型(普通/被减少/被增加)
]]
function ModelCreatureBasic:getEnergyCost()
	-- 需要知道当前的怒气值是否受到的增益/减益
	-- 计算怒气消耗值
	-- local energy = self.data:maxenergy() + self.data:energydiff() * self.maxSkillTimes
	-- if energy > self.data:energyExtreme() then energy = self.data:energyExtreme() end
	
	local energy = self.data:maxenergy()
	local newEnergy = energy
	-- 仙界对决替补未放过大招，怒气消耗为0
	if self:isNotPlayMaxSkill() then
		newEnergy = 0
	end

	-- 影响怒气消耗的buff
	local value = self.data:getOneBuffValue(Fight.buffType_energyCost)
	newEnergy = newEnergy + value
	-- 上限可超下限不可超
	if newEnergy < 0 then newEnergy = 0 end
	-- 免费
	if self.data:checkHasOneBuffType(Fight.buffType_energyNoCost) then
		newEnergy = 0
	end

	local costType = newEnergy - energy
	if costType ~= Fight.energyC_normal then
		costType = costType < 0 and Fight.energyC_reduce or Fight.energyC_add
	end

	return newEnergy,costType
end

--[[
	检查被击后，某些buff的行为
	@attacker 当前攻击的攻击者
	@atkData 当前攻击的攻击包(攻击结束后受击者触发一次这里是final的)
	@skill 当前攻击的技能
]]
function ModelCreatureBasic:checkBuffAfterHited(attacker,atkData,skill)
	
end

--[[
	首次攻击前检查
]]
function ModelCreatureBasic:checkBuffBeforeHit(attacker,atkData,skill)
	-- 如果已经挂了
	if self.hasHealthDied then return end
	-- 拼接技能不做
	if skill.isStitched then return end
	
	self.data:doBuffTriggerFunc(Fight.buffType_lingquan, {attacker})
end

-- 获取体重
function ModelCreatureBasic:getHeroMass()
	local mass = nil
	-- 体重标签
	if self.data.isCharacter then
		for k,v in pairs(self.data.treasures) do
			if v.treaType == Fight.treaType_normal then
				mass = v:sta_mass()
				break
			end
		end
		if not mass then
			echoError("主角没有战斗法宝---,使用默认法宝",self.data.curTreasure.hid)
		end
	else
		mass = self.data.curTreasure:sta_mass()		
	end
	-- 为了小数改为百分比
	return (mass or 100) / 100
end

return ModelCreatureBasic