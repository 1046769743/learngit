--[[
	Author:李朝野
	Date: 2017.08.07
	Modify: 2017.12.06 判定对象修改
	Modify: 2018.03.22
]]
--[[
	唐雪见被动

	技能描述：
	每回合开始时，唐雪见获得1点神树甘露。
	受到神树果实吸引，在随机位置出现神树之影。
	如果唐雪见站在神树之影上，则获得额外2点神树甘露。
	4层神树甘露时，唐雪见给所有队友增加攻击力，持续1回合。

	脚本处理部分：
	回合开始前给自己加甘露，并在格子上扔影子；
	检查如果在影子上则继续加甘露，如果甘露层数足够，放技能增加队友攻击力。

	参数：
	当前技能配置为满足条件释放的技能

	@@buffIdW 甘露buff的Id
	@@buffIdS 树影buff的Id 使用和甘露相同的type
	@@numMax 触发大招的甘露个数
	@@posArr 刷新树影位置 "1_2_3" 表示在1,2,3号位中随机一个位置刷新
]]
local Skill_tangxuejian_4 = class("Skill_tangxuejian_4", SkillAiBasic)

function Skill_tangxuejian_4:ctor(skill,id, buffIdW,buffIdS,numMax,posArr)
	Skill_tangxuejian_4.super.ctor(self,skill,id)

	self:errorLog(buffIdW, "buffIdW")
	self:errorLog(buffIdS, "buffIdS")
	self:errorLog(numMax, "numMax")
	self:errorLog(posArr, "posArr")
	
	self._buffIdW = buffIdW or 0
	self._buffIdS = buffIdS or 0
	self._numMax = tonumber(numMax or 0)
	self._posArr = {}
	self._lattices = nil
	local ps = string.split(posArr or "1_2_3_4_5_6", "_")
	for _,p in ipairs(ps) do
		if tonumber(p) then
			self._posArr[tonumber(p)] = true
		end
	end
	

	self._skill.isStitched = true
end

--[[
	回合开始检查是否触发加攻击力的效果
]]
function Skill_tangxuejian_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	
	-- 回合前给自己加甘露
	self:_addDew(1)
	-- 回合前加个树影
	self:_addShadow(1)

	-- 数量满足
	if self:chkDew() then
		-- 清掉标记的buff
		selfHero.data:clearBuffByType(Fight.buffType_tag_tangxuejian, true)

		selfHero:setRoundReady(Fight.process_myRoundStart, false)
		selfHero.currentSkill = self._skill

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 重置敌人身上关于我本回合的伤害信息
			selfHero:resetCurEnemyDmgInfo()

			selfHero:checkSkill(self._skill, false, self._skill.skillIndex)
		end)

		selfHero.triggerSkillControler:excuteTriggerSkill(function()
			selfHero:movetoInitPos(2)
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		end)

		-- self._skill:clearAtkChooseArr()

		-- selfHero:onMoveAttackPos(selfHero.currentSkill, true, true)
		-- selfHero.isAttacking = false

		-- if Fight.isDummy then
		-- 	selfHero:setRoundReady(Fight.process_myRoundStart, true)
		-- else
		-- 	selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
		-- end
	end
end

-- 攻击时神树给自己加相关内容
function Skill_tangxuejian_4:onHeroStartAttck(selfHero, targetHero, skill)
	if not self:isSelfHero(targetHero) then return end

	if skill == self._skill then return end

	-- 有神树阴影加甘露去掉阴影
	if self:chkShadow() then
		self:skillLog("唐雪见在树影之上")
		self:_addDew(2)
		self:_clearShadow()
		if self:chkDew() then
			-- 清掉标记的buff
			selfHero.data:clearBuffByType(Fight.buffType_tag_tangxuejian, true)

			-- 注册一个回合后技能
			selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
				-- 放技能
				selfHero:checkSkill(self._skill, false, nil)
			end)
		end
	end
end

-- 增加树影
function Skill_tangxuejian_4:_addShadow(num)
	local selfHero = self:getSelfHero()
	local fControler = selfHero.controler.formationControler
	
	if not self._lattices then
		self._lattices = {}
		for _,lattice in ipairs(fControler:getLatticeByCamp(selfHero.camp)) do
			if self._posArr[lattice.data.posIndex] then
				table.insert(self._lattices, lattice)
			end
		end
	end
	local lattices = self._lattices

	-- 随机num个格子
	local targets = BattleRandomControl.getNumsByGroup(lattices,num)
	for _,lattice in ipairs(targets) do
		-- 给格子加buff
		self:skillLog("给格子:%s，%s加影子buff",lattice.camp,lattice.data.posIndex)
		local buffObj = self:getBuff(self._buffIdS)
		lattice:checkCreateBuffByObj(buffObj, selfHero, self._skill)
	end
end

-- 清除树影
function Skill_tangxuejian_4:_clearShadow()
	local selfHero = self:getSelfHero()
	local fControler = selfHero.controler.formationControler
	local lattices = fControler:getLatticeByCamp(selfHero.camp)

	for _,lattice in ipairs(lattices) do
		self:skillLog("清理神树阴影",lattice.camp,lattice.data.posIndex)
		lattice:clearBuffByType(Fight.buffType_tag_tangxuejian, true, true)
	end
end
-- 检查树影
function Skill_tangxuejian_4:chkShadow()
	local selfHero = self:getSelfHero()
	local fControler = selfHero.controler.formationControler
	local lattices = fControler:getLatticeByCamp(selfHero.camp)
	local pos = selfHero.data.posIndex
	for _,lattice in ipairs(lattices) do
		if lattice.data.posIndex == pos then
			return lattice:checkHasOneBuffType(Fight.buffType_tag_tangxuejian)
		end
	end
	return false
end

-- 增加甘露
function Skill_tangxuejian_4:_addDew(num)
	local selfHero = self:getSelfHero()
	local now = selfHero.data:getBuffNumsByType(Fight.buffType_tag_tangxuejian)
	local add = num
	if now + add > self._numMax then
		add = self._numMax - now
	end
	
	self:skillLog("增加:%s个甘露",add)

	-- 加add个buff
	for i=1,add do
		local buffObj = self:getBuff(self._buffIdW)
		selfHero:checkCreateBuffByObj(buffObj, selfHero, self._skill)
	end
end

-- 检查甘露数量做大招
function Skill_tangxuejian_4:chkDew()
	local selfHero = self:getSelfHero()
	local num = selfHero.data:getBuffNumsByType(Fight.buffType_tag_tangxuejian)

	return num == self._numMax
end

return Skill_tangxuejian_4