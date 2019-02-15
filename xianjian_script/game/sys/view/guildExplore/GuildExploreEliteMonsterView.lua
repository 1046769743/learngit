-- GuildExploreEliteMonsterView
--[[
	Author: wk
	Date:2018-07-018
	Description: 精英怪
]]

local GuildExploreEliteMonsterView = class("GuildExploreEliteMonsterView", UIBase);

function GuildExploreEliteMonsterView:ctor(winName)
    GuildExploreEliteMonsterView.super.ctor(self, winName)
    -- self.monsterID  =  101  --怪物ID
end


function GuildExploreEliteMonsterView:loadUIComplete()
	self.mc_1:setVisible(false)
	self.txt_3:setVisible(false)
	self.UI_2:setVisible(false)
	self:registerEvent()
	self:addViewTouch()
end 



function GuildExploreEliteMonsterView:addViewTouch()
	self:registClickClose("out", function ()
		-- self:dispatchEventList()
		self:button_close()
	end,true)

end

--[[
	-- eventId = 
	-- hpPercent = 
	-- roleDemageList = {
			-- 	rid
			-- 	rank
			-- 	name
			-- 	hpPercent
		-- }
	-- count   --已挑战次数

]]

function GuildExploreEliteMonsterView:getServerData(eventModel)
	self.eventModel = eventModel
	local eventId = eventModel.id
	self.monsterID = eventModel.tid or 101
	local function callBack(event)
		if event.result then
			local data = event.result.data
			dump(event.result,"=====精英怪的数据=====")
			self.allData = data
			self:initData()
		end
	end
	local params = {
		eventId = eventId,
	}

	GuildExploreServer:getServeEliteMonsterData(params,callBack)

end


function GuildExploreEliteMonsterView:dispatchEventList()
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_HIDDEN_MONSTERUI)
end



function GuildExploreEliteMonsterView:registerEvent()
	-- EventControler:addEventListener(GuildExploreEvent.RES_EXCHANGE_REFRESH, self.initData, self)
	self.mc_1:setVisible(false)
	-- self:registClickClose("out")
	self.btn_1:setTouchedFunc(c_func(self.challengeButton, self),nil,true)
	self.btn_2:setTouchedFunc(c_func(self.invitationButton, self),nil,true)
	self.btn_close:setTouchedFunc(c_func(self.button_close, self),nil,true)
end

function GuildExploreEliteMonsterView:invitationButton()
	WindowControler:showTips("邀请已发送")
	-- self.eventModel.eventListId = 104
	-- GuildExploreEventModel:setEventListData(self.eventModel)
	local serveTime = TimeControler:getServerTime()
	local _type = FuncGuildExplore.eventType.eliteMonster
	local time = GuildExploreEventModel:getitationChallengMonsterCD(self.eventModel.id)
	-- echo("=========time======",time)
	if serveTime < time +  FuncGuildExplore.invitationCD then
		WindowControler:showTips(GameConfig.getLanguage("tid_Explore_des_132"))
		return
	end

	local hpPercent = self.allData.hpPercent
	if hpPercent <= 0 then
		WindowControler:showTips("怪物已死不能邀请")
		return
	end

	local function callBack(event)
		if event.result then
			if event.result.data.result == 0 then
				-- dump(event.result,"=====发送邀请成功=====")
				WindowControler:showTips("发送邀请成功")
				local _type = FuncGuildExplore.eventType.eliteMonster
				GuildExploreEventModel:setitationChallengMonsterCD(self.eventModel.id,serveTime)
			end
		end
	end

	local params = {
		eventId = self.eventModel.id
	}

	GuildExploreServer:eliteMonsterInvitation(params,callBack)

end

function GuildExploreEliteMonsterView:challengeButton()
	local monsterID  =  self.monsterID  --怪物ID
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterID )
	local triggerNum = 3 --data.triggerNum
	local count = self:getChallengCount()

	local hpPercent = self.allData.hpPercent
	if hpPercent <= 0 then
		WindowControler:showTips("怪物已死")
		return
	end
	if count >= triggerNum then
		WindowControler:showTips("挑战次数用完")
		return 
	end
	echo("======挑战精英====进入布阵界面=========")
	GuildExploreEventModel:setMonsterEventModel(self.eventModel)
	local params = {}
    params[FuncTeamFormation.formation.guildExploreElite] = {
        eventModel = self.eventModel,
        raidId = data.level,
    }
    -- self:dispatchEventList()
    self:button_close()
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.guildExploreElite,params)


end


function GuildExploreEliteMonsterView:initData()
	local monsterID  =  self.monsterID  --怪物ID
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterID )
	self.txt_1:setString(GameConfig.getLanguage(data.name))
	
	local hp = self.allData.hpPercent/100 or 100
	self.txt_4:setString("剩余:"..hp.."%")  --怪物血量
	local percent = hp
	self.progress_1:setPercent(percent)

	local power = GuildExploreModel:getGuildAbility()
	-- echo("======power========",power,UserModel:level())
	-- local ability = FuncGuildExplore.getLevelRevise(power,UserModel:level())
	self.txt_3:setVisible(true)
	local ability = FuncGuildExplore.getPowerByLevel(FuncGuildExplore.gridTypeMap.elite,UserModel:level(),monsterID,power)
	self.txt_3:setString(ability)
	self:setShowReward()
	self:initListView()
	self:setChallengCount()
end

function GuildExploreEliteMonsterView:setChallengCount()
	local monsterID  =  self.monsterID  --怪物ID
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterID )
	local triggerNum = 3 --data.triggerNum
	local count = triggerNum - self:getChallengCount()
	if tonumber(count) > 0  then
		self.txt_8:setColor(cc.c3b(84,48, 20))
	else
		self.txt_8:setColor(cc.c3b(255,0, 0))
	end
	self.txt_8:setString(count.."/"..triggerNum)
end

function GuildExploreEliteMonsterView:setShowReward()
	local monsterID  =  self.monsterID  --怪物ID
 	local newRewardArr = FuncGuildExplore.getMonsterReward(monsterID)

 	-- dump(newRewardArr,"数据奖励======")
 	self.UI_2:setVisible(false)
 	local posX = self.UI_2:getPositionX()
 	local posY = self.UI_2:getPositionY()

 	for i=1,#newRewardArr do
 		local baseCell = UIBaseDef:cloneOneView(self.UI_2);
 		baseCell:setPosition(cc.p(posX+(i-1)*100,posY))
 		-- baseCell:setScale(0.7)
 		self:addChild(baseCell)
 		baseCell:setResItemData({reward = newRewardArr[i]})

 		
 		local data  = string.split(newRewardArr[i], ",");

		local rewardType = data[1]      ----类型
		local rewardNum = data[3]   ---总数量
		local rewardId = data[2] 			---物品ID
		FuncCommUI.regesitShowResView(baseCell,
	            rewardType, rewardNum, rewardId, newRewardArr[i], true, true);
 	end

end

function GuildExploreEliteMonsterView:getChallengCount()
	local roleDemageList = self.allData.roleDemageList
	local count = 0
	if roleDemageList then
		for k,v in pairs(roleDemageList) do
			if v.rid == UserModel:rid() then
				count = v.count
			end
		end
	end
	return count
end

function GuildExploreEliteMonsterView:initListView()
	local data = self.allData.roleDemageList or {}
	
	table.sort(data,function(a,b)
        return a.demage > b.demage
    end)

	for i=1,#data do
		data[i].rank = i
	end

	local createFunc = function(itemData,index)
    	local baseCell = UIBaseDef:cloneOneView(self.mc_1);
        self:setCell(baseCell, itemData,index)
        return baseCell;
    end
     local updateFunc = function (itemData,view,index)
    	self:setCell(view, itemData,index)
	end

    local  _scrollParams = {
        {
            data =  data,
            createFunc = createFunc,
            updateFunc= updateFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -20, width = 270, height = 20},
            perFrame = 1,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()

end 



function GuildExploreEliteMonsterView:setCell(view, itemData,index)
	-- dump(itemData,"11111111111111")
	-- echo("=======index======",index)
	if index then
		if index > 4 then
			index = 4
		end
	else
		index = 1
	end
	view:showFrame(index)
	local baseCell = view.currentView

	local rank = itemData.rank
	baseCell.txt_1:setString(rank or 1)
	local name = itemData.name or "没有名字字段"
	baseCell.txt_2:setString(name)
	local hp = itemData.demage or 100
	baseCell.txt_3:setString((hp/100).."%")
	-- baseCell:setTouchedFunc(c_func(self.showPlayInfo, self,itemData),nil,true)
end

function GuildExploreEliteMonsterView:showPlayInfo(itemData)
	local playId =  itemData.uid
end

function GuildExploreEliteMonsterView:button_close()
	EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_MAIN_ISSHOW,{isShow = true})
	self:startHide()
end


function GuildExploreEliteMonsterView:deleteMe()
	-- TODO
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_RESUMESCALE)
	GuildExploreEliteMonsterView.super.deleteMe(self);
end

return GuildExploreEliteMonsterView