



--[[
动画编辑器中的bone对象。也是body对象
]]

AnimModelTransfer = class("AnimModelTransfer", 
		AnimModelBasic
	)


--[[

]]
function AnimModelTransfer:ctor(controler,cfg)
	AnimModelTransfer.super.ctor(self,controler)


    local fazhenAni = self.controler.view:createUIArmature("UI_liujie", "UI_liujie_chuansongfazhen ", self, true)


	self:initView(fazhenAni,0,"effectFaZhen")
	self.cfgData = cfg
end



--[[
self.initView 重写这个方法
]]
function AnimModelTransfer:initView(view,zorder,viewTyp)
	self.view = view
	self.viewType = viewTyp
	if not zorder  then zorder = 0 end
	--self.view:addto(self):pos(0,0)
	self._zorder = zorder


	--法阵动画开始播放
	self.view:play()
end


--[[
后去跳转的位置
]]
function AnimModelTransfer:getTransferPos()
	if self.cfgData then
		return self.cfgData.z
	end
end





--[[
更新每一帧
判断如果动画播放完成，不是stand or walk 则只播放一次
self.cfgData中可以读取到对应的方法属性
]]
function AnimModelTransfer:updateFrame()
	-- if self.curFrame == self.totalFrame then
	-- 	--local label = Fight.actions.action_stand
	-- 	local label
	-- 	if self:chkNeedLoop() then
			
	-- 		label = self.label
	-- 		--echo("循环-------",self._name,label)
	-- 	else
			
	-- 		label = Fight.actions.action_stand	
	-- 		--echo("不循环，直接站立-----",self._name,label)
	-- 	end
	-- 	self:playLabel(label)
	-- else
	-- 	self.curFrame = self.curFrame +1
	-- end
	
end

--[[
检测是否需要循环
]]
-- function AnimModelTransfer:chkNeedLoop()
-- 	if self.label == Fight.actions.action_stand or 
-- 		self.label == Fight.actions.action_stand2 or
-- 		self.label == Fight.actions.action_run or 
-- 		self.label == Fight.actions.action_race2 or 
-- 		self.label == Fight.actions.action_race3 or
-- 		self.label == Fight.actions.action_uncontrol
-- 	then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end







--[[
播放动画
]]
function AnimModelTransfer:playLabel(label)
	
	-- self.view:playLabel(self.cfgData[label], false, false)

	-- self.totalFrame = self.view:getTotalFrames(self.cfgData[label])
	-- --echo("----",label,"=============",self.curFrame,self.totalFrame)
	-- self.curFrame = 0
	-- self.label = label

	-- self.view:gotoAndPlay(self.curFrame)

	-- --开始播放
	-- self:updateFrame()
end



















return AnimModelTransfer