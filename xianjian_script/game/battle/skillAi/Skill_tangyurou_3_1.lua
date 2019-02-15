--[[
	Author:李朝野
	Date: 2017.10.13
]]

--[[
	唐雨柔大招扩充1
	
	技能描述：
	为我方生命最低者进行一次额外治疗（50%），改技能系数取值为原技能系数的50%

	脚本处理部分：
	为生命最低者施加一个攻击包修改攻击包的伤害系数

	参数：
	atkId 加血攻击包
	rate 额外攻击包治疗比例
]]

local Skill_tangyurou_3_1 = class("Skill_tangyurou_3_1", SkillAiBasic)

function Skill_tangyurou_3_1:ctor(skill,id,atkId,rate)
	Skill_tangyurou_3_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")
	self:errorLog(rate, "rate")

	self._atkData = ObjectAttack.new(atkId)
	local rate = tonumber(rate or 0)

	self._atkData.dmgRatio = rate/10000
end

function Skill_tangyurou_3_1:onBeforeSkill(selfHero, skill)
	-- 找到血量最少的人
	local tHero = nil
	local min = nil
	for _,hero in ipairs(selfHero.campArr) do
		if not min then
			min = hero.data:getAttrPercent(Fight.value_health)
			tHero = hero
		end
		local hper = hero.data:getAttrPercent(Fight.value_health)
		if hper < min then
			min = hper
			tHero = hero
		end
	end
	-- 血量最少者
	selfHero:sureAttackObj(tHero,self._atkData,self._skill)
end

return Skill_tangyurou_3_1