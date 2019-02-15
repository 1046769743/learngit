--[[
    guan
    2016.7.22

    主界面下面的toolBar 一排功能键
]]

local HomeMainCompoment = class("HomeMainCompoment", UIBase);
local btnTag = 945;

--btnName btn 名字 orderId 是 顺序，最右面是1
-- orderId 99 目标
HomeMainCompoment.BTN_SYS_NAME_MAP = {
    -- char = {btnName = "btn_char", orderId = 3, sysName = "char"},  
    partner = {btnName = "btn_friend", orderId = 1, sysName = "partner",isSystem = true}, 
    bag = {btnName = "btn_bag", orderId = 5, sysName = "bag",isSystem = true},    
    love = {btnName = "btn_love", orderId = 2, sysName = "love",isSystem = true},   ----情缘
    lottery =  {btnName = "btn_huodong1", orderId = 4, sysName = "lottery",isSystem = true},
    cimelia =  {btnName = "btn_god", orderId = 3, sysName = "cimelia",isSystem = true},
    otherMore =  {btnName = "btn_more", orderId = 6, isSystem = false,sysName = "array"},  ---更多
    guild = {btnName = "btn_guild", orderId = 23, sysName = "guild",isSystem = true},
    pvp = {btnName = "btn_arena", orderId = 22, sysName = "pvp",isSystem = true},  --仙途
    elite = {btnName = "btn_lilian", orderId = 21, sysName = "elite",isSystem = true},  --历练
};


function HomeMainCompoment:ctor(winName)
    HomeMainCompoment.super.ctor(self, winName);
    self._cloneCtns = {};
    self._ctnpostable = {};
    self._SysBtnArr = {};
end

function HomeMainCompoment:loadUIComplete()
    self:registerEvent();
    self.UI_more:setVisible(false)
    self:initUI();
    self.UI_more:initView()
    

end 


function HomeMainCompoment:registerEvent()
    HomeMainCompoment.super.registerEvent();

    --todo  应该是有功能开启事件
    EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT, 
        self.newSystemOpenCallBack, self)

    --显示了主界面（2017.11.16,添加一个99优先级，保证先重置按钮位置再触发其他事件）
    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self,99);

    --红点检查
    EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.redPointDateUpate, self, 1); 

    EventControler:addEventListener(HomeEvent.SHOW_BUTTON_EFFECT,
        self.buttonEffectIsShow, self, 1);


    EventControler:addEventListener(BattleEvent.BATTLEEVENT_ONBATTLEENTER, 
        self.onBattlleEnter, self)

    EventControler:addEventListener(HomeEvent.HIDDEN_MORE_VIEW, 
        self.hiddenView, self)

    EventControler:addEventListener(EliteEvent.ELITE_FIRST_PASS_RAID, 
        self.addPvPButtonEffect, self)

    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, 
        self.addPvPButtonEffect, self)

    -- EventControler:addEventListener(HomeEvent.SHOW_AIR_BUBBLE_UI,self.addBuddleTips,self)  --气泡暂时屏蔽
end

function HomeMainCompoment:addBuddleTips(params)

    local systme = params.params
    echo("===气泡显示==systme=======",systme)
    if not systme then
        return 
    end
    if systme == FuncCommon.SYSTEM_NAME.PVE then
        local datatable = {systemname = FuncCommon.SYSTEM_NAME.PVE,npc = false }
        -- self:addBubbleView(datatable,self.btn_world)
    else
        for i=1,#self._SysBtnArr do
            local datatable = {systemname = FuncCommon.SYSTEM_NAME.PVE,npc = false }
            local addctn = self._SysBtnArr[i].system
            local systemname = self._SysBtnArr[i].systemname
            if systemname == systme then
                datatable.systemname = systemname
                -- self:addBubbleView(datatable,addctn)
            end
        end
    end
end

function HomeMainCompoment:onCheckWhenShowWindow( ... )
    echo("------HomeMainCompoment:onCheckWhenShowWindow---");

    -- if WindowControler:isCurViewIsHomeTown() == true then 
    --     return;
    -- end 

    -- for k, v in pairs(self._cloneCtns) do
    --     local btn = v.widget:getChildByTag(btnTag);
    --     btn:disablePriorityTouch();
    -- end
    -- self.btn_world:disablePriorityTouch()
end

function HomeMainCompoment:onHomeShow(event)
    local lastViewName = event.params.lastViewName
    local currentVieName = event.params.currentVieName
    echo("---HomeMainCompoment:onHomeShow- -----lastViewName --currentVieName  --",lastViewName,currentVieName);
    -- if self._isNeedShowAni == true then 
    --     self:donwResChange(self._newSysName);
    --     self._isNeedShowAni = false;
    -- end
    -- 剧情对话界面被移除露出主城时不重新创建按钮2017.7.10
    if currentVieName ~= "WorldMainView"  then
        return 
    end

    if lastViewName ~= "PlotDialogView" then
        self:resetBtns()
    else
        local isHaveOpen = self:determineSystemHaveIsOpen()
        if isHaveOpen then
            self:resetBtns()
        end
    end

    for k, v in pairs(self._cloneCtns) do
        local btn = v.widget:getChildByTag(btnTag);
        self:manageRedPoint(btn, v.name)
    end

    -- 发送消息告诉HomeMainView，主城组件加载完成
    -- EventControler:dispatchEvent(WorldEvent.WORLD_UI_AND_BTN_FINISH, {_type = "homeBtn"})
    -- EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.worldComeToTop})
end

--判断是否有新系统开启
function HomeMainCompoment:determineSystemHaveIsOpen()
    local arr = HomeMainCompoment.BTN_SYS_NAME_MAP
    local ishave = false
    if self._cloneCtns ~= nil then
        for k, v in pairs(arr) do
            if v.isSystem then
                local havesysname = nil
                for key,valuer in pairs(self._cloneCtns) do
                    if valuer.orderId == v.orderId then
                        havesysname = true
                    end
                end
                if havesysname == nil then
                    local isOpen = FuncCommon.isSystemOpen(v.sysName);
                    if isOpen then
                        ishave = true
                    end
                end
            end
        end
    end
    return ishave
end


function HomeMainCompoment:onBattlleEnter( ... )
    echo("------------------------------");
    echo("----onBattlleEnter------");
    echo("------------------------------");

    HomeModel:setOpenSysCache(self:getOpenSys());
end

function HomeMainCompoment:redPointDateUpate(data)
    -- if true then
    --     return 
    -- end
    local params = data.params
    -- local tempFunc = function (  )
        local redPointType = params.redPointType;

        local isShow = HomeModel:isRedPointShow(redPointType);
        
        --历练按钮里面的系统红点  激情里面的小红点
        if redPointType == FuncCommon.SYSTEM_NAME.PVE then
            -- self.btn_lilian:getUpPanel().panel_red:setVisible(isShow);
            self.btn_juqing:getUpPanel().panel_red:setVisible(isShow);
            return;
        end

        local systemArr = HomeModel.MORE_OTHER
        for k, v in pairs(self._cloneCtns) do
           
            if v.name == redPointType then 
                local btnWidget = v.widget:getChildByTag(btnTag);
                local panel = btnWidget:getUpPanel();
                panel.panel_red:setVisible(isShow);
            end 
            if table.find(systemArr,v.name) then
                local isRedPointShow = HomeModel:getMoreRedIsShow()
                -- echo("========isRedPointShow=====",v.name,isRedPointShow)
                v.cloneBtn:getUpPanel().panel_red:setVisible(isRedPointShow);
            end 
        end
    -- end

    -- self:stopAllActions()
    -- self:delayCall(c_func(tempFunc), 0.01)

end

function HomeMainCompoment:newSystemOpenCallBack(event)    
    local openSysName = event.params.sysNameKey;

    -- echo("---HomeMainCompoment:newSystemOpenCallBack---", openSysName);

    function isNewBtnShow(openSysName)
        if openSysName ~= nil and 
                HomeMainCompoment.BTN_SYS_NAME_MAP[openSysName] ~= nil then 
            return true;
        else 
            return false;
        end  
    end
    
    if isNewBtnShow(openSysName) == true then 
        self._isNeedShowAni = true;
        self._newSysName = openSysName;
    end 
end

--删除特效 重新搞下面的btn, 为下个功能开启做准备
function HomeMainCompoment:resetBtns()
    echo("--HomeMainCompoment----resetBtns---");
    -- 按照上面的注释看应该是没有用了，先注掉2017.6.8 4:55

    self:initBtns();


end

function HomeMainCompoment:initUI()

    function setBtnUnVIsible()
        self.btn_arena:setVisible(false);
        self.btn_guild:setVisible(false);

        self.btn_bag:setVisible(false);
        self.btn_friend:setVisible(false);
        -- self.btn_holy:setVisible(false);
        -- self.btn_char:setVisible(false);
        -- self.btn_treasure:setVisible(false);
        -- self.btn_equipment:setVisible(false);
        self.btn_more:setVisible(false)
        self.btn_love:setVisible(false);
        self.btn_god:setVisible(false);
    end
    
    self:initFunc();
    setBtnUnVIsible();
    self:initBtns();
end

function HomeMainCompoment:clearCloneWidget()
    --[[
        self._cloneCtns = {};
    ]]
    for k,v in pairs(self._cloneCtns) do
        v.widget:removeFromParent();
    end

    -- if self._downAni ~= nil then 
    --     self._downAni:removeFromParent();
    --     self._downAni = nil;
    -- end 

    self._cloneCtns = {};
    self._SysBtnArr = {};
end

function HomeMainCompoment:initBtns()
    -- local newWorld = self.btn_six;
    -- newWorld:setTouchedFunc(c_func(self.clicknewWorld, self));
    self:clearCloneWidget();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            

    --历练 ---剧情
    local btnLilian =  self.btn_juqing ---self.btn_world;  
    btnLilian:stopAllActions()
    btnLilian:setScale(1)
    btnLilian:setTouchedFunc(c_func(self.clickplot, self), nil,true);

    ---之前处理六界按钮的红点  ---剧情的
    local isShowPVERedPoint = HomeModel:isRedPointShow(HomeModel.REDPOINT.DOWNBTN.CHALLENGE)
    
    if HomeModel:isRedPointShow(HomeModel.REDPOINT.DOWNBTN.CHALLENGE) then
        self.btn_juqing:getUpPanel().panel_red:setVisible(true);
    else 
        self.btn_juqing:getUpPanel().panel_red:setVisible(false);
    end 


    for sysName, v in pairs(HomeMainCompoment.BTN_SYS_NAME_MAP) do
        self[v.btnName]:setVisible(false)
    end

    local openSys = self:getOpenSys();
    if HomeModel:getOpenSysCache() ~= nil then 
        openSys = HomeModel:getOpenSysCache();
    end

    for index, v in pairs(openSys) do
        if self[v.btnName] ~= nil then
            self[v.btnName]:setVisible(false)
            --echo("=======v.btnName======",v.btnName)
        end

        -- 应该把index改成 v.orderId,或者直接读表里的orderNum,以前传入的是index
        local btnInCtnWidget = self:createSingleBtn(v, v.orderId);
        local btnWidget = btnInCtnWidget:getChildByTag(btnTag);
        -- 如果需要展示功能开启就隐藏这个按钮
        if TutorialManager.getInstance():isNeedOpenAnim(v.sysName) then
            if v.sysName == "cimelia" then  ---单独神器处理
                btnInCtnWidget:opacity(255)
            else
                btnInCtnWidget:opacity(0)
            end
            
        end
        --给合成单独判断下，它没有model，比较特殊
        -- if v.sysName == "treasure" then 
        --     if CombineControl:isHaveCanCombineTreasure() == false and 
        --             TreasuresModel:isRedPointShow() == false then  
        --         btnWidget:getUpPanel().panel_red:setVisible(false);
        --     else 
        --         btnWidget:getUpPanel().panel_red:setVisible(true);
        --     end 
        -- elseif v.sysName == "pvp" then
        --     local isShow = ChallengeModel:checkShowRed();
        --     btnWidget:getUpPanel().panel_red:setVisible(isShow);
        -- else 
        --     if HomeModel:isRedPointShow(v.sysName) == true then 
        --         btnWidget:getUpPanel().panel_red:setVisible(true);
        --     else 
        --         btnWidget:getUpPanel().panel_red:setVisible(false);
        --     end 
        -- end
        self:manageRedPoint(btnWidget, v.sysName)

        -- table.insert(self._cloneCtns, 
        --     {widget = btnInCtnWidget, name = v.sysName});

        --要不加 -btnIndex，点击区域有问题~
        self:addChild(btnInCtnWidget, v.orderId);


        -- end
    end


    HomeModel:insertCtnToclone( self._cloneCtns )
    -- dump(self._cloneCtns,"系统入口的表2222====")
    -- echoError("111111111111111111")
    HomeModel:setOpenSysCache(nil)
    self:btnPosArr()
    self:refreshBtnPos()
    for k,v in pairs(self._cloneCtns) do
        self:buttonEffectIsShow(v)
    end
    

    -- 检查需要加动画的弱引导
    local systems = TutorialManager.getInstance():getEntranceGuide("WorldMainView")

    for _,sysname in ipairs(systems) do
        local btn = self:getBtnBySysName(sysname)
        if btn then
            -- 给按钮加效果
            FuncCommUI.playAnimBreath(btn,three(sysname == "pve",1.1,1.2))
        end
    end
end

--按钮添加特效
function HomeMainCompoment:buttonEffectIsShow(data)
    local systemName = nil
    if data.params then
        systemName = data.params.systemName;
    else
        systemName = data.name
    end

    local map = HomeModel:getButtonEffectIsShow(systemName)
    -- dump(map,"按钮添加特效 =============== ")
    -- -- dump(self._cloneCtns, "\n\nself._cloneCtns====")
    -- echo("=====systemName====",systemName)
    local _ctn = nil
    if table.find(HomeModel.MORE_OTHER,systemName) or systemName == "array" then
        for k,v in pairs(self._cloneCtns) do
            if v.name == "array" then
                _ctn = v.cloneBtn
            end
        end
        for k,v in pairs(HomeModel.MORE_OTHER) do
            map = HomeModel:getButtonEffectIsShow(v)
            if map then
                break
            end
        end
    end


    if map and map._type then
        if not _ctn then
            for k,v in pairs(self._cloneCtns) do
                if systemName == v.name then
                    _ctn = v.cloneBtn
                elseif systemName == FuncCommon.SYSTEM_NAME.PVE then
                    _ctn = self.btn_juqing
                end
            end
        end
        -- echo("===========_ctn=========",_ctn)
        FuncCommUI.addHomeButtonEffect(_ctn,map,60)
    end
end


function HomeMainCompoment:btnPosArr()
    self._ctnpostable = {}

    for i=1,HomeModel.HomeView_Ctn do
        local x = self["ctn_"..i]:getPositionX()
        local y = self["ctn_"..i]:getPositionY()
        self._ctnpostable[i] = { x = x,y = y,index = i}
    end

    for i=1,3 do
        local x = self["ctn_2"..i]:getPositionX()
        local y = self["ctn_2"..i]:getPositionY()
        local pos  = { x = x,y = y,index = 20+i}
        table.insert(self._ctnpostable,pos)
    end

    -- dump(self._ctnpostable,"000000",5)
end
--刷新主城系统按钮位置
function HomeMainCompoment:refreshBtnPos()
    -- echo("主城按钮重新排序了 ====================")
    local index = 1
    local buttonNum = 0
    for i=1,#self._ctnpostable do
        local x = self._ctnpostable[i].x
        local y = self._ctnpostable[i].y
        if self._SysBtnArr[i] ~= nil then
            if self._SysBtnArr[i].orderId < 20 then  ---20 非第一列的按钮
                self._cloneCtns[i].widget:setPositionX(x)--cc.p(x,y))
                -- echo("=====xx=========",xx)
                if self._SysBtnArr[i].systemname == FuncCommon.SYSTEM_NAME.ARRAY then
                    self:setMoreButtonPos(self["ctn_"..i])
                end
                buttonNum = buttonNum + 1
            else
                local pos_x  = self["ctn_2"..index]:getPositionX()
                local pos_y  = self["ctn_2"..index]:getPositionY()
                self._cloneCtns[i].widget:setPosition(cc.p(pos_x,pos_y))
                index = index + 1     
            end
        end
    end

    if self._SysBtnArr then
        local num = buttonNum
        -- echoError("=====主城=按钮=个数=====",num)
        local offx =  145
        local sumLength = 740
        local offlen = 0.5
        if num >= 6 then
            self.panel_dt:setScaleX(1.05)
        elseif num < 6 then
            self.panel_dt:setScaleX((offx*num)/740)
        end
    end


    self:addPvPButtonEffect()

    if not  HomeModel.isShowEnterAni  then
        EventControler:dispatchEvent(WorldEvent.WORLD_UI_AND_BTN_FINISH, {_type = "homeBtn"})
    end
end

function HomeMainCompoment:addPvPButtonEffect()
    -- dump(self._cloneCtns,"3333333333333333")
    for k,v in pairs(self._cloneCtns) do
        if v.name == "elite" then
            self:addPVPAction(v.cloneBtn)
            break
        end
    end
end

function HomeMainCompoment:addPVPAction(btn)
    if btn then
        local ctn = btn:getUpPanel().ctn_1
        local isopen = HomeModel:isOpenPVPFile()
        local effect =  ctn:getChildByName("effect")
        echo("=====isopen=======",isopen,effect)
        if isopen then
            if not effect then
                effect = self:createUIArmature("UI_liujie","UI_liujie_jiantou_xintiaozhan", ctn, true, function ()
                end)
                effect:setName("effect")
                effect:setPosition(cc.p(-100,-20))
                -- effect:setScaleX(-1)
            end
            -- local isTutorial = TutorialManager.getInstance():isInTutorial()
            if TutorialManager.getInstance():isHomeExistGuide() 
                or TutorialManager.getInstance():isHomeExistSysOpen() 
                or TutorialManager.getInstance():isHasTriggerSystemOpen()
                or TutorialManager.getInstance():isInTutorial() then
            -- if isTutorial then
                effect:setVisible(false)
            else
                effect:setVisible(true)
            end
        else
            if effect then
               effect:setVisible(false)
            end
        end
        -- effect
    end
end

function HomeMainCompoment:manageRedPoint(btnWidget, sysName)
    -- if sysName == "treasure" then 
    --     if CombineControl:isHaveCanCombineTreasure() == false and 
    --             TreasuresModel:isRedPointShow() == false then  
    --         btnWidget:getUpPanel().panel_red:setVisible(false);
    --     else 
    --         btnWidget:getUpPanel().panel_red:setVisible(true);
    --     end 
    -- else
    if sysName == FuncCommon.SYSTEM_NAME.PVP then
        local isShow = ChallengePvPModel:checkShowRed();
        btnWidget:getUpPanel().panel_red:setVisible(isShow);
    elseif sysName == FuncCommon.SYSTEM_NAME.ARRAY then --处理更多按钮的红点显示问题
        local isShow = HomeModel:getMoreRedIsShow()
        btnWidget:getUpPanel().panel_red:setVisible(isShow);
    else 
        if HomeModel:isRedPointShow(sysName) == true then 
            btnWidget:getUpPanel().panel_red:setVisible(true);
        else 
            btnWidget:getUpPanel().panel_red:setVisible(false);
        end 
    end
end

function HomeMainCompoment:getOpenSys()
    local btnOpenSys = {};

    for sysName, v in pairs(HomeMainCompoment.BTN_SYS_NAME_MAP) do
        if sysName ~= "otherMore" then
            local isOpen = FuncCommon.isSystemOpen(sysName);
            if isOpen == true then 
                table.insert(btnOpenSys, v)
            end
        end
        if not v.isSystem then
            local systemAr = HomeModel.MORE_OTHER
            for k,valuer in pairs(systemAr) do
                local isOpen = FuncCommon.isSystemOpen(valuer);
                if isOpen then
                    table.insert(btnOpenSys, v)
                    break 
                end
            end
            
        end
    end

    --orderId 从小到大，排序
    local function sortFunc(p1, p2)
        if p1.orderId < p2.orderId then 
            return true;
        else 
            return false;
        end 
    end


    table.sort(btnOpenSys, sortFunc);

    return btnOpenSys;
end


function HomeMainCompoment:createSingleBtn(btnInfo, btnIndex)

    local cloneBtn = UIBaseDef:cloneOneView(self[btnInfo.btnName]);
    --echo("========btnInfo.sysName=======",btnInfo.sysName)
    local isRedPointShow = HomeModel:isRedPointShow(btnInfo.sysName);

    if btnInfo.sysName == FuncCommon.SYSTEM_NAME.ELITE then
        isRedPointShow = ChallengeModel:checkShowRed();
    elseif btnInfo.sysName == FuncCommon.SYSTEM_NAME.ARRAY then
        isRedPointShow = HomeModel:getMoreRedIsShow();  ----更多的红点处理
    end  

    cloneBtn:getUpPanel().panel_red:setVisible(isRedPointShow);

    cloneBtn:setVisible(true);
    cloneBtn:setPosition(-10, 0);

    --绑方法
    -- cloneBtn:setTouchedFunc(c_func(self._btnFuncs[btnInfo.sysName], self));
    -- cloneBtn:setTouchSwallowEnabled(true); 

    local cloneCtn = UIBaseDef:cloneOneView(self["ctn_" .. tostring(btnIndex)]);

    cloneCtn:addChild(cloneBtn, 100, btnTag);
    -- if btnInfo.sysName == "array" then
    --     self:setMoreButtonPos(cloneCtn)
    -- end
    

    cloneBtn:setTouchedFunc(c_func(self._btnFuncs[btnInfo.sysName], self,cloneCtn), nil,true);
    -- 统一加入
    table.insert(self._cloneCtns, 
        {widget = cloneCtn, name = btnInfo.sysName, orderId = btnInfo.orderId, cloneBtn = cloneBtn});

    table.insert(self._SysBtnArr,{systemname = btnInfo.sysName  ,system  = cloneBtn,orderId = btnInfo.orderId,widget =cloneCtn});

    return cloneCtn;
end
--添加气泡功能
function HomeMainCompoment:addBubbleView(datatable,followView)
    FuncCommUI.regesitShowBubbleView(datatable,followView)
end

function HomeMainCompoment:initFunc()
    self._btnFuncs = {
        pve = self.clickChalleng,
        pvp = self.clickGuildTu,
        romance = self.clickRomance,
        bag = self.clickBag,
        partner = self.clickPartner,
        -- char = self.clickChar,
        treasure = self.clickTreasure,
        lottery = self.clickLottery,
        love = self.clickLeve,
        cimelia = self.clickcimelia,
        array = self.clickotherMore,  
        guild = self.clickguild,
        elite = self.clickChalleng,
    };
end

--仙途
function HomeMainCompoment:clickGuildTu()
   echo("---------仙途---------");
   self:hiddenView()
   WindowControler:showWindow("ChallengePvpView");

end

function HomeMainCompoment:setMoreButtonPos(btn)
    local x = btn:getPositionX()
    local y = btn:getPositionY()
    self.UI_more:setPosition(cc.p(x-10,y+80))
end
---更多
function HomeMainCompoment:clickotherMore(cloneBtn)
    echo("---------更多---------");

    self:setMoreButtonPos(cloneBtn)
    if not self.toMoreView then
        self.UI_more:setVisible(true)
        self.UI_more:initView()
        self.toMoreView = true
        self:showMoreButtonEffect(false)
    else
        self.toMoreView  = false
        self.UI_more:setVisible(false)
        -- self.UI_more:initView() 
        self:showMoreButtonEffect(true)
    end
    

end

function HomeMainCompoment:showMoreButtonEffect(isShow)

    if isShow then
        for k,v in pairs(HomeModel.MORE_OTHER,systemName) do
            local map = HomeModel:getButtonEffectIsShow(v)
            if map then
                if (not map._type) or (not map.isShow) then
                    isShow = false
                end
            end
        end
    end

    local _ctn = nil
    for k,v in pairs(self._cloneCtns) do
        if v.name == "array" then
            _ctn = v.cloneBtn
        end
    end
    if _ctn then
        local effect = _ctn:getChildByName("UI_ketisheng")
        if effect then
            effect:setVisible(isShow)
        end
    end
end


function HomeMainCompoment:hiddenView()
    self.toMoreView  = false
    self.UI_more:setVisible(false)
    self:showMoreButtonEffect(true)
end




--三皇台
function HomeMainCompoment:clickLottery()
    echo("---------三皇台---------");
    self:hiddenView()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.LOTTERY)
end
function HomeMainCompoment:clickguild()
    echo("---------clickGuild---------");
    self:hiddenView()
    GuildControler:showTowerMainView()

end
--布阵
function HomeMainCompoment:clickarray()
    self:hiddenView()
    local isopen =  FuncCommon.isSystemOpen("array")
    if isopen then
        local parameter = FuncTeamFormation.formation.pve
        params = {}
        WindowControler:showWindow("WuXingTeamEmbattleView",parameter,params,true,false)
    end
 -- WindowControler:showWindow("VoiceDemoView")

end
--神器
function HomeMainCompoment:clickcimelia()
    self:hiddenView()
   ArtifactModel:isOpenArtifactSystem()
end


function HomeMainCompoment:clickGod()
    echo("---------clickGod---------");
    self:hiddenView()
    WindowControler:showTips("功能未开启");
--    WindowControler:showWindow("GodView")
    -- WindowControler:showWindow("PartnerEquipView")
end
function HomeMainCompoment:clickLeve()
    -- WindowControler:showWindow("LoveView");
    self:hiddenView()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.LOVE)
end

function HomeMainCompoment:clickPractice()
    echo("---------clickPractice---------");
    -- WindowControler:showWindow("PartnerEquipView")
    -- WindowControler:showWindow("PracticeMianView")  ---修炼
    self:hiddenView()
    ArtifactModel:isOpenArtifactSystem()
end

function HomeMainCompoment:clickRomance()
    echo("-----romance-------");
    -- WindowControler:showWindow("EliteView")
    self:hiddenView()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.ROMANCE)
end

-- function HomeMainCompoment:clickChar()
--     echo("-----clickCharMainView-------");
--     -- WindowControler:showWindow("CharMainView");
--     WindowControler:showTips("需要凯子 屏蔽主角")
-- end

function HomeMainCompoment:clickChalleng()
    echo("-----clickChallenge-----");  
    self:hiddenView()
    WindowControler:showWindow("ChallengeView");
    -- FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.PVP)
end

function HomeMainCompoment:clickTreasure()
    echo("-----clickTreasure-----");
    self:hiddenView()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.TREASURE_NEW)
end

function HomeMainCompoment:clickPartner()
    echo("-----clickPartner-----");
    -- 添加判断 是否有伙伴数据
    self:hiddenView()
    local data = PartnerModel:getAllPartner()
    for i = 1,5 do
        if PartnerModel:isOpenByType(i) then
            WindowControler:showWindow("PartnerView");
            return
        end
    end

    WindowControler:showTips("没有可开启的功能，正常不会出现")
end

-- --历练
-- function HomeMainCompoment:clickChalleng()
--     echo("-----click trial-----");
--     -- FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.PVE)
--     self:hiddenView()
--     WindowControler:showWindow("ChallengeView");

-- end

--剧情
function HomeMainCompoment:clickplot()
    local sysName = FuncCommon.SYSTEM_NAME.PVE
    local isopen,conditionValue, conditionType,lockTip = FuncCommon.isSystemOpen(sysName)
    if isopen then
        WindowControler:showWindow("WorldPVEListView")
    else
        WindowControler:showTips(lockTip)
    end
end

function HomeMainCompoment:clickBag()
    echo("-----clickBag-----");
    -- WindowControler:showWindow("ItemListView");
    self:hiddenView()
    FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.BAG)
end

-- 开启新功能，展示新图标出现动画
function HomeMainCompoment:openNewSystem(sysName, callBack)
    local btnInCtnWidget = nil
    --系统名称转换
    local sysTypeName = FuncCommon.getEntranceName(sysName)
    local  pos,ctnInfo,isserve  =  HomeModel:getCtnWidgetPos(sysTypeName) --  self:getCtnWidgetPos(sysTypeName)
    if isserve then
        btnInCtnWidget = ctnInfo.widget
    else
        btnInCtnWidget = ctnInfo
    end

    if sysTypeName == FuncCommon.SYSTEM_NAME.PVE then
        btnInCtnWidget = self.btn_juqing
    end
   -- 屏蔽点击
    -- WindowControler:setUIClickable(false)
    -- local array = {
    --     cc.FadeIn:create(1),
    --     cc.CallFunc:create(function()
    --         WindowControler:setUIClickable(true)
    --         if callBack then callBack() end
    --     end),
    -- }
    -- btnInCtnWidget:setOpacity(0)
    -- btnInCtnWidget:runAction(cc.Sequence:create(array))
    btnInCtnWidget:setOpacity(255)
    -- 打开屏蔽做回调
    -- WindowControler:setUIClickable(true)
    if callBack then callBack() end
end

-- 获取某功能图标的位置
function HomeMainCompoment:getSystemPos(sysName)
    echo("=======子系统名称===111======",sysName)
    local sysTypeName = FuncCommon.getEntranceName(sysName)
     -- echo("=======子系统名称===222======",sysTypeName)
    -- local  pos,isBtn = self:getCtnWidgetPos(sysTypeName)
    -- return pos
    local pos = HomeModel:bySysNameGetCtnPos(sysName)
    -- echo("3333333333333333333333333")
    if pos == nil then
        -- echo("2222222222222222222")
        local _btnwit = nil
        if sysTypeName == FuncCommon.SYSTEM_NAME.PVP then 
            -- _btnwit = self.btn_lilian
            -- echo("111111111111111111111111111111")
        else
        --     _btnwit = WindowControler:getWindow("HomeMainView"):getQuestPanel().btn_mubiao
        end
        local box = _btnwit:getContainerBox()
        local cx = box.x + box.width/2
        local cy = box.y + box.height/2
        local turnPos = _btnwit:convertToWorldSpaceAR(cc.p(cx,cy))
        return turnPos,_btnwit,false
    end
    -- echo("444444444444444444444444444444")
    return pos

end

function HomeMainCompoment:getBtnBySysName(sysName)
    -- 历练不在
    -- self._cloneCtns
    if sysName == FuncCommon.SYSTEM_NAME.PVE then
        return self.btn_lilian
    end

    for _,info in ipairs(self._cloneCtns) do
        if info.name == sysName then
            return info.cloneBtn
        end
    end
end

return HomeMainCompoment;

