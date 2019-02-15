--[[
	目标里的奇侠传记界面
]]

local QuestBiographyView = class("QuestBiographyView", UIBase)

function QuestBiographyView:ctor(winName)
	QuestBiographyView.super.ctor(self, winName)
end

function QuestBiographyView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function QuestBiographyView:registerEvent()
	-- self:registClickClose("out")
	-- self:registClickClose(nil,nil,false,false)
	EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI, self.updateUI, self)
end

function QuestBiographyView:initData()
	-- body
end

function QuestBiographyView:initViewAlign()
	-- body
end

function QuestBiographyView:initView()
	-- body
end

function QuestBiographyView:updateUI()
	-- 能进到这个界面一定有传记任务
	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	if not partnerId then return end
	
	-- 标题
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_quest_ui_010"))
	-- 奇侠名
	local partnerName = FuncPartner.getPartnerName(partnerId)
	self.txt_2:setString(partnerName)
	-- 节点名
	self.txt_jiedian:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(curNodeId, "nodeName"), partnerName))
	-- 整体描述
	self.rich_2:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(curNodeId, "describe2"), partnerName))
	-- 详情描述
	self.rich_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "describe"), partnerName))
	-- 处理奖励
	local rewards = FuncBiography.getBiographyValueByKey(curNodeId, "reward")
	local maxNum = 4
	for i=1,maxNum do
		local item = self["UI_" .. (i + 1)]
		if i <= #rewards then
			item:visible(true)
			item:setRewardItemData({reward = rewards[i]})
			item:showResItemName(true, true)

			local reward = string.split(rewards[i], ",")
			FuncCommUI.regesitShowResView(item, reward[1], reward[#reward], reward[#reward - 1], rewards[i])
		else
			item:visible(false)
		end
	end

	-- 处理按钮
	-- 放弃
	self.btn_fangqi:setTap(c_func(self.onClickGiveUp,self,partnerId))
	-- 前往
	self.btn_qianwang:setTap(c_func(self.onClickGo,self,partnerId,curNodeId,step))
end

-- 放弃
function QuestBiographyView:onClickGiveUp(partnerId)
	local title,des = FuncBiography.getGiveUp()
	title = GameConfig.getLanguage(title)
	des = GameConfig.getLanguageWithSwap(des,FuncPartner.getPartnerName(partnerId))
	-- 放弃
	WindowControler:showWindow("BiographySureView", {
		sure = function()
			BiographyServer:changeCurrentPartner("0",function()
				-- 换到目标页签
				WindowControler:showWindow("QuestMainView")
			end)		
		end,
		title = title,
		des = des,
	})
end

-- 前往
function QuestBiographyView:onClickGo(partnerId,curNodeId,step)
	-- 发消息，关界面
	local spaceName = FuncChapter.getSpaceNameByMapId(FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "map")[1])
-- echoError("去这里",spaceName)
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_NEAR_ONE_SPACE,{spaceName = spaceName})
end

return QuestBiographyView