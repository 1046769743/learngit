--[[
	Author:李朝野
	Date: 2017.08.23
]]

--[[
	狐妖女大招扩充1

	技能描述:
	单体，概率魅惑（眩晕），持续一回合；
	如果敌方身上带有忘魂效果，则必定控制;
	并且当狐妖女释放怒气技能后，未造成眩晕效果，则降低敌人一定攻击力，持续两回合；
	
	脚本处理部分：
	并且当狐妖女释放怒气技能后，未造成眩晕效果，则降低敌人一定攻击力，持续两回合；

	参数：
	ratio 眩晕概率
	atkId 必定控制的攻击包id（眩晕）
	atkId1 降低攻击力的攻击包id
]]
local Skill_huyaonv_3 = require("game.battle.skillAi.Skill_huyaonv_3")
local Skill_huyaonv_3_1 = class("Skill_huyaonv_3_1", Skill_huyaonv_3)

function Skill_huyaonv_3_1:ctor(skill,id, ratio, atkId, atkId1)
	Skill_huyaonv_3_1.super.ctor(self, skill, id, ratio, atkId)

	self:errorLog(atkId1, "atkId1")

	self._atkData1 = ObjectAttack.new(atkId1)
end

--[[
	最后一个攻击包决定是否眩晕对方
]]
function Skill_huyaonv_3_1:onAfterAttack(attacker,defender,skill,atkData)
	-- 做父类方法并且获得,是否眩晕了
	local flag = Skill_huyaonv_3_1.super.onAfterAttack(self, attacker,defender,skill,atkData)
	-- 未眩晕降低敌人攻击力
	if not flag then
		self:skillLog("狐妖女大招扩充对阵营%s %s号位做攻击包",defender.camp,defender.data.posIndex)
		attacker:sureAttackObj(defender,self._atkData1, self._skill)
	end

	return flag
end

return Skill_huyaonv_3_1