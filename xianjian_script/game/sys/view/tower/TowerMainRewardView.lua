--[[
	Author: caocheng
	Date:2017-07-27
	Description: 锁妖塔主界面宝箱领取
]]

local TowerMainRewardView = class("TowerMainRewardView", UIBase);

function TowerMainRewardView:ctor(winName,floorId,isShopBox,boxStatus)
    TowerMainRewardView.super.ctor(self, winName)
    self.nowFloorId = floorId
    self.isShopBox = isShopBox -- 是否开启商店商品类型
    self.boxStatus = boxStatus -- 宝箱状态
    echo("__________floorId,isShopBox,boxStatus____________",floorId,isShopBox,boxStatus)
end

function TowerMainRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerMainRewardView:registerEvent()
	TowerMainRewardView.super.registerEvent(self);
    self:registClickClose("out");
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
end

function TowerMainRewardView:initData()
    -- self.historyFloor = TowerMainModel:getMaxClearFloor()
    -- self.floorReward = TowerMainModel:getTowerFloorReward() or {}
end

function TowerMainRewardView:initView()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_033")) 
    if self.isShopBox then
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_080")) 
    end
    self.UI_1.mc_1:visible(false)

    if self.isShopBox then
        -- 读取表格的进度奖励图标进行展示 
        local floorData = FuncTower.getOneFloorData( self.nowFloorId )
        local shopId = floorData.shopUnlock
        local shopData = FuncShop.getOneTowerShopGoodsById( shopId )
        local rewardId = shopData.itemId
        local rewardType = FuncDataResource.RES_TYPE.ITEM
        local rewardNum = shopData.num
        local rewardStr = rewardType..","..rewardId..","..rewardNum
        self.mc_2:showFrame(1)
        local rewardUI = self.mc_2.currentView["UI_1"]
        rewardUI:visible(true)
        rewardUI:setResItemData({reward = rewardStr})
        rewardUI:showResItemName(false)
        FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,rewardStr,true,true)
        
        if self.boxStatus == FuncTower.boxStatusType.GOT then
            self.mc_1:showFrame(4) -- 已解锁
        elseif self.boxStatus == FuncTower.boxStatusType.ACCESSIBLE then
            self.mc_1:showFrame(4) -- 已解锁
            local hasCheck = TowerMainModel:getHasCheckTowerShopGoods(self.nowFloorId)
            if tostring(hasCheck) ~= "true" then
                TowerMainModel:recordHasCheckTowerShopGoods(self.nowFloorId,true)  -- 查看过则记录 用于主界面的隐藏商品panel
                EventControler:dispatchEvent(TowerEvent.TOWEREVENT_HAS_CHECK_UNLOCK_GOODS)
            end
        elseif self.boxStatus == FuncTower.boxStatusType.LOCK then
            local numString = Tool:transformNumToChineseWord(self.nowFloorId)
            local txtTip = GameConfig.getLanguageWithSwap("#tid_tower_ui_119",numString) --"通关锁妖塔"..numString.."层商店可解锁"
            if self.nowFloorId == tonumber(TowerMainModel:getMaxFloor()) then
                txtTip = "完美" .. txtTip
            end
            self.mc_1.currentView.txt_1:setString(txtTip)        
        end
        self.isShopBox = FuncTower.boxStatusType.GOT -- todo 记录本地
    else
        local rewardData = FuncTower.getFloorReward(self.nowFloorId)
        self.mc_2:showFrame(table.length(rewardData))
        -- 展示奖励
        for k,v in pairs(rewardData) do 
            local rewardUI = self.mc_2.currentView["UI_"..k]
            local reward = string.split(v,",")
            local rewardType = reward[1];
            local rewardNum = reward[table.length(reward)];
            local rewardId = reward[table.length(reward) - 1];
            
            rewardUI:visible(true)
            rewardUI:setResItemData({reward = v})
            rewardUI:showResItemName(false)
            FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,v,true,true)
        end

        if self.boxStatus == FuncTower.boxStatusType.GOT then
            self.mc_1:showFrame(3) -- 已经领取
        elseif self.boxStatus == FuncTower.boxStatusType.ACCESSIBLE then
            self.mc_1:showFrame(2)
            self.mc_1.currentView.btn_1:setTap(c_func(self.getReward,self))
        elseif self.boxStatus == FuncTower.boxStatusType.LOCK then
            local numString = Tool:transformNumToChineseWord(self.nowFloorId)
            local txtTip = GameConfig.getLanguageWithSwap("#tid_tower_ui_118",numString) --"通关锁妖塔"..numString.."层可开启"
            if self.nowFloorId == tonumber(TowerMainModel:getMaxFloor()) then
                txtTip = "完美" .. txtTip
            -- 由于阶段解锁的存在 可能第五层打完之后到达传送门 但是进不了第六层
            -- 此时第五层的宝箱不能领 做相应的提示
            elseif tonumber(self.nowFloorId) == 5 then
                local numString2 = Tool:transformNumToChineseWord(self.nowFloorId+1)
                txtTip = GameConfig.getLanguageWithSwap("#tid_tower_ui_123",numString,numString2)
            end
            self.mc_1.currentView.txt_1:setString(txtTip)        
        end
    end
end

function TowerMainRewardView:updateUI()
	
end

function TowerMainRewardView:deleteMe()
	TowerMainRewardView.super.deleteMe(self);
end

function TowerMainRewardView:getReward()
    local params ={}
    params.towerId = self.nowFloorId
    TowerServer:getFloorReward(params,c_func(self.hasReward,self))
end

function TowerMainRewardView:hasReward(event)
    
    if event.error then

    else
        TowerMainModel:updateData(event.result.data)

    --[["rewards" = {
             1 = "4,1000"
             2 = "1,5001,5"
             3 = "1,5002,5"
        }
    ]]  
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_SUCCESS_GETMAINREWARDVIEW)
        local goodsReward = {}
        self:startHide()
        
        -- WindowControler:showWindow("RewardSmallBgView", event.result.data.reward)
        WindowControler:showWindow("TowerGetRewardView",event.result.data.reward,goodsReward)
    end
end

function TowerMainRewardView:press_btn_close()
	self:startHide()
end

return TowerMainRewardView;
