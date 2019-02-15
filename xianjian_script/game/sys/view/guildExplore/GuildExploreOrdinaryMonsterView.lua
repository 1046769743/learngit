-- GuildExploreOrdinaryMonsterView.lua
--[[
	Author: wk
	Date:2018-07-018
	Description: 普通怪
]]

local GuildExploreOrdinaryMonsterView = class("GuildExploreOrdinaryMonsterView", UIBase);

function GuildExploreOrdinaryMonsterView:ctor(winName)
    GuildExploreOrdinaryMonsterView.super.ctor(self, winName)

end

function GuildExploreOrdinaryMonsterView:loadUIComplete()
	self:registerEvent()
	-- self:initData()
	-- self:registClickClose("out")
end 
function GuildExploreOrdinaryMonsterView:registerEvent()
	-- EventControler:addEventListener(GuildExploreEvent.RES_EXCHANGE_REFRESH, self.initData, self)


	self.btn_1:setTouchedFunc(c_func(self.challengeButton, self),nil,false);
end

function GuildExploreOrdinaryMonsterView:challengeButton()
	local monsterId  =  self.monsterID  --怪物ID
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterId )
	local level = data.level
	-- GuildExploreEventModel:setMonsterEventModel(self.eventModel)
	-- echo("==========普通怪物挑战=======")
	-- echo("========进入布阵============")

	-- ---[[  本地测试
	-- 	self:dispatchEventList()
	-- 	self.eventModel.eventListId = 104
	-- 	GuildExploreEventModel:setEventListData(self.eventModel)
	-- 	GuildExploreEventModel:challengSuccessful(self.eventModel,FuncGuildExplore.gridTypeMap.enemy)
	-- --]]
	GuildExploreEventModel:setMonsterEventModel(self.eventModel)
	local params = {}
    params[FuncTeamFormation.formation.guildExplorePve] = {
        eventModel = self.eventModel,
        raidId = level,
    }
    -- self:dispatchEventList()
     self:button_close()
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.guildExplorePve,params)
	


end
function GuildExploreOrdinaryMonsterView:getServerData(eventModel,object)

	self.eventModel = eventModel
	self.monsterID = eventModel.tid 
	self.mapMyView = object
	self:addViewTouch()
	self:initData()



end


function GuildExploreOrdinaryMonsterView:initData()
	local monsterID  =  self.monsterID  --怪物ID
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterID )
	self.txt_1:setString(GameConfig.getLanguage(data.name))
	-- dump(self.eventModel,"4444444444444")
	local eventData  = GuildExploreModel:getEventData( self.eventModel.id)
	dump(eventData,"怪物事件数据==========")
	
	local hp = 100
	if eventData.params then
		local levelHpPercent =  eventData.params.levelHpPercent
		if levelHpPercent then
			hp = levelHpPercent/100
		end
	end
	self.txt_4:setString("剩余:"..hp.."%")  --怪物血量
	local percent = hp
	self.progress_1:setPercent(percent)

	local power = GuildExploreModel:getMeAbility()   ---历史最高战力
	-- local ability = FuncGuildExplore.getLevelRevise(power,UserModel:level())
	local ability = FuncGuildExplore.getPowerByLevel(FuncGuildExplore.gridTypeMap.enemy,UserModel:level(),monsterID,power)
	self.txt_3:setString(ability)

	self:setShowReward()

end

function GuildExploreOrdinaryMonsterView:setShowReward()
	local monsterID  =  self.monsterID  --怪物ID
	local newRewardArr = FuncGuildExplore.getMonsterReward(monsterID)

 	self.UI_2:setVisible(false)
 	local posX = self.UI_2:getPositionX()-10
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


function GuildExploreOrdinaryMonsterView:addViewTouch()
	self.btn_close:setTouchedFunc(c_func(self.button_close, self),nil,false);
	self:registClickClose("out", function ()
		self:button_close()
	end,true)
end

function GuildExploreOrdinaryMonsterView:dispatchEventList()
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_HIDDEN_MONSTERUI)
end
function GuildExploreOrdinaryMonsterView:button_close()
	EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_MAIN_ISSHOW,{isShow = true})
	self:startHide()
end





function GuildExploreOrdinaryMonsterView:deleteMe()
	-- TODO
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_RESUMESCALE)
	GuildExploreOrdinaryMonsterView.super.deleteMe(self);
end

return GuildExploreOrdinaryMonsterView;
