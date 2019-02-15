--[[
	Author:李朝野
	Date: 2017.09.14
	Modify: 2018.03.03
]]


--[[
	韩菱纱被动

	技能描述：
	战场内自身攻击力提高20%。
	韩菱纱造成击倒或者释放1次怒气仙术，自身进入“虚弱”（特殊待机动作），
	攻击力降低30%攻击力，防御力降低20%防御力，持续2回合，
	可以叠加，不可被驱散。

	脚本处理部分：
	满足条件标记虚弱状态，添加负面buff

	参数：
	atkId 给自己加负面buff的攻击包
	round “虚弱”状态持续回合数
]]
local Skill_hanlingsha_4 = class("Skill_hanlingsha_4", SkillAiBasic)

function Skill_hanlingsha_4:ctor(skill,id, atkId, round)
	Skill_hanlingsha_4.super.ctor(self, skill, id)
	
	self:errorLog(atkId, "atkId")
	self:errorLog(round, "round")

	self._atkData = ObjectAttack.new(atkId)
	self.lastRound = tonumber(round or 2) -- 持续回合数
	self._round = 0 -- 当前回合数

	-------配合大招扩充的变量-------
	self._buffId1 = nil
	self._buffId2 = nil
	self._exSkill = nil
	self._flag = false -- 是否传递过参数
	self._useBuff = false -- 标记是否加了增强buff
	-------配合大招扩充的变量-------
end

-- 我方回合结束后刷新回合
function Skill_hanlingsha_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end

	if self._round > 0 then self._round = self._round - 1 end

	self:refreshAction()
end

-- 我击杀目标后
function Skill_hanlingsha_4:onKillEnemy(attacker, defender)
	if not self:isSelfHero(attacker) then return end

	self:_doWeak()
end

-- 我释放大招后
function Skill_hanlingsha_4:onAfterSkill(selfHero, skill)
	if skill.skillIndex == Fight.skillIndex_max then
		self:_doWeak()
	end

	return true
end

-- 做虚弱操作
function Skill_hanlingsha_4:_doWeak()
	local selfHero = self:getSelfHero()
	-- 刷新回合
	self._round = self.lastRound
	-- 对自己做攻击包
	selfHero:sureAttackObj(selfHero,self._atkData,self._skill)

	self:refreshAction()
end

-- 是否是虚弱状态
function Skill_hanlingsha_4:isSpWeak()
	return self._round > 0 
end

-- 刷新动作
function Skill_hanlingsha_4:refreshAction()
	local selfHero = self:getSelfHero()

	if self:isSpWeak() then
		selfHero:setUseSpStand(true)
	else
		selfHero:setUseSpStand(false)
	end
end

--------------------------配合大招扩充的方法---------------------------------
function Skill_hanlingsha_4:setExtraParams(skill,buffId1,buffId2)
	self._buffId1 = buffId1
	self._buffId2 = buffId2
	self._exSkill = skill
	self._flag = true
end
-- 检查伤害类型前加强
function Skill_hanlingsha_4:onBeforeDamageResult(attacker, defender, skill, atkData)
	if self._flag and skill ~= self._skill then
		-- 判断目标身上是否有相应buff
		if defender.data:checkHasOneBuffType(Fight.buffType_tag_hanlingsha) then
			self:skillLog("韩菱纱攻击有标记的人，给自己加buff:",self._buffId1, self._buffId2)
			self._useBuff = true
			-- 给自己加增强的buff
			local buffObj1 = self:getBuff(self._buffId1, self._exSkill)
			local buffObj2 = self:getBuff(self._buffId2, self._exSkill)
			attacker:checkCreateBuffByObj(buffObj1, attacker, self._exSkill)
			attacker:checkCreateBuffByObj(buffObj2, attacker, self._exSkill)
		end
	end
end
-- 检查完攻击类型后去掉相关buff
function Skill_hanlingsha_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if self._useBuff then
		self._useBuff = false
		self:skillLog("韩菱纱去掉增强buff:",self._buffId1, self._buffId2)
		attacker.data:clearOneBuffByHid(self._buffId1)
		attacker.data:clearOneBuffByHid(self._buffId2)
	end

	return dmg
end
--------------------------配合大招扩充的方法---------------------------------

return Skill_hanlingsha_4