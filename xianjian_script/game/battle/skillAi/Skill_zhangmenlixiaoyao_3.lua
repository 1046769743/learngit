--[[
	Author:李朝野
	Date: 2017.10.23
]]


--[[
	掌门李逍遥大招

	技能描述：
	召唤天罡剑阵，持续三回合或直至天罡剑阵存在期间战场内有一名敌方角色阵亡；
	天罡剑阵存在期间，降低掌门李逍遥己方全体防御力，但每当我方放大招后，掌门李逍遥便原地进行一次御剑术协助攻击（AOE则攻击多人）；
	——天罡剑阵存在，掌门李逍遥需要独特的待机动作+自身环绕特效以示区别

	脚本处理部分：
	放大招之后开始记回合，如果处于剑阵状态下就做协助攻击，剑阵失效后清除减防buff。

	参数：
	skillId 协助技的Id
	round 持续回合
	buffId 技能提前结束时需要清理的buffId
]]
local Skill_zhangmenlixiaoyao_3 = class("Skill_zhangmenlixiaoyao_3", SkillAiBasic)

function Skill_zhangmenlixiaoyao_3:ctor(skill,id,skillId,round,buffId)
	Skill_zhangmenlixiaoyao_3.super.ctor(self, skill, id)
	
	self:errorLog(skillId, "skillId")
	self:errorLog(round, "round")
	self:errorLog(buffId, "buffId")

	self._assitSkill = skillId
	self._round = tonumber(round or 0)
	self._buffId = tonumber(buffId or 0)

	self._count = 0 -- 记录回合
	self._hitHero = {} -- 记录需要攻击的人
end

--我方回合开始前
function Skill_zhangmenlixiaoyao_3:onMyRoundStart(selfHero )
	if not self:isSelfHero(selfHero) then return end

	if self._count > 0 then
		self._count = self._count - 1
		if self._count == 0 then
			self:_resetCount()
		end
	end
end

--[[
	有人某次攻击完，存自己将要攻击的人
]]
function Skill_zhangmenlixiaoyao_3:willNextAttack(attacker )
	-- 不在大招状态下
	if self._count == 0 then return end
	-- 不是自己
	if self:isSelfHero(attacker) then return end
	local selfHero = self:getSelfHero()
	-- 不是自己队友
	if selfHero.camp ~= attacker.camp then return end

	-- 先清空以前的记录，再重新记录本次攻击到的人
	self._hitHero = {}

	-- 敌人
	local toArr = attacker.toArr

	for _,hero in ipairs(toArr) do
		-- 此人被打到过
		if attacker:getHasHit(hero.data.posIndex) then
			table.insert(self._hitHero, hero)
		end
	end
end

--[[
	获取要打的人的方法
]]
function Skill_zhangmenlixiaoyao_3:getEnemyArr()
	return self._hitHero
end

-- 敌方死人提前结束
function Skill_zhangmenlixiaoyao_3:onOneHeroDied(attacker, defender)
	local selfHero = self:getSelfHero()
	-- 敌人死亡提前结束
	if selfHero.camp ~= defender.camp then
		self:_resetCount()
	end
end

--重置技能状态
function Skill_zhangmenlixiaoyao_3:_resetCount()
	local selfHero = self:getSelfHero()
	self._count = 0
	self._hitHero = {}
	selfHero:setUseSpStand(false)
	-- 清理我方buff
	for _,hero in ipairs(selfHero.campArr) do
		hero.data:clearOneBuffByHid(self._buffId)
	end
end

--[[
	放大招之后把回合数重置
]]
function Skill_zhangmenlixiaoyao_3:onAfterSkill(selfHero, skill)
	self._count = self._round
	-- 修改待机标记
	selfHero:setUseSpStand(true)

	return true
end

--[[
	检查协助攻击
]]
function Skill_zhangmenlixiaoyao_3:chkAssistAttack(lastHero,lastSkillIndex)
	-- 如果是自己不进行协助攻击
	if self:isSelfHero(lastHero) then return false end
	if self._count == 0 then return false end

	local result,skill = false,nil
	-- 有要打的人（为了保险做一次筛选）
	if #self._hitHero > 0 then
		for i=#self._hitHero,1,-1 do
			local hero = self._hitHero[i]
			if not SkillBaseFunc:isLiveHero(hero) then
				table.remove(self._hitHero, i)
			end
		end
	end

	if #self._hitHero > 0 then
		result = true
		skill = self:_getSkill(self._assitSkill, false)
	end

	return result,skill
end
--[[
	skillid 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_zhangmenlixiaoyao_3:_getSkill(skillid, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillid, {}, "A1", skill.skillParams)

	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), 0)
	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	return exSkill
end

return Skill_zhangmenlixiaoyao_3