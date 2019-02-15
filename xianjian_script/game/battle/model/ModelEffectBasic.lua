--
-- Author: dou
-- Date: 2014-03-10 14:18:29
--
ModelEffectBasic = class("ModelEffectBasic", ModelBasic)

ModelEffectBasic.target = nil --跟随对象
ModelEffectBasic.info = nil --跟随信息
ModelEffectBasic.frame = 0
ModelEffectBasic.frameEvent = nil 
ModelEffectBasic.skillEffect = nil
ModelEffectBasic.follow = false
ModelEffectBasic.existFrame = -1
function ModelEffectBasic:ctor( ...)
	ModelEffectBasic.super.ctor(self,...)
	--特效 深度排列类型优先级比较高
	self.depthType = 9
	self.data = {}
	self.modelType = Fight.modelType_effect
	self._zorderAdd = 0
	self.frameEvent = {}
	if self.controler:isQuickRunGame() then
		echoError("为什么还走到这里来了")
		return
	end
end


--创建特效类型
function ModelEffectBasic:getAniByType( animation ,isCycle,target)
	local ani = nil
	animation = animation and animation or "effect_1_behit"
	target = target or self
	-- 可能是spine动画
	local spineName = FuncArmature.getSpineName(animation)
	if spineName then
		if not isCycle then
			isCyle =false
		end
		local f1,f2 = FuncRes.spine(spineName) -- 这地方没有传atlasName
		local isCache = pc.PCSkeletonDataCache:getInstance():checkSkeletonDataIsPreLoad(f1)
		if not isCache then
			if target:isSummon() then
				-- 召唤物没有做预加载、所以先打一个警告
				echoWarn("找战斗策划，改角色是召唤物---特效：%s 未做缓存,请检查角色：%s配对的法宝 在Source表中的effSpine列是否填了该缓存!",spineName,target.data.hid)
			else
				echoError("找战斗策划，特效：%s 未做缓存,请检查角色：%s配对的法宝 在Source表中的effSpine列是否填了该缓存!",spineName,target.data.hid)
			end
		end
		ani = ViewSpine.new(spineName,nil,nil,spineName,true)
		ani:playLabel(animation,isCycle)
		--一定是从第一帧开始播放
		ani:gotoAndPlay(1)
	else
		--暂时加上这个
		-- local flaName = FuncArmature.getArmatureFlaName(animation)
		-- if flaName then
		-- 	FuncArmature.loadOneArmatureTexture(flaName, nil,true)
		-- else
		-- 	echoWarn("没有找到对应动画的fla:",animation)
		-- end
		
		ani = ViewArmature.new(animation)
	end
	self.animation = animation

	return ani
end


--设置最后一帧的回调
function ModelEffectBasic:setCallFunc( func ,params)
	self.endCallFunc = func
	self.endCallFuncParams =  params
end


function ModelEffectBasic:initView( ... )
	ModelEffectBasic.super.initView(self,...)
	-- self.myView.currentAni:scale(1,1)
	self.totalFrame = self.myView:getLabelFrames()
	if self.totalFrame == 1 then
		-- 手动加一帧防止无法正常销毁
		self.totalFrame = 2
	end
	if not self.isCycle then
		self.myView:setIsCycle(false)
	end
	
end

--锁定在中心
function ModelEffectBasic:setLockInCenter(  )
	self.lockCenter = true
	--让这个视图锁定在屏幕中心渲染
	self.myView:setLockTransform(true)
	self:setPos(GameVars.width /2,-GameVars.gameResHeight/2)

end


function ModelEffectBasic:setFollowBoneName( boneName )
	self.followBoneName = boneName
end

function ModelEffectBasic:onSkillBlack(  )
	self:updateZorder()

end

function ModelEffectBasic:updateZorder(  )
	if not self.target then
		return
	end
	if Fight.isDummy  then
		return
	end
	if self.target._isDied then
		return 
	end
	--如果我跟随的人zorder大于blackChar了 那么我也需要加上黑屏zorder
	if self.target.myView:getLocalZOrder()> Fight.zorder_blackChar then
		self.myView:zorder(self.target.__zorder + Fight.zorder_blackChar + self._zorderAdd)
	else
		
		self.myView:zorder(self.target.__zorder +  self._zorderAdd)
	end
end


function ModelEffectBasic:setTarget( target,pianyiX,pianyiY,pianyiZ,zorderAdd )
	self.target = target
	pianyiX = pianyiX and pianyiX or 0
	pianyiY = pianyiY and pianyiY or 0
	pianyiZ = pianyiZ and pianyiZ or 0
	--zorder 偏移 是主角的zorder + zorderAdd  就是特效的zorder
	self._zorderAdd = zorderAdd
	self.pianyiPos = {x=pianyiX,y=pianyiY,z=pianyiZ}
	if self.followBoneName then
		local isBoneExist = self.target.myView:isBoneExist(self.followBoneName)
		if not isBoneExist then
			echoWarn("__hid:%s, spine动画%s没有这个骨头:%s",self.target.data.sourceData.hid,self.target.data.sourceData.spine, self.followBoneName)
			self.followBoneName = nil
		end
	end
	-- echo(self.pianyiPos.y,"____self.pianyiPos")
end

function ModelEffectBasic:setFollow( follow )
	if follow == 0 then
		follow = false
	end
	self.follow = follow
end

--是否循环
function ModelEffectBasic:setIsCycle( value, existFrame)
	self.isCycle = value
	self.existFrame = existFrame or -1

end

--技能的特效
function ModelEffectBasic:setSkillEffect( t )
	self.skillEffect = t
end


function ModelEffectBasic:pauseAtLastFrame(buff)
	self.pauseLastFrame = true
end

function ModelEffectBasic:runBySpeedUpdate( )
	
	self.updateCount = self.updateCount + 1
	--必须目标没有死亡
	if self.follow and not self.target._isDied then
		--如果是有跟随骨头的
		if self.followBoneName then
			local bonePos = self.target.myView:getBonePos(self.followBoneName)
			if not bonePos then
				if not self._hasEchoWarn then
					self._hasEchoWarn  = true
					self.followBoneName = nil
					
				end
				
				bonePos = {x=0,y = 0}
			end
			-- echo(self.target.pos.x, self.pianyiPos.x, self.target.way, bonePos.x, Fight.wholeScale)
			--这里跟随的时候 需要加上目标的速度 否则就会出现坐标匹配补上的感觉
			self.pos.x = self.target.pos.x + self.pianyiPos.x*self.target.way + bonePos.x * self.target.way * Fight.wholeScale 
			self.pos.y = self.target.pos.y + self.pianyiPos.y  
			self.pos.z = self.target.pos.z + self.pianyiPos.z - bonePos.y*Fight.wholeScale 
		else
			self.pos.x = self.target.pos.x + self.pianyiPos.x*self.target.way + self.target._footRootPos.x 
			self.pos.y = self.target.pos.y + self.pianyiPos.y 
			self.pos.z = self.target.pos.z + self.pianyiPos.z - self.target._footRootPos.y
			
		end
		-- self:setWay(self.target.way)
		self:countScale()
		
	else
		
	end
	self:updateZorder()
	self:realPos()
	--每5帧一次 zorder调整
	-- if self.target and self.updateCount % 3 ==1 then
	-- 	self.myView:zorder(self.target.__zorder + self._zorderAdd)
	-- end

	if self.selfPause then
		return
	end

	--如果是循环的
	if self.isCycle then
		if self.existFrame > 0 then
			self.existFrame = self.existFrame -1
			if self.existFrame ==0 then
				self:deleteMe()
			end
		end
		return
	end
	--如果是最后一帧
	if self.updateCount == self.totalFrame -1 then
		if self.pauseLastFrame and self.pauseLastFrame == true then	
			if self.myView then
				self.myView:stop()
			end
		else
			self:deleteMe()
			if self.endCallFunc then
				local endFunc = self.endCallFunc
				local params = self.endCallFuncParams
				self.endCallFunc  = nil
				self.endCallFuncParams = nil
				if params then
					endFunc(unpack(params))
				else
					endFunc()
				end
				

			end

		end
	end
end


function ModelEffectBasic:deleteMe( ... )
	if self._isDied then
		return
	end

	if self.target then
		if self.skillEffect then
			self.target:clearSkillEff(self)
		end
		if self.animation then
			self.target:removeOneEffect(self.animation)
		end
		
		self.target = nil
	end

	ModelEffectBasic.super.deleteMe(self,...)
end


--==============================================================================
--===================== 一些特殊作用的特效 =====================================
--==============================================================================


--创建粒子拖尾效果
--[[
    fromPos {x=100,y=100},初始位置
    endPos  结束位置
    time  缓动时间
    image  图片路径url test/test_img_xiaohong.png
    wid     粒子的显示尺寸
    color   颜色 cc.c3b
    endFunc     缓动结束函数
    endClear    缓动结束后是否自动删除
]]
function ModelEffectBasic:createMotionStreak(way, fromPos,toPos,time,image,wid, color, endFunc,endClear )
    local nd = display.newNode()

    local path = FuncRes.iconOther( "other_icon_ChaPoint.png" )
    local motionStreak = cc.MotionStreak:create(0.5,wid,wid,color,path)
    motionStreak:pos(fromPos):addto(nd)

    --local sp = display.newSprite(path):size(wid,wid)
    local sp = ViewSpine.new("eff_treasure0",nil,nil,"eff_treasure0")
    sp:playLabel("eff_treasure0_hun")
    sp:pos(fromPos):addto(nd)

    
    local onComplete = function (  )
        if endClear then
            nd:delayCall(c_func(nd.clear,nd,true ),1)
        end
        if endFunc then
            endFunc()
        end
    end

    -- 以持续时间和贝塞尔曲线的配置结构体为参数创建动作  
    local bezier = {  
        cc.p(fromPos.x + 100*way, fromPos.y+100),  
        cc.p(fromPos.x + 150*way, fromPos.y),   
        cc.p(toPos.x, toPos.y),  
      }  
    local bzto = cc.BezierTo:create(time, bezier)     
    motionStreak:runAction(bzto)


    local bzto2 = cc.BezierTo:create(time, bezier)   
    local act_call = act.callfunc( onComplete )
    local seq = cc.Sequence:create({bzto2,act_call})
    sp:runAction(seq) 
    return nd
end



--一些通用特效映射类型
ModelEffectBasic.effMapType = {
	xuanyun = 1,
	bingdong = 2,
	yishang = 3,
	jisha = 4,
	teshuji = 5, 	--触发特殊技能
}


--[[
	2017.9.27 增加参数 showRandom == true 时 显示对应帧数的随机文字
]]
function ModelEffectBasic:checkShowBuffBone( bone,frame,kind,showRandom )
	if kind ~= 1 and kind ~= 2 then
		kind = 1
		echoError("frame:",frame,"showBuffBone ,错误的kind",kind)
	end
	local useLayer = nil
	local targetNode 
	local sp = FuncRes.iconBuffword(frame,kind,showRandom)
	bone:addDisplay(sp,0)
end

--创建头顶特效 
-- effType 1是眩晕 2是冰冻 3是易伤 4是击杀奖励
function ModelEffectBasic:createCommonHeadEff( effType,kind,hero )
	if Fight.isDummy then
		return
	end

	local effName 
	local boneName = "a"
	if hero.camp == 1 then
		effName = "common_buff_zia"
	else
		effName = "common_buff_zib"
		boneName = "a_copy"
	end

	local eff = hero:createEff(effName, 0, 100, 2, 1, true, true, false,nil,true,hero)
	local ani = eff.myView.currentAni
	ani:setScaleX(Fight.cameraWay )
	kind = kind or Fight.buffKind_huai
	self:checkShowBuffBone( ani:getBone("a"),effType,kind  )
	self:checkShowBuffBone( ani:getBone("a_copy"),effType,kind  )
	return eff
end
--创建buffWord特效
function ModelEffectBasic:createBuffWordEff( effectFrame,kind ,hero)
	local effName

	if kind == Fight.buffKind_hao  then
		effName = "common_buff_shangsheng"
	else
		effName = "common_buff_xiajiang"
	end

	-- if hero.camp == 1 then
	-- 	effName = "common_buff_zia"
	-- else
	-- 	effName = "common_buff_zib"
	-- end

	-- if kind == Fight.buffKind_hao  then
	-- 	effName = "common_buff_zia"
	-- else
	-- 	effName = "common_buff_zia"
	-- end
	local boneName = "a"

	local ypercent = 100
	if kind == Fight.buffKind_hao  then
		-- ypercent = 120
	else
		-- ypercent = 80
	end
	local eff = hero:createEff(effName, 0, ypercent, 2, 1, true, true, false,nil,true,hero)
	local ani = eff.myView.currentAni

	eff.myView.currentAni:setScaleX(Fight.cameraWay )

	self:checkShowBuffBone(ani:getBone(boneName),effectFrame,kind)
	return eff
end



return ModelEffectBasic