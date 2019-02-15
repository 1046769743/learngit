--[[
	Author:李朝野
	Date: 2018.01.08
]]

--[[
	暮菖兰大招扩充1

	技能描述:
	延长目标所受到的流血、灼烧、中毒、忘魂延长一回合；
	
	脚本处理部分:
	延长目标类型buff的作用时长；

	参数:
	@@buffs 目标buff类型 2_3 （脚本里会额外判断是否为持续类型）
	@@exRound 延长回合数
]]
local Skill_muchanglan_3_1 = class("Skill_muchanglan_3_1", SkillAiBasic)

function Skill_muchanglan_3_1:ctor(skill,id, buffs, exRound)
	Skill_muchanglan_3_1.super.ctor(self,skill,id)

	self:errorLog(buffs, "buffs")
	self:errorLog(exRound, "exRound")

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
  		return tonumber(v)
  	end)

  	self._exRound = tonumber(exRound or 0)
end

-- 延长受击者目标buff类型的回合数
function Skill_muchanglan_3_1:onCheckAttack(attacker,defender,skill,atkData, dmg)
	self:skillLog("暮菖兰大招扩充1，将延长阵营:%s,%s号位身上相关buff%s回合",defender.camp,defender.data.posIndex,self._exRound)
	for _,bt in ipairs(self._buffs) do
		-- 续self._exRound回合
		defender.data:extendBuffByType(bt, self._exRound)
	end

	return dmg
end

return Skill_muchanglan_3_1