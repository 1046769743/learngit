--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机主界面-view
]]
-- 5.21 pangkangning四测新版本大改，原先的已经不能使用

local DelegateMainView = class("DelegateMainView", UIBase)

function DelegateMainView:ctor( winName)
	DelegateMainView.super.ctor(self, winName)
    self._itemArray = {}
end

function DelegateMainView:registerEvent()
	DelegateMainView.super.registerEvent(self)
	EventControler:addEventListener(DelegateEvent.DELEGATE_TASK_UPDATE, self.updateTask, self)
    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE, self.time2Update, self)

	self.btn_2:setTouchedFunc(c_func(self.btn_help, self))
    self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self))
    self.panel_1.btn_1:setTouchedFunc(c_func(self.press_refresh_btn, self))
    -- self.UI_backhome.btn_topchat:visible(false)
    -- self.UI_backhome.btn_topmubiao:visible(false)
end

function DelegateMainView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end
-- 适配
function DelegateMainView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_mz, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1, UIAlignTypes.RightTop)
    
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.MiddleTop)
	self.panel_1.panel_renwu:visible(false)
    self.panel_2.txt_1:setString(GameConfig.getLanguage("#tid_delegate_3018"))
end
-- 更新数据
function DelegateMainView:updateTask( )
    self:updateUI()
    -- -- 直接手动刷新一次
    -- for k,v in pairs(self._itemArray) do
    --     self:updateTaskItem(v)
    -- end
end
-- 到刷新时间了
function DelegateMainView:time2Update(  )
    -- 刷新做的委托次数
    self:updateDoNum()
    -- 刷新次数
    self:updateRefreash()
end

function DelegateMainView:updateUI()
	-- 刷新滚动列表
	self:updateScrollView()
	-- 刷新右侧神秘委托界面
	self:updateSpecial()

	self:updateArrayItemByTime()
    -- 刷新做的委托次数
    self:updateDoNum()
    -- 刷新次数
    self:updateRefreash()
end
-- 更细你特殊委托数据
function DelegateMainView:updateSpecial( )
    local spData = DelegateModel:getSpecialTask()
    if not spData then
        local tmp = DelegateModel:getAllTask()
        dump(tmp,"+s=s===s")
        echoError ("为什么会没有特殊委托")
        return
    end
    local taskData = FuncDelegate.getTask(spData.id)
    -- 名字
    self.panel_2.txt_1:setString(GameConfig.getLanguage(taskData.taskName))
    if UserExtModel:chkCanDoExpecialDelelagte() then
        local status = DelegateModel:getCurTaskStatus(tostring(spData.id))
        if status == DelegateModel.TASK_STATUS.WAIT then --未开始
        	self.panel_2.mc_1:showFrame(2)
        	local _tView = self.panel_2.mc_1.currentView
            -- 判断是否需要消耗仙玉
            local curr = 0 -- DelegateModel:refreshSpecilaCount()
            local price = FuncDataSetting.geSpecialRefreshPrice()
            _tView.txt_1:setString((curr+1)*price)
            _tView.btn_1.__id = spData.id
            _tView.btn_2.__id = spData.id
            if not _tView.btn_1._init then
            	_tView.btn_1:setTouchedFunc(c_func(self.press_refresh_special_btn, self,_tView.btn_1))
            	_tView.btn_2:setTouchedFunc(c_func(self.press_item_btn, self,_tView.btn_2))
                _tView.btn_1._init = true
            end
        elseif status == DelegateModel.TASK_STATUS.INHAND then--未完成
        	self.panel_2.mc_1:showFrame(3)
        	local _tView = self.panel_2.mc_1.currentView
            local cTime = DelegateModel:getCurFinishTime(tostring(spData.id)) - TimeControler:getServerTime()
            if cTime < 0 then
                -- 这里其实状态要修改了
            else
                local str = TimeControler:turnTimeSec( cTime, TimeControler.timeType_dhhmmss )                
                _tView.txt_2:setString(str)--进行时间
            end
            _tView.btn_1.__id = spData.id
            if not _tView.btn_1._init then
            	_tView.btn_1:setTouchedFunc(c_func(self.press_item_btn, self,_tView.btn_1))
                _tView.btn_1._init = true
            end
        elseif status == DelegateModel.TASK_STATUS.FINISH then--可领取
        	self.panel_2.mc_1:showFrame(4)
        	local _tView = self.panel_2.mc_1.currentView
            _tView.btn_1.__id = spData.id
            if not _tView.btn_1._init then
            	_tView.btn_1:setTouchedFunc(c_func(self.press_item_btn, self,_tView.btn_1))
                _tView.btn_1._init = true
            end
        end
    else
        local curr = UserExtModel:getDelelagteDoCount()
        local max = FuncDataSetting.getUnLockSpecialTaskNum()
        local str = GameConfig.getLanguageWithSwap("#tid_delegate_3016",curr,max)
        self.panel_2.mc_1:showFrame(1)
        self.panel_2.mc_1.currentView.rich_1:setString(str)
    end
    -- 更新道具
    local itemView = self.panel_2.UI_1
    if taskData.specialReward and #taskData.specialReward > 0 then
        local data = taskData.specialReward[1]
        itemView:setResItemData({reward = data})
        itemView:showResItemName(false)
        itemView:showResItemNum(false)
        local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(data)
        FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,data, true, true)
        itemView:setTouchSwallowEnabled(true)
    else
        itemView:visible(false)
    end
    -- -- 更新立绘显示(立绘只要创建了，就不需要每次都刷新了)
    -- local npcData = FuncCommon.getNpcDataById(taskData.npcId)
    -- if npcData.spine then
    --     if self.panel_2.ctn_1._spineName == npcData.spine then
    --         return
    --     end
    --     self.panel_2.ctn_1:removeAllChildren()
    --     local spine = ViewSpine.new(npcData.spine)
    --     spine:playLabel("ui")
    --     spine:setScale(0.35)
    --     self.panel_2.ctn_1:addChild(spine)
    --     self.panel_2.ctn_1._spineName = npcData.spine
    -- else
    --     self.panel_2.ctn_1:removeAllChildren()
    --     self.panel_2.ctn_1._spineName = nil
    -- end
end
function DelegateMainView:getRefreshCost( )
    -- 获取领取的任务然后算刷新消耗的仙玉
    local taskData = DelegateModel:getAllTask()
    if not taskData or #taskData == 0 then
        return 0 
    end
    local count = 0
    for k,v in pairs(taskData) do
        if v.type ~= FuncDelegate.Type_Special then
            local status = DelegateModel:getCurTaskStatus(v.id)
            if status == DelegateModel.TASK_STATUS.WAIT then
                count = count + 1
            end
        end
    end
    local price = FuncDataSetting.getNormalRefreshPrice()
    local cost = count * price
    return cost
end
-- 更新已做的任务数
function DelegateMainView:updateDoNum( )
    local curr = CountModel:getDelegateCont()
    local max = FuncDataSetting.getNormalTaskNum()
    local nowCount = max - curr
    if nowCount < 0 then
        nowCount = 0
    end
    if nowCount == 0 then
        self.panel_1.mc_1:showFrame(2)
        self.panel_1.mc_1.currentView.txt_3:setString(nowCount)
    else
        self.panel_1.mc_1:showFrame(1)
        self.panel_1.mc_1.currentView.txt_3:setString(nowCount)
    end
end
-- 更新刷新次数和消耗
function DelegateMainView:updateRefreash( )
    self.panel_1.mc_3:visible(true)
    if self:checkNeedCost() then
        self.panel_1.mc_3:showFrame(1)
        local tmpView = self.panel_1.mc_3.currentView
        local cost = self:getRefreshCost()
        tmpView.txt_2:setString(cost)
        if cost == 0 then
            self.panel_1.mc_3:visible(false)
        end
    else
        self.panel_1.mc_3:showFrame(2)
    end
end
-- 检查刷新是否需要消耗仙玉
function DelegateMainView:checkNeedCost( )
    local curr = DelegateModel:refreshCount()
    local max = FuncDataSetting.getNormalRefreshTaskNum()
    if curr < max then
        return false
    else
        return true
    end
end
-- 更新滚动视图数据
function DelegateMainView:updateScrollView( )
	local taskData = DelegateModel:getAllTask()
    if not taskData or #taskData == 0 then
        self._itemArray = {}
        return
    end
    local datas = {}
    for k,v in pairs(taskData) do
        -- 特殊委托不加在这里
        if v.type ~= FuncDelegate.Type_Special then
            table.insert(datas,v)
        end
    end
    -- 删除一次已经完成的任务
    for i=#self._itemArray,1,-1 do
        local taskData = self._itemArray[i].item
        local have = false
        for m,n in pairs(datas) do
            if tostring(taskData.id) == tostring(n.id) then
                have = true
                break
            end
        end
        if not have then
            table.remove(self._itemArray,i)
        end
    end
    -- 刷新scroll界面
    local x,y = self.panel_1.panel_renwu:getPosition()
    local _updateItemValue = function( view,itemData,notAdd)
        self:updateItem(view,itemData)
        local tTbl = {view = view,item = itemData}
        self:updateTaskItem(tTbl)
        if not notAdd then
            table.insert(self._itemArray,tTbl)
        end
    end
    local function createItemFunc(item,index)
        local _view = UIBaseDef:cloneOneView(self.panel_1.panel_renwu)
        _view:pos(0,0)
        _updateItemValue(_view,item)
        _view.__id = item.id
        _view:visible(false)
        return _view
    end
    local function updateCellFunc(itemData, view)
        _updateItemValue(view,itemData)
        if view.__id ~= itemData.id then
            if not view.__anim then
                -- 新的需要加特效
                local _p = self.panel_1.scroll_1.innerContainer
                view.__anim = self:createUIArmature("UI_xianlingweituo","UI_xianlingweituo_kuang", _p, true)
                local _x,_y = view:getPosition()
                view.__anim:pos(-110 + _x,52 + _y)
            end
            view:visible(false)
            view._isHide = true --这个参数在ScrollViewExpand.lua中控制对应的显示与否值
            view.__anim:visible(true)
            view.__anim:playWithIndex(0)
            view.__id = itemData.id
            local pmNode = UIBaseDef:cloneOneView(self.panel_1.panel_renwu)
            _updateItemValue(pmNode,itemData,true)
            FuncArmature.changeBoneDisplay(view.__anim,"node",pmNode)
            -- 动画结束后调用
            view.__anim:registerFrameEventCallFunc(13,false,function( )
                view._isHide = false
                view.__anim:visible(false)
                view:visible(true)
            end)
        end
        return view;  
    end
    local params = {
        data  = datas,
        createFunc = createItemFunc,
        updateCellFunc = updateCellFunc,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heighGap = 2,
        perFrame = 1,
        perNums = 1,
        itemRect = {x = -9.5, y= -110,width = 614,height = 110},
    }
    self.panel_1.scroll_1:styleFill({params})
end
function DelegateMainView:updateItem(view,item )
	self:updateViewHead(view,item.id)
	-- 注册点击事件
    view.btn_renwuanniu.__id = item.id
	view.btn_renwuanniu:setTouchedFunc(c_func(self.press_item_btn, self,view.btn_renwuanniu))
end
-- 刷新头像
function DelegateMainView:updateViewHead(_view,id)
	local taskData = FuncDelegate.getTask(id)
    local npcData = FuncCommon.getNpcDataById(taskData.npcId)
    local _spriteIcon = display.newSprite(FuncRes.iconHero(npcData.icon))
    _spriteIcon:scale(1.2)
    _view.UI_1.ctn_1:removeAllChildren()
    _view.UI_1.ctn_1:addChild(_spriteIcon)
    _view.UI_1.panel_lv:visible(false)
    -- _view.UI_1.panel_lv.txt_3:setString(taskData.startLevel)--开启等级
    _view.UI_1.mc_dou:visible(false)
    _view.txt_1:setString(GameConfig.getLanguage(taskData.taskName)) --任务名称
    if taskData.levelDiff then
        _view.mc_star:showFrame(taskData.levelDiff) --任务难度
    end
end
function DelegateMainView:updateArrayItemByTime( )
    for k,v in pairs(self._itemArray) do
        self:updateTaskItem(v)
    end
    self:delayCall(function( )
        self:updateArrayItemByTime()
        self:updateSpecial()
    end,1)
end
function DelegateMainView:updateTaskItem(v )
    local taskData = FuncDelegate.getTask(v.item.id)
	local status = DelegateModel:getCurTaskStatus(v.item.id)
	if status == DelegateModel.TASK_STATUS.WAIT then
    	v.view.mc_time:visible(true)
		v.view.mc_time:showFrame(1)
    	v.view.btn_renwuanniu:getUpPanel().panel_red:visible(false)
	    v.view.btn_renwuanniu:getUpPanel().mc_anniuwenzi:showFrame(1)
        local str = GameConfig.getLanguageWithSwap("#tid_delegate_3002", string.format("%.1f", taskData.time / 3600))
		v.view.mc_time.currentView.txt_1:setString(str)
    elseif status == DelegateModel.TASK_STATUS.INHAND then --未完成
    	local cTime = DelegateModel:getCurFinishTime(tostring(v.item.id)) - TimeControler:getServerTime()
    	if cTime < 0 then
    		-- 这里其实状态要修改了
    	else
	    	v.view.mc_time:visible(true)
	    	v.view.btn_renwuanniu:getUpPanel().mc_anniuwenzi:showFrame(2)
    		v.view.mc_time:showFrame(2)
	    	v.view.btn_renwuanniu:getUpPanel().panel_red:visible(false)
	        local str = GameConfig.getLanguage("#tid_delegate_3015")..TimeControler:turnTimeSec( cTime, TimeControler.timeType_dhhmmss )
	        v.view.mc_time.currentView.txt_2:setString(str)
    	end
    elseif status == DelegateModel.TASK_STATUS.FINISH then --可领取
    	v.view.btn_renwuanniu:getUpPanel().mc_anniuwenzi:showFrame(3)
        -- 如果不能再领取了，则红点也需要取消
        if DelegateModel:chkIsMax() then
            v.view.btn_renwuanniu:getUpPanel().panel_red:visible(false)
        else
            v.view.btn_renwuanniu:getUpPanel().panel_red:visible(true)
        end
    	v.view.mc_time:visible(false)
	end
end
-- 帮助按钮
function DelegateMainView:btn_help( )
    WindowControler:showWindow("DelegateHelpView")
end

function DelegateMainView:press_btn_close()
	self:startHide()
end
function DelegateMainView:press_refresh_btn( )
    -- 检查是否有可刷新的任务
    local canRefresh = false
    for k,v in pairs(self._itemArray) do
        local status = DelegateModel:getCurTaskStatus(v.item.id)
        if status == DelegateModel.TASK_STATUS.WAIT then
            canRefresh = true
            break
        end
    end
    if not canRefresh then
        WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_3020"))
        return
    end
    -- 刷新任务
    local cost = self:getRefreshCost()
    local _type = 2
    if cost > 0 then
        _type = 1
    end
    local _doClickAction = function(  )
        if self:checkNeedCost() then
            if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, cost, true) then
                return
            end
        end
        DelegateServer:refreshNormalDelegate()
    end
    if DelegateModel:getNormalTip() then
        _doClickAction()
    else
        if self:checkNeedCost() then
            WindowControler:showWindow("DelegateTipsView",_type,cost,function()
                _doClickAction()
            end)
        else
            _doClickAction()
        end
    end
end
function DelegateMainView:press_refresh_special_btn(btn )
    local id = btn.__id
    local curr = DelegateModel:refreshSpecilaCount()
    local price = FuncDataSetting.geSpecialRefreshPrice()
    if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, price, true) then
        return
    end
    local _refreshSpecialTask = function( )
        DelegateServer:refreshSpeicalDelegate({delegateId = id,callBack = function( )
            -- 播放特效
            if not self.speAnim then
                local parent = self.panel_2.UI_1
                self.speAnim = self:createUIArmature("UI_xianlingweituo","UI_xianlingweituo_shuaxin", parent, true)
                self.speAnim:pos(40,-50)
            end
            self.speAnim:playWithIndex(0)
        end})
    end

    if DelegateModel:getSpecialTip() then
        _refreshSpecialTask()
    else
        WindowControler:showWindow("DelegateTipsView",3,price,function()
            _refreshSpecialTask()
        end)
    end
end
-- 按钮点击
function DelegateMainView:press_item_btn(btn)
    local id = btn.__id
	local status = DelegateModel:getCurTaskStatus(id)
    local taskData = FuncDelegate.getTask(id)   
	if status == DelegateModel.TASK_STATUS.WAIT then
        WindowControler:showWindow("DelegateSelectView",taskData)
    elseif status == DelegateModel.TASK_STATUS.INHAND then --未完成
        WindowControler:showWindow("DelegateSelectView",taskData)
    elseif status == DelegateModel.TASK_STATUS.FINISH then --可领取
        if DelegateModel:chkIsMax() and taskData.taskType ~= FuncDelegate.Type_Special then
            -- 达到奇侠每日任务次数(不是特殊委托)
            WindowControler:showTips(GameConfig.getLanguage("#tid_delegate_2013"))
            return
        end
        local partners = DelegateModel:getWorkingPartner(id)
        DelegateServer:finishTask({
            delegateId = id,
            callBack = function(params)
                params.partners = partners
                WindowControler:showWindow("DelegateRewardView", params)
            end
        })
    end
end


return DelegateMainView