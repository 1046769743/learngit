--
-- Author: XD
-- Date: 2014-07-10 12:03:53
--主要处理 一些敌人的一些特殊行为 
--
local Fight = Fight
-- local BattleControler = BattleControler
local FuncDataSetting  = FuncDataSetting
ModelEnemy = class("ModelEnemy", ModelHero)

--changeTreasureInfo


ModelEnemy._roundTreasureInfo = nil


function ModelEnemy:ctor( ... )
	ModelEnemy.super.ctor(self,...)
	self._ctorRound = 1 --登场回合
end
--重写回合开始前做的事
function ModelEnemy:doRoundFirst(  )
	self._ctorRound = self._ctorRound + 1
	--判断是否要变身
	self:checkTransBody()

	ModelEnemy.super.doRoundFirst(self)
	--判断回合数是否到了
	self:checkHeadBuffRound()
end


--判断是否要变身 回合前检测
function ModelEnemy:checkTransBody(  )
	local waveRound = self.logical:getCampRoundCount(self.camp)
	local realRound = math.ceil(self.controler:getCurrRound()/2)
	--判断的是否有回合换法宝ai
	local roundTreasureInfo = self.data:getRoundTreasure()
	if roundTreasureInfo then
		for k,v in pairs(roundTreasureInfo) do
			if v.params3 == 0 and v.round == waveRound then --波数回合
				--那么设置变身信息
				self:setTransbodyTreasureInfo(v)
				break
			elseif v.params3 == 1 and v.round == realRound then --绝对回合
				--那么设置变身信息
				self:setTransbodyTreasureInfo(v)
				break
			elseif v.params3 == 2 and v.round == self._ctorRound then --登场回合
				--那么设置变身信息
				self:setTransbodyTreasureInfo(v)
				break
			end
		end
	end

end


--判断头顶buff的回合
function ModelEnemy:checkHeadBuffRound(  )
	--如果没有beKillInfo
	local beKillInfo = self.data:beKill() 
	if not beKillInfo then
		return
	end
	--判断回合
	local round = self.logical:getCampRoundCount(self.camp)
	if round >= tonumber(beKillInfo[3]) then
		--那么情况data的kill 信息 同时自身加buff
		--如果是做攻击包
		echo("__自己把头顶特效吃了")
		self:doBeKillEnemyBuff(beKillInfo,self)
		--然后把beKill信息置空
		self.data.datas.beKill = nil
	end

end

