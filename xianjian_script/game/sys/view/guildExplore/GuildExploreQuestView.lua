-- GuildExploreQuestView
--[[
	Author: wk
	Date:2018-07-06
	Description: 仙盟探索任务
]]

local GuildExploreQuestView = class("GuildExploreQuestView", UIBase);

function GuildExploreQuestView:ctor(winName,_type,allData)
    GuildExploreQuestView.super.ctor(self, winName)

    self.select_type = _type or FuncGuildExplore.taskType.single
    self.questDataList = allData or {}
    echo("======self.select_type======",self.select_type)
end

function GuildExploreQuestView:loadUIComplete()
	-- local singeData,manyPeopleData  = FuncGuildExplore.getQuestData()
	local singeData,manyPeopleData  = GuildExploreModel:getAllTaskData()
	self.allData = {
		[1] = singeData,
		[2] = manyPeopleData,
	}
	self:registerEvent()
	self:initViewAlign()

	self:showButtonIsSelect()
	self:initData()

end 

function GuildExploreQuestView:registerEvent()
	GuildExploreQuestView.super.registerEvent(self);
	self.panel_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_106"))
	self.UI_1.btn_1:setTap(c_func(self.buttonClose,self))
	-- self:registClickClose("out")
	self.mc_1:setTouchedFunc(c_func(self.setButton, self,FuncGuildExplore.taskType.single),nil,true);
	self.mc_2:setTouchedFunc(c_func(self.setButton, self,FuncGuildExplore.taskType.manyPeople),nil,true);

	
	self:isShowButtonRed()
end

function GuildExploreQuestView:isShowButtonRed()
	local  isoshow1 = self:getButtonRed(FuncGuildExplore.taskType.single)
	self.mc_1:getViewByFrame(1).panel_red:setVisible(isoshow1)
	self.mc_1:getViewByFrame(2).panel_red:setVisible(isoshow1)
	local  isoshow2 = self:getButtonRed(FuncGuildExplore.taskType.manyPeople)
	self.mc_2:getViewByFrame(1).panel_red:setVisible(isoshow2)
	self.mc_2:getViewByFrame(2).panel_red:setVisible(isoshow2)
end



--多人还是单人的红点
function GuildExploreQuestView:getButtonRed(_type)
	local allData = nil
	if _type == FuncGuildExplore.taskType.single then
		local data = self.allData[tonumber(_type)]
		allData = self:setquestData(data)
	elseif _type == FuncGuildExplore.taskType.manyPeople then
		local data = self.allData[tonumber(_type)]
		allData = self:setquestData(data)
	end

	-- dump(allData,"===多人还是单人的红点====")
	-- echo("====_type=======",_type)
	for k,v in pairs(allData) do
		if v.finish and v.finish == 1 then
			if v.getRew and v.getRew == 1 then
				return true
			end
		end
	end

	return false

end




function GuildExploreQuestView:buttonClose()
	self:startHide()
end

function GuildExploreQuestView:setButton(index)
	if self.select_type == index then
		return 
	end
	
	self.select_type = index
	self:showButtonIsSelect()
	self:initData()
end
function GuildExploreQuestView:showButtonIsSelect()
	local _type = self.select_type
	if _type == FuncGuildExplore.taskType.single then
		self.mc_1:showFrame(2)
		self.mc_2:showFrame(1)
	elseif _type == FuncGuildExplore.taskType.manyPeople then
		self.mc_1:showFrame(1)
		self.mc_2:showFrame(2)
	end
end

function GuildExploreQuestView:listSort(data)
	data = self:setquestData(data)
	local sortFunc = function (h1,h2)
		if  h1.getRew > h2.getRew then
			return true
		else
			if 	h1.getRew == h2.getRew then 
				if h1.finish > h2.finish then
					return true
				else
					if h1.finish == h2.finish then
						if tonumber(h1.id) < tonumber(h2.id) then
							return true
						end
					end
				end
			end	
		end

		return false
	end
	table.sort(data,sortFunc)
	return data
end

function GuildExploreQuestView:setquestData(data)
	for k,v in pairs(data) do
		local newData = self.questDataList[tostring(v.id)] --取得那些任务完成 
		local condition = v.condition
		local process = newData.process
		local getState = newData.state

		if getState == 0 then --未领取
			v.getRew = 1
		else --领取
			v.getRew = 0
		end
		if process >= condition then --完成
			v.finish = 1
		else --未完成
			v.finish = 0
		end
	end
	
	return  data
end


function GuildExploreQuestView:initData()

	-- dump(self.allData,"2222222222222222222")

	local data = self.allData[tonumber(self.select_type)]
	-- local level =  GuildExploreModel:getGuildLevel()
	-- dump(data,"2222222222222222222")
	local newArr  = {}
	for k,v in pairs(data) do
		-- if v.guildCondition == level then
			table.insert(newArr,v)
		-- end
	end



	newArr = self:listSort(newArr)

	local createFunc = function(itemData,index)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:setCell(baseCell, itemData,index)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:setCell(view, itemData)
	end



    local  _scrollParams = {
        {
            data = newArr ,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 924, height = 120},
            perFrame = 1,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()


end

function GuildExploreQuestView:setCell(baseCell,itemData)
	-- dump(itemData,"33333333333333")
	local panel_cell = baseCell.panel_cell
	
	local title = itemData.des2  --目标描述
	panel_cell.txt_1:setString(GameConfig.getLanguage(title))
	local miaoshu  = itemData.des
	local condition = itemData.condition
	panel_cell.rich_2:setString(GameConfig.getLanguageWithSwap(miaoshu,condition))
	local reward = itemData.reward
	for i=1,3 do  --三个奖励
		local ui = panel_cell["UI_"..i]
		ui:setVisible(false)
		if reward[i] then
			ui:setVisible(true)
			self:setRewardData(ui,reward[i])
		end
	end
	
	self:setCondition(panel_cell,itemData)


end

--设置奖励ui
function GuildExploreQuestView:setRewardData(baseCell,reward)

	-- dump(reward,"33333333")
	-- local rewarArr = string.split(reward, ",");
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


function GuildExploreQuestView:getFuncData( cfgsName,id,key )
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

function GuildExploreQuestView:setCondition(view,itemData)

	local newData = self.questDataList[tostring(itemData.id)] --取得那些任务完成 
	local baseCell = view.mc_2
	-- local isFinish,num =  newData.param---GuildExploreEventModel:isGuildExploreQuestFinish(itemData.id)
	if not newData then
		newData = {
			process = 0,
			state = 0,1
	}
	end
	local condition = itemData.condition--[1]
	-- local type_arr = string.split(condition, ",");
	local getState = newData.state
	local process = newData.process
	if process >= condition then
		if getState == 0 then
			baseCell:showFrame(1)
			local panel =  baseCell:getViewByFrame(1).panel_3
			panel:setTouchedFunc(c_func(self.getRewardButton, self,itemData.id),nil,true);

		else
			baseCell:showFrame(3)
		end
	else
		baseCell:showFrame(2)
		local panel_progress =  baseCell:getViewByFrame(2).panel_progress
		local count = process --完成的数量
		panel_progress.txt_1:setString(count.."/"..condition)
		panel_progress.progress_blue:setPercent( math.abs(100 * count / condition) );

	end
end

-- --跳转
-- function GuildExploreQuestView:jumpToView(questId)
-- 	echo("==========跳转==========",questId)
-- end

--领取奖励按钮
function GuildExploreQuestView:getRewardButton(questId)
	-- echo("==========奖励任务ID========",questId)
	local function callBack( event )
		if event.result then
			-- dump(event.result,"领取任务返回数据==============")
			local task = event.result.data.task
			local reward = event.result.data.reward
			if self.questDataList[task.tid] then 
				self.questDataList[task.tid] = task
			end
			GuildExploreModel:setGetTaskRewardData(task.tid)
			local data = FuncGuildExplore.getFuncData( "ExploreQuest",questId)
			local rewardData = 	data.reward
			-- local rewardData = GuildExploreModel:rewardTypeConversion(reward) --GuildExploreEventModel:getShowRewardUIData(reward)
			dump(rewardData,"领取任务数据")
			WindowControler:showWindow("RewardSmallBgView", rewardData);
			self:initData()
			self:isShowButtonRed()
			EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_REFESH_RED)
			EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_TASK_REFRESH)
		end
	end

	local params = {
		tid = questId,
	}

	GuildExploreServer:getTaskReward(params,callBack)
end


function GuildExploreQuestView:initViewAlign()
	

end


function GuildExploreQuestView:updateUI()
	-- TODO
end

function GuildExploreQuestView:deleteMe()
	-- TODO

	GuildExploreQuestView.super.deleteMe(self);
end

return GuildExploreQuestView;
