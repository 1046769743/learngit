--[[
    Author: 张燕广
    Date:2017-10-25
    Description: 公会小游戏主角类
]]

local GuildBaseCharModel = require("game.sys.view.guildActivity.model.GuildBaseCharModel")
GuildCharModel = class("GuildCharModel",GuildBaseCharModel)

function GuildCharModel:ctor(controler,sex)
	GuildCharModel.super.ctor(self,controler)
		--方位对应的动作 左边是动作,右边是sc
	self.charRunFaceAction = {
        --右 
        {"run",1,},
        -- 右上
        {"run",1},
        -- 左上
        {"run",-1},
        -- 左
        {"run",-1},
        -- 左下
        {"run",-1},  
        --右下
        {"run",1},
    }

   self.charStandFaceAction = {
        --右 
        {"stand",1,},
        -- 右上
        {"stand",1},
        -- 左上
        {"stand",-1},
        -- 左
        {"stand",-1},
        -- 左下
        {"stand",-1},  
        --右下
        {"stand",1},
    }

	self.mySize = {width = 180,height = 180}
end

function GuildCharModel:registerEvent()
	GuildCharModel.super.registerEvent(self)
end

function GuildCharModel:initView(...)
	GuildCharModel.super.initView(self,...)
	-- 默认站立朝向
	self:mapViewAction(160)
	self:setClickFunc()
end

-- 每帧刷新
function GuildCharModel:dummyFrame()

end

--运动函数  根据一系列点运动						重复类型 0 表示不重复 1表示重头开始 2表示随机点序列以后重复
function GuildCharModel:moveByPointArr( pointArr,speed,repeateType )
	GuildCharModel.super.moveByPointArr(self, pointArr,speed,repeateType )
	self:rePlayAction(true)
end


function GuildCharModel:moveToPoint(targetPoint, speed,moveType )
	GuildCharModel.super.moveToPoint(self,targetPoint, speed,moveType)
	self:rePlayAction(true)
end

--运动到目标了
function GuildCharModel:overTargetPoint(  )
	GuildCharModel.super.overTargetPoint(self)
	self:rePlayAction(false)
end

-- 当主角移动到了目标点
function GuildCharModel:onMoveToPointCallBack()
	echo("主句移动到了")
	self:rePlayAction(false)
	self.myView:playLabel("stand")

	self.controler:saveCharPos(cc.p(self.pos.x,self.pos.y))
end

function GuildCharModel:setClickFunc( )
	local nd = display.newNode()
	
	--[[
	-- 测试代码
	local color = color or cc.c4b(255,0,0,120)
  	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(cc.size(self.charWidth,self.charHeight) )
	]]
    nd:setContentSize(self.mySize)
    nd:pos(-self.mySize.width / 2,self.mySize.height / 2)
	
	-- nd:setContentSize(cc.size(figure,figure) )
	nd:addto(self.myView,1)
	-- nd:setTouchedFunc(c_func(self.onClickChar,self),nil,true)
end

function GuildCharModel:onClickChar(  )
	echo("点击了主角")
end

--根据角色map方位 rotation 是 角度 不是弧度
function GuildCharModel:mapViewAction( ang )
end

function GuildCharModel:rePlayAction(isMoving)
   	if isMoving then
		self.myView:playLabel("run")
	else 
		self.myView:playLabel("stand")
	end
    
end

function GuildCharModel:getActionIndex(ang)
	local index = nil
	if ang >=-30 and ang <=30 then
		index = 1
	elseif ang >30 and ang <=90 then
		index = 2
	elseif ang >90 and ang <=150 then
		index = 3
	elseif ang >150 or ang <-150 then
		index = 4
	elseif ang >-150 and ang <=-90 then
		index = 5
	elseif ang >-90 and ang <=-30 then
		index = 6
	end

	return index
end

function GuildCharModel:deleteMe()
	GuildCharModel.super.deleteMe(self)
end

return GuildCharModel