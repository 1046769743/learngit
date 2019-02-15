--[[
	Author:李朝野
	Date: 2018.01.06
	Modify: 2018.03.12
]]

--[[
	主角法宝巫月神刀被动

	技能描述:
	每一次攻击均有6%的几率造成66%-666%之间的额外伤害；（纯随机，各数概率等）

	脚本处理部分:
	根据概率附加伤害

	参数:
	@@ratio 触发概率
	@@section 伤害区间（万分 a_b）
	@@atkIdK 触发特效的攻击包（不应有实际逻辑，只有表现特效）
]]
local Skill_wuyueshendao_4 = class("Skill_wuyueshendao_4", SkillAiBasic)

function Skill_wuyueshendao_4:ctor(skill,id, ratio, section, atkIdK)
	Skill_wuyueshendao_4.super.ctor(self,skill,id)

	self:errorLog(ratio, "ratio")
	self:errorLog(section, "section")
	self:errorLog(atkIdK, "atkIdK")

	self._ratio = tonumber(ratio or 0)
	self._section = string.split(section, "_")

	table.map(self._section, function(v,k)
		return tonumber(v)
	end)

	self._atkIdK = ObjectAttack.new(atkIdK)
end

-- 计算伤害时做检查
function Skill_wuyueshendao_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 附加伤害的判断
	if self._ratio >= BattleRandomControl.getOneRandomInt(10001,1) then
		local rate = BattleRandomControl.getOneRandomInt(self._section[2] + 1, self._section[1])
		self:skillLog("巫月神刀触发，附加伤害比率:%s",rate)

		dmg = dmg + math.round(attacker.data:atk() * rate / 10000)
		-- 表现攻击包
		attacker:sureAttackObj(defender,self._atkIdK,self._skill)
	end

	return dmg
end

return Skill_wuyueshendao_4