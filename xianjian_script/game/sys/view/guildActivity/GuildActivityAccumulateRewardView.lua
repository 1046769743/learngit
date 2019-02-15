--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:36:57
--Description: 仙盟GVE活动
--Description: 领取累积奖励界面
--


local GuildActivityAccumulateRewardView = class("GuildActivityAccumulateRewardView", UIBase);

function GuildActivityAccumulateRewardView:ctor(winName)
    GuildActivityAccumulateRewardView.super.ctor(self, winName)
end

function GuildActivityAccumulateRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityAccumulateRewardView:registerEvent()
	GuildActivityAccumulateRewardView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.onClose, self))
	-- 成功领取了奖励
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD, self.gotOneReward, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end
function GuildActivityAccumulateRewardView:gotOneReward( event )
	local rewardIds = event.params.rewardIds
	if FuncGuildActivity.isDebug then
		dump(rewardIds, "rewardIds")
	end
	-- 将多个奖励按id计算数量
	local rewardData = {}
	for k,v in ipairs(rewardIds) do
		local data = self.configAccumulateData[v]
		local dataArr = string.split(data.reward[1],",")
		local rewardId = dataArr[2]
		if not rewardData[rewardId] then
			rewardData[rewardId] = {}
			rewardData[rewardId].resourceId = dataArr[1]
			rewardData[rewardId].itemId = dataArr[2]
			rewardData[rewardId].num = tonumber(dataArr[3])
		elseif rewardData[rewardId].resourceId == dataArr[1]
			and rewardData[rewardId].itemId == dataArr[2]
			then
			rewardData[rewardId].num = rewardData[rewardId].num + tonumber(dataArr[3])
		end
	end
	if FuncGuildActivity.isDebug then
		dump(rewardData, "rewardData")
	end
	-- 将计算的数量格式化成奖励,做展示
	local finalRewardData = {}
	for k,v in pairs(rewardData) do
		finalRewardData[#finalRewardData + 1] = v.resourceId..","..v.itemId..","..v.num
	end
	if FuncGuildActivity.isDebug then
		dump(finalRewardData, "finalRewardData")
	end

	FuncCommUI.startFullScreenRewardView(finalRewardData)
	self.oneKeyGetReward = {}
	self:updateUI()
end

function GuildActivityAccumulateRewardView:onClose()
	self:startHide()
end
function GuildActivityAccumulateRewardView:initData()
	-- 一键领取可领的奖励id 数组
	self.oneKeyGetReward = {}
end

function GuildActivityAccumulateRewardView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_051")) 
	-- self.UI_1.panel_1:setVisible(false)

	self.rewardScrollList = self.scroll_1
	self.panel_2:setVisible(false)
	self:initRewardScroll()
end
function GuildActivityAccumulateRewardView:initRewardScroll( ... )
	local function createRewardItemFunc( _rewardData )
		local itemView = UIBaseDef:cloneOneView(self.panel_2)
		-- 奖励图标
		local rewardDataItemList = _rewardData.reward
		-- 默认先隐藏全部
	    for i=1,3 do
	        itemView["UI_"..i]:setVisible(false)
	    end
	    for k,v in pairs(rewardDataItemList) do
	        local rewardUI = UIBaseDef:cloneOneView(itemView.UI_1)
	        local posX = itemView.UI_1:getPositionX()

	        rewardUI:setVisible(true)
	        rewardUI:setPositionX(posX - 100*(k-1) + 60)
	        rewardUI:addto(itemView)

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
		local needNum = _rewardData.foodScore
		local str1 = "<color = 993300>".."本周积分:".."<->"
		if haveNum >= needNum then
			haveNum = needNum
		end
		str1 = str1.."<color = FF3300>"..haveNum.."/"..needNum.."<->"
		itemView.rich_1:setString(str1)

		-- 领取状态 及 红点
		local status = GuildActMainModel:getAccumulateRewardStatus(_rewardData.id)
		if status == FuncGuildActivity.rewardStatus.HAVE_GOT then
			itemView.mc_1:showFrame(2)
		elseif status == FuncGuildActivity.rewardStatus.CAN_GET then
			itemView.mc_1:showFrame(1)
			curView = itemView.mc_1:getCurFrameView()
			local btnPanel = curView.btn_1:getUpPanel()
			btnPanel.panel_red:setVisible(true)

			-- 领取奖励
			curView.btn_1:setTap(function()
				if not self.havedSentRequest then
					local rewards = {}
					rewards[1] = _rewardData.id
					GuildActMainModel:getAccumulateReward(UserModel:guildId(),rewards)
				end
			end)			
		elseif status == FuncGuildActivity.rewardStatus.CAN_NOT_GET then
			itemView.mc_1:showFrame(1)
			contentView = itemView.mc_1:getCurFrameView()
			local btnPanel = contentView.btn_1:getUpPanel()
			btnPanel.panel_red:setVisible(false)
			FilterTools.setGrayFilter(itemView.mc_1)
		end
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

function GuildActivityAccumulateRewardView:buildScrollParams()
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
	return ListParams 
end


function GuildActivityAccumulateRewardView:initViewAlign()
	-- TODO
end

function GuildActivityAccumulateRewardView:updateUI()
	local data = self:buildScrollParams()
	self.rewardScrollList:cancleCacheView()
    self.rewardScrollList:styleFill(data)
    self:updateOneKeyGetReward()
end

-- 更新一键领取的状态
function GuildActivityAccumulateRewardView:updateOneKeyGetReward()
	local rewards = self.oneKeyGetReward or {}
	if table.length(rewards) ~= 0 then
		self.btn_yl:getUpPanel().panel_red:visible(true)
		self.btn_yl:setTap(function()
			if not self.havedSentRequest then
				local rewards = self.oneKeyGetReward or {}
				if table.length(rewards) ~= 0 then
					GuildActMainModel:getAccumulateReward(UserModel:guildId(),rewards)
				end
			end
		end)
	else
		self.btn_yl:setTouchEnabled(false)
		FilterTools.setGrayFilter(self.btn_yl,120)
		self.btn_yl:getUpPanel().panel_red:visible(false)
	end
end

function GuildActivityAccumulateRewardView:deleteMe()
	-- TODO

	GuildActivityAccumulateRewardView.super.deleteMe(self);
end

return GuildActivityAccumulateRewardView;
