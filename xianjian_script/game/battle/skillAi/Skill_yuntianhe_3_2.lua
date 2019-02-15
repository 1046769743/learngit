--[[
	Author:李朝野
	Date: 2017.06.27
	Modify: 2017.11.02
	Modify: 2018.03.09 不再继承大招的脚本
]]
--[[
	云天河

	技能描述：
	释放大招时，此次攻击每有一个目标被暴击，则有一定概率使本次大招获得额外怒气；
	大招额外攻击一个生命比例最高单位一次，
	并如果此次额外攻击产生暴击，则该角色在本回合内下次受到伤害也必定暴击，并且暴击效果翻倍

	脚本处理部分：
	释放大招时，此次攻击每有一个目标被暴击，则有一定概率使本次大招获得额外怒气；
	大招额外攻击一个生命比例最高单位一次;

	参数：
	atkId 带有加怒buff的攻击包
	ratio 加怒概率
	atkIdNr 额外攻击的普通攻击包
	nrDamageR 额外攻击包的伤害率
	atkIdSp 带有必被暴击buff的攻击包（用于上buff）
]]
local Skill_yuntianhe_3_1 = require("game.battle.skillAi.Skill_yuntianhe_3_1")
local Skill_yuntianhe_3_2 = class("Skill_yuntianhe_3_2", Skill_yuntianhe_3_1)

function Skill_yuntianhe_3_2:ctor( skill,id,atkId,ratio,atkIdNr,nrDamageR,atkIdSp)
	Skill_yuntianhe_3_2.super.ctor(self,skill,id,atkId,ratio)

	self:errorLog(atkIdNr, "atkIdNr")
	self:errorLog(nrDamageR, "nrDamageR")
	self:errorLog(atkIdSp, "atkIdSp")

	self._atkDataNr = ObjectAttack.new(atkIdNr)
	self._nrDamageR = tonumber(nrDamageR) or 0
	self._atkDataSp = ObjectAttack.new(atkIdSp)

	-- 选中的人物
	self._chosenHero = nil
end

--[[
	攻击前选中一个生命比例最高的单位
]]
function Skill_yuntianhe_3_2:onBeforeSkill( selfHero, skill )
	local arr = selfHero.toArr
	local maxHPpercent = nil
	for i=1,#arr do
		local hero = arr[i]
		local hpP = hero.data:hp() / hero.data:maxhp()

		if not maxHPpercent or maxHPpercent < hpP then
			maxHPpercent = hpP
			self._chosenHero = hero
		end
	end

	if self._chosenHero then
		self:skillLog("云天河选择一个生命比例最高的单位%d,血量%.2f",self._chosenHero.data.posIndex, maxHPpercent)
	end
end

--[[
	目标生命百分比越高附加额外伤害越高
	有概率给自己加怒气
	暴击给对方上必被暴击buff
]]
function Skill_yuntianhe_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local dmg = Skill_yuntianhe_3_2.super.onCheckAttack(self, attacker, defender, skill, atkData, dmg)
	echo("必被暴击的buff",atkData.__yuntianheNr)
	if atkData.__yuntianheNr then

		local atkResult = defender:getDamageResult(attacker, skill)

		if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
			self:skillLog("云天河给%d上了必被暴击buff",defender.data.posIndex)
			attacker:sureAttackObj(defender, self._atkDataSp, skill)
		end
	end

	return dmg
end

--[[
	最后给一个人一次额外攻击
]]
function Skill_yuntianhe_3_2:onAfterSkill(selfHero, skill)
	Skill_yuntianhe_3_2.super.onAfterSkill(self, selfHero, skill)
	if self._chosenHero and SkillBaseFunc:isLiveHero(self._chosenHero) then
		self:skillLog("云天河额外攻击:",self._chosenHero.data.posIndex)
		self._atkDataNr.__yuntianheNr = true
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()
		-- 直接修改技能系数
		local tmpSkill = table.copy(skill)
		tmpSkill.damageR = self._nrDamageR
		selfHero:sureAttackObj(self._chosenHero,self._atkDataNr,tmpSkill)
	end

	self._chosenHero = nil

	return true
end

return Skill_yuntianhe_3_2