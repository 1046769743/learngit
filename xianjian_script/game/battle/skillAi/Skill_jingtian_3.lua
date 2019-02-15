--[[
	Author:李朝野
	Date: 2017.07.29
]]

--[[
	景天

	技能描述：
	单体，并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	每次攻击的触发连击概率各不相同
	修改版：
	在上面的基础上，每有一个硬币增加一次必连击

	脚本处理部分：
	并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	每次攻击的触发连击概率各不相同

	参数：
	@@maxTimes 最大连击次数
	@@ratios 每次的触发概率 "1000_2000"这样配为了减少参数个数
	@@skills 每次成功触发播放的skillId "xxxxxx_xxxxxx"
	@@failSkill 判定失败时播放的skillId "xxxxxx"
]]
local Skill_jingtian_3 = class("Skill_jingtian_3", SkillAiBasic)


function Skill_jingtian_3:ctor(skill,id,maxTimes,ratios,skills,failSkill)
	Skill_jingtian_3.super.ctor(self, skill,id)
	
	self:errorLog(maxTimes, "maxTimes")
	self:errorLog(ratios, "ratios")
	self:errorLog(skills, "skills")
	self:errorLog(failSkill, "failSkill")

	self._maxTimes = tonumber(maxTimes) or 0
	self._ratios = string.split(ratios, "_")
	self._skills = string.split(skills, "_")
	self._failSkill = failSkill

	if self._maxTimes ~= #self._ratios then
		echoWarn("景天连击次数与配置概率次数不符")
	end

	if #self._skills ~= #self._ratios then
		echoError("景天连击技能个数与配置概率个数不符")
	end

	self._counter = 0 -- 当前连击次数
end

--[[
	景天在大招攻击后判断是否需要进行连续攻击
]]
function Skill_jingtian_3:onAfterSkill( selfHero,skill )
	-- 敌方没人了或达到最大次数或自己死了
	if #selfHero.toArr == 0 or self._counter >= self._maxTimes or selfHero.hasHealthDied then
		-- 检查完毕 次数清零
		self._counter = 0
		return true
	end
	local flag = false
	-- 获取必成功次数
	local smallSkill = selfHero.data:getSkillByIndex(Fight.skillIndex_small)
	local smallSkillExpand = smallSkill and smallSkill.skillExpand or nil

	if smallSkillExpand then
		-- 获取金币个数
		local count = smallSkillExpand:getRuneNum()
		if count > 0 then
			self:skillLog("景天有%s个硬币，使用一个", count)
			flag = true
			smallSkillExpand:useRune(1)
		end
	end

	local ratio = tonumber(self._ratios[self._counter + 1]) or 0
	-- 满足概率判定成功
	if flag or ratio > BattleRandomControl.getOneRandomInt(10001,1) then
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		self._counter = self._counter + 1
		-- 概率符合
		self:skillLog("景天第%d次连击概率%d判断有效",self._counter, ratio)

		self:_giveskill(self._skills[self._counter], true)

		return false
	else
		-- 未判定成功 播放一个失败技能次数清零
		self._counter = 0

		self:_giveskill(self._failSkill, false)

		-- return true
		return false
	end
end

--[[
	skillid 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_jingtian_3:_giveskill(skillid, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillid, 1, "A1", skill.skillParams)
	-- 加个特殊标记
	if self._failSkill == skillid then
		exSkill.__jtFail = true
	end
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())
	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	exSkill.isStitched = true

	-- 放技能
	selfHero:checkSkill(exSkill, false, skill.skillIndex)
end

--[[
	景天在大招杀死人之后终止连击
]]
function Skill_jingtian_3:onKillEnemy( attacker,defender )
	-- 直接把连击次数置为最大
	self._counter = self._maxTimes
end

--[[
	获取最大连击次数
]]
function Skill_jingtian_3:getMaxTimes()
	return self._maxTimes
end

return Skill_jingtian_3