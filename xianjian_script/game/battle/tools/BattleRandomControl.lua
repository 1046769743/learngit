
-- if not DEBUG_SERVICES  then
-- 	require("bit")
-- else
-- 	require("framework.cc.utils.bit")
-- 	bit.lshift = bit.blshift
-- 	bit.rshift = bit.brshift

-- end
require("bit")
require("framework.functions")
local _yinziToIndexDic = {}

local max_ratio = 1/4294967295
local max_int = 0.5

local randomYinzi = class("randomYinzi")
randomYinzi.initR = 0
randomYinzi.r =0
randomYinzi.step =0


BattleRandomControl = {}

-- 跳过取正常随机序列标志
local jumpRandomStep = false

--获取下一步
function randomYinzi:getNext(  )
	
	-- if DEBUG_SERVICES or true then
	-- 	local rd = math.random()
	-- 	return rd
	-- end
	-- body
	local tempValue = bit.lshift(self.r,21)
	
	self.r = bit.bxor(self.r,tempValue)


	tempValue = bit.rshift(self.r,35)
	
	self.r = bit.bxor(self.r,tempValue)

	tempValue = bit.lshift(self.r,4)
	
	self.r = bit.bxor(self.r, tempValue)

	self.step = self.step +1
	local result 
	if self.r < 0 then
		--todo
		result = self.r*max_ratio +1
	else
		result = self.r*max_ratio
	end
	-- echo(self.r,self.step,"____________aaaaaaaaaaaaaa",self.initR,result)
	return result
	-- if self.step == 19 then
	-- 	echoError("_____________suijjjjj")
	-- end
	--echo(self.r*max_ratio+0.5)
	--如果小于0  那么就需要加上1.5 是为了保证取值在0.5-1之间  如果大于0 那么就是正常值 这个做是为了和64位的算法保持一致
	
end

-- 设置跳过
function BattleRandomControl.setJumpRandomStep( flag )
	echo("设置跳过随机序列==========",flag)
	jumpRandomStep = flag
end

function BattleRandomControl.getCurStep(index)
	if(not index) then
		index =1
	end
	local yinzi = _yinziToIndexDic[index]
	return yinzi.step	
end

--跳到指定的步数
function BattleRandomControl.gotoTargetStep( step,index )
	if(not index) then
		index =1
	end
	-- if step ==0 then
	-- 	--todo
	-- 	return
	-- end
	-- body
	local yinzi = _yinziToIndexDic[index]
	yinzi.r = yinzi.initR
	yinzi.step = 0
	for i=1,step  do
		yinzi:getNext()
	end
end


local str = ""


camCount = false

--获取一个随机数
function BattleRandomControl.getOneRandom( index )
	-- 本次随机不使用正常序列
	if jumpRandomStep then
		return math.random()
	end

	if index then
		echo(debug.traceback("_不应该有index----_"),"index:"..index)
	end
	if Fight.isOpenFightLogs then
		-- echo("_____取随机数了",BattleRandomControl.getCurStep())
	end
	
	if not index then
		--todo
		index =1
	end
	-- body
	local yinzi = _yinziToIndexDic[index]
	if(not yinzi) then
		yinzi = randomYinzi.new()
		yinzi.r = 1
		yinzi.initR =1
		_yinziToIndexDic[index] = yinzi

	end

	local result = yinzi:getNext()

	--echo("____step",yinzi.step,yinzi.initR,result)

	-- if dev.FIGHT_DEBUGUI then
	-- 	if  yinzi.step <=500 and yinzi.step >=300 then
	-- 		str =str.."\n".. debug.traceback(result.."__step"..yinzi.step.."__因子信息")
	-- 		if yinzi.step ==500 then
	-- 			outPutStr()
	-- 		end
	-- 	end
	-- end
	
	return result
end

function outPutStr(  )
	
	local cachePath = device.cachePath
	echo(cachePath,"___输出路径")
	io.writefile(cachePath.."temp.txt", str)
	str = ""
end



--随机获取一个方位
function BattleRandomControl.getOneRandomWay( index )
	local random = BattleRandomControl.getOneRandom(index)
	if random > 0.5 then
		return 1 
	end
	return -1
end


--获取一个随机的int		最大值(不包括这个值)	最小值	排除某个数
function BattleRandomControl.getOneRandomInt(resrrucr,min ,exclude,index)
	-- body

	local nums = resrrucr

	local excluArr
	local excluNum=0
	local i=0
	if exclude then
		--todo
		if type(exclude) == "number" then
			excluArr = {exclude}
		else
			excluArr = exclude
		end
		excluNum = table.getn(excluArr)

		--在判断是否有超出界限的数据
		local tempValue=0
		for i=excluNum,1,-1 do
			tempValue = excluArr[i]
			--如果超过范围了
			if tempValue >= resrrucr or tempValue < min then
				table.remove(excluArr,i)
			end
		end
		--然后在让这个数组按照升序排列 必须要升序
		table.sort(excluArr)
		excluNum = table.getn(excluArr)
		nums =nums- excluNum

	end

	if(not min) then min = 0 end
	nums = nums - min
	local random = BattleRandomControl.getOneRandom(index)*nums
	local result = math.floor(random)
	result = result + min
	if exclude then
		for i=1,excluNum do
			--如果大于或者等于排除的数了 那么就让这个数+1
			if result >= excluArr[i] then
				result = result +1
			end
		end

	end

	return result
end


	
--随机获取一个数量            起始值 终止值	排除区域{ {1,3},{4,5}}(必须不能有重叠,大小可以换)	 	 保留小数位数(默认-2)		种子序号
--  exclude  默认为空  可以为1维 或者包含多个区域的二维数组
function BattleRandomControl.getOneRandomFromArea(startNum,	endNum, 		 exclude, 					damic,				index)

	if not damic then
		damic = -2
	end

	if startNum > endNum then
		startNum,endNum = endNum,startNum
	end

	--记录初始化的start end
	local s = startNum
	local e = endNum


	local i,info
	local t1,t2
	if exclude then
		if type(exclude[1]) == "number" then
			exclude = {exclude}
		end

		--需要把exclude 进行交叉合并  如果有交叉区域 需要排重
		for i=1,table.getn(exclude) do
			info = exclude[i]
			t1 = info[1]
			t2 = info[2]
			t1 = number.numBorder(t1,s,e)
			t2 = number.numBorder(t2,s,e)
			if t2 < t1 then
				t1,t2 = t2,t1
			end

			endNum = endNum-t2 + t1
		end

	end


	local dis=endNum-startNum
	local random = BattleRandomControl.getOneRandom(index)
	
	local k=(endNum-startNum)/(1-0)
	local result=k*(random-0)+startNum
	if exclude then
		for i=1,table.getn(exclude) do
			info = exclude[i]

			t1 = info[1]
			t2 = info[2]
			t1 = number.numBorder(t1,s,e)
			t2 = number.numBorder(t2,s,e)

			if t2 < t1 then
				t1,t2 = t2,t1
			end

			if result >= t1 then
				result = result + t2- t1
			end
			
		end
	end
	
	result = number.numBorder(result,s,e)
	if damic then
		local powNum = math.pow(10,-damic)
		result = math.round(result * powNum)/powNum
		--还要取一次边界判断
	end
	

	return result
end

-- local total =0
-- local rrr = 0
-- local numsss = 100
-- for i=1,numsss do
-- 	rrr = BattleRandomControl.getOneRandomFromArea(5,	30, 		 { {1,10},{12,20}  }, 					-2			) 
-- 	total  = total +rrr
-- 	print( rrr,"获取随机数--"  )
-- end

-- print("平均数:"..total/numsss)
-- print("平均数:"..total/numsss)
-- print("平均数:"..total/numsss)
-- print("平均数:"..total/numsss)
-- print("平均数:"..total/numsss)



--随机获取一个矩形区域内的一个点 rect = {x=x,y =y,w=w,h=h}  
--[[
	outRect  排除区域范围  默认为空 可以传入包含多个rect的数组  也可以只传入 一个rect

]]
function BattleRandomControl.getOnePosInRect( rect,  damic,outRect, index )
	local x = BattleRandomControl.getOneRandomFromArea(rect.x, rect.x +rect.w, nil, damic,index)

	local y 

	if not outRect then
		y = BattleRandomControl.getOneRandomFromArea(rect.y, rect.y +rect.h, nil, damic,index)
	else
		--如果只是单个矩形
		if outRect.x then
			outRect = {outRect}
		end

		--然后遍历所有的 矩形外区域  先判断x是否和这些矩形区域相交
		local exclude = {}
		for i,v in ipairs(outRect) do
			--如果和这个矩形相交 那么 把这个矩形的y区域需要排除掉
			if x>=v.x and x <=v.x+v.w then
				table.insert(exclude,{v.y,v.y+v.h} )
			end
		end
		y = BattleRandomControl.getOneRandomFromArea(rect.y, rect.y +rect.h, exclude, damic,index)
	end

	return {x = x,y = y}
end

--设置一个随机种子
function BattleRandomControl.setOneRandomYinzi(yinzi,step,index )
	if not step then
		step = 0
		--todo
	end

	if not index then
		index = 1
		--todo
	end

	-- math.randomseed(yinzi)
	local randomObj = randomYinzi.new()
	randomObj.initR = yinzi
	randomYinzi.r = yinzi
	_yinziToIndexDic[index] = randomObj

	BattleRandomControl.gotoTargetStep(step,index)
	-- body
end

--获取随机因子
function BattleRandomControl.getRandomYinzi(  )
	return _yinziToIndexDic[1].initR
end


--传入一个int 获取等于这个int的指定数量且不重复的数组
function BattleRandomControl.getOneGroupIndex(restrict,nums,index )
	-- body
	
	if not nums then nums = restrict end
	local resultArr = {}
	local tempArr = {}
	for i=1,restrict do
		tempArr[i] = i
	end
	local pushIndex = 1
	for i=restrict,restrict-nums+1,-1 do
		local randomInt = BattleRandomControl.getOneRandomInt(i+1,1,nil,index)
		local value_1 = tempArr[randomInt]
		local value_2 = tempArr[i]
		resultArr[pushIndex] = value_1
		pushIndex = pushIndex +1
 
		--然后对临时数组进行交换操作
		tempArr[randomInt] = value_2
		tempArr[i] = value_1
	end
	return resultArr

end


--随机一个数组 返回新数组不改变原来的数组
function BattleRandomControl.randomOneGroupArr(arr ,index)
	-- body
	local nums = #(arr)
	local intArr = BattleRandomControl.getOneGroupIndex(nums,nil,index)
	local resultArr = {}
	for i=1,nums do
		resultArr[i] = arr[intArr[i]]
	end
	return resultArr
end

--获取一个数组里面的随机N个 数据
function BattleRandomControl.getNumsByGroup(arr,nums, exclude,index)
	local tempArr = arr
	if nums ==0 or not arr then
		return {}
	end
	if exclude then
		if type(exclude) == "number" then
			exclude = {exclude}
		end

		tempArr = table.copy(arr)
		for i=table.getn(tempArr),1,-1 do
			if table.indexof(exclude,tempArr[i]) ~= false then
				table.remove(tempArr,i)
			end
		end
	end

	tempArr = BattleRandomControl.randomOneGroupArr(tempArr,index)

	local resultArr = {}
	for i=1,nums do
		resultArr[i] = tempArr[i]
	end

	return resultArr

end

--按数组里面的比率获取数组的index              
--[[
	params 格式 {"property1","p2"  }  比较的是 arr[n][property1][p2] 的值 ,n为0- #arr
	exclude 需要排除的数组index
	gongshi  是一个计算值权重的比较函数 参数  (value ,index  )  ,value 表示值,  index 表示当前序号
	
]]
function BattleRandomControl.getOneIndexByGroup( arr,	params, exclude,	gongshi,index )
	
	--先把数组里面的所有数求合
	local total = 0
	local i,v
	local tempArr = {}
	local tempValue
	for i,v in ipairs(arr) do
		if exclude and  table.indexof(exclude, i) ~=false  then
			tempValue = 0
		elseif v ==0 then
			tempValue = 0
		else
			--如果有手动获取值的函数  那么取手动  否则 按照 getValue
			if gongshi then
				tempValue = gongshi(v,i)
			else
				tempValue =  table.getValue( v,params)
			end

			if not tempValue then
				dump(v)
				dump(params)
				echo(debug.traceback("这个数据为空",i))
				tempValue = 0
			end

		end
		
		total = total + tempValue
		table.insert(tempArr, total)
	end
	--如果总和为0了 那么随机一个 
	if total ==0 then
		echo( debug.traceback( "所有的 概率合为0那么随机一个") )
		return  BattleRandomControl.getOneRandomInt(#arr+1,1) , true
	end
	local random = BattleRandomControl.getOneRandom(index)
	random = random *total
	
	for i,v in ipairs(tempArr) do
		if random <= v then
			return i
		end
	end
	return i


end


--按数组里面的比率获取数组的多个index							exclude 需要剔除的数组 index
function BattleRandomControl.getIndexGroupByGroup( arr,nums,params,exclude,gongshi, index )
	local result = {}
	local pos
	nums = nums > #arr and #arr or nums
	local tempArr  = table.copy(arr)

	if exclude then
		for i,v in ipairs(arr) do
			--如果有需要剔除的 那么让这个剔除的 概率为0
			if table.indexof(exclude, i) ~= false then
				tempArr[i] = 0
			end
		end
	end

	

	local whetherNil
	for i=1,nums do
		pos ,whetherNil= BattleRandomControl.getOneIndexByGroup(tempArr,params,nil,gongshi, index)
		--让对应的index的权重为0
		if (not whetherNil) then
			tempArr[pos] = 0
			table.insert(result, pos)
		end
	end
	

	--返回获取到的数组结果
	return result

end




--已知一组数的合  而且每个数的取值范围 ,返回随机数
--[[
	a+b+c+d+e = 100
	每个数的取值范围为 12-18 随机取 a b c d e

]]
--										空数组(存储结果)			取数数量 	总和   			限制范围
function BattleRandomControl.getRandomByTotal(targetArr,					nums,		total,		exclude )
	
	if nums > 1 then
		local min = exclude[1] 
		local max= exclude[2] 

		local minTotal =  exclude[1] * (nums)
		local maxTotal =  exclude[2] * (nums)

		local dArea = exclude[2] - exclude[1]

		local new1 = exclude[1]
		--local new2 = exclude[2]

		local minPianyi = total-minTotal

		--计算最小值偏移  取值 需要保证所有值取最小的时候 都能保证等式成立才行
		if minPianyi < dArea then
			max = min + minPianyi
		end

		--计算最大值偏移  取值 需要保证所有值取最大的时候 都能保证等式成立才行
		local maxPianyi = maxTotal - total
		if maxPianyi < dArea then
			min = max - maxPianyi
		end

		--然后从新的min max 里面取一个数
		local random = BattleRandomControl.getOneRandomFromArea(min, max, nil, 0)

		table.insert(targetArr, random)
		--这里递归取值  但是这个时候 的 total 和nums都改变了
		return BattleRandomControl.getRandomByTotal(targetArr,nums-1,total-random,exclude )

	else
		--如果是最后一个数了  那么就直接取值
		local value = total
		table.insert(targetArr, value)
		return targetArr
	end

end






