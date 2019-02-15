--
-- Author: Your Name
-- Date: 2014-03-14 10:34:57
--


-- point = point or {}


-- point.x =0
-- point.y =0
-- function point:clone(  )
-- 	return  {x = self.x,y = self.y}
-- end



--定义一些静态的数据
math.cospi4 = math.cos( math.pi/4 )


local oldAtan2 = math.atan2

math.atan2=function ( dy,dx )
	if dy ==0 and dx ==0 then
		return 0
	end
	return oldAtan2(dy,dx)
end




--创建一个文件夹所在的目录
function io.creatDir( filepath )

	filepath = string.gsub(filepath, "\\", "/")
	local fileDir = string.split(filepath, "/")
	local tempValue = ""
	local length


	for i=1,#fileDir-1 do
		tempValue = tempValue.. fileDir[i].."\\"
		if not io.exists(tempValue) then
			os.execute( "if not exist "..tempValue.." mkdir "..tempValue)
		end
	end 
end

  



-- return var or def
function vcheck(var,def)
	if var==nil then return def end
	return var
end

--一个对象是否为空 
function empty(var)
	return not var or var=="" or var==0 or (type(var)=="table" and table.isEmpty(var))
end



function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
    return math.round(tonumber(v))
end

function tobool(v)
    return (v ~= nil and v ~= false)
end




--判断key是否在这个table里有值
function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

-- 三目运算 condition ? a : b
function three( condition, a, b )
	return (condition and {a} or {b})[1]
end


--[[
-- 简单的函数传递，用于各种事件时传递函数，可传递任意多个参数
-- 格式: c_func(func,a,b,c)
-- Usage:
	[1]基本使用方法
	有一个方法，需要传递函数
	function AAA:registerFunc(aaa_func) aaa_func() end
	若需要传递的函数为
	local function func(...) echo(...) end
	使用时
	self:registerFunc(func) --正常无法传递参数
	self:registerFunc(c_func(func,1)) --传递1个参数 --aaa_func被调用时打印输出为 1
	self:registerFunc(c_func(func,1,"a",{})) --传递3个参数 --aaa_func被调用时打印输出为 1 "a" table
	[2]另外，某些冒号函数的事件传递方法
	function AAA:bbb_func(...) echo(...) end
	self:registerFunc(c_func(self.bbb_func,self,1,"a")) --bbb_func被调用时打印输出为 1 "a"
	[3]另外支持，在调用时可以附加更多的参数值进来，如
	function AAA:registerFunc(ccc_func) ccc_func(4,5,6) end --参数值456是作为额外参数传递给ccc_func
	local function func(...) echo(...) end
	self:registerFunc(c_func(func,self,1,"a")) --ccc_func被调用时打印输出为 1 "a" 4 5 6 (会同时得到调用时传入的456)
 ]]
function c_func(f,...)
	local _args = {...}
	if not f then
		error("传递了空函数")
		dump(_args,"____args")
	end

	local maxNums = 0
	for k,v in pairs(_args) do
		maxNums = math.max(k,maxNums)
	end

	for i=1,maxNums do
		if not _args[i] then
			_args[i] = false
		end
	end

	return function(...)
		local _tmp = table.copy(_args)
		table.array_merge(_tmp,{...})
		return f(unpack(_tmp))
	end
end

--[[
-- 动态执行字符串
-- Usage:
	eval("echo(os.time())")
 ]]
function eval(str)
	if type(str) == "string" then
		return loadstring("return " .. str)()
	elseif type(str) == "number" then
		return loadstring("return " .. tostring(str))()
	else
		echo("is not a string")
	end
end










--矩形工具
rectEx= rectEx or {}
--是否包含一个点rect格式 x,y,w,h r = {x= x,y=y,w =w,h = h},    border 检测边界
function rectEx.contain(r,x,y ,border)
	border = border  and border or 0
	r.w = r.w or r.width
	r.h = r.h or r.height
	if x <r.x - border or x >r.x+r.w + border or y < r.y -border or y > r.y + r.h +border then
		return false
	end
	return true

end

function rectEx.mergeRect(rect1,rect2)
	-- rect1宽高为0，直接返回rect2
	if not rect1 or rect1.width<=0 or rect1.height<=0 then
		return rect2
	end
	-- rect2宽高为0，直接返回rect1
	if not rect2 or rect2.width<=0 or rect2.height<=0 then
		return rect1
	end
	-- 都有宽高，合并之
	local _minx = math.min(rect1.x,rect2.x)
	local _maxx = math.max(rect1.x+rect1.width,rect2.x + rect2.width)
	local _miny = math.min(rect1.y,rect2.y)
	local _maxy = math.max(rect1.y + rect1.height,rect2.y + rect2.height)
	return cc.rect(_minx,_miny,_maxx-_minx, _maxy-_miny)
end

--圆
circleEx= circleEx or {}
--判断一个点是否在圆内 圆的格式 {x=,y=,r=},border 检测留多少边界
function circleEx.contain(c,x,y,border )
	border = border  or 0
	local r = number.numBorder(c.r - border,0)
	local dx = x-c.x
	local dy = y -c.y
	if dx*dx+dy*dy>r*r then
	 	return false
	end 
	return true
end


--点工具
pointEx = pointEx or {}

--跟点赋予 transFrom 形变
function pointEx.pointApplyTransform(point,t )
	local p = {}
	p.x = t.a * point.x + t.c * point.y + t.tx;
	p.y = t.b * point.x + t.d * point.y + t.ty;
	return p
end


--给矩阵赋予 transFrom matrix 形变
--transfrom ,a,b,c,d,tx, ty
function rectEx.rectApplyTransform(rect,transfrom )



	local top = rect.y + rect.height
	local left = rect.x
	local right =rect.x + rect.width
	local bottom =rect.y

	local topLeft =pointEx.pointApplyTransform(cc.p(left,top),transfrom)
	local topRight =pointEx.pointApplyTransform(cc.p(right, top),transfrom)
	local bottomLeft =pointEx.pointApplyTransform(cc.p(left, bottom),transfrom)
	local bottomRight =pointEx.pointApplyTransform(cc.p(right, bottom),transfrom)


	--存储max min函数
	local min = math.min
	local max = math.max

	local minX = min(min(topLeft.x, topRight.x), min(bottomLeft.x, bottomRight.x));
    local maxX = max(max(topLeft.x, topRight.x), max(bottomLeft.x, bottomRight.x));
    local minY = min(min(topLeft.y, topRight.y), min(bottomLeft.y, bottomRight.y));
    local maxY = max(max(topLeft.y, topRight.y), max(bottomLeft.y, bottomRight.y));

    local result = cc.rect(minX,minY,(maxX-minX),(maxY- minY))
    return result

end


-- dump(rectEx.rectApplyTransform(cc.rect(0,0,960,54) ,{a=0.7070770263671875, b=-0.7070770263671875, c=-0.70709228515625, d=-0.70709228515625, tx=-0.3, ty=-1.3}   ) 		)



--以后还会有更多扩展  比如矩形是否与矩形相交  矩形是否和圆相交==



--获取真实的file名称
function getRealFileName( targetFile )
	return targetFile

end

--输出全局变量
function testGolbalKey(  )
	local arr = {}
	for k,v in pairs(_G) do
		table.insert(arr, k)
	end
	table.sort(arr)
	local str = ""
	str = table.concat(arr,", ")
	echo("globalKey:"..str .."_\nlength:"..#arr)
end


