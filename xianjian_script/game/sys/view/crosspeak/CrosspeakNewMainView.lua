local CrosspeakNewMainView = class("CrosspeakNewMainView", UIBase)

function CrosspeakNewMainView:ctor(winName)
	CrosspeakNewMainView.super.ctor(self, winName)
end
function CrosspeakNewMainView:setAlignment()
    --设置对齐方式
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_top, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_2, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1, UIAlignTypes.RightTop)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_you, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3, UIAlignTypes.RightBottom)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_3, UIAlignTypes.Right,nil,1)
end

function CrosspeakNewMainView:registerEvent()
    CrosspeakNewMainView.super.registerEvent();
    self.btn_back:setTap(c_func(self.onBtnBackTap,self))
    self.btn_guize:setTap(c_func(self.guizeTap,self))
    
 
    -- 刷新宝箱显示
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_BOX_STATE_EVENT,self.updateBox,self)
    -- 刷新红点
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RED_POINT_CHANGE_EVENT,self.btnRedShow,self)

    EventControler:addEventListener(UserEvent.USEREVENT_CROSSPEAKCOIN_CHANGE,self.updateXianqi,self)
    -- 段位积分变化
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT, self.updateLeiTai, self)
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT, self.updateXianqi, self)
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT, self.updateInfo, self)

    -- 赛季到期
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEASON_OVER_EVENT, self.updateUI, self)

end

function CrosspeakNewMainView:updateUI()
    self:updateBox( )
    self:updateLeiTai()
    self:updateInfo()
    self:updateBtns()
    self:btnRedShow()

    if not CrossPeakModel:renWuBoxId( ) then
        self:disabledUIClick()
        CrossPeakServer:requestRankServer( c_func(self.rankInitCallBack,self) )
    end
    
end

function CrosspeakNewMainView:openBuyView( )
    -- 判断是否在开启时间内
    local timeOpen = CrossPeakModel:isActionTimeOpen( )
    if timeOpen then
        local times = CrossPeakModel:getCurrentSYTimes( )
        if times <= 0 then
            WindowControler:showWindow("CrosspeakBuyView")
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2002")) 
        end
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2025"))
    end
end

function CrosspeakNewMainView:loadUIComplete()
    self:registerEvent()
    self:setAlignment()
    

    self:updateBox( )
    self:updateLeiTai()
    self:updateInfo()
    self:updateBtns()
    self:btnRedShow()

    self:checkShowSegmentUpView()

    if not CrossPeakModel:renWuBoxId( ) then
        self:disabledUIClick()
        CrossPeakServer:requestRankServer( c_func(self.rankInitCallBack,self) )
    end

    self:updateRewardBox()
end
function CrosspeakNewMainView:updateRewardBox( )
    self:updateBox()
    -- 启动一个计时器用于刷新宝箱时间
    self:delayCall(function( )
        self:updateRewardBox()
    end,1)
end

-- 判断是否弹段位晋升奖励
function CrosspeakNewMainView:checkShowSegmentUpView()
    -- 判断是否弹出段位晋升
    local battSeg = CrossPeakModel:getSegment( )
    local maxSeg = CrossPeakModel:getMaxSegment( )
    if tonumber(battSeg) < tonumber(maxSeg) then
        CrossPeakModel:setSegment(maxSeg)
        self:showSegmentUpView( )
    end
end


function CrosspeakNewMainView:rankInitCallBack( event )
    if event.result then
        self:resumeUIClick(  )
    else
        self:onBtnBackTap()
    end
end
-- 详情显示
function CrosspeakNewMainView:updateInfo()
    -- 赛季时间
    local mondayStr,sundayStr = CrossPeakModel:getActivityOpenTime()
    local a = string.split(mondayStr,"-")
    local b = string.split(sundayStr,"-")
    local str = GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2033",a[2],a[3],b[2],b[3])

    self.panel_you.txt_1x:setString(str) 
    -- 赛季排行
    local strRank = CrossPeakModel:getCurrentRank( )
    if strRank == 0 then
        strRank = GameConfig.getLanguage("#tid_crosspeak_006") 
    end
    self.panel_you.txt_2x:setString(strRank)
    -- 积分
    local currentScore = CrossPeakModel:getCurrentScore()
    self.panel_you.txt_3x:setString(currentScore)
    -- 本周玩法
    local btn1 = self.panel_you.btn_1
    local pmType = FuncCrosspeak.getPlayerModel()
    local pmName = FuncCrosspeak:getPlayModelName( pmType )..">>"
    btn1:getUpPanel().txt_1:setString(pmName)
    local pmOpen = CrossPeakModel:getPalyModelOpen( )
    if tonumber(pmType) == 1 then -- 标准 不会锁
        pmOpen = true
    end
    btn1:getUpPanel().panel_1:visible((not pmOpen))
    btn1:getUpPanel().panel_1.txt_1:setString(pmName)
    btn1:setTap(c_func(self.openPlayInfo,self,1,(not pmOpen)))
    -- 对决玩法
    local curSeg = CrossPeakModel:getCurrentSegment()
    local batMName = FuncCrosspeak.getBattleModelName( curSeg )
    local btn2 = self.panel_you.btn_2
    btn2:getUpPanel().txt_1:setString(batMName..">>")
    btn2:setTap(c_func(self.openPlayInfo,self,2,false))

    -- 新增奇侠 
    self:initAddPartnerList( )

    self.panel_hz.btn_guize:setTap(c_func(self.segmentTap, self) )
    
end
function CrosspeakNewMainView:openPlayInfo(openType,notOpen)
    if notOpen then
        local openSeg = CrossPeakModel:getCurrentSegment()
        for i=1,5 do
            local isOpen = FuncCrosspeak.getSegmentDataByIdAndKey(tostring(openSeg+i),"startPlayMethod")
            if isOpen and isOpen == 1 then
                openSeg = openSeg+i
                break
            end
        end
        WindowControler:showTips( GameConfig.getLanguageWithSwap("#tid_crosspeak_tips_2032",openSeg))
        return
    end
    WindowControler:showWindow("CrosspeakPlayerTipsView",openType)
end
function CrosspeakNewMainView:initAddPartnerList( )

    echo("当前 段位 === ",CrossPeakModel:getCurrentSegment())
    echo("当前 积分 === ",CrossPeakModel:getCurrentScore())
    local T = CrossPeakModel:getNewAddPartnerByLevelId(CrossPeakModel:getCurrentSegment())
    local list = self.panel_you.panel_pt.scroll_1
    local panel = self.panel_you.panel_pt.UI_1
    panel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel)
        self:updatePartnerItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updatePartnerItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = T,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -63, width = 80, height = 63},
        },
    };
    list:styleFill(_scrollParams);
    list:hideDragBar()

end
function CrosspeakNewMainView:updatePartnerItem( view, itemData )
    local panel = view
    panel:updataUI(itemData.id,"")
    local partnerData = FuncCrosspeak.getCrossPeakPartnerData(itemData.sid)
    panel:setStar( partnerData.star )
    panel:setQulity(partnerData.quality )
    panel:hideLevel(false)
    panel:setTouchedFunc(function ( ... )
        WindowControler:showWindow("PartnerCrosspeakInfoView", itemData.id,itemData.sid)
    end)
end

-- 擂台显示
function CrosspeakNewMainView:updateLeiTai( )
    self.segmentPanel = self.panel_hz

    -- 段位
    local currentSegmentId = CrossPeakModel:getCurrentSegment()
    local currentScore = CrossPeakModel:getCurrentScore()
    local segmentName = FuncCrosspeak.getSegmentName( currentSegmentId )
    local levelName = FuncCrosspeak.getSegmentLevelName( currentSegmentId )
    local segmentIcon = FuncCrosspeak.getSegmentIcon( currentSegmentId )

    local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
    local icon = display.newSprite(iconPath)
    self.segmentPanel.ctn_1:removeAllChildren()
    self.segmentPanel.ctn_1:addChild(icon)
    icon:setTouchedFunc(c_func(self.segmentTap, self) )


    self.segmentPanel.txt_1:setString(GameConfig.getLanguage(levelName))
    self.segmentPanel.txt_2:setString(GameConfig.getLanguage(segmentName))

    -- 时间开启
    self.segmentPanel.txt_time1:setString(FuncCrosspeak:getOpenWDay( ))
    self.segmentPanel.txt_time2:setString(CrossPeakModel:getOpenTimeStr( ))
    -- 挑战按钮
    self.btn_zhan:setTap(c_func(self.tiaozhanTap,self))
end
-- 宝箱显示
function CrosspeakNewMainView:updateBox( )
    self.currentFrame = -1
    self.daojishiIndex = nil

    local maxBoxNum = 5
    for i=1,maxBoxNum do
        local mcBox = self.panel_zuo["mc_xiang"..i]
        local stateBox = CrossPeakModel:getBoxStatr( i )
        -- 宝箱状态
        mcBox:showFrame(stateBox)
        -- echo("i === ",i,"  stateBox === ",stateBox)
        if stateBox <= 3 then
            local boxData = CrossPeakModel:getBoxDataByIndex(i)
            local boxPanel = mcBox.currentView.panel_1
            local boxIcon = FuncCrosspeak.getBoxIcon(boxData.boxId)
            local boxIconPath = FuncRes.crossBoxIcon( boxIcon )
            local boxIconSp = display.newSprite(boxIconPath)
            boxIconSp:scale(0.5)
            boxIconSp:setPositionY(-5)
            boxIconSp:setPositionX(5)
            boxPanel.ctn_boxIcon:removeAllChildren()
            boxPanel.ctn_boxIcon:addChild(boxIconSp)
            if stateBox < 3 then
                -- boxPanel:setTouchedFunc(c_func(self.boxInfoTap,self,boxData))
                FuncCommUI.regesitShowCrosspeakBoxTipView(boxPanel, boxData)
            end
        end
        if stateBox == 1 then
            local boxData = CrossPeakModel:getBoxDataByIndex(i)
            local unLockTime = FuncCrosspeak.getBoxUnlockTime(boxData.boxId)
            local boxPanel = mcBox.currentView.panel_1
            boxPanel.txt_2:setString(fmtSecToLnDHHMMSS(unLockTime))
        end

        if stateBox == 2 then
            -- 刷新倒计时 
            -- self.daojishiIndex = i
            -- self.currentFrame = 30
            -- self.tiemTxt = mcBox.currentView.panel_1.txt_1
            self:updateTime()
            -- self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

            -- 加速领取
            local btn = mcBox.currentView.panel_1.btn_jiasu
            btn:setTap(c_func(self.getRewardBoxCostTap,self,i))
        end
        if stateBox == 3 then
            -- 可领取状态 
            local btn = mcBox.currentView.panel_1.btn_lingqu
            btn:setTap(c_func(self.getRewardBoxTap,self,i))
        end
    end

    --开启次数
    local getBoxNum = CountModel:getCrossGetBoxNum()
    local maxBoxNum = FuncDataSetting.getCrosspeakMaxBoxNum(  )
    local txt_box = self.panel_zuo.txt_1
    -- 今日开启次数：需要配表
    local kqStr = GameConfig.getLanguage("#tid_crosspeak_020")
    txt_box:setString(kqStr)

    -- echo("最大开启报箱数 -=== ",maxBoxNum)
    -- self.panel_zuo.txt_2:setString(getBoxNum.."/"..maxBoxNum) 
    self.panel_zuo.txt_2:setString(maxBoxNum - getBoxNum) 
    -- self:updateXianqi( )
end
function CrosspeakNewMainView:updateXianqi( )
    -- local haveXianqi = UserModel:getCrossPeakCoin()
    -- local maxXianqi = UserModel:getMaxCrossPeakCoin()
    -- local txt_xianqi = self.panel_zuo.txt_2
    -- txt_xianqi:setString(haveXianqi.."/"..maxXianqi)
end
function CrosspeakNewMainView:updateTime(  )
    for i=1,5 do
        local stateBox = CrossPeakModel:getBoxStatr( i )
        if stateBox == 2 then
            local boxData = CrossPeakModel:getBoxDataByIndex(i)
            if boxData then
                local currentTime = TimeControler:getServerTime()
                local leftTime = boxData.unlockFinishTime - currentTime
                if leftTime < 0 then
                    self:updateBox( )
                else
                    local str = fmtSecToHHMMSS(leftTime)
                    local timeTxt = self.panel_zuo["mc_xiang"..i].currentView.panel_1.txt_1
                    timeTxt:setString(str)
                end
            end
        end
    end
    -- if self.currentFrame >= 30 and self.currentFrame >= 0 then
    --     self.currentFrame = 0
    --     local boxData = CrossPeakModel:getBoxDataByIndex(self.daojishiIndex)
    --     if boxData then
    --         local currentTime = TimeControler:getServerTime()
    --         local leftTime = boxData.unlockFinishTime - currentTime
    --         if leftTime < 0 then
    --             self.currentFrame = -1
    --             self.daojishiIndex = nil
    --             self:updateBox( )
    --         else
    --             local str = fmtSecToHHMMSS(leftTime)
    --             self.tiemTxt:setString(str)
    --         end
    --     else
    --         self.currentFrame = -1
    --         self.daojishiIndex = nil
    --         self:updateBox( )
    --     end
    -- elseif self.currentFrame >= 0 then 
    --     self.currentFrame = self.currentFrame  + 1 
    -- end
end

-- 点击宝箱事件
function CrosspeakNewMainView:boxInfoTap( boxData )
    WindowControler:showWindow("CrosspeakBoxInfoView", boxData)
end
-- 领取宝箱事件
function CrosspeakNewMainView:getRewardBoxTap( boxIndex )
    CrossPeakServer:crossPeakBoxRewardSever(boxIndex,1,c_func(self.getRewardBoxTapCallback,self) )
end
function CrosspeakNewMainView:getRewardBoxTapCallback( params )
    if params.result then
        local rewards = params.result.data.rewards
        dump(rewards, "----jiangli-----", 4)
        WindowControler:showWindow("RewardSmallBgView", rewards);
        self:updateBox()
    end
end
-- 消耗资源领取宝箱
function CrosspeakNewMainView:getRewardBoxCostTap( boxIndex )
    if CrossPeakModel:isGetBoxMax( ) then
        -- 宝箱奖励领取上限 提示
        local str = GameConfig.getLanguage("#tid_crosspeak_tips_2027")
        WindowControler:showTips(str)
        return 
    end
    if CrossPeakModel:isBoxCostEnough(boxIndex) then
        CrossPeakServer:crossPeakBoxRewardSever(boxIndex,0,c_func(self.getRewardBoxTapCallback,self) )
    else
        -- 弹出仙玉兑换仙气UI
        WindowControler:showWindow("CrosspeakBuyTipsView",boxIndex,c_func(self.getRewardBoxTapCallback,self))
    end
end

--按钮显示
function CrosspeakNewMainView:updateBtns()
    -- 回放
    self.btn_huifang:setTap(c_func(self.openZhanBaoView,self))
    -- 任务+
    self.btn_1:setTap(c_func(self.openTastView,self))
    -- 奖励
    self.btn_2:setTap(c_func(self.openRewardView,self))
    -- 排行
    self.btn_3:setTap(c_func(self.openPaiHangView,self))
end


function CrosspeakNewMainView:tiaozhanTap( )
    -- if true then
    --     WindowControler:showTips("战斗还在开发！！！")
    --     return
    -- end
    local isOpne = CrossPeakModel:isActionTimeOpen( )
    if not isOpne then
        WindowControler:showTips( GameConfig.getLanguage("#tid_crosspeak_tips_2025"))
        return
    end
    local seg = CrossPeakModel:getCurrentSegment()
    echo ("---仙剑对决段位=======",seg)
    -- 开始战斗
    -- 记录当前最大段位，出战斗后进阶会弹奖励
    CrossPeakModel:setSegment( CrossPeakModel:getMaxSegment() )
    
    CrossPeakModel:tiaozhanAction( )
end

function CrosspeakNewMainView:segmentTap()
	WindowControler:showWindow("CrosspeakSegmentView")
end

function CrosspeakNewMainView:guizeTap()
	WindowControler:showWindow("CrosspeakGuizetView")
end

function CrosspeakNewMainView:onBtnBackTap()
    echo("guanbi UI =======")
    self:startHide()
end

-- 刷新积分和段位
function CrosspeakNewMainView:updateScoreAndSegment()
	-- 段位 积分
	local currentSegmentId = CrossPeakModel:getCurrentSegment()
	local currentScore = CrossPeakModel:getCurrentScore()
	local segmentName = FuncCrosspeak.getSegmentName( currentSegmentId )
	local segmentIcon = FuncCrosspeak.getSegmentIcon( currentSegmentId )
	self.segmentPanel.txt_1:setString(GameConfig.getLanguage(segmentName))
	self.segmentPanel.txt_2:setString(currentScore)
	local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
	local icon = display.newSprite(iconPath)
    self.segmentPanel.ctn_1:removeAllChildren()
    self.segmentPanel.ctn_1:addChild(icon)
    icon:setTouchedFunc(c_func(self.segmentTap, self))
end

-- 挑战次数刷新
function CrosspeakNewMainView:updateChanllengeTimes( )
	-- 挑战次数
    local tiems = CrossPeakModel:getCurrentSYTimes( )
    -- 挑战次数：
    local str = GameConfig.getLanguage("#tid_crosspeak_016") 
    self.downPanel.txt_1:setString(str..tiems)
end
-- 排行刷新
function CrosspeakNewMainView:updateRank( )
    local strRank = CrossPeakModel:getCurrentRank( )
  	if strRank == 0 then
  		strRank = GameConfig.getLanguage("#tid_crosspeak_006")
  	end
    -- 赛季排名:
    local str = GameConfig.getLanguage("#tid_crosspeak_014")
  	self.panel_saipai.txt_1:setString(str..strRank)
end

-- 场景内的红点刷新
function CrosspeakNewMainView:btnRedShow( )
    -- 任务红点
    local red1 = CrossPeakModel:isShowRenWuRed()
    self.btn_1:getUpPanel().panel_red:visible(red1)
	-- 奖励红点
	local red2 = CrossPeakModel:isShowSegmentRed()
	self.btn_2:getUpPanel().panel_red:visible(red2)
	-- 排行红点
	local red3 = false
	self.btn_3:getUpPanel().panel_red:visible(red3)
end

-- 段位提升
function CrosspeakNewMainView:showSegmentUpView( )
    self:delayCall(function ( ... )
        WindowControler:showWindow("CrosspeakUpSegmentView")
    end,0.5)
end
--回放
function CrosspeakNewMainView:openZhanBaoView()
    CrossPeakModel:getReportListData( )
end
--任务
function CrosspeakNewMainView:openTastView( ... )
    -- CrossPeakModel:getReportListData( )
    WindowControler:showWindow("CrosspeakRenWuView")
end
-- 奖励
function CrosspeakNewMainView:openRewardView()
    CrossPeakModel:getGuildKillNum(  )
    WindowControler:showWindow("CrosspeakRewardView")
end
function CrosspeakNewMainView:openQieCuoView( )
    -- 敬请期待 tid_common_2036
    local str = GameConfig.getLanguage("tid_common_2036")
    WindowControler:showTips(str) 
end
function CrosspeakNewMainView:openPaiHangView( )
    CrossPeakModel:clearCrossPeakRankData( )
    local call = function (  )
        WindowControler:showWindow("CrosspeakRankView")
    end
    CrossPeakModel:requestCrossPeakRank( 1,call )
end
function CrosspeakNewMainView:openShopView( )
    local str = GameConfig.getLanguage("tid_common_2036")
    WindowControler:showTips(str)
end

return CrosspeakNewMainView
