-- BarrageMainView
-- Aouth wk
-- time 2018/1/30

local BarrageMainView = class("BarrageMainView", UIBase);

local linehight = 30  --默认一行高 30像素
function BarrageMainView:ctor(winName)
    BarrageMainView.super.ctor(self, winName);
end

function BarrageMainView:loadUIComplete()
	self.UI_1:setVisible(false)
	self:addLayer()
	self.random = nil

end 

function BarrageMainView:registerEvent()
	if self.system == FuncBarrage.SystemType.crosspeak then 
		EventControler:addEventListener("notify_chat_private_3516",self.upUIdata,self);
	elseif self.system == FuncBarrage.SystemType.tower then
		EventControler:addEventListener(BarrageEvent.COMMENTS_TO_BARRAGE_UI,self.upUIdata,self);
		EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE,self.getNextTowerRankData, self)
		EventControler:addEventListener(BarrageEvent.BARRAGE_RANK_COMMENT_UI_EVENT,self.getTowerNewAllData,self);
	elseif self.system == FuncBarrage.SystemType.world or self.system == FuncBarrage.SystemType.guild then
		EventControler:addEventListener("notify_chat_world_3512",self.worldData,self);
	    EventControler:addEventListener("notify_chat_league_3514",self.guildData,self);
		EventControler:addEventListener("notify_chat_system_3520",self.systemData,self);
		EventControler:addEventListener("notify_chat_love_3528",self.requestLoveMessage,self);
		EventControler:addEventListener(BarrageEvent.BARRAGE_LOVE_SYSTEM_DATA,self.notifyrequestLoveMessage,self);
		
		EventControler:addEventListener(BarrageEvent.BARRAGE_CHAT_SET_SHOW_EVENT,self.showWorldBarrage,self);
		
	elseif self.system == FuncBarrage.SystemType.plot then
		EventControler:addEventListener(BarrageEvent.BARRAGE_PLOT_EVENT,self.setplotData,self);
		EventControler:addEventListener(BarrageEvent.BARRAGE_SEND_PLOT_MYSELF_EVENT,self.setMyselfPlotData,self);
		
		EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP ,self.onUIShowComp,self)
		EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP,self.onShowComp,self)
	end
	
	
	EventControler:addEventListener(BarrageEvent.BARRAGE_UI_IS_SHOW,self.showCell,self);
	EventControler:addEventListener(BarrageEvent.BARRAGE_UI_IS_NOT_SHOW,self.notShowCell,self);
	EventControler:addEventListener(BarrageEvent.BARRAGE_REMVOE_VOICE_UI,self.removeVoiceUI,self);

end

function BarrageMainView:removeVoiceUI()
	local view  = self:getChildByName("barrageVoiceView")
	if view then
		view:removeChildByName("barrageVoiceView", true)
	end

end



function BarrageMainView:onShowComp()

	-- if self.system == FuncBarrage.SystemType.world then
	-- 	local arr = self:getViewName()
	-- 	for k,v in pairs(arr) do
	-- 		local view = WindowControler:getWindow(v)
	-- 		if view then
	-- 			return 
	-- 		end
	-- 	end
	-- 	BarrageControler:showBarrageView(true)
	-- else
	if self.system == FuncBarrage.SystemType.plot then
		local view = WindowControler:getWindow( "PlotDialogView" )
		if view then
			self.btn_danmu:setVisible(true)
		end
	end
end

function BarrageMainView:getViewName()
	local arr = {"PlotDialogView","BattleCrossPeakView","TowerMapView"}
	return arr
end

function BarrageMainView:onUIShowComp(e)
	local view = WindowControler:checkCurrentViewName( "AnimDialogView" )
	if not view then
		local view = WindowControler:getWindow( "PlotDialogView" )
		if not view then
			self.btn_danmu:setVisible(false)
		else
			self.btn_danmu:setVisible(true)
		end
	else
		self.btn_danmu:setVisible(true)
	end
end

function BarrageMainView:getTowerNewAllData()
	local  alldata = BarrageModel:gettowerCommentData()
	-- dump(alldata,"22222222222222222")
	if #alldata ~= #self.allData then
		self.allData = alldata
	end
end

function BarrageMainView:getNextTowerRankData()
	
	local function callback()
		local  alldata = BarrageModel:gettowerCommentData()
		-- dump(alldata,"锁妖塔下一层的数据")
		self.cellArr = {}  ---存放弹幕
		self.saveMoveCell = {}  ---存放移出界面外的弹幕
		self.indexdata = 1
		self.allData = alldata  --所有数据
		self.moveNode:removeAllChildren()
		self:createCellView(self.indexdata)  --先创建一个弹幕
	end
	BarrageModel:getNextTowerRankData(callback)
end


function BarrageMainView:showWorldBarrage()
	local showArr = {}
	for k,v in pairs(FuncChat.Chat_Set_Type) do
		showArr[k] = ChatModel:getSetBarrageShow(v)
	end
	if self.cellArr ~= nil then
		for k,v in pairs(self.cellArr) do
			if v.view.colorful ~= nil then
				if showArr[v.view.colorful] then
					v.view:setVisible(true)
				else
					v.view:setVisible(false)
				end
			end
		end
	end

end

--显示弹幕
function BarrageMainView:showCell()
	-- if self.cellArr ~= nil then
	-- 	for k,v in pairs(self.cellArr) do
	-- 		v:setVisible(true)
	-- 	end
	-- end
	if self.moveNode then
		self.moveNode:setVisible(true)
	end
end

--不显示弹幕
function BarrageMainView:notShowCell()
	-- if self.cellArr ~= nil then
		-- for k,v in pairs(self.cellArr) do
		-- 	v:setVisible(false)
		-- end
	-- end
	if self.moveNode then
		self.moveNode:setVisible(false)
	end
end


function BarrageMainView:addLayer()
	if self.moveNode == nil then
		self.moveNode = display.newNode() ---FuncRes.a_white()-- 170*4,36*9.5)
	    self.moveNode:anchor(cc.p(0,1))
	    self.moveNode:setPosition(cc.p(- GameVars.UIOffsetX,0))
	    self:addChild(self.moveNode,10)
	end
end

function BarrageMainView:setNodePos(pos)
	if self.moveNode ~= nil then
		local x = pos.x or 0
		local y = pos.y or 0
		self.moveNode:setPosition(cc.p(- GameVars.UIOffsetX + x, - y ))
	end
end


--[[
	local arrPame = {
		system = FuncBarrage.SystemType.plot,  --系统参数
		btnPos = {x = ,y = }  --弹幕按钮的位置
		barrageCellPos = {x = ,y =}, 弹幕区域的位置
		addview = ,--索要添加的视图
	}
 ]]

--根据系统名来判断是否显示弹幕
 function BarrageMainView:bySystemShowBarrage(system)
 	if system == FuncBarrage.SystemType.crosspeak then
 		local _type = FuncBarrage.BarrageSystemName.crossPeak
		local isshow = BarrageModel:getIsShowByType( _type )
		self:showbarrage(isshow)
	elseif system == FuncBarrage.SystemType.plot then
		local _type = FuncBarrage.BarrageSystemName.plot
		local isshow = BarrageModel:getIsShowByType( _type )
		self:showbarrage(isshow)
	elseif system == FuncBarrage.SystemType.tower then
		local _type = FuncBarrage.BarrageSystemName.comments
		local isshow = BarrageModel:getIsShowByType( _type )
		self:showbarrage(isshow)
	elseif system == FuncBarrage.SystemType.world then



	end

 end

 --是否显示弹幕
 function BarrageMainView:showbarrage(isshow)
 	if isshow then
 		self:showCell()
 	else
 		self:notShowCell()
 	end
 end

--初始化数据
function BarrageMainView:initData(arrPame,allData)

	-- dump(allData,"====显示弹幕发送界面的数据===")
	self.cellArr = {}  ---存放弹幕
	self.saveMoveCell = {}  ---存放移出界面外的弹幕
	self.arrPame = arrPame
	self.system = arrPame.system
	self.allData = allData  --所有数据
	if self.arrPame.plotData then
		self.plotID = self.arrPame.plotData[1]
		self.plotOrid = 1
	end
	self.linenum = FuncBarrage.getBarrageRowsNum(self.system)
	self.intervalTime = FuncBarrage.getBarrageTimeInterval(self.system) --间隔时间
	self.speed = {}  -- FuncBarrage.getBarrageSpeed(self.system)  测试

	if self.system == FuncBarrage.SystemType.crosspeak then
		self.btn_danmu:setTouchedFunc(c_func(self.showBarrageButton, self),nil,true);
	elseif self.system == FuncBarrage.SystemType.world then
	elseif self.system == FuncBarrage.SystemType.guild then
		-- self.random = math.random(1,2)
	elseif self.system == FuncBarrage.SystemType.plot then
		self.arrPame.plotData.plotID = arrPame.plotData[1]
		self.arrPame.plotData.order = 1
		self.btn_danmu:setTouchedFunc(c_func(self.showBarrageButton, self),nil,true);
		self.allData = BarrageModel:getPlotData(self.allData,self.arrPame)
	end
	-- dump(self.allData,"初始化聊天的数据 ====")
	self:bySystemShowBarrage(self.system)

	local sumhight = linehight * self.linenum  ---总高度
	self.barrageType = FuncBarrage.getBarrageType(self.system)
	self.index = 1
	self.indexdata = 1
	self.cellIndex = nil
	self:createCellView(self.indexdata)  --先创建一个弹幕
	self:addFrameScheduleUpdate()
	self:registerEvent();	
	local pos = self.arrPame.barrageCellPos
	self:setNodePos(pos)
end

function BarrageMainView:showBarrageButton()
	if self.arrPame ~= nil then
		local barrageVoiceView = WindowControler:createWindowNode("BarrageVoiceMainView")
		barrageVoiceView:setAllData(self.system,self.arrPame)
		barrageVoiceView:setPositionY(0)
		barrageVoiceView:setName("barrageVoiceView")
	 	self:addChild(barrageVoiceView,99999)
	end
end



function BarrageMainView:addFrameScheduleUpdate()
	self.handle = self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end

--重复调用控件
function BarrageMainView:updateCell(data)
	

	local view = nil
	if table.length(self.saveMoveCell) ~= 0 then
		for k,v in pairs(self.saveMoveCell) do
			if self.system == FuncBarrage.SystemType.world then
				if data ~= nil then
					local titleType = data.titleType or 3
					if tonumber(titleType) == FuncChat.CHAT_T_TYPE.system then
						view = v
						view.line = 1
						self:loaclCheckData(view)
						self.saveMoveCell[k] = nil
						break
					end
				else
					view = v
					if v.titleType == FuncChat.CHAT_T_TYPE.world or
						v.titleType == FuncChat.CHAT_T_TYPE.tream then 
					else
						view.line = 1
					end
					table.insert(self.cellArr,view)
					self.saveMoveCell[k] = nil
					break
				end
			else
				view = v
				self:loaclCheckData(view)
				self.saveMoveCell[k] = nil
				break
			end
		end
		if self.system ~= FuncBarrage.SystemType.plot  then
			if self.system ~= FuncBarrage.SystemType.crosspeak then
				if view == nil then
					for k,v in pairs(self.saveMoveCell) do
						view = v
						self:loaclCheckData(view)
						self.saveMoveCell[k] = nil
						break
					end
				end
				if data ~= nil then
					view.view:initData(data)
				end
				local pos = self:byLinegetPos(view.line or 1)
				view.view:setVisible(true)
				view.view:setPosition(cc.p(pos[1],-pos[2]))
			end
		else
			if data ~= nil then
				if view ~= nil then
					view.view:initData(data)
					local pos = self:byLinegetPos(view.line or 1)
					view.view:setVisible(true)
					view.view:setPosition(cc.p(pos[1],-pos[2]))
				end
			end
		end
	end

end

function BarrageMainView:loaclCheckData(newData)
	local issave = false
	if self.cellArr ~= nil then
		for k,v in pairs(self.cellArr) do
			if v.view == newData.view then
				self.cellArr[k] = newData
				issave = true
			end
		end
		if not issave then
			table.insert(self.cellArr,newData)
		end
	end
end

--创建控件
function BarrageMainView:createCellView(index)

	--如果是将要挂掉的 或者已经挂掉了 那么return
	if self.died or tolua.isnull(self) then
		return
	end

	if self.allData ~= nil then
		if self.allData[index] ~= nil then
			-- dump(self.allData,"111111111111111")
			local num = table.length(self.cellArr) + table.length(self.saveMoveCell)
			echo("=======控件总数量=num======",num,index,self.cellIndex)
			if self.cellIndex ~= nil and self.cellIndex ==  index then
				return
			end
			-- echo("=====index======",index)
			if num > FuncBarrage.MaxShowUINum then
				self:updateCell(self.allData[index])
			else
				local fistRandom = 1
				if self.allData[index].titleType ~= nil then
					local special = FuncBarrage.getBarrageSpecial(self.system)
					local titleType = self.allData[index].titleType
					local arrSpecial =  special[tonumber(titleType)]
					if arrSpecial ~= nil then
						self.random = math.random(tonumber(arrSpecial[1]),tonumber(arrSpecial[2]))
					else
						self.random = nil
					end
					-- if  == 1 then
					-- 	self.random = math.random(1,2)
					-- 	fistRandom = 1
					-- else
					-- 	self.random = nil
					-- 	fistRandom = 3  --从第三个开始随机
					-- end
				end
				local random = self.random or math.random(fistRandom,self.linenum)  ---例如 1 - 4  随机取一个
				local speedArr = FuncBarrage.getBarrageSpeed(self.system)
				if self.system == FuncBarrage.SystemType.plot or self.system == FuncBarrage.SystemType.tower then
					if self.plotrandom ~= nil then
						self.plotrandom = self.plotrandom + 1
						if self.plotrandom > 3 then
							self.plotrandom = 1
						end
					else
						self.plotrandom = 1
					end
					random = self.plotrandom
				end

				if self.speed[random] == nil then
					self.speed[random]  = math.random(speedArr[1],speedArr[2])
				end

				local offY = random * linehight
				local baseCell = UIBaseDef:cloneOneView(self.UI_1);
				local cellview = BarrageControler:createCellModels(self.barrageType,baseCell)
				local titleType = nil
				if cellview ~= nil then
					if self.system == FuncBarrage.SystemType.world then
						titleType = self.allData[index].titleType
						local system = FuncChat.Chat_Set_Type[titleType]
						local isshow = ChatModel:getSetBarrageShow(system)
						if isshow then
							cellview:setVisible(true)
						else
							cellview:setVisible(false)
						end
					end
					-- dump(self.allData[index],"22222222")
					cellview:initData(self.allData[index])
					local pos = self:byLinegetPos(random)
					-- dump(pos,"2222222222======")
					cellview:setPosition(cc.p(pos[1],-pos[2]))
					self.moveNode:addChild(cellview,9999)
					local itemview  = {view = cellview,line = random,titleType = titleType,speed = self.speed[random]}
					self.cellIndex = index
					table.insert(self.cellArr,itemview)
				end
			end
		-- else
		-- 	self:updateCell()
		end
	end
end

--根据行数获取点位置
function BarrageMainView:byLinegetPos(line)
	local withMaxX = GameVars.width  --屏幕最大的位置
	local maxPosX = nil  ---控件最大的位置
	local view = nil
	if line ~= nil then
		if self.cellArr ~= nil  then
			for k,v in pairs(self.cellArr) do
				if v ~= nil then
					local lines = v.line
					if lines ~= nil then
						if line == lines then
							if v.view ~= nil then
								local cell_X = v.view:getPositionX()
								local width =  v.view:getCellSize().width
								if cell_X + width >= withMaxX then
									if maxPosX ~= nil then
										if maxPosX < cell_X + width then
											maxPosX = cell_X + width
											view = v.view
										end
									else
										maxPosX = cell_X + width
										view = v.view
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if maxPosX ~= nil then
		if view ~= nil then
			local offX = 25 --偏移像素
			local size =  view:getCellSize()
			local width = size.width
			maxPosX = maxPosX + width + offX
			return {maxPosX,line * linehight}
		end
	end

	return {GameVars.width + 20,line * linehight}

end

function BarrageMainView:updateFrame()
	-- self:showWorldBarrage()
	local remainder = math.fmod(self.index,GameVars.GAMEFRAMERATE * self.intervalTime)
	if remainder == 0 then
		if table.length(self.allData) ~= 0 then
			-- if table.length(self.allData) ~= self.indexdata then
				self.indexdata = self.indexdata + 1
				self:createCellView(self.indexdata)
			-- end
		end
	end

	for k,v in pairs(self.cellArr) do
		local cellview = v.view
		local line = v.line
		if cellview ~= nil then
			local x = cellview:getPositionX()
			local with = cellview:getCellSize().width
			if x <= - with - 80 then
				cellview:setVisible(false)
				table.insert(self.saveMoveCell,v)
				-- self.cellArr[k] = nil  ---置空
				table.remove(self.cellArr,k)

			else
				-- local line = v.line
				cellview:setPositionX(cellview:getPositionX() - v.speed )--self.speed)
			end
		end
	end
	if table.length(self.saveMoveCell) ~= 0 then
		for k,v in pairs(self.saveMoveCell) do
			v.view:setVisible(false)
		end
	end
	self.index = self.index + 1
end
	

--有新数据来的时候刷新数据表
function BarrageMainView:upUIdata(event)
	
	local params = event.params
	local _type = self.system
	self.allData = BarrageModel:setAllData(_type,self.allData,params)
	local index = #self.allData
	self:createCellView(index)

end


--系统
function BarrageMainView:systemData(event)
	local data = event.params.params.data
	data.chattype = 1
	local index = #self.allData
	self.allData = BarrageModel:setdataByChatComment(1,{data},self.allData)
	self.random = math.random(1,2)
	self:showWorldBarrage()
	index = index + 1
	self:createCellView(index)
	self.random = nil

end

--缘伴
function BarrageMainView:requestLoveMessage(event)

	local data = event.params.params.data

	dump(event.params.params,"缘伴聊天语音数据 ======")
	data.chattype = 7
	self.random = math.random(3,self.linenum)
	local index = #self.allData
	self.allData = BarrageModel:setdataByChatComment(4,{data},self.allData)
	-- self:showWorldBarrage()
	-- dump(self.allData,"22222222222222222222")
	self:createCellView(index + 1)
	self.random = nil
end

--世界
function BarrageMainView:worldData(event)
	-- dump(event.params,"00000000000")
	local data = event.params.params.data
	data.chattype = 2
	self.random = math.random(3,self.linenum)
	self.allData = BarrageModel:setdataByChatComment(2,{data},self.allData)
	self:showWorldBarrage()
	local index = #self.allData
	self:createCellView(index)
	self.random = nil
	-- dump(self.allData,"添加一条世界聊天的数据")

end

function BarrageMainView:notifyrequestLoveMessage(event)
	-- dump(event.params,"2222222222222222")

	local data = {
		chattype = 7,
		content  = event.params,
		time     = TimeControler:getServerTime(),
		type     = 1,
		vip      = 0,
		zitype   = 6,
	}
	self.random = math.random(3,self.linenum)
	local index = #self.allData
	self.allData = BarrageModel:setdataByChatComment(4,{data},self.allData)
	self:showWorldBarrage()
	self:createCellView(index + 1)
	self.random = nil

end

--仙盟
function BarrageMainView:guildData(event)
	local data = event.params.params.data
	data.chattype = 3
	local index = #self.allData
	self.random = math.random(3,self.linenum)
	self.allData = BarrageModel:setdataByChatComment(3,{data},self.allData)
	index = index +1
	self:showWorldBarrage()
	self:createCellView(index)
	self.random = nil


end

function BarrageMainView:setplotData(event)
	local data = event.params
	-- dump(self.arrPame,"剧情数据====0000000===")
	-- echo("=========self.plotID=======",self.plotID,data.order)
	-- self.arrPame
	if self.plotID ~= nil then 
		if self.arrPame ~= nil then
			self.arrPame.plotData = {}
			self.arrPame.plotData.plotID = data.id
			self.arrPame.plotData.order = tonumber(data.order)
		else
			return
		end
		if tonumber(self.plotID) ~= tonumber(data.id) then
			local function callback(data)
				if self.arrPame ~= nil then
					local data  = BarrageModel:getPlotData(data,self.arrPame)
					self.allData = {}
					self.allData = data
					local index =  #self.allData
					if index >= 1 then
						index = 1
						self.cellIndex = 0
					end
					
					self:createCellView(index)
					self.indexdata = 1
				end
			end
			self.plotID = data.id
			BarrageModel.allPlotData = nil
			BarrageModel:getPlotCommentData(self.arrPame.plotData,callback)
		else
			if tonumber(data.order) ~= 1 then
				local  newData  = BarrageModel:getPlotData(BarrageModel.allPlotData,self.arrPame)
				local index =  #self.allData
				for k,v in pairs(newData) do
					table.insert(self.allData,v)
				end
				-- dump(self.allData,"剧情数据==222222=====")
				if index == 0 then
					index = 1
					self.cellIndex = 0
				end
				self:createCellView(index)
				self.indexdata = index
			end
		end
	end
	
	BarrageModel:setVoiceTypeAndData(self.arrPame,self.system)
end

function BarrageMainView:setMyselfPlotData(event)
	
	local params = event.params
	
	
	-- dump(params,"剧情数据===111111111====")
	local _type = self.system
	self.allData = BarrageModel:setAllData(_type,self.allData,params)
	local index = #self.allData
	self:createCellView(index)
	-- dump(self.allData,"剧情数据==111111=====")

end



function BarrageMainView:clickButtonBack()
    self:startHide();
end




return BarrageMainView;
