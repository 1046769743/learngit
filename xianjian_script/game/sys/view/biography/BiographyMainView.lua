--[[
	奇侠传记View
	author: lcy
	add: 2018.7.20
]]

local BiographyMainView = class("BiographyMainView", UIBase)

function BiographyMainView:ctor(winName, partnerId)
	BiographyMainView.super.ctor(self, winName)

	self._partnerId = partnerId -- 当前选中的奇侠
	self._curIdx = 1 -- 当前选中的任务索引
	self.taskData = FuncBiography.getTaskByPartnerId(partnerId)
	self.selectAnim = nil
end

function BiographyMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function BiographyMainView:registerEvent()
	self.btn_1:setTap(c_func(self.onClickHelp, self))
	self.btn_back:setTap(c_func(self.onClickBack, self))

	EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI, self.updateUI, self)
end

function BiographyMainView:initData()
	-- 当前的任务id
	local partnerId,curNodeId = BiographyModel:getCurrentTaskInfo()

	local first0 = nil
	-- 如果当前任务在此页面则指向当前任务，否则指向第一个状态为0的
	for idx,nodeId in ipairs(self.taskData) do
		-- 找到当前正在进行的任务
		if nodeId == curNodeId then
			self._curIdx = idx

			return
		end
		-- 赋值第一个为0的
		if not first0 and BiographyModel:getNodeInfo(nodeId).status == 0 then
			first0 = idx
			break
		end
	end

	if first0 then self._curIdx = first0 end
end

function BiographyMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.LeftTop)
end

function BiographyMainView:initView()
	-- body
end

function BiographyMainView:updateUI()
	self:updateIcon()
	self:updateBox()
	self:updateLine()
	self:updateBtnAndDes()
end

-- 更新按钮和描述
function BiographyMainView:updateBtnAndDes()
	-- 当前的任务id
	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	-- 当前没有在执行的任务
	if not partnerId then
		local curNodeId = BiographyModel:getCurrentNodeId()
	end

	local nowNodeId = self.taskData[self._curIdx]

	self.mc_1:visible(true)

	local partnerName = FuncPartner.getPartnerName(self._partnerId)
	-- 侧方标题
	self.mc_t1:showFrame(string.utf8len(partnerName) < 4 and 1 or 2)
	self.mc_t1.currentView.txt_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getTitle(), partnerName))

	-- 正在做的就是这个任务
	if curNodeId == nowNodeId then
		self.mc_1:showFrame(2) --  放弃
		self.mc_1.currentView.btn_1:setTap(c_func(self.onGetClick,self,nowNodeId,0,partnerId))
		-- 显示节点名称
		-- self.panel_t2.txt_1:visible(true)
		self.panel_t2.txt_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(nowNodeId, "nodeName"), partnerName))
		-- 显示当前任务进度的描述
		self.panel_t2.rich_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyNodeValueByKey(nowNodeId, step, "describe"), partnerName))
	else
		local nodeInfo = BiographyModel:getNodeInfo(nowNodeId)

		-- 宝箱不可领取状态
		if nodeInfo.status == 0 then
			-- 显示文本
			-- self.panel_t2.txt_1:visible(true)
			-- 显示接取条件几个字
			self.panel_t2.txt_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getCondition(), partnerName))
			-- 显示描述1
			self.panel_t2.rich_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(nowNodeId, "describe"), partnerName))
			self.mc_1:showFrame(1) -- 接取
			-- 是某满足条件
			local canGet,condition = BiographyModel:isNodeIdCanFetch(nowNodeId)
			if not canGet then
				FilterTools.setGrayFilter(self.mc_1.currentView.btn_1)
			else
				FilterTools.clearFilter(self.mc_1.currentView.btn_1)
			end
			-- 显示接取
			self.mc_1:visible(true)

			-- 当前没有正在执行的任务
			if not partnerId then
				-- 不满足条件
				if not canGet then
					self.mc_1.currentView.btn_1:setTap(c_func(self.onGetClick,self,nowNodeId,2,condition))
				else
					self.mc_1.currentView.btn_1:setTap(c_func(self.onGetClick,self,nowNodeId,1))
				end				
			else
				-- 显示节点名称
				self.panel_t2.txt_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(nowNodeId, "nodeName"), partnerName))
				-- 不满足条件
				if not canGet then
					self.mc_1.currentView.btn_1:setTap(c_func(self.onGetClick,self,nowNodeId,2,condition))
				else
					-- 满足但有其他正在做的任务
					self.mc_1.currentView.btn_1:setTap(c_func(self.onGetClick,self,nowNodeId,3,partnerId))
				end				
			end
		else-- 宝箱可领或宝箱已领
			-- 隐藏领取条件描述
			-- self.panel_t2.txt_1:visible(true)
			-- 显示
			self.panel_t2.txt_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(nowNodeId, "nodeName"), partnerName))
			-- 显示描述2
			self.panel_t2.rich_1:setString(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(nowNodeId, "describe2"), partnerName))
			-- 隐藏接取
			self.mc_1:visible(false)

		end
	end
end

-- 更新线
function BiographyMainView:updateLine()
	for i=1,3 do
		local nodeId = self.taskData[i]
		local nodeInfo = BiographyModel:getNodeInfo(nodeId)
		if nodeInfo.status ~= 0 then
			self["mc_x"..i]:showFrame(2)
		else
			self["mc_x"..i]:showFrame(1)
		end
	end
end

-- 更新图标
function BiographyMainView:updateIcon(idx)
	for i=1,4 do
		if not idx or idx == i then
			local icon = self["panel_j"..i]
			if self._curIdx == i then
				-- 当前选中的加特效
				-- self.selectAnim
				if not self.selectAnim then
					self.selectAnim = self:createUIArmature("UI_qixiazhuanji","UI_qixiazhuanji_kuobo",icon.ctn_1, true, GameVars.emptyFunc)
				else
					self.selectAnim:parent(icon.ctn_1)
				end
			else
				-- icon:showFrame(1)
				-- 非选中的去掉特效
			end

			if i > BiographyModel:getMaxIdxByPartner(self._partnerId) then
				-- 置灰
				FilterTools.setGrayFilter(icon)
			else
				-- 取消置灰
				FilterTools.clearFilter(icon)
			end

			icon:setTouchedFunc(c_func(self.onIconClick, self, i))
		end
	end
end

-- 更新箱子
function BiographyMainView:updateBox(idx)
	for i=1,4 do
		-- 更新对应箱子
		if not idx or idx == i then
			-- 节点id
			local nodeId = self.taskData[i]
			local nodeInfo = BiographyModel:getNodeInfo(nodeId)
			local nowBoxMc = self["mc_b"..i]

			if nodeInfo.status == 2 then -- 已领取	
				nowBoxMc:showFrame(2)
				-- 注册事件
				local touchview = self:playBoxAnim(i, false)
				touchview.currentView:setTouchedFunc(c_func(self.onBoxClick, self, i, nodeInfo.status))
			else
				nowBoxMc:showFrame(1)
				-- todo给箱子加个特效
				if nodeInfo.status == 1 then					
					-- 加特效
					local touchview = self:playBoxAnim(i, true)
					touchview.currentView:setTouchedFunc(c_func(self.onBoxClick, self, i, nodeInfo.status))
				else
					local touchview = self:playBoxAnim(i, false)
					touchview.currentView:setTouchedFunc(c_func(self.onBoxClick, self, i, nodeInfo.status))
				end
			end
		end
	end
end

-- 处理特效
function BiographyMainView:playBoxAnim(idx, isplay)
	local ctnBox = self["ctn_x"..idx]
	local mc_box = self["mc_b"..idx]

	ctnBox:removeAllChildren()

	if isplay then
		mc_box:visible(false)
		local mcView = UIBaseDef:cloneOneView(mc_box)
		mcView:pos(0,0)
		local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
		FuncArmature.changeBoneDisplay(anim,"node",mcView)
		anim:startPlay(true)

		return mcView
	else
		mc_box:visible(true)
		ctnBox:removeAllChildren()
	end

	return mc_box
end

-- 点图标
function BiographyMainView:onIconClick(idx)
	if idx ~= self._curIdx and idx <= BiographyModel:getMaxIdxByPartner(self._partnerId) then
		self._curIdx = idx
		self:updateIcon()
		self:updateBtnAndDes()
	end
end

-- 点箱子
function BiographyMainView:onBoxClick(idx, status)
	if status == 0 then
		-- 弹预览
		local rewards = FuncBiography.getBiographyValueByKey(self.taskData[idx], "reward")
		WindowControler:showWindow("BiographyRewardView", rewards)
	elseif status == 1 then
		-- 发奖励
		BiographyServer:getBoxReward(self.taskData[idx],function(data)
			-- 弹奖励
			local result = data.result
			if result.data and result.data.reward then
				FuncCommUI.startFullScreenRewardView(result.data.reward)
			end
		end)
	else
		-- 不管
	end
end

--[[
	点接取 isGet 0放弃 1接取 2置灰 3有正在进行的传记
	为 2 时 params 为不满足条件的原因
	为 3 时 params 为正在进行传记的奇侠ID
]]
function BiographyMainView:onGetClick(nodeId, isGet, params)
	if isGet == 0 then
		local title,des = FuncBiography.getGiveUp()
		title = GameConfig.getLanguage(title)
		des = GameConfig.getLanguageWithSwap(des,FuncPartner.getPartnerName(self._partnerId))
		-- 放弃
		WindowControler:showWindow("BiographySureView", {
			sure = function()
				BiographyServer:changeCurrentPartner("0")		
			end,
			title = title,
			des = des,
		})
	elseif isGet == 1 then
		-- 接取
		BiographyServer:changeCurrentPartner(nodeId,function ( data )
			if data.result then
				-- 弹一个接取到的界面
				WindowControler:showWindow("BiographyOpenView", {
				    partnerId = self._partnerId,
				    nodeId = nodeId,
				    callBack = function()
				    	-- 关闭后打开这个界面
				    	WindowControler:showWindow("QuestMainView",FuncQuest.QUEST_TYPE.ACHIEVEMENT)
				    end
				})
			else
				echoError("error 接取任务没有返回")
			end
		end)
	elseif isGet == 3 then
		-- 有正在进行的传记
		WindowControler:showTips(GameConfig.getLanguageWithSwap(FuncBiography.getHasBiographyTips(), FuncPartner.getPartnerName(params)))
	elseif isGet == 2 then
		-- 不可点的弹提示
		local tid = FuncBiography.getDesByCondition(params)
		WindowControler:showTips(GameConfig.getLanguageWithSwap(tid, FuncPartner.getPartnerName(self._partnerId), params.v))
	end
end

function BiographyMainView:onClickBack()
	self:startHide()
end

function BiographyMainView:onClickHelp()
	WindowControler:showWindow("BiographyGuideView")
end

return BiographyMainView