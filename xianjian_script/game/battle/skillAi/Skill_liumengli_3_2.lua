--[[
	Author:李朝野
	Date: 2017.10.09
	Modify: 2018.03.14
]]

--[[
	柳梦璃大招扩充2

	技能描述：
	如果没有眩晕，则30%概率沉默目标；

	脚本处理部分：
	怒气仙术会对本次未眩晕的目标，有一定几率造成沉默效果；

	参数：
	@@buffId 概率眩晕buff
	@@ratio 每个阵亡队友提供的概率加成
	@@atkId 概率沉默攻击包
]]
local Skill_liumengli_3_1 = require("game.battle.skillAi.Skill_liumengli_3_1")
local Skill_liumengli_3_2 = class("Skill_liumengli_3_2", Skill_liumengli_3_1)

function Skill_liumengli_3_2:ctor(skill,id, buffId, ratio, atkId)
	Skill_liumengli_3_2.super.ctor(self,skill,id, buffId, ratio)
	
	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

--[[
	检查此次攻击是否对敌方造成眩晕，如果没有，则做一些事情
]]
function Skill_liumengli_3_2:onAfterAttack(attacker,defender,skill,atkData)
	-- 先做父类方法
	Skill_liumengli_3_2.super.onAfterAttack(self, attacker,defender,skill,atkData)
	
	local selfHero = self:getSelfHero()
	local flag = false
	-- 是否被柳梦璃眩晕了
	local buffs = defender.data:getBuffsByType(Fight.buffType_xuanyun)
	if buffs then
		for _,buff in pairs(buffs) do
			-- 是柳梦璃给的buff
			if buff.hero == selfHero then
				flag = true
				break
			end
		end
	end

	if not flag then
		self:skillLog("柳梦璃此次攻击未对阵营:%s,%s号位造成眩晕，进行概率沉默",defender.camp,defender.data.posIndex)
		attacker:sureAttackObj(defender, self._atkData, skill)
	end
end

return Skill_liumengli_3_2