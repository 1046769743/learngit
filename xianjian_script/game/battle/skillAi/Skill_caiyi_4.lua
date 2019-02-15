--[[
	Author:李朝野
	Date: 2017.07.24
]]
--[[
	彩依被动

	技能描述：
	-- 进攻回合前，若同排队友阵亡，则为己方全体队友增加暴击率；
	进攻回合前，若有队友阵亡，则为己方全体队友增加暴击率；
	如果此时受到控制，则清除自身控制并释放该技能；
	此技能只会生效一次；

	脚本处理部分：
	满足上述条件发动彩依特殊技能；
	技能只会发动一次；

	参数：
]]


local Skill_caiyi_4 = class("Skill_caiyi_4", SkillAiBasic)


function Skill_caiyi_4:ctor(skill,id)
	Skill_caiyi_4.super.ctor(self, skill, id)

	-- self.atkData = ObjectAttack.new(atkId)
	-- 记录发动次数
	self._counter = 0
	-- 记录是否根据有人死亡触发
	self._flag = false
	-- 控制状态类型
	self._buffs = {
		Fight.buffType_xuanyun,
		Fight.buffType_bingdong,
		Fight.buffType_shufu,
	}
end

-- 回合开始前判定
function Skill_caiyi_4:onMyRoundStart( selfHero )
	if self:isSelfHero(selfHero) then
		-- self:skillLog("彩依回合开始前停止回合")
		-- selfHero:setRoundReady(false)
		-- 同排有人死亡
		if self._flag then
			self:skillLog("彩依回合开始前释放技能")
			-- 自己处于被控制的状态
			-- 清掉控制技能
			for _,buffType in ipairs(self._buffs) do
				local buffs = selfHero.data:getBuffsByType(buffType)
				if buffs then
					self._flag = true
					selfHero.data:clearBuffByType(buffType)
				end
			end
			
			self._counter = self._counter + 1

			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero.currentSkill = self._skill

			self._skill:clearAtkChooseArr()

			selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)
			selfHero.isAttacking = false --设置彩衣技能结束

			if Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, true)
			else
				selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
			end
		end

		self._flag = false
	end
end

-- 有人死亡的时候判断是否满足彩依放大招的条件
function Skill_caiyi_4:onOneHeroDied( attacker, defender )
	if self:isSelfHero(defender) then return end
	if self._counter > 0 then return end

	local selfHero = self:getSelfHero()
	-- 是否是队友
	if selfHero.camp ~= defender.camp then return end

	-- 死亡者是否和彩依同排 去掉同排的判定2017.8.22
	-- if math.floor((selfHero.data.posIndex - 1) / 2) == math.floor((defender.data.posIndex - 1) / 2) then
		self._flag = true
	-- end
end

return Skill_caiyi_4


