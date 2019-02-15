--2015.7.21 guan demo
--2016.4.20 guan zengqinghe
--2017.5.10 guan zhangqizhi

TutorialLayer = class("TutorialLayer", function()
    return display.newNode();
end)

local ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = 2,
    ["RIGHT"] = 1,
    ["UP"] = 2,
    ["DOWN"] = 1,
};

function TutorialLayer:ctor()
    FuncArmature.loadOneArmatureTexture("UI_qiangzhitishi", nil, true);
    FuncArmature.loadOneArmatureTexture("UI_main_img_shou", nil, true);

    self._tutorialManager = TutorialManager.getInstance();
    self._tutorialId = 1;
    -- self._groupId = nil;


    -- 错误点击时的缓冲数组（距离时间太近不予处理2017.7.10）
    self._clickEffArr = {}
    self._clickIndex = 0
    self._lastClickTime = 0

    self._waitBB = false -- 等待引导员说话

    self:initUI();
    self:initClick();

    self:skipUI();
end

function TutorialLayer:initUI() 
    self._touchNode = display.newLayer();
    --what!!
    self._touchNode:setContentSize(2000, 2000);

    self:addChild(self._touchNode, -1);
    self._touchNode:setTag(123);

    -- 统一走Manager遮罩2017.7.6
    self._grayLayer = self._tutorialManager:createGrayLayer();
    self:addChild(self._grayLayer, -1);

    self._npcContent = self:createNpcContent();
    self:addChild(self._npcContent, 1);

    self._videoContent = self:createVideoContent()
    self:addChild(self._videoContent, 1)

    -- 箭头创建方法修改一下
    self._arrowSprite = self:createArrow();
    self:addChild(self._arrowSprite, 200);

    --创建滑动方向
    local guideLine = WindowsTools:createWindow("GuideLine");
    self._guideLine = guideLine;
    self:addChild(self._guideLine, 800);
end


function TutorialLayer:skipUI()
    if IS_CAN_SKIP_TURORIAL ~= true then 
        return;
    end 

    -- local view = cc.Label:createWithSystemFont("跳过引导", GameVars.systemFontName, 24);
    -- self:addChild(view);
    -- view:pos(50, 12);
    -- view:setColor(cc.c3b(255,0,0));
    
    -- local eventDispatcher = cc.Director:getInstance():getEventDispatcher();
    -- local tutoriallistener = cc.EventListenerTouchOneByOne:create();

    -- local function onTouchBegan(touch, event)
    --     local uiPos = touch:getLocationInView();
    --     local clickPosGL = Tool:convertToGL({x = uiPos.x, y = uiPos.y}); 
    --     -- dump(clickPosGL, "---clickPosGL--");
    --     if clickPosGL.x > 0 and clickPosGL.x < 100 and clickPosGL.y < 24 and self._tutorialManager:getSkip() == false then 
    --         return true;
    --     else 
    --         return false;            
    --     end 
    -- end

    -- local function onTouchEnded(touch, event)  
    --     local uiPos = touch:getLocationInView();
    --     echo("---onTouchEnded!!---");
    --     self._tutorialManager:setSkip(true);
    --     self._tutorialManager:dispose();
    --     WindowControler:showTips( { text = "跳过引导！" })
    -- end

    -- tutoriallistener:registerScriptHandler(onTouchEnded,
    --     cc.Handler.EVENT_TOUCH_ENDED);
    -- tutoriallistener:registerScriptHandler(onTouchBegan, 
    --     cc.Handler.EVENT_TOUCH_BEGAN);

    -- eventDispatcher:addEventListenerWithSceneGraphPriority(
    --     tutoriallistener, view); 

end

function TutorialLayer:setUIByTurtoralId(gid, tid)
    self._tutorialId = tid;
    self._groupId = gid;

    -- 看看有没有前置Tips
    local tips = FuncGuide.getPreTips(self._groupId, self._tutorialId)
    if tips then
        WindowControler:showTips(GameConfig.getLanguage(tips))
    end

    --是否有剧情
    local plotId = FuncGuide.getPlotId(self._groupId, self._tutorialId);

    if plotId ~= nil then 
        self:setBeforePlotUI(plotId);
    else 
        self:setGuideUI();
    end 
end

function TutorialLayer:createArrow()
    local nd = display.newNode()
    local _atype = 0

    -- atype与特效名的对应
    local trans = {
        [1] = "UI_main_img_shou_sz",-- 有光圈手指
        [2] = "UI_main_img_shou",-- 无光圈手指
        [3] = "UI_qiangzhitishi_zhuanguang",-- 矩形光圈
    }

    function nd:showArrow( atype )
        if _atype == atype then return end
        self:removeAllChildren()

        _atype = atype
        local ani = FuncArmature.createArmature(trans[_atype], nil, true)
        nd:addChild(ani)
    end

    return nd
end

function TutorialLayer:createNpcContent()
    local widget = WindowsTools:createWindow("NpcContentWidget");
    widget:setVisible(false);

    return widget;
end

function TutorialLayer:createVideoContent()
    -- local widget = WindowsTools:createWindow("GuideVideoView")
    local widget = WindowControler:createWindowNode("GuideVideoView")
    widget:setVisible(false)

    return widget
end

function TutorialLayer:initClick()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    --setTouchedFunc 中的点击事件第二针才有效 擦
    local function onTouchBegan(event)
        local uiPos = cc.p(event.x, event.y);
        self.__beginEvent = event;
        if self:isInClickArea(uiPos.x, uiPos.y) == true then 
            self._isBeginIn = true;
        else  
            -- 不在点击区域
            self._isBeginIn = false;
        end 
        return true
    end

    local function onTouchEnded(event) 
        local uiPos = cc.p(event.x, event.y);
        local isEndIn = self:isInClickArea(uiPos.x, uiPos.y)
        --不是类型 3 才执行
        local mode = FuncGuide.getMode(self._groupId, 
            self._tutorialId);
        local message = FuncGuide.getFinishMessage(self._groupId, self._tutorialId)
        if isEndIn == true and self._isBeginIn == true and mode ~= "3" and not message then
            --完成这步引导
            self:finishCurStep();
        else 
            --没有按新手引导进行
            --好像不会到这里来，shortapi 的 click 里就拦截掉了
            -- self:showWrongClickTips()
        end 
    end

    self._touchNode:setTouchedFunc(onTouchEnded, nil, false, 
        onTouchBegan,nil,false);

    self._touchNode:setTouchEnabled(true);
end

function TutorialLayer:finishCurStep()
    -- 暂停状态步骤不前进
    if self._tutorialManager:isTotorialPaused() then
        echo("_______引导正在暂停中_______")
        return 
    end
    -- 停止可能存在的动作
    self._grayLayer:stopAni()
    self:setChildUnvisible();
    self._guideLine:setVisible(false)
    
    -- 看看有没有后置Tips
    local tips = FuncGuide.getSuffixTips(self._groupId, self._tutorialId)
    if tips then
        WindowControler:showTips(GameConfig.getLanguage(tips))
    end
    --看看有没有后置剧情
    local postPlotId = FuncGuide.getSuffixPlotId(self._groupId, self._tutorialId);

    if postPlotId == nil then 
        self._tutorialManager:finishCurTutorialId();
    else 
        self:setAfterPlotUI(postPlotId)
    end 
end

function TutorialLayer:setAfterPlotUI(plotId)
    self._touchNode:setTouchEnabled(false);
    self:setVisible(false);

    PlotDialogControl:init();

    --对话结束的回调
    local onUserAction = function(ud)
        if ud.step == -1 and ud.index == -1 then
            self._tutorialManager:finishCurTutorialId();
        end
    end

    PlotDialogControl:showPlotDialog(plotId, onUserAction)
    PlotDialogControl:setSkipButtonVisbale(true);
end

function TutorialLayer:setChildUnvisible()
    -- self._grayLayer:setVisible(false);
    self._grayLayer:setOpacity(0)
    self._npcContent:setVisible(false);
    self._arrowSprite:setVisible(false);
    self._videoContent:setVisible(false)
end

function TutorialLayer:getClickkEff()
    --目前最多创建3个clickEff 循环使用
    local clickEffArr = self._clickEffArr
    local getClickkEff = function ( index )
        if not clickEffArr[index] then
            clickEffArr[index] = FuncArmature.createArmature("UI_qiangzhitishi_tishi", 
                self, false, GameVars.emptyFunc)
        end

        local ani = clickEffArr[index]
        ani:visible(true)
        ani:playWithIndex(0, false)
        ani:doByLastFrame(false, true)
        ani:setLocalZOrder(300);
        ani._showTime = curTime
        return ani
    end

    local clickIndex = self._clickIndex
    clickIndex = clickIndex%3 +1
    self._clickIndex = clickIndex

    return getClickkEff(clickIndex)
end

function TutorialLayer:showWrongClickTips()
    -- local str = GameConfig.getLanguage("guide_wrong_click_tips"); 
    -- WindowControler:showTips(str);
    if self._waitBB then return end
    
    -- 距离上次点击时间太近不予处理
    local curTime = os.clock()
    if curTime - self._lastClickTime < 0.1 then
        return
    end
    self._lastClickTime = curTime

    -- 短暂显示蒙版
    self._grayLayer:showAni()

    local clickEff = self:getClickkEff()
    local cachePos = self._tutorialManager:getCachePos()
    local pos = cachePos or self:getTargetPos();
    clickEff:setPosition(pos.x, pos.y);

    -- 错误提示文本
    local wrongTextIds = FuncGuide.getWrongTextcontentIndex(self._groupId, self._tutorialId)
    -- 正确提示文本
    local tId = FuncGuide.getTextcontentIndex(self._groupId, self._tutorialId)

    -- 都没配就不显示
    if not wrongTextIds or not tId then
        return
    end

    -- 随机一个id出来
    local wrongTextIdx = RandomControl.getOneRandomInt(#wrongTextIds + 1, 1)
    local wrongText = GameConfig.getLanguage(wrongTextIds[wrongTextIdx])
    
    local text = tId and GameConfig.getLanguage(tId) or nil
    -- 组合文本
    local fText = {}
    table.insert(fText, wrongText)
    table.insert(fText, text)
    fText = table.concat(fText, "\n")
    -- string.format("%s\n%s",wrongText,text)
    -- 显示文本
    self._npcContent:setContent(fText)
    self._npcContent:setNPC(FuncGuide.getHongKuiSkinInfo()) -- 换成红葵
    self._npcContent:setVisible(true);
end

function TutorialLayer:isInClickArea(x, y, isNeedToGL)
    -- 暂停引导状态不屏蔽点击
    if self._tutorialManager:isTotorialPaused() then
        echo("_______引导正在暂停中_______")
        return true
    end
    if self:isCanClickEverwhere() == true then 
        return true;
    end 

    local clickPosGL = {x = x - GameVars.sceneOffsetX, y = y - GameVars.sceneOffsetY};

    -- if isNeedToGL then 
    --     clickPosGL = self:convertToGL({x = x, y = y});  
    -- end 

    local configClickRect = FuncGuide.getTouchRect(self._groupId, self._tutorialId);
    local width, height = configClickRect[1], configClickRect[2];
    local cachePos = self._tutorialManager:getCachePos()
    local pos = cachePos or self:getTargetPos();

    local rect = cc.rect(pos.x - width / 2, 
        pos.y - height / 2, width, height);

    -- dump(rect,"__rect")
    -- echo(pos.x,pos.y,"___aa")

    return cc.rectContainsPoint(rect, cc.p(clickPosGL.x, clickPosGL.y));
end 

--fuck！
global_diffdiffX = 0;

function TutorialLayer:getTargetPos()
    local configClickPos = FuncGuide.getClickPos(self._groupId, self._tutorialId);

    local horizontalLayout, verticalLayout, withNotch = 
        FuncGuide.getAdaptation(self._groupId, self._tutorialId);
    local pos = self:adjustToCurPos({x = configClickPos[1] + global_diffdiffX, y = configClickPos[2]}, 
        horizontalLayout, verticalLayout, 1, 1, withNotch);

    return pos;
end

function TutorialLayer:getArrowPos()
    local arrowInfo = FuncGuide.getArrowInfo(self._groupId, self._tutorialId);

    -- 适配走同一套
    local horizontalLayout, verticalLayout, withNotch = 
        FuncGuide.getAdaptation(self._groupId, self._tutorialId);
    local pos = self:adjustToCurPos({x = arrowInfo[2] + global_diffdiffX, y = arrowInfo[3]}, 
        horizontalLayout, verticalLayout, 1, 1, withNotch);

    return pos;
end

function TutorialLayer:getNpcPos()
    local npcPos = FuncGuide.getNpcPos(self._groupId, self._tutorialId)

    if not npcPos then return nil end

    -- 适配走同一套
    local horizontalLayout, verticalLayout, scaleX, scaleY = FuncGuide.getNPCAdaptation(self._groupId, self._tutorialId)
    local pos = self:adjustToCurPos({x = npcPos[1] + global_diffdiffX, y = npcPos[2]}, 
        horizontalLayout, verticalLayout, scaleX, scaleY);

    return pos;
end

function TutorialLayer:setGuideUI()
    -------------------测试-------------------
    -- self._touchNode:delayCall(c_func(function ()
    --     -- echo("时间到暂停新手引导")
    --     -- self._tutorialManager:pauseTutorial()
    --     EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, 
    --                 {ispause = true})
    -- end), 10)

    -- self._touchNode:delayCall(c_func(function ()
    --     -- echo("时间到恢复新手引导")
    --     -- self._tutorialManager:resumeTutorial()
    --     EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, 
    --                 {ispause = false})
    -- end), 15)
    -------------------测试-------------------
    local curWinName = FuncGuide.getWinName(
        self._groupId, self._tutorialId);

    self._touchNode:setTouchEnabled(true);

    --主界面场景坐标 得到一个偏移量
    if curWinName == "HomeMainView" then
        local posX = FuncGuide.getCameraPosX(self._groupId, self._tutorialId);        
        if posX ~= nil then 
            EventControler:dispatchEvent(HomeEvent.CHANGE_CAMERA_POSX, 
                {posX = posX});
        end 
    else 
        global_diffdiffX = 0;
    end 
    -- 根据当前步骤情况确认是否需要吞噬事件
    local mode = FuncGuide.getMode(self._groupId, 
        self._tutorialId)

    -- 目前只有4需要吞噬事件
    self._touchNode:setTouchSwallowEnabled(mode == "4")

    self:setClickUI();
end

--时候是点击任意位置有效
function TutorialLayer:isCanClickEverwhere()
    local mode = FuncGuide.getMode(self._groupId, 
        self._tutorialId);
    return (mode == "1" or  mode == "3" or mode == "4") and true or false;
end

-- 显示视频
function TutorialLayer:setVideo()
    local vid = FuncGuide.getValueByKey(self._groupId, self._tutorialId, "videoId", false)
    if vid then
        self._videoContent:visible(true)
        self._videoContent:setUI(vid)
    end
end

-- 将显示手指等方法拆出来
function TutorialLayer:setArrowUI()
    --箭头文件
    local isNeedArrow = FuncGuide.isNeedArrow(self._groupId, self._tutorialId);
    echo("----isNeedArrow----", isNeedArrow, self._groupId, self._tutorialId);

    local cachePos = self._tutorialManager:getCachePos()

    --没有手指
    if isNeedArrow == true then 
        local pos = cachePos or self:getArrowPos();
        -- 历史所限，这里只能再取一次
        local arrowInfo = FuncGuide.getArrowInfo(self._groupId, self._tutorialId);
        -- 箭头类型
        local atype = arrowInfo[1]
        self._arrowSprite:showArrow(atype);
        self._arrowSprite:setPosition(pos.x, pos.y);  
        local rotate = FuncGuide.getArrowDirection(self._groupId, self._tutorialId);
        self._arrowSprite:rotation(rotate);
        self._arrowSprite:setVisible(true);
    else 
        self._arrowSprite:setVisible(false)
    end
end

-- 显示黑框
function TutorialLayer:setMask()
    local cachePos = self._tutorialManager:getCachePos()

    -- 都有黑框,点击时会出现 getMaskskin 记得删掉
    if FuncGuide.isNeedMask(self._groupId, self._tutorialId) then 
        -- --点击位置
        local configClickRect = FuncGuide.getRect(self._groupId, self._tutorialId);
        local width, height = configClickRect[1], configClickRect[2];

        local pos = cachePos or self:getTargetPos();

        self._grayLayer:setEllipseSize(cc.size(width, height));
        self._grayLayer:setEllipsePosition(cc.p(pos.x, pos.y));

        -- 有一个需求，如果是第一步就显示一个光圈
        -- if self._tutorialId == 1 then
            local clickEff = self:getClickkEff()
            clickEff:setPosition(pos.x, pos.y);
        -- end

        self:createDebugRect()
    else 
        self._grayLayer:setEllipseSize(cc.size(5, 5));
        self._grayLayer:setEllipsePosition(cc.p(500, 500));
    end

    -- self._grayLayer:setOpacity(0)
    self._grayLayer:setMaskColor(cc.c4f(0.0,0.0,0.0,0/255.0))
end

function TutorialLayer:setLine()
    --是不是要显示滑动线
    local isShowLine = FuncGuide.isHaveLine( self._groupId, self._tutorialId )
    if isShowLine then 
        self._guideLine:setVisible(true);
        --得到位置
        local pos = self:getTargetPos();
        self._guideLine:setPosition(pos.x, pos.y);
        
        --是否旋转
        self._guideLine:setLineRotation(isShowLine);
        local lineRotation = FuncGuide.getLineRotation(self._groupId, self._tutorialId)
        self._guideLine:setRotation(lineRotation)
        
        if self._arrowSprite then
            self._arrowSprite:setVisible(false)
        end
    else 
        self._guideLine:setVisible(false);
    end
end

function TutorialLayer:setClickUI()
    if self._tempR then 
        self._tempR:removeFromParent() 
        self._tempR = nil
    end
    --[[
        self:setArrowUI()
        self:setMask()
        self:setLine()
    ]]
    -- self._grayLayer:visible(false)
    --npc
    self:setNpcContentUI();
end

-- 创建调试点击区域
function TutorialLayer:createDebugRect()
    if not SHOW_CLICK_RECT then return end
    local configClickRect = FuncGuide.getTouchRect(self._groupId, self._tutorialId);
    local width, height = configClickRect[1], configClickRect[2];
    local cachePos = self._tutorialManager:getCachePos()
    local pos = cachePos or self:getTargetPos();
    local rect = cc.rect(pos.x - width / 2, pos.y - height / 2, width, height)

    local r = display.newRect(rect,{fillColor = cc.c4f(1,0,0,0.3),borderColor = cc.c4f(0,1,0,1)})

    self._tempR = r

    self:addChild(r,10000)
end

function TutorialLayer:setNpcContentUI()
    local skinInfo = FuncGuide.getNpcskin(self._groupId, 
        self._tutorialId);

    if skinInfo ~= nil then 
        self._npcContent:setVisible(true);
        self._npcContent:setNPC(skinInfo) -- 蓝葵

        local npcPos = self:getNpcPos()
        if npcPos == nil then 
            npcPos = self:getMiddlePos();
        end 
       
        self._npcContent:setPosition(npcPos);

        --显示内容
        local tid = FuncGuide.getTextcontentIndex(self._groupId, 
            self._tutorialId);
        --[[
        -- 如果有文本内容，先屏蔽点击，播完再打开
        WindowControler:setUIClickable(false)
        self._waitBB = true
        self._npcContent:playContent(GameConfig.getLanguage(tid),function()
            self:setArrowUI()
            self:setMask()
            self:setLine()
            
            WindowControler:setUIClickable(true)
            self._waitBB = false
        end)
        ]]
        -- 先去掉播文字的设定
        self._npcContent:setContent(GameConfig.getLanguage(tid))
        self:setArrowUI()
        self:setMask()
        self:setLine()
        self:setVideo()
    else
        self:setArrowUI()
        self:setMask()
        self:setLine()
        self:setVideo()
    end
end

function TutorialLayer:getMiddlePos()
    local winWidth = GameVars.width;
    local winHeight = GameVars.height;
    return {x = winWidth / 2, y = winHeight / 2};
end

function TutorialLayer:setBeforePlotUI(plotId)
    self._touchNode:setTouchEnabled(false);
    self:setVisible(false);

    PlotDialogControl:init();

    --对话结束的回调
    local onUserAction = function(ud)
        if ud.step == -1 and ud.index == -1 then
            self:setGuideUI();
            self._touchNode:setTouchEnabled(true);
            self:setVisible(true);
            --序章主城结束
            if tonumber(self._groupId) == 20001 and tonumber(self._tutorialId) == 2 then   
                WindowControler:showWindow("LoginLoadingView");
            end
        end
    end

    PlotDialogControl:showPlotDialog(plotId, onUserAction)
    PlotDialogControl:setSkipButtonVisbale(true);
end


function TutorialLayer:getTouchNode()
    return self._touchNode;
end

function TutorialLayer:convertToGL(pos)
    local glView = cc.Director:getInstance():getOpenGLView();

    local designResolutionSize = glView:getDesignResolutionSize();

    pos = cc.Director:getInstance():convertToGL(
        {x = pos.x, y = pos.y}); 

    if designResolutionSize.width > GameVars.maxScreenWidth then 
        pos.x = pos.x - (designResolutionSize.width - GameVars.maxScreenWidth) / 2;
    elseif designResolutionSize.height > GameVars.maxScreenHeight then 
        pos.y = pos.y - (designResolutionSize.height - GameVars.maxScreenHeight) / 2;
    end 

    return pos;
end

--得到坐标差
function TutorialLayer:getDifXandY()

    local diffWidth = GameVars.width - GameVars.gameResWidth;
    local difHeight = GameVars.height - GameVars.gameResHeight ;

    return diffWidth, difHeight;
end

--从960*640到当前机器的坐标
function TutorialLayer:adjustToCurPos(pos, horizontalLayout, verticalLayout, scaleX, scaleY, withNotch)
    -- echo("adjustToCurPos", horizontalLayout, verticalLayout);
    return ScreenAdapterTools.turnGuidePos(pos, horizontalLayout, verticalLayout, scaleX, scaleY, withNotch)
end

function TutorialLayer:dispose()
    FuncArmature.clearOneArmatureTexture("UI_qiangzhitishi", true);
    FuncArmature.clearOneArmatureTexture("UI_main_img_shou", true);
end


