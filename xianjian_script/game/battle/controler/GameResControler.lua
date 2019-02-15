--
-- Author: xd
-- Date: 2016-04-25 12:24:10
--战斗资源管理器
local Fight = Fight
-- local BattleControler = BattleControler
GameResControler = class("GameResControler")

--缓存的数组
GameResControler._textureFlaArr = nil
GameResControler._textureSpineArr = nil

GameResControler.onLoadComplete = nil -- 加载完资源回调函数
GameResControler.cacheTexIdx = 0 -- 缓存资源控制

GameResControler.controler = nil
--
function GameResControler:ctor(controler)
	self.controler = controler
	self._textureFlaArr = {}
	self._textureSpineArr = {}
	self._soundEffect = {}
	self._isInCache = false
	self._exMapArr = {}

end
function GameResControler:resetControler(controler )
	self.controler = controler
	self:resetMapControler()
end
-- 加载地图
function GameResControler:resetMapControler()
	local _controler = self.controler
	local layer = _controler.layer
	_controler.map =  MapControler.new(layer.a11,layer.a13,_controler.levelInfo.__mapId, true )
end

--检测是否缓存了资源
function GameResControler:checkIsHasSpineRes(spbName,spineName)
	for i=1,#self._textureSpineArr do
		local spine = self._textureSpineArr[i]
		if spine[1] == spbName and spine[2] == spineName then
			return true
		end
	end
	return false
end

-- 技能.. 这儿要考虑循环创建的情况,如果创建的人物是objherohid 则不需要缓存.因为是召唤的自己分身
function GameResControler:cacheSkillSummonResource( skill, objHeroHid )
	for i,v in pairs(skill.attackInfos) do
		if v[1] == Fight.skill_type_summon then
			if v[3].hid ~= objHeroHid then
				self:cacheOneHeroResource(v[3])
			end
		end
	end
end

--缓存召唤物的资源
function GameResControler:cacheSummonResource( trea )
end

-- cache一个英雄的所有材质,ignoreCacheArt:忽略法宝的动作[仙界对决中使用，先加载伙伴的各项数据，最后再加载时装]
function GameResControler:cacheOneHeroResource( obj,add,ignoreCacheArt)
	local arr
	if add then
		arr = {spineArr = {},flaArr={},soundArr = {}}
	end
	-- char表配置的默认皮肤(其实这个可以不用加,因为必定会是默认的资源)
	-- table.insert(self._textureSpineArr,obj.defArmature)
	-- 添加纹理、【不需要缓存至TextureControler 则不传rid]

	local _checkAdd = function(rid,spbName,spineName)
		if rid and rid == UserModel:rid()	then
			if not TextureControler:checkOneHeroIsCache(spbName,spineName) then
				-- echo("缓存一个角色纹理---",spineName)
				TextureControler:cacheOneHeroSpine(spbName,spineName)
			end
		end
	    -- 唯一资源 
	    local has = self:checkIsHasSpineRes(spbName,spineName)
	    if not has then
	    	table.insert(self._textureSpineArr,{spbName,spineName})
	    	if add then
	    		table.insert(arr.spineArr,{spbName,spineName})
	    	end
	    end
	end
	-- 加载法宝特效
	local _checkAddTreasure = function (obj,trea )
		if not ignoreCacheArt then
			local spineName = trea.spineName
			if spineName then --B 类法宝没有配置这个字段
				local spbName = trea.spineName

				if spineName == "0" then
					spineName = obj.defArmature 
					spbName = obj.defSpbName     
			    end
			    _checkAdd(obj.characterRid,spbName,spineName)
			end
		end

		-- spine 特效
		local spineArr = trea.sourceData.effSpine
		if spineArr then
			for i,v in ipairs(spineArr) do
				_checkAdd(nil,v,v)
			end
		end

	    -- fla材质
	    local flaArr = trea.sourceData.fla
	    if flaArr then
	    	if type(flaArr) == "string" then
	    		flaArr = {flaArr}
	    	end
	    	for i,v in ipairs(flaArr) do
	    		local fla = v
	    		if not table.indexof(self._textureFlaArr,fla) then
		    		table.insert(self._textureFlaArr,fla)
		    		if add then
		    			table.insert(arr.flaArr,fla)
		    		end
		    	end
	    	end

	    	
	    end

	    -- 技能资源一定在spine中或者fla中, 特殊的就是召唤物
	    -- 计算召唤物
	    self:cacheSummonResource(trea)

	    -- 配在Source里的音效
	    local audioArr = trea.sourceData.sound
	    if audioArr then
	    	for _,v in ipairs(audioArr) do
	    		table.insert(self._soundEffect,v)
				if add then
					table.insert(arr.soundArr,v)
				end
	    	end
	    end
	end
	for k,trea in pairs(obj.treasures) do
		_checkAddTreasure(obj,trea)
		-- 这里做技能镜头、文字、立绘的纹理缓存
		local allSkills = trea:getAllSkills()
		for m,n in pairs(allSkills) do
			local cameraSkilParams = n:sta_cameraSpineParams()
			if cameraSkilParams then
				cameraSkilParams = cameraSkilParams[1]
				if cameraSkilParams.jingtou ~= "0" then
					_checkAdd(nil,cameraSkilParams.jingtou,cameraSkilParams.jingtou)
				end
				if cameraSkilParams.wenzi ~= "0" then
					_checkAdd(nil,cameraSkilParams.wenzi,cameraSkilParams.wenzi)
				end
				if cameraSkilParams.lihui ~= "0" then
					_checkAdd(obj.characterRid,cameraSkilParams.lihui,cameraSkilParams.lihui)
				end
			end
			-- 音频加帧预加载
			for kk,vv in pairs(n.audioInfos) do
				-- 最后去重
				-- if not table.find(self._soundEffect,vv[2]) then
					table.insert(self._soundEffect,vv[2])
					if add then
						table.insert(arr.soundArr,vv[2])
					end
				-- end
			end
		end
	end

	-- 额外加载的纹理缓存资源(战中换法宝的需求)
	for k,trea in pairs(obj.exTreasures) do
		_checkAddTreasure(obj,trea)
	end
	-- hpAi中的法宝切换加载纹理缓存
	if obj.hpAi then
		for k,v in pairs(obj:hpAi()) do
			if v.t == 2 then
			    local trea = ObjectTreasure.new(v.id,{})
				_checkAddTreasure(obj,trea)
			end
		end
	end
	return arr
end

-- 检查是否是序章、如果是，则获取序章需要加载的spine资源
function GameResControler:chk2GetXvZhangSpine( ... )
	local tmpSpineArr = {}
	local _checkAddTmp = function( _spine )
		if not table.indexof(tmpSpineArr,_spine) then
			table.insert(tmpSpineArr,_spine)
		end
	end
	local _addPlotEx = function( plotId )
		local pDada = FuncAnimPlot.getRowData(plotId)
		for i=1,30 do
			local body = pDada["body"..i]
			if body and body ~= "empty" then
				local sData = FuncTreasure.getSourceDataById(body)
				if sData.spine then
					_checkAddTmp(sData.spine)
				end
				if sData.spineFormale then
					_checkAddTmp(sData.spineFormale)
				end
				-- if sData.effSpine then
				-- 	for m,n in pairs(sData.effSpine) do
				-- 		_checkAddTmp(n)
				-- 	end
				-- end
			end
		end
		if pDada.map then
			if not table.indexof(self._exMapArr,pDada.map) then
				table.insert(self._exMapArr,pDada.map)
			end
		end
	end
	if self.controler.levelInfo.hid == Fight.xvzhangParams.xuzhang then
		local plotArr = self.controler.levelInfo:sta_storyPlot(1)
		for k,v in pairs(plotArr) do
			_addPlotEx(v.plotid)
		end
		local plotId = PrologueUtils:getAfterBattlePlotId()
		if plotId then
			_addPlotEx(plotId)
		end
	end
	return tmpSpineArr
end


--资源管理器 初始化 通过 battleInfo 加载材质, onLoadComplete,材质加载完成的回调
-- effArr 其他资源
function GameResControler:cacheResource( allObjArr,effArr,onLoadComplete )
	--echo("_________cacheResource_____________缓存资源")
	self.onLoadComplete = onLoadComplete
	--永久缓存的纹理
	self._foreverFlashCacheMap = {
		UI_zhandou = true,
		UI_zhandoud = true,
	}
	--增加UI击杀 特效  gaoshuang  add
	-- 缓存公共资源
	local flaArr = nil
	local spineArr = nil
	
	if BattleControler:isInMiniBattle() then
		flaArr = {
			"UI_zhandou","UI_zhandoud",
		}
		self._soundEffect = {} -- 此模式先不加载音效
	else
		flaArr = {
			"UI_main_img_shou",
			"UI_zhandou","UI_zhandou_lianxian","UI_kaizhan","UI_zhandou_zhenwei",
			"UI_zhandoud"
			-- "eff_buff_gongjili","eff_buff_jiafanghudun","UI_jishajiangli",
			-- "eff_buff_jiafangyuli","eff_buff_jianfang","eff_buff_xuanyun",
		}
	end
	self._textureFlaArr = flaArr

	local spineArr = {
		-- "eff_treasure0"
		"eff_mannuqi",
		-- "eff_shengminghudun",
		"eff_buff_nuqitisheng",
		"eff_buff_nuqijiangdi",
		-- "eff_liuxue",
		"eff_jiaxue",
		"eff_chenmo",
		"eff_buff_xuanyun",
	}

	if not BattleControler:isInMiniBattle() then
		-- 锁妖塔偷袭战需要加载睡眠怪睡眠特效
		if self.controler:isTowerTouxi() then
			table.insert(spineArr,"eff_buff_shuimian")
		end
		if self.controler:chkIsXvZhang() then
			table.insert(spineArr,"eff_plot_10002_zjflytoland")
		end
		-- 冰封玩法对应的冰冻特效
		if BattleControler:getBattleLabel() == GameVars.battleLabels.missionIcePve then
			table.insert(spineArr,"eff_30004_zhaolinger")
		end

		table.insert(self._soundEffect,"s_battle_battlebegin")--添加开战音效

		if BattleControler:checkIsTrail() ~= Fight.not_trail then
			table.insert(self._textureFlaArr,"UI_shilian_zhandou")
		end
		-- 如果有奇侠展示，需要添加对应的展示特效
		if self.controler.levelInfo:chkParnterShowData() then
			table.insert(self._textureFlaArr,"UI_qixiajieshao")
		end
	end
	
	for i=1,#spineArr do
		table.insert(self._textureSpineArr,{spineArr[i],spineArr[i]})
	end
	
	if effArr then
		for i=1,#effArr do
			table.insert(self._textureSpineArr,{effArr[i],effArr[i]})
		end
	end
	local tmpSpine = self:chk2GetXvZhangSpine()
	for i=1,#tmpSpine do
		table.insert(self._textureSpineArr,{tmpSpine[i],tmpSpine[i]})
	end
	dump(tmpSpine,"序章额外加载的资源")
	dump(self._exMapArr,"序章额外加载的地图资源")

	-- 计算法宝资源
	for h, v in pairs(allObjArr) do
		self:cacheOneHeroResource(v,false,v.__ignoreCacheArt)
	end

	-- 音效去重
	self._soundEffect = array.toSet(self._soundEffect)
	for i=#self._soundEffect,1,-1 do
		local sd = self._soundEffect[i]
		--如果已经缓存了 那么从数组里面移除
		if audio.checkHasCache( GameConfig.getMusic(sd) ) then
			table.remove(self._soundEffect,i)
			--缓存了 也要增加一次计数,保证常用的音效是不需要移除的
			AudioModel:preloadSound(sd)
		end

	end


	-- dump(self._textureSpineArr,"战斗spine资源")
	-- dump(self._textureFlaArr,"战斗flash资源")
	-- 判断缓存资源中是否有无效的资源、有则释放掉
	local cacheArray = TextureControler:getAllCacheTexture()
	-- dump(cacheArray,"cacheArray------")
	-- echo("zheli-----"，#cacheArray)
	for i=#cacheArray,1,-1 do
		local v = cacheArray[i]
		if not self:checkIsHasSpineRes(v[1],v[2]) then
			-- echo("清理无效缓存---",v[1],v[2])
			TextureControler:clearOneHeroSpine(v[1],v[2],i)
		end
	end
	-- dump(self._soundEffect,"音效=====")

	-- 缓存资源
	self.cacheTexIdx = 1
	--开始缓存声音
	self.controler._sceenRoot:delayCall(handler(self, self.cacheSoundPreLoadByFrame),0.01)
	self:threadCacheTexture()
end

function GameResControler:threadCacheTexture(  )
	--
	self._initTime1 = TimeControler:getTempTime(  )
	self._threadTextureArr = {}
	--缓存flash 
	
	--缓存spine  这里倒序插入spine
	-- 
	for i=#self._textureSpineArr,1,-1 do
		local textureInfo = self._textureSpineArr[i]
		local textureName= FuncRes.getSpineTexturePath(textureInfo[2])
		if not table.find(self._threadTextureArr, textureName) then
			table.insert(self._threadTextureArr, textureName)
		end
	end

	for i,v in ipairs(self._textureFlaArr) do
		local textureName= FuncRes.armature(v)

		if not table.find(self._threadTextureArr, textureName) then
			table.insert(self._threadTextureArr, textureName)
		end

		
	end

	--把这个数组分成4个近程去加载
	local threadNums = 1
	self._threadNums = threadNums
	self._threadTextureGroups = {}
	for i=1,threadNums do
		self._threadTextureGroups[i] = {index =0,textures = {},isOver = false,cachesArr = {}}
	end

	for i,v in ipairs(self._threadTextureArr) do
		local yushu = i %threadNums
		if yushu ==0 then
			yushu = threadNums
		end
		table.insert( self._threadTextureGroups[yushu].textures,v )
	end

	for i,v in ipairs(self._threadTextureGroups) do
		self:threadCacheByIndex(i,1)
	end

end


function GameResControler:threadCacheByIndex( threadIndex,index )
	local threadInfo = self._threadTextureGroups[threadIndex]
	
	local textureName = threadInfo.textures[index]

	--0.2秒后强制cache完成 防止异线程卡死
	local tempFunc = function (textureName, threadIndex,index ,tt,ti )
		
		--如果是已经缓存过的 return
		if threadInfo.cachesArr[index] then
			return
		end
		-- echo(textureName, threadIndex,index,"__资源加载完成,count:",tt,TimeControler:getTempTime(  ) -ti )
		threadInfo.cachesArr[index] = true
		cc.Director:getInstance():getTextureCache():addImage(textureName)
		--停止掉0.2秒的倒计时
		self.controler._sceenRoot:stopAction(threadInfo.delayId)
		self:oneThreadCacheComplete(threadIndex,index)

	end

	local count = display.getSpriteFramesCount(textureName)
	local spbName = string.gsub(textureName,".png", ".spb")
	local hasSpPreLoad = pc.PCSkeletonDataCache:getInstance():checkSkeletonDataIsPreLoad(spbName)
	if (not hasSpPreLoad) then
		display.addImageAsync(textureName,c_func(tempFunc,textureName, threadIndex,index,count,TimeControler:getTempTime(  )))
		threadInfo.delayId = self.controler._sceenRoot:delayCall(c_func(tempFunc,textureName, threadIndex,index,2,TimeControler:getTempTime(  )),0.5)
	else
		threadInfo.cachesArr[index] = true
		self:oneThreadCacheComplete(threadIndex,index)
	end
	-- echo("开始加载--",textureName)
	-- tempFunc(textureName, threadIndex,index,1,TimeControler:getTempTime(  ) )

	

end
--一个线程的缓存完毕
function GameResControler:oneThreadCacheComplete( threadIndex,index )
	index = index+1
	local threadInfo = self._threadTextureGroups[threadIndex]
	if index > #threadInfo.textures then
		threadInfo.isOver = true
		self:checkIsAllOver()
		return
	end

	self:threadCacheByIndex(threadIndex,index)
end

function GameResControler:checkIsAllOver(  )
	local isAllOver = true
	for i,v in ipairs(self._threadTextureGroups) do
		if not v.isOver  then
			isAllOver = false
			break
		end
	end
	if isAllOver then
		echo(TimeControler:getTempTime(  )- self._initTime1,"__加载纹理耗时")
	end
	--如果所有的资源和 和spine 载完毕.最后才开始加载spine
	if isAllOver and self._isSpineOver then
		self:resetMapControler()
		for k,v in pairs(self._exMapArr) do
			FuncRes.addMapTexture(v)
		end
		self.controler._sceenRoot:delayCall(function( )
			--通知界面 资源加载完毕
			self.onLoadComplete()
			self.onLoadComplete = nil
		end,0.2)
	end

end





-- 分帧加载资源
function GameResControler:cacheSpineTextureByFrame()
	local spineAni = self._textureSpineArr[self.cacheTexIdx]
	if not spineAni  then
		self.cacheTexIdx = 1
		self:cacheFlaTextureByFrame()
		return 
	end
	local spbName,altasName = FuncRes.spine(spineAni[1],spineAni[2])
	self.cacheTexIdx = self.cacheTexIdx + 1

	-- echo(pc.PCSkeletonDataCache:getInstance():checkSkeletonDataIsPreLoad(spbName),"spbNameCache",spbName)
	--如果是已经缓存了
	if pc.PCSkeletonDataCache:getInstance():checkSkeletonDataIsPreLoad(spbName) then
		self:cacheSpineTextureByFrame()
		return
	end
	pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(spbName,altasName)
	
	
	if self.cacheTexIdx > #self._textureSpineArr then
		self.cacheTexIdx = 1
		self:cacheFlaTextureByFrame()
	else
		self.controler._sceenRoot:delayCall(handler(self, self.cacheSpineTextureByFrame),0.001)
	end
end

-- 分帧加载资源
function GameResControler:cacheFlaTextureByFrame()
	--ViewArmature.cacheOneTexture(self._textureFlaArr[self.cacheTexIdx])
	--synchro 是否是 同步加载资源  false 是异步加载 true 是同步加载
	-- local flaAni = self._textureFlaArr[self.cacheTexIdx]
	-- if not flaAni  then
	-- 	self.cacheTexIdx = 1
	-- 	self:cacheSoundPreLoadByFrame()
	-- 	return 
	-- end
	
	local t1 = TimeControler:getTempTime(  )
	

	--因为flash纹理全部已经缓存了 所以这里直接加载所有的配置
	for i,v in ipairs(self._textureFlaArr) do
		FuncArmature.loadOneArmatureTexture(v ,nil ,true)
	end
	echo(t1- self._initTime1,"__加载spine资源耗时------flash耗时:", TimeControler:getTempTime(  )-t1)
	self._isSpineOver = true
	
	self:checkIsAllOver()


	-- self.cacheTexIdx = self.cacheTexIdx + 1
	-- if self.cacheTexIdx > #self._textureFlaArr then
	-- 	self.cacheTexIdx = 1
	-- 	self:cacheSoundPreLoadByFrame()
	-- else
	-- 	self.controler._sceenRoot:delayCall(handler(self, self.cacheFlaTextureByFrame),Fight.frame_time)
	-- end
end

-- 分帧预加载音频资源、每帧加载5个音频
function GameResControler:cacheSoundPreLoadByFrame( )
	-- if true then
	-- 	self:cacheSpineTextureByFrame()
	-- 	return
	-- end
	for i=1,5 do
		local audioFile = self._soundEffect[self.cacheTexIdx] 
		if not audioFile then
			self.cacheTexIdx = 1
			self._isSoundLoadOver = true
			echo("sound is over")
			-- self:checkIsAllOver()
			self:cacheSpineTextureByFrame()
			-- self.onLoadComplete()
			-- self.onLoadComplete = nil
			return
		end
		AudioModel:preloadSound(audioFile)

		self.cacheTexIdx = self.cacheTexIdx + 1
		if self.cacheTexIdx > #self._soundEffect then
			echo("sound is over")
			self.cacheTexIdx = 1
			self._isSoundLoadOver = true
			-- self:checkIsAllOver()
			self:cacheSpineTextureByFrame()
			-- self.onLoadComplete()
			-- self.onLoadComplete = nil
			return
		end
	end
	if self.cacheTexIdx <= #self._soundEffect then
		self.controler._sceenRoot:delayCall(handler(self, self.cacheSoundPreLoadByFrame),0.001)
	else
		self.cacheTexIdx = 1
	end
end
-- 额外缓存指定数组的角色资源
function GameResControler:cacheOtherRes(heroArr,onLoadComplete)

	if self:chkIsInCache() then
		echoWarn ("如果正在缓存状态，则需要等待")
		if not self._cacheArr then
			self._cacheArr = {}
			table.insert(self._cacheArr,{arr=heroArr,func = onLoadComplete})
		end
		return
	end
	self._isInCache = true
	local arr
	for k, obj in pairs(heroArr) do
		local tmp = self:cacheOneHeroResource(obj,true)
		if not arr then
			arr = tmp
		else
			for m,_ in pairs(arr) do
				array.merge2(arr[m],tmp[m])
			end
		end
	end
	local cacheIdx = 0
	local function _spineCache(cb )
		cacheIdx = cacheIdx + 1
		if cacheIdx <= #arr.spineArr then
			local v = arr.spineArr[cacheIdx]
			pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine(v[1],v[2]))
			self.controler._sceenRoot:delayCall(function( )
				_spineCache(cb)
			end,Fight.frame_time)
		else
			cacheIdx = 0
			cb()
		end
	end
	local function _flaCache(cb )
		cacheIdx = cacheIdx + 1
		if cacheIdx <= #arr.flaArr then
			local v = arr.flaArr[cacheIdx]
			FuncArmature.loadOneArmatureTexture(v ,nil ,true)
			self.controler._sceenRoot:delayCall(function( )
				_flaCache(cb)
			end,Fight.frame_time)
		else
			cacheIdx = 0
			cb()
		end
	end
	local function _soundCache(cb )
		for i=1,3 do
			cacheIdx = cacheIdx + 1
			if cacheIdx <= #arr.soundArr then
				local v = arr.soundArr[cacheIdx]
				AudioModel:preloadSound(arr.soundArr[idx])
			else
				cacheIdx = 0
				cb()
				return
			end
		end
		self.controler._sceenRoot:delayCall(function( )
			_soundCache(cb)
		end,Fight.frame_time)
	end
	_spineCache(function( )
		_flaCache(function(  )
			_soundCache(function( )
				self._isInCache = false
				onLoadComplete()
				if self._cacheArr then
					local tmp = self._cacheArr[1]
					self:cacheOtherRes(tmp.arr,tmp.func)
					table.remove(self._cacheArr,1)
					if #self._cacheArr == 0 then
						self._cacheArr = nil
					end
				end
			end)
		end)
	end)
end
-- 是否在缓存之中
function GameResControler:chkIsInCache( )
	return self._isInCache
end
-- 是否还有缓存队列
function GameResControler:chkHaveCacheList( )
	if self._cacheArr then
		return true
	end
	return false
end 


--清除材质.(但是本主角的材质不能删除)
function GameResControler:clearResource(  )
	--echo("_____________clearResource___________释放缓存的资源")
	local avatar = 1
	local level = 1
	-- local spbName,spineName = FuncChar.getSpineAniName( avatar, level)
	audio.autoClearCache()
	for i=#self._textureSpineArr,1,-1 do
		local spine = self._textureSpineArr[i]
		-- if spine[1] ~= spbName or spine[2] ~= spineName then
		-- 	pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine(spine[1],spine[2]));
		-- end
		-- 如果纹理需要缓存，则不需要删除
		if not TextureControler:checkOneHeroIsCache(spine[1],spine[2]) then
			-- echo("移除纹理----",spine[2])
			pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine(spine[1],spine[2]))
		end
	end

	for i=#self._textureFlaArr,1,-1 do	
		local texture = self._textureFlaArr[i]
		if not self._foreverFlashCacheMap[texture] then
			FuncArmature.clearOneArmatureTexture(texture,true)
		end
	end
	for i=#self._exMapArr,1,-1 do
		FuncRes.removeMapTexture(self._exMapArr[i])
	end
	

	-- 将预加载的音频释放掉 
	--暂时做自动释放管理
	-- for i=#self._soundEffect,1,-1 do
	-- 	local audioFile = self._soundEffect[self.cacheTexIdx]	
	-- 	AudioModel:unloadSound(audioFile)
	-- end


	-- self._textureSpineArr = nil
	-- self._textureFlaArr = nil
	self._textureSpineArr = {}
	self._textureFlaArr = {}
	self._soundEffect = {}
	self._exMapArr = {}

	-- 清除缓存的特效
	ViewArmature:clearArmatureCache()
	ViewSpine:clearSpineCache()
end


return GameResControler



-- 资源备份中.. 
-- -- spineArr
-- self.spineArr = {
-- 	"treasure_a1","treasure_a2","treasure_a3","treasure_b1","treasure_b2","treasure_b3",
-- 	"10001_caoYao","20001_shanShen","10003_dengLongGuai","10002_huDieYao","30001_wuHou",
-- 	}

-- --需要加载的材质数组 固定会加载的 肯定有
-- self.flaArr = {
-- 	"UI_battle","common","treasure0","treasure00","enemy10002","enemy10003","enemy20001",
-- 	"treasure101","treasure102","treasure103","treasure104","treasure105","treasure106","treasure107",
-- 	"treasure201","treasure202","treasure204","treasure205","treasure206","treasure207","treasure209","treasure210","treasure211",
-- 	"treasure305","treasure322","xueshi","TreaGiveOut","enemy_30002A",
-- }	

