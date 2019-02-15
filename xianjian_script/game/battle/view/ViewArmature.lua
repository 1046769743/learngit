--
-- Author: Your Name
-- Date: 2014-12-23 10:46:13
--
ViewArmature = class("ViewArmature",function (  )
	return display.newNode()
end)


--隐藏bone的 name对象
--[[
	boneName = true or false   true  表示 隐藏  false表示显示


]]
ViewArmature.hideBoneObj = nil

local isCacheAni = true

local disableView =false

--动画缓存
local armatureCache = {}

--[[
	--缓存格式 按照动画的名称缓存
	{
		heroes_1 = {	
					{stand = aramture,walk = armature,...				}	,	
					{stand = aramture,walk = armature,...				}	,	
		},
		heroes_2 = {
					{stand = aramture,walk = armature,...				}	,	
					{stand = aramture,walk = armature,...				}	,	
		}

		effect_hit = {
				{effect_hit = armature},
				{effect_hit = armature},
				...
		
		},
		
	}


]]



local function getArmatureCache(armatureName )
	local arr = armatureCache[armatureName] 
	if not arr then
		return nil
	end

	if #arr == 0 then
		return nil
	end

	local obj = arr[1]
	for k,v in pairs(obj) do
		if v.pos then
			v:pos(0,0)
		end
		FilterTools.clearFilter(v)
	end
	table.remove(arr,1)
		
	return obj
end


local function setArmatureCache(armatureName,actorObj )
	if not armatureCache[armatureName] then
		armatureCache[armatureName] = {}
	end
	--插入actorObj
	table.insert(armatureCache[armatureName],actorObj )
end


local function releaseAni( ani )
	if not ani or tolua.isnull(ani) then
		return
	end
	ani:cleanup()
	ani:release()
end

local function clearGroupArmature( clearArr )
	for i,v in ipairs(clearArr) do
		WindowControler:globalDelayCall(c_func( releaseAni, v) ,i/GameVars.GAMEFRAMERATE  )
	end
end
 
--清除所有的缓存 这里一定要分帧缓存  因为 一次性删除所有的缓存会很卡 
function ViewArmature:clearArmatureCache( )

	local clearArr = {}

	for k,v in pairs(armatureCache) do


		for a,b in ipairs(v) do
			for c,d in pairs(b) do
				table.insert(clearArr, d)
			end
		end
	end
	armatureCache = {}
	clearGroupArmature(clearArr)
end


--显示或者隐藏某个bone
function ViewArmature:visibleBone( boneName ,value)
	self.hideBoneObj[boneName] = value and false or true

	--遍历所有动画  拿取boneName  并显示或者隐藏 该层bone
	for k,v in pairs(self.aniObj) do
		local bone = v:getBone(boneName)
		if bone then
			bone:setVisible(value)
		end
	end
end

--复原所有隐藏的bone
function ViewArmature:setAllHideBoneVisible( bl )
	for i,v in pairs(self.hideBoneObj) do
		if  v then
			for j,k in pairs(self.aniObj) do
				local bone = k:getBone(i)
				if bone then
					bone:setVisible(bl)
				end
			end
		end
	end
end


function ViewArmature:clearOneArmatureCache(armatureName )
	local arr = armatureCache[armatureName]
	if not arr or #arr ==0 then
		return
	end
	--置空 对应动画
	armatureCache[armatureName] = {}
	local clearArr = {}
	for i,v in ipairs(arr) do
		for c,d in pairs(v) do
			table.insert(clearArr, d)
		end
	end
	clearGroupArmature(clearArr)

end


ViewArmature.playNormal=1
ViewArmature.playReWind=-1


--[[
	armatureDatas = {
		labels= {stand,walk,attack,...} or nil   空 表示是 单层动画
		armatureName = "enemy_1" ...			--动画名称
		did 									--did 数据id  这个是用来判断是否从缓存里面拿取的 因为动画的解析卡顿问题  所以需要缓存处理
	}
	
]]


ViewArmature.playSpeed = 1




function ViewArmature:ctor(name,actions,handleUpdate)


	self.hideBoneObj = {}
	self.actions= actions or {}
 	self.armatureName=name
 	-- self._handleUpdate = handleUpdate
 	--判断是否有 labels 没有的话 就是当特效播放  但是为了结构一致  也传入一个固定值
 
	local ani

	local aniObj
	aniObj = getArmatureCache(name)

	self.aniObj = aniObj

	--回调函数
	self.callFuncArr = {}


	if actions then
		local lastLabel 
		if not aniObj then
			self.aniObj ={}
			for k,v in pairs(actions) do
				ani = self:createAniByName(name.."_"..k, name)
				self.aniObj[k] = ani
				lastLabel= k
			end
		end

		--self:playLabel(lastLabel)
	else
		if not aniObj then
			self.aniObj ={}
			local nm = string.split(name,"_")
			ani = self:createAniByName(name,nm[1])
			self.aniObj[name] = ani
		else
			ani = self.aniObj[name]
		end
		
		self:playLabel(name)
		--self.currentAni = ani
		self._totalFrames = ani:getAnimation().getRawDuration and ani:getAnimation():getRawDuration() or 100
	end

end

--初始化完成之后做的事情
function ViewArmature:doAfterInit(  )
	--移除刷新函数
	-- if self.currentAni then
	-- 	self.currentAni:unscheduleUpdate()
	-- end
end


function ViewArmature:createAniByName(armatureName,flaName)

	if not pc.ArmatureDataManager:getInstance():getAnimationData(armatureName) then
		error(armatureName .. "is not exisit")
		return nil
	end

	local ani = FuncArmature.createArmature(armatureName,nil,  true )  --pc.Armature:create(armatureName)

	local defaultScale = ArmatureData:getArmatureShowScale( flaName ,armatureName )
	ani:scale(defaultScale)

	--做一次retain操作
	--必须不是自动播放的
	if isCacheAni then
		ani:retain()
	end
	
	
	return ani
end

--设置是否循环播放 
function ViewArmature:setIsCycle( value )
	if value then
		self.currentAni:playWithIndex(0, 1)
	else
		self.currentAni:playWithIndex(0, 0)
	end
end


--判断某个动作是否存在
function ViewArmature:checkHasLabel( label )
    if self.actions[label] then
    	return true
    end
    return false
end

--获取动作帧长度
function ViewArmature:getTotalFrames(  )
	return self.currentAni:getAnimation():getRawDuration()
end

-- 获得当前动画播放的位置
function ViewArmature:getCurrentFrame()
	return self.currentAni:getAnimation():getCurrentFrameIndex()
end

--获取某个标签的长度
function ViewArmature:getLabelFrames(label )
	if not label then
		return self._totalFrames
	end
	return self.actions[label]
end

--播放某个动作
function ViewArmature:playLabel( label )
	label = label or self.currentLabel
	if self.currentLabel == label then
		return
	end

	if self.currentAni then
		-- self.currentAni:pause()
		
		-- FilterTools.clearFilter(self)
		self.currentAni:removeFromParent()
	end

	
	self.currentAni = self.aniObj[label]  --getArmatureCache(self.armatureName,self.currentLabel):addto(self)
	if not self.currentAni then
		--echo("______可能是召唤物没有这个动作_______",label)
		label = "standby2"
		self.currentAni = self.aniObj[label]
	end
	self.currentAni:addto(self)
	
	self.currentLabel = label

	--每次获取的时候 清除掉自身的滤镜效果
	FilterTools.clearFilter(self.currentAni)
	-- self.currentAni:getAnimation():playWithIndex(0,0,1)
	FuncArmature.playOrPauseArmature(self.currentAni,true)
	self.currentAni:resumeArmature()
	FuncArmature.setArmaturePlaySpeed(self.currentAni,self.playSpeed)
	if disableView then
		self.currentAni:visible(false)
	end

	if self._handleUpdate then
		-- self.currentAni:unscheduleUpdate()
	end
	
end


--设置效果  目前只能设置一个效果
function ViewArmature:setFilter( filterName,params )
	-- body
	self.filter = {name =filterName,params = params}
end


--清除滤镜效果
function ViewArmature:clearFilter( )

	self.filter = nil
end


--设置播放方式  1 正波 -1倒波
function ViewArmature:setPlayType( type )
	self._playType=type
	if self._playType==ViewArmature.playNormal then
		self._currentFrame=1
		self._realFrame = 1
	else
		self._currentFrame=self._totalFrames
		self._realFrame = self._totalFrames
	end
	return self
end


function ViewArmature:stop(  )
	self._isPlay=false
	FuncArmature.playOrPauseArmature(self.currentAni, false )
end

function ViewArmature:play()
    self._isPlay=true
    FuncArmature.playOrPauseArmature(self.currentAni, true )
end


function ViewArmature:gotoAndPlay( frame )
	if frame > 0 then
		frame = frame -1
	end
	self.currentAni:resumeArmature()
	self.currentAni:getAnimation():gotoAndPlay(frame)
	return self
end

function ViewArmature:gotoAndStop(frame)
	if frame > 0 then
		frame = frame - 1
	end
	self.currentAni:getAnimation():gotoAndPause(frame)
	return self
end



function ViewArmature:setPlaySpeed(value )
	self.playSpeed = value
	if self.currentAni then
		FuncArmature.setArmaturePlaySpeed(self.currentAni,self.playSpeed * GameVars.GAMEFRAMERATE /30)
	end
	
end

--目前废弃掉  手动刷新 动画
function ViewArmature:updateFrame( dt )

	--如果已经清空了
	if tolua.isnull(self.currentAni) then
		return
	end

   	self.currentAni:update(Fight.armatureUpdateScale   )
end


function ViewArmature:clear(  )
	
	local index =0
	--清楚所有隐藏的bone
	self:setAllHideBoneVisible(true)
	if isCacheAni then
		setArmatureCache(self.armatureName,self.aniObj)
	end
	

	if self.currentAni then
		self.currentAni:pause()
		self.currentAni:stopAllActions()
		FilterTools.clearFilter(self)
		self.currentAni:removeFromParent(false)
		self.currentAni = nil
	end


	self:removeFromParent()
end


function ViewArmature:deleteMe(  )

	self:clear()
end


--传入一个回调函数
function ViewArmature:pushOneCallFunc( delayFrame,func,params )
	if delayFrame ==0 then
		if params then
			func(unpack(params))
		else
			func()
		end
		return
	elseif delayFrame == -1 then
		--   -1表示最后一帧
		delayFrame = self._currentFrame
	end

	local info = {
		left = delayFrame,
		func = func,
		params = params,
	}
	--插入到最前面
	table.insert(self.callFuncArr,1, info)
end


--停到最后一帧
function ViewArmature:stopToLastFrame(  )
	--不是自动播放的 不执行
	if not self.autoPlay then
		return
	end
	--self:pushOneCallFunc(-1, self.currentAni.pause, {self.currentAni})
end

--缓存一个材质
function ViewArmature.cacheOneTexture( armatureName )	
	local textureFile,plistFile,xmlFile = FuncRes.armature(armatureName)
	if not cc.FileUtils:getInstance():isFileExist(textureFile) then
		echoError("找不到动画fla,动画名:",armatureName)
		return
	end
	pc.ArmatureDataManager:getInstance():addArmatureFileInfo(textureFile,plistFile,xmlFile)
end


return ViewArmature
