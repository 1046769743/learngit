
number = number or {}

--判断一个数是否为空
function number.isNan(value )
	if not value then
		return true
	end

	if tostring(value) == "nan" or tostring(value) == "inf" then
		return  true
	end
	return false
end


--							如果只有area1 或者只有area2  那么只检测单边界左 或右
function number.numBorder( value,area1,area2 )
	local s,e

	if number.isNan(value) then
		echo(value, debug.traceback("__传入的数据是空的"))
		return area1
	end

	if area1 and area2 then
		if area1 < area2 then
			s = area1
			e =area2
		else
			s = area2
			e = area1
		end
	elseif not area2 and area1 then
		s = area1
	elseif not area1 and area2 then
		e = area2
	end
	if s then
		value = value < s and s or value
	end
	if e then
		value = value > e and e or value
	end
	return value 

end


--转化小数为百分比字符串
function number.numToPercent( value )
	value =  math.round(value*100)
	return value.."%"
end

--[[
	value = 123
	ret = {1, 2, 3}
]]
function number.split( value )
	local rets = {}

	if value == 0 then 
		table.insert(rets, 0);
	else 
		while value ~= 0 do
			local num = value % 10;
			table.insert(rets, 1, num);
			value = math.floor(value / 10);
		end
	end 

	return rets;
end

--[[
	n1和n2 十位是否相等
]]
function number.isDecimalEqual( n1, n2 )
	return (math.floor(n1 / 10)) == (math.floor(n2 / 10)) and true or false;
end


--[[
	有几位不同
	eg: 123  12123  return 5
	    14123  14132 return 2
]]
function number.diffDigitCount(n1, n2)

	local n1Array = number.split(n1);
	local n2Array = number.split(n2);

	local n1Len = table.length(n1Array);
	local n2Len = table.length(n2Array);

	if n1Len ~= n2Len then 
		--位数不相等返回一个长的
		return n1Len > n2Len and n1Len or n2Len;
	else 
		for i = 1, n1Len do
			if n1Array[i] ~= n2Array[i] then
				return n1Len - i + 1;
			end
		end
	end 

	return 0;
end

--[[
	value = 13 _num = 2
	ret = {1, 0, 1, 1}

    value = 13 _num = 10
    ret = {1, 3}
]]
function number.splitByNum( value ,_num)
	local rets = {}

	while value ~= 0 do
		local num = value % _num;
		table.insert(rets, 1, num);
		value = math.floor(value / _num);
	end
    local _rets = {}
    for i = #rets ,1,-1 do
    table.insert(_rets,rets[i])
    end
    

	return _rets;
end

--[[
	eg: 
	lcoal r = number.int2BinaryArray(6);

	r = { 1 = 0,
		  2 = 1,
		  3 = 1,
		}
]]
function number.int2BinaryArray(num)
	local bit = require("framework.cc.utils.bit")

	local array = bit.tobits(num);
	return array;
end

--浮点数会差修正
--用于精确计算整数与浮点数之间的乘法
--输入一个浮点数,返回与这个浮点数最接近的整数
function number.precisefloat(  floatValue )
    local MATH_EPS = 0.000002
    local _lowValue  = math.floor(floatValue)
    local _upValue = math.ceil(floatValue )
    if floatValue - _lowValue < _upValue - floatValue then
        return _lowValue
    end
    return _upValue
end
--返回浮点数的小数部分,注意,如果该数字非常接近于一个整数,则返回0
function number.fract(floatValue)
    local MATH_EPS = 0.000031
    --在一个整数的左侧的非常临近的区域
    local _upValue = math.ceil(floatValue)
    if (_upValue - floatValue)/floatValue <=MATH_EPS then    --向上舍入,检测器精确度
        return 0           
    end
    --在某个整数的右侧的非常临近的区域
    local _downValue =  math.floor(floatValue)
    if( floatValue - _downValue)/floatValue <= MATH_EPS then
        return 0
    end
    return math.abs(floatValue - _downValue)
end
--舍入
function number.roundoff(floatValue)
    --如果误差在0.003%之内,就约等于这个数字
    local MATH_EPS = 0.000031
    local _up = math.ceil(floatValue)
    --低于临近的整数值
    if (_up -floatValue)/floatValue <=MATH_EPS then
        return _up
    end
    --高于临近的整数值
    local _down = math.floor(floatValue)
    if (floatValue - _down)/floatValue<= MATH_EPS then
        return _down
    end
    return _down
end
--向下取整,如果这个数字向右非常趋近于某一个整数,则返回这个整数
function number.roundfloor( floatValue)
    local MATH_EPS = 0.000002
    local _upfloor = math.floor(floatValue +MATH_EPS )
    local _floorValue = math.floor(floatValue)
    if _upfloor > _floorValue then
        return _upfloor
    end
    return _floorValue
end
--向上取整,如果这个数字向左非常趋近于某一个数字,则返回这个数字
function number.roundceil( floatValue)
    local MATH_EPS = 0.000002
    local _lowceil = math.ceil(floatValue  - MATH_EPS)
    local _ceilValue = math.ceil(floatValue)
    if _ceilValue > _lowceil then
        return _lowceil
    end
    return _ceilValue
end

--返回给定数字的某一个二进制位
--index:从0到最高位的数目-1
function number.bitat( d, index)
    local m = 1
    local i=0
    while i< index+1 do
        m = m*2
        i = i+1
    end
    local n= m/2
    return math.floor(d%m/n)
end






















