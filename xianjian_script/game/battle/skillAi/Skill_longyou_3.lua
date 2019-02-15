--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2017.11.07 pangkangning
	Modify: 2017.11.19 pangkangning
	Modify: 2017.12.29 lcy
	Modify: 2018.01.04 lcy
]]

--[[
	龙幽
	描述，对有额外状态的人有额外表现和额外伤害

	脚本处理部分：
	对有配置buff的人在技能结束后，如果有特殊buff中的一个则释放配置技能，否则释放另一个技能
	（配置技能不应该配伤害的攻击包，应该用buff，否则伤害无法控制）

	参数：
	buffs 需要检查的buff类型 xx_xx_xx
	skillId 额外释放的技能Id
	failSkillId 判定失败释放的技能Id
]]

local Skill_longyou_3 = class("Skill_longyou_3", SkillAiBasic)

function Skill_longyou_3:ctor(skill,id,buffs,skillId,failSkillId)
	Skill_longyou_3.super.ctor(self, skill, id)
	
	self:errorLog(buffs, "buffs")
	self:errorLog(skillId, "skillId")

	-- 某种buff类型
	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)

	self._skillId = tonumber(skillId or self._skill.hid)
	self._failSkillId = tonumber(failSkillId or self._skill.hid)

	self._count = 0 -- 记录追击次数（现在不需要多次了，但是先保留这个字段了）
	self._first = true -- 记录是否是第一次检查，防止无限循环释放
	self._aHero = nil -- 记录受击人物，龙幽大招为单体，需要记录受击者，受击者死后不能再追加，否则会攻击额外目标
end

--[[
	大招对中了配置类型buff角色造成额外伤害
]]
function Skill_longyou_3:onCheckAttack( attacker,defender,skill,atkData,dmg )
	-- 只有第一个大招检查
	if self._first then
		self._first = false
		for _,v in ipairs(self._buffs) do
			if defender.data:checkHasOneBuffType(v) then
				self._count = self._count + 1
				break
			end
		end
		self._aHero = defender
	end

	return dmg
end
--[[
function Skill_longyou_3:onAfterAttack(attacker, defender, skill, atkData)
	-- 判断角色是否有 灼烧、中毒、流血
	for i,v in ipairs(self._buffs) do
		local buffArr = defender.data:getBuffsByType(v)
		if buffArr then
			for m,n in ipairs(buffArr) do
				self:skillLog("龙幽大招对灼烧、流血角色造成额外伤害")
				attacker:sureAttackObj(defender, self._atkData, self._skill)
			end
		end
	end
end
]]

-- 杀敌重置追杀的行为
function Skill_longyou_3:onKillEnemy( attacker,defender )
	if not self:isSelfHero(attacker) then return end

	self._count = 0
	self._aHero = nil
end

--[[
	龙幽在回合后判断是否需要追加几个技能
]]
function Skill_longyou_3:onAfterSkill(selfHero, skill)
	if skill.__lyFail then
		self._count = 0
		self._first = true
		self._aHero = nil

		return true
	end

	if self._count > 0 then
		self._count = self._count - 1

		self:skillLog("龙幽回合后进行追加，还有:%s次", self._count)
		self:_giveSkill(self._skillId, true)

		return false
	else
		self:skillLog("龙幽释放判定失败的技能")
		self:_giveSkill(self._failSkillId, true)

		return false
	end
end

--[[
	skillId 放的技能skillId
	isExpand 是否继承扩展行为
]]
function Skill_longyou_3:_giveSkill(skillId, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillId, 1, "A1", skill.skillParams)
	-- 加个特殊标记接了一段技能之后一定没有下一段
	-- if self._failSkillId == skillId then
		exSkill.__lyFail = true
	-- end
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())

	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end
	-- 放技能
	selfHero:checkSkill(exSkill, false, skill.skillIndex)

	return exSkill
end

return Skill_longyou_3