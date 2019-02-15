--[[
	Author: lcy
	Date: 2018.08.04
]]

--[[
	天妖皇普通技能

	技能描述：
	攻击当前单体，吸取一定比例攻击力防御力。

	参数:
	buffIdAM 减攻攻击包id	atkminus
	buffIdAP 加攻buffid（值由减功攻击包作用值决定）atkplus
	AMLimitR 减攻上限比例（万分）
	buffIdDM 减防攻击包id
	buffIdDP 加防buffid（值由减防攻击包作用值决定）
	DMLimitR 减防上限比例（万分）
]]
local Skill_tianyaohuang_2 = class("Skill_tianyaohuang_2", SkillAiBasic)

function Skill_tianyaohuang_2:ctor(skill,id,buffIdAM,buffIdAP,AMLimitR,buffIdDM,buffIdDP,DMLimitR)
	Skill_tianyaohuang_2.super.ctor(self,skill,id)

	self:errorLog(buffIdAM, "buffIdAM")
	self:errorLog(buffIdAP, "buffIdAP")
	self:errorLog(AMLimitR, "AMLimitR")

	self:errorLog(buffIdDM, "buffIdDM")
	self:errorLog(buffIdDP, "buffIdDP")
	self:errorLog(DMLimitR, "DMLimitR")

	self._buffIdAM = buffIdAM or 0
	self._buffIdAP = buffIdAP or 0
	self._AMLimitR = tonumber(AMLimitR or 10000)

	self._buffIdDM = buffIdDM or 0
	self._buffIdDP = buffIdDP or 0
	self._DMLimitR = tonumber(DMLimitR or 10000)
end

--[[
	偷攻防
]]
function Skill_tianyaohuang_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 计算增加的攻击力
	local buffObjAM = self:getBuff(self._buffIdAM)
	local atk = math.round(math.abs(buffObjAM:getEffValue(defender.data:atk())))
	-- 判断边界
	local AML = math.round(attacker.data:getInitValue(Fight.value_atk) * self._AMLimitR / 10000)
	if atk > AML then atk = AML end

	-- 赋值
	buffObjAM.value = -atk
	buffObjAM.changeType = Fight.valueChangeType_num

	local buffObjAP = self:getBuff(self._buffIdAP)
	buffObjAP.value = atk
	buffObjAP.changeType = Fight.valueChangeType_num

	-- 计算增加的防御力
	local buffObjDM = self:getBuff(self._buffIdDM)
	local def = math.round(math.abs(buffObjDM:getEffValue(defender.data:def())))
	-- 判断边界
	local DML = math.round(attacker.data:getInitValue(Fight.value_phydef) * self._DMLimitR / 10000)
	if def > DML then def = DML end
	
	-- 赋值
	buffObjDM.value = -def
	buffObjDM.changeType = Fight.valueChangeType_num

	local buffObjDP = self:getBuff(self._buffIdDP)
	buffObjDP.value = def
	buffObjDP.changeType = Fight.valueChangeType_num

	self:skillLog("天妖皇给自己增加atk:%d，def:%d",atk,def)

	-- 作用减防buff
	defender:checkCreateBuffByObj(buffObjAM, attacker, self._skill)
	defender:checkCreateBuffByObj(buffObjDM, attacker, self._skill)
	-- 作用给自己加的buff
	attacker:checkCreateBuffByObj(buffObjAP, attacker, self._skill)
	attacker:checkCreateBuffByObj(buffObjDP, attacker, self._skill)

	-- 先偷取后作用需要重新计算dmg
	local atkResult = defender:getDamageResult(attacker, skill)
	dmg = Formula:skillDamage(attacker,defender,skill,false,atkResult)
	return dmg
end

return Skill_tianyaohuang_2