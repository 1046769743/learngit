--
--Author:      zhuguangyuan
--DateTime:    2018-03-10 10:23:24
--Description: 搜刮主界面
--1.

local TowerCharModelClazz = require("game.sys.view.tower.model.TowerCollectionCharModel")
local TowerCollectionView = class("TowerCollectionView", UIBase);

function TowerCollectionView:ctor(winName)
    TowerCollectionView.super.ctor(self, winName)
end

function TowerCollectionView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function TowerCollectionView:registerEvent()
	TowerCollectionView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))

	EventControler:addEventListener(TowerEvent.TOWER_COLLECT_FIND_ONE_RESULT,self.findOneResult,self)
	EventControler:addEventListener(TowerEvent.TOWER_GO_TO_HANDLE_EVENTS_CONFIRMED,self.gotoHandleEvents,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_ACCELERATE_DATA_UPDATE_SUCCEED,self.updateUI,self)

	-- 确认加速
	EventControler:addEventListener(TowerEvent.TOWER_GO_TO_ACCELERATE_COLLECTION_CONFIRMED,self.accelerateCollection,self)
	-- 解决了一个事件 通知搜刮场景删掉相应的npc
	EventControler:addEventListener(TowerEvent.TOWER_HANDLE_ONE_EVENT_SUCCEED,self.finishedOneEvent,self)
end

function TowerCollectionView:finishedOneEvent( event )
	dump(event.params, "处理完一个事件")
	-- 这里给一条消息 让主界面搜刮红点做更新
	TowerMainModel:checkCollectionBtnRedPoint()
	-- EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED)
	self:updateSceneNpc()
end
-- 刷新进度百分比及剩余搜刮时间
function TowerCollectionView:updateFrame()
	if self.isAccelerating then
		-- echo("________ 加速中...____________")
		self.btn_status:setBtnStr( GameConfig.getLanguage("#tid_tower_ui_122"),"txt_1")
	end
	local status,curProcess = TowerMainModel:getCurStatusAndProgress()
	curProcess = math.floor(curProcess)
	self.txt_progress:setString(curProcess.."%")
	if status == FuncTower.COLLECTION_STATUS.TODO then
		self.isCharMoving = false
		if self.charModel then
			self.charModel:rePlayAction(false)
			self.charModel:setIsCharMoving(false)
		end

		self.isAccelerating = false
		self.btn_status:setBtnStr( GameConfig.getLanguage("#tid_tower_ui_120"),"txt_1")
		local leftTimes = TowerMainModel:getCollectionTimes()
		local maxTimes = FuncDataSetting.getDataByConstantName("TowerCollectionNum") or 3
		local str = leftTimes.."/"..maxTimes
		if leftTimes > 0  then
			str = "<color = 76AD59>"..str.."<->"
		else
			str = "<color = FF6633>"..str.."<->"
		end
		local leftTimesTips = GameConfig.getLanguageWithSwap("#tid_tower_ui_085",str)
		self.panel_bao22.rich_1:visible(true)
		self.panel_bao22.rich_1:setString(leftTimesTips)

		self.txt_leftT:visible(false)
		self.progressBar:setPercent(curProcess)
		self:unscheduleUpdate()

		local tips1 = GameConfig.getLanguageWithSwap("#tid_tower_UI_collection_1",TowerMainModel:getCollectionFloor())
		self.txt_status:setString(tips1)
	elseif status == FuncTower.COLLECTION_STATUS.DONE then
		echo("_________ 搜刮完成 !!!_____________")
		self.isCharMoving = false
		if self.charModel then
			self.charModel:rePlayAction(false)
			self.charModel:setIsCharMoving(false)
		end
		self.panel_bao22.rich_1:visible(false)

		self.isAccelerating = false
		self.btn_status:setBtnStr( GameConfig.getLanguage("#tid_tower_ui_121"),"txt_1")
		self.txt_leftT:visible(false)
		self.progressBar:setPercent(curProcess)
		self:processEndCfunc()
		self:unscheduleUpdate()

		local tips1 = GameConfig.getLanguageWithSwap("#tid_tower_UI_collection_3")
		self.txt_status:setString(tips1)
	else
		-- echo("_______ 搜刮中 ___________________")
		if not self.isCharMoving then
			self.isCharMoving = true
			self.charModel:resetIsPlayEmotion()
			self.charModel:moveToPoint({x= -250,y=-70}, self.charModel.charMovingSpeed)
		end
		if self.charModel then
			self.charModel:updateFrame()
		end
		self.panel_bao22.rich_1:visible(false)
	 	if not curProcess then
	 		return 
	 	end
	 	-- 设置显示正在搜刮第几层
	 	local maxPerfectFloor = TowerMainModel:getCollectionFloor()
		local handlingFloor = 1
		for i=maxPerfectFloor,1,-1 do
			if curProcess >= ((i-1)/maxPerfectFloor)*100 then
				handlingFloor = i 
				break
	 		end
		end
		local tips1 = GameConfig.getLanguageWithSwap("#tid_tower_UI_collection_2",handlingFloor)
		self.txt_status:setString(tips1)

		self.progressBar:setPercent(curProcess)
		local isTimeVisible = true
		local leftTime = TowerMainModel:getFinishTime() - TimeControler:getServerTime()
		local timeStr = TimeControler:turnTimeSec( leftTime,TimeControler.timeType_mmss )
		self.txt_leftT:setString(timeStr)
		self.txt_leftT:visible(isTimeVisible)
	end
end

-- 搜刮到事件或者奖励
function TowerCollectionView:findOneResult( event )
	if event and event.params then
		local data = event.params
		if data.type == FuncTower.COLLECTION_RESULT_TYPE.REWARD then
			self:updateCollectingReward()
		elseif data.type == FuncTower.COLLECTION_RESULT_TYPE.EVENT then
			self:updateSceneNpc(data)
		end
	end
end

-- 更新获得的奖励滚动条
function TowerCollectionView:updateCollectingReward()
	local foundResult = TowerMainModel:getFoundCollectingReward()
	dump(foundResult, "=====搜刮出新东东 更新获得的奖励滚动条=====")
	self.rewardScrollParams[1].data = foundResult or {}
	self.ScrollView.scroll_1:hideDragBar()
	self.ScrollView.scroll_1:cancleCacheView()
	self.ScrollView.scroll_1:styleFill(self.rewardScrollParams)
end

-- 更新搜刮场景npc
-- 传入数据则只创建相应事件的npc
-- 否则创建全部已经搜刮出来的事件的npc
function TowerCollectionView:updateSceneNpc( data )
	dump(data, "=====搜刮出事件 更新搜刮场景npc=====")
	if data and data.info then
		local eventId = data.info
		self:createOneNpc(eventId)
	else
		echo("___________ 更新npc ___________________")
		local allFoundEvents = TowerMainModel:getFoundCollectingEvent()
		dump(allFoundEvents, "allFoundEvents")

		-- 已经搜刮结束则取
		if not allFoundEvents or table.length(allFoundEvents)==0 then
			local collectionStatus = TowerMainModel:getCollectionStatus()
			if collectionStatus == FuncTower.COLLECTION_STATUS.DONE then
				local allEvents = TowerMainModel:towerCollection().events
				dump(allEvents, "== 搜刮完成 的数据allEvents")
				for eventId,v in pairs(allEvents) do
					allFoundEvents[eventId] = 0
				end
				dump(allFoundEvents, "== 搜刮完成 的数据allData")
			end
		end
		for eventId,handleOrNot in pairs(allFoundEvents) do
			local e,status = TowerMainModel:checkEventStatus(eventId)
			echo("______eventId,status________",eventId,status)
			if status == FuncTower.COLLECTION_EVENT_STATUS.DONE then
				if self.npcSpineVector[tostring(eventId)] then
					self.npcSpineVector[tostring(eventId)]:removeFromParent()
					self.npcSpineVector[tostring(eventId)] = nil
				end
			else
				self:createOneNpc(eventId)
			end
		end
	end
end

function TowerCollectionView:createOneNpc( eventId )
	if not self.npcSpineVector[tostring(eventId)] then
		local eventData = FuncTower.getCollectionEventDataByID(eventId)
		local npcId = eventData.spine
		self.npcSpineVector[tostring(eventId)] = self:createNpcSpineById(npcId)
		local numOfNpc = table.length(self.npcSpineVector)
		local pos = self.npcPosArr[numOfNpc]
		self.npcSpineVector[tostring(eventId)]:parent(self.sceneCtn,14-numOfNpc):pos(pos.x,pos.y)
		local node = display.newNode():addto(self.npcSpineVector[tostring(eventId)]):pos(-40,10) 
		node:setContentSize(cc.size(80,150))
		node:setTouchEnabled(true)
		node:setTouchedFunc(c_func(self.handleOneEvent,self,eventId))
		-- -- 点击区域测试代码
		-- local color = color or cc.c4b(255,0,0,120)
		-- local layer = cc.LayerColor:create(color)
		-- layer:setContentSize(node:getContentSize())
		-- node:addChild(layer)
	end
end
function TowerCollectionView:handleOneEvent( eventId )
	local collectStatus = TowerMainModel:getCollectionStatus()
	local isAutoJumpToNext = not (collectStatus == FuncTower.COLLECTION_STATUS.COLLECTING)
	WindowControler:showWindow("TowerCollectionEventView",eventId,isAutoJumpToNext)
end

-- 创建npcId spine动画
function TowerCollectionView:createNpcSpineById(npcId)
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)

	local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand

    local npcNode = nil
    local npcAnim = nil
    if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract"
        npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
        npcAnim:setScale(-0.7,0.7)
    end
    return npcAnim
end


function TowerCollectionView:gotoHandleEvents( event )
	local toHandleEvent = TowerMainModel:getToHandleEvent()
	local collectStatus = TowerMainModel:getCollectionStatus()
	local isAutoJumpToNext = not (collectStatus == FuncTower.COLLECTION_STATUS.COLLECTING)
	WindowControler:showWindow("TowerCollectionEventView",toHandleEvent,isAutoJumpToNext)
end

function TowerCollectionView:initData()
	-- TODO
end

function TowerCollectionView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_079"))
	self.UI_1.mc_1:visible(false)

	self.sceneCtn = self.panel_bao22.ctn_1
	self.txt_status = self.panel_bao22.panel_bao11.txt_1
	self.txt_progress = self.panel_bao22.panel_bao11.panel_1.txt_1
	self.txt_leftT = self.panel_bao22.panel_bao11.txt_green
	self.progressBar = self.panel_bao22.panel_bao11.panel_1.progress_1

	self.btn_status = self.panel_bao22.btn_sougua

	self:initScrollCfg()

	self:initSceneNPC()
	self:updateUI()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
end

function TowerCollectionView:initSceneNPC()
	local scenePng = FuncRes.iconTowerEvent("tower_img_souguachangjing")
	local sprite = display.newSprite(scenePng)
	self.sceneCtn:addChild(sprite,1)
	local xpos = 0
	local ypos = -50
	local zpos = 0

	local charSex = nil
	if PrologueUtils:showPrologue() then
		charSex = FuncChar.getCharSex(LoginControler:getLocalRoleId())
	else
		charSex = UserModel:sex()
	end
	self.charModel = TowerCharModelClazz.new(charSex)
	local playerSpine = GarmentModel:getCharGarmentSpine()
    self.charModel:initView(self.sceneCtn,playerSpine,xpos,ypos,zpos,{width=180,height=180})
    self.charModel:setViewScale(0.7)
    self.charModel:setZOrder(100)
    self.charModel:createAllAni( self )
    -- self.charModel:playEmotionFoundBox(_callBack)
    -- self.charModel:playEmotionSweat(_callBack)
    -- self.charModel:playEmotionAttack(_callBack)
-- -- ====================================================

	self.npcSpineVector = {} -- 场景立绘形象
	self.npcPosArr = {
		{x=100-26,y=-70},
		{x=170-26,y=-70},
		{x=240-26,y=-70},
		{x=310-26,y=-70},
		
		{x=100-26,y=-50},
		{x=170-26,y=-50},
		{x=240-26,y=-50},
		{x=310-26,y=-50},

		{x=100-26,y=-90},
		{x=170-26,y=-90},
		{x=240-26,y=-90},
		{x=310-26,y=-90},
	} -- 场景立绘站立的位置数组
	self:updateSceneNpc()
end

function TowerCollectionView:playerRuningForSearching( isRunning )
end
function TowerCollectionView:initScrollCfg()
	self.panel_bao22.UI_4:visible(false)
    -- 竖直滚动条
    local createItemFunc = function ( itemData )
		local itemView = UIBaseDef:cloneOneView(self.panel_bao22.UI_4)
		itemView:visible(true)
		self:setOneRewardData(itemData,itemView)
        return itemView
    end
    local updateItemFunc = function(itemData,itemView)
		self:setOneRewardData(itemData,itemView)
        return itemView
    end
    -- itemView参数配置
    self.rewardScrollParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-100,width = 100,height = 100},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 15,
	        offsetY = 10,
	        widthGap = -17,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }
end

function TowerCollectionView:setOneRewardData( itemData,itemView )
	-- dump(itemData, "一个奖励的数据 用于显示")
	if not itemData then
		return 
	end
	local isCoin = false
	local rewardArr = string.split(itemData,",")
	-- dump(rewardArr, "rewardArr===")
	local rewardId,rewardType,rewardNum,rewardStr
	if #rewardArr > 3 then
		rewardType = rewardArr[2]
		rewardId = rewardArr[3]
		rewardNum = rewardArr[4]
	elseif #rewardArr < 3 then
		rewardType = rewardArr[1]
		rewardNum = rewardArr[2] 
		rewardStr = rewardType..","..rewardNum
		isCoin = true
	else
		rewardType = rewardArr[1]
		rewardId = rewardArr[2]
		rewardNum = rewardArr[3] 
	end
	if not isCoin then
		rewardStr = rewardType..","..rewardId..","..rewardNum
	end
	local rewardUI = itemView
    rewardUI:visible(true)
    rewardUI:setResItemData({reward = rewardStr})
    rewardUI:showResItemName(false)
    FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,rewardStr,true,true)
end

function TowerCollectionView:initViewAlign()
	-- TODO
end

function TowerCollectionView:updateUI()
	local status,rewardData = TowerMainModel:getCollectionStatus()
	echo("____________status,rewardData______________",status,rewardData)
	self:updateViewByStatus( status,rewardData )
	self:updateSceneNpc()
	self:updatePrivilegesTxt()
end

-- 刷新搜刮进程 界面
function TowerCollectionView:updateViewByStatus( status,rewardData )
	local panel = self.panel_bao22.panel_bao11
	if tonumber(status) == FuncTower.COLLECTION_STATUS.TODO then
		local perfectFloor = TowerMainModel:getCollectionFloor()
		local tips1 = GameConfig.getLanguageWithSwap("#tid_tower_UI_collection_1",perfectFloor)
		self.txt_status:setString(tips1)
		local tips2 = GameConfig.getLanguage("#tid_tower_UI_collection_8")
		self.btn_status:setBtnStr( tips2,"txt_1")
		self.btn_status:setTap(c_func(self.startCollection, self))

		self.panel_bao22.mc_zx:showFrame(2)
		self.ScrollView = self.panel_bao22.mc_zx:getCurFrameView()
		self:initRewardShowView()

		self.txt_leftT:visible(false)

	elseif tonumber(status) == FuncTower.COLLECTION_STATUS.COLLECTING then
		local curCollectingFloor = 2
		local tips2 = GameConfig.getLanguage("#tid_tower_UI_collection_20")
		self.btn_status:setBtnStr( tips2,"txt_1")
		self.btn_status:setTap(c_func(self.toConfirmAcc, self))

		self.panel_bao22.mc_zx:showFrame(1)
		self.ScrollView = self.panel_bao22.mc_zx:getCurFrameView()

		self:updateCollectingReward()
		self:updateSceneNpc()
	elseif tonumber(status) == FuncTower.COLLECTION_STATUS.DONE then
		local tips1 = GameConfig.getLanguage("#tid_tower_UI_collection_3")
		local tips2 = GameConfig.getLanguage("#tid_tower_UI_collection_9")
		self.txt_status:setString(tips1)
		self.btn_status:setBtnStr( tips2,"txt_1")
		self.btn_status:setTap(c_func(self.getCollectionReward, self))

		self.panel_bao22.mc_zx:showFrame(1)
		self.ScrollView = self.panel_bao22.mc_zx:getCurFrameView()

		dump(rewardData, "搜刮完成的奖励数据 rewardData")
		rewardData = FuncCommon.countRewards(rewardData)
		-- dump(rewardData, "合并后搜刮完成的奖励数据 rewardData")
		self.rewardScrollParams[1].data = rewardData or {}
		self.ScrollView.scroll_1:hideDragBar()
		self.ScrollView.scroll_1:cancleCacheView()
		self.ScrollView.scroll_1:styleFill(self.rewardScrollParams)
	end
end

-- 初始化可能获得
function TowerCollectionView:initRewardShowView()
	local perfectFloor = TowerMainModel:getCollectionFloor()
	local configCollectData = FuncTower.getCollectionDataByID(perfectFloor)
	local definiteReward = configCollectData.rewardSure 
	local possibilyReward1 = FuncItem.getRewardData(configCollectData.rewardUnsureNomal) 
	local possibilyReward2 = FuncItem.getRewardData(configCollectData.rewardUnsureRare) 
	-- dump(definiteReward, "definiteReward")
	-- dump(possibilyReward1, "possibilyReward1")
	-- dump(possibilyReward2, "possibilyReward2")

	self.ScrollView.mc_1:showFrame(#definiteReward)
	local contentView = self.ScrollView.mc_1:getCurFrameView()
	for k,v in pairs(definiteReward) do
		self:setOneRewardData( v,contentView["UI_"..k] )
	end

	local possibilyReward = {}
	table.array_merge(possibilyReward,possibilyReward1.info)
	table.array_merge(possibilyReward,possibilyReward2.info)
	-- dump(possibilyReward, "可能获得")
	self.rewardScrollParams[1].data = possibilyReward 
	self.ScrollView.scroll_1:hideDragBar()
	self.ScrollView.scroll_1:cancleCacheView()
	self.ScrollView.scroll_1:styleFill(self.rewardScrollParams)
end
-- 开始搜刮
function TowerCollectionView:startCollection()
	local leftTimes = TowerMainModel:getCollectionTimes()
	if leftTimes < 1 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_082"))
	else
		local function callBack( serverData )
			-- dump(serverData, "============= 搜刮奖励 ==================")
			if serverData.result then
				local data = serverData.result.data
				TowerMainModel:updateData(data)
				self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
				TowerMainModel:initCollectingData()
				self:updateViewByStatus( FuncTower.COLLECTION_STATUS.COLLECTING,data )
				TowerMainModel:checkCollectionBtnRedPoint()
			end
		end
		local params = {}
		TowerServer:startCollection(params,callBack)
	end
end

function TowerCollectionView:toConfirmAcc()
	WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.ACCELERATE_CONFIRM)
end
-- 加速搜刮
function TowerCollectionView:accelerateCollection()
	local params = {}
	local function callBack( serverData )
		if serverData.error then
			return 
		else
			local data = serverData.result.data
			-- dump(data, "pppppppp 加速返回")
			TowerMainModel:updateData(data)
			TowerMainModel:cancelAllTimers()
			-- TowerMainModel:checkCollectionBtnRedPoint()
		end
	end
	if not self.isAccelerating then
		echo("________ 发送 加速请求 ________________")
		self.btn_status:setTap(c_func(self.startCollection, self))
		TowerServer:collectionAccelerate(params,callBack)
		self.isAccelerating = true
	end
end

-- 搜刮完成
-- 领取奖励
-- 若有待处理事件则先处理事件
function TowerCollectionView:getCollectionReward( ... )
	local toHandleEvent = TowerMainModel:getToHandleEvent()
	if toHandleEvent then
		local viewType = FuncTower.VIEW_TYPE.RECONFIRM_TIPS_TO_HANDLE_EVENTS
		local pararms = {}
		WindowControler:showWindow("TowerChooseTipsView",viewType,pararms)
		return 
	end
	echo("_______ 领取搜刮奖励 ___________")
	local allCollectionRewards = table.deepCopy(TowerMainModel:getHasFinishReward())
	local function callBack( serverData )
		if serverData.result then
			local data = serverData.result.data
			-- dump(data, "领取搜刮奖励返回,需弹窗展示")
			TowerMainModel:updateData(data)
			WindowControler:showWindow("RewardSmallBgView", allCollectionRewards)
			-- 这里给一条消息 让主界面搜刮红点做更新
			TowerMainModel:checkCollectionBtnRedPoint()
			-- EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED)
			self:updateViewByStatus( FuncTower.COLLECTION_STATUS.TODO )
			self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
		end
	end
	local params = {}
	TowerServer:receiveCollectionRewards(params,callBack)
end

function TowerCollectionView:processEndCfunc( )
	echo("_________ 搜嘎嘎进度完成 !!! _________")
	TowerMainModel:cancelAllTimers()
	-- self:updateUI()
	local status,rewardData = TowerMainModel:getCollectionStatus()
	dump(status, "status")
	dump(rewardData, "rewardData")
	self:updateViewByStatus( FuncTower.COLLECTION_STATUS.DONE,TowerMainModel:getHasFinishReward() )
	self:updateSceneNpc()
	TowerMainModel:checkCollectionBtnRedPoint()
end

function TowerCollectionView:updatePrivilegesTxt()
	local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.switch_collection_needNoWait 
    local curTime = TimeControler:getServerTime()
    -- local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition(privilegeData,additionType,curTime,fromSys)

    if isHas then
    	self.panel_bao22.panel_bao11.mc_1:showFrame(2)
    	self.panel_bao22.panel_bao11.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_130"))
    else
    	self.panel_bao22.panel_bao11.mc_1:showFrame(1)
    	self.panel_bao22.panel_bao11.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_131"))
    end
end

function TowerCollectionView:deleteMe()
	TowerCollectionView.super.deleteMe(self);
end

function TowerCollectionView:press_btn_close()
	self:startHide()
end

return TowerCollectionView;
