--zhangqiang

local MemoryAttrView = class("MemoryAttrView", UIBase);


function MemoryAttrView:ctor(winName)
    MemoryAttrView.super.ctor(self, winName);
end

--分辨率适配
function MemoryAttrView:uiAdjust()

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.LeftTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop);
end
function MemoryAttrView:registerEvent()
    MemoryAttrView.super.registerEvent();

    -- 退出
    self.UI_1.btn_1:setTap(c_func(self.close,self))
    self:registClickClose("out")

end


function MemoryAttrView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI( )
end 



function MemoryAttrView:updateUI( )
    local attr = MemoryCardModel:getMemoryAllAttr( )

    local getAttrDes = function ( _attr,_key )
        return FuncMemoryCard.getAttrDes( _attr,_key )
    end

    local updatePanel = function( panel,frame,_attr )
        panel.mc_qixia:showFrame(frame)
        -- 攻击
        local str1 = getAttrDes(_attr,"10")
        -- 物防
        local str2 = getAttrDes(_attr,"11")
        -- 法防
        local str3 = getAttrDes(_attr,"12")
        -- 血量
        local str4 = getAttrDes(_attr,"2")
        local str = str1 .."\n".. str2 .."\n" .. str3 .."\n".. str4
        panel.txt_1:setString(str)
    end
    -- 攻击类奇侠
    local attr1 = attr["1"]
    updatePanel(self.panel_attr1,1,attr1)
    -- 防御类奇侠
    local attr2 = attr["2"]
    updatePanel(self.panel_attr2,2,attr2)
    -- 辅助类奇侠
    local attr3 = attr["3"]
    updatePanel(self.panel_attr3,3,attr3)
    -- 主角
    local attr0 = attr["0"]
    updatePanel(self.panel_attr4,4,attr0)
end


function MemoryAttrView:close()
    self:startHide()
end


return MemoryAttrView;