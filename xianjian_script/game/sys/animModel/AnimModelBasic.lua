
Fight = Fight  or {}
Fight.actions = {}

Fight.actions = {
    action_stand = "stand",
    action_stand2 = "stand2",   --防守状态的站立

    action_stand2Start = "stand2Start" ,    --防守战力开始

    action_readyStart = "readyStart", --攻击准备开始
    action_readyLoop = "readyLoop", --攻击准备循环

    action_standSkillStart = "standSkillStart",     --大招待机
    action_standSkillLoop = "standSkillLoop",     --大招待机循环


    action_run = "run",
    action_race2 = "race2",
    action_race3 = "race3" ,
    action_attack1= "attack1",
    action_attack2= "attack2",
    action_attack3= "attack3",
    action_blow1= "blow1",
    action_blow2= "blow2",
    action_blow3= "blow3",
    action_win= "win",
    action_die= "die",
    action_hit= "hit",
    action_walk= "walk",
    action_treaOver = "treaOver",
    action_treaOn = "treaOn",       --法宝上身
    action_treaOn2 = "treaOn2",        --小技能上身
    action_treaOn3 = "treaOn3",         --大招上身
    action_giveOutBS = "giveOutBS",     --祭出B开始
    action_giveOutBM = "giveOutBM",     --祭出B循环
    action_giveOutBE = "giveOutBE",     --祭出B结束

    action_inAction = "inAction",     --登场



    action_original = "original" ,      --素颜法宝恢复
    action_block = "block",             --格挡
    action_relive = "relive",           --复活

    action_powerup = "powerup" ,        --击杀播放powerup

    action_uncontrol = "uncontrol" ,    --晕眩播放这个动作

}






--[[
剧情编辑器中的model对象基类
]]

AnimModelBasic = class("AnimModelBasic", function()
    return display.newNode()
end)


--[[
Constructor

]]
function AnimModelBasic:ctor(controler)
	self.controler = controler
end

--[[
view:ViewSpine.new()出来的视图
viewType: bone   effect
]]
function AnimModelBasic:initView(view,zorder,viewTyp)
	self.view = view
	self.viewType = viewTyp
	if not zorder  then zorder = 0 end
	self.view:addto(self):pos(0,0)
	self._zorder = zorder
    self._viewScale = 1
end

-- 设置缩放
function AnimModelBasic:setScale(scale)
    if not scale then return end
    self._viewScale = scale
    if self.view then
        self.view:setScale(self._viewScale)
    end
end

--[[
设置层级关系.  但是真正的排序放在view中。这里只是记录
]]
function AnimModelBasic:setAnimOrder(zOrder)
    
	self._zorder = zOrder
end


--[[
获取当前记录的层级
]]
function AnimModelBasic:getAnimOrder()
	return self._zorder
end


--[[
获取父节点的名字，body1 body2 ...  or root
]]
function AnimModelBasic:getparentStr()
	return self._parentStr
end



function AnimModelBasic:getViewType()
	return self.viewType
end
function AnimModelBasic:setViewType(_type)
    self.viewType = _type
end

--[[
设置父节点的名字
如果没有则为root
]]
function AnimModelBasic:setParentStr(strName)
	if not strName then
		strName = "root"
	end
	self._parentStr = strName
end

--[[
设置名字
]]
function AnimModelBasic:setNameStr(nameStr)
	self._name = nameStr
end


--[[
获取名字
]]
function AnimModelBasic:getNameStr()
	return self._name
end



--[[
update
给子类用
]]
function AnimModelBasic:updateFrame()

end


--[[
本Spine执行播放动画
获取这个spine 对应label的帧长度
]]
function AnimModelBasic:playLabel(label)

	-- self.totalFrame = self.view:getTotalFrames(label)
	-- self.curFrame = 0
	-- --开始播放
	-- self.view:playLabel(label, false, false)
	--gotoAndPlay
end

function AnimModelBasic:deleteMe()
     --销毁事件
    EventControler:clearOneObjEvent( self )
end

return AnimModelBasic

