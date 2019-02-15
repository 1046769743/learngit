--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	蛤蟆绿放毒的逻辑

	技能描述:
	孔雀胆毒。如果目标身上有鹤顶红，则变为致命剧毒，如果没哟则仍为孔雀胆。

	脚本处理部分:
	如描述中处理buff使用，判断使用具体buffId

	参数:
	h_buffId 鹤顶红buffId
	k_buffId 孔雀胆buffId
	j_buffId 致命剧毒buffId
]]
local Skill_hamalv_2 = class("Skill_hamalv_2", SkillAiBasic)

function Skill_hamalv_2:ctor(skill,id,h_buffId,k_buffId,j_buffId)
	Skill_hamalv_2.super.ctor(self,skill,id)

	self:errorLog(h_buffId, "h_buffId")
	self:errorLog(k_buffId, "k_buffId")
	self:errorLog(j_buffId, "j_buffId")

	self._h_buffId = h_buffId or 0
	self._k_buffId = k_buffId or 0
	self._j_buffId = j_buffId or 0
end

-- 攻击时进行毒的检查
function Skill_hamalv_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local buffId = self._k_buffId -- 默认上孔雀胆
	-- 先检查对面身上有没有毒提高效率
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		-- 有鹤顶红存在（并清除了），换成致命剧毒
		if defender.data:clearOneBuffByHid(self._h_buffId) then
			buffId = self._j_buffId
			self:skillLog("蛤蟆绿遇到鹤顶红，将释放致命剧毒")
		end
	end
	-- 上buff
	defender:checkCreateBuff(buffId, attacker, self._skill)
end

return Skill_hamalv_2