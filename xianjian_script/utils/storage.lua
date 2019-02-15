
local storage = class("storage", sqlite)

--[[
-- self.__cached = {}, --缓存的数据
-- self.__tableName = "",
 ]]

function storage:ctor(tagname)
	self:init(self:dbname())
	self.__cached = {}
	-- tagname需要过滤掉非字母和数字字符，否则会有不符合表名规则的字符
	self.__tableName = string.format("s_%s",string.upper(string.gsub(tagname,"%W","Z")))
	self:create_table()
	self.__targetName = tagname
end
function storage:dbname()
	if not self._dbname then
		-- "sgtc"+游戏名称+游戏平台+"bkrz"
		self._dbname = string.format("sgtc%s%sbkrz",AppInformation:getGameName(),AppInformation:getAppPlatform())
	end
	return self._dbname
end
function storage:create_table()
	local sql = "CREATE TABLE if not exists " .. self.__tableName.. " (key varchar(40) primary key,value varchar(500))"
	self:exec(sql)
end

-- -- public functions
-- 取值
function storage:get(key,default)
	--echoInfo("storage:get - key=<%s>",key)
	if not isset(self.__cached,key) then
		self.__cached[key] = self:__get(key)
	end
	local ret = self.__cached[key]
	if ret==nil then
		if default~=nil then ret = default end
	end
	--echo("storage:get - value.len=",ret and string.len(ret))
	return ret
end

-- 设置值
function storage:set(key,value)
	--echoInfo("storage:set - key=<%s>,value=<%s>",key,value)
	--相同的key 就不需要重复set 节省效率
	if(self.__cached[key] ~= nil) then
		if self.__cached[key] == value then
			return
		end
	end
	self.__cached[key] = value
	self:__set(key,value)
end

--返回所有
function storage:getAll()
	if not self.__initAll then
		self.__cached = self:__getAll()
		self.__initAll = true
	end
	return self.__cached
end

-- 是否存在这个键
function storage:exists(key)
	if isset(self.__cached,key) then return true end
	return self:__exists(key)
end
-- 删除值
function storage:del(key)
	self.__cached[key] = nil
	self:__del(key)
end
-- 删除所有
function storage:delAll()
	self.__cached = {}
	self:__delAll()
end

--删除表 删除后禁止访问其他方法
function storage:drop()
	self:__drop()
	self.__cached = nil
	self.__tableName = nil
	self._dbname = nil
end

-- -- private functions
--从本地库中取值
function storage:__get(key)
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
function storage:__getAll()
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
function storage:__drop()
	local sql = "DROP TABLE "..self.__tableName
	self:exec(sql)
end

--保存至本地库
function storage:__set(key,value)
	local sql = string.format("replace into %s (\'key\',\'value\') values (\'%s\',\'%s\')",self.__tableName,key,value)
	self:exec(sql)
end
--判断本地库中是否有这个键 todo
function storage:__exists(key)
	return false
end

--从本地库中删除 todo
function storage:__del(key)

end
--从本地库中删除所有
function storage:__delAll()
	local sql = "DELETE FROM "..self.__tableName
	self:exec(sql)
end

return storage
