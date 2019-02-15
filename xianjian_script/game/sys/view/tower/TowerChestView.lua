--[[
	Author: caocheng
	Date:2017-08-02
	Description: 宝箱界面
    --
    --Author:      zhuguangyuan
    --DateTime:    2018-03-08 18:43:33
    --Description: 维护 将写死的变量定义在funcTower里 
    --
    
]]

local TowerChestView = class("TowerChestView", UIBase);

function TowerChestView:ctor(winName,params,chestType,chestId)
    TowerChestView.super.ctor(self, winName)
    self.params = params
    self.type = chestType or FuncTowerMap.BOX_OPEN_CON_TYPE.NONE -- 默认不需要条件
    self.chestId = chestId
end

function TowerChestView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerChestView:registerEvent()
	TowerChestView.super.registerEvent(self);
     self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self))
end

function TowerChestView:initData()
	self.chestData = FuncTower.getTowerChest(self.chestId)
end

function TowerChestView:initView() 
    self.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_004"))
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_box_101"))
    self.mc_x:showFrame(2)

    local iconName = self.chestData.png
    local iconPath = FuncRes.iconTowerEvent(iconName)
    local iconSprite = display.newSprite(iconPath)
    self.mc_x.currentView.ctn_1:removeAllChildren()
    self.mc_x.currentView.ctn_1:addChild(iconSprite)
    if self.chestData.des then
        self.txt_1:setString(GameConfig.getLanguage(self.chestData.des))
    else
        self.txt_1:visible(false)
    end
	if tostring(self.type) == FuncTowerMap.BOX_OPEN_CON_TYPE.NEED_KEY then
        self.mc_x:showFrame(2)
        iconSprite:pos(0,10)
        self.mc_x.currentView.panel_1:visible(false)
		self.panel_1:visible(true)
		self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.questChest,self))
	else
        self.panel_1:visible(false)
		self.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.questChest,self))
	end
end

function TowerChestView:initViewAlign()
	-- TODO
end

function TowerChestView:updateUI()
	-- TODO
end

-- 点击开宝箱
function TowerChestView:questChest()
	local params = {}
	params.x = self.params.x
	params.y = self.params.y
    -- 判断是否有开启钥匙
	if tostring(self.type) == FuncTowerMap.BOX_OPEN_CON_TYPE.NEED_KEY then
        local keyArr = string.split(self.chestData.condition[1],",")
        if keyArr[2] then
            key = keyArr[2]
        end
        echo("_____________key_______________________",key)
        local hasKey = TowerMainModel:isHasBoxKey(key)
        if hasKey then
		    TowerServer:getChest(params,c_func(self.enterChestReward,self))
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_tower_prompt_102"))
        end
    else
        -- 不需要钥匙就能打开的宝箱会产出场景内道具
        -- 所以要做判断
        local itemNum = TowerMainModel:getItemNum()
        if tonumber(itemNum) < FuncTower.towerItemMaxNum then
            TowerServer:getChest(params,c_func(self.enterChestReward,self)) 
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_tower_prompt_103"))    
        end   
	end	
end

-- 开宝箱回调 打开奖励界面 注意有场景内道具奖励
function TowerChestView:enterChestReward(event)
	if event.error then 
		local errorInfo= event.error
		if tonumber(errorInfo.code) == 261504 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_005")) 
			self:startHide()
        end	
        if tonumber(errorInfo.code) == 261901  then
        	WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_006"))
        	self:startHide()
        end
        if tonumber(errorInfo.code) == 261501 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_007"))
			self:startHide()
        end
    else   
    	-- dump(event.result.data,"开宝箱返回的数据")
		TowerMainModel:updateData(event.result.data)
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_OPEN_BOX_SUCCESS)  --- 获取宝箱成功
        local goodsReward = {}
        local goodsId = event.result.data.goodsId
        local compReward = event.result.data.reward
        if goodsId ~= "" then
        	goodsReward[#goodsReward+1] = FuncTower.towerItemType..","..goodsId .. ",1"
        end
        if (compReward and table.length(compReward)>0) 
            or (goodsReward and table.length(goodsReward)>0) 
        then
            WindowControler:showWindow("TowerGetRewardView",compReward,goodsReward) 
        end
		self:startHide()
	end
end

function TowerChestView:press_btn_close()
	self:startHide()
end

function TowerChestView:deleteMe()
    TowerChestView.super.deleteMe(self);
end

return TowerChestView;
