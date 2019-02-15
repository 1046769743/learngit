--2017.2.21
--战斗中的引导

BattleTutorialLayer = class("BattleTutorialLayer", function()
    return display.newNode();
end)

local _battleTutorialLayer = nil;
local TCHVAILD = "battleTchNode"

local ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = 2,
    ["RIGHT"] = 1,
    ["UP"] = 2,
    ["DOWN"] = 1,
};

function BattleTutorialLayer.getInstance()
	if _battleTutorialLayer == nil then 
		_battleTutorialLayer = BattleTutorialLayer.new();

		WindowControler:getScene()._tutoralRoot:addChild(_battleTutorialLayer, 
			WindowControler.ZORDER_Tutorial);

		_battleTutorialLayer:setVisible(false);

		return _battleTutorialLayer;	
	end
	return _battleTutorialLayer;
end


--根据id展示引导 finishCallBack 完成后的回调
function BattleTutorialLayer:show(id, finishCallBack)
    echo("----showId---", id);
	if self._isTutoring == true then 
		echo('----上一步没有完成 id---', tostring(self._showStepId));
		return;
	end 

	self._callBack = finishCallBack;
	self._showStepId = id;
	self._isTutoring = true;
	_battleTutorialLayer:setVisible(true);
	
	self:setClickUI();
end

-- 隐藏战斗引导（不要调用，只有战斗弱引导倒计时结束可以调用）
function BattleTutorialLayer:hideBattleWeakGuide()
    if not self._isTutoring then return end

    _battleTutorialLayer:setVisible(false)
    self._isTutoring = false
end

function BattleTutorialLayer:manualFinish()
    self:finishStep();
end

function BattleTutorialLayer:isInTuroring()
	return self._isTutoring;
end


function BattleTutorialLayer:isInSetTouchClickArea(x, y, node)
    if x == nil or y == nil then 
    	return false;
    end 

	local ret = self:isInClickArea(x, y);

	if ret == false then 
        -- 因为底层去了延迟 所以这里也去掉延迟2017.11.9
        -- WindowControler:globalDelayCall(function ( ... )
        -- 只由自己的节点触发
        if node.__tchVaild == TCHVAILD then
			self:showWrongClickTips()
        end
        -- end, 0.001)
	end 

	return ret;
end

--------------=========private method==============------------------

function BattleTutorialLayer:ctor()
	GameLuaLoader:loadGameSysFuncs()
    FuncArmature.loadOneArmatureTexture("UI_qiangzhitishi", nil, true);
    FuncArmature.loadOneArmatureTexture("UI_main_img_shou", nil, true);

    self._tutorialManager = TutorialManager.getInstance();

	--正在引导中
	self._isTutoring = false;
	--点击完成后的callback
	self._callBack = nil;

	self._showStepId = nil;

    -- 错误点击时的缓冲数组（距离时间太近不予处理2017.7.10）
    self._clickEffArr = {}
    self._clickIndex = 0
    self._lastClickTime = 0

    self._waitBB = false -- 等待引导员说话

	self:initUI();
	self:initClick();
end

function BattleTutorialLayer:initUI()
    --点击区域
    self._touchNode = display.newLayer();
    self._touchNode:setContentSize(2000, 2000);

    self:addChild(self._touchNode, -1);
    self._touchNode:setTag(123);

    --黑色遮罩 统一走Manager遮罩2017.7.6
    self._grayLayer = self._tutorialManager:createGrayLayer();
    self:addChild(self._grayLayer, -1);

    --对话层
    self._npcContent = self:createNpcContent();
    self:addChild(self._npcContent, 1);

    self._arrowSprite = self:createArrow();
    self:addChild(self._arrowSprite, 200)

    -- 黑色半透的遮罩（以前是grayLayer去了加加了去），完全走配置，配了有，不配没有
    local layer = display.newColorLayer(cc.c4b(0,0,0,120))
    layer:setContentSize(cc.size(GameVars.fullWidth, GameVars.height))

    self._mask = layer
    self:addChild(self._mask, -5)

    --创建滑动方向
    local guideLine = WindowsTools:createWindow("GuideLine");
    self._guideLine = guideLine;
    self:addChild(self._guideLine, 800);

    local middlePos = self:getMiddlePos();
    guideLine:setPosition(middlePos.x, middlePos.y + 60);
end

function BattleTutorialLayer:initClick()
    local function onTouchBegan(event)
        -- echo("什么时候点击的很重要")
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

        echo("-------------------self._isBeginIn == true--", self._isBeginIn);
        echo("---begin-- xy", self.__beginEvent.x, self.__beginEvent.y);
        echo("-------------------self._isEndIn----", isEndIn);
        echo("-------------------self._showStepId----", self._showStepId);
        echo("--end-- xy", event.x, event.y);
        echo("self:isWaitForMessage(self._showStepId)", self:isWaitForMessage(self._showStepId));


        if isEndIn == true and self._isBeginIn == true and self:isWaitForMessage(self._showStepId) == false then
            --完成这步引导
            self:finishStep();
        else 
            --没有按新手引导进行
            -- self:showWrongClickTips()
        end 
    end
    self._touchNode.__tchVaild = TCHVAILD
    self._touchNode:setTouchedFunc(onTouchEnded, nil, false, 
        onTouchBegan,nil,false);

    self._touchNode:setTouchEnabled(true);
end

function BattleTutorialLayer:getMiddlePos()
    local winWidth = GameVars.width;
    local winHeight = GameVars.height;
    return {x = winWidth / 2, y = winHeight / 2};
end

function BattleTutorialLayer:setNpcContentUI()
    local skinInfo = FuncGuide.getBattleNpcskin(self._showStepId)
    local npcPos = self:getNpcPos()
    -- FuncGuide.getBattleNpcPos(self._showStepId)

    if npcPos == nil or skinInfo == nil then
        self._npcContent:setVisible(false)
        self:setArrowUI()
        self:setMask()
        self:setLine()
    else
        self._npcContent:setVisible(true)

        self._npcContent:setNPC(skinInfo) -- NPC
        self._npcContent:setPosition(npcPos);

        --显示内容
        local tid = FuncGuide.getBattleTextcontentIndex(self._showStepId);
        --[[
        -- 如果有文本内容，先屏蔽点击，播完再打开
        WindowControler:setUIClickable(false)
        self._waitBB = true
        self._npcContent:playContent(GameConfig.getLanguage(tid), function()
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
    end
    
    -- 黑色遮罩
    self:setFullMask()
end

-- 将显示手指等方法拆出来
function BattleTutorialLayer:setArrowUI()
    if FuncGuide.isBattleNeedArrow(self._showStepId) then
        local pos = self:getArrowPos()
        local arrowInfo = FuncGuide.getBattleArrowInfo(self._showStepId)
        local atype = arrowInfo[1]
        
        if self.extraPos then
            pos = self.extraPos
        end

        self._arrowSprite:showArrow(atype)
        self._arrowSprite:setPosition(pos.x, pos.y)

        self._arrowSprite:setVisible(true)
        -- 旋转角度
        local rotate = FuncGuide.getBattleArrowDirection(self._showStepId)
        self._arrowSprite:rotation(rotate)
    else
        self._arrowSprite:setVisible(false)
    end
end

-- 显示表现遮罩
function BattleTutorialLayer:setFullMask()
    self._mask:visible(FuncGuide.getBattleFullMask(self._showStepId))
end

-- 显示黑框
function BattleTutorialLayer:setMask()
    -- 黑色遮罩都用错误点击的时候渐隐显示2017.7.6
    if self:isCanClickEverwhere() == true then

    else
        --点击位置
        local configClickRect = FuncGuide.getBattleRect( self._showStepId );
        local width, height = configClickRect[1], configClickRect[2];


        local pos = self:getTargetPos();
        
        if self.extraPos then
            pos = self.extraPos
        end

        -- 这一步闪一下光圈
        if FuncGuide.isBattleRectNeedStress(self._showStepId) then
            local clickEff = self:getClickkEff()
            clickEff:setPosition(pos.x, pos.y);
        end

        self._grayLayer:setEllipseSize(cc.size(width, height));
        self._grayLayer:setEllipsePosition(cc.p(pos.x, pos.y));

        self:createDebugRect()
    end

    self._grayLayer:setMaskColor(cc.c4f(0.0,0.0,0.0,0/255.0))
end

function BattleTutorialLayer:setLine()
    --是不是要显示滑动线
    local isShowLine = FuncGuide.isBattleHaveLine( self._showStepId );
    if isShowLine then 
        self._guideLine:setVisible(true);
        
        if self.extraPos then
            pos = self.extraPos
        end

        --得到位置
        local pos = self:getTargetPos();
        self._guideLine:setPosition(pos.x, pos.y);
        
        --是否旋转
        self._guideLine:setLineRotation(isShowLine);
        local lineRotation = FuncGuide.getBattleLineRotation(self._showStepId)
        self._guideLine:setRotation(lineRotation)
        
        if self._arrowSprite then
            self._arrowSprite:setVisible(false)
        end
        
    else 
        self._guideLine:setVisible(false);
    end
end

function BattleTutorialLayer:setClickUI()
    -- 重置一下这个特殊标记
    self.extraPos = nil

    if self._tempR then
        self._tempR:removeFromParent() 
        self._tempR = nil
    end 

    --[[
        self:setArrowUI()
        self:setMask()
        self:setLine()
    ]]

    self:setNpcContentUI();
end

-- 创建调试点击区域
function BattleTutorialLayer:createDebugRect()
    if not SHOW_CLICK_RECT then return end
    local configClickRect = FuncGuide.getBattleRect( self._showStepId );
    local width, height = configClickRect[1], configClickRect[2];
    local pos = self:getTargetPos();
    local rect = cc.rect(pos.x - width / 2, pos.y - height / 2, width, height)

    local r = display.newRect(rect,{fillColor = cc.c4f(1,0,0,0.3),borderColor = cc.c4f(0,1,0,1)})

    self._tempR = r

    self:addChild(r,10000)
end

-- 按照传入的位置设置箭头位置（仅做一个特殊处理用不通用）
-- 改了 现在作为通用处理了
function BattleTutorialLayer:setExtraPos(pos)
    pos = {x = pos.x - GameVars.sceneOffsetX, y = pos.y - GameVars.sceneOffsetY}
    self.extraPos = pos

    if self._arrowSprite then
        self._arrowSprite:pos(pos.x, pos.y)
    end
    if self._grayLayer then
        self._grayLayer:setEllipsePosition(pos)
    end
end

function BattleTutorialLayer:createArrow()
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

function BattleTutorialLayer:finishStep()
    -- 暂停状态步骤不前进
    if self._tutorialManager:isTotorialPaused() then
        echo("_______引导正在暂停中_______")
        return 
    end
    
    echo("---finishStep----",self._showStepId);
    if self._showStepId then
        local uniqueId = FuncGuide.getBattleToCenterId(self._showStepId)
        if uniqueId then
            ClientActionControler:sendTutoralStepToWebCenter(uniqueId)
        end
    end
    -- self._grayLayer:setVisible(false);
    -- 停止可能存在的动作
    self._grayLayer:stopAni()
    self._arrowSprite:setVisible(false)
    self._npcContent:setVisible(false);
    self._guideLine:setVisible(false);

    _battleTutorialLayer:setVisible(false);

    self._isTutoring = false;

    if self._callBack then 
        echo("---self._callBack----");
        local func = self._callBack
        self._callBack = nil
    	func()
    end 

end

function BattleTutorialLayer:createNpcContent()
    local widget = WindowsTools:createWindow("NpcContentWidget");
    widget:setVisible(false);

    return widget;
end

function BattleTutorialLayer:isInClickArea(x, y)
    -- 暂停引导状态不屏蔽点击
    if self._tutorialManager:isTotorialPaused() then
        echo("_______引导正在暂停中_______")
        return true
    end

    if self:isCanClickEverwhere() == true then 
        echo("----self:isCanClickEverwhere() == true----");
        return true;
    end 

    local clickPosGL = {x = x  - GameVars.sceneOffsetX, y = y - GameVars.sceneOffsetY};  
    local configClickRect = FuncGuide.getBattleTouchRect( self._showStepId );
    local width, height = configClickRect[1], configClickRect[2];
    local pos = self:getTargetPos();
    if self.extraPos then
        pos = self.extraPos
    end

    local rect = cc.rect(pos.x - width / 2, 
        pos.y - height / 2, width, height);

    return cc.rectContainsPoint(rect, cc.p(clickPosGL.x, clickPosGL.y));
end 

--必须是等消息才行
function BattleTutorialLayer:isWaitForMessage(step)
    echo("FuncGuide.isWaitBattleMessage( step )",FuncGuide.isWaitBattleMessage( step ))
    return FuncGuide.isWaitBattleMessage( step );
end

--时候是点击任意位置有效
function BattleTutorialLayer:isCanClickEverwhere()
    local mode = FuncGuide.getBattleMode( self._showStepId );
    return mode == "1" or mode == "3" and true or false;
end

function BattleTutorialLayer:getTargetPos()
    -- FuncGuide.getBattleAdaptation(step)
    local pos = FuncGuide.getBattleClickPos( self._showStepId );

    local horizontalLayout, verticalLayout, scaleX, scaleY = 
        FuncGuide.getBattleAdaptation(self._showStepId);
    
    if horizontalLayout then -- 有返回值则认为按UI适配
        pos = self:adjustToCurPos({x = pos.x, y = pos.y}, 
            horizontalLayout, verticalLayout, scaleX, scaleY)
        -- echo("转换了",pos.x,pos.y)
    else -- 没有走以前的方法
        local x,y = self:turnBattlePos( pos.x,pos.y )
        pos = {x=x,y=y}
        -- echo("没有转换了",pos.x,pos.y)
    end

	return pos
end

function BattleTutorialLayer:getArrowPos()
    local arrowInfo = FuncGuide.getBattleArrowInfo(self._showStepId);

    -- 适配走同一套
    -- local x,y = self:turnBattlePos(arrowInfo[2],arrowInfo[3])
    -- pos = {x=x,y=y}

    local horizontalLayout, verticalLayout, scaleX, scaleY = 
        FuncGuide.getBattleAdaptation(self._showStepId);
    
    if horizontalLayout then -- 有返回值则认为按UI适配
        pos = self:adjustToCurPos({x = arrowInfo[2], y = arrowInfo[3]}, 
            horizontalLayout, verticalLayout, scaleX, scaleY)
        echo("转换了",pos.x,pos.y)
    else -- 没有走以前的方法
        local x,y = self:turnBattlePos( arrowInfo[2],arrowInfo[3] )
        pos = {x=x,y=y}
        echo("没有转换了",pos.x,pos.y)
    end

    return pos;
end

function BattleTutorialLayer:getNpcPos()
    local npcPos = FuncGuide.getBattleNpcPos(self._showStepId)

    if not npcPos then return nil end

    -- 适配走同一套
    local horizontalLayout, verticalLayout, scaleX, scaleY = 0,0,1,1
    local pos = self:adjustToCurPos({x = npcPos[1] + global_diffdiffX, y = npcPos[2]}, 
        horizontalLayout, verticalLayout, scaleX, scaleY);

    return pos;
end

function BattleTutorialLayer:getClickkEff()
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
        return ani
    end

    local clickIndex = self._clickIndex
    clickIndex = clickIndex%3 +1
    self._clickIndex = clickIndex

    return getClickkEff(clickIndex)
end

function BattleTutorialLayer:showWrongClickTips()
    if self._waitBB then return end

    -- 距离上次点击时间太近不予处理
    local curTime = os.clock()
    if curTime - self._lastClickTime < 0.1 then
        return
    end
    self._lastClickTime = curTime

    --没有按新手引导进行
    -- if self:isWaitForMessage(self._showStepId) == true then 
    --     return;
    -- end

    -- 播放黑色蒙版渐隐效果
    self._grayLayer:showAni()

    local clickEff = self:getClickkEff(clickIndex)
    local pos = self:getTargetPos();
    if self.extraPos then
        pos = self.extraPos
    end
    clickEff:setPosition(pos.x, pos.y);

    -- 错误提示文本
    local wrongTextIds = FuncGuide.getBattleWrongTextcontentIndex(self._showStepId)
    -- 正确提示文本
    local tId = FuncGuide.getBattleTextcontentIndex(self._showStepId)

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

function BattleTutorialLayer:adjustToCurPos(pos, horizontalLayout, verticalLayout, scaleX, scaleY)
    return ScreenAdapterTools.turnGuidePos(pos, horizontalLayout, verticalLayout, scaleX, scaleY)
end

function BattleTutorialLayer:getDifXandY()
    local diffWidth = GameVars.width - GameVars.gameResWidth
    local difHeight = GameVars.height - GameVars.gameResHeight

    return diffWidth, difHeight
end

--转换战斗坐标
function BattleTutorialLayer:turnBattlePos(x, y)
    return x + GameVars.UIOffsetX,y
end
--[[
--转换战斗坐标,way方向 1 表示我方 -1表示敌方
function BattleTutorialLayer:turnBattlePos( x,y ,way)
    --如果宽度是小于1024的 那么直接偏移
    way = way or 1
    --先还原成标准坐标
    local turnGameScale = GameVars.gameResWidth/GameVars.maxScreenWidth
    local widOff = math.round(GameVars.maxScreenWidth-GameVars.gameResWidth)/2
    local heiOff = math.round(GameVars.gameResHeight* (1-turnGameScale) )
    local oldX = x
    local oldY = y
    x = x - widOff * way
    -- y = y + heiOff 

    x = x / turnGameScale
    y = y / turnGameScale

    --在转化成游戏相对坐标
    if GameVars.width < GameVars.maxScreenWidth then
        turnGameScale = GameVars.width / GameVars.maxScreenWidth
        widOff = math.round(GameVars.maxScreenWidth - GameVars.width) /2
        heiOff = math.round(GameVars.height* (1-turnGameScale))
    else
        turnGameScale = 1
        widOff = 0
        heiOff = 0
    end
    x = x * turnGameScale + GameVars.UIOffsetX  +  widOff * way
    y = y * turnGameScale

    -- echo("x:%s y:%s turnGameScale:%s GameVars.UIOffsetX:%s widOff:%s way:%s", x, y, turnGameScale, GameVars.UIOffsetX, widOff, way)

    return x,y
end
]]


