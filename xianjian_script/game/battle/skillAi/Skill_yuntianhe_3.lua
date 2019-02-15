--[[
	Author:李朝野
	Date: 2017.06.24
	Modify: 2018.03.09 废弃，与后续需求的关联都已不存在
]]
--[[
	云天河

	技能描述：
	用弓箭攻击敌方全体，造成巨额伤害，仅在本次攻击中，云天河提升暴击率及暴击倍数（通用暴击上升特效）；
	若此次攻击暴击，则无视敌人一定比例防御；->造成目标20%防御力的额外伤害（2017.7.31修改）
	——暴击时，攻击特效会比原来的大一些。（暂不处理）

	脚本处理部分：
	若此次攻击暴击，则无视敌人一定比例防御；

	参数：
	igDefRate 无视防御的比例（万分比）->造成防御力额外伤害的比例（2017.7.31修改）
]]
local Skill_yuntianhe_3 = class("Skill_yuntianhe_3", SkillAiBasic)

function Skill_yuntianhe_3:ctor(skill,id,igDefRate)
	Skill_yuntianhe_3.super.ctor(self,skill,id)

	self:errorLog(igDefRate, "igDefRate")

	self._igDefRate  = tonumber(igDefRate) or 0
end

--[[
	目标生命百分比越高附加额外伤害越高
]]
function Skill_yuntianhe_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	-- 本次攻击暴击了，应该无视一定的防御计算伤害->造成目标防御力百分比的额外伤害
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		--[[
		-- 变化防御值
		local defValue = defender.data:def() * self._igDefRate / 10000
		if defValue > 0 then
			self:skillLog("云天河暴击,无视%.2f防御的比例，重新计算伤害",self._igDefRate / 10000)
			-- 减防御
			defender.data:changeValue(Fight.value_phydef, -defValue)
			-- 计算伤害
			dmg = Formula:skillDamage(attacker,defender,skill,false,atkResult)
			-- 把防御加回来
			defender.data:changeValue(Fight.value_phydef, defValue)
		end
		]]
		dmg = math.round(dmg + defender.data:def() * self._igDefRate / 10000)
		self:skillLog("云天河暴击，对目标附加防御力百分比的伤害，最终伤害%s",dmg)
	end

	return dmg
end

return Skill_yuntianhe_3