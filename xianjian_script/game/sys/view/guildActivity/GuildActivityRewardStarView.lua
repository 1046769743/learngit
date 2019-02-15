--
--Author:      zhuguangyuan
--DateTime:    2018-05-10 11:13:14
--Description: 仙盟厨房奖励_子界面_星级奖励
--

local GuildActivityRewardStarView = class("GuildActivityRewardStarView", UIBase);

function GuildActivityRewardStarView:ctor(winName)
    GuildActivityRewardStarView.super.ctor(self, winName)
end

function GuildActivityRewardStarView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityRewardStarView:registerEvent()
	GuildActivityRewardStarView.super.registerEvent(self);
end

function GuildActivityRewardStarView:initData()
	self.totalFoodStarLevelData = {1,2,3,4,5}
	self:initScrollCfg()
end

function GuildActivityRewardStarView:initScrollCfg()
	self.panel_2:visible(false)
	local createItemFunc = function( itemData )
		local itemView = UIBaseDef:cloneOneView(self.panel_2)
		self:updateOneItemView(itemData,itemView)
		return itemView
	end
	local updateItemFunc = function( itemData,itemView )
		self:updateOneItemView(itemData,itemView)
		return itemView
	end
	self.scrollParams = {
		{
	    	data = self.totalFoodStarLevelData,
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 0,
	        offsetY = -20,
	        widthGap = 0,
	        heightGap = 0,
	        itemRect = {x = -154,y = -80,width = 434,height = 80},
	        perFrame = 1,
	        cellWithGroup = 1
		}
	}
    self.scroll_1:styleFill(self.scrollParams)
    self.scroll_1:setScrollBorder(-20)
end

function GuildActivityRewardStarView:updateOneItemView(itemData,itemView)
	local level = tonumber(itemData)
	local data = FuncGuildActivity.getFoodLevelData( GuildActMainModel:getCurFoodId(),level )
	if data.foodLevelReward then
		itemView.mc_fivestar:showFrame(level or 1)
		-- dump(data.foodLevelReward, "某星级奖励数据")
		local rewardNum = table.length(data.foodLevelReward)
		itemView.mc_2:showFrame(rewardNum)
		local contentView = itemView.mc_2:getCurFrameView()
		for i,v in ipairs(data.foodLevelReward) do
			local params = {
	            reward=v,
	        }
			contentView["UI_"..i]:setResItemData(params)
			contentView["UI_"..i]:setResItemClickEnable(true)
			contentView["UI_"..i]:showResItemNum(true)
			local resNum,_,_ ,resType,resId = UserModel:getResInfo( v )
        	FuncCommUI.regesitShowResView(contentView["UI_"..i],resType,resNum,resId,v,true,true)
		end
	end
end

function GuildActivityRewardStarView:initView()
	-- TODO
end

function GuildActivityRewardStarView:initViewAlign()
	-- TODO
end

function GuildActivityRewardStarView:updateUI()
	-- TODO
end

function GuildActivityRewardStarView:deleteMe()
	-- TODO

	GuildActivityRewardStarView.super.deleteMe(self);
end

return GuildActivityRewardStarView;
