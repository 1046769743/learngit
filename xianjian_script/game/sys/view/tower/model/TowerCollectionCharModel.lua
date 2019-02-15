--
--Author:      zhuguangyuan
--DateTime:    2018-04-04 17:48:56
--Description: 搜刮场景主角Model
--


local TowerMoveModel = require("game.sys.view.tower.model.TowerMoveModel")
TowerCollectionCharModel = class("TowerCollectionCharModel",TowerMoveModel)

function TowerCollectionCharModel:ctor()
	TowerCollectionCharModel.super.ctor(self)
	
	--方位对应的动作 左边是动作,右边是sc
	self.charRunFaceAction = {
        --右 
        {"run",1,},
        -- 右上
        {"run",1},
        -- 左上
        {"run",-1},
        -- 左
        {"run",-1},
        -- 左下
        {"run",-1},  
        --右下
        {"run",1},
    }

   self.charStandFaceAction = {
        --右 
        {"stand",1,},
        -- 右上
        {"stand",1},
        -- 左上
        {"stand",-1},
        -- 左
        {"stand",-1},
        -- 左下
        {"stand",-1},  
        --右下
        {"stand",1},
    }

	self.mySize = {width = 180,height = 180}
    self.charMovingSpeed = 3  -- 主角移动速度

    self.numToActionMap = {
		"playEmotionFoundBox",
		"playEmotionSweat",
		"playEmotionAttack",
	}
end

function TowerCollectionCharModel:registerEvent()
	TowerCollectionCharModel.super.registerEvent(self)
end

function TowerCollectionCharModel:initView(...)
	TowerCollectionCharModel.super.initView(self,...)
	-- 默认站立朝向
	self:mapViewAction(160)
	self:setClickFunc()
end

-- 每帧刷新
function TowerCollectionCharModel:dummyFrame()
end

function TowerCollectionCharModel:moveToPoint(targetPoint, speed,moveType )
	-- echoError("_______ 移动 _______________")
	local collectStatus = TowerMainModel:getCollectionStatus()
	if collectStatus ~= FuncTower.COLLECTION_STATUS.COLLECTING then 
		echo("_________ 嘿嘿嘿 ,站住@!")
		self:rePlayAction(false)
		self:setIsCharMoving(false)
		return
	end
	TowerCollectionCharModel.super.moveToPoint(self,targetPoint, speed,moveType)
	--映射view的视图
	self:mapViewAction(self.angle)
	self:rePlayAction(true)
end

function TowerCollectionCharModel:isCharMoving()
	return self.isMoving
end

function TowerCollectionCharModel:setIsCharMoving(isMoving)
	self.isMoving = isMoving
end

-- 当主角移动到了目标点
function TowerCollectionCharModel:onMoveToPointCallBack(isEnd)
	if isEnd then
		self:rePlayAction(false)
		self:setIsCharMoving(false)
	end

	if not self.toPlayEmotion then
		self.toPlayEmotion = 2
	end

	local collectStatus = TowerMainModel:getCollectionStatus()
	if collectStatus == FuncTower.COLLECTION_STATUS.COLLECTING then 
		if self.toPlayEmotion == 1 then
			local function callBack()
				-- echo("______zheli 111__________")
				self:moveToPoint({x= math.random(-230,-200),y=math.random(-70,10)}, self.charMovingSpeed)
				self.toPlayEmotion = self.toPlayEmotion + 1
			end
			local index = math.random(1,3)
			self[self.numToActionMap[index]](self,callBack)
		elseif self.toPlayEmotion == 2 then
			-- echo("______zheli 222 __________")
			self:moveToPoint({x= math.random(0,10),y= math.random(-70,10)}, self.charMovingSpeed)
			self.toPlayEmotion = self.toPlayEmotion + 1
		elseif self.toPlayEmotion == 3 then
			-- echo("______zheli 333 __________")
			self:moveToPoint({x= math.random(-60,-40),y= math.random(-70,10)}, self.charMovingSpeed)
			self.toPlayEmotion = self.toPlayEmotion + 1
			self.toPlayEmotion = 1
		end
	else
		self.toPlayEmotion = 2
		self:rePlayAction(false)
		self:setIsCharMoving(false)
	end
end

function TowerCollectionCharModel:resetIsPlayEmotion()
	self.toPlayEmotion = 2
end
function TowerCollectionCharModel:playEmotion( ... )

end

-- 播放找到宝箱动画
function TowerCollectionCharModel:playEmotionFoundBox(_callBack)
	self.aniFoundBox:visible(true)
	self.aniFoundBox:gotoAndPlay(0)
	local function callBack( ... )
		self.excellentBoy:visible(true)
		self.excellentBoy:gotoAndPlay(0)
		self.excellentBoy:doByLastFrame( false, true ,_callBack)

	end
	self.aniFoundBox:delayCall( c_func(callBack),3/GameVars.GAMEFRAMERATE)
	self.aniFoundBox:doByLastFrame( false, true ,GameVars.emptyFunc)
end

function TowerCollectionCharModel:playEmotionSweat(_callBack)
	self.aniSweat:visible(true)
	self.aniSweat:gotoAndPlay(0)
	self.aniSweat:doByLastFrame( false, true ,_callBack)
end

function TowerCollectionCharModel:playEmotionAttack(_callBack)
	local index = math.random(1,#self.allTargetMonsters)
	self.monsterSpine[index]:visible(true)
	local sourceData  
	if self.sourceId ~= GarmentModel:getGarmentSourcrId() then
		self.sourceId = GarmentModel:getGarmentSourcrId()
		sourceData = FuncTreasure.getSourceDataById(self.sourceId)
		self.actionLabel = sourceData.attack2
	end
	self.myView:playLabel(self.actionLabel)
	self.monsterSpine[index]:playLabel(Fight.actions.action_attack2) 
	local totalFrames = self.myView:getLabelFrames(self.actionLabel)
	local function monsterDie()
		self.monsterDieAni:visible(true)
		self.monsterDieAni:gotoAndPlay(0)
		self.monsterDieAni:doByLastFrame( false, true ,function ()
			self.monsterSpine[index]:visible(false)
			if _callBack then
				_callBack()
			end
		end)
	end
	self.myView:delayCall(monsterDie, totalFrames/GameVars.GAMEFRAMERATE )
end

-- 创建动画
function TowerCollectionCharModel:createAllAni( collectionView )
	if not self.aniFoundBox then
		self.excellentBoy = collectionView:createUIArmature("UI_lihuibiaoqing", "UI_lihuibiaoqing_jing",self.myView, true, GameVars.emptyFunc)
		self.excellentBoy:pos(0,self.mySize.height)
		self.excellentBoy:visible(false)
		self.excellentBoy:scale(0.7)

		self.aniFoundBox = collectionView:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_baoxiang",self.myView, true, GameVars.emptyFunc)
		self.aniFoundBox:pos(-60,0):zorder(-10)
		self.aniFoundBox:visible(false)
		self.aniFoundBox:scale(0.7)
	end

	if not self.aniSweat then
		self.aniSweat = collectionView:createUIArmature("UI_lihuibiaoqing", "UI_lihuibiaoqing_hanyan",self.myView, true, GameVars.emptyFunc)
		self.aniSweat:pos(0,self.mySize.height)
		self.aniSweat:scale(0.7)
		self.aniSweat:visible(false)
	end

	-- 播放怪死亡动画
	if not self.monsterDieAni then
		self.monsterDieAni = collectionView:createUIArmature("UI_suoyaota","UI_suoyaota_guaiwuxiaoshi", self.myView, true, GameVars.emptyFunc)
		self.monsterDieAni:pos(-110,30)
		self.monsterDieAni:setVisible(false)
		self.monsterDieAni:scale(0.7)
		self.monsterDieAni:zorder(-10)
	end

	if self.collectionFloor ~= TowerMainModel:getCollectionFloor() then
		self.monsterSpine = {}
		self.collectionFloor = TowerMainModel:getCollectionFloor()
		local collectionData = FuncTower.getCollectionDataByID(self.collectionFloor)
		self.allTargetMonsters = collectionData.monsterId
		for k,monsterId in pairs(self.allTargetMonsters) do
			local sourceCfg = FuncTreasure.getSourceDataById(monsterId)
			local spineName = sourceCfg.spine
			self.monsterSpine[tonumber(k)] = ViewSpine.new(spineName,{},spineName):addto(self.myView):pos(-110,0)
			self.monsterSpine[tonumber(k)]:scale(0.7)
			self.monsterSpine[tonumber(k)]:playLabel("stand",true)
			self.monsterSpine[tonumber(k)]:zorder(-20)
			self.monsterSpine[tonumber(k)]:visible(false)
		end
	end 
end

-- 修正主角朝向
function TowerCollectionCharModel:adjustViewAction()
	-- local clickGridModel = self.controler.clickedGridModel

	-- if clickGridModel ~= nil and clickGridModel ~= self.gridModel then
	-- 	local targetPoint = clickGridModel.pos
	-- 	local ang = self:calAngle(targetPoint)
	-- 	self:mapViewAction(ang)
	-- end
end

function TowerCollectionCharModel:setClickFunc( )
	local nd = display.newNode()
	
	--[[
	-- 测试代码
	local color = color or cc.c4b(255,0,0,120)
  	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(cc.size(self.charWidth,self.charHeight) )
	]]
    nd:setContentSize(self.mySize)
    nd:pos(-self.mySize.width / 2,self.mySize.height / 2)
	
	-- nd:setContentSize(cc.size(figure,figure) )
	nd:addto(self.myView,1)
	-- nd:setTouchedFunc(c_func(self.onClickChar,self),nil,true)
end

function TowerCollectionCharModel:onClickChar(  )
	echo("点击了主角")
end

--根据角色map方位 rotation 是 角度 不是弧度
function TowerCollectionCharModel:mapViewAction( ang )
	-- ang  是-180 到+180之间的数 就是 math.atan2(dy,dx) * 180 /math.pi
    -- local index = math.ceil( (ang +180) / 60)
    local index = self:getActionIndex(ang)

    -- echo("_____ang",index,ang,ang - 180)

    if index > #self.charStandFaceAction then
        index = #self.charStandFaceAction
    end
    if index < 1 then
        index = 1
    end
    
    local action = nil
    local scaleX = 1
    action = self.charStandFaceAction[index][1]
	scaleX = self.charStandFaceAction[index][2]

    self.myView.currentAni:setScaleX(scaleX * self.viewScale)
    self.myView:playLabel(action)

    --当前动作标签
 	self.label = action
 	-- echo("________mapViewAction self.label___________",self.label)
 	--当前方位 只分左右
 	self.way = scaleX
 	--当前角度
 	self.rotation = ang

 	self.charFace = action
 	self.charScaleX = scaleX
    self.index = index
end

function TowerCollectionCharModel:rePlayAction(isMoving)
	-- 设置为站立动作
	-- echoWarn("__________ 执行 rePlayAction,__________________",isMoving)
	local action = self.charStandFaceAction[self.index][1]
	local faceActinArr = nil

	if isMoving then
		faceActinArr = self.charRunFaceAction
	else
		faceActinArr = self.charStandFaceAction
	end

	action = faceActinArr[self.index][1]
	-- echo("___________执行动作  action ______________",action,self.zorder)
	scaleX = faceActinArr[self.index][2]

	self.myView.currentAni:setScaleX(scaleX * self.viewScale)
    self.myView:playLabel(action)
end

function TowerCollectionCharModel:getActionIndex(ang)
	local index = nil
	-- 角度做一个修正，解决坐上/下角度刚好超过边界值的问题
	local offset = -1
	ang = ang + offset
	if ang >=-30 and ang <=30 then
		index = 1
	elseif ang >30 and ang <=90 then
		index = 2
	elseif ang >90 and ang <=150 then
		index = 3
	elseif ang >150 or ang <-150 then
		index = 4
	elseif ang >-150 and ang <=-90 then
		index = 5
	elseif ang >-90 and ang <=-30 then
		index = 6
	end

	return index
end

return TowerCollectionCharModel
