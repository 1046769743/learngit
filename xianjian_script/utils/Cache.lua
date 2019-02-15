--
-- Author: xd
-- Date: 2016-08-30 15:17:02
--
Cache = Cache or {}
Cache._cacheInfo = {}
--获取全局缓存数据
function Cache:get( key,defvalue )
	if not self._cacheInfo[key] then
		return defvalue
	end
	return  self._cacheInfo[key]
end

--设置全局缓存数据
function Cache:set( key,value )
	self._cacheInfo[key]  = value
end