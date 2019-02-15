local BattlePauseTipView = class("BattlePauseTipView", UIBase);


function BattlePauseTipView:ctor(winName,pauseType,callback)
    BattlePauseTipView.super.ctor(self, winName);
    self.pauseType = pauseType
    self.callback = callback
end

function BattlePauseTipView:loadUIComplete()
	self:registerEvent();
end 

function BattlePauseTipView:registerEvent()
	BattlePauseTipView.super.registerEvent()
    if BattleControler:checkIsCrossPeak() then
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2021"))
        self.rich_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2020"))
    else
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid2283"))
        local str = ""
        if self.pauseType == Fight.pause_quit then
            -- 如果是六界，则扣除1点体力
            -- if BattleControler.battleLabel == GameVars.battleLabels.worldPve then
            --     str = GameConfig.getLanguageWithSwap("#tid2285", 1)
            -- else
                str = GameConfig.getLanguage("#tid2287")
            -- end
            if BattleControler.battleLabel == GameVars.battleLabels.guildBossGve then
                str = GameConfig.getLanguage("#tid_battle_11")
            end
            self.rich_1:setString(str)
        elseif self.pauseType == Fight.pause_restart then

            -- if BattleControler.battleLabel == GameVars.battleLabels.worldPve then
            --     str = GameConfig.getLanguageWithSwap("#tid2284", 1)
            -- else
                str = GameConfig.getLanguage("#tid2286")
            -- end
            self.rich_1:setString(str)
        end
    end
    self.UI_1.btn_close:setTap(c_func(self.canelClick,self))
    self.UI_1.mc_1:showFrame(2)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.sureClick,self))
    self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.canelClick,self))
end
function BattlePauseTipView:sureClick( )
    if self.callback then
        self.callback(1)
    end
    self:startHide()
end
function BattlePauseTipView:canelClick( )
    self:startHide()
end

return BattlePauseTipView;
