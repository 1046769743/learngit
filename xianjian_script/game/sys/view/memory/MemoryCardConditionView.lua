--zhangqiang

local MemoryCardConditionView = class("MemoryCardConditionView", UIBase);


function MemoryCardConditionView:ctor(winName)
    MemoryCardConditionView.super.ctor(self, winName);
end

--分辨率适配
function MemoryCardConditionView:uiAdjust()
    
end
function MemoryCardConditionView:registerEvent()
    MemoryCardConditionView.super.registerEvent();

    self:registClickClose("out")
    self.UI_bg.btn_close:setTap(c_func(self.close,self))
end

function MemoryCardConditionView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI( )
end 

function MemoryCardConditionView:updateUI( )
    self.UI_bg.txt_1:visible(false)
    self.UI_bg.panel_1:visible(false)
    self.UI_bg.mc_1:visible(false)
    self.rich_1:setString(GameConfig.getLanguage("#tid_memory_002"))
end


function MemoryCardConditionView:close()
    
    self:startHide()
end


return MemoryCardConditionView;