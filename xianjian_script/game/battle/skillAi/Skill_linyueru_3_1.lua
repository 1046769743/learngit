--[[
	Author:李朝野
	Date: 2017.06.23
	Modify: 2018.03.07 击杀增加攻击力
]]
--[[
	林月如大招

	技能描述：
	横排，中排并施加DEBUFF，令其所受伤害时最终结果按比例上升。（通用免伤下降特效）；
	自身施加Buff：将接下来一回合内受到的伤害转换为一定攻击力；

	脚本处理部分：
	将接下来一回合内受到的伤害转换为一定攻击力；

	参数：
	skillid 攻击一排的技能id（原技能攻击一个）
	atkId 加攻击的攻击包Id
]]
local Skill_linyueru_3 = require("game.battle.skillAi.Skill_linyueru_3")

local Skill_linyueru_3_1 = class("Skill_linyueru_3_1", Skill_linyueru_3)

function Skill_linyueru_3_1:ctor(skill,id,skillid,atkId)
	Skill_linyueru_3_1.super.ctor(self, skill, id, skillid)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 击杀后
function Skill_linyueru_3_1:onKillEnemy(attacker, defender)
	if not self:isSelfHero(attacker) then return end

	self:skillLog("林月如击杀阵营:%s,%s号位，对自己施加攻击包:%s",defender.camp,defender.data.posIndex,self._atkData.hid)
	attacker:sureAttackObj(attacker,self._atkData,self._skill)
end

return Skill_linyueru_3_1