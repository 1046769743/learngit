-- LSChat:

local LSChat = {
	__db_prv = false,
	__db_pub = false,
}
local LSChat = {
	db_prv = {},
}

--[[
-- 账户私有存储(分区分uid)
-- LSChat:prv():get("key",def)
-- LSChat:prv():set("key",value)
 ]]
function LSChat:createTable(tableName)
	if tableName == nil then
		echo("=====创建表格出问题  tableName is nil ====")
		return 
	end
	if self.db_prv[tableName] == nil then
		local tab = string.format(tableName.."_%s",UserModel:uid())
		self.db_prv[tableName] = storagechat.new(tab)
	end
	
end

--根据表名获取表格
function LSChat:byNameGetTable(tableName)
	if self.db_prv[tableName] == nil then
		local tab = string.format(tableName.."_%s",UserModel:uid())
		self.db_prv[tableName] = storagechat.new(tab)
	end
	return self.db_prv[tableName]
end

---根据表名设置表的数据
function LSChat:setData(tableName,key,value)
	local db_prv = self:byNameGetTable(tableName)
	db_prv:set(key,value)
end
--根据表名获取数据
function LSChat:getData(tableName,key,default)
	echo("=========tableName=======",tableName)
	local db_prv = self:byNameGetTable(tableName)
	if db_prv then
		return db_prv:get(key,default)
	else
		return nil
	end
end

function LSChat:getallData(tableName)
	local db_prv = self:byNameGetTable(tableName)
	if db_prv ~= nil then
		local alldata = db_prv:getAll()
		return alldata
	else
		return nil
	end
end

function LSChat:prv()
	if not self.__db_prv then
		--assert(uzone~=0 and uid~=0,"@LSChat:prv(). uzone or uid is 0.")
		-- 标识是"kvprv_z分区_uid"

		local tagname = self:getSqlName()
		self.__db_prv = storagechat.new(tagname)
		self._preName = tagname
	end
	return self.__db_prv
end


--初始化 pre
function LSChat:initPrv(  )
	echo("__初始化本地数据库缓存",self.__db_prv )
	if self.__db_prv then
		self.__db_prv.__cached = nil
		self.__db_prv:close()
	end

	local tagname = self:getSqlName()
	self.__db_prv = storagechat.new(tagname)
	self._preName = tagname
end

local pre_nologin = "pre_nologin"

function LSChat:getSqlName()
	if LoginControler and LoginControler:isLogin() then
		return string.format("pre_%s",UserModel:uid())
	end
	return string.format(pre_nologin )

end

--删除未登入的序章
function LSChat:delNoLoginCacheData(  )
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
-- LSChat:pub():get("key",def)
-- LSChat:pub():set("key",value)
 ]]
function LSChat:pub()
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
function LSChat:ver()
	if not self.__ver then
		local tagname="ver"
		self.__ver = storage.new(tagname)
	end
	return self.__ver
end

function LSChat:restore()
	self.__db_prv = nil
end

--todo加存table相关方法

return LSChat
