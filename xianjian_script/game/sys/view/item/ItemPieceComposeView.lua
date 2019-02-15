--[[
	Author: 张燕广
	Date:2017-07-14
	Description: 道具碎片合成结果界面
]]

local ItemPieceComposeView = class("ItemPieceComposeView", UIBase);

function ItemPieceComposeView:ctor(winName,data)
    ItemPieceComposeView.super.ctor(self, winName)

    self.rewardData = data.reward
end

function ItemPieceComposeView:loadUIComplete()
	self:registerEvent()
	self:initData()
    self:initView()
	self:updateUI()
end 

function ItemPieceComposeView:registerEvent()
	ItemPieceComposeView.super.registerEvent(self);
    -- 确定按钮
    self.btn_2:setTap(c_func(self.startHide,self))
end

function ItemPieceComposeView:initData()
	self.itemNum = #self.rewardData
end

function ItemPieceComposeView:initView()
    FuncCommUI.addBlackBg(self.widthScreenOffset,self._root)
    self.btn_2:setVisible(false)
end

-- 隐藏所有item
function ItemPieceComposeView:hideAllItem()
    for i=1,self.itemNum do
        self.itemPanels["panel_" .. i]:setVisible(false)
    end
end

function ItemPieceComposeView:updateUI()
	AudioModel:playSound(MusicConfig.s_com_reward);

    self.mc_shuliang:showFrame(self.itemNum)
    self.itemPanels = self.mc_shuliang.currentView

    -- 隐藏所有道具item
    self:hideAllItem()

    self.UI_1.ctn_1:removeAllChildren()
    self.UI_1.ctn_3:removeAllChildren()
    FuncCommUI.addCommonBgEffect(self.UI_1.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, nil, true, true, -85)
    -- FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)

    self:delayCall(c_func(self.showRewards,self),0.1)
end

function ItemPieceComposeView:showRewards()
    for i=1,self.itemNum do
        local itemView = self.itemPanels["panel_" .. i]
        local rewardStr = self.rewardData[i]

        local intervalTime = 2 / GameVars.ARMATURERATE
        local delayTime = intervalTime * i

        self:delayShowItem(itemView,rewardStr,delayTime)

        if i == self.itemNum then
            self:delayCall(c_func(self.showActionBtn,self,true),delayTime + intervalTime)
        end
    end
end

-- 延迟显示item
function ItemPieceComposeView:delayShowItem(itemView,rewardStr,delayTime)
    local callBack = function()
        local params = {
            reward = rewardStr
        }
        itemView.UI_1:setResItemData(params)
        itemView.UI_1:showResItemName(true,true,1)
        itemView:setVisible(true)

        itemView.UI_1:pos(7,-5)
        FuncCommUI.playRewardItemAnim(itemView.ctn_1,itemView.UI_1)

        local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(rewardStr)
        FuncCommUI.regesitShowResView(itemView.UI_1, resType, needNum, resId, rewardStr, true, true)
        itemView.UI_1:setTouchSwallowEnabled(true)
    end

    self:delayCall(c_func(callBack, self),delayTime)
end

function ItemPieceComposeView:showActionBtn(visible)
    self.btn_2:setVisible(visible)
end

function ItemPieceComposeView:deleteMe()
	ItemPieceComposeView.super.deleteMe(self);
end

return ItemPieceComposeView;
