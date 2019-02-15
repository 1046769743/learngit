--zhangqiang

local MemoryCardChipsShowView = class("MemoryCardChipsShowView", UIBase);


function MemoryCardChipsShowView:ctor(winName,cardId,chipId,levelUp)
    MemoryCardChipsShowView.super.ctor(self, winName);
    self.chipId = chipId
    self.cardId = cardId
    self.levelUp = levelUp
end

--分辨率适配
function MemoryCardChipsShowView:uiAdjust()
    
end
function MemoryCardChipsShowView:registerEvent()
    MemoryCardChipsShowView.super.registerEvent();

    self:registClickClose(nil, c_func(self.close, self))
end

function MemoryCardChipsShowView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
    self:updateUI( )
end 

function MemoryCardChipsShowView:updateUI( )
    self.UI_crardinfo:updateUI(self.cardId,true)
end

function MemoryCardChipsShowView:hideComplete()
    
    if  self.isLvUp then
        --echo("展示升级界面--------------------")
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true);
    else
        --echo("不升级------------")
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end


    MemoryCardChipsShowView.super.hideComplete(self)
end

function MemoryCardChipsShowView:close()
    
    self:startHide()
end


return MemoryCardChipsShowView;