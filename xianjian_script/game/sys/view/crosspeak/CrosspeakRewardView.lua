local CrosspeakRewardView = class("CrosspeakRewardView", UIBase)
local REWARD_TYPE = {
    ACTIVE = 1,
    SEGMENT = 2,
    RANK = 3,
    GUILD = 4,
}
function CrosspeakRewardView:ctor(winName)
	CrosspeakRewardView.super.ctor(self, winName)
end
function CrosspeakRewardView:setAlignment()
    --设置对齐方式
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
end

function CrosspeakRewardView:registerEvent()
    CrosspeakRewardView.super.registerEvent();
    self:registClickClose("out")
    self.btn_back:setTap(c_func(self.closeUI,self))

end


function CrosspeakRewardView:loadUIComplete()
    self:registerEvent()
    self:setAlignment()
    self.currentType = REWARD_TYPE.SEGMENT
    self:initUI()
    self:updateBtnsShow()

    --标题名称
    local djStr = GameConfig.getLanguage("#tid_crosspeak_022") 
    local nameTitle = djStr
    self.UI_1.txt_1:setString(nameTitle)

    self.panel_yeqian["mc_1"]:visible(false)
end
function CrosspeakRewardView:initUI( )
    if self.currentType == REWARD_TYPE.ACTIVE then
        self:updateActiveReward(  )
    elseif self.currentType == REWARD_TYPE.RANK then
        self:updateRankReward()
    elseif self.currentType == REWARD_TYPE.SEGMENT then
        self:updateSegmentReward()
    elseif self.currentType == REWARD_TYPE.GUILD then
        local lvRank,score = CrossPeakModel:currentGuildRankAndScore( )
        if not lvRank then
            -- 请求一次仙盟排行的数据
            CrossPeakModel:requestCrossPeakRank( 2,function( )
                self:updateGuidReward()
            end )
        else
            self:updateGuidReward()
        end
    end
end
function CrosspeakRewardView:updateBtnsShow()
    for i = 1,4 do
        local btn_mc = self.panel_yeqian["mc_"..i]
        btn_mc:showFrame(1)
        local btn = btn_mc.currentView.btn_1
        btn:setTap(c_func(self.btnsTap,self,i))
        if i == 1 then
            -- 判断是否有红点
            local isShow = CrossPeakModel:isShowSegmentRed()
            btn_mc.currentView.panel_hongdian:visible(isShow)
        else
            btn_mc.currentView.panel_hongdian:visible(false)
        end
    end
    local btn_mc = self.panel_yeqian["mc_"..self.currentType]
    btn_mc:showFrame(2)
end
function CrosspeakRewardView:btnsTap(_type)
    self.currentType = _type
    self:initUI( )
    self:updateBtnsShow()
end

-- 0 不可领取 1 已经领取 2 可领取
function CrosspeakRewardView:isCanGetReward(data )
    local conditon = data.gainCondition
    conditon = conditon[1]
    local num = conditon.num
    local num1 = 0
    local iscan = false
    local isGete = false
    if conditon.id == 1 then
        -- 对战次数
        num1 = CrossPeakModel:getTiaozhanNum( )
    elseif conditon.id == 2 then
        -- 胜场次数
        num1 = CrossPeakModel:getWinNum( )
    end 

    local activity = CrossPeakModel:getActivityReward(data.id )
    if not activity then
        if num1 >= num then
            return 2
        else
            return 0
        end
    else
        return 1
    end
    
end
function CrosspeakRewardView:sortActiveFunc(a,b)
    local aRewad = self:isCanGetReward(a)
    local bRewad = self:isCanGetReward(b)
    if aRewad == bRewad then
        return not self:sortFunc(a,b)
    elseif aRewad == 2 then
        return true
    elseif aRewad == 1 then
        return false
    elseif aRewad == 0 then
        if bRewad == 1 then
            return true
        elseif bRewad == 2 then
            return false
        end
    end
    return false
end


function CrosspeakRewardView:sortFunc(a,b)
    
    local aid = a.id or a.hid
    local bid = b.id or b.hid
    if tonumber(bid)<tonumber(aid) then
        return true
    end
    return false
end

function CrosspeakRewardView:updateActiveReward(  )
    self.mc_1:showFrame(1)
    local rewardPanel = self.mc_1.currentView.panel_alat
    -- 胜利次数
    local winNum = CrossPeakModel:getWinNum( )
    rewardPanel.txt_2:setString(winNum)
    -- 击倒次数
    local jidaoNum = CrossPeakModel:getJidaoNum()
    rewardPanel.txt_4:setString(jidaoNum)

    -- 初始活跃奖励列表
    local data = FuncCrosspeak.getCrossPeakActiveReward()
    local rewardData = {}
    for i,v in pairs(data) do
        table.insert(rewardData, v)
    end
    
    table.sort(rewardData,c_func(self.sortActiveFunc,self))
    local itemPanel = rewardPanel.panel_ge
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateActiveItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateActiveItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = rewardData,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 932, height = 120},
        },
    };
    rewardPanel.scroll_1:styleFill(_scrollParams);
    rewardPanel.scroll_1:hideDragBar()
end

function CrosspeakRewardView:updateActiveItem( view,data )
    local conditon = data.gainCondition
    conditon = conditon[1]
    local num = conditon.num
    local num1 = 0
    local iscan = false
    local isGete = false
    if conditon.id == 3 then
        -- 击倒次数
        num1 = CrossPeakModel:getJidaoNum( )
        view.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_007"))
        view.txt_2:setString(num)
    elseif conditon.id == 2 then
        -- 胜场次数
        num1 = CrossPeakModel:getWinNum( )
        view.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_008"))
        view.txt_2:setString(num)
    end 
    if num1 >= num then
        local activity = CrossPeakModel:getActivityReward(data.id )
        if not activity then
            view.mc_btn:showFrame(1)
            iscan = true
        else
            view.mc_btn:showFrame(3)
            iscan = false
            isGete = true
        end
    else
        view.mc_btn:showFrame(2)
        FilterTools.setGrayFilter(view.mc_btn.currentView.btn_1)
    end
    if not isGete then
        local btn1 = view.mc_btn.currentView.btn_1
        btn1:setTap(c_func(self.btnRewardTap,self,iscan,conditon.id,data))
    end
    
    view.mc_daoju:showFrame(1)
    local rewardPanel = view.mc_daoju.currentView
    -- 奖励
    for i=1,5 do
        rewardPanel["UI_"..i]:visible(false)
    end
    for i,v in pairs(data.reward) do
        local rewardView = rewardPanel["UI_"..i]
        rewardView:visible(true)
        local itemData = v
        rewardView:setResItemData({reward = itemData})
        rewardView:showResItemName(false)
        rewardView:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
    end
end

function CrosspeakRewardView:btnRewardTap(_isCan,_type,data )
    if _isCan then
        CrossPeakServer:getActiveRewardServer(data.id,c_func(self.receiveTapCallBack,self))
        WindowControler:showWindow("RewardSmallBgView", data.reward);
    else
        if _type == 1 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2003")) 
        elseif _type == 2 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2004")) 
        end
    end
end
function CrosspeakRewardView:receiveTapCallBack( params )
    if params.result then
        self:initUI( )
        self:updateBtnsShow()
        -- local rewardPanel = self.mc_1.currentView.panel_alat
        -- rewardPanel.scroll_1:refreshCellView( 1 )
    end
end

function CrosspeakRewardView:updateRankReward(  )
    self.mc_1:showFrame(3)
    local rewardPanel = self.mc_1.currentView.panel_bfly
    -- 当前排名
    local currentRank = CrossPeakModel:getCurrentRank( )
    echo("--------------currentRank ===========")
    if currentRank == 0 then
        rewardPanel.txt_2:setString(GameConfig.getLanguage("#tid_crosspeak_006"))
        -- 时间
        rewardPanel.txt_4:visible(false)
        rewardPanel.txt_5:visible(false)
    else
        rewardPanel.txt_2:setString(currentRank)
        -- 时间
        rewardPanel.txt_4:visible(true)
        rewardPanel.txt_4:visible(GameConfig.getLanguage("#tid_crosspeak_009"))
        rewardPanel.txt_5:visible(true)
        rewardPanel.txt_5:setString(GameConfig.getLanguage("#tid_crosspeak_010"))
    end
    rewardPanel.txt_3:visible(false)
    
    
    --奖励
    for i=1,5 do
        rewardPanel["UI_"..i]:visible(false)
    end
    local currentRewardData = FuncCrosspeak.getRewardByRank( currentRank )
    for i,v in pairs(currentRewardData) do
        local rewardView = rewardPanel["UI_"..i]
        rewardView:visible(true)
        local itemData = v
        rewardView:setResItemData({reward = itemData})
        rewardView:showResItemName(false)
        rewardView:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
    end


    -- 初始排行奖励列表
    local data = FuncCrosspeak.getCrossPeakRankReward()
    local rankData = {}
    for i,v in pairs(data) do
        table.insert(rankData, v)
    end
    local _sortFunc = function ( a,b )
        if a.rankStart < b.rankStart then
            return true
        end
        return false
    end
    table.sort(rankData,_sortFunc)
    local itemPanel = rewardPanel.panel_ge
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateRankItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateRankItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = rankData,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 932, height = 120},
        },
    };
    rewardPanel.scroll_1:styleFill(_scrollParams);
    rewardPanel.scroll_1:hideDragBar()
end
function CrosspeakRewardView:updateRankItem( view,data )
    view.mc_1:showFrame(6)
    local rankTxt = view.mc_1.currentView.rich_1
    local str1 = GameConfig.getLanguage("#tid_crosspeak_012")
    local rankStr = string.format(str1,tostring(1))
    if data.rankStart == data.rank then
        rankStr = string.format(str1,tostring(data.rank))
    else
        local str2 = GameConfig.getLanguage("#tid_crosspeak_013")
        rankStr = string.format(str1,tostring(data.rankStart),tostring(data.rank))
    end
    rankTxt:setString(rankStr)

    view.mc_daoju:showFrame(1)
    local rewardPanel = view.mc_daoju.currentView
    -- 奖励
    for i=1,5 do
        rewardPanel["UI_"..i]:visible(false)
    end
    for i,v in pairs(data.reward) do
        local rewardView = rewardPanel["UI_"..i]
        rewardView:visible(true)
        local itemData = v
        rewardView:setResItemData({reward = itemData})
        rewardView:showResItemName(false)
        rewardView:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
    end
end

function CrosspeakRewardView:updateSegmentReward(  )
    self.mc_1:showFrame(2)
    local rewardPanel = self.mc_1.currentView.panel_hgws

    -- 初始排行奖励列表
    local data = FuncCrosspeak.getCrossPeakSegmentData()
    local segmentData = {}
    for i,v in pairs(data) do
        table.insert(segmentData, v)
    end
    table.sort(segmentData,c_func(self.sortFunc,self))
    local itemPanel = rewardPanel.panel_ge
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateSegmentItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateSegmentItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = segmentData,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 932, height = 120},
        },
    };
    local index = 1
    local maxSeg = CrossPeakModel:getMaxSegment( )
    for i,v in pairs(segmentData) do
        if tonumber(v.id) == tonumber(maxSeg) then
            index = i
        end
    end
    rewardPanel.scroll_1:styleFill(_scrollParams);
    rewardPanel.scroll_1:hideDragBar()
    rewardPanel.scroll_1:gotoTargetPos(index,1)
end
function CrosspeakRewardView:updateSegmentItem( view,data )
    local rewardPanel = view
    -- 奖励
    for i=1,6 do
        rewardPanel["UI_"..i]:visible(false)
    end
    -- 最高奖励
    local maxReward = data.seasonSegmentReward
    for i,v in pairs(maxReward) do
        local rewardView = rewardPanel["UI_"..i]
        rewardView:visible(true)
        local itemData = v
        rewardView:setResItemData({reward = itemData})
        rewardView:showResItemName(false)
        rewardView:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
    end
    -- 晋升奖励
    local upReward = data.segmentUpReward or {}
    for i,v in pairs(upReward) do
        local rewardView = rewardPanel["UI_"..(i+3)]
        rewardView:visible(true)
        local itemData = v
        rewardView:setResItemData({reward = itemData})
        rewardView:showResItemName(false)
        rewardView:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
    end
    -- 图标
    local iconPath = FuncRes.crossSegmentIcon( data.segmentIcon )
    local icon = display.newSprite(iconPath)
    rewardPanel.ctn_1:removeAllChildren()
    rewardPanel.ctn_1:addChild(icon)
    icon:scale(0.3)
    --name
    rewardPanel.mc_lv:visible(false)
    -- rewardPanel.mc_lv:showFrame(tonumber(data.id))
    --maxSeg
    local maxSeg = CrossPeakModel:getMaxSegment( )
    if tonumber(data.id) == tonumber(maxSeg) then
        rewardPanel.panel_zg:visible(true)
    else
        rewardPanel.panel_zg:visible(false)
    end
end

-------------------------------------------------------------------------
----------------------------仙盟奖励相关---------------------------------
-------------------------------------------------------------------------
-- 仙盟奖励
function CrosspeakRewardView:updateGuidReward()
    -- 默认选中 排行
    self.currentGuidType = 1
    self.mc_1:showFrame(4)
    local guildPanel = self.mc_1.currentView

    local mc_gph = guildPanel.mc_paimingjiangli
    local mc_gjl = guildPanel.mc_leijijiangli
    mc_gph:showFrame(1)
    local btn1 = mc_gph.currentView.btn_1
    btn1:setTap(function (  )
        self.currentGuidType = 1
        self:updateGuidShow( guildPanel )
    end)
    mc_gjl:showFrame(1)
    local btn2 = mc_gjl.currentView.btn_1
    btn2:setTap(function (  )
        self.currentGuidType = 2
        echo("ssssssss----------ssssssss")
        self:updateGuidShow( guildPanel )
    end)

    -- local btn_ph = guildPanel.btn_paihang
    -- btn_ph:setTap(function (  )
    --     CrossPeakModel:clearCrossPeakRankData( )
    --     CrossPeakModel:requestCrossPeakRank( 1 )
    -- end)
    self:updateGuidShow( guildPanel )
    -- btn_ph:visible(false)
end
function CrosspeakRewardView:updateGuidShow( guildPanel )

    local mc_gph = guildPanel.mc_paimingjiangli
    local mc_gjl = guildPanel.mc_leijijiangli
    local txt_des = guildPanel.txt_1
    local txt_ph = guildPanel.txt_3
    -- local btn_ph = guildPanel.btn_paihang
    local scroll_gph = guildPanel.scroll_1
    local scroll_gjl = guildPanel.scroll_2 
    local str = ""
    if self.currentGuidType == 1 then
        mc_gph:showFrame(2)
        mc_gjl:showFrame(1)
        -- btn_ph:visible(true)
        str = GameConfig.getLanguage("#tid_corsspeak_instruction_3002")
        scroll_gph:visible(true)
        scroll_gjl:visible(false)
        self:initGuildRank( guildPanel )
        -- 当前排行
        local lvRank,score = CrossPeakModel:currentGuildRankAndScore( )
        -- echoError ("aa===",lvRank,score,"s===")
        if lvRank and tonumber(lvRank) > 0 then
            txt_ph:visible(true)
            txt_ph:setString(GameConfig.getLanguageWithSwap("#tid_crosspeak_046",lvRank))
        else
            txt_ph:visible(true)
            txt_ph:setString(GameConfig.getLanguage("#tid_crosspeak_045"))
        end
        guildPanel.txt_2:visible(true)
        guildPanel.panel_pdd:visible(true)
    else
        mc_gph:showFrame(1)
        mc_gjl:showFrame(2)
        -- btn_ph:visible(false)
        str = GameConfig.getLanguage("#tid_corsspeak_instruction_3003")
        scroll_gph:visible(false)
        scroll_gjl:visible(true)
        self:initGuildReward( guildPanel )

        txt_ph:visible(false)
        guildPanel.txt_2:visible(false)
        guildPanel.panel_pdd:visible(false)
    end
    txt_des:setString(str)



end
function CrosspeakRewardView:initGuildRank( guildPanel )
    local cfgData = FuncCrosspeak.getGuildRankData( )
    local data = {}
    for i,v in pairs(cfgData) do
        table.insert(data,v)
    end
    local _funcSort = function ( a,b )
        if a.rankStart < b.rankStart then
            return true
        end
        return false
    end
    table.sort(data,_funcSort)


    local score_gph = guildPanel.scroll_1
    guildPanel.mc_1:showFrame(1)
    local itemPanel = guildPanel.mc_1.currentView.panel_1
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateGPHItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateGPHItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = data,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 932, height = 120},
        },
    };

    score_gph:styleFill(_scrollParams);
    score_gph:hideDragBar()
    score_gph:gotoTargetPos(1,1)
end
function CrosspeakRewardView:updateGPHItem( view, itemData )
    local panel = view.panel_1
    local data = itemData

    local str = ""
    if data.rankStart == data.rank then
        str = string.format("第%s名",data.rank)
    else
        str = string.format("第%s-%s名",data.rankStart,data.rank)
    end

    panel.txt_1:setString(str)

    local reward = data.reward
    for i = 1,4 do
        panel["UI_"..i]:visible(false)
    end
    for i,v in pairs(reward) do
        local panelRewad = panel["UI_"..i]
        panelRewad:visible(true)

        local itemData = v
        panelRewad:setResItemData({reward = itemData})
        panelRewad:showResItemName(false)
        panelRewad:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(panelRewad, resType, needNum, resId,itemData,true,true)

    end
end

function CrosspeakRewardView:initGuildReward( guildPanel )
    local cfgData = FuncCrosspeak.getGuildAccumulateData( )
    local data = {}
    for i,v in pairs(cfgData) do
        table.insert(data,v)
    end
    local _funcSort = function ( a,b )
        if tonumber(a.hid) < tonumber(b.hid) then
            return true
        end
        return false
    end
    table.sort(data,_funcSort)


    local score_gjl = guildPanel.scroll_2
    guildPanel.mc_1:showFrame(2)
    local itemPanel = guildPanel.mc_1.currentView.panel_1
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateGJLItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateGJLItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = data,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 932, height = 120},
        },
    };

    score_gjl:styleFill(_scrollParams);
    score_gjl:hideDragBar()
    score_gjl:gotoTargetPos(1,1)
end
function CrosspeakRewardView:updateGJLItem( view, itemData )
    local panel = view.panel_1
    local data = itemData

    -- 当前
    local currentNum = CrossPeakModel:getGuildKillPartnerNum(  )
    -- 目标
    local goalNum = data.hitPartnerNum

    panel.txt_2:setString(currentNum)
    panel.txt_3:setString("/"..goalNum)
    -- panel.txt_2:setString(currentNum.."/"..goalNum)

    if currentNum >= goalNum then
        panel.mc_dacheng:showFrame(2)
    else
        panel.mc_dacheng:showFrame(1)
    end

    local reward = data.reward
    for i = 1,4 do
        panel["UI_"..i]:visible(false)
    end
    for i,v in pairs(reward) do
        if i > 3 then
            break
        end
        local panelRewad = panel["UI_"..i]
        panelRewad:visible(true)

        local itemData = v
        panelRewad:setResItemData({reward = itemData})
        panelRewad:showResItemName(false)
        panelRewad:showResItemNum(true)
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
        FuncCommUI.regesitShowResView(panelRewad, resType, needNum, resId,itemData,true,true)

    end
end




-------------------------------------------------------------------------
----------------------------仙盟奖励END---------------------------------
-------------------------------------------------------------------------
function CrosspeakRewardView:closeUI( )
    self:startHide()
end

return CrosspeakRewardView
