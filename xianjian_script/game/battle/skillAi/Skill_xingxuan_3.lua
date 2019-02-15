--[[
	Author:李朝野
	Date: 2017.09.15
	Modify: 2017.10.20
	Modify: 2018.03.10
]]


--[[
	星璇大招

	技能描述：
	若目标生命低于50%，播放另一个技能，并造成额外伤害；

	脚本处理部分：
	大招会有两段，第一段之前要判断血量决定第二段放哪个技能；
	2017.11.14 pangkangning修改
	若目标生命低于50%，则附加自身一定攻击力万分比的额外伤害；需要做逻辑判断：
	在技能A攻击时，判断目标被技能A攻击前血量，如果高于某一个万分比（配置），则播放技能B，不然放技能C；
	大招扩充2:如果自己血线高于对手，则附加提升伤害系数（万分比）
	参数：
	hpper 血限，万分
	skills 额外技能"xxx_xxx" 1弱2强
	atkId 表现攻击包的Id
]]
local Skill_xingxuan_3 = class("Skill_xingxuan_3", SkillAiBasic)

function Skill_xingxuan_3:ctor(skill,id, hpper, skills,atkId)
	Skill_xingxuan_3.super.ctor(self, skill, id)
	
	self:errorLog(hpper, "hpper")
	self:errorLog(skills, "skills")
	self:errorLog(atkId, "atkId")

	self._hpPer = tonumber(hpper or 0) / 10000
	self._skills = string.split(skills, "_")
	self._atkData = ObjectAttack.new(atkId)

	-- 记录第二段要释放的技能，敌人死亡则不放
	self._secondSkill = nil
end

--[[
	在第一个空攻击包收到的时候就进行检查
]]
function Skill_xingxuan_3:onBeforeDamageResult(attacker,defender,skill,atkData)
	local hpPer = defender.data:hp() / defender.data:maxhp()

	if hpPer <= self._hpPer and skill ~= self._skill then
		-- 不是最弱的技能，播一个特效
		attacker:sureAttackObj(attacker,self._atkData,self._skill)
	end
end

--[[
	打血前检查生命值
]]
function Skill_xingxuan_3:onCheckAttack(attacker,defender,skill,atkData, dmg)
	local hpPer = defender.data:hp() / defender.data:maxhp()

	if hpPer <= self._hpPer then
		self:skillLog("阵营%s,%s号位生命低于:%s",defender.camp,defender.data.posIndex,self._hpPer/10000)
		self._secondSkill = self._skills[2]
	else
		self._secondSkill = self._skills[1]
	end

	return dmg
end

--[[
	在大招杀死人之后终止连击
]]
function Skill_xingxuan_3:onKillEnemy( attacker,defender )
	-- 直接把标记置空
	self._secondSkill = nil
end

--[[
	第一段大招后做判断
]]
function Skill_xingxuan_3:onAfterSkill( selfHero,skill )
	local result = true
	-- 记录了技能就释放
	if self._secondSkill then
		local tskill = self._secondSkill
		self._secondSkill = nil
		self:_giveSkill(tskill, false)

		result = false
	end

	return result
end

--[[
	skillid 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_xingxuan_3:_giveSkill(skillid, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillid, 1, "A1", skill.skillParams)

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

return Skill_xingxuan_3