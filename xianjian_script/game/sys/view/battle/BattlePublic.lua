local BattlePublic = class("BattlePublic", UIBase);

--[[
    self.mc_1,
    self.mc_ag,
    self.mc_cheng,
    self.mc_dh,
    self.mc_doutiao,
    self.mc_hd,
    self.mc_hx,
    self.mc_jichu,
    self.mc_lg,
    self.mc_qv,
    self.mc_rx,
    self.mc_tiaozi,
    self.panel_bar1.ctn_1,
    self.panel_bar1.mc_chatBall,
    self.panel_bar1.panel_1,
    self.panel_bar1.txt_name,
    self.panel_bar2.mc_chatBall,
    self.panel_bar2.panel_1,
    self.panel_bar2.txt_name,
    self.panel_bar3.mc_chatBall,
    self.panel_bar3.panel_1,
    self.panel_bar3.txt_name,
    self.panel_jiaodi_boss.ctn_1,
    self.panel_jiaodi_zhujue.ctn_1,
    self.txt_texie,
    self.txt_treasure,
    self.txt_treasure2,
]]

function BattlePublic:ctor(winName)
    BattlePublic.super.ctor(self, winName);
end

function BattlePublic:loadUIComplete()
	self:registerEvent();
end 

function BattlePublic:registerEvent()
	BattlePublic.super.registerEvent();

end



function BattlePublic:updateUI()
	
end


return BattlePublic;
