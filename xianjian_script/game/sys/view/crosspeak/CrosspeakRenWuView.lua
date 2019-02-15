local CrosspeakRenWuView = class("CrosspeakRenWuView", UIBase)

function CrosspeakRenWuView:ctor(winName)
	CrosspeakRenWuView.super.ctor(self, winName)
end
function CrosspeakRenWuView:setAlignment()
    --设置对齐方式
end

function CrosspeakRenWuView:registerEvent()
    CrosspeakRenWuView.super.registerEvent();
    self:registClickClose("out")
    self.panel_di.btn_1:setTap(c_func(self.closeUI,self))

    self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_026"))
    -- EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RENWU_DATACHANGE_EVENT,self.updateRenwu,self)
end


function CrosspeakRenWuView:loadUIComplete()
    self:registerEvent()

    self:initUI()
end
function CrosspeakRenWuView:initUI( )
    -- 宝箱奖励状态
    self:updateBox()
    -- 任务进度
    self:updateRenwu()
end
-- 宝箱奖励状态
function CrosspeakRenWuView:updateBox()
    local boxId = CrossPeakModel:renWuBoxId( )
    local boxData = FuncCrosspeak.getBoxDataById( boxId )
    -- 进度
    local currentPercent = CrossPeakModel:renWuFinishCount( ) -- 当前进度 
    local maxPercent = boxData.taskNum -- 总进度
    local progressBar = self.panel_1.progress_1
    local progressTxt = self.panel_1.txt_1
    progressBar:setPercent(currentPercent/maxPercent*100)
    progressTxt:setString(currentPercent.." / "..maxPercent)
    -- 宝箱显示
    local boxIcon = boxData.boxPic
    local boxPath = FuncRes.crossBoxIcon( boxIcon )
    local boxSp = display.newSprite(boxPath)
    local boxCtn = self.ctn_box
    boxCtn:removeAllChildren()
    boxCtn:addChild(boxSp)
    -- 宝箱段位
    local boxSegment = boxData.segment
    local segmentName = FuncCrosspeak.getSegmentLevelName( tostring(boxSegment) )
    self.txt_2:setString(GameConfig.getLanguage(segmentName))
    -- 宝箱
    local boxName = boxData.boxName
    self.txt_2:setString(GameConfig.getLanguage(boxName))
    -- 是否可领取宝箱
    if currentPercent >= maxPercent then
        -- 可领取状态
        self.mc_txt:showFrame(2)
        self.panel_1:visible(false)
        boxSp:setTouchedFunc(c_func(self.getRenwuBoxTap,self))
    else
        self.mc_txt:showFrame(1)
        self.panel_1:visible(true)
        -- 不可领取
        boxSp:setTouchedFunc(c_func(self.openRenwuBoxInfo,self))
    end
end
-- 领取任务宝箱
function CrosspeakRenWuView:getRenwuBoxTap()
    echo("领取任务宝箱--------")
    CrossPeakServer:crossPeakGetRenWuBoxSever(c_func(self.getRenwuBoxTapCallBack,self) )
end
function CrosspeakRenWuView:getRenwuBoxTapCallBack(params)
    if params.result then
        local rewards = params.result.data.rewards
        WindowControler:showWindow("RewardSmallBgView", rewards);
        self:updateBox()
        self:updateRenwu()
    else
        -- 领取宝箱失败
    end
end
-- 打开任务宝箱详情
function CrosspeakRenWuView:openRenwuBoxInfo()
    echo("打开任务宝箱详情--------")
    local boxId = CrossPeakModel:renWuBoxId( )
    WindowControler:showWindow("CrosspeakRenwuBoxInfoView",boxId)
end
-- 刷新任务
function CrosspeakRenWuView:updateRenwu()
    
    -- 任务数据
    local data = CrossPeakModel:renWuData()
    local itemsData = {}
    for i,v in pairs(data) do
        local t = {}
        t.id = i
        t.value = v
        table.insert(itemsData,t)
    end
    local sortFunc = function ( a,b )
        if tonumber(a.id) > tonumber(b.id) then
            return true
        end
        return false
    end
    table.sort(itemsData,sortFunc)

    local allNum = table.length(itemsData)
    for i=1,3 do
        if i == (allNum + 1) then
            self:updateItemFunc(itemsData[i],i,true)
        else
            self:updateItemFunc(itemsData[i],i,false)
        end
    end
end
-- 刷新每个任务的方法
function CrosspeakRenWuView:updateItemFunc(itemData,index,isNext)
    local mc_panel = self["mc_item"..index]
    mc_panel:visible(true)
    if itemData then
        mc_panel:showFrame(1)
        local panel = mc_panel.currentView
        local finishNum = itemData.value
        local id = itemData.id
        local renWuData = FuncCrosspeak.getTastDataById( id )
        -- 任务说明
        local tips = renWuData.taskTips
        panel.txt_3:setString(GameConfig.getLanguage(tips))
        -- 奖励列表
        local rewards = renWuData.reward
        for i=1,3 do
            local _ui = panel["UI_"..i] 
            local data = {}
            data.reward = rewards[i]
            if data then
                _ui:visible(true)
                _ui:setRewardItemData(data)
                -- itemView:showResItemName(true)
                _ui:showResItemNum(false)
                -- 注册点击事件
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(data.reward)
                FuncCommUI.regesitShowResView(_ui, resType, needNum, resId,data.reward,true,true)
            else
                _ui:visible(false)
            end
        end
        -- 进度
        local currentNum = finishNum
        local allNum = renWuData.needCount

        local refBtn = panel.btn_sx
        if currentNum >= allNum then
            panel.mc_btn:showFrame(2)
            -- 领取按钮
            local getBtn = panel.mc_btn.currentView.btn_1
            getBtn:setTap(c_func(self.getRenwuRewardTap,self,id,index))
            refBtn:visible(false)
        else
            panel.mc_btn:showFrame(1)
            local txt = panel.mc_btn.currentView.panel_1.txt_1
            local progressBar = panel.mc_btn.currentView.panel_1.progress_1
            txt:setString(currentNum.."/"..allNum)
            progressBar:setPercent(currentNum/allNum*100)
            -- 刷新按钮
            refBtn:visible(true)
            refBtn:setTap(c_func(self.refreshRenwuRewardTap,self,id,index))
        end
        
    elseif isNext then 
        mc_panel:showFrame(2)
        local function updateTime( ... )
            local nextTime = CrossPeakModel:nextRenwuRefreshTime( )
            if nextTime > 0 then
                if mc_panel and mc_panel.currentView.txt_2 then
                    mc_panel.currentView.txt_2:setString(fmtSecToHHMMSS((nextTime+2)))
                end
            end
        end
        
        updateTime()
        -- 倒计时
        self:scheduleUpdateWithPriorityLua(updateTime, 0)

    else
        mc_panel:visible(false)
    end
end
-- 领取任务奖励按钮
function CrosspeakRenWuView:getRenwuRewardTap(id)
    CrossPeakServer:crossPeakGetRenWuSever(id,c_func(self.getRenwuRewardTapCallBack,self,id) )
end
function CrosspeakRenWuView:getRenwuRewardTapCallBack(id,params)
    if params.result then
        local taskData = FuncCrosspeak.getTastDataById(id)
        if taskData then
            local rewards = taskData.reward
            WindowControler:showWindow("RewardSmallBgView", rewards);
        end
        self:updateBox()
        self:updateRenwu()
        -- 发送红点通知
        EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RED_POINT_CHANGE_EVENT)
    end
end
-- 刷新任务
function CrosspeakRenWuView:refreshRenwuRewardTap(id,index)
    -- -- 判断是否满足刷新条件
    -- local refreshedNum = CountModel:getCrosTaskRefreshNum()
    -- local maxNum = FuncDataSetting.getCrosspeakRenwuRefreshNum()
    -- if refreshedNum >= maxNum then
    --     echoError("配表 已达到刷新上限")
    -- else
    --     self.refreshIndex = index
    --     self.refreshMissionId = id
    --     CrossPeakServer:crossPeakRefreshRenWuSever(id,c_func(self.refreshRenwuRewardTapCallBack,self) )
    -- end 
    local refreshedNum = CountModel:getCrosTaskRefreshNum()
    local maxNum = FuncDataSetting.getCrosspeakRenwuRefreshNum()
    if refreshedNum >= maxNum then
        WindowControler:showTips( { text = GameConfig.getLanguage("#tid_crosspeak_025") })
    else
        WindowControler:showWindow("CrosspeakRenwuRfView",id,c_func(self.refreshRenwuRewardTapCallBack,self))
        self.refreshIndex = index
        self.refreshMissionId = id
    end
end
function CrosspeakRenWuView:refreshRenwuRewardTapCallBack(params)
    if params.result then
        dump(params.result.data, "shuaxin de renwu -----", 9)
        local Data = params.result.data.dirtyList.u.crossPeak.cpMissionInfo.missions
        local itemData = {}
        for i,v in pairs(Data) do
            itemData.id = i
            itemData.value = v
        end
        self:updateItemFunc(itemData,self.refreshIndex)
    end
end

function CrosspeakRenWuView:closeUI( )
    self:startHide()
end

return CrosspeakRenWuView
