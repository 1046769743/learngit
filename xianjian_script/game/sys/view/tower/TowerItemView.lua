--[[
	Author: Long Xiaohua
	Date:2017-08-03
	Description: TODO
]]

local TowerItemView = class("TowerItemView", UIBase);

function TowerItemView:ctor(winName)
    TowerItemView.super.ctor(self, winName)
end

function TowerItemView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerItemView:registerEvent()
	TowerItemView.super.registerEvent(self);
end

function TowerItemView:initData()
	-- TODO
end

function TowerItemView:initView()
	-- TODO
end

function TowerItemView:initViewAlign()
	-- TODO
end

function TowerItemView:updateUI()

end

function TowerItemView:setTowerItemData(data)
	-- dump(data, "\n\ndata=====", 3)
	-- 切分reward字符串
	local itemData = string.split(data["reward"], ",")
	-- dump(itemData, "\n\nitemData=====", 3)
	-- 通过切分得到的数组分别得到id和num
	local itemId = itemData[1]
	-- echo("itemId  type  ==="..itemId)
	local num = itemData[2]
	-- 得到item的name tid和item图片的name
	local itemName = FuncTower.getGoodsValue(itemId, "name")
	local iconName = FuncTower.getGoodsValue(itemId, "iconImg")
	local name = FuncTranslate._getLanguage(itemName)
	local itemIcon = display.newSprite(FuncRes.iconTowerEvent(iconName))
	itemIcon:setScale(0.9)
	-- 设置UI
	self.mc_zi.currentView.txt_1:setString(tostring(name))
	self.txt_goodsshuliang:setString(tostring(num))
	self.ctn_1:addChild(itemIcon)
	self.ctn_1:setVisible(true)
	self.mc_zi:setVisible(true)
end

function TowerItemView:getIconCtn()
	return self.ctn_1
end

function TowerItemView:setIconVisible(visible)
	self.ctn_1:setVisible(visible)
end

function TowerItemView:setNameVisible(visible)
	self.mc_zi:setVisible(visible)
end

function TowerItemView:setItemNumVisible(visible)
	self.txt_goodsshuliang:setVisible(visible)
end

function TowerItemView:deleteMe()
	-- TODO

	TowerItemView.super.deleteMe(self);
end

return TowerItemView;
