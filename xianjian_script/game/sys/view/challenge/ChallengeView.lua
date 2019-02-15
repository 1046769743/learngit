--2016.8.11
--ZQ 
--2018.04.25
--wk 


local ChallengeView = class("ChallengeView", UIBase);


function ChallengeView:ctor(winName)
    ChallengeView.super.ctor(self, winName);
end

function ChallengeView:loadUIComplete()
    self:registerEvent();

    --创建背景动画
    self:createBgAni()
    --暂时隐藏
    --关闭按钮右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fanhui,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_tz,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_UI,UIAlignTypes.RightTop)
     
    FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.Middle,1,0)

    self:initScrollView()
    

    
end 

function ChallengeView:createBgAni(  )
    -- local nd = display.newNode():addto(self._root,-1):pos(GameVars.gameResWidth/2,-GameVars.gameResHeight/2)
    -- local ani  = self:createUIArmature("UI_lilian", "UI_lilianzong", nd, true)
    -- echoError("11111")
    local backCtn = display.newNode():addto(self._root,-1):pos(800,-GameVars.UIOffsetY)
    local frontCtn = display.newNode():addto(self._root,1):pos(800,-GameVars.UIOffsetY)


    self.mapControler = MapControler.new(backCtn,frontCtn,"map_lilianrukou")
    self._root:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)

end

function ChallengeView:updateFrame(  )
    local scrollx,scrolly = self.scroll_1:getCurrentPos(  )
    self.mapControler:updatePos(scrollx,0)

end



function ChallengeView:initScrollView()
    local jump = nil
    -- 获取需要做弱引导的入口
    self._weakGuideSys = {}
    for _,sysname in ipairs(TutorialManager.getInstance():getEntranceGuide("ChallengeView")) do
        self._weakGuideSys[sysname] = true
        jump = sysname
    end
    -- 有强制引导不影响视图位置
    if jump and TutorialManager.getInstance():isCurViewExistGuide("ChallengeView") then
        jump = nil
    end

    self.panel_1:setVisible(false)
    local createFunc = function ( itemData )
        local ui = UIBaseDef:cloneOneView(self.panel_1)
        self:updateUI(ui,itemData)

		return ui
    end
    function updateCellFunc( itemData,view )
        self:updateUI(view,itemData)
    end

    local box = self.panel_1:getContainerBox()
    local configData = ChallengeModel:getChallengModelData()

    -- dump(configData,"3233333333")

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
            perNums = 1,
        }
        table.insert(_scrollParams,params)
    end

    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
    self.scroll_1:refreshCellView(1)
    -- self.scroll_1:setCanScroll(false);

    if jump then
        self:todoView(jump)
    end
end

function ChallengeView:registerEvent()
    self.btn_fanhui:setTap(c_func(self.press_btn_close, self));
--    EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.onPVPReportResultOk, self)
    EventControler:addEventListener(TrialEvent.BATTLE_SUCCESSS_EVENT,self.initScrollView, self);
    -- EventControler:addEventListener(TrialEvent.SWEEP_BATTLE_SUCCESS_EVENT,
    --     self.initScrollView, self);

    EventControler:addEventListener(TowerEvent.TOWEREVENT_RESET_TOWER_SUCCESS,self.initScrollView, self);
    EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED,self.initScrollView,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_SUCCESS_GETMAINREWARDVIEW,self.initScrollView,self)
--//On Event PVP Challenge
    -- EventControler:addEventListener(PvpEvent.PVP_RED_POINT_EVENT,self.onPvpChallengeCountChange,self);
    
    EventControler:addEventListener(ChallengeEvent.YIMENG_RED_POINT_CHANGE,self.initScrollView,self);

    EventControler:addEventListener(WonderlandEvent.WONDERLAND_BACK_UI,self.initScrollView,self);
    
    -- EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RED_POINT_CHANGE_EVENT,self.refreshCrossPeakRed,self);
    -- EventControler:addEventListener(TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION,self.showRecallRed,self)

    -- 领取了额外宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, self.initScrollView, self)
    -- 领取了星级宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.initScrollView, self)

    EventControler:addEventListener(TutorialEvent.TUTORIAL_TRIGGER_REMOVE, self.initScrollView, self)
    -- 无底深渊 事件
    EventControler:addEventListener(EndlessEvent.ENDLESS_BOX_STATUS_CHANGED, self.initScrollView, self)
end

--刷新按钮红点的问题
-- function ChallengeView:refreshCrossPeakRed(  )
--     self:initCrossPeak(self.panel_1)
-- end

function ChallengeView:refreshWonderland()

    local _pvpView=self.panel_1.mc_xj:getViewByFrame(2);
    local isShow = WonderlandModel:shoehomeRed()
    _pvpView.btn_1.panel_red:setVisible(isShow);
    local dayTimes = WonderlandModel:getSumCountNum()
    _pvpView.btn_1.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))

end



-- 忆梦红点
function ChallengeView:redPointYiMengShow(params)

    local isShow = params.params.isShow 
    self.panel_1.mc_ym:showFrame(2)
    local infoUI = self.panel_1.mc_ym.currentView.btn_1
    infoUI.txt_1:visible(false)
    -- 是否显示红点
    infoUI.panel_red:setVisible(isShow)
    EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
end
--竞技场红点显示
function ChallengeView:redPointPVPShow()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.PVP)
    local _pvpView=self.panel_1.mc_dengxian:getViewByFrame(2);

    local isShow = PVPModel:isRedPointShow()
    _pvpView.btn_1.panel_red:setVisible(isShow);
end
--//竞技场剩余次数发生变化
function ChallengeView:onPvpChallengeCountChange()
    local    _pvpView=self.panel_1.mc_dengxian:getViewByFrame(2);
    --购买的挑战次数
    local buyCount = CountModel:getPVPBuyChallengeCount()
    --已经挑战的次数
    local callengeCount = CountModel:getPVPChallengeCount()
    local firstTime = PVPModel:firstTime()
    local _challengeTimesLeft = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
    _pvpView.btn_1.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), _challengeTimesLeft));
    self:redPointPVPShow()
    -- echo("-----------------Event.PVP_RED_POINT_EVENT- 次数 = ".._challengeTimesLeft)
    EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
end

function ChallengeView:onTrialReportResultOk()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TRIAL)
    local trailred =  TrailModel:showChallengTrailMainRed()
    self.panel_1.mc_slk:showFrame(2)
    self.panel_1.mc_slk.currentView.btn_1.panel_red:setVisible(trailred);
    self.panel_1.mc_slk.currentView.btn_1.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
end

-- 锁妖塔挑战次数变更红点
function ChallengeView:onTowerReportResultOk()
    local dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TOWER);
    self.panel_1.mc_syt:showFrame(2);
    local isShow = TowerMainModel:checkTowerAllRedPoint()
    self.panel_1.mc_syt.currentView.btn_1.panel_red:setVisible(isShow);
    self.panel_1.mc_syt.currentView.btn_1.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
    EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
end

-- 锁妖塔搜刮红点更新
function ChallengeView:updateCollectionRedPoint( event )
    local isShow = true
    if event and event.params then
        isShow = event.params.isShow
        echo("______________挑战界面监听到搜刮红点消息 ______________",isShow)
    end
    if not isShow then
        isShow = TowerMainModel:checkTowerAllRedPoint()
    end
    if self.panel_1 and self.panel_1.mc_syt.currentView.btn_1.panel_red then
        self.panel_1.mc_syt.currentView.btn_1.panel_red:setVisible(isShow)
        EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
    end
end


function ChallengeView:updateUI( view ,itemData)


    self:initCommon(view,itemData)

end

function ChallengeView:initCommon(view,itemData)


    -- dump(itemData,"111111111111111111")
    local typeId = itemData.name
    local isOpen1 , valuers,conditionType = FuncCommon.isSystemOpen(typeId)
    local icons = itemData.icon  -- ChallengeModel:getIconsBySystemId(typeId)
    local frame = itemData.frame or 1
    local mcInfo = view.mc_dengxian
    local systemName = itemData.functionName or "测试系统"
    local openDes = itemData.openDes
    local gameDes = itemData.gameDes
    local rewardDes = itemData.rewardDes
    local viewEnterName -- 功能入口
    local dayTimes = 0

    if typeId == ChallengeModel.KEYS.TOWER then
        viewEnterName = "TowerMainView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TOWER)
    elseif typeId == ChallengeModel.KEYS.PVP then 
        viewEnterName = "ArenaMainView" 
        dayTimes = ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.PVP)
    elseif typeId == ChallengeModel.KEYS.TRIAL then 
        viewEnterName = "TrialNewEntranceView"
        dayTimes =  ChallengeModel:getDayTimesBySystemId(ChallengeModel.KEYS.TRIAL)
    elseif typeId == ChallengeModel.KEYS.YIMENG then
        viewEnterName = "TowerMainView" 
        dayTimes = 1
    elseif typeId == ChallengeModel.KEYS.WONDERLAND then
        viewEnterName = "WonderlandMainView" 
        dayTimes =  WonderlandModel:getSumCountNum()
        echo(dayTimes,"_dayTimes")
    elseif typeId == ChallengeModel.KEYS.SHAREBOSS then
        dayTimes =  0
    elseif typeId == ChallengeModel.KEYS.ENDLESS then
        dayTimes =  0
    elseif typeId == ChallengeModel.KEYS.CROSSPEAK then
        self:initCrossPeak( view )
        return
    elseif typeId == ChallengeModel.KEYS.MISSION then
        dayTimes =  0
    end

    
    if isOpen1  then
        -- FilterTools.clearFilter(mcInfo:getViewByFrame(2).btn_1)
        mcInfo:showFrame(2)


        local infoUI = mcInfo:getViewByFrame(2).panel_1
        infoUI.txt_deng:setString(GameConfig.getLanguage(systemName))

        
        infoUI.panel_red:setVisible(false)
        infoUI.mc_two:showFrame(frame)
            
        infoUI.txt_2:setString(GameConfig.getLanguage(gameDes))
        infoUI.txt_3:setString(GameConfig.getLanguage(rewardDes))

        if typeId ~= ChallengeModel.KEYS.PVP then
            if dayTimes > 0 then
                --红点显示
                infoUI.panel_red:setVisible(true)
            else
                infoUI.panel_red:setVisible(false)
            end
            
        else
            self:redPointPVPShow()
            -- 剩余次数
            infoUI.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
        end

        if typeId == ChallengeModel.KEYS.TOWER  then 
            infoUI.txt_1:visible(true)
            infoUI.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
        end
        
        --单独判断忆梦
        if typeId == ChallengeModel.KEYS.YIMENG then
            infoUI.txt_1:visible(false)
            -- 判断是否显示红点
            if WorldModel:showEliteRedPoint() then
                --红点显示
                infoUI.panel_red:setVisible(true)

            else
                infoUI.panel_red:setVisible(false)
            end
            -- infoUI.txt_1:setVisible(true)
            local isopen = HomeModel:isOpenPVPFile()
            infoUI.ctn_2:removeAllChildren()
            local effect =  infoUI.ctn_2:getChildByName("effect")
            if isopen then
                if not effect then
                    effect = self:createUIArmature("UI_lilian03","UI_lilian03_yanhua", infoUI.ctn_2, true, function ()
                    end)
                    effect:setName("effect")
                    local effect1 = self:createUIArmature("UI_lilian03","UI_lilian03_xintishi", effect, true, function ()
                    end)
                    effect1:setPosition(cc.p(-95,170))
                    -- effect:setPosition(cc.p(140,100))
                end
                local isTutorial = TutorialManager.getInstance():isInTutorial()
                if not isTutorial then
                    effect:setVisible(true)
                else
                    effect:setVisible(false)
                end
            else
                if effect then
                    effect:setVisible(false)
                end
            end
        end

        ---单独判断试炼
        if typeId == ChallengeModel.KEYS.TRIAL then
            infoUI.txt_1:setString(string.format(GameConfig.getLanguage("tid_tower_1009"), dayTimes))
            local trailred =  TrailModel:showChallengTrailMainRed()
            infoUI.panel_red:setVisible(trailred or false)
        end

        --单独判断锁妖塔
        if typeId == ChallengeModel.KEYS.TOWER then
            local isShow = TowerMainModel:checkTowerAllRedPoint()
            infoUI.panel_red:setVisible(isShow)
        end

        --须臾仙境
        if typeId == ChallengeModel.KEYS.WONDERLAND then
            -- self:refreshWonderland()
            local _str = string.format(GameConfig.getLanguage("#tid_tiaozhuan_02"),tostring(dayTimes)) 
            infoUI.txt_1:setString(_str)
            local isShow = WonderlandModel:shoehomeRed()
            infoUI.panel_red:setVisible(isShow)
        end

        -- if typeId == ChallengeModel.KEYS.SHAREBOSS then
        --     infoUI.txt_1:setVisible(false)
        -- end 

        --无底深渊
        if typeId == ChallengeModel.KEYS.ENDLESS then
            local isShow = EndlessModel:updateRedPointStatus()
            infoUI.panel_red:setVisible(isShow)
            infoUI.txt_1:setVisible(false)
        end 

        --旧的回忆
        if typeId == ChallengeModel.KEYS.PVE then
            -- infoUI.txt_1:setVisible(false) 
            infoUI.panel_red:setVisible( WorldModel:showMainRedPoint()  or false )
            infoUI.txt_1:setVisible(false)
        end 

        --六界轶事
        if  typeId ==  ChallengeModel.KEYS.MISSION then
            -- infoUI.txt_1:setVisible(false)
            local isShow = MissionModel:isShowRed()
            infoUI.panel_red:setVisible(isShow or false)
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
                -- rewardView:setScxa
                FuncCommUI.regesitShowResView(rewardView,
                        rewardType, rewardNum, rewardId, itemData, true, true);
                
            end
        end
        -- mcInfo.currentView.btn_1:setTap(c_func(function ()
        infoUI.mc_two:registerBtnEff()
        infoUI.mc_two:setTouchedFunc(c_func(function ()

            if typeId == ChallengeModel.KEYS.TOWER then
                TowerControler:enterTowerMainView()
            elseif typeId == ChallengeModel.KEYS.SHAREBOSS then
                ShareBossControler:enterShareBossMainView()
            elseif typeId == ChallengeModel.KEYS.ENDLESS then
                EndlessControler:enterEndlessMainView()
            elseif typeId == ChallengeModel.KEYS.YIMENG then
                if WorldModel:isOpenElite() then
                    -- EliteMainModel:enterEliteExploreScene()
                    WindowControler:showWindow("EliteMainView")
                else
                    WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_002"))
                end
            elseif typeId == ChallengeModel.KEYS.TRIAL then
                WindowControler:showWindow(viewEnterName)
            elseif typeId == ChallengeModel.KEYS.PVE then   ---旧的回忆
                self:onClickGoPVEListView()
            elseif  typeId == ChallengeModel.KEYS.MISSION then
                WindowControler:showWindow("MissionMainView")
            else
                WindowControler:showWindow(viewEnterName)
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
        local infoUI = mcInfo:getViewByFrame(1).btn_1
        infoUI:getUpPanel().mc_1:showFrame(frame)
        infoUI:getUpPanel().txt_deng:setString(GameConfig.getLanguage(systemName))
        mcInfo:showFrame(1)

        -- FilterTools.setGrayFilter( mcInfo:getViewByFrame(1).btn_1)

        ---开启等级条件
        infoUI:getUpPanel().rich_1:setString(GameConfig.getLanguage(openDes))

        mcInfo.currentView.btn_1:setTap(c_func(function ()
            WindowControler:showTips( GameConfig.getLanguage(openDes) )
        end, self));
    end
end



function ChallengeView:onClickGoPVEListView()
    if WorldModel:isOpenPVEMemory() then
        WindowControler:showWindow("WorldPVEListView")
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_001"))
    end
end 


-- 滚动到对应的位置
function ChallengeView:todoView(systemName)
    echo("=====ChallengeView==systemName======",systemName)

    local configData = ChallengeModel:getChallengModelData()
    local groupIndex = 1
    for k,v in pairs(configData) do
        if v.name == systemName then
            groupIndex = tonumber(k)
            break
        end
    end
    self.scroll_1:gotoTargetPos(1,groupIndex ,1)  --跳到中间
    if systemName == FuncCommon.SYSTEM_NAME.ENDLESS then
        echo("============第一次引导无底深渊============")
        TeamFormationModel:allOnTeamFormationForEndless()
    end



    return groupIndex
end

function ChallengeView:press_btn_close()
    -- EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
    local isShow = ChallengeModel:checkShowRed()
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.DOWNBTN.ELITE, isShow =isShow});
    self:startHide()
end


function ChallengeView:upTowerData(event)
    TowerMainModel:updateData(event.result.data)
end


function ChallengeView:deleteMe()
    if self.mapControler then
        self.mapControler:deleteMe()
    end
    ChallengeView.super.deleteMe(self)
end


return ChallengeView;
