--[[
	Author:庞康宁
	Date: 2017.11.13
	Detail: 大招：当敌方处于某些Buff类型时，使用另一个表现的大招；
	Modef:
	被动技：生命低于35%之后，提升自身攻击力，此效果不可被驱散，生命恢复后效果仍然存在；只会触发一次；
	大招扩充1：当主角释放炫龙拳以前，如果获得了增益类Buff，使用另一个表现的大招；
	大招扩充2：当敌方处于某些Buff类型时，延长这些Buff的回合数，+1;

	exSkillId：特殊表表现大招id
	exBuffId:提升自身攻击力的buff
	buffs:某些需要延长的buff类型
	-- 修改
	2017.11.19 pangkangning
	废弃不用
]]

local Skill_treasureLongxing_3 = class("Skill_treasureLongxing_3", SkillAiBasic)


function Skill_treasureLongxing_3:ctor(skill,id,exSkillId,exBuffId,buffs)
	Skill_treasureLongxing_3.super.ctor(self,skill,id,exSkillId,exBuffId,buffs)
	self._exSkillId = exSkillId
	self._exbuffObj = ObjectBuff.new(exBuffId, self._skill)
	self._isExpend = false -- 是否已经出发提升攻击力效果

	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end

-- 当自己被击时检查血量是否低于35%添加提升攻击力的buff、只触发一次
function Skill_treasureLongxing_3:onAfterHited( selfHero,attacker,skill,atkData )
	if self._isExpend then return end
	local hpPer = math.round(selfHero.data:hp()/selfHero.data:maxhp()*100)
	if hpPer <= 35 then
		self:skillLog("主角生命低于万分比:35,添加提升自身攻击力的buff")
		selfHero:checkCreateBuffByObj(self._exbuffObj, selfHero, self._skill)
		self._isExpend = true
	end
end
return Skill_treasureLongxing_3