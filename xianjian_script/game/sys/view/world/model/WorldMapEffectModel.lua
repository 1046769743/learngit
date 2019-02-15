--[[
	Author: 张燕广
	Date:2017-11-03
	Description: 六界地图场景特效类
]]

local WorldBuildingModel = require("game.sys.view.world.model.WorldBuildingModel")
WorldMapEffectModel = class("WorldSpaceModel",WorldBuildingModel)

function WorldMapEffectModel:ctor(controler,viewCtn,info)
	WorldMapEffectModel.super.ctor(self,controler)
	self.viewCtn = viewCtn
	self.effInfo = info
	self.effName = info.fullName

	self:initPos(self.effInfo)
end

function WorldMapEffectModel:initPos(cfgInfo)
	-- 导出的地标sprite原点是中心
	local width = cfgInfo.width
	local height = cfgInfo.height
	local x = cfgInfo.x

	-- spine原点是脚下中心
	local y = cfgInfo.y - 50 --height / 2
	self:setPos(x,y,0)
end

function WorldMapEffectModel:dummyFrame()
	WorldMapEffectModel.super.dummyFrame(self)
end

function WorldMapEffectModel:createModelView()
	if self.myView then
		return
	end

	local effInfo = self.effInfo
	local size = cc.size(effInfo.width,effInfo.height)

	local spineName = self.effInfo.fullName
	local labelName = "animation"

	-- TODO spine资源容错处理
	if not cc.FileUtils:getInstance():isFileExist("anim/spine/"..spineName..".png") then
		-- echoWarn("找策划spine不存在 spineName",spineName)
		return
	end

	local spine = ViewSpine.new(spineName)
	spine:playLabel(labelName)
	self:initView(self.viewCtn,spine,x,y,0,size)
end

function WorldMapEffectModel:deleteMyView()
	-- echo("删除特效........self.effName=",self.effName)
	WorldBuildingModel.super.deleteMyView(self)
end

return WorldMapEffectModel
