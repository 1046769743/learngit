--[[
    Author: 张燕广
    Date:2017-10-25
    Description: 公会小游戏玩家基类
]]

local GuildMoveModel = require("game.sys.view.guildActivity.model.GuildMoveModel")
GuilddBaseCharModel = class("GuilddBaseCharModel",GuildMoveModel)

function GuilddBaseCharModel:ctor( controler )
	GuilddBaseCharModel.super.ctor(self,controler)
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

--根据角色map方位 rotation 是 角度 不是弧度
function GuilddBaseCharModel:mapViewAction( ang )
	-- ang  是-180 到+180之间的数 就是 math.atan2(dy,dx) * 180 /math.pi
    -- local index = math.ceil( (ang +180) / 60)
    local index = self:getActionIndex(ang)

    -- echo("_____ang",index,ang,ang - 180)

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

    --当前动作标签
 	self.label = action
 	--当前方位 只分左右
 	self.way = scaleX
 	--当前角度
 	self.rotation = ang

 	self.charFace = action
 	self.charScaleX = scaleX
    self.index = index
end

-- 初始化玩家名字和头衔
--Author:      zhuguangyuan
--DateTime:    2018-01-15 09:56:07
--Description: gve二期需求
function GuilddBaseCharModel:initPlayerNameAndTitle( _playSpine,_titlePanelView,_playerInfo )
    if _playSpine and _titlePanelView then
        self:initTitlePanleView(_titlePanelView,_playerInfo)
        _titlePanelView:parent(_playSpine)
        _titlePanelView:anchor(0.5,0.5)
        _titlePanelView:pos(0,144)
    end
end

function GuilddBaseCharModel:initTitlePanleView( _titlePanelView,_playerInfo )
    if _titlePanelView then
        _titlePanelView:visible(true)
        _titlePanelView.txt_name:setString(_playerInfo.name)
        local crown = _playerInfo.crown 
        if crown > 0 then
            _titlePanelView.mc_touxian:showFrame(crown)
        else
            _titlePanelView.mc_touxian:showFrame(1)
        end

        local titleId = _playerInfo.title
        if titleId ~= "" then
            TitleModel:showtitle(titleId,_titlePanelView.ctn_1)
        end

        local width = FuncCommUI.setRichwidth(_playerInfo.name)
        local x = _titlePanelView.mc_touxian:getPositionX()
         _titlePanelView.mc_touxian:setPositionX(x-width/2-55)
    end
end

function GuilddBaseCharModel:setPlayerZorder()
    self.myView:setLocalZOrder(1000)
end
function GuilddBaseCharModel:getActionIndex(ang)
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

function GuilddBaseCharModel:getActionDirection()
    if self.index == 1 or self.index == 2 or self.index == 6 then
        return 1
    else 
        return -1
    end
end

function GuilddBaseCharModel:getPlayerView()
    return self.myView
end

function GuilddBaseCharModel:deleteMe()
    GuilddBaseCharModel.super.deleteMe(self)
end

return GuilddBaseCharModel
