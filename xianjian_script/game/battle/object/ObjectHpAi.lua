--
-- Author: xd
-- Date: 2016-11-14 14:12:59
--
ObjectHpAi = class("ObjectHpAi")
local Fight = Fight
-- local BattleControler = BattleControler
--当前所处的位置  0表示 第一阶段还没触发
ObjectHpAi.currentStep = 0

--"80,1,10001,1,0;80,1,10002,1,0;"
--[[
血量信息数组	
{
	{hp:,buffs:{ {id:10001,replace:1,是否可被后面的覆盖,} ,treasures:{	{id:1001,...}	}		}		}	}	}	
}

]]
--
ObjectHpAi.hpInfo = {}

--初始化hp ai
function ObjectHpAi:ctor( cfgs,objHero )
	self.hpCfgs = cfgs
	self.objHero = objHero
	self._isEmptyAi = true
	self.dataInfo = {}
	self:initData()
	self.allActiveBuffer = {}
	if not self._isEmptyAi then
		objHero:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH,self.onHpChanged,self)
    	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self.onCheckEnergyAdd, self)
	end
	
end

--[[
当血量发生变化的时候
]]
function ObjectHpAi:onHpChanged()
	self:onChkBuff()
	self:onChkTrea()
end
-- 检查发生变化时的前提条件是否满足
function ObjectHpAi:checkCanDo( )
	if self.minHp  == nil then
		self.minHp = self.objHero:getAttrPercent("hp")*100
	end
	if self.minHp then
		if self.minHp> self.objHero:getAttrPercent("hp")*100 then
			self.minHp = self.objHero:getAttrPercent("hp")*100
		end
	end
	-- dump(event.params,"ss---",1)
	if not next(self.dataInfo) then
		--echo("没有配置hpAi 暂时先不处理")
		return false
	end
	return true
end

-- 检查能否添加怒气奖励
function ObjectHpAi:onCheckEnergyAdd( event )
	if not self:checkCanDo() then
		return
	end
	local attacker = event.params
	
	for k,v in pairs(self.dataInfo) do
		if self.minHp<= v.hp then
			-- 未激活
			if v.energyState == -1 then
				v.energyState = 1
				-- echo("攻击者在打掉Boss一条血获得怒气")
				-- if not attacker.data:checkHasOneBuffType(Fight.buffType_fengnu) then
				-- 	attacker.data:changeValue(Fight.value_energy, Fight.bossHpAiEnergyResume)
				-- 	--创建怒气特效
				-- 	attacker:insterEffWord({2,Fight.wenzi_jianglinuqi,Fight.buffKind_hao })
				-- 	attacker:createEff("eff_mannuqi_zishen", 0, 0, 1, nil,nil,true)
				-- end
				
				local energyInfo = attacker.controler.levelInfo:getBattleEnergyRule()
				-- 加怒气(NOTE:如果此时boss自己扣血的，则加的是boss阵营对应的怒气)
				if attacker.controler.energyControler:addEnergy(Fight.energy_entire, energyInfo.bossHpAiEnergyResume, attacker) then
					--创建怒气特效
					attacker:insterEffWord({2,Fight.wenzi_jianglinuqi,Fight.buffKind_hao })
					attacker:createEff("eff_mannuqi_zishen", 0, 0, 1, nil,nil,true,nil,nil,nil,attacker)
				end
			end
		end
	end
end

--[[
buffer检查激活
]]
function ObjectHpAi:onChkBuff(attacker)
	if self.minHp  == nil then
		self.minHp = self.objHero:getAttrPercent("hp")*100
	end
	if self.minHp then
		if self.minHp> self.objHero:getAttrPercent("hp")*100 then
			self.minHp = self.objHero:getAttrPercent("hp")*100
		end
	end
	--echo(self.minHp,self.objHero:getAttrPercent("hp"),"---------------")
	if self.curBuffs == nil then
		self.curBuffs = {}
	end
	--检查哪些buffer被激活
	if not next(self.dataInfo) then
		--echo("没有配置hpAi 暂时先不处理")
		return
	end
	--local step = 1
	self.allActiveBuffer ={}
	local index = 1
	local maxStep = -1   		 --比maxStep大的buffer和treas都被激活了
	for k,v in pairs(self.dataInfo) do
		if self.minHp<= v.hp then
			--echo("当前的buffer应该是被激活了")
			if maxStep == -1 then maxStep = k end
			for kk,vv in pairs(v.buffs) do
				if maxStep>=k then
					--被激活的
						if vv.replace == 0 and maxStep > k then	--buffer会被后边的顶掉
							if vv.state == 1 or vv.state == 2 then
								vv.state = 3		--表示需要被顶掉
							end
								--vv.state = -1
						else	--buffer不会被后边的顶掉
							if vv.state == 1 then
								vv.state = 2 		--表示已经被激活过了。
							elseif vv.state == -1 then
								vv.state = 1
							end
							--所有激活的buffer放入数组
							--table.insert(self.allActiveBuffer,vv)
							--self.allActiveBuffer[vv.id..index] = vv
						end
						self.allActiveBuffer[vv.id..index] = vv
				else
					--没有被激活的
				end
			end
		else
		end
		index = index+1
	end

	local controler = self.objHero.__heroModel.controler
	-- local trailType = BattleControler:checkIsTrail()
	for kk,vv in pairs(self.allActiveBuffer) do
		-- and trailType ~= Fight.not_trail 暂时加这个条件、有可能试炼boss也会自己激活某个boss
		-- replace其实就是表中的p1字段，为2的时候是试炼中掉落的buff、
		-- params2 0的时候直接掉落指点的buff，为1的时候掉落的是EnemyInfo中rdmDropBuff字段掉落的buff
		if vv.replace == 2 then
			if vv.state == 1 then
				-- 已经废弃
			end
		else
			if self.curBuffs[kk] == nil then
				self.curBuffs[kk] = vv
			end
			if vv.type == 1 then
				--echo("vv.id",vv.id,vv.t,"===aaaaaaaaaa特殊行为============",self.objHero.hid)
				--如果是做buff
				if vv.state ==1 then
					--echoError("buffer激活,bufferId is ",vv.id,"===========================")
					self.objHero.__heroModel:checkCreateBuff(vv.id)
					--vv.state = 2
				elseif vv.state == 3 then
					echoWarn("buffer应该被顶掉","============================")
					self.objHero:clearOneBuffByHid(vv.id)
				end			
			end
		end
	end
end


--[[
法宝激活
]]
function ObjectHpAi:onChkTrea(  )

	if self.minHp  == nil then
		self.minHp = self.objHero:getAttrPercent("hp")*100
	end
	if self.minHp then
		if self.minHp> self.objHero:getAttrPercent("hp")*100 then
			self.minHp = self.objHero:getAttrPercent("hp")*100
		end
	end

	--echo(self.minHp,self.objHero:getAttrPercent("hp"),"---------------")
	if self.curBuffs == nil then
		self.curBuffs = {}
	end
	--检查哪些buffer被激活
	if not next(self.dataInfo) then
		--echo("没有配置hpAi 暂时先不处理")
		return
	end


	self.allActiveTreas ={}
	local index = 1
	local maxStep = -1   		 --比maxStep大的buffer和treas都被激活了
	for k,v in pairs(self.dataInfo) do
		if self.minHp<= v.hp then
			if maxStep == -1 then maxStep = k end
			--这里是法宝的处理，暂留 todo dev
			for kk,vv in pairs(v.treasures) do
				if maxStep>k then
					--vv.state = -1
				else
					if vv.state ==1 then
						--echoError("法宝激活过了--------")
						vv.state = 2 			--表示该法宝已经激活过了
					elseif vv.state == -1 then
						--echo("激活法宝======================")
						vv.state = 1 			--激活该法宝
					end
					self.allActiveTreas[vv.id..index] = vv
				end
			end
		else
		end
		index = index+1
	end

	-- echo("当前激活的法宝======================")
	-- dump(self.allActiveTreas)
	-- echo("当前激活的法宝======================")
	for kk,vv in pairs(self.allActiveTreas) do
		if  vv.type == 2 then
			if vv.state == 1 then
				echo("___将要变身----------------")
				--vv.state = 2
				self.objHero.__heroModel:setTransbodyTreasureInfo(vv)
			elseif vv.state == 2 then
				-- echo("法宝已经使用过了")
			end
		end
	end

end


function ObjectHpAi:initData(  )
	-- echo("当前的hpCfgs-------")
	-- dump(self.hpCfgs)
	-- echo("当前的hpCfgs-------")
	if self.hpCfgs == nil or (not next(self.hpCfgs)) then
		self.dataInfo ={}
		--table.insert(self.dataInfo,{hp=0,buffs={},treasures={}})
	end

	local tempInfo = {}
	local getHp = function ( hp )
		for k,v in pairs(tempInfo) do
			if v.hp == hp then
				return v
			end
		end
		return nil
	end
	table.sort( self.hpCfgs, function (a,b)
		return a.hp<b.hp
	end )
	for k,v in ipairs(self.hpCfgs) do

		local obj = {}
		if v.t == 1 then
			--加buffer
			obj.id = v.id
			obj.replace = v.p1
			obj.type = 1
			obj.params2 = v.p2
			obj.state = -1
		elseif v.t == 2 then
			--换法宝
			obj.id = v.id
			obj.type = 2
			obj.params1 = v.p1
			obj.params2 = v.p2
			obj.state = -1
		end
		
		local val = {}
		local hpCfgVal = getHp(v.hp)
		if not hpCfgVal then
			--energyState：怒气加成
			table.insert(tempInfo,{hp=v.hp,buffs={},treasures = {},energyState = -1} )
			val =tempInfo[#tempInfo]
		else
			val = hpCfgVal
		end
		if v.t == 1 then
			table.insert(val.buffs,obj)
		elseif v.t == 2 then
			table.insert(val.treasures,obj)
		end
	end

	self.dataInfo = tempInfo
	if table.isEmpty(self.dataInfo) then
		self._isEmptyAi = true
	else
		self._isEmptyAi = false
	end

	-- echo("整理后的数据--------")
	-- dump(self.dataInfo)
	-- echo("整理后的数据--------")

end



-- function ObjectHpAi:( ... )
-- 	-- body
-- end

--[[
获取buffer所有激活的buffer
这里要判断血量的情况
]]
function ObjectHpAi:getActiveBuffInfo(  )
	if self.objHero:getAttrPercent("hp")*100 == 0 then
		return {}
	end
	return self.allActiveBuffer
end



--[[
获取所有的buffer
返回以 buffer Id 为key的hash结构
]]
function ObjectHpAi:getAllBuffInfo(  )
	local allBuffer = {}
	for k,v in pairs(self.dataInfo) do
		if v.buffs then
			for kk,vv in pairs(v.buffs) do
				allBuffer[vv.id] = vv
			end
		end
	end
	return allBuffer
end

--[[
获取当前血量等信息
]]
function ObjectHpAi:getDataInfo(  )
	return self.dataInfo
end

-- function ObjectHpAi:getHpStep(  )
-- 	--
-- 	local hpPercent = self.objHero.data:getAttrPercent("hp")
-- 	--根据百分比算 这个是第几阶段
-- 	if not next(self.dataInfo) then
-- 		echo("没有配置hpAi 暂时先不处理")
-- 	end

-- 	for k,v in pairs(self.dataInfo) do
-- 		if hpPercent<= v.hp then
-- 			return v
-- 		end
-- 	end
-- 	return {}
-- end







