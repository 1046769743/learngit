-- GuildExploreBuildPosView
--[[
	Author: wk
	Date:2018-07-05
	Description: 建筑的坑位
]]

local GuildExploreBuildPosView = class("GuildExploreBuildPosView", UIBase);
--[[
	pames = {
		id = ,
		text =,
		index = ,
		allData = ,
	}
]]
--占位的枚举
local mc_arr = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 2,
	[5] = 3,
	[6] = 4,
}
function GuildExploreBuildPosView:ctor(winName,pames)
    GuildExploreBuildPosView.super.ctor(self, winName)
   
    self.data = pames
end

function GuildExploreBuildPosView:loadUIComplete()
	self:createData(self.data)
	self:registerEvent()
	self:initViewAlign()

end 


function GuildExploreBuildPosView:onBattleExitResume()
	self:getNewData()
end

function GuildExploreBuildPosView:getNewData()
	local eventdata = GuildExploreEventModel:getcityData()
	if eventdata then
		self:refreshData(eventdata)
	end
end




function GuildExploreBuildPosView:refreshData(data)
	data.index = self.pames.index
	local nameArr  =  self:getFuncCityData("ExploreCity",self.pames.id,"bottomName2" )
	local name = nameArr[self.pames.index]
	data.text = GameConfig.getLanguage(name)
	self:createData(data)
end

function GuildExploreBuildPosView:createData(data)
	self.pames = data
    self.eventId = self.pames.allData.eventId
	self.isbattle,self.pantnerData = GuildExploreModel:getPantnerIsbattle( self.eventId)
	self:addSprite()
	self:setSumPower()
	self:setBuffText()
	self:initData()


end


function GuildExploreBuildPosView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1,UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)

end

function GuildExploreBuildPosView:registerEvent()
	GuildExploreBuildPosView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.startHide,self))
	self.UI_1.txt_1:setString(self.pames.text)

	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLORE_CITY_SERVE_ERROR_POS_REFRESHUI, self.getNewData,self)

end

function GuildExploreBuildPosView:getFuncCityData( cfgsName,id,key )
	local cfgsName = cfgsName --"ExploreCity"
	local id = id
	local keyData 
	if key == nil then
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	else
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	end
	
	return keyData
end




function GuildExploreBuildPosView:addSprite()
	local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id,"base" )
	local res = string.split(baseData[1], ",")
	local ability = res[1]
	local addAdility = res[2]
	local time = res[3]
	local _type = res[4]
	local itemId = res[5]
	local count = res[6]
	local addNum = res[7]
	local icon = nil
	if _type == FuncGuildExplore.guildExploreResType  then
		local image   =  self:getFuncCityData("ExploreResource",itemId,"icon" )
		icon = FuncRes.getIconResByName(image)
	else
		local iconName = FuncDataResource.getIconPathById(_type)
		icon = FuncRes.getIconResByName(iconName)
	end
	local sprite = display.newSprite(icon)
	sprite:size(35,35)

	local haveMe = self:meIsExist() --我是否占领了坑位
	local pames = nil 
	if haveMe then
		pames = 2
		self.mc_1:showFrame(pames)

	else
		pames = 1
		self.mc_1:showFrame(pames)
	end
	local panel = self.mc_1:getViewByFrame(pames)
	if pames == 1 then
		panel.ctn_1:removeAllChildren()
		panel.ctn_1:addChild(sprite)
	elseif pames == 2 then
		panel.ctn_1:removeAllChildren()
		panel.ctn_1:addChild(sprite)
		local sprite2 = display.newSprite(icon)
		sprite2:size(35,35)
		panel.ctn_2:removeAllChildren()
		panel.ctn_2:addChild(sprite2)

		self:upMiningData()
		--- 显示数据
		self:unscheduleUpdate()
		self:scheduleUpdateWithPriorityLua(c_func(self.upMiningData, self) ,0)
		
	end
end


function GuildExploreBuildPosView:upMiningData()
	local panel = self.mc_1:getViewByFrame(2)
	local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id)
	local res = string.split(baseData.base[1], ",")
	local ability = tonumber(res[1])
	local addAdility = tonumber(res[2])
	-- local time = tonumber(res[3])
	-- local _type = res[4]
	-- local count = tonumber(res[5])
	-- local addNum = tonumber(res[6])

	local time = tonumber(res[3])
	local _type = tonumber(res[4])
	local itemId = tonumber(res[5])
	local count = tonumber(res[6])
	local addNum = tonumber(res[7])

	local newpartnerIdList = {}
	if self.isbattle then
		if self.pantnerData ~= nil then
			for k,v in pairs(self.pantnerData) do
				table.insert(newpartnerIdList,v.id)
			end
		end
	end

	-- if _type == FuncGuildExplore.guildExploreResType then

	-- else

	-- end


	local partnerAbility = GuildExploreModel:getPartnersAbility(newpartnerIdList)
	if partnerAbility > ability then
	 	local addFactor = math.floor((partnerAbility - ability)/addAdility) * addNum
	 	count = count + addFactor
	end
	if time == 1 then
		panel.txt_2:setString(count.."/分钟")
	else
		panel.txt_2:setString(count.."/"..time.."分钟")
	end
	local group = self.pames.index
	local occupy = self.pames.allData.occupy[tostring(group)]
	local  ctime = 0
	if occupy then
		for k,v in pairs(occupy) do
			if v.roleInfo.id ==  UserModel:rid() then
				ctime = v.cTime
			end
		end
	end
	local serveTime = TimeControler:getServerTime()
	if ctime ~= 0 then
		-- echo("====serveTime===111111111=",serveTime,ctime,(serveTime-ctime)/(time*60))
		local createTime = math.floor((serveTime-ctime)/(time*60))
		count =  createTime * count
	end

	panel.txt_4:setString(count)
end

--设置总战力
function GuildExploreBuildPosView:setSumPower()
	local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id)	
	local res = string.split(baseData.base[1], ",")
	local ability = tonumber(res[1])
	local power = ability --self.pames.allData.ability
	local power = GuildExploreModel:getGuildAbility()
	local ability = FuncGuildExplore.getPowerByLevel(FuncGuildExplore.gridTypeMap.build,UserModel:level(),self.pames.id,power)
	self.UI_2:setPower(power)
end

function GuildExploreBuildPosView:setBuffText()
	local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id)
	local index = self.pames.index  --建筑的第几个位置
	local buff = baseData.buff
	local buffArr =  string.split(buff[index], ",")
	local buteData = FuncChar.getAttributeData()
	local key =  buffArr[1]
	local valuer = buffArr[2]
    local buteName = GameConfig.getLanguage(buteData[tostring(key)].name)
    self.txt_1:setString("所有水晶处于开采状态时,"..buteName.."提升"..valuer.."%")

    -- local image = self:getFuncCityData( "ExploreCity",self.cityID,"buffIcon" )
    local image = baseData.buffIcon
	local icon = FuncRes.iconBuff(image[index])
    local sprite = display.newSprite(icon)
    self.ctn_1:addChild(sprite)
    
end


function GuildExploreBuildPosView:initData()
	local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id)
	local index = self.pames.index
	local blockNum = baseData.blockNum

	local num = tonumber(blockNum[index])
	local frame = mc_arr[num]
	self.mc_2:showFrame(frame)

	for i=1,num do
		local mc = self.mc_2:getViewByFrame(frame)
		local view = mc["panel_"..i]
		self:setPanelview(view,i)
	end
end


--判断怪物是否死亡
function GuildExploreBuildPosView:getMonsterIsdeath(index)
	local group = self.pames.index
	local index = index
	local allData = self.pames.allData
	local groupData = allData.monster[tostring(group)]
	if  groupData then
		local monsterData = groupData[tostring(index)]
		if monsterData and monsterData.monsterState then
			local levelHpPercent = monsterData.monsterState.levelHpPercent
			if levelHpPercent == 0  then
				return true,monsterData
			end
		end
	end
	return false 
end

function GuildExploreBuildPosView:setPanelview(view,index)
	-- local isHavePeople = self:meIsExist(true,index) -- 是否有人占了坑位
	-- echo("1111111111=======",isHavePeople)
	
	local monsterIsdeath,monsterData = self:getMonsterIsdeath(index)
	if monsterIsdeath then   --怪物是否已死
		local isMe,playdata = self:meIsExist(false,index)  --是不是我占领的
		-- echo("======monsterIsdeath======isMe=====",monsterIsdeath,isMe,index)
		if isMe then
			view.mc_2:showFrame(3)
			view.mc_h:showFrame(1)
			view.mc_1:showFrame(2)
			local text = view.mc_h:getViewByFrame(1)
			text.txt_1:setVisible(true)
			text.txt_1:setString(UserModel:name())
			local btn = view.mc_2:getViewByFrame(3).btn_1
			btn:setTouchedFunc(c_func(self.evacuationButton, self,index),nil,true);
		else
			local isMine,playdata = self:whetherMining(index)  --是否开采了
			-- echo("========isMine=======",isMe)
			if isMine then
				view.mc_2:setVisible(false)
				view.mc_1:showFrame(2)
				view.mc_h:showFrame(1)
				local text = view.mc_h:getViewByFrame(1)
				local name = playdata.roleInfo.name or ""
				text.txt_1:setVisible(true)
				text.txt_1:setString(name)
			else
				view.mc_2:setVisible(true)
				view.mc_1:showFrame(2)
				view.mc_2:showFrame(2)
				view.mc_h:showFrame(1)
				local text = view.mc_h:getViewByFrame(1)
				-- local time = 100 ---倒计时时间
				text.txt_1:setVisible(false)
			--setString(UserModel:name())
				-- text.txt_1:setString(time..GameConfig.getLanguage("#tid_Explore_des_129"))
				local btn = view.mc_2:getViewByFrame(2).btn_1
				btn:setTouchedFunc(c_func(self.mineButton, self,index),nil,true);
			end
		end
	else
		-- local isMine = self:whetherMining()  --是否开采了
		local monsterData = self:getMonsterData(index)
		-- local isMine = self:whetherMining()  --是否开采了
		local isMe,data = self:meIsExist(false,index)
		local serveTime = TimeControler:getServerTime()
		echo("======monsterIsdeath======isMine==111111===",isMe)
		if monsterData and ((monsterData.lockRid ~= "" and monsterData.lockRid ~= UserModel:rid() ) or monsterData.lockTime == 0) and monsterData.lockTime > serveTime then
			view.mc_1:showFrame(1)
			view.mc_2:setVisible(false)
			view.mc_h:showFrame(1)
			local panel = view.mc_h:getViewByFrame(1)
			panel.txt_1:setString("其他玩家占领中")
		else

			if isMe then
				view.mc_2:setVisible(false)
				view.mc_h:setVisible(false)
			else
				view.mc_2:setVisible(true)
				view.mc_h:setVisible(true)
			end
			view.mc_1:showFrame(1)
			view.mc_2:showFrame(1)
			view.mc_h:showFrame(2)
			local panel = view.mc_h:getViewByFrame(2)
			
			local percent = 100  --设置进度
			if monsterData then
				percent = monsterData.monsterState.levelHpPercent/100
			end
			panel.txt_2:setString(percent.."%")
			panel.progress_1:setPercent(percent)
			local btn = view.mc_2:getViewByFrame(1).btn_1
			btn:setTouchedFunc(c_func(self.occupationButton, self,index),nil,true);

			local isMining = self:meIsExist(false)
			if isMining then
				btn:getUpPanel().txt_1:setString("邀请")
				btn:setTouchedFunc(c_func(self.invitationButton, self,index),nil,true);
			else
				btn:getUpPanel().txt_1:setString("占领")
			end

		end
		-- echo("======monsterIsdeath======isMe=====",monsterIsdeath,isMe)
	end


end

function GuildExploreBuildPosView:invitationButton(index)

	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end

	local eventId = self.pames.allData.eventModel.id
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
		eventId = eventId, 
		index = self.pames.index,
	}
	GuildExploreServer:invitationChallengCity(params,callBack)
end

function GuildExploreBuildPosView:getMonsterData(pos)
	local monster = self.pames.allData.monster
	local index =  self.pames.index
	local data = monster[tostring(index)]
	-- dump(data,"显示")
	return data[tostring(pos)]

end

--撤离按钮
function GuildExploreBuildPosView:evacuationButton(index)
	

	local eventId = self.pames.allData.eventId

	local function callBack(event)
		if event.result then
			WindowControler:showTips("成功撤离");
			local result = event.result.data.result
			if result == 0 then
			-- FuncGuildExplore.getResIdByType(resType)
				local reward = event.result.data.reward
				local partenerList = event.result.data.partenerList or {}
				GuildExploreModel:setPartnerIsHas(partenerList)
				-- dump(event.result,"\n=====成功撤离返回数据======")
				if reward and table.length(reward) ~= 0 then
					local rewardData,ischange = GuildExploreModel:rewardTypeConversion(reward)
					if ischange then
						WindowControler:showWindow("RewardSmallBgView", rewardData);
					end
				end

				local isbattle,pantnerData = GuildExploreModel:getPantnerIsbattle(eventId)
				-- echo("=====isbattle=======",isbattle)
				
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

				self.pames.allData.occupy[tostring(self.pames.index)][tostring(index)] = nil
				-- dump(self.pames,"成功撤离本地数=====")

				self:addSprite()
				self:setSumPower()
				self:setBuffText()
				self:initData()

				EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
				EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_SEND_PANTNER_UI)
			end
		end

	end

	local pames = {
		eventId = eventId,
	}

	GuildExploreServer:leaveToCity(pames,callBack)


end


--开采按钮
function GuildExploreBuildPosView:mineButton(index)
	echo("=========开采按钮=========")

	local arr = {
		id = self.pames.allData.eventId,
		name = self.pames.text,
		_type = FuncGuildExplore.lineupType.building,
		group = self.pames.index,
		index = index,
		tid =  self.pames.allData.eventModel.tid,
		callBack = function (data)
				local newData = {
					rid = UserModel:rid(),
					name = UserModel:name(),
					cTime = TimeControler:getServerTime(),
					position = data.position,
					group = data.group or 1,
					roleInfo = {id = UserModel:rid()},
				}
				self.pames.allData.occupy[tostring(data.group)][tostring(data.position)] = newData
				self:getNewData()
				self:upMiningData()
				EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_DISPATCH_PANTNER)
		end,
	}

	WindowControler:showWindow("GuildExploreLineupView",arr)

end

--占领按钮  --进入布阵界面
function GuildExploreBuildPosView:occupationButton(index)
	-- echo("=========占领按钮=========",index)


		local baseData  =  self:getFuncCityData("ExploreCity",self.pames.id)
		local level = baseData.level[self.pames.index]
		self.pames.allData.eventModel.group = self.pames.index
		self.pames.allData.eventModel.index = index
		GuildExploreEventModel:setMonsterEventModel(self.pames.allData.eventModel)

		local params = {}
	    params[FuncTeamFormation.formation.guildExplorePve] = {
	        eventModel = self.pames.allData.eventModel,
	        raidId = level,
	    }


    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.guildExplorePve,params)




end



--我是不是存在,以及是不是我占领的
function GuildExploreBuildPosView:meIsExist(isOther,_index)
	local occupy = self.pames.allData.occupy
	local group = self.pames.index
	local data = occupy[tostring(group)]
	if data and table.length(data)  ~= 0 then
		if not isOther then
			for k,v in pairs(data) do
				if v.roleInfo.id == UserModel:rid() then
					if not _index then
						return true,data
					else
						if v.position == _index then
							return true,data
						end
					end
				end
			end
		else
			if table.length(data) ~= 0 then
				-- local data1 = occupy[group][_index]
				-- if data1 then
					return true,data
				-- end
			end
		end
	end
	return false,data
end


--我是否开采
function GuildExploreBuildPosView:whetherMining(_index)
	local occupy = self.pames.allData.occupy
	local _type = self.pames.index
	if occupy then
		for k,v in pairs(occupy[tostring(_type)]) do
			if v then
				if tonumber(k) == tonumber(_index) then
					if v.roleInfo then
						return true,v
					end
				end
			end
		end
	end
	return false,nil


end





function GuildExploreBuildPosView:deleteMe()
	-- TODO

	GuildExploreBuildPosView.super.deleteMe(self);
end




return GuildExploreBuildPosView;
