-- GuildMainView
--wk

require("game.sys.view.home.init");  

local GuildMainView = class("GuildMainView", UIBase);

local isShowEnterAni = true;

function GuildMainView:ctor(winName)
    GuildMainView.super.ctor(self, winName);
    --全屏ui的数量 当全屏ui的数量为0的时候 那么应该显示自己
    self._fullUINums = 0

end


--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function GuildMainView:getEnterBattleCacheData()
    local ret = true
    return ret;
end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
-- function GuildMainView:onBattleExitResume(cacheData)
--     local currentSound = AudioModel:getCurrentMusic();
--     if currentSound == MusicConfig.m_scene_main then 
--         -- AudioModel:stopMusic();
--     end 
--     WindowControler:setisNeedJumpToHome(false);
-- end

-- function GuildMainView:onBecomeTopView()
--     local currentSound = AudioModel:getCurrentMusic();
--     if currentSound ~= MusicConfig.m_scene_main then 
--         AudioModel:playMusic(MusicConfig.m_scene_main, true)
--     end 
--     WindowControler:setisNeedJumpToHome(false);
--     self:showAbilityEffect()
-- end


function GuildMainView:loadUIComplete()

    -- echo(GuildModel:getlastGveTime(),"\n\n\n\n\n上一次gvetime")
    -- dump(GuildModel:getGvefood(),"公会煮菜信息")
    -- dump(GuildModel:getGveMembers(),"参加公会gve活动成员信息")
    -- dump(GuildModel:getGveTeams(),"组队列表")

    -- WindowControler:setisNeedJumpToHome(false);

    -- AudioModel:playMusic(MusicConfig.m_scene_main, true)

    FuncArmature.loadOneArmatureTexture("UI_zhujuexuanzhong", nil, true)



    self.panel_playerTitle:setVisible(false);
    self.panel_otherPlayerTitle:setVisible(false);

    self.panel_otherLvl:setVisible(false);
    self.mc_build:setVisible(false)

    -- self:zhujianpinbi()
    -- self:registerEvent();
    self:initPlayer();
    -- self:getoldAbility()

    --只是上面红点和左侧红点
    self:initRedPoint();
    -- self:initPlayerInfo();
    -- self:initSysWillOpenUI();
    -- self:initTestBtn();

    self:initEnterAni();

    self:setMainButton();

    -- self:addChatView();

    -- self:addQuestAndChat()


    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_youla,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_youla,UIAlignTypes.LeftBottom)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.RightBottom)

    
    EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_EVENT, 
        self.lognOut, self)
    EventControler:addEventListener(GuildEvent.REFRESH_SIGN_EVENT, self.initRedPoint, self)
    EventControler:addEventListener(GuildEvent.REFRESH_BOUNS_EVENT, self.initRedPoint, self)
    EventControler:addEventListener(GuildEvent.GET_QIFU_REWARD, self.initRedPoint, self)

    
    EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.lognOut, self)

    --初始化左下角信息
    self:initGuildInfo()

    --是否已经起名字了
    -- self:initNameView();
    --[[
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_downBtns,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_aniDown,UIAlignTypes.RightBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuoshang,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_aniLeftUp,UIAlignTypes.LeftTop)


    
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_zuoAni,UIAlignTypes.LeftBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_zhanghao, UIAlignTypes.LeftTop)

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_upBtns, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_upAni, UIAlignTypes.RightTop);


    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_OtherIcon, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_battleInvitation, UIAlignTypes.LeftTop);


    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_qianAni, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_mubiao, UIAlignTypes.RightTop);

    --发送事件，显示主界面，第一次显示时候主动调用
    EventControler:dispatchEvent(HomeEvent.SHOW_HOME_VIEW);

    --等级或名字发生变化或vip
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
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
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOG_OUT, self.lognOut, self)
    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self); 

    EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, 
        self.onRechargeCallBack, self);

    EventControler:addEventListener(UserEvent.USEREVENT_PLAYER_POWER_CHANGE, 
        self.powerChange, self);

    -- 看起来功能重合，先注掉，之后有问题再行修改2017.7.11
    -- if UserModel:isLvlUp() == true then 
    --     if UserModel:isNewSystemOpenByLevel( UserModel:level() ) == true then
    --         local sysNameKey = FuncChar.getCharLevelUpValueByLv(
    --             UserModel:level(), "sysNameKey");

    --         EventControler:dispatchEvent(
    --             HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysNameKey});
    --     end 
    -- end 

    if LoginControler:showAccountUp() then
        self.btn_zhanghao:setVisible(true)
        self.btn_zhanghao:setTouchedFunc(c_func(self.clickUpdateUser, self));
    else
        self.btn_zhanghao:setVisible(false)
    end
    ]]  
    self:addBarrageUI()
    
end 

function GuildMainView:initGuildInfo(  )
    local groupId = GuildModel:getGroupID()
    if tonumber(groupId) == 0 then
        groupId = GameConfig.getLanguage("#tid_group_guild_1506")
    end
    self.panel_youla.txt_1:setString(groupId)
    self.panel_youla.txt_2:setString(GuildModel:getGuildBaseInfo().notice)
end


--添加弹幕界面
function GuildMainView:addBarrageUI()

    local arrPame = {
        system = FuncBarrage.SystemType.guild,  --系统参数
        btnPos = {x = 0,y = -50},  --弹幕按钮的位置
        barrageCellPos = {x = 0,y = -20}, --弹幕区域的位置
        addview = self,--索要添加的视图
    }
    BarrageControler:showBarrageCommUI(arrPame)
end

-- --添加聊天和目标按钮
-- function GuildMainView:addQuestAndChat()
--     local arrData = {
--         systemView = FuncCommon.SYSTEM_NAME.GUILD,--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end

function GuildMainView:setMainButton()
    self.panel_1.btn_world:setTouchedFunc(c_func(self.lognOut, self));
    self.panel_1.btn_w:setTouchedFunc(c_func(self.foundation, self));
    self.panel_1.btn_world:getUpPanel().panel_red:setVisible(false)
    self.panel_1.btn_w:getUpPanel().panel_red:setVisible(false)
end
--跳转到仙盟详情界面
function GuildMainView:foundation()
    -- WindowControler:showWindow("GuildInFoView");
    if not GuildControler:touchToMainview() then
        return 
    end
    GuildControler:getMemberList(1)
end
---屏蔽加号
-- function GuildMainView:zhujianpinbi()
  
--   self.panel_zuoshang.panel_res.UI_yuanbao.btn_xianyujiahao:setVisible(false)
--   self.panel_zuoshang.panel_res.UI_sanhuang.btn_lingshijiahao:setVisible(false)
--   self.panel_zuoshang.panel_res.UI_tongbi.btn_lingshijiahao:setVisible(false)
--   self.panel_zuoshang.panel_res.UI_tili.btn_tilijiahao:setVisible(false)

-- end

--显示战力特效显示 ---每次到主界面都会调用
function GuildMainView:showAbilityEffect()
    if  self.oldAbility ~= nil then
        if self.oldAbility ~= UserModel:getAbility() then
            if self.oldAbility < UserModel:getAbility() then
                FuncCommUI.showPowerChangeArmature(self.oldAbility or 10, UserModel:getAbility() or 10,0.8,true,1.8);
                self.oldAbility = UserModel:getAbility()
            end
        end
    end
    ---主角战力到达头衔所需战力条件发送头衔红点显示
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.DOWNBTN.CHAR, isShow = CharModel:isShowCharCrownRed()});
    self:setPlayerPower()
end
-- 获得主角战力
function GuildMainView:getoldAbility()
    self.oldAbility = UserModel:getAbility()
end



function GuildMainView:initEnterAni()
    -- if isShowEnterAni == true then 

    --     self.UI_downBtns:setVisible(false);
    --     -- self.UI_upBtns:setVisible(false);
    --     self.panel_mubiao:setVisible(false);
    --     self.panel_zuoshang:setVisible(false);
    --     self.panel_youla:setVisible(false);
    --     self.btn_zhanghao:setVisible(false);

        EventControler:addEventListener(GuildEvent.SHOW_RES_COMING_ANI, 
            self.showEnterAni, self);
    -- end 
end 

function GuildMainView:showEnterAni()
    echo("------GuildMainView showEnterAni-------");
    
    -- if isShowEnterAni == true then 
        --下面
       
        local downAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a1", 
            self.ctn_aniDown, false, function ()
                --触发新手
                -- EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
                --     {tutorailParam = TutorialEvent.CustomParam.FirstInHomeTown});
    
                -- isShowEnterAni = false;

                -- 检查是否弹出设置昵称界面
                -- LoginControler:checkShowPlayerSetNicknameView()

                echo("=======22222222222222211=========")
                -- dump(UserModel.LoginData,"1111111111",6)
                -- if UserModel.LoginData == nil then
                -- -- 检查是否弹出公告界面
                --     LoginControler:checkShowGonggao()
                -- else
                --     -- 进入重登机制
                --     LoginInfoControler:onBattleStatus(UserModel.LoginData,false)
                -- end
                
            end);

        -- self.UI_downBtns:setPosition(5, 0);
        -- FuncArmature.changeBoneDisplay(downAni, "layer1", self.UI_downBtns);

        -- if self:questOpen() then
        --     --活动icon  
        --     local activityAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a3", 
        --         self.ctn_upAni, false, GameVars.emptyFunc);
        --     self.panel_mubiao:setPosition(-14, 0);
        --     FuncArmature.changeBoneDisplay(activityAni, "layer1", self.panel_mubiao);
        -- end

        -- --左边的东西
        -- local leftAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a4", 
        --     self.ctn_zuoAni, false, GameVars.emptyFunc);
        -- self.panel_youla:setPosition(0, -250);
        -- FuncArmature.changeBoneDisplay(leftAni, "layer1", self.panel_youla);    

        -- --名字
        -- local leftUpAni = self:createUIArmature("UI_zhujiemian", "UI_zhujiemian_a5", 
        --     self.ctn_aniLeftUp, false, GameVars.emptyFunc);
        -- self.panel_zuoshang:setPosition(0, 0);
        -- FuncArmature.changeBoneDisplay(leftUpAni, "layer1", self.panel_zuoshang);
    -- end 

end

function GuildMainView:goldChangeCallBack()
    self:initPlayerInfo();
end

function GuildMainView:powerChange()
    self:setPlayerPower();
end

function GuildMainView:onRechargeCallBack()
    -- if VipModel:getNextVipGiltToBuy() ~= -1 then 
    --     self.panel_zuoshang.panel_red:setVisible(true);
    -- else 
    --     self.panel_zuoshang.panel_red:setVisible(false);
    -- end 

    -- self.panel_zuoshang.panel_red:setVisible(false)
end 


--//调整消息通知提示UI结构
function GuildMainView:notifyLampShow(_param)
      local   _lamps=_param.params;
      for _index=1,#_lamps do
               -- self.UI_lamp:insertMessage(_lamps[_index]);
      end
end

function GuildMainView:lognOut()
    GuildModel:sendHomeMainViewRed()
    EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
    self:startHide();
end

function GuildMainView:vipChangeCallBack()
    self:initPlayerInfo();
end

function GuildMainView:nameChangeCallBack()
    self:initPlayerInfo();
end

function GuildMainView:LvlChangeCallBack()
    self:initPlayerInfo();
    self:initSysWillOpenUI();
end

function GuildMainView:initSysWillOpenUI()
    local willOpenName, sysOpenLvl = HomeModel:getWillOpenSysName();
    local typeSystemIcon = FuncCommon.hasSystemIcon()
    self.panel_youla.panel_4:setVisible(typeSystemIcon);
    if self.panel_youla.panel_4:isVisible() then
        local panel = self.panel_youla.panel_4.btn_sysicon:getUpPanel();
        local ctn = panel.ctn_sysicon;
        ctn:removeAllChildren();
        local spPath = FuncRes.iconSys(willOpenName);

        local sp = display.newSprite(spPath);
        ctn:addChild(sp);
        sp:size(ctn.ctnWidth, ctn.ctnHeight);
        self.panel_youla.panel_4.btn_sysicon:setTouchedFunc(c_func(self.pressWillOpenSys, 
            self, willOpenName, sysOpenLvl), nil,true);

        local tidName = FuncCommon.getSysOpensysname(willOpenName);
        panel.txt_1:setString(GameConfig.getLanguage(tidName));

        --等级
        local lvlArray = number.split(sysOpenLvl);
        if table.length(lvlArray) == 1 then 
        --前10级
            panel.mc_qshu:setVisible(false);
            panel.mc_hshu:showFrame(lvlArray[1] + 1);
        else 
            panel.mc_qshu:setVisible(true);
            panel.mc_qshu:showFrame(lvlArray[1] + 1);
            panel.mc_hshu:showFrame(lvlArray[2] + 1);
        end 
    end
end

function GuildMainView:pressWillOpenSys(willOpenName, sysOpenLvl)
    local willOpenName, sysOpenLvl = HomeModel:getWillOpenSysName()
    WindowControler:showWindow("SysWillOpenView", willOpenName, sysOpenLvl);
end

function GuildMainView:onMusicStatusChange(event)
    local music_st = LS:pub():get(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.ON)
    if music_st == FuncSetting.SWITCH_STATES.ON then
        if audio.isMusicPlaying() then
            AudioModel:resumeMusic()
        else
            AudioModel:playMusic("m_scene_main", true)
        end
    end
end

function GuildMainView:initRedPoint()
    -- self.panel_youla.panel_2.panel_red:setVisible(false)--HomeModel:isRedPointShow(HomeModel.REDPOINT.LEFTMARGIN.CHAT));
    -- self.panel_youla.panel_1.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.LEFTMARGIN.FRIEND));
    -- self.panel_youla.panel_3.panel_red:setVisible(false)
    -- self.panel_youla.panel_mail.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.LEFTMARGIN.MAIL));
    -- self.panel_mubiao.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.NPC.QUEST))
    local blessingRed = GuildModel:blessingRed()
    local bonusred = GuildModel:bonusListRed()
    local singred = GuildModel:signShowRed()

    -- echo("====111111111111111111111====",singred,bonusred,blessingRed)
    self.panel_1.btn_w:getUpPanel().panel_red:setVisible(singred or bonusred or blessingRed)

end

function GuildMainView:initPlayerInfo()
    self.panel_zuoshang:setTouchedFunc(c_func(self.clickPlayerInfo, self));
    self.panel_zuoshang:setTouchSwallowEnabled(true);

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
    -- self.panel_zuoshang.mc_1:setTouchedFunc(c_func(self.gotoVipView, self));
    -- self.panel_zuoshang.mc_1:setTouchSwallowEnabled(true);

    -- if VipModel:getNextVipGiltToBuy() ~= -1 then 
    --     self.panel_zuoshang.panel_red:setVisible(true);
    -- else 
    --     self.panel_zuoshang.panel_red:setVisible(false);
    -- end 

    self.panel_zuoshang.mc_1:setVisible(false);
    -- self.panel_zuoshang.panel_red:setVisible(false);
    --woca
    -- self.panel_zuoshang.panel_red:setPosition(-5000,0);
    self.panel_zuoshang.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.PLAYERINFO.TITLE))
    --战力
    self:setPlayerPower();

    --头像
    -- local charIcon = CharModel:getCharIconSp();
    -- self.panel_zuoshang.ctn_touxiang:addChild(charIcon);
    
    -- local ctn =  self.panel_zuoshang.ctn_touxiang
    -- ctn:removeAllChildren()
    -- HomeModel:setPlayerfram(ctn,UserModel:frame())
    -- HomeModel:setPlayerIcon(ctn,UserModel:head())
end

function GuildMainView:clickUpdateUser()
    echo("----clickUpdateUser----");
    WindowControler:showWindow("LoginBindingAccount")
end

function GuildMainView:onGuestBindingSuccess()
    self.btn_zhanghao:setVisible(false)
end

function GuildMainView:gotoVipView()
    local pageView = VipModel:getNextVipGiltToBuy();
    if pageView == -1 then 
        pageView = UserModel:vip();
    end 
    WindowControler:showWindow("VipMainNewView", false, pageView);
end

function GuildMainView:setPowerNum(nums)
    local len = table.length(nums);

    if len > 6 then 
        echo("-----------warning: power is over 999999!!!----------");
        return;
    end 

    self.panel_zuoshang.panel_zhanli.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.panel_zuoshang.panel_zhanli.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

function GuildMainView:setPlayerPower()
    local power = UserModel:getAbility();
    local powerValueTable = number.split(power);

    self:setPowerNum(powerValueTable);
end

function GuildMainView:clickPlayerInfo()
    AudioModel:playSound("s_com_click1")
    echo("--clickPlayerInfo--");
    WindowControler:showWindow("PlayerInfoView");
    -- HomeModel:openNewSystem( "pvp", function()
    --     echo("检查新手引导的东西去吧")
    -- end )
end


function GuildMainView:initPlayer()
    local mapNode = GuildMapLayer.new(self);
    self._mapNode = mapNode;

    -- HomeModel:setHomeUI(self);

    self:addChild(mapNode, -1);  
    echo("----GuildMainView:initPlayer---");

    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self._mapNode, UIAlignTypes.Left);
end

function GuildMainView:registerEvent()
    GuildMainView.super.registerEvent();

    EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)


    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, 
        self.onModelUpdateEnd, self)
    -- EventControler:addEventListener(HomeEvent.RED_POINT_EVENT, self.onRedPointChanged, self);

    --任务变化更新右上角
    EventControler:addEventListener(QuestEvent.AFTER_QUEST_GET_REWARD,
        self.setQuestUI, self); 
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.setQuestUI, self); 
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.setQuestUI, self); 
    
    EventControler:addEventListener(LoginEvent.LOGINEVENT_GUEST_BINDING_SUCCESS,
        self.onGuestBindingSuccess, self); 

    

    -- ---头像刷新
    -- EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_FRAM_EVENT,
    --     self.refreshHeadView, self); 
    -- EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_EVENT,
    --     self.refreshHeadView, self); 



    
    -- self.panel_youla.ctn_chat:setTouchedFuncWithPriority(c_func(self.chatBtnClick, self), 2);
    --注册走马灯消息推送接收事件
    EventControler:addEventListener(HomeEvent.TROT_LAMP_EVENT, self.notifyLampShow,self);

    --任务跑到右上角
    self.panel_mubiao.btn_renwu:setTouchedFunc(c_func(self.questGo, self), nil,true);
    self.panel_mubiao.btn_mubiao:setTouchedFunc(c_func(self.questClick, self), nil,true);

    self:leftButtonIsOpen();


    self:setQuestUI();

    -- self:addBubbleView()
end
function GuildMainView:addBubbleView()
    -- FuncCommUI.regesitShowBubbleView(FuncCommon.SYSTEM_NAME.QUEST,self.panel_mubiao)
end

--目标任务开启问题
function GuildMainView:questOpen()
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
function GuildMainView:leftButtonIsOpen()
    
    self.panel_youla.panel_2:setVisible(false)
    self.panel_youla.panel_3:setVisible(false)
    self.panel_youla.panel_dt:setVisible(false)
        --左边三个btn
    self.panel_youla.panel_1:setTouchedFunc(c_func(self.showFriendView, self), nil,true);
    -- self.panel_youla.panel_2:setVisible(false)
    self.panel_youla.panel_2:setTouchedFunc(c_func(self.chatBtnTeamClick, self), nil,true);
    self.panel_youla.panel_3:setTouchedFunc(c_func(self.chatBtnTeamClick, self), nil,true);

    self.panel_youla.panel_1:setPositionX(self.panel_youla.panel_3:getPositionX() + 5)

    local isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND)
    if isopen then
        self.panel_youla.panel_1:setVisible(true)
    else
        self.panel_youla.panel_1:setVisible(false)
    end
end

function GuildMainView:refreshHeadView(event)
    -- dump(event.params,"数据模式")
    local data = event.params
    local _ctn = self.panel_zuoshang.ctn_touxiang
    if data.userHeadId then
        UserHeadModel:setPlayerHeadAndFrame(_ctn,UserModel:avatar(),data.userHeadId,nil)
    elseif data.headFrameId then
        UserHeadModel:setPlayerHeadAndFrame(_ctn,UserModel:avatar(),nil,data.headFrameId)
    end
end

function GuildMainView:chatBtnTeamClick()
     -- WindowControler:showTips(GameConfig.getLanguage("chat_function_not_open_1015")); ---暂未开启
     -- TODO 屏蔽工会相关逻辑 by ZhangYanguang
     -- WindowControler:showWindow("TriaNewlTeamView");
end
---添加游戏聊天界面
function GuildMainView:addChatView()
    -- self.panel_youla.ctn_chat
    self.chatmainview =  WindowControler:createWindowNode("ChatAddMainview")
    self.chatmainview:setPosition(cc.p(0,0))
    self.panel_youla.ctn_chat:addChild(self.chatmainview)

    local node = display.newNode()
    node:addto(self.panel_youla.ctn_chat,100):size(330,104)
    node:anchor(0,0)
    node:setPositionY(-100)
    node:setTouchedFunc(c_func(self.chatBtnClick, self),nil,true);

end
--有上角跳转
function GuildMainView:questGo()
    if self._isDaily == false then 
        --完成了的话，直接领奖
        local isFinish = TargetQuestModel:isMainLineQuestFinish(self._recommandId);
        if isFinish == false then 

            local questType = FuncQuest.readMainlineQuest(self._recommandId, "conditionType");
            local jumpInfo = TargetQuestModel.JUMP_VIEW[tostring(questType)];
            -- echo("=====00000000000=========",self._recommandId)
            if jumpInfo ~= nil then 
                echo("jumpView.viewName  ======111111111111======== " .. tostring(jumpInfo.viewName));
                if jumpInfo.viewName ~= nil then 
                    -- DailyQuestModel:setquestId(self._recommandId)
                    WindowControler:showWindow(jumpInfo.viewName);
                elseif jumpInfo.funName ~= nil  then 
                    jumpInfo.funName(self._recommandId);
                else 
                    -- self:startHide();
                end 
                EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
                    {questId = self._recommandId, questType = 2});
            else 
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2038")); 
            end

        else    
            QuestServer:getMainQuestReward(self._recommandId, 
                c_func(self.finishMainLineCallBack, self));
        end 
    else 
        local isFinish = DailyQuestModel:isDailyQuestFinish(self._recommandId);
        if isFinish == false then
            local questType = FuncQuest.readEverydayQuest(self._recommandId, "conditionType");
            local jumpInfo = DailyQuestModel.JUMP_VIEW[tostring(questType)];
            if jumpInfo ~= nil then 
                echo("jumpView.viewName ==22222222====" .. tostring(jumpInfo.viewName));
                if jumpInfo.jumpFunc ~= nil then 
                    jumpInfo.jumpFunc();
                else 
                    -- DailyQuestModel:setquestId(self._recommandId)
                    WindowControler:showWindow(jumpInfo.viewName);
                end 
                EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
                    {questId = self._recommandId, questType = 1});
            else 
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"));
            end 
        else  
            QuestServer:getEveryQuestReward(self._recommandId, 
                c_func(self.finishDailyCallBack, self))

        end 
    end 
end

function GuildMainView:finishDailyCallBack()
    echo("finishDailyCallBack " .. tostring(self._recommandId)); 

    local rewards = FuncQuest.getQuestReward(2, self._recommandId);
    FuncCommUI.startFullScreenRewardView(rewards, function ( ... )
            FuncCommUI.ShowRecordTips(self._recommandId);

            if UserModel:isLvlUp() == true then 
                EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
            end 
        end
    );

    EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD);

end

function GuildMainView:finishMainLineCallBack()    
    local rewards = FuncQuest.getQuestReward(1, self._recommandId);
    FuncCommUI.startFullScreenRewardView(rewards, function ( ... )
            FuncCommUI.ShowRecordTips(self._recommandId)
        end
    );

    if TargetQuestModel:isQuestComplete(self._recommandId) == true then 
        LS:prv():set(tostring(self._recommandId), 
            tostring(self._recommandId));
        --在发送一个任务变化消息
        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID}); 
    end

    EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD); 
end

function GuildMainView:setQuestUI()
    --任务的id
    local isDaily, recommandId = HomeModel:getRecommandInHomeView();

    self._isDaily = isDaily;
    self._recommandId = recommandId;

    local iconName;
    local iconPath; 
    local iconSp;
    local questNameTid; 
   
    if isDaily == false then 
        iconName = FuncQuest.readMainlineQuest(recommandId, "icon");
        iconPath = FuncRes.iconQuest(iconName)
        iconSp = display.newSprite(iconPath);
        iconSp:setScale(0.7)
        questNameTid = FuncQuest.readMainlineQuest(recommandId, "name");

        local isFinish = TargetQuestModel:isMainLineQuestFinish(self._recommandId);

        if isFinish == true then 
            self.panel_mubiao.btn_renwu:getUpPanel().panel_jiangli:setVisible(true);
        else 
            self.panel_mubiao.btn_renwu:getUpPanel().panel_jiangli:setVisible(false);
        end

        local ctn = self.panel_mubiao.btn_renwu:getUpPanel().ctn_1;
        ctn:setVisible(true);
        ctn:removeAllChildren();
        ctn:addChild(iconSp);
        self.panel_mubiao.btn_renwu:getUpPanel().mc_ui:setVisible(false);

    else 
        iconName = FuncQuest.readEverydayQuest(recommandId, "icon");
        iconPath = FuncRes.iconQuest(iconName)
        iconSp = display.newSprite(iconPath);
        questNameTid =  FuncQuest.readEverydayQuest(recommandId, "name");

        local isFinish = DailyQuestModel:isDailyQuestFinish(self._recommandId);
        if isFinish == true then 
            self.panel_mubiao.btn_renwu:getUpPanel().panel_jiangli:setVisible(true);
        else 
            self.panel_mubiao.btn_renwu:getUpPanel().panel_jiangli:setVisible(false);
        end

        local rewards = FuncQuest.getQuestReward(2, recommandId);
        function isExpReward(reward)
            local itemType = nil;
            local itemId = nil;
            local itemNum = nil;

            local reward = string.split(reward, ",");
            --是货币
            if tostring( reward[1] ) == FuncDataResource.RES_TYPE.EXP then 
                return true;
            else 
                return false;
            end 

        end
        local mc_ui = self.panel_mubiao.btn_renwu:getUpPanel().mc_ui;
        mc_ui:setVisible(true);
        --是不是经验
        if  isExpReward(rewards[1]) then 
            mc_ui:showFrame(2);
        else 
            mc_ui:showFrame(1);
            local iconUI = mc_ui.currentView.UI_item;

            iconUI:setResItemData({reward = rewards[1]});
            iconUI:showResItemNum(false);
        end       

        local ctn = self.panel_mubiao.btn_renwu:getUpPanel().ctn_1;
        ctn:setVisible(false); 
    end 

    self.panel_mubiao.btn_renwu:getUpPanel().txt_1:setString(GameConfig.getLanguage(questNameTid))
end

function GuildMainView:changeMap()
    self._mapNode:changeMap();
end

function GuildMainView:questClick()
    WindowControler:showWindow("QuestMainView");
end

-- --//好友事件变化 djb
-- function GuildMainView:onRedPointChanged(_event)
--     local  _param=_event.params;
--     if (_param.redPointType == HomeModel.REDPOINT.LEFTMARGIN.FRIEND) then
--         self.panel_youla.panel_1.panel_red:setVisible(_param.isShow);
--     elseif _param.redPointType == HomeModel.REDPOINT.LEFTMARGIN.MAIL then 
--         self.panel_youla.panel_1.panel_red:setVisible(_param.isShow);
--     elseif _param.redPointType == HomeModel.REDPOINT.LEFTMARGIN.CHAT then 
--         self.panel_youla.panel_2.panel_red:setVisible(false)--_param.isShow);
--     elseif _param.redPointType == HomeModel.REDPOINT.PLAYERINFO.TITLE then
--         -- echo("=====================333333333======",HomeModel:isRedPointShow(HomeModel.REDPOINT.PLAYERINFO.TITLE))
--         self.panel_zuoshang.panel_red:setVisible(HomeModel:isRedPointShow(HomeModel.REDPOINT.PLAYERINFO.TITLE))
--     elseif _param.redPointType == FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST then
--         self.panel_mubiao.panel_red:setVisible(_param.isShow)
--     end
-- end

function GuildMainView:mailBtnClick()
    echo("clickA1_mail");
    -- WindowControler:showWindow("MailView")
end

--djb
function GuildMainView:chatBtnClick()
    echo("chatBtnClick");
--//设置等级限制
--chat_common_level_not_reach_1014
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
   -- local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT);
   -- local   _user_level=UserModel:level();
   -- if(_user_level<_level)then
   --         WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
   --         return;
   -- end
   -- local   _select_index=1;
   -- if(ChatModel:isChatFlag())then
   --      _select_index=3;
   -- end
   --  local  chatUI=WindowControler:showWindow("ChatMainView");

end

function GuildMainView:onModelUpdateEnd()
    self:initPlayerInfo()
end


--当一个ui开始显示的时候
--todo 判断是不是全屏界面  HOMEEVENT_COME_BACK_TO_MAIN_VIEW
function GuildMainView:onUIShowComp( e )
    if WindowControler:isCurViewIsHomeTown() == true then 
        return;
    end 

    local targetUI = e.params.ui

    if targetUI:checkIsFullUI()  then
        self:visible(false)
        self:otherViewOnHome();
        --主界面人物不动
        self._mapNode:pauseAllSpine();
        self:resetBtnsCompoment();
    end

end

--其他界面在 home 上面 --仙盟界面不用
function GuildMainView:otherViewOnHome()
    -- EventControler:dispatchEvent(HomeEvent.OTHER_VIEW_ON_HOME);
end


--又返回这个界面执行的函数, 这个是全屏界面才做的判断
function GuildMainView:comeBackToThisView()
    -- echo("------GuildMainView:comeBackThisView--------");
end

function GuildMainView:resetBtnsCompoment()
    echo("---GuildMainView:resetBtnsCompoment---");
    --有新的btn出现进行重置
    if self.UI_downBtns._isNeedReSetDownBtns == true then 
        self.UI_downBtns._isNeedReSetDownBtns = false;
        self.UI_downBtns:resetBtns();
    end 
end

function GuildMainView:showFriendView()
   FriendViewControler:showView();
end

function GuildMainView:initTestBtn()
    if self.btn_goToTest then
        self.btn_goToTest:setVisible(false);
    end
    
end

function GuildMainView:gototest()
    self:startHide();
end

function GuildMainView:deleteMe()
    HomeModel:setHomeUI(nil);
    
    self._mapNode:dispose();
    GuildMainView.super.deleteMe(self);


end 

function GuildMainView:updateLayerBubbleUI(chatData)
    self._mapNode:updateBubbleUI(chatData);
end

-- 获取下排图标实例
function GuildMainView:getBtnComponent()
    return self.UI_downBtns
end

-- 获取目标系统实例
function GuildMainView:getQuestPanel()
    return self.panel_mubiao.btn_mubiao
    -- return self.panel_mubiao
end

return GuildMainView;











