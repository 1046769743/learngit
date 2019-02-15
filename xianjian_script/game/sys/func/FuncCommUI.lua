--
-- User: zhangyanguang
-- Date: 2015/5/22
-- 公用UI设置

FuncCommUI = FuncCommUI or {}



FuncCommUI.LogsView = nil
FuncCommUI.GMEnterView = nil
FuncCommUI.SceneTestView = nil
FuncCommUI.BattleInfoView = nil

if  DEBUG_SERVICES then
    return
end
FuncCommUI.COLORS = {
	TEXT_RED = cc.c3b(255,39,0),
	TEXT_WHITE = cc.c3b(255,255,255),
}


FuncCommUI.VideoPlayerEvent = {
    PLAYING = 0,
    PAUSED = 1,
    STOPPED= 2,
    COMPLETED =3,
    SKIP =4,
}

FuncCommUI.EFFEC_TTITLE = {
    ["UPGRADE"] = 1,   ---升级
    ["ADVANCED"] = 2,   --进阶
    ["HOISTING"] = 3,   --提升
    ["NOTESPRIT"] = 4,  --注灵
    ["CREAT"] = 5,      --创建
    ["GONGXIHUODE"] = 6,--恭喜获得
    ["UPSTAE"] = 7,     --升星
    ["UPQUILITY"] = 8,     --品质提升
    ["UPSEGMENT"] = 10,    -- 段位晋升
    ["AWAKEN"] = 11, -- 装备觉醒
    ["ACTIVATION"] = 12, -- 装备觉醒
}

FuncCommUI.EFFEC_NUM_TTITLE = {
    ["ACTIVATION"] = 1,   ---激活
    ["HOISTING"] = 2,   --提升
    ["ADVANCED"] = 3,   --进阶
    ["UPGRADE"] = 4,   ---升级
    ["RESONANCE"] = 5,  --共鸣
    ["STRENDTHENING"] = 6,      --强化
    ["SCIENCE"] = 7,      --修改
    ["EATING"] = 8,      --食用

}

--主城按钮特效名字
FuncCommUI.BUTTON_EFFECT_NAME = {
    ["NEWSHOP"] = 2,   ---新商品
    ["HOISTING"] = 1,   --提升
}

--scale9缩放规则,alignType 对齐方式,withScaleX x方向缩放拉长系数,会在左右2边均匀加长
--withScaleX x方向缩放拉长系数,会在上下均匀加长 
--withScaleX 是一个比例值 
--如果传空或者0表示不缩放 传其他表示按照 withScaleX*( GameVars.width  - GameVars.gameResWidth )宽度缩放
--withScaleY也是同理  
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
--[[
    示例 机型是 1136*768
    FuncCommUI.setScale9Align(widthScreenOffset, scale9Sprite,UIAlignTypes.MiddleTop,1,0 )
    表示让 scale9Sprite 居中朝上对其,x方向 会让这个scale9左右各自加长 (1136-960) *withscaleX /2的宽度 
    scroll的适配同样如此
]]
function FuncCommUI.setScale9Align( widthScreenOffset,view,alignType,withScaleX,withScaleY ,moveScale)
    return ScreenAdapterTools.setScale9Align( widthScreenOffset,view,alignType,withScaleX,withScaleY ,moveScale)

end

--参数格式 和 setScale9Align 一样
-- fillNotouch 是否填充刘海区域,默认不填充
function FuncCommUI.setScrollAlign(widthScreenOffset, scroll,alignType,withScaleX,withScaleY ,moveScale,fillNotouch)
    return ScreenAdapterTools.setScrollAlign(widthScreenOffset, scroll,alignType,withScaleX,withScaleY ,moveScale,fillNotouch)
end


--设置view对其
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
-- widthScreenOffset  每个系统调用这个方法时 必须传递 对应ui的 widthScreenOffset 参数
--  withNotch 0表示不偏移刘海区域, 默认为0,  1表示向右深入刘海区域, -1表示向左深入刘海区 ,这个针对新手引导适配场景的点击区域, 特殊组件也可以使用
function FuncCommUI.setViewAlign(widthScreenOffset,view,alignType,moveScaleX , moveScaleY,withNotch)
    return ScreenAdapterTools.setViewAlign(widthScreenOffset,view,alignType,moveScaleX , moveScaleY,withNotch)
end

--适配一个背景sprite scaleType 0或者空 表示等比缩放适配 1表示只缩放x 2表示只缩放y 3表示不缩放
--注意 bg 一定要放在ui里面才有效
function FuncCommUI.setBgScaleAlign( bgSprite,scaleType )
    return ScreenAdapterTools.setBgScaleAlign( bgSprite,scaleType )
end

-- 清除一个view的适配
function FuncCommUI.clearAdapterView( view )
    ScreenAdapterTools.clearAdapterView(view)
end

-- 滚动文本框中的数字
--[[
    frame 持续帧数
    bits,  精确到的位数  默认是 个位 也就是0 
    callBack 回调
]]
function FuncCommUI.tweenTxtNum(txt,beginNum,endNum,frame, bits, callBack)
    if endNum == beginNum then
        if callBack then
            callBack()
        end
        return
    end
    frame = frame or 10

    bits = bits or 0

    local perNum = ( (endNum - beginNum) / frame )
    local p = math.pow(10,bits)
    perNum = math.ceil( perNum/p ) * p

    if perNum ==0 then
        return
    end
    --先移除事件  因为有可能重复注册
    txt:unscheduleUpdate()
    local bNum = beginNum
    local count = 1;
    local listener = function (dt)
        count = count + 1
        bNum = bNum +  perNum
        txt:setString(tostring(bNum) )

        frame = frame -1
        if frame == 0 then
            txt:setString(tostring(endNum))
            txt:unscheduleUpdate()
            if callBack then
                callBack()
            end

        elseif  (endNum - bNum) / perNum < 1 then
            txt:setString(tostring(endNum))
            txt:unscheduleUpdate()
            if callBack then
                callBack()
            end

        end

    end
    txt:scheduleUpdateWithPriorityLua(listener, 0) 
end

-- 获得遮罩层
function FuncCommUI.getMaskCan(maskSprite, contentNode,...)
	local clipper = cc.ClippingNode:create()
    clipper:setCascadeOpacityEnabled(true)
    clipper:setOpacityModifyRGB(true)
	clipper:setStencil(maskSprite)
    clipper:setInverted(false)
    clipper:setAlphaThreshold(0.01)
    contentNode:parent(clipper)
    local args = {...}
    if args and #args >0 then
        for i,v in ipairs(args) do
            v:parent(clipper)
        end
    end

    return clipper
end

-- 获得遮罩层   通过传参控制是显示遮罩内还是遮罩外内容 isInvert=true显示外 
function FuncCommUI.getMaskCanByInvert(maskSprite, contentNode, isInvert, ...)
    local clipper = cc.ClippingNode:create()
    clipper:setCascadeOpacityEnabled(true)
    clipper:setOpacityModifyRGB(true)
    clipper:setStencil(maskSprite)
    clipper:setInverted(isInvert)
    clipper:setAlphaThreshold(0.01)
    contentNode:parent(clipper)
    local args = {...}
    if args and #args >0 then
        for i,v in ipairs(args) do
            v:parent(clipper)
        end
    end

    return clipper
end


-- 加入LogsView
function FuncCommUI.addLogsView()
    if FuncCommUI.LogsView then
        return
    end
    local logsView = WindowControler:createWindowNode("LogsView")
    FuncCommUI.LogsView = logsView
    logsView:zorder(99999)
    logsView:setName("LogsView")
    logsView:setPosition(10, GameVars.height - 150);

    local scene = display.getRunningScene()
    scene._highRoot:addChild(logsView)
end

function FuncCommUI.addGmEnterView()
    if FuncCommUI.GMEnterView then
        return
    end

    local GMEnterView = WindowControler:createWindowNode("GMEnterView")
    GMEnterView:zorder(99999)
    GMEnterView:setName("GMEnterView")
    FuncCommUI.GMEnterView = GMEnterView
    GMEnterView:setPosition(10, GameVars.height);

    local scene = display.getRunningScene()
    scene._highRoot:addChild(GMEnterView)

end
function FuncCommUI.addBattleInfoView()
    if not BattleControler:isInBattle() then
        echo("不在战斗中,不能查看角色属性")
        return
    end
    if FuncCommUI.BattleInfoView then
        FuncCommUI.BattleInfoView:updateUI()
        return
    end

    local view = WindowControler:createWindowNode("BattleDebugAttrView")
    view:zorder(99999)
    view:setName("BattleDebugAttrView")

    local scene = display.getRunningScene()
    scene._topRoot:addChild(view)

    FuncCommUI.BattleInfoView = view
end
function FuncCommUI.addSceneTest(  )
    -- if  DEBUG_ENTER_SCENE_TEST then
    if FuncCommUI.SceneTestView then
        return
    end
    local scene = display.getRunningScene()
    scene:addSceneTest()
end

-- 移除LogsView
function FuncCommUI.removeLogsView()
    local scene = display.getRunningScene()
    scene._root:removeChildByName("LogsView", true)
end




local _inputView

--开始输入     传入一个回调  callBack("haha",1) 2个参数 输入结果 和方式 1是确定 0是取消
function FuncCommUI.startInput(curstr, callBack,inputParams )
    if not _inputView then
        _inputView = WindowControler:createWindowNode("InputView")
        _inputView:visible(false)
        local scene = WindowControler:getCurrScene()
        _inputView:addto(scene._topRoot,WindowControler.ZORDER_INPUT)
    end
    _inputView:startInput(curstr,callBack,inputParams)

end

--全屏奖励界面5个以下  --
function FuncCommUI.startFullScreenRewardView(itemArray, callBack)
    if itemArray ~= nil then
        WindowControler:showWindow("RewardSmallBgView", itemArray, callBack);
    else
        dump(itemArray,"奖励返回数据")
    end
end 

--缓存的奖励数组
local cacheRewardArr = {}
--当前是否在运动中
local isMoving = false

local MOVE_TIP_TYPE = {
    TYPE_RES_REWARD = 1,
    TYPE_FIGHT_ATTR = 2
}
FuncCommUI.offsetX=GameVars.cx
FuncCommUI.offsetY=GameVars.height - 340
FuncCommUI.TipHeight=60;--//弹出奖励UI的高度
FuncCommUI.FixedSpeedY=60;--//纵向飘动的速度
FuncCommUI.scheduleController=nil;--//回调函数控制器,需要手工进行销毁
FuncCommUI.TipSequence={} --//弹出提示队列
FuncCommUI.TimeInterval={[1]=0.24,[2]=0.04,[3]=0.24,[4]=1.5,[5]=0.25};
--//弹出记录的状态
local    RewardTipState={
    TipState_Born=0,--//刚产生
    TipState_FadeIn=1,--//透明度开始变化,淡入
    TipState_Delay1=2,--//第一次停留
    TipState_Move=3,--//开始移动
    TipState_Delay2=4,--//第二次停留
    TipState_FadeOut=5,--//开始淡出
}
--弹出奖励UI队列
local  scheduler = Tool:configRequire("framework.scheduler")
--弹出奖励道具数组   奖励格式 [ "1,101,1", "3,100",    ] 直接传递配置表的格式 或者服务器回来的格式 
--通用奖励格式
function FuncCommUI.startRewardView( rewardArr,rewardType,isSpiritStones)
    local tipType = rewardType or MOVE_TIP_TYPE.TYPE_RES_REWARD
    if not rewardArr then
        echoError("没有传奖励数组进来")
        return
    end
    for i,v in ipairs(rewardArr) do
        local tipData = {}
        tipData.data = v
        tipData.tipType = tipType
        --将需要奖励的 道具 缓存起来
        table.insert(cacheRewardArr, tipData)
    end

--    if isMoving then
--        return 
--    end
    FuncCommUI.resumeMove(isSpiritStones)
    AudioModel:playSound(MusicConfig.s_com_reward);
    
    
end


--复原
function FuncCommUI.resumeMove(isSpiritStones)
--    isMoving =false
    while(#cacheRewardArr>0)do
        local tipData = cacheRewardArr[1].data
        local tipType = cacheRewardArr[1].tipType
--        FuncCommUI.startMoving(tipData,tipType)
        FuncCommUI.insertTipMessage(tipData,tipType,isSpiritStones);
        table.remove(cacheRewardArr,1)
    end

end

-- 根据tip类型，创建对应的view
function FuncCommUI.createMoveTipView(tipType,isSpiritStones)
    local tipView = nil
    if tipType == nil or tipType == MOVE_TIP_TYPE.TYPE_RES_REWARD then
        tipView = WindowsTools:createWindow("TipItemView",isSpiritStones)
    elseif tipType == MOVE_TIP_TYPE.TYPE_FIGHT_ATTR then
        tipView = WindowsTools:createWindow("TipFightAttrView")
    end

    return tipView
end
-- //获取基本类型时弹出式页面
function FuncCommUI.showTipMessage(_resType, _resCount)
    FuncCommUI.startRewardView({_resType ..",".._resCount} )
end
--//将给定的数据转换成弹出提示框,并初始化相关的数据结构
function FuncCommUI.insertTipMessage(tipData,tipType,isSpiritStones)
    local scene = WindowControler:getScene()
    local scale=scene:getScale()
    local ui = FuncCommUI.createMoveTipView(tipType,isSpiritStones)
    ui:pos(FuncCommUI.offsetX,FuncCommUI.offsetY):addto(scene,9999)
    ui:setRewardInfo(tipData)
--//初始隐藏
    ui:setCascadeColorEnabled(true);
    ui:setOpacity(0);
    ui.tipState=RewardTipState.TipState_FadeIn;
    ui.delayTime=0;--//提示框处于该状态已经持续的时间
    ui.originY=ui:getPositionY();
--//插入到调度队列中
    table.insert(FuncCommUI.TipSequence,ui)
--//开始调度
    if(not FuncCommUI.scheduleController)then
        FuncCommUI.scheduleController=scheduler.scheduleGlobal(FuncCommUI.startMoving,0);
    end
end
---//调度队列
function FuncCommUI.startMoving(_deltaTime)
--//队列为空,就停止调度器
    if(#FuncCommUI.TipSequence<=0)then
        scheduler.unscheduleGlobal(FuncCommUI.scheduleController);
        FuncCommUI.scheduleController=nil;
        return;
    end
    --//从下一个UI开始,依次向下遍历,所有的UI位置由上一个决定
    local  last_ui=nil;
    local  select_index=0;--//从select_index开始依次向上遍历,高度增加
    local _index=1;
    --    echo("delta time:",_deltaTime);
    while(_index<=#FuncCommUI.TipSequence) do
        local  ui=FuncCommUI.TipSequence[_index];
        if(last_ui~=nil and last_ui:getPositionY()-ui:getPositionY()<FuncCommUI.FixedSpeedY and ui.tipState==RewardTipState.TipState_FadeIn)then--//此时以下的UI是不能调度的
            break;
        end
        if(ui.tipState==RewardTipState.TipState_FadeIn)then
            ui.delayTime=ui.delayTime+_deltaTime;
            rate=_deltaTime/FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn];
            local  opacity=64+191*rate;
            select_index=_index;
            if( ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn])then
                ui:setOpacity(255);
                ui.tipState=RewardTipState.TipState_Move;
                ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_FadeIn];
                ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
            else
                ui:setOpacity(opacity);
                ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
            end
        elseif(ui.tipState==RewardTipState.TipState_Move)then
            ui.delayTime=ui.delayTime+_deltaTime;
            rate=_deltaTime/FuncCommUI.TimeInterval[RewardTipState.TipState_Move];
            select_index=_index;
            if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_Move])then
                ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_Move];
                ui.tipState=RewardTipState.TipState_Delay2;--//进入第二阶段延迟
                ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
            else
                ui:setPositionY(ui:getPositionY()+FuncCommUI.FixedSpeedY*rate);
            end
        elseif(ui.tipState==RewardTipState.TipState_Delay2)then--//第二阶段延迟
            ui.delayTime=ui.delayTime+_deltaTime;
            if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_Delay2])then
                ui.delayTime=ui.delayTime-FuncCommUI.TimeInterval[RewardTipState.TipState_Delay2];
                ui.tipState=RewardTipState.TipState_FadeOut;
           end
        elseif(ui.tipState==RewardTipState.TipState_FadeOut)then
            ui.delayTime=ui.delayTime+_deltaTime;
            rate=ui.delayTime/FuncCommUI.TimeInterval[RewardTipState.TipState_FadeOut];
            if(ui.delayTime>=FuncCommUI.TimeInterval[RewardTipState.TipState_FadeOut])then--//如果超过了事件限制,删除掉这个UI
                table.remove(FuncCommUI.TipSequence,1);
                local  nextState=0;
                local  nextTime=0
                if(1<=#FuncCommUI.TipSequence)then
                    nextState=FuncCommUI.TipSequence[1].tipState;
                    nextTime=FuncCommUI.TipSequence[1].delayTime
                end
                ui:deleteMe();
                ui=nil;
                _index=_index-1;--//此种情况在整个函数运行期间至多出现一次
                if(select_index>0)then
                    select_index=select_index-1;
                end
            else
                ui:setOpacity(255*(1.0-rate));
            end
        end
        _index=_index+1;
        last_ui=ui;
    end
    --//自底向上遍历
    if(select_index>0)then
        local  from_index=select_index-1;
        local  lastPositionY=FuncCommUI.TipSequence[select_index]:getPositionY();
        for _index2=from_index, 1,-1 do
            local ui=FuncCommUI.TipSequence[_index2];
            local  nowPositionY=ui:getPositionY();
            if(nowPositionY-lastPositionY<FuncCommUI.TipHeight)then--//如果两个UI之间小于UI的高度,此时已经产生了挤压,需要调整距离
                  local offsetY=FuncCommUI.TipHeight-nowPositionY+lastPositionY;
                  ui:setPositionY(nowPositionY+offsetY);
            end
            lastPositionY=ui:getPositionY();
        end
    end
end

-- 展示tip View
function FuncCommUI.regesitShowTipView(followView,tipViewName,params,playSound)
    local currentUi= nil
    local overFunc = function (  )
    end

    local movedFunc = function (  )
    end

    local beginFunc = function (  )
        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end

            if playSound and AudioModel:isSoundOn() then
                AudioModel:playSound("s_com_click2")
            end
        end

        local scene = WindowControler:getCurrScene()
        currentUi = WindowsTools:createWindow(tipViewName,params):addto(scene,100):pos(GameVars.UIOffsetX,
            GameVars.height)
        currentUi:registClickClose(nil,nil,true,true)
        currentUi:startShow(followView)
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,false,nil,nil)
end

-- params结构
--[[
    skillId = skillId
    level = level
--]]
function FuncCommUI.regesitShowSkillTipView(followView,params,playSound)
     FuncCommUI.regesitShowTipView(followView,"PartnerSkillDetailView",params,playSound)
end
function FuncCommUI.regesitShowTreasureSkillTipView(followView,params,playSound)
     FuncCommUI.regesitShowTipView(followView,"TreasureSkillTips",params,playSound)
end
function FuncCommUI.regesitShowCharSkillTipView(followView,params,playSound)
     FuncCommUI.regesitShowTipView(followView,"PartnerCharSkillDetailView",params,playSound)
end

function FuncCommUI.regesitShowCrosspeakBoxTipView(followView, boxData)
    FuncCommUI.regesitShowTipView(followView,"CrosspeakBoxInfoView",boxData,false)
end

function FuncCommUI.regesitShowBuyCoinTipView(followView,params,playSound)
    FuncCommUI.regesitShowTipView(followView,"CompBuyCoinTips",params,playSound)
end

function FuncCommUI.regesitShowEquipTipView( followView,params,playSound )
    FuncCommUI.regesitShowTipView(followView,"LineUpEquipTipsView",params,playSound)
end

function FuncCommUI.regesitShowTreasureTipView(followView,str,playSound)
    FuncCommUI.regesitShowTipView(followView,"TreasureNewTips",str,playSound)
end
-- params结构
--[[
    _partnerId = _partnerId
    _type = _type 
--]]
function FuncCommUI.regesitShowPartnerTipView(followView,params,playSound)
    FuncCommUI.regesitShowTipView(followView,"PartnerTips",params,playSound)
end
-- params结构
--[[
    _value = _value
    _type = _type 
--]]
function FuncCommUI.regesitShowPartnerStarTipView(followView,params,playSound)
    FuncCommUI.regesitShowTipView(followView,"PartnerStarTips",params,playSound)
end

--通用资源tip详细信息显示框 注册资源显示信息
--followView  传递过来进行坐标参照的view,  
--如果followView 是scroll滚动条 里面的一个 子节点, 那么这个 followView 必须有一个checkCanClick方法
-- isSound 这个只用在邮件 试炼里 表示是图标的音效
-- hideTipNum 隐藏tips上的个数
function FuncCommUI.regesitShowResView( followView, resType,resNums,resId , reward ,isSound ,hideTipNum,isArtifact)
    local currentUi= nil
    

    local overFunc = function (  )
    end
    
    local movedFunc = function (  )

    end

    local beginFunc = function (  )

        if resType == FuncDataResource.RES_TYPE.PARTNER then
            local params = {id = resId}
            WindowControler:showWindow("PartnerCompInfoView", params,{},false)
            return
        end

        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end
        end
        if isSound and AudioModel:isSoundOn() then
             AudioModel:playSound("s_com_click2")
        end
        local scene = WindowControler:getCurrScene()
        if not isArtifact then
            currentUi = WindowsTools:createWindow("TipItemView2"):addto(scene,100):pos(GameVars.UIOffsetX,GameVars.height  - GameVars.UIOffsetY)
            currentUi:setResInfo(resType,resNums,resId ,reward ,hideTipNum )
        else
            currentUi = WindowsTools:createWindow("ArtifactDesTips"):addto(scene,100):pos(GameVars.UIOffsetX- 150,GameVars.height  - GameVars.UIOffsetY)
            currentUi:setResInfo(ArtifactModel:getselectArID())
        end
        currentUi:registClickClose(nil,nil,true,true)
        currentUi:startShow(followView)
        if currentUi.UI_2 and currentUi.UI_2.panelInfo ~= nil then
            if currentUi.UI_2.panelInfo.mc_dou ~= nil then
                currentUi.UI_2.panelInfo.mc_dou:setVisible(false)
            end
        end
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,true,nil,nil)
end

--datatable = {systemname = ,npc = ,offset = {x= ,y = }}
--显示气泡
function FuncCommUI.regesitShowBubbleView(datatable,followView,index)

    local systemname = datatable.systemname
    local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(systemname)
    if not isopen then
        return 
    end
    --新手引导，和新系统开启
    if TutorialManager.getInstance():isHomeExistGuide() then
        return
    end
    local view = WindowControler:getWindow( "PlotDialogView" ) 
    if view then
        return 
    end
    local ctn =  followView
    if ctn ~= nil then
        if ctn.getUpPanel ~= nil then
            if ctn:getUpPanel().ctn_1 then
                ctn = ctn:getUpPanel().ctn_1
                ctn:removeAllChildren()
                HomeModel.airBubbleArr[systemname] = nil
            end
        end
    else
        return
    end

    local _node = display.newNode()
    ctn:addChild(_node,100)
    _node:setScale(0)
    local currentUi = WindowsTools:createWindow("CompAirBubblesView")
    currentUi:addto(_node,100)
    local isopen,_pos,pamses =  currentUi:dataIsNil(datatable)
    local datainfor = currentUi.datainfor
    index = index or 1
    if datainfor ~= nil then
        if datainfor.priorSystem ~= index then
            -- isopen = false
        end
    end
    

    if isopen then
        if HomeModel.airBubbleArr[systemname] == nil then
            HomeModel.airBubbleArr[systemname] = {alldata = {systemname = systemname,npc = datatable.npc},followView = followView,uiview = currentUi}  
        end
    
        local postable = {}
        if datatable.offset ~= nil then
            _node:setPosition(cc.p( datatable.offset.x, datatable.offset.y))
        else
            _node:setPosition(cc.p( _pos.node_x,_pos.node_y))
        end
        currentUi:setPosition(cc.p( _pos.x,_pos.y))
        if not pamses then
            currentUi:initData()
        end

        local time_1,time_2,time_3 = currentUi:getIntervalTime()
        local scaleto_1 = act.scaleto(0.1,1.2,1.2)
        local scaleto_2 = act.scaleto(0.05,1.0,1.0)
        local delaytime_1 = act.delaytime(time_1)
        local delaytime_1_1 = act.delaytime(1.0)
        local delaytime_1_2 = act.delaytime(0.2)
        local delaytime_2 = act.delaytime(time_2)
        local scaleto_3 = act.scaleto(0.2,0)
        -- local delaytime_3 = act.delaytime(time_3)
        local func = act.callfunc(function ()
            local function cellBack(intervalTime)
                if not currentUi.isRunaction then
                    _node:setOpacity(0)
                    HomeModel:showAirBubbleUI()
                    local back_1 = act.callfunc(function ()
                        _node:setOpacity(0)
                        -- HomeModel:showAirBubbleUI()
                    end)
                    local back_2 = act.callfunc(function ()
                        _node:setOpacity(255)
                    --     -- FuncCommUI.runcationFun(currentUi,_node)
                    end)
                    -- if intervalTime ~= nil then
                    --     local timeArr  = string.split(intervalTime, ",")
                    --     local delaytime_4 = act.delaytime(timeArr[1])
                    --     local delaytime_5= act.delaytime(timeArr[2])
                    --     currentUi.isRunaction = true
                    --     currentUi:runAction(act._repeat(act.sequence(delaytime_4,back_1,delaytime_5,back_2)))
                    -- end

                    currentUi.isRunaction = true
                    local delaytime_3_1 = act.delaytime(time_1 + 1.0)
                    local delaytime_2_1 = act.delaytime(time_2)
                    currentUi:runAction(act._repeat(act.sequence(delaytime_3_1,back_1,delaytime_2_1,back_2)))
                end
            end
            currentUi:setcellString(cellBack)
        end)
        local seqAct = act.sequence(func,scaleto_1,scaleto_2,delaytime_1,scaleto_3,delaytime_1_1)
        if _node ~= nil then
            _node:runAction(act._repeat(seqAct))
        end
    end
end
function FuncCommUI.runcationFun(currentUi,_node)
    local time_1,time_2,time_3 = currentUi:getIntervalTime()
    local scaleto_1 = act.scaleto(0.1,1.2,1.2)
    local scaleto_2 = act.scaleto(0.05,1.0,1.0)
    local delaytime_2 = act.delaytime(time_2)
    local scaleto_3 = act.scaleto(0.2,0)
    local delaytime_3 = act.delaytime(time_3)
    local func = act.callfunc(function ()
        local function cellBack(intervalTime)
            currentUi:setVisible(false)
            local back_1 = act.callfunc(function ()
                currentUi:setVisible(false)
                HomeModel:showAirBubbleUI()
            end)
            local back_2 = act.callfunc(function ()
                currentUi:setVisible(true)
                FuncCommUI.runcationFun(currentUi,_node)
            end)
            if intervalTime ~= nil then
                local timeArr  = string.split(intervalTime, ",")
                local delaytime_4 = act.delaytime(timeArr[1])
                local delaytime_5= act.delaytime(timeArr[2])
                currentUi:runAction(act.sequence(delaytime_4,back_1,delaytime_5,back_2))
            end
        end
        currentUi:setcellString(cellBack)
    end)
    local seqAct = act.sequence(func,scaleto_1,scaleto_2,delaytime_2,scaleto_3,delaytime_3)
    if _node ~= nil then
        _node:runAction(act._repeat(seqAct))
    end
end

--六界气泡   竞技场仙术设置也用了这个气泡
function FuncCommUI.regesitWorldBubbleView(datatable,followView, isPvp) 
    local ctn = followView
    local _node = display.newNode()
    ctn:addChild(_node,100)
    _node:setScale(0)
    _node:pos(0, -22)
    if isPvp then
        _node:pos(10, -40)
    end

    local currentUi = WindowsTools:createWindow("WorldQiPaoView", datatable, isPvp)
    -- local an = followView:getContainerBox()
    currentUi:addto(_node,100)
    local offset_x, offset_y = currentUi:getOffset()
    currentUi:setPosition(cc.p(offset_x, offset_y + 22))
    local time_1,time_2,time_3 = currentUi:getIntervalTime()
    -- WindowControler:globalDelayCall(function ()
    local scaleto_1 = act.scaleto(0.4,1.2,1.2)
    local scaleto_2 = act.scaleto(0.1,1.0,1.0)
    local delaytime_2 = act.delaytime(2.0)
    local scaleto_3 = act.scaleto(0.2,0)
    local delaytime_3 = act.delaytime(time_3)
    local seqAct = act.sequence(scaleto_1,scaleto_2,delaytime_2,scaleto_3,delaytime_3)
    if _node ~= nil then
        -- if isPvp then
            _node:runAction(act._repeat(seqAct))
        -- else
        --     _node:runAction(seqAct)
        -- end
        
    end
    return currentUi
    -- end,time_1)
end
--成就奖励
function FuncCommUI.regesitShowRecordView( followView, questId, isSound, callwithFunc)
    local currentUi= nil
    local overFunc = function (  )
    end
    
    local movedFunc = function (  )

    end

    local beginFunc = function (  )
        if followView.checkCanClick then
            if not followView:checkCanClick() then
                return  false
            end
        end
        if isSound and AudioModel:isSoundOn() then
             AudioModel:playSound("s_com_click2")
        end

        if callwithFunc then 
            callwithFunc();
        end 
        local scene = WindowControler:getCurrScene()
        currentUi = WindowsTools:createWindow("TipItemView6"):addto(scene,100):pos(GameVars.UIOffsetX,GameVars.height  - GameVars.UIOffsetY)
        currentUi:setUI(questId)
        currentUi:registClickClose(nil,nil,true,true)
        currentUi:startShow(followView)
        return true
    end

    followView:setTouchedFunc(beginFunc,nil,false,nil,nil)
end

--弹出成就ui
function FuncCommUI.ShowRecordTips(questId)
    local isRecord = FuncQuest.readMainlineQuest(questId, "record", false)
    if isRecord == nil then 
        return;
    end 

    local CompRecordView = WindowControler:createWindowNode("CompRecordView")
    CompRecordView:setUI(questId);
    CompRecordView:zorder(99999)

    CompRecordView:setPosition(GameVars.width - 450, 570);

    local scene = display.getRunningScene()
    scene._topRoot:addChild(CompRecordView)

    WindowControler:globalDelayCall(function()
        CompRecordView:removeFromParent();
    end, 3)
end

--[[
    通用恭喜获得，每个奖品播放的动画效果
]]
function FuncCommUI.playCommonRewardAnim(view,itemViewArr,offsetX,offsetY)
    local callBack = function(itemView)
        itemView:setVisible(true)
    end

    for i=1,#itemViewArr do
        local itemView = itemViewArr[i]
        itemView:setVisible(false)

        local intervalTime = 2 / GameVars.ARMATURERATE
        local delayTime = intervalTime * i

        local playAnim = function()
            itemView:setVisible(true)
            itemView.UI_1:pos(offsetX,offsetY)
            FuncCommUI.playRewardItemAnim(itemView.ctn_1,itemView.UI_1)
        end
        view:delayCall(c_func(playAnim),delayTime)
    end
end

-- 播放宝箱奖品item动画
function FuncCommUI.playRewardItemAnim(ctnNode,changeNode,callback, frame, posX, posY)
    local anim = FuncArmature.createArmature("UI_common_chutubiao",ctnNode, false, GameVars.emptyFunc)

    local frame = frame or 5
    anim:registerFrameEventCallFunc(frame, 1,function ()
            if callback  then
                callback() 
            end
        end);

    if posX and posY then
        changeNode:pos(posX, posY)
    end
    
    FuncArmature.changeBoneDisplay(anim , "node1", changeNode)
    anim:pos(0, 0)
    anim:startPlay(false)

    return anim
end

-- 播放奖品item动画
function FuncCommUI.playLotteryRewardItemAnim(rewardItem,_time,callBack)
    rewardItem:setVisible(true)
    local time = _time or 0.4
    local scaleAction = rewardItem:getScaleAnimByPos(0,0,0)
    local scaleAction2 = rewardItem:getScaleAnimByPos(time,1.0,1.0)

    rewardItem:opacity(0)
    local alphaAction = act.fadein(time)
    local itemAnim = cc.Spawn:create(scaleAction2,alphaAction)

    rewardItem:stopAllActions()
    rewardItem:runAction(
        cc.Sequence:create(scaleAction,itemAnim)
    )

    if callBack then
        rewardItem:delayCall(c_func(callBack), time)
    end
end

-- 播放FadeIn动画
function FuncCommUI.playFadeInAnim(itemView,_time,callBack)
    itemView:setVisible(true)
    local time = _time or 0.4
    itemView:opacity(0)
    local alphaAction = act.fadein(time)

    itemView:stopAllActions()
    itemView:runAction(
        cc.Sequence:create(alphaAction)
    )

    if callBack then
        itemView:delayCall(c_func(callBack), time)
    end
end




-- 在view上添加全屏全黑背景
function FuncCommUI.addBlackBg(widthScreenOffset,view,_opacity)
    local bg = FuncRes.a_black(GameVars.width,GameVars.height):anchor(0,1)
    bg:pos(- GameVars.UIOffsetX - widthScreenOffset/2,GameVars.UIOffsetY)
    bg:opacity(_opacity or 200)
    view:addChild(bg,-10)
end



--临时缓存的文本
local cacheTempLabel = nil

function FuncCommUI.initTempLabelCache()
    if not cacheTempLabel then
        cacheTempLabel = cc.Label:create()
        cacheTempLabel:visible(false)
        local scene = WindowControler:getCurrScene()
        cacheTempLabel:parent(scene)

        -- cacheTempLabel:retain()
        cacheTempLabel:setLineBreakWithoutSpace(true)
        -- local scene = WindowControler:getCurrScene()
        -- cacheTempLabel:addto(scene,1000)
        -- cacheTempLabel:pos(250,300)
        -- cacheTempLabel:setTextColor(cc.c4b(255,0,0,255))

    end
end


--销毁缓存的文本
function FuncCommUI:clearCacheTempLabel (  )
    if cacheTempLabel and not  tolua.isnull(cacheTempLabel) then
        
        cacheTempLabel:clear()
    end
end

--获取某个字符串的宽度 --通常是用来判断是否是单行还是多行
function FuncCommUI.getStringWidth(str, fontSize,fontName )
    fontName = fontName and UIBaseDef:turnFontName(fontName) or UIBaseDef:turnFontName(GameVars.systemFontName)
	  FuncCommUI.initTempLabelCache()
    local ttfCfg = {
        fontFilePath = fontName,
        fontSize = fontSize
    }
    cacheTempLabel:setTTFConfig(ttfCfg)
    cacheTempLabel:setString(str)
	cacheTempLabel:setDimensions(0,0)
    return cacheTempLabel:getContentSize().width
end

function FuncCommUI.splitStringByWidth(contentStr, fontSize,fontName,maxWidth,offset)
    offset = offset or 0

    local strArr = {}
    if maxWidth <= 0 then
        return strArr
    end

    local width = FuncCommUI.getStringWidth(contentStr, fontSize,fontName )
    if width <= (maxWidth + offset) then
        strArr[#strArr+1] = contentStr
        return strArr
    end

    local isFind = function(curWidth,nextWidth)
        if nextWidth then
            if curWidth <= (maxWidth + offset) and nextWidth >= (maxWidth + offset) then
                return true
            end
        else
            if curWidth >= (maxWidth + offset) then
                return true
            end
        end

        return false
    end

    local createSplitArr = function(contentStr)
        local strArr = {}
        local indexArr = {}
        local len = string.utf8len(contentStr)

        local beginIdx = 1
        local endIdx = 1
        local count = 1

        local curStr 
        local curWidth
        local nextStr
        local nextWidth

        -- 遍历分割字符串,生成分割点数组  
        for i=1,len do
            if beginIdx > len then
                break
            end

            endIdx = beginIdx+count

            -- 当前字符串及宽度
            local curStr = string.subcn(contentStr,beginIdx,(endIdx-beginIdx+1))
            local curWidth = FuncCommUI.getStringWidth(curStr, fontSize,fontName)

            -- 下一个字符串及宽度
            if endIdx < len then
                nextStr = string.subcn(contentStr,beginIdx,(endIdx+1)-beginIdx+1)
                nextWidth = FuncCommUI.getStringWidth(nextStr, fontSize,fontName)
            else
                nextStr = nil
                nextWidth = nil
            end

            -- 是否找到分割点
            if isFind(curWidth,nextWidth) then
                count = 1
                beginIdx = endIdx+1
                indexArr[#indexArr+1] = endIdx

                strArr[#strArr+1] = curStr
            else
                count = count + 1
            end

            if i == len and indexArr[#indexArr] ~= len then
                -- indexArr[#indexArr+1] = len
                local tempStr = string.subcn(contentStr,beginIdx,(len-beginIdx+1))
                strArr[#strArr+1] = tempStr
            end
        end

        return indexArr,strArr
    end

    local indexArr,strArr = createSplitArr(contentStr)
    return strArr
end

--给定内容，字体、字体大小，和固定的宽度，计算文本的高度
function FuncCommUI.getStringHeightByFixedWidth(strContent, fontSize, fontName, fixedWidth)
	  FuncCommUI.initTempLabelCache()
	  --下面这句会导致ios下文字高度计算问题,注释掉就没问题了
    fontName = fontName and UIBaseDef:turnFontName(fontName) or UIBaseDef:turnFontName(GameVars.systemFontName)
        
    local ttfCfg = {
        fontFilePath = fontName,
        fontSize = fontSize
    }
    cacheTempLabel:setTTFConfig(ttfCfg)
	cacheTempLabel:setDimensions(fixedWidth, 0)

    strContent =  FuncCommUI.getStringAndImage(strContent)
    cacheTempLabel:setString(strContent)
   
	local height = cacheTempLabel:getContentSize().height
    local width = cacheTempLabel:getContentSize().width
    local numLines = cacheTempLabel:getStringNumLines()
    -- cacheTempLabel:parent(WindowControler:getScene(),1000):pos(480,200)
	return height,numLines,width
end


function FuncCommUI.getStringAndImage(text)
  local newstring  = ""
  local stringtable = RichTextExpand:jiexitext(text)
  for i=1,#stringtable do
      if stringtable[i].image == nil then
        newstring = newstring..stringtable[i].char
      else
        local imagename = nil
        local icontable =  ChatModel:getBiaoqingIcon()
        for k,v in pairs(icontable) do
            if v == stringtable[i].name then
                imagename = k
            end
        end
        if imagename ~= nil then
          local char = "图A"
          newstring = newstring..char
        else
          local char = stringtable[i].name
          newstring = newstring..char
        end
      end
  end
  -- dump(stringtable,"11111111111111111111111")
  return newstring
end



function FuncCommUI.playSuccessArmature(compUI,SUCCESS_TYPE,whichBg,showAnyClose,align)
    echoError("不应该走到这里来了")
    return nil
end

--战力变化动画
local maxPowerAni = 2;
local existPowerAni = 0;
local powerAni = {};
local powerNumUI = {};
function FuncCommUI.showPowerChangeArmature(prePower, curPower,_uiscale,_type,_numberscale,offsetX,offsetY)
    echo("\n==========prePower=============",prePower,curPower, "type ==", _type)
    -- if true then
    --     return
    -- end
    _uiscale = nil
    _numberscale = nil
    if BattleControler:isInBattle() then
        -- 当处在战斗中，不弹战力变化动画
        -- fix:战斗结算中当有角色升级导致战力变化的时候会调用此方法
        return
    end
    local strname = "UI_zhanlibianhua_zhanlibianhua"
    if _type ~= nil then
        strname = "UI_zhanlibianhua_zongzhanli"
    end
    if powerAni["UI_zhanlibianhua_zhanlibianhua"] then
        powerAni["UI_zhanlibianhua_zhanlibianhua"]:setVisible(false)
    end

    if powerAni["UI_zhanlibianhua_zongzhanli"] then
        powerAni["UI_zhanlibianhua_zongzhanli"]:setVisible(false)
    end

    local numberScale =  1.15
    if _numberscale then
        numberScale = _numberscale
    end

    local ui = nil
    if not powerNumUI[strname] then
        ui = WindowsTools:createWindow("PowerRolling", prePower, curPower);
        ui:setScale(numberScale);
        ui:setPositionX(-5)
        ui:setPositionY(0)
        if _type ~= nil then
            ui:setPositionY(6)
        else
            ui:setPositionY(3)
        end
        powerNumUI[strname] = ui
    else
        ui = powerNumUI[strname]
        ui:resetPower( prePower, curPower )
    end
   
    
    -- existPowerAni = existPowerAni + 1;

    -- if existPowerAni > maxPowerAni then 
    --     local ani = powerAni[1];
    --     ani:pause();
    --     ani:removeFromParent();
    --     existPowerAni = existPowerAni - 1;
    --     table.remove(powerAni, 1);
    --     -- echo();
    -- end 
    local RollingNumAni = nil
    if not powerAni[strname] then
        FuncArmature.loadOneArmatureTexture("UI_zhanlibianhua", nil, true)
        RollingNumAni = FuncArmature.createArmature(strname, 
        nil, false, GameVars.emptyFunc);
        powerAni[strname] = RollingNumAni
        --加到场景中
        WindowControler:getScene()._topRoot:addChild(RollingNumAni, 
            WindowControler.ZORDER_PowerRolling);

        FuncArmature.changeBoneDisplay(RollingNumAni, "gunshuzib", ui);
        FuncArmature.changeBoneDisplay(RollingNumAni, "gunshuzi", display.newNode());
    else
        RollingNumAni = powerAni[strname]
    end
    -- local RollingNumAni = FuncArmature.createArmature(strname, 
    --     nil, false, GameVars.emptyFunc);
    
    RollingNumAni:removeFrameCallFunc(  )
    RollingNumAni:startPlay(false, true )
    RollingNumAni:doByLastFrame(false, false, function ( ... )
        -- existPowerAni = existPowerAni - 1;
        -- table.remove(powerAni, 1);
        RollingNumAni:visible(false)
    end);
    if _uiscale then
        RollingNumAni:setScale(_uiscale)
        ui:setPositionX(20*_uiscale)
    end

    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    RollingNumAni:setPosition(GameVars.width / 2 + 125 + offsetX, GameVars.height / 4 * 3 - 160 + offsetY);

    --播放音效
    AudioModel:playSound(MusicConfig.s_power_zhanli)  
    

    RollingNumAni:registerFrameEventCallFunc(15, 1, function ( ... )
        AudioModel:playSound(MusicConfig.s_power_number) 
        ui:startRolling();
    end);

end


--[[
    所有scroll可否滚动
]]
function FuncCommUI.setCanScroll(isCanScroll)
    if HomeMapLayer ~= nil then 
        HomeMapLayer.setCanScroll(isCanScroll);
    end 

    if ScrollViewExpand ~= nil then 
        ScrollViewExpand.setEnableScroll(isCanScroll);
    end 

    if AnimDialogControl ~= nil then
        AnimDialogControl:setCanScroll(isCanScroll)
    end
end

--[[
    竖排文本
    params = {
        str = "str"
        num = num -- 每列几个字
        space = 1, -- 列间距几个" "
        txt = txt -- txt实例
    }
]]

function FuncCommUI.setVerTicalTXT( params )
    -- 计算默认每列几个字
    local function calNum( txt )
        -- local fs = txt:getFontSize()
        local lh = txt:getLineHeight()
        local height = txt:getContentSize().height

        return math.floor(height / lh)
    end

    local txt = params.txt 
    local h = params.num or calNum(txt)
    local str = params.str
    local space = params.space or 1
    local t = {}

    -- 预处理半角空格和英文逗号都替换成全角
    str = string.gsub(str, ",", "，")
    str = string.gsub(str, " ", "　")

    tStr = string.split2Array(str)
    local function check( tb, idx )
        if not tb[idx] then tb[idx] = {} end
    end

    local dis = 0
    for i=1,#tStr do
        local idx = (i - 1 + dis) % h + 1

        check(t, idx)
        -- 补位
        if tStr[i] == "\n" then
            dis = dis + h - idx
            for j=idx,h do
                check(t, j)
                table.insert(t[j], "　") -- 一个全角空格
                -- table.insert(t[j], "\t")
            end
        else
            table.insert(t[idx], tStr[i])
        end
    end


    table.walk(t, function( values, k )
        t[k] = table.concat(table.reverse(values), string.rep(" ", space))
        if values[1] == '，' then
            t[k] = t[k] .. " "
        elseif values[1] == "　" then -- 处理右侧段首的空格
            t[k] = t[k] .. " " -- 加一个个半角空格用于被删除
        end
    end)

    local text = table.concat(t, "\n")


    local alignmentType = params.alignmentType or cc.TEXT_ALIGNMENT_CENTER
    -- 设置文本格式
    if txt then
        txt:setAdditionalKerning(-1)
        txt:setAlignment(alignmentType)
        txt:setString(text)
    end

    return text
end

function FuncCommUI.showWorldView(stageType,raidId)
    if stageType ~= WorldModel.stageType.TYPE_STAGE_ELITE then
        if AnimDialogControl:getIsInWorldMap() then
            AnimDialogControl:destoryDialog() 
        end
    end
    WorldControler:showWorldView(true,stageType,raidId)
end

function FuncCommUI:showPartnerView(stageType)
    local  avatar = UserModel:avatar()
    local isopen = PartnerModel:isOpenByType(stageType,avatar)
    if isopen then
        WindowControler:showWindow("PartnerView",stageType,avatar)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid1540"))
    end

end

--让一个view 开启拖拽 并自动判定拖拽边界
--clickView 注册点击的node,
-- view 需要跟随运动的node
function FuncCommUI.dragOneView( clickView ,view )
    view = view or clickView
    local box = view:getContainerBox()
    local nd = display.newNode():anchor(0,1)
    
    if clickView._hasRegesitDraw then
        return
    end
    clickView._hasRegesitDraw  = true
    local boxClickView = clickView:getContainerBox()
    nd:setContentSize(cc.size(boxClickView.width,boxClickView.height))    
    nd:addto(clickView,10000)

    local pressDown = function ( event )
        local turnPos = view:convertToNodeSpaceAR(cc.p(event.x,event.y))
        view.__lastX = turnPos.x
        view.__lastY = turnPos.y
    end

    local pressMove = function ( event )
        local turnPos = view:convertToNodeSpaceAR(cc.p(event.x,event.y))
        local moveX = turnPos.x - view.__lastX
        local moveY = turnPos.y - view.__lastY
        local x,y = view:getPosition()


        x = x +moveX
        y = y + moveY

        --在边界判断
        local parent = view:getParent()
        local yuandian = parent:convertToNodeSpaceAR(cc.p(0,0))
        if x +box.x < yuandian.x then
            x = yuandian.x - box.x
        elseif x+box.x +box.width > yuandian.x + GameVars.width  then
            x = yuandian.x + GameVars.width - box.width - box.x
        end

        if y + box.y < yuandian.y then
            y = yuandian.y - box.y
        elseif y +box.y +box.height > yuandian.y+GameVars.height  then
            y = yuandian.y+GameVars.height - box.height - box.y
        end
        view:pos(x,y)

    end

    nd:setTouchedFunc(GameVars.emptyFunc, nil, false, pressDown, pressMove)

end
function FuncCommUI.setRichwidth(string)
    -- echo("==========111111====================",string)
    local str = tostring(string)
    local fontSize = 11
    local lenInByte = #str
    local width = 0
    -- dump(lenInByte,"1111111111111")
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        -- echo("============curByte================",curByte)
        if curByte>0 and curByte<97 then   ---字符数字
            byteCount = 5
        elseif curByte>=97 and curByte<127 then   --字母
            byteCount = 1
        elseif curByte>=127 and curByte<192 then
            byteCount = 0
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
         -- if byteCount == 0 then

         -- end
        local char = string.sub(str, i, i+byteCount-1)
        -- i = i + byteCount -1
        -- echo("=========000==============",byteCount)
        if byteCount == 0 then
            width = width + fontSize * 0.3
        elseif byteCount == 1 then
            width = width + fontSize +1
        elseif byteCount == 5 then
            width = width + fontSize * 1.2
        else
            width = width + fontSize + 2
        end
    end
    return width
end
--根据数据 ---分解数据成数组
function FuncCommUI.byNumberGetNumberArr(numbers)
    --[[
    local numbsrer=  123445
        numbsrer = {
            [1] = 1,
            [2] = 2,
            [3] = 4,
        }
    ]]
    local newarr = {}
    for i=1,#numbers do
        local curByte = string.byte(numbers, i)
        newarr[i] = string.char(curByte)
    end
    return newarr
end

-- 获取公共头像框内的头像[添加圆角裁剪]
function FuncCommUI.getUtilHeadMaskSprite( iconUrl )
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:setScale(1.2)
    -- 通过遮罩实现头像裁剪
    local  _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,display.newSprite( FuncRes.iconHero(iconUrl )):scale(1.2)  )
    return _spriteIcon
end
-- 根据传递的view 初始化对应的头像数据
-- {hid,isRoboot,icon,lv,star,quality}
function FuncCommUI.initHeadIconData(view,data)
    -- 对view做填充
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:setScale(1.2)
    local iconSpr = display.newSprite( FuncRes.iconHero(data.icon))
    iconSpr:scale(1.2)
    local  _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
    view.UI_1.ctn_1:addChild(_spriteIcon )
    view.UI_1.mc_dou:showFrame(data.star or 1)
    view.UI_1.panel_lv.txt_3:setString(data.lv or 1)
    view.UI_1.mc_kuang:showFrame(tonumber(FuncChar.getBorderFramByQuality(data.quality or 1) ) )
end

--_bgctn  放特效的  _type 从 FuncCommUI.EFFEC_TTITLE 取 offsetY整个特效向下的偏移量 不传默认为0 
-- hideAnyClose 传true隐藏下方文字
-- showShort字段 传true为上下较窄动画 false为上下较宽的动画 不传默认为false
function FuncCommUI.addCommonBgEffect(_bgctn, _type, _callback, showShort, hideAnyClose, offsetY)
    if offsetY == nil then
        offsetY = 0
    end
    FuncArmature.loadOneArmatureTexture("UI_tongyongjiesuan", nil, true)
    -- local bgAni = FuncArmature.createArmature(
    --     "UI_tongyongjiesuan_jiesuan", _bgctn, false,function ()
    local bgAni = FuncArmature.createArmature("UI_tongyongjiesuan_jiesuan", _bgctn, false, function ()
            
    end);
    bgAni:registerFrameEventCallFunc(8,1,function ()
            if _callback then
                _callback()
            end
        end);

    if showShort == nil then
        showShort = false
    end


    if showShort == true then
        bgAni:getBone("di3"):setVisible(false)
        bgAni:registerFrameEventCallFunc(75,1,function ()
                bgAni:getBoneDisplay("di1"):pause()
            end);
        if hideAnyClose then
            local animDi1 = bgAni:getBoneDisplay("di1")
            animDi1:getBone("renyi"):setVisible(false)
        end
    elseif showShort == false then
        bgAni:getBone("di1"):setVisible(false)
        bgAni:registerFrameEventCallFunc(75,1,function ()
                bgAni:getBoneDisplay("di3"):pause()
            end);
        if hideAnyClose then
            local animDi1 = bgAni:getBoneDisplay("di3")
            animDi1:getBone("renyi"):setVisible(false)
        end
    end

    
    -- bgAni:getBoneDisplay("node2"):setVisible(false) 
    bgAni:pos(0, offsetY)
    bgAni:getBone("di2"):setVisible(false)
    -- bgAni:getBoneDisplay("di1"):gotoAndPause(30)

    -- bgAni:getBone("di2"):setVisible(false)

    local anim3 = bgAni:getBoneDisplay("node3")
    anim3:playWithIndex(_type - 1)
    -- local anim1 = bgAni:getBoneDisplay("node2")
    -- anim1:playWithIndex(_type - 1)
    -- anim1:setVisible(false)
    local anim2 = bgAni:getBoneDisplay("node1")
    anim2:playWithIndex(_type - 1)

    local anim4 = bgAni:getBoneDisplay("layer2")
    local saoGuangAnim = anim4:getBoneDisplay("node2")
    if saoGuangAnim.playWithIndex then
        saoGuangAnim:playWithIndex(_type - 1)
    end
    -- anim2:setVisible(false)
    -- bgAni:startPlay(false)
    return bgAni;
end

--统一显示铜钱的获得途径
function FuncCommUI.showCoinGetView()
    WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.COIN)
end

-- 播放主角登场动画
function FuncCommUI.playCharDebutVideo(callBack,roleType)
    if (device.platform ~= "ios" and device.platform ~= "android") then
        -- WindowControler:showTips("播放主角登场动画,1秒后结束")
        if callBack then
            -- WindowControler:globalDelayCall(callBack, 1)
            callBack()
        end
        return
    end

    local videoName = "movie/CharMaleDebut.mp4"
    -- 固定用男视频
    -- if roleType == 2 then
    --     videoName = "movie/CharFemaleDebut.mp4"
    -- end

    local size = cc.size(GameVars.width,GameVars.height)
    local pos = cc.p(GameVars.width/2,GameVars.height/2)

    local videoPlayer = nil
    local eventCallBack = function(sener, eventType)
        if eventType == FuncCommUI.VideoPlayerEvent.COMPLETED then
            local deleteVidoPlayer = function()
                if videoPlayer and (not tolua.isnull(videoPlayer) ) then
                    videoPlayer:removeFromParent()
                end
            end
            
            AudioModel:playSound(MusicConfig.s_char_role,false)
            videoPlayer:setVisible(false)
            WindowControler:globalDelayCall(c_func(deleteVidoPlayer), 1/GameVars.ARMATURERATE)

            if callBack then
                callBack()
            end
        end
    end

    local scene = WindowControler:getCurrScene()
    videoPlayer = FuncCommUI.createVideoView(scene.__doc,videoName,size,pos,eventCallBack,true)
    if videoPlayer then
        videoPlayer:play()
    end

    return videoPlayer
end

--[[
    ctn:mp4适配被加入的容器
    videoName:视频名称
    size:视频尺寸
    pos:视频位置
    eventCallBack:视频播放事件回调
    fullScreen:是否开启全屏
    showSkipBtn:是否创建跳过按钮
]]
function FuncCommUI.createVideoView(ctn,videoName,size,pos,eventCallBack,fullScreen,showSkipBtn)
    local videoPlayer = nil
    size = size or cc.size(100,100)
    pos = pos or cc.p(0,0)
    if (device.platform ~= "ios" and device.platform ~= "android") then
        return videoPlayer
    end

    local fileUtils = cc.FileUtils:getInstance()
    if not videoName or not fileUtils:isFileExist(videoName) then
        WindowControler:showTips("视频播放失败")
        return
    end

    -- 如果存在该视频文件
    if videoName and fileUtils:isFileExist(videoName) then
        -- 删除视频函数
        local deleteVidoPlayer = function()
        if videoPlayer then
                videoPlayer:removeFromParent()
            end
        end

        if eventCallBack == nil then
            -- 默认回调函数
            local callBack = function(sener, eventType)
                if eventType == FuncCommUI.VideoPlayerEvent.PLAYING then
                    echo("video-PLAYING")
                elseif eventType == FuncCommUI.VideoPlayerEvent.SKIP then
                    echo("video-SKIP")
                    videoPlayer:setVisible(false)
                    WindowControler:globalDelayCall(c_func(deleteVidoPlayer), 1/GameVars.ARMATURERATE)
                elseif eventType == FuncCommUI.VideoPlayerEvent.COMPLETED then
                    echo("video-Complete")
                    videoPlayer:setVisible(false)
                    WindowControler:globalDelayCall(c_func(deleteVidoPlayer), 1/GameVars.ARMATURERATE)
                end
            end

            eventCallBack = callBack
        end

        -- 是否执行视频播放回调
        local toDoCallBack = true
        -- 解决iOS11.3，视频播放开始时收到视频播放结束的回调
        if AppInformation:checkSpecialVideo() then
            toDoCallBack = false
        end

        local setCallBack = function()
            toDoCallBack = true
        end
            
        -- 视频回调函数
        local vpEventCallBack = function(sener, eventType)
            if not toDoCallBack and eventType == FuncCommUI.VideoPlayerEvent.PLAYING then
                WindowControler:globalDelayCall(c_func(setCallBack),1)
            end

            if toDoCallBack then
                eventCallBack(sener,eventType)
            end
        end

        local videoFullPath = fileUtils:fullPathForFilename(videoName)
        videoPlayer = pc.VideoPlayer:create()

        if fullScreen then
            videoPlayer:setFullScreenEnabled(true)
            -- size = cc.size(GameVars.width,GameVars.height)
            -- echo("GameVars.UIOffsetY=-",GameVars.UIOffsetY,GameVars.UIOffsetX)
            -- pos = cc.p(GameVars.UIOffsetX + GameVars.width/2,GameVars.UIOffsetY+GameVars.height/2)
        end
        
        videoPlayer:setContentSize(size)
        videoPlayer:pos(pos.x,pos.y)
        videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        videoPlayer:setVisible(true)
        ctn:addChild(videoPlayer)
        
        videoPlayer:addEventListener(c_func(vpEventCallBack))
        videoPlayer:setFileName(videoFullPath)
        -- videoPlayer:play()

        -- 如果是全屏且需要创建跳过按钮
        if fullScreen and showSkipBtn then
            local addSkipBtn = function()
                videoPlayer:addSkipButton("static/btn_skip.png","static/btn_skip.png")
            end
            -- WindowControler:globalDelayCall(c_func(addSkipBtn),1/30)
            addSkipBtn()
        end
    end

    return videoPlayer
end

function FuncCommUI.showVideoView(videoName,size,pos)
    if (device.platform ~= "ios" and device.platform ~= "android") then
        return nil
    end

    local fileUtils = cc.FileUtils:getInstance()
    if videoName and fileUtils:isFileExist(videoName) then
        local scene = WindowControler:getCurrScene()
        local videoPlayer = scene:getVideoPlayer()
        if not videoPlayer then
            echo("video-videoPlayer is nil")
            return
        end

        local videoFullPath = fileUtils:fullPathForFilename(videoName)
        videoPlayer:stop()
        videoPlayer:setVisible(true)

        if size then
            videoPlayer:setContentSize(size)
        end

        if pos then
            videoPlayer:pos(pos)
        end
        
        echo("video videoFullPath=",videoFullPath,videoPlayer:isPlaying())
        videoPlayer:setFileName(videoFullPath)
        videoPlayer:play()
    end

    return videoPlayer
end

--将一个数字转化成字符 6位数 显示成万. 9位数显示成亿
function FuncCommUI.turnOneNumToStr(num )
    num = tonumber(num)
    if not num then
        return ""
    end
    local str 
    local yiNums = 1000000000
    local wanNums = 100000
    if num >= yiNums  then
        str = math.floor(num*10/yiNums) .. FuncTranslate._getLanguage("tid_res_num_yi")
    elseif num >= wanNums then
        str = math.floor(num*10/wanNums) .. FuncTranslate._getLanguage("tid_res_num_wan")
    else
        str = tostring(num)
    end
    return str

end

--[[
    将奖励字符串(csv中的配置)转换为奖励对象
]]
function FuncCommUI.turnOneRewardStr(reward)
    local rewardArr = string.split(reward,",")
    local rewardId,rewardType,rewardNum,rewardStr

    local rewardObj = {}
    -- 配置了权重的奖励
    if #rewardArr > 3 then
        rewardType = rewardArr[2]
        rewardId = rewardArr[3]
        rewardNum = rewardArr[4]
        rewardStr = rewardType..","..rewardId..","..rewardNum
    -- 道具类型
    elseif #rewardArr == 3 then
        rewardType = rewardArr[1]
        rewardId = rewardArr[2]
        rewardNum = rewardArr[3] 

        rewardStr = reward
    -- 2位结构的资源
    elseif #rewardArr == 2 then
        rewardType = rewardArr[1]
        rewardNum = rewardArr[2] 
        rewardStr = reward
    end

    rewardObj.type = rewardType
    rewardObj.id = rewardId
    rewardObj.num = rewardNum
    rewardObj.str = rewardStr

    return rewardObj
end

-- 给传入的node做一个呼吸的动画效果,scale呼吸尺寸
function FuncCommUI.playAnimBreath(view,scale,baseScaleX,baseScaleY)
    local baseScaleX = baseScaleX or 1
    local baseScaleY = baseScaleY or 1

    scale = scale or 1.05
    -- 写动画
    local arr = {
        cc.EaseOut:create(cc.ScaleTo:create(0.4,baseScaleX * scale, baseScaleY * scale),4),
        cc.DelayTime:create(0.1),
        cc.EaseIn:create(cc.ScaleTo:create(0.4,baseScaleX, baseScaleY),4),
    }
    view:stopAllActions()
    view:setScale(baseScaleX,baseScaleY)
    view:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
end

--播放数字特效 params = {text = {},isEffectType = ,x = ,y = ,scale = ,scale_Size  = {width = ,height = },callBack = }
function FuncCommUI.playNumberRunaction(_ctn,data)
    local x = data.x or 0
    local y = data.y or 0
     _ctn:setOpacity(255)
    local effect = _ctn:getChildByName("fankuitexiaozi")
    if data.isEffectType then
        if not effect then
            FuncArmature.loadOneArmatureTexture("UI_fankuitexiaozi", nil, true)
            local startAni = FuncArmature.createArmature("UI_fankuitexiaozi_zong", _ctn, true, function ()
                -- _ctn:removeAllChildren()
            end);
            effect = startAni
            startAni:setName("fankuitexiaozi")
        end
        effect:setVisible(true)
        local textAnim1 = effect:getBoneDisplay("node_fankuitexiaozi_text")
        textAnim1:playWithIndex(data.isEffectType - 1,0,true)
        local tempFunc = function (  )
            -- effect:setVisible(true)
            -- effect:setVisible(false)
        end
        effect:startPlay()
        effect:doByLastFrame(false, false, tempFunc)

        local num = table.length(data.text)
        effect:setPositionY((num * 50)/2+ 75 + y)
    else
        if effect then
            effect:setVisible(false)
        end
    end
    
    if data.scale then
        _ctn:setScale(data.scale)
    end

    data._ctn = _ctn
    local view = _ctn:getChildByName("CompAttributeNumList")
    if not view then
        local numberview = WindowControler:createWindowNode("CompAttributeNumList")
        numberview:setPosition(cc.p(x,y))
        numberview:addTo(_ctn)
        numberview:setName("CompAttributeNumList")
        numberview:initData(data)
    else
        view:initData(data)
    end
end

--添加主城按钮特效
function FuncCommUI.addHomeButtonEffect(_ctn,data,offsetY)
    if not _ctn then
        return
    end
    dump(data,"按钮数据结构 =====")
    local effect = _ctn:getChildByName("UI_ketisheng")
    if data._type then
        if not effect then
            FuncArmature.loadOneArmatureTexture("UI_ketisheng", nil, true)
            effect = FuncArmature.createArmature("UI_ketisheng", _ctn, true, function ()
            end);
            effect:setName("UI_ketisheng")
            local box = _ctn:getContainerBox()
            -- local cx = box.x + box.width/2
            local cy = box.y + box.height/2
            if offsetY then
                effect:setPositionY(offsetY)
            end
        end
        -- local textAnim1 = effect:getBoneDisplay("layer1_copy")
        local textAnim2 = effect:getBoneDisplay("layer1")
        -- textAnim1:playWithIndex(data._type - 1)
        textAnim2:playWithIndex(data._type - 1)
        effect:startPlay(true,false)
        effect:setVisible(data.isShow or false)
    end
end

--添加一个小爆炸提示特效(奇侠界面中的各种小爆点)  offsetX, offsetY分别为偏移值 scale缩放比例 scale = {x = 1, y = 1}
function FuncCommUI.addAttentionAnim(_animName, _ctn, offsetX, offsetY, scale, _callBack)
    local anim = _ctn:getChildByName("attentionAnim")
    if not anim then
        FuncArmature.loadOneArmatureTexture("UI_tishitexiao", nil, true)
        anim = FuncArmature.createArmature(_animName, _ctn, true)
        anim:setName("attentionAnim")
    else
        anim:setVisible(false)
    end

    if scale then
        local scaleX = scale.x or 1
        local scaleY = scale.y or 1
        anim:setScaleX(scaleX)
        anim:setScaleY(scaleY)
    end

    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    anim:pos(offsetX, offsetY)
    
    anim:registerFrameEventCallFunc(15, 1, function ()
            if _callBack then
                _callBack()
            end
        end)
    local tempfunc = function()
        anim:setVisible(false)
    end
    anim:doByLastFrame(false, false, tempfunc)
    anim:startPlay(false, false)
end
