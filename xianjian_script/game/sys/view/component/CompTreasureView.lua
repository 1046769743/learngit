local CompTreasureView = class("CompTreasureView", UIBase);

--[[
    self.ctn_icon,
    self.mc_biaoqian,
    self.mc_di,
    self.mc_zizhi,
]]

function CompTreasureView:ctor(winName)
    CompTreasureView.super.ctor(self, winName);
end

function CompTreasureView:loadUIComplete()
	self:registerEvent();
end 

function CompTreasureView:registerEvent()
	CompTreasureView.super.registerEvent();

end



function CompTreasureView:updateUI(treasureId)
    if treasureId == nil then return end

    local itemIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
    itemIcon:setScale(0.7)

    local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
    treasureName = GameConfig.getLanguage(treasureName)

    -- 法宝名字
    local itemName = treasureName

    -- 法宝资质
    local quality = FuncTreasure.getValueByKeyTD(treasureId,"quality")

    -- 法宝位置
    local pos = FuncTreasure.getValueByKeyTD(treasureId,"label1")

    -- 物品图标
    local _sprite = display.newSprite(FuncRes.iconTreasure(treasureId)):size(self.ctn_icon.ctnWidth,self.ctn_icon.ctnHeight)
    self.ctn_icon:removeAllChildren();
    itemIcon:parent(self.ctn_icon)
    --资质
    self.mc_zizhi:showFrame(quality)
    
    -- 法宝位置icon
    self.mc_biaoqian:setVisible(false)
    if pos <= 3 and pos >= 1 then 
        self.mc_biaoqian:showFrame(pos)
    else
        self.mc_biaoqian:setVisible(false)
    end 
end


return CompTreasureView;
