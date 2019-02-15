--
--Author:      zhuguangyuan
--DateTime:    2017-12-23 11:09:59
--Description: 怪特性描述小弹窗,由怪界面中?按钮点击弹出
--

local TowerMonsterDescriptionView = class("TowerMonsterDescriptionView", UIBase);

function TowerMonsterDescriptionView:ctor(winName,monsterData)
    TowerMonsterDescriptionView.super.ctor(self, winName)
    self.monsterData = monsterData
end

function TowerMonsterDescriptionView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerMonsterDescriptionView:registerEvent()
	TowerMonsterDescriptionView.super.registerEvent(self);
	 self:registClickClose("out")
end

function TowerMonsterDescriptionView:initData()
	-- TODO
end

function TowerMonsterDescriptionView:initView()
	local descStr = ""
	local configDesc = self.monsterData.skillDes1
	if configDesc then
		descStr = GameConfig.getLanguage(configDesc)
	end
	configDesc = self.monsterData.skillDes2
	if configDesc then
		descStr = descStr.."\n"..GameConfig.getLanguage(configDesc)
	end
	self.panel_1.txt_1:setString(descStr)
end

function TowerMonsterDescriptionView:initViewAlign()
	-- TODO
end

function TowerMonsterDescriptionView:updateUI()
	-- TODO
end

function TowerMonsterDescriptionView:deleteMe()
	-- TODO

	TowerMonsterDescriptionView.super.deleteMe(self);
end

return TowerMonsterDescriptionView;
