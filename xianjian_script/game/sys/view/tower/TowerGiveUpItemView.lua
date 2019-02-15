--[[
	Author: TODO
	Date:2017-08-02
	Description: TODO
]]

local TowerGiveUpItemView = class("TowerGiveUpItemView", UIBase);

function TowerGiveUpItemView:ctor(winName,itemId)
    TowerGiveUpItemView.super.ctor(self, winName)
    self.itemId = itemId
end

function TowerGiveUpItemView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerGiveUpItemView:registerEvent()
	TowerGiveUpItemView.super.registerEvent(self);
	 self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
end

function TowerGiveUpItemView:initData()
	self.itemData = FuncTower.getGoodsData(self.itemId)
end

function TowerGiveUpItemView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_030")) 
	local name = GameConfig.getLanguage(self.itemData.name)
	local _str = string.format(GameConfig.getLanguage("#tid_tower_ui_031"),name)
	self.rich_1:setString(_str)
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.giveUPItemEffect,self))
end

function TowerGiveUpItemView:initViewAlign()
	-- TODO
end

function TowerGiveUpItemView:updateUI()
	-- TODO
end

function TowerGiveUpItemView:deleteMe()
	-- TODO

	TowerGiveUpItemView.super.deleteMe(self);
end

function TowerGiveUpItemView:giveUPItemEffect()
	local params= {
		goodsId = self.itemId,
	}
	TowerServer:giveUpItem(params,c_func(self.giveUpScuess,self))
end


function TowerGiveUpItemView:giveUpScuess(event)
	if event.error then
		local errorInfo= event.error
		if tonumber(errorInfo.code) == 261501 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_032"))
	    end	
	else
		TowerMainModel:updateData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_DROP_ITEM_SUCCESS)
	end
	self:startHide()
end


function TowerGiveUpItemView:press_btn_close()

	self:startHide()
end

return TowerGiveUpItemView;
