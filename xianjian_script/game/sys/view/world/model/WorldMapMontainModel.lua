--[[
	Author: 张燕广
	Date:2017-11-03
	Description: 六界地图山体类
]]

local WorldBuildingModel = require("game.sys.view.world.model.WorldBuildingModel")
WorldMapMontainModel = class("WorldMapMontainModel",WorldBuildingModel)

function WorldMapMontainModel:ctor(controler,viewCtn,montainName,info)
	WorldMapMontainModel.super.ctor(self,controler)
	self.montainName = montainName
	self.viewCtn = viewCtn
	self.cfgInfo = info

	self:initPos(self.cfgInfo)
end

function WorldMapMontainModel:initPos(cfgInfo)
	-- 导出的地标sprite原点是中心
	local width = cfgInfo.width
	local height = cfgInfo.height
	local x = cfgInfo.x

	-- spine原点是脚下中心
	local y = cfgInfo.y - height / 2
	self:setPos(x,y,0)
end

function WorldMapMontainModel:dummyFrame()
	WorldMapMontainModel.super.dummyFrame(self)
end

function WorldMapMontainModel:onCreateModelViewDone(view)
	local cfgInfo = self.cfgInfo
	local width = cfgInfo.width
	local height = cfgInfo.height
	
	local size = cc.size(cfgInfo.width,cfgInfo.height)

	local x = cfgInfo.x
	local y = cfgInfo.y - height / 2

	view:anchor(0.5,0)
	self:initView(self.viewCtn,view,x,y,0,size)
end

function WorldMapMontainModel:createModelView()
	if self.myView then
		return
	end
	
	local iconPath = FuncRes.iconWorldMontain(self.montainName)
	local view = display.newSprite(iconPath)
	self:onCreateModelViewDone(view)
end

function WorldMapMontainModel:deleteMyView()
	-- echo("删除山体........self.montainName=",self.montainName)
	WorldMapMontainModel.super.deleteMyView(self)
end

return WorldMapMontainModel
