--[[
	Author:李朝野
	Date: 2017.07.26
	Modify: 2017.10.09
]]
--[[
	龙幽被动

	技能描述：
	攻击附带概率灼烧效果，并且如果攻击带有灼烧效果的敌人，获得额外怒气（每次攻击仅获得1次）；
	修改：攻击已经处于灼烧效果的敌人，立刻进行一次灼烧效果伤害

	脚本处理部分：
	攻击附带概率灼烧效果，并且如果攻击带有灼烧效果的敌人，获得额外怒气（每次攻击仅获得1次）；
	修改：攻击已经处于灼烧效果的敌人，立刻进行一次灼烧效果伤害

	参数：
	atkId1 带有灼烧buff的攻击包
	atkId2 带有灼烧buff的攻击包（立刻执行的）
]]
-- 2017.11.21 pangkangning 去掉atkId2
local Skill_longyou_4 = class("Skill_longyou_4", SkillAiBasic)

function Skill_longyou_4:ctor(skill,id,atkId1)
	Skill_longyou_4.super.ctor(self, skill, id)

	self:errorLog(atkId1, "atkId1")
	-- self:errorLog(atkId2, "atkId2")

	self._atkData1 = ObjectAttack.new(atkId1)
	-- self._atkData2 = ObjectAttack.new(atkId2)

	-- 记录是否获加过buff
	self._flag = {}
end

function Skill_longyou_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 判断是否攻击了有灼烧的人
	-- if not self._flag[defender] and defender.data:checkHasOneBuffType(Fight.buffType_zhuoshao) then
	-- 	self._flag[defender] = true

	-- 	self:skillLog("龙幽被动对%s号位施加立刻灼烧攻击包",defender.data.posIndex)
	-- 	-- 给受击者加一个带buff的攻击包
	-- 	attacker:sureAttackObj(defender, self._atkData2, self._skill)
	-- end

	self:skillLog("龙幽被动对%s号位施加概率灼烧攻击包",defender.data.posIndex)
	-- 给受击者加一个带buff的攻击包
	attacker:sureAttackObj(defender, self._atkData1, self._skill)

	return dmg
end

--[[
	攻击完成后重置一下自己加buff的
]]
function Skill_longyou_4:willNextAttack( attacker )
	if not self:isSelfHero(attacker) then return end
	self._flag = {}
end

return Skill_longyou_4