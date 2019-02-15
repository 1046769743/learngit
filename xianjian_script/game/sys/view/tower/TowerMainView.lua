--[[
	Author: caocheng
	Date:2017-07-25
	Description: 锁妖塔主界面
]]

local TowerMainView = class("TowerMainView", UIBase);

function TowerMainView:ctor(winName)
    TowerMainView.super.ctor(self, winName)
    self.rewardBoxIdx = {1,3,5,7,9,10} 
end

function TowerMainView:loadUIComplete()
	self:setViewVisible(false)
	local initMainView = function()
		self:setViewVisible(true)
		self:registerEvent()
		self:initData()
		self:initViewAlign()
		self:initView()
		self:updateUI()
		self:disabledUIClick()
		self:delayCall(c_func(self.isHasShopBuff),0.4)

		self:updateFloorBoxBar()
	end
	
	-- 进入锁妖塔主界面时，判断是否拉取了锁妖塔数据
	-- 如果没有，先拉取数据再初始化界面
	if not TowerMainModel:hasUpdateServerData() then
		self:checkTowerData(c_func(initMainView))
	else
		initMainView()
	end
end 

function TowerMainView:setViewVisible(visible)
	local arr = self._root:getChildren()
	for k, v in pairs(arr) do
		v:setVisible(visible)
	end
end

function TowerMainView:checkTowerData(callBack)
	TowerControler:getMapData(callBack)
end

function TowerMainView:registerEvent()
	TowerMainView.super.registerEvent(self);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self))
	
	EventControler:addEventListener(TowerEvent.TOWEREVENT_RESET_TOWER,self.resetMainView,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_SWEEP_TOWER,self.onConfirmToSweepTower,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_COLLECT_TOWER,self.onConfirmToCollectTower,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CLOSE_GETREWARDVIEW,self.openSweepShop,self)
	-- EventControler:addEventListener(TowerEvent.TOWEREVENT_SUCCESS_GETMAINREWARDVIEW,self.openRewaridBox,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_UPDATE_TESETTOWERTYPE,self.updataNowFloorView,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_TOWERMAPVIEW,self.enterTowerGridMap,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED,self.updateCollectionRedPoint,self)

	-- 领取宝箱 刷新左侧滚动条
	-- 自动打开格子(完美通关) 刷新左侧滚动条
	EventControler:addEventListener(TowerEvent.TOWEREVENT_SUCCESS_GETMAINREWARDVIEW,self.jianting,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_AUTO_OPEN_LEFT_GRIDS,self.jianting,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE,self.jianting,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_HAS_CHECK_UNLOCK_GOODS,self.jianting,self)

	-- 打开了一个新界面
	EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_CONFIRM_TO_CLICK_LOCK,self.confirmToClickLock,self)
end

function TowerMainView:confirmToClickLock( event )
	-- WindowControler:popWindow("TowerMainView")
	local mapView = WindowControler:getWindow( "TowerMapView" )
	if mapView then
		mapView:clickClose()
	end
	self:arriveNewStage()
end

function TowerMainView:updateCollectionRedPoint( event )
	local isShow = false

	if event and event.params then
		isShow = event.params.isShow
	else
		isShow = TowerMainModel:checkCollectionBtnRedPoint(true)
	end
	-- self.btn_3:visible(true)
    if TowerMainModel:isInNewGuide() then
    	isShow = false
    end
	self.btn_3:getUpPanel().panel_red:visible(isShow)
end

function TowerMainView:onUIShowComp(e)
	echo("TowerMainView----------锁妖塔主界面")
	if WindowControler:checkCurrentViewName("TowerMainView") then 
        return
    end 

    local targetUI = e.params.ui
    if targetUI:checkIsFullUI()  then
        self:visible(false)
    end
end

function TowerMainView:onBecomeTopView()
	self:visible(true)
	-- if TowerMainModel.isAutoClickLock then
	-- 	local data = table.deepCopy(TowerMainModel.isAutoClickLock)
	-- 	TowerMainModel.isAutoClickLock = nil
	-- 	if self.lockBtn then
	-- 		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_tower_ui_081",data.nextfloor,data.needLevel))
	-- 	end
	-- end
end

-- 达到新阶段
function TowerMainView:arriveNewStage(_nextfloor)
	-- 判断能否进入下一层
	echo("__________________nextfloor",_nextfloor)
	local nextfloor = _nextfloor or (TowerMainModel:getCurrentFloor() + 1)
	local isLock,needLevel,isJump = TowerMainModel:checkIsCanEnterFloor( nextfloor )
	if isLock then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_tower_ui_081",nextfloor,needLevel))
	else
		echo("z_________________找到传送门并判断其状态是否为已探索 _____________________")
		local mapData = TowerMapModel:getTowerMapData(towerFloor)
		-- dump(mapData, "=====================desciption-====================================")
		local isArrive = false
		for x,rowData in pairs(mapData) do
			for y,v in pairs(rowData) do
				local info = v.info
				if info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.ENDPOINT then
					local endPointStatus = info[FuncTowerMap.GRID_BIT.STATUS]
					if endPointStatus == FuncTowerMap.GRID_BIT_STATUS.EXPLORED 
						or endPointStatus == FuncTowerMap.GRID_BIT_STATUS.CLEAR then
						if not isJump then
							isArrive = true
							self:playLockBreakAni()
						end
						break
					end
				end
			end
		end
		if not isArrive then
			WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_tower_ui_115",TowerMainModel:getCurrentFloor()))
		end
	end
end

-- 播放开锁动画
-- 之后回到mapview播放换层动画
function TowerMainView:playLockBreakAni()
	local function callback()
		-- local mapView = WindowControler:getWindow( "TowerMapView" )
		-- if mapView then
		-- 	WindowControler:popWindow("TowerMapView")
		-- else
		-- 	TowerMainView:enterTowerGridMap()
		-- end
		TowerMainView:enterTowerGridMap()
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CONFIRM_TO_ENTER_NEXT_FLOOR)
	end
	local animation = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_kaisuo", self.lockBtn, false, callback) 
	animation:pos(121,-115)
end

function TowerMainView:initData()
	-- 左侧进度条宝箱 宝箱的状态
	self.boxStatusType = FuncTower.boxStatusType

	-- "扫荡"类型
	self.sweepType = {
		SWEEP = 1,     -- 扫荡
		COLLECT = 2,   -- 搜刮
	}

	-- 第几层的语言映射
	self.languageMap = {
        "一","二","三","四","五",
        "六","七","八","九","十",
        "十一","十二","十三","十四","十五",
        "十六","十七","十八","十九","二十",
	}

	-- 
	self.currentFloor = TowerMainModel:getCurrentFloor()
	self.historyFloor = TowerMainModel:getMaxClearFloor()
	self.perfectFloor = TowerMainModel:getPerfectFloor()
	self.floorReward = TowerMainModel:getTowerFloorReward()
end

function TowerMainView:initView()
	-- local isLock,needLevel = TowerMainModel:checkIsCanEnterFloor( self.currentFloor )
	-- if isLock then
	-- 	self.panel_2.mc_3:showFrame(5)
	-- else
		self.panel_2.mc_3:showFrame(2)
		local btnView = self:createUIArmature("UI_suoyaota","UI_suoyaota_zhantexiao",self.panel_2.mc_3.currentView.btn_zhan,true, GameVars.emptyFunc)
	    btnView:pos(80,-91)
	-- end

	self:initFloorDoor(self.currentFloor,self.historyFloor)
	self.btn_rule:setTouchedFunc(c_func(self.enterRuleView, self))
	
	self.btn_1:getUpPanel().panel_red:visible(false)
	self.btn_2:getUpPanel().panel_red:visible(false)
	self.btn_1:setTouchedFunc(c_func(self.enterTowerShop,self))
	-- self.btn_2:setTouchedFunc(c_func(self.enterRaking,self))

	-- 初始化搜刮红点
	-- self:updateCollectionRedPoint()
	self.btn_3:getUpPanel().panel_red:visible(false)
	TowerMainModel:checkCollectionBtnRedPoint()

	self.btn_2:visible(false)
	-- self.btn_3:visible(false)
	self:setResetButton()

    self:createBoxAni()

    local size = self.scale9_sp:getContainerBox()
    self.scale9_sp:setScaleY(GameVars.height/size.height)
    ChatModel:setPlayerIcon(self.panel_1.panel_2.panel_2.ctn_1,UserModel:head(),UserModel:avatar())
end

function TowerMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop);   
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop); 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.MiddleBottom); 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_reset,UIAlignTypes.RightBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_mainbtn,UIAlignTypes.RightBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_rule, UIAlignTypes.LeftTop);

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_sp,UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1,UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2,UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3,UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.Left);
end

function TowerMainView:updateUI()
	self:progressByReward()
end

function TowerMainView:resetTips() 
	WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_034"))
end

function TowerMainView:progressByReward()
	if true then
		return 
	end
	local percentNum = (457+self.panel_1["txt_"..self.historyFloor]:getPositionY())/457
	self.panel_1.panel_1.progress_1:setDirection(ProgressBar.d_u)
	self.panel_1.panel_1.progress_1:setPercent(percentNum*100)
	self.panel_1.panel_2:setPositionY(self.panel_1["txt_"..self.historyFloor]:getPositionY())
end

function TowerMainView:initFloorDoor(nowCurrentFloor,nowHistoryFloor)
	self.panel_2.mc_0:visible(true)
	self.panel_2.mc_1:visible(true)
	self.panel_2.mc_2:visible(true)
	self.panel_2.mc_3:visible(true)
	local floorStatus = {
		lock_small = 1,
		can_enter = 2,
		unlock = 3,
		tower_roof = 4,
		lock_big = 5,
	}

	-- 显示三个楼层的状态
	local maxTowerFloor = table.length(FuncTower.getTowerCfgData())
	local currentFloor = nowCurrentFloor
	local nowHistoryFloor = nowHistoryFloor
	if tonumber(currentFloor) == tonumber(nowHistoryFloor) and tonumber(currentFloor)+1 < maxTowerFloor then
		self.panel_2.mc_1:showFrame(floorStatus.lock_small)
		self.panel_2.mc_2:showFrame(floorStatus.unlock)
	elseif tonumber(currentFloor)+1 == tonumber(nowHistoryFloor) and tonumber(currentFloor)+1 < maxTowerFloor then
		self.panel_2.mc_1:showFrame(floorStatus.unlock)
		self.panel_2.mc_2:showFrame(floorStatus.unlock)
	elseif tonumber(currentFloor)+2 <= tonumber(nowHistoryFloor) and tonumber(currentFloor)+2 <= maxTowerFloor then
		self.panel_2.mc_1:showFrame(floorStatus.unlock)
		self.panel_2.mc_2:showFrame(floorStatus.unlock)
	elseif tonumber(currentFloor)+3 <= tonumber(nowHistoryFloor) and tonumber(currentFloor)+3 <= maxTowerFloor then
		self.panel_2.mc_1:showFrame(floorStatus.unlock)
		self.panel_2.mc_2:showFrame(floorStatus.unlock)
		self.panel_2.mc_0:showFrame(floorStatus.unlock)
	else
		self.panel_2.mc_1:showFrame(floorStatus.lock_small)
		self.panel_2.mc_2:showFrame(floorStatus.lock_small)	
	end

	-- 等级解锁大锁
	echo("_________等级解锁大锁___________")
	-- TowerMainModel:checkIsArriveNextStage(_currentFloor)
	local isLock = TowerMainModel:checkIsCanEnterFloor(nowCurrentFloor+1)
	local isShowNewStageLock = TowerMainModel:checkIsArriveNextStage( nowCurrentFloor )
	if isShowNewStageLock or isLock then
		self.panel_2.mc_2:showFrame(floorStatus.lock_big)
		self.lockBtn = self.panel_2.mc_2:getCurFrameView().panel_suo
		self.lockBtn:setTouchedFunc(c_func(self.arriveNewStage,self, nowCurrentFloor + 1))
		local animation = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_suo", self.lockBtn, true, GameVars.emptyFunc) 
		animation:pos(111,-95)
	else
		isLock = TowerMainModel:checkIsCanEnterFloor(nowCurrentFloor+2)
		isShowNewStageLock = TowerMainModel:checkIsArriveNextStage( nowCurrentFloor+1 )
		if isShowNewStageLock or isLock then
			self.panel_2.mc_1:showFrame(floorStatus.lock_big)
			self.lockBtn = self.panel_2.mc_1:getCurFrameView().panel_suo
			self.lockBtn:setTouchedFunc(c_func(self.arriveNewStage,self, nowCurrentFloor + 2))
			local animation = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_suo", self.lockBtn, true, GameVars.emptyFunc) 
			animation:pos(111,-95)
		else
			isLock = TowerMainModel:checkIsCanEnterFloor(nowCurrentFloor+3)
			isShowNewStageLock = TowerMainModel:checkIsArriveNextStage( nowCurrentFloor+2 )
			if isShowNewStageLock or isLock then
				self.panel_2.mc_0:showFrame(floorStatus.lock_big)
				self.lockBtn = self.panel_2.mc_0:getCurFrameView().panel_suo
				self.lockBtn:setTouchedFunc(c_func(self.arriveNewStage,self, nowCurrentFloor + 3))
				local animation = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_suo", self.lockBtn, true, GameVars.emptyFunc) 
				animation:pos(111,-95)
			end
		end
	end

	-- 显示第几层
	local strCeng = "层"
	if tonumber(currentFloor+1) <= maxTowerFloor then
		self.panel_2.mc_2.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+1))..strCeng)
	end
	if tonumber(currentFloor+2) <= maxTowerFloor then
		self.panel_2.mc_1.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+2))..strCeng)
	end
	if tonumber(currentFloor+3) <= maxTowerFloor then
		self.panel_2.mc_0.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+3))..strCeng)
	end
	self.panel_2.mc_3.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor))..strCeng)

	-- 显示楼顶
	if tonumber(currentFloor) == tonumber(maxTowerFloor)-1 then
		self.panel_2.mc_1:showFrame(floorStatus.tower_roof)
		self.panel_2.mc_0:visible(false)
	elseif tonumber(currentFloor) == tonumber(maxTowerFloor) then
		self.panel_2.mc_2:showFrame(floorStatus.tower_roof)
		self.panel_2.mc_1:visible(false)
		self.panel_2.mc_0:visible(false)
	elseif tonumber(currentFloor) == tonumber(maxTowerFloor)-1 then
		self.panel_2.mc_0:showFrame(floorStatus.tower_roof)
	end	
end

function TowerMainView:enterTowerGridMap()
	local mapView = WindowControler:getWindow( "TowerMapView" )
	if mapView then
		WindowControler:popWindow("TowerMapView")
	else
		local nowTowerFloor = TowerMainModel:getCurrentFloor()
		WindowControler:showWindow("TowerMapView",nowTowerFloor,true)
	end

	-- local nowTowerFloor = TowerMainModel:getCurrentFloor()
	-- WindowControler:showWindow("TowerMapView",nowTowerFloor,true)
end

function TowerMainView:enterRaking() 
	WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
end


function TowerMainView:enterWorldBoss()
	WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
	-- WindowControler:showWindow("TowerWorldBossView")
end

function TowerMainView:enterTowerShop()
	-- WindowControler:showTips("功能未开启")
	 WindowControler:showWindow("ShopView",FuncShop.SHOP_TYPES.TOWER_SHOP)
end

function TowerMainView:resetMainUI()
	WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.RESER_VIEW)
end


function TowerMainView:enterRewardView(floorNum,isShopBox,boxStatus)
	WindowControler:showWindow("TowerMainRewardView",floorNum,isShopBox,boxStatus)
end

function TowerMainView:openSweepShop(event)
	local data = nil
	if event and event.params and event.params.data then
		data = event.params.data
		-- dump(data, "desciption")
	end
	if data then
		WindowControler:showWindow("TowerMapShopView",data.shopId,cc.p(data.x,data.y))
	else
		WindowControler:showWindow("TowerSweepShopView")
	end
end

function TowerMainView:hasSweepTimes()
	WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.SWEEP_TIPS_VIEW)
end



-- ===================================================================================
-- 执行扫荡逻辑
-- ===================================================================================
-- 播放扫荡动画并发送扫荡请求
function TowerMainView:onConfirmToSweepTower()
 	local tempNum = 1
 	if self.sweepUIAnimation == nil then
 		self.sweepUIAnimation = self:createUIArmature("UI_suoyaota","UI_suoyaota_saodang",self.panel_2,false,GameVars.emptyFunc)
 		self.sweepUIAnimation:pos(255,-90)
 		self.sweepUIAnimation:visible(false)
 	end
 	self.mcFloorOne = UIBaseDef:cloneOneView(self.panel_2.mc_3)
 	self.mcFloorTwo = UIBaseDef:cloneOneView(self.panel_2.mc_2)
 	self.mcFloorThree = UIBaseDef:cloneOneView(self.panel_2.mc_1)
 	self.mcFloorFour = UIBaseDef:cloneOneView(self.panel_2.mc_0)
 	FuncArmature.changeBoneDisplay(self.sweepUIAnimation,"ef",self.mcFloorOne)
 	FuncArmature.changeBoneDisplay(self.sweepUIAnimation,"sfs",self.mcFloorTwo)
 	FuncArmature.changeBoneDisplay(self.sweepUIAnimation,"af",self.mcFloorThree)
 	FuncArmature.changeBoneDisplay(self.sweepUIAnimation,"vd",self.mcFloorFour)

 	self.panel_2.mc_3:visible(false)
 	self.panel_2.mc_2:visible(false)
 	self.panel_2.mc_1:visible(false)
 	self.panel_2.mc_0:visible(false)

 	self:playSweepAnimation(tempNum)
end
-- 递归播放扫荡升层动画
-- 完毕之后发送扫荡请求
function TowerMainView:playSweepAnimation(hasAnimationNum)
	local nowHighFloor = TowerMainModel:getPerfectFloor()
	
	if hasAnimationNum > nowHighFloor then
 		self:resumeUIClick()
 		self.panel_2.mc_3:visible(true)
	 	self.panel_2.mc_2:visible(true)
	 	self.panel_2.mc_1:visible(true)
	 	self.panel_2.mc_0:visible(true)
 		TowerServer:sweepTower(c_func(self.sweepTowerCallback,self))
 		return
 	else
 		self:disabledUIClick()
 		self.sweepUIAnimation:visible(true)
    	self.sweepUIAnimation:startPlay(true,true)
    	self.sweepUIAnimation:doByLastFrame(false,true,c_func(self.playSweepAnimation,self,hasAnimationNum+1))
 		self:initCloneFloorDoor(hasAnimationNum,nowHighFloor)
 		self.mcFloorOne:setPositionY(0)
 		self.mcFloorTwo:setPositionY(0)
 		self.mcFloorThree:setPositionY(0)
 		self.mcFloorFour:setPositionY(0)
 		FuncArmature.setArmaturePlaySpeed(self.sweepUIAnimation,0.8)
 	end
end
-- 扫荡请求发送后 回调
function TowerMainView:sweepTowerCallback(event)
	if event.error then 
		local errorInfo= event.error
		if tonumber(errorInfo.code) == 260901 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_037")) 
 		end	
 		if tonumber(errorInfo.code) == 260902 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_038"))
 		end	
 		if tonumber(errorInfo.code) == 261101 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_039"))
 		end	
	else		
		-- 扫荡成功，重新加载数据
		if TowerConfig.SHOW_TOWER_DATA then
			dump(event.result.data, "扫荡锁妖塔!!!!返回的数据 === ")
		end
		TowerMainModel:reLoadTowerData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLOSE_GETREWARDVIEW)
 		self:resetMainView()
	end
end

function TowerMainView:onConfirmToCollectTower()
	self:enterCollectionView()
end

-- 重设主界面
function TowerMainView:resetMainView()
	-- 重置npc 劫财劫色数据
    local _params = {}
    TowerMainModel:saveNPCRobberRobData( _params )
    
	self:initData()
	self:initFloorDoor(self.currentFloor,self.historyFloor)
	self:progressByReward()
	self:setResetButton()
	-- self:updateCollectionRedPoint()
	self.btn_3:getUpPanel().panel_red:visible(false)
	TowerMainModel:checkCollectionBtnRedPoint()
end


-- ===================================================================================
-- 设置重置按钮
-- ===================================================================================
-- 若未进入锁妖塔 则不需重置
function TowerMainView:setResetButton()
	local nowResetType = TowerMainModel:getResetType() 
	-- 显示重置按钮状态
	local leftResetTimes = TowerMainModel:getTowerNum()   -- 获取剩余重置次数
	echo("_____leftResetTimes_______",leftResetTimes)
	-- 未开打不需重置,已重置无剩余重置次数,有重置次数
	if tostring(nowResetType) == FuncTower.towerResetStatus.HAVE_BEEN_RESET
		or tostring(nowResetType) == FuncTower.towerResetStatus.NOT_INVOLVED then
		self.panel_reset.btn_1:setTouchedFunc(c_func(self.resetTips,self))
		FilterTools.setGrayFilter( self.panel_reset.btn_1 )
		self.panel_reset.panel_red:visible(false)
	elseif leftResetTimes == 0  then
		FilterTools.setGrayFilter( self.panel_reset.btn_1 )
		self.panel_reset.btn_1:setTouchedFunc(c_func(self.resetNumTips,self))
		self.panel_reset.panel_red:visible(false)
	else
		FilterTools.clearFilter( self.panel_reset.btn_1 )
		self.panel_reset.btn_1:setTouchedFunc(c_func(self.resetMainUI,self))

		if TowerMainModel:isInNewGuide() then
			self.panel_reset.panel_red:visible(false)
		else
			self.panel_reset.panel_red:visible(true)
		end
	end

	-- 显示扫荡按钮状态 
	if tostring(nowResetType) == FuncTower.towerResetStatus.HAVE_BEEN_RESET then	
		-- 已经有完美通关层 可扫荡 可搜刮
		if self.perfectFloor >= 1 then
			self.mc_mainbtn.currentView.btn_1:setTouchedFunc(c_func(self.enterSweepReconfirmView,self,self.sweepType.SWEEP))
			if TowerMainModel:isInNewGuide() then
				self.mc_mainbtn.currentView.panel_hongdian:visible(false)
			else
				self.mc_mainbtn.currentView.panel_hongdian:visible(true)
			end
			FilterTools.clearFilter(self.mc_mainbtn.currentView.btn_1)
			self.panel_2.mc_3.currentView.btn_zhan:setTouchedFunc(c_func(self.hasSweepTimes,self))
			echo("___________1111111111111111________________")
			local collectionFloor = TowerMainModel:getCollectionFloor()
			if collectionFloor > 0 then
				self.btn_3:visible(true)
				self.btn_3:setTouchedFunc(c_func(self.onConfirmToCollectTower, self))
			else
				self.btn_3:visible(false)
			end
		-- 没有完美通关层 不可扫荡 不可搜刮
		else
			self.mc_mainbtn.currentView.panel_hongdian:visible(false)
			self.mc_mainbtn.currentView.btn_1:setTouchedFunc(c_func(self.needToPerfectAtleastOneFloorTips,self,self.sweepType.SWEEP))
			FilterTools.setGrayFilter(self.mc_mainbtn.currentView.btn_1)
			self.panel_2.mc_3.currentView.btn_zhan:setTouchedFunc(c_func(self.enterTowerGridMap,self))
			-- self.btn_3:setTouchedFunc(c_func(self.needToPerfectAtleastOneFloorTips, self,self.sweepType.COLLECT))	
			self.btn_3:visible(false)
		end	
	else
	-- 未开始攻略,不可扫荡,不可搜刮
	-- 已经开打,不可扫荡,不可搜刮
		self.mc_mainbtn.currentView.btn_1:setTouchedFunc(c_func(self.canNotSweepTips,self,self.sweepType.SWEEP))
		FilterTools.setGrayFilter(self.mc_mainbtn.currentView.btn_1)
		self.mc_mainbtn.currentView.panel_hongdian:visible(false)
		self.panel_2.mc_3.currentView.btn_zhan:setTouchedFunc(c_func(self.enterTowerGridMap,self))	
		-- self.btn_3:setTouchedFunc(c_func(self.canNotSweepTips, self,self.sweepType.COLLECT))
		-- self.btn_3:setTouchedFunc(c_func(self.canNotSweepTips, self,self.sweepType.COLLECT))

		if tostring(nowResetType) == FuncTower.towerResetStatus.NOT_INVOLVED then
			self.btn_3:visible(false)
		else
			local collectionFloor = TowerMainModel:getCollectionFloor()
			if collectionFloor > 0 then
				self.btn_3:visible(true)
				self.btn_3:setTouchedFunc(c_func(self.onConfirmToCollectTower, self))
			else
				self.btn_3:visible(false)
			end
		end	
	end
	self.panel_reset.panel_cishu:visible(false)
	-- self.panel_reset.panel_cishu.txt_1:setString(leftResetTimes)
end	

-- 进入扫荡或者搜刮确认界面
function TowerMainView:enterSweepReconfirmView(sweepType)
	if sweepType == self.sweepType.SWEEP then
		WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.SWEEP_VIEW)
	elseif sweepType == self.sweepType.COLLECT then
		-- WindowControler:showWindow("TowerCollectionView")
	end
end

-- 至少完美通关一层 提示
function TowerMainView:needToPerfectAtleastOneFloorTips(sweepType)
	if sweepType == self.sweepType.SWEEP then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_041"))
	elseif sweepType == self.sweepType.COLLECT then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_073"))
	end
end

-- 不能扫荡 不能搜刮
function TowerMainView:canNotSweepTips(sweepType)
	local resetStatus = TowerMainModel:getResetType()
	if sweepType == self.sweepType.SWEEP then
		if tostring(resetStatus) == FuncTower.towerResetStatus.NOT_INVOLVED then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_035"))
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_036")) 
		end	
	-- elseif sweepType == self.sweepType.COLLECT then
	-- 	if tostring(resetStatus) == FuncTower.towerResetStatus.NOT_INVOLVED then
	-- 		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_069"))
	-- 	else
	-- 		if TowerMainModel:getPerfectFloor() > 0 then
	-- 			self:onConfirmToCollectTower()
	-- 		else
	-- 			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_073")) 
	-- 		end
	-- 	end	
	end
end

-- 玩法规则界面
function TowerMainView:enterRuleView()
	WindowControler:showWindow("TowerRuleView")
end

-- 进入搜刮界面
function TowerMainView:enterCollectionView()
	local collectionFloor = TowerMainModel:getCollectionFloor()
	if collectionFloor > 0 then
		WindowControler:showWindow("TowerCollectionView")
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_103"))
	end
end

function TowerMainView:createBoxAni()
	if true then
		return 
	end
	local realBoxFloor = self.historyFloor 
	for i = 1,#self.rewardBoxIdx do
		 if self.rewardBoxIdx[i] <= realBoxFloor then
		 	-- 已经领取的宝箱
		 	if self.floorReward and self:checkKey(self.floorReward,self.rewardBoxIdx[i]) then
        		self.panel_1["panel_box"..self.rewardBoxIdx[i]].mc_box1:visible(true)
        		self.panel_1["panel_box"..self.rewardBoxIdx[i]].ctn_1:removeAllChildren()
            	self.panel_1["panel_box"..self.rewardBoxIdx[i]].mc_box1:showFrame(2)
            else
            	local rewardUI = UIBaseDef:cloneOneView(self.panel_1["panel_box"..self.rewardBoxIdx[i]].mc_box1)
            	self.panel_1["panel_box"..self.rewardBoxIdx[i]].mc_box1:visible(false)

            	local ctn = self.panel_1["panel_box"..self.rewardBoxIdx[i]].ctn_1
            	ctn:removeAllChildren()
            	local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctn, false, GameVars.emptyFunc)
            	FuncArmature.changeBoneDisplay(anim,"node",rewardUI)
            	anim:setPosition(-2,8)
	    		anim:startPlay(true)
	    		rewardUI:setTouchedFunc(c_func(self.enterRewardView,self,self.rewardBoxIdx[i]))
            end   	
    	end
		self.panel_1["panel_box"..self.rewardBoxIdx[i]].mc_box1:setTouchedFunc(c_func(self.enterRewardView,self,self.rewardBoxIdx[i]))
	end
end	

function TowerMainView:checkKey(tableData,keyValue)
	for k,v in pairs(tableData) do
		if tonumber(k) == tonumber(keyValue) then
			return true
		end
	end
	return false
end


function TowerMainView:isHasShopBuff()
	local nowMapShopType = TowerMainModel:checkMapShop()
	local shopBuffData = TowerMainModel:getAllShopsBuff()
	if nowMapShopType and shopBuffData and table.length(shopBuffData)~= 0 then
	 	-- WindowControler:showWindow("TowerMapShopView",nil,{},true)
	 end
	 self:resumeUIClick()
end

function TowerMainView:openRewaridBox(event)
	-- self:initData()
	-- self:createBoxAni()
	self.panel_1.scroll_1:refreshCellView(1)
end

function TowerMainView:initCloneFloorDoor(nowCurrentFloor,nowHistoryFloor)
	local maxTowerFloor = table.length(FuncTower.getTowerCfgData())
	local currentFloor = nowCurrentFloor
	local nowHistoryFloor = nowHistoryFloor
	self.mcFloorOne:showFrame(2)
	if tonumber(currentFloor) == tonumber(nowHistoryFloor) and tonumber(currentFloor)+1 < maxTowerFloor then
		self.mcFloorThree:showFrame(1)
		self.mcFloorTwo:showFrame(1)
	elseif tonumber(currentFloor)+1 == tonumber(nowHistoryFloor) and tonumber(currentFloor)+1 < maxTowerFloor then
		self.mcFloorThree:showFrame(1)
		self.mcFloorTwo:showFrame(3)
	elseif tonumber(currentFloor)+2 <= tonumber(nowHistoryFloor) and tonumber(currentFloor)+2 <= maxTowerFloor then
		self.mcFloorThree:showFrame(3)
		self.mcFloorTwo:showFrame(3)
	elseif tonumber(currentFloor)+3 <= tonumber(nowHistoryFloor) and tonumber(currentFloor)+3 <= maxTowerFloor then
		self.mcFloorThree:showFrame(3)
		self.mcFloorTwo:showFrame(3)
		self.mcFloorFour:showFrame(3)
	else
		self.mcFloorThree:showFrame(1)
		self.mcFloorTwo:showFrame(1)	
	end
	
	local strCeng = "层"
    if tonumber(currentFloor) <= maxTowerFloor then
		self.mcFloorOne.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor))..strCeng)
	end
	if tonumber(currentFloor+1) <= maxTowerFloor then
		self.mcFloorTwo.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+1))..strCeng)
	end
	if tonumber(currentFloor+2) <= maxTowerFloor then
		self.mcFloorThree.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+2))..strCeng)
	end
	if tonumber(currentFloor+3) <= maxTowerFloor then
		self.mcFloorFour.currentView.txt_ceng:setString(Tool:transformNumToChineseWord(tonumber(currentFloor+3))..strCeng)
	end

	if tonumber(currentFloor) == tonumber(maxTowerFloor)-1 then
		self.mcFloorThree:showFrame(4)
		self.mcFloorFour:visible(false)
	elseif tonumber(currentFloor) == tonumber(maxTowerFloor) then
		self.mcFloorTwo:showFrame(4)
		self.mcFloorThree:visible(false)
		self.mcFloorFour:visible(false)
	elseif tonumber(currentFloor) == tonumber(maxTowerFloor)-1 then
		self.mcFloorFour:showFrame(4)
	end	
end

function TowerMainView:updataNowFloorView()
	self:initData()
	self:setResetButton()
	self:progressByReward()
	self:initFloorDoor(self.currentFloor,self.historyFloor)
	self:createBoxAni()
end

function TowerMainView:resetNumTips()
	WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_040")) 
end







-- ===================================================================================
-- 设置左侧进度层宝箱
-- ===================================================================================
function TowerMainView:updateFloorBoxBar( _curFloorId,_maxFloorNum )
	self:initBoxScroll()
	self:updateBoxesScroll()
end

function TowerMainView:jianting( event )
	self:updateBoxesScroll()
end
-- 初始化左侧宝箱进度条
function TowerMainView:initBoxScroll()
	self.panel_1.scroll_1:hideDragBar()
	self.panel_1.panel_boxes:visible(false)
	local createBoxPanelFunc = function(onePageData)
		local itemView = UIBaseDef:cloneOneView(self.panel_1.panel_boxes) 
		itemView:visible(true)
		self:updateOnePageBoxes(itemView,onePageData)
		return itemView
	end
	local freshBoxPanelFunc = function(onePageData,itemView)
		itemView:visible(true)
		self:updateOnePageBoxes(itemView,onePageData)
		return itemView
	end

	-- 将配置的层数分等级
	local numOfOnePage = 5  -- 一页5个宝箱
	local allPageBoxes = {}
	local maxFloorNum = FuncTower.getMaxFloor()

	local onePageData = {}
	local pageNum = 0
	for i=1,maxFloorNum do
		onePageData[#onePageData + 1] = i
		if #onePageData == numOfOnePage then
			allPageBoxes[#allPageBoxes + 1] = table.deepCopy(onePageData)
			pageNum = pageNum + 1
			onePageData = {}
		elseif i == maxFloorNum then
			allPageBoxes[#allPageBoxes + 1] = table.deepCopy(onePageData)
			pageNum = pageNum + 1
			onePageData = {}
		end
	end

	self.maxStage = pageNum -- 最大阶段数
	local tem = {}
	for i=pageNum,1,-1 do
		tem[#tem + 1] = allPageBoxes[i]
	end
	allPageBoxes = tem
	self.scrollParams = {
		{
        data = allPageBoxes,
        createFunc = createBoxPanelFunc,
        updateCellFunc = freshBoxPanelFunc,
        perNums= 1,
        offsetX = -40,
        offsetY = 0,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x=0,y=-456,width = 103,height = 456}, 
        perFrame = 1,
		}
    }
    local function scrollMoveEndCallBack(itemIndex, groupIndex)
		if itemIndex < 1 then
	        itemIndex = 1
	    end
	    if itemIndex ~= self.lastSellected then
	    	self.lastSellected = itemIndex
	    	local stage = self.maxStage - itemIndex + 1
	    	self.lastSelectedStage = stage
			echo("...移动到了 stage=",stage)
	    	self.panel_1.scroll_1:refreshCellView(1)
	    	local curStageFirstFloorId = (stage - 1)*5 + 1
			self:updatePlayerHeadIcon( curStageFirstFloorId )
	    end
    end
    self.panel_1.scroll_1:setScrollPage(1, 10, 0,{scale = 1,wave = 0},c_func(scrollMoveEndCallBack))
end

-- 更新一个阶段的进度宝箱
function TowerMainView:updateOnePageBoxes(itemView,onePageData)
	-- dump(onePageData, "一页数据")
	-- 更新该阶段每个宝箱的视图
	for i=1,5 do
		local floorId = onePageData[i]
		if not floorId then
			for ii=i,5 do
			 	itemView["mc_box"..ii]:visible(false)
			end 
			return
		end
		local floorData = FuncTower.getOneFloorData( floorId )
		-- 判断宝箱类型
		local isShopBox = false
		if floorData and floorData.reward then
			isShopBox = false
		elseif floorData and floorData.shopUnlock then
			isShopBox = true
		end
		-- 判断宝箱状态,是否领取
		-- 注意是否点开看过 点开看过就算领取
		local boxStatus = self.boxStatusType.LOCK
		local maxPassFloor = TowerMainModel:getMaxClearFloor()
		if tonumber(floorId) <= maxPassFloor then
			boxStatus = self.boxStatusType.ACCESSIBLE
		end

		-- 如果是已解锁商店 如果点击查看过则算是 已经领取
		if isShopBox then
			local hasCheck = TowerMainModel:getHasCheckTowerShopGoods(floorId)
			if tostring(hasCheck) == "true" then
				boxStatus = self.boxStatusType.GOT
			end
		else
			local haveGotBox = TowerMainModel:getTowerFloorReward() or {}
			for k,v in pairs(haveGotBox) do
	            if tostring(floorId) == tostring(k) then
	            	boxStatus = self.boxStatusType.GOT
	            end
	        end
	    end
		self:setBoxView(floorId,itemView["mc_box"..i],isShopBox,boxStatus )
	end
end

-- 设置一个宝箱的状态 
-- 监听点击事件 并响应
-- isShopBox 是否解锁商店物品类型的box
function TowerMainView:setBoxView(floorId,oneBoxView,isShopBox,boxStatus )
	-- echo("\n=== floorId,isShopBox,boxStatus =",floorId,isShopBox,boxStatus)
	if isShopBox then
		oneBoxView:showFrame(2)
		local contentView = oneBoxView:getCurFrameView()
		local tips = GameConfig.getLanguageWithSwap("#tid_tower_UI_main_1",self.languageMap[tonumber(floorId)]) 
		contentView.txt_1:setString(tips)

		local floorData = FuncTower.getOneFloorData( floorId )
        local shopId = floorData.shopUnlock
        local shopData = FuncShop.getOneTowerShopGoodsById( shopId )
        local rewardId = shopData.itemId
        local rewardType = FuncDataResource.RES_TYPE.ITEM
        local rewardNum = shopData.num
        local rewardStr = rewardType..","..rewardId..","..rewardNum
        local rewardUI = contentView.panel_qipao.UI_1
        rewardUI:visible(true)
        rewardUI:setResItemData({reward = rewardStr})
        rewardUI:showResItemName(false)
        rewardUI:showResItemNum(false)
        FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,rewardStr,true,true)

		if boxStatus == self.boxStatusType.LOCK 
			or boxStatus == self.boxStatusType.ACCESSIBLE then
			contentView.panel_qipao:visible(true)
			local actArr = {
                act.scaleto(0.3, 1),
                act.delaytime(2),
                act.scaleto(0.2, 0),
                act.delaytime(2)
			}
			contentView.panel_qipao:stopAllActions()
			contentView.panel_qipao:runAction(act._repeat(act.sequence(unpack(actArr))))
		elseif boxStatus == self.boxStatusType.GOT then
			contentView.panel_qipao:visible(false)
		end
		contentView.panel_shop1:setTouchedFunc(c_func(self.enterRewardView,self,floorId,isShopBox,boxStatus))
	else
		oneBoxView:showFrame(1)
		local contentView = oneBoxView:getCurFrameView()
		local tips = GameConfig.getLanguageWithSwap("#tid_tower_UI_main_1",self.languageMap[tonumber(floorId)]) 
		contentView.txt_1:setString(tips)
		if boxStatus == self.boxStatusType.LOCK then
        	contentView.panel_box1.mc_box1:visible(true)
			contentView.panel_box1.mc_box1:showFrame(1)		
		elseif boxStatus == self.boxStatusType.ACCESSIBLE then
			-- todo 加动画
        	local rewardUI = UIBaseDef:cloneOneView(contentView.panel_box1.mc_box1)
        	contentView.panel_box1.mc_box1:visible(false)

        	local ctn = contentView.panel_box1.ctn_1
        	ctn:removeAllChildren()
        	local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctn, false, GameVars.emptyFunc)
        	FuncArmature.changeBoneDisplay(anim,"node",rewardUI)
        	anim:setPosition(0,0)
    		anim:startPlay(true)
    		anim:scale(0.8)
    		anim:getBone("node"):scale(1.3):pos(2,9)
    		rewardUI:setTouchedFunc(c_func(self.enterRewardView,self,floorId,isShopBox,boxStatus)) 
		elseif boxStatus == self.boxStatusType.GOT then
			contentView.panel_box1.ctn_1:removeAllChildren()
        	contentView.panel_box1.mc_box1:visible(true)
			contentView.panel_box1.mc_box1:showFrame(2)
		end
		contentView.panel_box1:setTouchedFunc(c_func(self.enterRewardView,self,floorId,isShopBox,boxStatus))
	end
end

-- 更新进度宝箱
function TowerMainView:updateBoxesScroll()
	self.panel_1.scroll_1:cancleCacheView()
	self.panel_1.scroll_1:styleFill(self.scrollParams)
	local floor = TowerMainModel:getCurrentFloor()
	local maxfloor = FuncTower.getMaxFloor()
	local floorData = FuncTower.getOneFloorData( floor )
	local maxfloorData = FuncTower.getOneFloorData( maxfloor )
	local stage = tonumber(floorData.stage)
	if self.lastSelectedStage then
		stage = self.lastSelectedStage
	end

	local function callback(stage)
		self.panel_1.scroll_1:pageEaseMoveTo((self.maxStage - stage + 1),1,0);
		self.lastSelectedStage = stage
		echo("______ 收到消息 或者刚进界面 _______",stage)
		local curStageFirstFloorId = (stage - 1)*5 + 1
		self:updatePlayerHeadIcon( curStageFirstFloorId )
	end
	self.panel_1.scroll_1:setOnCreateCompFunc( c_func(callback,stage) )
end

function TowerMainView:updatePlayerHeadIcon( curStageFirstFloorId )
	-- 设置进度条及玩家头像
	local historyPassMaxFloor = TowerMainModel:getMaxClearFloor()
	local isArrivedLowestFloor = historyPassMaxFloor - curStageFirstFloorId + 1
	local isShowpPlayerIcon = true   -- 玩家头像是否在可视范围
	if isArrivedLowestFloor < 0 then
		isArrivedLowestFloor = 0
		isShowpPlayerIcon = false
	end
	local progress = isArrivedLowestFloor/5
	if progress > 1 then
		progress = 1
		isShowpPlayerIcon = false
	end
	self.panel_1.panel_1.progress_1:setDirection(ProgressBar.d_u)
	self.panel_1.panel_1.progress_1:setPercent(progress*100)
	local ssize = self.panel_1.panel_1.progress_1:getContainerBox()
	local posYOfPlayerIcon = self.panel_1.panel_1:getPositionY() - ssize.height + ssize.height * progress
	self.panel_1.panel_2:visible(isShowpPlayerIcon)
	self.panel_1.panel_2:setPositionY(posYOfPlayerIcon)
end

function TowerMainView:press_btn_close()
	local mapView = WindowControler:getWindow( "TowerMapView" )
	if mapView then
		mapView:clickClose()
	end
	self:startHide()
end

function TowerMainView:deleteMe()
	TowerMainView.super.deleteMe(self);
end
return TowerMainView;

