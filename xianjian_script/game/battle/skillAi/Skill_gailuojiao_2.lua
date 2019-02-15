--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	盖罗娇放毒的逻辑

	技能描述:
	鹤顶红毒。如果目标身上有孔雀胆，则变为致命剧毒，如果没有则仍为鹤顶红毒。

	脚本处理部分:
	如描述中处理buff使用，判断使用具体buffId

	参数:
	h_buffId 鹤顶红buffId
	k_buffId 孔雀胆buffId
	j_buffId 致命剧毒buffId
]]
local Skill_gailuojiao_2 = class("Skill_gailuojiao_2", SkillAiBasic)

function Skill_gailuojiao_2:ctor(skill,id, h_buffId,k_buffId,j_buffId)
	Skill_gailuojiao_2.super.ctor(self,skill,id)

	self:errorLog(h_buffId, "h_buffId")
	self:errorLog(k_buffId, "k_buffId")
	self:errorLog(j_buffId, "j_buffId")

	self._h_buffId = h_buffId or 0
	self._k_buffId = k_buffId or 0
	self._j_buffId = j_buffId or 0
end

-- 攻击时进行毒的检查
function Skill_gailuojiao_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local buffId = self._h_buffId -- 默认上鹤顶红
	-- 先检查对面身上有没有毒提高效率
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		-- 有孔雀胆存在（并清除了），换成致命剧毒
		if defender.data:clearOneBuffByHid(self._k_buffId) then
			buffId = self._j_buffId
			self:skillLog("盖罗娇遇孔雀胆，将释放致命剧毒")
		end
	end
	-- 上buff
	defender:checkCreateBuff(buffId, attacker, self._skill)
end

return Skill_gailuojiao_2