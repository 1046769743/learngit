--
-- Author: xd
-- Date: 2015-11-26 15:03:42
-- 主场景  登入进去以后就是主场景

SceneMain = class("SceneMain", SceneBase)

function SceneMain:ctor(...)

    SceneMain.super.ctor(self, ...)
    -- 战斗root
    self._battleRoot = display.newNode()
    self.__doc:addChild(self._battleRoot);

    --新手引导层
    self._tutoralRoot = display.newNode():addto(self.__doc)

    --置顶的root
    self._topRoot = display.newNode()


    PCSdkHelper:initBuglyUserinfo()

    self.__doc:addChild(self._topRoot)
    --最高的root  会盖住 top ,主要是发现新资源 或者网络异常问题 会盖住他
    self._highRoot = display.newNode():addTo(self.__doc)
    self:addSpecialShape()
    -- 初始化login界面背景
    self:initLoginLoadingViewBg()

    --创建进入测试界面的按钮
    if  DEBUG_ENTER_SCENE_TEST then
        local panel = UIBaseDef:createPublicComponent( "UI_debug_GM","panel_3" )
        panel.mc_1.currentView.txt_1:setString("测试窗口")
        panel:setTouchedFunc(c_func(self.enterTestWindow,self))
        panel:setTouchSwallowEnabled(true)
        panel:addto(self.__doc):pos(100,GameVars.height -20)
        FuncCommUI.SceneTestView = panel
        FuncCommUI.dragOneView(panel)

    end

    if IS_SHOW_BATTLE_IFNO then
        self:addBattleDebugInfoView()
    end

    if SHOW_CLICK_RECT then
        self:addTutorialDebugInfoView()
    end

    self:addShowLogView()
end



function SceneMain:addSpecialShape(  )
    if AppInformation:isToolBarIphone(  ) then
        GameVars.toolBarWidth = 55
        GameVars.toolBarWay = -1
        ScreenAdapterTools.initDatas()
    end
    if GameVars.toolBarWidth > 0 and  GameVars.toolBarWay~= 0 then
        -- WindowControler:showOrHideBorderBar( true ,self)
    end
    
end

function SceneMain:addSceneTest( )
    local panel = UIBaseDef:createPublicComponent( "UI_debug_GM","panel_3" )
    panel.mc_1.currentView.txt_1:setString("测试窗口")
    panel:setTouchedFunc(c_func(self.enterTestWindow,self))
    panel:setTouchSwallowEnabled(true)
    panel:addto(self.__doc):pos(100,GameVars.height -20)
    FuncCommUI.SceneTestView = panel
    FuncCommUI.dragOneView(panel)
end
function SceneMain:addBattleDebugInfoView( ... )
    local panel = UIBaseDef:createPublicComponent( "UI_debug_GM","panel_3" )
    panel.mc_1.currentView.txt_1:setString("查看属性")
    panel:setTouchedFunc(c_func(self.enterBattleInfoView,self))
    panel:setTouchSwallowEnabled(true)
    panel:addto(self.__doc):pos(300,GameVars.height-20)
    -- FuncCommUI.SceneTestView = panel
    FuncCommUI.dragOneView(panel)
end
function SceneMain:enterBattleInfoView( )
   FuncCommUI.addBattleInfoView()
end

function SceneMain:addTutorialDebugInfoView()
    local panel = UIBaseDef:createPublicComponent( "UI_debug_GM","panel_3" )
    panel.mc_1.currentView.txt_1:setString("引导步骤")
    panel:setTouchSwallowEnabled(true)
    panel:addto(self.__doc):pos(500,GameVars.height-20)
    -- FuncCommUI.SceneTestView = panel
    FuncCommUI.dragOneView(panel)

    EventControler:addEventListener(TutorialEvent.TUTORIAL_DEBUG, function(scenemain, event)
        local groupId = tostring(event.params.groupId)
        local tutorialId = tostring(event.params.tutorialId)
        panel.mc_1.currentView.txt_1:setString(groupId .. ":" .. tutorialId)
    end, self);
end

function SceneMain:enterTestWindow(  )
    if self._winTest and (not tolua.isnull(self._winTest) ) then
        self._winTest:clear()
    end
    package.loaded["app.scenes.Window_test"] = nil
    package.preload["app.scenes.Window_test"] = nil
    self._winTest = require("app.scenes.Window_test").new():addto(self.__doc,1000)
end


function SceneMain:initLoginLoadingViewBg()
    -- local cfg = WindowsTools:getUiCfg("LoginLoadingView")
    -- local loginBg = display.newSprite("bg/" .. cfg.bg)
    -- FuncCommUI.setBgScaleAlign(loginBg)
    -- loginBg:setScale(GameVars.bgSpriteScale)
    -- loginBg:pos(0 ,GameVars.height)
    display.addSpriteFrames("anim/armature/UI_denglu.plist", "anim/armature/UI_denglu.png")
    local sp = display.newSprite("#UI_denglu_yj-g11111.png")
    sp:anchor(0,0)
    sp:pos(GameVars.fullWidth/2-GameVars.maxScreenWidth /2-14 +GameVars.sceneOffsetX  ,GameVars.sceneOffsetY)
    self.__sceneBgRoot:addChild(sp,-1)
end

-- 进入场景
function SceneMain:onEnter()
    SceneMain.super.onEnter(self)
    
    TimeControler:init()
    -- 注册事件
    self:registEvent()
    -- 最先需要初始化的
    self:initFirst()
    
    self:showLoading()
end

function SceneMain:addSceneBg()

end

-- 在登入之前需要初始化的东西放在这里
function SceneMain:initFirst()
    
    
    FuncArmature.loadOneArmatureTexture("UI_zhuanjuhua", nil, true)
    --初始化随机因子
    RandomControl.setOneRandomYinzi(TimeControler:getTime(),0)

    -- AudioModel初始化
    
     -- 是否显示点击坐标
    -- if SHOW_CLICK_POS == true then 
        -- self:showClickPos();
    -- end

    if DEBUG_ENTER_SCENE_TEST then
        self:initCommonRes()
    end
    self:updateBarPos()
end

-- 注册事件
function SceneMain:registEvent()
    SceneMain.super.registEvent(self)
end

-- Login Model 更新完成回调
function SceneMain:onLoginModelUpdateComplete()
    GameLuaLoader:loadGameSysFuncs()
    GameLuaLoader:loadGameBattleInit()
end

-- 进入登录loading界面
function SceneMain:showLoading()
    WindowControler:showWindow("LoginLoadingView")
end

-- 显示点击坐标
function SceneMain:showClickPos()
    self._layer = cc.Node:create();
    self:addChild(self._layer);

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    if self._tutoriallistener == nil then 
        self._tutoriallistener = cc.EventListenerTouchOneByOne:create();
    end 

    -- self._tutoriallistener:setSwallowTouches(true);

    local function onTouchBegan(touch, event)
        local uiPos = touch:getLocationInView()

        local clickPosGL = Tool:convertToGL({x = uiPos.x, y = uiPos.y}); 

        -- print("click pos x: " .. tostring(clickPosGL.x) .. " y: " .. tostring(clickPosGL.y));
        -- dump(clickPosGL, "--gl--pos");
        return true
    end

    local function onTouchEnded(touch, event)  
        local uiPos = touch:getLocationInView();
        -- dump(uiPos, "--pos---onTouchEnded");
    end

    self._tutoriallistener:registerScriptHandler(onTouchEnded,
        cc.Handler.EVENT_TOUCH_ENDED);
    self._tutoriallistener:registerScriptHandler(onTouchBegan, 
        cc.Handler.EVENT_TOUCH_BEGAN);

    eventDispatcher:addEventListenerWithSceneGraphPriority(
        self._tutoriallistener, self._layer); 
end

playSound = true
--创建点击屏幕特效
function SceneMain:createClickEff(  )
    FuncArmature.loadOneArmatureTexture("UI_ClickEffect", nil, true)
    --注册全屏点击特效
    --目前最多创建3个clickEff 循环使用

    local clickNode = display.newNode():addto(self,100):size(GameVars.width,GameVars.height )
    clickNode:anchor(0,0):pos(GameVars.sceneOffsetX ,GameVars.sceneOffsetY)

    local clickEffArr = {}
    local getClickkEff = function ( index )
        if not clickEffArr[index] then
            clickEffArr[index] =  FuncArmature.createArmature("UI_ClickEffect", self._topRoot, false, GameVars.emptyFunc)
           
        end
        local ani = clickEffArr[index]
        ani:visible(true)
        ani:playWithIndex(0, false)
        ani:doByLastFrame(false, true)
        return ani
    end

    local clickIndex = 0

    --点击屏幕创建 特效
    local tempFunc = function (e  )
        if IS_SHOW_CLICK_EFFECT then
            local index = clickIndex%3 +1
            clickIndex = clickIndex+ 1
            local clickEff = getClickkEff(index)
            
            local turnPos = self._topRoot:convertToNodeSpaceAR(e)
            clickEff:pos(turnPos.x,turnPos.y)

            if playSound == true then
                -- AudioModel:playSound("s_com_click2")
            end 
        end
    end



    clickNode:setTouchedFunc(GameVars.emptyFunc, cc.rect(0 ,0,GameVars.width,GameVars.height ), 
        false, tempFunc, nil, false)
end

-- ===================================================== 对外接口 =====================================================

function SceneMain:initCommonRes()
    self:createClickEff()
     -- 需要加载通用ui特效
    FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
    FuncArmature.loadOneArmatureTexture("common", nil, true)
end


-- 获取战斗root
function SceneMain:getBattleRoot()
    return self._battleRoot
end

-- 设置BattleRoot是否显示
function SceneMain:setBattleRootVisiable(visible)
    if self._battleRoot then
        self._battleRoot:setVisible(visible)
    end
end

-- 显示战斗root 那么就需要隐藏 root
function SceneMain:showBattleRoot(ignoreHideRoot)
    if not ignoreHideRoot then
        self._root:visible(false)
    end
    
    if self._testRoot then
        self._testRoot:visible(false)
    end

    self._battleRoot:visible(true)
end

-- 显示主root
function SceneMain:showRoot()
    self._root:visible(true)
    self._battleRoot:visible(false)
    if self._testRoot then
        self._testRoot:visible(true)
    end
end

--显示所有root
function SceneMain:showAllRoot(  )
    self._root:visible(true)
    self._battleRoot:visible(true)
end


-- 显示玩家基本信息
function SceneMain:showUserInfo()
    -- 空实现
end


--显示log界面和发送错误到平台
function SceneMain:addShowLogView()
    local index = 0
    local node = display.newNode()
    node:size(50,50)
    node:anchor(0,0.5)
    node:setPosition(cc.p(0,GameVars.height/2))
    -- local scene = display.getRunningScene()
    self.__doc:addChild(node,10000)
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(false)
    self.lastClickTime = os.time()
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
                return true
        elseif event.name == "moved" then

        elseif event.name == "ended" then
            if IS_OPEN_LOGDEBUG then
                --超过2秒就重置为0
                local disTime = os.time() -self.lastClickTime
                if disTime >  1  then
                    GameVars.clickNumberTimes = 0
                end
                self.lastClickTime = os.time()
                GameVars.clickNumberTimes = GameVars.clickNumberTimes + 1
                local logremainder =  math.fmod(GameVars.clickNumberTimes,3)
                local remainder =  math.fmod(GameVars.clickNumberTimes,5)
                -- echo("======点击次数========",GameVars.clickNumberTimes)
                if logremainder == 0 then
                    -- DEBUG_LOGVIEW = true
                    -- FuncCommUI.addLogsView()
                end

                --1.5秒才让换一次场景
                if DEBUG_TESTSCENE and disTime > 1.5  then

                    EventControler:dispatchEvent("mapchanged")
                end

                if remainder == 0 then
                    --如果是dev平台的 一定弹出日志
                    if LoginControler and LoginControler:checkWhiteAccount() or  AppInformation:getAppPlatform() == "dev" then
                        DEBUG_LOGVIEW = true
                        echo("___这个是白名单------或者是windows平台")
                        DEBUG_ENTER_SCENE_TEST = true
                        FuncCommUI.addSceneTest(  )
                        FuncCommUI.addLogsView()
                        DEBUG_FPS = true
                        local sharedDirector = cc.Director:getInstance()
                        sharedDirector:setDisplayStats(true)

                    end
                    ClientActionControler:sendLuaErrorLogToPlatform()
                end
            end
        end
    end)
end

return SceneMain
