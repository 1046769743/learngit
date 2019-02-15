-- Author: ZhangYanguang
-- Date: 2017-06-22
-- 六界主角基类model

local WorldMoveModel = require("game.sys.view.world.model.WorldMoveModel")
WorldBaseCharModel = class("WorldBaseCharModel",WorldMoveModel)

function WorldBaseCharModel:ctor( controler )
	WorldBaseCharModel.super.ctor(self,controler)
	--方位对应的动作 左边是动作,右边是sc
	self.charFaceAction = {
        --右 
        {"crossrange",1,},
        -- 右上
        {"leanup",-1},
        -- 左上
        {"leanup",1},
        -- 左
        {"crossrange",-1},
        -- 左下
        {"leandown",-1},  
        --右下
        {"leandown",1},
    }

    self.charActionSize = {
    	crossrange = cc.size(190,240),
    	leanup = cc.size(145,240),
    	leandown = cc.size(145,240)
	}
end

--[[
    更新视图及size
]]
function WorldBaseCharModel:updateModelView(view,size)
    WorldBaseCharModel.super.updateModelView(self,view,size)
    if self.myView then
        self.myView.currentAni:setScaleX(self.charScaleX)
        self.myView:playLabel(self.charFace)
    end
end

--根据角色map方位 rotation 是 角度 不是弧度
function WorldBaseCharModel:mapViewAction( ang )
	-- ang  是-180 到+180之间的数 就是 math.atan2(dy,dx) * 180 /math.pi
    -- local index = math.ceil( (ang +180) / 60)
    local index = self:getActionIndex(ang)
    self:setAction(index)
    -- echo("_____ang",index,ang,ang - 180)
 	--当前角度
 	self.rotation = ang
end

-- 设置右朝向
function WorldBaseCharModel:setRightAction()
    self:setAction(1)
end

-- 设置左朝向
function WorldBaseCharModel:setLeftAction()
    self:setAction(4)
end

-- 设置朝向
function WorldBaseCharModel:setAction(index)
    if index > #self.charFaceAction then
        index = #self.charFaceAction
    end
    if index < 1 then
        index = 1
    end
    
    local action = self.charFaceAction[index][1]
    local scaleX = self.charFaceAction[index][2]
    self.myView.currentAni:setScaleX(scaleX * self.viewScale)
    self.myView:playLabel(action)
    self.charFace = action
    self.charScaleX = scaleX
    self.index = index
    --当前动作标签
    self.label = action
    --当前方位 只分左右
    self.way = scaleX
end

function WorldBaseCharModel:getActionIndex(ang)
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

function WorldBaseCharModel:getActionDirection()
    if self.index == 1 or self.index == 2 or self.index == 6 then
        return 1
    else 
        return -1
    end
end

function WorldBaseCharModel:getPlayerView()
    return self.myView
end

function WorldBaseCharModel:realPos()
    WorldBaseCharModel.super.realPos(self)
    self:setScaleByPos()
end

function WorldBaseCharModel:getWorldPosByPoint(targetPoint)
    local point
    if self.viewCtn then
        point = self.viewCtn:convertToWorldSpaceAR(targetPoint);
    else
        point = GameVars.emptyPoint
    end

    return point
end

-- 根据位置设置缩放，实现近大远小
function WorldBaseCharModel:setScaleByPos()
    if not self.controler then
        return
    end

    if self.myView then
        local turnPos = self.myView:convertToWorldSpaceAR(GameVars.emptyPoint)
        local scale = (1-turnPos.y/GameVars.height) * 0.2 + self.baseScale
        self:setViewScale(scale)
    end
end

return WorldBaseCharModel
