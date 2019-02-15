--guan
--2015.12.15
--2016.02.12 换一次界面
--2016.06.25 换二次界面
--2016.07.22 为下面btn添加开启动画，抽出ui HomeMainCompoment 
--2017.02.23 
--2017.03.21 


require("game.sys.view.home.init");  

local HomeMainView = class("HomeMainView", UIBase);

local isShowEnterAni = true;  --废弃

function HomeMainView:ctor(winName)
    HomeMainView.super.ctor(self, winName);
    --全屏ui的数量 当全屏ui的数量为0的时候 那么应该显示自己
    self._fullUINums = 0
    self.friendred = {}

end


--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function HomeMainView:getEnterBattleCacheData()
    local ret = true
    return ret;
end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
function HomeMainView:onBattleExitResume(cacheData)
    local currentSound = AudioModel:getCurrentMusic();
    if currentSound == MusicConfig.m_scene_main then 
        -- AudioModel:stopMusic();
    end 
    WindowControler:setisNeedJumpToHome(false);
end



function HomeMainView:loadUIComplete()

    HomeModel:setMainButtonOpen(true)
    WindowControler:setisNeedJumpToHome(false);
    AudioModel:playMusic(MusicConfig.m_scene_main, true)
    self.panel_4:setVisible(false)
    self.UI_huodongrukou:setVisible(false)
    ---保存右上角按钮的位置
    self:setallPanel()


    --获得主角战力
    self:getoldAbility()

    --监听注册事件
    self:registerEvent();
    ---先隐藏按钮上的所有按钮
    self:initEnterAni();

    ---UI适配
    self:initViewAlign()

    --初始化右上角按钮的点击的方法
    self:initFunc()

    --屏蔽资源点击的加号
    self:zhujianpinbi()

    --初始化左下角按钮的红点
    self:initRedPoint();

    ---初始化主角信息按钮
    self:initPlayerInfo();

   

    ---处理右上角按钮
    self:setRightButton();

    --左下边按钮是否开启
    self:leftButtonIsOpen();


    self:setMonthCardButton()

    self:setLeftRightTelescopic()



    --显示界面上按钮的动画
    self:delayCall(function ()
        self:addQuestAndChat()
         ---显示左下角将要开启系统的提示UI
        -- self:initSysWillOpenUI();
        self:showEnterAni()
    end,0.2)

    -- self:delayCall(function ()
    --    EventControler:dispatchEvent(HomeEvent.SHOW_BUTTON_EFFECT,
    --     {systemName = FuncCommon.SYSTEM_NAME.SHOP_1 ,
    --     effectType = FuncCommUI.BUTTON_EFFECT_NAME.HOISTING,
    --     isShow = true }
    -- )
    -- end,5)

    

    -- 进入主城打点
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ActionConfig.login_enter_home);

    --获取仙盟红包的数据
    GuildRedPacketModel:sendServeAllData()
    
    -- 初始化日志发送器
    self:initClientActionSender()
    

    local scene = WindowControler:getCurrScene()
    scene:setBgRootVisible(false)

    --提前加载主角选中特效
    -- FuncArmature.loadOneArmatureTexture("UI_zhujuexuanzhong", nil, true)



    -- self.mubiao_x1 = self.panel_mubiao.btn_mubiao:getPositionX()
    -- self.red_x2 = self.panel_mubiao.panel_red:getPositionX()


    --跑马灯   暂时没加
    -- WindowControler:showNotice()  


   -- -- FuncHome.getBubbleListData()
   --  self:delayCall(function ()   --延迟显示气泡
   --      HomeModel.airBubbleArr = {}
   --      HomeModel:showAirBubbleUI()
   --  end,2.5)
end 

-- 初始化日志发送器，尽量降低日志丢点
function HomeMainView:initClientActionSender()
    local initSender = function()
        self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
    end

    local delaySec = 1
    self:delayCall(c_func(initSender),delaySec)
end

function HomeMainView:updateFrame()
    -- 2分钟(2*60*30)
    local maxFrame = 3600
    if not self.frameCount then
        self.frameCount = 1
    else
        self.frameCount = self.frameCount + 1
    end

    if self.frameCount >= maxFrame then
        self.frameCount = 1
        -- 发送日志
        ClientActionControler:sendStorageFileToDataCenter();
    end
end

-- 左右伸缩
function HomeMainView:setLeftRightTelescopic()
    self.panel_mubiao.panel_r.panel_red:setVisible(false)
    self.panel_mubiao.panel_r:setTouchedFunc(c_func(self.clickLeftAndRight,self),nil,true)
end

function HomeMainView:clickLeftAndRight()
    local open = HomeModel:getMainButtonOpen()
    self.panel_mubiao.panel_r:setTouchEnabled(false)
    -- echoError("======open==========",open)
    if not self.panel_open then
        self.panel_open = true
        if open then
            self.panel_mubiao.panel_r.panel_1:setScaleX(-1)
            HomeModel:setMainButtonOpen(false)
            self:toRight()
        else
            self.panel_mubiao.panel_r.panel_1:setScaleX(1)
            HomeModel:setMainButtonOpen(true)
            self:toLeft()
            self.panel_mubiao.panel_r.panel_red:setVisible(false)
        end
    end
end

---退出
function HomeMainView:toRight()
    QuestAndChatModel:setOpenView(false)
    local function _closeCallback()
        self.panel_mubiao.panel_r:setTouchEnabled(true)
        self.panel_mubiao.panel_button:setVisible(false)
        local isShowRed = false
        for k,v in pairs(FuncHome.RIGHTBUTTON_NAME) do
            local isshow = HomeModel._showMap[v]
            echo("======是否有红点显示==vvv========",v,isshow)
            if isshow then
                isShowRed = isshow
            end
        end
        self.panel_open = false
        self.panel_mubiao.panel_r.panel_red:setVisible(isShowRed)
    end
    local  _rect = self.panel_mubiao.panel_button:getContainerBox();
    local  _otherx,_othery=self.panel_mubiao.panel_button:getPosition()
    local  _mAction=cc.MoveTo:create(0.2,cc.p(_otherx+_rect.width,_othery));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
    self.panel_mubiao.panel_button:runAction(_mSeq);
end 

function HomeMainView:toLeft()
    self.panel_mubiao.panel_button:setVisible(true)
     local function callback()
        self.panel_open = false
        self.panel_mubiao.panel_r:setTouchEnabled(true)
    end
    local  _rect=self.panel_mubiao.panel_button:getContainerBox();
    local  _otherx,_othery=self.panel_mubiao.panel_button:getPosition();
    -- self.panel_mubiao.panel_button:setPosition(cc.p(_otherx - _rect.width,_othery));
    local  _mAction = cc.MoveTo:create(0.2,cc.p(_otherx - _rect.width,_othery));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(callback));
    self.panel_mubiao.panel_button:runAction(_mSeq);
end




--设置月卡按钮
function HomeMainView:setMonthCardButton()
    for i=1,3 do
        local panel = self.panel_zuoshang["panel_card"..i]
        FilterTools.setGrayFilter(panel)
        panel:setTouchedFunc(c_func(self.cellFunMonthCard,self,i),nil,true)
    end
    local monthData =  FuncMonthCard.getconfig_MonthCard()
    for k,v in pairs(monthData) do
        if v.position then
            local monthCardId = k
            local data = MonthCardModel:checkCardIsActivity( k )
            -- echo("=====data===月卡=======",data)
            if data then
                local panel = self.panel_zuoshang["panel_card"..(tonumber(v.position))]
                FilterTools.clearFilter(panel)
            end
        end
    end
end

function HomeMainView:cellFunMonthCard(_type)
    -- echo("======月卡按钮========",_type)
    WindowControler:showWindow("MonthCardMainView")
end


function HomeMainView:setallPanel()

    ---左上角按钮的位置(三皇台，首充，八天奖励，福利等)
    self.rightBX = {}
    local num = table.length(FuncHome.RIGHTBUTTON_NAME)
    for i=1,num do
        local button = self.panel_mubiao.panel_button["ctn_"..i]
        if button ~= nil then
            self.rightBX[i] = button:getPositionX()
        end
    end
end



function HomeMainView:registerEvent()
    HomeMainView.super.registerEvent();

    EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, 
        self.onModelUpdateEnd, self)
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT, self.onRedPointChanged, self);

    
    EventControler:addEventListener(LoginEvent.LOGINEVENT_GUEST_BINDING_SUCCESS,
        self.onGuestBindingSuccess, self); 

    ---头像刷新
    EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_FRAM_EVENT,
        self.refreshHerdView, self); 

    EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_EVENT,
        self.refreshHerdView, self);

    --气泡事件
    EventControler:addEventListener(HomeEvent.SHOW_AIR_BUBBLE_UI,
        self.addBubbleView,self)

    --注册走马灯消息推送接收事件
    EventControler:addEventListener(HomeEvent.TROT_LAMP_EVENT,
        self.notifyLampShow,self);

    EventControler:addEventListener(UserEvent.BUTTON_REFRESH_EVENT, 
        self.setRightButton, self);

    EventControler:addEventListener(CarnivalEvent.CARNIVAL_PERIOD_CHANGED, 
        self.setRightButton, self);


    --等级或名字发生变化或vip
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.LvlChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USER_INFO_CHANGE_EVENT, 
        self.LvlChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_NAME_CHANGE_OK, 
        self.nameChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_SET_NAME_OK, 
        self.nameChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, 
        self.vipChangeCallBack, self)

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
        self.goldChangeCallBack, self)

    --音乐设置变化
    EventControler:addEventListener(SettingEvent.SETTINGEVENT_MUSIC_SETTING_CHANGE, 
        self.onMusicStatusChange, self)

    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOG_OUT, 
        self.lognOut, self)

    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self); 

    EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
        self.onRechargeCallBack, self);

    EventControler:addEventListener(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
        self.powerChange, self);

    EventControler:addEventListener(HomeEvent.HOME_VOICE_PLAY, 
        self.restoreMusic, self);

    EventControler:addEventListener(LoginEvent.LOGINEVENT_CLOSE_HOME_GONGGAO,
        self.showMainQiDengView, self);
    
    EventControler:addEventListener(ChargeEvent.GET_FIRST_CHARGE_REWARD_EVENT,
        self.setRightButton, self)


    EventControler:addEventListener(UserEvent.USEREVENT_EXP_CHANGE,
        self.refreshCharExp, self)

    EventControler:addEventListener(ActivityEvent.TRRIGER_WANDER_MERCHANT,
        self.setRightButton, self)
    
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT,
        self.setMonthCardButton, self)

    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_RECHARGE_SUCCESS_EVENT, 
        self.setMonthCardButton, self)

    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_TIME_OVER_EVENT, 
        self.setMonthCardButton, self)

        
    
    EventControler:addEventListener(HomeEvent.LIMIT_NEXT_UI,
        self.showNextViewLimt, self)

    EventControler:addEventListener(HomeEvent.SHOW_BUTTON_UI_VIEW,
        self.setViewNotVisible, self)

    EventControler:addEventListener(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,
        self.initRedPoint,self)

    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_IS_OPEN_EVENT,self.setRightButton, self)

    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_REFRESH_MAIN_RED,self.setRightButton, self)

    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE, self.setRightButton, self)

    EventControler:addEventListener(ActivityEvent.ACTEVENT_EVENTDAYTASK_REFRESH_RED, self.setRightButton, self)

    
end

--显示想一个限时活动的入口
function HomeMainView:showNextViewLimt(event)
    echo("=======显示下一个限时活动的入口=======")

    if event ~= nil then
        local _type = event.params._type
        if _type ~= nil then
            if HomeModel.systemToArr and HomeModel.systemToArr[_type] then
                HomeModel.systemToArr[_type] = nil
            end
        end
    end
    -- iflocal typeSystemIcon = HomeModel:hasSystemIcon()

    if self:isShowEntry() then
        self.panel_4:setVisible(false)
        self.UI_huodongrukou:setVisible(true)
        self.UI_huodongrukou:initUI()
        return 
    end
    self.UI_huodongrukou:setVisible(false)
    self:initSysWillOpenUI()
end

function HomeMainView:isShowEntry()
    local data =  HomeModel:getsystemIsOpen()
    for i=1,#data do
        local systemName = data[i].associateActivity
        local systemData = HomeModel:getSystemIsHas(systemName)
        if not systemData then
            return true
        end
    end
    return false
end



--UI适配
function HomeMainView:initViewAlign()

    if not HomeModel.logInTo then
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_aniDown,UIAlignTypes.RightBottom)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_aniLeftUp,UIAlignTypes.LeftTop)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_zuoAni,UIAlignTypes.LeftBottom)
        -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_zhanghao, UIAlignTypes.LeftTop)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_upAni, UIAlignTypes.RightTop);
    else
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_downBtns,UIAlignTypes.RightBottom)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuoshang,UIAlignTypes.LeftTop)
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_youla,UIAlignTypes.LeftBottom)
        -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_upBtns, UIAlignTypes.RightTop);
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_mubiao, UIAlignTypes.RightTop);
    end
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_4, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_qianAni, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_huodongrukou, UIAlignTypes.RightTop);
end


-- self:delayCall(function ()
--     self:addBarrageUI()
-- end,1.0)
-- --添加弹幕界面
-- function HomeMainView:addBarrageUI()

--     local arrPame = {
--         system = FuncBarrage.SystemType.world,  --系统参数
--         btnPos = {x = 0,y = -50},  --弹幕按钮的位置
--         barrageCellPos = {x = 0,y = 20}, --弹幕区域的位置
--         addview = self,--索要添加的视图
--     }
--     BarrageControler:showBarrageCommUI(arrPame)
-- end


--添加聊天和目标按钮
function HomeMainView:addQuestAndChat()

    -- echoError("=========添加聊天和目标按钮===========")
    local arrData = {
        systemView = "home",--系统
        view = self,---界面
    }
    QuestAndChatControler:createInitUI(arrData)
end

--公告退出后显示七登
function HomeMainView:showMainQiDengView()
    HomeModel:showGongGoORQIdeng()
end


--恢复主城背景音乐  

function HomeMainView:restoreMusic( )
    AudioModel:resumeMusic()--开始播放播放背景音乐
    -- AudioModel:playMusic(MusicConfig.m_scene_main, true)
end



--处理右上按钮
function HomeMainView:setRightButton()
    local rightPanel = self.panel_mubiao
    local buttonPos = {}
    local isSysOpen = {}
    local  _index = 1
    -- for i=1,#FuncHome.RIGHTBUTTON_NAME do
    rightPanel.panel_button.btn_huodong9:setVisible(false)
    for k,v in pairs(FuncHome.RIGHTBUTTON_NAME) do
        local button = rightPanel.panel_button["btn_huodong"..k]
        local i = tonumber(k)
        if button ~= nil then
            button:setVisible(false)
            local sysname = v --FuncHome.RIGHTBUTTON_NAME[i]  --FuncCommon.SYSTEM_NAME.EVERYDAYTARGET
            if i >= 2 then
                if i == 5 then
                    -- local level = UserModel:level()
                    -- if level >= 4 and level < 13 then
                    --     isSysOpen[_index] =  { widget = button, id = i}
                    --     _index = _index + 1
                    -- end
                else
                    local isopen = FuncCommon.isSystemOpen(sysname)
                    if isopen then
                       
                        if i == FuncHome.RIGHTBUTTON_INDEX.happySign then
                            isSysOpen[_index] = { widget = button, id = i,name = sysname}
                            _index = _index + 1
                            local valuer = HomeModel._showButton[sysname]
                            if valuer ~= nil and valuer == false then
                                _index = _index  - 1
                                isSysOpen[_index] = nil
                            end

                            local frame = HappySignModel:getPeriodStatus()
                            button:getUpPanel().mc_gaileyougai:showFrame(frame)
                            local str = "登录礼" --"七天奖励"
                            -- if frame == FuncHappySign.periodId.FIRST then
                            --     str = "登录礼"-- "八天奖励"
                            -- end
                            button:getUpPanel().txt_1:setString(str)
                            
                        elseif i == FuncHome.RIGHTBUTTON_INDEX.carnival then 
                            if CarnivalModel:isCarnivalOpen() then
                                isSysOpen[_index] = { widget = button, id = i,name = sysname}
                                _index = _index + 1
                                local carnivalId = CarnivalModel:getCurrentCarnivalId()
                                button:getUpPanel().mc_gaimaoa:showFrame(carnivalId)
                                local str = "开服狂欢"
                                -- if carnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
                                --     str = "嘉年华"
                                -- end
                                button:getUpPanel().txt_1:setString(str)
                            end
                        elseif  i == FuncHome.RIGHTBUTTON_INDEX.everydayTarget then
                            local isopens = ActTaskModel:checkEverydayShow()
                            if  isopens then
                                isSysOpen[_index] =  { widget = button, id = i,name = sysname}
                                _index = _index + 1
                            end
                        elseif  i == FuncHome.RIGHTBUTTON_INDEX.mall then 
                            isSysOpen[_index] = { widget = button, id = i,name = sysname}
                            _index = _index + 1
                        elseif  i == FuncHome.RIGHTBUTTON_INDEX.monthCard then 
                            isSysOpen[_index] = { widget = button, id = i,name = sysname}
                             _index = _index + 1  
                        elseif i == FuncHome.RIGHTBUTTON_INDEX.traveler then
                            local open = ActConditionModel:checkIfHasWanderMerchant()
                            if open then
                                isSysOpen[_index] =  { widget = button, id = i,name = sysname}
                                _index = _index + 1
                            end
                        elseif i == FuncHome.RIGHTBUTTON_INDEX.activityEntrance then 
                            isSysOpen[_index] = { widget = button, id = i}
                             _index = _index + 1 
                             local str = "活动"
                             button:getUpPanel().txt_1:setString(str)
                        elseif i == FuncHome.RIGHTBUTTON_INDEX.roulette then
                            local open = LuckyGuyModel:isOpenAct()
                            if open then
                                isSysOpen[_index] =  { widget = button, id = i,name = sysname}
                                _index = _index + 1
                                local str = "幸运探宝"
                                button:getUpPanel().txt_1:setString(str)
                            end
                        else  --首冲不开启
                            if ActivityFirstRechargeModel:haveGetFirstGift() then

                            else
                                isSysOpen[_index] = { widget = button, id = i,name = sysname}
                                _index = _index + 1
                            end                        
                        end
                    end
                end  
            else
                isSysOpen[_index] =  { widget = button, id = i,name = sysname}
                _index = _index + 1
            end
        end
    end
    HomeModel:insertCtnToclone(isSysOpen)
    for i=1,#isSysOpen do
        local button = isSysOpen[i].widget
        local panel =  self.panel_mubiao.panel_button["ctn_"..i]
        local ctn_x = panel:getPositionX()
        button:setPositionX(ctn_x - 20)
        button:setVisible(true)
        if isSysOpen[i].name == FuncHome.RIGHTBUTTON_NAME[7] then
            self:addButtonEff(button)
        end
    end

    for k,v in pairs(FuncHome.RIGHTBUTTON_NAME) do
        local i= tonumber(k)
        --设置按钮点击事件
        local button = rightPanel.panel_button["btn_huodong"..i]
        if button ~= nil then
            button:setTouchedFunc(c_func(self._btnFuncs[i],self),nil,true)
            --处理按钮点击的红点事件
            local panel_red = button:getUpPanel().panel_red
            if panel_red then
                panel_red:setVisible(false)

                if v == "roulette" then  ---- 转盘单独处理了 不行再改
                    if CountModel:getLuckyGuyFreeTimes() == 0 then
                        panel_red:setVisible(true)
                    end
                elseif v == "traveler" then
                    local times = CountModel:getTravelShopNum()  --- 购买礼包次数
                    if times == 0 then
                        panel_red:setVisible(true)
                    end
                elseif v == "everydayTarget" then
                    if ActTaskModel:getEverydayTargetRed() then
                        panel_red:setVisible(true)
                    end
                else
                    local  activename = v
                    if activename ~= nil then
                        local isshow = HomeModel._showMap[activename] or false
                        panel_red:setVisible(isshow)
                    end
                end
            end
        end
    end
end

function HomeMainView:addButtonEff(button)
    local ctn = button:getUpPanel()
    if not ctn:getChildByName("UI_zhujiemian") then
        local ani = self:createUIArmature("UI_zhujiemian",
            "UI_zhujiemian_yuekaxiaoguo", ctn, true)
        local box = button:getContainerBox()
        ani:setScale(0.66)
        ani:setName("UI_zhujiemian")
        ani:setPosition(cc.p(box.width/2+3,-box.height/2+14))
        ani:getBoneDisplay("layer2"):setVisible(false)
        ani:getBoneDisplay("layer3"):setVisible(false)
    end
end

function HomeMainView:initFunc()
    -- self._btnFuncs = {
    --     [1] = self.clickLottery,
    --     [2] = self.clickShop,
    --     [3] = self.TODOinFuLi,
    --     [4] = self.TODOinKuanghuang,
    --     [5] = self.TODOinQiDeng,
    --     [6] = self.TODOinShouChong,
    --     [7] = self.TODOinReward,
    --     [8] = self.TODOinEverydayTarget,
    -- };
    self._btnFuncs = {
        [1] = self.TODOinFuLi,
        [2] = self.TODOinKuanghuang,
        [3] = self.TODOinQiDeng,
        [4] = self.TODOinShouChong,
        [5] = self.TODOinReward,
        [6] = self.TODOinEverydayTarget,
        [7] = self.TODOmontherCard,
        [8] = self.TODOMall,
        [9] = self.TODOinActCondition,
        [10] = self.TODONewActivity,
        [11] = self.TODONewroulette,
    };
end

--幸运转盘活动
function HomeMainView:TODONewroulette()
    if LuckyGuyModel:isOpenAct() then
        WindowControler:showWindow("LuckyGuyMainView")
    else
        WindowControler:showTips("活动已过期")
    end
end

function HomeMainView:TODONewActivity(  )
    WindowControler:showWindow("NewActivityMainView")
end

function HomeMainView:TODOmontherCard()
    WindowControler:showWindow("MonthCardMainView")
    -- WindowControler:showWindow("LuckyGuyMainView")
end

function HomeMainView:TODOMall()
    WindowControler:showWindow("MallMainView")
end

function HomeMainView:TODOinActCondition()
    ActConditionModel:openWanderMerchantView()
end

function HomeMainView:TODOinEverydayTarget()
    WindowControler:showWindow("WelfareActFouView")
end

function HomeMainView:TODOinReward()
    -- WindowControler:showWindow("LevelRewardView")
end
--三皇台
function HomeMainView:clickLottery()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.LOTTERY)
    -- WindowControler:showWindow("GatherSoulMainView");
    
end
--商店
function HomeMainView:clickShop()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.SHOP_1)
    -- if self._aniToDisposeArray[sysName] == true then 
    --     self._aniToDisposeArray[sysName] = false;
    --     npcPanel.ctn_ani:removeAllChildren();
    --     npcPanel.ctn_icon:setVisible(true);
    --     npcPanel.ctn_npcName:setVisible(true);
    -- end 
end
--福利
function HomeMainView:TODOinFuLi()
    WindowControler:showWindow("WelfareNewMinView");
end
--首充
function HomeMainView:TODOinShouChong()
    -- WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"));   
    WindowControler:showWindow("ActivityFirstRechargeView")
end
--狂欢
function HomeMainView:TODOinKuanghuang()   
    if CarnivalModel:isCarnivalOpen() then
        WindowControler:showWindow("CarnivalMainView")
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
    end
end
--七登
function HomeMainView:TODOinQiDeng()
    WindowControler:showWindow("HappySignView")  
end
--六界大事
function HomeMainView:TODOinLiuJie()
    WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"));
end

--显示战力特效显示 ---每次到主界面都会调用
function HomeMainView:showAbilityEffect()
    local windownames =  TutorialManager.getInstance():isHomeExistSysOpen() and TutorialManager.getInstance():isHasTriggerSystemOpen()
    echo("========系统开启返回===========",windownames)
    if not windownames then
        if  self.oldAbility ~= nil or self.oldAbility ~= 0 then
            if self.oldAbility ~= UserModel:getcharSumAbility()  then-- UserModel:getAbility() then
                if self.oldAbility < UserModel:getcharSumAbility() then-- UserModel:getAbility() then
                    FuncCommUI.showPowerChangeArmature(self.oldAbility or 10, UserModel:getcharSumAbility() or 10,0.8,true,1.8);
                end
            end
        end
    end
    self.oldAbility = UserModel:getcharSumAbility()
    ---主角战力到达头衔所需战力条件发送头衔红点显示
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.DOWNBTN.CHAR, isShow = CharModel:isShowCharCrownRed()});
    self:setPlayerPower()
end
-- 获得主角战力
function HomeMainView:getoldAbility()
    self.oldAbility = UserModel:getcharSumAbility()
end



function HomeMainView:initEnterAni()
    if HomeModel.isShowEnterAni == true then 

        WindowControler:setUIClickable(false);

        self.UI_downBtns:setVisible(false);
        -- self.UI_upBtns:setVisible(false);
        self.panel_mubiao:setVisible(false);
        self.panel_zuoshang:setVisible(false);
        self.panel_youla:setVisible(false);
        -- self.btn_zhanghao:setVisible(false);

        -- EventControler:addEventListener(HomeEvent.SHOW_RES_COMING_ANI, 
        --     self.showEnterAni, self);
    end 
end 

--设置界面不显示和不播动画
function HomeMainView:setViewNotVisible(_event)
    local isShow =  _event.params.isShow
    self:setVisible(isShow)
    HomeModel.isShowEnterAni = isShow
    HomeModel:LogInToType()
    if isShow then
        self:showEnterAni()
        self:addQuestAndChat()
    end
    WindowControler:setUIClickable(true)
end

--显示主城动画
function HomeMainView:showEnterAni()
    echo("------HomeMainView showEnterAni----");
    
    if HomeModel.isShowEnterAni == true then
        self:setVisible(true)
        --下面
        local downAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a1", 
            self.ctn_aniDown, false, function ( ... )
                
                --触发新手
                -- EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
                --     {tutorailParam = TutorialEvent.CustomParam.FirstInHomeTown});
                EventControler:dispatchEvent(WorldEvent.WORLD_UI_AND_BTN_FINISH, {_type = "homeBtn"})
                -- WindowControler:setUIClickable(true)
                
                HomeModel.isShowEnterAni = false;

                LoginControler:checkShowPlayerSetNicknameView()
                
                -- dump(UserModel.LoginData,"1111111111",6)
                if UserModel.LoginData == nil then
                    ------warning查是否弹出七登或者公告界面
                    -- if not HomeModel.logInTo then
                    --    HomeModel:homeMainShowGongGao()
                    -- end
                else
                    UserModel.LoginData = nil
                    -- 重新同步用户状态
                    CommonServer:updateUserState()
                    -- LoginInfoControler:onBattleStatus(UserModel.LoginData,false)
                end

                local openClickable = function()
                    WindowControler:setUIClickable(true)
                end

                -- 如果主城上当前没有强制引导
                if not TutorialManager.getInstance():isHomeExistGuide() then
                    WindowControler:setUIClickable(true)
                end
                
                HomeModel:LogInToType() ---添加一个重新登入还是界面退的的方法 
                self:showSystemOpenByHome()
                
            end);

        if not HomeModel.logInTo then
           HomeModel:homeMainShowGongGao()
        end

        FuncArmature.changeBoneDisplay(downAni, "layer1", self.UI_downBtns);
        self.UI_downBtns:setPosition(0, 0);


        
        if self:questOpen() then
            --活动icon  
            local activityAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a3", 
                self.ctn_upAni, false, GameVars.emptyFunc);
            self.panel_mubiao:setPosition(0, 0);
            FuncArmature.changeBoneDisplay(activityAni, "layer1", self.panel_mubiao);
        end

        --左边的东西
        local leftAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a4", 
            self.ctn_zuoAni, false, GameVars.emptyFunc);
        self.panel_youla:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(leftAni, "layer1", self.panel_youla);    

        --名字
        local leftUpAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a5", 
            self.ctn_aniLeftUp, false, GameVars.emptyFunc);
        self.panel_zuoshang:setPosition(0, 0);
        FuncArmature.changeBoneDisplay(leftUpAni, "layer1", self.panel_zuoshang);

        self.UI_huodongrukou:setVisible(true)
        self.UI_huodongrukou:initUI()
    else
        self.UI_huodongrukou:setVisible(true)
        self.UI_huodongrukou:initUI()
    end 


end


function HomeMainView:goldChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:powerChange()
    self:setPlayerPower();
end

function HomeMainView:onRechargeCallBack()
    -- if VipModel:getNextVipGiltToBuy() ~= -1 then 
    --     self.panel_zuoshang.panel_red:setVisible(true);
    -- else 
    --     self.panel_zuoshang.panel_red:setVisible(false);
    -- end 

    -- self.panel_zuoshang.panel_red:setVisible(false)
end 

function HomeMainView:onHomeShow(event)
    echo("----------------！！！！come home now ！！！---------------")
    local lastViewName = nil
    if event ~= nil then
        if event.params ~=  nil then
            lastViewName = event.params.lastViewName
            echo("-----------上一次的界面-----------",lastViewName);
        end
    end

    

    ---主界面已经没有地图。注释不用
    -- EventControler:dispatchEvent(HomeEvent.BLACK_TO_MAINVIEW_FRESH_MAP_COT,
    --     {lastViewName = lastViewName})


    --到新主城后，调用另外一个新手引导
    -- if HomeModel.isShowEnterAni == false then 
    --     EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
    --         {tutorailParam = TutorialEvent.CustomParam.FirstInHomeTown});
    -- end 
     
    --主城音乐，
    -- local currentSound = AudioModel:getCurrentMusic();
    -- if currentSound ~= MusicConfig.m_scene_main then 
    --     AudioModel:playMusic(MusicConfig.m_scene_main, true)
    -- end 

    -- WindowControler:setisNeedJumpToHome(false);
    self:showAbilityEffect()

    -- 二测升级奖励临时弹窗  暂时没用到
    -- self:delayCall(function ( ... )
    --     WindowControler:showLevelUpReward()
    -- end,1)


    self:comeBackToThisView();


    self:leftButtonIsOpen()

    self:buttonresumeUIClick()

    -- self:addQuestAndChat()

    HomeModel.airBubbleArr = {}
    HomeModel:showAirBubbleUI()

    local params = {
        [1] = {params = FuncCommon.SYSTEM_NAME.QUEST},
        [2] = {params = FuncCommon.SYSTEM_NAME.FRIEND},
    }
    for i=1,#params do
        self:addBubbleView(params)
    end
    
    self:showSystemOpenByHome()
    self:initSysWillOpenUI()
end

--//调整消息通知提示UI结构
function HomeMainView:notifyLampShow(_param)
      local   _lamps=_param.params;
      for _index=1,#_lamps do
               -- self.UI_lamp:insertMessage(_lamps[_index]);
      end
end
---按钮恢复事件
function HomeMainView:buttonresumeUIClick()
    self:resumeUIClick()
end
---按钮禁止恢复事件
function HomeMainView:buttondisabledUIClick()
    self:disabledUIClick()
end

function HomeMainView:lognOut()
    -- self:startHide();
end

function HomeMainView:vipChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:nameChangeCallBack()
    self:initPlayerInfo();
end

function HomeMainView:LvlChangeCallBack()
    self:initPlayerInfo();
    self:initSysWillOpenUI();
    self:setRightButton();
end

function HomeMainView:initSysWillOpenUI()
    if self:isShowEntry() then
        self.panel_4:setVisible(false);
        return
    end
    -- echo("======initSysWillOpenUI====系统开启==")
    local willOpenName, condition = HomeModel:getWillOpenSysName();
    local typeSystemIcon = HomeModel:hasSystemIcon()
    -- echo("========willOpenName======系统开启=======",willOpenName,typeSystemIcon)
    self.panel_4:setVisible(typeSystemIcon);
    if self.panel_4:isVisible() then
        if willOpenName ~= nil then
            local panel = self.panel_4.btn_sysicon:getUpPanel();
            local ctn = panel.ctn_sysicon;
            ctn:removeAllChildren();
            local spPath = FuncRes.iconSys(willOpenName);

            local sp = display.newSprite(spPath);
            ctn:addChild(sp);
            sp:size(ctn.ctnWidth, ctn.ctnHeight);
            self.panel_4.btn_sysicon:setTouchedFunc(c_func(self.pressWillOpenSys, 
                self, willOpenName, condition), nil,true);
            local tidName = FuncCommon.getSysOpensysname(willOpenName);
            local systemicon = willOpenName.."_title.png"
            local spices = FuncRes.iconSys(systemicon)
            local icon = display.newSprite(spices)
            -- icon:setScale(0.6)
            -- icon:anchor(0.1,0.8)
            local tid =  FuncCommon.getSysOpenValue(willOpenName, "newsystemName")
            panel.ctn_sytemname:removeAllChildren()
            panel.ctn_sytemname:addChild(icon)
            --等级
            panel.rich_level:setString(GameConfig.getLanguage(tid))


            local _effect = self.panel_4.ctn_eff:getChildByName("UI_tishi_zong")--armatureName[colorframe])
            if not _effect then
                _effect= self:createUIArmature("UI_tishi","UI_tishi_zong", self.panel_4.ctn_eff, true, GameVars.emptyFunc)
                _effect:setName("UI_tishi_zong")
            end
            _effect:startPlay(true)

        end
    end
end

function HomeMainView:pressWillOpenSys(willOpenName, condition)
    local willOpenName, condition = HomeModel:getWillOpenSysName()
    WindowControler:showWindow("SysWillOpenView", willOpenName, condition);
end

function HomeMainView:onMusicStatusChange(event)
    local music_st = LS:pub():get(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.ON)
    if music_st == FuncSetting.SWITCH_STATES.ON then
        if audio.isMusicPlaying() then
            AudioModel:resumeMusic()
        else
            AudioModel:playMusic("m_scene_main", true)
        end
    end
end

function HomeMainView:initRedPoint()
    -- self.panel_youla.panel_2.panel_red:setVisible(false)
    local isshowred = FriendModel:isFriendApply()  or  FriendModel:getFriendIsHaveSp() or false 
    self.panel_youla.panel_1.panel_red:setVisible(isshowred);
    -- self.panel_youla.panel_3.panel_red:setVisible(false)
    self.panel_youla.panel_mail.panel_red:setVisible(MailModel:checkShowRedForFriend() or false)
    self.panel_youla.panel_mubiao.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.NPC.QUEST) or false)
    -- self.panel_mubiao.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.NPC.QUEST))
    self.panel_youla.panel_luntan.panel_red:setVisible(false)
end

function HomeMainView:initPlayerInfo()
    self.panel_zuoshang.ctn_touxiang:setTouchedFunc(c_func(self.clickPlayerInfo, self), nil,true);


    local name = UserModel:name();
    self.panel_zuoshang.txt_1:setString(name);
    --等级
    local lvl = UserModel:level();

    if lvl < 10 then 
        self.panel_zuoshang.mc_2:showFrame(1);
    elseif lvl < 100 then
        self.panel_zuoshang.mc_2:showFrame(2);
    else 
        self.panel_zuoshang.mc_2:showFrame(3);
    end 
    self.panel_zuoshang.mc_2:getCurFrameView().txt_2:setString(lvl);

    --vip
    -- local vip = UserModel:vip();
    -- self.panel_zuoshang.mc_1:showFrame(vip + 1);
    -- self.panel_zuoshang.mc_1:setTouchedFunc(c_func(self.gotoVipView, self), nil,true);
    -- self.panel_zuoshang.mc_1:setVisible(false);

    -- if VipModel:getNextVipGiltToBuy() ~= -1 then 
    --     self.panel_zuoshang.panel_red:setVisible(true);
    -- else 
    --     self.panel_zuoshang.panel_red:setVisible(false);
    -- end 

    

    self.panel_zuoshang.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.PLAYERINFO.TITLE))

    --战力
    self:setPlayerPower();

    --头像
    local ctn =  self.panel_zuoshang.ctn_touxiang
    UserHeadModel:setPlayerHeadAndFrame(ctn,UserModel:avatar(),UserModel:head(),UserModel:frame())



   
    self:refreshCharExp()

end

function HomeMainView:refreshCharExp()
    local currentExp = UserModel:exp()
    local maxExp = FuncChar.getCharMaxExpAtLevel(UserModel:level())
    local txt_exp =  self.panel_zuoshang.txt_2
    local progress_1 = self.panel_zuoshang.progress_1
    if FuncChar.getCharMaxLv() == UserModel:level() then 
        txt_exp:setString("--/--")--显示文字百分比
        progress_1:setPercent(100) --显示进度条
    else
        local str = string.format("%d/%d",currentExp, maxExp)
        local percent = currentExp*1.0/maxExp*100
        txt_exp:setString(str)
        progress_1:setPercent(percent)
    end
end

function HomeMainView:clickUpdateUser()
    echo("----clickUpdateUser----");
    WindowControler:showWindow("LoginBindingAccount")
end

function HomeMainView:onGuestBindingSuccess()
    self.btn_zhanghao:setVisible(false)
end

function HomeMainView:gotoVipView()
    local pageView = VipModel:getNextVipGiltToBuy();
    if pageView == -1 then 
        pageView = UserModel:vip();
    end 
    -- WindowControler:showWindow("VipMainNewView", false, pageView);
end

---设置主角战力
function HomeMainView:setPowerNum(nums)
    local power =  UserModel:getcharSumAbility() 
    self.panel_zuoshang.panel_zhanli.UI_num:setPower(power)

end

function HomeMainView:setPlayerPower()
    local power = UserModel:getcharSumAbility() --UserModel:getAbility();
    local powerValueTable = number.split(power);

    self:setPowerNum(powerValueTable);
end

function HomeMainView:clickPlayerInfo()
    AudioModel:playSound("s_com_click1")
    echo("--clickPlayerInfo--");
    WindowControler:showWindow("PlayerInfoView");
    
end


function HomeMainView:addBubbleView(params)
    local system = params.params
    if system == FuncCommon.SYSTEM_NAME.QUEST then
        -- local  datatable1 = {systemname = FuncCommon.SYSTEM_NAME.QUEST,npc = false,offset = {x = 10,y = -90} }
        -- FuncCommUI.regesitShowBubbleView(datatable1,self.panel_youla.panel_mubiao)
    elseif system == FuncCommon.SYSTEM_NAME.FRIEND then
        local  datatable2 = {systemname = FuncCommon.SYSTEM_NAME.FRIEND,npc = false }
        -- FuncCommUI.regesitShowBubbleView(datatable2,self.panel_youla.panel_1)
    end

end



--目标任务开启问题
function HomeMainView:questOpen()
    local isopen = true
    for i=1,#FuncQuest.systemName do
        local opens,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(FuncQuest.systemName[i])
        if is_sy_screening then
            isopen = false
            break
        end
    end
    return isopen
end
--左下边系统是否开启
function HomeMainView:leftButtonIsOpen()
    
    -- self.panel_youla.panel_2:setVisible(false)
    -- self.panel_youla.panel_3:setVisible(false)
    -- self.panel_youla.panel_dt:setVisible(false)

    -- self.panel_youla.panel_lb.panel_red:setVisible(false)
    --左边三个btn
    self.panel_youla.panel_1.btn_1:setTouchedFunc(c_func(self.showFriendView, self), nil,true);
    self.panel_youla.panel_mail:setTouchedFunc(c_func(self.showEmailView, self), nil,true);
    self.panel_youla.panel_mubiao:setTouchedFunc(c_func(self.questClick, self), nil,true)
    self.panel_youla.panel_lianjie:setTouchedFunc(c_func(self.questionnaireClick, self), nil,true)
    self.panel_youla.panel_chat:setTouchedFunc(c_func(self.chatClick, self), nil,true)
    self.panel_youla.panel_luntan:setTouchedFunc(c_func(self.luntanClick, self), nil,true)

    local buttonArr = {}  --cloneBtn = nil

        
    local chat_isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT)
    if chat_isopen then
        self.panel_youla.panel_chat:setVisible(true)
        self.panel_youla.panel_chat.panel_red:setVisible(ChatModel:getPrivateDataRed() or false)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_chat ,name = FuncCommon.SYSTEM_NAME.CHAT }
        table.insert(buttonArr,cloneBtn)
    else
        self.panel_youla.panel_chat:setVisible(false)
    end

    local friend_isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND)
    if friend_isopen then
        self.panel_youla.panel_1:setVisible(true)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_1,name = FuncCommon.SYSTEM_NAME.FRIEND }
        table.insert(buttonArr,cloneBtn)
    else
        self.panel_youla.panel_1:setVisible(false)
    end

    local mail_isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIL)
    if mail_isopen then
        self.panel_youla.panel_mail:setVisible(true)
        self.panel_youla.panel_mail.panel_red:setVisible(MailModel:checkShowRedForFriend() or false)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_mail ,name = FuncCommon.SYSTEM_NAME.MAIL }
        table.insert(buttonArr,cloneBtn)
    else
        self.panel_youla.panel_mail:setVisible(false)
    end

    local quest_isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST)
    if quest_isopen then
        self.panel_youla.panel_mubiao.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.NPC.QUEST) or false)
        self.panel_youla.panel_mubiao:setVisible(true)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_mubiao ,name = FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST}
        table.insert(buttonArr,cloneBtn)
    else
        self.panel_youla.panel_mubiao:setVisible(false)
    end

  
    local luntan_isopen = PCSdkHelper:isTencentChannel()
    if luntan_isopen then
        self.panel_youla.panel_luntan:setVisible(true)
        self.panel_youla.panel_luntan.panel_red:setVisible(ChatModel:getPrivateDataRed() or false)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_luntan ,name = FuncCommon.SYSTEM_NAME.CHAT }
        table.insert(buttonArr,cloneBtn)
    else
        self.panel_youla.panel_luntan:setVisible(false)
    end

    self.panel_youla.panel_lianjie.panel_red:setVisible(false)
    -- 问卷按钮
    if GameStatic:checkQuestionnaireClosed() then
        self.panel_youla.panel_lianjie:setVisible(false)
    else
        self.panel_youla.panel_lianjie:setVisible(true)
        local cloneBtn = {cloneBtn = self.panel_youla.panel_lianjie ,name = "feedback"}
        table.insert(buttonArr,cloneBtn)
    end


    

    HomeModel:insertCtnToclone(buttonArr)


    for i=1,table.length(buttonArr) do
        local panel  = buttonArr[i]
        if panel  then
            local ctn_ = self.panel_youla["ctn_"..i]
            local x = ctn_:getPositionX()
            local y = ctn_:getPositionY()
            panel.cloneBtn:setPosition(cc.p(x,y))
        end
    end

end

---应用宝
function HomeMainView:luntanClick()
    echo("=====应用宝======")
    PCSdkHelper:openForum()
end

function HomeMainView:chatClick()
    WindowControler:showWindow("ChatMainView");
end

-- 问卷调查
function HomeMainView:questionnaireClick()
    local callBack = function(data)
        if data and data.result then
            local url = data.result.data.url
            if device.platform == "ios" then
                PCSdkHelper:loadUrl(url,0)
            elseif device.platform == "android" then
                PCSdkHelper:loadUrl(url,3)
            else
                PCSdkHelper:loadUrl(url,3)
            end
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_main_wenjuan_0001"))
        end
    end

    HomeServer:getQuestionnaireUrl(c_func(callBack))
end


function HomeMainView:refreshHerdView(event)
    dump(event.params,"数据模式")
    local data = event.params
    local _ctn = self.panel_zuoshang.ctn_touxiang
    if data.userHeadId then
        UserHeadModel:setPlayerHeadAndFrame(_ctn,UserModel:avatar(),data.userHeadId,nil)
    elseif data.headFrameId then
        UserHeadModel:setPlayerHeadAndFrame(_ctn,UserModel:avatar(),nil,data.headFrameId)
    end
end


function HomeMainView:kefuBtnClick()
    -- WindowControler:showWindow("GameFeedBackView")
    GameFeedBackControler:enterGameFeedBackView()
end

function HomeMainView:cdKeyBtnClick()
    WindowControler:showWindow("CdkeyExchangeView")
    -- local rewards = {"4,500", "4,500", "4,500", "4,500", "4,500", "4,500", "4,500", "4,500", "4,500", "4,500"}
    -- WindowControler:showWindow("CdkeyExchangeResult", rewards)
end

function HomeMainView:chatBtnTeamClick()
     -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015")); ---暂未开启
     -- TODO 屏蔽工会相关逻辑 by ZhangYanguang
     -- WindowControler:showWindow("TriaNewlTeamView");
end


function HomeMainView:changeMap()
    self._mapNode:changeMap();
end

function HomeMainView:questClick()
    WindowControler:showWindow("QuestMainView");
end

--//红点事件变化 djb
function HomeMainView:onRedPointChanged(_event)
    
    local params = _event.params
    -- local tempFunc = function ()
        local  _param= params;
        local id = params.redPointType;
        local isShow = params.isShow or false;
        if (_param.redPointType == HomeModel.REDPOINT.LEFTMARGIN.FRIEND) then
            self.panel_youla.panel_1.panel_red:setVisible(isShow or false);
        elseif _param.redPointType == HomeModel.REDPOINT.LEFTMARGIN.MAIL then
            local mailred =  MailModel:checkShowRedForFriend() or false
            self.panel_youla.panel_mail.panel_red:setVisible(mailred);
        elseif _param.redPointType == HomeModel.REDPOINT.PLAYERINFO.TITLE then
            self.panel_zuoshang.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.PLAYERINFO.TITLE))
        elseif _param.redPointType == FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST then
            self.panel_youla.panel_mubiao.panel_red:setVisible(_param.isShow or false)
        end

        
        local rightPanel = self.panel_mubiao
        local index = 1
        -- 活动的入口红点
        local cellindex = FuncHome.RIGHTBUTTON_INDEX[id]
        if  cellindex ~= nil then
            index = cellindex
            local button = rightPanel.panel_button["btn_huodong"..index]
            if button ~= nil then
                button:getUpPanel().panel_red:setVisible(isShow)
            end
        end
        
    -- end

    -- self.panel_youla:stopAllActions()
    -- self.panel_youla:delayCall(c_func(tempFunc), 0.01)
end

function HomeMainView:mailBtnClick()
    echo("clickA1_mail");
    -- WindowControler:showWindow("MailView")
end


function HomeMainView:onModelUpdateEnd()
    self:initPlayerInfo()
end


--当一个ui开始显示的时候
--todo 判断是不是全屏界面  HOMEEVENT_COME_BACK_TO_MAIN_VIEW
function HomeMainView:onUIShowComp( e )

    echo("=======HomeMainView==显示其它界面=========")
    if WindowControler:isCurViewIsHomeTown() == true then 
        return;
    end 
    local targetUI = e.params.ui
    if targetUI:checkIsFullUI()  then
        self:resetBtnsCompoment();
    end
end


--又返回这个界面执行的函数, 这个是全屏界面才做的判断
function HomeMainView:comeBackToThisView()
    -- echo("------HomeMainView:comeBackThisView--------");
end

function HomeMainView:resetBtnsCompoment()
    echo("---HomeMainView:resetBtnsCompoment---");
    --有新的btn出现进行重置
    if self.UI_downBtns._isNeedReSetDownBtns == true then 
        self.UI_downBtns._isNeedReSetDownBtns = false;
        self.UI_downBtns:resetBtns();
    end 
end

function HomeMainView:showFriendView()
   FriendViewControler:showView();
end
function HomeMainView:showEmailView()
    WindowControler:showWindow("FriendEmailview")
end


function HomeMainView:gototest()
    self:startHide();
end

function HomeMainView:deleteMe()
    HomeModel:setHomeUI(nil);
    
    self._mapNode:dispose();
    HomeMainView.super.deleteMe(self);

    UserModel:cacheUserData();

end 

function HomeMainView:updateLayerBubbleUI(chatData)
    self._mapNode:updateBubbleUI(chatData);
end

-- 获取下排图标实例
function HomeMainView:getBtnComponent()
    return self.UI_downBtns
end

-- 获取目标系统实例
function HomeMainView:getQuestPanel()
    return self.panel_youla
    -- return self.panel_mubiao
end
function HomeMainView:getRightButtonTab()
    local button = {
        [1] = self.panel_mubiao.panel_button.btn_huodong1,
        [2] = self.panel_mubiao.panel_button.btn_huodong2,
        [3] = self.panel_mubiao.panel_button.btn_huodong3,
        [4] = self.panel_mubiao.panel_button.btn_huodong4,
        [5] = self.panel_mubiao.panel_button.btn_huodong5,
        [6] = self.panel_mubiao.panel_button.btn_huodong6,
    }
    return button
end
---屏蔽加号
function HomeMainView:zhujianpinbi()
    self.panel_zuoshang.panel_res.UI_yuanbao.btn_xianyujiahao:setVisible(false)
    -- self.panel_zuoshang.panel_res.UI_sanhuang.btn_lingshijiahao:setVisible(false)
    -- self.panel_zuoshang.panel_res.UI_tongbi.btn_lingshijiahao:setVisible(false)
    self.panel_zuoshang.panel_res.UI_tili.btn_tilijiahao:setVisible(false)
end

--[[
    在没有引导控制的新功能开启的情况下由主城控制
]]
function HomeMainView:showSystemOpenByHome()
    local flag,systems = TutorialManager.getInstance():isHasTriggerSystemOpen()
    if flag then
        -- 递归调用新功能开启
        HomeModel:openNewSystem(systems[1], c_func(self.showSystemOpenByHome, self))
    end
end

-- 开启新功能，展示新图标出现动画
function HomeMainView:openNewSystem(sysName, callBack)

    --系统名称转换
    local sysTypeName = FuncCommon.getEntranceName(sysName)
    local pos,ctnInfo,isserve  =  HomeModel:getCtnWidgetPos(sysTypeName) --  self:getCtnWidgetPos(sysTypeName)
    local btnInCtnWidget = nil
    if  table.find(FuncHome.homemLeftButtonArr,sysTypeName) then
        local questAndChatMainView = self:getChildByName("QuestAddMainListView")
        if questAndChatMainView then
            btnInCtnWidget = questAndChatMainView.panel_2
        end
    elseif  table.find(FuncHome.RIGHTBUTTON_NAME,sysTypeName) then
        btnInCtnWidget = ctnInfo.widget
    else 
        btnInCtnWidget = ctnInfo.cloneBtn
    end

   -- 屏蔽点击
    WindowControler:setUIClickable(false)
    local array = {
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            WindowControler:setUIClickable(true)
            if callBack then callBack() end
        end),
    }
    if btnInCtnWidget then
        btnInCtnWidget:setOpacity(0)
        btnInCtnWidget:runAction(cc.Sequence:create(array))
    end
end

-- 获取某功能图标的位置
function HomeMainView:getSystemPos(sysName)
    echo("=======子系统名称===111======",sysName)
    local sysTypeName = FuncCommon.getEntranceName(sysName)
    local pos = HomeModel:bySysNameGetCtnPos(sysName)
    if pos == nil then
        echo("======pos===不存在位置报错找前端=====")
    end
    return pos

end

function HomeMainView:deleteMe(...)
    HomeMainView.super.deleteMe(self,...)

end

return HomeMainView;