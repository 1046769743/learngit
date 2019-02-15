--[[
	Author:李朝野
	Date: 2017.06.27
]]

--[[
	罗刹鬼婆

	技能描述：
	每回合会召唤1只鬼魂，均为小体型的。形态各异。
	（凶恶为主，不要做成Q萌的，鬼马小精灵中的坏的那三只可以作为参考）

	脚本处理部分：
	每回合会召唤1只鬼魂，伪随机

	参数：

]]
local Skill_luochaguipo_4 = class("Skill_luochaguipo_4", SkillAiBasic)

function Skill_luochaguipo_4:ctor(skill,id)
	Skill_luochaguipo_4.super.ctor(self,skill,id)

	-- 召唤记录表
	self._summonRecord = {}
end
--[[
	我方回合开始前
]]
function Skill_luochaguipo_4:onMyRoundStart( selfHero )
	if not selfHero.data:checkCanAttack() then return end
	
	self:skillLog("罗刹鬼婆回合开始前做召唤逻辑")
	-- 做召唤逻辑
	selfHero:setRoundReady(Fight.process_myRoundStart, false)

	selfHero.currentSkill = self._skill

	selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

	--召唤完毕后判定 roundReady完毕
	if Fight.isDummy  then
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	else
		selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true} )
	end
end

--[[
	召唤逻辑
	每次召唤一只，伪随机，位置不固定
]]
function Skill_luochaguipo_4:onDoSummon( selfHero, atkData )
	local summonInfo = atkData:sta_summon()
	local emptyPos = nil
	-- 先找一个空位
	for pos=1,6 do
		local posHero = selfHero.logical:findHeroModel(selfHero.camp,pos,true)
		if not posHero then
			emptyPos = pos
			break
		end
	end
	-- 找到空位
	if emptyPos then
		-- 随机一只
		local tInfo = BattleRandomControl.getNumsByGroup(summonInfo,1,self._summonRecord)
		table.insert(self._summonRecord, tInfo[1])

		-- 全都随机过了，重置一次
		if #self._summonRecord == #summonInfo then
			self._summonRecord = {}
		end
		tInfo[1].pos = emptyPos

		self:skillLog("罗刹鬼婆找到空位%d，召唤小鬼%d",emptyPos,tInfo[1].id)

		local hero = selfHero:summonOneTarget(tInfo[1])
		if hero then 
			if atkData:sta_aniArr() then
				hero:createEffGroup(atkData:sta_aniArr(),false,nil,selfHero)
			end
			-- 刚刚召唤出来的置为不可攻击
			hero.hasAutoMove = true
			hero.hasOperate = true
		end

		-- 排序
		selfHero.logical:sortCampPos(selfHero.camp)
	end
end

return Skill_luochaguipo_4