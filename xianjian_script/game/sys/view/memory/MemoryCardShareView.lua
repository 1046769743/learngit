--zhangqiang

local MemoryCardShareView = class("MemoryCardShareView", UIBase);


function MemoryCardShareView:ctor(winName,cardId)
    MemoryCardShareView.super.ctor(self, winName);
    self.cardId = cardId
end

--分辨率适配
function MemoryCardShareView:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_wx, UIAlignTypes.RightBottom);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_pyq, UIAlignTypes.RightBottom);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_share, UIAlignTypes.RightTop);
end
function MemoryCardShareView:registerEvent()
    MemoryCardShareView.super.registerEvent();

    -- 退出
    self.btn_close:setTap(c_func(self.close,self))
    -- if self.btn_close then
    --    self.btn_close:setVisible(false)
    -- end
    -- 微信
    -- self.UI_share.btn_weixin:setTouchedFunc(c_func(self.pressShareBtn,self,1))
    -- self.UI_share.btn_pengyouquan:setTouchedFunc(c_func(self.pressShareBtn,self,2))
    -- self.UI_share.btn_weibo:setTouchedFunc(c_func(self.pressShareBtn,self,3))

    -- self:registClickClose()
    
end

function MemoryCardShareView:pressShareBtn(index )
    -- echo("微信分享成功后")
    self:shareQuest( )
end


function MemoryCardShareView:shareQuest( )
    -- 判断是否已领取分享奖励
    if not MemoryCardModel:checkCardFinishShare(self.cardId) then
        MemoryServer:shareMemoryCard(self.cardId,c_func(self.shareQuestCallBack,self))
    else
        --直接关闭
        self:close()
    end
end
function MemoryCardShareView:shareQuestCallBack( params )
    if params.result then
        local num = FuncDataSetting.getMemoryShareRewardNum(  )
        local str = "4,"..num
        local reward = {str}
        FuncCommUI.startFullScreenRewardView(reward)
        -- EventControler:dispatchEvent(MemoryEvent.MEMORY_CARD_SHARE_EVENT)
    end
    -- 分享成不成功 都关闭UI
    self:close()
end

function MemoryCardShareView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI( )
end 



function MemoryCardShareView:updateUI( )

    local getShareNode = function (  )
        local box = self._shareNode:getContainerBoxToParent()
        local contentInfo = {}
        local width = box.width
        local height = box.height
        
        -- 截屏内容如果包含了全屏背景，需要做如下处理
        contentInfo.offsetX = -(box.x + GameVars.UIOffsetX)
        contentInfo.offsetY = -(box.y + GameVars.UIOffsetY)

        self._shareNode.contentInfo = contentInfo
        
        return self._shareNode
    end
    self._shareNode = self.ctn_card
    self.UI_share:setShareCallBack(getShareNode,c_func(self.shareQuest,self) )

    -- 诗
    local cardData = FuncMemoryCard.getMemoryCardDataById(self.cardId)
    -- local poem = cardData.poem
    -- self.txt_1:setString(GameConfig.getLanguage(poem))

    -- 情景卡
    local cardIconPath = FuncRes.memoryCardIcon( cardData.source )
    local cardIconSp = display.newSprite(cardIconPath)

    -- self:changeBg(cardData.source)

    -- self.ctn_card:removeAllChildren()
    -- self.ctn_card:addChild(cardIconSp)

    local wenziIcon = FuncRes.memoryCardZhezhaoIcon( cardData.txt )
    local wenziSp = display.newSprite(wenziIcon)
    local txtLocation = cardData.txtLocation
    wenziSp:pos(txtLocation[1],txtLocation[2])

    self.ctn_card:removeAllChildren()
    
    self.ctn_card:addChild(cardIconSp)
    self.ctn_card:addChild(wenziSp)
    

end

--隐藏按钮
function MemoryCardShareView:hideShareBtn( )
    -- 微信
    -- self.txt_wx:visible(false)
    -- 朋友圈
    -- self.txt_pyq:visible(false)
    self.UI_share:visible(false)
end

function MemoryCardShareView:close()
    self:startHide()
end


return MemoryCardShareView;