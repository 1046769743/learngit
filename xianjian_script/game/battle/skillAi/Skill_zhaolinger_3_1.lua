--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2018.08.08
]]

--[[
	赵灵儿大招扩充1

	技能描述：
	大招再次随机攻击两个额外目标，此攻击不带有冰冻效果，并且不会打碎冰冻效果；

	脚本处理部分：
	大招再次随机攻击两个额外目标

	参数：
	treasureId 更换的treasureId
	maxRound 持续回合数
	atkId 冰冻攻击包id
	rate 每个水系奇侠带来的伤害提升

	atkIdEx 额外攻击的攻击包
	exDamageR 额外攻击包伤害率
	nums 额外攻击的人数
]]
local Skill_zhaolinger_3 = require("game.battle.skillAi.Skill_zhaolinger_3")
local Skill_zhaolinger_3_1 = class("Skill_zhaolinger_3_1", Skill_zhaolinger_3)

function Skill_zhaolinger_3_1:ctor(skill,id,treasureId,maxRound,atkId,rate,atkIdEx,exDamageR,nums)
	Skill_zhaolinger_3_1.super.ctor(self,skill,id,treasureId,maxRound,atkId,rate)

	self:errorLog(atkIdEx, "atkIdEx")
	self:errorLog(exDamageR, "exDamageR")
	self:errorLog(nums, "nums")

	self._atkDataEx = ObjectAttack.new(atkIdEx)
	self._atkDataEx.isFinal = true
	self._exDmgR = tonumber(exDamageR) or 0
	self._nums = tonumber(nums) or 0
end

--[[
	攻击结束对随机两人进行一次伤害
]]
function Skill_zhaolinger_3_1:onAfterSkill(selfHero, skill)
	-- 做父类方法的事情
	Skill_zhaolinger_3_1.super.onAfterSkill(self, selfHero, skill)

	local toArr = {}
	for _,hero in ipairs(selfHero.toArr) do
		if SkillBaseFunc:isLiveHero(hero) then
			table.insert(toArr, hero)
		end
	end
	-- 对列表乱序
	toArr = BattleRandomControl.randomOneGroupArr(toArr)
	-- 截取两人
	toArr = SkillBaseFunc:cutChooseNums(self._nums, toArr)

	-- 重置敌人身上关于我本回合的伤害信息
	selfHero:resetCurEnemyDmgInfo()
	-- 直接修改技能系数
	local tmpSkill = table.copy(self._skill)
	tmpSkill.damageR = self._exDmgR
	tmpSkill.isStitched = true
	for _,hero in ipairs(toArr) do
		self:skillLog("赵灵儿额外攻击阵营%s,%s号位",hero.camp,hero.data.posIndex)
		self._atkDataEx.__zhaolingerEx = true
		selfHero:sureAttackObj(hero,self._atkDataEx,tmpSkill)
	end

	return true
end

return Skill_zhaolinger_3_1