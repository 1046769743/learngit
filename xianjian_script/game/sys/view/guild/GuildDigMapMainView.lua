--仙盟藏宝图主界面
local GuildDigMapMainView = class("GuildDigMapMainView", UIBase);

function GuildDigMapMainView:ctor(winName,_type)
    GuildDigMapMainView.super.ctor(self, winName);
end

function GuildDigMapMainView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self.node = display.newNode()
    self.node:setContentSize(cc.size(0,0))
    self.node:pos(0,0)
    self.node:anchor(0,0)
    self.node:addto(self)
    self.node:setTouchEnabled(false)
    self.node:setTouchSwallowEnabled(true)

	self:initData()
end

function GuildDigMapMainView:registerEvent()
	-- body
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self.btn_wen:setTouchedFunc(c_func(self.questionmark, self),nil,true);
	EventControler:addEventListener(GuildEvent.REFRESH_DIG_MAP_MAIN_VIEW, self.initData, self)
end

function GuildDigMapMainView:initData()  ----获取地图数据  刷新地图的状态
	local function _callback( event )
		if event.result then
			local data = event.result.data.digs
			local digTool = event.result.data.digTool or 0
			self.digTool = digTool
			if data then
				EventControler:dispatchEvent(GuildEvent.REFRESH_DIGTOOLNUM,{digTool = digTool})
				self:initUI(data)
			end
		end
	end
	GuildServer:getGuildDigList(_callback)
end

----地图气泡状态的显示
function GuildDigMapMainView:initUI(data)
	self.panel_1:visible(false)
	self:delayCall(function()
		local iconView
		local length = FuncGuild.getDigRewardLength()
		for i = 1,length do
			self:removeChildByTag(i)   ---- 先移除iconview 避免重复创建
		end
		for i = 1,length do
			iconView = UIBaseDef:cloneOneView(self.panel_1):addTo(self.node)
			iconView:setTag(i)
			iconView.UI_1:visible(false)
			iconView.panel_1:visible(false)
			iconView.mc_1:visible(false)
			-- dump(data,"data =================== ")
			for k,v in pairs(data) do
				if tonumber(k) == i then
					local position = FuncGuild.getDigMapPosition(k)[1]
					local arr = string.split(position,",")
					iconView:setPosition(arr[1],arr[2])
					iconView.btn_1:setTap(c_func(self.clickBubble,self,k))
					-- if table.length(v) > 1 then
					if v.name then
						iconView.panel_1:visible(true)
						iconView.panel_1.txt_1:setString(tostring(v.name))
						iconView.UI_1:visible(true)
						iconView.mc_1:visible(true)
						-- dump(FuncGuild.getBestGoodsFromConfigs(k),"reward= = = = == ")
						local reward = FuncGuild.getBestGoodsFromConfigs(k)[1]
						iconView.UI_1:setResItemData({reward =reward})
						-- dump(reward,"reward ========== ")
						iconView.UI_1.panelInfo.mc_kuang:setVisible(false)
						iconView.UI_1.panelInfo.txt_goodsshuliang:setVisible(false)
						local rewardData = string.split(reward,",")
						local quility = FuncDataResource.getQualityById( rewardData[1],rewardData[2] )
						iconView.mc_1:showFrame(quility)
					end
				end
			end
			-- dump(arr,"position = = = = = = ")
		end
	end,0.05)
end

----点击气泡  挖宝
function GuildDigMapMainView:clickBubble( id )
	-- echo("id = = = = = ",id)
	local function _Callback( event )
		if event.result then
			if self.digTool <= 0 then
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_dig_001"))
				return
			end
			local function _callback(_param)
				if _param.result then
					self.node:visible(false)
					local reward = _param.result.data.reward
					local digTool = _param.result.data.dirtyList.u.guildExt.digTool
					local rewardArr = reward[1]
					local rewardLit = string.split(rewardArr,",")
					local configs = FuncGuild.getBestGoodsFromConfigs(id)[1]
					local configsLit = string.split(configs,",")
					local isBest = false
					-- echo("rewardLit = = = = = = = = ",rewardLit[2])
					-- echo("configsLit = = = = = = = ",configsLit[2])
					if rewardLit[2] == configsLit[2] then   ---- 判断当前出的物品是不是极品
						isBest = true
					end
					local isExchange = false                ---- 判断是否有宝箱可以兑换 如果有 奖励展示界面需要处理
					local treasureList = FuncGuild.getAllExchangeData()
					for i = 1,table.length(treasureList) do
						if GuildModel:boxExchaneIsOk(i) then
							isExchange = true
						end
					end

					local data = event.result.data.digs
					self.digTool = event.result.data.digTool or 0
					local position = FuncGuild.getDigMapPosition(id)[1]
					local arr = string.split(position,",")
					self.ctn_1:setPosition(arr[1]+120,arr[2]-90)
					self.ctn_1:removeAllChildren()
					local wabaoAni = self:createUIArmature("UI_xianmeng_keji","UI_xianmeng_keji_wabao",self.ctn_1, true, GameVars.emptyFunc)
					self:delayCall(function( )
						self.ctn_1:removeAllChildren()
						self.node:visible(true)
 	        			----奖励界面
						WindowControler:showWindow("GuildDigRewardView", reward , FuncGuild.guildDig_Reward_From.DIGREWARD , nil, isBest , isExchange)
						----刷新地图
						EventControler:dispatchEvent(GuildEvent.REFRESH_DIG_MAP_MAIN_VIEW)
  	        		end,1.2)
					self.digTool = digTool
					----刷新铲子数量
					EventControler:dispatchEvent(GuildEvent.REFRESH_DIGTOOLNUM,{digTool = digTool})
					----刷新宝库和心愿界面
					EventControler:dispatchEvent(GuildEvent.REFRESH_TREASURE_MAIN_VIEW)
				else
					----错误情况
				end
			end
			local params = {
				id = id,
			}
			GuildServer:sendGuildDigBox(params,_callback)
		end
	end
	GuildServer:getGuildDigList(_Callback)
end

----适配
function GuildDigMapMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1,UIAlignTypes.RightTop)
end

----弹出获取途径
function GuildDigMapMainView:getItemDataPath(itemID)
	WindowControler:showWindow("GetWayListView",itemID)
end

-- 点击问号
function GuildDigMapMainView:questionmark()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.TAIQINGDIAN)
end

function GuildDigMapMainView:press_btn_close()
	self.node:setVisible(false)
	self:startHide()
end

return GuildDigMapMainView;
