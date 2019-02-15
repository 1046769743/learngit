
local Fight = Fight
local table = table
AttackUseType = {}

-- function AttackUseType:addPower(treasure, ratio)
-- 	local manaCost = tonumber(treasure:sta_manaC())
-- 	if ratio < 33 then
-- 		return math.floor(manaCost/2)-1
-- 	elseif ratio <= 66 then
-- 		return math.floor(manaCost/2)
-- 	else
-- 		return math.floor(manaCost/2)+1
-- 	end
-- end

--真正的attack包逻辑.
function AttackUseType:expand(attacker,defender, atkData,skill)
	local useType = nil
	local atkResult,damage 

	--判定伤害结果
	defender:checkDamageResult(attacker,atkData,skill)
	--记录自己的伤害信息
	attacker:setRecordDmgInfo(defender,atkData,skill)

	atkResult = defender:getDamageResult(attacker,skill)
	local specialSkill = attacker.data:getSpecialSkill() 

	
	--受击方 判断是否有特殊技（不止判断特殊技2017.7.18）
	-- local specialSkill_def = defender.data:getSpecialSkill() 
	-- 受击方技能
	local defenderSkills = defender.data:getAllSkills()

	-- echo(atkResult,"_______________________atkResult")
	--先做攻击

	if atkData:sta_buffs() then
		self:buffs(attacker,defender, atkData,skill,atkData:sta_buffs())
	end

	if atkData:sta_dmg() then
		damage  = defender:getAtkDamage(attacker,atkData,skill) --Formula:skillDamage(attacker,defender,skill,atkData,atkResult)
		
		self:damageHit(atkResult,damage,attacker,defender, atkData,skill)
	end



	--如果是净化或者驱散效果
	if atkData:sta_purify() then
		self:purify(attacker,defender, atkData,skill,atkData:sta_purify())
	else
		-- 不是净化驱散的直接拨特效
		local aniArr = atkData:sta_aniArr()
		if aniArr then
			defender:createEffGroup(aniArr, false,true,attacker)
		end
	end

	if atkData:sta_addHp() then
		damage  = Formula:skillTreat(attacker,defender,skill,atkData,atkResult)
		if skill.skillExpand then
			damage = skill.skillExpand:onCheckTreat(attacker,defender,skill,atkData, damage) or damage
		end
		self:addHp(atkResult,damage ,attacker,defender, atkData,skill)
	end

	if atkData:sta_dmg2hp() then
		--获取attacker,的skill的总伤害
		local allDmg = StatisticsControler:getRidDamage(attacker.data.rid, attacker.atkTimes)
		if allDmg > 0 then
			-- buff加成的比例
			local exValue = attacker.data:getOneBuffValue(Fight.buffType_eNxixue)
			local hp = math.round(allDmg * (atkData:sta_dmg2hp() + exValue)/10000)
			self:addHp(atkResult, hp, attacker, defender, atkData, skill)
		end
		
	end

	self:checkAtkBlow(defender,atkData,skill ,attacker,atkResult)

	self:checkRoutHudun(attacker,defender, atkData,skill)
	-- 检查炸弹崩溃
	self:checkBombRout(attacker, defender, atkData, skill)

	--发送全局生命值改变事件 主要是通知ui变化
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGEHEALTH ,attacker)

	if atkData.isFinal then
		--如果是攻击后判定 
		if skill.skillExpand then
			skill.skillExpand:onAfterAttack(attacker,defender,skill,atkData)
		end
		--攻击者特殊技也会做一次攻击后触发
		if specialSkill and specialSkill.skillExpand then
			specialSkill.skillExpand:onAfterAttack(attacker,defender,skill,atkData)
		end
		-- （不止判断特殊技2017.7.18）
		-- if specialSkill_def and  specialSkill_def.skillExpand and specialSkill ~= skill then
		-- 	--做挨打后或者被作用后的判断,不一定特指挨打,有可能是被加血,damage可能为空
		-- 	specialSkill_def.skillExpand:onAfterHited(defender,attacker,  skill, atkData,damage)
		-- end
		if defenderSkills then
			for i,nowSkill in ipairs(defenderSkills) do
				if nowSkill ~= skill and nowSkill.skillExpand then
					nowSkill.skillExpand:onAfterHited(defender, attacker, skill, atkData, damage)
				end
			end
		end

		-- 检查被击后，某些buff的行为
		defender:checkBuffAfterHited(attacker, atkData, skill)

		-- 做受击后记次
		for _,buffType in ipairs(Fight.useBuffByBeHited) do
			defender.data:useBuffsByType(buffType)
		end

		-- 伤害攻击包才会生效
		if atkData:sta_dmg() then
			-- 非加血的最后一个攻击包检查carrierbuff
			local buffs = attacker.data:getBuffsByType(Fight.buffType_atkcarrier)
			if buffs then
				echo("携带攻击包的buff生效，并作用")
				for _,buff in ipairs(buffs) do
					local expandParams = buff.expandParams -- expandParams中是攻击包
					if expandParams and expandParams[1] == 1 then
						for i=2,#expandParams do
							attacker:sureAttackObj(defender,expandParams[i],buff.skill)
						end
					end
				end
			end
		end
	end

	

	return atkResult
end

--判断是否销毁护盾
function AttackUseType:checkRoutHudun( attacker,defender, atkData,skill )
	-- 检查某类护盾类的buff（有吸收后崩溃效果的）
	local function manageHuDunbuff( defender, buffType )
		--击飞完毕之后判断是否需要销毁护盾
		local hudunValue,buffArr = defender.data:getOneBuffValue(buffType )
		local buffObj
		if buffArr then
			buffObj = buffArr[1]
		end
		--如果是最后一个攻击包 而且 这个护盾buff崩溃了
		if buffObj and  buffObj.isRout and atkData.isFinal then
			defender.data:clearOneBuffObj(buffObj,true)
			-- table.remove(buffArr,1)
			echo("__最后一个攻击包执行崩溃,buffId",buffObj.hid)
			local routAction = buffObj:sta_routAction()
			if routAction then
				for i,v in ipairs(routAction) do
					--如果是攻击包
					if v.t == 1 then
						local atkData = ObjectAttack.new(v.p1)
						defender:checkAttack(atkData,defender.data:getSkillByIndex(buffObj.skillIndex),attacker)
					--如果是做buff
					elseif v.t == 2 then
						defender:checkCreateBuff(v.p1, defender,skill)
					elseif v.t == 4 then
						local buffHids = string.split(v.p1,"_")
						for _,hid in ipairs(buffHids) do
							defender.data:clearOneBuffByHid(hid)	
						end
					end
				end
			end
		end
	end
	-- 检查护盾
	manageHuDunbuff(defender, Fight.buffType_hudun)
	-- 检查创伤
	manageHuDunbuff(defender, Fight.buffType_chuangshang)
	-- 检查治疗护盾的崩溃
	manageHuDunbuff(defender, Fight.buffType_zlhudun)
end

-- 计算护盾抵消值
function AttackUseType:calDiXiao(damage, defender, buffType)
	--伤害抵消,如果有生命护盾 那么抵消
	local dixiao = 0
	local damage = math.round(damage)

	if defender.data:checkHasOneBuffType(buffType) then
		--判断护盾
		--获取护盾值
		local hudunValue,buffArr = defender.data:getOneBuffValue(buffType)
		local buffObj
		if buffArr then
			buffObj = buffArr[1]
		end
		if hudunValue > 0 then
			if damage > hudunValue  then
				dixiao = hudunValue
			else
				dixiao = damage
			end
			
			buffObj.value = buffObj.value - dixiao

			--如果抵消护盾取消了 那么做崩溃动画
			if buffObj.value <= 0 then
				--标记要崩溃了
				buffObj.isRout = true
				
			end
		end

		-- 如果发生了抵消，做一下buff上绑定的作用特效
		--判断是否有作用动画
		local useAniArr = buffObj:sta_useAniArr()
		if useAniArr and dixiao > 0 then
			defender:createEffGroup(useAniArr, false, true, defender)
		end
	end

	return damage - dixiao,dixiao
end

-- 检查能否击飞
function AttackUseType:chkCanBlow(defender, atkResult, skill)
	local blowState = 0
	local result = true

	-- 不能击飞的buff
	local buffs = {
		Fight.buffType_bingdong,
		Fight.buffType_shufu,
		Fight.buffType_hudun,
		Fight.buffType_zlhudun,
		Fight.buffType_dingshen,
		Fight.buffType_bingfeng,
		Fight.buffType_mianyidmg,
	}
	
	for _,v in ipairs(buffs) do
		if defender.data:checkHasOneBuffType(v) then
			blowState = 1
			result = false
			break
		end
	end

	-- 对此技能的伤害免疫
	if skill and defender.data:isImmnueDmg(skill.atkType,skill.skillIndex) then
		blowState = 1
		result = false
	end

	-- 其他不能击飞的事
	if defender.data:immunity() == 2 then
		blowState = 1
		result = false
	elseif defender.data:immunity() == 1 then
		result = false
	end

	if atkResult == Fight.damageResult_gedang or atkResult == Fight.damageResult_baojigedang  then
		result = false
		if blowState == 0 then
			blowState = 2
		end
	end

	return result,blowState
end

--判断击飞
function AttackUseType:checkAtkBlow(defender,atkData,skill ,attacker ,atkResult)
	
	--如果有冰冻或者 霸体 那么是不击飞的 除非是死亡
	--必须是伤害行为才执行击飞
	if not atkData:sta_dmg() then
		return
	end

	local movePos = atkData:sta_move()
	self:checkClearHeroFromArr(defender,atkData,skill,attacker)

	--纯跑逻辑或者快进   是不做后面的事情的
	if Fight.isDummy or attacker.controler:isQuickRunGame() then
		return
	end

	--blowState 0表示随配置 1表示身体不能被控制  霸体和冰冻状态 是不受击的 2表示格挡
	local flag,blowState = AttackUseType:chkCanBlow(defender, atkResult, skill)

	--如果防守方阵营就是当前攻击阵营  那么不应该被击飞;同时攻击者非混乱状态;同时不是交替攻击模式
	if defender.camp == defender.logical.currentCamp 
	and not attacker:isConfusion() 
	and defender.logical.roundModel ~= Fight.roundModel_switch
	then
		flag = false
		-- return
	end

	-- 如果自己就是正在进行攻击的人不做受伤反馈，对于反击技能需要排除，同时目前没有反伤致死的情况
	if defender.logical.attackingHero == defender and not skill._isFightBack then
		return
	end

	if flag and movePos then
		self:blowHero(defender,movePos,atkData)
	else
		--如果小于0 那么直接把他从数组清除,死亡时要移除数组防止,做死亡动作时候,还会被攻击检测.
		if defender.data:hp() <= 0 then
			--必须不是在空中的时候 才执行下面的操作
			if defender.myState ~= "jump" then
				if atkData.isFinal then
					if defender:checkWillBeRelive() or defender:checkWillDieSkill() then
						echo("这个人将要被复活")
						defender:justFrame(Fight.actions.action_blow3, nil, true)
					else
						if defender.data:feigndie() == 1 then
							defender:feignDie()
						else
							defender:justFrame(Fight.actions.action_die, nil, true)
						end
					end
				else
					if blowState == 0 then
						defender:justFrame(Fight.actions.action_hit, nil, true)
					end
				end
			end
		else
			--必须不在空中的时候 才能挨打
			if defender.myState ~= "jump" then
				if blowState == 0 then
					defender:justFrame(Fight.actions.action_hit, nil, true)
				--如果是格挡
				elseif blowState == 2 then
					defender:justFrame(Fight.actions.action_block, nil, true)
				end
			end
			
		end
	end
end


--击飞某个英雄
function AttackUseType:blowHero( hero,movePos,atkData )
	-- 根据M修正击飞距离后再进行后续判断
	if movePos[4] and movePos[4] == 1 then -- 击飞考虑体重
		movePos = table.copy(movePos)
		movePos[1] = movePos[1]/math.sqrt(hero:getHeroMass())
		movePos[2] = movePos[2]/math.sqrt(hero:getHeroMass())
	end

	local dz = -movePos[2] - hero.pos.z
	--如果目标高度 比现在低
	if dz > 0 then
		dz = 0
	end
	local vz = 0
	local t1 =0
	local t2 = 0
	local vx = 0
	local dx = -movePos[1] * hero.way
	--如果是击飞
	if dz < 0 then
		-- 已经是死亡动作了就不再做击飞（buff会导致先死亡）
		if hero.label == Fight.actions.action_die then
			return
		end

		hero:initMoveType()

		local moveFrame = movePos[3] or 0
		--先计算下 加速度
		if moveFrame == 0 then
			hero.addSpeed.z =  Fight.moveType_g
		else
			hero.addSpeed.z = math.ceil( movePos[2]/(moveFrame*moveFrame) *2)
		end

		--得把整个路程分成2段
		vx,vz = Equation.countSpeedXZBySEHG(hero.pos.x,hero.pos.z,hero.pos.x + dx ,0,hero.addSpeed.z,hero.pos.z + dz )
		
		hero:initMove(vx,0)
		hero:initJump(vz)

		if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
			hero:justFrame(Fight.actions.action_blow1, 1, true)
		else
			hero:justFrame(Fight.actions.action_blow1, nil, true)
		end

	else
		--如果是在空中的 而且只是水平位移 那么不执行
		if hero.myState == "jump" then
			return
		end
		if hero.data:hp() <= 0 then
			if atkData.isFinal then
				--如果是即将复活的
				if hero:checkWillBeRelive() or hero:checkWillDieSkill() then
					echo("_________滚动状态复活")
					hero:justFrame(Fight.actions.action_blow3, nil, true)
				else
					if hero.data:feigndie() == 1 then
						hero:feignDie()
					else
						hero:justFrame(Fight.actions.action_die, nil, true)
					end
				end
				
				return
			else
				if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
					hero:justFrame(Fight.actions.action_blow1, 1, true)
				else
					hero:justFrame(Fight.actions.action_blow1, nil, true)
				end
			end
			
			return
		else
			if hero.label == Fight.actions.action_blow1 or hero.label == Fight.actions.action_blow2 then
				hero:justFrame(Fight.actions.action_blow1, 1, true)
			else
				hero:justFrame(Fight.actions.action_blow1, nil, true)
			end
		end
		--如果没有z速度 就水平击退 默认是击退开始动作加5帧
		local moveFrame = hero.totalFrames + 5
		vx = dx / moveFrame
		hero:initMove(vx,0)
		
	end
end


--判断是否应该从数组剔除这个人物 
function AttackUseType:checkClearHeroFromArr( hero,atkData,skill,attacker )
	-- 判断是否是这个技能的最后一个攻击包
	if not atkData.isFinal then return end

	if hero.data:hp()> 0 then
		return
	end
	-- 有人将要真正死亡
	hero.logical:doChanceFunc({camp = 0,chance = Fight.chance_onHeroRealWillDied ,defender = hero, attacker = attacker})
	
	-- 再检查一次血量，防止在时机中改变了血量
	if hero.data:hp()> 0 then
		-- 没死人也要检查一次结果，因为有的人把自己救回来后会变成中立
		hero.controler:checkGameResult()
		return
	end

	if not hero.hasHealthDied then
		hero.hasHealthDied = true

		--是否击杀 追击者
		local isKillSign = hero == hero.logical.attackSign 
		
		--让attacker执行击杀英雄事件
		-- 把时机移动到这里是为了在结算前做完最后的逻辑（比如，慕容紫英击杀额外获得怒气，在锁妖塔中，如果击杀的是最后一人，放在后面怒气会加不上）
		attacker:onKillEnemy(hero)

		local energyInfo = hero.controler.levelInfo:getBattleEnergyRule()
		local energyControler = hero.controler.energyControler
		-- 屏蔽加怒
		if energyControler:addEnergy(Fight.energy_entire, energyInfo.killEnergyResume, nil, attacker.camp) then
			--创建击杀获得怒气特效
			attacker:createEff("eff_mannuqi_zishen", 0, 0, 1, nil,nil,true,nil,nil,nil,attacker)
		end
		-- 锁妖塔我方死亡角色、则需要回怒(该机制只对我方有效,仙界对决等pvp不能用)
		if BattleControler:checkIsTower() and hero.camp == Fight.camp_1 and
		 energyInfo.deathEnergyResume then
			energyControler:addEnergy(Fight.energy_entire,energyInfo.deathEnergyResume,nil,hero.camp)
		end

		-- 炸弹buff需要标记崩溃
		local buffs = hero.data:getBuffsByType(Fight.buffType_bomb)
		if buffs then
			for _,buff in ipairs(buffs) do
				buff.isRout = true
			end
		end
		-- 这里也要检查，不然后面就被打死了会清除负面buff
		self:checkBombRout(attacker, hero, atkData, skill)

		hero.controler:oneHeroeHealthDied(hero, attacker)
		
		if hero.data:beKill() then
			attacker.hasKillEnemy = true
		end

	end
end

--判断击杀绝技
--[[
去掉击杀技
function AttackUseType:checkKillSkill(hero,atkData,skill,attacker  )
	local killSkill = attacker.data.curTreasure.skill7
	if not killSkill then
		return 
	end
	echo("___触发击杀技能",killSkill.hid)
	killSkill:doAtkDataFunc()
end
]]

-- 通过类型判定调用伤害计算公式

--多次减血数组
function AttackUseType:checkkMultyAttackEffect(model,atkData,numType,damage, showZorder)
	if Fight.isDummy then
		return
	end

	--3倍速度 就不飘数字特效了
	if Fight.debug_battleSpeed >=3 then
		return
	end

	local scoreT =  1--atkData:sta_scoreT()
	local scoreD = 1-- atkData:sta_scoreD()

	local perDamage = math.ceil( damage)
	-- for i=1,scoreT do
	-- 	model:pushOneCallFunc((i-1)*scoreD,"createNumEff",{numType,perDamage,showZorder})
	-- end

	model:createNumEff(numType,perDamage,showZorder)
end
-- 检查会被打破的bug
function AttackUseType:checkBreakBuff(attacker,defender, atkData,skill)
	-- 新处理冰封怪打了就醒机制
	if not attacker:getHasHit(defender.data.posIndex) then
		if defender.data:checkHasOneBuffType(Fight.buffType_bingfeng) then
			-- 移除冰封buff
			defender.data:clearBuffByType(Fight.buffType_bingfeng)
		end 
	end
	--必须是第一次攻击才能击碎冰盾
	-- if atkData.isFirst then
	-- isFirst判断有问题，可能isFirst的攻击包可能只是打某个特殊位置那么其他位置的冰冻就无法被正确去除2017.8.14
	-- 冰冻现在不需要被打破了 2017.12.04
	if false and not attacker:getHasHit(defender.data.posIndex) then
		-- 检查是否有冰冻
		if defender.data:checkHasOneBuffType(Fight.buffType_bingdong) then
			-- 计算伤害
			local value,buffArr = defender.data:getOneBuffValue( Fight.buffType_bingdong )
			local changeType = buffArr[1].changeType or Fight.valueChangeType_num
			local dmg
			if changeType == Fight.valueChangeType_num then
				dmg = value
			else
				local initValue = defender.data:getInitValue(Fight.value_health)
				dmg = math.round(initValue * value / 10000)
			end
			echo("冰冻被击碎，造成额外伤害")
			--直接让防守者打碎冰盾
			defender.data:clearGroupBuff(Fight.buffType_bingdong )
			-- 冰冻被打碎要掉血走伤害
			AttackUseType:damageHit(Fight.damageResult_normal, dmg,attacker,defender, atkData, skill, true)
		elseif defender.data:checkHasOneBuffType(Fight.buffType_sleep) then
			defender.data:clearGroupBuff(Fight.buffType_sleep )
		end
	end
end
-- 1 打击
-- 说明: A:首先判断法宝能抵挡多少伤害; B 然后减血, C如果血量为零就直接跳过通过重创后仰击退来最后运行到死亡动作.
-- noChkHit 不进行技能攻击检查，避免循环伤害
function AttackUseType:damageHit(atkResult,damage,attacker,defender, atkData,skill,noChkHit)
	-- 检查与冰冻相关内容
	AttackUseType:checkBreakBuff(attacker,defender, atkData,skill)

	-- 起到治疗作用的生命护盾
	local value,dixiao = AttackUseType:calDiXiao(damage, defender, Fight.buffType_zlhudun)
	if dixiao > 0 then
		AttackUseType:addHp(atkResult,dixiao,attacker,defender, atkData,skill)
	end
	--伤害抵消
	value,dixiao = AttackUseType:calDiXiao(value, defender, Fight.buffType_hudun)

	-- 去掉最低能打出1点血的限制2017.11.21
	value =value <1 and 0 or value

	--如果是进攻的时候 被反击了 那么不致死（用回合判断有问题因为在switch模式下回合持有方可能是被攻击的）
	--2018.3.2 反击也可致死
	-- if defender ==defender.logical.attackingHero then
	-- 	if value >= defender.data:hp() then
	-- 		value = defender.data:hp() -1
	-- 	end
	-- end

	self:checkBomb(attacker, defender, atkData, skill, value)

	--改变血量是要抵消的
	local changeNum,realChangeNum = defender.data:changeValue(Fight.value_health , -value, 1, 0,nil,skill.atkType,skill.skillIndex)
	--进攻者也需要掉血
	local thornNum = AttackUseType:usedThorns( realChangeNum,attacker,defender, atkData,skill )

	--普通攻击或者格挡
	if atkResult == Fight.damageResult_normal or atkResult == Fight.damageResult_gedang   then
		AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_shanghai ,changeNum,1)
	else
		AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_baoji  ,changeNum,1)
	end

	-- onBeHit
	-- 受击者目前只检查被动技能
	local specialSkill = defender.data:getSpecialSkill()
	if specialSkill and specialSkill.skillExpand then
		specialSkill.skillExpand:onBeHit(attacker,defender,skill,atkData,atkResult,math.abs(realChangeNum))
	end
	
	if not noChkHit then
		if skill.skillExpand then
			skill.skillExpand:onHitHero(attacker,defender,skill,atkData,atkResult,realChangeNum)
		end
	end

	-- 如果是因为免疫而没有打出伤害，damage不计入记录，以此也可以保证总伤害不会显示
	if defender.data:isImmnueDmg(skill.atkType,skill.skillIndex) then
		damage = 0
	end

	-- 处理炎波buff
	if defender.data:checkHasOneBuffType(Fight.buffType_yanbo) then
		-- 记录伤害
		for _,buff in ipairs(defender.data:getBuffsByType(Fight.buffType_yanbo)) do
			buff:checkYanboTrigger(attacker,realChangeNum)
		end
	end

	--统计伤害---
	StatisticsControler:statisticsdamage(attacker,defender,skill,damage,-realChangeNum)
	if thornNum > 0 then
		-- 有反伤，也需要统计
		StatisticsControler:statisticsdamage(defender,attacker,skill,thornNum,thornNum)
	end
	defender:flash()

	-- 重伤
	AttackUseType:checkZhongShang(attacker,defender, atkData,skill)

	-- 标记已经伤害到
	attacker:setHasHit(defender.data.posIndex)
end

-- 检查重伤
function AttackUseType:checkZhongShang(attacker,defender, atkData,skill)
	-- 重伤状态最后一个攻击包下
	if not defender.hasHealthDied
	and defender.data:checkHasOneBuffType(Fight.buffType_zhongshang) 
	and atkData.isFinal == true
	then
		-- buff不叠加
		local buff = defender.data:getBuffsByType(Fight.buffType_zhongshang)[1]
		-- 计算伤害目标自身生命的百分比
		local baseHp = defender.data:hp()
		if buff.expandParams and buff.expandParams[1] == 2 then
			baseHp = defender.data:maxhp()
		end
		local dmg = math.round(baseHp * buff.value / 10000)
		dmg = Formula:getBuffLimitDmg(buff,dmg)
		local tmpAtkData = table.copy(atkData)
		-- 防止递归直接把一个人打死
		tmpAtkData.isFinal = false
		AttackUseType:damageHit(Fight.damageResult_normal, dmg,attacker,defender, tmpAtkData, skill)
	end
end

--反伤
function AttackUseType:usedThorns( damage,attacker,defender, atkData,skill )
	--判断反伤
	local thorns = defender.data:thorns()
	-- thorns = 3000
	--如果是没有反伤的 return
	if thorns == 0 then
		return 0
	end
	-- 检查增强反伤的buff
	local exValue = attacker.data:getOneBuffValue(Fight.buffType_huhun)
	local dmgThorn =  math.round(math.abs(damage * (thorns + exValue) /10000))

	if dmgThorn < 1 then 
		return 0 
	end

	if dmgThorn >= attacker.data:hp() then
		dmgThorn = attacker.data:hp()-1
	end
	-- if attacker.data:hp() <= 1 then
	-- 	dmgThorn = 0
	-- end
	if dmgThorn < 0 then
		return 0
	end
	-- 反伤buff
	local buffs = defender.data:getBuffsByType(Fight.buffType_fantan)
	if buffs then
		for _,buffObj in ipairs(buffs) do
			if buffObj:sta_expandAniArr() then
				-- 在攻击者身上做特效
				attacker:createEffGroup(buffObj:sta_expandAniArr(), false,true,attacker)
			end
		end
	end
	local changeNum, showNums = attacker.data:changeValue(Fight.value_health , -dmgThorn, 1, 0)
	AttackUseType:checkkMultyAttackEffect(attacker,atkData,Fight.hitType_shanghai ,showNums,1)
	return dmgThorn
end

--2
function AttackUseType:addHp(atkResult,hp,attacker,defender, atkData,skill)	
	--如果有无法恢复生命  return
	if defender.data:checkHasOneBuffType(Fight.buffType_nocureR ) then
		return
	end

	-- Fight.buffType_chuangshang
	--伤害抵消,如果有创伤效果,吸收治疗
	local value,dixiao = AttackUseType:calDiXiao(hp, defender, Fight.buffType_chuangshang)
	-- if value < 1 then return

	defender.data:changeValue(Fight.value_health,value,1,0)
	defender:checkHealth()
	AttackUseType:checkkMultyAttackEffect(defender,atkData,Fight.hitType_zhiliao ,value,1)
end

-- 净化或者驱散
function AttackUseType:purify(attacker,defender, atkData,skill,params)
	--净化
	local ptype = params[1]
	local ratio = params[2]
	
	local  random = BattleRandomControl.getOneRandomInt(10001, 1)
	if random<ratio then
		-- 个别技能有需求，检查驱散前的时机
		if skill.skillExpand then
			skill.skillExpand:onBeforePurify(attacker,defender,skill,atkData)
		end
		
		if ptype == 1 then
			defender.data:clearBuffByKind(Fight.buffKind_huai,false,true)
		elseif ptype == 2 then
			defender.data:clearBuffByKind(Fight.buffKind_hao,false,true)
		elseif ptype == 3 then
			echo("清除指定buff类型")
			local buffs = {unpack(params,3)}
			for _,bt in ipairs(buffs) do
				defender.data:clearBuffByType(bt,nil,nil,true)
			end
		end

		-- 净化触发成功播特效
		local aniArr = atkData:sta_aniArr()
		if aniArr then
			defender:createEffGroup(aniArr, false,true,attacker)
		end
	end
	
end

--作用buff
function AttackUseType:buffs(attacker,defender, atkData,skill,buffs)
	if buffs and #buffs >0 then
		--判断攻击包中的 specialAttack是否有触发概率
		local ratio = atkData:sta_specialRatio() or 10000

		if ratio < 10000 and BattleRandomControl.getOneRandomInt(10001, 1) > ratio then
			return
		end

		for i,v in ipairs(buffs) do
			defender:checkCreateBuff(v,attacker,skill)
		end
	end
	
end

function AttackUseType:expandLattice(attacker,defender, atkData,skill)
	if atkData:sta_buffs() then
		self:buffs(attacker,defender, atkData,skill,atkData:sta_buffs())
	end

	local aniArr = atkData:sta_aniArr()
	if aniArr then
		defender:createEffGroup(aniArr, false,true,attacker)
	end
end

-- 检查炸弹buff伤害记录
function AttackUseType:checkBomb(attacker, defender, atkData, skill, dmg)
	local buffs = defender.data:getBuffsByType(Fight.buffType_bomb)
	if buffs then
		for _,buff in ipairs(buffs) do
			if not buff.isRout then
				-- 将伤害记录下来
				buff._bombRecDmg = buff._bombRecDmg + dmg
				if buff._bombRecDmg >= tonumber(buff.expandParams[1]) then
					buff.isRout = true
				end
			end
		end
	end
end

-- 检查炸弹buff崩溃
function AttackUseType:checkBombRout(attacker, defender, atkData, skill)
	local buffs = defender.data:getBuffsByType(Fight.buffType_bomb)
	if buffs then
		for _,buff in ipairs(buffs) do
			if buff.isRout and atkData.isFinal then
				-- attacker.triggerSkillControler:pushOneSkillFunc(attacker, function( )
					defender.data:clearOneBuffObj(buff,true)
					local atkD = ObjectAttack.new(buff.expandParams[2])
					-- 可以给个final 因为执行这个的时候，主受击逻辑一定已经执行完了
					atkD.isFinal = true
					-- 借tempHero的手去触发
					local tempHero = buff.hero
					-- 放buff的人已经不在
					if not (tempHero and not tempHero.hasHealthDied) then
						-- 如果攻击者与受击者同阵营，在对面阵营选一个人来触发
						if attacker.camp == defender.camp then
							for _,hero in ipairs(defender.toArr) do
								if hero and not hero.hasHealthDied then
									tempHero = hero
									break
								end
							end
						else
							tempHero = attacker
						end
					end
					echo("做炸弹爆炸buff")
					tempHero:checkAttack(atkD, buff.skill, defender, true)
				-- end,20)
			end
		end
	end
end


return AttackUseType