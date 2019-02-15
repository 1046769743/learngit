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
	在一场战斗内，魔尊重楼每释放一次大招，则会提升下一次大招的伤害，效果累计；

	脚本处理部分：
	对敌方单体造成伤害，并根据目标当前怒气值，附加额外伤害；
	若此次攻击造成击杀，则溢出伤害转嫁至敌方生命比例最高者。
	转移的溢出伤害也会根据当前目标的怒气量进行伤害提升，其比例效果等同于第一次释放怒气技能；
	在一场战斗内，魔尊重楼每释放一次大招，则会提升下一次大招的伤害，效果累计；

	参数：
	@@dmgRate 怒气转换伤害的比率
	@@atkId 溢出伤害的攻击包
	@@elevateRate 每次提升伤害的比率
]]

local Skill_zhenshenchonglou_3_2 = class("Skill_zhenshenchonglou_3_2", SkillAiBasic)

function Skill_zhenshenchonglou_3_2:ctor( skill,id,dmgRate, atkId, elevateRate )
	Skill_zhenshenchonglou_3_2.super.ctor(self,skill,id,dmgRate,atkId)

	self:errorLog(elevateRate, "elevateRate")

	self._elevateRate = tonumber(elevateRate) or 0
	self._maxTimes = 0 -- 记录释放大招次数
end

function Skill_zhenshenchonglou_3_2:onCheckAttack( attacker,defender,skill,atkData,dmg )
	-- 先根据大招次数增加伤害
	dmg = dmg + dmg * self._elevateRate / 10000 * self._maxTimes
	self:skillLog("重楼当前释放大招次数:%d,加成后伤害:%d", self._maxTimes, dmg)
	if not atkData._zhenshenchonglou then
		-- 不是重楼溢出伤害的攻击包，增加大招累计次数
		self._maxTimes = self._maxTimes + 1
	end
	-- 再处理其他内容
	dmg = Skill_zhenshenchonglou_3_2.super.onCheckAttack(self,attacker,defender,skill,atkData,dmg)
	
	return dmg
end

return Skill_zhenshenchonglou_3_2