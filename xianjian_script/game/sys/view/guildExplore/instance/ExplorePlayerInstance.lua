--
-- Author: 角色实例类.主要控制运动和一些操作
-- Date: 2018-07-03 11:54:03
--

local ExplorePlayerInstance = class("ExplorePlayerInstance", ExploreMoveInstance)

--是否重叠 
ExplorePlayerInstance.isOverLap = false

function ExplorePlayerInstance:setIsSelf( value )
	self._isSelf = true
	self.depthType = 10
	self.targetPos = {x=0,y =0}
	self:registerEvent()
	if self._isSelf then
		self._initDepthHeight = 10
		self:setDepthHeight(self._initDepthHeight)
	end
	self.isOverLap =false
end


function ExplorePlayerInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 2,height =FuncGuildExplore.gridHeight *3 }
end

function ExplorePlayerInstance:registerEvent()
end

--创建名字panel
function ExplorePlayerInstance:createNamePanel(  )

	local panel

	if self._isSelf then
		panel = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_player1" )
		local ani = self.controler.mainUI:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_jiantou", panel, true)
		ani:pos(0,30)
	else
		--我方阵营
		if self:checkIsSelfCamp()  then
			panel = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_player2" )
		else
			panel = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_player2" )
		end
	end
	local name = self._data.userInfo.name
	panel.txt_1:setString(name)
	panel:addTo(self.controler.mapControler.a22)
	self.namePanel = panel

	

end




--当点击map了
function ExplorePlayerInstance:onClickMap( targetX,targetY )
	-- GuildExploreServer:willGotoTargetPos( self.gridPos.x,self.gridPos.y,targetX,targetY )

	-- 暂定开始寻路
	if self.gridPos.x == targetX and  self.gridPos.y == targetY then
		self.targetData = self.gridControler:getGridOriginData( targetX,targetY)
		self:checkClickEvent()
		return
	end
	
	self:stopCurrentMove( targetX,targetY)

end



--停止当前运动
function ExplorePlayerInstance:stopCurrentMove( targetX,targetY )
	--隐藏当前路径
	
	--如果当前是有运动的 
	if self.moveType ~= 0 then
		--那么暂停当前的运动
		self:setIsPauseMove(true)
		local tempFunc = function ( serverInfo )
			self:setIsPauseMove(false)
			echo("_11111111111_这个停止行为没有意义")
			if not serverInfo.result then
				return
			end
			self.controler.mapControler:hideCurrentPath()
			self:setWillStop(true)
			self:sureDoClick(targetX,targetY)
		end
		--找到当前的movepoint  并停住
		local gridPos = {x = self.movePostion.gridX,y = self.movePostion.gridY}
		local params = self:turnMoveInfoToServer(gridPos.x,gridPos.y,gridPos.x,gridPos.y,{gridPos}  )
		--发送
		GuildExploreServer:moveToTargetPos( params ,tempFunc)
	else
		self:sureDoClick( targetX,targetY )
	end

end



--显示移动
function ExplorePlayerInstance:sureDoClick( targetX,targetY )
	local t1 = os.clock()
	
	local pathArr =self:findOnePath(targetX,targetY)
	echo(os.clock()- t1,"____寻路时间-----精力:",energy, pathArr and #pathArr or 0,"开始寻路:",self.gridPos.x,self.gridPos.y,targetX,targetY,"__targetX,targetY")
	
	--没有寻到路径
	if not pathArr then
		--如果是我已经站在目标点附近了 那么
		self:checkClickPlayer(targetX,targetY )
		return
	end

	local length = #pathArr
	for i=length,1,-1 do
		local pos = pathArr[i]
		--如果是不可通过的 
		if not self.gridControler:checkCanPass(pos.x,pos.y) then
			--移除不可通过的点
			table.remove(pathArr,i)
		end
	end
	local pathLength = #pathArr 
	local gridData  = self.gridControler:getGridData( targetX,targetY)
	--如果路径为0 表示是相邻的点
	if pathLength == 0 then
		--获取目标点的数据
		self.targetData = self.gridControler:getGridOriginData( targetX,targetY)
		-- echo("_寻路路径无法到达---------")
		self:overTargetPoint(true)
		return
	end
	--获取当前精力值
	local energy = GuildExploreModel:getEnegry(  )
	--如果大于最大路线
	if pathLength > GuildExploreModel:getMaxEnergy(  ) then
		echo("目的地过于遥远无法到达,需要消耗:%d点精力",pathLength)
		return
	end
	
	local tempFunc = function (  )
		local params = self:turnMoveInfoToServer(self.gridPos.x,self.gridPos.y,targetX,targetY ,pathArr  )

		GuildExploreServer:moveToTargetPos( params )

		--获取目标点的数据
		self.targetData = self.gridControler:getGridOriginData( targetX,targetY)

	end
	--只有自己才会显示路径 以及消耗提示
	self.controler.mapControler:showOnePath(pathArr,self.gridPos.x,self.gridPos.y)
	local window = WindowsTools:createWindow("GuildExploreCostEnergy",pathLength,tempFunc)
	window:addto(self.controler.mainUI._root,10)
	local endPos = pathArr[#pathArr]
	endPos = self.gridControler:getGridWorldPos(endPos.x, endPos.y)
	local targetPos = self.controler.mapControler.a22:convertLocalToNodeLocalPos(self.controler.mainUI, endPos)
	-- targetPos.y = targetPos.y- 50
	local border = 200 - GameVars.UIOffsetX 
	if targetPos.x > GameVars.gameResWidth - border then
		targetPos.x = GameVars.gameResWidth - border
	elseif targetPos.x < border  then
		targetPos.x = border
	end

	local yOffset = 50
	local yborder = 200 - GameVars.UIOffsetY
	--先做边界判断 
	if targetPos.y > -yOffset then
		targetPos.y  =-yOffset
	elseif targetPos.y < -GameVars.gameResHeight + yOffset then
		targetPos.y = -GameVars.gameResHeight + yOffset
	end

	if targetPos.y < -GameVars.gameResHeight +yborder then
		 targetPos.y =  targetPos.y  + yOffset
	elseif  targetPos.y  > -yborder then
		targetPos.y = targetPos.y- yOffset
	end

	window:pos(targetPos.x,targetPos.y)
end




--找一个到目标点可走的点
function ExplorePlayerInstance:findOnePath( x,y )

	local eventModel = GuildExploreModel:getSubGridEvent( x,y )
	local _,pathArr = self.controler.pathControler:findPath(self.gridPos,{x=x,y = y })
	if not eventModel then
		--如果是不可走区域 那么不能走
		if not self.gridControler:checkCanPass( x,y ) then
			return nil
		end
		if #pathArr == 0 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_tips_1"))
			return nil
		end
		return pathArr
	else
		--有事件  那么读取事件的所有子节点 找一个最短路径
		local originData = self.gridControler:getGridOriginData( x,y )
		_,pathArr = self.controler.pathControler:findPath(self.gridPos,{x=x,y = y })
		local isNearTarget = false
		if ExploreGridControler:checkPosIsNear( x,y ,self.gridPos.x,self.gridPos.y)  then
			isNearTarget = true
			return {}
		end
		local  minPathArr = pathArr
		if #pathArr ==0 then
			minPathArr = nil
		end

		if originData.child then
			for i,v in ipairs(originData.child) do
				local childx,childy = FuncGuildExplore.getPosByKey(v)
				if ExploreGridControler:checkPosIsNear( childx,childy,self.gridPos.x,self.gridPos.y )  then
					isNearTarget = true
					return  {}
				end
				_,pathArr = self.controler.pathControler:findPath(self.gridPos,{x=childx,y = childy })
				if #pathArr >= 1  then
					if not minPathArr then
						minPathArr = pathArr
					else
						if #minPathArr > #pathArr then
							minPathArr = pathArr
						end
					end
				end
			end
		end
		--如果是
		if isNearTarget then
			return {}
		end
		if not minPathArr then
			minPathArr = pathArr
		end
		--如果最短路径为0了 表示目标不可到达
		if #minPathArr == 0 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_tips_1"))
			return nil
		end

		return minPathArr

	end
	
	return pathArr

end


--点击寻路
function ExplorePlayerInstance:overTargetPoint( isEnd )
	ExplorePlayerInstance.super.overTargetPoint(self,isEnd)
	if not self._isSelf then
		return
	end
	--如果确定到达了
	if not isEnd then
		return 
	end


	local tempFunc = function (  )
		
		self:checkClickEvent()
	end

	GuildExploreServer:sureArrive(tempFunc)


end

function ExplorePlayerInstance:checkClickEvent()
	if not self.targetData then
		self:checkClickPlayer( self.gridPos.x,self.gridPos.y )
		return
	end

	--判断点击的是什么东西
	local x,y = self.targetData.x,self.targetData.y
	--如果是有事件的
	local eventModel =  GuildExploreModel:getGridEvent( x,y )
	if eventModel then
		self:doClickEvent(x,y)

	else
		self:checkClickPlayer( x,y )
	end

	self.targetData = nil
end


--执行点击地图事件逻辑
function ExplorePlayerInstance:doClickEvent( x,y )
	local eventModel =  GuildExploreModel:getGridEvent( x,y )
	--如果没有事件  直接返回
	if not eventModel then
		return
	end
	eventModel.x = x
	eventModel.y = y

	local eventInstance = self.controler:getEventInstance(FuncGuildExplore.getKeyByPos(x, y))

	-- dump(eventModel,"点击获取地图上的数据结构 ====== ")
	--如果是小怪 


	local delayTime = 0


	local tempFunc = function (  )
		if eventModel.type == FuncGuildExplore.gridTypeMap.enemy   then
			echo("点击的是小怪弹出小怪面板")
			self:addMonsterView(eventModel)
		elseif eventModel.type == FuncGuildExplore.gridTypeMap.elite  then
			echo("点击的是精英怪弹出,精英面板")
			self:addMonsterView(eventModel)
		elseif eventModel.type == FuncGuildExplore.gridTypeMap.res  then
			echo("点击的是资源,弹出资源面板")
			self:pickupResources(eventModel)
		elseif eventModel.type == FuncGuildExplore.gridTypeMap.spring  then
			echo("点击的是灵泉,弹出灵泉面板")
			self:pickupSpring(eventModel)
		elseif eventModel.type == FuncGuildExplore.gridTypeMap.build  then
			echo("点击的是建筑,弹出建筑面板")
			local eventId = eventModel
			GuildExploreEventModel:showBuildUI(eventModel)
			self.controler.mapControler:resumeScaleInstance()
			self.controler:pushOneCallFunc(5, self.controler.mapControler.resumeScaleInstance, {self.controler.mapControler})
		elseif eventModel.type == FuncGuildExplore.gridTypeMap.mine  then
			echo("点击的是矿洞,弹出矿洞面板")
			GuildExploreEventModel:showMineUI(eventModel,false)
			self.controler:pushOneCallFunc(5, self.controler.mapControler.resumeScaleInstance, {self.controler.mapControler})
		end
	end

	if eventModel.type ~= FuncGuildExplore.gridTypeMap.res and  eventModel.type ~= FuncGuildExplore.gridTypeMap.spring then
		self.controler.mapControler:scaleToTargetInstance( eventInstance )
		delayTime = 0.3
		self.controler:pushOneCallFunc(10, tempFunc)
	else
		tempFunc()
	end
	

end  



--当一个格子到达的时候
function ExplorePlayerInstance:oneGridArrived(x,y,fromx,fromy,index ,isFinal)
	if self._isSelf then
		--如果是将要停止的 直接return
		if self._willStop then
			return
		end
		self.controler.mapControler:hideOnePathPos(x,y,index,isFinal)
		if isFinal then
			self.controler.mainUI:showOrHideWalkCue(false)
		end

	end
	-- --本地扣除一点精力值
	-- self.controler:checkOnePosPlayer(x,y)
	-- self.controler:checkOnePosPlayer(fromx,fromy)
end

--[[
	eventModel = {
	    "id"      = 48
	    "tid"     = "102"
	    "type"    = "5"
	    "visible" = 1
	    "x"       = 52
	    "y"       = 22
	}
]]
--拾取灵泉
function ExplorePlayerInstance:pickupSpring(eventModel)
	local function callBack(event)
		if event.result then
			dump(event.result,"========拾取灵泉的返回数据======")
			-- if event.result.data.result
			if event.result.data then
				local buff = event.result.data.buff
				if buff then
					for k,v in pairs(buff) do
						local buffData = FuncGuildExplore.getFuncData( "ExploreBuff",k,"effect")
						local res = string.split(buffData[v.index], ",")
						local _type = res[1]
						local valuerMore = res[2]
						local value = res[3]
					end
					GuildExploreModel:setBuffList(buff)
				end

				self:createSpringEff(eventModel.x,eventModel.y,eventModel.tid)
				-- local key =  FuncGuildExplore.getKeyByPos(eventModel.x,eventModel.y )
				-- local tempData = {
				-- 	mapInfo = {
				-- 		cells = {
				-- 			[key] = {eventList = 1}
				-- 		},
				-- 		events = {
				-- 			[eventModel.id] = 1
				-- 		}
				-- 	}
				-- }
				-- GuildExploreModel:deleteData( tempData )
			end
		else

		end
	end
	local params = {
		eventId = eventModel.id
	}
	GuildExploreServer:sendPickupSpring(params,callBack)
end

--创建,灵泉特效
function ExplorePlayerInstance:createSpringEff( x,y,tid )
	local worldPos = self.gridControler:getGridWorldPos( x,y )
	--创建一个灵泉特效
	if not self.springAni then
		self.springAni = self.controler.mainUI:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_penquanxiaoshi", self.controler.mapControler.a22, false, GameVars.emptyFunc)
	end
	
	--换装 
	if self.springAni.currentTid ~= tid then
		self.springAni.currentTid = tid
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreBuff",tid ,"img")
		local view =  self.controler.mapControler:createViewBySourceId(sourceId)
		view:anchor(0.5,0.64)
		FuncArmature.changeBoneDisplay(self.springAni, "node", view)
	end
	self.springAni:startPlay(false, false,true):pos(worldPos.x,worldPos.y-15):zorder(1000000)


	self.controler:pushOneCallFunc(20, self.createSelfGetSpringEff, {self})
	

end

function ExplorePlayerInstance:createSelfGetSpringEff(  )
	--创建自身获取特效
	if not self.springSelfAni then
		self.springSelfAni = self.controler.mainUI:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_shilitisheng", self.myView, false, GameVars.emptyFunc):pos(0,20)
		
	end
	self.springSelfAni:startPlay(false, false,true)
end


--拾取资源
function ExplorePlayerInstance:pickupResources(eventModel)
	-- dump(eventModel,"eventrMode =============")
	local function callBack(event)
		if event.result then
			-- dump(event.result,"========拾取资源的返回数/据======")
			local reward =  event.result.data.reward

			-- GuildExploreModel:byEventModelDeleteData(eventModel)
			if reward then
				-- local res = string.split(reward[1], ",")
				local record = FuncGuildExplore.getCfgDatasByKey( "ExploreRes",eventModel.tid ,"record")
				if record then
					reward = GuildExploreModel:rewardTypeConversion(reward)
					if record == 1 then
						WindowControler:showWindow("GuildExploreSurpriseView",reward);
					else
						WindowControler:showWindow("RewardSmallBgView", reward);
					end
				else
					-- dump(reward,"=====显示奖励的数据======")
					reward = GuildExploreModel:rewardTypeConversion(reward)
					FuncCommUI.startRewardView(reward)
				end
				
				GuildExploreServer:checkSetExploreOption( eventModel.tid ,callback)
				local res = string.split(reward[1], ",")
				local wind = WindowControler:getWindow( "GuildExploreMainView" )
				if wind then
					-- echo("======存在===wind=======")
					local endPos = nil
					local index = 1
					if res[1] == FuncGuildExplore.guildExploreResType then 
						local itemId = res[2]
						index = itemId
						endPos = wind:getResPos(tonumber(itemId))
					else
						index = 5
						endPos = wind:getResPos(tonumber(5))
					end
					local function callBack()
						-- echo("1111111111111111111======callBack===",index)
					end
					local beginPos = self.gridControler:getGridWorldPos( eventModel.x,eventModel.y )
					
					beginPos = self.controler.mapControler.a22:convertLocalToNodeLocalPos(wind,beginPos)
					-- dump(beginPos,"======开始位置===")
					-- dump(endPos,"======最终位置===")
					self:playAddStarParticles(beginPos,endPos,callBack)
				end


				EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
			end
		end
	end


	local params = {
		eventId = eventModel.id,
	}

	GuildExploreServer:sendPickupResources(params,callBack)
end



-- 播放新增star特效
function ExplorePlayerInstance:playAddStarParticles(beginPos,endPos,callBack)
    local effectPlist = FuncRes.getParticlePath() .. 'mobailizi.plist'
    local particleNode = cc.ParticleSystemQuad:create(effectPlist);
    particleNode:setTotalParticles(200);
    particleNode:setVisible(false);

    self.controler.mainUI._root:addChild(particleNode)
    particleNode:pos(beginPos)
   	particleNode:zorder(10000)

    local deleteParticle = function()
        particleNode:removeFromParent()
        -- echo("删除特效")
    end

    local beginX = beginPos.x
    local beginY = beginPos.y

    local endX = endPos.x
    local endY = endPos.y

    local xDiff = endX - beginX+15
    local yDiff = endY - beginY-15

    local acts = {
        act.callfunc(function ( ... )
            particleNode:setVisible(false);
        end),
        act.delaytime(0.2),
        act.callfunc(function ( ... )
            particleNode:setVisible(true);
        end),
        act.moveby(0.7, xDiff, yDiff),
        act.callfunc(callBack),
        act.delaytime(1.0 / GameVars.GAMEFRAMERATE * 5),
        act.moveby(1.0 / GameVars.GAMEFRAMERATE, 500, 500),
        act.delaytime(1),
        act.callfunc(deleteParticle),
    };

    particleNode:runAction(act.sequence(unpack(acts)));
end




--添加怪物的界面
function ExplorePlayerInstance:addMonsterView(eventModel)
	local viewName = nil
	-- if not self.monsterView then
	-- 	self.monsterView = {}
	-- end
	if eventModel.type == FuncGuildExplore.gridTypeMap.enemy   then  --普通怪
		viewName = "GuildExploreOrdinaryMonsterView"
	elseif eventModel.type == FuncGuildExplore.gridTypeMap.elite  then  --精英怪
		viewName = "GuildExploreEliteMonsterView"

	end

	if viewName then
		local wind = WindowControler:showWindow(viewName)
		wind:getServerData(eventModel)
		EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_MAIN_ISSHOW,{isShow = false})
	end

end


--是否点击角色了
function ExplorePlayerInstance:checkClickPlayer( gridX,gridY )
	local playerArr = self.controler:getPlayerByGrid(gridX, gridY)

	if #playerArr == 1 then
		self.controler:showOnePlayerInfo( playerArr[1]:getData() )
	elseif #playerArr > 1 then
		--
		local dataArr = {}
		for i,v in ipairs(playerArr) do
			table.insert(dataArr, v:getData())
		end
		WindowControler:showWindow("GuildExploreCheckPlayerView",dataArr,self.controler)

	end

end


--是否是我方阵营
function ExplorePlayerInstance:checkIsSelfCamp(  )
	--后面需要扩展 ,controler里面会有一个 guidCamp的值
	return self.camp == 1
end


--重写设置是否出界函数
function ExplorePlayerInstance:setIsOut(value )
	ExplorePlayerInstance.super.setIsOut(self,value)
	if not self.namePanel then
		return
	end
	self:checkNamePanelVisible()
end

--判断是否显示 名字panel
function ExplorePlayerInstance:checkNamePanelVisible(  )
	if self.isOverLap then
		self.namePanel:setVisible(false)
	elseif self._isOut then
		self.namePanel:setVisible(false)
	else
		self.namePanel:setVisible(true)
	end
end

-- 设置是否重叠
function ExplorePlayerInstance:setIsOverLap( value )
	self.isOverLap = value
	if value then
		self.myView:setOpacity(125)
		self:setDepthHeight(0)
	else
		self.myView:setOpacity(255)
		self:setDepthHeight(5)
	end
	self:checkNamePanelVisible()
end


function ExplorePlayerInstance:deleteMe(  )
	ExplorePlayerInstance.super.deleteMe(self)
	if self.namePanel and(not tolua.isnull(self.namePanel) ) then
		self.namePanel:removeFromParent()
		self.namePanel = nil
	end
end



return ExplorePlayerInstance