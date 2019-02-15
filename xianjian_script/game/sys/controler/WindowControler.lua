local WindowControler={}
WindowControler.VIEW_LEVEL_MAX = 9 --view的最大级别数字
WindowControler.hasCreatWindowNums = 0


WindowControler.ZORDER_LOADING = 9999 		--loadui的zorder 最大
WindowControler.ZORDER_INPUT = 1100 		--输入文本的 高度, 不能超过loading 但是大于所有的tips
WindowControler.ZORDER_TIPS =  999 			--一些信息提示框  他也是ui

--最上层的是否可以点击层
WindowControler.ZORDER_UI_CONTROL_CLICKABLE_OR_NOT = 998 

WindowControler.ZORDER_Tutorial = 995 		--新手引导层 他是node

--盖在上层的node，主界面有个右上角有个其他玩家信息 要点哪都关闭
WindowControler.ZORDER_TopOnUI = 990

WindowControler.ZORDER_PowerRolling = 985	
--网络错误的窗口要放到最高层
WindowControler.ZORDER_SERVERERROR = 9999

--进战斗前的ui数量
WindowControler._beforBattleUINums = 0


--增加系列cache方法
--BindExtend.cache(WindowControler)
--窗口层级管理 {window1,window2,...	}
WindowControler.windowInfo = {}

--缓存的window信息,{ {root=rootName,name=windowName,params= {}},...	}
WindowControler.windowCacheInfo = {}



WindowControler.lockTexture = false 	--是否锁住材质不让释放,因为可能在异步加载的过程中会释放


--缓存窗口的层级信息 
--[[
	winName = 0
	
]]
WindowControler._lastZorderInfo = {}
function WindowControler:getWindowLastZorder(winName  )
	if not self._lastZorderInfo[winName] then
		return 0
	end
	return self._lastZorderInfo[winName] or 0
end


--现在打开的view，没有考虑zorder，showWindowByRoot就算加一个，closeWindow就减一个 todo 完善我
-- WindowControler.viewOpens = {};

-- ============================== 霸道分割线 ============================== --
-- view基础控制
-- ============================== 霸道分割线 ============================== --


function WindowControler:init()
	--升级后接受信息
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
    	self.showLevelUp, self);
    EventControler:addEventListener(UserEvent.USEREVENT_CHANGE_SPIRITSTONES,
    	self.showSpiritStones,self)
end

function WindowControler:showLevelUp(event)
	if WindowControler:isCurViewIsGm() == true then 
		local newLvl = event.params.level;
		WindowControler:showTopWindow("CharLevelUpView", newLvl);
	else 
		--等级有变化，才弹
		local isLvlup, lvl = UserModel:isLvlUp();
		if isLvlup == true then 
			WindowControler:showTopWindow("CharLevelUpView", lvl);
		end 
	end 
end
function WindowControler:showLevelUpReward(event)
	-- if TutorialManager.getInstance():isHomeExistGuide() 
 --    	or TutorialManager.getInstance():isHomeExistSysOpen() then
 --        return 
 --    end
	-- local level = LS:prv():get("LevelUpRewardShow",-1)
	-- if tonumber(level) > 1 then
	-- 	---新手引导，和新系统开启
	-- 	echo("________弹出升级奖励_______________________")
	--     WindowControler:showWindow("LevelRewardView")
	--     LS:prv():set("LevelUpRewardShow",-1)
	-- end
end



--[[
	设置全局可不可点击，管不了战斗界面，tips可点（让掉线重连可以点）
	true 是 可点击
	false 是不可点击
	**分系统控制自己系统勿用**可用
	UIBase:disabledUIClick
	UIBase:resumeUIClick
]]
function WindowControler:setUIClickable(isClickable)
	function createListener()
		local clickableListener = nil;
		local node = display.newNode();
		node:setContentSize(cc.size(GameVars.width *2,GameVars.height*2))
		node:anchor(0.5,0.5)
		node:pos(GameVars.cx ,GameVars.cy)
		WindowControler:getScene()._topRoot:addChild(node, 
			WindowControler.ZORDER_UI_CONTROL_CLICKABLE_OR_NOT);


		node:setTouchedFunc(GameVars.emptyFunc, nil, true, nil, nil, false)

		return node;
	end

	if not self._globalNode then
		self._globalNode = createListener()
	end

	self._globalNode:setVisible(not isClickable )
	-- if isClickable then
	-- 	echoError("放开了点击 =============")
	-- else
	-- 	echo("屏蔽了点击 =============")
	-- end
	--todo 主界面的listener 搞一下 要不还能拖动主界面，再看看npc的点击是不是用listener了
end

--只创建节点 不加载到界面上
function WindowControler:createWindowNode(winName)
	local cfg = WindowsTools:getUiCfg(winName)
	local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,y=cfg.pos.y - GameVars.UIOffsetY};

	local ui = WindowsTools:createWindow(winName);

	-- ui:ignoreAnchorPointForPosition(false);
	-- ui:setAnchorPoint(cc.p(0,0));
	ui:setPosition(newPos);
	return ui;
end

-- 特殊接口，在底层强行修改界面层级（注意，战斗里弹窗的特殊需求导致的写法，以后不要使用）
function WindowControler:setSpWindowRoot(rootName)
	self._spWinRoot = rootName
end

--显示正常root的某个view
function WindowControler:showWindow(winName,...)
	-- if "RechargeMainView" == winName then 
	-- 	-- WindowControler:showTips( { text = "仙玉不足" } )
	-- else 
		return self:showWindowByRoot("root",winName,...)
	-- end 
end


--显示战斗窗口
function WindowControler:showBattleWindow(winName,...  )
	return self:showWindowByRoot("battle",winName,...)
end

--显示新手引导层的windows
function WindowControler:showTutoralWindow( winName,... )
	return self:showWindowByRoot("tutoral",winName,...)
end

--显示top窗口
function WindowControler:showTopWindow(winName,...  )
	return self:showWindowByRoot("top",winName,...)
end

function WindowControler:showHighWindow(winName,...  )
	return self:showWindowByRoot("high",winName,...)
end

function WindowControler:systemNameIsOpen(winName)
	local  winNametable = FuncCommon.SYSTEM_VIEW_TO_NAME[winName]
	if winNametable ~= nil then
		local isopen,level,typeid,lockTip,is_sy_screening = nil
		if #winNametable ~= 0 then
			for i=1,#winNametable do
				isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(winNametable[i])
				if is_sy_screening then
					break
				end
			end
		end
		-- local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(winName)
		if is_sy_screening then
			WindowControler:showTips(FuncCommon.screeningstring);
			return false
		end
	end
	return true
end

--显示窗口
function WindowControler:showWindowByRoot(rootName,winName,...  )
	rootName = three(self._spWinRoot, self._spWinRoot, rootName)
	
	if not winName then
		error("WindowControler show view params is nil!")
		return nil
	end
	--是否屏蔽系统
	local isopen =  self:systemNameIsOpen(winName)
	if not isopen then
		return nil 
	end

   
    local cfg = WindowsTools:getUiCfg(winName )
     
	if cfg.ui then
	 	echo("\n============Open The Window Name =======--->>lua:"..winName ..",----------->flashUI:"..cfg.ui)
	else
	 	echo("\n============Open The Window Name =======--->>lua:"..winName )
	end
    local oldWindow = self:getWindow(winName)
	if oldWindow then
		if cfg.foreverNew then
			oldWindow:startHide()
		else
			return self:popWindow(winName,...)
		end

		
	end
	--缓存一个ui打开时的 纹理信息
	TextureControler:noteOneTextureState( winName )

	local t1 = os.clock()
	local scene = self:getCurrScene()
	local rootCtn
	if rootName == "battle"  then
		rootCtn = scene._battleRoot
	elseif rootName =="root" then
		rootCtn = scene._root
	elseif rootName =="tutoral" then
		rootCtn = scene._tutoralRoot
	elseif rootName =="top" then
		rootCtn = scene._topRoot
	elseif rootName =="high"  then
		rootCtn = scene._highRoot
	else
		echoError("错误的rootName:", rootName)
		rootCtn = scene._root
	end

	

	local newPos = {x=cfg.pos.x + GameVars.UIOffsetX  ,y=cfg.pos.y - GameVars.UIOffsetY};
	
	local ui = WindowsTools:createWindow(winName,...):addto(rootCtn):pos(newPos)
	--缓存root名称 和 参数
	ui._cacheInfo = {root = rootName,name = winName,zorder = #self.windowInfo +1, params = {...}}

	--如果有 缓存的winZorder
	local lastZorder = self:getWindowLastZorder(winName) 
	if lastZorder > 0 then
		ui:zorder(lastZorder)
		ui._cacheInfo.zorder = lastZorder
	else
		--那么新创建的ui需要加上
		ui._cacheInfo.zorder = ui._cacheInfo.zorder + self._beforBattleUINums
		ui:zorder(ui._cacheInfo.zorder)
	end

	-- for i=1,#self.windowInfo do
	-- 	echo(i)
	-- end

	--如果这个创建的窗口层级 小于总层级 说明是需要插入进去
	if ui._cacheInfo.zorder <= #self.windowInfo then
		
	end

	self._lastZorderInfo[winName] = nil

	table.insert(self.windowInfo, ui)

	if not cfg.hideBg then
		local color 
		if cfg.bgAlpha then
			color = cc.c4b(0,0,0,cfg.bgAlpha)
		else
			color = cc.c4b(0,0,0,150)
		end

		local layer =  self:createCoverLayer(nil,nil,color,ui:checkIsFullUI(),cfg.screen):addTo(ui,-10)
		layer:visible(false)
		ui.colorLayer=layer;
	end
	
	-- dump(ui:getAnchorPoint());
	if not ui then
		error("WindowsTools create window error")
		return
	end	
	ui:onAddtoParent()
    -- 
	-- 开始显示
	ui:startShow()

	-- 保存本次打开的 window
	self.lastWinName = winName

	echo(os.clock()-t1,"_打开窗口时间:",winName,"zorder:",ui._cacheInfo.zorder)

	self:tostring();

	self:setTouchNumbers()

	return ui
end
function WindowControler:setTouchNumbers()
	GameVars.clickNumberTimes = 0
end

--判断是否有window
function WindowControler:checkHasWindow( windowName )
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			return true
		end
	end
	return false
end

--让window显示最上层
function WindowControler:popWindow( windowName ,...)
	local view
	local index =0
	for i,v in ipairs(self.windowInfo) do
		if v.windowName == windowName then
			view = v
			index = i
			table.remove(self.windowInfo,i)
			break
		end
	end
	echo("popWindow:",windowName,view,tolua.isnull(view),index)
	table.insert(self.windowInfo, view)
	for i,v in ipairs(self.windowInfo) do
		v:zorder(i+ self._beforBattleUINums)
		v._cacheInfo.zorder = i + self._beforBattleUINums
	end
	self:topWindowBecomeActive()
	--更新ui显示
	self:updateUiVisible()

	view:onSelfPop(...)

	return view

	-- view:startShow()
end

--移除一个window ,根据名字
function WindowControler:removeWindowByWinName( windowName )
	local index = -1
	for i,v in ipairs(self.windowInfo) do
		if v.windowName == windowName then
			index = i
			break
		end
	end
	if index ~= -1  then
		local originLen = #self.windowInfo
		table.remove(self.windowInfo,index)
		--移除一个window 需要让其他层的所有window zorder 减1
		for i=index,originLen-1  do
			local winView = self.windowInfo[i]
			winView._cacheInfo.zorder = winView._cacheInfo.zorder - 1
			winView:zorder(winView._cacheInfo.zorder)
		end


		if index == originLen then
			self:topWindowBecomeActive()
		end
	end

	--更新ui显示
	self:updateUiVisible()
	self:tostring()
end

--当ui发生变化的时候  更新ui的 visible
function WindowControler:updateUiVisible(  )
	if GameLuaLoader:isGameDestory() then
		return
	end
	local length = #self.windowInfo
	local root = self:getCurrScene()._root
	local btRoot = self:getCurrScene()._battleRoot
	for i=length,1,-1 do
		local uiView = self.windowInfo[i]
		local parent = uiView:getParent()
			--非全屏的ui肯定是显示的
		uiView:visible(true)
		if uiView:checkIsFullUI()   then
			local windowName = uiView.windowName
			for ii=1,i-1 do
				--隐藏其他所有被压着的ui
				local secondUiView = self.windowInfo[ii]
				local secondParnt = secondUiView:getParent()
				if secondParnt == root or secondParnt == btRoot then
					-- 解决loadingView到六界主城闪黑屏问题
					secondUiView:visible(false)
					echo("隐藏其他ui",secondUiView.windowName,"当前ui:",windowName)
				end
			end
			return
		end
		
	end
end

-- 是否是登录加载界面
function WindowControler:isLoginLoadingView(windowName)
	return windowName == "LoginLoadingView"
end

--获取window
function WindowControler:getWindow( windowName )
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			return v
		end
	end
	return nil
end

--获取某个window的层级 如果没有 就是0
function WindowControler:getWindowOrder( windowName )
	for i,v in ipairs(self.windowInfo) do
		if v.windowName ==windowName then
			return i
		end
	end
	return 0
end

--windowInfo 堆栈变化时，调用最顶层view的 onBecomeTopView 方法
function WindowControler:topWindowBecomeActive()
	local top = self.windowInfo[#self.windowInfo]
	if top then
		top:onBecomeTopView()
		EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
	        {viewName = top.windowName});
	end
end



--关闭某个层级的view
function WindowControler:closeWindow(windowName)
	local window = self:getWindow(windowName)
	if window then
		window:startHide()
	end
end

--移除某个window ,只是把他从windowInfo里面移除
function WindowControler:removeWindowFromGroup( windowName )
	echo("移除某个window：",windowName)
	local scene = self:getCurrScene()
	--scene._root:removeChildByName("BgLayer",true);

	self:removeWindowByWinName(windowName)

	local curWinInfo = self:getCurrentWindowView();
	if curWinInfo ~= nil then 

		echo(curWinInfo.windowName ,"____最新的一个uiname")
		--如果这个窗口是一个全屏ui 那么让地下的
		if curWinInfo:checkIsFullUI() then
			curWinInfo:visible(true)
		end
		
		--回到主界面  --wk修改 “WorldMainView” 20180421
		if curWinInfo.windowName == "WorldMainView" then
			EventControler:dispatchEvent(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW,
				{lastViewName = windowName,currentVieName = curWinInfo.windowName})
		end
		
	    EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_VIEW_CHANGE, 
	        {viewName = curWinInfo.windowName});
	end 
	self.hasCreatWindowNums = self.hasCreatWindowNums +1
	--每6次关闭窗口 做一次lua垃圾回收
	if self.hasCreatWindowNums %4 == 0 then
		collectgarbage("collect")
	end
end

function WindowControler:isCurViewIsGm()
	local curViewName = self:getCurrentWindowView().windowName;
	if curViewName == "TestConnView" then 
	return true;
	else 
		return false;
	end 
end

function WindowControler:isCurViewIsHomeTown()
	return WindowControler:checkCurrentViewName("WorldMainView")
end

--判断最顶层的ui是不是自己 传递进来的windowName
function WindowControler:checkCurrentViewName( windowName )
	if not self:getCurrentWindowView() then
		return false
	end
	local curViewName = self:getCurrentWindowView().windowName;
	
	if windowName == curViewName then
		return true
	end
	return false
end


function WindowControler:getCurrentWindowView()
	--取出zorder最大的一个界面
	local index = -1;
	for k,v in pairs(self.windowInfo) do
		local uiZorder = v:getLocalZOrder(); 
		if uiZorder >= index then 
			index = k;
		end 
	end

	return self.windowInfo[index]
end

--关闭所有的ui
function WindowControler:clearAllWindow(  )
	for k,v in pairs(self.windowInfo) do
		if not tolua.isnull(v) then
			v:deleteMe()
		end
		
	end

	self.windowInfo = {}
end


--创建一个覆盖的层 主要用来覆盖底下的 点击事件
function WindowControler:createCoverLayer( x,y ,color,isFullUi,screen)
	x= x or - GameVars.UIOffsetX 
	y = y or GameVars.UIOffsetY
	if not screen then
		x = x - GameVars.widthDistance/2
	end
	-- y = y - GameVars.height 
	local layer
	--如果是全屏ui
	if isFullUi then         
		layer = display.newNode():pos(x,y)
	else
		color = color or cc.c4b(0,0,0,120)
		layer = display.newColorLayer(color):pos(x,y)

	end

	layer:setName("BgLayer");
	layer:setContentSize(cc.size(GameVars.fullWidth,GameVars.height))
	layer:anchor(0,1)
    layer:setTouchEnabled(true)
    layer:setTouchSwallowEnabled(true)

    -- dump(layer:getContainerBox(),"__layerBox")

    return layer
end

--切换场景
function WindowControler:chgScene(sceneName, hasTransition)
	local oldScene = self:getScene()
	if oldScene then
		oldScene:removeFromParent()
	end

	local scene = require("app.scenes." .. sceneName).new()

	local transitionType = nil
	if hasTransition then
		transitionType = "fade"
	end
	display.replaceScene(scene, transitionType, 0.6 )

	self.loadView = nil
	return scene
end

--判断并获取当前场景
function WindowControler:getScene()
	return display.getRunningScene()
end

function  WindowControler:getDocLayer()
    local scene = self:getScene()
    return scene.__doc
end

function WindowControler:getCurrScene()
	return display.getRunningScene()
end

function WindowControler:enabledClickEffect( val )
	local scene = self:getCurrScene()
	if scene["enableClickEffect"] then
		scene["enableClickEffect"](scene,val)
	end
end

WindowControler._loadingCount =0

--显示load
function WindowControler:showLoading(  )
	if self._isLoading then
		return
	end
	self._loadingCount = self._loadingCount +1
	if not self.loadView then

		self.loadView = WindowsTools:createWindow("ServerLoading");
		local scene = self:getCurrScene()
		local cfg = WindowsTools:getUiCfg("ServerLoading")

		local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,y=cfg.pos.y - GameVars.UIOffsetY};
		local layer = self:createCoverLayer(nil,nil,cc.c4b(255,255,0,0),true,cfg.screen):addTo(self.loadView,0)
		self.loadView:pos(newPos):addto(scene._topRoot,self.ZORDER_LOADING) --:zorder(self.ZORDER_LOADING)
	else
		self.loadView:visible(true)
	end
	self._isLoading = true
	self.loadView:startShow()

	--loading时候，让新手引导层不可点击
    if LoginControler:isStartPlay() == true and 
		TutorialManager.getInstance():isAllFinish() == false and 
		 TutorialManager.getInstance():isTutoring() == true then 

		 self._alreadyHideTutorlayer = true;
		 TutorialManager.getInstance():hideTutorialLayer();
	end 
end

--隐藏loading
function WindowControler:hideLoading()
	if not self._isLoading then
		return
	end
	self._isLoading = false
	-- if true then
	-- 	return
	-- end
	self._loadingCount = self._loadingCount -1
	if self.loadView then
		self.loadView:visible(false)
		self.loadView:hideLoadingAnim()
		--关loading时候，让新手引导层不可点击
	    if self._alreadyHideTutorlayer == true then 
		 	TutorialManager.getInstance():showTutorialLayer();
		 	self._alreadyHideTutorlayer = false;
		end 
	end
end

--[[
	是否正在Loading中
]]
function WindowControler:isLoading()
	return self._isLoading ;
end

--显示错误警告
--[[
	info = {text:提示文本信息  }
	delayTime = 文本显示持续时间
	offsetY = Y轴上的偏移值
]]

function WindowControler:showTips(info, delayTime, offsetY,isGveScore)
	local scene = self:getCurrScene()
	if not scene then
		return
	end
	if not self._tips then
		self._tips = WindowsTools:createWindow("Tips"):addto(scene._highRoot,WindowControler.ZORDER_TIPS)
	end
	AudioModel:playSound("s_com_tip")


	local cfg = WindowsTools:getUiCfg("Tips" )
	local offsetY = offsetY or 0
	local newPos = {x= GameVars.cx - 16,y= GameVars.height-170-90 + offsetY};
	self._tips:pos(newPos.x,newPos.y)
	if isGveScore then
		local scoreView = WindowsTools:createWindow("GuildActivityScorePopupView"):addto(scene._highRoot,WindowControler.ZORDER_TIPS)
		local cfg = WindowsTools:getUiCfg("GuildActivityScorePopupView" )
		local offsetY = offsetY or 0
		local newPos = {x= GameVars.cx-80,y= GameVars.height-170-90-20 + offsetY};
		scoreView:pos(newPos.x,newPos.y)
		scoreView:startShow(info, delayTime)
		scoreView:visible(true)
		self._tips:visible(false)
	else
		self._tips:startShow(info, delayTime)
		self._tips:visible(true)
	end

end
--//系统公告提示框,注意,此函数只能在主场景中调用
function WindowControler:showNotice()
	local scene = self:getCurrScene()
	if not self._tips then
		self._tips = WindowsTools:createWindow("TrotHoseLampView"):addto(scene._topRoot,WindowControler.ZORDER_TIPS)
	end
--	AudioModel:playSound("s_com_tip")

	local cfg = WindowsTools:getUiCfg("TrotHoseLampView" )

	local newPos = {x= GameVars.cx,y= GameVars.height-170-90 };
	self._tips:pos(newPos.x,newPos.y)
	self._tips:startShow(info)
	self._tips:visible(true)
end
--[[
	--todo 暂时没有考虑富文本

	params = {
		title = "", --标题
		des = "",   --内容
		isSingleBtn = bool, --1个btn还是2个btn 默认 true
		firstBtnCallBack = func, --第1个btn的点击相应 默认(关闭界面)
		secondBtnCallBack = func, --第2个btn的点击相应 默认(关闭界面)
		firstBtnStr = "",  --第1个btn上的字符 默认是 "取消" （一个btn是"确定"）
		secondBtnStr = "",  --第2个btn上的字符 默认是 "确定"
	}
]]
function WindowControler:showAlertView(params)
	if params.isSingleBtn == nil then
		params.isSingleBtn = true;
	end 

	self:showWindow("MessageBoxView", params);

end

-- ============================== 霸道分割线 ============================== --
--退出游戏
function WindowControler:exit()
	cc.Director:getInstance():endToLua()
	if device.platform == "ios" then
		--实测发现 android部分机型调用os.exit有几率异常退出
		os.exit()
	end
end

--是否需要跳回主城
function WindowControler:isNeedJumpToHome()
	--没有完成强制新手的话，每次都回到主界面 
	--echo("--isNeedJumpToHome--", tostring(self._needJumpToHome),"===============");
	return self._needJumpToHome or false;
end

--每次回到主城，清除之
function WindowControler:setisNeedJumpToHome(bool)
	--echo("--setisNeedJumpToHome--", tostring(self._needJumpToHome) ,"=====================");
	self._needJumpToHome = bool;
end

--一键回主界面`
function WindowControler:goBackToHomeView(noDelay)
	function delayCall( ... )
		--是不是在战斗中 战斗中来个标记,loading的时候读这个标记，直接跳
		local viewToHide = {};

		for i = 1,#self.windowInfo do
			local v = self.windowInfo[i];

			if v.windowName == "WorldMainView" then
				
			else
				table.insert(viewToHide, v);
			end
		end

		for k, v in pairs(viewToHide) do
			v:startHide();
		end
		-- 执行完后打开
		-- WindowControler:setUIClickable(true)
	end
	echo("强制回主城goBackToHomeView==========")

	--一键回主界面的时候 需要 关闭探索 
	-- GuildExploreServer:onExitExplore(true )
	GuildExploreServer:handleCloseServer(  )

	-- 屏蔽掉点击
	-- WindowControler:setUIClickable(false)
	if noDelay then
		delayCall()
	else
		--延迟是因为寻仙返回，配一键返回主城，声音有问题（不延迟效果会有问题，寻仙已经不存在了，先加回来看情况）
		self:globalDelayCall(delayCall, 1 / GameVars.GAMEFRAMERATE );
	end
end

--一键回登入
function WindowControler:goBackToEnterGameView()
	LoginControler:restarGame()
end

--清除没有被使用的材质 一般主要在进战斗 出战斗的时候 或者大量使用icon的ui会调用
--rightnow 是否是立即移除
function WindowControler:clearUnusedTexture( rightnow )
	--如果是使用散图的  那么不清理 
	if CONFIG_USEDISPERSED then
		return
	end
	--进入战斗之前移除没有使用的texture
    local tempFunc = function (  )
    	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end

    --直接立马清除未使用的材质,不需要延迟,否则可能造成线程错乱
    tempFunc()

    
end

--关闭所有的ui
function WindowControler:closeAllWindow(  )
	local length = #self.windowInfo
	for i=length,1,-1 do
		local win = self.windowInfo[i]
		win:startHide()
	end
	self.windowInfo = {}
end


--全局的延迟器, 如果是ui里面需要用 延迟函数的 一定要用ui自己的delayCall,不允许使用全局delaycall,否则 当ui关闭的时候
--还会执行全局dealyCall 
function WindowControler:globalDelayCall(func,delay )
	local scene = self:getCurrScene()
	scene:delayCall(func, delay)
end

--清除全局注册的所有delayCall
function WindowControler:clearGlobalDelay(  )
	local scene = self:getCurrScene()
	scene:stopAllActions()
end

--忽略的窗口
local ignoreClearArr = {"LoginLoadingView","GuildActivityMainView","GuildActivityInteractView"}

--当进入战斗的时候
function WindowControler:onEnterBattle( callBack )
	--遍历所有的WindowInfo

	if self.hasCache == true then
		self:globalDelayCall(callBack, (1)/GameVars.GAMEFRAMERATE )
		return
	end

	self.windowCacheInfo = {}
	self.hasCache = true
	

	self._beforBattleUINums = #self.windowInfo

	--分帧删除目前已经存在的场景
	local length = #self.windowInfo

	local tempClearUI = function ( ui,uiName )
		echo(uiName,"__onEnterBattle_deleteMe_")
		if not tolua.isnull(ui) then
			ui:deleteMe()
		else
			echo("这个ui可能是刚执行startHide函数",uiName)
		end
		
	end

	for i=#self.windowInfo,1,-1 do
		local v = self.windowInfo[i]
		local cacheInfo = v._cacheInfo
		--存储下复原时候的缓存数据
		cacheInfo.resumeData = v:getEnterBattleCacheData()
		--只移除root上的所有view
		if cacheInfo.root == "root"  then
			local winName = cacheInfo.name
			if not table.indexof(ignoreClearArr, winName) then
				echo("移除当前window:",cacheInfo.name)
				table.insert(self.windowCacheInfo,1, cacheInfo)
				table.remove(self.windowInfo,i)
				self:globalDelayCall(c_func(tempClearUI,  v, v.windowName), i/GameVars.GAMEFRAMERATE )
				self._lastZorderInfo[winName] = i
			else
				echo("忽略移除的window:",cacheInfo.name)
				self._beforBattleUINums = self._beforBattleUINums -1
			end
		else
			self._beforBattleUINums=self._beforBattleUINums -1
		end
	end

	local tempFunc = function (  )
		self:clearUnusedTexture()
		if callBack then
			callBack()
		end
	end
	self:globalDelayCall(tempFunc, (length+1)/GameVars.GAMEFRAMERATE )

	echo("还剩多少个ui:",#self.windowInfo)

end


--给窗口排序
function WindowControler:sortWindow(  )
	local sortFunc = function ( w1,w2 )
		return w1._cacheInfo.zorder < w2._cacheInfo.zorder
	end

	table.sort(self.windowInfo,sortFunc)

end

--等ui回复完毕
function WindowControler:onResumeComplete(  )
	self._beforBattleUINums = 0
	self._lastZorderInfo ={}
	--给窗口重新排序
	self:sortWindow()
	self:tostring()
	self.hasCache = false
end

--打印窗口层级
function WindowControler:tostring()
	-- echo("窗口层级信息：")
	-- for i,v in ipairs(self.windowInfo) do
	-- 	echo("name:"..v._cacheInfo.name..",zorder:"..v._cacheInfo.zorder)
	-- end
end


--当退出战斗的时候
function WindowControler:onExitBattle(  )
	--遍历所有缓存的窗口信息

	--做一次垃圾收集
	if not Fight.isDummy then
        collectgarbage("collect")
    end
	local progressActions = {}

	--销毁游戏
	local destoryGameInfo = {
		percent = 10,
		frame = 10,
		action = function (  )
			--其实这个就是operation、因为仙界对决中的resultInfo 没有operation 所以这么取
			local handleInfo = BattleControler.gameControler.logical.handleOperationInfo 
	        local resultInfo = BattleControler:getBattleDatas(BattleControler.gameControler.isSkip)
	        local logs = BattleControler.gameControler.verifyControler:encrypt()


	        -- -- 因为多人战斗 可能弹出结算的时候 win或者lose界面已经出了,会造成这2个界面永远无法关闭
	        -- local winUI = self:getWindow("BattleWin")
	        -- if winUI then
	        -- 	winUI:startHide()
	        -- end
	        -- local loseUI = self:getWindow("BattleLose")
	        -- if loseUI then
	        -- 	loseUI:startHide()
	        -- end
	        -- 暂停退出不做复盘校验
	        if resultInfo.isPauseOut ~= 1 and resultInfo.isSkip ~= 1  then
	        	-- 取一个复盘的条件
	        	local check = BattleControler.gameControler:isNeedCheckDummy()
	        	local isReplay = BattleControler.gameControler:isReplayGame()
				BattleControler.gameControler:deleteMe()
				BattleControler.gameControler = nil	
				--做复盘校验
				if check and (not DEBUG_SERVICES) and IS_CHECK_DUMMY and (not Fight.isDummy) and (not isReplay) then
	                BattleControler:checkBattleDummy(handleInfo,logs)
	            end
	         else
	         	BattleControler.gameControler:deleteMe()
				BattleControler.gameControler = nil	
	        end
	        -- 将battleRoot上的所有UI 都关闭掉
	        local length = #self.windowInfo
	        local btRoot = self:getCurrScene()._battleRoot
	        for i = length,1,-1 do
	        	local uiView = self.windowInfo[i]
	        	local parent = uiView:getParent()
	        	if parent == btRoot and uiView.startHide and uiView.windowName ~= "BattleView" then
	        		echo ("这个ui",uiView.windowName,"没有被关闭")
	        		uiView:startHide()
	        	end
	        end
		end
	}
	--清理未使用纹理
	local clearUnUserTexInfo = {
		percent = 20,
		frame = 5,
		action = function (  )
			WindowControler:clearUnusedTexture()
			--同时校验下战斗纹理是否有常驻的
			TextureControler:compareTextureState("Battle")
		end
	}

	table.insert(progressActions, destoryGameInfo)
	table.insert(progressActions, clearUnUserTexInfo)

	local perViewFrame = math.ceil( 40/#self.windowCacheInfo )
	local perPercent =  math.ceil( 100/#self.windowCacheInfo )

	local createResumeWindow = function (cacheInfo)
		local zorder = cacheInfo.zorder
		local window = self:showWindowByRoot(cacheInfo.root,cacheInfo.name,unpack(cacheInfo.params))
		window:onBattleExitResume(cacheInfo.resumeData)
		-- window:zorder(zorder)
		-- echo(zorder,"___________新的zorder",cacheInfo.name)
		self:sortWindow()
		self:tostring()
	end

	for i,v in ipairs(self.windowCacheInfo) do
		local info = {
			percent =20 + perPercent * i,
			frame = perViewFrame,
			action =c_func(createResumeWindow, v)  --c_func(self.showWindowByRoot,self, v.root,v.name,unpack(v.params) )
		}
		if i == #self.windowCacheInfo then
			info.percent = 100
		end
		table.insert(progressActions, info)
		-- if v.params then
		-- 	self:showWindowByRoot(v.root,v.name , unpack(v.params))
		-- else
		-- 	self:showWindowByRoot(v.root,v.name )
		-- end
	end
	self.windowCacheInfo = {}
	return progressActions
end

function WindowControler:showPlayerSetNicknameView()
	self:showTutoralWindow("LoginSetNicknameView")
end

-- 展示选角界面
function WindowControler:showSelectRoleView()
	-- 默认为男
	local roleType = 1
	local randomIndex =  RandomControl.getOneRandomInt(11,1)
	if randomIndex % 2 == 0 then
		roleType = 2
	end

	local roleViewUI = nil
	local callBack = function()
		if roleViewUI then
			roleViewUI:playUICharDebut()
		end
	end

	local loadRoleViewUI = function(roleType,delayShow)
		-- echo("提前加载界面......")
		roleViewUI = self:showTutoralWindow("SelectRoleView",LoginControler.SELECT_ROLE_TYPE.GUILD,roleType,delayShow)
	end

	if (device.platform == "ios" and not AudioModel:checkNeedPlayVideo()) then
        loadRoleViewUI(roleType,false)
        return
    end

	if (device.platform ~= "ios" and device.platform ~= "android") then
        loadRoleViewUI(roleType,false)
        roleViewUI:playUICharDebut()
        return
    end

	WindowControler:globalDelayCall(c_func(loadRoleViewUI,roleType,true), 2)
	local videoPlayer = FuncCommUI.playCharDebutVideo(c_func(callBack),roleType)
	-- videoPlayer = FuncCommUI.playCharDebutVideo()
	-- WindowControler:globalDelayCall(c_func(callBack), 9)
end

function WindowControler:destroyData()
	self:clearAllWindow()
	self.windowInfo = {}
end

--展示灵石获得的属性
function WindowControler:showSpiritStones(event)
	local temptype = 31
	local tempNum = event.params.tempNum
	local rewardStr = string.format("%s,%s", temptype,tempNum)
	if tempNum > 0 then
		-- FuncCommUI.startRewardView({rewardStr},nil,true)  ---- 干掉灵石tips 梁文让的
	end
	
end


function WindowControler:showOrHideBorderBar( value,scene )
	if not self._leftSp then
		scene = scene or self:getCurrScene()
		local leftSp = display.newSprite("icon/other/color_line.png", 0):addto(scene,1000)
		local hei = leftSp:getContentSize().height
		local  spWid = leftSp:getContentSize().width
		leftSp:setScaleY(GameVars.height/hei)
		leftSp:pos(spWid/2,GameVars.height /2)

		local rightSp = display.newSprite("icon/other/color_line.png", 0):addto(scene,1000)
		
		rightSp:setScaleY(GameVars.height/hei)
		rightSp:setScaleX(-1)
		rightSp:pos(GameVars.fullWidth-spWid/2,GameVars.height /2)
		self._leftSp = leftSp
		self._rightSp = rightSp
	end

	local tempFunc = function (  view,value)
		view:stopAllActions()
		if value then
			view:visible(true)
			view:opacity(0)
			view:fadeTo(0.5, 255)
		else
			view:visible(false)
		end
	end
	tempFunc(self._leftSp,value)
	tempFunc(self._rightSp,value)
end


WindowControler:init();

return WindowControler

