local BattleView = class("BattleView", UIBase);

--[[
]]

BattleView.maxStarLevel = 3

BattleView.baoxiangNums = 0


--激活对象 特效
BattleView.ani_attackSign = nil


-- 测试
function BattleView:ctor(winName)
    BattleView.super.ctor(self, winName)

    self._canClick = true
    self.updateCount = 0
    self.quickGameWinButtonState = false --Temp 限制点击次数
    --是否真正开始战斗
    -- 本地缓存处理自动战斗处理，这个主要是在开战之前能够处理自动战斗按钮的操作
    self._realStart = false

    self:setNodeEventEnabled(true)

end

--UI加载完成
function BattleView:loadUIComplete()
    self._currentStarLevel = self.maxStarLevel
    --ui对其
    -- 左上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_sl,UIAlignTypes.LeftTop)

    -- 右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_qipao,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_qipao2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_qipao3,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_suo,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_huatong,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_laba,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_diaoxian,UIAlignTypes.RightTop)

    -- 居中靠上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipeixx,UIAlignTypes.MiddleTop)


    --居中靠下
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_bzwc,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_djs,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_tou,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zongnu,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_nutiao,UIAlignTypes.MiddleBottom)

    -- 右下

    --N回合内击败山神
    self.panel_sl:visible(false)
    -- 自动战斗开启的气泡
    self.panel_qipao:visible(false)
    -- 开启更高倍速气泡
    self.panel_qipao2:visible(false)
    -- 托管气泡
    self.panel_qipao3:visible(false)

    self.panel_zongnu:visible(false)
    self.panel_nutiao:visible(false)
    -- gve玩家在线状态
    self.panel_diaoxian:visible(false)
    -- 隐藏一个多余的气泡
    if self.panel_qipao3 then
        self.panel_qipao3:visible(false)
    end

    -- 倒计时
    self.panel_djs:visible(false)

    -- 布阵完成按钮
    self.btn_bzwc:visible(false)
    self.btn_bzwc:setTouchedFunc(c_func(self.pressBuZhenFinish,self))

    -- 语音
    self.mc_huatong:visible(false)
    self.mc_huatong:setTouchedFunc(c_func(self.micClick,self))
    -- 听筒
    self.mc_laba:visible(false)
    self.mc_laba:setTouchedFunc(c_func(self.voiceClick,self))

    -- 初始化三星跳过按钮
    self:initTestUI()

    self._root:visible(false)


    self._bLabel = BattleControler:getBattleLabel()

    self.mc_2:setTouchedFunc(c_func(self.speedClick,self),self.mc_2:getContainerBox())

    -- 添加自动战斗特效
    self.autoAni = self:createUIArmature("UI_zhandou", "UI_zhandou_zidong", self.btn_2,true,GameVars.emptyFunc)
    -- self.autoAni:anchor(0,1)
    -- self.autoAni:pos(-3,3)
    self.autoAni:playWithIndex(0,0)--默认非自动
    self:registerEvent()
end

function BattleView:initTestUI( )
    --竞技场、共享副本没有三星跳过的调试界面
    if IS_SHOWBATTLESKIP and 
        not BattleControler:checkIsPVP() and 
        not BattleControler:checkIsShareBossPVE() and 
        not (BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossPve) then
        local  creatBtns = function (text,clickFunc  )
            local view = UIBaseDef:createPublicComponent( "UI_debug_public","panel_bt" )
            FuncCommUI.setViewAlign(self.widthScreenOffset,view,UIAlignTypes.MiddleTop)
            view.txt_1:setString(text)
            view:setTouchedFunc(clickFunc)
            view:addto(self.panel_shipeixx:getParent())
            return view
        end
        echo("GameVars.UIOffsetY",GameVars.UIOffsetY,GameVars.sceneOffsetY,GameVars.bgOffsetY)
        if true then
            creatBtns("三星7", c_func(self.quickGameWin, self,7)):pos(250,10)  
            creatBtns("二星5", c_func(self.quickGameWin, self,5)):pos(420,10)  
            creatBtns("一星1", c_func(self.quickGameWin, self,1)):pos(590,10)  
            creatBtns("失败", c_func(self.quickGameWin, self,0)):pos(250,10-60)
            creatBtns("多人校验", c_func(self.checkLog, self)):pos(420,10-60) 
        end
    end
end


-- function BattleView:showBuzhenFinish( value )
--     if self.btn_bzwc then
--         if self.controler:chkIsXvZhang() then return end -- 序章第一关不显示
--         -- 仙盟gve不是自己的布阵回合不显示布阵完成按钮
--         if self._bLabel == GameVars.battleLabels.guildBossGve and
--          (not self.controler.formationControler:checkIsMeBZ()) then
--             self.btn_bzwc:visible(false)
--             return
--         end
--         local status = self.controler:getLogicalCountStatus()
--         -- 如果不是布阵状态，按钮也不显示
--         if status ~= Fight.countState_buzhen then
--             if Fight.is_show_button and status == Fight.countState_switch then
--                 self.btn_bzwc:visible(value)
--                 return
--             end
--             self.btn_bzwc:visible(false)
--             return
--         end
--         self.btn_bzwc:visible(value)
--     end
-- end

--[[
暂停按钮
]]
function BattleView:onPauseClick(  )
    --echo("暂停")
    if self.controler then
        self.controler:playOrPause(false)
        self.controler:testFramePlay(3)
    end
end




--[[
界面退出
]]
function BattleView:onEnter(  )
    -- self:scheduleUpdateWithPriorityLua(c_func(self.onUpdateAutoFrame, self), 0) 
end

--[[
界面进入
]]
function BattleView:onExit(  )
    self:unscheduleUpdate()
end

-- 隐藏倒计时
function BattleView:hideOrShowCD(b)
    if self.controler:isQuickRunGame() or 
        self.controler:isReplayGame() 
        then
        self.panel_djs:visible(false)
        return
    end
    self.panel_djs:visible(b)
end

-- 倒计时相关处理
function BattleView:onUpdateCD( ... )
    local leftFrame = self.controler.logical:getLeftAutoFrame()
    if leftFrame < 0 then
        -- echo("---:leftAutoFrame",leftFrame)
        return 
    end
    if self.controler:isQuickRunGame() then
        return
    end
    local minSec
    if BattleControler:checkIsMultyBattle() then
        minSec = math.ceil(leftFrame/(Fight.doubleGameSpeed*GameVars.GAMEFRAMERATE))
    else
        minSec = math.ceil( leftFrame/GameVars.GAMEFRAMERATE )
    end
    self:_updateRoundNum(self.panel_djs.mc_1,minSec)
end

--[[
    重启倒计时
]]
function BattleView:resetCountDown()
    self:hideOrShowCD(true)
end

--战斗暂停
function BattleView:doPauseBattle(  )
    if not self._canClick then
        return
    end

    if self.controler.__gameStep == Fight.gameStep.result then
        return
    end
    if self.controler:isReplayGame() and BattleControler:checkIsCrossPeak() then
        -- 重播战报的时候其实是直接运行至指定回合就行了
        local idx = BattleControler:getOperationCount() --操作数
        self.controler:runGameToTargetRound(idx)
    elseif BattleControler:checkIsPVP()  then
        -- PVP直接弹战斗结束界面
        if PVPModel:isLastFightWin() then
            self:quickPVPGame(-1)
        else
            self:quickPVPGame(-2)
        end
    -- elseif self.controler.gameMode == Fight.gameMode_gve then
    --     echo("GVE暂停不做操作----")
    elseif BattleControler:checkIsCrossPeak() then
        self:crossPeakThrow()
    elseif self._bLabel == GameVars.battleLabels.guildBossGve then
        -- 多人GVE
        self:guildBossQuick()
    else
        if BattleControler:checkIsShareBossPVE() or 
            -- self._bLabel == GameVars.battleLabels.guildGve or
            self._bLabel == GameVars.battleLabels.guildBossPve then
            self:quickShareBossGame()
        else
            --发送暂停事件 
            FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
            WindowControler:showBattleWindow("BattlePauseView",self.controler)
        end
    end
end

-- 巅峰竞技场认输
function BattleView:crossPeakThrow( ... )
    -- 添加确认取消对话框
    WindowControler:showBattleWindow("BattlePauseTipView",Fight.pause_quit,function()
        if not self.quickGameWinButtonState then
            self.quickGameWinButtonState = true
            self.controler.server:sendGiveUpHandle({team = BattleControler:getTeamCamp()})
            -- self.controler.server:sendThrow()
        end
    end)

end
-- 仙盟多人中退出战斗
function BattleView:guildBossQuick( ... )
    -- 添加确认取消对话框
    WindowControler:showBattleWindow("BattlePauseTipView",Fight.pause_quit,function()
        if not self.quickGameWinButtonState then
            self.quickGameWinButtonState = true
            -- 发送退出操作(主动退出有惩罚，不能断线重连)
            self.controler.server:sendGuildBossQuit({rid=self.controler:getUserRid()})
        end
    end)
end
--[[
快速跳过PVP
-1:表示竞技场胜利
-2:表示竞技场失败
]]
function BattleView:quickPVPGame(star)


    if not self.quickGameWinButtonState then
        --BattleControler:showReward( {})
        -- -1 表示竞技场胜利
        --快速跳过为改变当前波数为最大波数
        -- self.controler.__currentWave = self.controler.levelInfo.maxWaves
        -- self.controler:quickVictory(star)
        self.controler:quickGameToResult()
        self.quickGameWinButtonState = true
    end
end

function BattleView:quickShareBossGame( )
    if not self.quickGameWinButtonState then
        self.controler:checkToQuickGame()
        self.quickGameWinButtonState = true
    end
end


--快速跳过战斗
function BattleView:quickGameWin( star)
    if not self.quickGameWinButtonState then --Temp 只允许点击一次即可
        self.controler:quickVictory(star)
        self.quickGameWinButtonState = true
    end 
end

function BattleView:registerEvent()
    --暂停按钮的操作  mc_1  这个状态是点击  按下  弹起状态
    --self.panel_1.btn_1:setTap(c_func(self.press_btn_1, self));
    --注册游戏结束事件

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_NEXTWAVE,self.onNextWave,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT,self.autoChanged,self )

    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_REWARD,self.onGameOver,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDEND,self.onRoundEnd,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BUZHEN_CANCLE, self.pressSureBuzhenBtn, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_CHANGE, self.newEnergyShow, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_RETURN, self.energyReturn, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MONKEY_CHANGE, self.updateMonkeyNum, self)
    -- FightEvent:addEventListener(BattleEvent.BATTLEEVENT_COUNTSTATE_CHANGE, self.updateUIVisibleStatus, self)

    -- FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CROSSPEAK_SURE, self.crossPeakSureBattle, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MAX_ENERGY_CHANGE, self.maxEnergyChange, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_GVE_TIME_OUT, self.gveTimeOut, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_QUICK_TO_ROUND, self.quickToRounUpdate, self)
    -- 仙界对决托管状态改变
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_AUTOFLAG_CHANGE, self.autoFlagChagne, self)
    -- 战斗状态机发生变化
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BATTLESTATE_CHANGE, self.onBattleStateChagne, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOW_GAMEUI, self.initGameComplete, self)
    -- 展示bp结算
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BP_SHOW, self.showBPInfo, self)
    -- 多人战斗玩家在线状态发生变化
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_LINESTATE_CHANGE, self.updateOtherUser, self)
    -- 角色释放大招
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_MAX_SKILL, self.heroPlayMaxSkill, self)
    -- 场景内角色点击事件
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_HERO_TOUCH, self.updateTouchHeroTip, self)
end


function BattleView:heroPlayMaxSkill( event )
    -- 当角色释放大招的时候，将头像框隐藏30帧
    -- self:visible(false)
    -- self:delayCall(function( )
    --     self:visible(true)
    -- end,1.5)
end
function BattleView:autoFlagChagne( )
    if self.controler:isQuickRunGame() then
        return
    end
    if not BattleControler:checkIsMultyBattle() then
        return
    end
    -- 托管按钮显示与否
    if self.controler:checkUserIsAuthFlag() then
        if BattleControler:checkIsCrossPeak() then
            self.mc_2:visible(true)
        elseif self._bLabel == GameVars.battleLabels.guildBossGve then
            self.mc_2:showFrame(4)
            self.panel_suo:visible(false)
        end
        self:showTuoGuanQiPao()
    else
        if BattleControler:checkIsCrossPeak() then
            self.mc_2:visible(false)
        elseif self._bLabel == GameVars.battleLabels.guildBossGve then
            self.mc_2:showFrame(2)
            self.panel_suo:visible(true)
        end
    end
end
function BattleView:quickToRounUpdate( )
    self:updateRoundCount()
    -- 更新托管按钮
    self:autoFlagChagne()
    -- 更新倒计时显示与否
    local bState = self.controler.logical:getBattleState()
    if bState == Fight.battleState_formation or 
       bState == Fight.battleState_changePerson or
       bState == Fight.battleState_formationBefore or 
       bState == Fight.battleState_spirit then
       self:hideOrShowCD(true)
    else
       self:hideOrShowCD(false)
    end
    self:_updateBzwcBtn(bState)
end

-- 更新快速进行至战斗的回合数
function BattleView:updateRoundCount( )
    -- 更新回合数显示
    self:updateRoundLab()

    -- 更新托管按钮
    self:autoFlagChagne()
    -- 更新怒气值
    self:updateEnergyInfo()
    -- echo("回合数据=====",curRound,rct)
end
-- 更新回合数显示
function BattleView:updateRoundLab( )
    local cView = self.panel_shipeixx.mc_1.currentView
    local rct = self.controler:getMaxRound()/2
    if BattleControler:checkIsTrail() ~= Fight.not_trail  then
        rct = math.floor(self.controler:getMaxRound()/2)
    elseif self._bLabel == GameVars.battleLabels.missionBombPve then
        rct = math.floor(self.controler:getMaxRound()/2)
    end
    self:_updateRoundNum(cView.mc_num2,rct)
    -- 总回合数
        -- pangkangning 2017.11.08 上一波总回合数+当前回合数
    local curRound = self.controler:getCurrRound()
    curRound = math.ceil(curRound/2)
    self:_updateRoundNum(cView.mc_num1,curRound)

    -- 更新怒气值
    self:updateEnergyInfo()
end

-- 意识夺宝更新获得的宝物个数

function BattleView:updateMonkeyNum( )
    local count = self.controler.logical.missionNum or 0 
    if self._bLabel == GameVars.battleLabels.missionMonkeyPve then
        self.panel_sl.txt_1:setString(GameConfig.getLanguage("#tid_mission_100")..count)
    elseif self._bLabel == GameVars.battleLabels.missionBombPve then
        self.panel_sl.txt_1:setString(GameConfig.getLanguage("#tid_battle_8")..count)
    end
end

-- 添加开战特效
function BattleView:playKaiZhanTeXiao(callBack)
    if self.controler._gameResult ~= Fight.result_none then
        -- 已经出结果了
        if callBack then
            callBack()
        end
        return
    end
    -- self.controler.formationControler:changeBlackScreenVisible(true)
    -- local kaizhan = self:createUIArmature("UI_kaizhan","UI_kaizhan_kaizhan_b",self,false,function( )
    --     -- self.controler.formationControler:changeBlackScreenVisible(false)
    --     BattleControler:setXuQing(false)
    --     if callBack then
    --         callBack()
    --     end
    -- end)
    local kaizhan = self:createUIArmature("UI_kaizhan","UI_kaizhan_kaizhan_b",self,false)
    kaizhan:playWithIndex(1,0)
    kaizhan:pos(GameVars.halfResWidth,-GameVars.halfResHeight)--绝对中心位置

    kaizhan:registerFrameEventCallFunc(35,false,function( )
        BattleControler:setXuQing(false)
        if callBack then
            callBack()
        end
    end)

    -- 剧情
    if BattleControler:chkIsXuQing() then
        kaizhan:getBone("h"):visible(false)
        kaizhan:getBone("layer7"):visible(true)
    else
        kaizhan:getBone("h"):visible(true)
        kaizhan:getBone("layer7"):visible(false)
    end
    -- 添加音效
    AudioModel:playSound("s_battle_battlebegin")
end

--[[
布阵完成
]]
function BattleView:pressSureBuzhenBtn(  )
    --dump(self)
    self.controler.formationControler:buZhenSetTargetPos(0)
    -- --隐藏作用特效
    self.controler.formationControler:doFinishBuZhen()
end

----------------------------------------按钮点击事件--------------------
-- 点击暂停按钮
function BattleView:press_btn_1()

    --如果不能点击 比如 是开场动画的时候
    if not self._canClick then
        return
    end

    if self.controler.__gameStep == Fight.gameStep.result then
        return
    end
    --发送暂停事件 
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
    WindowControler:showBattleWindow("BattlePauseView",self.controler)

end

-------------update刷新函数--------------------------------------------
function BattleView:updateFrame(  )
    self.updateCount = self.updateCount +1
    self:updateTimeAndStar()
    -- 倒计时的显示逻辑
    self:onUpdateCD()
    if self.crossPeakView then
        self.crossPeakView:checkSendBattleLog()
        if self.crossPeakView.bpView then
            self.crossPeakView.bpView:onUpdateCD()
        end
    end
end


--刷新计时 和星级
function BattleView:updateTimeAndStar(  )

    if self.updateCount % GameVars.GAMEFRAMERATE ~= 0 then
        return
    end
    if self.controler.gameLeftTime > 0 then
        local second = math.round(self.controler.gameLeftTime/GameVars.GAMEFRAMERATE)
        local star = self.maxStarLevel
        --如果有星级评价
        local str = fmtSecToMMSS(second)
        --self.panel_1.txt_2:setString(str)

    end
end





--------------------------侦听事件---------------------------
--[[
回合结束
]]

function BattleView:onRoundEnd( event )
    --echo("回合结束")
    if self.comAni then
        self.comAniIndex = 3
        self.comAni:gotoAndPlay(0)
        self.comAni:playWithIndex(3,false)
        --倒计时播放完成  播放消失
        -- self.comAni:getBoneDisplay("note1"):gotoAndPause(comCnt)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer3"):gotoAndPause(first+1)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer4"):gotoAndPause(second+1)
        -- self.comAni:getBoneDisplay("note2"):getBoneDisplay("layer5"):gotoAndPause(third+1)
    end
end


--侦听战斗结束事件
function BattleView:onGameOver( event )
    local result = event.params.result
    -- echo("战斗结果数据=====================")
    -- dump(event.params)
    -- echo("战斗结果数据=====================")

    if BattleControler.userLevel then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        return
    end


    --隐藏root
    self._root:visible(false)
    --停止当前背景音乐
     AudioModel:stopMusic()

    -- 战斗结束打点（主线和精英在这里没问题,有些战斗不走这里）
    self.controler:doClientAction(1)

     --如果是pvp战斗界面
    if tonumber(result) == Fight.result_win then
        WindowControler:showBattleWindow("BattleWin",event.params)
    else
        WindowControler:showBattleWindow("BattleLose",event.params)
    end
    --延迟一帧 隐藏战斗界面
    local tempFunc = function (  )
        self.controler.layer:setGameVisible(false)
    end
    self:delayCall(tempFunc, 0.03)

end


--@测试代码
function BattleView:creatBtns( text,clickFunc )

    local xpos = 30

    local ypos = -110
    local sp = display.newNode():addto(self):pos(xpos,ypos):anchor(0,0)
    sp:size(80,40)
    display.newRect(cc.rect(0, 0,80, 40),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(40,20)
    sp:setTouchedFunc(clickFunc,cc.rect(0,0,84,44))
end

--能否点击
function BattleView:setClickAble( value )
    self._canClick = value
end

--点击布阵完成按钮
function BattleView:pressBuZhenFinish()
    local camp = BattleControler:getTeamCamp()
    self.controler.server:sendBuZhenFinishHandle({camp = camp})
end

--点击自动战斗按钮
function BattleView:pressAutoBtn(  )

    -- 只要点自动战斗这个一定会隐藏
    self.panel_qipao:visible(false)
    
    local wave = self.controler.__currentWave
    local round = self.controler.logical.roundCount

    if self._realStart then
        -- local isAuto = self.controler.logical:getAutoState(self.controler:getUserRid())
        -- if isAuto then
        --     -- 设置非自动战斗
        --     --判断本回合是否操作过
        --     if not self.controler:getCacheValue("auto"..wave.."_"..round.."0") then
        --         self.controler.server:sendOneAutoHandle({auto=0})
        --         self.controler:setCacheValue("auto"..wave.."_"..round.."0",1)
        --     else
        --         WindowControler:showTips(GameConfig.getLanguage("#tid_battle_9"))
        --     end
        -- else

        --     if not self.controler:getCacheValue("auto"..wave.."_"..round.."1") then
        --         self.controler.server:sendOneAutoHandle({auto=1})
        --         self.controler:setCacheValue("auto"..wave.."_"..round.."1",1)
        --     else
        --         WindowControler:showTips(GameConfig.getLanguage("#tid_battle_10"))
        --     end
        -- end
        local isAuto,waiting = self.controler:getUIGameAuto()
        if waiting then
            WindowControler:showTips(GameConfig.getLanguage("#tid_battle_autofight_1"))
            -- WindowControler:showTips("请等待响应")
        else
            self.controler:setGameAuto(not isAuto)
            -- 更新动画状态（仅显示，当需要网络请求时，不一定能与逻辑一致）
            self:updateAutoChangeAnim(self.controler:getUIGameAuto())
        end
    else
        -- 战前缓存的自动战斗状态
        local score = self.controler:getUserAutoStatus()
        if score == 1 then
            self:updateStorageAuto(0)
            self:updateAutoChangeAnim(false)
        else
            self:updateStorageAuto(1)
            self:updateAutoChangeAnim(true)
        end
    end
end

----------------------外部调用------------------------------------------
--设置游戏控制器
function BattleView:setControler(controler )
    self.controler = controler

    -- 暂停或返回按钮
    if BattleControler:checkIsPVP() or
     BattleControler:checkIsShareBossPVE() or 
     -- self._bLabel == GameVars.battleLabels.guildGve or
     self._bLabel == GameVars.battleLabels.guildBossPve
      then
        self.mc_1:showFrame(3)
    elseif BattleControler:checkIsCrossPeak() then
        -- 认输
        self.mc_1:showFrame(4)
    elseif self._bLabel == GameVars.battleLabels.guildBossGve then
        -- GVE跳过
        self.mc_1:showFrame(5)
        -- 语音的两个按钮往右边靠
        local x,y = self.mc_huatong:getPosition()
        self.mc_laba:setPosition(cc.p(x,y))
        x,y = self.btn_2:getPosition()
        self.mc_huatong:setPosition(cc.p(x-15,y+19))

        self:updateRealTimeStatus() --一进来就更新多人语音的状态
        self.panel_suo:visible(true)
    elseif self._bLabel == GameVars.battleLabels.guildGve then
        self.mc_1:visible(false)
    else
        -- GVE 也是暂停界面，但是没有暂停功能
        --暂停按钮的控制  弹起状态
        if BattleControler.__gameMode == Fight.gameMode_gve then
            self.mc_1:visible(false)
        end
        -- self.mc_1:showFrame(1)
    end
    if self.controler:isReplayGame() then
        self.mc_1:showFrame(3)
        self.panel_djs:visible(false)
    end
    self.mc_1.currentView.btn_1:setTap(c_func(self.doPauseBattle,self))


    if self._bLabel == GameVars.battleLabels.guildBossGve then
        self.mc_laba:visible(true)
        self.mc_huatong:visible(true)
    end

    if not TutorialManager.getInstance():isAllFinish() then
       --self.panel_1.btn_1:visible(false)
    end

    if self.controler.levelInfo._tutorial then
        --self.panel_1.btn_1:visible(false)
    end
    --必须是能操作的 而且不是回放
    if self.controler:checkCanHandle() and not self.controler:isReplayGame()  then
        self.btn_2:setTap(c_func(self.pressAutoBtn,self),nil,true)

        --判断是否是自动战斗  自动战斗
        if self.controler.logical:checkIsAutoAttack(1) then
            self.btn_2:setOpacity(100)
        else
            self.btn_2:setOpacity(255)
        end

    else
        --否则把暂停按钮置灰
        FilterTools.setGrayFilter(self.btn_2)
    end
    -- 点击事件,注释掉才能点解角色
    self.colorLayer:visible(false)

    self:chkAutoBtnVisibe()
    
    self:loadWaveData()

    self:onNextWave()

    self:chkHideAllUIForXvZhang()

    self:initGameSpeedFormLocal()

    self:updateRoundLab()
    self:updateEnergyInfo()

    if IS_BATTLE_DEBUGHERO then
        local ui= WindowsTools:createWindow("BattleDebugHeroView"):addto(self._root,1000)
        ui:pos(200,10)
        ui:setControler(self.controler)
        FuncCommUI.dragOneView(ui)
    end
    self:beforeStarUpdateUserAutoStatus()

    if self._bLabel == GameVars.battleLabels.missionMonkeyPve then
        self.panel_sl:visible(true)
        self.panel_sl.txt_1:setString(GameConfig.getLanguage("#tid_mission_100").."0")
    elseif self._bLabel == GameVars.battleLabels.missionBombPve then
        self.panel_sl:visible(true)
        self.panel_sl.txt_1:setString(GameConfig.getLanguage("#tid_battle_8").."0")
    end

end


--添加别的特殊玩法的ui
function BattleView:setSpecialUI( )

    local _createSpecialUI =function( windowName )
        local view = WindowsTools:createWindow(windowName):addto(self.panel_shipeixx:getParent())
        view:visible(false)
        view:initControler(self,self.controler)
        return view
    end
    -- 登仙台ui
    if BattleControler:checkIsPVP() then
        self.ui_hp_view = _createSpecialUI("BattlePVPHpView")
        self.ui_hp_view:visible(true)
    end
    -- 巅峰竞技场UI
    if BattleControler:checkIsCrossPeak() then
        self.crossPeakView = _createSpecialUI("BattleCrossPeakView")
    end
    -- 换灵UI
    if self.controler.formationControler:chkHuanlingIsOpenAndCan() and 
        not BattleControler:checkIsCrossPeak() then
        self.huanling_view = _createSpecialUI("BattleHuanLingView")
        self.controler.formationControler:initChangeElementUI()
    end
    -- 车轮战
    if self.controler.levelInfo:chkIsRefreshType() then
        self.refreshView = _createSpecialUI("BattleRefreshView")
    end
    -- 奇侠展示
    if self.controler.levelInfo:chkParnterShowData() then
        self.parnterShowView = _createSpecialUI("BattleParnterShowViewView")
    end
    -- 神力界面
    if self._bLabel == GameVars.battleLabels.guildBossGve then
        self.gpPowerView = _createSpecialUI("BattleGuildView")
        self.panel_suo:visible(true)
    end
    -- buff刷新界面
    if self.controler.levelInfo:chkIsHaveBattleBuff() or
     self.controler.levelInfo:chkIsWaveRefresh() or
     self.controler.levelInfo:chkIsAnswerType() then
        self.buffsView = _createSpecialUI("BattleBuffsView")
    end
    -- bossUI (这个层级最高)
    if self.controler.gameMode == Fight.gameMode_pve or 
        self.controler.gameMode == Fight.gameMode_gve then
        self.ui_hp_view = _createSpecialUI("BattlePVEHpView")
    end
end

-- 加一个方法控制怒气显示
function BattleView:setEnergyVisible(value)
    -- 序章第一关不显示
    if self.controler:chkIsXvZhang() and value then return end

    self.panel_zongnu:visible(value)
    self.panel_nutiao:visible(value)
end
--[[
序章中所有的UI隐藏
]]
function BattleView:chkHideAllUIForXvZhang(  )
    -- 序章全部隐藏
    if self.controler 
        and (self.controler:chkIsXvZhang()) 
    then
        --echo("全部隐藏-----------")
        -- self.UI_pvp_hp:visible(false)
        -- self.UI_pve_hp:visible(false)
        if self.ui_hp_view then
            self.ui_hp_view:visible(false)
        end
        self.panel_shipeixx:visible(false)
        self.btn_2:visible(false)
        self.mc_2:visible(false)
        self.mc_1:visible(false)
        self.panel_suo:visible(false)
        self.panel_qipao:visible(false)

        return
    end

    --self.mc_1:visible(true)
    if not LoginControler:isLogin() then
        return
    end
    --急速功能按钮 的显隐控制
    if not BattleControler.isDebugBattle then
        --如果加速功能没有开启则 不显示加速按钮
        if self.controler and  (not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.AUTOMATIC)  )
        then
            self.btn_2:visible(false)
        end

        if self.controler and ( not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLESPEEDTWO) )
        then
            self.mc_2:visible(false)
        end

        if self.controler and  (not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLEPAUSE)   )
        then
            self.mc_1:visible(false)
        end
        --  #7299tracup 登仙台第一场允许跳过
        -- if self.controler and (   TutorialManager.getInstance():isArneaHideOutBtn() )
        -- then
        --     self.mc_1:visible(false)
        -- end

    end

    -- 有引导的关卡不显示自动战斗 
    if self.controler:chkHasGuide() then
        self.btn_2:visible(false)
    end
end
-- pve pvp 暂停，自动战斗显示隐藏
function BattleView:chkAutoBtnVisibe(  )
    if self.controler.gameMode == Fight.gameMode_pvp or self.controler.gameMode ==  Fight.gameMode_gve then
        self.btn_2:visible(false)
    elseif self.controler.gameMode ==  Fight.gameMode_pve  then
        self.btn_2:visible(true)
    end
end



function BattleView:initGameSpeedFormLocal(  )
    -- 仙界对决该按钮是托管按钮
    if BattleControler:checkIsCrossPeak() then
        self.mc_2:showFrame(4)
        self.controler:changeGameSpeed(2)
        self.mc_2:visible(false)
        return
    end
    local speed = tonumber(LS:prv():get(StorageCode.battle_game_speed,1))
    if speed ~= 1 and speed ~= 2 and speed ~= 3 then
        echoWarn("速率不对---",speed)
        speed = 1
    end
    if self.controler.gameMode == Fight.gameMode_gve then
        speed = 2
    end
    self.controler:changeGameSpeed(speed)
    self.mc_2:showFrame(speed)
end


--[[
倍率发生改变
]]
function BattleView:speedClick(  )
    if BattleControler:checkIsCrossPeak() then
        -- 取消托管
        self.controler.server:sendAutoFlagHandle({rid = self.controler:getUserRid(),setAuthFlag = 1})
        self.mc_2:visible(false)
        return
    end
    if self._bLabel == GameVars.battleLabels.guildBossGve then
        self.controler.server:sendAutoFlagHandle({rid = self.controler:getUserRid(),setAuthFlag = 1})
        self.mc_2:showFrame(2)
        self.panel_suo:visible(true)
        return
    end
    if self.controler.gameMode == Fight.gameMode_gve then
        -- echo("试炼GVE不能改变战斗倍数")
        return 
    end

    -- 点了这里一定会隐藏
    self.panel_qipao2:visible(false)

    local speed = self.controler.originSpeed
    if speed == 1 then
        if LoginControler:isLogin() and 
            self.controler and 
            ( not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLESPEEDTWO) )
        then
            speed = 1
        else
            speed = 2
        end
        --主线3-3开启才可以设置2倍速
    elseif speed == Fight.doubleGameSpeed then
        --主线7-6才开启3倍速
        if LoginControler:isLogin() and 
        self.controler and 
        ( not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLESPEEDTHREE) )
        then
            speed = 1
        else
            speed = 3
        end
    elseif speed == Fight.thirdGameSpeed then
        speed = 1
    end
    if speed > 3 then
        speed = 3
        echoError ("理论上不会走到这里，是不是开了多倍速开关")
    end
    self.controler:changeGameSpeed(speed)
    LS:prv():set(StorageCode.battle_game_speed,speed)
    self.mc_2:showFrame(speed)

    --倒计时动画
    -- if self.fiveCDAnim then
    --     FuncArmature.setArmaturePlaySpeed( self.fiveCDAnim ,self.controler.updateScale)
    -- end
end

-- 刚刚进入游戏的时候，判断玩家回合状态
function BattleView:beforeStarUpdateUserAutoStatus( )
    local scode = self.controler:getUserAutoStatus()
    if scode == 1 then
        self.autoAni:playWithIndex(1,1)
    else
        self.autoAni:playWithIndex(0,0)
    end
end
-- 更新自动状态按钮动画特效显示
function BattleView:updateAutoChangeAnim(isAuto)
    if isAuto then
        self.autoAni:playWithIndex(1,1)
    else
        self.autoAni:playWithIndex(0,0)
    end
end
-- 更新本地的自动战斗配置
function BattleView:updateStorageAuto(value )
    if BattleControler:checkIsWorldPVE() then
        LS:prv():set(StorageCode.battle_world_pve_auto,value)
    -- elseif BattleControler:checkIsTrialPve() then
    --     LS:prv():set(StorageCode.battle_trail_pve_auto,value)
    elseif BattleControler:checkIsTower() then
        LS:prv():set(StorageCode.battle_tower_auto,value)
    elseif self._bLabel == GameVars.battleLabels.missionMonkeyPve or 
        self._bLabel == GameVars.battleLabels.missionBattlePve then
        LS:prv():set(StorageCode.battle_mission_auto,value)
    elseif BattleControler:checkIsShareBossPVE() then
        local tmpArr = {}
        local sbStr = LS:prv():get(StorageCode.battle_shareboss_auto,nil)
        if sbStr then
            tmpArr = json.decode(sbStr)
            if type(tmpArr) ~= 'table' then
                tmpArr = {}
            end
        end
        local bId = ShareBossModel:getSelectedId() or "1"
        tmpArr[bId] = value
        LS:prv():set(StorageCode.battle_shareboss_auto,json.encode(tmpArr))
        -- LS:prv():set(StorageCode.battle_shareboss_auto,value)
    elseif self._bLabel == GameVars.battleLabels.wonderLandPve then
        LS:prv():set(StorageCode.battle_wonderland_auto,value)
    elseif self._bLabel == GameVars.battleLabels.missionIcePve then
        LS:prv():set(StorageCode.battle_ice_auto,value)
    elseif self._bLabel == GameVars.battleLabels.missionBombPve then
        LS:prv():set(StorageCode.battle_bomb_auto,value)
    elseif self._bLabel == GameVars.battleLabels.endlessPve then
        LS:prv():set(StorageCode.battle_endless_auto,value)
    elseif self._bLabel == GameVars.battleLabels.guildBossPve then
        LS:prv():set(StorageCode.battle_guildboss_auto,value)
    elseif self._bLabel == GameVars.battleLabels.guildGve then
        LS:prv():set(StorageCode.battle_guildGve_auto,value)
    elseif BattleControler:checkIsExploreBattle() then
        if self._bLabel == GameVars.battleLabels.exploreElite then
            LS:prv():set(StorageCode.battle_exploreElite_auto,value)
        else
            LS:prv():set(StorageCode.battle_guildExplore_auto,value)
        end
    end
end
--[[
是否是自动战斗
]]
function BattleView:autoChanged(  )
    --精英1-3才开启自动战斗
    local isAuto = false
    if self._realStart or self.controler:chkIsWaitToQuick() then
        isAuto = self.controler.logical:getAutoState()
    else
        isAuto = self.controler:getUserAutoStatus() == 1 or false
    end
    if isAuto then
        self:pressSureBuzhenBtn()
        -- 当切换自动战斗的时候，若有箭头指引则去掉指引箭头
        self.controler:showGuideArrow(false)
        -- 快速出结果不存储自动战斗状态
        if not self.controler:chkIsWaitToQuick() then
            self:updateStorageAuto(1)
        end
    else
        self:updateStorageAuto(0)
    end
    self:updateAutoChangeAnim(isAuto)

    echo("是否是自动战斗=======",isAuto)
end


-- 更新回合数的数据
function BattleView:_updateRoundNum(view,num )
    if num < 10 then
        view:showFrame(1)
        view.currentView.mc_1:showFrame(num+1)
    else
        view:showFrame(2)
        local a = math.floor(num/10)
        local b = num - a*10
        view.currentView.mc_1:showFrame(a+1)
        view.currentView.mc_2:showFrame(b+1)
    end
end

--[[
回合发生改变
]]
function BattleView:onRoundStart(  )    
    if not self._realStart then
        if self.controler:isTowerTouxi() then
            -- 锁妖塔首回合是偷袭，所以真正战斗时第二回合才算
            if self.controler.roundCount == 2 then
                self._realStart = true
            end
        else
            self._realStart = true
        end
    end
    self:setEnergyVisible(true)
    self:updateRoundCount()

    self.comAniIndex = 0

    -- self:updateAutoChangeAnim()  --更新自动战斗的状态
    if self.controler:isQuickRunGame() then
        return
    end
    local camp = self.controler:getUIHandleCamp()
    local ani = self["ani_chushou_"..camp]

    -- local aniquan = self["ani_chushouquan_"..camp]

    if not ani then
        local aniName 
        local aniNameQuan
        if camp == 1 then
            aniName = "UI_zhandou_youfangjingong"
            -- 偷袭第一回合使用这个标签
            if self.controler:isTowerTouxiAndFirstWaveRound() then
                aniName = "UI_zhandou_touxi"
            end
            -- aniNameQuan = "UI_zhandou_wofang"
        else
            aniName = "UI_zhandou_difangjingong"
            -- aniNameQuan = "UI_zhandou_difang"

        end
        ani = self:createUIArmature("UI_zhandou", aniName, self._root, true)
        -- 当不是锁妖塔偷袭战的时候再缓存
        if BattleControler:checkIsTower() then
            if not (camp == 1 and self.controler:isTowerTouxiAndFirstWaveRound()) then
                self["ani_chushou_"..camp] = ani
            end
        end
        local xpos,ypos
        ypos = -100
        if camp == 2 then
            xpos = 150
            ani:pos(xpos,ypos)
            FuncCommUI.setViewAlign(self.widthScreenOffset,ani,UIAlignTypes.Left)
        else
            xpos = GameVars.gameResWidth  - 150
            ani:pos(xpos,ypos)
            FuncCommUI.setViewAlign(self.widthScreenOffset,ani,UIAlignTypes.Right)
        end

        
    end
    ani:visible(true)
    ani:stopAllActions()
    ani:runEndToNextLabel(0,1,false,true,60)

    -- aniquan:visible(true)
    -- aniquan:startPlay(false)
    -- aniquan:doByLastFrame(false,true)
    -- 更新倒计时
    self:onUpdateCD()
end

--  初始化关卡波数头像
function BattleView:loadWaveData( )
    if BattleControler:checkIsPVP() or 
    BattleControler:checkIsCrossPeak() then
        self.panel_shipeixx.mc_1:showFrame(2)
        return
    end
    self.panel_shipeixx.mc_1:showFrame(1)
    local wView = self.panel_shipeixx.mc_1.currentView.mc_gui
    local maxWaves = self.controler.levelInfo.maxWaves
    self._jinduArr = {}
    local x,y = wView:getPosition()
    local parent = wView:getParent()
    local w = 35
    wView:visible(false)
    -- 检查显示头像的是boss还是小怪
    local wave = #self.controler.levelInfo.waveDatas
    for i=1,wave do
        local arr = self.controler.levelInfo.waveDatas[i]
        local isBoss = false
        for k,v in pairs(arr) do
            -- 只要不是小怪和中立怪，就是boss
            for m,n in pairs(v.treasures) do
                if n.treaType == Fight.treaType_base then
                    local db = ObjectCommon.getPrototypeData( "level.EnemyTreasure",n.hid)
                    if db.profession ~= Fight.profession_monster then
                        isBoss = true
                    end
                    break
                end
            end
        end
        local viewAnim
        if isBoss then
            viewAnim = self:createUIArmature("UI_zhandou","UI_zhandoud_daguai", parent, true)
        else
            viewAnim = self:createUIArmature("UI_zhandou","UI_zhandoud_xiaoguai", parent, true)
        end
        viewAnim:pos(x + (wave - i) * w,y)
        viewAnim:gotoAndPause(0)
        table.insert(self._jinduArr,viewAnim)
    end
end
-- 
function BattleView:onNextWave( params )

    if BattleControler:checkIsPVP() or 
    BattleControler:checkIsCrossPeak() then
        return
    end
    -- echo("战斗进入下一波")
    -- dump(params)
    -- echo("战斗进入下一波")
    --self.__currentWave == self.levelInfo.maxWaves
    if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
    local curWave = self.controler.__currentWave
    local maxWaves = self.controler.levelInfo.maxWaves
    -- self.txt_san:setString(curWave.."/"..maxWaves)
    -- --目前规则是 第二波 首回合 可以手动布阵
    -- echo("____下一波-----------------",curWave,self.controler.gameMode == Fight.gameMode_pve,self.controler.logical)
    if curWave == 0 then
        return
    end
    local v2 = self._jinduArr[curWave]
    if not v2 then
        return
    end
    if curWave > 1 then
        local v = self._jinduArr[curWave-1]
        v:playWithIndex(2,0)
        v:delayCall(function( )
            v2:playWithIndex(0,0)
        end,20/GameVars.GAMEFRAMERATE)
    else
        v2:playWithIndex(0,0)
    end
    
    -- 初始化总怒气信息
    local eInfo = self.controler.energyControler:getEnergyInfo(BattleControler:getTeamCamp( ))
    self:newEnergyShow({params=eInfo})
end



--初始化完毕
function BattleView:initGameComplete(  )
    self._root:visible(true)
    if not self.controler then
        return
    end
    self.panel_suo:visible(false)

    if self._bLabel == GameVars.battleLabels.crossPeakPve then
        self.btn_2:visible(false)
        if not self.controler:isReplayGame() then
            self.mc_1:visible(false)
        end
    end
    -- 检查自动战斗的开启特效
    self.controler:chkAutoAttackGuide(self, self.btn_2)
    -- 检查加速开启特效
    self.controler:chkSpeedGuide(self, self.mc_2)
    -- 对UI做相应的处理
    self.icon_view = self.UI_tou --头像
    if self.icon_view then
        self.icon_view:visible(false)
        self.icon_view:initControler(self,self.controler)
    end

    self:setSpecialUI()
    if BattleControler:checkIsCrossPeak() and 
        (not BattleControler:checkIsCrossPeakModeBP() )
       then
        -- 初始化
        self.crossPeakView:reloadHeadData()
    end
    if self.controler:chkIsXvZhang() then
        self:setSpGuideUI()
    end
    if self._bLabel == GameVars.battleLabels.guildBossGve then
        local _rid = self.controler.levelInfo:getOtherRid()
        local oName = ""
        local bInfo = self.controler.levelInfo:getBattleInfo()
        for k,u in pairs(bInfo.battleUsers) do
            local id = u.rid or u._id
            if id == _rid then
                oName = u.name
                break
            end
        end
        self.panel_diaoxian.txt_1:setString(oName) --玩家信息
    end
end

-- 显示/隐藏弱引导提示箭头
function BattleView:showGuideArrow(isShow, pos)
    if not isShow then
        if not self.guideArrow then return end
        self.guideArrow:visible(false)
    else
        if not self.guideArrow then
            self.guideArrow = FuncArmature.createArmature("UI_main_img_shou_sz", self, true);
        end
        self.guideArrow:pos(pos or cc.p(0,0))
        self.guideArrow:visible(true)
    end
end

--掉落道具
function BattleView:createDrop( itemArr,x,y,ctn,frameIdx)
    if not itemArr then
        return
    end
    local perDis = Fight.drop_distance --每个距离位置
    local leftPos = -(#itemArr-1)/2 *perDis + x
    local  createBaoxiang = function ( x,y,tox ,ctn)
        local ani = self:createUIArmature("UI_zhandou","UI_zhandou_diaobaoxiang", ctn, false,GameVars.emptyFunc)
        ani:pos(x,y )
        ani:moveTo(0.5,tox,y)
        ani:playWithIndex(0)
        ani:setTouchedFunc(c_func(self.easeChest,self,ani ))
        --默认3秒后自动飞到目标点
        ani:delayCall(c_func(self.easeChest,self, ani), 2 )
        if frameIdx then
            ani:getBoneDisplay("a1"):playWithIndex(frameIdx)
        end
    end

    for i=1,#itemArr do
        self:delayCall(c_func(createBaoxiang,x,y + RandomControl.getOneRandomInt(15, -15) ,leftPos + perDis*(i-1),ctn ), (i-1)*0.1+ 0.001 )
    end
end

--让一个宝箱缓动运动到ui目标点
function BattleView:easeChest(chestView )
    -- local p = self.panel_shipeixx.mc_gui
    local p = self.panel_sl.txt_1
    if chestView._isMoving then
        return
    end
    chestView._isMoving = true
    local turnPos = chestView:convertLocalToNodeLocalPos(p)
    --强制添加到 宝箱容器
    chestView:parent(p):pos(turnPos.x,turnPos.y)
    --播放第三个动作  也就是飞过去的动作
    --chestView:playWithIndex(2, false)

    --获取帧数
    local frame = chestView:getAnimation():getRawDuration()
    local angle = math.atan2(-turnPos.y,-turnPos.x)

    chestView:getBoneDisplay("a1"):setRotation(angle*180/math.pi)
    --到达目标点
    local onOverEnd = function ( chest  )
        chest:clear()
        --宝箱播放动画
        --self.ani_baoxiang:startPlay(false)
        if not self.baoxiangNums  then self.baoxiangNums = 0 end
        self.baoxiangNums = self.baoxiangNums +1
        --更新宝箱数量
        --self.panel_1.txt_1:setString(self.baoxiangNums)
        -- self.btn_4:getUpPanel().txt_1:setString(self.baoxiangNums)
        --播放到达特效

    end

    --做一个缓动
    transition.moveTo(chestView,
        {x = 0+20, y = -40, time = (frame-8)/GameVars.GAMEFRAMERATE ,
        -- easing = "exponentialIn",
        onComplete = c_func(onOverEnd, chestView)
        }) 
end


--获取中心坐标
function BattleView:getCtnCenterPos()
    return GameVars.halfResWidth,-GameVars.halfResHeight 
end


--计算阵营的总血量
function BattleView:countTotalHp( camp )
    local campArr = camp ==1  and self.controler.campArr_1 or self.controler.campArr_2
    local hp =0
    for k,v in pairs(campArr) do
        hp = hp +  v.data:hp()
    end
    return hp
end

-- 重写方法
function BattleView:disabledUIClick()
    -- 父类
    BattleView.super.disabledUIClick(self)
    -- 头像处理下
    if self.icon_view then
        self.icon_view:disabledUIClick()
    end
end
-- 恢复方法
function BattleView:resumeUIClick()
    -- 父类
    BattleView.super.resumeUIClick(self)
    -- 头像处理下
    if self.icon_view then
        self.icon_view:resumeUIClick()
    end
end
-- 屏蔽头像点击
function BattleView:disableIconClick(value)
    if self.icon_view then
        if value then
            self.icon_view:disabledUIClick()
        else
            self.icon_view:resumeUIClick()
        end
    end
end
-- 根据hid获取头像坐标的方法
function BattleView:getPosByHeroHid( hid )
    if self.icon_view then
        return self.icon_view:getPosByHeroHid(hid)
    else
        return cc.p(0,0)
    end
end

function BattleView:deleteMe(  )
    self.controler = nil
     --清除自身的侦听 
    FightEvent:clearOneObjEvent(self)
    BattleView.super.deleteMe(self)
   
end

-- 怒气增加动画
function BattleView:showAddEnergyAnim(num)
    if not self.energyNumAnim then
        self.energyNumAnim = self:createUIArmature("UI_zhandou", "UI_zhandou_jiashuzi", 
                            self.panel_zongnu,false,GameVars.emptyFunc)
        self.energyNumAnim:pos(45,30)
    end
    local maxEntireEnergy = self.controler.energyControler:getMaxEntireEnergy(BattleControler:getTeamCamp())
    if num < 1 then num = 1 end
    if num > maxEntireEnergy then num = maxEntireEnergy end 
    self.energyNumAnim:getBoneDisplay("layer2"):getBoneDisplay("layer7"):playWithIndex(num)
    self.energyNumAnim:playWithIndex(0)
end
function BattleView:updateEnergyInfo(eInfo)
    -- self:updateRateInfo(eInfo.rate)
    local maxEntireEnergy = self.controler.energyControler:getMaxEntireEnergy(BattleControler:getTeamCamp())
    -- 总怒气
    if maxEntireEnergy >= 10 then
        self.panel_zongnu.mc_2:showFrame(2)
        local t1 = math.floor(maxEntireEnergy/10)
        local t2 = maxEntireEnergy - 10 * t1
        self.panel_zongnu.mc_2.currentView.mc_1:showFrame(t1+1)
        self.panel_zongnu.mc_2.currentView.mc_2:showFrame(t2+1)
    else
        self.panel_zongnu.mc_2:showFrame(1)
        self.panel_zongnu.mc_2.currentView.mc_1:showFrame(maxEntireEnergy+1)
    end
    -- 当前怒气
    local nowEntire = self.controler.energyControler:getEntire(BattleControler:getTeamCamp())
    if eInfo then
        nowEntire = eInfo.entire
    end
    -- 当前怒气
    if nowEntire >= 10 then
        self.panel_zongnu.mc_1:showFrame(2)
        local t1 = math.floor(nowEntire/10)
        local t2 = nowEntire - 10 * t1
        self.panel_zongnu.mc_1.currentView.mc_1:showFrame(t1+1)
        self.panel_zongnu.mc_1.currentView.mc_2:showFrame(t2+1)
    else
        self.panel_zongnu.mc_1:showFrame(1)
        self.panel_zongnu.mc_1.currentView.mc_1:showFrame(nowEntire+1)
    end
    if not eInfo then
        return
    end
    self.__oldInfo = eInfo
    self:updateEnergyAnim()
end
-- 获取怒气条位置
function BattleView:getEnergyPos( nd )
    local size = self.panel_nutiao:getContainerBox()
    return self.panel_nutiao:convertLocalToNodeLocalPos(nd, cc.p(size.width,-size.height))
end
-- 更新怒气特效
function BattleView:updateEnergyAnim()
    local boneName = {"guang","zhezhao"}
    local tmp,lowY,TopY = 70,0,70--、差值、最低、最高
    local b1,b2 = boneName[1],boneName[2]
    if not self.energyAni then
        self.energyAni = self:createUIArmature("UI_zhandoud", "UI_zhandoud_nuqizhang", 
                                self.panel_nutiao,true,GameVars.emptyFunc)
        self.energyAni:pos(31,-41)
    end
    local per = self.__oldInfo.entire/self.__oldInfo.maxEntire
    local oldY = self.energyAni:getBone(b1):getPositionY()
    local newY = 0
    if per == 1 then
        self.energyAni:getBone(b1):visible(false)
        newY = TopY
    elseif per == 0 then
        self.energyAni:getBone(b1):visible(false)
        newY = lowY
    else
        self.energyAni:getBone(b1):visible(true)
        newY = lowY+tmp*per
    end
    newY = math.max(lowY,newY)
    newY = math.min(TopY,newY)
    if oldY ~= newY then
        local _moveBone = function( bone,y )
            transition.moveTo(bone,
            {x =0, y = y, time =0.2})
        end
        _moveBone(self.energyAni:getBone(b1),newY)
        _moveBone(self.energyAni:getBone(b2),newY)
    end 
end
-- 最大怒气变化处理
function BattleView:maxEnergyChange( )
    self:updateEnergyInfo()
end
-- 怒气显示先在这里临时封装一点方法吧
-- {
-- entire --大怒气
-- piece -- 小怒气
-- rate -- 增长率
-- plus -- true增加false减少
-- camp --怒气变化的阵营
-- }
function BattleView:newEnergyShow( event )
    if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
    local camp = BattleControler:getTeamCamp()
    local maxEntireEnergy = self.controler.energyControler:getMaxEntireEnergy(camp)
    local scale_test = 0.7 --怒气特效缩放值
    local eInfo = event.params
    if eInfo.camp ~= camp then
        return
    end
    if eInfo.plus then
        if self.__oldInfo then
            -- 满格又满能量点
            if self.__oldInfo.entire == maxEntireEnergy and eInfo.piece == Fight.maxPieceEnergy then
                self:updateEnergyInfo(eInfo)
                return
            end
            local num = eInfo.entire - self.__oldInfo.entire
            if num > 0 then
                self:showAddEnergyAnim(num)
            end
            if not self.xiaohaoAnim then
                self.xiaohaoAnim = self:createUIArmature("UI_zhandou", "UI_zhandou_xiaohaonuqi", 
                                self.panel_nutiao,false,GameVars.emptyFunc)
                self.xiaohaoAnim:scale(2)
                self.xiaohaoAnim:pos(30,-50)
            end
            self.xiaohaoAnim:playWithIndex(0,0,0)
        end
    end
    self:updateEnergyInfo(eInfo)
end
function BattleView:energyReturn( event )
    if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
    local eInfo = event.params
    if eInfo.camp == self.controler:getUIHandleCamp() then
        self:updateEnergyInfo(eInfo)
    end
end

-- 控制头像显隐
function BattleView:setIconViewVisible(value)
    -- 还没有开始战斗的时候，头像不要显示出来
    if not self._realStart then
        return
    end
    if self.icon_view then
        self.icon_view:visible(value)
    end
end
function BattleView:showJieshuDonghua(cb)
    -- 共享副本赛事结束的时候调用的这个方法
    local _actionCallBack = function( )
        self:visible(false)
        if cb then
            cb()
        end
    end
    self:visible(true)
    local donghua = self:createUIArmature("UI_gongxiangfuben", "UI_gongxiangfuben_shuimo", 
                                self,false,_actionCallBack)
    donghua:pos(GameVars.halfResWidth,-GameVars.halfResHeight)

end
-- 仙盟GVE时间快到了所以需要退出战斗
function BattleView:gveTimeOut( )
    self.controler:checkToQuickGame()
end

-- 更新ui处理
function BattleView:updateUIVisibleStatus( )
    -- if BattleControler:checkIsCrossPeak() and self.crossPeakView then
    --     self.crossPeakView:updateTipInfo()
    --     self.crossPeakView:updateViewVisible()
    -- end
    -- self:setEnergyVisible(true)
    -- local cState = self.controler:getLogicalCountStatus()
    -- if cState == Fight.countState_buzhen then
    --     self:hideOrShowCD(true)
    --     -- local camp = self.controler:getUIHandleCamp()
    --     if self.controler:chkIsOnMyCamp() then
    --         -- self.icon_view:updateIconVisible(true)
    --         self:showBuzhenFinish(true)
    --     else
    --         -- self.icon_view:updateIconVisible(false)
    --         self:showBuzhenFinish(false)
    --     end
    -- elseif cState == Fight.countState_change then
    --     self:hideOrShowCD(true)
    --     -- self.icon_view:updateIconVisible(false)
    --     self:showBuzhenFinish(false)
    -- elseif cState == Fight.countState_bp then
    --     self:hideOrShowCD(true)
    -- elseif cState == Fight.countState_spirit then
    --    self:hideOrShowCD(true)
    -- else
    --     if Fight.is_show_button and cState == Fight.countState_switch then
    --         self:hideOrShowCD(true)
    --     else
    --         self:hideOrShowCD(false)
    --     end
    --     -- echoError ("waht????",self.controler:chkIsOnMyCamp(),self.controler.logical.isInRound)
    --     -- 在我方战斗的回合内、也需要显示头像层
    --     if self.controler:chkIsOnMyCamp() and self.controler.logical.isInRound then
    --         -- self.icon_view:updateIconVisible(true)
    --     else
    --         -- self.icon_view:updateIconVisible(false)
    --         self:showBuzhenFinish(false)
    --     end
    -- end
end
function BattleView:showBeforeChange( )
    if self.crossPeakView then
        -- 初始化
        self.crossPeakView:reloadHeadData()
    end
    -- 显示布阵
    self.controler.formationControler:doBeginBuZhen()
    -- 显示时间
    self:hideOrShowCD(true)
end
-- 更新布阵按钮显示与否
function BattleView:_updateBzwcBtn(bState)
    local isSpecial = false
    if self.controler:chkIsXvZhang() then
        isSpecial = true
    end
    -- 仙盟gve不是自己的布阵回合不显示布阵完成按钮
    if self._bLabel == GameVars.battleLabels.guildBossGve then
        if (not self.controler.formationControler:checkIsMeBZ()) then
            isSpecial = true
        end
        -- 共闯秘境神力阶段，也不显示布阵完成按钮
        if bState == Fight.battleState_spirit then
            isSpecial = true
        end
        -- 敌方布阵的时候也不显示(会闪一下)
        if bState == Fight.battleState_formation and 
            self.controler:getUIHandleCamp() == Fight.camp_2 then
            isSpecial = true
        end
    end
    if BattleControler:checkIsCrossPeak() then
        -- 仙界对决不是我的回合不显示布阵完成按钮
        if not self.controler:chkIsOnMyCamp() then
           isSpecial = true
        end
        -- 仙界对决换人阶段不显示布阵完成按钮
        if bState == Fight.battleState_changePerson then
            isSpecial = true
        end
        if bState == Fight.battleState_formationBefore  then
            isSpecial = true
        end
    end
    if bState == Fight.battleState_wait or
        bState == Fight.battleState_battle or
        bState == Fight.battleState_switch or 
        bState == Fight.battleState_none or
        bState == Fight.battleState_end or
        bState == Fight.battleState_ready or
        isSpecial then
        self.btn_bzwc:visible(false)
    else
        self.btn_bzwc:visible(true)
    end
end

-- 头像框显示与否
function BattleView:onBattleStateChagne()
    if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
    local bState = self.controler.logical:getBattleState()
    if not self.icon_view then
        return
    end
    -- 倒计时显示与否
    if bState == Fight.battleState_changePerson or
        bState == Fight.battleState_formation or
        bState == Fight.battleState_selectPerson or
        bState == Fight.battleState_formationBefore or
        bState == Fight.battleState_spirit then
        self:hideOrShowCD(true)
    else
        self:hideOrShowCD(false)
    end
    self:_updateBzwcBtn(bState) --更新布阵完成按钮

    if self.icon_view then
        if bState == Fight.battleState_formation or 
           bState == Fight.battleState_changePerson or
           bState == Fight.battleState_formationBefore then
            if self.controler:chkIsOnMyCamp() then
                self.icon_view:updateIconVisible(true)
            else
                self.icon_view:updateIconVisible(false)
            end
        elseif bState == Fight.battleState_spirit then
            -- 共闯秘境轮到我释放神力阶段，不显示头像
            if self.controler.artifactControler:checkIsMeUseSpirit() then
                self.icon_view:updateIconVisible(false)
            else
                self.icon_view:updateIconVisible(true)
            end
            self.icon_view:updateIconVisible(false)
        else
            if self.controler:chkIsOnMyCamp() then
                if BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
                    if self.controler.artifactControler:checkIsMeUseSpirit() then
                        self.icon_view:updateIconVisible(false)
                    else
                        self.icon_view:updateIconVisible(true)
                    end
                else
                    self.icon_view:updateIconVisible(true)
                end
                -- 进入战斗了，那需要刷新一次
                if bState == Fight.battleState_battle then
                    self.icon_view:changeHeadStatus()
                end
            else
                self.icon_view:updateIconVisible(false)
            end
       end
        if bState == Fight.battleState_formation and BattleControler:checkIsCrossPeak() then
            -- 刷新一次头像
            self.icon_view:changeHeadStatus()
        end
    end
    if self.crossPeakView then
        self.crossPeakView:updateHouBuVisible(true)
        -- if bState == Fight.battleState_changePerson or 
        --    bState == Fight.battleState_formationBefore then
        --    self.crossPeakView:updateHouBuVisible(true)
        -- else
        --     self.crossPeakView:updateHouBuVisible(false)
        -- end
    end
end
function BattleView:showTuoGuanQiPao( )
    self.panel_qipao3:visible(true)
    self:delayCall(function( )
        self.panel_qipao3:visible(false)
    end,3)
end
function BattleView:checkLog(  )
    if not BattleControler:checkIsMultyBattle() then
        echoError ("只有多人的时候这个按钮才有用")
        return
    end
    -- 获取至本回合的日志，然后发送
    local info = {
        round=self.controler.logical.roundCount,
        logsInfo = self.controler.logical:getDebugLogsInfo(),
    }
    self.controler.server:sendDebugCommand(info)
end
-- 添加仙界对决超时处理[10秒没响应则发送战斗结算数据]
function BattleView:addCrossPeakResultTimeOut(battleId)
    if self.controler:isReplayGame() then
        return
    end
    self:delayCall(function(  )
        self:sendCrossPeakTimeOut(battleId)
    end,10)
end
function BattleView:sendCrossPeakTimeOut( battleId)
    if self.controler.server and (not self.controler.server.__rewardInfo) then
        self.controler.server:sendCrossPeakTimeOut(battleId,function (data)
            if data.error and BattleControler:isInBattle() then
                BattleControler:onExitBattle()
            end
        end)
    end
end
-- 处理序章特殊UI
function BattleView:setSpGuideUI()
    -- 头像部分的
    if self.icon_view then
        self.icon_view:setSpGuideUI()
    end
    -- 怒气部分
    self:setEnergyVisible(false)
    -- 隐藏一个多余的气泡
    if self.panel_qipao3 then
        self.panel_qipao3:visible(false)
    end
end
-- 仙界对决胜负已出特效
function BattleView:showEndBattleAni(cb)
    local anim
    anim = self:createUIArmature("UI_xianjianduijue","UI_xianjianduijue_sfyf0", self, false,function( )
        if anim then
            anim:removeFromParent()
            anim = nil
        end
        if cb then
            cb()
        end
    end)
    anim:playWithIndex(1,0)
    anim:pos(GameVars.halfResWidth,-GameVars.halfResHeight)
end
-- 点角色弹详情tip
function BattleView:updateTouchHeroTip( event)
    if self._bLabel == GameVars.battleLabels.guildGve or
        self._bLabel == GameVars.battleLabels.pvp or
        self._bLabel == GameVars.battleLabels.missionBattlePve or
        self._bLabel == GameVars.battleLabels.crossPeakPve or
        self._bLabel == GameVars.battleLabels.crossPeakPvp2 or
        self._bLabel == GameVars.battleLabels.guildBossGve
        then
        return
    end
    local params = event.params
    if params.type == 1 then
        local model = params.model
    local bState = self.controler.logical:getBattleState()
        if model.camp ~= Fight.camp_2 and bState == Fight.battleState_formation   then
            -- 我方布阵的时候不需要弹tip
            if self._heroTip then
                self._heroTip:visible(false)
            end
            return
        end
        if not self._heroTip then
            self._heroTip = UIBaseDef:createPublicComponent( "UI_battle_public","panel_3" )
            self._heroTip:addTo(self)
            self._heroTip.rich_2:visible(false) --buff对应的说明文字
        end
        if model.data.isCharacter and LoginControler:isLogin() then
            self._heroTip.txt_2:setString(UserModel:name())
        else
            self._heroTip.txt_2:setString(model.data:getName())
        end
        local str = GameConfig.getLanguage(model.data.curTreasure:sta_des())
        self._heroTip.rich_1:setString(str)
        -- local pos = self:convertToNodeSpaceAR(cc.p(model._initPos.x,model._initPos.y))
        self._heroTip:pos(cc.p(GameVars.halfResWidth-155,-GameVars.halfResHeight+130))
        self._heroTip:visible(true)

        local nSize = cc.size(280,194) --原始的尺寸
        local worldWidth = nSize.width-45 --文字宽度
        local _resetSize = function( )
            self._heroTip.scale9_1:setContentSize(nSize)
            self._heroTip.txt_2:setContentSize(cc.size(worldWidth,40))
            self._heroTip.txt_2:pos(21,25)
            self._heroTip.rich_1:setContentSize(cc.size(worldWidth,72))
            self._heroTip.rich_1:pos(21,18)
            self._heroTip.rich_2._initWid = worldWidth
            self._heroTip.rich_2:setContentSize(cc.size(worldWidth,70))
            self._heroTip.rich_2:pos(21,-48)
            -- echo ("s===",worldWidth,nSize.width,nSize.height)
        end
        _resetSize()

        local buffIconGroups = model.data:getAllBuffIcons()
        -- buff显示
        if #buffIconGroups == 0 then
            self._heroTip.rich_2:visible(false)
        else
            self._heroTip.rich_2:visible(true)
            local str = ""
            for i,v in ipairs(buffIconGroups) do
                local tmpId = string.split(v.id,"_")[1]
                local buffDB = ObjectCommon.getPrototypeData( "battle.Buff",tmpId )
                -- 添加buff图标
                if buffDB.icon then
                    str = str.."[buff/"..buffDB.icon..".png] "
                    -- 添加buff显示
                    if buffDB.buffTips then
                        str = str..GameConfig.getLanguage(buffDB.buffTips).."\n"
                    else
                        str = str..GameConfig.getLanguage("#tid_battle_bufftips_basic").."\n"
                    end
                end
            end
            self._heroTip.rich_2:setIconSize(cc.size(22,22))
            -- self._heroTip.rich_2:setString(str)
            local w,h = self._heroTip.rich_2:setStringByAutoSize(str)
            local maxHeight = GameVars.halfResHeight - 80
            -- echo("ww---hhh",w,h,worldWidth,maxHeight)
            if h < 80 then
                -- 高度不变
            elseif h > maxHeight then
                for i=1,5 do
                    worldWidth = worldWidth + 50
                    self._heroTip.rich_2._initWid = worldWidth
                    self._heroTip.rich_2:setContentSize(cc.size(worldWidth,70))
                    local _w,_h = self._heroTip.rich_2:setStringByAutoSize(str)
                    if _h < maxHeight or i == 5 then
                        nSize.width = worldWidth
                        nSize.height = _h + 125
                        -- echo("bbbb",_h,maxHeight,i,nSize.width,nSize.height)
                        break
                    end
                end
            else
                nSize.height = h + 125
            end
            _resetSize() --重置坐标宽高
        end
    elseif params.type == 2 then
        if self._heroTip then
            self._heroTip:visible(false)
        end
    end
end
-- bp结束后弹bp结果
function BattleView:showBPInfo( )
    if Fight.isDummy or self.controler:isQuickRunGame() or
     self.controler:isReplayGame() then
        return
    end
    if not BattleControler:checkIsCrossPeakModeBP() then
        return
    end
    -- 是自选卡模式才弹
    WindowControler:showBattleWindow("BattleBpShowView",self.controler)
end
-- 更新GVE玩家在线状态
function BattleView:updateOtherUser()
    if self._bLabel ~= GameVars.battleLabels.guildBossGve then
        return
    end
    -- 如果玩家掉线了，需要显示这条信息
    local _rid = self.controler.levelInfo:getOtherRid()
    if self.controler.logical:chkUserIsLineOff(_rid) then
        self.panel_diaoxian:visible(true)
    else
        self.panel_diaoxian:visible(false)
    end
end
-- 更新玩家麦克风、喇叭状态
function BattleView:updateRealTimeStatus( )
    local micFrame = LS:prv():get(StorageCode.realTime_mic,1) -- 1开启，2关闭
    micFrame = tonumber(micFrame)
    self.mc_huatong:showFrame(micFrame)

    local staFrame = LS:prv():get(StorageCode.realTime_voice,1) -- 1开启，2关闭
    staFrame = tonumber(staFrame)
    self.mc_laba:showFrame(staFrame)
end
-- 话筒点击事件
function BattleView:micClick(  )
    local micFrame = LS:prv():get(StorageCode.realTime_mic,1)
    micFrame = tonumber(micFrame)
    if micFrame == 1 then
       micFrame = 2
    else
        micFrame = 1
    end
    self.mc_huatong:showFrame(micFrame)
    LS:prv():set(StorageCode.realTime_mic,micFrame)
    local isOpen = micFrame == 1 and true or false 
    ChatShareControler:updateMicOrSpeak(1, isOpen)
end
-- 喇叭点击事件
function BattleView:voiceClick(  )
    local vFrame = LS:prv():get(StorageCode.realTime_voice,1)
    vFrame = tonumber(vFrame)
    if vFrame == 1 then
       vFrame = 2
    else
        vFrame = 1
    end
    self.mc_laba:showFrame(vFrame)
    LS:prv():set(StorageCode.realTime_voice,vFrame)
    local isOpen = vFrame == 1 and true or false 
    ChatShareControler:updateMicOrSpeak(2, isOpen)
end
return BattleView;
 