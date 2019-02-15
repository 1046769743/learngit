--[[
	Author:李朝野
	Date: 2017.07.26
	Modify:	2017.10.12
]]
--[[
	慕容紫英被动

	技能描述：
	慕容紫英善于怒气的运用，自身免疫怒气降低、无法获得怒气效果；
	修改版：
	如果慕容紫英攻击造成击杀，则击杀目标后，获得敌人剩余怒气；
	再改版：
	如果此次攻击造成击杀，则击杀目标后，获得1点公用怒气；

	脚本处理部分：
	-- 慕容紫英不会受到配置的buff类型作用
	-- 如果慕容紫英攻击造成击杀，则击杀目标后，获得敌人剩余怒气；
	击杀目标后，获得1点公用怒气；

	参数：
	-- buffs 慕容紫英免疫的buff效果 如：2_3减血眩晕（废弃）
	atkId 获得怒气的攻击包
]]
local Skill_murongziying_4 = class("Skill_murongziying_4", SkillAiBasic)

function Skill_murongziying_4:ctor(skill,id,atkId)
	Skill_murongziying_4.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")
	
	self._atkData = ObjectAttack.new(atkId)
end
--[[
	造成击杀时加怒
]]
function Skill_murongziying_4:onKillEnemy( attacker,defender )
	if not self:isSelfHero(attacker) then return end
	self:skillLog("慕容紫英击杀阵营:%s,%s号位，对自己施加攻击包:%s",defender.camp,defender.data.posIndex,self._atkData.hid)
	attacker:sureAttackObj(attacker,self._atkData,self._skill)
end
--[[
function Skill_murongziying_4:onKillEnemy( attacker,defender )
	-- 敌人剩余怒气
	local lastEnergy = defender.data:energy()
	if lastEnergy > 0 then
		-- attacker.data:changeValue(Fight.value_energy, lastEnergy)
		-- 杀人本来就能获得怒气 这里展示的效果先注释掉
		-- local style = 1
		-- local frame = Fight.buffMapFlowWordHao[Fight.buffType_nuqi]
		-- attacker:insterEffWord({style, frame,Fight.buffKind_hao})
		self:skillLog("慕容紫英击杀获得额外怒气", lastEnergy)
	end
end
]]
--[==[
function Skill_murongziying_4:ctor(skill,id,buffs)
	Skill_murongziying_4.super.ctor(self, skill, id)

	self:errorLog(buffs, "buffs")

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end

--[[
	慕容紫英对特定类型buff免疫
]]
function Skill_murongziying_4:onBeforeUseBuff(selfHero, attacker, skill, buffObj)
	local result = true
	-- 满足条件
	if array.isExistInArray(self._buffs, buffObj.type) then
		self:skillLog("慕容紫英阻止buff%s生效", buffObj.hid)
		result = false
		-- 可以加怒
		if buffObj.type == Fight.buffType_nuqi and buffObj.value and buffObj.value > 0 then
			result = true
		end
	end

	return result
end
]==]

return Skill_murongziying_4