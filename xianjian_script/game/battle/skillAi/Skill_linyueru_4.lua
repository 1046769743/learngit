--[[
	Author:李朝野
	Date: 2017.7.18
]]

--[[
	林月如被动（此脚本部分逻辑需要填在被动技能处才能生效）

	技能描述：
	战场内每有一个单位阵亡，提升一次自身攻击（最多叠加4次，每次身边多一把剑）；
	需要支持配置atk包（附带Buff）
	
	脚本处理部分：
	战场内每有一个单位阵亡，提升一次自身攻击

	参数：
	action 加攻击力时做的动作
	atk1Id 第一次加攻击力buff的攻击包
	atk2Id 第二次加攻击力buff的攻击包
	atk3Id 第三次加攻击力buff的攻击包
	atk4Id 第四次加攻击力buff的攻击包
	slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
]]
local Skill_linyueru_4 = class("Skill_linyueru_4", SkillAiBasic)

function Skill_linyueru_4:ctor(skill,id,action,atk1Id,atk2Id,atk3Id,atk4Id,slots)
	Skill_linyueru_4.super.ctor(self, skill, id)

	self:errorLog(action, "action")
	self:errorLog(atk1Id, "atk1Id")
	self:errorLog(atk2Id, "atk2Id")
	self:errorLog(atk3Id, "atk3Id")
	self:errorLog(atk4Id, "atk4Id")
	self:errorLog(slots, "slots")

	self._atkDatas = {}
		
	self._action = action

	self._atkDatas[1] = ObjectAttack.new(atk1Id)
	self._atkDatas[2] = ObjectAttack.new(atk2Id)
	self._atkDatas[3] = ObjectAttack.new(atk3Id)
	self._atkDatas[4] = ObjectAttack.new(atk4Id)

	-- 记录将要执行的索引
	self._idx = 0
	-- 最大叠加次数
	self._max = 4

	-- 符文名的映射表
	self._aniSlots = string.split(slots, "_")
end
-- 有人死亡就触发
function Skill_linyueru_4:onOneHeroDied( attacker, defender )
	if self:isSelfHero(defender) then return end
	-- 加满不再加
	if self._idx >= self._max then return end

	local selfHero = self:getSelfHero()

	if not self:chkHasBuffIndex(selfHero) then
		self._idx = 1
	else
		self._idx = self._idx+1
	end

	if self._idx > self._max then
		self._idx = self._max
	end
	self:skillLog("有人死亡林月如增加buff，索引idx=",self._idx)
	self:_setSlotVisible()
	selfHero:sureAttackObj(selfHero,self._atkDatas[self._idx],self._skill)

	-- 非dummy且在原地才做动作
	if not Fight.isDummy 
		and selfHero:isAtInitPos()
	then
		selfHero:justFrame(self._action)
		-- 做完这个动作恢复人物该有的状态
		local totalFrames = selfHero:getTotalFrames(self._action)
		selfHero:pushOneCallFunc(tonumber(totalFrames), "checkFullEnergyStyle",{})
	end
end

function Skill_linyueru_4:chkHasBuffIndex(attacker)
	local has = false
	local nowAtkData = self._atkDatas[self._idx]
	if nowAtkData then
		--遍历当前所有的攻击包
		local buffs = nowAtkData:sta_buffs()
		--获取所有的buff
		--local has = false
		for kk,vv in pairs(buffs) do
			--判断buff是否存在
			local buff = attacker.data:getBuffByHid(vv)	
			if buff then
				--如果存在，就人物当前使用的攻击包的序号
				has = true
				attacker.data:clearOneBuffByHid(buff.hid)
			end
		end
	end

	return has
end

-- 设置符文的可见度
function Skill_linyueru_4:_setSlotVisible()
	if Fight.isDummy then return end
	
	for i,v in ipairs(self._aniSlots) do
		self:getSelfHero().myView:setSlotVisible(v,i <= self._idx)
	end
end

-- buff被驱散可能会影响符文的显示 （这个时候要处理符文的可见度）
function Skill_linyueru_4:onBuffBeClear( selfHero, buffObj )
	if self._idx == 0 then return end-- 没加过相关buff不用检查
	-- 是否有相关buff被清理
	local flag = false
	-- 查看被清除的buff是不是与符文相关的
	local buffs = self._atkDatas[self._idx]:sta_buffs()
	for i,hid in ipairs(buffs) do
		if buffObj.hid == hid then
			self:skillLog("林月如特殊buff%s被清掉了",hid)
			-- 相关buff被清除
			-- self._idx = 0
			flag = true
		end
	end

	if flag then
		self:_setSlotVisible()
	end
end

-- num 使用的符文个数
function Skill_linyueru_4:useRune( num )
	-- 减少符文数量
	local result = self._idx - num
	if result <= 0 then result = 0 end
	self._idx = result
	local selfHero = self:getSelfHero()
	self:chkHasBuffIndex(selfHero)

	if self._idx ~= 0 then
		selfHero:sureAttackObj(selfHero,self._atkDatas[self._idx],self._skill)
	end

	self:_setSlotVisible()
end

-- 获取符文个数
function Skill_linyueru_4:getRuneNum()
	return self._idx
end 

return Skill_linyueru_4