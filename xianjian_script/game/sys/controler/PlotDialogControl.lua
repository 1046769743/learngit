local PlotDialogControl = { }
----------------------------------------------------
PlotDialogControl.addSelfAmoutt = 0

---------------------------------------------------- 
local scheduler = require("framework.scheduler") 

function PlotDialogControl:init()
    EventControler:addEventListener(UserEvent.USEREVENT_CLOSE_SET_NICK_NAME_VIEW,self.onNickNameViewClose,self)

    self.curStep = 1
    -- 当前执行到的步数
    PlotDialogControl.addSelfAmoutt = 0
    --当前一行的数据
    self.pdata = { }
    --所有的数据
    self.allData = { }
    --立绘说话前的动作id
    self.preAniVer = { }

    --回调方法 当某一条内容执行完毕后的灰掉方法
    self.optionBtCallback = nil
    

    local x,y = WindowControler:getDocLayer():getPosition()
    self.originPosition=cc.p(x,y);

    self._isDestory = false
end  
 
-- 震动播放顺序
local PLOT_DIALOG_STATE = {
    -- A=出场动画播放之前
    A = 1,
    -- B=出场动画播放时
    B = 2,
    -- C=说话之前震动
    C = 3,
    -- D=说话之后震动
    D = 4,
    -- E= 选项按钮
    E = 5,
}
 
-- 优先级,震动，动画
function PlotDialogControl:showPlotDialog(id, _callback)
    self:init()

    if self.handle ~= nil then
        scheduler.unscheduleGlobal(self.handle)
    end

    --当前的一个定时器，主要用来刷新 震屏信息
    self.handle = scheduler.scheduleGlobal(handler(self, self.updateFrame), 0.05)

    --这个是选择后的回调
    self.optionBtCallback = _callback
    self.plotId = id
    self.view = WindowControler:showTutoralWindow("PlotDialogView", self);
    --self.view.colorLayer:setPlotLayerSize(GameVars.width+100,GameVars.height+100);
    --self.plotDialogState = -1
    --self:onTouchEvent()
    self.view:setAnimId(self.animId)
    self:sortPlotData(id)

    self:showNextPlot()
   
    return self
end 

function PlotDialogControl:setAnimId(animId)
    self.animId = animId
end
-- 获取当前立绘对话UI
function PlotDialogControl:getPlotView()
    return self.view
end

--[[
跳转到新的plotId对应的
]]
function  PlotDialogControl:skipNewPlot( plotId )

    echo("PlotDialogControl跳转到下一条的Plot------",plotId)

    self:destoryDialog()
    --当前的一个定时器，主要用来刷新 震屏信息
    self.handle = scheduler.scheduleGlobal(handler(self, self.updateFrame), 0.05)
    self.view = WindowControler:showTutoralWindow("PlotDialogView", self);
    self.curStep = 1
    -- 当前执行到的步数
    PlotDialogControl.addSelfAmoutt = 0
    -- 加载纹理材质
    -- FuncArmature.loadOneArmatureTexture("UI_battle", nil, true)
    --当前一行的数据
    self.pdata = { }
    --所有的数据
    self.allData = { }
    --立绘说话前的动作id
    self.preAniVer = { }

    self.plotId = plotId
    self:sortPlotData(plotId)
    self:showNextPlot()
end

--[[
order播放完成后执行的回调
]]
function PlotDialogControl:setAfterOrderCallBack(callBack)
    self.orderCallBack = callBack
end


--[[
是否显示跳过按钮
]]
function  PlotDialogControl:setSkipButtonVisbale( state )
   --self.view.btn_1:setVisible(state)
end   


-- 当关闭设置昵称的界面时
function PlotDialogControl:onNickNameViewClose()
    if self.view then
        self.view:hideUI( true )
    end
    self.curStep = self.curStep - 1
    self:showNextPlot()
end

function PlotDialogControl:showNextPlot(  )
    if self.curStep>1 then
        --上一条播放完成了 策划需要在条目播放前执行，也可以在这里修改
        --如果是播放之前就不减1 
        if self.orderCallBack then
            --echo("orderCallBack---------------------")
            self.orderCallBack(self.plotId,self.allData[self.curStep-1].order)
        end
    end

    local allCnt = #self.allData
    if self.curStep >allCnt then
        --已经播放完了所有的id对应的立绘对话了
        -- 弹出选角界面
        if tostring(self.plotId) == "1000049" then
            WindowControler:showSelectRoleView()
        end
        if tostring(self.plotId) == "40000" then
            self:showPartnerCard(  )
        end
        self:destoryDialog()
        return
    end

    self.pdata = self.allData[self.curStep]
    
    -- 剧情对话执行该步骤，弹出设置玩家昵称界面
    if tostring(self.plotId) == "40000" and tonumber(self.curStep) == 4 then
        local showNext = function()
            self:showNextStepView(self.pdata,exitTab)
        end

        -- echoError ('起名----',self.view)
        -- 2018.07.26 主角昵称与选角合并后引导相关修改
        -- if not UserModel:isNameInited() then
        if true then
            -- EventControler:dispatchEvent(UserEvent.USEREVENT_CLOSE_SET_NICK_NAME_VIEW)
            EventControler:dispatchEvent(UserEvent.USEREVENT_SET_NAME_OK)
            self:showNextStepView(self.pdata,exitTab)
            --[[
            WindowControler:showPlayerSetNicknameView()
            if self.view then
                self.view:delayCall(c_func(showNext), 0.1)
                self.view:hideUI( false )
            else
                showNext()
            end
            ]]
        else
            showNext()
        end
    else
        self:showNextStepView(self.pdata,exitTab)
    end

    self.curStep = self.curStep + 1
end

-- 都是写死的 引导新提的需求
function PlotDialogControl:showPartnerCard(  )
    -- WindowControler:showTutoralWindow("NewLotteryJieGuoCradView",{1,"5003"})

    local param = {
        id = "5003",
        skin = "1",
        file = nil,
        funFile = nil,
    }
    WindowControler:showTutoralWindow("PartnerSkinFirstShowView",param)

end


--[[
显示下一条
]]
function PlotDialogControl:showNextStepView(curRow,exitTab)
    if self.view then
        self.view:showNextStepView(curRow, exitTab)
        self.view:setCanSkip( false )
        --self.view:
        --wk  加一个弹幕事件监听方法
        EventControler:dispatchEvent(BarrageEvent.BARRAGE_PLOT_EVENT,curRow)
        if curRow and curRow["shake"] then
            self:shake(10, 5, "xy")
        end
    end
end


function PlotDialogControl:plotInfoCompleteAni()
    self.preAniVer = self.pdata.afterAni or { }
    self.aniIndex = #self.preAniVer or 0
    self.curAniIdx = 1
    self:aniCompleteCallBack()
end  

function PlotDialogControl:aniCompleteCallBack()

    if self.plotDialogState == PLOT_DIALOG_STATE.A then
        -- 进场
        self.plotDialogState = PLOT_DIALOG_STATE.C
        if self.aniIndex ~= 0 then
            -- 检查进场动画序列
            local _enterAni = self.pdata.preAni[self.curAniIdx]
            self:playAniView(_enterAni)
        else
             self.plotDialogState = PLOT_DIALOG_STATE.D
            self:updatePlogInfo(self.pdata)
        end
    elseif self.plotDialogState == PLOT_DIALOG_STATE.C then
        -- 对话前
        if self.curAniIdx <= self.aniIndex then
            local _enterAni = self.pdata.preAni[self.curAniIdx]
            local _time = _yuan3(_enterAni == 0, 5, 1)
            if _enterAni == 0 then
                local _dtime = cc.DelayTime:create(_time)
                local _act = cc.CallFunc:create(
                function()
                    self.curAniIdx = self.curAniIdx + 1
                    _enterAni = self.pdata.preAni[self.curAniIdx]
                    self:playAniView(_enterAni)
                end
                )
                local _action = cc.Sequence:create(_dtime,
                _act)
                self.view:runAction(_action)
            else
                self:playAniView(_enterAni)
            end
        else
            self.view:removeCurAni()
            if self.pdata.shake[PLOT_DIALOG_STATE.C] == 1 then
                self:shake(10, 10, "x")
            end
            if self.isShowOption then
                -- 进入新动画检测 是否需要显示对话选项
                self:updatePlogInfo(self.pdata,false)
                self:showOptionView()
                --self:setOptionState(false)
            else
                self:updatePlogInfo(self.pdata)
            end
            self.plotDialogState = PLOT_DIALOG_STATE.D
        end
    elseif self.plotDialogState == PLOT_DIALOG_STATE.D then
        -- 退场动画

        if self.pdata.shake[PLOT_DIALOG_STATE.D] == 1 then
            self:shake(10, 10, "x")
        end
        if self.curAniIdx <= self.aniIndex  then
            self:playAniView(self.preAniVer[self.curAniIdx])
        else
            --  a process complete
            self.view:plotDialogComplete(self.pdata)

            if self.pdata.nextId == nil then
                -- close Window
                self:destoryDialog()
                return
            end
            self.curStep = self.pdata.nextId[1]
            self.playAniState = false
            -- 进入新流程 检查是否入场动画..震动...
            -- 此处检查是否有选项
            if self.pdata.glaType == 1 then
                --self:setOptionState(true, true)
            else
                self.plotDialogState = PLOT_DIALOG_STATE.E
                self:setOptionState(false)
                self:onTouchEvent()
            end
            --  self.curAniIdx = 1
        end
    else
        -- 选项
        return
    end

end

function PlotDialogControl:playAniView(_enterAni, dir)

    if _enterAni ~= nil then
        self.playAniState = true
        local _data = { enterAni = _enterAni, img = self.pdata.img, dir = self.pdata.pos[2], pos = self.pdata.pos,ani=self.preAniVer[self.curAniIdx-1] }
        if(_enterAni~=0)then
             self.view:removeCurAni()
             self.view:playPlotAni(_data)
        else
             self.view:playDelayAni(_data);
        end
        self.curAniIdx = self.curAniIdx + 1
    end
end 

--[[
跳过立绘对话
但是这个跳过，这是调到下一条
]]
function PlotDialogControl:skipPlot(order)
    self:showNextPlot()
end

--[[
获取当前ID的所有的 行 
]]
function PlotDialogControl:sortPlotData(plotId)
    local _allData = FuncPlot.getPlotData(plotId)
    local _i = 1
    for _, key in pairs(_allData) do
        table.insert(self.allData, FuncPlot.getStepPlotData(plotId,_i))
        _i = _i + 1
    end
end

function PlotDialogControl:updatePlogInfo( data, isShowText)
     
    local _textVisable = _yuan3(isShowText == nil ,true,false)
    self.view:updateUI(self.pdata,_textVisable)
    self.playAniState = false
end 

function PlotDialogControl:updateFrame(dt)
    self:sceneShake()
end 

--[[
销毁整个立绘对话框的操作
isJump 是否是跳过退出
]]
function PlotDialogControl:destoryDialog(isJump)
    -- 如果已经关闭过一次
    if self._isDestory then return end
    self._isDestory = true
    --echo("销毁PlotDilogView=-===================")
    if self.handle ~= nil then
        scheduler.unscheduleGlobal(self.handle)
    end

    if self.optionBtCallback then
        self.optionBtCallback( { step = - 1, index = - 1, plotId = self.plotId, isJump = isJump})
    end
    
    if self.view then
        self.view:startHide()
        self.view = nil
    end
    self.animId = nil
    self:clear()
end 
   
-- 震屏
function PlotDialogControl:shake(frame, range, shakeType)

    range = range and range or 2
    frame = frame and frame or 6
    shakeType = shakeType and shakeType or "xy"
    self.shakeInfo = {
        frame = frame,
        shakeType = shakeType
    }
    if shakeType == "x" then
        self.shakeInfo.range = { range, 0 }
    elseif shakeType == "y" then
        self.shakeInfo.range = { 0, range }
    else
        self.shakeInfo.range = { range, range }
    end
    local shakeLayer = WindowControler:getDocLayer()

    if self.oldPos then
        shakeLayer:pos(self.oldPos[1], self.oldPos[1])
    else
        self.oldPos = { shakeLayer:getPosition() }
    end
end

--[[
从当前的代码中看  updateFrame只是执行了震屏操作
执行震屏操作  在 updateFrame中进行更新
在sceneShake中就是每帧刷新屏幕的位置
而且当前的press_skip_button 不可用

]]
function PlotDialogControl:sceneShake()
    -- echo("执行震屏操作-------")
    if not self.shakeInfo then
        if self.view  then
            if not tolua.isnull(self.view) then
                self.view:setCanSkip( true )
            else
                echoWarn("_view 被移除了,但是不是从controler里面移除的")
            end
            
        end
        return
    end
    local shakeLayer = WindowControler:getDocLayer()
    self.shakeInfo.frame = self.shakeInfo.frame - 1

    local oldXpos = self.oldPos[1] or 0
    local oldYpos = self.oldPos[2] or 0
    local pianyi =(self.shakeInfo.frame % 2 * 2 - 1)

    shakeLayer:pos(oldXpos + pianyi * self.shakeInfo.range[1], oldYpos + pianyi * self.shakeInfo.range[2])

    if self.shakeInfo.frame == 0 then
        self.shakeInfo = nil
        shakeLayer:pos(oldXpos, oldYpos)
        self.oldPos = nil
    end
    if (self.press_skip_button)then
            self.press_skip_button=nil;
            shakeLayer:setPosition(self.originPosition);
    end
end


function PlotDialogControl:clear()
    -- self.view  = nil
end 

return PlotDialogControl 
