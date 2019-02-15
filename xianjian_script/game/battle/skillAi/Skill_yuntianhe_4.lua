--[[
	Author:李朝野
	Date: 2017.07.29
	Modify: 2018.03.09
	Modify: 2018.08.09
]]

--[[
	云天河被动

	技能描述：
	如果攻击造成了暴击，则额外附加云天河10%攻击力的额外伤害
	Modify: 若释放仙术时己方每存活一个火系奇侠，则额外提升此次攻击5%暴击率

	脚本处理部分：
	如果造成暴击对相关人员做额外攻击

	参数：
	atkId 带有标记buff的攻击包

	buffId 提升暴击率的buffId

	当前技能作为额外释放的技能
]]
local Skill_yuntianhe_4 = class("Skill_yuntianhe_4", SkillAiBasic)

function Skill_yuntianhe_4:ctor(skill,id, atkId, buffId)
	Skill_yuntianhe_4.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")
	self:errorLog(buffId, "buffId")

	self._atkData = ObjectAttack.new(atkId)
	self._buffId = buffId or 0

	-- 记录触发的人
	self._flag = {}
	self._useBuff = false
end

-- 攻击时检查是否暴击并做记录
-- 检查完攻击类型后去掉相关buff
function Skill_yuntianhe_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if skill == self._skill then return dmg end
	if atkData.__yuntianheNr then return dmg end

	if self._useBuff then
		self._useBuff = false
		self:skillLog("云天河去掉增强buff:",self._buffId)
		attacker.data:clearOneBuffByHid(self._buffId)
	end

	local atkResult = defender:getDamageResult(attacker, skill)
	-- 本次攻击暴击了，记录当前被暴击的人
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		self._flag[#self._flag + 1] = defender
		attacker:sureAttackObj(defender,self._atkData,self._skill)
	end

	return dmg
end

-- 攻击结束根据buff拼接技能，打指定的人
function Skill_yuntianhe_4:onAfterSkill(selfHero, skill)
	local result = true

	if skill == self._skill then
		return result
	end

	-- 查找攻击目标
	if #self._flag > 0 then
		local herolist = self._flag
		
		self:skillLog("云天河触发额外攻击",#self._flag)
		self._skill:setAppointAtkChooseArr()

		self._flag = {}

		self._skill.isStitched = true

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 找到还没有死的
			local tmpList = {}
			for _,hero in ipairs(herolist) do
				if not (hero.data:hp() <= 0 or hero.hasHealthDied) then
					tmpList[#tmpList + 1] = hero
				end
			end

			-- 如果当前自己不能行动或对方已经死亡则不会进行攻击
			if SkillBaseFunc:isLiveHero(selfHero) and selfHero.data:checkCanAttack() and #tmpList > 0 then
				self._skill:setAppointAtkChooseArr(tmpList)
				selfHero:checkSkill(self._skill, false, self._skill.skillIndex)
			else
				-- 执行下一项
				selfHero.triggerSkillControler:excuteTriggerSkill()
			end
		end)
	end

	return result
end

-- 检查伤害类型前加强
function Skill_yuntianhe_4:onBeforeDamageResult(attacker, defender, skill, atkData)
	-- 检查火系奇侠人数
	local count = 0
	for _,hero in ipairs(attacker.campArr) do
		if hero:getHeroElement() == Fight.element_fire then
			count = count + 1
		end
	end

	if count > 0 then
		self:skillLog("云天河攻击火系奇侠人数:",count)
		self._useBuff = true
		-- 给自己加增强的buff
		local buffObj = self:getBuff(self._buffId, self._skill)
		-- 增强数值
		buffObj.value = buffObj.value * count
		attacker:checkCreateBuffByObj(buffObj, attacker, self._skill)
	end
end

return Skill_yuntianhe_4