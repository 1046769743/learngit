--[[
    Author: 张燕广
    Date:2017-10-25
    Description: 公会小游戏主角类
]]

local GuildBaseCharModel = require("game.sys.view.guildActivity.model.GuildBaseCharModel")
GuildPlayerModel = class("GuildPlayerModel",GuildBaseCharModel)

function GuildPlayerModel:ctor(controler,sex)
	GuildPlayerModel.super.ctor(self,controler)
end

function GuildPlayerModel:registerEvent()

end

function GuildPlayerModel:initView(...)
	GuildPlayerModel.super.initView(self,...)

end

--运动函数  根据一系列点运动						重复类型 0 表示不重复 1表示重头开始 2表示随机点序列以后重复
function GuildPlayerModel:moveByPointArr( pointArr,speed,repeateType )
	GuildPlayerModel.super.moveByPointArr(self, pointArr,speed,repeateType )
	self:rePlayAction(true)
end

function GuildPlayerModel:moveToPoint(targetPoint, speed,moveType )
	GuildPlayerModel.super.moveToPoint(self,targetPoint, speed,moveType)

	self:rePlayAction(true)
end

--运动到目标了
function GuildPlayerModel:overTargetPoint(  )
	GuildPlayerModel.super.overTargetPoint(self)
	self:rePlayAction(false)
end

-- 当主角移动到了目标点
function GuildPlayerModel:onMoveToPointCallBack()
	echo("主句移动到了")
	self:rePlayAction(false)
	self.myView:playLabel("stand")
end


function GuildPlayerModel:rePlayAction(isMoving)
   	if isMoving then
		self.myView:playLabel("run")
	else 
		self.myView:playLabel("stand")
	end
    
end
function GuildPlayerModel:deleteMe()
	GuildPlayerModel.super.deleteMe(self)
end

return GuildPlayerModel