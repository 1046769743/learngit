--
-- Author: Your Name
-- Date: 2014-01-02 10:21:52
--


MapControler= class("MapControler")


local oneScreenWidth = 1136 -- 一屏的宽度   因为现在默认是按3屏摆放的 所以 需要判定当每一层的x坐标到达多少的时候 进行 循环容器

local baseScreenWidth = 960 		--基础屏幕宽度

local baseScreenNums = 3 		--基础屏幕数量  默认是拼3屏

local halfScreenWidth = 1136/2 				--半屏的宽度

local baseSwitchPos = oneScreenWidth * 1.5  --基础的需要切换的坐标  也就是说必须要坐标大于1.8屏的时候 才需要开始进行循环预备 

local mapScale = 1

local threeScreenWidth = oneScreenWidth * baseScreenNums 		--3屏幕的宽度
local halfThreeWidth = threeScreenWidth /2 			--1.5屏宽度
 
local useRepeatMap = false


MapControler.scaleCtnObj =nil  --进行缩放的容器Obj
MapControler.moveCtnObj = nil  --进行运动的容器obj


MapControler.layerPosIndexObj = nil 	--记录每一层 所在第几屏

local disableMap = false

--现在map采用循环拼接方式 所以需要对容器进行循环管理

--这个是记录每一层容器的初始偏移值 
MapControler.ctnPianyiObj = nil
MapControler.mapMaxWidth = 0

--容器数组  对于每一层 都是可能是一个二维数组
--[[
	layer1 = {screen1,screen2   }
	layer2 = {screen1,screen2},
	...
]]
MapControler.ctnArrObj = nil

--血玉
MapControler.leftBloodJade = nil
MapControler.rightBloodJade = nil
MapControler.bloodJadePos = nil

-- 场景
local sceneArr = {
	"map_bingfenggu",
	"map_caishenhuanjing",
	"map_dalichunyi",
	"map_dalikuhuang",
	"map_dengxiantaizhandou",
	"map_fengduguicheng",
	"map_guzhanchang",
	"map_huainanwangling",
	"map_huanmingjie",
	"map_huoshenshilian",
	"map_lishushan",
	"map_loulan",
	"map_mojie",
	"map_qionghuafeixu",
	"map_shanshenshilian",
	"map_shenjiangmijing",
	"map_shenshu",
	"map_shilipo",
	"map_shushan",
	"map_suoyaotanei",
	"map_suoyaotawanfa",
	"map_suoyaotawanfa2",
	"map_suzhoucheng",
	"map_suzhouchengwai",
	"map_tangjiabao",
	"map_xianlingdao",
	"map_wanrengufeng",
	"map_xianlingdao",
	"map_yandishennongdong",
	"map_xianmengzhucheng",
	"map_yuhangzhen",
	"map_zhucheng",
	'map_zuihuayin',


}

--是否是反向制作的map
local backWayMap = {
	"map_qionghuafeixu", "map_mojie","map_shushan",
	"map_huangshanshandao","map_xianlingdao","map_fengduguicheng"

}


local currentMapIndex
function MapControler:setNextMapId(isInit )
	--目前用自动按钮 测试场景

	if not  currentMapIndex then
		currentMapIndex = 1
	else
		if not isInit then
			currentMapIndex = currentMapIndex + 1
			if currentMapIndex > #sceneArr then
				currentMapIndex = 1
			end
		end
	end
	echo("changeMap :",sceneArr[currentMapIndex])
	self:setMapId(sceneArr[currentMapIndex] )
end


function MapControler:ctor(backCtn,frontCtn, mapId,isBattleMap)
  	index = index or 1
  	-- mapId = "map_pilitang"
  	-- mapId = "map_nanzhaoguo"
  	
  -- 	if table.indexof(backWayMap, mapId) == false then
		-- echoWarn("地图没有反向------")
		-- mapId = "map_qionghuafeixu"
  -- 	end
  	local mapCfgs = require("level.SceneMap")
 	if mapCfgs[mapId] then
 		self.mapMaxWidth = mapCfgs[mapId].width
 		echo("maxMaxWidth,",self.mapMaxWidth)
 	else
 		self.mapMaxWidth = GameVars.maxMapWidth 
 	end



  	--先判断场景是否存在
  	if not cc.FileUtils:getInstance():isFileExist("mapConfig/"..mapId..".lua") then
  		echoError("没有这个地图数据:%s,用map_qionghuafeixu代替",mapId)
  		mapId = "map_qionghuafeixu"
  	end

  	-- mapId =  "map_mojie"
	self.mapId =  mapId 
	

  	self.isBattleMap = isBattleMap
  	--如果不是战斗地图  那么需要再次反向
  	if not isBattleMap then
  		local tempBackNode = display.newNode():addto(backCtn)
  		tempBackNode:setScaleX(-1)

  		local tempFrontNode = display.newNode():addto(frontCtn)
  	  	tempFrontNode:setScaleX(-1)
  	  	local offsetX = GameVars.UIOffsetX + GameVars.gameResWidth
  	  	
  	  	tempBackNode:pos(GameVars.UIOffsetX + GameVars.gameResWidth  ,0)
  	  	tempFrontNode:pos(GameVars.UIOffsetX + GameVars.gameResWidth  ,0)

  	  	backCtn = tempBackNode
  	  	frontCtn = tempFrontNode

  	  	--重新二次反向场景
  	  	echo("___二次反向场景,场景id:",mapId)
  	else
  		-- 仙界对决地图不随Fight.cameraWay 翻转
  		if Fight.cameraWay == 1 then
  			local tempBackNode = display.newNode():addto(backCtn)
	  		tempBackNode:setScaleX(-1)

	  		local tempFrontNode = display.newNode():addto(frontCtn)
	  	  	tempFrontNode:setScaleX(-1)
	  	  	local offsetX = GameVars.UIOffsetX + GameVars.gameResWidth
	  	  	
	  	  	tempBackNode:pos(GameVars.UIOffsetX *2+ GameVars.gameResWidth  ,0)
	  	  	tempFrontNode:pos(GameVars.UIOffsetX*2 + GameVars.gameResWidth  ,0)

	  	  	backCtn = tempBackNode
	  	  	frontCtn = tempFrontNode
  		end
  		echo("战斗场景,场景id",mapId)
  	end

  	self.backCtn = backCtn
  	self.frontCtn = frontCtn

 	self.layerIndex = index
  
  	-- self:setNextMapId(true)

  	self:setMapId(mapId)

  	EventControler:addEventListener("mapchanged", self.onMapChanged,self)

  	return self
end

function MapControler:onMapChanged(  )
	self:setNextMapId()
end


function MapControler:setMapId(mapId  )
	if tolua.isnull(self.backCtn) then
		--说明自己已经被销毁了
		EventEx:clearOneObjEvent( self )
		return
	end
	--先清除当前的map
	self:clearCurrentMap()

	local backLayer = self.backCtn--self.controler.layer["a"..self.layerIndex.."1"]

	if disableMap then
		return
	end

	self.ctnArrObj = {}
	self.ctnPianyiObj = {}
	self.scaleCtnObj  = {}
	self.moveCtnObj = {}
	self.layerPosIndexObj = {}

	--local map = WindowsTools:createWindow("BattleMap"):addto(backLayer)
	local map = BattleMapTools:createWindow(mapId):addto(backLayer):pos(0,-GameVars.height)

	self.mapId = mapId
	self.map = map
	self.speed = map.speed
	self.ctnNameArr = map.ctnNameArr
	
	local landIndex = map.landIndex
	self.landIndex = landIndex
	if landIndex ==0 then
		landIndex = 99999
	end
	--给每一层需要包一层 用来缩放的
	local ctnBack = self.backCtn
	local ctnFront = self.frontCtn  

	self.moveWay = 1
	local scaleCtn = 1

	scaleCtn = -1

	-- if table.indexof(backWayMap,mapId) then
	-- 	scaleCtn = -1
	-- end

	if (self.isBattleMap) then
		self.moveWay = -1
	end


	for i,v in ipairs(self.ctnNameArr) do

		local scaleNode =  display.newNode()
		self.scaleCtnObj[v] = scaleNode

		local oldCtn = map[v]

		local px,py = oldCtn:getPosition()

		--记录偏移 
		self.ctnPianyiObj[v] = {px,py}

		--初始化存储oldCtn
		self.ctnArrObj[v] = {oldCtn}

		--运动层 addto  scale层
		local moveNode = display.newNode():pos(0,0)
		self.moveCtnObj[v] = moveNode
		scaleNode:addTo(moveNode)
		--原始层 addto  move层
		oldCtn:parent(scaleNode)

		if scaleCtn == -1 then
			local backNode = display.newNode()
			moveNode:addto(backNode)
			backNode:setScaleX(-1)
			-- backNode:setPositionX(1136)
			if i <= landIndex  then
				backNode:addto(ctnBack)
			else
				backNode:addto(ctnFront)
				moveNode.isFrontLayer = true
				scaleNode.isFrontLayer = true
			end
		else
			if i <= landIndex  then
				moveNode:addto(ctnBack)
			else
				moveNode:addto(ctnFront)
				moveNode.isFrontLayer = true
				scaleNode.isFrontLayer = true
			end

		end

		
	end
	self:updatePos(0,0)

	if self._targetScale then
		self:updateScale(self._targetScale, self._scalePos)
	end
end

--清除当前地形
function MapControler:clearCurrentMap(  )
	if self.map then
		for k,v in pairs(self.scaleCtnObj) do
			v:removeSelf()
		end

		self.map:deleteMe()
		self.map = nil

		self.layerPosIndexObj = nil
		--清除ctn数组
		self.ctnArrObj = nil
		self.scaleCtnObj = nil
		self.moveCtnObj = nil
		self.ctnPianyiObj = nil

	end
end

--获取某个layer的view
function MapControler:getOneLayerView(layerId,index  )
	--如果是还没创建 layer的 那么需要克隆一下
	if not self.ctnArrObj[layerId][index] then
		self:cloneOneLayer(layerId)
	end
	return self.ctnArrObj[layerId][index]
end

--给某个layer 设置坐标
function MapControler:setOneLayerPos(  )
	-- body
end

--根据坐标判断容器坐标
function MapControler:checkLayerPos( layerId,targetXpos )
	--如果都不够 基础长度
	-- if true then
	-- 	return
	-- end

	targetXpos = - targetXpos


	if targetXpos < baseSwitchPos then
		return
	end



	
	--判断坐标在哪个区间内
	local index = math.ceil( (targetXpos )  /oneScreenWidth )
	
	-- --如果区域相同不执行
	if self.layerPosIndexObj[layerId]== index then
		return
	end

	--目前是循环的 所有至多只需要2个layer 就可以了
	local layer1 =self:getOneLayerView(layerId,1)
	local layer2 =self:getOneLayerView(layerId,2)

	--判断当前应该在哪个循环层
	local layerIndex = math.ceil ( index /3  )
	
	

	local yushu = layerIndex % 2

	local layerPos = self.ctnPianyiObj[layerId]

	--如果是在当前屏幕的左半边 那么需要向左循环
	if targetXpos % threeScreenWidth < oneScreenWidth then
		
		--如果当前是落在a屏
		if yushu == 1 then
			--那么移动b屏幕
			layer1:pos( (layerIndex-1) * threeScreenWidth + layerPos[1],layerPos[2] )
			layer2:pos( (layerIndex-2) * threeScreenWidth+ layerPos[1],layerPos[2] )
		else
			--否则就是移动a屏
			layer2:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer1:pos( (layerIndex-2) * threeScreenWidth+ layerPos[1],layerPos[2] )
			
		end
	else
		--如果当前是落在a屏
		if yushu == 1 then
			--那么移动b屏幕
			layer1:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer2:pos( (layerIndex) * threeScreenWidth+ layerPos[1],layerPos[2] )
		else
			--否则就是移动a屏
			layer2:pos( (layerIndex-1) * threeScreenWidth+ layerPos[1],layerPos[2] )
			layer1:pos( (layerIndex) * threeScreenWidth+ layerPos[1],layerPos[2] )
		end
	end

	--echo(targetXpos,index,"________targetPosx",layerIndex, layer2:getPosition())
end

-- 复制某一层
function MapControler:cloneOneLayer( layerId )
	local uiDatas = self.map.__uiCfg

	local index =  table.indexof(self.ctnNameArr, layerId)
	if not index then
		error("错误的layerid",layerId) 	
	end 

	local layerData = uiDatas.ch[index]

	if not layerData then
		error("没有找到这个层数据,index:",index)
	end
	local moveCtn = self.moveCtnObj[layerId]


	--设置为场景url
	UIBaseDef:setResUrlMap(  )
	UIBaseDef:setDynamicName(self.map.__uiCfg.ex.fla)
	--克隆一层以后 就可以
	local nd = UIBaseDef:get_panel( layerData)
	--nd:visible(false)
	nd:parent(moveCtn)

	UIBaseDef:setDynamicName(nil)
	UIBaseDef:setResUrlUI(  )
	table.insert(self.ctnArrObj[layerId], nd) 
end


--让地形绕某点缩放
function MapControler:updateScale( resultScale,scalePos ,scaleY)
	if disableMap then
		return
	end
	scaleY = scaleY or resultScale

	-- if true then
	-- 	return
	-- end
	self._targetScale = resultScale
	self._scalePos = scalePos
	local xpos
	local ypos
	for i,v in pairs(self.speed) do
	    local sa = 1-  (1- resultScale)    * v 
	    local sy = 1- (1-scaleY) * v
        xpos = math.round( scalePos.x - scalePos.x * sa )
        ypos = math.round( scalePos.y - scalePos.y  * sy )
        -- echo(xpos,"___scaleXpos")
        local targetCtn =  self.scaleCtnObj[i] 
        targetCtn:pos(xpos* self.moveWay,-ypos)

        targetCtn:setScaleX(sa)
        targetCtn:setScaleY(sy)
	end
end

--抖动地图
function MapControler:shakeMap( x,y,sx,sy,tweenTime )
	self.frontCtn:visible(false)
	local xpos
	local ypos
	for i,v in pairs(self.speed) do
	    local sa = 1-  (1- sx)    * v 
	    local sy = 1- (1-sy) * v
        -- echo(xpos,"___scaleXpos")
        local targetCtn =  self.scaleCtnObj[i] 
        local targetX = x*v * self.moveWay
        local targetY = y *v
        if targetCtn.isFrontLayer then
        	sa  =1
        	sy = 1
        	targetY = 0
        end
        if tweenTime then
        	targetCtn:moveTo(tweenTime,targetX,targetY ) 
	        targetCtn:scaleTo(tweenTime,sa)
        else
        	targetCtn:pos(targetX,targetY)
	        targetCtn:setScaleX(sa)
	        targetCtn:setScaleY(sy)
        end
        
	end
end


--更新坐标
function MapControler:updatePos( posx,posy )
	if disableMap then
		return
	end
	local turnposx,turnposy
	-- if posx > 0 then
	-- 	posx = 0
	-- end
	posx = math.round(posx)

	for k,v in pairs(self.speed) do
		turnposx =  posx * v * self.moveWay
		turnposy =  posy * v --math.pow(v,0.5) 
		if self.moveCtnObj[k] then 

			if self.moveCtnObj[k].isFrontLayer then
				self.moveCtnObj[k]:pos(turnposx,0)
			else
				self.moveCtnObj[k]:pos(turnposx,turnposy)
			end

			-- self.moveCtnObj[k]:pos(turnposx,turnposy)
			--echo(table.indexof(k,"panel_land"),"---table.indexof",k)

			-- if string.find(k, "land") then
			-- 	self:checkLayerPos(k,turnposx)
			-- end
			if useRepeatMap then
				self:checkLayerPos(k,turnposx)
			end
			
			
		end
	end
end

-- 前景层的显示或隐藏
function MapControler:updateFrontLayer( b )
	self.frontCtn:visible(b)
end

-- mainlayer层
function MapControler:deleteMe(  )
	if disableMap then
		return
	end
	self:clearCurrentMap()
end



--是否是宽屏场景
function MapControler:isWidthMap(  )
	-- local widMapArr = {"map_fengduguicheng"}
	-- if table.indexof(widMapArr, self.mapId) then
	-- 	return true
	-- end
	-- return false
	return true
end

--获取地图的最大宽度
function MapControler:getMaxMapWidth(  )
	return self.mapMaxWidth
end