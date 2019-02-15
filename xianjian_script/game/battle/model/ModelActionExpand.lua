

ModelActionExpand = class("ModelActionExpand", ModelFrameBasic)

ModelActionExpand.__viewZOrder = nil

function ModelActionExpand:ctor(...)
	self.modelType = Fight.modelType_treasure
	ModelActionExpand.super.ctor(self,...)

	self.__viewZOrder = 1

	self.data = {}
end


function ModelActionExpand:setTarget(target,aniName,offsetX,offsetY)
	self.player = target
	self.aniName = aniName

	offsetX = offsetX and offsetX or 0 
	offsetY = offsetY and offsetY or 0	
	self:setPos(offsetX,0,offsetY)

	--self.viewData =  FrameDatas.getActionExpandData(self.aniName)
	self.viewData =  FrameDatas.getViewData(false, self.aniName )

	self.data.sourceData = {}
	for k, v in pairs(self.viewData.actionFrames) do
		self.data.sourceData[k] = k
		self.data.sourceData[k] = k
	end
end

-- 设置zorder 1 在人的上面,-1在人的下面
function ModelActionExpand:setViewZOrder(z)
	self.__viewZOrder = z
end


function ModelActionExpand:createView()
	if not self.player then
		return
	end

	local view = ViewArmature.new(self.aniName,self.viewData.actionFrames)
	self.myView = view
	
	return view
end


-- 设置攻击或者创建missle 信息
function ModelActionExpand:setAtkAndMslInfo(skill,atkinfo,missleinfo)
	self.currentSkill = skill
end

-- 要跟随主体
function ModelActionExpand:controlEvent()
	if self.player then
		local playerX = self.player.pos.x + self.player._footRootPos.x
		local playerY = self.player.pos.y + self.player._footRootPos.y
		local playerZ = self.player.pos.z 
		self:setPos(playerX,playerY,playerZ) 
	end
end

-- 主要是为了发送导弹
function ModelActionExpand:frameEvent()
	ModelActionExpand.super.frameEvent(self)
	
	if self.label ~= Fight.actions.action_attack1 then
		return
	end
end


return ModelActionExpand