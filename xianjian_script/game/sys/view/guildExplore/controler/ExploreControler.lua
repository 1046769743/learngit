--
-- Author: xd
-- Date: 2018-07-03 11:49:58
-- 探索控制器.主要是控制场景元素的创建管理元素对象
local  ExploreControler = class("ExploreControler")

--我方角色数组
ExploreControler.campArr_1 = nil
--敌方角色数组 
ExploreControler.campArr_2 = nil

--所有对象数组 用来管理场景销毁时的处理
ExploreControler.allInstanceArr = nil

--获取玩家自身instance
ExploreControler.selfPlayer = nil

--所有事件的表
ExploreControler.allEventInstanceMap = nil

ExploreControler.allPlayerInstanceMap = nil
--所有出生点的表
ExploreControler.allBirthInstanceMap = nil

ExploreControler.createIndex = 0

--仙盟 控制器
function ExploreControler:ctor( mainUI )
	
	self.totalDt = 0
	self.callFuncArr = {}
	self.allInstanceArr = {}
	self.campArr_1 ={}
	self.campArr_2 ={}
	self.allEventInstanceMap = {}
	self.allPlayerInstanceMap = {}
	self.allBirthInstanceMap = {}
	self.mainUI = mainUI
	local rootNode = display.newNode():addto(mainUI._root,-1)
	--先存储数据
	self._rootNode = rootNode
	self.allData =  GuildExploreModel:getAllMapData(  ) 
	self.gridControler = ExploreGridControler  --ExploreGridControler.new(self,self.allData.mapInfo.cells)
	
	self.mapControler = ExploreMapControlerEx.new(self,rootNode,self.allData.mapInfo.cells,self.allData.mapInfo.width,self.allData.mapInfo.height)
	
	--初始化所有的事件
	self:initAllEvent()
	
	--刷新计数器
	self.updateCount = 0 
	self.updateDt =0
	self.mapControler:initMapPos()
	self.pathControler = ExplorePathControler.new(self.gridControler)
	--获取我方所有阵营玩家数据
	local userData = GuildExploreModel:getAllSelfUsersDatas(  )
	self:initUsersData(userData,1)

	--初始化出生点
	self:pushOneCallFunc(1, "initBirthPoint")

	rootNode:scheduleUpdateWithPriorityLua(c_func(self.checkUpDate,self),0)

	--侦听玩家数据变化消息
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_USERDATACHANGE, self.onUsersDataChange,self)
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_USERLEAVE, self.onUsersDataDelete,self)

	--侦听事件变化消息
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_EVENTCHANGE, self.onEventChange,self)

	EventControler:addEventListener(GuildExploreEvent.GUILDEXPOREEVENT_MAPCHANGE, self.onMapDataChange,self)
	--注册地图数据删除事件
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPOREEVENT_MAPDELETE, self.onMapDataDelete,self)
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_INITCOMPLETE, self.onExploreReInitComplete,self)

end


--矿洞重复初始化完毕
function ExploreControler:onExploreReInitComplete(  )
	--需要同步界面的事件和 角色
	--初始化所有事件刷新 数据也需要重新拿引用
	self.allData = GuildExploreModel:getAllMapData(  ) 
	if self.mapControler then
		self.mapControler.mapCells = self.allData.mapInfo.cells
	end

	-- 需要销毁所有的事件
	for k,v in pairs(self.allEventInstanceMap) do
		v:destoryData()
		self.allEventInstanceMap[k] = nil
	end

	self:onMapDataChange({params = self.allData.mapInfo.cells})
	--初始化所有角色刷新
	self:onUsersDataChange({params = self.allData.mapInfo.roles})
	-- self.mapControler:resumeScaleInstance()

end

--获取某一阵营的数组
function ExploreControler:getCampArr( camp )
	if camp == 1 then
		return self.campArr_1
	else
		return self.campArr_2
	end
end

--移除某一个玩家
function ExploreControler:clearOnePlayer( playerInstance,rid)
	local campArr = self:getCampArr(playerInstance.camp)
	table.removebyvalue(campArr, playerInstance)
	playerInstance:deleteMe()
	
	--从所有对象里面移除
	table.removebyvalue(self.allInstanceArr, playerInstance)
	self.allPlayerInstanceMap[rid] = nil
	self:checkOnePosPlayer(playerInstance.gridPos.x,playerInstance.gridPos.y)
	echo("移除一个玩家",rid)
end





--初始化创建所有玩家
function ExploreControler:initUsersData(userData,camp )
	local index = 0
	for k,v in pairs(userData) do
		index = index +1
		self:pushOneCallFunc(index+1, "createOnePlayer", {v,camp,k})
	end
end


function ExploreControler:initBirthPoint(  )
	local mapId = self.allData.mapInfo.mapId
	local birthPointArr = FuncGuildExplore.getCfgDatasByKey( "ExploreMapChoose",mapId ,"start")
	for i,v in ipairs(birthPointArr) do
		local instance = ExploreBrithInstance.new(self)
		local gridArr = string.split(v, ",")
		instance:setBirthPoint(tonumber(gridArr[1]),tonumber(gridArr[2]),i )
		self.allBirthInstanceMap[i] = instance
	end

end

--创建所有的事件
function ExploreControler:initAllEvent(data,events  )
	local cells = self.allData.mapInfo.cells
	for k,v in pairs(cells) do
		--如果是有事件的  创建事件
		--必须不是子节点 而且有eventList的
		if (not v.sub) and v.eventList then
			local x,y = FuncGuildExplore.getPosByKey(k)
			local eventModel = GuildExploreModel:getGridEvent(x,y)
			if not eventModel  then
			else
				self:createOneEvent(eventModel,x,y)
			end
		end
	end

end


--创建一个事件
function ExploreControler:createOneEvent(eventModel,x,y )
	

	local t = tostring(eventModel.type)
	local tid = eventModel.tid
	local cl 
	local view
	local miniName = nil
	local sourceId
	local nameNanelName
	--如果是怪物
	if t == FuncGuildExplore.gridTypeMap.enemy then
		cl = ExploreEnemyInstance


	elseif t == FuncGuildExplore.gridTypeMap.elite then
		cl = ExploreEnemyInstance
		-- miniName = "panel_map3"
	elseif t == FuncGuildExplore.gridTypeMap.mine  then
		cl = ExploreMineInstance
		sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreMine",tid ,"img")
		nameNanelName = "panel_mine_"..FuncGuildExplore.getCfgDatasByKey( "ExploreMine",tid ,"mineType")
		miniName = "panel_map4"
	elseif t == FuncGuildExplore.gridTypeMap.res  then
		sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreRes",tid ,"img")
		cl = ExploreResInstance
	elseif t == FuncGuildExplore.gridTypeMap.spring  then
		cl = ExploreSpringInstance
		sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreBuff",tid ,"img")
	elseif t == FuncGuildExplore.gridTypeMap.build  then
		cl = ExploreBuildInstance
		miniName = "panel_map5"
		sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreCity",tid ,"img")
	end
	if not cl then
		echoError("没有这个class:",t,tid,t=="1")
	end
	local instance = cl.new(self,eventModel)
	instance:setGridPos(x, y)
	if sourceId then
		instance:setTexturePanelName("panel_".. sourceId,nameNanelName)

	end
	
	if miniName then
		if self.mainUI[miniName] then
			local miniView =  UIBaseDef:cloneOneView( self.mainUI[miniName] )
			-- miniView:setScale(0.7)
			instance:setMiniView(miniView)
			instance:checkShowMiniView()
		end
	end
	

	local key = FuncGuildExplore.getKeyByPos(x,y)
	--按照 标准存储格式 
	self.allEventInstanceMap[key] = instance

end

--根据坐标获取事件实例
function ExploreControler:getEventInstance( key )
	return self.allEventInstanceMap[key]
end

--获取角色实例
function ExploreControler:getPlayerInstance( rid )
	return self.allPlayerInstanceMap[tostring(rid)]
end


--销毁一个事件
function ExploreControler:clearOneEventInstance( key )
	local instance = self:getEventInstance(key)
	if instance then
		instance:destoryData()
		self.allEventInstanceMap[key] = nil
	end
end

--当事件发生变化
function ExploreControler:onEventChange( event )
	local eventData = event.params
	dump(eventData,"__eventData")

	--事件变化 设置1帧以后刷新
	self.mapControler:setWillRefreshCount(1)

end

--地图数据发生变化
function ExploreControler:onMapDataChange( event )
	local mapChange = event.params
	--地图数据发生变化
	for k,v in pairs(mapChange) do
		--如果是删除事件了
		local x,y = FuncGuildExplore.getPosByKey( k )
		local eventModel = GuildExploreModel:getGridEvent( x,y ) 
		local instance = self:getEventInstance(k)
		local gridData = self.gridControler:getGridDataByKey(k)
		if not gridData.sub and gridData.eventList  then
			if eventModel then
				if not instance then
					self:createOneEvent(eventModel, x, y)
					self.mapControler:setWillRefreshCount(1)
				end
			else
				--如果没有事件  那么需要删除这个实例
				if instance then
					self:clearOneEventInstance(k)
					self.mapControler:setWillRefreshCount(1)
				end
			end
		end
		

	end


end

--地图数据删除了
function ExploreControler:onMapDataDelete( event )
	local mapChange = event.params
	--地图数据发生变化
	for k,v in pairs(mapChange) do
		--如果是删除事件了
		if v.eventList == 1 then
			self:clearOneEventInstance(k)
		else

		end

	end
end



--阵容1玩家数据发生变化
function ExploreControler:onUsersDataChange( event )
	local params = event.params
	for i,v in pairs(params) do
		-- 如果这个时候 这个角色刚好退出去了 那么这个玩家是不存在的
		if GuildExploreModel:getUserDataByRid( i ) then
			local playerInstance = self:getPlayerInstance(i)
			if not playerInstance then
				--那么需要创建一个角色
				local userData = GuildExploreModel:getUserDataByRid( i)
				self:createOnePlayer(userData,userData.camp or 1,i)
			else
				playerInstance:onDataChange(v)
			end
		end

		
		
	end
	self.mapControler:setWillRefreshCount(1)

end

--当一个用户离开
function ExploreControler:onUsersDataDelete( event )
	local params = event.params
	for i,v in pairs(params) do
		local playerInstance = self:getPlayerInstance(i)
		if  playerInstance and v == 1 then
			self:clearOnePlayer(playerInstance,i)
		end
		
	end
	-- self:checkShowMiniView()
end


--判断是否刷新小地图
function ExploreControler:checkShowMiniView(gridX,gridY  )
	local nearPoints = FuncGuildExplore.nearPoints
	local instance = self:getEventInstance(FuncGuildExplore.getKeyByPos(gridX,gridY))
	if instance then
		instance:checkShowMiniView()
	end
	
	for k,v in pairs(nearPoints) do
		instance = self:getEventInstance(FuncGuildExplore.getKeyByPos(gridX+v[1],gridY+v[2]))
		if instance then
			instance:checkShowMiniView()
		end
		
	end
end


--创建一个玩家
function ExploreControler:createOnePlayer( userData,camp,rid )
	--这里需要判断这个rid是否存在  因为是分帧创建的 这个时候  这个人可能会掉线
	local tempUserData =  GuildExploreModel:getUserDataByRid( rid )
	if not tempUserData then
		echoWarn("创建角色的时候 这个玩家已经掉线了",rid)
		return
	end

	if self:getPlayerInstance(rid) then
		echo("当前rid角色已经存在,是因为已经接受到了 role enter map",rid)
		return
	end

	local instance = ExplorePlayerInstance.new(self,userData)
	local garmentId
	if userData.userInfo.userExt  and userData.userInfo.userExt.garmentId then
		garmentId = userData.userInfo.userExt.garmentId
	else
		garmentId = ""
	end
	local sp = FuncGarment.getSpineViewByAvatarAndGarmentId(userData.userInfo.avatar, garmentId,false)
	instance:initView(self.mapControler.a22, sp)
	--设置网格坐标  这里最好和model里面的坐标区别开来一个是静态 一个是动态
	-- dump(userData,"__userData")
	instance:setViewScale(FuncGuildExplore.chapterScale)
	local gridX,gridY = FuncGuildExplore.getPosByKey(userData.pos.target)
	local miniName
	if rid == UserModel:rid() then
		self.selfPlayer = instance
		instance:setIsSelf(true)
		miniName = "panel_map1"
		self.selfPlayer.myView.currentAni:setOpacity(0)
		--创建出场特效
		self:pushOneCallFunc(60, "createPlayerEnterAni")
	else
		miniName = "panel_map2"
	end
	

	local campArr = self:getCampArr(camp)
	instance:createNamePanel()
	instance:updatePosInfo( userData.pos )

	if self.mainUI[miniName] then
		local miniView =  UIBaseDef:cloneOneView( self.mainUI[miniName] )
		instance:setMiniView(miniView)
		instance:checkShowMiniView()
	end
	table.insert(campArr, instance)
	table.insert(self.allInstanceArr, instance)	
	self.allPlayerInstanceMap[rid] = instance
	--

	self:checkOnePosPlayer(instance.gridPos.x,instance.gridPos.y)

end

function ExploreControler:createPlayerEnterAni(  )
	local ani = self.mainUI:createUIArmature("UI_chuchangguang", "UI_chuchangguang", self.mapControler.a23, false)
	ani:pos(self.selfPlayer.pos.x,self.selfPlayer.pos.y)
	-- ani:setScale(scale)
	-- self.selfPlayer.myView.currentAni:visible(true)
	self.selfPlayer.myView.currentAni:fadeTo(1, 255)
end


--判断某个点上的角色透明度
function ExploreControler:checkOnePosPlayer( gridX,gridY )
	local playerArr = self:getPlayerByGrid( gridX,gridY ,true)

	local player
	if #playerArr == 1 then
		player = playerArr[1]
		player:setIsOverLap(false)
	elseif #playerArr > 1 then
		playerArr[1]:setIsOverLap(false)
		for i=2,#playerArr do
			playerArr[i]:setIsOverLap(true)
		end
	end
end


--根据网格坐标获取主角
function ExploreControler:getPlayerByGrid( gridX,gridY ,containerSelf)
	local resultArr = {}

	local countCampArr = function ( campArr )
		for i,v in ipairs(campArr) do
			if v.gridPos.x == gridX and v.gridPos.y == gridY then
				if v._isSelf  then
					if containerSelf then
						table.insert(resultArr, 1,v)
					end
				else
					table.insert(resultArr, v)
				end
			end
		end
	end
	countCampArr(self.campArr_1)
	countCampArr(self.campArr_2)
	
	return resultArr
end


--查看一个角色信息
function ExploreControler:showOnePlayerInfo( data )
	
	local onGetUserInfoBack = function ( serverInfo )
		if not serverInfo.result then
			return
		end
		WindowControler:showWindow("CompPlayerDetailView",serverInfo.result.data.data[1],self,3)
	end
	local rid = data.rid
	local param = {
		rids ={rid}
	}
	ChatServer:queryPlayerInfo(param,onGetUserInfoBack)
end

function ExploreControler:checkUpDate( dt )
	self.updateDt  = self.updateDt  + dt
	self.totalDt = self.totalDt + dt
	--修改刷新方式 改为累进式 执行updateframe. 必须要满 1帧的时间才刷新一次.同时记录剩余刷新量.
	-- 这样就算快或者慢 计算都是准确的 前提是玩家没有开加速器
	if self.updateDt > Fight.dummyUpdata then
		local loop = math.floor(self.updateDt/Fight.dummyUpdata)
		for i=1,loop do
			self:updateFrame(Fight.dummyUpdata) 
		end
		self.updateDt = self.updateDt - Fight.dummyUpdata* loop
	end
end

function ExploreControler:updateFrame( dt )

	


	self.updateCount = self.updateCount+1
	self.mapControler:updateFrame()
	--调用所有对象的updateframe
	local length = #self.allInstanceArr
	for i=length,1,-1 do
		self.allInstanceArr[i]:updateFrame()
	end

	self:updateCallFunc()
	
end



--更新回调
function ExploreControler:updateCallFunc(  )

	--执行一些回调
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		if callInfo  and callInfo.left > 0 then
			callInfo.left = callInfo.left -1
			if callInfo.left ==0 then
				--必须先移除这个回调信息 因为回调函数里面可能继续有回调
				-- 减少遍历这里保留直接删除，因为这里的倒序删除不会产生问题
				table.remove(self.callFuncArr,i)
				--如果回调是字符串
				if type(callInfo.func) == "string" then
					if callInfo.params then
						self[callInfo.func](self,unpack(callInfo.params))
					else
						self[callInfo.func](self)
					end
				else
					if callInfo.params then
						callInfo.func(unpack(callInfo.params))
					else
						callInfo.func()
					end
				end
				
			end
		end
	end
end


function ExploreControler:pushOneCallFunc( delayFrame,func,params )
	if not func then
		echoError("___空函数")
		return
	end
	
	if not delayFrame then
		echoError("___空帧数")
		return
	end

	if delayFrame ==0 then
		if type(func) == "string" then
			func = self[func]
			if params then
				self[func](self,unpack(params))
			else
				self[func](self)
			end
		else
			if params then
				func(unpack(params))
			else
				func()
			end
		end
		
		return
	end

	local info = {
		left = delayFrame,
		func = func,
		params = params,
		_valid = true,
	}

	--插入到最前面
	table.insert(self.callFuncArr,1, info)
end



--清除一个回调
function ExploreControler:clearOneCallFunc( func,obj )
	local function clearFunc( t )
		local length = #t
		for i=length,1,-1 do
			local info = t[i]
			if  info.func == func then
				if obj then
					if info.params and info.params[1] == obj then
						table.remove(t,i)
					end
				else
					table.remove(t,i)
				end
				
			end
		end
	end
	clearFunc(self.callFuncArr)
end


-- 根据传入的targe移除parames里面是该对象的oneClallFunc
function ExploreControler:clearOneCallFuncByObj(target )
	local function clearFunc( t )
		local length = #t
		for i=length,1,-1 do
			local info = t[i]
			if  info.params and info.params[1] == target then
				table.remove(t,i)
			end
		end
	end
	clearFunc(self.callFuncArr)
end




function ExploreControler:deleteMe(  )
	if self._isDied then
		return
	end
	self._isDied = true
	--调用所有子对象的deleme
	for i=#self.allInstanceArr,1,-1 do
		self.allInstanceArr[i]:deleteMe()
	end
	self.allInstanceArr = nil
	--清除自身数据事件
	EventControler:clearOneObjEvent(self)
	self.allPlayerInstanceMap = nil
	for k,v in pairs(self.allEventInstanceMap) do
		v:deleteMe()
	end
	self.allEventInstanceMap = nil
	for k,v in pairs(self.allBirthInstanceMap) do
		v:deleteMe()
	end
	self.allBirthInstanceMap = nil
	

	self._isDied = true
	self.mapControler:deleteMe()
	self.gridControler=  nil
	if not tolua.isnull(self._rootNode) then
		self._rootNode:unscheduleUpdate()
		self._rootNode:removeAllChildren()
		self._rootNode = nil
		
	end
end


return ExploreControler