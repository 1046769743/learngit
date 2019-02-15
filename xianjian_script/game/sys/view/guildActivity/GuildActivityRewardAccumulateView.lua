--
--Author:      zhuguangyuan
--DateTime:    2018-05-10 11:12:33
--Description: 仙盟厨房奖励_子界面_积分奖励
--

local GuildActivityRewardAccumulateView = class("GuildActivityRewardAccumulateView", UIBase);

function GuildActivityRewardAccumulateView:ctor(winName)
    GuildActivityRewardAccumulateView.super.ctor(self, winName)
end

function GuildActivityRewardAccumulateView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityRewardAccumulateView:registerEvent()
	GuildActivityRewardAccumulateView.super.registerEvent(self);
	-- 成功领取了奖励
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD, self.gotOneReward, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end

function GuildActivityRewardAccumulateView:gotOneReward( event )
	local rewardIds = event.params.rewardIds
	if FuncGuildActivity.isDebug then
		dump(rewardIds, "rewardIds")
	end
	-- 将多个奖励按id计算数量
	local rewardData = {}
	for k,v in ipairs(rewardIds) do
		local data = self.configAccumulateData[v]
		for kk,rewardStr in pairs(data.reward) do
			local dataArr = string.split(rewardStr,",")
			local rewardId = dataArr[1].."_"..dataArr[#dataArr-1]
			if not rewardData[rewardId] then
				rewardData[rewardId] = {}
				rewardData[rewardId].resourceId = dataArr[1]
				rewardData[rewardId].itemId = dataArr[#dataArr-1]
				rewardData[rewardId].num = tonumber(dataArr[#dataArr])
			elseif rewardData[rewardId].resourceId == dataArr[1]
				and rewardData[rewardId].itemId == dataArr[#dataArr-1]
				then
				rewardData[rewardId].num = rewardData[rewardId].num + tonumber(dataArr[#dataArr])
			end
		end
	end
	if FuncGuildActivity.isDebug then
		dump(rewardData, "rewardData")
	end
	-- 将计算的数量格式化成奖励,做展示
	local finalRewardData = {}
	for k,v in pairs(rewardData) do
		if tostring(v.resourceId) == tostring(v.itemId) then
			finalRewardData[#finalRewardData + 1] = v.resourceId..","..v.num
		else
			finalRewardData[#finalRewardData + 1] = v.resourceId..","..v.itemId..","..v.num
		end
	end
	if FuncGuildActivity.isDebug then
		dump(finalRewardData, "finalRewardData")
	end

	FuncCommUI.startFullScreenRewardView(finalRewardData)
	self.oneKeyGetReward = {}
	self:updateUI()
end

function GuildActivityRewardAccumulateView:initData()
	-- 一键领取可领的奖励id 数组
	self.oneKeyGetReward = {}
end

function GuildActivityRewardAccumulateView:initView()
	self.rewardScrollList = self.scroll_1
	self.panel_1:setVisible(false)
	self:initRewardScroll()
end

function GuildActivityRewardAccumulateView:initRewardScroll( ... )
	local function createRewardItemFunc( itemData )
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		self:updateOneItemView(itemData,itemView)
		return itemView
	end
	self.rewardListParams =  {
	   	data = nil,
        createFunc = createRewardItemFunc,
        perNums= 1,
        offsetX = 10,
        offsetY = 10,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x = 0,y = -116,width = 982,height = 116},
        perFrame = 1,
        cellWithGroup = 1
	}
end

function GuildActivityRewardAccumulateView:updateOneItemView(itemData, itemView)
	-- dump(itemData, "=========== zhiidesciption", nesting)
	local rewardDataItemList = itemData.reward
    local rewardNum = table.length(rewardDataItemList)
    itemView.mc_1:showFrame(rewardNum)
    local contentView = itemView.mc_1:getCurFrameView()
    for i,v in pairs(rewardDataItemList) do
        local rewardUI = contentView["UI_"..i] -- UIBaseDef:cloneOneView(itemView.UI_1)

        local rewardStr = v
        local params = {
            reward=rewardStr,
        }
        rewardUI:setResItemData(params)
        rewardUI:setResItemClickEnable(true)
        rewardUI:showResItemNum(true)  

        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(rewardUI,resType,resNum,resId,rewardStr,true,true)
    end

	-- 数量
	local haveNum = GuildActMainModel:getAccumulateScore()
	local needNum = itemData.foodScore
	local str1 = "<color = 993300>".."".."<->"
	if haveNum >= needNum then
		haveNum = needNum
		str1 = str1.."<color = 008c0d>"..haveNum.."/"..needNum.."<->"
	else
		str1 = str1.."<color = FF3300>"..haveNum.."/"..needNum.."<->"
	end

	itemView.rich_1:setString(str1)

	-- 领取状态 及 红点
	local status = GuildActMainModel:getAccumulateRewardStatus(itemData.id)
	if status == FuncGuildActivity.rewardStatus.HAVE_GOT then
		itemView.mc_2:showFrame(3)
	elseif status == FuncGuildActivity.rewardStatus.CAN_GET then
		itemView.mc_2:showFrame(2)
		curView = itemView.mc_2:getCurFrameView()
		local btnPanel = curView.btn_1v:getUpPanel()
		btnPanel.panel_red:setVisible(true)

		-- 领取奖励
		curView.btn_1v:setTap(function()
			if not self.havedSentRequest then
				local rewards = {}
				rewards[1] = itemData.id
				GuildActMainModel:getAccumulateReward(UserModel:guildId(),rewards)
			end
		end)			
	elseif status == FuncGuildActivity.rewardStatus.CAN_NOT_GET then
		itemView.mc_2:showFrame(1)
	end
end


function GuildActivityRewardAccumulateView:buildScrollParams()
	-- 积分奖励暂未考虑多期活动的情况
	-- 或者多期活动的积分奖励都一样
	self.configAccumulateData = FuncGuildActivity.getAccumulateReward()
	self.rewardLength = 0
	for k,v in pairs(self.configAccumulateData) do
		self.rewardLength = self.rewardLength + 1 
	end
	-- dump(self.configAccumulateData,"累积奖励信息===")

	local params = nil
	local ListParams = {}
	for i = 1,self.rewardLength do
		params = table.deepCopy(self.rewardListParams)
		params.data = {self.configAccumulateData[tostring(i)]}
		ListParams[#ListParams + 1] = params

		local status = GuildActMainModel:getAccumulateRewardStatus(tostring(i))
		if status == FuncGuildActivity.rewardStatus.CAN_GET then
			self.oneKeyGetReward[#self.oneKeyGetReward + 1] = tostring(i)
		end
	end
	-- dump(ListParams,"累积奖励信息===")

	return ListParams 
end

function GuildActivityRewardAccumulateView:updateUI()
	local data = self:buildScrollParams()
	self.rewardScrollList:cancleCacheView()
    self.rewardScrollList:styleFill(data)
    self:updateOneKeyGetReward()
end

-- 更新一键领取的状态
function GuildActivityRewardAccumulateView:updateOneKeyGetReward()
	echo("________ 更新一键领取的状态 ")
	local rewards = self.oneKeyGetReward or {}
	if table.length(rewards) ~= 0 then
		FilterTools.clearFilter(self.btn_1)
	else
		FilterTools.setGrayFilter(self.btn_1,120)
	end

	self.btn_1:setTap(function()
		if table.length(rewards) ~= 0 then 
			if not self.havedSentRequest then
				local rewards = self.oneKeyGetReward or {}
				if table.length(rewards) ~= 0 then
					GuildActMainModel:getAccumulateReward(UserModel:guildId(),rewards)
				end
			end
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_food_tip_3006") )
		end
	end)
end

function GuildActivityRewardAccumulateView:initViewAlign()
	-- TODO
end

function GuildActivityRewardAccumulateView:onClose()
	self:startHide()
end

function GuildActivityRewardAccumulateView:deleteMe()
	GuildActivityRewardAccumulateView.super.deleteMe(self);
end

return GuildActivityRewardAccumulateView;
