-- Author: ZhangYanguang
-- Date: 2017-04-17
-- 六界新版主界面

local WorldMainView = class("WorldMainView", UIBase);

-- raidId 大地图跳到指定关卡
function WorldMainView:ctor(winName,raidId)
    WorldMainView.super.ctor(self, winName);

    self.MAP_TYPE = {
    	MAIN_MAP = 1,
    	AERIA_MAP = 2
	}
end

function WorldMainView:loadUIComplete()
	self:playBgMusic( )
	self:loadkQuestUI(DailyQuestModel:getquestId());
	self:initView()
	self:registerEvent()

	self:jumpToTargetRaid()

	self:addBarrageUI()   

	-- TODO 六界主界面加载较慢，导致从LoginLoading到主城会闪黑屏，采用下面临时解决方案 ZhangYanguang
	local closeLoadingView = function()
		WindowControler:closeWindow("LoginLoadingView")
	end

	self:delayCall(closeLoadingView, 3)
	
	local registerTagNotices = function()
		PushHelper:registerTagNotices()
	end

	self:delayCall(registerTagNotices, 10)
end 

--添加弹幕界面
function WorldMainView:addBarrageUI()

	local arrPame = {
		system = FuncBarrage.SystemType.world,  --系统参数
		btnPos = {x = 0,y = -50},  --弹幕按钮的位置
		barrageCellPos = {x = 0,y = 20}, --弹幕区域的位置
		addview = self,--索要添加的视图
	}
	BarrageControler:showBarrageCommUI(arrPame)
end

-- --添加聊天和目标按钮
-- function WorldMainView:addQuestAndChat()
--     local arrData = {
--         systemView = "world",--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end

function WorldMainView:initView()
	IS_SHOW_CLICK_EFFECT = false

	self.mcUI = self.mc_1
	self.mcUI:setShowAllFrame(true)
	self.mcUI:showFrame(1)
	self.mainMapView = self.mcUI:getCurFrameView()
	self.mainMapView.UI_1.UI_name_title:setVisible(false)
end

function WorldMainView:playBgMusic( )
	AudioModel:playMusic(MusicConfig.m_scene_pve, true)
end

-- UI适配
function WorldMainView:registerEvent()
	EventControler:addEventListener(WorldEvent.WORLDEVENT_SHOW_MAIN_MAP,self.showMainMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_SHOW_AERIAL_MAP,self.showAerialMap,self)
	-- 关闭整个六界
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLOSE_WHOLE_WORLD,self.startHide,self)
	-- 打开了一个新界面
	EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)
	-- 播放背景音乐
	EventControler:addEventListener(WorldEvent.WORLDEVENT_PLAY_BGMUSIC ,self.playBgMusic,self)

	EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self);

end

-- 跳转到指定关卡(npc)
function WorldMainView:jumpToTargetRaid(targetRaidId)
	if targetRaidId then
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_FORCE_CHAR_TO_NPC)
	end
end

--[[
	如果是通WindowControler:popWindow回到主城，
	可能没有HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW消息
	通过下面的方法保证引导消息能正常发送
]]
function WorldMainView:onSelfPop( ... )
	WorldMainView.super.onSelfPop(self,...)
	self:onHomeShow()
end

function WorldMainView:onUIShowComp(e)
	if WindowControler:checkCurrentViewName("WorldMainView") == true then 
		IS_SHOW_CLICK_EFFECT = false
        return;
    else
    	-- 发送一个隐藏仙灵委托界面的消息
    	EventControler:dispatchEvent(DelegateEvent.DELEGATE_VIEW_CLOSE)
    	IS_SHOW_CLICK_EFFECT = true
    end 

    local targetUI = e.params.ui

    if targetUI:checkIsFullUI()  then
        self:visible(false)
        echo("发送隐藏消息......",self:isVisible())
    	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_WORLD_MAIN_ON_NOT_TOPVIEW)
    end
end

-- 跳转到主地图
function WorldMainView:showMainMap(data)
	if self.isPlayAnim then
		return
	end

	if self.curMapType == self.MAP_TYPE.MAIN_MAP then
		return
	end

	self.curMapType = self.MAP_TYPE.MAIN_MAP

	self.aerialMapView:setLocalZOrder(1)

	self.mcUI:showFrame(1)
	self.mainMapView = self.mcUI:getCurFrameView()
	self.mainMapView:setLocalZOrder(0)

	if data and data.params and data.params.mapInfo then
		self.mapInfo = data.params.mapInfo
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_UPDATE_MAIN_MAP,{mapInfo=self.mapInfo})
	end

	local mapCloseCallBack = function()
		self.aerialMapView:setVisible(false)
		self.aerialMapView:opacity(255)
		self.isPlayAnim = false
	end

	self.isPlayAnim = true
	self:playMapCloseAnim(self.aerialMapView,1,mapCloseCallBack)
	-- self:playMapOpenAnim(self.mainMapView,1)
end

function WorldMainView:onBecomeTopView() 
	echo("\n=======六界大地图onBecomeTopView")
	self:visible(true)
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_UPDATE_NPC_WHEN_TOP_VIEW)
	else
		-- 非引导中再执行
		if ShareBossModel:checkFindReward() then
			local findReward = ShareBossModel:getFindReward()
			WindowControler:showWindow("ShareFindRewardView", findReward)
			ShareBossModel:resetFindReward()
		end

		if not ActivityFirstRechargeModel:isRecharged() and ActivityFirstRechargeModel:getFirstChargePushStatus() then
			WindowControler:showWindow("ActivityFirstRechargeView")
			ActivityFirstRechargeModel:resetFirstChargePushStatus()
		end
	end

	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_WORLD_MAIN_ON_TOPVIEW)
end

function WorldMainView:onHomeShow(event)
	echo("\n=======六界大地图onHomeShow")

	if event then
		if not PrologueUtils:showPrologueJoinAnim() then
			local lastViewName = event.params.lastViewName
		    local currentVieName = event.params.currentVieName
			if currentVieName == "WorldMainView"  then
				if not HomeModel.isShowEnterAni then
			        EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE,
			 			{tutorailParam = TutorialEvent.CustomParam.worldComeToTop})
			    end
		    end
		end
	end
end

-- 跳转到缩略图
function WorldMainView:showAerialMap(data)
	if self.isPlayAnim then
		return
	end
	
	if self.curMapType == self.MAP_TYPE.AERIA_MAP then
		return
	end

	self.curMapType = self.MAP_TYPE.AERIA_MAP

	self.mainMapView:setLocalZOrder(1)

	self.mcUI:showFrame(2)
	self.aerialMapView = self.mcUI:getCurFrameView()
	self.aerialMapView:setLocalZOrder(0)

	if data and data.params and data.params.mapInfo then
		self.mapInfo = data.params.mapInfo
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_UPDATE_AERIA_MAP,{mapInfo=self.mapInfo})
	end

	local mapCloseCallBack = function()
		self.mainMapView:setVisible(false)
		self.mainMapView:opacity(255)
		self.isPlayAnim = false
	end

	self.isPlayAnim = true
	self:playMapCloseAnim(self.mainMapView,1,mapCloseCallBack)
	self:playMapOpenAnim(self.aerialMapView,1)
end

function WorldMainView:playMapOpenAnim(mapView,secTime,callBack)
	local actCallBack = nil
	if callBack then
		actCallBack = act.callfunc(callBack)
	end

	mapView:opacity(0)

	local act = cc.Sequence:create(
		act.fadein(secTime)
		,actCallBack
		,nil)

	mapView:runAction(act)
end


function WorldMainView:playMapCloseAnim(mapView,secTime,callBack)
	local actCallBack = nil
	if callBack then
		actCallBack = act.callfunc(callBack)
	end

	local act = cc.Sequence:create(
		act.fadeout(secTime)
		,actCallBack
		,nil)

	mapView:runAction(act)
end

function WorldMainView:getMapInfo()
	return mapInfo
end

function WorldMainView:deleteMe()
	-- EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLOSE_WORLD)
	WorldMainView.super.deleteMe(self)
	IS_SHOW_CLICK_EFFECT = true
end



function WorldMainView:getBtnComponent()
	local uiView =  self.mcUI:getViewByFrame(1)

	return uiView.UI_1.UI_main.UI_downBtns

end


--获得其他按钮的资源
function WorldMainView:getOtherButton()
	local uiView =  self.mcUI:getViewByFrame(1)
	return uiView.UI_1.UI_main
end



return WorldMainView
