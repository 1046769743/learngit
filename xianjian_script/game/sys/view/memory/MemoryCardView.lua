--zhangqiang
--2018.3.20 

local MemoryCardView = class("MemoryCardView", UIBase);


function MemoryCardView:ctor(winName,cardId,memoryId)
    MemoryCardView.super.ctor(self, winName);
    self.cardId = cardId
    self.memoryId = memoryId
end

--分辨率适配
function MemoryCardView:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_pl, UIAlignTypes.RightBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_sx, UIAlignTypes.LeftBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3, UIAlignTypes.Right);

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop);

end
function MemoryCardView:registerEvent()
    MemoryCardView.super.registerEvent();

    -- 退出
    self.btn_back:setTap(c_func(self.close,self))
    -- -- 详情
    -- self.btn_guize:setTap(c_func(self.clickLabel,self))
    -- 左右按钮
    EventControler:addEventListener(MemoryEvent.MEMORY_CARD_SHARE_EVENT,self.updateBtn,self)

    
end


function MemoryCardView:updateChangeCardBtnShow( )
    local allCard = self:getAllShowCards()
    if table.length(allCard) <= 1 then
        self.btn_2:visible(false)
        self.btn_3:visible(false)
    else
        local currentIndex = 1
        for i = 1,#allCard do
            if allCard[i] == self.cardId then
                currentIndex = i
            end
        end
        self.currentIndex = currentIndex
        if (currentIndex-1) > 0 then
            self.btn_2:visible(true)
        else
            self.btn_2:visible(false)
        end
        if (currentIndex+1) > #allCard then
            self.btn_3:visible(false)
        else
            self.btn_3:visible(true)
        end
    end
    self.btn_2:setTap(c_func(self.changeCardBtn,self,-1))
    self.btn_3:setTap(c_func(self.changeCardBtn,self,1))

end

function MemoryCardView:changeCardBtn(_type)
    local allCard = self:getAllShowCards()
    if _type == 1 then
        if (self.currentIndex+1) > #allCard then
            return
        end
    elseif _type == -1 then
        if (self.currentIndex-1) <= 0 then
            return
        end
    end
    
    self.currentIndex = self.currentIndex + _type
    self.cardId = allCard[self.currentIndex]
    self:updateUI( self.cardId )
    self:updateChangeCardBtnShow( )
end


function MemoryCardView:loadUIComplete()
	self:registerEvent();
    self:uiAdjust()
    self:updateUI( self.cardId )
    self:updateChangeCardBtnShow()
end 

function MemoryCardView:getAllShowCards()
    -- 所有ke显示的卡片
    local allShowCards = {}
    local data = FuncMemoryCard.getMemoryDataById(self.memoryId)
    local cards = data.pictureId
    for i,v in pairs(cards) do
        if MemoryCardModel:checkCardCanShow(v) then
            table.insert(allShowCards,v)
        end
    end
    return allShowCards
end

function MemoryCardView:updateUI( cardId )
    
    self:updateCard(cardId)

    self:updateBtn()
        
    self:updateAttr()
end

function MemoryCardView:updateCard( cardId )
    self.UI_crardinfo:updateUI(cardId)
end

function MemoryCardView:updateAttr()
    -- 判断是否已激活
    -- if MemoryCardModel:checkCardFinishJiHuo(self.cardId) then
    --     self.panel_sx.txt_1:setString(GameConfig.getLanguage("#tid_memory_013"))
    --     self.txt_4:visible(false)
    -- else
    --     self.panel_sx.txt_1:setString(GameConfig.getLanguage("#tid_memory_014"))
    --     self.txt_4:visible(true)
    -- end
    

    local cardData = FuncMemoryCard.getMemoryCardDataById(self.cardId)
    local targetFrame = FuncMemoryCard.getTypeFrame( cardData.target[1] )
    self.panel_sx.mc_qixia:showFrame(targetFrame)

    local attrT = FuncMemoryCard.getCardAttrById( self.cardId )
    local attrStr = ""
    for i,v in pairs(attrT) do
        local value = v.value
        if v.mode == 2 then
            value = (v.value/100).."%"
        end
        attrStr = attrStr .. v.name .. "+" .. value .. "  "
    end
    self.panel_sx.txt_3:setString(attrStr)
end

function MemoryCardView:updateBtn( )
    local memoryId = self.memoryId
    local cardId = self.cardId
    -- 评论 一直存在
    self.btn_pl:setTap(c_func(self.openPinglunTap,self))

    -- 激活 or 分享
    local mc_btn = self.mc_4
    local isJiHuo = MemoryCardModel:checkCardFinishJiHuo(cardId)
    self:removeChild(self.node)
    self.node = display.newNode()
    self.node:setContentSize(cc.size(843,463))
    self.node:pos(155,-560)
    self.node:anchor(0,0)
    self.node:addto(self,1)
    self.node:setTouchEnabled(true)
    -- local color = color or cc.c4b(255,0,0,120)
    -- local layer = cc.LayerColor:create(color)
    -- self.node:addChild(layer)
    -- layer:setContentSize(cc.size(843,463) )
    if isJiHuo then
        mc_btn:showFrame(2)
        local btn = mc_btn.currentView.btn_1
        local txt = mc_btn.currentView.txt_2
        btn:setTap(c_func(self.shareTap,self))
        self.node:setTouchedFunc(c_func(self.shareTap,self))
    else
        mc_btn:showFrame(1)
        local btn = mc_btn.currentView.btn_1
        local panelRed = mc_btn.currentView.panel_red
        self.node:setTouchedFunc(c_func(self.gotoGetWay,self))
        -- 判断是否可激活
        local canLight = MemoryCardModel:checkCardCanJiHuo(cardId)
        if canLight then
            FilterTools.clearFilter(btn)
            panelRed:visible(true)
        else
            FilterTools.setGrayFilter(btn)
            panelRed:visible(false)
        end
        btn:setTap(c_func(self.jiHuoTap,self))

        local num = FuncDataSetting.getMemoryShareRewardNum(  )
        mc_btn.currentView.panel_1.txt_2:setString(num)

    end
end

function MemoryCardView:gotoGetWay()
    local methodTips = FuncMemoryCard.getMethodString(self.cardId)
    WindowControler:showTips(methodTips)
end

function MemoryCardView:jiHuoTap( )
    local cardId = self.cardId
    local canJihuo,canLightT = MemoryCardModel:checkCardCanJiHuo(cardId)
    if canJihuo then
        -- 是否全部点亮
        self.power = MemoryCardModel:getMemoryPower( )
        if #canLightT > 0 then
            for i,v in pairs(canLightT) do
                MemoryCardModel:setChipLightById(v)
            end
            MemoryServer:sendActivation(self.cardId,c_func(self.jiHuoTapCallBack,self))
        else
            MemoryServer:sendActivation(self.cardId,c_func(self.jiHuoTapCallBack,self))
        end
    else
        echo("碎片不足= ==============")
        WindowControler:showTips("碎片不足")
    end
end

function MemoryCardView:jiHuoTapCallBack(event)
    if event.result then
        echo("激活成功！！！！！！！！！")
        local power = MemoryCardModel:getMemoryPower( )
        if power > self.power then
            FuncCommUI.showPowerChangeArmature(self.power or 10, power or 10 );
        end

        WindowControler:showTips(GameConfig.getLanguage("#tid_memory_015"))
        
        MemoryServer:shareMemoryCard(self.cardId,c_func(self.rewardQuestCallBack,self))
    else
        local code = event.error.code
        if code == 680101 then
            -- 情景卡已经激活  
            self:close()
        end
    end
end

-- 新需求 激活成功获得奖励
function MemoryCardView:rewardQuestCallBack( params )
    if params.result then
        local num = FuncDataSetting.getMemoryShareRewardNum(  )
        local str = "4,"..num
        local reward = {str}

        local showShareFunc = function ( ... )
            local shareView = WindowControler:showWindow("MemoryCardShareView",self.cardId)
            -- shareView:hideShareBtn( )
            self:updateUI( self.cardId )
        end

        FuncCommUI.startFullScreenRewardView(reward,showShareFunc)

        EventControler:dispatchEvent(MemoryEvent.MEMORY_CARD_SHARE_EVENT)
    end
end


function MemoryCardView:shareTap()
    echo("开始分享-=------------")
    WindowControler:showWindow("MemoryCardShareView",self.cardId)
    
end

function MemoryCardView:openPinglunTap( )
    local arrayData = {
        systemName = "memorys",
        diifID = self.cardId,
        flagCommentOnly = 1,
        title = "评论",
        hideTC = true,
    }
    RankAndcommentsControler:showQingJingCommentsUI(arrayData)
    -- 
    -- WindowControler:showWindow("MemoryPingLunView",self.cardId,self.memoryId)
    -- WindowControler:showTutoralWindow("MemoryView","1001")
end

function MemoryCardView:close()
    self:startHide()
end

return MemoryCardView;