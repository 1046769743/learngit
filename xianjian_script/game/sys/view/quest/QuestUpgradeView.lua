--guan
--2017.4.8 

local QuestUpgradeView = class("QuestUpgradeView", UIBase)


function QuestUpgradeView:ctor(winName)
	echo("__________QuestUpgradeView________")
	QuestUpgradeView.super.ctor(self, winName)
end

function QuestUpgradeView:loadUIComplete()
	self:registerEvent()

	self._cellItem = self.panel_1.panel_1;
	self._cellItem:setVisible(false);

	self._upList = self.panel_1.scroll_1;
	self._lastSelectLvlIndex = nil;
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_quest_ui_009"))
	self:initUI();
end

function QuestUpgradeView:registerEvent()
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.refreshgetBtn, self)
end

--进游戏后的显示界面

function QuestUpgradeView:getEntryRewardIndex()
	local allData = FuncQuest:getUpgradeArray();

	for _, v in pairs(allData) do
		local lvl = v.condition;
		local index = v.id;
		local lvl = FuncQuest:readUpgradeQuest(index, "condition");
	
		local curLvl = UserModel:level();
		if curLvl >= lvl and TargetQuestModel:isRewardAlreadyGet(index) == false then 
			return index;
		end 
	end

	--找到第一个没有完成的
	for _, v in pairs(allData) do
		local lvl = v.condition;
		local index = v.id;
		local lvl = FuncQuest:readUpgradeQuest(index, "condition");
	
		local curLvl = UserModel:level();
		if curLvl < lvl  then 
			return index;
		end 
	end

	return allData[#allData].id;
end

function QuestUpgradeView:initUI()
	self:initUpListUI();
end

function QuestUpgradeView:refreshgetBtn()
	local index = table.length(UserModel:receiveLevelRewards())
	if index >= 1 then
		self:setRewardUI(index+1);
	end
end

function QuestUpgradeView:setRewardUI(index)
	local lvl = FuncQuest:readUpgradeQuest(index, "condition");
	local rewards = FuncQuest:readUpgradeQuest(index, "reward");

	local strLabel = self.panel_1.panel_2.txt_1;
	local str = string.format("%d级等级礼包", lvl);
	strLabel:setString(str);

	local rewardLen = table.length(rewards);
	self.panel_1.panel_2.mc_eight:showFrame(rewardLen);

	local curLvl = UserModel:level();
	if curLvl >= lvl and TargetQuestModel:isRewardAlreadyGet(index) == false then
		self.panel_1.btn_1:setVisible(true);
	else 
		self.panel_1.btn_1:setVisible(false);
	end 

	self.panel_1.panel_get:visible(TargetQuestModel:isRewardAlreadyGet(index))

	--领取
	self.panel_1.btn_1:setTouchedFunc(c_func(self.rewardsGet, self, index));

	--奖励图标
	for i, v in pairs(rewards) do
		local reward = string.split(rewards[i], ",");
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];

		local commonUI = self.panel_1.panel_2.mc_eight:getCurFrameView()["UI_" .. tostring(i)];
		commonUI:setResItemData({reward = rewards[i]});
		commonUI:showResItemName(false);
		commonUI:showResItemRedPoint(false);
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, rewards[i], true, true);
	end

end

function QuestUpgradeView:rewardsGet(lvlIndex)
	QuestServer:getLvlQuestReward(lvlIndex, c_func(self.rewardCallBack, self, lvlIndex))
end

function QuestUpgradeView:rewardCallBack(lvlIndex)
	local rewards = FuncQuest:readUpgradeQuest(lvlIndex, "reward");
	-- FuncCommUI.startFullScreenRewardView(rewards);
	FuncCommUI.startRewardView(rewards)
	--已领取
	self._lastSelectView.panel_1:setVisible(true);
	--领取隐藏
	self.panel_1.btn_1:setVisible(false);
	self.panel_1.panel_get:visible(true)
	local index = self._lastSelectLvlIndex + 1
	local data = FuncQuest:getUpgradeArray()
	if index <= #data then
		-- self:setRewardUI(index)
		self:initUpListUI()
		
	end
	EventControler:dispatchEvent(QuestEvent.UPGRADE_GET_REWARD, 
        {});
end

function QuestUpgradeView:initUpListUI()
	local scrollData = FuncQuest:getUpgradeArray();

	local createItemFunc = function (itemData)
		local baseCell = UIBaseDef:cloneOneView(self._cellItem);
		self:updateLvlItem(baseCell, itemData);
		return baseCell;
	end

	local scrollParams = { 
		{
	        data = scrollData,
	        createFunc = createItemFunc,
	        offsetX = 15,
	        offsetY = 0,
	        widthGap = 10,
	        heightGap = 0,
	        itemRect = {x = 0, y = 0, width = 161, height = 176},
	    }
	};
	self._upList:cancleCacheView();
	self._upList:styleFill(scrollParams);
	self._upList:hideDragBar();

	--选中默认的
	local rewardIndex = self:getEntryRewardIndex(); 
	local entryData =  FuncQuest:getUpgradeArray()[rewardIndex];
	local cell = self._upList:getViewByData(entryData);

	self:changeSelectLvl(rewardIndex, cell);

	self._upList:gotoTargetPos(rewardIndex, 1);
end

function QuestUpgradeView:updateLvlItem(baseCell, itemData)
	local lvl = itemData.condition;
	local index = itemData.id;

	local strLabel = baseCell.txt_1;
	local str = string.format("%d级", lvl);

	strLabel:setString(str);

	--点击
	baseCell.btn_1:setTouchedFunc(c_func(self.changeSelectLvl, self, index, baseCell));

	--最后一个不显示index
	local totalNum = FuncQuest:getUpdateArrayLen();

	-- if index == totalNum then 
	-- 	baseCell.scale9_1:setVisible(false);
	-- end 

	local ctn = baseCell.ctn_2
	ctn:removeAllChildren()
	--是否已领取
	if TargetQuestModel:isRewardAlreadyGet(index) == true then 
		baseCell.panel_1:setVisible(true);
		baseCell.panel_red:visible(false)
	else 
		baseCell.panel_1:setVisible(false);
		local curLvl = UserModel:level();
		if curLvl >= lvl and TargetQuestModel:isRewardAlreadyGet(index) == false then
			-- 屏蔽特效
			-- local lockAni = self:createUIArmature("UI_task","UI_task_jianglixunhuan", ctn, true, function ()
   --          end)
            -- 变成现实红点
            baseCell.panel_red:visible(true)
        else
        	baseCell.panel_red:visible(false)
		end 
	end 

	local rewards = FuncQuest:readUpgradeQuest(index, "reward");
	--icon
	local lastReward = string.split(rewards[#rewards], ",");
	local lastIconId = lastReward[table.length(lastReward) - 1];
	local lastType = lastReward[1];

	local iconPath = FuncRes.iconRes(lastType, lastIconId);
	local iconSp = display.newSprite(iconPath); 

	local ctn = baseCell.btn_1:getUpPanel().ctn_1;
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", ctn, false, GameVars.emptyFunc);
	FuncArmature.changeBoneDisplay(iconAnim, "node", iconSp);

	--背景显示
	local mc_1 = baseCell.btn_1:getUpPanel().mc_1;
	mc_1:showFrame(index);


	local scrollData = FuncQuest:getUpgradeArray();
	local iddata = scrollData[tonumber(itemData.id)+1]
	local newcondition = nil
	if iddata ~= nil then
		newcondition = iddata.condition
	end

	local percent = 0
	local userlevel =  UserModel:level()
	if userlevel <= tonumber(lvl) then
		percent = 0
	else
		if newcondition ~= nil then
			if userlevel < newcondition then
				local spacing = tonumber(newcondition) - tonumber(lvl)
				local newlevel = userlevel - tonumber(lvl)
				percent = (newlevel*100)/spacing
			else
				percent = 100
			end
		end
	end
end

function QuestUpgradeView:changeSelectLvl(index, baseCell)
	if self._lastSelectLvlIndex == index then 
		return;
	end 

	self:setRewardUI(index);

	--把上一个选择的变为没有选择状态
	local lockAni = self:createUIArmature("UI_task","UI_task_jianglixunhuan", baseCell.ctn_2, true, function ()
    end)

	if self._lastSelectView ~= nil then 
		if self._lastSelectView.ctn_2 ~= nil then
			self._lastSelectView.ctn_2:removeAllChildren()
		end
	end 

	self._lastSelectLvlIndex = index;
	self._lastSelectView = baseCell;
end


return QuestUpgradeView