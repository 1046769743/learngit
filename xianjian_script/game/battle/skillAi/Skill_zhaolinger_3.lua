--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2017.11.28
	Modify: 2018.08.08
]]

--[[
	赵灵儿大招

	技能描述：
	释放全体冰咒，对敌方减益效果最多者必获得冰冻效果；
	接下来的三个回合，将雷咒改为冰咒，对敌方单体进行攻击，概率冰冻；
	Modify:如果有负面状态相同的人则随机一个；
	Modify:释放风雪冰天，每存在一个水系奇侠，则提升5%伤害；
	
	脚本处理部分：
	对敌方减益效果最多者必获得冰冻效果；
	释放大招后通过替换法宝的方式改变小技能；

	参数：
	treasureId 更换的treasureId
	maxRound 持续回合数
	atkId 冰冻攻击包id
	rate 每个水系奇侠带来的伤害提升
]]
local Skill_zhaolinger_3 = class("Skill_zhaolinger_3", SkillAiBasic)

function Skill_zhaolinger_3:ctor(skill,id,treasureId,maxRound,atkId,rate)
	Skill_zhaolinger_3.super.ctor(self, skill,id)
	
	self:errorLog(treasureId, "treasureId")
	self:errorLog(maxRound, "maxRound")
	self:errorLog(atkId, "atkId")
	self:errorLog(rate, "rate")

	self._treasureId = treasureId
	self._treasure = nil

	self._maxRound = tonumber(maxRound or 0)
	self._atkData = ObjectAttack.new(atkId)
	self._rate = tonumber(rate or 0)

	self._nowRound = -1
	self._oldTreasure = nil
end

-- 计算伤害时检查己方水系奇侠人数
function Skill_zhaolinger_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local count = 0
	for _,hero in ipairs(attacker.campArr) do
		-- 水系奇侠
		if hero:getHeroElement() == Fight.element_water then
			count = count + 1
		end
	end

	if count > 0 then
		self:skillLog("赵灵儿方水系奇侠人数及数值",count,dmg,math.round(dmg * self._rate * count / 10000))
		dmg = dmg + math.round(dmg * self._rate * count / 10000)
	end

	return dmg
end

-- 初始化法宝以及给法宝赋值
function Skill_zhaolinger_3:onSetHero(selfHero)
	self._oldTreasure = selfHero.data.curTreasure

	-- 先新建一个treasure出来
	local treasure = ObjectTreasure.new(self._treasureId,
		{hid = self._treasureId,treaType = "base",partnerId = self._oldTreasure:getPartnerId()})
	treasure.treaType = Fight.treaType_base

	-- 获取一下skillinfo
	local skillInfo = self._oldTreasure:getSkillInfo()
	-- 对新法宝技能做一下赋值保证可以被阵位加强
	for _,skill in ipairs(treasure:getAllSkills()) do
		local idx = skill:getSkillIndex()
		if skillInfo then
			local origin = skillInfo[idx - 1]
			skill:setOriginalData(origin)
		end
		skill:setHero(selfHero)
	end
	treasure:setSkillInfo(skillInfo)
	treasure:setOriginSkillData(self._oldTreasure:getOriginSkillData())
	
	-- 普攻的扩展使用当前的普攻的扩展
	treasure.skill2.skillExpand = self._oldTreasure.skill2.skillExpand
	-- 大招使用当前大招
	treasure:setSkill(self._oldTreasure.skill3, 3)
	treasure:setSkill(self._oldTreasure.skill4, 4)

	self._treasure = treasure
end

--[[
	攻击结束后把法宝换了
]]
function Skill_zhaolinger_3:onAfterSkill( selfHero,skill )
	-- 攻击结束之后对减益效果最多的人造成冰冻
	local toArr = selfHero.toArr

	if #toArr > 0 then
		local tempArr = {}

		-- local badAss = toArr[1]
		-- local badNums = badAss.data:getBuffNumsByKind(Fight.buffKind_huai)
		-- 统计个数
		for _,hero in ipairs(toArr) do
			if SkillBaseFunc:isLiveHero(hero) then
				local tbNums = hero.data:getBuffNumsByKind(Fight.buffKind_huai)
				table.insert(tempArr, {
					tHero = hero,
					tbNums = tbNums
				})
			end
		end

		local function sortFunc(a, b)
			if a.tbNums == b.tbNums then
				return a.tHero.data.posIndex < b.tHero.data.posIndex
			end

			return a.tbNums > b.tbNums
		end

		table.sort(tempArr, sortFunc)

		if not empty(tempArr) then
			-- 找出比较多的一组人
			local heroArr = {}
			local num = tempArr[1].tbNums
			for i=1,#tempArr do
				if num == tempArr[i].tbNums then
					table.insert(heroArr, tempArr[i])
				else
					break
				end
			end

			-- 随机乱序
			heroArr = BattleRandomControl.randomOneGroupArr(heroArr)
			-- 取第一个人
			local badAss = heroArr[1].tHero
			local tbNums = heroArr[1].tbNums

			self:skillLog("赵灵儿对阵营%s,%s号冰冻,此人负面状态%s个",badAss.camp,badAss.data.posIndex,tbNums)
			-- 对减益buff最多的人造成冰冻
			selfHero:sureAttackObj(badAss, self._atkData, self._skill)
		end
	end

	-- 换法宝，必须是大招
	if self._nowRound == -1 then
		self:skillLog("赵灵儿释放大招，更换技能")

		selfHero.data:useTreasure(self._treasure)
		-- 换了法宝，需要更新五行强化情况
		selfHero:updateElementEnhance()

		self._nowRound = self._maxRound
	else
		self:skillLog("赵灵儿释放大招，刷新大招次数")
		self._nowRound = self._maxRound
	end

	return true
end

--[[
	每回合要减次数
]]
function Skill_zhaolinger_3:onMyRoundStart( selfHero )
	if not self:isSelfHero(selfHero) then return end
	if self._nowRound == -1 then return end
	if self._nowRound == 0 then
		self:skillLog("赵灵儿回合数达到，换回法宝")
		selfHero.data:useTreasure(self._oldTreasure)
		-- 换了法宝，需要更新五行强化情况
		selfHero:updateElementEnhance()
	end
	self._nowRound = self._nowRound - 1
end

return Skill_zhaolinger_3