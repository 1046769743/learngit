--
-- Author: xd
-- Date: 2015-10-8 16:47:35
--

numEncrypt=numEncrypt or  {}


--每一个字符的抬头 必须是 竖线开头 如果没匹配成功就会报错 

numEncrypt.title = "|@"
numEncrypt.titleLen = string.len(numEncrypt.title)


--比如 1 对应的字符是 |a ,12对应的字符是 |an


--加密的key 不能包含title 


--全部采用3位字符串读对应加密  这样加大篡改难度
numEncrypt.bit = 3 
--对应 			   0   1   2   3   4   5   6   7   8   9   .   -
numEncrypt.key = {"~ah","abe","nba","g5e","!dq","he!","ufo","igb","lch","dai","lqj","x^k"}



--数组0-9对应的字符串 这个是用来方便的方向获取数字 为了 加密和非加密的 统一性 全部改成方法获取
for i=0,9,1 do
	numEncrypt["ns"..i] = function (self  )
		return self["__ns"..i]
	end

	--获取简单的数字 主要用来 获取默认值的时候用
	numEncrypt["getNum"..i] = function (self  )
		return self:getNum(self["ns"..i](self))
	end

end


--获取小数点
function numEncrypt:nsd()
	return self.__nsd
end

--获取减号对应字符串
function numEncrypt:nsj()
	return self.__nsj
end



-- numEncrypt.ns0 =nil   -- ns0 1,2,3..全部改成动态申明,
-- numEncrypt.nsd = nil  --小数点 对应的加密串
-- numEncrypt.nsj = nil  --减号  对应的加密串

-- function numEncrypt:getNum0( )
-- 	return self:getNum(self:ns0())
-- end




--初始化需要传入一个key  然后输出 0 1 2 3 4 5 6 7 8 9
function numEncrypt:init(key )
	if key then
		self.key = key
	end
	
	--获取key对应的bit数
	self.bit = string.len(self.key[1])
	--初始化0 -9的字符串
	for i=0,9 do
		self["__ns"..i] = self:getStr(i)
		-- echo(self["ns"..i] ,"___",self:getNum("z~ah"))
	end

	self.__nsd = self.title .. self.key[11]
	self.__nsj = self.title .. self.key[12]


end



--[[
--获取合并后的字符  比如有时候 想得到一个 -0.2345对应的字符串 那么传入方法为
	numEncrypt:getMergeStr(numEncrypt:nsj(),numEncrypt:ns0(),numEncrypt:nsd(), numEncrypt:ns2(),numEncrypt:ns3(),numEncrypt:ns4(),numEncrypt:ns5() )
]]
function numEncrypt:getMergeStr( ... )
	local arg = {...}
	local tempStr = ""
	for i=1,#arg do
		tempStr =tempStr..self:getNum(arg[i])
	end

	return self:getStr(tonumber( tempStr ))

end


--根据加密的字符串获取数
function numEncrypt:getNum(str )

	if not str then
		return nil
	end

	if type(str) =="number" then
		return str
	end

	if tonumber(str) then
		return tonumber(str)
	end

	local firstStr = string.sub(str, 1,self.titleLen)
	if firstStr ~= self.title then
		echo(debug.traceback("错误的字符串"..str) )
		error("错误的字符串"..str)
		return self:getNum0()
	end
	local length = string.len(str)
	str = string.sub(str,1 + self.titleLen ,length )
	--扣除 title的长度
	length = length -self.titleLen
	local count = length/self.bit

	local resultNum = ""
	for i=1,count do
		local nowStr = string.sub(str, (i-1)*self.bit+1,i*self.bit)
		local index = table.indexof(self.key, nowStr)

		--如果没有index
		if not index then
			error("数据被修改了 报错------------------")
			return self:getNum0()
		elseif index == 11 then
			resultNum = resultNum .. "."
		elseif index == 12 then
			resultNum = resultNum .. "-"
		else
			resultNum = resultNum .. (index-1)
		end
	end

	if resultNum =="." then
		return resultNum
	elseif resultNum =="-" then
		return resultNum
	end

	return tonumber(resultNum)
end


--加密数字
function numEncrypt:getStr( num )
	
	local resutlStr = self.title
	local tempStr = tostring(num)
	local length = string.len(num)

	for i=1,length do
		local str = string.sub(tempStr,i,i)
		if str == "." then
			resutlStr  = resutlStr .. numEncrypt.key[11]
		elseif str =="-" then
			resutlStr  = resutlStr .. numEncrypt.key[12]
		else
			local tempValue = numEncrypt.key[tonumber(str) +1]
			if not tempValue then
				error("__数据被修改了")
			end
			resutlStr  = resutlStr .. tempValue
		end
	end

	return resutlStr

end

--判断是否是加密的字符串
function numEncrypt:checkIsEncodeStr(str )
	if string.sub(str,1,self.titleLen) == self.title then
		return true
	end
	return false

end



--加密一个object
function numEncrypt:encodeObject( obj )
	-- body
	local t
	local resultObj = {}
	for k,v in pairs(obj) do
		t = type(v)
		-- dump(v,"____obj__")
		if t == "number" then
			resultObj[k] = self:getStr(v)
		elseif t =="table" then
			resultObj[k] = self:encodeObject(v)
		else
			resultObj[k] = v
		end
	end
	return resultObj
end

--解密一个object
function numEncrypt:decodeObject( obj )
	local t
	local resultObj = {}
	for k,v in pairs(obj) do
		t = type(v)
		if t == "string" then
			if self:checkIsEncodeStr(v) then
				resultObj[k] = self:getNum(v)
			else
				resultObj[k] = v
			end
		elseif t =="table" then
			resultObj[k] = self:decodeObject(v)
		else
			resultObj[k] = v
		end
	end
	return resultObj
end



--初始化
numEncrypt:init()

-- local obj = {
-- 	a= 1,
-- 	b=2,
-- 	c={2,"aaa"},
-- 	[1]  ="hha",
-- 	[2] = 3
	
-- }

-- local enobj = numEncrypt:encodeObject( obj )
--dump(enobj,"enobj---encode")
-- dump(numEncrypt:decodeObject( obj ),"decodeObject")


