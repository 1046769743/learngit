
local LS = {
	__db_prv = false,
	__db_pub = false,
}

--[[
-- 账户私有存储(1以区服rid区分的)
-- LS:prv():get("key",def)
-- LS:prv():set("key",value)

	--所有的区服共享的本地存储数据
	LS:pub()  
	调用LS的时候一定要注意区分是私有的还是公用的. 一般声音开关是公共的
 ]]
function LS:prv()
	if not self.__db_prv then
		--assert(uzone~=0 and uid~=0,"@LS:prv(). uzone or uid is 0.")
		-- 标识是"kvprv_z分区_uid"

		local tagname = self:getSqlName()
		self.__db_prv = storage.new(tagname)
		self._preName = tagname
	end
	return self.__db_prv
end


--初始化 pre
function LS:initPrv(  )
	echo("__初始化本地数据库缓存",self.__db_prv )
	if self.__db_prv then
		self.__db_prv.__cached = nil
		self.__db_prv:close()
	end

	local tagname = self:getSqlName()
	self.__db_prv = storage.new(tagname)
	self._preName = tagname
end

local pre_nologin = "pre_nologin"

function LS:getSqlName()
	if LoginControler and LoginControler:isLogin() then
		return string.format("pre_%s_%s", LoginControler:getServerId(), UserModel:uid())
	end
	return string.format(pre_nologin )

end

--删除未登入的序章
function LS:delNoLoginCacheData(  )
	if self.tagname ~= pre_nologin then
		local tempDb = storage.new(pre_nologin)
		tempDb:delAll()
		tempDb:close()
	else
		if self.__db_prv then
			self.__db_prv:delAll()
			self.__db_prv:close()
			self.__db_prv = nil
			self:initPrv()
		end
	end
end

--[[
-- 本机器所有账号通用存储
-- LS:pub():get("key",def)
-- LS:pub():set("key",value)
 ]]
function LS:pub()
	if not self.__db_pub then
		-- 标识是"kvpub"
		local tagname = "pub"
		self.__db_pub = storage.new(tagname)
	end
	return self.__db_pub
end

--[[
--本机版本控制版本成功数据存储
 ]]
function LS:ver()
	if not self.__ver then
		local tagname="ver"
		self.__ver = storage.new(tagname)
	end
	return self.__ver
end

function LS:restore()
	self.__db_prv = nil
end

--todo加存table相关方法

return LS
