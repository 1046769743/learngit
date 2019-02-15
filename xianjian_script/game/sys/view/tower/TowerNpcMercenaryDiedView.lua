--
--Author:      zhuguangyuan
--DateTime:    2017-12-22 11:19:27
--Description: 锁妖塔npc类型 雇佣兵 可花钱买入己方队伍
--


local TowerNpcMercenaryDiedView = class("TowerNpcMercenaryDiedView", UIBase);

function TowerNpcMercenaryDiedView:ctor(winName,_mercenaryId)
    TowerNpcMercenaryDiedView.super.ctor(self, winName)
    self.mercenaryId = _mercenaryId
    echo("_________  self.mercenaryId ________", self.mercenaryId)
end

function TowerNpcMercenaryDiedView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerNpcMercenaryDiedView:registerEvent()
	TowerNpcMercenaryDiedView.super.registerEvent(self);
end

function TowerNpcMercenaryDiedView:initData()

end

function TowerNpcMercenaryDiedView:initView()
  	local enemyInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", self.mercenaryId)
	local icon1 = display.newSprite(FuncRes.iconHero( enemyInfo.icon )) 
	self.panel_1.ctn_1:addChild(icon1)
end

function TowerNpcMercenaryDiedView:initViewAlign()
	-- TODO
end

function TowerNpcMercenaryDiedView:updateUI()

end

function TowerNpcMercenaryDiedView:buyTheMercenary()

end

function TowerNpcMercenaryDiedView:press_btn_close()
	self:startHide()
end

function TowerNpcMercenaryDiedView:deleteMe()
	-- TODO
	TowerNpcMercenaryDiedView.super.deleteMe(self);
end

return TowerNpcMercenaryDiedView;
