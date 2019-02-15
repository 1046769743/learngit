--
-- Author: XD
-- Date: 2014-07-10 12:03:53
--主要处理一些特殊功能 表现相关
--
local Fight = Fight
-- local BattleControler = BattleControler -- 2018.04.14注掉，以这种方式赋值，BattleControler无法被全局替换
local FuncDataSetting  = FuncDataSetting
ModelHero = class("ModelHero", ModelAutoFight)
local table = table

ModelHero._reFreshPos = nil -- 如果是怪物，需要记住怪物的刷新点
ModelHero._fightState = nil -- 战斗方式


--是否回合钱准备好了
ModelHero.isRoundReady = true
 
ModelHero.transbodyInfo = nil 		--将要变身的hid 针对boss


ModelHero.hasKillEnemy = false 		--是否杀人了


--
ModelHero.effectWordInfo = nil 		--飘字管理
ModelHero.effectWordLeftFrame = -1

ModelHero._roundReadyT = nil -- 为了处理非顺势操作，记录调用roundDeady的次数（为了保证set false 和 set true次数对应，不然多次设置会冲突）
---------宠物逻辑目前废弃代码尚未删除---------
ModelHero._pet = nil -- 存放宠物，目前只有李忆如使用，只有部分逻辑
ModelHero._owner = nil -- 对应宠物，存放主人
ModelHero._isPet = nil
---------宠物逻辑目前废弃代码尚未删除---------

ModelHero.puppeteer = nil -- 傀儡师（这里只存傀儡归属的阵营）

-- 加modelType是为了不强制覆盖为heroes
function ModelHero:ctor( controler,obj,modelType )
    self.modelType = modelType or Fight.modelType_heroes
	ModelHero.super.ctor(self,controler,obj)

    self._hasArriveReadyPos = false

    self._interTreasure = "bzd" 
    self._reFreshPos = 0
    --这两个现在应该都不需要了。
    self.usedTreasures = {}
    self.showTreasures = {}

    if not Fight.isDummy then
    	--回合开始   法宝如果存在就消失
	    FightEvent:addEventListener("BATTLE_SHOW_HERO", self.pressShowHero, self)

	    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_CHANGE, self.checkFullEnergyStyle, self)

    end
    
    self.effectWordInfo = {}
    self.effectWordLeftFrame = -1

    self._roundReadyT = {} -- set false 入栈，set true 出栈，为空时才改变状态
    local mt = {
		__index = function(t, key)
			return 0
		end
	}
	setmetatable(self._roundReadyT,mt)
    self._pet = {}
    self._isPet = false
    -- obj:addEventListener(BattleEvent.BATTLEEVENT_CHANGEENEGRY, self.checkFullEnergyStyle, self)

end
function ModelHero:pressShowHero( event )
	self.myView.currentAni:visible(event.params)
	if event.params then
		self.myView:play()
	else
		self.myView:pause()
	end
end

--判断是否是主要的英雄 如果是我方 那么应该是主角  如果是地方 那么应该是 敌人的boss
function ModelHero:checkIsMainHero(  )
	if self.data.isCharacter then
		return true
	elseif self.data:boss() == 1 then
		return true
	end

	return false
end


--初始化完毕
function ModelHero:onInitComplete( )

	if not Fight.isDummy then
		-- 创建血条
		local kind = 2  -- 1 主角 2 除了小怪和召唤物 3 小怪 、6 中立怪 7 障碍物 (公用小怪血条)
		if self.data.isCharacter then
			kind = 1
		end
		-- 2018.01.24 pangkangning 现在应该没有用到peopleType这个字段的地方
		-- local peopleType = self.data:peopleType()
		-- if peopleType == Fight.people_type_monster then
		-- 	kind = 3
		-- end
		local profession = self:getHeroProfession()
		local isMonster = (profession == Fight.profession_monster)
		-- 锁妖塔、小怪配了五行，则显示五行标签
		if BattleControler:checkIsTower() and self:getHeroElement() ~= Fight.element_non then
			isMonster = false
		end
		if profession == Fight.profession_neutral or
		 profession == Fight.profession_obstacle or
		 isMonster
		  then
			kind = 3
		end

		self:createHealthBar(0,self.data.viewSize[2] * Fight.wholeScale ,self.controler.layer:getGameCtn(2),kind)
	end
	--注册点击事件
	if self.camp == 1 then
		self:setClickFunc()
	elseif self.camp == 2 then
		self:checkCreateHeadBuff()
		self:setClickFunc()
	end
	
end
-- 气泡处理
function ModelHero:checkTallBubbleOnComplete(  )
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_enterEnd})
end

--判断头上顶特殊buff
function ModelHero:checkCreateHeadBuff(  )
	if Fight.isDummy  then
		return
	end
	local beKillInfo = self.data:beKill()
	if not beKillInfo then
		return
	end

	local iconType = beKillInfo[3]
	local aniName = "UI_zhandou_buff"
	if iconType == "1" then
		--todo
	end
	self._headBuffEff = self:createEff(aniName, 0, 100, 1, 1, true, true, true,nil,nil,self)
	self._headBuffEff.pianyiPos.z = -self.data.viewSize[2] - 50
end

--当被杀死的时候 	后面是助攻人员
function ModelHero:beKilled( attacker ,zhugongArr)
	self:doKillEff(attacker,zhugongArr)
	local beKillInfo = self.data:beKill()
	if not beKillInfo then
		return
	end



	if not attacker then
		if not self._headBuffEff then
			return
		end
		self._headBuffEff:deleteMe()
		self._headBuffEff = nil
	else
		--如果是做攻击包
		self:doBeKillEnemyBuff(beKillInfo,attacker)
		
	end
end

--[[
	被杀死的时候 飘球球特球特效
	modify 2017.10.10
	修改内容：
	只有敌方被杀才飞球
	去掉关于助攻的飘球，固定球的数量
	修改球飞的终点为右侧UI怒气条
]]
function ModelHero:doKillEff( attacker ,zhugongArr )
	if Fight.isDummy  then
		return
	end
	if self.camp == 1 then
		return
	end
	-- 攻击者死亡不执行
	if attacker.data:hp() <= 0 then
		return 
	end
	--如果是超速的 那么不执行
	if self.controler:isQuickRunGame()  then
		return
	end
	--需要创建的数量

	local perNums = 2 
	local attackNums = 6 --主角至少4个	
	--如果没有助攻的 主角是6个
	if #zhugongArr == 0 then
		attackNums = 6 
	end

	local createNums = (attackNums + perNums * #zhugongArr )

	--根据createNums 创建组合 由 3 4 5 6 边形组合
	local numsToShapeMap = {
		[6] = {6},
		[7] = {4,3},
		[8] = {4,4},
		[9] = {5,4},
		[10] = {6,4},
		[11] = {6,5},
		[12] ={6,6},
		[13] = {5,4,4},
		[14] = {6,4,4},
		[15] = {5,5,5},
		[16] = {6,5,5},
		[17] = {6,6,5},
		[18] = {6,6,6},
	}
	--半径数组
	local ratioArr = {
		[1] = {{130,120,0} },
		[2] = {{160,150,0},{100,90,math.pi/4}},
		[3] = {{160,150,0},{100,90,math.pi/6},{60,55,math.pi*2/6}	},
	}

	--先随机这么多角度
	local angleArr = {}
	--全部用弧度
	
	local perAng  =0

	--定义形状数组
	local shapeArr = numsToShapeMap[createNums]
	local rGroup = ratioArr[#shapeArr]
	for i,v in ipairs(shapeArr) do
		--读取对应的半径数组
		local rArea = rGroup[i]
		perAng = 2 * math.pi/ v
		for i=1,v do
			local r = RandomControl.getOneRandomInt(rArea[1], rArea[2])
			local ang = perAng * (i-1) + rArea[3]
			table.insert(angleArr,{ang = ang,r = r})
		end
	end


	--然后在把这个数组随机打乱
	angleArr = RandomControl.randomOneGroupArr(angleArr)


	local followTarget = function (eff,hero,effIndex  )
		--如果英雄死亡了  那么直接消失
		if hero._isDied then
			eff:clear()
			return
		end
		local xpos,ypos = eff:getPosition()

		local targetx,targety
		local energyPos = hero.controler.gameUi:getEnergyPos(hero.controler.layer.a123)
		targetx = energyPos.x
		targety = energyPos.y
		--[[
		targetx = hero.pos.x
		targety = -hero.pos.y + hero.data.viewSize[2] /2
		]]

		local dx = targetx - xpos
		local dy = targety - ypos
		local dis = math.sqrt(dx*dx+ dy*dy)
		local minSpeed = 40
		if dis <= minSpeed then
			--销毁eff
			-- echo("销毁eff")
			eff:unscheduleUpdate()
			eff:delayCall(c_func(eff.clear,eff,true), 0.001)

			return
		end

		local speed = dis * 0.1
		if speed < minSpeed then
			speed = minSpeed
		end
		speed = minSpeed

		local ang = math.atan2(targety-ypos, targetx - xpos)
		eff.weiba:setRotation(-ang * 180/math.pi)
		--缓动追上去
		eff:setPosition(xpos + speed * math.cos(ang),ypos + speed * math.sin(ang))
		if not eff._updateCount then
			eff._updateCount = 0
		end
		eff._updateCount = eff._updateCount +1
		local weibaScale = 1
		local targetScale = dis /200
		
		targetScale = targetScale> 4 and 4 or targetScale
		targetScale = targetScale < 1 and 1 or targetScale


		if eff._updateCount < 10 then
			weibaScale = 0.3 * eff._updateCount + 0.7
			--20帧以后 就开始逐渐恢复原大小
		elseif eff._updateCount > 20 then
			--计算scale差
			weibaScale = eff.weiba:getScaleX()
			local disScale = targetScale -  weibaScale 
			disScale = disScale * 0.1
			local minScaleSpeed = 0.1
			if disScale< minScaleSpeed and disScale > -minScaleSpeed then
				weibaScale = targetScale
			else
				weibaScale = weibaScale + disScale
			end
		end
		eff.weiba:setScaleX(weibaScale)


	end

	--当炸开的时候  需要追上对应的hero
	local onzhakai = function (eff, hero ,effIndex )
		--这是目标点
		local targetx,targety
		targetx = hero.pos.x
		targety = -hero.pos.y + hero.data.viewSize[2] /2
		local xpos,ypos = eff:getPosition()
		local ang = math.atan2(targety-ypos, targetx - xpos)
		--设置角度
		eff.weiba:setRotation(-ang * 180/math.pi)
		eff.weiba:setScaleX(1)
		eff:scheduleUpdateWithPriorityLua(c_func(followTarget,eff,hero,effIndex),0)
	end

	--创建一个爆开效果 
	local layer = self.controler.layer.a123
	local createEff = function ( angle,hero,effIndex ,radio)
		local nd = display.newNode():addto(layer)
		local weiba = display.newSprite(FuncRes.iconBattle("battle_tuowei")):addto(nd)
		--获取球
		local yuan = display.newSprite(FuncRes.iconBattle("battle_qiu")):addto(nd)
		weiba:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
		yuan:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
		nd.weiba = weiba
		nd.yuan = yuan

		-- 刚开始是炸出去
		weiba:setScaleX(0)
		weiba:setRotation(-angle*180/math.pi)
		--随机一个运动距离
		local distance = radio
		local xpos,ypos = self:getViewCenterPos()
		nd:pos(xpos,ypos)
		--初始的时候 只给50透明度
		nd:opacity(50)
		local targetx = xpos + distance * math.cos(angle)
		local targety = ypos + distance * math.sin(angle)

		local targetx2 = xpos + (distance - 20 )* math.cos(angle)
		local targety2 = ypos + (distance - 20 ) * math.sin(angle)
		local disTime = (distance -50) /1000

		--先让容器整体做运动
		local moveAct = act.moveto(0.2, targetx, targety)

		local bounceAct  = act.bounceout(moveAct)

		local moveAct2 = act.moveto(0.2, targetx2, targety2)

		local delayAct = act.delaytime( disTime )
		local callAct = act.callfunc(c_func(onzhakai,nd,hero,effIndex))
		
		local seqAct = act.sequence(bounceAct,moveAct2,delayAct,callAct)
		nd:runAction(seqAct)
		nd:fadeTo(0.1, 255)

	end




	for i=1,createNums do
		if i <= attackNums then
			-- 屏蔽加怒
			if not attacker.data:checkHasOneBuffType(Fight.buffType_fengnu) then
				createEff(angleArr[i].ang,attacker,i,angleArr[i].r)
			end
		else
			if not attacker.data:checkHasOneBuffType(Fight.buffType_fengnu) then
				createEff(angleArr[i].ang,zhugongArr[math.ceil( (i-attackNums)/perNums)],i,angleArr[i].r)
			end
		end
	end
end

--[[
	做人物获得公用怒气的特效
	每一个单独飞一个
	-- etype 怒气类型，大小
	value 获得的数量
]]
function ModelHero:doGetEnergyEff(value)
	-- 跑逻辑不创建
	if Fight.isDummy then return end
	-- 快跑不创建
	if self.controler:isQuickRunGame() then return end
	-- 演示不创建
	if self.controler:isInMiniBattle() then return end
	-- 敌方不创建
	if self.camp == 2 then return end

	local layer = nil --self.controler.layer.a123
	local gameUi = self.controler.gameUi

	layer = gameUi

	-- 消失并清除自己
	local onArrival = function ( eff )
		eff.ani.currentAni:playWithIndex(2)
		eff.ani.currentAni:doByLastFrame(false,false,function()
			if eff and not tolua.isnull(eff) then
				eff:clear()
			end
		end)
	end
	-- 移动到指定位置
	local moveToPos = function (eff)
		local targetx, targety
		local energyPos = gameUi:getEnergyPos(layer)
		targetx = energyPos.x
		targety = energyPos.y
		
		self._energyEffIdx = self._energyEffIdx - 1

		local delayAct = act.delaytime( eff.idx * 0.1 )
		local moveAct = act.moveto(0.5, targetx, targety)
		local callAct = act.callfunc(c_func(onArrival,nd))
		local seqAct = act.sequence(delayAct, moveAct, callAct)

		eff:runAction(seqAct)
	end
	-- 创建一个火
	local createEff = function ( idx )
		-- 创建一个容器便于操作
		local nd = display.newNode():addto(layer)
		local ani = ViewArmature.new("UI_zhandou_nuqihuo"):addto(nd)
		local xpos,ypos = self:getViewCenterPos()
		local tempPos = self.myView:getParent():convertLocalToNodeLocalPos(layer, cc.p(xpos,ypos))
		nd:setPosition(tempPos.x, tempPos.y)

		nd.idx = idx or 0
		nd.ani = ani
		-- ani.currentAni:runEndToNextLabel(0,1,true)
		ani.currentAni:playWithIndex(0)
		ani.currentAni:doByLastFrame(false,false,c_func(moveToPos,nd))

		return nd
	end
	
	local num = math.abs(value or 0)
	if not self._energyEffIdx then self._energyEffIdx = 0 end
	if num > 5 then num = 5 end -- 太多认为是错误情况
	for i=1,num do
		self._energyEffIdx = self._energyEffIdx + 1
		createEff(self._energyEffIdx)
	end
end

function ModelHero:doBeKillEnemyBuff( beKillInfo,attacker )
	if not beKillInfo then
		return
	end
	--如果是做攻击包
	if beKillInfo[1] == "1" then
		local atkData = ObjectAttack.new(beKillInfo[2])
		attacker:checkAttack(atkData,attacker.data.curTreasure.skill1)
	end

	--如果是超速的 那么不执行
	if self.controler:isQuickRunGame()  then
		return
	end

	if not self._headBuffEff then
		return
	end

	local target = attacker
	local fromPos = {x = self.pos.x, y = self.pos.y}	
	--如果不是我自己吃的buff
	if attacker ~= self then
		local modelEnergy = ModelEffectEnergy.new(self.controler)
		modelEnergy:setTarget(target,fromPos)
		self.controler:insertOneObject(modelEnergy)
	end
	

	local dx = (attacker.pos.x - self.pos.x) * self._headBuffEff.way
	local dy = attacker.pos.y - self.pos.y 
	-- self._headBuffEff:setFollow(false)

	local actDelay = act.delaytime(1.5)
	local act1 = act.moveto(0.2, dx, -dy-self.data.viewSize[2]/2)
	local act2 = act.fadeto(0.2,0)
	local actque = act.sequence(actDelay,act1,act2)
	self._headBuffEff.myView.currentAni:runAction(actque)
	self._headBuffEff:pushOneCallFunc(50, "startDoDiedFunc")
	self._headBuffEff = nil

end


--[[
回合开始前
]]
function ModelHero:doRoundFirst(  )
	ModelHero.super.doRoundFirst(self)
	if Fight.isDummy  then
		return
	end
	if (not self.data:checkCanAttack() )  then
		-- 冰封不显示无法行动
		if not self.data:checkHasOneBuffType(Fight.buffType_bingfeng) then
			self:insterEffWord({2,Fight.wenzi_noAction,Fight.buffKind_huai})	
		end
	end


end



--[[
回合结束
]]
function ModelHero:doRoundEnd(  )
	ModelHero.super.doRoundEnd(self)
	--self:hideCanAttack()
	self:YinCangDaZhao()
	self:hideAttackNum()
end



--[[
隐藏大招
]]
function ModelHero:YinCangDaZhao()
	if Fight.isDummy  then
		return
	end
	self.healthBar:YinCangFaBao()
end



--[[
点击hero显示 攻击次序
]]
function ModelHero:showAttackNum(num)
	--echo("aaaaaaaaaaaaaaaaa")
	local canAttack = true
    if self.logical.currentCamp ~= 1 then
        canAttack = false
    end

    if canAttack then
		if num>=2 and num<=6 then
			self.healthBar:showAttackNum(num,self.data.viewSize[1],(self.data.viewSize[2] ) * Fight.wholeScale)
		end
	end
end

--[[
隐藏操作数字
]]
function ModelHero:hideAttackNum(  )
	if Fight.isDummy then
		return
	end
	--echo("攻击发生了。隐藏掉 数字")
	self.healthBar:hideAttackNum()
end




--给场上英雄注册点击事件 点击后显示 明按
function ModelHero:setClickFunc(  )

	if Fight.isDummy then
		return
	end
	--如果是敌方的 不给点击事件
	-- if self.camp == 2 then
	-- 	return
	-- end

	local nd = display.newNode()
	local viewSize 
	local figure = self.data:figure()
	local wid = math.ceil(figure/2)
	local hei = figure >1 and 1.5 or 1
	wid = wid *Fight.position_xdistance
	hei = 110 * hei + 80

	nd:setContentSize(cc.size(wid,hei) )
	nd:addto(self.healthBar,-1)
	--nd:pos()
	--注册点全部放到脚下
	nd:anchor(0,0.1)

	nd:pos(-wid* 0.5,- self.healthBarPos.y)

	-- 展示战斗不需要点击事件
	if self.controler:isInMiniBattle() then
		return
	end

	-- 注册点击事件
	nd:setTouchedFunc(c_func(self.pressClickView,self), nil, true, 
					c_func(self.pressClickViewDown, self), 
					c_func(self.pressClickViewMove, self),false,
					c_func(self.pressClickViewUp, self) )
		FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BUZHEN_CANCLE, self.buZhenTimeOver, self)
	
	-- --必须是自己人才可以触发移动或者点击事件
	-- if self.camp == BattleControler:getTeamCamp() 
	-- 	and self.data.characterRid == self.controler:getUserRid() 
	-- then
	-- 	nd:setTouchedFunc(c_func(self.pressClickView,self), nil, true, c_func(self.pressClickViewDown, self), c_func(self.pressClickViewMove, self),false,c_func(self.pressClickViewUp, self) )
	-- 	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BUZHEN_CANCLE, self.buZhenTimeOver, self)
	-- 	--创建脚下光环
	-- 	if self.controler.gameMode == Fight.gameMode_gve  then
	-- 		local ani = FuncArmature.createArmature("common_juese_xia", nil, true)
	-- 		ani:addto(self.myView,-1000)
			
	-- 	end
	-- end
end
function ModelHero:checkCanTouch()
	local canTouch = false
	if self.controler.gameMode == Fight.gameMode_gve then
		canTouch = true
	elseif self.camp == BattleControler:getTeamCamp() and 
		self.data.characterRid == self.controler:getUserRid() then
			canTouch = true
	end
	return canTouch
end
--[[
点击主角或者英雄
]]
function ModelHero:pressClickView(  )
	if not self:checkCanTouch() then
		return
	end
	if BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
		local gpView = self.controler.gameUi.gpPowerView
		if self.camp == gpView:getSelectedCamp() then
			-- 检查是否是可选的神力阶段，点击释放 注意not的括号
			if not (self.controler.logical:getBattleState() == Fight.battleState_spirit and
			 self.controler.artifactControler:checkIsMeUseSpirit() and 
			 gpView:getSpiritOType() == Fight.spiritType_click)
			then
				return 
			end
			local skillId = gpView:getSelectedId()
			if skillId then
				gpView:resetSelectedId()
				local info = {sid = skillId,rid =rid,posRid = self.data.rid,camp = self.camp}
				self.controler.server:sendUseOneSpirit(info)
			end
		end
		return
	end
	-- echo("点击了",self.controler.gameUi , self.controler.gameUi.__disabledLayer , self.controler.gameUi.__disabledLayer:isVisible())
	if self.controler.gameUi and self.controler.gameUi.__disabledLayer and self.controler.gameUi.__disabledLayer:isVisible() then
		echoWarn("_被禁掉ui了居然还走到这里来了")
		return 
	end

	self:clearOneCallFunc("cancleClickView")
	if  self.swallowHandleClick then
		echo("拖跩--------")
		self.swallowHandleClick  =false
		return
	end

	-- 序章引导正在攻击过程不可点击
	if self.controler:chkHasGuide() then
		if self.logical.attackingHero then
			return
		end
	end

	if self.controler:chkYinDaoDrag() then
		return
	end
	local bState = self.controler.logical:getBattleState()
	if self:isNewInCrossPeak() and 
		(bState == Fight.battleState_formationBefore or bState == Fight.battleState_changePerson) then
		self.controler.cpControler:downOneHero(self)
		return
	end

	-- 布阵倒计时中不能点击
	if self.logical.roundModel == Fight.roundModel_semiautomated and 
		bState == Fight.battleState_formation 
			then
		return
	end


	if not self:jianChaShiFangJiNengHeDaZhao() then
		return
	end
end


--[[
执行攻击操作 isUITouch true 代表是从点击头像ui调用的，默认false
]]
function ModelHero:doAttackClick(isUITouch)
	isUITouch = isUITouch or false
	-- 发消息结束引导（这里会导致任何战斗都加载引导资源，比发消息代价大的多，暂时去掉2017.11.13）
	
	-- if BattleTutorialLayer.getInstance():isInTuroring() then
		EventControler:dispatchEvent(TutorialEvent.TUTORIAL_PARTNER_ATK )
	-- end

	local opInfo 
	if self.data:checkCanGiveSkill() then
		opInfo = self:chooseAppointHandle(Fight.operationType_BigSkill)
	else
		opInfo = self:chooseAppointHandle(Fight.operationType_giveSkill)
	end

	-- 如果是在别人普通攻击时发出的指令
	if self.logical.attackingHero and self.logical.attackingHero ~= self then
		local currentSkill = self.logical.attackingHero.currentSkill
		-- 如果是小技能会打断
		if currentSkill and currentSkill.skillIndex == Fight.skillIndex_small then
			opInfo.timely = true
		end
	end

    -- 根据模式判断是否可点
    if self.logical.roundModel == Fight.roundModel_semiautomated then
    	-- 小技能不通过手动释放
    	if opInfo.params == Fight.skillIndex_small then
    		return
    	end
    end
    -- 取消动画行为
    self.controler:showGuideArrow(false)
    
    -- 引导中放一个大招立马屏蔽
    if self.controler:chkIsXvZhang() then
	    self.controler.gameUi:disableIconClick(true)
	end
    self.controler.server:sendOneClickHandle(opInfo)

    if not isUITouch then
	    -- 给UI发一个通知
	    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ATTACK_CLICK,self)
    end
end




--[[
判断是否点击释放技能和大招
]]
function ModelHero:jianChaShiFangJiNengHeDaZhao()
	if self.camp ~= BattleControler:getTeamCamp() then
		--点击的是地方   选择我方人员
		return false
	end
	--如果我已经挂了  是不能点的
	if self._isDied then
		return false
	end
	--必须是回合中的 才可以
	if not self.logical.isInRound then
		return false
	end

	--如果本回合内是自动战斗的
	if self.logical:checkIsAutoAttack(self.camp) then
		return
	end


	if self.logical.currentCamp ~= self.camp then
		return false
	end

	if not self.data:checkCanAttack() then
        return false
    end
    if self.data:hp()<=0 then
        return false
    end

    --如果已经 攻击了
    if self.hasOperate then
        return false
    end

    -- 对面没人了不能点
    if #self.toArr == 0 then
		return false
	end

    return true
end



function ModelHero:buZhenTimeOver(  )
	if self.hasHealthDied then return end
	
	self.cachePos = nil
	-- end
	self.myView:opacity(255)
	--清空按下坐标偏移
	self._clickDownOffset = nil
	self:clearUseHeroesLine()


end




--视图按下了  那么拖动这个hero进行移动
function ModelHero:pressClickViewDown(event  )
	if Fight.isDummy then
		return
	end
	
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_HERO_TOUCH,{type =1 ,model = self} )
	if not self:checkCanTouch() then
		return
	end
	self.swallowHandleClick = false

	-- 须臾仙境NPC不可换位
	if BattleControler:getBattleLabel() == GameVars.battleLabels.wonderLandPve 
		and self.data:isRobootNPC()
	then
		return
	end
	
	--正在攻击中
	if self.logical.attackingHero then
		return
	end

	--如果是不能布阵的
	if not self.controler:checkCanBuzhen() then
		return 
	end
	local bState = self.controler.logical:getBattleState()
	-- 仙界对决一开始上下阵
	if BattleControler:checkIsCrossPeak() then
		if bState ~= Fight.battleState_formationBefore then
			if not self.logical.isInRound then
				return
			end
		else
			local oData = self.controler.levelInfo:getCrossPeakOtherData()
			if oData.changeCamp ~= self.camp then
				return
			end
			-- 战前上下阵状态、如果不是新上的，也不能移动
			if not (self:isNewInCrossPeak() or 
				self:getHeroProfession() == Fight.profession_obstacle) then
				return
			end
		end
	-- 如果是多人gve 不是在神力阶段不能拖敌方角色
	elseif BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
		local gpView = self.controler.gameUi.gpPowerView
		if self.camp == gpView:getSelectedCamp() then
			local spType = gpView:getSpiritOType()
			-- 这里准备一秒以后弹神力技能圈，当移动的时候，需要隐藏掉(或者取消)
			if spType ~= Fight.spiritType_drag then
				-- 已经移动了，则取消掉
				local camp = self.camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
				local skillId = gpView:getSelectedId()
				if skillId then
					local tmpArr = self.controler.artifactControler:getSpiritSkillArr(camp,
									skillId,{hero = self})
					self:showSpiritArr(tmpArr)
				end
			end
			-- 神力阶段，否则不是我方选择神力不能拖拽，体型要为1才能拖拽
			if not (bState == Fight.battleState_spirit and
			 self.controler.artifactControler:checkIsMeUseSpirit() and 
			 spType == Fight.spiritType_drag and
			 self.data:figure() == 1 )
			then
				return 
			end
			if spType == Fight.spiritType_drag then
				-- 选取我方所有体型为1 的奇侠
				local tmpArr = {}
				for k,v in pairs(self.campArr) do
					if v.data:figure() == 1 then
						table.insert(tmpArr,v)
					end
				end
				self:showSpiritArr(tmpArr)
				-- 并且显示脚底格子(空位置的格子不需要显示红圈)
				self.controler.formationControler:setBuZhenVisible(true)
			end
		else
			-- 布阵阶段不是我方布阵不能拖拽
			if not (bState == Fight.battleState_formation and
			  self.controler.formationControler:checkIsMeBZ() and 
			  self.camp == Fight.camp_1) then
				return 
			end
		end
	else
		if not self.logical.isInRound then
			return
		end
	end

	--如果是不能攻击的 本回合 那么不应该执行
	if not self.data:checkCanAttack() then
		return
	end

	-- local posIndex = self.data.posIndex
	if self.hasOperate and self:getHeroProfession() ~= Fight.profession_obstacle then
		return
	end

	-- 如果有弱引导，关闭一下可能存在的弱引导
	if FuncGuide.hasBattleWeakGuide(self.controler.levelInfo.hid) then
		self.controler:closeTutorial()
	end
	
	--先备份阵形
	self.logical:backUpFormation(self.camp)

	--self.cachePos = {}

	local targetX = event.x
	local targetY = event.y
	--记录偏移坐标
	local dx = targetX *Fight.cameraWay - self.pos.x 
	local dy = -targetY  - self.pos.y
	self:pushOneCallFunc(math.round(8* self.controler.updateScale), "cancleClickView")
	self._clickDownOffset = {dx,dy}
	self.srcPosIndex = self.data.posIndex


	--显示显隐控制
	self.myView:opacity(100)
	if self.controler.logical:getBattleState() ~= Fight.battleState_spirit then
		--让我能打到的人变量
		self.controler.viewPerform:setHeroCanAttackPerform(self)
		self.controler.formationControler:buZhenSetTargetPos(self.data.posIndex,self)
	end
	-- self:checkUseHeroesLine()
	self._cancleClick = false
	-- 隐藏弱引导箭头
	self.controler:showGuideArrow(false)
end
-- 显示神力技能范围
function ModelHero:showSpiritArr(heroArr)
	local chorrArr = {}
	for k,v in pairs(heroArr) do
		local posIdx = v.data.posIndex
		local info = {}
		local x,y = self.controler.reFreshControler:turnPosition( v.camp,posIdx,1,self.controler.middlePos )
    	info.pos ={x= x,y = y}
    	info.camp = self.toCamp
    	info.posIndex = posIdx
    	table.insert(chorrArr,info)
	end
	self.controler.viewPerform:createAtkUseEff(chorrArr)
end



function ModelHero:cancleClickView(  )
	echo("__取消点击时间")
	self.swallowHandleClick = true
	self:checkUseHeroesLine()
end

--点击移动事件
function ModelHero:pressClickViewMove( event )
	--echo("moveing-------------")
	if not self._clickDownOffset then
		return 
	end
	if not self:checkCanTouch() then
		return
	end
	if not self.swallowHandleClick then
		self:clearOneCallFunc("cancleClickView")
		self:checkUseHeroesLine()
		self.swallowHandleClick =  true
	end	

	-- self.swallowHandleClick =  true

	-- 引导中已经拖动到过正确的位置则不再检查拖动
	if self.controler:chkYinDaoDrag() and self.rightDrag then
		return
	end

	local targetX = event.x*Fight.cameraWay - self._clickDownOffset[1]
	local targetY = -event.y - self._clickDownOffset[2]

	targetX,targetY = self.controler:tuozhuaiBianJieJianCha(self.camp,targetX,targetY)

	self:setPos(targetX,targetY,0)

	--判断落在哪个区域
	local posIndex = self:getAreaPosIndex(self.pos.x,self.pos.y)
	-- echo("-------",posIndex,"=============",self.data.posIndex)
	if posIndex == 0 then
		posIndex = self.data.posIndex
	end
	

	if posIndex == 0 then
		--self:setToTargetPosIndex(self.data.posIndex)
		-- self:setPos(targetX,targetY,0)
		self.controler.formationControler:buZhenSetTargetPos(0)
	else
		local hasPosChange = false
		if self.data.posIndex ~= posIndex then

			hasPosChange = true

			if not empty(self.cachePos) then
				--if targetHero ~= self.cachePos.hero then
				if self.cachePos.hero then
					self.cachePos.hero:setToTargetPosIndex(self.cachePos.pos,nil,self.camp)
				end
				
				self:setToTargetPosIndex(self.cachePos.selfPosIndex,nil,self.camp)
				self.cachePos = nil
				--end
			end

			local targetHero = self.logical:findHeroModelExc( self.camp,posIndex,self)
			if targetHero then 
				self.cachePos = {}
				self.cachePos.hero= targetHero 
				self.cachePos.pos= targetHero.data.posIndex
				self.cachePos.selfPosIndex = self.data.posIndex

				targetHero:setToTargetPosIndex(self.data.posIndex,nil,self.camp)  
			else
				self.cachePos = {}
				self.cachePos.pos = posIndex -- 这里需要存不然引导布阵会回到原位 2017.11.14
				self.cachePos.selfPosIndex = self.data.posIndex
			end
			if self.controler:chkYinDaoDrag() then
				--必须是序章拖拽的指定位置
				local dragTarget,fromPos = self.controler:getYinDaoDragTarget()
				-- echo("dragTarget fromPos",dragTarget,fromPos,self.data.posIndex)
				if posIndex == dragTarget or (self.cachePos and self.cachePos.pos == dragTarget) then
					-- 起始位置和终止位置需要一致
					if fromPos == self.data.posIndex then
						-- 标记已经做过正确的拖拽
						self.rightDrag = true
					end
				end
			end
			self:setToTargetPosIndex(posIndex,nil,self.camp)

			if self.controler.logical:getBattleState() ~= Fight.battleState_spirit then
				--让我能打到的人变量
				self.controler.viewPerform:setHeroCanAttackPerform(self)
				self.controler.formationControler:buZhenSetTargetPos(posIndex,self)

				self:checkUseHeroesLine()
			end
		end
		-- self:setPos(targetX,targetY,0)
	end

	self:followLineHero()
end

function ModelHero:getAreaPosIndex(posx,posy)
	local targetHero,index = self.controler:getAreaTargetByPos(self.camp,posx,posy)

	if targetHero then
		-- echo("这个位置上的英雄已经攻击过了-------")
		if (targetHero.hasOperate  or not targetHero.data:checkCanAttack()) and
			 targetHero:getHeroProfession() ~= Fight.profession_obstacle  -- 不能行动
			then
			index = 0
		--不能操控有方的伙伴布阵
		-- elseif targetHero.data.characterRid ~= self.controler:getUserRid() then
		-- 	index = 0
		end

		-- 须臾仙境NPC不可换位
		if BattleControler:getBattleLabel() == GameVars.battleLabels.wonderLandPve 
			and targetHero.data:isRobootNPC()
		then
			index = 0
		end
		-- 仙界对决战前换位只能换新上的角色
		if BattleControler:checkIsCrossPeak() then
			local bState = self.controler.logical:getBattleState() 
			if bState == Fight.battleState_formationBefore and 
				(not targetHero:isNewInCrossPeak()) and 
				targetHero:getHeroProfession() ~= Fight.profession_obstacle then
				index = 0
			end
		end
		-- 多人GVE敌方不能选大体型的怪
		if BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
			local camp = self.controler.gameUi.gpPowerView:getSelectedCamp()
			if self.camp == camp and 
				targetHero.data:figure() > 1 then
				index = 0 
			end
		end
	end

	if self.controler:chkYinDaoDrag() then
		--如果是引导拖拽
		--必须是序章引导的目标点
		if index ~= self.controler:getYinDaoDragTarget() then
			index = 0
		end
	end

	return index
end



function ModelHero:pressClickViewUp( event )
	local bState = self.controler.logical:getBattleState() 
	if bState == Fight.battleState_spirit then
		self.controler.viewPerform:hideAllAtkUseEff()
		self.controler.formationControler:setBuZhenVisible(false)
	end

	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_HERO_TOUCH,{type =2 ,model = self} )
	if not self:checkCanTouch() then
		return
	end
	-- self.controler.viewPerform:hideAllAtkUseEff()
	if not self._clickDownOffset then
		return 
	end
	-- if self.data.isRobootNPC then
	-- 	return
	-- end
	if Fight.isDummy then
		return
	end
	-- self.swallowHandleClick =  false

	self:clearUseHeroesLine()
	self.controler.formationControler:buZhenSetTargetPos(0)
	local posIndex = self:getAreaPosIndex(self.pos.x,self.pos.y)
	if self.controler:chkYinDaoDrag() then
		-- 已经标记拖拽正确
		if self.rightDrag then
			self.rightDrag = false
			--拖动到目标位置  更新拖拽标识
			self.controler.hasDraged = true
			--发送消息   关闭新手引导
			EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SLIDE_OVER_EVENT )
		end
	end
	local rid = self.controler:getUserRid()
	local heroRid = self.data.rid
	if (not self.cachePos) then
		self.logical:cancleFormation((not self.cachePos))
	else
		local backupBeforePos = self.logical:getHeroBackupBeforPos(self)--备份前的位置
		if self.cachePos then
			posIndex = self.cachePos.pos or self.cachePos.selfPosIndex
		end
		if posIndex == 0 then
			echoError ("为什么此时坐标还是0")
			posIndex = self.data.posIndex
		end
		self:setToTargetPosIndex(posIndex,nil,self.camp)
		if bState == Fight.battleState_formationBefore then
			local info = {rid =rid,type=Fight.battle_card_hero,
							posSource = backupBeforePos,posTarget = posIndex,posRid = heroRid}
			self.controler.server:sendBeforeChangePosHandle(info)
		elseif bState == Fight.battleState_spirit then
			if posIndex ~= self.srcPosIndex then
				-- 这地方是根据UI获取对应的神力技能skillId的
				local skillId = self.controler.gameUi.gpPowerView:getSelectedId()
				if skillId then 
					self.controler.gameUi.gpPowerView:resetSelectedId()
					local info = {sid = skillId,rid =rid,pos = posIndex,posRid = heroRid,camp = self.camp}
					self.controler.server:sendUseOneSpirit(info)
				end
			end
		elseif bState == Fight.battleState_changePerson or 
			bState == Fight.battleState_formation 
			then
			local info = {rid =rid,pos = posIndex,posRid = heroRid,camp = self.camp}
			self.controler.server:sendChangePosHandle(info)
		end
	end
	-- 恢复敌方表现
	self.controler.viewPerform:setGroupViewAlpha(self.toArr,180)

	self.myView:opacity(255)

	--清空按下坐标偏移
	self._clickDownOffset = nil

	self.cachePos = nil
end

--[[
	做回合前流程内容
]]
function ModelHero:doRoundFirstProcess(key)
	self:setRoundReady(key, false)

	local function processFunc()
		if key == Fight.process_relive then
			self:doReliveAction()
		elseif key == Fight.process_treasure then
			-- self:doRoundFirstDelay()
			if self:chkChangeSkin(1) then
				-- 有换装的时候不应该有换法宝
			else
				self:checkTreasureEnd()
			end
		elseif key == Fight.process_myRoundStart then
			self.data:checkChanceTrigger({camp = self.camp,chance = Fight.chance_roundStart})
		elseif key == Fight.process_enemyRoundStart then
			self.data:checkChanceTrigger({camp = self.camp,chance = Fight.chance_toStart})
		end
		return self:setRoundReady(key, true)
	end
	
	-- 非静止状态/blow3起身过程中 是静止状态但是也不在原位，非追进度状态 ，需要等待
	if (not self.hasHealthDied) and (not self.controler:isQuickRunGame()) and 
		(self:isMove() or not self:isAtInitPos() and self.label == Fight.actions.action_blow3) then
		-- not self:isAtInitPos() and ) then
		return self:pushOneInitPosCompleteCall(processFunc)
	else
		return processFunc()
	end
end

--[[
	做回合后流程内容
]]
function ModelHero:doRoundEndProcess(key)
	self:setRoundEndReady(key, false)

	if key == Fight.process_end_treasure then
		self:chkChangeSkin(2)
	elseif key == Fight.process_end_myRoundEnd then
		self.data:checkChanceTrigger({camp = self.camp,chance = Fight.chance_roundEnd})
	elseif key == Fight.process_end_enemyRoundEnd then
		self.data:checkChanceTrigger({camp = self.camp,chance = Fight.chance_toEnd})
	end

	return self:setRoundEndReady(key, true)
end
--[[
	roundType 1 回合前 2 回合后
]]
function ModelHero:_setRoundReady(key, value, roundType)
	if self.isRoundReady == true and value == true then return end

	local oldReady = self.isRoundReady
	-- echo("我是谁", key, self.camp, self.data.posIndex)
	if value == false then
		-- echo("_setRoundReady 设置一次 false",key)
		self._roundReadyT[key] = self._roundReadyT[key] + 1

		self.isRoundReady = value
	else
		-- echo("_setRoundReady 设置一次 true",key)
		self._roundReadyT[key] = self._roundReadyT[key] - 1

		if self._roundReadyT[key] <= 0 then
			self._roundReadyT[key] = 0
			self.isRoundReady = value
		else
			-- echo("还有%s次%s,ready没有重置",self._roundReadyT[key],key)
			return
		end
	end

	if value == true and key == Fight.process_myRoundStart then
		self:checkFullEnergyStyle()
		-- self:justFrame(Fight.actions.action_standSkillStart)
	end

	if value and not oldReady then
		local camp = (key == Fight.process_enemyRoundStart or key == Fight.process_end_enemyRoundEnd) and self.toCamp or self.camp

		return self.logical:processRound(roundType, key, camp)
	end
end

--[[
	回合后
	key 流程等待的内容
	value true or false
]]
function ModelHero:setRoundEndReady(key, value)
	return self:_setRoundReady(key, value, 2)
end
--[[
	回合前
	key 流程等待的内容
	value true or false
]]
function ModelHero:setRoundReady(key, value)
	return self:_setRoundReady(key, value, 1)
end

function ModelHero:getRoundReady()
	return self.isRoundReady
end

--回合初变身 针对boss
function ModelHero:setTransbodyTreasureInfo( info )
	self.transbodyInfo = info
end


function ModelHero:controlEvent()
	ModelHero.super.controlEvent(self)
	self:updateEffectWord()
	


end

--更新头顶飘字动画
function ModelHero:updateEffectWord(  )
	if Fight.isDummy  then
		return
	end
	if self.controler:isQuickRunGame() then
		return
	end
	-- 2017.7.3
	if self._isDied then
		return
	end

	if self.effectWordLeftFrame > 0 then
		self.effectWordLeftFrame = self.effectWordLeftFrame- 1
		if self.effectWordLeftFrame == 0 then
			self:checkPlayEffWord()
		end
	end

	local length = #self.effectWordInfo
	if length > 0 then
		for i=length,1 ,-1 do
			local info = self.effectWordInfo[i]
			if info.left > 0 then
				info.left = info.left - 1
				if info.left == 0  then
					table.remove(self.effectWordInfo,i)
				end
			end
		end
	end

end


--做退场行为 
function ModelHero:doExitGameAction(  )
	--默认 直接原地死亡
	if self.camp == 2 then

	else
		--清除所有buff
		self.data:clearAllBuff()
		--暂时直接stand
		self:justFrame(Fight.actions.action_stand)
	end
end


--插入一个飘字文字
function ModelHero:insterEffWord( params,isDelay )
	if Fight.isDummy  then
		return
	end
	if self.controler:isQuickRunGame() then
		return
	end
	if not  isDelay then
		--如果是杀人了 那么需要延时几帧
		if self.hasKillEnemy then
			self:pushOneCallFunc(Fight.killEnemyFrame, "insterEffWord", {params,true})
			return
		end
	end

	--插入到头上去
	table.insert(self.effectWordInfo,1,{p = params,left = 30,isPlay =false})
	if self.effectWordLeftFrame <= 0 then
		self:checkPlayEffWord()
	end
	
end


--判断是否出特效
function ModelHero:checkPlayEffWord(  )
	if Fight.isDummy  then
		return
	end
	if self.controler:isQuickRunGame() then
		return
	end
	
	if #self.effectWordInfo == 0 then
		return
	end
	--倒着遍历
	local length = #self.effectWordInfo
	for i=length,1,-1 do
		local v = self.effectWordInfo[i]
		if not v.isPlay then
			v.isPlay = true
			local info = v.p
			--如果是创建头顶特效的
			if info[1] == 2 then
				 v.eff = ModelEffectBasic:createCommonHeadEff( info[2],info[3],self)
			elseif info[1]==1 then
				 v.eff =ModelEffectBasic:createBuffWordEff( info[2],info[3] ,self)
			end
			self.effectWordLeftFrame = 5

			--如果插入了一条 那么 先头的特效得依次网上偏移
			for ii=i+1,length do
				local vv = self.effectWordInfo[ii]
				if vv.eff then
					--让子特效依次位移上去
					vv.eff.myView.currentAni:pos(0,(ii-i) * 25)
				end
			end

			break
		end
	end
end
-- 重写父类方法
function ModelHero:resumeEvent()
	ModelHero.super.resumeEvent(self)

	self:checkFullEnergyStyle()
end

--判断是否切换满怒动作
function ModelHero:checkFullEnergyStyle( )
	if Fight.isDummy then
		return
	end
	if Fight.isHideSkillStand then
		return
	end

	if not self.data:checkCanGiveSkill() then
		-- 2017.11.18 pangkangning
		-- 当角色处在大招状态，则需要重置大招状态为当前状态
		if self.label == Fight.actions.action_standSkillStart or
		self.label == Fight.actions.action_standSkillLoop then
			self:changeActionInitFramDatas(Fight.actions.action_stand)
		end
		return
	end
	--如果阵营不符合
	--2017.12.7 与阵营无关了
	-- if self.camp ~= self.logical.currentCamp  then
	-- 	return
	-- end
	--必须是站立状态才行
	--2017.12.7 必须是站立状态才能切
	if self.moveType ~= 0
		-- self.label ~= Fight.actions.action_stand and self.label ~= Fight.actions.action_stand2 
		-- and self.label ~= Fight.actions.action_standWeek
	then
		return
	end

	-- 不再重新播
	if self.label == Fight.actions.action_standSkillStart
	or self.label == Fight.actions.action_standSkillLoop
	then
		return
	end
	--如果当前回合已经攻击过了 那么不执行
	-- if self.hasAttacked then
	-- 	return
	-- end
	-- 小怪不检查
	if self:getHeroProfession() == Fight.profession_monster then
		return
	end
	
	if #self.toArr == 0 then
		return
	end
	-- 已经释放大招了，也不显示满怒气状态 2017.11.21 pangkangning
	if self.hasOperate then
        return
    end
    -- 必须是站立状态才能够切换为大招激活状态
    if self.label ~= Fight.actions.action_stand and self.label ~= Fight.actions.action_stand2 and
    	self.label ~= Fight.actions.action_standWeek
    	then
    	return 
    end 
	-- 检查一下怒气条的状态
	self.healthBar:checkShowFullEnergyEff()

	self:gotoFrame(Fight.actions.action_standSkillStart)
	-- 检查法宝特效
	self:checkTreasureEff(self.data.curTreasure)
end
function ModelHero:checkWordEff( )
	--怒气技激活,我方才飘字
	if self.camp == 1 and (self.label == Fight.actions.action_standSkillStart or
	self.label == Fight.actions.action_standSkillLoop) then
		self:insterEffWord({2,Fight.wenzi_nuqijijihuo,Fight.buffKind_hao })
	end
end

-- 检查法宝特效
function ModelHero:checkTreasureEff(treasureObj)
	if true then return end
	if Fight.isDummy then return end

	if not self.data.isCharacter then return end

	local eff = self.treasureEff
	local aniName = "UI_zhandou_fabaojichu"
	if not eff then
		eff = self:createEff(aniName, 0, 40, 1, self.way, true, true, true,nil,nil,self)
		
		function eff:playShow(treasureObj)
			local icon = treasureObj:sta_icon()
			if not icon then
				-- 其他人也有法宝但是只有主角需要表现所以在这里检查
				echoError("找战斗策划法宝%s没有配置icon字段",treasureObj.hid)
				icon = "treaIcon_304"
			end
			local path = FuncRes.iconEnemyTreasure(icon)
			local sp = display.newSprite(path):size(30,30):anchor(0,1)
			FuncArmature.changeBoneDisplay(eff.myView.currentAni, "node1", sp)
			self.myView.currentAni:runEndToNextLabel(0,1,true,false)
		end

		function eff:playHide()
			self.myView.currentAni:playWithIndex(2,false)
		end
	end

	eff:playShow(treasureObj)

	self.treasureEff = eff
end

-- 释放法宝
function ModelHero:giveTreasure()
	if Fight.isDummy then return end
	if self.treasureEff then
		self.treasureEff:playHide()
	end
end
-- 当一个buff被加入时
function ModelHero:onOneBuffBeInsert( buffObj )
	-- 通知UI怒气消耗改变的消息
	if buffObj.type == Fight.buffType_energyNoCost 
	or buffObj.type == Fight.buffType_energyCost
	then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE,{model=self})
	end
end
--当一个buff被清除
function ModelHero:onOneBuffClear( buffType )
	-- 如果是傀儡buff则人物直接死亡
	if buffType == Fight.buffType_kuilei then
		echo("傀儡buff崩溃人物随之死亡")
		self:doHeroDie()
		return
	end

	if Fight.isDummy  then
		return
	end
	if buffType == Fight.buffType_xuanyun  then
		self:checkXuanyun()
	end
	if buffType == Fight.buffType_energyNoCost
	or buffType == Fight.buffType_energyCost
	then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE,{model=self})
	end
	--当一个buff被清除的时候 判定下是否激活大招满怒
	
	if self.logical.currentCamp == self.camp and self.logical.isInRound	 then
		self:checkFullEnergyStyle()
	end
end

--获取相对自身中心点的坐标
function ModelHero:getViewCenterPos(  )
	local x,y = self.myView:getPosition()
	return x, (y + self.data.viewSize[2]/2 )
end
-- 将怪物站位直接设置指定坐标,六界轶事刷怪用到、
-- 调用此方法的时候，最终还是会调用setToTargetPosIndex方法
function ModelHero:setMonsterToPosIndex(posIndex )
	self.data.posIndex = posIndex
end

--[[
	将英雄设置到指定的坐标
	formationBackUp 做备份的还原
]]
function ModelHero:setToTargetPosIndex( posIndex, formationBackUp,camp)
	camp = camp or 1
	local newx,newy = self.controler.reFreshControler:turnPosition(camp,posIndex,self.data:figure(),self.controler.middlePos)
	-- if not isOpen  then
	-- 	return
	-- end
	-- self._initPos = {x= newx,y = newy, z = 0}
	self:setInitPos({x= newx,y = newy, z = 0})

	local change = false
	if self.data.posIndex ~= posIndex then
	    change = true
	end

	self.data.posIndex = posIndex

	-- 如果位置发生改变,更新五行强化信息（这里与精确位置无关，只与posIndex有关，所以不用每次都更新）
	-- formationBackUp时是为了先恢复原阵位，再设置成最终阵位，抛弃了中间移动的过程，此时不需要重新刷新增强状态
	if change and not formationBackUp then
		self:updateElementEnhance()
	end

	self:setPos(newx,newy,0)

	--更新gridPos
	local xIndex = math.ceil( posIndex /2 )
    local yIndex = posIndex %2 
    if yIndex == 0 then
    	yIndex = 2
    end
    self.data.gridPos.x = xIndex
    self.data.gridPos.y = yIndex

    -- 宠物位置
    if not empty(self._pet) then
    	for _,pet in ipairs(self._pet) do
    		pet:setPos(pet._initPos.x,pet._initPos.y,pet._initPos.z)
    		pet.data.posIndex = posIndex
    		pet.data.gridPos.x = xIndex
    		pet.data.gridPos.y = yIndex
    	end
    end
    -- 如果位置发生变化才更新一下信息（这里与精确位置无关，只与posIndex有关，所以不用每次都更新）
    if change and not formationBackUp then
	    -- 更新特效位置
		self:updateEffPos()
	end

	--需要情况技能的atkchoose
    local skill = self:getNextSkill()
    if skill then
    	skill:clearAtkChooseArr()
    end

	--同时更新血条的位置
	if  Fight.isDummy  then
		return
	end
	self.healthBar:adjustBarPos()
	self:countScale()
end


--获得buff时候 的表现
function ModelHero:buffIconMoveAction( buffObj)
	--纯跑逻辑的时候 不执行
	if Fight.isDummy  then
		return
	end

	if not self.healthBar then
		return
	end

	--如果是超速的 那么不执行
	if self.controler:isQuickRunGame()  then
		return
	end

	--如果挂了 就没必要了
	if self.data:hp()<= 0 then
		return
	end

	if buffObj.kind == Fight.buffKind_huai  then
		return
	end

	local buffView = self.healthBar:getBuffView( buffObj )
	--如果没有buffView 直接return 说明buff没创建成功（或没有icon）
	if not buffView then
		return
	end
	if not buffObj:sta_buffFla() then
		return
	end
	buffView:setOpacity(0)

	local fromHero = buffObj.hero

	if not fromHero.healthBar then return end

	local kind = buffObj.kind
	-- local sp = display.newSprite(FuncRes.iconBuff(icon)):addto(self.controler.layer.a123)

	local x = fromHero.pos.x
	local y = -fromHero.pos.y - fromHero.pos.z + fromHero.healthBar._viewHeight

	local turnPos =  self.controler.layer.a123:convertLocalToNodeLocalPos(self.healthBar._barView,cc.p(x,y))

	-- "UI_zhandou_buff_jiagongjili" 作为默认特效
	local aniName = buffObj:sta_buffFla() or "UI_zhandou_buff_jiagongjili"

	local ani = ViewArmature.new(aniName):addto(self.healthBar._barView)
	ani:pos(turnPos.x,turnPos.y)

	--目标点
	local targetX,targetY = self.pos.x,-self.pos.y + fromHero.healthBar._viewHeight /2

	local targetTurnPos =  self.controler.layer.a123:convertLocalToNodeLocalPos(self.healthBar._barView,cc.p(targetX,targetY))
	targetX = targetTurnPos.x
	targetY = targetTurnPos.y
	--移动到目标点
	ani.currentAni:playWithIndex(0,false)
	
	--让buffView显示 然后销毁ani
	local act_func4 = function (  )
		ani:deleteMe()
		local act_fadeTo = act.fadeto(0.2,255)
		buffView:runAction(act_fadeTo)
	end

	--让特效运动到 buffIcon点 后 消息
	local act_func3 = function (  )
		if self._isDied then
			ani:deleteMe()
			return
		end
		local buffPos = buffView:convertLocalToNodeLocalPos(self.healthBar._barView)

		local act_move = act.moveto(0.1,buffPos.x, buffPos.y )	
		local act_call = act.callfunc(act_func4)
		local act_seq = act.sequence(act_move,act_call)
		ani:runAction(act_seq)
	end


	local act_func2 = function (  )
		ani.currentAni:playWithIndex(2,false)
		ani:delayCall(act_func3, ani.currentAni:getAnimation():getRawDuration()/ GameVars.GAMEFRAMERATE  )
	end

	local act_func1 = function (  )
		local act_move = act.moveto(0.2,targetX, targetY )
		local act_call = act.callfunc(act_func2)
		local act_seq = act.sequence(act_move,act_call )
		ani:runAction(act_seq)
	end
	
	ani:delayCall(act_func1, ani.currentAni:getAnimation():getRawDuration()/ GameVars.GAMEFRAMERATE  )


end

-- 显示额外的技能框
function ModelHero:addSkillEffectAperture()
	local skill = self:getNextSkill()
    local attackPosArr = AttackChooseType:getSkillCanAttackPos(self,skill)
    local atkUseEffArr  = {}
    for i,v in ipairs(attackPosArr) do
    	local info = {}
    	local x,y = self.controler.reFreshControler:turnPosition( self.toCamp,v,1,self.controler.middlePos )
    	info.pos ={x= x,y = y}
    	info.camp = self.toCamp
    	info.posIndex = v
    	table.insert(atkUseEffArr, info)
    end
    self.controler.viewPerform:createAtkUseEff(atkUseEffArr)
end

--初始化相关的人
function ModelHero:checkUseHeroesLine(  )
	--useHeroesLineMap
	--[[
		{
			--
			{targetHero,ani},
			{emytyPos,ani},
		}
	]]
	if self.controler.logical:getBattleState() == Fight.battleState_spirit then
		return
	end
	
	--先清除相关连线
	self:clearUseHeroesLine()
	if not self.useHeroesLineMap then
		self.useHeroesLineMap = {}
	end
	local skill = self:getNextSkill()
    local chooseArr = AttackChooseType:getSkillCanAtkEnemy(self,skill,true)

    --获取技能完整能打的位置（这个数组是用来打空地用的）
    local attackPosArr = AttackChooseType:getSkillCanAttackPos(self,skill)
    -- echo("获取技能完整能打的位置", #chooseArr)
    -- dump(attackPosArr)
    local hasRandom = false
    for i,v in ipairs(chooseArr) do
    	if v.randomHero then
    		hasRandom = true
    	end
    end
    if #attackPosArr == #chooseArr or hasRandom then -- 选敌人数和最大人数相等置空打空地用的表；有随机的选人也置空
    	attackPosArr = {}
    end
    local length = #attackPosArr
    for i=length,1,-1 do
    	local posIndex = attackPosArr[i]
    	for ii,vv in ipairs(chooseArr) do
    		--如果这个位置已经有人了 那么就移除
    		-- vv.camp ~= self.camp 这个判定暂时没看懂原因，保留
    		if vv.camp ~= self.camp and vv.data:isHoldPosIndex(posIndex) then
    			table.remove(attackPosArr, i)
    		end
    	end
    end
    local atkUseEffArr  = {}
    for i,v in ipairs(attackPosArr) do
    	local info = {}
    	local x,y = self.controler.reFreshControler:turnPosition( self.toCamp,v,1,self.controler.middlePos )
    	info.pos ={x= x,y = y}
    	info.camp = self.toCamp
    	info.posIndex = v
    	table.insert(self.useHeroesLineMap, info)

    	table.insert(atkUseEffArr, info)
    end
    

    for i,v in ipairs(chooseArr) do
    	local info = {wenziAniArr = {}}
    	if true then
    		info.targetHero = v
    		info.pos = v.pos
    		info.camp = v.camp
    		info.posIndex = v.data.posIndex
    		-- echo("_____创建buff",v.__tempBuffObjs)
    		local index = 0

    		if v.__tempBuffObjs then
    			-- 去重
    			local tb = {}
    			local result = {}
    			for ii,vv in ipairs(v.__tempBuffObjs) do
    				if not tb[vv.type] then
    					tb[vv.type] = true
    					table.insert(result, vv)
    				end
    			end
    			v.__tempBuffObjs = result
    			--如果是有buff的
    			for ii,vv in ipairs(v.__tempBuffObjs) do
    				local frame ,style = vv:getEffWordFrame()
    				--如果是有带飘字样式
    				if frame then
    					--文字特效
    					local wenziAni = ViewArmature.new("common_zishanshuo"):addto(self.controler.layer.a123,2000)
    					--跳到对应的帧上
    					ModelEffectBasic:checkShowBuffBone(wenziAni.currentAni:getBone("layer1"),frame,vv.kind,vv._isRandom)

    					wenziAni.currentAni:setScaleX(Fight.cameraWay )
    					wenziAni:pos(v.pos.x,-v.pos.y + v.data.viewSize[2] + index * 20)
    					index = index + 1
    					table.insert(info.wenziAniArr, wenziAni)
    				end
    			end
    		end

    		-- 随机文字
    		if v.randomHero then
    			--文字特效
    			local wenziAni = ViewArmature.new("common_zishanshuo"):addto(self.controler.layer.a123,2000)
    			--跳到对应的帧上
    			local frame = v.camp == 1 and Fight.wenzi_random1 or Fight.wenzi_random2
    			ModelEffectBasic:checkShowBuffBone(wenziAni.currentAni:getBone("layer1"),frame,1)

    			wenziAni.currentAni:setScaleX(Fight.cameraWay )
    			wenziAni:pos(v.pos.x,-v.pos.y + v.data.viewSize[2] + index * 20)
    			table.insert(info.wenziAniArr, wenziAni)
    			index = index + 1
    		end
    		table.insert(self.useHeroesLineMap, info)
    	end
    end
    --创建空地指引特效
    self.controler.viewPerform:createAtkUseEff(atkUseEffArr)

    self:followLineHero()

end

--清空所有的连线
function ModelHero:clearUseHeroesLine(  )
	self.controler.viewPerform:hideAllAtkUseEff()
	
	if not self.useHeroesLineMap then
		return
	end
	
	for i,v in ipairs(self.useHeroesLineMap) do
		if v.lineAni then
			v.lineAni:deleteMe()
		end
		--如果有文字特效的 清除
		if v.wenziAniArr then
			for ii,vv in ipairs(v.wenziAniArr) do
				vv:deleteMe()
			end
			v.wenziAniArr = nil
		end

		v.targetHero = nil
	end
	self.useHeroesLineMap = {}
end


-- baseDis 基础距离 这个时候的 scale是保持1的
function ModelHero:followLineHero( )
	if not self.useHeroesLineMap then
		return
	end
	if self.controler.logical:getBattleState() == Fight.battleState_spirit then
		return
	end
	for i,v in ipairs(self.useHeroesLineMap ) do

		local info = v
		local targetHero = info.targetHero
		if targetHero ~= self then
			
			local dis
		    local scale
		    local rotation
		    local dx = info.pos.x - self.pos.x
		    local absDx = math.abs(dx)
		    local dy = info.pos.y - self.pos.y
		    local ang = math.atan2(dy,dx)
		    local dis = math.sqrt(dx*dx+dy*dy)
		    local lineAni
		    local aniName 
		    local baseDis
		    if info.camp ~= self.camp then
		    	aniName = "UI_zhandou_lianxian_chang1"
		    	baseDis = 840
		    elseif absDx < 30 then
		    	aniName = "UI_zhandou_lianxian_duan1"
		    	baseDis = 180
		    else
		    	aniName = "UI_zhandou_lianxian_duan2"
		    	baseDis = 150
		    end
		    if info.aniName ~= aniName then
		    	if info.lineAni then
		    		info.lineAni:deleteMe()
		    	end
		    	info.lineAni = ViewArmature.new(aniName):addto(self.controler.layer.a123,20000)
		    	info.aniName = aniName
		    end

		    local lineAni = info.lineAni
		    --计算缩放系数
		    local scale = dis/baseDis
		    local turnAng = ang * 180/math.pi
		    --修正角度
		    lineAni:setRotation(turnAng)
		    if turnAng >= -90 and turnAng <=  90 then
		    	lineAni:setScaleY(1)
		    else
		    	lineAni:setScaleY(-1)
		    end
		    --修正缩放
		    lineAni:setScaleX(scale)
		    lineAni:pos(self.pos.x,-self.pos.y)
		end
	    
	end
end

--是否是我的hero
function ModelHero:isMineHero(  )
	return self.data.characterRid == self.controler:getUserRid()
end
-- 2017.08.09 pangkangning 获取角色职业 1=攻，2=防，3=辅，4=小怪，5=Boss 
function ModelHero:getHeroProfession(  )
	-- 带有墓碑buff,职业转为中立（不能行动）
	if self.data:checkHasOneBuffType(Fight.buffType_tag_mubei) then
		-- return Fight.profession_obstacle
		return Fight.profession_neutral
	end
	
	-- 主角所穿戴的法宝的攻防辅标签
	if self.data.isCharacter then
		for k,v in pairs(self.data.treasures) do
			if v.treaType == Fight.treaType_normal then
				-- echo("主角所穿戴的法宝的攻防辅标签---",v:sta_profession())
				return v:sta_profession()
			end
		end
		echoError("主角没有战斗法宝---,使用默认法宝",self.data.curTreasure.hid)
	end
	return self.data.curTreasure:sta_profession()
end
-- 获取角色属性
function ModelHero:getHeroElement()
	local result = 0
	local elements
	-- 主角属性
	if self.data.isCharacter then
		for k,v in pairs(self.data.treasures) do
			if v.treaType == Fight.treaType_normal then
				-- echo("主角所穿戴的法宝的攻防辅标签---",v.hid,v:sta_profession(),self.data.hid,self.camp)
				elements = v:sta_elements()
				break
			end
		end
		if not elements then
			echoError("主角没有战斗法宝---,使用默认法宝",self.data.curTreasure.hid)
		end
	else
		elements = self.data.curTreasure:sta_elements()
	end

	if elements then
		result = tonumber(elements[1])
	end

	return result
end
-- 获取自己受到的减伤增强
function ModelHero:getEnhanceDef(targetElement)
	return self.controler.formationControler:getHeroEnhanceDef(self, targetElement)
end
-- 更新当前五行强化情况
function ModelHero:updateElementEnhance()
	-- if true then
	-- 	-- 临时解决加成报错，需要修改getSkillParams，内容将较多，改完打开屏蔽
	-- 	return 
	-- end
	local fControler = self.controler.formationControler
	local exlvl = fControler:getHeroEnhanceSkillLvl(self)
	local camp = self.camp
	local pos = self.data.posIndex

	local heroElement = self:getHeroElement()
	local elementInfo = fControler:getElementInfoByPos(camp,pos)
	if self.data.isCharacter then
		for i,treasure in ipairs(self.data.treasures) do
			treasure:enhanceSkill(exlvl)
		end
	else
		self.data.curTreasure:enhanceSkill(exlvl)
	end

	-- 发消息改变标签
	if Fight.isDummy then return end
	-- if elementInfo.element ~= 0 then
	-- 	-- 添加打印log
	-- 	echo("阵营%s,%s号位,人物五行%s,脚底五行:%s,技能增强等级%s,五行防御:%s",
	-- 		camp,pos,heroElement,elementInfo.element,exlvl,elementInfo.exDef)
	-- else
	-- 	echo("阵营%s,%s号位,人物五行%s,脚底五行:%s,无属性增强",
	-- 		camp,pos,heroElement,elementInfo.element)
	-- end
	-- echo("发消息",heroElement,elementInfo.element)
	-- echoError("更新显示")
	-- 阵位表现
	-- fControler:updateElementDefEff(self)
	fControler:updateElementDefEffByCamp(self.camp)

	self.data:dispatchEvent(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_CHANGE,{heroElement = heroElement,posElement = elementInfo.element})
end
-- 是否是召唤物
function ModelHero:isSummon( )
	if self.__isSummon then
		return true
	end
	return false
end
function ModelHero:setIsSummon(b )
	self.__isSummon = b
end
-- 获取雇佣兵信息
function ModelHero:getTeamFlag( ... )
	if self.data.teamFlag then
		return self.data:teamFlag()
	end
	return nil
end

-- 继承父类
function ModelHero:setInitPos(initPos)
	ModelHero.super.setInitPos(self, initPos)

	if not empty(self._pet) then
		local realWay = self.camp == 1 and Fight.myWay or Fight.enemyWay

		local tInitPos = {
			x = self._initPos.x - realWay * 40,
			y = self._initPos.y - 2,
			z = self._initPos.z
		}
		for _,pet in ipairs(self._pet) do
			pet:setInitPos(tInitPos)
		end
	end
end

-- 加入一个宠物
function ModelHero:addOnePet(hero)
	hero:setPOwner(self)
	table.insert(self._pet, hero)
end

-- 去掉一个宠物，暂时默认删除第一个
function ModelHero:removeOnePet()
	local pet = self._pet[1]
	if pet then
		table.remove(self._pet, 1)
		pet:doHeroDie()
	end
end

-- 获取一个宠物，暂时默认获取第一个
function ModelHero:getOnePet()
	return self._pet[1]
end

-- 获取自己是否为宠物
function ModelHero:isPet()
	return self._isPet
end

-- 获取主人（当自己是宠物时）
function ModelHero:getPOwner()
	return self._owner
end

-- 设置主人
function ModelHero:setPOwner(hero)
	self._owner = hero
end
-- 是否是巅峰竞技场刚刚上阵的伙伴
function ModelHero:isNewInCrossPeak()
	return self.__isNewCP
end
-- 设置伙伴是否是新的
function ModelHero:setNewInCrossPeak(b)
	self.__isNewCP = b
end
-- 仙界对决玩家替补上阵玩家释放大招状态(true：未放过大招,默认nil)
function ModelHero:isNotPlayMaxSkill( )
	return self.__notPlayMaxSkill
end
function ModelHero:setHasPlayMaxSkill(b)
	self.__notPlayMaxSkill = b
end
-- 设置scale时其他内容需要改变
function ModelHero:setViewScale( ... )
	ModelHero.super.setViewScale(self, ...)

	if self.healthBar then
		self.healthBarPos.y = self.data.viewSize[2] * (Fight.wholeScale + self.viewScale - self._viewScale)
		self.healthBar:updateViewHight()
	end
end
-- 检查回合换人逻辑
function ModelHero:chkChangeSkin(roundType)
	local levelInfo = self.controler.levelInfo
	local bChange = levelInfo:getBattleChange(self.controler.__currentWave)
	if bChange and not self:hasNotAliveBuff() then -- 不是傀儡
		local round = self.logical.roundCount
		for _,v in ipairs(bChange) do
			if v.round == round and v.rType == roundType and self.data.hid == v.changeId then
				-- 要变身
				self:doChangeSkin(roundType,v)
				return true
			end
		end
	end

	return false
end
-- 做特殊的回合变身（区别于回合换法宝因为逻辑无法兼容，把逻辑从LogicalControler挪过来）
function ModelHero:doChangeSkin(roundType,cValue)
	if roundType == Fight.p_roundStart then
		self:setRoundReady(Fight.process_treasure, false)
	elseif roundType == Fight.p_roundEnd then
		self:setRoundEndReady(Fight.process_end_treasure, false)
	end
	-- 有变身动作
	if cValue.change == 1 and (not Fight.isDummy) then
		self:justFrame(Fight.actions.action_treaOver)
		self:pushOneCallFunc(self.totalFrames, "doChangeSkinOver", {roundType,cValue})
	else
		self:doChangeSkinOver(roundType,cValue)
	end
end
-- 特殊变身完成
function ModelHero:doChangeSkinOver(roundType, cValue)
	local msg = {}
	local levelInfo = self.controler.levelInfo
	local newHero = nil
	if cValue.cType == 1 then -- 换人
		local posIndex = self.data.posIndex
		local tlvRevise = levelInfo:getTowerBattleLevelRevise()
		local enemyInfo = EnemyInfo.new(cValue.newId,levelInfo.__levelRevise,tlvRevise)
		enemyInfo.attr.posIndex = posIndex
		local objHero = ObjectHero.new(cValue.newId,enemyInfo.attr)
		objHero.rid = objHero.hid.."_"..posIndex.."_"..cValue.camp
		if cValue.camp == 1 then
			objHero.characterRid = model.data.characterRid --这个角色属于谁的
		end
		-- model:doHeroDie(true)
		newHero = self.controler.reFreshControler:createHeroes(objHero,cValue.camp,posIndex,Fight.enterType_stand)
		msg.posIndex = posIndex
		msg.hid = objHero.hid
		newHero.data:initAure() --初始化光环
		newHero:doHelpSkill() -- 做协助技
		
		if newHero.healthBar then
			newHero.healthBar:showOrHideBar(true)
		end
		-- 血条显隐
		if self.healthBar then
			self.healthBar:showOrHideBar(false)
		end
		
		self:setOpacity(0) -- 隐藏自己
		-- 需要给角色做一次排序，否则技能释放时可能选不到此人
		self.logical:sortCampPos(cValue.camp)
	elseif cValue.cType == 2 then -- 换法宝
		local idx = self.data:insterTreasure(cValue.newId)
		self:onGiveOutTreasureEnd(idx, false)
		msg.posIndex = self.data.posIndex
		msg.hid = self.data.hid

		newHero = self
	end

	-- 有变身动作
	if cValue.change == 1 and (not Fight.isDummy) then
		newHero:justFrame(Fight.actions.action_original)
		self:pushOneCallFunc(self.totalFrames, "doChangeSkinOriginal", {roundType, cValue})
	else
		self:doChangeSkinOriginal(roundType, cValue)
	end

	if cValue.camp == 1 then
		-- 需要更新头像
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ICON_CHANGE,msg)
	end
end
-- 变身完成
function ModelHero:doChangeSkinOriginal(roundType, cValue)
	if cValue.cType == 1 then -- 换人
		-- 换人需要把自己杀掉
		self:doHeroDie(true)
	end

	-- 崩溃完将回合状态置回
	if roundType == Fight.p_roundStart then
		self:setRoundReady(Fight.process_treasure, true)
	elseif roundType == Fight.p_roundEnd then
		self:setRoundEndReady(Fight.process_end_treasure, true)
	end
end

-- 继承
-- @@isMove 是因为移动而设置方向
function ModelHero:setWay(way, isMove)
	-- 因为移动而设置方向，不受敌阵傀儡的面向影响
	if not isMove and self.puppeteer and self.puppeteer ~= self.camp then
		way = -way
	end

	ModelHero.super.setWay(self, way)
end


-- 含有不计为活人的buff
function ModelHero:hasNotAliveBuff()
	return self.data:hasNotAliveBuff()
end

-- 继承处理觉醒的换装
function ModelHero:initView( ... )
	ModelHero.super.initView(self, ...)
	if Fight.isDummy then return end

	if self.data and self.data.awakenWeapon and self.myView then
		self.myView:changeAttachmentByFrame(self.data.awakenWeapon)
	end
end

-- 追进度后更新位置相关
function ModelHero:updatePosAfterQuick()
	if self._viewName then
		-- 还原视图
		self:changeView(self.data.curSpbName)
		self:standAction()
		self:updateViewPlaySpeed()
		-- 还原运动状态
		self:initMoveType()
		self:initStand()
		-- 更新位置
		self:setPos(self._initPos.x,self._initPos.y,self._initPos.z)
		self:realPos()
	end
end