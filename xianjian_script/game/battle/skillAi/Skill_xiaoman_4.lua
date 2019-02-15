--[[
	Author:李朝野
	Date: 2017.07.24
	Modify: 2017.10.12
	Modify: 2018.03.15
]]
--[[
	小蛮被动

	技能描述：
	情蛊，开场时，给随机一名男性和女性种下情蛊，不包括主角，
	男性奇侠攻击力提高15%，女性奇侠怒气消耗降低1，情蛊无法被驱散。
	当其中一名角色死亡，会使情蛊的另一人中毒，每回合开始时受到10%最大气血伤害，
	中毒效果无法被驱散，小蛮死亡时会清除情蛊。

	脚本处理部分：
	技能内容

	参数：
	@@buffMale 男性角色buff
	@@buffFemale 女性角色buff
	@@buffPosion 毒buff
	@@action 施法时播放的动作
]]
local Skill_xiaoman_4 = class("Skill_xiaoman_4", SkillAiBasic)

function Skill_xiaoman_4:ctor(skill,id, buffMale, buffFemale, buffPosion, action)
	Skill_xiaoman_4.super.ctor(self, skill, id)

	self:errorLog(buffMale, "buffMale")
	self:errorLog(buffFemale, "buffFemale")
	self:errorLog(buffPosion, "buffPosion")
	self:errorLog(action, "action")

	self._buffMale = buffMale or 0
	self._buffFemale = buffFemale or 0
	self._buffPosion = buffPosion or 0
	self._action = action or "none"

	-- 标记首回合
	self._flag = true

	self._male = nil
	self._female = nil

	self._trigger = false -- 标记死亡时的先后顺序
end

-- 我方回合开始前
function Skill_xiaoman_4:onMyRoundStart(selfHero )
	if self:isSelfHero(selfHero) then
		-- 检查一次
		if self._flag then
			self._flag = false
			-- 检查男女角色
			local male = {}
			local female = {}

			for _,hero in ipairs(selfHero.campArr) do
				if not SkillBaseFunc:checkCharacter(hero) 
					and SkillBaseFunc:isLiveHero(hero)
				then
					if SkillBaseFunc:checkSex(hero, Fight.sex_male) then
						male[#male + 1] = hero
					elseif SkillBaseFunc:checkSex(hero, Fight.sex_female) then
						female[#female + 1] = hero
					end
				end
			end

			male = male[BattleRandomControl.getOneRandomInt(#male+1, 1)]
			female = female[BattleRandomControl.getOneRandomInt(#female+1, 1)]

			-- 找到一男一女
			if male and female then
				self:skillLog("小蛮选定一男一女,男:阵营%s,%s号位,女:阵营%s,%s号位",male.camp,male.data.posIndex,female.camp,female.data.posIndex)

				local buffObjM = self:getBuff(self._buffMale)
				local buffObjF = self:getBuff(self._buffFemale)

				male:checkCreateBuffByObj(buffObjM, selfHero, self._skill)
				female:checkCreateBuffByObj(buffObjF, selfHero, self._skill)

				-- 处理动作相关
				if not Fight.isDummy and self._action ~= "none" then
					selfHero:setRoundReady(Fight.process_myRoundStart, false)
					selfHero:justFrame(self._action)
					-- 做完动作再准备完成
					local totalFrames = selfHero:getTotalFrames(self._action)
					selfHero:pushOneCallFunc(tonumber(totalFrames), "setRoundReady",{Fight.process_myRoundStart, true})
				end

				self._male = male
				self._female = female
			end
		end
	end
end

-- 有人死亡
function Skill_xiaoman_4:onOneHeroDied(attacker, defender)
	if self._male and self._female then
		local selfHero = self:getSelfHero()

		local live,die = nil,nil
		-- 挂了一个
		if self._female == defender then
			live,die = self._male,self._female
			self._female = nil
		elseif self._male == defender then
			live,die = self._female,self._male
			self._male = nil
		end

		-- 是两个之一
		if live then
			local buffObjP = self:getBuff(self._buffPosion)
			-- 自己让自己中毒
			self:skillLog("阵营%s,%s号位痛苦不已身中剧毒",live.camp,live.data.posIndex)
			live:checkCreateBuffByObj(buffObjP, live)
			-- 清掉清掉情蛊的buff
			live.data:clearOneBuffByHid(SkillBaseFunc:checkSex(live, Fight.sex_male) and self._buffMale or self._buffFemale, true)
			-- 死者也清掉，不然可能被复活为傀儡
			die.data:clearOneBuffByHid(SkillBaseFunc:checkSex(live, Fight.sex_male) and self._buffFemale or self._buffMale, true)

			-- 如果同一次攻击中小蛮先阵亡注册了清除事件则需要清除
			if self._trigger then
				self:skillLog("小蛮先注册了死亡事件，清除")
				self._trigger = false
				selfHero.willDieSkill = false
				-- 杀死自己（同时会清除注册的事件）
				selfHero:doHeroDie(true)
			end
		end

		-- 死者是小蛮
		if self:isSelfHero(defender) then
			-- 小两口都活着
			if self._male and self._female then
				self._trigger = true

				selfHero.willDieSkill = true -- 防止对象被删除
				if selfHero.healthBar then
					selfHero.healthBar:opacity(0)
				end
				-- 清除两人身上的buff
				selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
					self:skillLog("小蛮清除小两口身上的buff")

					self._trigger = false

					if self._male then
						self._male.data:clearOneBuffByHid(self._buffMale, true)
					end
					if self._female then
						self._female.data:clearOneBuffByHid(self._buffFemale, true)
					end

					self._male = nil
					self._female = nil

					selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
					selfHero.willDieSkill = false
					selfHero:setOpacity(255)
					-- 放技能
					selfHero:checkSkill(self._skill, false, nil)
				end)
			end
		end
	end
end

function Skill_xiaoman_4:onAfterSkill(selfHero, skill)
	if skill == self._skill then
		-- 不是复活的
		if not selfHero:checkWillBeRelive() then
			selfHero:doHeroDie(true)
		else
			selfHero:setOpacity(0)
		end
	end

	return true
end

return Skill_xiaoman_4