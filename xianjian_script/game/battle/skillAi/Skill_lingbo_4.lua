--[[
	Author:李朝野
	Date: 2017.08.07
	Modify: 2018.03.14
]]
--[[
	凌波被动

	技能描述：
	凌波每次攻击，给目标添加标记，持续一回合，回合开始前检测标记，引爆相连的标记，非斜线均为相连。


	脚本处理部分：
	凌波回合前检测对方的标记情况，进行引爆。（无法引爆也要清除）

	参数：
	当前技能即为释放的技能
	@@atkId 带有标记的攻击包
	@@dmgRs 不同连击数对应的damageR "3_4_5_1"
]]
local Skill_lingbo_4 = class("Skill_lingbo_4", SkillAiBasic)

function Skill_lingbo_4:ctor(skill,id, atkId,dmgRs)
	Skill_lingbo_4.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")
	self:errorLog(dmgRs, "dmgRs")

	self._atkData = ObjectAttack.new(atkId)

	self._dmgRs = string.split(dmgRs, "_")

	table.map(self._dmgRs, function( v, k )
		return tonumber(v)
	end)

	self._skill.__exSkill = true -- 标记特殊技能用于做判断
end

--[[
	攻击前即为对方添加标记
]]
function Skill_lingbo_4:onCheckAttack(attacker,defender,skill,atkData, dmg)
	-- 当前技能不添加标记
	if not skill.__exSkill then
		self:skillLog("凌波为阵营%s,%s号位添加标记",defender.camp,defender.data.posIndex)
		attacker:sureAttackObj(defender,self._atkData,skill)
	end

	return dmg
end

-- 回合开始前做检查
function Skill_lingbo_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 返回连击数（与伤害相关）,受击列表,与无关列表
	local comb,resultArr = self:_calConnectNum(selfHero.toArr)
	
	-- 没发生连击的直接清掉所有buff
	for _,hero in ipairs(selfHero.toArr) do
		if not array.isExistInArray(resultArr, hero) then
			hero.data:clearBuffByType(Fight.buffType_tag_lingbo)
		end
	end

	-- 发生连击了做技能
	if comb > 0 then
		self:skillLog("凌波触发连击，连击数和伤害率",comb,self._dmgRs[comb-1])
		selfHero:setRoundReady(Fight.process_myRoundStart, false)

		selfHero.currentSkill = self._skill

		-- 给个排序保证复盘顺序一致
		table.sort(resultArr, function(a,b)
			return tonumber(a.data.posIndex) < tonumber(b.data.posIndex)
		end)

		-- 无法选敌使用钦定的方式
		self._skill:setAppointAtkChooseArr()
		self._skill:setAppointAtkChooseArr(resultArr)

		self._skill.isStitched = true

		-- 改变伤害率不需要考虑重置
		self._skill.damageR = self._dmgRs[comb-1]

		selfHero:onMoveAttackPos(self._skill,true,true)
		selfHero.isAttacking = false --设置技能结束

		local totalFrames = selfHero:getTotalFrames(self._skill:sta_action())

		if Fight.isDummy then
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		else
			selfHero:pushOneCallFunc(totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
		end
	end
end

-- 返回存在相连关系的人
function Skill_lingbo_4:_calConnectNum(arr)
	-- 找出带有标记的人
	local tagArr = {}
	for _,hero in ipairs(arr) do
		if hero.data:checkHasOneBuffType(Fight.buffType_tag_lingbo) then
			tagArr[#tagArr + 1] = hero
		end
	end

	-- 递归查找有相连关系的人，单向检查即可不需要双向检查
	local visit = {}
	local max = #tagArr
	local function chk(hero,be,resArr)
		if visit[hero] then return end

		resArr[#resArr + 1] = hero
		visit[hero] = true

		if be > max then return end

		for i=be,max do
			local pos = hero.data.gridPos
			local newPos = tagArr[i].data.gridPos
			if (pos.x == newPos.x and math.abs(pos.y - newPos.y) == 1) 
				or (pos.y == newPos.y and math.abs(pos.x - newPos.x) == 1)
			then
				chk(tagArr[i],i+1,resArr)
			end
		end
	end

	local tempArr = {}

	for i,hero in ipairs(tagArr) do
		if not tempArr[hero] then tempArr[hero] = {} end
		chk(hero,i+1,tempArr[hero])
	end

	-- 转换格式，由于当前阵型不可能存在不同数量的情况（比如2连+3连）所以可以直接加入
	local resultArr = {} -- 相关列表
	local result = 0
	for _,lineArr in pairs(tempArr) do
		if #lineArr > 1 then
			result = #lineArr
			for _,hero in ipairs(lineArr) do
				resultArr[#resultArr + 1] = hero
			end
		end
	end

	return result,resultArr
end

return Skill_lingbo_4