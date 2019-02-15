--
-- Author: Your Name
-- Date: 2014-12-23 10:47:45
--
ViewHealthBar = class("ViewHealthBar", function ( )
	return display.newNode()
end)
ViewHealthBar._initHealth =0
ViewHealthBar.data =nil
--剩余显示血条时间 每帧刷新 
ViewHealthBar._leftShowTime = 0

-- 血条是脑袋上还是脚下
ViewHealthBar._posType = 1 --1:脚下 2:头上


--主角头上角标显示事件
local charCueTime = 999
local charNameTime = 4 	--角色名显示时间
local hpWidth = 75

--血条持续时间
local barLastTime = 2*GameVars.GAMEFRAMERATE  		

--血条的rootNode
ViewHealthBar._rootNode = nil   --rootNode是会所有的东西一起变暗的
ViewHealthBar._lightNode = nil --lightNode 是不需要变暗的

-- 五行标签特效
local wuxingArray = {
	"UI_zhandoud_feng",
	"UI_zhandoud_lei",
	"UI_zhandoud_shui",
	"UI_zhandoud_huo",
	"UI_zhandoud_tu"
}
local hpBarArr = {
	"progress_1",
	"progress_bai",
	"progress_2",
	"progress_banma",
}


--血条有自己的逻辑  如果在一定时间内没有挨打 那么隐藏血条
function ViewHealthBar:ctor(info,health)
	self._posType = 1
	self.allBlood=health
	self.blood=health
	self.data = info
	self._rootNode = display.newNode():addTo(self)
	self._lightNode = display.newNode():addTo(self)
	-- 延迟一帧显示血条、在试炼里面做对应的处理
	-- self:visible(false)

	-- self:delayCall(function( )
	-- 	-- 此地方不能设置visible，因为仙界对决仙人掌模式中仙人掌的触摸事件是注册在血条上的，如果visible=false就不能触摸了
	-- 	-- if self.target and self.target:getHeroProfession() == Fight.profession_obstacle then
	-- 	-- 	self:visible(false)
	-- 	-- else
	-- 		self:visible(true)
	-- 		if not BattleControler:checkIsCrossPeak() then
	-- 			if self._barView then
	-- 				self._barView:visible(false)
	-- 			end
	-- 			if self._buffCtn then
	-- 				self._buffCtn:visible(false)
	-- 			end
	-- 		end
	-- 	-- end
	-- end,1/GameVars.GAMEFRAMERATE)

	-- if not self._barView then
	-- 	local viewName  = "panel_bar2"
	-- 	local barView = UIBaseDef:createPublicComponent( "UI_battle_public",viewName )
	-- 	barView:setScaleX(Fight.cameraWay )
	-- 	barView:addto(self._rootNode):pos(0,0)
	-- 	self._barView = barView
	-- end

	-- if not self._buffCtn then
	-- 	self._buffCtn = display.newNode():addto(self._barView)
	-- end

	-- if not BattleControler:checkIsCrossPeak() then
	-- 	if self._barView then
	-- 		self._barView:visible(false)
	-- 	end
	-- 	if self._buffCtn then
	-- 		self._buffCtn:visible(false)
	-- 	end
	-- end
end

--设置目标  barType  1是主角自己  2是敌方boss或者敌方玩家  3是小怪
function ViewHealthBar:setTarget( heroes,barType )
	self.barType = barType or 1
	self.target = heroes

	-- 创建血条
	local barView = UIBaseDef:createPublicComponent( "UI_battle_public","mc_progressx" )
	barView:setScaleX(Fight.cameraWay * 0.88)
	self._barView = barView
	barView:addto(self._rootNode):pos(0,0)


	self:updateViewHight() --更新血条高度
	self:showOrHideBar(false)
	
	local style = {
		_style = ProgressBar.STYLE.SCALE
	}
	local hpBar = self._barView.currentView.mc_progress.currentView.hpBar
	for k,v in pairs(hpBarArr) do
		-- hpBar[v]:setStyle(style)
		if v == "progress_banma" then
			hpBar[v]:setDirection(ProgressBar.r_l) --斑马血条是从右到左
		else
			hpBar[v]:setDirection(ProgressBar.l_r)
		end
	end
	self:pressHealthChange(nil)
	self:updateMaxHpVisible(false)

	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH , self.pressHealthChange ,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_MAXHPCHANGE , self.pressHealthChange ,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_ONBUFFCHANGE,self.pressBuffChange,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_PLAYER_STATE , self.pressUserStateChange ,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_CHANGE,self.formationChange,self)
	self.target.data:addEventListener(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_FINISH,self.formationFinish,self)

	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,self.pressShowHP,self)
end
-- 阵型改变完成
function ViewHealthBar:formationFinish( event )
	local data = event.params
	-- 更新抗性相关
	self:updateElementTip(data.posElement)
end
-- 阵型改变
function ViewHealthBar:formationChange( event )
	if not self:chkShowOrHideElement() then
		return
	end
	local data = event.params
	self:changeFormationElement(data.posElement,data.heroElement)
end
-- 检查特效是否存在
function ViewHealthBar:checkAnim( )
	local pView = self._barView.currentView.mc_progress.currentView.mc_1
	local idx = self.target:getHeroElement()
	if idx == 0 then
		-- echoError ("这个怎么会走进来呢",self.target.posIndex,idx)
		return
	end
	if not pView then 
		return
	end
	local armaStr = wuxingArray[idx]
	for i=1,2 do
		-- 这里用pView 是因为有可能会切mc的显示帧
		if not pView.xunhuanAnim then
			pView.xunhuanAnim = self:createUIArmature("UI_zhandoud",armaStr, pView, true,GameVars.emptyFunc)
			pView.xunhuanAnim:anchor(0.18,0.47)
			pView.xunhuanAnim:visible(false)
		end
		if not pView.chuxianAnim then
			pView.chuxianAnim = self:createUIArmature("UI_zhandoud","UI_zhandoud_wulingchuxian", pView, false,GameVars.emptyFunc)
		    pView.chuxianAnim:anchor(0.3,0.77)
			pView.chuxianAnim:visible(false)
		end
	end
end
function ViewHealthBar:updateElementStatus(b )
	local pView = self._barView.currentView.mc_progress.currentView.mc_1
	if not pView then 
		return
	end
	-- 保证同一个frame 和同一个fetpye的时候，不做五行的动作
	if not self.__oldpView then
		self.__oldpView = pView
	end
	if not self._feType then
		self._feType = -1
	end
	if b then
		if self._feType == 1 and self.__oldpView == pView then
			return
		end
		self._feType = 1
		pView.chuxianAnim:visible(true)
		pView.chuxianAnim:playWithIndex(0,0,true)
		pView.chuxianAnim:delayCall(function( )
			pView.xunhuanAnim:visible(true)
		end,46/GameVars.GAMEFRAMERATE )
	else
		if not pView.chuxianAnim or not pView.xunhuanAnim then
			return
		end
		if self._feType == 2 and self.__oldpView == pView then
			return
		end
		self._feType = 2
		pView.chuxianAnim:stopAllActions()
		pView.xunhuanAnim:visible(b)
		pView.chuxianAnim:visible(b)
	end
	self.__oldpView = pView
end
-- 根据脚底的阵型更新脑袋上五行的标签
function ViewHealthBar:updateElemnet(formation,element)
	element = element or self.target:getHeroElement()
	
	local pView = self._barView.currentView.mc_progress.currentView.mc_1
	local fIdx = element
	if element == Fight.element_non then
		fIdx = 6
	end
	-- formation对应帧数
	if self:getHealthCamp() == 2 and self.barType == 3 then
		-- 小怪没有五行
	else
		if pView then
			pView:showFrame(fIdx)
			if element ~= Fight.element_non then 
				local eIdx = formation
				if formation == Fight.element_non then
					eIdx = 6
				end
				pView.currentView.mc_1:showFrame(eIdx)
			end
		end
	end
	self:checkAnim()
end
-- 根据 阵、角色属性显示标签
function ViewHealthBar:changeFormationElement( formation,element)
	if not self:chkShowOrHideElement() then
		return
	end
	local pView = self._barView.currentView.mc_progress.currentView.mc_1
	self:updateElemnet(formation,element)
	if formation == Fight.element_non then
		self:updateElementStatus(false)
	    self.__oldFormation = formation
	else
		if self.__oldFormation and self.__oldFormation == formation then
			if formation == element then
				self:updateElementStatus(true)
			else
				self:updateElementStatus(false)
			end
			return
		end
		self.__oldFormation = formation
		if formation == element then
			self:updateElementStatus(true)
		else
			self:updateElementStatus(false)
		end
	end
end
function ViewHealthBar:createUIArmature( ... )
	if self.target.controler.gameUi then
		return self.target.controler.gameUi:createUIArmature(...)
	end
end
function ViewHealthBar:updateHeroType()
	-- boss、辅助、小怪、防御、攻击
	-- dump(self.target.data.curTreasure.data,"aab-----")
	local _type = self.target:getHeroProfession()
	-- local _type = self.target.data:profession()
	if _type == 1 then
		-- 攻
		self._barView.mc_tu:showFrame(5)
	elseif _type == 2 then
		-- 防
		self._barView.mc_tu:showFrame(4)
	elseif _type == 3 then
		-- 辅
		self._barView.mc_tu:showFrame(2)
	elseif _type == 4 then
		-- 小怪
		self._barView.mc_tu:showFrame(3)
	elseif _type == 5 then
		-- boss
		self._barView.mc_tu:showFrame(1)
	end
end


--直接显示hp
function ViewHealthBar:pressShowHP( e )
	if self.target.controler:isQuickRunGame() then
		return
	end
	if e.params.camp == 0 then
		if e.params.visible == true then
			self._leftShowTime = -1
			self:showOrHideBar(true)
		else
			self:showOrHideBar(false)
		end
	else
		if self.target.camp ~= e.params.camp then
			-- self:showOrHideBar(false)
		else
			if e.params.visible == true then
				self._leftShowTime = -1
				self:showOrHideBar(true)
			else
				self:showOrHideBar(false)
			end
		end
	end
end


--buff状态发生变化
function ViewHealthBar:pressBuffChange( e )
	if self.target._isDied then
		return 
	end

	if self.target.controler:isQuickRunGame() then
		return
	end

	-- for i,v in ipairs(buffIconGroups) do
	-- 	echo(v.id,v.icon,"___buffGroup")
	-- end
	-- echo(#buffIconGroups,"___buffIconGroups__")

	if not self._buffCtn  then
		self._buffCtn = display.newNode():addto(self._barView)
	end
	--脚下的位置
	local yWay   --1是朝上叠 -1是向下叠
	if self._posType == 1 then
		self._buffCtn:pos(hpWidth+10,-20)
		yWay = -1
	else
		self._buffCtn:pos(hpWidth+10,-25)
		yWay = 1
	end
	self._buffCtn:setScaleX(Fight.cameraWay )

	local buffChildArr = self._buffCtn:getChildren()
	--让所有的buff隐藏
	for i,v in ipairs(buffChildArr) do
		v:visible(false)
	end

	--
	local perWid = 24
	local perNums = 4
	local perHei = 24
	--拿到所有的buff icon 数组
	local buffIconGroups = self.target.data:getAllBuffIcons()
	--每行4个 间隔32 
	for i,v in ipairs(buffIconGroups) do
		local length = #buffChildArr
		local view
		for ii=length,1,-1 do
			view = buffChildArr[ii]
			--匹配相同 buff,id
			if view.buffId == v.id then
				view:visible(true)
				table.remove(buffChildArr,ii)
				break
			end
			view = nil
		end
		local xIndex =  i % perNums
		if  xIndex == 0 then
			xIndex = perNums
		end
		xIndex = xIndex -2
		local yIndex = math.ceil( i/perNums )

		local xpos = (xIndex - 0.5) * perWid * Fight.cameraWay 
		local ypos = (yIndex - 0.5) * perHei * yWay
		if not view then
			view = display.newSprite(FuncRes.iconBuff(v.icon),xpos,ypos ):addto(self._buffCtn)
			view.buffId = v.id
		else
			view:pos(xpos,ypos)
		end
	end

end

--根据buffObj 获取对应的buff图标
function ViewHealthBar:getBuffView( buffObj )
	local buffChildArr = self._buffCtn:getChildren()
	for i,v in ipairs(buffChildArr) do
		if v.buffId == buffObj.hid then
			return v
		end
	end
	return nil

end

--用户状态发生变化
function ViewHealthBar:pressUserStateChange( e )
	local state = e.params
	if self._barView.panel_1.mc_1 and state and state[1] then
		-- echo(state,"______用户状态")
		--直接跳到对应帧上去
		self._barView.panel_1.mc_1:showFrame(state[1])
	end

end


--是否永久显示
function ViewHealthBar:setAlwaysShow( )
	if self.target:getHeroProfession() == Fight.profession_obstacle then
		self.alwaysShow = false
	else
		self.alwaysShow = true
	end
	self:visible(self.alwaysShow)
end

--更新血条 不要不停用action了 
function ViewHealthBar:updateFrame(  )
	if self._leftShowTime > 0 then
		self._leftShowTime = self._leftShowTime -1
		if self._leftShowTime ==0 then
			self:showOrHideBar(false)
		end
	end
end


--生命发生变化
function ViewHealthBar:pressHealthChange( event)
	if self.target.controler:isQuickRunGame() then
		return
	end
	--如果不是初始化
	if event then
		self:showOrHideBar(true)
		if not self:isHealthVisible() then
			self._leftShowTime = barLastTime
		end
	end

	local percent = math.round( self.target.data:hp()/self.target.data:maxhp() * 100 )

	self:updateMaxHpStatus()

	local hpBar = self._barView.currentView.mc_progress.currentView.hpBar
	if event then
		hpBar.progress_1:setPercent(percent)
		hpBar.progress_bai:visible(true)
		hpBar.progress_bai:opacity(150)
		self:delayCall(function( )
			hpBar.progress_bai:visible(false)
			hpBar.progress_bai:setPercent(percent)
			hpBar.progress_2:tweenToPercent(percent,20)
		end, 5/GameVars.GAMEFRAMERATE)
	else
		hpBar.progress_1:setPercent(percent)
		hpBar.progress_2:setPercent(percent)
		hpBar.progress_bai:setPercent(percent)
	end
end

--能量发生变化
function ViewHealthBar:pressEnergyChange( event)
	if self.target.controler:isQuickRunGame() then
		return
	end
	-- if self.target.camp ~=1 then
	-- 	return
	-- end
	if event then
		self:showOrHideBar(true)
		if not self:isHealthVisible() then
			self._leftShowTime = barLastTime
		end
	end

	self:checkShowFullEnergyEff()
	local percent = math.round( self.target.data:energy()/self.target.data:maxenergy() * 100 )

	

	if self:getHealthCamp() == 1 then
		local progress = self._barView.panel_1.mc_progress.currentView.progress_4
		if not progress then
			echoWarn("这个不可能走的，这是为什么呢！")
			return
		end
		-- local progress = self._barView.panel_1.mc_progress.currentView.progress_3
		local callFunc = function (  )
			-- echo("__filtertool twenn-0-----")
			FilterTools.flash_easeBetween(progress,20,5,"oldFt","red",true)
		end

		if event then
			progress:tweenToPercent(percent,10,callFunc)
		else
			progress:setPercent(percent)
		end
		if percent >= 100 then
			-- self._barView.panel_1.mc_progress.currentView.progress_4:tweenToPercent(percent,20)
			-- self._barView.panel_1.mc_progress.currentView.progress_4:visible(true)
			-- self._barView.panel_1.mc_progress.currentView.progress_3:visible(false)
		else
			-- self._barView.panel_1.mc_progress.currentView.progress_4:visible(true)
			-- self._barView.panel_1.mc_progress.currentView.progress_4:tweenToPercent(percent,30)
			-- self._barView.panel_1.mc_progress.currentView.progress_3:visible(true)
		end
		
	end
	--取消缓动
	-- self._barView.panel_1.progress_3:setPercent(percent)
	-- self._barView.panel_1.progress_4:setPercent(percent)
end
-- 更改角色怒气豆消耗显示
function ViewHealthBar:energyCostChange( event )
    if self.target.controler:isQuickRunGame() then
        return
    end
    self:checkShowFullEnergyEff()
    if event then
        self:showOrHideBar(true)
        if not self:isVisible() then
            self._leftShowTime = barLastTime
        end
    end
end
--判断是否显示怒气条
function ViewHealthBar:checkShowFullEnergyEff(  )
	-- if not event then
	-- 	return
	-- end
	if self.target.controler:isQuickRunGame() then
		return
	end
	
	--地方阵营不显示怒气
	if self:getHealthCamp() == 2 then
		return
	end
	-- if self.target.data:energy() >= self.target.data:maxenergy()  then
	if self.target.data:checkCanGiveSkill(true)  then
		--如果不是满怒状态
		if not self._mannuState  then
			self._mannuState = true
			--创建特效
			if not self._mannuAni then
				self._mannuAni = ViewSpine.new("eff_mannuqi")
				self._mannuAni:parent(self._barView):pos(0,-3)
			end
			local actionArr = {
				{label = "eff_mannuqi_nuqitiao_chuxian"},
				{label = "eff_mannuqi_nuqitiao_xunhuan",loop = true},
			}
			-- 满怒后不需要这个特效了，修改为豆提示
			self._mannuAni:visible(false)
			-- self._mannuAni:visible(true)
			self._mannuAni:stopAllActions()
			self._mannuAni:playActionArr(actionArr)
		end

	else
		if self._mannuState then
			self._mannuState = false
			if self._mannuAni then
				self._mannuAni:stopAllActions()
				self._mannuAni:visible(false)
			end
		end

	end

end



--初始化时间
function ViewHealthBar:setInitTime( time )
	self.initTime = time
end

--改变时间
function ViewHealthBar:setTime( time )
	self.time = time
end


function ViewHealthBar:deleteMe( )
	self.target.data:clearOneObjEvent(self)
	FightEvent:clearOneObjEvent(self)
	--移除侦听
	self:removeFromParent()

end







--[[
隐藏法宝
]]
function ViewHealthBar:YinCangFaBao()
	if self.treaView then
		self.treaView:visible(false)
	end
end









--[[
显示英雄的攻击次序
这个人的操作次序
]]
function ViewHealthBar:showAttackNum( num,viewSizeWith,viewSizeHeight)
	if num>= 2 and num<=6 then
		if not self.attackNumView then
			self.attackNumView = UIBaseDef:createPublicComponent("UI_battle","mc_newnumber"):addto(self._rootNode)
		end
		self.attackNumView:pos(0,-viewSizeHeight)

		self.attackNumView:visible(true)
		self.attackNumView:setScaleX(Fight.cameraWay * 2)
		self.attackNumView:setScaleY( 2)
		self.attackNumView:showFrame(num-1)
	else
		self:hideAttackNum()
	end
end



--[[
隐藏英雄攻击测序
]]
function ViewHealthBar:hideAttackNum(  )
	if self.attackNumView then
		self.attackNumView:visible(false)
	end

end


--显示或者隐藏血条
function ViewHealthBar:showOrHideBar( value )
	-- 战斗等待阶段不显示血条
	local bState self.target.controler.logical:getBattleState()
	if bstate == Fight.battleState_wait then
		value = false
	end
	if self.target:getHeroProfession() == Fight.profession_obstacle then
		-- 障碍物永远不显示血条
		value = false
	end
	self._barView:visible(value)
	if self._buffCtn then
		self._buffCtn:visible(value)
	end
	self:chkOtherViewVisible()
end
-- 检查低血量及白条
function ViewHealthBar:chkOtherViewVisible(  )
	-- 只有我方血条低于30才显示提示效果(其实是绿色的那个progress)
	local hpBar = self._barView.currentView.mc_progress.currentView.hpBar
	local percent = math.round( self.target.data:hp()/self.target.data:maxhp() * 100 )
	if self:isHealthVisible() and self:getHealthCamp() == Fight.camp_1 and percent <= 30 then
		hpBar.panel_d1:visible(true)
		self:playNoteAnim(hpBar.panel_d1)
	else
		hpBar.panel_d1:setScaleY(1.1)
		hpBar.panel_d1:visible(false)
	end
	hpBar.progress_bai:visible(false)
end
-- 血槽低于多少的闪烁动画
function ViewHealthBar:playNoteAnim( view )
	view:stopAllActions()
	local fadeout = act.fadeto( 0.5,0 )
	local fadein = act.fadeto( 0.5,255 )
	local delaytime = act.delaytime(1.0)
	local sequence = act.sequence(fadein,delaytime,fadeout)
    local action = cc.RepeatForever:create(sequence)
    view:runAction(action)
end

--血条是否显示状态
function ViewHealthBar:isHealthVisible()
	if self._barView then
		return self._barView:isVisible()
	else
		return false
	end
end

--修正血条的位置
function ViewHealthBar:adjustBarPos(  )
	-- local w = self._barView:getContainerBox()
	local camp = self:getHealthCamp()
	local posIdx = self.target.data.posIndex
	local isBoss = (camp == Fight.camp_2 and self.target.data:boss()== 1 and self.target.data:figure() > 1)
	--如果是下排的人
	if posIdx %2 == 0 or isBoss then
		self._posType = 1
		self._barView:pos(hpWidth * (-1)*Fight.cameraWay ,-self._viewHeight)
		self._barView:showFrame(1)
		if self.treaView then
			self.treaView:pos(0,-self._viewHeight-70)
		end
	else
		self._posType = 2
		self._barView:pos(hpWidth* (-1)*Fight.cameraWay,30)
		self._barView:showFrame(2)
		if self.treaView then
			self.treaView:pos(0,50)
		end
	end
	-- 血条根据敌我和阵位做相应的偏移
	if camp == Fight.camp_1 then
		if posIdx <=2 then
			self._barView:setPositionX((hpWidth+20)*(-1)* Fight.cameraWay)
		elseif posIdx >=5 then
			self._barView:setPositionX((hpWidth-20)*(-1)* Fight.cameraWay)
		end
	else
		if posIdx <=2 then
			self._barView:setPositionX((hpWidth-20)*(-1)* Fight.cameraWay)
		elseif posIdx >=5 then
			self._barView:setPositionX((hpWidth+20)*(-1)* Fight.cameraWay)
		end
	end
	local pmcView = self._barView.currentView.mc_progress
	-- 是否显示五灵
	if camp == Fight.camp_2 and self.barType == 3 then
		pmcView:showFrame(2)
	else
		if not self:chkShowOrHideElement() then
			pmcView:showFrame(2)
		else
			pmcView:showFrame(1)
		end
	end
	-- 添加血条
	if not pmcView.currentView.hpBar then
		-- 读取哪一条血
		local pType = self._posType
		-- 敌方小怪或者未开启五灵时候
		if (camp == Fight.camp_2 and self.barType == 3) or 
			(not self:chkShowOrHideElement()) then
			pType = 3
		end
		local str = string.format("panel_bar_%s_%s",camp,pType)
		local tmpView = UIBaseDef:createPublicComponent( "UI_battle_public",str)
		tmpView:pos(0,0)
		tmpView:addto(pmcView.currentView.ctn_1)
		if pType == 3 then
			tmpView:setScaleX(0.88)
		end
		self._barView.currentView.mc_progress.currentView.hpBar = tmpView
	end
	local hpBar = self._barView.currentView.mc_progress.currentView.hpBar

	-- 更新对应frame 血条、血值、五行标签
	local percent = math.round( self.target.data:hp()/self.target.data:maxhp() * 100 )
	for k,v in pairs(hpBarArr) do
		hpBar[v]:setPercent(percent)
	end

	self:chkOtherViewVisible()
	-- 设置五行
	local fControler = self.target.controler.formationControler
	local eInfo =fControler:getElementInfoByPos(self.target.camp,self.target.data.posIndex)
	self:changeFormationElement(eInfo.element,self.target:getHeroElement())

	self:updateMaxHpStatus()
	-- 重排buff位置
	self:pressBuffChange()
end
-- 更新是否显示血量上限的层
function ViewHealthBar:updateMaxHpVisible( b ,per)
	local hpBar = self._barView.currentView.mc_progress.currentView.hpBar
	hpBar.progress_banma:visible(b)
	if per then
		hpBar.progress_banma:setPercent(per)
	end
end
-- 刷新一下血量的数据
function ViewHealthBar:updateMaxHpStatus(  )
	local fullPercent = math.round( self.target.data:maxtreahp()/self.target.data:maxhp() * 100 ) 
	local emptyPercent = 100 - fullPercent
	if emptyPercent ==0 then
		self:updateMaxHpVisible(false)
	else
		self:updateMaxHpVisible(true,emptyPercent)
	end
end
-- 因为巅峰竞技场是镜像翻转的、然后血条不能翻转，所以需要获取一次血条的camp
function ViewHealthBar:getHealthCamp(  )
	if BattleControler:getTeamCamp( ) == Fight.camp_2 then
		if not self._uiCamp then
			self._uiCamp = self.target.camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
		end
		return self._uiCamp
	end
	return self.target.camp
end
-- 检查是否显示五行标签
-- 2018.08.10 打开五灵阵位功能开启前对五灵标签的屏蔽
function ViewHealthBar:chkShowOrHideElement( )
	if (not self.target.controler.formationControler:checkIsOpenFormation()) then
	-- if (not self.target.controler.formationControler:checkIsOpenFormation()) or
	-- 		BattleControler:checkIsCrossPeak() then
		return false
	end
	return true
end

-- 更新高低
function ViewHealthBar:updateViewHight()
	-- 比例这样处理是因为,viewsize在之前已经作用过viewScale了
	self._viewHeight = (self.target.data.viewSize[2]) * (Fight.wholeScale + self.target.viewScale - self.target._viewScale) 
	self:adjustBarPos()
end
-- 根据阵型五行和角色五行飘对应的抗性、技能增强字 (TODO:换灵没有做处理)
function ViewHealthBar:updateElementTip(posElement)
	if posElement == Fight.element_non then
		return
	end
	if not self._elementTip then
		self._elementTip = UIBaseDef:createPublicComponent( "UI_battle_public","panel_prop" )
		self._elementTip:setScaleX(Fight.cameraWay )
		self._elementTip:addto(self._rootNode):pos(0,0)
	end
	local tmpView = self._elementTip
	local eInfo = self.target.controler.formationControler:getElementInfoByPos(self.target.camp,self.target.data.posIndex)
	local heroElement = self.target:getHeroElement()
	local str1 = GameConfig.getLanguageWithSwap("#tid_battle_lineup_fivesoulres_"..eInfo.element, eInfo.exDef/100)
	tmpView.txt_1:setString(str1)
	-- 技能增强文字
	if posElement == heroElement then
		tmpView.txt_2:visible(true)
		local str2 = GameConfig.getLanguageWithSwap("#tid_battle_lineup_fivesoulskillup", eInfo.exLv)
		tmpView.txt_2:setString(str2)
	else
		tmpView.txt_2:visible(false)
	end
    tmpView:stopAllActions()
    tmpView:opacity(255)
    tmpView:visible(true)
    tmpView:pos(0, -150)
    local callBack = function ()
        tmpView:setVisible(false)
    end
    tmpView:runAction(cc.Sequence:create(
            act.delaytime(1.1),
            act.spawn(act.moveto(1, 0, 100),act.fadeout(1)),
            act.callfunc(c_func(callBack))
        ))
end

return ViewHealthBar