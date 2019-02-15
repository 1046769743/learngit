--[[
	Author:李朝野
	Date: 2017.07.24
]]
--[[
	狐妖女被动

	技能描述：
	狐妖女死亡后，会增加己方全体男性伙伴与主角攻击力，持续一回合；
	修改版：
	攻击狐妖女的敌人身上带有忘魂效果——每回合开始时损失气血上限4%气血，持续两回合；
	当敌人身上的忘魂效果达到4层时，狐妖女在回合开始前为全体队友增加攻击力；（清除自身状态）

	脚本处理部分：
	攻击狐妖女的人被加忘魂；
	敌人身上忘魂数量符合条件时时狐妖女给自己方人加攻击力

	参数：
	被动技能本身是给所有人加攻击力 触发时释放
	atkId1 增加忘魂buff的攻击包
	num 触发增加攻击力的忘魂层数
	buffs 要清除的状态 如：2_3减血眩晕
]]
local Skill_huyaonv_4 = class("Skill_huyaonv_4", SkillAiBasic)

function Skill_huyaonv_4:ctor(skill,id,atkId1,num,buffs)
	Skill_huyaonv_4.super.ctor(self, skill, id)
	
	self:errorLog(atkId1, "atkId1")
	self:errorLog(num, "num")
	self:errorLog(buffs, "buffs")

	self._atkData1 = ObjectAttack.new(atkId1)

	-- 触发层数
	self._num = tonumber(num) or 10

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end

--[[
	挨打时给对方加buff
]]
function Skill_huyaonv_4:onAfterHited( selfHero,attacker,skill,atkData )
	if selfHero.data:hp()<0 then
		--自己血量大于0才有效
		return
	end
	-- 对方身上已有忘魂buff不加新的（不行因为要刷新）
	self:skillLog("狐妖女被打为阵营%s %s号位加忘魂",attacker.camp, attacker.data.posIndex)
	-- 给地方加忘魂
	selfHero:sureAttackObj(attacker,self._atkData1,self._skill)
end

--[[
	回合开始前判定
]]
function Skill_huyaonv_4:onMyRoundStart( selfHero )
	if self:isSelfHero(selfHero) then
		-- 判断地方带有忘魂的人的数量
		local count = 0
		for _,hero in ipairs(selfHero.toArr) do
			if hero.data:checkHasOneBuffType(Fight.buffType_wanghun) then
				count = count + 1
			end
		end
		-- 同排有人死亡
		if count >= self._num then
			self:skillLog("敌方身上共有忘魂数%s回合开始前释放技能", count)

			-- 清掉控制技能
			for _,buffType in ipairs(self._buffs) do
				local buffs = selfHero.data:getBuffsByType(buffType)
				if buffs then
					self._flag = true
					selfHero.data:clearBuffByType(buffType)
				end
			end

			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero.currentSkill = self._skill

			selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)


			if Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, true)
			else
				selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart,true})
			end
		end
	end
end

--[[
	有人死亡就触发
]]
-- function Skill_huyaonv_4:onOneHeroDied( attacker, defender )
-- 	-- 如果是自己死亡
-- 	if self:isSelfHero(defender) then
-- 		self:skillLog("狐妖女死亡，被动触发")
-- 		local selfHero = self:getSelfHero()
-- 		local campArr = selfHero.campArr
-- 		for _,hero in ipairs(campArr) do
-- 			-- 男性或主角
-- 			if SkillBaseFunc:checkSex( hero,1 ) or SkillBaseFunc:checkCharacter(hero) then
-- 				-- 做加攻攻击包
-- 				selfHero:sureAttackObj(hero,self._atkData,self._skill)
-- 			end
-- 		end
-- 	end
-- end


return Skill_huyaonv_4