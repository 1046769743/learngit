--[[
	Author:李朝野
	Date: 2017.06.29
]]

--[[
	真身重楼

	技能描述：
	对敌方单体造成伤害，并根据目标当前怒气值，附加额外伤害；
	若此次攻击造成击杀，则溢出伤害转嫁至敌方生命比例最高者。（额外的特效表现）
	转移的溢出伤害也会根据当前目标的怒气量进行伤害提升，其比例效果等同于第一次释放怒气技能；

	脚本处理部分：
	对敌方单体造成伤害，并根据目标当前怒气值，附加额外伤害；
	若此次攻击造成击杀，则溢出伤害转嫁至敌方生命比例最高者。
	转移的溢出伤害也会根据当前目标的怒气量进行伤害提升，其比例效果等同于第一次释放怒气技能；

	参数：
	@@dmgRate 怒气转换伤害的比率
	@@atkId 溢出伤害的攻击包
]]

local Skill_zhenshenchonglou_3_1 = class("Skill_zhenshenchonglou_3_1", SkillAiBasic)

function Skill_zhenshenchonglou_3_1:ctor( ... )
	Skill_zhenshenchonglou_3_1.super.ctor(self, ...)
end

function Skill_zhenshenchonglou_3_1:onCheckAttack( attacker,defender,skill,atkData,dmg )
	if atkData._zhenshenchonglou then -- 真身重楼特殊攻击包
		-- 伤害使用溢出伤害 不使用计算的伤害
		dmg = self._overDmg

		self._overDmg = 0
		self._overAtk = false
		self:skillLog("重楼对%d号位造成%d伤害，此伤害为溢出伤害。",defender.data.posIndex, dmg)
	end
	-- 计算怒气加成伤害
	dmg = self:calExEnergydmg(defender, dmg)

	--[[
		计算溢出伤害
		考虑护盾
	]]
	self:calOverDmg(defender, dmg)

	return dmg
end

return Skill_zhenshenchonglou_3_1