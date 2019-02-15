--[[
	Author:李朝野
	Date: 2017.08.08
]]


--[[
	唐雪见大招扩充2

	技能描述：
	怒气仙术附加状态如果被附加者在当回合内每获得一次增益效果，则额外获得一定攻击力；
	扩充内容配支持配置额外atk包（挂攻击力Buff，每触发一次，多一个，线性增加）

	脚本处理部分：
	怒气仙术附加状态如果被附加者在当回合内每获得一次增益效果，则额外获得一定攻击力；
	扩充内容配支持配置额外atk包（挂攻击力Buff，每触发一次，多一个，线性增加）
	
	备注：
	技能本身提升的暴击和破击保留，当满足条件的时候用双倍数值的buff覆盖
	这里配置的buff要与技能本身的buff相同

	参数：
	hpPer 满足的血量比例（万分）
	buffId1 暴击buffId
	buffId2 破击buffId
	buffId3 增加攻击力的buff
]]
local Skill_tangxuejian_3_1 = require("game.battle.skillAi.Skill_tangxuejian_3_1")
local Skill_tangxuejian_3_2 = class("Skill_tangxuejian_3_2", Skill_tangxuejian_3_1)


function Skill_tangxuejian_3_2:ctor(skill,id,hpPer,buffId1,buffId2,buffId3)
	Skill_tangxuejian_3_2.super.ctor(self,skill,id,hpPer,buffId1,buffId2)

	self:errorLog(buffId3, "buffId3")

	-- self._buffObj3 = ObjectBuff.new(buffId3, self._skill)
	self._buffId3 = buffId3 or 0
	-- 记录增加攻击力次数，为了保证唯一buffId不互相覆盖
	self._counter = 0
end
--[[
	检测身上有没有唐雪见给上的buff，如果有并且当前buff是增益buff，上加攻击力的buff
]]
function Skill_tangxuejian_3_2:onOneBeUseBuff(attacker, defender, skill, buffObj)
	local selfHero = self:getSelfHero()
	-- 是否是自己人
	if selfHero.camp ~= defender.camp then return end
	-- 如果是当前自己的技能返回
	if skill == self._skill then return end
	-- 是否有唐雪见给的buff
	local flag = false
	local buffs = defender.data:getBuffsByType(Fight.buffType_hudun)
	if not buffs then return end
	for _,buff in pairs(buffs) do
		-- 是唐雪见给的buff
		if buff.hero == selfHero then
			flag = true
			break
		end
	end

	flag = flag and (buffObj.kind == Fight.buffKind_hao)

	if flag then
		self._counter = self._counter + 1
		local tempObj = self:getBuff(self._buffId3)
		-- table.copy(self._buffObj3)
		tempObj.hid = string.format("%s_%s",tempObj.hid,self._counter)
		defender:checkCreateBuffByObj(tempObj, selfHero, self._skill)
		self:skillLog("唐雪见大招扩充2触发，给阵营:%s，%s号位加攻击力，buff:%s", defender.camp, defender.data.posIndex, tempObj.hid)
	end
end

return Skill_tangxuejian_3_2