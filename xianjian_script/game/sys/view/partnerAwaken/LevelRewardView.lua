local LevelRewardView = class("LevelRewardView", UIBase);

local dataCfg = {
    [1] = {reward = 1,level = 4 },
    [2] = {reward = 1,level = 5 },
    [3] = {reward = 1,level = 7 },
    [4] = {reward = 10,level = 13 },
}

function LevelRewardView:ctor(winName,isLevel)
    LevelRewardView.super.ctor(self, winName);
    self.isLevel = isLevel
end

function LevelRewardView:loadUIComplete()
    self:registerEvent()
    self:initData()
    self:initUI()
end 

function LevelRewardView:initData()
	local currentLevel = UserModel:level()
    local showLevel = LS:prv():get("LevelUpRewardShow",-1)
    local rewardNum = 13
    self.enterType = 1
    echo("___________showLevel === ",showLevel)
    if tonumber(showLevel) == -1 then
        for i = 4,1,-1 do
            local level = dataCfg[i].level
            if currentLevel >= level then
                showLevel = level
                self.enterType = 2
                break
            end   
            
            rewardNum = rewardNum - dataCfg[i].reward
        end 
    end
    for i = 1, 4 do
        if dataCfg[i].level == tonumber(showLevel)  then
            self.showIndex = i
            if self.enterType == 1 then
                rewardNum = dataCfg[i].reward
            end
            break
        end
    end
	self.showData =  {} 
    self.showData.level = dataCfg[self.showIndex].level
    self.showData.reward = rewardNum
end

function LevelRewardView:initUI( )
    
    --显示
    for i = 1,4 do
    	if i > self.showIndex then 
    		local level = dataCfg[i].level
    		self.panel_di["txt_"..i]:setString(level..GameConfig.getLanguage("#tid_level_reward_001"))
    	else
    		self.panel_di["panel_kuai"..i]:visible(false)
    		self.panel_di["panel_xiangg"..i]:visible(false)
    		self.panel_di["txt_"..i]:visible(false)
    	end
    end

    -- 奖励
    if self.enterType == 1 then
        self.panel_xy.txt_1:setString(GameConfig.getLanguage("#tid_level_reward_002"))
    elseif self.enterType == 2 then
        self.panel_xy.txt_1:setString(GameConfig.getLanguage("#tid_level_reward_003"))
    end
    local reward = self.showData.reward
    self.panel_xy.txt_2:setString(reward)
    -- self.panel_xy.txt_4:setString("个三皇化相领")
    -- 下阶段预告
    if self.showIndex >= 4 then
    	self.panel_bao.mc_1:showFrame(2)
    else
		self.panel_bao.mc_1:showFrame(1)
		local panel = self.panel_bao.mc_1.currentView
		local nextIndex = self.showIndex + 1
		local nextLevel = dataCfg[nextIndex].level
		local nextReward = dataCfg[nextIndex].reward

		if nextLevel >= 10 then
			panel.mc_num:showFrame(2)
			local a,b = math.modf(nextLevel/10)
            local bb = b*10+1
            if bb == 10 then
                bb = 0
            end
			panel.mc_num.currentView.mc_12:showFrame(bb)
			panel.mc_num.currentView.mc_11:showFrame(a+1)
		else
			panel.mc_num:showFrame(1)
			panel.mc_num.currentView.mc_1:showFrame(nextLevel+1)
		end
        local _str = string.format(GameConfig.getLanguage("#tid_level_reward_004"),tostring(nextReward))
		panel.txt_2:setString(_str)
    end

end



function LevelRewardView:registerEvent()
    LevelRewardView.super.registerEvent();

    self:registClickClose(1, c_func( function()
        self:disabledUIClick(  )

        self:startHide()

        if self.showIndex == 4 then
            -- 跳转到三皇抽卡
            if not TutorialManager.getInstance():isTutoring() then
                WindowControler:showWindow("GatherSoulMainView",2);
            end
        end
    end , self))
end


return LevelRewardView;
   