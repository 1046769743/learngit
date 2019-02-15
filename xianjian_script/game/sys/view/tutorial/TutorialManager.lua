--2015.7.21 guan
--2016.4.22 guan
--2017.5.10 guan zhangqizhi


--用等级解锁中，开始监听那个GroupId，用消息和界面触发！！！！！到了界面就点不了了
--发送消息，就开始显示新手引导
--解锁条件
--废弃 BattleGuide 整合到 NoviceGuide 中 ！加个完成的点击方式

--怎么跳回主城？？？？？开启功能

require("game.sys.view.tutorial.TutorialLayer")
require("game.sys.view.tutorial.BattleTutorialLayer")

TutorialManager = class("TutorialManager");

local _tutorialManager = nil;
local prologueTutorialGroupId = 20000;
local prologueKeyInLS = "prologueKeyInLS";

local skip = false;

local waitForSystemOpen = "waitForSystemOpen";

function TutorialManager.getInstance()
	if _tutorialManager == nil then 
		_tutorialManager = TutorialManager.new();
		return _tutorialManager;	
	end
	return _tutorialManager;
end

function TutorialManager:ctor()
	--大步id 当前正在进行的 groupId
	self._groupId = nil;
	--小步id
	self._tutorialId = 1;
	--是否在引导中
	self._isTuroring = false;
	-- 当前解锁的id
	self._unlockId = nil;
	-- 当前展示的功能开启id，只用作检查主城按钮是否该存在的问题（为功能开启加的不然会出现显示不正常的bug）
	self._openSysId = nil
	--新手引导层
	self._tutorialLayer = nil;

	self._preIsDone = true;

	--服务器记录的step 用于大退
	self._stepInServer = 1;

	--已经触发，哪里也点不了了, 正在等消息来
	self._waitForMessage = false;

	--是否完成强制引导
	self._isFinishForceTutorial = false

	--这是嘛？？？
	self._isAlreadyShowMainHome = false;

	--被触发的新手引导 UnlockGuide 表里的 id
	self._unlockGuides = {};

	--存触发式引导的表
	self._triggerGuides = {}

	-- 当进行触发式引导时会将当前的步骤存起来，完成后再恢复（正常情况下在其他引导过程中不会进入有触发式引导的界面，所以理论上不会冲突，但是防止策划配置问题加此字段）
	-- self._stepCache = {}

	-- 存放由外部传入的位置，个别步骤位置靠外部传入
	self._cachePos = nil

	--是否是暂停状态
	self._isPaused = false

	GameLuaLoader:loadGameSysFuncs()
end

function TutorialManager:registerEvent()
	--不能是 UIEVENT_SHOWCOMP, windowCfg.style的话，有可能没有发出 UIEVENT_SHOWCOMP，就已经可以点了
  	EventControler:addEventListener(UIEvent.UIEVENT_STARTSHOW, 
  		self.onCheckWhenShowWindow, self);

  	--pvp level 界面没有 windows name 单独接受个消息
  	EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_OPEN_LEVEL_VIEW, 
  		self.onCheckMessageShowWindow, self);

  	EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
  		self.onCheckWhenCloseWindow, self);

  	--序章触发新手
  	EventControler:addEventListener(TutorialEvent.TUTORIALEVENT_PROLOGUE_TRIGGER, 
  		self.onCheckPrologue, self);

   	EventControler:addEventListener(HomeEvent.SHOW_RES_COMING_ANI, 
  		self.onAlreadyShowHomeAni, self); 

   	--根据系统名字开启引导
   	EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT, 
  		self.unLockGuide, self); 

   	EventControler:addEventListener(UserEvent.LOGIN_ENTER_GAME_RES_LOADING, 
  		self.loginUnlockGuide, self);  

     EventControler:addEventListener(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
  		self.customEventCallback, self);  	

     EventControler:addEventListener(TutorialEvent.PRO_LOGUE_OPEN, 
  		self.prologueOpen, self); 

    --滑动引导
    EventControler:addEventListener(TutorialEvent.TUTORIAL_SLIDE_OVER_EVENT, 
  		self.waitForSlide, self); 

    --伙伴攻击引导
    EventControler:addEventListener(TutorialEvent.TUTORIAL_PARTNER_ATK, 
    	self.waitForAtk, self)

    --领取宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, 
  		self.onWorldBoxOpen, self); 

    --三皇台
    -- EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_LOTTERY, 
  		-- self.onLotterySuccess, self); 

  	-- 拖动布阵
  	EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_FORMATION,
  		self.onFormationSuccess, self)  	

  	-- 聚魂(动画)结束
  	EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_JUHUN,
  		self.onGetMessage, self)

  	-- 仙盟厨房特殊引导结束
  	EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_GUILDACTIVITY,
  		self.onGetMessage, self)

  	-- 视频播放完成消息
  	EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_VIDEO,
  		self.onPlayComplete, self)

    --通关消息
    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID,
        self.onBattleWin, self);  

    -- 玩家命名消息
    EventControler:addEventListener(UserEvent.USEREVENT_SET_NAME_OK,
        self.onNameSuccess, self);

    -- 暂停新手引导
    EventControler:addEventListener(TutorialEvent.TUTORIAL_SET_PAUSE, self.onSetTutorialPause, self)
    -- 收到战斗结束消息
    EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_BATTLE, self.onBattleFinish, self)
end
--[[

]]
function TutorialManager:onBattleFinish( event )
	echo("-------onBattleFinish------")
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不需要检查引导---");
		return;
	end

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId)

	if TutorialEvent.TUTORIAL_FINISH_BATTLE == message then
		local result = event.params.result
		
		if tonumber(result) == 1 then
			-- 过关了
			echo("过关，完成此步 ====== _groupId, _tutorialId",self._groupId,self._tutorialId)
			self._tutorialLayer:finishCurStep()
		else
			-- 没过关
			local fallBackStep =  FuncGuide.getFallBackStep(self._groupId, self._tutorialId)
			echo("没过关，回退到步骤 fallBackStep",fallBackStep)
			self._tutorialId = fallBackStep or self._tutorialId
			self._preIsDone = true
		end
	end
end
--[[
	这个暂时废弃，因为不能只接受六界战斗完成的消息了
]]
function TutorialManager:onBattleWin()
	echo("-------onBattleWin------");
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是战斗胜利---");
		return;
	end	

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId);

	echo("---WorldEvent.WORLDEVENT_FIRST_PASS_RAID-", WorldEvent.WORLDEVENT_FIRST_PASS_RAID, message);
	echo("-----self._groupId, self._tutorialId-----", self._groupId, self._tutorialId);

	if WorldEvent.WORLDEVENT_FIRST_PASS_RAID == message then 
		echo("!!!!!!");
		self._tutorialLayer:finishCurStep();
	end 
end

function TutorialManager:onWorldBoxOpen()
	echo("-------onWorldBoxOpen------");
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是开宝箱---");
		return;
	end	

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId);

	echo("---WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES-", WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, message);
	echo("-----self._groupId, self._tutorialId-----", self._groupId, self._tutorialId);

	if WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES == message then 
		echo("!!!!!!");
		self._tutorialLayer:finishCurStep();
	end 

end

function TutorialManager:onGetMessage(event)
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不在引导中---");
		return;
	end

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId)
	echo("收到消息",event.name,message)
	if event.name == message then 
		self._tutorialLayer:finishCurStep();
	end
end

function TutorialManager:onFormationSuccess()
	echo("-------onFormationSuccess------")
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是布阵步---");
		return;
	end

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId)
	if TutorialEvent.TUTORIAL_FINISH_FORMATION == message then 
		self._tutorialLayer:finishCurStep();
	end
end

function TutorialManager:onPlayComplete()
	echo("-------onPlayComplete------")
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是播放步---");
		return;
	end

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId)
	if TutorialEvent.TUTORIAL_FINISH_VIDEO == message then 
		self._tutorialLayer:finishCurStep();
	end
end

function TutorialManager:onLotterySuccess()
	echo("-------onLotterySuccess------");
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是抽开步---");
		return;
	end	

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId);
	if TutorialEvent.TUTORIAL_FINISH_LOTTERY == message then 
		self._tutorialLayer:finishCurStep();
	end 
end

function TutorialManager:onNameSuccess()
	echo("-------onNameSuccess------");
	if (self._groupId == nil or self._tutorialId == nil) then 
		echo("----不是改名步---");
		return;
	end	

	local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId);
	if UserEvent.USEREVENT_SET_NAME_OK == message then 
		self._tutorialLayer:finishCurStep();
	end
end

function TutorialManager:onAlreadyShowHomeAni()
	self._isAlreadyShowMainHome = true;
end

function TutorialManager:customEventCallback( event )
	local eventParam = event.params.tutorailParam;
	echo("----eventParam-----", eventParam, self._groupId, self._tutorialId, self._preIsDone);

	-- 检查一下此消息是否有触发式引导，如果有给引导参数赋值
	self:checkTriggerOnCustome(eventParam)

	if (self._groupId == nil or self._tutorialId == nil) then 
		
		return;
	end

	if self._preIsDone == false then 
		return;
	end

	-- self._cachePos = event.params.targetPos

	local function showGuide()
		self._preIsDone = true

		self:showTuroral();
	end
	
	-- 首先检查是否是对应的消息
	local paramInConfig = FuncGuide.getParameter(self._groupId, self._tutorialId);

	echo("----eventParam-paramInConfig-----", eventParam, paramInConfig);

	if paramInConfig == eventParam then
		-- 查看是否配置有主城入口（如果有位置动态获取）
		local entranceName = FuncGuide.getEntranceName(self._groupId, self._tutorialId)
		echo("entranceName=====",entranceName,"======self._groupId===",self._groupId,"====self._tutorialId==",self._tutorialId)
		if entranceName then
			-- 根据不同的界面调用不同的方法
			local viewName = self:getCurStepViewName()
			self:getPosByEntrance(viewName, entranceName)
		end
		-- echo("获取功能的位置 ============")

		-- 检查是否是功能开启的类型,是否需要功能开启
		if self._unlockId then
			local flag,sysname = self:isShowSystemOpenById(self._unlockId)
			-- FuncGuide.isShowSystemOpenById( self._unlockId )
			echo("检查是否是功能开启的类型,是否需要功能开启",self._unlockId,sysname)
			local beginGroupId = FuncGuide.getBeginGroupId(self._unlockId)
			-- 不是主城不做飞图标，不是第一个触发组也不飞
			if paramInConfig ~= TutorialEvent.CustomParam.worldComeToTop or beginGroupId ~= self._groupId then
				flag = false
			end

			-- flag = false

			if flag then
				-- 防止循环调用
				self._preIsDone = false
				-- 调用接口播放主城功能开启动画，检查引导后续步骤作为回调
				echo("调用接口播放主城功能开启动画",sysname)
				local function openNewSystemCallBack()
					-- self:clearOpenSys()
					showGuide()
				end
				HomeModel:openNewSystem( sysname, openNewSystemCallBack )
				-- showGuide()
			else
				-- 直接检查引导后续步骤
				showGuide()
			end
		else
			-- 之间检查后续步骤
			showGuide()
		end
	end
end

function TutorialManager:onCheckPrologue(event)
	if not self._groupId or not self._unlockId then return end
	echo("---------!!!!!!--onCheckPrologue--!!!!!!!---------");
	if TutorialEvent.TUTORIALEVENT_PROLOGUE_TRIGGER == self._nextStepMessage then 
		if event.params and TutorialEvent.CustomParam.Skip == event.params.tutorailParam then
			-- 跳过一条引导的消息
			-- echoError("跳过当前小步",self._nextStepMessage)
			-- self:showStepId()
			self:finishCurTutorialId()
		else
			self:showTuroral();
		end
	end 
end

function TutorialManager:onCheckWhenShowWindow(event)
	self._curViewName = event.params.ui.windowName;
	self:onCheck();
end

function TutorialManager:onCheckMessageShowWindow(event)
	echo("------------onCheckMessageShowWindow-----------");
	-- if WorldEvent.WORLDEVENT_PVE_OPEN_LEVEL_VIEW == self._nextStepMessage then 
	-- 	self:showTuroral();
	-- end 
end

function TutorialManager:onCheckWhenCloseWindow(event)
	self._curViewName = event.params.viewName;
	self:onCheck();
end

--生产给后端发送的消息 unlockId + ; + groupId + ; + stepId
function TutorialManager:genToServerMessage(unlockId, groupId, stepId)
	echo("---genToServerMessage unlockId----", unlockId);
	echo("---genToServerMessage groupId----", groupId);
	echo("---genToServerMessage stepId----", stepId);

	--这一步存在否
	local isExist = FuncGuide.checkIsStepExist(groupId, stepId);
	if isExist == true then 
		return string.format("%s;%s;%s", tostring(unlockId), tostring(groupId), tostring(stepId));
	else 
		local nextGroupId = groupId + 1;
		--整个步骤结束
		if FuncGuide.isGroundExist(nextGroupId) == false then 
			return waitForSystemOpen;
		else 
			--还有下一个大组
			return string.format("%s;%s;%s", tostring(unlockId), tostring(nextGroupId), 1);
		end 
	end 
end

function TutorialManager:prologueOpen()
	echo("------------prologueOpen-----------");
	self._unlockId = "1";
end

function TutorialManager:loginUnlockGuide()
	local unlockId = FuncGuide.getLoginInFisrtForceGuideId();

	if unlockId ~= nil and self._unlockId == nil and self._isFinishForceTutorial == false then 
		--告诉后端正在进行新手 
		self:unLock(unlockId);
	end 

end

function TutorialManager:unLock(unlockId,noServer)
	if not unlockId or not FuncGuide.getBeginGroupId(unlockId) then return end
	
	self._unlockId = unlockId;
	-- echoError("赋值unlock", unlockId)
	self._openSysId = unlockId
	local groupId = FuncGuide.getBeginGroupId(unlockId);

	-- 如果是10006这一步，需要检查聚魂次数是否已经大于1，若大于1则跳过此步骤（第二次一定会抽到一个龙幽）
	if tonumber(groupId) == 10006 and NewLotteryModel:getLotterSumCount() > 1 then
		groupId = 10007
	end

	local stepMessage = self:genToServerMessage(unlockId, groupId, 1);

	self._tutorialId = 1;
	self._groupId = groupId;
	if noServer then return end
	-- 有新的功能引导开启，应当重置stepInServer2017.7.3
	self:setStepInServer(1)
	TutorServer:beginTutorStep(stepMessage);

	if SHOW_CLICK_RECT then
		EventControler:dispatchEvent(TutorialEvent.TUTORIAL_DEBUG, {groupId = self._groupId, tutorialId = self._tutorialId})
	end
end

-- 重置网络存储的id
function TutorialManager:setStepInServer(step)
	self._stepInServer = tonumber(step)
end

function TutorialManager:unLockGuide(event)
	--分成登陆游戏 系统开启 
	local openSysName = event.params.sysNameKey;
	local unlockId = FuncGuide.getUnlockGuideIdBySystemName(openSysName);

	echo("---unlockId---", unlockId);
	echo("---openSysName---", openSysName);
	
	if unlockId ~= nil 
		and array.isExistInArray(self._unlockGuides, unlockId) == false 
		-- 解锁的Id和当前正在进行的Id一致也不加入
		and unlockId ~= self._unlockId
	then 
		local isTrigger = FuncGuide.getUnlockGuideValueByKey(unlockId, "isTrigger")
		if isTrigger then
			if not array.isExistInArray(self._triggerGuides, unlockId) then
				echo("插入触发式的引导 ==========",unlockId)
				table.insert(self._triggerGuides, unlockId)
				TutorServer:unLockUpdate( unlockId, true);
			end

			return
		end

		if #self._unlockGuides == 0 and self._unlockId == nil then 
			self:unLock(unlockId);
		else 
			-- dump(self._unlockGuides, "self._unlockGuides")
			-- error("手动引发报错")
			echo("插入流程强制的引导 ==========",unlockId)
			table.insert(self._unlockGuides, unlockId);
			-- 有新加入的内容，重新按照优先级进行一下排序
			self._unlockGuides = self:sortByOpenOrderWithUnlockId(self._unlockGuides)
			TutorServer:unLockUpdate( unlockId, true);
			dump(self._unlockGuides, "-----table.inserttable.inserttable.insert---");
		end

	end 
end

function TutorialManager:sortByOpenOrderWithSysName( t )
	local tempPri = {}

	for i,sysName in ipairs(t) do
		tempPri[sysName] = FuncGuide.getOpenPriorityBySysname(sysName)
	end

	local function sortFunc( a, b )
		return tempPri[a] < tempPri[b]
	end

	table.sort(t, sortFunc)

	return t
end

function TutorialManager:sortByOpenOrderWithUnlockId( t )
	local tempPri = {}

	for i,unlockId in ipairs(t) do
		tempPri[unlockId] = FuncGuide.getOpenPriorityById( unlockId )
	end

	local function sortFunc( a, b )
		return tempPri[a] < tempPri[b]
	end

	table.sort(t, sortFunc)

	return t
end

function TutorialManager:isWaitingForMessage()
	if self._waitForMessage == true then 
		return true;
	else 
		return false;
	end 
end

function TutorialManager:isTutoring()
	if skip == true or self._tutorialLayer == nil then 
		return false;
	end 

	local isVisible = self._tutorialLayer:isVisible();
	
	if isVisible == true and self._curViewName ~= "CompServerOverTimeTipView" then 
		return true;
	else 
		return false;
	end 
end

function TutorialManager:setSkip(isSkip) 
	skip = isSkip;
end 

function TutorialManager:getSkip() 
	return skip;
end 
-- 2017.11.29先去掉这个限制，因为有其他的内容需要用到板子了
function TutorialManager:showBattleTutorialLayer(step, finishCallBack)
	-- if IS_CLOSE_TURORIAL == false then 
		BattleTutorialLayer.getInstance():show(step, finishCallBack);
	-- else  
	-- 	if finishCallBack ~= nil then 
	-- 		finishCallBack();
	-- 	end 
	-- end 
end

-- 按照传入的位置设置箭头位置（仅做一个特殊处理用不通用）
function TutorialManager:setBattleExtraPos(pos)
    -- if IS_CLOSE_TURORIAL == false then
    	BattleTutorialLayer.getInstance():setExtraPos(pos)
    -- end
end

-- 获取BattleTutorialLayer
function TutorialManager:getBattleTutorialLayer()
	return BattleTutorialLayer.getInstance()
end

function TutorialManager:waitForSlide()
	self:manualBattleFinish()
end

function TutorialManager:waitForAtk()
	self:manualBattleFinish()
end

function TutorialManager:manualBattleFinish()
	BattleTutorialLayer.getInstance():manualFinish();
end
-- 隐藏战斗引导（不要调用，只有战斗弱引导倒计时结束可以调用）
function TutorialManager:hideBattleWeakGuide()
	BattleTutorialLayer.getInstance():hideBattleWeakGuide()
end

function TutorialManager:getTutorialLayer()
	return self._tutorialLayer;
end
--[[
	返回两个表，主流程引导的表，存触发式引导的表
]]
function TutorialManager:getUnlockGuides(serverUnlock)
	local ret = {}
	local trigger = {}

	for k, id in pairs(serverUnlock) do
		local isTrigger = FuncGuide.getUnlockGuideValueByKey(id, "isTrigger")
		if isTrigger then
			table.insert(trigger, id)
		else
			table.insert(ret, id)
		end
	end	

	-- 按照优先级进行一下排序
	ret = self:sortByOpenOrderWithUnlockId(ret)

	return ret,trigger
end

--开始新手引导监听
function TutorialManager:startWork()
	echo("----TutorialManager startWork-----");
	local showPrologue = PrologueUtils:showPrologue();

	self._isTuroring = false;
	self._preIsDone = true;

	--序章中的引导
	if showPrologue == true then 
		echo("-----TutorialManager showPrologue------");
		local value = LS:pub():get(prologueKeyInLS, "defaultValue");
		if value == "defaultValue" then 
			self._groupId = prologueTutorialGroupId;
		else 
			self._groupId = tonumber(value);
		end 
		self._tutorialId = 1;
	else 
		--从后端恢复一下 self._unlockGuides todo;
		local serverUnlock = UserModel:guide();

		dump(serverUnlock, "----serverUnlock-----");

		self._unlockGuides,self._triggerGuides = self:getUnlockGuides(serverUnlock);
		dump(self._unlockGuides, "----self._unlockGuides self._unlockGuides-----");
		dump(self._triggerGuides, "----self._triggerGuides-----")

		local serverInfo = UserExtModel:guide();
		echo("-----serverInfo----", serverInfo);

		if serverInfo == waitForSystemOpen then 
			self._unlockId = nil;
			self._groupId = nil;
			self._tutorialId = nil;
			self._isFinishForceTutorial = true;
		else 
			self._unlockId, self._groupId, self._stepInServer = TutorialManager:parseServerData(serverInfo);
			-- self._unlockId, self._groupId,self._stepInServer = 23,10150,1
			self._openSysId = self._unlockId
			-- echoError("赋值")
			if self._unlockId ~= 2 then 
				self._isFinishForceTutorial = true;
			else 
				self._isFinishForceTutorial = false;
			end 

			self._tutorialId = 1;

			self:checkTutorialStuck()

			--看看要不要触发后续引导
			if self._unlockId == nil and #self._unlockGuides > 0 then 
				local unlock = self._unlockGuides[1];
				self:unLock(unlock);
				table.remove(self._unlockGuides, 1);
				TutorServer:unLockUpdate( unlock, false );

			end 
		end

		if SHOW_CLICK_RECT then
			EventControler:dispatchEvent(TutorialEvent.TUTORIAL_DEBUG, {groupId = self._groupId, tutorialId = self._tutorialId})
		end
	end 

	if self._tutorialLayer == nil then
		self._tutorialLayer = TutorialLayer.new();
		WindowControler:getScene()._tutoralRoot:addChild(self._tutorialLayer, 
		WindowControler.ZORDER_Tutorial);
		self:registerEvent();
	end
	
	self:hideTutorialLayer();
end

--info 是 unlockId + ";" + groupId + ; + stepId  stepId可能是空
function TutorialManager:parseServerData(info)
	local infoArray = string.split(info, ";");

	local unlockId =  tonumber(infoArray[1]);
	local groundId = tonumber(infoArray[2]);
	local step = tonumber(infoArray[3] or 1);
	-- if unlockId == 2 or unlockId == 11 then
	-- 	return 
	-- end
	--看看是不是已经超过了关键点了
	local isOverKeyPoint = FuncGuide.isOverKeyPoint(groundId, step);

	if isOverKeyPoint == false then 
		return unlockId, groundId, step;
	else 
		--看看下一大步还有没有了
		local isExist = FuncGuide.isGroundExist(groundId + 1);
		if isExist == true then 
			return unlockId, groundId + 1, 1;
		else
			return nil, nil, 1;
		end 
	end 
end

function TutorialManager:isTutorialPartner( npcId )
	local groupId = FuncGuide.getBeginGroupId(11);
	local pId = FuncGuide.getOtherInfo(groupId, 1);
	
	if tonumber(npcId) == tonumber(pId) then 
		return true
	else 
		return false;
	end 
end

function TutorialManager:getJumpToNpcInfo()
	if IS_CLOSE_TURORIAL == true then 
		return nil;
	end 
	-- local combineInfo = {index = FuncPartner.PartnerIndex.PARTNER_COMBINE, partnerId = 5003};
	echo("---self._unlockId----", self._unlockId);
	-- if self._unlockId then
	if self._groupId and self._tutorialId then
		local groupId = FuncGuide.getBeginGroupId(self._unlockId)
		-- 改成通过当前的步骤读
		-- local pId = FuncGuide.getOtherInfo(groupId, 1);
		local otherInfo = FuncGuide.getOtherInfo(tonumber(self._groupId),tonumber(self._tutorialId))
		if otherInfo then
			local pId = otherInfo[2]
			if pId == "zhujue" then
				pId = UserModel:avatar()
			end
			return {index = tonumber(otherInfo[1]), partnerId = pId}
			-- return {index = FuncPartner.PartnerIndex.PARTNER_UPSTAR, partnerId = pId}
		end
	end

	return nil;
end

function TutorialManager:isArneaHideOutBtn()
	if IS_CLOSE_TURORIAL == true then 
		return false;
	end 

	if tostring(self._unlockId) == "6" then
	    echo("---isArneaHideOutBtn---true----"); 
		return true
	else 
	    echo("---isArneaHideOutBtn---false----"); 
		return false;
	end 
end

--六界 npc 静止不动（2018.09.03 现在有两段引导都需要处理）
function TutorialManager:isNpcInWorldHalt()
	-- echo("-----self._isFinishForceTutorial------", self._isFinishForceTutorial);
	-- echo("-----self._groupId------", self._groupId);
	if self:isFinishForceGuide() == false then 
		return true;
	end 

	-- 这一段也需要
	-- 强制引导和第一段触发引导，现在是升品
	if tostring(self._unlockId) == "2" or tostring(self._unlockId) == "3" then
		return true
	end

	return false
end

--是否完成强制引导
function TutorialManager:isFinishForceGuide()
	--关闭引导，这样就算都完事了
	if IS_CLOSE_TURORIAL == true then 
		return true;
	end 
	if self._isFinishForceTutorial == true then 
		return true;
	end 

	return false;
end

-- wtf 写死 是否屏蔽战斗跳过
function TutorialManager:isShieldBattleExit()
	if IS_CLOSE_TURORIAL == true then
		return false
	end

	-- 强制引导和第一段触发引导，现在是升品
	if tostring(self._unlockId) == "2" or tostring(self._unlockId) == "3" then
		return true
	end

	return false
end

function TutorialManager:isInBtnClickArea(x, y)
    if x == nil or y == nil then 
    	return false;
    end 

	local ret = self._tutorialLayer:isInClickArea(x, y);

	if ret == false then 
        
        -- WindowControler:globalDelayCall(function ( ... )
			if self._tutorialLayer then
				-- 这里好像没用，屏蔽掉
				-- self._tutorialLayer:showWrongClickTips()
			end
        -- end, 0.001)

	end 

	return ret;
end

function TutorialManager:isInSetTouchClickArea(x, y)
    if x == nil or y == nil then 
    	return false;
    end 

	local ret = self._tutorialLayer:isInClickArea(x, y);

	if ret == false then 
		-- 因为底层去了延迟 所以这里也去掉延迟2017.11.9
        -- WindowControler:globalDelayCall(function ( ... )
        	--跳过新手引导 self._tutorialLayer 可能是空的
        	if self._tutorialLayer then
				self._tutorialLayer:showWrongClickTips();
			end 
        -- end, 0.001)
	end 

	return ret;
end
--[[
	检查是否有触发式引导
]]
function TutorialManager:checkTriggerGuide()
	-- 寻找当前界面是否存在
	if #self._triggerGuides == 0 then return end
	if self._unlockId ~= nil then return end -- 有主流程引导优先主流程引导

	for i,id in ripairs(self._triggerGuides) do
		local groupId = FuncGuide.getBeginGroupId(id)
		local viewName = FuncGuide.getWinName(groupId, 1) -- 查看第一步的界面
		-- 不是靠消息触发
		if viewName == self._curViewName and not FuncGuide.getConditionorigin(groupId, 1) then
			-- 到了当前界面触发本次触发引导
			echo("到了触发界面，触发触发式引导",viewName,id)
			-- 不发送当前步骤给服务器，并且，将当前步骤删除，所以不论是否完成只会触发一次
			self:unLock(id,true)
			table.remove(self._triggerGuides, i);

			EventControler:dispatchEvent(TutorialEvent.TUTORIAL_TRIGGER_REMOVE)

			-- 不是必须完成的触发式才直接删除
			local isTrigger = FuncGuide.getUnlockGuideValueByKey(id, "isTrigger")
			if isTrigger and isTrigger ~= 2 then
				TutorServer:unLockUpdate( id, false );
			end

			break
		end
	end
end
--[[
	收到消息的时候检查触发引导
]]
function TutorialManager:checkTriggerOnCustome(eventParam)
	-- 寻找是否存在
	if #self._triggerGuides == 0 then return end
	if self._unlockId ~= nil then return end -- 有主流程引导优先主流程引导

	-- 倒序
	for i,id in ripairs(self._triggerGuides) do
		local groupId = FuncGuide.getBeginGroupId(id)
		local paramInConfig = FuncGuide.getParameter(groupId, 1);
		if paramInConfig == eventParam then
			echo("收到消息，触发触发式引导",eventParam)
			-- 不发送当前步骤给服务器，并且，将当前步骤删除，所以不论是否完成只会触发一次
			self:unLock(id,true)
			table.remove(self._triggerGuides, i);

			EventControler:dispatchEvent(TutorialEvent.TUTORIAL_TRIGGER_REMOVE)

			-- 不是必须完成的触发式才直接删除
			local isTrigger = FuncGuide.getUnlockGuideValueByKey(id, "isTrigger")
			if isTrigger and isTrigger ~= 2 then
				TutorServer:unLockUpdate( id, false );
			end

			break
		end
	end
end
--[[
	新新手引导大步激活，下一步是否激活。第一个引导也是通过此来激活的
]]
function TutorialManager:onCheck()
	self:checkTriggerGuide()
	if self._unlockId == nil then
		return;
	end 

	self._nextStepMessage = FuncGuide.getConditionorigin(self._groupId, self._tutorialId);
	-- 等待消息后面都不需要做
	if self._nextStepMessage then return end

	local viewName = self:getCurStepViewName();
	echo("-----onStateCheck _curViewName------", tostring(self._curViewName), viewName);

	if viewName == self._curViewName then
		local entranceName = FuncGuide.getEntranceName(self._groupId, self._tutorialId)

		if entranceName then
			-- more_treasure
			self:getPosByEntrance(viewName, entranceName)
		end
	end

	--全屏不可点击
	if viewName == self._curViewName and self._preIsDone == true and self._nextStepMessage == nil then 
		echo("----viewName---self._curViewName---", viewName, self._curViewName);
		WindowControler:setUIClickable(false);
	end 

	if self._preIsDone == true and self._groupId ~= nil and self._nextStepMessage == nil then 
		--大步进行中
		if self._isTuroring == true then 
			if self._curViewName == viewName then 
				self:showTuroral();
			end 
		else 
			--新开启大步
			self:openCheck(self._curViewName);
		end 
	end 
end

--[[
	和上面的 onCheck 有什么区别
]]
function TutorialManager:openCheck(viewName)
	if self._unlockId == nil then 
		-- 没有后续步骤，放开屏蔽
		WindowControler:setUIClickable(true)
		return;
	end 

	echo("---openCheck---", viewName);
	echo("---self:getCurStepViewName()---", self:getCurStepViewName());

	self._nextStepMessage = FuncGuide.getConditionorigin(self._groupId, self._tutorialId);

	if viewName == self:getCurStepViewName() then 
		if self._nextStepMessage == nil then 
			self:showTuroral();
		else 
			if self._preIsDone == true then 
				WindowControler:setUIClickable(false);
			end
			self._waitForMessage = true; 
		end 

		return;
	end
end

-- 当前步骤是否需要跳回主城（目前是第一步就需要跳）
function TutorialManager:isCurUnlockJump()
	echo("self._unlockId",self._unlockId,FuncGuide.getUnlockJump(self._unlockId))
	if not self._unlockId then return false end
	
	return FuncGuide.getUnlockJump(self._unlockId)
end

-- 当前步骤是否是第一步
function TutorialManager:isCurStepFirstStep()
	echo("self._tutorialId",self._tutorialId)
	if (self._groupId == nil or self._tutorialId == nil) then
		echo("--- 没有步骤 不需要跳 ---")
		return false
	else
		return self._tutorialId == 1
	end
end

--完全完成当前大步
function TutorialManager:finishCurGroupId()
	self._isTuroring = false;

	if PrologueUtils:showPrologue() then 
		LS:pub():set(prologueKeyInLS, self._groupId + 1);
	end
	-- 完成一个大步时发引导层UI消失的消息，如果每一小步都发收消息的地方可能会出现反复重置标记的问题
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_UI_SHOWORHIDE, {isShow = false})
	-- 重设网络步骤
	self:setStepInServer(1)
	
	--是否跳回主城
	local jump = FuncGuide.getJump(self._groupId, self._tutorialId);
	if jump == 1 then 
		if BattleControler:isInBattle() then
			WindowControler:setisNeedJumpToHome(true);
		else
			WindowControler:goBackToHomeView();
			-- 先默认不让点
			WindowControler:setUIClickable(false)
		end
	end 

    --完成触发组
    if self:isFinishCurUnlockGuide(self._groupId + 1) == true then
    	local unlockId = self._unlockId;
        self._unlockId = nil;
        self._tutorialId = nil;
        self._groupId = nil;
        self._isFinishForceTutorial = true;
        
        self:clearOpenSys()

        local isTrigger = FuncGuide.getUnlockGuideValueByKey(unlockId, "isTrigger")
        if isTrigger == 2 then
        	-- 无论如何都再删一次引导标记，因为触发类型为2的触发式引导必须完成，所以没办法一开始就删步骤
        	TutorServer:unLockUpdate( unlockId, false );
        end
        

        --如果还有其他，继续触发之
        if #self._unlockGuides > 0 then 
        	echo("----table.removetable.removetable.remove----");
        	-- dump(self._unlockGuides, "self._unlockGuides")
        	local unlockId = self._unlockGuides[1];
        	self:unLock(unlockId);
        	table.remove(self._unlockGuides, 1);
			TutorServer:unLockUpdate( unlockId, false );
        else
        	-- 放开屏蔽
        	WindowControler:setUIClickable(true)
        end 

    else 
    	-- 当完成一步时记录应该重置一下2017.8.25
    	-- self:setStepInServer(1)

    	self._tutorialId = 1;
		self._groupId = self._groupId + 1;
		--再检查一下有没有新的大步开启 同一个ui开启 比如都是主城
		self:openCheck(self._curViewName);
    end

end

--这一组强制引导都完成了
function TutorialManager:isFinishCurUnlockGuide( groupId )
	--如果这一个groupId是空 则说明都完成了
	local isExist = FuncGuide.isGroundExist(groupId);

	if isExist == false then 
		return true;
	else 
		return false;
	end 
end

function TutorialManager:finishProcess()
	self._preIsDone = true;
	--隐藏新手引导
	self:hideTutorialLayer();
	self:doSomethingWhenFinish()

	if self:isFinshCurGroupId() == true then 
		echo("------isFinshCurGroupId true-----");
		--完成了这个大步
		self:finishCurGroupId();
	else 
		echo("-------isFinshCurGroupId false-------",self._tutorialId);
		--还有下一步
		local curId = self._tutorialId;
		self._tutorialId = self:getNextStepId();

		self._groupId,self._tutorialId = self:changeStepSpecial(self._groupId,self._tutorialId)
		echo("--NextStep--", self._tutorialId);

		self._nextStepMessage = FuncGuide.getConditionorigin(self._groupId, self._tutorialId);

		if self:isShowNextStepNow(curId) == true then
			local entranceName = FuncGuide.getEntranceName(self._groupId, self._tutorialId)
			if entranceName then
				-- more_treasure
				local viewName = self:getCurStepViewName()
				self:getPosByEntrance(viewName, entranceName)
			end

			--直接换界面
			self:showTuroral();
		end 
	end 

	if SHOW_CLICK_RECT then
		EventControler:dispatchEvent(TutorialEvent.TUTORIAL_DEBUG, {groupId = self._groupId, tutorialId = self._tutorialId})
	end

	-- 发个消息给需要检查标志位的系统
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_ONE_GROUP)
end

-- 完成特殊步骤做特殊事情（写死……）
function TutorialManager:doSomethingWhenFinish()
	if not self._groupId or not self._tutorialId then return end

	-- 当完成这一步后调用奇侠界面方法跳转界面
	-- if tostring(self._groupId) == "10000" and tostring(self._tutorialId) == "5" then
	-- 	-- 2 5033
	-- 	local partnerView = WindowControler:getWindow("PartnerView")
	-- 	-- 跳转
	-- 	if partnerView then
	-- 		partnerView:changeUIWithIndexAndId(2,5033)
	-- 	end
	-- end
end

-- 特殊改变步骤的方式
function TutorialManager:changeStepSpecial(groupId,tutorialId)
	-- 基本靠写死
	-- if tonumber(groupId) == 10016 and tonumber(tutorialId) == 2 then
	-- 	-- 如果龙幽已经合成了直接进行到第3步
	-- 	if PartnerModel:isHavedPatnner(5033) then
	-- 		tutorialId = 3
	-- 	end
	-- end

	-- if tonumber(groupId) == 10060 and tonumber(tutorialId) == 3 then
	-- 	-- 如果（第二章第二个）星级宝箱已经领取了直接进行到第5步
	-- 	if not WorldModel:hasStarBoxByBoxIndex(102,2) then
	-- 		tutorialId = 5
	-- 	end
	-- end

	return groupId,tutorialId
end

--完成当前小步, 在 TutorialLayer 层调用
function TutorialManager:finishCurTutorialId()
	local uniqueId = FuncGuide.getToCenterId(self._groupId, 
		self._tutorialId);
	echo(" ------finishCurTutorialId----- ", uniqueId);

	ClientActionControler:sendTutoralStepToWebCenter(uniqueId);
	FuncCommUI.setCanScroll(true);
	-- 重置一下可能存在的传入位置
	self._cachePos = nil

	--完成强制引导
	if self:isNeedToSendFinishRequestAfterFinish() == true 
		and PrologueUtils:showPrologue() == false then 

		local nextStep = self:getNextStepId(); 
		-- wtf 写死这一步完成直接记下一步 -- 
		-- 1-1后领取宝箱
		if self._groupId == 2 and nextStep == 3 then
			nextStep = 4
		end
		-- 第一次引导聚魂等莲花上树
		if self._groupId == 32 and nextStep == 3 then
			nextStep = 4
		end
		-- 第二次引导聚魂等莲花上树
		if self._groupId == 10006 and nextStep == 3 then
			nextStep = 4
		end
		-- wtf 写死这一步完成直接记下一步 -- 
		local stepMessage = self:genToServerMessage(
			self._unlockId, self._groupId, nextStep);
		
		TutorServer:beginTutorStep(stepMessage, 
			c_func(self.finishCallback, self));

	else 
		self:finishProcess();
	end
end

function TutorialManager:finishCallback(event)
	echo("--finishCallback--");
    if event.error == nil then
    	self:finishProcess();
    end 
end

--[[
	执行到这肯定有下一步
]]
function TutorialManager:isShowNextStepNow(curId)
	local isNextTutorialChangeView = self:isNextTutorialChangeView(curId);

	local nextStepId = self:getNextStepId(curId);
	local nextStepMessage = FuncGuide.getConditionorigin(self._groupId, nextStepId);

	if isNextTutorialChangeView == false and nextStepMessage == nil then
		return true;
	else 
		return false;
	end 
end

--下一步是否换ui了
function TutorialManager:isNextTutorialChangeView(curId)
	local nextStep = self:getNextStepId(curId);
	local nextView = FuncGuide.getWinName(self._groupId, nextStep);

	--没有下一个界面
	if nextView == nil then 
		return false;
	else 
		return nextView ~= self._curViewName and true or false;
	end 

end

--是否需呀发送完成任务请求
function TutorialManager:isNeedToSendFinishRequestAfterFinish()
	local isConnect = FuncGuide.getIsServerConnect(self._groupId, self._tutorialId);
	return isConnect;
end

function TutorialManager:isFinshCurGroupId()
	local nextStep = self:getNextStepId();
	local isExist = FuncGuide.checkIsStepExist(self._groupId, nextStep);
	if isExist then
		return false
	else 
		return true;
	end
end

-- 是否有引导步骤存在（与isTutoring不同 isTutoring是在进行引导 此函数式有引导步骤存在）
function TutorialManager:isInTutorial()
	if (self._groupId == nil or self._tutorialId == nil) then
		-- echo("--- 没有步骤 没有进行任何引导 ---")
		return false
	end

	if self._unlockId == nil then
		echo("--- 没有功能引导 不会有伙伴引导 ---")
		return false
	end

	-- 这个判断是在伙伴界面做的 满足上面条件不应该乱点
	return true
end

--得到下一步id 跳过已经完成的
function TutorialManager:getNextStepId(stepId)
	local curStepId = stepId or self._tutorialId;
	echo("现在步骤", curStepId, "网络步骤", self._stepInServer)
	if not curStepId or not self._stepInServer then 
		echoError("错误情况，函数getNextStepId中，curStepId or self._stepInServer为空",curStepId,self._stepInServer)
		return nil 
	end

	local nextId = curStepId + 1

	if curStepId >= self._stepInServer then 
		-- nextId = curStepId + 1;
	else 
		-- nextId = curStepId + 1;
		
		-- nextId < self._stepInServer 是下一步不超过已经完成的步骤 
		-- 并且 FuncGuide.isSkipStep(self._groupId, nextId) == true 是需要跳过的id
		-- 2017.6.19 改成正常的逻辑 < ，根据上一个人说是为了解决一个bug才改成<=的 但是他已经不记得原因了，目前需要这里是正常逻辑，等bug再出现去解决根本问题
		while (nextId < self._stepInServer and FuncGuide.isSkipStep(self._groupId, nextId) == true) do
			nextId = nextId + 1
		end

		-- return nextId;
	end

	-- 如果是不应该播视频的步骤，直接跳过视频步
	if not AudioModel:checkNeedPlayVideo() then
		-- 存在视频则跳过
		while FuncGuide.getValueByKey(self._groupId, nextId, "videoId", false) do
			nextId = nextId + 1
		end
	end

	return nextId
end

--[[
	显示新手引导层
]]
function TutorialManager:showTutorialLayer()
	echo("--showTutorialLayer--");
   	self._tutorialLayer:setVisible(true);
   	-- 引导层UI出现时发消息
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_UI_SHOWORHIDE, {isShow = true})
end

--[[
	隐藏新手引导层 getTouchNode
]]
function TutorialManager:hideTutorialLayer()
	echo("--hideTutorialLayer--", tostring( self._tutorialLayer ));
    self._tutorialLayer:setVisible(false);
    	
end

--开始显示新手引导
function TutorialManager:showTuroral()
	-- 容错（消息到达先后可能会导致这里为空）
	if (self._groupId == nil or self._tutorialId == nil) then
		return
	end

	local function showCall()
		FuncCommUI.setCanScroll(false);
		WindowControler:setUIClickable(true);

		-- 进入前最后再做一次判断防止又打开了新的界面（目前可解决登仙台流程问题，没发现其他副作用,2017.7.7）
		local curWinInfo = WindowControler:getCurrentWindowView()
		-- 容错没有信息要返回
		if not curWinInfo then
			return
		end
		echo("最后再判断一下",self:getCurStepViewName(),curWinInfo.windowName)
		if self:getCurStepViewName() ~= curWinInfo.windowName then
			return 
		end

		self._preIsDone = false;
		self._waitForMessage = false;		

		self:showStepId();

		self._isTuroring = true;
		self:showTutorialLayer();

		self._tutorialLayer:setUIByTurtoralId(self._groupId, 
			self._tutorialId);
	end

	WindowControler:setUIClickable(false);
	FuncCommUI.setCanScroll(false);
	

	if self._tutorialLayer ~= nil then 
		local delayCall = FuncGuide.getDelayByFrame( self._groupId, self._tutorialId );
		if delayCall ~= 0 then 
			self._tutorialLayer:delayCallByFrame(showCall, delayCall);
		else 
			showCall();
		end 
	end 

end

function TutorialManager:reomveTutorialLayer()
	-- if self._tutorialLayer ~= nil then 
	-- 	self._tutorialLayer:dispose();
	-- 	self._tutorialLayer:removeFromParent();
	-- 	self._tutorialLayer = nil;
	-- end 
end

--当前引导id 触发界面
function TutorialManager:getCurStepViewName()
	self:showStepId();
	return FuncGuide.getWinName(self._groupId, self._tutorialId);
end

--析构
function TutorialManager:dispose()
	echo("-----TutorialManager:dispose----");
	FuncCommUI.setCanScroll(true);
	
	-- EventControler:clearOneObjEvent(self);
	-- self:reomveTutorialLayer();
	-- _tutorialManager = nil;
end

function TutorialManager:showStepId()
	echo("--_tutorialId ", tostring(self._tutorialId));
	echo("--_groupId ", tostring(self._groupId));
end

--整个游戏能否响应点击 
function TutorialManager:setUItouchable(isCanTouch)
	WindowControler:setUIClickable(isCanTouch);
end 

function TutorialManager:checkToOpenTurorial()
	if IS_CLOSE_TURORIAL ~= true or DEBUG_SKIP_PROLOGURE ~= true then 		
		local tutorialManager = TutorialManager.getInstance();
		-- if tutorialManager:isAllFinish() == false then 
			tutorialManager:startWork(self);
		-- end 
	end 
end

function TutorialManager:resetPologueTurtoailStep()
	LS:pub():set(prologueKeyInLS, "defaultValue");
end


--todo 这个判断是有问题的， 目前永远不知道是否已经完成所有引导
function TutorialManager:isAllFinish()
	--关闭引导，这样就算都完事了
	if IS_CLOSE_TURORIAL == true then 
		return true;
	end 

	return false;
end

-- 消除功能开启id
function TutorialManager:clearOpenSys()
	-- echoError("清空一下")
	self._openSysId = nil
end

-- 获取某个功能是否尚未进行过功能开启引导
function TutorialManager:isNeedOpenAnim( sysname )
	if IS_CLOSE_TURORIAL then
		return false
	else
		-- echoError("判断某功能是否需要显示功能开启", sysname)
		local id = FuncGuide.getUnlockGuideIdBySystemName(sysname)
		if not id then return false end
		-- 检查是否需要引导动画
		local flag = self:isShowSystemOpenById(id)
		-- FuncGuide.isShowSystemOpenById(id)
		if not flag then return false end
		-- echo("id", self._openSysId,id)
		-- dump(self._unlockGuides, "self._unlockGuides")
		for i,v in ipairs(self._unlockGuides) do
			if tonumber(v) == tonumber(id) then
				return true
			end
		end

		-- return tonumber(id) == tonumber(self._unlockId)
		return tonumber(id) == tonumber(self._openSysId)
	end
end
--2017.7.5
--[[
	暂停新手引导功能
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, 
                    {ispause = true})
]]
function TutorialManager:onSetTutorialPause( event )
	local isPause = event.params.ispause
	if isPause then
		self:pauseTutorial()
	else
		self:resumeTutorial()
	end
end

function TutorialManager:pauseTutorial()
	echo("暂停新手引导")
	self._isPaused = true
end

-- 恢复新手引导
function TutorialManager:resumeTutorial()
	echo("恢复新手引导")
	self._isPaused = false
end

-- 获取新手引导是否处于暂停状态
function TutorialManager:isTotorialPaused()
	return self._isPaused
end


-- 主城是否存在新功能开启
function TutorialManager:isHomeExistSysOpen()
	-- 引导关了一定不存在
	if IS_CLOSE_TURORIAL == true then return false end

	-- 没有步骤一定不存在
	if self._groupId == nil 
		or self._tutorialId == nil 
		or self._unlockId == nil 
	then 
		return false 
	end

	local flag,sysname = self:isShowSystemOpenById(self._unlockId)
	-- FuncGuide.isShowSystemOpenById( self._unlockId )
	return flag
end

-- 主城当前是否存在引导
function TutorialManager:isHomeExistGuide()
	-- 引导关了一定不存在
	if IS_CLOSE_TURORIAL == true then return false end
	-- 没有引导步骤一定不存在
	if self._groupId == nil or self._tutorialId == nil then
		return false
	end
	
	-- 检查触发消息是否是主城
	local paramInConfig = FuncGuide.getParameter(self._groupId, self._tutorialId)
	
	if TutorialEvent.CustomParam.worldComeToTop == paramInConfig then
		return true
	end

	return false
end

-- 当前界面是否存在引导
function TutorialManager:isCurViewExistGuide(viewName)
	-- 引导关了一定不存在
	if IS_CLOSE_TURORIAL == true then return false end
	-- 没有引导步骤一定不存在
	if self._groupId == nil or self._tutorialId == nil then
		return false
	end

	local guideView = self:getCurStepViewName()

	return guideView == viewName
end

--[[
	获取传入位置
]]
function TutorialManager:getCachePos()
	if self._cachePos then
		return {x = self._cachePos.x - GameVars.sceneOffsetX, y = self._cachePos.y - GameVars.sceneOffsetY}
	else
		return nil
	end
end

--[[
	做升级跳转
	检查将要进行的步骤是否需要先说话，需要则先说话不需要则跳转
]]
function TutorialManager:doLevelJump(func)
	local plotId = FuncGuide.getPerJumpPlot(self._unlockId)
	echo("引导 ============ doLevelJump",plotId,self._unlockId,"代码变了",WindowControler:getCurrentWindowView().windowName)
	if plotId and WindowControler:getCurrentWindowView().windowName ~= "WorldMainView" then -- 当前界面不能是主城
		--对话结束的回调
		local onUserAction = function(ud)
		    if ud.step == -1 and ud.index == -1 then
		        if func then
		        	func()
		        end
		    end
		end

		PlotDialogControl:showPlotDialog(plotId, onUserAction)
	else
		if func then
			func()
		end
	end
end

-- 返回是否进行战斗外布阵
function TutorialManager:isOutFormation()
	if not self._groupId or not self._tutorialId then return false end
	
	return (FuncGuide.getFinishMessage(self._groupId, self._tutorialId) == TutorialEvent.TUTORIAL_FINISH_FORMATION)
end

-- 试炼特殊布阵开关
function TutorialManager:isTrialFormation()
	return self._groupId == 10014 -- 写死了，不然无法分辨
end

-- 替换文本
function TutorialManager:transTextContent(str)
	if not str then return end
	-- 未登录不替换
	if not LoginControler:isLogin() then
	    return str
	end
	-- 把#1替换为主角名
	local newStr,replaceNum = string.gsub(str,"#1",UserModel:name())
	return newStr
end

-- 提供一个创建黑色引导区域的方法
function TutorialManager:createGrayLayer()
	local _ellipse = cc.ClippingEllipse:create();
	
	_ellipse:setContentSize(cc.size(GameVars.width, GameVars.height));
	_ellipse:setEllipsePosition(cc.p(240,300));
	_ellipse:setEllipseSize(cc.size(200,150));
	_ellipse:setColorEasePercent(0.2);
	_ellipse:pos(0, 0);
	
	local startOpacity = 0
	local maxOpacity = 150
	local endOpacity = 0

	local fadeItime = 0.5
	local delayTime = 1.5
	local fadeOTime = 0.5

	local _setMaskColor = _ellipse.setMaskColor

	function _ellipse:setMaskColor( c4f )
	    _setMaskColor(self, c4f)
	    self._c4f = c4f
	end

	function _ellipse:_fadeTo( fopacity,topacity, durTime, delay, callback )
	    local durTime = durTime or 0
	    local topacity = topacity or 0
	    local fopacity = fopacity or 0
	    local delay = delay or 0

	    local nowOpacity = fopacity
	    self:setMaskColor(cc.c4f(0.0,0.0,0.0,nowOpacity/255.0))
	    -- 停止以前可能有的事件
	    self:stopAni()
	    -- 开启新事件
	    self:scheduleUpdateWithPriorityLua(function(dt)
	        if delay > 0 then
	            delay = delay - dt
	            return
	        end
	        nowOpacity = nowOpacity + (topacity - fopacity) * dt / durTime
	        if fopacity > topacity and nowOpacity <= topacity then
	            nowOpacity = topacity
	            self:stopAni()
	        end

	        if fopacity <= topacity and nowOpacity >= topacity then
	            nowOpacity = topacity
	            self:stopAni()
	            if callback then callback() end
	        end
	        -- echo("from",fopacity,"topacity",topacity,"nowOpacity",nowOpacity)
	        self:setMaskColor(cc.c4f(0.0,0.0,0.0,nowOpacity/255.0))
	    end, 0)
	end

	function _ellipse:showAni()
		self:visible(true)
	    local nowOpacity = self._c4f.a * 255
	    -- 渐现
	    self:_fadeTo(nowOpacity, maxOpacity, fadeItime, nil, function()
	        -- 停留后渐隐
	        self:_fadeTo(maxOpacity, 0, fadeOTime, delayTime)
	    end)
	end

	function _ellipse:stopAni()
		self:visible(false)
		self:unscheduleUpdate()
	end

	_ellipse:setMaskColor(cc.c4f(0.0,0.0,0.0,0/255.0));

	return _ellipse
end

--[[
	开启引导时的容错检查
	如果开启引导已经是第n次了，就直接结束这一步引导
]]
function TutorialManager:checkTutorialStuck()
	-- 调试情况下不开启检查
	if SHOW_CLICK_RECT then return end
	if not self._unlockId then return end
	-- 没有获取到证明从未初始化过，初始化一个
	local list = LS:prv():get(StorageCode.tutorial_avoid_stuck)
	if not list then
		-- 初始化一个列表，防止稀疏数组的问题
		list = {}
		for i=2,25 do
			list[tostring(i)] = 0
		end
	else
		list = json.decode(list)
	end

	if not list[self._unlockId] then list[self._unlockId] = 0 end

	list[self._unlockId] = list[self._unlockId] + 1

	LS:prv():set(StorageCode.tutorial_avoid_stuck,json.encode(list))

	-- 第三次进就消掉本次引导,强制引导不会消除
	if list[self._unlockId] < 3 or self._unlockId == "2" then return end	

	local unlockId = self._unlockId
	self._unlockId = nil
	self._groupId = nil

	-- 将步骤置为等待开启
	TutorServer:beginTutorStep(waitForSystemOpen)
	-- 去掉这一步引导
	TutorServer:unLockUpdate(unlockId, false)

	-- 存一个log
	local str = string.format("unlockId:%s, groupId:%s",unlockId,self._groupId)
	ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA, ClientTagData.tutorialAvoidStuck, str)
end

--[[
	获取位置的通用方法
]]
function TutorialManager:getPosByEntrance(viewName, entranceName)
	if viewName == "ChallengeView" then
		self._cachePos = ChallengeModel:getChallengeSystemPos(entranceName)
	end
	if viewName == "ChallengePvpView" then
		self._cachePos = ChallengePvPModel:getChallengeSystemPos(entranceName)
	end

	if viewName == "WorldMainView" then
		if entranceName == "npc" then
			self._cachePos = WorldControler:getCurNpcPosition()
		elseif string.find(entranceName, "more") then
			local temp = string.split(entranceName, "_")
			self._cachePos = HomeModel:getMoreButtonPos(temp[2])
		else
			self._cachePos = HomeModel:bySysNameGetCtnPos(entranceName)
		end
	end

	-- 仙盟酒家特殊步骤直接特殊处理
	if self._groupId and self._tutorialId then
		if tonumber(self._groupId) == 10150 then
			local temp = {
				[5] = 1,
				[6] = 2,
				[9] = 3,
				[10] = 4,
			}
			local window = WindowControler:getWindow("GuildActivityInteractView")
			if temp[tonumber(self._tutorialId)] and window then
				self._cachePos = window:getGuidingPos(temp[tonumber(self._tutorialId)])
			end
		end
	end
end

--[[
	获取需要做弱引导的系统的接口
]]
function TutorialManager:getEntranceGuide(viewName)
	if #self._triggerGuides == 0 then return {} end
	local result,insertFunc = Tool:getInsertFunc()

	-- 挨个检查
	for _,id in ipairs(self._triggerGuides) do
		local preEntrance = FuncGuide.getPreEntranceById(id)
		for _,info in ipairs(preEntrance or {}) do
			if info.view == viewName then
				-- 入口名插入结果
				insertFunc(info.entrance)
			end
		end
	end

	return result
end

--[[
	检查是否还有新功能开启	
]]
function TutorialManager:isShowSystemOpenById(id)
	local flag,sysname = FuncGuide.isShowSystemOpenById( id )
	-- 存取一下本地的信息，保证一般情况下只会看一次
	-- tutorial_sysopen_check
	local list = LS:prv():get(StorageCode.tutorial_sysopen_check)
	if not list then 
		list = {} 
	else
		list = json.decode(list)
	end
	-- 需要功能开启且本地没有记录
	return flag and list[sysname] ~= true,sysname
end

--[[
	返回是否有需要展示的新功能开启效果，（仅对于触发式引导）
]]
function TutorialManager:isHasTriggerSystemOpen()
	-- 主界面存在强引导的情况下，不触发弱引导的飞图标
	if self:isHomeExistGuide() or self:isHomeExistSysOpen() then return false,{} end

	if #self._triggerGuides == 0 then return nil end
	local result = {}

	for _,id in ipairs(self._triggerGuides) do
		local flag,sysname = self:isShowSystemOpenById(id)
		if flag then
			table.insert(result,sysname)
		end
	end

	return not empty(result), result
end

-- 是否完成了1-1这一步引导（为了记一下首次进入六界的动画）
function TutorialManager:isFinishFirstStep()
	-- 当前步骤不是第一步就是完成了
	return not (self._groupId == 1 and self._tutorialId == 1)
end

--[[
	wtf
	聚魂是否需要直接出现在树顶
	引导步骤为 3-4 10006-4 的时候直接出现在树顶
]]
function TutorialManager:isGatherSoulOnTreeTop()
	return (self._groupId == 3 and self._tutorialId == 4 or self._groupId == 10006 and self._tutorialId == 4)
end