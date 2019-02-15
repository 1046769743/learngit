--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- 竞技场规则说明界面

local ArenaRulesView = class("ArenaRulesView", MultiScrollBaseView)

function ArenaRulesView:ctor(winName)
    ArenaRulesView.super.ctor(self, winName)
end

function ArenaRulesView:loadUIComplete()
	self:registerEvent()
    self:initData()
    self:initView()
    -- self:createScroller(self.scroll_list3,self.scrollerCfg)
    self:initScrollCfg()
	self:setViewAlign()
    self:updateUI()
end 

function ArenaRulesView:registerEvent()
	ArenaRulesView.super.registerEvent()
	self.UI_1.btn_1:setTap(c_func(self.close,self))
	self:registClickClose("out")
end

function ArenaRulesView:initView() 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_pvp_009"))
end

function ArenaRulesView:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close2, UIAlignTypes.RightTop)
	--竖向适配
	--local scale = GameVars.height*1.0/GameVars.gameResHeight
	--self.scale9_1:runAction(act.moveby(0,0, (GameVars.height-GameVars.gameResHeight)/2))
	--local bgSize = self.scale9_1:getContentSize()
	--self.scale9_1:setContentSize(cc.size(bgSize.width, bgSize.height *scale))
	--FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_list3, UIAlignTypes.MiddleTop, scale)
end

-- 初始化数据
function ArenaRulesView:initData()
    self.palyerReward = {1}
    self.rankAwardList = FuncPvp.getRankReward()
end

-- 滚动配置
function ArenaRulesView:initScrollCfg()
    self.panel_rulehead:setVisible(false)
    self.panel_ruleinfo:setVisible(false)
    self.panel_rulereward:setVisible(false)

    local createRewardHeadFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_rulehead)
		self:initHeadItem(view, itemData)
        return view
    end

    local createRuleFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_ruleinfo)
		self:initRuleItem(view, itemData)
        return view
    end

    local createRankRewardFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_rulereward)
		self:initRewardItem(view, itemData)
        return view
    end

    self.scrollParams = {
        {
            data = self.palyerReward,
            createFunc = createRewardHeadFunc,
            perNums = 1,
            offsetX = 50,
            offsetY = 30,
            itemRect = {x=0,y=-193,width=716.6,height=193},
            heightGap = 0,
            perFrame = 2,
        },
        {
            data = {1}, 
            createFunc = createRuleFunc,
            perNums = 1,
            offsetX = 50,
            offsetY = 10,
            itemRect = {x=0,y=-335,width=763,height=335},
            heightGap = 0,
            perFrame = 2,
        },
        {
            data = self.rankAwardList,
            createFunc = createRankRewardFunc,
            perNums = 1,
            offsetX = 115,
            offsetY = -20,
            itemRect = {x=0,y=-41,width=654,height=41},
            heightGap = 5,
            perFrame = 2,
        },
    }
end

function ArenaRulesView:updateUI()
    -- 创建滚动条
    self.scroll_list3:styleFill(self.scrollParams)
 --   self.scroll_list3:enableMarginBluring(0.15);
end


-- 更新规则说明Item
function ArenaRulesView:initRuleItem(itemView,data)
	itemView.txt_2:setString(PVPModel:getHistoryTopRank())
--	itemView.txt_1:setString(GameConfig.getLanguage('tid_pvp_1016'))
    itemView.txt_3:setString(GameConfig.getLanguage('tid_pvp_1017'))
    itemView.txt_4:setString(GameConfig.getLanguage('tid_pvp_1018'))
    itemView.txt_5:setString(GameConfig.getLanguage('tid_pvp_1019'))
    itemView.txt_6:setString(GameConfig.getLanguage('tid_pvp_1020'))
    itemView.txt_7:setString(GameConfig.getLanguage('tid_pvp_1021'))
end

-- 更新当前奖励item
function ArenaRulesView:initHeadItem(itemPanel, data)
	local maxRewardRank = FuncPvp.getMaxRewardRank()
	local currentRank = PVPModel:getUserRank()
	local currentRankReward = FuncPvp.getRewardByRank(currentRank)
	itemPanel.txt_2:setString(currentRank)
	if not currentRankReward then
		itemPanel.mc_1:showFrame(2)
		local itemView = itemPanel.mc_1.currentView
		itemView.txt_1:setString(GameConfig.getLanguage('tid_pvp_1025'))
	else
		itemPanel.mc_1:showFrame(1)
		local itemView = itemPanel.mc_1.currentView
		itemPanel.txt_1:setString(GameConfig.getLanguage('tid_pvp_1014'))
		itemView.panel_1.txt_1:setString(GameConfig.getLanguage('tid_pvp_1015'))
		-- 设置玩家当前排名可获得的奖励物品
		self:initCurrentReward(currentRankReward, itemView)
	end
	
end

-- 更新排名奖励item
function ArenaRulesView:initRewardItem(itemView, data)
	local rank = data.rank
	itemView.txt_1:setString(GameConfig.getLanguageWithSwap('tid_pvp_1024', rank))
	local reward = data.reward
	for i=1, 3 do 
		local rewardStr = reward[i]
		local txtView = itemView['txt_'..(i+1)]
		if rewardStr then
			local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(rewardStr)
			local iconName = FuncRes.iconRes(resType)
			local icon = display.newSprite(iconName)
			local iconCtn = itemView['panel_reward'..i].ctn_reward_pic
			icon:addto(iconCtn):scaleTo(0, 0.6)
			txtView:setString(needNum)
		else
			txtView:visible(false)
		end
	end
end

--玩家当前可获得的排名奖励
function ArenaRulesView:initCurrentReward(reward, view)
	for i=1,3 do
		local resStr = reward[i]
		local panel = view.panel_1['panel_'..i] 
		if resStr then
			local needNum,hasNum,isEnough ,resType,itemId = UserModel:getResInfo(resStr)
			--判断是道具 还是其他资源  除了道具  其他资源走相同的
			local quality = FuncDataResource.getQualityById( resType,itemId )
			local iconPath = FuncRes.iconRes(resType,itemId)
			local icon = display.newSprite(iconPath)

			--self.txt_goodsshuliang:setString(needNum)
			panel.mc_1:showFrame(quality)
			panel.ctn_1:removeAllChildren()
			icon:addto(panel.ctn_1):anchor(0,1)
			panel.txt_1:setString(needNum)
		else
			panel:visible(false)
		end
	end
end


-- 关闭
function ArenaRulesView:close()
    self:startHide()
end

return ArenaRulesView
