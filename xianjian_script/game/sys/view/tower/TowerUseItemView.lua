
--[[
	Author: TODO
	Date:2017-08-02
	Description: TODO
]]

local TowerUseItemView = class("TowerUseItemView", UIBase);

function TowerUseItemView:ctor(winName,itemId,itemTime,gridPos,isCheckItem)
    TowerUseItemView.super.ctor(self, winName)
    self.itemId = itemId or "1003"
    self.itemTime = itemTime

    self.gridPos = gridPos or {}
    self.isCheckItem = isCheckItem or false
end 

function TowerUseItemView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerUseItemView:registerEvent()
	TowerUseItemView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
	EventControler:addEventListener(TowerEvent.TOWEREVENT_DROP_ITEM_SUCCESS,self.press_btn_close,self);
end

function TowerUseItemView:initData()
	self.itemData = FuncTower.getGoodsData(self.itemId)
end

function TowerUseItemView:initView()
	self.btn_dq:visible(false)
	self.btn_sy:visible(false)
	if not self.isCheckItem then
		if self.itemId =="1001" then
			self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_059"))
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.press_btn_close,self))
		else  
			self.UI_1.txt_1:setString(GameConfig.getLanguage(self.itemData.name))
			self.UI_1.mc_1:showFrame(3)
			self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_060"))
			self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_061"))
			self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.useItem,self))
			self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.giveUpItem,self))
		end	
	else
		self.UI_1.txt_1:setString(GameConfig.getLanguage(self.itemData.name))
		self.UI_1.mc_1:showFrame(3)
		self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_062"))
		self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_063"))
		self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.getItem,self))
		self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.byPassItem,self))
	end
	local spritePath = FuncRes.iconTowerEvent(self.itemData.iconImg)
	local sp = display.newSprite(spritePath)
	self.UI_2.ctn_1:addChild(sp)
	self.UI_2:setItemNumVisible(false)
	self.UI_2.mc_zi:visible(false)
	self.txt_1:setString(GameConfig.getLanguage(self.itemData.des))
	if self.itemData.goodsType ==3  then
		local typeData =FuncTower.getTowerBuffAttrData(self.itemData.attribute[1])
		local typeDataNum = typeData.attr[1].value/100
		local typeDataText = typeDataNum
		self.rich_1:setString(GameConfig.getLanguageWithSwap(self.itemData.effectDes,typeDataText))
		
	else
		self.rich_1:setString(GameConfig.getLanguage(self.itemData.effectDes))
	end	
end

function TowerUseItemView:initViewAlign()
	-- TODO
end

function TowerUseItemView:updateUI()
	-- TODO
end

function TowerUseItemView:useItem()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLICK_USE_ITEM,{itemId=self.itemId,itemTime=self.itemTime})
	self:startHide()
end

function TowerUseItemView:deleteMe()
	-- TODO

	TowerUseItemView.super.deleteMe(self);
end

function TowerUseItemView:giveUpItem()
    WindowControler:showWindow("TowerGiveUpItemView",self.itemId)
end

function TowerUseItemView:press_btn_close()
	self:startHide()
end

function TowerUseItemView:byPassItem()
	local params = {
	x = self.gridPos.x,
	y = self.gridPos.y,
	}
	TowerServer:byPassLocation(params,c_func(self.byPassEffect,self))
end

function TowerUseItemView:byPassEffect(event)
	if event.error then
		-- WindowControler:showTips("绕过道具失败")
	else
		local passItemData ={
			itemId=self.itemId,
			x = self.gridPos.x,
			y = self.gridPos.y,
		}
		TowerMainModel:updateData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_SKIP_MONSTER,passItemData)
		self:startHide()
	end	
end

function TowerUseItemView:getItem()
	local itemNum = TowerMainModel:getItemNum()
	if itemNum == 3 then
		WindowControler:showTips(GameConfig.getErrorLanguage("#error261901"))
		self:startHide()
	else	
		local params = {
			x = self.gridPos.x,
			y = self.gridPos.y,
			itemId = self.itemId 
		}
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHOOSE_GET_ITEM,params)
		self:startHide()
	end	
end


return TowerUseItemView;
