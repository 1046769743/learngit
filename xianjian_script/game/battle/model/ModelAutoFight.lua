--
-- Author: XD
-- Date: 2014-07-24 10:48:11
--主要处理释放法宝 释放技能这块的逻辑
--
local Fight = Fight
-- local BattleControler = BattleControler
ModelAutoFight = class("ModelAutoFight", ModelCreatureBasic)
local table = table

ModelAutoFight.isArrive = false 		-- 判断是否到达  如果到达之后 那么 就不需要进行 运动检测了  只有在有敌人死亡的时候 才需要进行 运动检测
ModelAutoFight.isWaiting = false 		-- 是否是等待当中
ModelAutoFight.idleInfo = nil 			-- 闲置信息
ModelAutoFight.treasuresInfo = nil 		-- 当前法宝剩余时间信息
ModelAutoFight.currentSkill = nil 		-- 当前释放的技能
ModelAutoFight.nextSkillIndex = 1 		--下一个技能index


ModelAutoFight.hasOperate = false 	--标记当前回合 是否插入操作
ModelAutoFight.hasAutoMove = false -- 已经自动行动过

ModelAutoFight.atkTimes = 0 -- 加一个出手次数的记录
ModelAutoFight.maxSkillTimes = 0 -- 记录大招出手次数
ModelAutoFight.isAttacking = false -- 标记是否在攻击中
--[[
	存放当前回合对某一位置的是否造成了伤害（目前用来判定第一次攻击打碎冰冻）
	{
		posindex = true,
	}
]]
ModelAutoFight.hasHit = nil
--[[
	用于存放谁打过我、按照先后顺序存放
	{
		rid = "10001_1_1"
	}
]]
ModelAutoFight.attackerArray = nil

function ModelAutoFight:ctor( ... )
	ModelAutoFight.super.ctor(self,...)
	-- self.nextSkillIndex = Fight.skillIndex_normal
	self.nextSkillIndex = Fight.skillIndex_small

	self.hasHit = {}
	self.attackerArray = {}
end
 

--初始化数据
function ModelAutoFight:initData( data )
	ModelAutoFight.super.initData(self, data )
end

---------------------------技能相关---------------------------------
---------------------------技能相关---------------------------------
---------------------------技能相关---------------------------------


--创建技能特效分上下层
function ModelAutoFight:createSkillEff(skill)	
	if not Fight.isDummy then
		local aniEff = skill:sta_aniArr()
		skill.__skillEffArr = self:createEffGroup(aniEff, false,nil,self)
		if skill.__skillEffArr then
			for i=1,#skill.__skillEffArr do
				skill.__skillEffArr[i]:setSkillEffect(i)
			end
		end
    end
end

-- 更新技能位置
function ModelAutoFight:updateSkillEffPos(skill)
	if not Fight.isDummy then
		self:_updateEffPos(skill.__skillEffArr)
	end
end

-- 更新位置
function ModelAutoFight:updateEffPos()
	ModelAutoFight.super.updateEffPos(self)

	-- buff位置
	self:updateBuffEffPos()
end

-- 更新buff位置（换位时需要更新）
function ModelAutoFight:updateBuffEffPos()
	if Fight.isDummy or self.controler:isQuickRunGame() then return end

	local allBuffs = self.data:getAllBuffs()
	for k,buffObj in pairs(allBuffs) do
		self:_updateEffPos(buffObj.aniArr)
	end
end

-- t=底层特效, 2 上层特效, 3警示区域
function ModelAutoFight:clearSkillEff( t )
	if not self.currentSkill then
		return
	end
	if self.currentSkill.__skillEffArr then
		table.removebyvalue(self.currentSkill.__skillEffArr,t)
		-- table.remove(self.currentSkill.__skillEffArr,t)
		if #self.currentSkill.__skillEffArr == 0 then
			self.currentSkill.__skillEffArr = nil
		end
	end
end

--释放一个技能
function ModelAutoFight:giveOutOneSkill( skill,skillIndex,isChangeTreasure)
	self.currentSkill = skill
	
	local xpos,ypos = AttackChooseType:getSkillAttackPos( self.controler,self, skill )
	
	-- 时机位置更换为我的第一个攻击包之前
	-- self.logical:doChanceFunc( {camp = 0,attacker = self,chance = Fight.chance_atkStart,defender = firstHero} )
	if not Fight.isDummy then
		
		echo("____释放技能id:",skill.hid)
		local firstHero = AttackChooseType:findHeroByPosIndex(skill.firstHeroPosIndex,self.campArr)

		-- 更改检查透明度流程 2017.6.30
		-- if not isChangeTreasure then
			--判断透明度
			self.controler.viewPerform:checkRelation(self,skill)
			if skillIndex == 3 then
				self:playMaxSkillEff(skill)
			end
		-- end
		--检查阵位反应
		self.controler.viewPerform:checkElementPerform(self,skill)
		

		local enterTypeInfo = skill:sta_enterType() or {0,0}
		local enterType = enterTypeInfo[1]
		--入场速度
		local enterSpeed = enterTypeInfo[2] or 0
		--如果没有出场效果
		if enterType == 0 then
			self:moveToSkillPos(skill,Fight.actions.action_run,xpos,ypos,enterSpeed)
		--小技能出场 播放race2
		elseif enterType == 1 then
			if not isChangeTreasure then
				self:justFrame(Fight.actions.action_treaOn2 , nil, true)
				self:pushOneCallFunc(self.totalFrames, "moveToSkillPos", {skill,Fight.actions.action_race2,xpos,ypos,enterSpeed })
			else
				self:moveToSkillPos(skill,Fight.actions.action_race2,xpos,ypos,enterSpeed)
			end
			-- self:moveToSkillPos(skill,Fight.actions.action_race2,xpos,ypos)
		--大招入场效果
		elseif enterType == 2 then
			--如果是0 那么立马切换过去
			if speed == 0 then
				speed = 999999
			end
			if not isChangeTreasure then
				self:justFrame(Fight.actions.action_treaOn3 , nil, true)
				self:pushOneCallFunc(self.totalFrames, "moveToSkillPos", {skill,Fight.actions.action_race3,xpos,ypos,enterSpeed })
			else
				self:moveToSkillPos(skill,Fight.actions.action_race3,xpos,ypos,enterSpeed)
			end
		end
	else
		--这里必须要先选一次打击目标 否则纯跑逻辑和视图就会对不上
		AttackChooseType:getSkillCanAtkEnemy( self,skill )
		--直接达到技能目标点
		return self:onMoveAttackPos(skill)
	end
end

--让自己跑到对应的位置上去
function ModelAutoFight:moveToSkillPos( skill,action,xpos,ypos,speed )
	action = action or Fight.actions.action_run
	--判断屏幕运动和镜头 运动和速度相关的逻辑 放到 moveModel里面去
	self:checkScreenCamera(skill,xpos,ypos,speed)

	if skill:sta_appear() == Fight.skill_appear_myplace  then
		self:onMoveAttackPos(skill,true)
	--如果没有任何坐标偏移
	elseif xpos == self.pos.x and ypos == self.pos.y then
		self:onMoveAttackPos(skill,true)
	else
		local pointParams = {
			x = xpos,
			y = ypos + 2,
			call = {"onMoveAttackPos",{skill}}
		}
		local tSpeed
		if not speed or  speed == 0 then
			tSpeed = self:countSpeed(xpos,ypos+2)
		else
			tSpeed  = speed
		end

		pointParams.speed = tSpeed
		-- 移动前修正位置2017.7.1
		self:setWay(self:getWayByPos(xpos),true)
		self:moveToPoint(pointParams)
		if self.moveType == 1 or self.moveType == 2 then
			self:justFrame(action)
		end
	end

	
	local  blackFrame = skill:sta_blackFrame() or 0
	if blackFrame > 0 and (not Fight.isDummy)  then
		self.controler:pushOneCallFunc(blackFrame, "hideBlackScene")
	end

	
end

--[[
	到达攻击点
	noComplete 攻击结束之后不执行 onSkillActionComplete -- 2018.5.11此参数逐渐废弃，可以使用triggerSkillControler:pushOneSkillFunc + triggerSkillControler:excuteTriggerSkill 替代，不过注意excuteTriggerSkill不要乱用
]]
function ModelAutoFight:onMoveAttackPos( skill, isOldPlace, noComplete )
	--插入帧事件
	local attackInfos = skill.attackInfos -- 暂时不用这个了
	local skillFrameArr = skill.skillFrameArr
	local audioInfos = skill.audioInfos
	self.isAttacking = true

	-- 记录释放技能的人
	self.controler.verifyControler:getOneSkillInfo(self,skill,BattleRandomControl.getCurStep())

	if not Fight.isDummy then
		-- 取消可能存在的移动状态
		self:cancelMove()
		-- 到达目标点之后修正脸的方向
		self:setWay(self:getMyAtkWay(skill))

		self:checkScreenCameraMax(skill)

		-- 走上面新的转向逻辑2017.7.1
		--如果出现方式是我面前 那么得转向
		-- if not isOldPlace and(  skill:sta_appear() == Fight.skill_appear_myFirst or skill:sta_appear() == Fight.skill_appear_myMiddle) then
		-- 	self:setWay(self.way* - 1)
		-- else
			
		-- end

		--开始改变动作
		local action = skill:sta_action()
		
		self:justFrame(action)

		-- 技能长度，在这里取，防止打断
		local totalFrames = self:getTotalFrames(action)

		--技能执行前
		self:checkBeforeSkill(skill)

		--那么延迟这么多帧（所有帧数需要提前一帧，因为pushOneCallFunc的方式要比动作帧慢一帧，同下面onSKillActionComplete）
		for i,v in ipairs(skillFrameArr) do
			-- 是技能帧
			if v.skillfunc then
				local frame = v.frame
				if frame > totalFrames then
					echoError("_找战斗策划___这个技能事件检测帧大于当前动作长度,label:%s,动作长度:%d,检测帧:%d, hid:%s,skill:%s,",self.label,totalFrames,frame,self.data.hid,skill.hid)
				end
				frame = frame - 1 
				if frame < 0 then frame = 0 end
				self:pushOneCallFunc(frame, v.func, {self,skill,frame})
			else -- 是攻击包
				local frame = v[2]
				if frame > totalFrames then
					echoError("_找战斗策划___这个技能检测帧大于当前动作长度,label:%s,动作长度:%d,检测帧:%d, hid:%s,skill:%s,",self.label,totalFrames,frame,self.data.hid,skill.hid)
				end
				local bulletParams = v[3].bulletParams
				if bulletParams and bulletParams.moveFrame + frame > totalFrames then
					echoError("_找战斗策划___这个子弹攻击包作用帧大于当前动作长度，label:%s,动作长度:%s,作用帧:%s, hid:%s,skill:%s",self.label,totalFrames,frame + bulletParams.moveFrame,self.data.hid,skill.hid)
				end
				frame = frame - 1 
				if frame < 0 then frame = 0 end
				self:pushOneCallFunc(frame, "checkSkillInfo", {v,skill,i})
			end
		end

		-- 处理音效
		for i,v in ipairs(audioInfos) do
			local frame = v[1]
			frame = frame - 1 
			if frame < 0 then frame = 0 end
			self:pushOneCallFunc(frame, "playAudio", {v[2]})
		end
		-- pangkangning 2017.09.27 盗宝者逃跑逻辑闪一帧，所以将 totalFrames + 1 修改为totalFrames了
		if noComplete ~= true then
			-- totalFrames - 1 是因为修改了pushOneCallFunc后动作帧一定比 pushOneCallFunc 的帧快 1 帧
			self:pushOneCallFunc(totalFrames - 1, "onSkillActionComplete")
		end
		-- 技能特效
		self:createSkillEff(skill)
	else
		--技能执行前
		self:checkBeforeSkill(skill)
		--直接检测帧
		for i,v in ipairs(skillFrameArr) do
			if v.skillfunc then -- 是技能帧事件
				v.func(self,skill,v.frame)
			else -- 是攻击包
				self:checkSkillInfo(v,skill,i)
			end
		end
		
		--直接通知控制器攻击完成
		-- echo("__攻击完成",self.camp,self.data.posIndex)
		if noComplete ~= true then
			return self:onSkillActionComplete()
		end
	end

end

--[[
技能执行前
]]
function ModelAutoFight:checkBeforeSkill(skill)
	-- 开始攻击前（放到这里是考虑到随机和复盘的问题）
	self.logical:doChanceFunc( {camp = 0,attacker = self,chance = Fight.chance_atkStart,defender = firstHero, skill = skill} )
	
	if skill.skillExpand then
		skill.skillExpand:onBeforeSkill(self,skill)
	end
end



--[[
技能完成后
返回是否返回攻击位置
]]
function ModelAutoFight:checkAfterSkill(skill)
	local flag = true

	--判断特殊技（把特殊技的判定移到前面，目前是发现景天复盘加buff先后的问题，2017.12.4）
	local specialSkill = self.data:getSpecialSkill()
	-- 如果这个技能被主动释放了，那这里不应该走，因为下面已经走到了
	if specialSkill and specialSkill.skillExpand and skill ~= specialSkill then
		flag = specialSkill.skillExpand:onAfterSkill(self,skill) 
	end

	if skill.skillExpand then
		-- 如果被动里有释放技能，那么当前的技能需要注册在之后执行才能保证复盘顺序绝对一致
		if not flag then
			self.triggerSkillControler:pushOneSkillFunc(self, function()
				local flag = skill.skillExpand:onAfterSkill(self,skill)
				if not flag then
					-- 如果放了一个技能则不用处理
				else
					-- 没有放技能需要手动驱动一下进程
					self.triggerSkillControler:excuteTriggerSkill()
				end
			end)
		else
			flag = skill.skillExpand:onAfterSkill(self,skill) and flag
		end
	end

	return flag
end






--判断是否有濒临死亡事件
function ModelAutoFight:checkHeroWillDied( skill )
	local atkInfos = skill.attackInfos


end



--判断技能攻击检测
function ModelAutoFight:checkSkillInfo(info,skill,atkIndex)
	if not skill then
		echo("__________________为什么没有技能？？？？")
		return
	end
	if self._isDied then
		echoError ("已经死亡了不应该再判断攻击检测了")
		return
	end

	--如果已经出结果了 那么不应该检测技能了
	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end

	-- 敌方死光也需要判断 因为技能可能是作用在己方2018.01.29
	--如果敌方已经死光了 那么也不需要判断
	-- if #self.toArr == 0 then
	-- 	return
	-- end
	local atkData = info[3]
	atkData.atkIndex = atkIndex

	--如果是攻击包
	if info[1] == Fight.skill_type_attack  then
		self:checkAttack(atkData,skill)
	elseif info[1] == Fight.skill_type_missle then
		self:createMissle( info[3],skill)
	else
		echoWarn("错误的技能类型",info[1])
	end
end

--技能动作播放完毕
function ModelAutoFight:onSkillActionComplete(  )
	--判断如果没有真正释放技能就返回
	if not self.currentSkill then return end
	
	--拿到坐标偏移
	local skillOffset = self.currentSkill:sta_atkOffset()
	--技能完毕清除技能
	self.currentSkill:clearAtkChooseArr()
	if skillOffset then
		--那么进行坐标偏移
		self:setPos(self.pos.x +skillOffset * self.way,self.pos.y,self.pos.z )
	end

	-- 攻击结束，认为伙伴行动过，更新相关buff的值
	self.data:setChkActionBuffState(true)

	-- 返回是否返回攻击位置
	if not self:checkAfterSkill(self.currentSkill) then return end
	--[[
		重置人物混乱的状态
		先在这里重置回来，意味着上面的时机也会处理到
	]]
	self:resetConfusion()

	if not self._cfunc_onSkillComplete then
		self._cfunc_onSkillComplete = c_func(self.onSkillComplete, self)
	end

	-- 如果已经出结果就强行检查一次素颜,否则主角形态无法恢复（不能简单的把变身提前到这个位置，否则会反复变身）
	if self.controler and self.controler.__gameStep == Fight.gameStep.result then
		--恢复法宝
		self:checkResumeTreasure()
	end

	return self.triggerSkillControler:excuteTriggerSkill(self._cfunc_onSkillComplete)
	-- return self.triggerSkillControler:excuteTriggerSkill(c_func(self.onSkillComplete, self))
end

-- 技能以及触发内容都完成后相关操作
function ModelAutoFight:onSkillComplete()
	--恢复法宝
	self:checkResumeTreasure()
	
	if Fight.isDummy then
		return self:movetoInitPos(1)
	else
		if self.hasKillEnemy and self.camp == 1 then
			--取消杀人属性  然后 20帧后 播放
			self.hasKillEnemy =false
			self:standAction()

			--10帧以后播放powerup
			self:pushOneCallFunc(10, "justFrame", {Fight.actions.action_powerup})
		else
			self:movetoInitPos(1)
		end
	end
end

--主角法宝放完后得直接切换成素颜
function ModelAutoFight:checkResumeTreasure(  )
	--判断主角当前法宝是不是默认法宝
	if not self.data.isCharacter then
		return
	end

	if self.data.curTreasureIndex == 0 then
		return
	end
	local treasureIndex = 0

	local oldSpineName = self.data.curSpbName
	local treasureObj = self.data.treasures[treasureIndex+1]
	self.data:useTreasure(treasureObj,treasureIndex)
	if oldSpineName ~= self.data.curSpbName then
		self:changeView(self.data.curSpbName)
	end



end




--即将位置复原 t 类型 1表示 是攻击完毕后 回到起点 
--2表示起身后回到起点  或者从别的位置回到起点 不做其他事
--3表示复活后回调起点
function ModelAutoFight:movetoInitPos( t ,speed)
	--显示或者隐藏buffani
	if not Fight.isDummy then
		self:showOrHideBuffAni(true)
	end
	

	t = t and t or 1
	-- 攻击结束，如果自身死亡，则攻击结束、原地死亡【自爆】
	if t == 1 and (self.data:hp() <= 0 or self._isZiBao) then
		
		return self:onAttackComplete()
		-- self:checkHealth()
	end
	--如果确定没人了 那么直接攻击完毕
	if self:checkIsNoPerson() and t ==1  then
		
		return self:onAttackComplete()
	end

	if Fight.isDummy then
		-- self:initPosComplete(t)
	else
		self:setWay(self:getWayByPos(self._initPos.x),true)
		local posParams = {
			x = self._initPos.x,
			y = self._initPos.y,
			call = {"initPosComplete",{t}},
			speed = speed or  self:countSpeed(self._initPos.x, self._initPos.y,10)
		}
		self:moveToPoint(posParams)

		--必须是有一定距离才回到起点
		if self.moveType == 1 or self.moveType == 2 then
			self:justFrame(Fight.actions.action_run, nil)
		end
		
	end
	
	
	
	if t ==1 then
		
		return self:onAttackComplete()
	end
	
end

--判断下被动技能
function ModelAutoFight:checkPassive( )
	local skillIndex = self.currentSkill.skillIndex
	--被动技能
	local passiveSkill = self.data.curTreasure.skill8
	if not passiveSkill then
		return
	end
	--判定是否激活被动技
	if not passiveSkill:checkCanTrig(skillIndex) then
		return
	end
	echo(passiveSkill.useStyle,"___开始触发被动技了",skillIndex)
	--如果是简单做攻击包
	if passiveSkill.useStyle == 1 then
		passiveSkill:usePassiveAtkDatas(nil)
	else
		--把这个技能放到控制器里
		self.logical:insertPassiveSkill(passiveSkill)
	end



end

-- 注册一个归位函数
function ModelAutoFight:pushOneInitPosCompleteCall(func )
	if Fight.isDummy or self.controler:isQuickRunGame() then
		return func()
	else
		self.__onInitPosComplete = func
	end
end

--初始化坐标结束
function ModelAutoFight:initPosComplete( t )
	-- 如果已经死亡了不再做后面的事情
	if self._isDied then
		return 
	end

	if self.camp == 1 then
		self:setWay(1)
	else
		self:setWay(-1)
	end

	self:doInitPosComplete()

	self:checkUseFilterStyle()
	--判断是否取消连击
	t = t and t or 1
	if t == 1 then

	--如果是复活回来,判断是否有法宝崩溃结束
	elseif t == 3 then -- 法宝不在这里检查
	-- 	self:checkTreasureEnd()
	end
	--判断眩晕动作
	self:checkXuanyun()
	--判断大招满能量
	self:checkFullEnergyStyle()
end

-- 真实释放技能，不要直接调用，通过checkSkill调用
function ModelAutoFight:realCheckSkill(skill,isChangeTreasure,skillIndex)
	self:setOpacity(255)
	-- 检查混乱
	self:checkConfusion()
	
	self.isAttacking = true

	if not skill then
		skillIndex = skillIndex or Fight.skillIndex_small
		if skillIndex == Fight.skillIndex_max and not self.data:hasMaxSkill() 	 then
			skillIndex = Fight.skillIndex_small
		end

		skill = self.data.curTreasure:getSkill(skillIndex)
	else
		skillIndex = skillIndex or skill.skillIndex 
	end
	
	if not skill then
		echoWarn("没有对应技能:","skill"..skillIndex,"法宝id:",self.data.curTreasure.hid)
	end

	if skill.skillExpand then
		skill = skill.skillExpand:onBeforeCheckSkill(self, skill) or skill
	end
	

	if skillIndex == Fight.skillIndex_max then
		-- 影响怒气消耗的buff标记使用
		self.data:useBuffsByType(Fight.buffType_energyCost)

		-- 怒气免费buff标记使用
		self.data:useBuffsByType(Fight.buffType_energyNoCost)

		-- 大招出手
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MAX_SKILL,{model=self})
	end
	-- 非拼接技能
	if not skill.isStitched then
		-- 增加攻击次数
		self.atkTimes = self.atkTimes + 1
	end

	skill:clearAtkChooseArr()

	-- AttackChooseType:getSkillAttackPos( self.controler,self, skill )
	-- 战斗内数据
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_beforeSkill,skillId = skill.hid})

	return self:onAttackSignToSkill(skill,skillIndex, isChangeTreasure)
end

--根据回合数判断应该用什么技能
function ModelAutoFight:checkSkill(...)
	-- 有可能回合切换时间内还未落地强制归位
	-- if not Fight.isDummy and not self:isAtInitPos() and self.myState == Fight.state_jump then
	-- 	self.myState = Fight.state_stand
	-- 	self:clearOneCallFunc("initPosComplete")
	-- 	self:setPos(self._initPos.x,self._initPos.y,self._initPos.z)
	-- end
	-- 如果没落地就落地归位以后再做正事，（这里只检查落地，有a放完大招接着放小技能连续攻击的需求）
	if not Fight.isDummy and not self:isAtInitPos() and self.myState == Fight.state_jump then
		return self:pushOneInitPosCompleteCall(c_func(self.realCheckSkill, self, ...))
	end

	return self:realCheckSkill(...)
end

function ModelAutoFight:onAttackSignToSkill(skill,skillIndex, isChangeTreasure)
	-- 2017.6.30
	-- if not isChangeTreasure then
	self.controler:hideBlackScene()
	-- end

	--不是大招才增加怒气
	if skillIndex ~= Fight.skillIndex_max then
		-- 标记使用buff
		self.data:useBuffsByType(Fight.buffType_atkEnergyResume)
	else
		if (not Fight.debugFullEnergy) and 
			(not self.controler.energyControler:chkIsInfiniteEnergy())
			then
				if self.controler:isTowerTouxiAndFirstWaveRound() then
					echo("如果是锁妖塔偷袭战第一回合，则不需要清空怒气")
				else
					-- self.data:changeValue(Fight.value_energy , -energy)
					-- 大招消耗怒气
					-- self.controler.energyControler:useEnergy(self)
				end
		end
	end

	self:showOrHideBuffAni(false)

	return self:giveOutOneSkill(skill,skillIndex,isChangeTreasure)
end

--获取下一个将要释放的技能
function ModelAutoFight:getNextSkill(  )
	local skillIndex = Fight.skillIndex_small
	-- self.nextSkillIndex
	local skill
	--只有是默认法宝 才会判定大招
	if self.data:isDefaultTreasure() then
		--如果能量满了  那么 优先用最后一个技能 就是大招
		--如果能量满而且能够释放技能的
		if self.data:checkCanGiveSkill() then
			skillIndex = Fight.skillIndex_max
		end
	end
	-- 主角的大招是法宝的3技能
	if skillIndex == Fight.skillIndex_max and self.data.isCharacter then 
		skill = self.data.treasures[2].skill3
	else
		skill = self.data.curTreasure:getSkill(skillIndex)
	end
	return skill,skillIndex
end


--------------------------------------法宝相关--------------------------------
--------------------------------------法宝相关--------------------------------
--------------------------------------法宝相关--------------------------------


--当B类法宝祭出结束时
function ModelAutoFight:onGiveoutBE(  )

	echo("释放B类法宝结束 还原回去--",self.data.curTreasure.treasureLabel,self.data.curTreasure.hid)
	--如果是b类法宝 那么放完变成素颜就回去
	local  treasureObj = self.data.curTreasure
	if treasureObj.treasureLabel == Fight.treasureLabel_b  then
		-- 这个时候 需要换回素颜 
		echo("______播放法宝崩溃动作")
		self:justFrame(Fight.actions.action_treaOver)
	else
		self:movetoInitPos(1)
	end
end


--切换法宝
function ModelAutoFight:checkTreasure(treasureIndex, skillIdx)
	-- 同checkSkill
	if not Fight.isDummy 
		and not self.controler:isQuickRunGame()
		and not self:isAtInitPos() 
		and self.myState == Fight.state_jump 
	then
		return self:pushOneInitPosCompleteCall(c_func(self.checkTreasure, self, treasureIndex,skillIdx))
	end
	
	self.isAttacking = true

	if not Fight.isDummy then
		return self:onAttackSignToTreasure(treasureIndex,skillIdx)
		-- 法宝消失特效
		-- self:giveTreasure()
	else
		return self:onGiveOutTreasureEnd(treasureIndex,true,skillIdx)
	end
	
end

--播放大招特写
function ModelAutoFight:playMaxSkillEff( skill )
	if Fight.isDummy  then
		return
	end

	if true then
		return
	end

	local aniInfoArr = {

	}

	if self.data.hid == "30008" then
		aniInfoArr = { {name = "dazhaoceshi_lixiaoyao",action = "eff_dazhaotishi",type = "spine",layer = self.controler.layer.a122 } }
	 
	elseif self.data.hid == "30005" then
		aniInfoArr = { {name = "dazhaoceshi_linyueru",action = "texie_hou",type = "spine" ,layer = self.controler.layer.a122} ,
						{name = "dazhaoceshi_linyueru",action = "texie_qian",type = "spine" ,layer = self.controler.layer.a124} ,
					}
	else
		aniInfoArr = { {name = "UI_dazhaotishi_linyueru",type = "flash",layer = self.controler.layer.a122 } }
	end 
	self:onSkillBlack(Fight.zorder_blackChar +100)
	for i,v in ipairs(aniInfoArr) do
		local eff = ModelEffectBasic.new(self.controler)
		eff:setIsCycle(false)
		eff:setFollow(false)
		eff:setTarget(self,0,0,0,0)
		local focusPos = self.controler.screen.focusPos
		-- local ani = ViewArmature.new("UI_dazhaotishi_linyueru")
		local ani
		if v.type == "spine" then
			ani = ViewSpine.new(v.name)
			ani:playLabel(v.action)
		else
			ani = ViewArmature.new(v.name)
		end

		ani:setScaleX(Fight.cameraWay * self.way *0.8)
		ani:setScaleY(0.8)
		eff:initView(v.layer ,ani,focusPos.x ,focusPos.y ,0)
		
		eff.myView:zorder(Fight.zorder_blackChar+100 + self.__zorder - 1 )
		self.controler:insertOneObject(eff)
	end


	

	if callBack then
		self:pushOneCallFunc(20, callBack)
	end
	

end

--播放大招镜头
function ModelAutoFight:playMaxSkillCamrea(skill  )
	if skill.hid == "300073" or skill.hid  == "3000731" then
		
	end
end



--准备开始放法宝了
function ModelAutoFight:onAttackSignToTreasure(treasureIndex, skillIdx)
	--直接播放祭出动作
	self.controler:hideBlackScene()
	self:justFrame(Fight.actions.action_treaOn3, 1)
	-- skill:clearAtkChooseArr()
	-- --判定操作相关人员
	-- self.controler.viewPerform:checkRelation(self, skill )
	--播放大招特写
	-- if treasureIndex >= 1 then
	-- 	self:playMaxSkillEff(skill)
	-- end

	if Fight.isDummy  then
		self:onGiveOutTreasureEnd(treasureIndex,true,skillIdx)
	else
		self:pushOneCallFunc(self.totalFrames, "onGiveOutTreasureEnd", {treasureIndex,true,skillIdx})
	end

end


--法宝祭出结束
function ModelAutoFight:onGiveOutTreasureEnd(treasureIndex, doSkill, skillIdx)
	
	--比较2个法宝是否是同一个对象 或者是否需要换装
	local oldSpineName = self.data.curSpbName
	local treasureObj = self.data.treasures[treasureIndex+1]
	self.data:useTreasure(treasureObj,treasureIndex)
	if oldSpineName ~= self.data.curSpbName then
		self:changeView(self.data.curSpbName)
	end
	if self.camp == 1 then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGETREASURE,treasureIndex)
	end
	if doSkill then
		local skillIdx = skillIdx or Fight.skillIndex_max
		local skill = self.data.curTreasure:getSkill(skillIdx)
		echo(treasureIndex,"_____更换法宝--------------")
		--那么默认放第一个技能
		return self:checkSkill(skill,true,Fight.skillIndex_max )
	end
	
end

--法宝崩溃结束
function ModelAutoFight:onTreasureOverEnd(  )
	
	local  treasureIndex =0
	echo("___法宝崩溃完毕",self.isRoundReady)
	local oldTrasure = self.data.curTreasure
	--比较2个法宝是否是同一个对象 或者是否需要换装
	local oldSpineName = self.data.curSpbName
	--如果是boss变身的
	if self.transbodyInfo then
		treasureIndex = self.data:insterTreasure(self.transbodyInfo.id)
	end

	local treasureObj = self.data.treasures[treasureIndex+1]
	self.data:useTreasure(treasureObj,treasureIndex)
	if oldSpineName ~= self.data.curSpbName then
		self:changeView(self.data.curSpbName)
	end

	
	echo("A类法宝崩溃 播放original")
	if Fight.isDummy  then
		self:onOriginalEnd()
	else
		-- 播变身动作则也播素颜动作
		if self.transbodyInfo and self.transbodyInfo.params2 == 1 then
			--切换成素颜的时候  需要播放 original动作
			self:justFrame(Fight.actions.action_original)
			self:pushOneCallFunc(self.totalFrames, "onOriginalEnd")
		else
			self:onOriginalEnd()
		end
	end

	--删除变身信息
	self.transbodyInfo = nil
	--切换成素颜  只有我方切换的时候 才做这个事情
	if self.camp == 1 then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGETREASURE,treasureIndex)
	end
	
end

--崩溃结束
function ModelAutoFight:onOriginalEnd(  )
	--这个时候让自己在单独做一次 特殊技 回合开始前判定
	-- 不做了 流程变了 后面会做
	-- self.data:checkChanceTrigger({camp = self.camp,chance =Fight.chance_roundStart})
	
	-- 崩溃完将回合状态置回
	return self:setRoundReady(Fight.process_treasure, true)
end

--[[
	做buff的特殊行为
]]
function ModelAutoFight:checkSpBuffOnAttackComplete()
	-- 冰符buff在放大招的时候有特殊的行为
	if self.currentSkill.skillIndex == Fight.skillIndex_max then
		-- 怒气消耗不增长buff
		if not self.data:checkHasOneBuffType(Fight.buffType_energyCostUnchange) then
			-- 放大招增加怒气增长次数
			self.maxSkillTimes = self.maxSkillTimes + 1
		else
			self.data:useBuffsByType(Fight.buffType_energyCostUnchange)
		end
		-- 暂时在这里发出个人怒气消耗值变化的通知
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE,{model=self})

		-- 冰符
		local buffs = self.data:getBuffsByType(Fight.buffType_bingfu)
		if buffs then
			for _,buff in ipairs(buffs) do
				buff:delayBingfu()
			end
		end

		-- 刑锁
		local buffs = self.data:getBuffsByType(Fight.buffType_xingsuo)
		if buffs then
			for _,buff in ipairs(buffs) do
				buff:checkXingsuoTrigger()
			end
		end
	end

	-- 攻击后做记次的
	for _,buffType in ipairs(Fight.useBuffByAttack) do
		self.data:useBuffsByType(buffType)
	end
end

--攻击完毕
function ModelAutoFight:onAttackComplete()
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,
							{tType = Fight.talkTip_afterSkill,
							skillId = self.currentSkill.hid})

	-- 做特殊buff的行为
	self:checkSpBuffOnAttackComplete()

	self.currentSkill:clearAtkChooseArr()
	-- self:checkAfterSkill(self.currentSkill)
	--判断触发被动技
	self:checkPassive()

	self.isAttacking = false
	self.attackComplete = true
	--判断时机 在做这个时机函数里面 可能 会触发连击 如果触发连接 会在 skillai里面把 attackComplete = false
	self.logical:doChanceFunc({camp = 0,chance = Fight.chance_atkend,attacker = self})

	if (not Fight.isDummy) and self.controler then
		-- 每打完一个人，隐藏总伤害的显示
	    local totalEff = self.controler.__totalDamageEff
	    if totalEff and totalEff.setShowEnd then
	    	totalEff:setShowEnd(true)
	    end
	end

	-- 隐藏可能存在的伤害
	if self.effectNum then
		self.effectNum:hideEff()
	end
	
	-- 重置首次攻击记录
	self:resetHasHit()
	
	if self.attackComplete then
		-- 自己是宠物执行主人回合后事件
		if self:isPet() then
			-- 技能类型一定是small
			self.logical:onAttackComplete(self:getPOwner(),Fight.skillIndex_small)
			return
		end
		
		-- 恢复自己的速度
		if self.__originSpeed then 
			self:setUpdateScale(self.__originSpeed)
			self.__originSpeed = nil
		end
		-- 如果自己是被中断的完成标志置回
		if self == self.logical.preAttackingHero then
			self.logical.preAttackingHero = nil 
			return
		end
		local curSkillIndex = self.currentSkill.skillIndex
		self.currentSkill = nil

		-- 再加一次判断
		if self ~= self.logical.attackingHero then return end

		local pet = self:getOnePet()
		-- 宠物跟随小技能出手(要判断当前宠物是否已经变成宠物了)
		if pet and pet:isPet() and curSkillIndex == Fight.skillIndex_small then
			return pet:giveOutOneSkill(pet.data:getSkillByIndex(Fight.skillIndex_small), Fight.skillIndex_small)
		else
			-- 宠物复盘的问题（如果是isDummy是不会走人物死亡相关的逻辑的，加在这里解决复盘问题）
			-- 同时加在这里不会导致复盘的时候宠物多出手
			if Fight.isDummy then
				if pet and not pet:isPet() then
					pet:beComePet()
				end
			end

			return self.logical:onAttackComplete(self,curSkillIndex)
		end
	end
end

--[[
	检查协助攻击
	@@lastHero 刚刚完成攻击的hero
	@@lastSkillIndex 刚刚释放的技能index
	return result是否有协助攻击,tSkill要释放的技能
]]
function ModelAutoFight:chkDoAssistAttack(lastHero,lastSkillIndex)
	local skills = self.data:getAllSkills(5)
	local result = false
	local tSkill = nil
	
	for _,skill in ipairs(skills) do
		if skill.skillExpand then
			result,tSkill = skill.skillExpand:chkAssistAttack(lastHero,lastSkillIndex)
		end
	end

	return result,tSkill
end
-----------------------------------------回合相关-------------------------------------------
-----------------------------------------回合相关-------------------------------------------
-----------------------------------------回合相关-------------------------------------------

--回合前做的事情（目前是结算buff，重置各种标记）
--回合前的流程 依次先判断 复活, 法宝treaover,召唤, 
function ModelAutoFight:doRoundFirst(  )

	self:resetAttackState("all")
	self.data:updateRoundFirst()
	-- 
	self:chkCanAttackByProfession()
	-- 重置出手次数
	self.atkTimes = 0
	--清空技能的选择目标缓存
    local skill = self:getNextSkill()
    if skill then
    	skill:clearAtkChooseArr()
    end
    
    -- 重置动作（这里会导致切波后打断人物往回跑的动作）
    -- self:justFrame(Fight.actions.action_stand)

	--初始化伤害结果判定(自己身上他人攻击自己的信息)
	self:resetDamageResultInfo()
	--初始化记录的伤害信息(自己身上攻击他人的信息)
	self:resetRecordDmgInfo()
end

-- 做回合前内容（复活、换法宝、回合前召唤（兼容以前代码暂时不做拆分））
function ModelAutoFight:doRoundFirstDelay()
	self:setRoundReady(Fight.process_treasure, false)

	--如果是将要自行复活的
	if self.reliveState == 1 and self.hasHealthDied then

		echo("_设置ready状态为false---",self.data.posIndex)

		--先做复活功能
		self:doReliveAction()
	else

	end
end

--做复活行为
--目前复活内部不给独立时间
-- force 强制做复活
function ModelAutoFight:doReliveAction(force)
	--如果是将要自行复活的
	if force or self.reliveState == 1 and self.hasHealthDied then
		-- 加血加怒
		local expandParams = self.reliveParams
		if expandParams then
			local  changeNums = self.data:changeValue(Fight.value_health,expandParams[2],expandParams[1],0)
			self:createNumEff(Fight.hitType_zhiliao ,changeNums)
			--改变怒气
			if expandParams[4] > 0 then
			    changeNums = self.data:changeValue(Fight.value_health,expandParams[4],expandParams[3],0)
			    self:createNumEff(Fight.hitType_jiafali  ,changeNums)
			end

			-- 移除复活的buff
			self.data:clearOneBuffByHid(expandParams.hid)
		end

		--把我插入进数组
		local campArr = self.campArr
		table.insert(campArr, self)
		local diedArr = self.diedArr
		--移除自己
		table.removebyvalue(diedArr, self)

		self.hasHealthDied =false

		self.logical:sortCampPos(self.camp)
		--重新加入数组排序
		
		-- 不再做复活动作，因为多数人没有且看不出来，并且之后的跑动可能会打断攻击的跑动
		-- self:justFrame(Fight.actions.action_relive,nil,true)
		-- if Fight.isDummy  then
			self:onReliveComplete()
		-- else
		-- 	self:pushOneCallFunc(self.totalFrames, "onReliveComplete")
		-- end
	end
end

--[[
	执行人物死亡
	特殊情况执行，不会发送人物死亡等事件
	遍历时注意反向遍历
	doNotPlayAction:是否需要播放死亡动作，默认nil
]]
function ModelAutoFight:doHeroDie(doNotPlayAction)
	if self._isDied then
		echo("已经死亡了不继续做死亡事件")
		return
	end
	-- 清理可能存在的触发回调
	self.triggerSkillControler:removeOneSkillFuncByModel(self)
	
	-- 如果将要被复活不能执行强制杀死
	if self:checkWillBeRelive() or self:checkWillDieSkill() then
		echo("将要复活的不死亡")
		return
	end

	self._isZiBao = true
	-- 在人物列表里移除自己
	table.removebyvalue(self.campArr, self)

	-- 在死亡列表里移除自己
	table.removebyvalue(self.diedArr, self)
	-- 清除可能存在的其他内容
	self.data:cancleAure()
	self:onRemoveCamp()
	
	self.logical:onOneHeroDied(self)
	
	-- 战前战中换人不做处理
	if BattleControler:checkIsCrossPeak() then
		local bState = self.controler.logical:getBattleState()
		if bState == Fight.battleState_formationBefore or
			bState == Fight.battleState_changePerson then
		else
			self.controler:checkGameResult() -- 死人就要检查结果
		end
	else
		self.controler:checkGameResult() -- 死人就要检查结果
	end

	-- 做死亡动作
	if not doNotPlayAction then
		self:justFrame(Fight.actions.action_die, nil, true)
	else
		self:startDoDiedFunc()
	end
	
	if self.healthBar then
		self.healthBar:visible(false)
	end
end

--复活完毕
function ModelAutoFight:onReliveComplete(  )
	--改变复活状态
	self.reliveState = 2
	--取消标记死亡
		
	--判断是否在原地
	echo("_复活完毕-------state:%s,是否原地:%s,人物位置:%s",self.myState,tostring(self.pos.x == self._initPos.x),self.data.posIndex)
	if not Fight.isDummy and self.pos.x ~= self._initPos.x then
		--3表示复活起身
		self:movetoInitPos(3)
	-- else
	-- 	self:checkTreasureEnd()
	end
end




--判断是否法宝崩溃
function ModelAutoFight:checkTreasureEnd(  )
	if self.data.curTreasure.leftRound  > 0 then
		--减少法宝使用次数
		self.data.curTreasure.leftRound = self.data.curTreasure.leftRound-1
	end
	
	--如果是变身的
	if self.data.curTreasure.leftRound == 0 or self.transbodyInfo then
		--如果是清除控制形buff的 ,那么需要清除晕眩冰冻和沉默
		if self.transbodyInfo and  self.transbodyInfo.params1 == 1 then
			self.data:clearGroupBuff(Fight.buffType_xuanyun )
			self.data:clearGroupBuff(Fight.buffType_bingdong )
			self.data:clearGroupBuff(Fight.buffType_shufu )
			self.data:clearGroupBuff(Fight.buffType_chenmo  )
			self.data:clearGroupBuff(Fight.buffType_mabi  )
			self.data:clearGroupBuff(Fight.buffType_sleep)
		end
		-- if self.data:checkHasOneBuffType(Fight.buffType_bingdong) then
		-- 	return
		-- end
		--设置回合readyFals
		self:setRoundReady(Fight.process_treasure, false)
		if Fight.isDummy  then
			--直接over
			self:onTreasureOverEnd()
		else
			-- 有变身动作
			if self.transbodyInfo and self.transbodyInfo.params2 == 1 then
				self:justFrame(Fight.actions.action_treaOver)
				self:pushOneCallFunc(self.totalFrames, "onTreasureOverEnd")
			else
				--直接over
				self:onTreasureOverEnd()
			end
		end
		
		echo("____法宝崩溃,当前法宝位置:",self.data.curTreasureIndex,self.totalFrames)
	end
end

--敌方回合前做什么事情
function ModelAutoFight:doToRoundFirst(  )
	-- 这种模式下敌方回合前也要重置
	if self.logical.roundModel == Fight.roundModel_switch then
		--初始化伤害结果判定(自己身上他人攻击自己的信息)
		self:resetDamageResultInfo()
		--初始化记录的伤害信息(自己身上攻击他人的信息)
		self:resetRecordDmgInfo()
	end

	-- 如果移动中不打断动作,后面没有实际逻辑（目前出现在锁妖塔偷袭切回合太快会打断）
	if self:isMove() then return end

	--判断是否进入防守状态
	if self.data:checkCanAttack() then
		--切换动作的时候  需要进行分帧
		if Fight.isDummy  then
			self:justFrame(Fight.actions.action_stand2Start)
		else
			-- 目前看延迟没有什么作用，先注掉防止各种动作打断。2018.04.03
			-- if self.camp == 1 then
			-- 	local delayFrame = 0
			-- 	delayFrame = (math.ceil(self.data.posIndex/2)  -1) * 5
			-- 	if delayFrame > 0 then
			-- 		self:pushOneCallFunc(delayFrame, "justFrame", {Fight.actions.action_stand2Start})
			-- 	else
			-- 		self:justFrame(Fight.actions.action_stand2Start)
			-- 	end
				
			-- else
			-- 	self:justFrame(Fight.actions.action_stand2Start)
			-- end
			self:justFrame(Fight.actions.action_stand2Start)
		end
		
		
	end
end

--我方回合后做的事情
function ModelAutoFight:doRoundEnd(  )
	self.data:updateRoundEnd()
	-- 这里也需要重置一下攻击信息，不然在roundModel_switch模式下无法攻击
	self:resetAttackState("all")
	-- 等待释放大招状态重置，因为可能技能点了没有放出来
	self.isWaiting = false
	-- 将不能攻击的角色重置
	self:chkCanAttackByProfession()
	-- 重置攻击过我的人的记录
	self:resetAttackerArray()
end

--敌方回合后做的事情
function ModelAutoFight:doToRoundEnd(  )
	self.data:updateToRoundEnd()


end
-- 获取攻击包指令
function ModelAutoFight:getBaseOperationInfo( )
	local operationInfo = {index = self.data.posIndex ,camp = self.camp,
	type = Fight.operationType_giveSkill,params = Fight.skillIndex_max,
	timely = false,
	}
	return operationInfo
end
-- 根据给的操作模式返回攻击包信息
function ModelAutoFight:chooseAppointHandle(opType)
	local operationInfo = self:getBaseOperationInfo()
	-- 有预设释放的技能
	if self.__aiSkill then
		opType = self.__aiSkill
	end
	if opType == Fight.operationType_BigSkill then
		if self.data.isCharacter then
			operationInfo.type = Fight.operationType_giveTreasure
			operationInfo.params = 1
		else
			operationInfo.type = Fight.operationType_giveSkill
			operationInfo.params = Fight.skillIndex_max
		end
	elseif opType == Fight.operationType_giveSkill then
		operationInfo.type = Fight.operationType_giveSkill
		operationInfo.params = Fight.skillIndex_small
	end
	--记录一个出手次数 作为唯一性校验
	operationInfo.atkTimes = self.atkTimes
	return operationInfo
end

-- 设置Logical Ai选择的技能
function ModelAutoFight:setAiSkill(skilltype)
	self.__aiSkill = skilltype
end

-- roundModel模式回合类型
function ModelAutoFight:chooseOneAutoHandle(roundModel)
	local opInfo = self:getBaseOperationInfo()
	if roundModel == Fight.roundModel_normal then
		if self.data:checkCanGiveSkill() then
			--判断能否给大招
			opInfo = self:chooseAppointHandle(Fight.operationType_BigSkill)
		else
			-- 默认给小技能
			opInfo = self:chooseAppointHandle(Fight.operationType_giveSkill)
		end
	elseif roundModel == Fight.roundModel_semiautomated then
		echo("回合模式----===",roundModel,self.data.posIndex,self.camp)
		-- 如果自动战斗自动优先释放大招(不是小怪)
        if self:getHeroProfession() ~= Fight.profession_monster and
         self.logical:checkIsAutoAttack(self.camp,self.data.characterRid) and
          self.data:checkCanGiveSkill() and not self.hasOperate then
			opInfo = self:chooseAppointHandle(Fight.operationType_BigSkill)
		else
			opInfo = self:chooseAppointHandle(Fight.operationType_giveSkill)
		end
	elseif roundModel == Fight.roundModel_switch then
		if self.logical:checkIsAutoAttack(self.camp,self.data.characterRid) and self.data:checkCanGiveSkill() and not self.hasOperate then
			opInfo = self:chooseAppointHandle(Fight.operationType_BigSkill)
		else
			opInfo = self:chooseAppointHandle(Fight.operationType_giveSkill)
		end
	end
	-- 选完后置空一下预选技能
	self:setAiSkill(nil)

	return opInfo
end


--激活击杀技
function ModelAutoFight:onKillEnemy( killedHero )
	if (not Fight.isDummy) and self.currentSkill then
		local isCrit = false
		local atkResult = killedHero:getDamageResult(self, self.currentSkill)
		if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
			isCrit = true
		end
		local sourceId = killedHero.data:getCurrTreasureSourceId()
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_onKill,isCrit = isCrit,killerId = sourceId})
	end
	--判断当前技能ai
	if self.currentSkill and self.currentSkill.skillExpand then
		self.currentSkill.skillExpand:onKillEnemy(self,killedHero)
	end
	--判断特殊技
	local specialSkill = self.data:getSpecialSkill()
	if specialSkill and specialSkill.skillExpand then
		specialSkill.skillExpand:onKillEnemy(self,killedHero)
	end


	--[[
	去掉击杀技这个设定
	local killSkill = self.data.curTreasure.skill7
	if not killSkill then
		return 
	end
	echo("___activityKillSkill",killSkill.hid)
	self.hasKillEnemy = true
	killSkill:doAtkDataFunc()
	]]
end

--[[
	重置攻击状态
	kind 重置类型"all"所有 "small"小技能 "max"大招
]]

function ModelAutoFight:resetAttackState(kind)
	kind = kind or "all"
	if kind == "all" or kind == "max" then
		self.hasOperate = false
	end
	if kind == "all" or kind == "small" then
		self.hasAutoMove = false
	end

	if kind ~= "small" then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHECK_UI_HEAD,{model=self})
	end
end
-- 攻击过
function ModelAutoFight:hasAttacked()
	return self.hasOperate or self.hasAutoMove
end

-- 检查混乱行为
function ModelAutoFight:checkConfusion()
	-- 中了混乱buff
	if self.data:checkHasOneBuffType(Fight.buffType_hunluan) then
		-- 概率
		local ratio = self.data:getOneBuffValue(Fight.buffType_hunluan)
		-- 产生混乱（并且己方有人而且是有活人才可以）
		if ratio > BattleRandomControl.getOneRandomInt(10001, 1) then
			local flag = false
			-- 遍历己方阵容是否有其他人
			for _,hero in ipairs(self.campArr) do
				if hero ~= self and not hero:hasNotAliveBuff() then
					flag = true
					break
				end
			end
			if flag then
				self:mutiny()
				-- 标记自己产生了混乱，攻击结束后要重置
				self._confusion = true 
			end
		end
		--[[
			buff被使用一次（正常是覆盖的所以里面应该只有一个buff）
			目前认为每判定一次就使用了一次
		]]
		self.data:useBuffsByType(Fight.buffType_hunluan)
	end
	-- 自己带有傀儡buff
	if self.data:checkHasOneBuffType(Fight.buffType_kuilei) then
		-- 所属阵营与自己阵营不同，要先做混乱
		if self.puppeteer ~= self.camp then
			self:mutiny()
			self._confusion = true
		end
	end
end

-- 重置混乱行为
function ModelAutoFight:resetConfusion()
	if self._confusion --[[and not self._isDied]] then
		self:mutiny()
		self._confusion = false
	end
end

-- 是否为混乱状态
function ModelAutoFight:isConfusion()
	return self._confusion
end

-- 转换自己的阵营为敌方（叛变）混乱用
function ModelAutoFight:mutiny()
	local toArr = self.toArr
	local campArr = self.campArr

	local toCamp = self.toCamp
	local camp = self.camp

	local way = self.way

	-- 这些操作只有在人物没死的情况下才能做
	if not self._isDied then
		-- 找到自己的位置
		local idx = nil
		for i=#campArr,1,-1 do
			if campArr[i] == self then
				idx = i
				break
			end
		end
		-- 没找到说明已经删除过或者自己已经死亡
		-- if not idx then return end
		-- 找到才做阵营的操作，找不到也要将阵营重置，不然回合可能混乱
		if idx then
			-- 先把自己放到对面阵营里
			table.remove(campArr, idx)
			table.insert(toArr, self)
			-- 排序
			self.logical:sortCampPos(campArr)
		  	self.logical:sortCampPos(toArr)
		  	-- 交换变量
		  	self.toArr = campArr
		  	self.campArr = toArr
		end
	end
  	self.toCamp = camp
  	self.camp = toCamp
  	
	if self.puppeteer == self.camp then
		self.way = -way
	end
end

-- 根据阵营和技能出现方式获取脸的朝向
function ModelAutoFight:getMyAtkWay(skill)
	local appear = skill:sta_appear()
	if not appear then
		echoError("找策划skill:%d没有配置appear",skill.hid)
	end
	-- 面向敌方
	local faceToenemy = {
		Fight.skill_appear_normal,
		Fight.skill_appear_normalEx,
		Fight.skill_appear_ymiddle,
		Fight.skill_appear_toMiddle,
		Fight.skill_appear_myplace,
	}
	-- 面向己方
	local faceToSelf = {
		Fight.skill_appear_myFirst,
		Fight.skill_appear_myMiddle,
		Fight.skill_appear_myyMiddle,
	}
	-- 面向己方
	if array.isExistInArray(faceToSelf, appear) then
		return self.camp == 1 and Fight.enemyWay or Fight.myWay
	elseif array.isExistInArray(faceToenemy, appear) then
		return self.camp == 2 and Fight.enemyWay or Fight.myWay
	end

	echoError("找策划技能skill:%d配置的appear:%d不存在", skill.hid, skill:sta_appear())
end

--[[
	做协助技
	阵营初始化完毕后会做
]]
function ModelAutoFight:doHelpSkill()
	-- 强更一下位置（血条修改后，协助技的buff位置会受时机影响不正确，应该是位置问题，所以加入代码，做之前强刷一下位置）
	self:realPos()

	local skills = self.data:getAllSkills()
	for _,skill in ipairs(skills) do
		if skill.helpSkillAtk then
			self:checkAttack(skill.helpSkillAtk,skill)
		end
	end
end

-- 重置攻击记录
function ModelAutoFight:resetHasHit(posIndex)
	local pos = posIndex

	if pos then
		self.hasHit[pos] = false
	else
		for k,v in pairs(self.hasHit) do
			self.hasHit[k] = false
		end
	end
end

-- 标记是否攻击过
function ModelAutoFight:setHasHit(posIndex)
	if posIndex and posIndex >= 1 and posIndex <= 6 then
		self.hasHit[posIndex] = true
	else
		echoError("posIndex:%s不符合条件",posIndex)
	end
end

-- 获取是否攻击过
function ModelAutoFight:getHasHit(posIndex)
	return self.hasHit[posIndex] == true
end
-- 重置攻击我的数组
function ModelAutoFight:resetAttackerArray( ... )
	self.attackerArray = {}
end
-- 记录攻击我的角色的Rid
function ModelAutoFight:saveAttackerRid(attacker )
	if #self.attackerArray > 0 then
		if self:getLastAttackerRid() ~= attacker.data.rid then
			table.insert(self.attackerArray,attacker.data.rid)
		end
	else
		table.insert(self.attackerArray,attacker.data.rid)
	end
end
-- 获取最后攻击我的人
function ModelAutoFight:getLastAttackerRid(  )
	if #self.attackerArray > 0 then
		return self.attackerArray[#self.attackerArray]
	end
	return nil
end
-- 根据职业检测是否可攻击
function ModelAutoFight:chkCanAttackByProfession( )
	-- 如果是中立或者障碍物、不能行动;则将行动置为true
	if self:getHeroProfession() == Fight.profession_neutral or 
		self:getHeroProfession() == Fight.profession_obstacle then
		self.hasOperate = true
		self.hasAutoMove = true
	end
end
-- 临时设置角色不可攻击方法(波数刷怪当前回合不可攻击)
function ModelAutoFight:setCanNotAttack()
	self.hasOperate = true
	self.hasAutoMove = true
end

-- 死亡时检查一下buff
function ModelAutoFight:checkDieBuffs(attacker)
	local buffs = self.data:getBuffsByType(Fight.buffType_atkcarrier)
	if buffs and attacker then
		echo("携带攻击包的buff生效，并作用")
		for _,buff in ipairs(buffs) do
			local expandParams = buff.expandParams -- expandParams中是攻击包
			if expandParams and expandParams[1] == 2 then
				for i=2,#expandParams do
					self:sureAttackObj(attacker,expandParams[i],buff.skill)
				end
			end
		end
	end
end
-- 是否有存动作
function ModelAutoFight:isNeeddoInitPosComplete()
	return self.__onInitPosComplete ~= nil
end
-- 做缓存动作
function ModelAutoFight:doInitPosComplete()
	if self.__onInitPosComplete then
		local func = self.__onInitPosComplete
		self.__onInitPosComplete = nil
		return func()
	end
end
-- 重写下到达目的地方法 --
function ModelAutoFight:onRefreshMoveComplete()
	-- 移动到位后
	self:doInitPosComplete()
	ModelAutoFight.super.onRefreshMoveComplete(self)
end

function ModelAutoFight:standAction()
	-- 移动到位后
	self:doInitPosComplete()
	ModelAutoFight.super.standAction(self)
end
-- 重写下到达目的地方法 --