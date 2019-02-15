--[[
	Author:李朝野
	Date: 2017.08.23
]]

--[[
	狐妖女大招

	技能描述:
	单体，概率魅惑（眩晕），持续一回合；
	如果敌方身上带有忘魂效果，则必定控制
	
	脚本处理部分：
	判断是否晕对方

	参数：
	ratio 眩晕概率
	atkId 必定控制的攻击包id（眩晕）
]]
local Skill_huyaonv_3 = class("Skill_huyaonv_3", SkillAiBasic)

function Skill_huyaonv_3:ctor(skill,id, ratio, atkId)
	Skill_huyaonv_3.super.ctor(self, skill, id)

	self:errorLog(ratio, "ratio")
	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
	self._ratio = tonumber(ratio) or 0
end

--[[
	最后一个攻击包决定是否眩晕对方
]]
function Skill_huyaonv_3:onAfterAttack(attacker,defender,skill,atkData  )
	-- 判断对方是否中了忘魂
	local flag = false
	if defender.data:checkHasOneBuffType(Fight.buffType_wanghun) then
		self:skillLog("阵营%s %s号位中了忘魂",defender.camp,defender.data.posIndex)
		flag = true
	end
	-- 判断概率
	if not flag then
		if self._ratio > BattleRandomControl.getOneRandomInt(10001,1) then
			flag = true
		end
	end

	if flag then
		self:skillLog("狐妖女眩晕阵营%s %s号位",defender.camp,defender.data.posIndex)
		attacker:sureAttackObj(defender,self._atkData,self._skill)
	end
	-- 返回一个是否眩晕的结果给大招扩充用
	return flag
end

return Skill_huyaonv_3