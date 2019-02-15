--[[
    Author: pangkangning
    Date:2018-07-03
    Description: 地形编辑器相关逻辑控制器
    NOTE：如果有新的地形需要在 xd_调试界面.fla 中 UI_debug_public 添加相应道具，命名规则参考依据命名的原件
]]

require("lfs")

local EditorControler = {}
EditorControler.mapData = {} --地图数据
EditorControler.max = {x=1,y=1} --地图的尺寸数据
-- 操作模式
EditorControler.handleType = {
	cover = 1,--行走与否(默认可行走)
	terrain = 2,--地形
	none = 3 , --无任何操作模式
	area = 4 ,--小区域的地块
}
EditorControler.handleData = {type=EditorControler.handleType.none,value=0} --当前操作模式

local areaCsvName = "ExploreMapSmallBlock"

-- 更新操作模式
function EditorControler:updateHandleInfo( hType,value )
	self.handleData.type = hType
	self.handleData.value = tonumber(value) or 0

	EventControler:dispatchEvent(EditorEvent.EDITOR_HANDLE_CHANGE,self.handleData)
end
function EditorControler:setAreaData(tmpX,tmpY)
	tmpX,tmpY = tmpX or 0,tmpY or 0
	tmpX = tmpX * 2 + tmpY
	-- 区块表、这个单独存在ExploreMapSmallBlock
	self.areaData = Tool:configRequire("explore."..areaCsvName)
	-- 重新设置下areaPos对应的key值(方便检索)
	for k,v in pairs(self.areaData) do
		if not v.areaPos then
			v.areaPos = {}
		end
		local areaArr = table.deepCopy(v.areaPos)
		local tmpArr = {}
		for m,n in pairs(areaArr) do
			local a,b = n.x + tmpX,n.y + tmpY
			local key = FuncGuildExplore.getKeyByPos(a,b)
			tmpArr[key] = {x=a,y = b}
		end
		v.areaPos = tmpArr
	end
	LS:pub():set("EDITOR_FILE_NAME",self.currFileName)
end
-- 设置地图数据
function EditorControler:setMapData(fileName)
	self.currFileName = fileName --当前编辑的文件名
	self.mapData = {}
	package.loaded["exploreMap."..fileName] = nil --先卸载这个lua文件
	self.mapData = Tool:configRequire("exploreMap."..fileName)
	self:setAreaData()
	
	self:updateMapMax()
	-- 地图设置成功后，发送通知地形刷新
	EventControler:dispatchEvent(EditorEvent.EDITOR_LOAD_COMP)
end
-- 获取初始化的值(存储的数据格式)
function EditorControler:createDefaultData(x,y)
	local tmp = {x = x,y = y}
	-- 同奇同偶才有值
	if x%2 == y%2 then
		tmp.info = {1,1}
	end
	return tmp
end
-- 更新格子上的数据
function EditorControler:updateGridData(x,y)
	if self.mapData[tostring(x)] and self.mapData[tostring(x)][tostring(y)] then
		local dataInfo = self.mapData[tostring(x)][tostring(y)].info
		if dataInfo then
			-- 根据操作做相应的处理
			if self.handleData.type == self.handleType.terrain then 
				if #dataInfo >= 2 and dataInfo[2] ~= self.handleData.value and
					 self.handleData.value > 0 then
					dataInfo[2] = self.handleData.value
					EventControler:dispatchEvent(EditorEvent.EDITOR_GRID_CHANGE,{x = x,y = y})
				end
			elseif self.handleData.type == self.handleType.cover then
				if #dataInfo < 3 then
					for i=#dataInfo+1,3 do
						table.insert(dataInfo,0) --默认为可走、且把数组前面的值都置为0
					end
				end
				if dataInfo[3] ~= self.handleData.value then
					dataInfo[3] = self.handleData.value
					EventControler:dispatchEvent(EditorEvent.EDITOR_GRID_CHANGE,{x = x,y = y})
				end
			end
		end
		if self.handleData.type == self.handleType.area then
			local isHave = false
			for k,v in pairs(self.areaData) do
				local tmpArr = v.areaPos
				local key = FuncGuildExplore.getKeyByPos(x,y)
				if tmpArr[key] then
					if tonumber(k) == self.handleData.value then
						isHave = true
					else
						v.areaPos[key] = nil --将原来格子的数据删掉
					end
					break
				end
			end
			if not isHave then
				local tmpArr = self.areaData[tostring(self.handleData.value)].areaPos
				local key = FuncGuildExplore.getKeyByPos(x,y)
				tmpArr[key] = {x=x,y = y}
				EventControler:dispatchEvent(EditorEvent.EDITOR_GRID_CHANGE,{x = x,y = y})
			end
		end
	end
end
-- 重置地图大小
function EditorControler:resetMapSize(newX,newY)
	local x,y = self.max.x,self.max.y
	local tmpX,tmpY = math.floor((newX - x)/4),math.floor((newY - y)/2)
	-- if tmpX%2 ~= tmpY%2 then
	-- 	echo("不是同奇同偶，需要设置为同奇同偶")
	-- 	newX = newX + 2
	-- end
	echo("地图修改",tmpX,tmpY)
	self:updateMapMax(newX,newY,tmpX,tmpY)
	-- 地图设置成功后，发送通知地形刷新
	EventControler:dispatchEvent(EditorEvent.EDITOR_RESET_SIZE,{oldX = x,oldY = y})
	-- dump(self.mapData,"s===")
end
-- 更新地形数据
function EditorControler:updateMapMax(newX,newY,tmpX,tmpY)
	local x,y = newX,newY
	local _x,_y,maxX,minY,maxY = 0,0,0,0,0
	if not newX then
		x,y = 1,1
		local count = 0
		for k,v in pairs(self.mapData) do
			for m,n in pairs(v) do
				_x,_y = tonumber(n.x),tonumber(n.y)
				minY = math.min(_y,minY)
				maxY = math.max(_y,maxY)
				maxX = math.max(_x,maxX)
				if n.info then
					count = count + 1
				end
			end
		end
		self.maxGrid = count
		x,y = FuncGuildExplore.getMapSize(maxX,minY,maxY)
	else
		local oldMap = table.deepCopy(self.mapData)
		self:createrEmptyData(newX,newY,tmpX,tmpY)
		local c,d = tmpX or 0,tmpY or 0
		c = c * 2 + d
		for m,yArr in pairs(self.mapData) do
			for n,v in pairs(yArr) do
				if v and v.info then
					local a,b = v.x - c ,v.y - d
					if oldMap[tostring(a)] and oldMap[tostring(a)][tostring(b)] then
						v.info = oldMap[tostring(a)][tostring(b)].info
					end
				end
			end
		end
	end
	-- 重新设置地图大小
	self.max.x,self.max.y = x,y
end

-- 根据Y轴获取x的起始位置
function EditorControler:getStartX(y)
	local offsetPerNums = FuncGuildExplore.offsetPerNums
	local offset = math.ceil(y/offsetPerNums)
	local xStart = y - (offset-1)*2
	return xStart
end
-- 获取获取偏移
function EditorControler:getOffSet(x)
	local offsetPerNums = FuncGuildExplore.offsetPerNumsUp
	local offset = -math.floor(x/offsetPerNums)
	return offset
end
-- 生成一个新的默认地形 (tmpX,tmpY 偏移的地形)
function EditorControler:createrEmptyData( x,y,tmpX,tmpY)
	local count = 0
	self.mapData = {}
	local rx,ry
	for j=1,y,1 do
		local xStart = FuncGuildExplore.getStartX(j)
		for i=xStart,x+xStart do
			local offSet = FuncGuildExplore.getOffSet(i/2)
			rx,ry = i + offSet,j + offSet
			local tmpInfo = self:createDefaultData(rx,ry)
			if tmpInfo.info then
				if not self.mapData[tostring(rx)] then
					self.mapData[tostring(rx)] = {}
				end
				self.mapData[tostring(rx)][tostring(ry)] = tmpInfo
				count = count + 1
			end
		end
	end
	self.maxGrid = count
	-- 设置地图大小
	self.max.x,self.max.y = x,y
	self:setAreaData(tmpX,tmpY)
end
-- 创建一张地图
function EditorControler:createMapData(fileName,x,y)
	self.currFileName = fileName --当前编辑的文件名
	self:createrEmptyData(x,y)
	self:_saveFile(fileName)
	EventControler:dispatchEvent(EditorEvent.EDITOR_LOAD_COMP)
end
-- 存储编辑好的地形
function EditorControler:saveMapFile( ... )
	if not self.currFileName then
		echoError ("联系技术，文件名不存在")
	end
	self:_saveFile(self.currFileName)
	self:saveAreaPosData()
end
-- 获取存储的文件内容
function EditorControler:getSaveData()
	local saveStr = "x,y,data,desig by editor \n"
	saveStr = saveStr .. "x[string],y[string],info[vector<string>],\n"
	for x,yArr in pairs(self.mapData) do
		for y,v in pairs(yArr) do
			if v and v.info and (v.x%2 == v.y%2) then
				saveStr = saveStr ..v.x..","..v.y..","..table.concat(v.info, ";")..";,\n"
			end
		end
	end
	return saveStr
end
-- 保存文件
function EditorControler:_saveFile(fileName)
	local filePath = self:getFullPathFile(fileName)
	local saveStr = self:getSaveData()
	if not saveStr then
		return
	end
	if device.platform == "windows" or device.platform =="mac" then
		local targetFile, errorMsg = io.open(filePath, "w+") --覆盖
		targetFile:write(saveStr)
		targetFile:close()
	end
end
-- 获取存储的文件路径
function EditorControler:getFullPathFile( fileName,fullPath)
	fullPath = fullPath or "configs_dev/exploreMap/" 
	local pathStr = ""
	-- 获取需要存储的位置
	if device.platform =="mac" then
		pathStr = AppHelper:getResourcesRoot()
	elseif device.platform == "windows" then
		pathStr = lfs.currentdir()
        pathStr = string.gsub(pathStr, "\\","/").."/"
	end
	fullPath = string.gsub(pathStr, "/Resources", "/")..fullPath
	-- local fullPath = string.format("%s/configs_dev/exploreMap/",string.gsub(pathStr, "/Resources", ""))
	if (not cc.FileUtils:getInstance():isDirectoryExist(fullPath) ) then
		cc.FileUtils:getInstance():createDirectory(fullPath)
	end
	fullPath = fullPath..fileName..".csv"
	-- 获取需要保存的文件位置
	echo("存储的文件路径----:",fullPath)
	return fullPath
end

-- 存储区块配表areaPos
function EditorControler:getAreaPosSaveData()
	local saveStr = "x,y,data,desig by editor \n"
	saveStr = saveStr .. "id[string],type[int],areaPos@lua[vector;x[int];y[int]],\n"
	for k,v in pairs(self.areaData) do
		saveStr = saveStr ..v.id..","..(v.type or "")..",\""
		for m,n in pairs(v.areaPos) do
			if n.x%2 == n.y%2 then
				saveStr = saveStr ..n.x..","..n.y..";"
			end
		end
		saveStr = saveStr .. "\",\n"
	end
	return saveStr
end
function EditorControler:saveAreaPosData( )
	local filePath = self:getFullPathFile(areaCsvName,"configs_dev/explore/")
	local saveStr = self:getAreaPosSaveData()
	if not saveStr then
		return
	end
	if device.platform == "windows" or device.platform =="mac" then
		local targetFile, errorMsg = io.open(filePath, "w+") --覆盖
		targetFile:write(saveStr)
		targetFile:close()
	end
end

return EditorControler