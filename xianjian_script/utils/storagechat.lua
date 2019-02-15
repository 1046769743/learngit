
local storagechat = class("storagechat", sqlite)

--[[
-- self.__cached = {}, --缓存的数据
-- self.__tableName = "",
 ]]

function storagechat:ctor(tagname)
	self:init(self:dbname(tagname))
	self.__cached = {}
	-- tagname需要过滤掉非字母和数字字符，否则会有不符合表名规则的字符
	self.__tableName = string.format("s_%s",string.upper(string.gsub(tagname,"%W","Z")))
	self:create_table()
	self.__targetName = tagname
end
function storagechat:dbname(tagname)
	if not self._dbname then
		-- "sgtc"+游戏名称+游戏平台+"bkrz"
		self._dbname = string.format("sgtc%sbkrz",tagname)
	end
	return self._dbname
end
function storagechat:create_table()
	local sql = "CREATE TABLE if not exists " .. self.__tableName.. " (key varchar(40) primary key,value varchar(500))"
	self:exec(sql)
end

-- -- public functions
-- 取值
function storagechat:get(key,default)

	if not isset(self.__cached,key) then
		self.__cached[key] = self:__get(key)
	end
	local ret = self.__cached[key]
	if ret==nil then
		if default~=nil then ret = default end
	end
	--echo("storagechat:get - value.len=",ret and string.len(ret))
	return ret
end

-- 设置值
function storagechat:set(key,value)
	--echoInfo("storagechat:set - key=<%s>,value=<%s>",key,value)
	self.__cached[key] = value
	self:__set(key,value)
end

--返回所有
function storagechat:getAll()
	if not self.__initAll then
		self.__cached = self:__getAll()
		self.__initAll = true
	end
	return self.__cached
end

-- 是否存在这个键
function storagechat:exists(key)
	if isset(self.__cached,key) then return true end
	return self:__exists(key)
end
-- 删除值
function storagechat:del(key)
	self.__cached[key] = nil
	self:__del(key)
end
-- 删除所有
function storagechat:delAll()
	self.__cached = {}
	self:__delAll()
end

--删除表 删除后禁止访问其他方法
function storagechat:drop()
	self:__drop()
	self.__cached = nil
	self.__tableName = nil
	self._dbname = nil
end

-- -- private functions
--从本地库中取值
function storagechat:__get(key)
	local stmt = self._db:prepare("SELECT * FROM ".. self.__tableName .." WHERE key=\'"..key.."\'")
	local stepr = stmt:step()
	local value=nil
	if(stepr == 100) then -- sqlite3.ROW 为 100
		value= stmt:get_value(1)
	end
	stmt:finalize()
	return value
end

--从本地库里取所有值放到cache中
function storagechat:__getAll()
	local stmt = self._db:prepare("SELECT * FROM ".. self.__tableName)
	local stepr = stmt:step()
	local arr = {}
	while(stepr == 100) do -- sqlite3.ROW 为 100
		local key = stmt:get_value(0)
		local value = stmt:get_value(1)
		arr[key] = value
		stepr = stmt:step()
	end
	stmt:finalize()
	return arr
end

--删除表
function storagechat:__drop()
	local sql = "DROP TABLE "..self.__tableName
	self:exec(sql)
end

--保存至本地库
function storagechat:__set(key,value)
	local sql = string.format("replace into %s (\'key\',\'value\') values (\'%s\',\'%s\')",self.__tableName,key,value)
	self:exec(sql)
end
--判断本地库中是否有这个键 todo
function storagechat:__exists(key)
	return false
end

--从本地库中删除 todo
function storagechat:__del(key)

end
--从本地库中删除所有
function storagechat:__delAll()
	local sql = "DELETE FROM "..self.__tableName
	self:exec(sql)
end

return storagechat
