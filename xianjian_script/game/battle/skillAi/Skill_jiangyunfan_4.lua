--[[
	Author:李朝野
	Date: 2017.07.26
]]
--[[
	姜云凡被动

	技能描述：
	姜云凡自身免疫持续类伤害，并且使攻击时，概率附加流血效果；

	脚本处理部分：
	姜云凡免疫持续类伤害，攻击时概率附加流血效果；

	参数：
	rate 附加流血效果概率
	atkId 流血攻击包id
	buffs 姜云凡免疫的buff类型 2_3 （脚本里会额外判断是否为持续类型）
]]
local Skill_jiangyunfan_4 = class("Skill_jiangyunfan_4", SkillAiBasic)

function Skill_jiangyunfan_4:ctor(skill,id,rate,atkId,buffs)
	Skill_jiangyunfan_4.super.ctor(self, skill, id)

	self:errorLog(rate, "rate")
	self:errorLog(atkId, "atkId")
	self:errorLog(buffs, "buffs")

	self._rate = tonumber(rate) or 0
	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
	
	self._atkData = ObjectAttack.new(atkId)
end

--攻击时概率附加流血效果
function Skill_jiangyunfan_4:onCheckAttack( attacker,defender,skill,atkData, dmg )
	if self._rate > BattleRandomControl.getOneRandomInt(10001,1) then
		self:skillLog("姜云凡被动触发，对%s号位应用攻击包", defender.data.posIndex)
		attacker:sureAttackObj(defender, self._atkData, self._skill)
	end

	return dmg
end

--[[
	姜云凡免疫持续类伤害
	满足免疫buff类型并且执行时机为本方回合开始前的2
]]
function Skill_jiangyunfan_4:onBeforeUseBuff(selfHero, attacker, skill, buffObj)
	local result = true
	-- 满足条件
	if buffObj.runType == Fight.buffRunType_round and array.isExistInArray(self._buffs, buffObj.type) then
		self:skillLog("姜云凡被动阻止buff%s生效", buffObj.hid)
		result = false
	end

	return result
end





return Skill_jiangyunfan_4