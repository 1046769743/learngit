-- GuildExploreRewardView
--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreRewardView = class("GuildExploreRewardView", UIBase);

function GuildExploreRewardView:ctor(winName)
    GuildExploreRewardView.super.ctor(self, winName)
end

function GuildExploreRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:unscheduleUpdate()
	self:scheduleUpdateWithPriorityLua(c_func(self.updataTime, self) ,0)
end 

function GuildExploreRewardView:registerEvent()
	GuildExploreRewardView.super.registerEvent(self);
	-- self:registClickClose("out")
	self:registClickClose(-1, c_func( function()
        self:setClose()
    end , self))

	self.UI_1.btn_close:setTap(c_func(self.setClose,self))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_103"))
	self.UI_1.mc_1:setVisible(false)
	self.panel_1:setVisible(false)

end

function GuildExploreRewardView:setClose()
	EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_OFF_LINE_REWARD)
	self:startHide()
end

function GuildExploreRewardView:initData()

	self.isok,self.allData = GuildExploreModel:getoffLineReward()

	-- dump(self.allData,"离线数据奖励=========== ")
	local newData = {}


	if not self.allData then
		self.allData = {}
	end

	local time = TimeControler:getServerTime()
	for k,v in pairs(self.allData) do
		-- if v.type == 3 then
		-- 	table.insert(newData,v)
		-- else
			if v.expireTime > time then
				table.insert(newData,v)
			end
		-- end
	end

    table.sort(newData,function(a,b)
        return a.expireTime > b.expireTime
    end)


	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:setCell(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:setCell(view, itemData)
	end



    local  _scrollParams = {
        {
            data = newData,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -110, width = 450, height = 110},
            perFrame = 0,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()


end

function GuildExploreRewardView:calculateTime(_finishTime)
	local times = _finishTime - TimeControler:getServerTime()
	if times > 0 then
		times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
	else
		times = nil
	end
	return times
end

function GuildExploreRewardView:setCell(view,itemData)

	-- dump(itemData,"离线奖励数据结构========")

	local _type = tostring(itemData.type)
	local str = ""
	-- echo("======_type========",_type)
	if _type == "1"  then
		str = "精英怪挑战奖励:"
	elseif _type == "2"  then  --矿脉
		str = "矿脉采集奖励:"
	elseif _type == "3" then  --大型建筑
		str = "建筑采集奖励"
	end

	view.txt_2:setString(str)

	local resource = itemData.resource

	local rewards = {}
	for k,v in pairs(resource) do
		table.insert(rewards,v)
	end


	
	local time = self:calculateTime(itemData.expireTime)
	view.txt_1:setString(time)

	view.btn_1:setTouchedFunc(c_func(self.getReward, self,itemData),nil,true);

	view.UI_1:setVisible(false)
	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(view.UI_1);
        self:setRewardData(baseCell, itemData)
        return baseCell;
    end
     local updateFunc = function (itemData,view)
    	self:setRewardData(view, itemData)
	end




    local  _scrollParams = {
        {
            data = rewards ,
            createFunc = createFunc,
            updateFunc= updateFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -80, width = 80, height = 80},
            perFrame = 0,
        }
    }    
    view.scroll_1:refreshCellView( 1 )
    view.scroll_1:styleFill(_scrollParams);
    view.scroll_1:hideDragBar()


end

--领取奖励
function GuildExploreRewardView:getReward(itemData)
	-- echo("======领取奖励========")
	local function callBack( event )
		-- dump(event.result,"领取奖励数据后的返回=======")
		if event.result then
			local result = event.result.data.result
			if result == 0 then
				local reward = event.result.data.resource
				if reward then
					WindowControler:showTips("领取成功")
					local rewardData = GuildExploreModel:rewardTypeConversion(reward)
					WindowControler:showWindow("RewardSmallBgView", rewardData);
					-- echo("----领取成功后刷新列表---")
					
				end
				GuildExploreModel:setoffLineReward(itemData.id)
				self:initData()
				EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_OFF_LINE_REWARD)
			end
		end
	end



	local params = {
		id = itemData.id
	}
	GuildExploreServer:getOfflineReward(params,callBack)
end

--设置奖励ui
function GuildExploreRewardView:setRewardData(baseCell,reward)


	local rewarArr = string.split(reward, ",");


	-- local rewarArr = GuildExploreEventModel:getShowRewardUIData({[rewarArr[1]] = rewarArr[2]})
	baseCell:setResItemData({reward = reward})

	local data  = string.split(reward, ",");


	local rewardType = data[1]      ----类型
	local rewardNum = data[3]   ---总数量
	local rewardId = data[2] 			---物品ID
	FuncCommUI.regesitShowResView(baseCell,
            rewardType, rewardNum, rewardId,reward, true, true);


	-- baseCell.mc_1:showFrame(1)
	-- local data  =  self:getFuncData("ExploreResource",rewarArr[1])
	-- local panel_1 = baseCell.mc_1:getViewByFrame(1).btn_1:getUpPanel().panel_1
	-- panel_1.panel_red:setVisible(false)
	-- local quility = data.quality
	-- panel_1.mc_kuang:showFrame(quility)
	-- panel_1.ctn_1:removeAllChildren()

	-- local iconpath = FuncRes.getGuildExporeIcon(data.icon)
	-- local sprite = display.newSprite(iconpath)
	-- sprite:setScale(0.6)
	-- panel_1.ctn_1:addChild(sprite)
	-- panel_1.mc_zi:showFrame(quility)
	-- local txt_1 = panel_1.mc_zi:getViewByFrame(quility).txt_1
	-- local  name = data.translateId
	-- txt_1:setVisible(false)
	-- -- txt_1:setString(GameConfig.getLanguage(name))
	-- local num = rewarArr[2]
	-- panel_1.txt_goodsshuliang:setString(num)
	-- local  y = baseCell:getPositionY()
	-- baseCell:setPositionY(y - 10)
end


function GuildExploreRewardView:updataTime()
	if self.frameCount then
		if (self.frameCount % GameVars.GAMEFRAMERATE == 0) then
			if self.allData then
				for i=1,#self.allData do
					local cell = self.scroll_1:getViewByData(self.allData[i])
					if cell then 
						if self.allData[i] then
							local expireTime = self.allData[i].expireTime
							local serverTime = TimeControler:getServerTime()
							if expireTime > serverTime then
								local time = self:calculateTime(expireTime)
								cell.txt_1:setString(time)
							else
								cell.txt_1:setString("已过期")
								cell.btn_1:setVisible(false)
							end
						end
					end
				end
			end
		end
		self.frameCount = self.frameCount + 1;
	else
		self.frameCount = 1
	end
end


function GuildExploreRewardView:getFuncData( cfgsName,id,key )
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

function GuildExploreRewardView:deleteMe()
	GuildExploreRewardView.super.deleteMe(self);
end

return GuildExploreRewardView;
