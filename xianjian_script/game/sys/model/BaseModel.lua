
local BaseModel = class("BaseModel")


--属性key table  会自动为设置的key绑定方法,同时 key对应的值应该加密
BaseModel._datakeys = nil

--[[
	_datakeys = {

		lv =  numEncrypt:getMergeStr( numEncrypt:ns1(),numEncrypt:ns2(),numEncrypt:ns3() )   --存储为加密的 123级
		name = "hh",
		money = numEncrypt:getStr(numEncrypt:ns3(),numEncrypt:ns0(),numEncrypt:ns0(),numEncrypt:ns0(),numEncrypt:ns0() ) --存储为加密的30000

	}

]]

function BaseModel:ctor()
	
end

-- -------------------- 威武分割线 -------------------- --
--初始化数据
function BaseModel:init(_doc)
	self._data = _doc
	if type(_doc) ~= "table" then
		self._data = {}
	end
end
--是否有效
function BaseModel:valid()
	return not empty(self._data)
end
function BaseModel:data()
	return self._data
end
function BaseModel:setData(data)
	self._data = data
end
--检查static调用
function BaseModel:chkStatic(first_param)
	if DEBUG>1 and type(first_param)=="table" and first_param.__cname == self.__cname then
		echo("must be '.', not ':'")
		assert(false,string.format("@%s Check static failed!",self.__cname))
	end
end

--创建列名调用方法(如,Userdata._data.uid拥有Userdata:uid()方法)
function BaseModel:createKeyFunc()
	if not self._datakeys then
		self._datakeys = self._data
	end
	if type(self._data)=="table" then
		for colName,s in pairs(self._datakeys) do

			if not self[colName] then
				--判断是否有需要加密的key  
				--isInit默认为空 表示获取解密后的数据,如果是 table 会把整个table解密,  isInit为true 就获取原始值 
				self[colName] = function(_self, isinit )

					local value = _self._data[colName]
					if not value then
						value = s
					end
					if not value then
						return nil
					end

					--如果是获取原始对象
					if isinit ~= nil then
						return  value
					end

					--如果是复杂对象 就整体解密
					if type(value) == "table" then
						return numEncrypt:decodeObject(value)
					end

					if numEncrypt:checkIsEncodeStr(value) then
						return numEncrypt:getNum(value)
					else
						return value
					end
				end
			end

			
		end
	end
end
-- -------------------- 威武分割线 -------------------- --
function BaseModel:get(key1d,def)
	key1d = tostring(key1d)
	return vcheck(self._data[key1d],def)
end
function BaseModel:set(key1d,value)
	self._data[key1d] = value
end
function BaseModel:has(key1d)
	return isset(self._data,tostring(key1d))
end
function BaseModel:get2d(key1d,key2d,def)
	local _value1d = self:get(key1d)
	if empty(_value1d) then return def end
	key2d = tostring(key2d)
	--assert(isset(_value1d, key2d),string.format("@%s.%s, no key2d(%s).",self._cname,key1d,key2d))
	return vcheck(_value1d[key2d],def)
end
function BaseModel:set2d(key1d,key2d,value)
	self._data[key1d][key2d] = value
end
function BaseModel:get3d(key1d,key2d,key3d,def)
	local _value2d = self:get2d(key1d,key2d)
	if empty(_value2d) then return def end
	key3d = tostring(key3d)
	return vcheck(_value2d[key3d],def)
end

-- 重置恢复初始
function BaseModel:restore()
	self._data = {}
end

--把自身数据转换成json字符串
function BaseModel:tostring()
	return json.encode(self._data)
end

--更新数据
function BaseModel:updateData(data)
	-- echo("BaseModel:updateData data=");
	if data and self._data then
		table.deepMerge(self._data,data)
	end
end


--添加一条数据
function BaseModel:addData( key, childData )
	if(self.data[key]) then 
		echo( "class:" ..  self.__cname ..  " , has data by did:" .. key)
	end
	self._data[key] = childData
end


--删除数据
function BaseModel:deleteData( keyData ) 
	--深度删除 key
	table.deepDelKey(self._data,keyData,1)
end


return BaseModel
