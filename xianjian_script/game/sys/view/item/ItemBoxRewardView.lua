local ItemBoxRewardView = class("ItemBoxRewardView", UIBase);

function ItemBoxRewardView:ctor(winName,data)
    ItemBoxRewardView.super.ctor(self, winName);
    -- 开宝箱
    self.rewardData = data.reward
    self:changeData(self.rewardData)

    -- dump(self.rewardData, "\n\nself.rewardData==")
    self.boxId = data.itemId
    self.openBoxType = data.itemNum

    self.leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    -- 是否正在开宝箱中
    self.isOpeningBox = false
end

function ItemBoxRewardView:loadUIComplete()
	self:registerEvent();
    self:initData()
    self:initView()
    self:updateUI()

end 
function ItemBoxRewardView:changeData(data)
    local partner_table = {}
    for i,v in ipairs(data) do
        local str_table = string.split(v, ",")
        if tostring(str_table[1]) == FuncDataResource.RES_TYPE.PARTNER then
            local partnerId = str_table[2]
            local param = {
                index = i,
                partnerId = partnerId,
            }
            table.insert(partner_table, param)
        end
    end

    if #partner_table > 1 then
        local i = 1
        while i <= #partner_table - 1 do
            for j = i + 1, #partner_table do
                if partner_table[j].partnerId == partner_table[i].partnerId then
                    local partnerId = partner_table[i].partnerId
                    local partnerData = FuncPartner.getPartnerById(partnerId)
                    local debrisNum = partnerData.sameCardDebris
                    self.rewardData[partner_table[j].index] = FuncDataResource.RES_TYPE.ITEM..","..partnerId..","..debrisNum                 
                end

                i = i + 1
            end
        end    
    end
    
end

function ItemBoxRewardView:initData()
    self.itemNum = #self.rewardData
    self.anim = {}
end

function ItemBoxRewardView:initView()
    FuncCommUI.addBlackBg(self.widthScreenOffset,self._root)

    self:initAnim()
end

function ItemBoxRewardView:initAnim()
    --加载特效
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)
end

function ItemBoxRewardView:registerEvent()
	ItemBoxRewardView.super.registerEvent();
end

function ItemBoxRewardView:updateUI()
    AudioModel:playSound(MusicConfig.s_com_reward);

    self.mc_x1.currentView.mc_shuliang:showFrame(self.itemNum)
    self.itemPanels = self.mc_x1.currentView.mc_shuliang.currentView
    if #self.anim ~= self.itemNum then
        self.anim = {}
    end
    self:showActionBtn(false)
    self:hideAllItem()
    self.UI_1.ctn_1:removeAllChildren()
    self.UI_1.ctn_3:removeAllChildren()
    -- if not self.huodeAnim then
    self.huodeAnim = FuncCommUI.addCommonBgEffect(self.UI_1.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, nil, true, true, -85)
    -- else
    --     self.huodeAnim:startPlay(false, false)
    -- end
    
    -- FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.GET,1)
    self:updateItemView(1)
    -- self:delayCall(c_func(self.showRewards,self),0.1)
end

function ItemBoxRewardView:showRewards()

    for i=1,self.itemNum do
        local itemView = self.itemPanels["panel_" .. i]
        local rewardStr = self.rewardData[i]

        local intervalTime = 2 / GameVars.ARMATURERATE
        local delayTime = intervalTime * i
        local _callBack = function (rewardStr)
            local str_table = string.split(rewardStr, ",")
            if tostring(str_table[1]) == FuncDataResource.RES_TYPE.PARTNER then
                local partnerId = str_table[2]
                PartnerModel:showPartnerSkin(partnerId)
            end
        end
        self:delayShowItem(itemView,rewardStr,delayTime,c_func(_callBack, rewardStr, self))

        if i == self.itemNum then
            self:delayCall(c_func(self.showActionBtn,self,true), delayTime + intervalTime)
        end
    end
end

function ItemBoxRewardView:updateItemView(index)
    local itemView = self.itemPanels["panel_" .. index]
    local rewardStr = self.rewardData[index]
    local params = {
        reward = rewardStr
    }
    self.index = index
    itemView.UI_1:setResItemData(params)
    itemView.UI_1:showResItemName(true,true)
    itemView.UI_1:showResItemNameWithQuality()
    itemView:setVisible(true)
    
    itemView.UI_1:pos(8,-5)

    local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(rewardStr)
    FuncCommUI.regesitShowResView(itemView.UI_1, resType, needNum, resId, rewardStr, true, true)
    itemView.UI_1:setTouchSwallowEnabled(true)
    -- dump(self.anim, "\n\nself.anim==")
    if not self.anim[index] then
        self.anim[index] = FuncCommUI.playRewardItemAnim(itemView.ctn_1,itemView.UI_1,c_func(self.updateNextItemView, self), 4)
    else
        self.anim[index]:startPlay()

        self:delayCall(c_func(self.updateNextItemView, self), 4 / GameVars.GAMEFRAMERATE)
    end
    
end

function ItemBoxRewardView:updateNextItemView()
    local rewardStr = self.rewardData[self.index]
    if not rewardStr then
        return 
    end
    local str_table = string.split(rewardStr, ",")
    if tostring(str_table[1]) == FuncDataResource.RES_TYPE.PARTNER then
        local partnerId = str_table[2]
        local delayShow = function ()
            local params = {
                id = partnerId,
                skin = "1",
            }

            WindowControler:showWindow("PartnerSkinFirstShowView", params, function ()
                self.index = self.index + 1            
                if not self.rewardData[self.index] then
                    self:delayCall(c_func(self.showActionBtn, self, true), 0.1)
                    return 
                end
                
                self:updateItemView(self.index)
            end)
        end
        self:delayCall(c_func(delayShow), 0.5)
    else 
        self.index = self.index + 1      
        if not self.rewardData[self.index] then
            self:delayCall(c_func(self.showActionBtn, self, true), 0.1)
            return 
        end
        
        self:updateItemView(self.index)   
    end
end

function ItemBoxRewardView:showActionBtn(visible)
    -- 更新宝箱剩余数量
    self.leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    if self.leftBoxNum == 0 then
        self.mc_1:showFrame(2)
        self.mc_1.currentView.btn_2:setTap(c_func(self.close, self));
    else
        self.mc_1:showFrame(1)
        self.mc_1.currentView.btn_1:setTap(c_func(self.openBoxes, self));
        self.mc_1.currentView.btn_2:setTap(c_func(self.close, self));

        if self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_ONE then
            self.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("tid_bag_1001"))
        elseif self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_TEN then
            local showBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN
            if self.leftBoxNum < showBoxNum then
                showBoxNum = self.leftBoxNum
            end
            self.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_bag_1002",showBoxNum))
        end
    end

    self.mc_1:setVisible(visible)
end

-- 延迟显示item
function ItemBoxRewardView:delayShowItem(itemView,rewardStr,delayTime,callback)
    -- echo("\n\nrewardStr==", rewardStr)
    local callBack = function()
        local params = {
            reward = rewardStr
        }
        itemView.UI_1:setResItemData(params)
        itemView.UI_1:showResItemName(true,true,1)
        itemView:setVisible(true)

        itemView.UI_1:pos(6,-4)
        FuncCommUI.playRewardItemAnim(itemView.ctn_1,itemView.UI_1)
        if callback then
            self:delayCall(c_func(callback), 0.5)
        end
    end

    self:delayCall(c_func(callBack, self),delayTime)
    
end

-- 隐藏所有item
function ItemBoxRewardView:hideAllItem()
    for i=1,self.itemNum do
        self.itemPanels["panel_" .. i]:setVisible(false)
    end
end

-- 再开宝箱
function ItemBoxRewardView:openBoxes()
    if self.isOpeningBox then
        return
    end

    local leftBoxNum = ItemsModel:getItemNumById(self.boxId)
    local costBoxNum = 1
    -- 没有宝箱，关闭窗口
    if leftBoxNum < 1 then
        self:close()
        return 
    end

    self.reward_status = {}
    if tostring(self.boxId) == "2200" then
        local rewardData = FuncItem.getRewardData(self.boxId).info
        for i,v in ipairs(rewardData) do
            local str_table = string.split(v, ",")
            local partnerId = str_table[3]
            if PartnerModel:isHavedPatnner(partnerId) then
                table.insert(self.reward_status, tostring(partnerId))
            end
        end
    end
    -- 再抽之前先隐藏items
    self:hideAllItem()

    if self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_ONE then
        costBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_ONE
        local canUse = ItemsModel:checkItemUseCondition(self.boxId,costBoxNum)
        if canUse then
            self.isOpeningBox = true
            ItemServer:customItems(self.boxId, costBoxNum,c_func(self.openBoxesCallBack,self))
        end
    elseif self.openBoxType == ItemsModel.boxType.TYPE_BOX_NUM_TEN then
        costBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN
        local canUse = ItemsModel:checkItemUseCondition(self.boxId,costBoxNum)
        if not canUse then
            -- 不足10个宝箱，有几个开几个
            costBoxNum = leftBoxNum
        end

        self.isOpeningBox = true
        ItemServer:customItems(self.boxId, costBoxNum,c_func(self.openBoxesCallBack,self))
    end
end

-- 再开宝箱回调
function ItemBoxRewardView:openBoxesCallBack(event)
    self.isOpeningBox = false
    
    if event.result then
        self.rewardData = event.result.data.reward
        -- dump(self.rewardData, "\n\nself.rewardData==")
        -- dump(self.reward_status, "\n\nself.reward_status===")
        for i,v in ipairs(self.rewardData) do
            local str_table = string.split(v, ",")
            if tostring(str_table[1]) == FuncDataResource.RES_TYPE.PARTNER then
                local partnerId = str_table[2]
                if table.indexof(self.reward_status, partnerId) then
                    local partnerData = FuncPartner.getPartnerById(partnerId)
                    local debrisNum = partnerData.sameCardDebris
                    self.rewardData[i] = FuncDataResource.RES_TYPE.ITEM..","..partnerId..","..debrisNum
                end
            end
        end

        self:changeData(self.rewardData)
        -- dump(self.rewardData, "\n\nself.rewardData==")
        self.itemNum = #self.rewardData
        self:updateUI()
    end
end

function ItemBoxRewardView:close()
    self:startHide()
end


return ItemBoxRewardView;
