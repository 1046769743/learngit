--2016.02.12
--2016.9.7
--guan

local HomeModel = class("HomeModel");

HomeModel.REDPOINT = {
    --上面活动栏的红点
    ACTIVITY = {
        ACTIVITY = "activity",  --活动
        GIFT = "gift",  --礼物
        CHARGE = "charge",  --充值
        FIRST_CHARGE = "firstCharge",  --首冲
        HAPPY_SIGN = "happySign",       --签到
        REAL_NAME = "realName",       --签到
        CARNIVAL = "carnival",    --狂欢
        EVERYDAYTARGET = "everydayTarget",--每日目标
        MALL = "mall",   --商城
        MONTHCARD  = "monthCard",   --月卡
        ACTCONDITION =  "actCondition",--六界游商
    },

    --导航栏的红点, 下面就是注释的，
    --没有这个导航了，之后要干掉
    NAVIGATION = {
    },

    NPC = {
        QUEST = FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST,
        SHOP = FuncCommon.SYSTEM_NAME.SHOP_1,
        GAMBLE = FuncCommon.SYSTEM_NAME.GAMBLE,
        LOTTERY = FuncCommon.SYSTEM_NAME.LOTTERY,
        SIGN = FuncCommon.SYSTEM_NAME.SIGN,
    },

    --左侧的聊天, 好友系统, 写死就2个不会变
    LEFTMARGIN = {
        FRIEND = "friend",--"panel_youla.panel_1.panel_red",--好友
        CHAT = "chat",--"panel_youla.panel_2.panel_red",  --聊天
        MAIL = "mail",--"panel_youla.panel_mail.panel_red" --邮件
    },


    DOWNBTN = {
        TREASURE = "treasure", --法宝
        CHAR = "char",        --主角
        GOD = "god",           --神明
        PARTNER = "partner",     --伙伴+
        BAG = "bag",           --包裹
        ROMANCE = "romance",   --奇缘
        CHALLENGE = "pve",           --挑战
        GUILD = "guild",       --公会
        WORLD = "world",       --寻仙
        EQUIPMENT = "partnerEquipment",       --装备
        PRACTICE = "practice", --修炼仙术
        LOVE = "love",    --情缘
        CIMELIA = "cimelia", --神器
        ARRAY = "array", --布阵
        GUAJI = "GUAJI", --挂机
        PVP = "pvp", --仙途
        HANDBOOK = "handbook", --仙途
        FIVESOUL = "fivesoul",
        SHOP = "shop1",
        ELITE = "elite",
    },
    MAPSYSTEM = {
        WELFARE = "welfare",--福利
        -- {
        --     NEWSIGN = "newsign",  --每日签到
        --     LINGSHISHOP = "lingshishop",  --灵石商店
        -- }, 
        ACTIVITYENTRANCE = "activityEntrance", --新活动入口
    },

    PLAYERINFO = {
        TITLE = "title",   --- 称号
    },

};
HomeModel.HomeView_Ctn = 6  ---底部六个ctn的位置


--更多按钮显示的系统
HomeModel.MORE_OTHER = {
    [1] = "shop1",--FuncCommon.SYSTEM_NAME.SHOP_1,
    [2] = "array",--FuncCommon.SYSTEM_NAME.ARRAY,
    [3] = "memory",--FuncCommon.SYSTEM_NAME.MEMORYCARD,
    [4] = "treasure",--FuncCommon.SYSTEM_NAME.TREASURE_NEW,
    [5] = "fivesoul",--FuncCommon.SYSTEM_NAME.FIVESOUL,
    [6] = "ranklist",--FuncCommon.SYSTEM_NAME.RANKLIST,
    [7] = "handbook",--FuncCommon.SYSTEM_NAME.HANDBOOK,
}








local userPosX = nil
local userPosY = nil
function HomeModel:init()
    --作弊一下，偷偷require
    require("game.sys.func.FuncHome");
    FuncHome.init();
    self.isShowEnterAni = true  --首次登入展示动画
    self.logInTo = false   --- 首次登入
    self._showMap = {};
    self._showButton = {}
    self._buttonShowMap = {}
    
    self:registListenEvent();
    self._openSys = self:sortOpenSysByOpenLvl();
    self.isMoByspRunaction = false
    self.MainButtonRight = true

    ---存储气泡系统的列表
    self.airBubbleArr = {}
end

function HomeModel:registListenEvent()
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointDateUpate, self, 10);  

    EventControler:addEventListener(HomeEvent.SHOW_BUTTON_EFFECT,
        self.buttonEffectIsShow, self, 10);
    

    -- 监听精英通关消息
    EventControler:addEventListener(EliteEvent.ELITE_FIRST_PASS_RAID,
        self.eliteSystemOpenCheckByNewRaid, self)

    --根据新通关的副本进度判断有没有开启新功能
    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID,
        self.systemOpenCheckByNewRaid, self);  
   
    --暂时没用到
    -- EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES,
    --     self.onBoxOpen, self);

    --升级了
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.onLevelUp, self, 10);

    EventControler:addEventListener(TutorialEvent.TUTORIAL_LEVEL_UP, 
        self.onLevelUp, self, 10)

    EventControler:addEventListener(HomeEvent.HOME_MODEL_BUTTON_SHOW,
        self.buttonDateUpate, self); 


    EventControler:addEventListener(HomeEvent.SHOW_CHONGZHI_UI_EVENT,
        self.showChongZhiFangli, self);

    EventControler:addEventListener(HomeEvent.REFRESH_HONOR_EVENT,--TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        self.honorPlayerUpdate, self)

end

function HomeModel:honorPlayerUpdate()
   HomeServer:getDiaoestPlayer(c_func(self.RefreshHonorData, self));
end
function HomeModel:RefreshHonorData(event)
    self:setHonorData(event.result.data.worship)
end

function HomeModel:buttonDateUpate( data )

    -- dump(data,"登入数据",8)
    local name  = data.params.buttonType;
    local isShow = data.params.isShow;

    self._showButton[name] = isShow


end
--得到主城上的显示活动btn 
function HomeModel:getShowActivity()
    --得到所有活动
    --[[
        {
           sysName = {sysName = v},
           sysName = {sysName = v},
           sysName = {sysName = v}
        }
    ]]
    local allActivityArray = {};
    for k, v in pairs(HomeModel.REDPOINT.ACTIVITY) do
        allActivityArray[v] = {sysName = v};
    end

    --是不是完成首冲了 
    if HomeModel:isFinishFirstCharge() == true then 
        allActivityArray[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE] = nil;
    end 

    --是不是完成了欢乐签到
    -- if HappySignModel:isHappySignFinish() == true then 
        -- allActivityArray[HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN] = nil;
    -- end 

    --先暂停展示其他的btn
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.ACTIVITY] = nil;
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.GIFT] = nil;
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE] = nil;
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN] = nil;
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.CHARGE] = nil;
    allActivityArray[HomeModel.REDPOINT.ACTIVITY.REAL_NAME] = nil;


    local retArray = {};
    for k, v in pairs(allActivityArray) do
        table.insert(retArray, k);
    end


    local sortFunc = function (p1, p2)
        -- echo("---p1---", p1);
        local p1Order = FuncHome.getValue(p1, "order");
        local p2Order = FuncHome.getValue(p2, "order");
        if p1Order < p2Order then 
            return true;
        else 
            return false;
        end 
    end

    if #retArray > 1 then 
        table.sort(retArray, sortFunc);
    end 

    return retArray;
end
--[[
function HomeModel:onBoxOpen(event)
    -- 暂时注掉，是否设置为退出与是否有宝箱无关
    if true then return end

    local raidId = event.params.raidId;
 
    echo("----onBoxOpen----", raidId);
    local isNewSystemOpen, sysNameArr = UserModel:isNewSystemOpenByRaidId(raidId);
    echo("----onBoxOpen isNewSystemOpen", isNewSystemOpen);
    dump(sysNameArr, "sysNameArr----")
    local isNeedJump = FuncGuide.isNeedJumpToHomeWhenSysOpen(sysNameArr);

    if isNeedJump == true then 
        echo("----isNeedJump-----", isNeedJump);
        WindowControler:setisNeedJumpToHome(true);

        if IS_CLOSE_TURORIAL == false then
            -- 引导不关需要对要开启的系统做一个优先级的排序
            sysNameArr = TutorialManager.getInstance():sortByOpenOrderWithSysName(sysNameArr)
        end

        if WorldModel:hasExtraBox(raidId) then
            for i,sysName in ipairs(sysNameArr) do
                EventControler:dispatchEvent(HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysName});
            end
        end 
        
    else 
        echo("----isNeedJump-false--");
    end 

    if IS_CLOSE_TURORIAL == false then 
        -- 引导流程修改，取消10101之后强制跳出 2017.6.19
        if tonumber(raidId) == 10103 or tonumber(raidId) == 10203 then 
            WindowControler:setisNeedJumpToHome(true);
        end
    end 
end
]]
-- 精英关卡开通的监听
function HomeModel:eliteSystemOpenCheckByNewRaid(event)
    local raidId = event.params.raidId;

    echo("-----elite SystemOpenCheckByNewRaid-----", raidId)

    local isNewSystemOpen, sysNameArr = UserModel:isNewSystemOpenByRaidId(raidId)
    echo("-----isNewSystemOpen", isNewSystemOpen)
    -- dump(sysNameArr, "sysNameArr----")

    if IS_CLOSE_TURORIAL == false then
        -- 引导不关需要对要开启的系统做一个优先级的排序
        sysNameArr = TutorialManager.getInstance():sortByOpenOrderWithSysName(sysNameArr)
    end

    local isNeedJump = FuncGuide.isNeedJumpToHomeWhenSysOpen(sysNameArr)
    -- 功能开启消息挪出来
    for i,sysName in ipairs(sysNameArr) do
        EventControler:dispatchEvent(HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysName});
    end

    if isNeedJump == true then 
        WindowControler:setisNeedJumpToHome(true);
    end

    -- 后检查等级
    self:onLevelUp()
end

function HomeModel:systemOpenCheckByNewRaid(event)
    local raidId = event.params.raidId;

    echo("-----systemOpenCheckByNewRaid----", raidId);
    -- 优先关卡
    -- self:onLevelUp();
    --[[
     暂时注掉，是否设置为退出与是否有宝箱无关
    if WorldModel:hasExtraBox(raidId) then
        echo("----out----");
        self:onLevelUp()
        return;
    end 
    ]]

    local isNewSystemOpen, sysNameArr = UserModel:isNewSystemOpenByRaidId(raidId);
    echo("-----isNewSystemOpen", isNewSystemOpen);
    -- dump(sysNameArr, "sysNameArr----")
    --10101 10103 10201 这三关必定从剧情里跳出来
    if IS_CLOSE_TURORIAL == false then
        -- 引导流程修改，取消10101之后强制跳出 2017.6.19
        if tonumber(raidId) == 10103 or tonumber(raidId) == 10203 then 
            WindowControler:setisNeedJumpToHome(true);
        end
        -- 引导不关需要对要开启的系统做一个优先级的排序
        sysNameArr = TutorialManager.getInstance():sortByOpenOrderWithSysName(sysNameArr)
    end 

    local isNeedJump = FuncGuide.isNeedJumpToHomeWhenSysOpen(sysNameArr);
    
    for i,sysName in ipairs(sysNameArr) do
        EventControler:dispatchEvent(HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysName});
    end

    echo("isNeedJump ===========",isNeedJump)
    if isNeedJump == true then 
        WindowControler:setisNeedJumpToHome(true);
    end 
    -- 后检查等级
    self:onLevelUp()
end

function HomeModel:redPointDateUpate(data)
    local id = data.params.redPointType;
    local isShow = data.params.isShow or false;
    if id ~= nil then 

        if isShow == false then 
            self._showMap[id] = isShow;
        else 
            self._showMap[id] = true;
        end 
    end 

end
--显示按钮漂字特效存储  {systemName =(系统名),,effectType (特效类型),isshow = true or flase}
function HomeModel:buttonEffectIsShow(data)
    local id = data.params.systemName;
    local effectType = data.params.effectType;
    local isShow = data.params.isShow or false;
    if id ~= nil then 
        if isShow == false  then 
            self._buttonShowMap[id] = {isShow = isShow, _type = effectType};
        else 
            self._buttonShowMap[id] = {isShow = true, _type = effectType};
        end 
    end 
    -- dump(self._buttonShowMap,"11111111111111111")

end

function HomeModel:getButtonEffectIsShow(systemName)
    local map = self._buttonShowMap[systemName];
    return map
end

function HomeModel:redPontsDump()
    -- echo("-------------HomeModel:redPontsDump-----------");
    -- dump(self._showMap, "---self._showMap--");
end

function HomeModel:isRedPointShow(redPointType)
    local isShow = self._showMap[redPointType] == true and true or false;
    return isShow
end

--[[
    功能名按开启等级排序
]]
function HomeModel:sortOpenSysByOpenLvl()
    local sysOpenTable = FuncCommon.getSysOpenData();
    local ret = {};
    for sysName, value in pairs(sysOpenTable) do
        local condition = value.condition;
        -- if cond ~= nil and cond[1].t == 1 and cond[1].v ~= 1 then 
        if value.isShow then
            local isShowTips = false;
            if value.isShow == 1 then
                isShowTips = true;
            end 
            table.insert(ret, {sysName = sysName, condition = condition,newsystemgrade = value.newsystemgrade, isShow = isShowTips,newsystemlevel = value.newsystemlevel});
        end  
    end

    local function sortTable(a, b)
        if a.newsystemlevel >= b.newsystemlevel then 
            return false;
        else 
            return true;
        end 
        return true;
    end
    table.sort(ret, sortTable);

    return ret;
end

function HomeModel:getOpenSysByNameLevel(lvl)
    for _, v in pairs(self._openSys) do
        if lvl == v.lvl then 
            return v.sysName;
        end 
    end
    return nil;
end 

function HomeModel:getWillOpenSysName()

    local nowHeroLv = tonumber(UserModel:level())
    -- dump(self._openSys,"111111111111")
    for i=1,table.length(self._openSys) do
        local condition = self._openSys[i].condition
        -- local newsystemgrade = self._openSys[i].newsystemgrade
        local sysName = self._openSys[i].sysName
        local isopen = UserModel:checkCondition(condition)
        if  isopen then
            local sumLevel = self._openSys[i].newsystemlevel + self._openSys[i].newsystemgrade
            if  self._openSys[i].isShow == true  and nowHeroLv >= self._openSys[i].newsystemlevel  and  nowHeroLv <= sumLevel then
                return sysName,condition,true
            end
        end
    end

    return nil,nil,nil
end

function HomeModel:hasSystemIcon()
    local systemOpenData = FuncCommon.getSysOpenData()
    local nowHeroLv = tonumber(UserModel:level())
    local sysName,condition = self:getWillOpenSysName()
    local sysData = systemOpenData[tostring(sysName)]
    -- local sysCondition = sysData.condition
    if sysName == nil  then
        return false
    end

    local closeSystemIconLv = sysData.newsystemlevel + sysData.newsystemgrade
    if nowHeroLv >= sysData.newsystemlevel and nowHeroLv <= closeSystemIconLv then
        return true
    end

    return false
end

function HomeModel:setOpenSysCache(cache)
    self._openSysCache = cache;
end

function HomeModel:getOpenSysCache()
    return self._openSysCache;
end

--是不是完成了首冲
function HomeModel:isFinishFirstCharge()
    if tonumber(UserModel:goldTotal()) ~= 0 and 
            tonumber(UserExtModel:firstRechargeGift()) == 1 then 
        return true;
    else 
        return false;
    end 
end

--是不是显示首冲红点
function HomeModel:isShowFirstChargeRedPoint()
    if tonumber(UserModel:goldTotal()) ~= 0 and 
            tonumber(UserExtModel:firstRechargeGift()) ~= 1 then 
        return true;
    else 
        return false;
    end 
end

--[[
    聊天发生变化调用之
    因为更新太频繁了，所以没有发事件，而是直接在 model 中更新ui，呵呵
]]
function HomeModel:chatHomeDelegateMethod(chatData)
    self:updateChatBubbleUI(chatData)
end

function HomeModel:updateChatBubbleUI(chatData)
    if self._homeUI ~= nil then 
        self._homeUI:updateLayerBubbleUI(chatData);
    end 
end

function HomeModel:setHomeUI(homeUI)
    self._homeUI = homeUI;
end

function HomeModel:getRecommandInHomeView()
    --先不显示日常推荐
    local openLvl = FuncDataSetting.getDailyRecommandOpenLvl();
    local isDailyQuest = false;
    local questId = nil;
    if openLvl <= UserModel:level() then 
        questId = DailyQuestModel:getDailyRecommandId();
        if questId == nil then 
            isDailyQuest = false;
            questId = TargetQuestModel:getRecommendQuestId();
        else 
            isDailyQuest = true;
        end 
    else 
        isDailyQuest = false;
        questId = TargetQuestModel:getRecommendQuestId();
    end 
    return isDailyQuest, questId;
end

--同时开2个，先显示六界的 再显示升级的开启
--通关某个 raidId 有没有新功能产生
--true 新系统开启 sysName 开启的功能名
-- function HomeModel:isNewSystemOpenByRaidId(raidId)
--     local systemOpenConfig = FuncCommon.getSysOpenData();

--     for sysName, value in pairs(systemOpenConfig) do
--         local cond = value.condition;
--         if cond ~= nil and cond[1].t == 4 and cond[1].v == tonumber(raidId) then 
--             return true, sysName;
--         end  
--     end

--     return false;
-- end

function HomeModel:onLevelUp(event)
    local newLvl = nil;
    local isLvlup = false;

    if WindowControler:isCurViewIsGm() == true then 
        if event ~= nil then
            newLvl = event.params.level;
        else
            newLvl = UserModel:level() + 1
        end
    else 
        isLvlup, newLvl = UserModel:isLvlUp();
        echo("----isLvlup, newLvl---", isLvlup, newLvl);
        if isLvlup ~= true then 
            return
        end         
    end 

    local lastLv =  UserModel:getlastLv() or newLvl - 1;
    echo("----lastLv, newLvl---", lastLv, newLvl);
    local sysArrays = UserModel:isNewSystemOpenInRange(lastLv, newLvl);

    if IS_CLOSE_TURORIAL == false then
        -- 引导不关需要对要开启的系统做一个优先级的排序
        sysArrays = TutorialManager.getInstance():sortByOpenOrderWithSysName(sysArrays)
    end

    -- dump(sysArrays, "---sysArrays onLevelUp---");

    local callBackFunc = function ()
        for _, sysName in pairs(sysArrays) do
            EventControler:dispatchEvent(
                HomeEvent.SYSTEM_OPEN_EVENT, {sysNameKey = sysName});
        end
    end

    WindowControler:globalDelayCall(callBackFunc, 5 / GameVars.GAMEFRAMERATE  );
end

-- 处理新功能开启时主城上的显示效果
function HomeModel:openNewSystem( sysname, callBack )
    if UserModel.LoginData ~= nil then
        return
    end
    local btnComponent = nil
    echo("========sysname=====",sysname)
    if table.find(FuncHome.homemButtonArr,sysname) then
        btnComponent = WindowControler:getWindow("WorldMainView"):getOtherButton()
    elseif table.find(FuncHome.RIGHTBUTTON_NAME,sysname) then
        btnComponent = WindowControler:getWindow("WorldMainView"):getOtherButton()
    else
        btnComponent = WindowControler:getWindow("WorldMainView"):getBtnComponent()
    end

    local params = {
        sysname = sysname,
        callBack = function() -- 后续事件的回调
            callBack()
            -- btnComponent:openNewSystem(sysname, callBack)
        end,
        btnCallBack = function() -- 图标出现的回调
            btnComponent:openNewSystem(sysname)
        end,
        worldPos = btnComponent:getSystemPos(sysname),
        flySwitch = FuncCommon.getFlySwich(sysname) or 0,
    }
        
    -- 调用界面显示，做一个假飞动画
    -- 飞完调用HomeMainCompoment显示新图标
    -- 回调走起就算结束
    -- WindowControler:getWindow( windowName )
    
    WindowControler:setUIClickable(false)
    WindowControler:globalDelayCall(function()
        WindowControler:setUIClickable(true)
        WindowControler:showWindow("SysOpenView", params)
    end, 5/GameVars.GAMEFRAMERATE)
end



function HomeModel:setUserTimeInLoacl()
    if  LS:pub():get("UserModelTime"..UserModel:rid()) == nil then
        LS:pub():set("UserModelTime"..UserModel:rid(),TimeControler:getServerTime())
        return true
    else
        local oldtimes = LS:pub():get("UserModelTime"..UserModel:rid())
        local timeData = os.date("*t",oldtimes)
        -- local newt = TimeControler:getServerTime()
        if timeData.hour > 0 and timeData.hour <= 4 then
            local shengyu = 4 - timeData.hour
            local sumsec = shengyu * 3600
            if TimeControler:getServerTime() - oldtimes > sumsec then
                LS:pub():set("UserModelTime"..UserModel:rid(),TimeControler:getServerTime())
                return true
            else
                return false
            end
        else
           local huors =  24 - timeData.hour
           local sec = huors * 3600 --- 末阶段的秒数
           local sumsec =  sec + 4 * 3600
           if TimeControler:getServerTime() - oldtimes > sumsec then
                LS:pub():set("UserModelTime"..UserModel:rid(),TimeControler:getServerTime())
                return true
           else
                return false
           end
        end 
    end
    return false
end

function HomeModel:OpenFuLiSyStem()
    for i=1,#FuncWelfare.VIEW_SYSTEM_NAME_TYPE do
        local system = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[i]
        local isOpen, needLvl = FuncCommon.isSystemOpen(system);
        if isOpen then
            WindowControler:showWindow("WelfareMinView",i);
            return
        end
    end
end
--设置六界第一的数据
function HomeModel:setHonorData(data)
    self.honorData = data
    EventControler:dispatchEvent(TitleEvent.HONOR_REFRESH_TITLE)
end
---获取六界第一数据
function HomeModel:getHonorDataRid()
    if self.honorData ~= nil then
        return  self.honorData.rid
    end
    return nil
end

function HomeModel:sendMainviewHonoraData()
    local sumtime = GameStatic._local_data.honorNpcPosFreshTime
    local intervaltime = sumtime   --总时间
    for i=1,sumtime/intervaltime do
        WindowControler:globalDelayCall(function ()
            EventControler:dispatchEvent(HomeEvent.REFRESH_HONOR_EVENT)
        end,intervaltime*i)
    end
end
function HomeModel:setsaveUserPos(x,y)
    userPosX = x
    userPosY = y 
end
function HomeModel:getsaveUserPos()
    return  userPosX,userPosY
end

function HomeModel:LogInToType()
    self.logInTo = true
end

function HomeModel:setcloneCtns(btnList)
    self._cloneCtns = {}
    self._cloneCtns = btnList
end

function HomeModel:insertCtnToclone(dataList)
    if dataList then
        if self._cloneCtns == nil then
            self._cloneCtns = {}
        end
        for k,v in pairs(dataList) do
            local isHas = false
            for _k,_v in pairs(self._cloneCtns) do
                if _v.name == v.name then
                    self._cloneCtns[_k] = v
                    isHas = true
                end
            end
            if not isHas then
                table.insert(self._cloneCtns,v)
            end
        end
    end
    -- dump(self._cloneCtns,"插入数据主界面按钮========")
end

--根据系统名称获取按钮坐标
function HomeModel:bySysNameGetCtnPos(sysName)
    if self._cloneCtns ~= nil then
        local sysTypeName = FuncCommon.getEntranceName(sysName)
        local  pos,isBtn = self:getCtnWidgetPos(sysTypeName)
        return pos
    end
end

function HomeModel:getCtnWidgetPos(sysTypeName)
    echo("=======系统入口名称=========",sysTypeName)
    -- dump(self._cloneCtns,"系统入口的表2222",9)
    local homemainview = WindowControler:getWindow("WorldMainView")
    local system_Ctn = self._cloneCtns
    -- dump(system_Ctn,"系统数据入===============")
    
    local _btnwit = nil
    if sysTypeName == FuncCommon.SYSTEM_NAME.PVE then
        if homemainview then
            _btnwit = homemainview:getBtnComponent().btn_juqing
        end
    elseif FuncHome.RIGHTBUTTON_INDEX[sysTypeName] ~= nil then
        local index = FuncHome.RIGHTBUTTON_INDEX[sysTypeName]
        local buttonTab = homemainview:getRightButtonTab()
        _btnwit = buttonTab[tonumber(index)]
    else
        for k,v in pairs(system_Ctn) do
            if v.name == sysTypeName then
                local cloneBtn = v.cloneBtn  
                -- echo("======111111=========",v.name,cloneBtn)  
                local box = cloneBtn:getContainerBox()
                local cx = box.x + box.width/2
                local cy = box.y + box.height/2
                turnPos = cloneBtn:convertToWorldSpaceAR(cc.p(cx,cy))
                -- echo("========系统位置  x   y  ====1111=====",turnPos.x,turnPos.y)
                return  turnPos,v,true
            end
        end
        -- if homemainview then
        --     echo("====新手引导指引错误 不应该走到这一步====系统名称=======",sysTypeName)
        --     _btnwit = homemainview:getBtnComponent().btn_lilian --:getQuestPanel().btn_mubiao
        -- end
    end

    local box = _btnwit:getContainerBox()
    local cx = box.x + box.width/2
    local cy = box.y + box.height/2
    local turnPos = _btnwit:convertToWorldSpaceAR(cc.p(cx,cy))
     echo("========系统位置  x   y  ===22222======",turnPos.x,turnPos.y)
    return turnPos,_btnwit,false
end


function HomeModel:getMoreButtonPos(sysTypeName)
    local WorldMainView = WindowControler:getWindow("WorldMainView")
    local _btnwit = nil
    if WorldMainView then
        _btnwit = WorldMainView:getBtnComponent().UI_more
        _btnwit:initView()
        for k,v in pairs(HomeModel.MORE_OTHER) do
            if sysTypeName == v then
                local cloneBtn = _btnwit["btn_"..k]
                local box = cloneBtn:getContainerBox()
                local cx = box.x + box.width/2
                local cy = box.y + box.height/2
                local turnPos = cloneBtn:convertToWorldSpaceAR(cc.p(cx,cy))
                echo("========更多按钮里面的系统位置  x   y=====",turnPos.x,turnPos.y)
                return  turnPos,v,true
            end
        end  
    end
    echo("====不应该走到这一步==========",sysTypeName)
end

-- --获取当前按钮的位置
-- function HomeModel:getButtonPos(orderId)
--     for i=1,#self._ctnpostable do
--         local x = self._ctnpostable[i].x
--         local y = self._ctnpostable[i].y
--         if self._SysBtnArr[i] ~= nil then
--             if self._SysBtnArr[i].orderId == orderId  then
--                 return i
--             end
--         end
--     end
-- end

function HomeModel:homeMainShowGongGao()
    if IS_TODO_MAIN_RUNCATION then
        return 
    end
    ---新手引导，和新系统开启
    if TutorialManager.getInstance():isHomeExistGuide() 
        or TutorialManager.getInstance():isHomeExistSysOpen() 
        or TutorialManager.getInstance():isHasTriggerSystemOpen()
    then
        return 
    end


    self:showGongGoORQIdeng()

end


function HomeModel:showGongGoORQIdeng()
    local sysname = FuncCommon.SYSTEM_NAME.HAPPYSIGN
    local isopen = FuncCommon.isSystemOpen(sysname)
    if isopen then
        if self._showButton[sysname] ~= nil and self._showButton[sysname] == false then

        else
            local day = HappySignModel:getOnlineDays()
            local maxday = FuncHappySign.getHappySignDays()  
            if day > maxday then
                day = maxday
            end
            local isok = HappySignModel:isHappySign( day )
            if not isok then
                local isLoadingShow = true  --登入显示
                WindowControler:showWindow("HappySignView",isLoadingShow)
            else
                self:showChongZhiFangli()
            end
        end
    else
        self:showChongZhiFangli()
    end
end

--根据数据来显示气泡
function HomeModel:showAirBubbleUI()
    local data = FuncHome.getBubbleListData()

    for k,v in pairs(data) do
        if v ~= nil then
            local systemname = v.name
            local isok = self:judgmentInAirFile(systemname)
            if isok then
                if self.airBubbleArr[systemname] == nil then
                    self.airBubbleArr[systemname] = v
                    EventControler:dispatchEvent(HomeEvent.SHOW_AIR_BUBBLE_UI,self.airBubbleArr[systemname].name)
                    break   
                end
            end
        end
    end
end


--判断气泡的条件是否完成
function HomeModel:judgmentInAirFile(systemname)

    local alldata = FuncHome.getBubbleData()
    local singedata = alldata[systemname]
    if singedata == nil then
        return false
    end
    local datainfor = nil
    for i=1,table.length(singedata) do
        local index = tostring(i)
        local bubbledata = singedata[index]
        local taketime = bubbledata.takeTme
        local invalidTime = bubbledata.invalidTime
        local valueA = {} --{t = nil,v =nil }
        local valueB = {}
        for _a = 1,#taketime do
            valueA[_a] = {}
            local arrTable = string.split(taketime[_a], ",")
            valueA[_a].t = tonumber(arrTable[1])
            valueA[_a].v = tonumber(arrTable[2])
        end
        for _b = 1,#invalidTime do
            valueB[_b] = {}
            local arrTable = string.split(invalidTime[_b], ",")
            valueB[_b].t = tonumber(arrTable[1])
            valueB[_b].v = tonumber(arrTable[2])
        end
        local iscompleteA =  UserModel:checkCondition( valueA )
        local iscompleteB =  UserModel:checkCondition( valueB )
        
        if iscompleteA == nil  and iscompleteB ~= nil then  --完成
            if issubtypes then
                if valueA[2] ~= nil then
                    if systemname  == FuncCommon.SYSTEM_NAME.ROMANCE then
                            datainfor = bubbledata
                    elseif systemname  == FuncCommon.SYSTEM_NAME.PVE then
                        if WorldModel:hasPVEStarBoxes() then
                            datainfor = bubbledata
                        else
                            datainfor = nil
                        end
                    end
                    break
                end
            else
                datainfor = bubbledata
                break
            end
        end
    end
    if datainfor ~= nil then
        return true,datainfor
    else
        return false
    end
end


---获取更多按钮的红点显示问题
function HomeModel:getMoreRedIsShow()
    local isShowRed = false
    local buttonArr =  self.MORE_OTHER
    for k,v in pairs(buttonArr) do
        isShowRed =  self._showMap[v]
        if isShowRed then
            -- echo("=======更多按钮的红点系统=======",v)
            return isShowRed
        end
    end
    return   false
end


function HomeModel:getMainButtonOpen()
    return self.MainButtonRight
end
---设置右上角按钮是不是伸缩进去
function HomeModel:setMainButtonOpen(open)
    self.MainButtonRight = open
end

--显示充值返利
function HomeModel:showChongZhiFangli()
    --延迟一帧调用
    local frequencies = UserModel:frequencies()
    local num = frequencies["9"] or 0
    if TutorialManager.getInstance():isHomeExistGuide() or  num <= 1 then
       return  
    end

    --显示完充值返利后是否需要显示首充或者月卡界面
    local showFirstRechargeView = function ()
        if LoginControler:getFirstLoginStatus() then
            if not ActivityFirstRechargeModel:isRecharged() then
                WindowControler:showWindow("ActivityFirstRechargeView")
            else
                local inactiveMonthCards = MonthCardModel:getUnpurchasedMonthCards()
                if #inactiveMonthCards > 0 then
                    WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[inactiveMonthCards[1].monthCardId])
                end
            end
        end
    end

    WindowControler:globalDelayCall(function ()
           WindowControler:showWindow("CompChongZhiShowUI", showFirstRechargeView)  
        end, 1/GameVars.GAMEFRAMERATE)   
end

function HomeModel:setSystemToArr(systemName)
    if not self.systemToArr then
        self.systemToArr = {}
    end
    if systemName ~=   FuncCommon.SYSTEM_NAME.SHAREBOSS then
        self.systemToArr[systemName] = {
            time = TimeControler:getServerTime(),
            ishave = true,
        }
    end
end

--判断系统是否已经开启过
function HomeModel:getSystemIsHas(systemName)
    if self.systemToArr and self.systemToArr[systemName] then
        return self.systemToArr[systemName].ishave
    end
    return nil
end

--获得限时活动是否开启
function HomeModel:getsystemIsOpen()
    local systemArr = {"shareBoss","crossPeak"}
    local newInsert = {}
    local dataList = FuncActivityList.getDataList()
    for i=1,table.length(dataList) do
        local data = dataList[i]
        local associateActivity = data.associateActivity
        if table.find(systemArr,associateActivity) then
            if associateActivity == "crossPeak" then
                local isopen = CrossPeakModel:isActivityOpen()
                --echo("=====isopen===仙盟对决是否开启======",isopen)
                if isopen then
                    table.insert(newInsert,data)
                end
            elseif  associateActivity == "guildactivity" then
                local isaddGuild = GuildModel:isInGuild()
                if isaddGuild then
                    local isopen = GuildActMainModel:isActivityCanOpen()
                    if isopen then
                        table.insert(newInsert,data)
                    end
                end
            elseif   associateActivity == "shareBoss" then
                echo("\n\n幻境邪站的star===", star)
                local star = ShareBossModel:needShowShareBossForHomeView()
                if star and star > 0 then
                    data.star = star
                    table.insert(newInsert,data)
                end
            end
        end
    end
    return newInsert
end



function HomeModel:isOpenPVPFile()
    local fileArr = FuncHome.OPEN_PVP_ACTION_FILE 
    local mainId =  WorldModel:getMaxPassRaidId(FuncChapter.stageType.TYPE_STAGE_MAIN)
    local eliteId =  WorldModel:getMaxPassRaidId(FuncChapter.stageType.TYPE_STAGE_ELITE)
    for i=1,#fileArr do
        if mainId >= fileArr[i][1] and eliteId < fileArr[i][2] then
            return true
        end
    end
    return false
end



return HomeModel;
















