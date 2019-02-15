--
-- Author: xd
-- Date: 2017-02-21 16:34:21
--
SkillAiBasic = class{"SkillAiBasic"}


function SkillAiBasic:ctor(skill,id,... )
	self._expandId = id
	self._skill = skill

	self._frameFunc = {} -- 注册到技能序列中执行的函数
	--[[
		{
			{
				func = 
				frame = 
			},
			{
				
			}
		}
	]]
end



--执行ai chance,时机,
function SkillAiBasic:excuteAi(... )
	if self.trigChance ~= chance then
		return
	end
end

--[[
	会在技能脚本关联人物的时候执行
	可以用于注册一些一开始就要进行监听的事件等
]]
function SkillAiBasic:onSetHero(selfHero)
	-- 子类重写
end

--判断能否执行
function SkillAiBasic:checkCanExcute( chance )
	return self.trigChance == chance
end

-- 判断伤害类型前（damageResult）
function SkillAiBasic:onBeforeDamageResult(attacker,defender,skill,atkData)
	
end

--当进行攻击检测时 对一个人 整个技能过程中只检测一次
--默认是什么都不做 但是一定要返回新伤害
function SkillAiBasic:onCheckAttack(attacker,defender,skill,atkData, dmg)
	return dmg
end

--当被攻击时检查改变伤害（区别于onCheckAttack，是进攻方检查）
function SkillAiBasic:onCheckBeAttack(attacker,defender,skill,atkData, dmg)
	return dmg
end

--当进行加血检测是，对一个人 整个技能过程中可能检测多次
--默认是什么都不做 但是一定要返回新治疗值
function SkillAiBasic:onCheckTreat(attacker,defender,skill,atkData, dmg)
	return dmg
end

-- 驱散前
function SkillAiBasic:onBeforePurify(attacker,defender,skill,atkData)
	-- body
end

--在攻击之前 检测   对一个人 整个技能过程中只检测一次
function SkillAiBasic:onBeforeAttack(attacker,defender,skill,atkData )
	return 
end

--[[
	攻击敌人过程中（单次伤害）
	注意如果在这个函数里对其他人做伤害行为要检查死亡情况
]]
function SkillAiBasic:onHitHero(attacker,defender,skill,atkData,atkResult,dmg)
	
end

--[[
	受击过程中
	*注意 掉血后检查 无法改变伤害量
]]
function SkillAiBasic:onBeHit(attacker,defender,skill,atkData,atkResult,dmg)

end

--攻击判定之后
function SkillAiBasic:onAfterAttack(attacker,defender,skill,atkData)
	return 
end

--[[
	在buff value 被作用之前 (doBuffFunc)
	**注意 value是经过其他计算的value，不要直接返回 buffObj.value
]]
function SkillAiBasic:onBuffBeDo(value, changeType, buffObj)
	return value,changeType
end

--[[
	被加buff之前，返回是否可以加此buff
]]
function SkillAiBasic:onBeforeUseBuff( selfHero,attacker,skill,buffObj )
	return true
end

--[[
被上buff
@selfHero ：被种buff的人
@attacker:  施加buff的
@skill:     buff所在的skill
@buffObj
备注，只在被动技有效
]]
function SkillAiBasic:onBeUseBuff( selfHero,attacker,skill,buffObj)
	-- body
end

--[[
	某个人被上buff
	@@attacker 施加buff的人
	@@defender 被施加buff的人
	@@skill 技能
	@@buffObj 施加的buffObj
	备注，所有有技能脚本的人都能收到
]]
function SkillAiBasic:onOneBeUseBuff(attacker, defender, skill, buffObj)

end

--[[
	被删除buff
	只在被动技有效
	这里目前只能拿到
	selfHero
	buffObj
]]
function SkillAiBasic:onBuffBeClear( selfHero, buffObj )

end

--我击杀目标后
function SkillAiBasic:onKillEnemy( attacker,defender )
	
end

--有人击杀目标后
--[[
	理论上讲attacker伤害来源是有可能为空的
]]
function SkillAiBasic:onOneHeroDied(attacker, defender )
	-- body
end

--当有人行动的时候 targetHero 是行动的英雄
function SkillAiBasic:onHeroStartAttck(selfHero, targetHero, skill)
	
end


--我方回合开始前
function SkillAiBasic:onMyRoundStart(selfHero )
	
end

--我方回合结束后
function SkillAiBasic:onMyRoundEnd(selfHero)
	
end

--[[
	召唤时机
]]
function SkillAiBasic:onDoSummon(selfHero, atkData)
	local summonInfo = atkData:sta_summon()
	for i,v in ipairs(summonInfo) do
		local hero = selfHero:summonOneTarget(v)
		if hero and atkData:sta_aniArr() then
			hero:createEffGroup(atkData:sta_aniArr(),false,nil,selfHero)
		end
	end
	--然后排序
	selfHero.logical:sortCampPos(selfHero.camp)
end

--[[
地方回合前
]]
function SkillAiBasic:onEnemyRoundStart(selfHero)
	
end

-- 敌方回合结束后
function SkillAiBasic:onEnemyRoundEnd(selfHero)
	-- body
end


--当我即将要触发被击 
function SkillAiBasic:onBeforeHited(selfHero,attacker,skill,atkData )
	-- body
end


--被击之后
function SkillAiBasic:onAfterHited( selfHero,attacker,skill,atkData )
	

end

--第一回合开始前,比如有些人要做施法 有些人要使用光环
function SkillAiBasic:onBattleStart( selfHero )
	
end


--频临死亡 下一次受击将会死亡的时候 触发  
--2017.10.9这个方法不能用，因为人会不会死不仅仅受技能的纯伤害影响
function SkillAiBasic:beforeWillDied(selfHero,willDiedHeroes,damage )
	
end

--真正死亡之前
function SkillAiBasic:beforeRealDied(attacker, defender)
	-- body
end

--即将进行 攻击完毕判定时候
function SkillAiBasic:willNextAttack(attacker )
	
end



--[[
	技能被触发后
	返回技能结束后是否要返回原位
]]
function SkillAiBasic:onAfterSkill(selfHero,skill)
	return true
end

--释放技能之前(技能被确定之前ModelAutoFight:checkSkill)需要返回skill
function SkillAiBasic:onBeforeCheckSkill(selfHero,skill)
	return skill
end

--技能被出发前

function SkillAiBasic:onBeforeSkill(selfHero, skill)
	
end

--[[
	检查协助攻击
	@@lastHero 刚刚完成攻击的hero
	@@lastSkillIndex 刚刚释放的技能index
	return result是否有协助攻击,tSkill要释放的技能
]]
function SkillAiBasic:chkAssistAttack(lastHero,lastSkillIndex)
	return false,nil
end

-- 判断是不是自己的人物
function SkillAiBasic:isSelfHero( targetHero )
	return self._skill.heroModel == targetHero
end

-- 获取自己的人物
function SkillAiBasic:getSelfHero()
	return self._skill.heroModel
end

-- 获取和本技能相关的buff
function SkillAiBasic:getBuff(buffId, skill)
	local tskill = skill or self._skill
	return ObjectBuff.new(buffId, tskill)
end

-- （处理value）获取需要从技能参数中读取的值
function SkillAiBasic:checkValue(value)
	if not value then 
        return  
    end

    local result = tonumber(value)

    if not result then
        result = self._skill:getSkillParamsByValue(value, string.format("技能:%s的脚本",self._skill.hid))
    end

    return result
end

-- 神器使用，返回是否该释放技能，子类重写
-- applyType 作用类型
-- chance 1回合开始前 2回合结束后
function SkillAiBasic:artifactCanUse(applyType, currentCamp, chance)
	if applyType == Fight.atSkill_applyType_manual then
		return self:manualArtifactCanUse()
	else -- Fight.atSkill_applyType_auto
		return self:autoArtifactCanUse(currentCamp, chance)
	end
end

-- 神器使用，返回是否该释放技能，子类重写
-- chance 1回合开始前 2回合结束后
function SkillAiBasic:autoArtifactCanUse(currentCamp, chance)
	return false
end

function SkillAiBasic:manualArtifactCanUse(...)
	return false
end
--[[
	释放一个技能（有些脚本里自己写了，由于使用频率较高，现在在父类方法里加一个）
	@@skillid 技能id
	@@isExpand 是否继承扩展性为
	@@isStitched 是否作为拼接技能
]]
function SkillAiBasic:_giveSkill(skillid, isExpand, isStitched)
	local selfHero = self:getSelfHero()
	local skill = self._skill

	local exSkill = self:_getExSkill(skillid, isExpand)

	if isStitched then
		exSkill.isStitched = true
	end

	-- 放技能
	selfHero:checkSkill(exSkill, false, skill.skillIndex)
end
--[[
	获取一个技能
]]
function SkillAiBasic:_getExSkill(skillid, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	
	-- 新获得一个技能（伤害系数走原技能的）
	local exSkill = ObjectSkill.new(skillid, {}, "A1", skill.skillParams)
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())
	exSkill.skillIndex = skill.skillIndex

	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	return exSkill
end

-- 是否应用来自脚本的额外buff值
function SkillAiBasic:isUseBuffEx(buffId)
	-- 默认不应用
	return false
end

-- 获取buff额外的value值
function SkillAiBasic:getBuffExValue(buffId)
	return 0
end

-- 获取buff额外的ratio值
function SkillAiBasic:getBuffExRatio(buffId)
	return 0
end

-- 获取buff额外的calValue(按属性取值的buff用的值)
function SkillAiBasic:getBuffExCalValue(buffId)
	-- return rate,n
	return 0,0
end

--[[
	注册方法到技能帧序列中（为了满足策划对于表现的需求）
	慎用，需要仔细考虑战斗复盘问题，方法里不应该做攻击包的伤害
	@@frame 执行帧数
	@@func 执行的函数 func(attacker, skill, frame)
]]
function SkillAiBasic:registSkillFunc(frame, func)
	self._frameFunc[#self._frameFunc + 1] = {
		frame = frame,
		func = func,
		skillfunc = true,
	}

	table.sort(self._frameFunc, function(a,b)
		return a.frame < b.frame
	end)
end

-- 获取技能帧事件
function SkillAiBasic:getAllSkillFunc()
	return self._frameFunc
end

-- 神力使用，返回攻击范围或处理某些技能参数
--[[
	技能需要的参数（type table根据技能而定）
	例{
		hero = model -- 主目标（比较特殊的雾魂神力是两人换位）
	}
]]
-- 注，由于神器选敌方式是以用户输入为依据，修改现有逻辑不容易实现，放在脚本里做选敌，正常技能不要使用
-- 如果重写就不要再返回 nil了 因为选敌可能会产生缓存，主动释放和被动释放不同
function SkillAiBasic:getSpiritSkillArr(params)
	return nil
end
----------------- 功能函数 --------------
function SkillAiBasic:errorLog( var, des )
	if not var then
		echoError(self._skill.hid, self._expandId, "没有配置", des)
	end
end

function SkillAiBasic:skillLog( ... )
	if Fight.isOpenFightLogs   then
		echo(...)
	end
end