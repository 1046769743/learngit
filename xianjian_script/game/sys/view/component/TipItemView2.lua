--通用道具tip显示
local TipItemView2 = class("TipItemView2", InfoTipsBase);

--[[
    self.UI_comp_tipsItem2,
    self.ctn_icon,
    self.mc_1,
    self.scale9_tips,
    self.txt_1,
    self.txt_2,
]]

function TipItemView2:ctor(winName)
    TipItemView2.super.ctor(self, winName);
end

function TipItemView2:loadUIComplete()
	self:registerEvent();
end 

function TipItemView2:registerEvent()
	TipItemView2.super.registerEvent();

end


--资源类型字符串
function TipItemView2:setResInfo(resType,nums,resId , reward , hideTipNum)
    --判断是道具 还是其他资源  除了道具  其他资源走相同的
    -- local quality = FuncDataResource.getQualityById( resType,resId )
    -- local iconPath = FuncRes.iconRes(resType,resId)

    -- local icon = display.newSprite(iconPath)
    -- -- 如果是法宝
    -- if resType == FuncDataResource.RES_TYPE.TREASURE then
    --     icon:setScale(0.45)
    -- else
    --    -- icon:setScale(1.2)
    -- end
    -- echo("========resId======1111111111111====",resType,resId)
    local describ = FuncDataResource.getResDescrib( tostring(resType),resId )

    local resName = FuncDataResource.getResNameById(resType,resId)
    self.txt_1:setString(resName)
    self.txt_2:setString(describ)

    -- 这个地方需要 修改
    

    self.UI_2:setResItemData(
    {
        reward = reward
    })

    if hideTipNum then
        self.UI_2:showResItemNum(false)
    end
    
    -- self.panel = self.UI_2.mc_1.currentView.btn_1:getUpPanel().panel_1

    -- self.panel.mc_kuang:showFrame(_yuan3(quality > 5,1,quality))

    -- self.panel.txt_goodsshuliang:setVisible(false)
    -- self.panel.mc_zi:setVisible(false)
    -- self.panel.panel_red:setVisible(false)
    
    
    -- self.panel.ctn_1:removeAllChildren()
    -- icon:addto(self.panel.ctn_1):anchor(0.5,0.5)
end



function TipItemView2:updateUI()
	
end


return TipItemView2;
