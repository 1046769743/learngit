--[[
	Author:李朝野
	Date: 2017.09.22
]]

--[[
	法宝琴大招

	技能描述：
	如果此次怒气仙术暴击，则移除己方一名角色所有减益Buff；
	
	脚本处理部分：
	如果本次技能暴击，则选定己方一名角色清除减益

	参数：
	atkId1 减怒攻击包
	atkId2 净化攻击包
]]
local Skill_treasureqin_3_1 = require("game.battle.skillAi.Skill_treasureqin_3_1")
local Skill_treasureqin_3_2 = class("Skill_treasureqin_3_2", Skill_treasureqin_3_1)

function Skill_treasureqin_3_2:ctor(skill,id,atkId1,atkId2)
	Skill_treasureqin_3_2.super.ctor(self,skill,id,atkId1)

	self:errorLog(atkId2, "atkId2")

	self._atkData2 = ObjectAttack.new(atkId2)

	-- 标记是否暴击
	self._flag2 = false
end

--[[
	检查暴击情况
	local atkResult = defender:getDamageResult(attacker, skill)
]]
function Skill_treasureqin_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		self._flag2 = true
	end

	return dmg
end

--[[
	如果符合条件对一个己方单位净化
]]
function Skill_treasureqin_3_2:onAfterAttack(attacker,defender,skill,atkData)
	Skill_treasureqin_3_2.super.onAfterAttack(self, attacker,defender,skill,atkData)
	if self._flag2 then
		-- 选人
		local resultArr = {}
		for _,hero in ipairs(attacker.campArr) do
			if #hero.data:getBuffsByKind(Fight.buffKind_huai) > 0 then
				table.insert(resultArr, hero)
			end
		end

		if #resultArr == 0 then
			resultArr = attacker.campArr
		end

		-- 随机一个
		local hero = BattleRandomControl.getNumsByGroup(resultArr,1)[1]

		if hero then
			self:skillLog("法宝琴大招符合条件，对阵营%s %s号施加净化攻击包:%s",hero.camp,hero.data.posIndex,self._atkData2.hid)
			attacker:sureAttackObj(hero,self._atkData2,skill)
		end
		self._flag2 = false
	end
end

return Skill_treasureqin_3_2