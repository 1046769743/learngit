local LogsView = class("LogsView", UIBase);

function LogsView:ctor(winName)
    LogsView.super.ctor(self, winName);
end

function LogsView:loadUIComplete()
    self:initData()
    self:initView()
    self:updateUI(true)

    self:registerEvent();
--	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,0)
   self:schedule(c_func(self.frameUpdate, self),4);
--//为刷新面板注册事件
   self.panel_1.panel_refresh_info:setTouchedFunc(c_func(self.frameUpdate,self),nil,true);
   self.panel_1.panel_refresh_info:setClickPriority(GameVars.clickPriorityMap.overGuide)
   self.panel_1.panel_refresh_info:setTouchSwallowEnabled(true);
   if(not DEBUG_FPS)then
       -- self.panel_1.txt_lua:setVisible(false);
       -- self.panel_1.txt_lua_name:setVisible(false);
       -- self.panel_1.panel_refresh:setVisible(false);
   end
   self.lastX = 0
   self.lastY =0
   
end 



function LogsView:initData()
    self.isShow = false
    self.logType = LogsControler.logType
    self.curLogType = self.logType.LOG_TYPE_NORMAL

    local pngTypeStr = _yuan3(CONFIG_USEDISPERSED, "散图", "大图")
    self.panel_1.txt_version:setString(AppInformation:getVersion()..':'..pngTypeStr)
    
    -- self:testInsertLogs()
end

function LogsView:frameUpdate()
	local now = TimeControler:getServerTime()
	local timeStr = os.date("%c", now)
	self.panel_1.txt_server_time:setString(timeStr)
--//系统信息
 --  local    vD=cc.Director:getInstance();
 --  local   vRate=1024*1024;
 --  self.panel_1.txt_sprite:setString(""..vD:getSpriteCount());--//精灵数目
 --  self.panel_1.txt_node:setString(""..vD:getNodeCount());--//节点的数目
 --  self.panel_1.txt_texture:setString(string.format("%.4fM",vD:getTextureTotalMemory()/vRate));--//纹理内存
--   self.panel_1.txt_texture_cache:setString(string.format("%.4fM",vD:getTextureCacheMemory()/vRate));
--Lua内存
   self.panel_1.txt_lua:setString(string.format("%.3fM",collectgarbage("count")/1024));
end

-- 测试插入日志
function LogsView:testInsertLogs()
    for i=1,10 do
        local msg = "#1abcdefg123456790#2abcdefg123456790#3abcdefg123456790-" .. i
        LogsControler:addNormal(msg)

        msg = "CharView 类了错误了啊xx类发发生了错误了啊类发发生了错误了啊" .. i
        LogsControler:addWarn(msg)

        msg = "CharView 类了错误了啊xx类发发生了错误了啊类发发生了错误了啊" .. i
        LogsControler:addError(msg)
    end
end

function LogsView:initView()
    self.logViewWidth = 100
    self.logViewHeight = 100

    self.logScroller = self.panel_1.scroll_1
    self.logScroller:setClickPriority(GameVars.clickPriorityMap.overGuide)

    self.mcShowOrHide = self.mc_1
    self.logPanel = self.panel_1

    self.panelNormal = self.panel_1.panel_1
    self.panelWarring = self.panel_1.panel_2
    self.panelError = self.panel_1.panel_3

    self.btnPanelTab = {
        self.panelNormal,
        self.panelWarring,
        self.panelError
    }

    self.panelNormal:setTouchedFunc(c_func(self.showLog,self,self.logType.LOG_TYPE_NORMAL),nil,true);
    self.panelWarring:setTouchedFunc(c_func(self.showLog,self,self.logType.LOG_TYPE_WARN),nil,true);
    self.panelError:setTouchedFunc(c_func(self.showLog,self,self.logType.LOG_TYPE_ERROR),nil,true);

    self.panelNormal:setClickPriority(GameVars.clickPriorityMap.overGuide)
    self.panelWarring:setClickPriority(GameVars.clickPriorityMap.overGuide)
    self.panelError:setClickPriority(GameVars.clickPriorityMap.overGuide)

end

function LogsView:registerEvent()
	LogsView.super.registerEvent();
    -- 显示或隐藏
    self:setSwitchMcStatus(1)

    self.logPanel.btn_clear:setTap(c_func(self.clearLogByType, self));

    EventControler:addEventListener(LogEvent.LOGEVENT_LOG_CHANGE, self.updateLogs, self)
	self.panel_1.btn_clear_view:setTap(c_func(self.onRefreshCurrentViewTap, self))
	self.panel_1.btn_clear_ui_configs:setTap(c_func(self.clearModuleUIConfigsByCurrentView, self))
	self.panel_1.btn_switch_server:setTap(c_func(self.onGlobalServerSwitchTap, self))
    FuncCommUI.dragOneView(self.mc_1, self)
end

function LogsView:onGlobalServerSwitchTap()
	self:showOrHideLogsView()
	WindowControler:showWindow("GlobalServerSwitchView", self)



end

function LogsView:clearModuleUIConfigsByCurrentView()
	local currentView = WindowControler:getCurrentWindowView()
	local cname = currentView.__cname
	local uiName = WindowsTools:getUiName(cname)
	if not uiName then
		return
	end
	local model_name = string.match(uiName, "(UI_[a-zA-Z0-9]+).*")
	for k,v in pairs(package.loaded) do
		if string.find(k, "uiConfig."..model_name..".*") then
			package.loaded[k] = false
		end
	end
	self:_reloadView(currentView, cname)
end

function LogsView:onRefreshCurrentViewTap()
	local currentView = WindowControler:getCurrentWindowView()
	local cname = currentView.__cname
	local uiName = WindowsTools:getUiName(cname)
	if uiName then
		package.loaded["uiConfig."..uiName] = false
	end
	self:_reloadView(currentView, cname)
end

function LogsView:_reloadView(currentView, cname)
	for k,v in pairs(package.loaded) do
		if string.find(k, "[a-zA-Z.]+".."%."..cname.."$") then
			currentView:startHide()
			_G[cname] =nil
			package.loaded[k] = false
			require(k)
			WindowControler:showWindow(cname)
			break
		end
	end
end

-- 显示或关闭logsView
function LogsView:showOrHideLogsView()
    -- 隐藏
    if self.isShow then
        self.isShow = false
    else
        -- 显示
        self.isShow = true
    end

    self:updateUI(true)
end

-- 根据类别，清空log
function LogsView:clearLogByType()
    LogsControler:clearLogByType(self.curLogType)
end




-- 设置显示/隐藏开关的状态
function LogsView:setSwitchMcStatus(whichiFrame)
    self.mcShowOrHide:showFrame(whichiFrame)
    self.mc_1:setTouchedFunc(c_func(self.showOrHideLogsView,self));
    self.mc_1:setClickPriority(GameVars.clickPriorityMap.overGuide)
    
end

function LogsView:updateViewStatus()
    if self.isShow then
        self:setSwitchMcStatus(1)

        self.logPanel:setVisible(true)
    else
        self:setSwitchMcStatus(2)
        self.logPanel:setVisible(false)
    end

    for i=1,#self.btnPanelTab do
        local panel = self.btnPanelTab[i]
        panel.mc_1:showFrame(i)

        if self.curLogType == i then
            panel.mc_2:showFrame(2)
        else
            panel.mc_2:showFrame(1)
        end
    end
end

-- 显示相应类型的log
function LogsView:showLog(logType)
    if self.curLogType == logType then
        return
    end

    self.curLogType = logType
    self:updateUI(true)
end

-- log发生变化
function LogsView:updateLogs(event)
    --游戏被销毁的时候 就不处理了
    if GameLuaLoader:isGameDestory() then
        return
    end
    local logType = event.params.logType
    --如果是 error 那么就弹出错误提示
    -- if logType == self.logType.LOG_TYPE_ERROR then
    --     if not self.isShow then
    --         self.isShow = true
    --     end
    --     self:showLog(self.logType.LOG_TYPE_ERROR)
        
    --     return
    -- end
    if not self.isShow then
        return
    end
    
    if logType == self.curLogType then
        self:updateUI()
    end
end

function LogsView:updateUI(isChangePage)

    --判定为至少2秒才刷一次
    if not self._lastUpdateTime then
        self._lastUpdateTime = os.time()
    else
        local t = os.time()
        if (t - self._lastUpdateTime) < 2 and (not isChangePage ) then
            return
        end
        self._lastUpdateTime = os.time()
    end





    -- 更新显示状态
    self:updateViewStatus()

	self.logArr = LogsControler:getLogs(self.curLogType)
    -- self.adapter = GridViewAdapter.new(self.logArr);
    -- self.adapter:setUIView(self);
    --显示gridView
    -- self.logScroller:recreateUI(self.adapter); 

    local createFunc = function ( data )
        local view = WindowControler:createWindowNode("LogsItem")
        view:setMessage(self.curLogType,data)
        return view
    end

    local updateCellFunc = function ( data,view )
        view:setMessage(self.curLogType,data)
        return view
    end

    local params = {
        {
            perNums = 1,
            offsetX =0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 5,
            itemRect = {x=0,y= -40, width = 564,height = 40},
            perFrame=5,
            data = self.logArr,
            createFunc = createFunc,
            updateCellFunc = updateCellFunc
        }

    }
    
    self.logScroller:styleFill(params)
    if isChangePage then
        self.logScroller:gotoTargetPos(#self.logArr,1,2)
    end
    




end

function LogsView:getLogType()
    return self.curLogType
end

return LogsView;
