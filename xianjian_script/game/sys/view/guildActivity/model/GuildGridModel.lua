--[[
	Author: 张燕广
	Date:2017-10-25
	Description: 公会活动小游戏地图格子类
]]

local GuildBasicModel = require("game.sys.view.guildActivity.model.GuildBasicModel")
GuildGridModel = class("TowerGridModel",GuildBasicModel)

function GuildGridModel:ctor(controler,gridIdx)
	GuildGridModel.super.ctor(self,controler)
	self.gridIdx = gridIdx
end

function GuildGridModel:registerEvent()

end
function GuildGridModel:initView(...)
	GuildMonsterModel.super.initView(self,...)
end

function GuildGridModel:getGridPosition( _index )
	_index = tonumber(20 - _index + 1)
	local perDisX = 90
	local perDisY = 80
	if _index <= 5 then
		local offset = (_index<4 and _index or (6-_index)) - 1
		xpos = _index * perDisX - offset*40
		ypos = _index * perDisY + offset*20
	elseif _index <= 10 then
		local offset = (_index<9 and (_index-5) or (11-_index)) - 1
		xpos = _index * perDisX + 40 + offset*40
		ypos = (11-_index) * perDisY + offset*20
	elseif _index <= 15 then
		local offset = (_index<14 and (_index-10) or (16-_index)) - 1
		xpos = _index * perDisX + 80 - offset*40
		ypos = (_index -10) * perDisY + offset*20
	elseif _index <= 20 then
		local offset = (_index<19 and (_index-15) or (21-_index)) - 1
		xpos = _index * perDisX + 120 + offset*40
		ypos = (21-_index) * perDisY + offset*20
	end
	-- return xpos,ypos
	return xpos-850,ypos-700
end

-- 创建动画 
function GuildGridModel:createComboAmature(posX,posY)
	-- local panelList = self.controler.map:getCachePanel()
	self.comboAni = self.controler.ui:createUIArmature("UI_xianmenggve","UI_xianmenggve_xiaochudiren", self.viewCtn, false,GameVars.emptyFunc)
	self.comboAni:pos(posX,posY)
	self.comboAni:anchor(0.5,0.5)
	-- self.comboAni:startPlay(false)
	self.comboAni:pause()
	self.comboAni:visible(false)
end

-- 播放动画 
function GuildGridModel:playAnimation()
	if not self.comboAni then
		self.comboAni = self.controler.ui:createUIArmature("UI_xianmenggve","UI_xianmenggve_xiaochudiren", self.viewCtn, false,GameVars.emptyFunc)
		self.comboAni:pause()
	end
	-- self.comboAni:visible(true)
	-- self.comboAni:gotoAndPlay(1)
	self.comboAni:startPlay(false)
	-- self.comboAni:visible(false)
end

function GuildGridModel:deleteMe()
	GuildGridModel.super.deleteMe(self)
end

return GuildGridModel