--
--Author:      zhuguangyuan
--DateTime:    2017-12-25 11:41:48
--Description: 锁妖塔固定事件 -- 五星池
--


local TowerObstacleView = class("TowerObstacleView", UIBase);

function TowerObstacleView:ctor(winName,params)
    TowerObstacleView.super.ctor(self, winName)
    self.obstacleData = params
    -- self.gridPos = params
    -- dump(self.gridPos, "self.gridPos")
end

function TowerObstacleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerObstacleView:registerEvent()
	TowerObstacleView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
 --    EventControler:addEventListener(TowerEvent.TOWEREVENT_GOT_SOUL_COMFIRMED, self.getSoulProperty, self)
end

function TowerObstacleView:initData()
	self:updateData()
end

function TowerObstacleView:updateData()

end

function TowerObstacleView:initView()
	local name = self.obstacleData.name
	self.UI_1.txt_1:setString(GameConfig.getLanguage(name))
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_close, self))

	local tipss = GameConfig.getLanguage(self.obstacleData.des)
	self.rich_1:setString(tipss)
end

function TowerObstacleView:initViewAlign()
	-- TODO
end

function TowerObstacleView:updateUI()

end

function TowerObstacleView:press_btn_close()
	self:startHide()
end

function TowerObstacleView:deleteMe()
	-- TODO

	TowerObstacleView.super.deleteMe(self);
end

return TowerObstacleView;
