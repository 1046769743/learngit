--
-- Author: xd
-- Date: 2017-08-25 10:25:35
--
local TextureControler = TextureControler or {}


TextureControler._spineCachetextureArray = {} 	--{spbName,spineName}


--缓存所有的纹理名称数组  去除后缀名,包含路径
TextureControler.textureNameArr = {}
TextureControler.soundCacheMap = {}


function TextureControler:init(  )
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListener = cc.EventListenerCustom:create(SystemEvent.SYSTEMEVENT_LOAD_TEXTURE_PATH,
                                c_func(self.onLoadOneTexture,self))
    eventDispatcher:addEventListenerWithFixedPriority(customListener, 1)
end
 
function TextureControler:onLoadOneTexture(data )
	local str = data:getDataString()
	self:noteOneTexture(str)
end
 
-- 获取所有缓存的资源
function TextureControler:getAllCacheTexture( )
	return self._spineCachetextureArray
end

-- 检查纹理是否已经缓存
function TextureControler:checkOneHeroIsCache(spbName,spineName )
	for k,v in pairs(self._spineCachetextureArray) do
		if v[1] == spbName and v[2] == spineName then
			return true
		end
	end
	return false
end

--缓存一个伙伴的纹理spine纹理 、isAtOnce true为立即加载其纹理,
function TextureControler:cacheOneHeroSpine( spbName,spineName,isAtOnce)
	if not self:checkOneHeroIsCache(spbName,spineName) then
		table.insert(self._spineCachetextureArray,{spbName,spineName})
		if isAtOnce then
			pc.PCSkeletonDataCache:getInstance():SkeletonDataPreLoad(FuncRes.spine(spbName,spineName))
		end
	end
end
--  清理指定一个缓存的纹理、会立即释放其spine纹理
function TextureControler:clearOneHeroSpine(spbName,spineName,idx)
	local _removeSpine = function( k,v )
		pc.PCSkeletonDataCache:getInstance():clearCacheByFileName(FuncRes.spine(v[1],v[2]))
		table.remove(self._spineCachetextureArray,idx)
	end
	if idx then
		if idx <= #self._spineCachetextureArray then
			local v = self._spineCachetextureArray[idx]
			if v[1] == spbName and v[2] == spineName then
				_removeSpine(idx,v)
			end
		end
	else
		for k,v in pairs(self._spineCachetextureArray) do
			if v[1] == spbName and v[2] == spineName then
				_removeSpine(k,v)
				break
			end
		end
	end
end

--记录当前纹理状态的map
local textureStateMap = {}
local igoneTextureArr = {
	"a2_4.png",
	"a0_4.png",
	"a1_4.png",
	"UI_HongKui.png",
	"UI_comp_common.png",
	--新手引导相关的忽略
	"UI_HongKui.png",
	"UI_guide_line.png",
	"UI_qiangzhitishi.png",
	"UI_main_img_shou.png",
	"UI_novice.png",
	"UI_zhanlibianhua",
	"UI_tongyonghuode",

}
--忽略测试的系统
local igoneWindowArr = {
	"BattleView",
	"BattleLose",
	"BattleWin",
	"CompLoading",
	"LoginLoadingView",
}
function TextureControler:splitTextureInfo( str )
	--先根据分号拆分
	local arr1 = string.split(str, ";")
	local arr2 = {}
	--去掉最后一个信息
	local length = #arr1 - 1
	for i=1,10 do
		print(i)
	end
end

--记录某一时刻的纹理状态
function TextureControler:noteOneTextureState( key )
	if not DEBUG_MEM then
		return
	end
	--如果是用散图的
	if CONFIG_USEDISPERSED then
		return
	end
	if table.find(igoneWindowArr,key) then
		return
	end
	textureStateMap[key] = nil
	local textureInfoStr = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
	local arr = string.split2d(textureInfoStr,";",",")
	textureStateMap[key] = arr

end



--比较纹理状态 并输出打印信息
function TextureControler:compareTextureState( key )
	if not DEBUG_MEM then
		return
	end
	--如果是用散图的
	if CONFIG_USEDISPERSED then
		return
	end
	--如果是忽略这个key的 那么也不执行
	if table.find(igoneWindowArr,key) then
		return
	end
	local noteStateArr = textureStateMap[key]
	if not noteStateArr then
		echoWarn("_不应该没有state:",key)
		return
	end
	local textureInfoStr = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
	local infoArr = string.split2d(textureInfoStr,";",",")
	local addTextureArr = {}
	--比较这2个数组 是否有哪些不一致的地方
	for i,v in ipairs(infoArr) do
		--纹理名称是 texture name
		local textureName = v[1]
		local hasFind = false
		if i ==#infoArr or UIBaseDef:isGlobalPng( textureName )
			--如果是忽略的纹理
			or table.find (igoneTextureArr,textureName)

		 then
			hasFind = true
		else
			for ii,vv in ipairs(noteStateArr) do
				if vv[1] == textureName then
					hasFind = true
				end
			end
		end
		
		if not hasFind then
			table.insert(addTextureArr, textureName)
		end
	end
	if #addTextureArr >= 1 then
		echoWarn("有可能存在纹理泄露 请检查是否有没释放的纹理")
		echoWarn(key .. "系统关闭后增加的纹理:"..table.concat(addTextureArr,",") )
		echoWarn("-------------------------------------------\n-------------------------------------------------------------")
	end
	local totalInfo = infoArr[#infoArr]

	echo("from %s,tex mem: %s,lua mem:%0.2f KB",key,totalInfo[1],collectgarbage("count"))

end


function TextureControler:noteOneTexture(key)
	if not DEBUG_CREATE_WHILTE_LIST then
		return
	end

	--以小数点为分隔符
	local turnKeyArr = string.split(key, ".")
	local targetKey = turnKeyArr[1].."*"
	if not table.find( self.textureNameArr,targetKey )then
		table.insert(self.textureNameArr, targetKey)
	end

end


function TextureControler:noteOneSound( key )
	self.soundCacheMap[key] = true
end

function TextureControler:checkSoundHasCached( key )
	return self.soundCacheMap[key]
end


return TextureControler