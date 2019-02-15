--[[
	Author: lcy
	Date: 2018.05.14
]]

--[[
	玄霄被动技能

	技能描述:
	凰焰焚世，玄冰状态下，战场内每当出现眩晕、沉默、冰冻、混乱，则获得一枚凤凰羽。
	最多达到三枚。
	回合前如果收集到三枚，则恢复玄霄全部气血，清空所有异常状态，激活阳炎状态。
	待所有凤凰羽耗尽，下回合初玄霄恢复玄冰状态。

	脚本处理部分:
	管理两份法宝切换状态；
	更新新老技能的五灵强化情况；
	管理两份资源的显示

	参数:
	@@treasureId 更换的treasureId
	@@buffs 可激活羽毛的bufftype _ 分格 "1_2_3_4"
	@@atkId 给自己加满血的攻击包
	@@slots 需要控制的slots的名字 _ 分格 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
]]
local STATE_ICE = 1 -- 冰封状态
local STATE_FIRE = 2 -- 阳炎状态

local Skill_xuanxiao_4 = class("Skill_xuanxiao_4", SkillAiBasic)

function Skill_xuanxiao_4:ctor(skill,id, treasureId, buffs, atkId, slots)
	Skill_xuanxiao_4.super.ctor(self, skill, id)

	self:errorLog(treasureId, "treasureId")
	self:errorLog(buffs, "buffs")
	self:errorLog(atkId, "atkId")
	self:errorLog(slots, "slots")

	self._treasureId = treasureId or 1
	self._fireTreasure = 1 -- 之后再处理法宝的初始化
	self._iceTreasure = nil

	self._buffs = {}
	for _,bt in ipairs(string.split(buffs, "_")) do
		self._buffs[tonumber(bt)] = true
	end

	-- 加血攻击包
	self._atkData = ObjectAttack.new(atkId)

	-- 符文名的映射表
	self._aniSlots = string.split(slots, "_")

	-- 当前羽毛个数
	self._idx = 0
	-- 最大叠加次数
	self._max = 3

	-- 人物状态
	self._state = STATE_ICE
end

-- 初始化法宝以及给法宝赋值
function Skill_xuanxiao_4:onSetHero(selfHero)
	self._iceTreasure = selfHero.data.curTreasure

	-- 先新建一个treasure出来
	local treasure = ObjectTreasure.new(self._treasureId,
		{hid = self._treasureId,treaType = "base",partnerId = self._iceTreasure:getPartnerId()})
	treasure.treaType = Fight.treaType_base
	-- 获取一下skillinfo
	local skillInfo = self._iceTreasure:getSkillInfo()
	-- 对新法宝技能做一下赋值保证可以被阵位加强
	-- for _,skill in ipairs(treasure:getAllSkills()) do
	-- 	local idx = skill:getSkillIndex()
	-- 	local origin = skillInfo[idx - 1]
	-- 	skill:setOriginalData(origin)
	-- 	skill:setHero(selfHero)
	-- end
	-- 由于技能是按顺序sethero的所以此时前几个技能已经初始化完毕了,现在取一下技能
	local ice_skills = self._iceTreasure:getAllSkills(Fight.skillIndex_max)
	for _,iceskill in ipairs(ice_skills) do
		local idx = iceskill:getSkillIndex()
		local fire_id = iceskill.skillExpand:getFireId()
		local fire_skill = iceskill.skillExpand:_getExSkill(fire_id, false)

		if skillInfo then
			local origin = skillInfo[idx - 1]
			fire_skill:setOriginalData(origin)
		end
		fire_skill:setTreasure(treasure, fire_skill.skillIndex)
		
		fire_skill:setHero(selfHero)

		treasure:setSkill(fire_skill, fire_skill.skillIndex)
	end

	treasure:setSkillInfo(skillInfo)
	treasure:setOriginSkillData(self._iceTreasure:getOriginSkillData())
	
	-- 被动技能用同一个
	treasure:setSkill(self._iceTreasure:getSkill(Fight.skillIndex_passive),Fight.skillIndex_passive)

	self._fireTreasure = treasure
end

-- 获取法宝
function Skill_xuanxiao_4:_getTreasure(state)
	local result = nil
	if state == STATE_ICE then
		result = self._iceTreasure
	elseif state == STATE_FIRE then
		result = self._fireTreasure
	end

	return result
end

-- 回合开始前
function Skill_xuanxiao_4:onMyRoundStart(selfHero)
	-- 不是自己不检查
	if not self:isSelfHero(selfHero) then return end
	-- 死人不检查
	if not SkillBaseFunc:isLiveHero(selfHero) then return end

	local flag = nil	
	-- 冰封状态，羽毛已满
	if self._state == STATE_ICE and self:isRuneFull() then
		-- 清空所有异常状态
		selfHero.data:clearBuffByKind(Fight.buffKind_huai, true)
		-- 给自己回满血
		selfHero:sureAttackObj(selfHero, self._atkData, self._skill)
		-- 做变身
		flag = STATE_FIRE
	-- 阳炎状态，羽毛已空
	elseif self._state == STATE_FIRE and self:isRuneEmpty() then
		-- 做变身
		flag = STATE_ICE
	end
	-- 需要做变身
	if flag then
		selfHero:setRoundReady(Fight.process_myRoundStart, false)

		self._state = flag
		if not Fight.isDummy then
			-- 变身动作
			selfHero:justFrame(Fight.actions.action_treaOver)
			-- 等待变完
			selfHero:pushOneCallFunc(selfHero.totalFrames - 1,function()
				local oldSpineName = selfHero.data.curSpbName
				local treasureObj = self:_getTreasure(flag)
				selfHero.data:useTreasure(treasureObj)
				if oldSpineName ~= selfHero.data.curSpbName then
					selfHero:changeView(selfHero.data.curSpbName)
				end
				-- 刷新一下视图
				self:_setSlotVisible()
				-- 换了法宝，需要更新五行强化情况
				selfHero:updateElementEnhance()
				-- 做完成动作
				selfHero:justFrame(Fight.actions.action_original)
				-- 注册完成的回调
				selfHero:pushOneCallFunc(selfHero.totalFrames - 1,"setRoundReady",{Fight.process_myRoundStart, true})
			end)
		else
			-- 直接把法宝换掉即可
			local treasureObj = self:_getTreasure(flag)
			selfHero.data:useTreasure(treasureObj)
			-- 换了法宝，需要更新五行强化情况
			selfHero:updateElementEnhance()
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		end
	end
end

-- 当有人被添加buff时检查
function Skill_xuanxiao_4:onOneBeUseBuff(attacker, defender, skill, buffObj)
	-- 火状态不管
	if self._state == STATE_FIRE then return end

	-- 如果满足条件
	if self._buffs[buffObj.type] then
		self:addRune(1)
	end
end

-- num 增加符文个数
function Skill_xuanxiao_4:addRune(num)
	if self._idx > self._max then return end

	-- 增加符文数量
	self._idx = self._idx + num
	if self._idx > self._max then self._idx = self._max end

	self:_setSlotVisible()
end

-- num 使用的符文个数
function Skill_xuanxiao_4:useRune(num)
	if self._idx <= 0 then return end

	-- 减少符文数量
	self._idx = self._idx - num
	if self._idx  <= 0 then self._idx  = 0 end

	self:_setSlotVisible()
end

-- 获取符文个数
function Skill_xuanxiao_4:getRuneNum()
	return self._idx
end

-- 设置符文可见度
function Skill_xuanxiao_4:_setSlotVisible()
	if Fight.isDummy then return end

	for i,v in ipairs(self._aniSlots) do
		self:getSelfHero().myView:setSlotVisible(v, i <= self._idx)
	end
end

-- 符文是否已满
function Skill_xuanxiao_4:isRuneFull()
	return self._idx == self._max
end

-- 符文是否已空
function Skill_xuanxiao_4:isRuneEmpty()
	return self._idx == 0
end

return Skill_xuanxiao_4