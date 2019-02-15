--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:37:38
--Description: 仙盟GVE活动
--Description: 煮菜界面
--


local GuildActivityCookingView = class("GuildActivityCookingView", UIBase);

function GuildActivityCookingView:ctor(winName)
    GuildActivityCookingView.super.ctor(self, winName)
end

function GuildActivityCookingView:loadUIComplete()
	-- if true then
	-- 	local v = "1,10101,20"
	-- 	local dataArr = string.split(v,",")
	-- 	local itemPath = FuncItem.getIconPathById(dataArr[2])
	-- 	itemPath = FuncRes.iconItemWithImage(itemPath)
	-- 	echo("________itemPath_______",itemPath)
	-- 	local num = dataArr[3]
	-- 	local text1 = "食神眷顾,锅里蹦出了["..itemPath.."]"..num
	-- 	WindowControler:showTips( { text = text1 },3 )	
	-- 	self.UI_1.btn_1:setTap(c_func(self.onClose, self))

	-- 	self:startHide()
	-- 	return
	-- end
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function GuildActivityCookingView:registerEvent()
	GuildActivityCookingView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.onClose, self))

	self:scheduleUpdateWithPriorityLua(c_func(self.continusPutMaterial, self),0);
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_INPUT_INGREDIENTS, self.onSomeoneInputIngredients, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end

function GuildActivityCookingView:onSomeoneInputIngredients( event )
 	if not event.params.data.ingredients then
 		return
 	end
	-- dump(event.params.data,"监听到 某人向大锅中投入了食材")
	-- dump(self.materialTOPanelX, "映射表", 3)

 	for materialId,v in pairs(event.params.data.useIngredients) do
 		local num1 = self.materialTOPanelX[materialId]

 		local data = GuildActMainModel:getGuildTotalIngredients(materialId)
		self:updateOneItemExpend( data,self.totalMaterialPanel["panel_rou"..num1],v )

		local data2 = GuildActMainModel:getCurHaveIngredients(materialId)
		self:updateOneItemRemain( data2,self.personalMaterialPanel["panel_yan"..num1] )

		-- 刷新食物星级
		self:reFreshFoodStar()
		
		-- 创建左侧滚动条信息
		local playerInfo = GuildModel:getMemberInfo(event.params.data.rid)
		local oneMessage ={
			playerName = playerInfo.name,
			materialNum = v,
			materialName = data.name,
		}
		self:updateMessageView(oneMessage)
 	end
end

function GuildActivityCookingView:onClose()
	self:unscheduleUpdate()
	self:startHide()
end


function GuildActivityCookingView:initData()
	-- 长按2秒结束时投入全部可投入食材
	self.putAllCanPutTimeLimit = 2

	self.materialTOPanelX = {}

	self.isLongPress = false --是否在长按期内

	self.messageDataList = self:getMessageRecords()
	self.currentMessageNum = #self.messageDataList
	-- dump(self.messageDataList, "打开界面 获取本地存储的信息_____ self.messageDataList ")
	-- echo("______信息条数 self.currentMessageNum _________ ",self.currentMessageNum)
end


function GuildActivityCookingView:initView()
	self.UI_1.panel_1:setVisible(false)
	self.UI_1.txt_1:setVisible(false)
	self.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_052")) 
	self.totalMaterialPanel = self.panel_1
	self.personalMaterialPanel = self.panel_2
	self.personalMaterialPanel.txt_xiang:visible(false)

	self.totalMaterialPanel:setTouchedFunc(c_func(self.showFoodStarReward,self,false))
	self.personalMaterialPanel:setTouchedFunc(c_func(self.showFoodStarReward,self,false))
	-- 显示食材
	local configMaterials = FuncGuildActivity.getFoodMaterial(GuildActMainModel:getCurFoodId())
	for k,v in pairs(configMaterials) do
		local materialId = v.id
		self.materialTOPanelX[materialId] = k
		-- 仙盟总食材
		local data = GuildActMainModel:getGuildTotalIngredients(materialId)
		self:updateOneItemExpend( data, self.totalMaterialPanel["panel_rou"..k])

		local itemId = FuncGuildActivity.getMaterialIcon(materialId)
		local itemPath = FuncRes.getFoodIcon(itemId)
		itemSprite = display.newSprite(itemPath):anchor(0.5,0.5)
		itemSprite:pos(0,0)
		itemSprite:setScale(1)
		self.totalMaterialPanel["panel_rou"..k].panel_chicai.ctn_1:removeAllChildren()
		self.totalMaterialPanel["panel_rou"..k].panel_chicai.ctn_1:addChild(itemSprite)

		-- 玩家收集到的食材
		-- 长按连续投入食材逻辑处理
		self.personalMaterialPanel["panel_yan"..k].mc_kuang:setTouchedFunc(
			c_func(self.onTouchMaterialEnd,self,materialId), nil, true, 
			c_func(self.onTouchMaterialBegin,self,materialId),
			c_func(self.onTouchMaterialMove,self,materialId),true,
			c_func(self.onTouchGlobalEnd,self,materialId)
		)
		data = GuildActMainModel:getCurHaveIngredients(materialId)
		self:updateOneItemRemain( data, self.personalMaterialPanel["panel_yan"..k])
		itemSprite2 = display.newSprite(itemPath):anchor(0.5,0.5)
		itemSprite2:pos(0,0)
		itemSprite2:setScale(1)
		self.personalMaterialPanel["panel_yan"..k].ctn_1:removeAllChildren()
		self.personalMaterialPanel["panel_yan"..k].ctn_1:addChild(itemSprite2)
	end

	-- 初始化动态显示显示投放食材信息滚动条
	self.messageRich1 = self.totalMaterialPanel.panel_tishi.rich_1
	self.messageScroll = self.totalMaterialPanel.panel_tishi.scroll_1
	self.messageRich1:setVisible(false)

	self:initFoodStarPanel(self.personalMaterialPanel.panel_foodStar)
	self.personalMaterialPanel.panel_foodStar:visible(false)
	-- self.personalMaterialPanel.panel_foodStar:registClickClose("out")
	self.personalMaterialPanel.btn_xiang:setTap(c_func(self.showFoodStarReward,self))
	self:reFreshFoodStar()

	self:initMessageScroll()
	self:updateMessageView()
	self:initEffect()
end

function GuildActivityCookingView:initFoodStarPanel(_panelView)
	local limit = tonumber(FuncGuildActivity.maxFoodStar) - 0 
	for i=1,limit do
		local data = FuncGuildActivity.getFoodLevelData( GuildActMainModel:getCurFoodId(),i )
		if data.foodLevelReward then
			dump(data.foodLevelReward, "desciption")
			local rewardNum = 0
			for k,v in pairs(data.foodLevelReward) do
				rewardNum = rewardNum + 1
				local rewardArr = string.split(v,",")
				local itemName = "nil"
				if #rewardArr == 2 then
 					itemName = FuncDataResource.getResName(rewardArr[#rewardArr - 1])
				else
					itemName = FuncItem.getItemName(rewardArr[#rewardArr - 1])
				end
				local itemNum = rewardArr[#rewardArr]
				local text = itemName.."X"..itemNum
				_panelView["panel_"..i]["txt_"..(rewardNum+1)]:setString(text)
			end
			if rewardNum < 2 then
				_panelView["panel_"..i]["txt_"..(rewardNum+2)]:visible(false)
			end
		end
	end
	_panelView.txt_1:setString(GameConfig.getLanguage("#tid_food_tip_3009"))
end
function GuildActivityCookingView:showFoodStarReward(showOrNot)
	echo("_______显示食物星级奖励浮窗_____________",self.isShow)
	self.isShow = not self.isShow
	if showOrNot == true or showOrNot == false then
		self.personalMaterialPanel.panel_foodStar:visible(showOrNot)
	else
		self.personalMaterialPanel.panel_foodStar:visible(self.isShow)
	end
end

function GuildActivityCookingView:initEffect( ... )
	local ctn_1 = self.panel_2.ctn_guo 
	local cookingAnimation = self:createUIArmature("UI_xianmenggve","UI_xianmenggve_guotexiao", ctn_1, true,GameVars.emptyFunc)
    cookingAnimation:startPlay(true)
end

function GuildActivityCookingView:reFreshFoodStar()
	local foodStar = GuildActMainModel:getFoodStar()
	echo("___________ 食物星级 ____________ ",foodStar)

	self.maxFoodStar = 5
	self.personalMaterialPanel.mc_star:showFrame(self.maxFoodStar)
	local currentView = self.personalMaterialPanel.mc_star:getCurFrameView()
	for i=1,self.maxFoodStar do
		if i <= foodStar then
			currentView["mc_"..i]:showFrame(1)
		else
			currentView["mc_"..i]:showFrame(2)
		end
	end
end

function GuildActivityCookingView:initMessageScroll()
	local function createMessageFunc( _messageData )
		local itemView = UIBaseDef:cloneOneView(self.messageRich1)

		local messageStr = "<color = 33CC00>【".._messageData.playerName.."】<->"
		messageStr = messageStr.."向锅中投入了"
		messageStr = messageStr.._messageData.materialNum.."两".._messageData.materialName	
		messageStr = messageStr..",味道似乎更奇妙了"	

		itemView:setString(messageStr)
		return itemView
	end

	self.messageListParams =  {
	   	data = nil,
        createFunc = createMessageFunc,
        perNums= 1,
        offsetX = 10,
        offsetY = 10,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x = 3.2,y =-50,width = 325,height = 50},
        perFrame = 1,
        cellWithGroup = 1
	}
end

-- 
function GuildActivityCookingView:buildMessageScrollParams( _oneMessage )
	-- dump(_oneMessage, "__________ _oneMessage —— ")
	if _oneMessage then
		self.currentMessageNum = self.currentMessageNum + 1
		table.insert(self.messageDataList, self.currentMessageNum, _oneMessage)
	end

	if self.currentMessageNum > 10 then
		self.currentMessageNum = self.currentMessageNum -1
		table.remove(self.messageDataList,1)
	end

	self:setMessageRecords(self.messageDataList)
	-- dump(self.messageDataList, "self.messageDataList", 5)
	local ListParams = {}
	if self.messageDataList and self.messageDataList then
		for k,v in ipairs(self.messageDataList) do
			local params = table.deepCopy(self.messageListParams)
			params.data = {v}
			ListParams[#ListParams + 1] = params
		end
	end
	return ListParams
end


function GuildActivityCookingView:setMessageRecords(_list)
	echo("\n\n\n\n___________ 记录投入食材信息到本地 ——————————————————————————")
	if (not LSChat:byNameGetTable(GuildActMainModel.messageName)) then
		LSChat:createTable(GuildActMainModel.messageName)
	end

	-- dump(_list, "存信息____", 5)
	if _list then
		_list = json.encode( _list ) 
		LSChat:setData(GuildActMainModel.messageName,"_list",_list)
	end
end
function GuildActivityCookingView:getMessageRecords()
	local listtable = LSChat:byNameGetTable(GuildActMainModel.messageName)
	if listtable ~= nil then
		local list = LSChat:getData(GuildActMainModel.messageName,"_list")
		if tostring(list) ~= "nil" then
			-- dump(_list, "LSChat:getallData._list_________ ", 5)
			local _list = json.decode( list ) 
			return _list
		end
	end
	return {}
end

-- 仙盟大锅内的食材
function GuildActivityCookingView:updateOneItemExpend( _materialData,_itemView,_inPutNum )
	local materialName = FuncGuildActivity.getMaterialName(_materialData.id)
	materialName = GameConfig.getLanguage(materialName)

	local progress = _itemView.panel_progress.progress_1
    local percent = _materialData.curNum / _materialData.maxNum * 100
    progress:setDirection(ProgressBar.l_r)
    progress:setPercent(percent)
    _itemView.panel_progress.txt_1:setString(_materialData.curNum.."/".._materialData.maxNum)

    local numStatus = FuncGuildActivity.getMaterialNumStatus( percent )
    materialName= materialName --.." —— "..numStatus
	_itemView.txt_1:setString(materialName)
	if _inPutNum then
		_itemView.panel_50:setVisible(true) 
		_itemView.panel_50.txt_1:setString("+".._inPutNum) 
		-- 闪现临时 “动画”
		local function setInvisible( ... )
			_itemView.panel_50:setVisible(false) 
		end
		self:delayCall(c_func(setInvisible), 0.5)		
	else
		_itemView.panel_50:setVisible(false) 
	end
end
 
-- 玩家当前剩余食材
function GuildActivityCookingView:updateOneItemRemain( _materialData,_itemView )
	-- 更新选中效果
	if not self.lastMaterialId then
		local num1 = self.materialTOPanelX[_materialData.id]
		self.personalMaterialPanel["panel_yan"..num1].panel_1:setVisible(false)
	end

	local canPutInMaxNum = FuncGuildActivity.getMaterialCanPutInMaxNum(_materialData.id)
	local havePutInData = GuildActMainModel:getHavePutInIngredient( _materialData.id )
	local text = "("..havePutInData.curNum.."/"..canPutInMaxNum..")"

	local isShow = GuildActMainModel:isShowOneMaterialRedPoint( _materialData.id )
	if self.lastMaterialId ==  _materialData.id then
		isShow = false
	end
	_itemView.panel_red:setVisible(isShow)

	local materialName = FuncGuildActivity.getMaterialName(_materialData.id)
	materialName = GameConfig.getLanguage(materialName)
	_itemView.txt_1:setString(materialName..text)
	_itemView.txt_2:setString(_materialData.curNum)
end

--[[
	更新素材的剩余数量
]]
function GuildActivityCookingView:updateMaterialLeftNum(materialId,putInNum)
	local num = self.materialTOPanelX[materialId]
	local itemView = self.personalMaterialPanel["panel_yan"..num]
	
	local leftNum = self.currentMaterialData.curNum - putInNum
	if leftNum < 0 then
		leftNum = 0
	end

	itemView.txt_2:setString(leftNum)
end

function GuildActivityCookingView:initViewAlign()
	-- TODO
end

function GuildActivityCookingView:updateMessageView(_oneMessage)
	local messageData = self:buildMessageScrollParams(_oneMessage)
	-- dump(messageData, "desciption")
	if messageData and (not table.isEmpty(messageData)) then
		-- self.messageScroll:cancleCacheView()
		self.messageScroll:hideDragBar()
	    self.messageScroll:styleFill(messageData)
  		self.messageScroll:gotoTargetPos(self.currentMessageNum, 1, 2, 0)		
	end
end

--====================================================================================
-- 长按食材连续投入锅处理逻辑
--====================================================================================
function GuildActivityCookingView:onTouchMaterialBegin( _materialId,event )
	echo("点击开始__",_materialId)
	self:showFoodStarReward(false) -- 隐藏掉星级奖励小panel

	self.currentMaterialId = _materialId
	if self.lastMaterialId then
		local num1 = self.materialTOPanelX[self.lastMaterialId]
		self.personalMaterialPanel["panel_yan"..num1].panel_1:setVisible(false)
		local isShow = GuildActMainModel:isShowOneMaterialRedPoint(self.lastMaterialId )
		self.personalMaterialPanel["panel_yan"..num1].panel_red:setVisible(isShow)	
	end
	local num1 = self.materialTOPanelX[self.currentMaterialId]
	self.personalMaterialPanel["panel_yan"..num1].panel_1:setVisible(true)	
	self.personalMaterialPanel["panel_yan"..num1].panel_red:setVisible(false)	

	self.currentMaterialData = GuildActMainModel:getCurHaveIngredients(self.currentMaterialId)
	self.isLongPress = true 
	self.frameCount = 1 
	self.putInNum = 0 
end
function GuildActivityCookingView:onTouchMaterialMove( _materialId,event )
	echo("点击移动__", _materialId)
	self.currentMaterialId = _materialId
	self.isLongPress = false
end
function GuildActivityCookingView:onTouchMaterialEnd( _materialId,event )
	echo("点击结束__", _materialId)
	self.currentMaterialId = _materialId
	self.isLongPress = false
end
function GuildActivityCookingView:onTouchGlobalEnd( _materialId,event )
	echo("\n点击 全局结束__",_materialId )
	self.currentMaterialId = _materialId
	self.isLongPress = false
	self.hasPopupTips = false

	local materialName = FuncGuildActivity.getMaterialName(_materialId)
	materialName = GameConfig.getLanguage(materialName)
	echo("\n_______ 全局结束投入 食材 数量 ______ = ",materialName,self.putInNum)
	-- 长按3秒全部可投入食材投入锅

	local stillCanPutInNum = self:getCanPutInMaxNum(_materialId)
	-- echo("stillCanPutInNum======",stillCanPutInNum)
	-- echo("self.frameCount=",self.frameCount)
	local maxFrame = GameVars.GAMEFRAMERATE*self.putAllCanPutTimeLimit
	if self.frameCount >= maxFrame then
		self.putInNum = stillCanPutInNum
	end

	-- echo("self.putInNum===",self.putInNum)

	-- 更新剩余数量
	self:updateMaterialLeftNum(self.currentMaterialId,self.putInNum)

	local customMaterialId = self.currentMaterialId

	if self.putInNum ~= 0 then
		local itemArr = {}
		itemArr[_materialId] = self.putInNum

		local function callbackFunc( serverData )
			if serverData.error then
				-- 更新剩余数量
				echo("customMaterialId=",customMaterialId)
				self:updateMaterialLeftNum(customMaterialId,0)
				return
			end

			if FuncGuildActivity.isDebug then
				dump(serverData.result.data, "投入食材服务器返回=====")
			end
			
			local data = serverData.result.data
			if data and data.rewards and table.length(data.rewards) then
				FuncCommUI.startRewardView(data.rewards)
				-- for k,v in pairs(data.rewards) do
				-- 	local dataArr = string.split(v,",")
				-- 	local itemPath = FuncItem.getIconPathById(dataArr[2])
				-- 	echo("________itemPath_______",itemPath)
				-- 	local num = dataArr[2]
				-- 	local text1 = "食神眷顾,锅里蹦出了["..itemPath.."]"..num
				-- 	WindowControler:showTips( { text = text1 },3 )
				-- end
			end
		end

		-- 发送投入食材请求
		-- GuildActivityServer:putInMaterials(_guildId,_foodItems,_callBack)
		GuildActivityServer:putInMaterials(UserModel:guildId(),itemArr,c_func(callbackFunc))
	end
end

-- function GuildActivityCookingView:randomGetReward( serverData )
-- 	dump(serverData.params, "投入食材服务器返回=====")
-- end
function GuildActivityCookingView:continusPutMaterial( ... )
	if self.isLongPress ==  false then
		if self.currentMaterialId then
			local num1 = self.materialTOPanelX[self.currentMaterialId]
			-- self.totalMaterialPanel["panel_rou"..num1].panel_50:setVisible(false) 
			self.lastMaterialId = self.currentMaterialId	
			self.currentMaterialId = nil
		end
		return
	end

	-- 食材入锅特效
	-- 左边食材数量增加
	-- 左下实时刷新投入食材的玩家
	-- 下边显示玩家食材数量的变化
	local stillCanPutInNum = self:getCanPutInMaxNum( self.currentMaterialId )
	if self.putInNum >= stillCanPutInNum then
		return
	end

	-- 按住时间达到最大时间，将素材全部投入进去
	local maxFrame = GameVars.GAMEFRAMERATE*self.putAllCanPutTimeLimit
	if self.frameCount >= maxFrame then
		self.putInNum = stillCanPutInNum
	end

	-- 每3帧放入一个食材
	local framePerPutIn = 3
	if (self.isLongPress ==  true) and (self.frameCount % framePerPutIn == 0) then
		local data = GuildActMainModel:getGuildTotalIngredients(self.currentMaterialId)
		if self.putInNum >= self.currentMaterialData.curNum then
			if not self.hasPopupTips then
				WindowControler:showTips( GameConfig.getLanguage("#tid_guild_053"))
				self.hasPopupTips = true
			end
		elseif (self.putInNum + data.curNum) >= data.maxNum then 
			if not self.hasPopupTips then
				WindowControler:showTips( GameConfig.getLanguage("#tid_guild_054"))
				self.hasPopupTips = true
			end
		elseif (self.putInNum ) >= stillCanPutInNum then
			if not self.hasPopupTips then
				WindowControler:showTips( GameConfig.getLanguage("#tid_guild_055"))
				self.hasPopupTips = true
			end
		else
			self.putInNum = self.putInNum + 1
			local name = "UI_xianmenggve_toushi1"
			local left = false
			local num1 = self.materialTOPanelX[self.currentMaterialId]
			if num1 == 1 or num1 == 5 then
				name = "UI_xianmenggve_toushi1"
				if num1 == 5 then
					left = true 
				end
			elseif num1 == 2 or num1 == 4 then
				name = "UI_xianmenggve_toushi2"
				if num1 == 4 then
					left = true 
				end
			else
				name = "UI_xianmenggve_toushi3"
			end
		
			local ctn_1 = self.personalMaterialPanel["panel_yan"..num1].ctn_1
			if not self._flyAnimation then
				self._flyAnimation = {}
			end
			if not self._flyAnimation[num1] then
				self._flyAnimation[num1] = {}
				-- self._flyAnimation[num1] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				self._flyAnimation[num1][1] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				self._flyAnimation[num1][2] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				self._flyAnimation[num1][3] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				self._flyAnimation[num1][4] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				self._flyAnimation[num1][5] = self:createUIArmature("UI_xianmenggve",name, ctn_1, false,GameVars.emptyFunc)
				if (num1 == 4 or num1 == 5) then
					self._flyAnimation[num1][1]:setScaleX(-1)
					self._flyAnimation[num1][2]:setScaleX(-1)
					self._flyAnimation[num1][3]:setScaleX(-1)
					self._flyAnimation[num1][4]:setScaleX(-1)
					self._flyAnimation[num1][5]:setScaleX(-1)
				end
			end

			self.playSpeed = 3 * GameVars.GAMEFRAMERATE /30
			if not self._curIndex then
				self._curIndex = {}
			end
			if not self._curIndex[num1] then
				self._curIndex[num1] = 1
			end 
			self._curIndex[num1] = (self._curIndex[num1] + 1)%6 
			if self._curIndex[num1] == 0 then
				self._curIndex[num1] = 1
			end
			FuncArmature.setArmaturePlaySpeed(self._flyAnimation[num1][self._curIndex[num1]],self.playSpeed)
		    self._flyAnimation[num1][self._curIndex[num1]]:startPlay(false,true)
			echo("投入食材---",self.currentMaterialId,num1)
		end
	end 

	self.frameCount = self.frameCount + 1;
	-- 更新剩余数量
	self:updateMaterialLeftNum(self.currentMaterialId,self.putInNum)
end

function GuildActivityCookingView:getCanPutInMaxNum( _materialId )
	local wholeGuildData = GuildActMainModel:getGuildTotalIngredients(_materialId)
	local stillCanPutInNum = wholeGuildData.maxNum - wholeGuildData.curNum 
	local havePutInData = GuildActMainModel:getHavePutInIngredient(_materialId)
	local stillCanPutInNum2 = havePutInData.maxNum - havePutInData.curNum 
	if stillCanPutInNum2 < stillCanPutInNum then
		stillCanPutInNum = stillCanPutInNum2
	end
	local playerOwnData = GuildActMainModel:getCurHaveIngredients(_materialId)
	local playerOwnNum = 0
	if playerOwnData then
		playerOwnNum = playerOwnData.curNum 
	end
	if playerOwnNum < stillCanPutInNum then
		stillCanPutInNum = playerOwnNum
	end
	return stillCanPutInNum
end

function GuildActivityCookingView:deleteMe()
	GuildActivityCookingView.super.deleteMe(self);
end

return GuildActivityCookingView;
