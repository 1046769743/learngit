local BattleWin3 = class("BattleWin3", UIBase);

 

function BattleWin3:ctor(winName,params)
	self.battleDatas = params
    BattleWin3.super.ctor(self, winName);
 
end

function BattleWin3:loadUIComplete()
    self:registerEvent(); 
    self:updateUI()
end 
 
-- 退出战斗
function BattleWin3:pressClose()
 
end


function BattleWin3:registerEvent()
    self:registClickClose(-1, c_func( function()
           self:startHide()
    end , self))
end
 
function BattleWin3:updateUI()
 
end


function BattleWin3:hideComplete()
	BattleWin3.super.hideComplete(self)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
end

function BattleWin3:deleteMe()
    BattleWin3.super.deleteMe(self)
    self.controler = nil
end 

return BattleWin3;
