--[[
	Author: Long Xiaohua
	Date:2017-08-03
	Description: TODO
]]

local EliteItemView = class("EliteItemView", UIBase);

function EliteItemView:ctor(winName)
    EliteItemView.super.ctor(self, winName)
end

function EliteItemView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EliteItemView:registerEvent()
	EliteItemView.super.registerEvent(self);
end

function EliteItemView:initData()
	-- TODO
end

function EliteItemView:initView()
	-- TODO
end

function EliteItemView:initViewAlign()
	-- TODO
end

function EliteItemView:updateUI()

end

function EliteItemView:setEliteItemData(data)
	-- dump(data, "\n\ndata=====", 3)
	-- 切分reward字符串
	local itemData = string.split(data["reward"], ",")
	-- dump(itemData, "\n\nitemData=====", 3)
	-- 通过切分得到的数组分别得到id和num
	local itemId = itemData[1]
	-- echo("itemId  type  ==="..itemId)
	local num = itemData[2]
	-- 得到item的name tid和item图片的name
	local itemName = FuncElite.getGoodsValue(itemId, "name")
	local iconName = FuncElite.getGoodsValue(itemId, "iconImg")
	local name = FuncTranslate._getLanguage(itemName)
	local itemIcon = display.newSprite(FuncRes.iconElite(iconName))
	itemIcon:setScale(0.9)
	-- 设置UI
	self.mc_zi.currentView.txt_1:setString(tostring(name))
	self.txt_goodsshuliang:setString(tostring(num))
	self.ctn_1:addChild(itemIcon)
	self.ctn_1:setVisible(true)
	self.mc_zi:setVisible(true)
end

function EliteItemView:getIconCtn()
	return self.ctn_1
end

function EliteItemView:setIconVisible(visible)
	self.ctn_1:setVisible(visible)
end

function EliteItemView:setNameVisible(visible)
	self.mc_zi:setVisible(visible)
end

function EliteItemView:setItemNumVisible(visible)
	self.txt_goodsshuliang:setVisible(visible)
end

function EliteItemView:deleteMe()
	-- TODO

	EliteItemView.super.deleteMe(self);
end

return EliteItemView;
