-- GuildExploreMiningView
-- Author: Wk
-- Date: 2017-07-04
-- 采矿主界面

local GuildExploreMiningView = class("GuildExploreMiningView", UIBase);


--采矿的数据allData（框的ID和被占领的数据）
function GuildExploreMiningView:ctor(winName,allData)
    GuildExploreMiningView.super.ctor(self, winName);
    self:createData(allData)
end
function GuildExploreMiningView:createData(allData)

	-- dump(allData,"11111111111111")
	self.allData = allData
    self.isJump = allData.isJump
    self.mineData = allData.mineData
    self.eventModel = allData.eventModel
    self.mineID = allData.eventModel.tid
end

function GuildExploreMiningView:loadUIComplete()

	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);

	self:setUIViewAlign()
	self:registerEvent()
	self:openScheduleUp()
	-- self:addspine()
	self:setBuildpos()
end 

function GuildExploreMiningView:setBuildpos()
	local posArr = self:getFuncMineData( "size" )
	for i=1,3 do
		local res = string.split(posArr[i], ",")
		local x = res[1]
		local y = res[2]
		local scale = res[3]
		self["mc_"..i]:setPosition(cc.p(x,-y))
		self["mc_"..i]:setScale(scale/100)
	end
end

function GuildExploreMiningView:setUIViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_res,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_4,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_tips,UIAlignTypes.MiddleTop)

end

function GuildExploreMiningView:onBattleExitResume()
	echo("=========矿脉重取数据==========")
	local eventdata = GuildExploreEventModel:getMonsterEventModel()
	self:getServerData(eventdata)
end

function GuildExploreMiningView:registerEvent()
	GuildExploreMiningView.super.registerEvent(self)
	-- EventControler:addEventListener(NewLotteryEvent.NEXT_VIEW_UI,self.nextView,self);
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLORE_MINE_SERVE_ERROR_REFRESHUI, self.getServerData,self)

end


function GuildExploreMiningView:getServerData(eventModel)
	if eventModel.params and eventModel.params == FuncGuildExplore.lineupType.mining then
		eventModel = self.eventModel
	else
		eventModel = eventModel
	end
	local function cellFunc(data)
		self:createData(data)
		self:openScheduleUp()
	end
	GuildExploreEventModel:showMineUI(eventModel,false,cellFunc)
end



function GuildExploreMiningView:openScheduleUp()
	self:getLocalData()
	self:addspine()
	self:initData()
	
	self:unscheduleUpdate()
	self:scheduleUpdateWithPriorityLua(c_func(self.initData, self) ,0)
end




function GuildExploreMiningView:initData()
	local mineNum = 3 --总共三个坑位
	for i=1,mineNum do
		local _panel = self["mc_"..i]
		self:setPanelDataView(_panel,i)
	end
	self:setDes()
end

function GuildExploreMiningView:addspine()
	local mineNum = 3 --总共三个坑位
	for i=1,mineNum do
		local _panel = self["mc_"..i]
		local newPanel = _panel:getViewByFrame(1)
		local spineID = self:getFuncMineData( "spine" )
		local spine =  FuncRes.getSpineViewBySourceId(spineID[i])
		newPanel.ctn_1:removeAllChildren()
		newPanel.ctn_1:addChild(spine)
	end
	for i=1,mineNum do
		local occupy = self.mineData.occupy
		if occupy then
			local occupyData = occupy[tostring(i)]
			if occupyData then
				local playData = occupyData.roleInfo
				local _panel = self["mc_"..i]
				local newPanel = _panel:getViewByFrame(3)
				local avatar = UserModel:avatar()
				local garmentId = UserExtModel:garmentId()
				if playData then
					avatar = playData.avatar
					if playData.userExt then
						garmentId = playData.userExt.garmentId
					end
				end
					-- --加玩家自身的spine
				local avatarId = avatar 
				local garmentId = garmentId
				local spine = GarmentModel:getSpineViewByAvatarAndGarmentId(avatarId, garmentId)
				newPanel.ctn_2:removeAllChildren()
				newPanel.ctn_2:addChild(spine)
				newPanel.ctn_1:removeAllChildren()
				newPanel.ctn_1:setVisible(true)
				-- if playData.id == UserModel:rid() then
					local startAni = self:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_kaicai",newPanel.ctn_1, true, GameVars.emptyFunc)
					startAni:setPosition(cc.p(-20,20))
				-- end
			end
		end
	end

	for i=1,3 do
		local _panel = self["mc_"..i]
		local newPanel = _panel:getViewByFrame(1)
		local power = GuildExploreModel:getMeAbility()
		local ability = FuncGuildExplore.getPowerByLevel(FuncGuildExplore.gridTypeMap.mine,UserModel:level(),self.mineID,power)
		newPanel.UI_1:setPower(ability)
	end





end



--是否占领
function GuildExploreMiningView:isOccupation(index)
	local data = self.mineData.occupy[tostring(index)]
	if data and table.length(data) ~= 0   then
		return true,data
	end
	return false
end

--矿脉是否到时间
function GuildExploreMiningView:mineIsFinishTime()
	-- dump(self.mineData,"11111111111111111111")
	local finishTime = self.mineData.finishTime
	if not finishTime or finishTime == -1 then
		return false
	else
		if finishTime <= TimeControler:getServerTime() then
			return true
		end
	end
	return false
end

--计算开采的数量 1 = 累计开采，2 = 已开采
function GuildExploreMiningView:getMiningResNum(_type,playData)
	local timeYield = self:getFuncMineData( "timeYield" )
	if timeYield == nil then
		timeYield = self:getFuncMineData( "timeYield2" )
	end
	local occupy = self.mineData.occupy
	local peopleNum = table.length(occupy) 
	local reward = nil
	if timeYield[peopleNum] then
		reward = timeYield[peopleNum]
	else
		reward = timeYield[1]
	end
	local res = string.split(reward, ",")
	local count = 0
	local sumNum = 0
	local finishTime = self.mineData.finishTime
	local startTime = playData.cTime
	if startTime then
	local min = 60

	if res[2] == FuncGuildExplore.guildExploreResType then
		count = res[4]
	else
		count = res[3]
	end

	if tonumber(res[1]) == 1 then
		min = 60 * tonumber(res[1])
	else
		min = 60 * tonumber(res[1])
	end
	local serverTime = TimeControler:getServerTime()
		if _type == 1 then
			local time = math.floor((finishTime - startTime)/min)
			sumNum = time * count
		elseif _type == 2 then
			local endTime = serverTime
			if serverTime >= finishTime then
				endTime = finishTime
			end
			local time = math.floor((endTime - startTime)/min)
			sumNum = time * count
		end
	end

	return sumNum 
end

--判断我是不开采其他界面
function GuildExploreMiningView:getMeMiningOtherMine(index)
	local occupy = self.mineData.occupy
	-- dump(occupy,"222222222222222222")
	for k,v in pairs(occupy) do
		if v.roleInfo then
			if v.roleInfo.id == UserModel:rid() then
				if index then
					if tonumber(k) == tonumber(index) then
						return true
					end
				else
					return true
				end
			end
		end
	end
	return false
end

function GuildExploreMiningView:calculateTime(_finishTime)
	local times = _finishTime - TimeControler:getServerTime()
	if times > 0 then
		times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
	else
		times = nil
	end
	return times
end

function GuildExploreMiningView:setPanelDataView(_panel,index)
	local occupation,playData = self:isOccupation(index)  --是否被占领
	local finishTime = self.mineData.finishTime   ---矿脉是否启动开采 
	local isfinish = self:mineIsFinishTime() 
	local monster =  self.mineData.monster[tostring(index)]

	if not occupation then 
		local myoccupation = self:getMeMiningOtherMine() --该坑位没有被占领，我是不是占领其他坑位
		local isMonster = monster
		if monster then
			if monster.monsterState then
				local levelHpPercent = monster.monsterState.levelHpPercent 
				if levelHpPercent and  levelHpPercent > 0 then
					isMonster = false
				end
			end
		end
		local isoccupation = self:getMeMiningOtherMine()  ---自己占领
		if isoccupation then
			isMonster = false
		end
		-- echo("4444444444444444")
		-- echoError("=====isMonster========",isMonster)
		if isMonster then   ----怪物情况
			-- echo("3333333333333333")
			-- local levelHpPercent = monster.monsterState.levelHpPercent 
			-- if levelHpPercent > 0 then
			-- dump(monster,"111111111111111")
				if monster.lockRid == "" then
					monster.lockRid = UserModel:rid()
				end
				if monster.lockTime == "" then
					monster.lockTime = TimeControler:getServerTime() + 5*3600
				end
				local lockRid = monster.lockRid
				local lockTime = monster.lockTime or TimeControler:getServerTime() + 5*3600
				local serveTime = TimeControler:getServerTime()
				if UserModel:rid() ~= lockRid then
					if serveTime < lockTime then
						_panel:showFrame(2)
						newPanel = _panel:getViewByFrame(2)
						-- local time = self:calculateTime(lockTime)
						local time =  FuncGuildExplore.calculateTime(lockTime)
						newPanel.txt_1:setString(time.."后可以开采")
						newPanel.btn_1:setTouchedFunc(c_func(self.beExploitButton, self,index),nil,true);
					end
					-- echo("11111111111111=====",index)
				else
					-- echo("222222222222===1===",index)
					_panel:showFrame(2)
					newPanel = _panel:getViewByFrame(2)
					
					if serveTime < lockTime then
						-- echo("======serveTime======",serveTime,lockTime,lockTime-serveTime)
						-- local time = self:calculateTime(lockTime)
						local time =  FuncGuildExplore.calculateTime(lockTime)
						newPanel.txt_1:setString(time.."后其他人可开采")
						newPanel.txt_1:setVisible(true)
					else
						-- echo("222222222222===2===",index)
						newPanel.txt_1:setVisible(false)
					end
					newPanel.btn_1:setTouchedFunc(c_func(self.exploitButton, self,index),nil,true);
				end
				-- echo("=======isfinish=====",isfinish)
			
				newPanel = _panel:getViewByFrame(1)
				-- local power = GuildExploreModel:getGuildAbility()
				-- local ability = FuncGuildExplore.getLevelRevise(power,UserModel:level())
				-- newPanel.UI_1:setPower(ability)
				-- local levelHpPercent = monster.monsterState.levelHpPercent 
				local hpNum =  100  ---怪物血量
				if monster then
					if monster.monsterState then
						hpNum = (monster.monsterState.levelHpPercent)/100
					end
					if monster.monsterState.levelHpPercent <= 0 then
						_panel:showFrame(2)
						local kaicai_Panel  = _panel:getViewByFrame(2)
						if serveTime > lockTime then
							kaicai_Panel.txt_1:setVisible(false)
						end
						kaicai_Panel.btn_1:setTouchedFunc(c_func(self.exploitButton, self,index),nil,true);
					end
				end
				newPanel.txt_2:setString(hpNum.."%")
				local percent = hpNum ---血量条
				newPanel.progress_1:setPercent(percent)

				if isfinish then
					if newPanel.txt_1 then
						newPanel.txt_1:setVisible(false)
					end
					if newPanel.btn_1 then
						newPanel.btn_1:setVisible(false)
					end
				end
		else
			local monster = self.mineData.monster[tostring(index)]
			local serveTime = TimeControler:getServerTime()
			if monster and monster.lockRid ~= "" and monster.lockRid ~= UserModel:rid() and  monster.lockTime > serveTime then
				_panel:showFrame(2)
				local newPanel = _panel:getViewByFrame(2)
				newPanel.txt_1:setString("其他人占领中")
				newPanel.btn_1:setVisible(false)
				-- newPanel.btn_1:setTouchedFunc(c_func(self.beOccupationButton, self,index),nil,true);
			else
				_panel:showFrame(1)
				local newPanel = _panel:getViewByFrame(1)

				-- local powernumber = UserModel:getcharSumAbility() --  推荐战力 --自己的战力
				-- local power = GuildExploreModel:getGuildAbility()
				-- -- local ability = FuncGuildExplore.getLevelRevise(power,UserModel:level())
				-- -- echo("====power======",power)
				-- local ability = FuncGuildExplore.getPowerByLevel(FuncGuildExplore.gridTypeMap.mine,UserModel:level(),self.mineID,power)

				-- -- echo("=======power=======",power,"\n\n ======UserModel:level()========",UserModel:level(),"\n\n===ability===",ability)
				-- newPanel.UI_1:setPower(ability)
				-- local levelHpPercent = monster.monsterState.levelHpPercent 
				local hpNum =  100  ---怪物血量
				if monster then
					if monster.monsterState then
						hpNum = (monster.monsterState.levelHpPercent)/100
					end
				end
				
				newPanel.txt_2:setString(hpNum.."%")
				local percent = hpNum ---血量条
				newPanel.progress_1:setPercent(percent)
				if newPanel.panel_1 then
					newPanel.panel_1:setVisible(true)
				end
				local myoccupation = self:getMeMiningOtherMine() 
				if not myoccupation then 
					newPanel.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_108"))
					newPanel.btn_1:setTouchedFunc(c_func(self.setOccupation, self,index),nil,true);
				else
					newPanel.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_109"))
					newPanel.btn_1:setTouchedFunc(c_func(self.setInvitation, self,index),nil,true);
					newPanel.txt_2:setVisible(false)
					newPanel.progress_1:setVisible(false)
					-- newPanel.btn_1:setVisible(false)
					newPanel.panel_1:setVisible(false)
					if monster then
						if monster.monsterState then
							if hpNum == 0 then
								_panel:showFrame(2)
								local newPanel1 = _panel:getViewByFrame(2)
								newPanel1.txt_1:setVisible(false)
								newPanel1.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_109"))
								newPanel1.btn_1:setTouchedFunc(c_func(self.setInvitation, self,index),nil,true);
							end
						end
					end
					if isfinish then
						newPanel.btn_1:setVisible(false)
					end
				end
				if isfinish then
					newPanel.txt_2:setVisible(false)
					newPanel.progress_1:setVisible(false)
					newPanel.btn_1:setVisible(false)
				end
			end
		end
	else
		-- echo("5555555555555555555555=============",index)
		local isMyoccupation = self:getMeMiningOtherMine(index)  ---是否被自己占领
		if isMyoccupation then
			-- echo("5555555555555555555555======11111111=======",index)
			local isExploit =  true ---是否可以或者开采了
			if isExploit then  
				_panel:showFrame(3)
				local newPanel = _panel:getViewByFrame(3)
				local name = playData.name or UserModel:name()
				newPanel.txt_1:setString(name)
				-- newPanel.panel_1:setVisible(false)
				local isgetReward = self:mineIsFinishTime()  ---是否完成可以领奖励
				if isgetReward then
					newPanel.mc_1:showFrame(2)
					local getMC = newPanel.mc_1:getViewByFrame(2)
					local num = self:getMiningResNum(1,playData) --累计开采数量
					getMC.txt_2:setString(num)
					--领取开采的奖励
					getMC.btn_1:setTouchedFunc(c_func(self.evacuationButton, self,index),nil,true);
					newPanel.ctn_1:setVisible(false)
				else
					newPanel.mc_1:showFrame(1)
					local getMC = newPanel.mc_1:getViewByFrame(1)
					local num = self:getMiningResNum(2,playData) --已开采数量
					getMC.txt_2:setString(num)
					--撤离按钮
					getMC.btn_1:setTouchedFunc(c_func(self.evacuationButton, self),nil,true);
				end
			else
				_panel:showFrame(2)
				local newPanel = _panel:getViewByFrame(2)
				local time = playData.cTime or 60
				newPanel.txt_1:setString(time..GameConfig.getLanguage("#tid_Explore_des_107"))
				newPanel.btn_1:setTouchedFunc(c_func(self.exploitButton, self,index),nil,true);
					if isfinish then
						-- echo("222222222222===4===",index)
					newPanel.txt_1:setVisible(false)
					-- newPanel.progress_1:setVisible(false)
					newPanel.btn_1:setVisible(false)
				end
			end
		else
			-- echo("5555555555555555555555======22222222222=======",index)
			_panel:showFrame(3)
			local newPanel = _panel:getViewByFrame(3)
			newPanel.mc_1:setVisible(false)
			-- newPanel.panel_1:setVisible(true)
			local name =  UserModel:name()
			if playData.roleInfo then
				name = playData.roleInfo.name
			end
			
			newPanel.txt_1:setString(name)

		end
	end
end

function GuildExploreMiningView:beOccupationButton()
	-- body
end


--设置奖励描述
function GuildExploreMiningView:setDes()
	local occupy = self.mineData.occupy

	-- dump(self.mineData,"1111111111111111")

	local peopleNum = table.length(occupy) ---占领(开采)的人数--TODO
	local isOverTime = self:mineIsFinishTime()  --矿到了结束时间
	if peopleNum == 0 then
		peopleNum = 1
	end

	if isOverTime then
		self.mc_4:showFrame(4)
	else
		local panel = nil
		local iconPath = nil
		local resArr = self:getFuncMineData( "timeYield" )
		if resArr then  --- --读取第一个字段的资源  timeYield  --TODO

			local reward = resArr[peopleNum]
			local res = string.split(reward, ",")
			if res[2] == FuncGuildExplore.guildExploreResType then
				local keyData = FuncGuildExplore.getCfgDatas("ExploreResource",res[3])
				iconPath = FuncRes.getIconResByName(keyData.icon)
			else
				local icon =  FuncDataResource.getIconPathById( res[2] )
				iconPath = FuncRes.getIconResByName(icon)
			end
		else
			-- resArr =  self:getFuncMineData( "timeYield2" )
			-- local reward = resArr[peopleNum]
			-- local res = string.split(reward, ",")
			-- local iconName = FuncDataResource.getIconPathById( res[1] )
			-- iconPath = FuncRes.getIconResByName(iconName)
		end

		if table.length(occupy) <= 0 then
			self.mc_4:showFrame(1)
			panel = self.mc_4:getViewByFrame(1)
		else
			self.mc_4:showFrame(3)
			panel = self.mc_4:getViewByFrame(3)
			panel.mc_1:showFrame(peopleNum)--开采情况
			local text = panel.mc_1:getViewByFrame(peopleNum).txt_2
			-- local resArr =  self:getFuncMineData( "timeYield" )
			local reward = resArr[peopleNum]
			local res = string.split(reward, ",")
			local baseNum = 0
			if res[2] == FuncGuildExplore.guildExploreResType then
				baseNum = res[4]
			else
				baseNum = res[3]
			end
			if tonumber(res[1]) == 1 then
				text:setString(baseNum.."/分钟")
			else
				text:setString(baseNum.."/"..res[1].."分钟")
			end
			local time = self.mineData.finishTime - TimeControler:getServerTime()
			local timeDes =  TimeControler:turnTimeSec(time, TimeControler.timeType_hhmmss)
			panel.txt_2:setString(timeDes.."后矿脉消失")
			panel.btn_des:setTouchedFunc(c_func(self.desButton, self,panel.btn_des),nil,true);
			local sumtime = self.localData.time[self.mineData.mineSize]
			percent = (time/sumtime)*100
			-- echo("percent = ========",time,sumtime,self.mineData.mineSize,percent)
			panel.progress_1:setPercent(percent)
		end
		

		panel.ctn_1:removeAllChildren()
		local sprite = display.newSprite(iconPath)
		sprite:size(35,35)
		panel.ctn_1:addChild(sprite)
	end
end

function GuildExploreMiningView:desButton(_ctn)
	-- WindowControler:showWindow("GuildExploreResTipsView",self.mineID);
	GuildExploreEventModel:showResInfoView(self.mineID,_ctn)
end

--领取开采奖励
function GuildExploreMiningView:getRewardButton(index)
	echo("=======领取开采奖励=======")
	-- local reward = nil
	-- local resArr =  self:getFuncMineData( "timeYield" )
	-- if resArr  then  
	-- 	reward = resArr[1]
	-- 	res = string.split(reward, ",")
	-- else
	-- 	resArr =  self:getFuncMineData( "timeYield2" )
	-- 	reward = resArr[1]
	-- 	res = string.split(reward, ",")
	-- end



	---[[ --手动设置数据变化
	-- local rewardData  = res[1]..","..res[2]
	-- if tonumber(self.mineID) < 105 then  
	-- 	rewardData = {[tonumber(res[1])] = tonumber(res[2])}
	-- 	for k,v in pairs(rewardData) do
	-- 		GuildExploreModel:setResCount(k,tonumber(v))
	-- 	end
	-- 	rewardData = GuildExploreEventModel:getShowRewardUIData(rewardData)
	-- end
	-- 	FuncCommUI.startRewardView(rewardData)
	-- 	EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
	-- 	self:clickButtonBack()
	--]]

end

--撤离按钮
function GuildExploreMiningView:evacuationButton()
	echo("=======撤离按钮=======")
	local function callBack(event)
		if event.result then
			-- dump(event.result,"撤离奖励 =======")
			WindowControler:showTips("成功撤离");
			local reward =  event.result.data.reward

			reward,ischange = GuildExploreModel:rewardTypeConversion(reward)
			if ischange then
				FuncCommUI.startRewardView(reward)
			end


			local isbattle,pantnerData = GuildExploreModel:getPantnerIsbattle(self.eventModel.id)
			if isbattle then
				for k,v in pairs(pantnerData) do
					local partnerData = GuildExploreModel:getUnitInfoDataByPartnerId(v.id)
					local eventModel = {
						hpPercent = partnerData.hpPercent,
						dispatch = "",
						ability = partnerData.ability,
						id = partnerData.id,
					}
					GuildExploreModel:setUnitInfoDataByPartnerId(v.id,eventModel)
				end
			end

			EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_SEND_PANTNER_UI)

			self:clickButtonBack()
		end

	end
	local pames = {
		eventId = self.eventModel.id, --撤离
	}
	GuildExploreServer:leaveToMine(pames,callBack)
end

function GuildExploreMiningView:beExploitButton( index )
	WindowControler:showTips("被其他玩家锁定")
end


--开采按钮
function GuildExploreMiningView:exploitButton(index)
	echo("=======开采按钮=======")

		local arr = {
			id = self.mineData.eventId,
			tid =  self.mineData.tid,
			name = GameConfig.getLanguage(self:getFuncMineData( "name" )),
			_type = FuncGuildExplore.lineupType.mining,
			index = index,
			allData = self.mineData,
			callBack = function (data)								
				local newData = {
					id = UserModel:rid(),
					name = UserModel:name(),
					cTime = data.cTime,
					position = data.position,
					avatar = UserModel:avatar(),
				}
				self.mineData.finishTime = data.finishTime
				self.mineData.occupy[tostring(data.position)] = {}
				self.mineData.occupy[tostring(data.position)].roleInfo = newData

				-- dump(self.mineData,"33333333333333")
				self:openScheduleUp()
			end,
		}
		if self.isJump  then
			local function tempFunc()
				WindowControler:showWindow("GuildExploreLineupView",arr)
			end
			local eventModel = self.eventModel
			-- echo("=======跳转弹消耗灵力界面=======")
			-- dump(eventModel,"=====eventModel======")
			local num = self:getCostEnergyCount()
			WindowControler:showWindow("GuildExploreCostEnergy",num,tempFunc)
		else	
			WindowControler:showWindow("GuildExploreLineupView",arr)
		end

end

--占领按钮
function GuildExploreMiningView:setOccupation(index)
	
	-- -- if self.isJump then
	-- -- 	echo("=======消耗精气值====")
	-- -- 	-- WindowControler:showWindow("GuildExploreCostSpView",0,true)
	-- -- else
	-- 	echo("=======占领按钮===进战斗====",self.mineID)
	-- 	WindowControler:showTips("成功占领,跳过战斗")--GameConfig.getLanguage("#tid_guild_004"))
	-- 	local data = {
	-- 		rid = UserModel:rid(),
	-- 		name = UserModel:name(),
	-- 		cTime = TimeControler:getServerTime() + 360,
	-- 				-- startTime = TimeControler:getServerTime(),--开始时间
	-- 	}
	-- 	self.mineData.occupy[index] = data
	-- 	self:openScheduleUp()
	-- -- end

	-- local monster =  self.mineData.monster[tostring(index)]
	-- if monster then   ----怪物情况
	-- 	local lockRid = monster.lockRid
	-- 	local lockTime = monster.lockTime
	-- 	local serveTime = TimeControler:getServerTime()
	-- 	if UserModel:rid() ~= lockRid then
	-- 		if serveTime < lockTime then
	-- 			WindowControler:showTips("被其他玩家锁定")
	-- 			return
	-- 		end
	-- 	end
	-- end

	local level = self.localData.level[index]

	echo("========进入布阵界面=======")

	
	self.eventModel.index = index
	GuildExploreEventModel:setMonsterEventModel(self.eventModel)
	local params = {}
    params[FuncTeamFormation.formation.guildExplorePve] = {
        eventModel = self.eventModel,
        raidId = level,
    }

    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.guildExplorePve,params)
	

end

--邀请按钮
function GuildExploreMiningView:setInvitation()
	-- echo("=======邀请按钮=======")

	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end

	local eventId = self.eventModel.id
	local ishas = GuildExploreEventModel:getInviteNumber(eventId)
	if ishas then
		WindowControler:showTips("邀请已发送")--GameConfig.getLanguage("#tid_guild_004"))
		return 
	end


	local function callBack(event)
		if event.result then
			-- dump(event.result,"=====发送邀请成功=====")
			GuildExploreEventModel:setInviteNumber(eventId)
			WindowControler:showTips("发送邀请成功")
		end
	end

	local params = {
		eventId = self.eventModel.id
	}

	GuildExploreServer:invitationChallengMine(params,callBack)

	-- local function callback(_param)
	-- 	-- dump(_param.result,"公会邀请数据",8)
	-- 	if _param.result then
	-- 		GuildExploreEventModel:setInviteNumber(eventId)
	-- 		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_004"))
	-- 	end
	-- end
	-- local mineId = self.mineID --矿洞ID
	-- local name = self:getFuncMineData( "name" )
	-- local tips = GameConfig.getLanguageWithSwap("#tid_unionlevel_talk_1", UserModel:name(),GameConfig.getLanguage(name))

	-- local info = {
	-- 	desc = tips,
	-- 	eventModel = self.eventModel,
	-- }
	-- local param = {}
	-- local content = json.encode(info)
	-- param.content = content
	-- param.type = FuncChat.EventEx_Type.guildExportMine
	-- ChatServer:sendLeagueMessage(param,callback);


end


function GuildExploreMiningView:getFuncMineData( key )
	-- local cfgsName = "ExploreMine"
	-- local mineID = self.mineID
	-- local keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,mineID,key)
	-- return keyData

	return self.localData[key]

end

--取配表数据
function GuildExploreMiningView:getLocalData()
	local mineID = self.mineID
	self.localData = FuncGuildExplore.getCfgDatas( "ExploreMine",mineID ) --FuncGuildExplore.getCfgDatasByKey(cfgsName,mineID,key)
end


--获取快捷跳转后消耗的精力
function GuildExploreMiningView:getCostEnergyCount()
	local finishTime = self.mineData.finishTime
	local serverTime = TimeControler:getServerTime()
	local surplusTime = finishTime - serverTime
	if surplusTime > 0 then

	end
	return 10
end



function GuildExploreMiningView:clickButtonBack()
	self:startHide()
end



return GuildExploreMiningView;
