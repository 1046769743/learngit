--todo 加 东西 

local TrailLoadingView = class("TrailLoadingView", UIBase);

--[[
    self.panel_jindu,
    self.panel_jindu.ctn_dongxiao,
    self.panel_jindu.progress_jindu,
    self.panel_jindu.txt_1,
    self.panel_lianjie.mc_1,
    self.panel_lianjie.mc_2,
    self.panel_lianjie.mc_3,
    self.panel_lianjie.txt_1,
    self.panel_lianjie.txt_2,
    self.panel_lianjie.txt_3,
    self.panel_lianjie.txt_level1,
    self.panel_lianjie.txt_level2,
    self.panel_lianjie.txt_level3,
    self.panel_lianjie.txt_name1,
    self.panel_lianjie.txt_name2,
    self.panel_lianjie.txt_name3,
    self.panel_lianjie.txt_xxzy,
    self.panel_xinxi.mc_miaoshu,
    self.panel_xinxi.mc_mingzi,
    self.panel_xinxi.mc_touxiang,
]]

function TrailLoadingView:ctor(winName)
    TrailLoadingView.super.ctor(self, winName);
end

function TrailLoadingView:loadUIComplete()
	self:registerEvent();
end 

function TrailLoadingView:registerEvent()
	TrailLoadingView.super.registerEvent();

end



function TrailLoadingView:updateUI()
	
end


return TrailLoadingView;
