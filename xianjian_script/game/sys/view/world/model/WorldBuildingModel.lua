--[[
	Author: 张燕广
	Date:2017-11-03
	Description: 六界基础建筑类，具备自动创建视图和销毁视图功能
				 可能的子类：地标、山体、特效等
]]

local WorldBasicModel = require("game.sys.view.world.model.WorldMoveModel")
WorldBuildingModel = class("WorldBuildingModel",WorldBasicModel)

function WorldBuildingModel:dummyFrame()
	self:updateView()
end

-- 更新视图
function WorldBuildingModel:updateView()
	if self:checkCanSee() then
		self:createModelView()
	else
		if self.myView then
			self:deleteMyView()
		end
	end
end

-- 检查是否能看到
function WorldBuildingModel:checkCanSee()
	return self:isInScreen()
end

return WorldBuildingModel
