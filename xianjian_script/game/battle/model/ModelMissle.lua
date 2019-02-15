--
-- Author: XD
-- Date: 2014-07-24 10:39:44
--
local Fight = Fight
ModelMissle = class("ModelMissle", ModelHitBasic)


ModelMissle.appearPos = nil
ModelMissle.attTarget = nil
ModelMissle.replicatView = nil


-- 以下需要备份
ModelMissle.currentSkill = nil
ModelMissle._attackNums = 0
ModelMissle._area = nil -- 碰撞检测区域
ModelMissle._isRepeat = nil
ModelMissle._zorderAdd = 0 --zorder 相对与player的zorder偏移

function ModelMissle:ctor( controler, obj, skill )
	self.modelType = Fight.modelType_missle
	ModelMissle.super.ctor(self,controler, obj)
	self.depthType = 7
	
	self.currentSkill = skill
	self.gravitiAble =false
	self.hitBorderAble = true-- 默认边界检测
	self.appearPos = {x=0,y=0}
	self._area = {}	
	self._isRepeat = false -- 是否重复攻击同一个人
end

function ModelMissle:initView(...)
	ModelMissle.super.initView(self,...)
	if self.myView then
		-- if self.data:sta_playTime() == 1 then
		--取消 playtime
		if self.data:sta_dieCtrl() == 1 then
			self.myView:setIsCycle(false)
		end
	end
	self:checkCanPlayView()
end


function ModelMissle:getViewData( obj )
	local armature = obj.curArmature
	if Fight.isDummy  then
		self.viewData = {}
		return
	end
	if obj.spineName then
		--说明是spine动画
		local spineData = FuncArmature.getSpineArmatureFrameData( obj.spineName )
		local viewFrame = spineData.actionFrames[armature]
		self.viewData = {frames = viewFrame,image = armature,spine = obj.spineName}
	else
		self.viewData = FrameDatas.getViewData(false, obj.curArmature )
		if not self.viewData then
			echoError("_找策划_这个missle的动画配置没有找到:",obj.curArmature,obj.hid)
		end
	end

end


--设置 有
function ModelMissle:setTarget(player,attackTarget,carrier,pianyiY )

	self.player = player
	--如果指定载体 那么载体就是player 这个主要是用来处理初始创建坐标的 ,不需要存储
	self.carrier = carrier or player

 	if self.data.atkData then
		self.atkData = self.data.atkData
	else
		self.atkData = self.data.attackInfos[1][2]
	end

	self._attackNums = self.atkData:sta_attackNums()
	
	if attackTarget then
		self.attTarget = attackTarget
		self.focusHit = true
	else
		-- 确定攻击目标
		-- self:checkAtkTarget()
	end
	
	self:setWay(self.player.way)

	local chooseArr = AttackChooseType:atkChooseByType(self.player, self.atkData,nil, self.campArr, self.toArr,self.currentSkill )
	if not chooseArr or #chooseArr ==0 then
		echo("创建的目标missle没有选中人")
	else
		local firstHero = chooseArr[1]
		local lastHero = chooseArr[#chooseArr]
		local xpos,ypos,zpos = 0,0,0
		xpos = xpos + ( firstHero.pos.x+  lastHero.pos.x ) /2
		ypos = ypos + ( firstHero.pos.y+  lastHero.pos.y ) /2
		ypos = ypos + pianyiY
		local appearType = self.data:sta_appearType()
		--如果是锁定y坐标为中间的
		if appearType == 2 then
			ypos = Fight.initYpos_3
		end
		self:setPos(xpos, ypos,zpos)
	end

end

-- 确认打击的目标
function ModelMissle:checkAtkTarget()
	-- 如果不是打击最近的人. 则必须给一个目标   目前不考虑运动类型和速度问题	
	local chooseArr = AttackChooseType:atkChooseByType(self.player,self.atkData,attTarget,self.campArr,self.toArr,self.currentSkill)   
	if #chooseArr > 0 then
		self.attTarget = chooseArr[1]
		self.atkData.attTarget = self.attTarget
	else
		echoWarn("__________error! missle,missle没有获取选中目标")
	end
	return chooseArr
end

-- 初始化速度
function ModelMissle:adjustSpeedByMoveType()	
	local speed = self.data:sta_speed()
	if speed and speed > 0 then
		if self.data.moveType == Fight.missle_moveType_paowuxian then -- 抛物线

			local x1 = self.pos.x
			local y1 = self.pos.y
			local z1 = self.pos.z

			local hitHeight = self.data:sta_hitHeight() or 50
			local x2 = self.attTarget.pos.x
			local y2 = self.attTarget.pos.y
			local z2 = self.attTarget.pos.z-self.attTarget.data.viewSize[2]*hitHeight/100 

			local dx = x2- x1
			local xspeed 
			local h = -80
			local absDx = math.abs(dx)
			local addspeedz  =0
			local zspeed
			local yspeed
			local dy = y2 -y1
			if dx==0 then
				xspeed = 0
				yspeed =0
				zspeed =0
			else
				xspeed = self.data.speed / dx* absDx
				local time = dx/xspeed
				
				yspeed = dy / time

				--算高度 上升高度在-80 到-120之间
				local minHei = 80
				local maxHei = 300
				local hei = -absDx /3
				hei = hei < minHei and minHei or hei
				hei = hei > maxHei and maxHei or hei
				--目标z不能在上空
				if z1 -  z2 > hei  then
					z2 = z1 - hei + 10
				end
				
				zspeed,addspeedz = Equation.countSpeedZBySEH(x1,z1,x2,z2,xspeed,z1 - hei )
			end
			self:setSpeed(xspeed,yspeed)
			self:initJump(zspeed)
			self.gravitiAble = true
			self:setGravity(addspeedz)

		elseif self.data.moveType == Fight.missle_moveType_xie then -- 斜下运动
			local targetEnemy
			if not self.attTarget then			
				local nearArr = self.player:getNearEnemy(true)
				if #nearArr > 0 then
					targetEnemy = nearArr[1]
				else
					--这儿如果被魅惑了就会出问题,可以直接return
					return
				end
			else
				targetEnemy = self.attTarget
			end
			local targetPos = {x = targetEnemy.pos.x  , y = targetEnemy.pos.y,z = targetEnemy.pos.z - targetEnemy.data.viewSize[2]*Fight.hit_position }
			self:mapSpeedToTargetPos(targetPos,self.data.speed,self.data.changeRota)
			
		else
			self:initMove(speed*self.way,0)
		end
	--如果是按固定帧运动
	elseif self.data.moveType == Fight.missle_moveType_frame then
		local moveFrame = self.data:sta_mFrame()
		if not moveFrame or moveFrame ==0 then
			echoError("这个miss运动方式是按帧运动但是没有配置帧"..self.data.hid)
		end
		local target = self.attTarget
		--如果没有攻击目标
		if not target then
			return
		end

		local targetPos = {x = target.pos.x  , y = target.pos.y,z = target.pos.z - target.data.viewSize[2]*Fight.hit_position }
			
		local xspeed = (target.pos.x -self.pos.x ) / moveFrame
		self:initMove(xspeed,0)
	end
end

-- 帧事件
function ModelMissle:controlEvent()
	ModelMissle.super.controlEvent(self)
	
	--如果是有攻击检测帧数的
	-- if self.data.attackInfos  then
	-- 	for i,v in ipairs(self.data.attackInfos) do
	-- 		if v[1] == self.updateCount then
	-- 			self.atkData = v[2]								
	-- 			self:checkAttack(self.atkData)
	-- 			--如果是按帧检测的 那么 通常是可以进行重复打击的
	-- 			self:initHitObjs()
	-- 		end
	-- 	end
	-- else
	-- 	--检查攻击
	-- 	self:checkAttack(self.atkData)
	-- end
	
	--如果是按固定帧运动的
	-- if self.data.moveType == Fight.missle_moveType_frame then
	-- 	local moveFrame = self.data:sta_mFrame() + 1
	-- 	if self.updateCount == moveFrame then
	-- 		self:initStand()
	-- 	end
	-- end


	self:checkDied()
end

--判断死亡
function ModelMissle:checkDied(  )
	if self.data:sta_dieCtrl() == 1 then
		--如果是到达最后一帧了
		if self.updateCount >= self.viewData.frames then
			self:startDoDiedFunc()
		end
	else
		--如果是运动的
		if #self.toArr == 0 then
			self:startDoDiedFunc()
			return
		end

		if self.data.existFrame >= 0  then
			--如果到达存活时间了
			if  self.data.existFrame == self.updateCount then
				self:startDoDiedFunc()
			end
		end
	end
	
end


--攻击交互-----------------------------------------------
--检测攻击   
function ModelMissle:checkAttack(atkData)
	if not atkData then
		error("没有找到当前动作数据:"..self.player.label)
	end

	if self._isRepeat then
		self._attackNums = self.atkData:sta_attackNums()
	end

	--如果不能打人了
	if self._attackNums == 0 then		
		return
	end
	
	-- 如果是强制攻击的话可以直接
	local must = true
	-- 先扩散在检测攻击,
	-- self:checkDiffusion(atkData)
	local useWay = atkData:sta_useWay()
	local campArr = self.toArr
	if useWay == 1 then --本方人员
		campArr = self.campArr
	end
	
	local chooseArr = nil
	chooseArr = AttackChooseType:atkChooseByType(self.player,atkData,self.attTarget,self.campArr,self.toArr,self.currentSkill)

	local dieCtrl = self.data:sta_dieCtrl()

	local hitedArr = {}
	
	-- 循环遍历敌人 
	for i=1,#chooseArr do
		-- 控制打击的人数
		if self._attackNums == 0 then
			break
		end

		local enemy = chooseArr[i]
				
		if must then
			self:sureAttackObj(enemy,atkData)

			--如果需要创建missle的 ,那么新missle的载体就是自己
			table.insert(hitedArr, enemy)

			--如果目标生命值小于0  那么需要更换attack目标
			if self.attTarget and self.attTarget.data:hp()<=0 then
				self.attTarget = enemy
			end

			self._attackNums = self._attackNums - 1

			if dieCtrl == 0 then
				-- local through = self.data:sta_through()
				-- 这儿不管是否设置穿透,只要设置目标了,则打击到目标,子弹就消失
				-- 但是如果这个子弹是播放一遍的,可能是一直打击一个目标,这儿就不控制子弹的消失
				-- if enemy == self.attTarget and not self._isRepeat and through ~= 1 then -- 可重复打击就不删除
				--取消through
				if enemy == self.attTarget and not self._isRepeat  then -- 可重复打击就不删除
					self:initStand()
					self:startDoDiedFunc()
					break					
				end

				--那么开始做死亡函数
				-- if self._attackNums == 0 and self.data:sta_through() ~= 1 then
				if self._attackNums == 0  then
					-- 如果只设定穿透没有目标,则会打到屏幕外面
					self:initStand()
					self:startDoDiedFunc()
					break		
				end
			end
		end
	end
end


-- 检测扩散
function ModelMissle:checkDiffusion(atkData)
	local erea = atkData:sta_area()
	
	--有扩散攻击才需要这样
	if self.data:sta_diffusion() then
		local e1 = numEncrypt:getNum(erea[1])
		local e2 = numEncrypt:getNum(erea[2])
		local kind = self.data:sta_diffusion()
		if kind == Fight.diffusion_youce then
			e2 = e2 + self.data:sta_difSpeed()*self.updateCount--*self.way
		elseif kind == Fight.diffusion_zuoce then
			e1 = e1 - self.data:sta_difSpeed()*self.updateCount--*self.way
		else
			e1 = e1 - self.data:sta_difSpeed()*self.updateCount--*self.way
			e2 = e2 + self.data:sta_difSpeed()*self.updateCount--*self.way
		end	
		self._area = {e1,e2}
	else
		self._area = erea or {-40,40}
	end

	
end




--确定攻击到谁了
function ModelMissle:sureAttackObj( enemy,atkData )
	table.insert(self.hitObjs, enemy)

	--实际上是子弹的载体打了队伍 
	enemy:runBeHitedFunc(self.player,atkData,self.currentSkill)
end


--边界检测  
function ModelMissle:checkBorder(  )
	if not self.controler.middlePos then
		return false
	end
	--当dieCtrl 为2的时候 没必要判断 强制删除missle 即可
	local far = self.pos.x - self.appearPos.x 
	--远处消失
	if math.abs(far) > 1200 then
		self:initStand()
		self:startDoDiedFunc()
		return true
	end
	return  false
end


-- miss 着地函数
function ModelMissle:fallLand(  )
	self:initStand()
	self:startDoDiedFunc()
end

--开始死亡
function ModelMissle:startDoDiedFunc( diedType )
	ModelMissle.super.startDoDiedFunc(self,diedType)

end

--重写死亡函数
function ModelMissle:deleteMe(  )

	-- self.controler.logical:onAttackComplete(self.player.camp,self.player.data.posIndex)
	
	if self.replicatView then
		self.replicatView:deleteMe()
		self.replicatView = nil
	end

	ModelMissle.super.deleteMe(self)
end


--执行被打函数
function ModelMissle:runBeHitedFunc( attacker,atkData,skill )
	
	--获取作用方式
	local useType = atkData.useType

	--目前临时这样定义 攻击伤害
	local damage = attacker.data:atk() 
	damage = damage < 1 and 1 or damage	

	--比如伤害大于0
	if damage > 0 then
		--同时改变能量值
		self.data:changeValue(Fight.value_health ,-damage)

		self:createNumEff(Fight.hitType_shanghai ,-damage)
	end

	if self.data:hp() and  self.data:hp() <= 0 then
		self:startDoDiedFunc()
	end

end



return ModelMissle