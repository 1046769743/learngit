--[[
	Author: 张燕广
	Date:2018-07-26
	Description: Game小游戏系统数据类
]]

local GameModel = class("GameModel",BaseModel)

function GameModel:init(d)
	self.modelName = "game"
	GameModel.super.init(self, d)
	
	self:initData()
	self:registerEvent()
end

function GameModel:initData()
	
end

--更新数据
function GameModel:updateData(data)
	GameModel.super.updateData(self,data);
end

--删除数据
function GameModel:deleteData( data ) 
	GameModel.super.deleteData(self,data);
	
end

function GameModel:registerEvent()

end

GameModel:init({})

return GameModel

