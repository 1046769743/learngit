-- ChallengePvpView


local ChallengePvpView = class("ChallengePvpView", UIBase);


function ChallengePvpView:ctor(winName)
    ChallengePvpView.super.ctor(self, winName);
end

function ChallengePvpView:loadUIComplete()
    self:registerEvent();
    self:createBgAni()
    self.btn_fanhui:setTap(c_func(self.press_btn_close, self));
    --暂时隐藏
    self.panel_1:visible(false)
    
    --关闭按钮右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fanhui,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_UI,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_tz,UIAlignTypes.LeftTop) 
    FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.Middle,1,0)
    self:initScrollView()


end 

function ChallengePvpView:createBgAni(  )
    -- local nd = display.newNode():addto(self._root,-1):pos(GameVars.gameResWidth/2,-GameVars.gameResHeight/2)
    -- local ani  = self:createUIArmature("UI_lilian", "UI_lilianzong", nd, true)
    -- echoError("11111")
    local backCtn = display.newNode():addto(self._root,-1):pos(300,-GameVars.UIOffsetY)
    local frontCtn = display.newNode():addto(self._root,1):pos(300,-GameVars.UIOffsetY)


    self.mapControler = MapControler.new(backCtn,frontCtn,"map_xianturukou")
    self._root:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)

end

function ChallengePvpView:updateFrame(  )
    local scrollx,scrolly = self.scroll_1:getCurrentPos(  )
    self.mapControler:updatePos(scrollx,0)

end





function ChallengePvpView:registerEvent()
    EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.initScrollView, self)
    EventControler:addEventListener(PvpEvent.PVP_RED_POINT_EVENT,self.initScrollView,self);
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RED_POINT_CHANGE_EVENT,self.initScrollView,self);
    EventControler:addEventListener(DelegateEvent.DELEGATE_FINISH_CHANGE, self.initScrollView, self)
    EventControler:addEventListener(TutorialEvent.TUTORIAL_TRIGGER_REMOVE, self.initScrollView, self)
end

function ChallengePvpView:onPvpChallengeCountChange()
    
end

function ChallengePvpView:initScrollView()
    local jump = nil
    -- 获取需要做弱引导的入口
    self._weakGuideSys = {}
    for _,sysname in ipairs(TutorialManager.getInstance():getEntranceGuide("ChallengePvpView")) do
        self._weakGuideSys[sysname] = true
        jump = sysname
    end
    -- 有强制引导不影响视图位置
    if jump and TutorialManager.getInstance():isCurViewExistGuide("ChallengePvpView") then
        jump = nil
    end

    local createFunc = function ( itemData )
       local ui = UIBaseDef:cloneOneView(self.panel_1)
        self:updateUI(ui,itemData)
        return ui
    end
    function updateCellFunc( itemData,view )
        self:updateUI(view,itemData)
    end

    local configData = ChallengePvPModel:getChallengModelData()
    local _scrollParams = {}
    for i=1,#configData do
        local y =  configData[i].locationY or 0
        local params =  {
            data = {configData[i]},
            createFunc = createFunc,
            updateCellFunc = updateCellFunc,
            perFrame = 0,
            offsetX = 40,
            offsetY = -y,
            itemRect = {x=0,y= -470,width=350,height = 470},
            widthGap = 0,
            heightGap = 0,
            perNums = 300,
        }
        table.insert(_scrollParams,params)
    end
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:refreshCellView(1)
    self.scroll_1:hideDragBar()

    if jump then
        self:todoView(jump)
    end
end





function ChallengePvpView:updateUI( view ,itemData)
    self:initCommon(view,itemData)
end


function ChallengePvpView:initCommon(view,itemData)

    local typeId = itemData.name
    local isOpen1 , valuers,conditionType = FuncCommon.isSystemOpen(typeId)
    local icons = ChallengePvPModel:getIconsBySystemId(typeId)
    local mcInfo = view.mc_dengxian
    local frame = itemData.frame or 1   
    local mcInfo = view.mc_dengxian
    local systemName = itemData.functionName or "测试系统"
    local openDes = itemData.openDes
    local gameDes = itemData.gameDes
    local rewardDes = itemData.rewardDes
    local viewEnterName -- 功能入口
    local dayTimes = 0




    if typeId == ChallengePvPModel.KEYS.SHAREBOSS then

    elseif typeId == ChallengePvPModel.KEYS.PVP then 
        viewEnterName = "ArenaMainView" 
        
    elseif typeId == ChallengePvPModel.KEYS.DELEGATE then 

    elseif typeId == ChallengePvPModel.KEYS.CROSSPEAK then

    elseif typeId == ChallengePvPModel.KEYS.RING then

    end
    if isOpen1  then
        -- FilterTools.clearFilter(mcInfo:getViewByFrame(2).btn_1)
        mcInfo:showFrame(2)

        --系统的名称
        local infoUI = mcInfo:getViewByFrame(2).panel_1
        infoUI.txt_deng:setString(GameConfig.getLanguage(systemName))
        --系统的背景
        infoUI.mc_two:showFrame(frame)


        infoUI.txt_2:setString(GameConfig.getLanguage(gameDes))
        infoUI.txt_3:setString(GameConfig.getLanguage(rewardDes))
            

        infoUI.panel_red:setVisible(false)
        infoUI.txt_1:setVisible(false)

        -- 竞技场
        if typeId == ChallengePvPModel.KEYS.PVP then
            infoUI.txt_1:setVisible(true)
            dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.PVP)
            infoUI.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
            local isShow = PVPModel:isRedPointShow()
            infoUI.panel_red:setVisible(isShow or false)
        end


        --幻境协站
        if typeId == ChallengeModel.KEYS.SHAREBOSS then
            infoUI.txt_1:setVisible(false)
        end 

        if typeId == ChallengePvPModel.KEYS.CROSSPEAK then
            infoUI.txt_1:setVisible(true)
            local tiems = CrossPeakModel:getCurrentSYTimes( )
            -- local _str = string.format(GameConfig.getLanguage("#tid_tiaozhuan_02"),tostring(tiems))
            -- infoUI.txt_1:setString(_str)
            infoUI.txt_1:setVisible(false)
            local isShow = CrossPeakModel:isShowRed()
            infoUI.panel_red:setVisible(isShow or false)
        end


        if typeId == ChallengePvPModel.KEYS.DELEGATE then 
            infoUI.txt_1:setVisible(true)
            local isShow = DelegateModel:isShowRedPoint()
            infoUI.panel_red:setVisible(isShow or false)
            local count = CountModel:getDelegateCont()
            local num =  FuncDataSetting.getDataByConstantName("DelegateTaskDayNum")
            dayTimes = num -  count
            if dayTimes <= 0 then
                dayTimes = 0
            end
            infoUI.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
        end

        if typeId == ChallengePvPModel.KEYS.RING then
            --暂时屏蔽情缘红点
            infoUI.panel_red:setVisible(false)

        end




        --可得到的物品 列表
        if icons ~= nil then
            for i,v in pairs(icons) do
                local rewardView = infoUI["UI_"..i]
                local itemData = v
                rewardView:setResItemData({reward = itemData})
                rewardView:showResItemName(false)
                rewardView:showResItemNum(false)

                local reward = string.split(itemData, ",")
                local rewardType = reward[1]      ----类型
                local rewardNum = reward[3]   ---总数量
                local rewardId = reward[2]          ---物品ID
                FuncCommUI.regesitShowResView(rewardView,
                        rewardType, rewardNum, rewardId, itemData, true, true);


            end
        else
            for i=1,3 do
                local rewardView = infoUI["UI_"..i]
                rewardView:setVisible(false)
            end
        end
        infoUI.mc_two:registerBtnEff()
        infoUI.mc_two:setTouchedFunc(c_func(function ()
            if typeId == ChallengePvPModel.KEYS.SHAREBOSS then
                ShareBossControler:enterShareBossMainView()
            elseif typeId == ChallengePvPModel.KEYS.PVP then
                WindowControler:showWindow("ArenaMainView")
            elseif typeId == ChallengePvPModel.KEYS.DELEGATE then 
                WindowControler:showWindow("DelegateMainView")
            elseif typeId == ChallengePvPModel.KEYS.CROSSPEAK then
                WindowControler:showWindow("CrosspeakNewMainView")
            end
        end, self));

        -- 加弱引导效果
        if self._weakGuideSys[typeId] then
            FuncCommUI.playAnimBreath(infoUI.mc_two,1.05)
        else
            infoUI.mc_two:stopAllActions()
            infoUI.mc_two:setScale(1)
        end
    else

        --系统的名称
        local infoUI = mcInfo:getViewByFrame(1).btn_1
        infoUI:getUpPanel().txt_deng:setString(GameConfig.getLanguage(systemName))

        -- local infoUI = mcInfo:getViewByFrame(1).btn_1
        mcInfo:showFrame(1)

        -- mcInfo.currentView.txt_1:setString(GameConfig.getLanguage(openDes))
        infoUI:getUpPanel().mc_1:showFrame(frame)

         infoUI:getUpPanel().rich_1:setString(GameConfig.getLanguage(openDes))

        -- FilterTools.setGrayFilter(mcInfo:getViewByFrame(1).btn_1)
        mcInfo.currentView.btn_1:setTap(c_func(function ()
            WindowControler:showTips(GameConfig.getLanguage(openDes)); 
        end, self));
        
    end
end

-- 滚动到对应的位置
function ChallengePvpView:todoView(systemName)
    echo("=====ChallengePvpView==systemName======",systemName)

    local configData = ChallengePvPModel:getChallengModelData()
    local groupIndex = 1
    for k,v in pairs(configData) do
        if v.name == systemName then
            groupIndex = tonumber(k)
            break
        end
    end
    self.scroll_1:gotoTargetPos(1,groupIndex ,1)  --跳到中间

    if systemName == FuncCommon.SYSTEM_NAME.PVP then
        echo("============第一次引导竞技场============")
        TeamFormationModel:allOnTeamFormationForPvp()
    end

    return groupIndex
end


function ChallengePvpView:press_btn_close()
    EventControler:dispatchEvent(ChallengeEvent.YIMENG_RED_POINT_CHANGE)
    self:startHide()
end


function ChallengePvpView:deleteMe()
    if self.mapControler then
        self.mapControler:deleteMe()
        self.mapControler =nil
    end
    ChallengePvpView.super.deleteMe(self)
end

return ChallengePvpView;
