--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2018.08.08
]]

--[[
	赵灵儿大招扩充2

	技能描述：
	随机一人施加冰符

	脚本处理部分：
	
	备注：
	-- 该类继承自大招扩充1，扩充2的特性通过配表可实现，参数配置与大招扩充1一致 2017.11.28改为脚本实现，直接配置有个bug,暂时没有时间查

	参数：
	treasureId 更换的treasureId
	maxRound 持续回合数
	atkId 冰冻攻击包id
	rate 每个水系奇侠带来的伤害提升

	atkIdEx 额外攻击的攻击包
	exDamageR 额外攻击包伤害率
	nums 额外攻击的人数

	atkIdIce 冰符攻击包
]]
local Skill_zhaolinger_3_1 = require("game.battle.skillAi.Skill_zhaolinger_3_1")
local Skill_zhaolinger_3_2 = class("Skill_zhaolinger_3_2", Skill_zhaolinger_3_1)


function Skill_zhaolinger_3_2:ctor(skill,id,treasureId,maxRound,atkId,rate,atkIdEx,exDamageR,nums,atkIdIce)
	Skill_zhaolinger_3_2.super.ctor(self,skill,id,treasureId,maxRound,atkId,rate,atkIdEx,exDamageR,nums)

	self._atkDataIce = ObjectAttack.new(atkIdIce)
end

-- 攻击结束对随即一人放冰符buff
function Skill_zhaolinger_3_2:onAfterSkill(selfHero, skill)
	-- 做父类方法的事情
	Skill_zhaolinger_3_2.super.onAfterSkill(self, selfHero, skill)
	-- 找一个人
	local toArr = {}
	for _,hero in ipairs(selfHero.toArr) do
		if SkillBaseFunc:isLiveHero(hero) then
			table.insert(toArr, hero)
		end
	end
	-- 对列表乱序
	toArr = BattleRandomControl.randomOneGroupArr(toArr)
	-- 取第一个人
	local hero = toArr[1]

	if hero then
		self:skillLog("赵灵儿对阵营%s,%s号位施加攻击包",hero.camp,hero.data.posIndex,self._atkDataIce.hid)
		selfHero:sureAttackObj(hero,self._atkDataIce,self._skill)
	end

	return true
end

return Skill_zhaolinger_3_2