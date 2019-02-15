--[[
	Author: TODO
	Date:2018-07-11
	Description: TODO
]]

local ShareBossCompView = class("ShareBossCompView", UIBase);

function ShareBossCompView:ctor(winName, _itemData, _group, testArr)
    ShareBossCompView.super.ctor(self, winName)

    self.itemData = _itemData
    self.group = _group
    -- dump(self.itemData, "\n\nself.itemData=====")
    self.testArr = testArr
end

function ShareBossCompView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()

	self.bossViews = {}
	--根据数据加载界面  分为三种情况 第一种为没有幻境的情况 第二种为额外添加的最后一屏
	if self.itemData == 1 then
		self:updateBgView()
		self.mc_1:showFrame(2)
		self:updatePreviousBgView()
		self:updateNextBgView()
		if self.testArr then
			for i,v in ipairs(self.testArr) do
				local bossView = UIBaseDef:cloneOneView(self.panel_1)

				self:testBossView(bossView, v)
				bossView:addto(self._root)
				local posX = 130 + (i - 1) * 340

				--高度需要有一定的差异 中间的那个需要高于两边的
				local posY = -100 + (i - 1) % 2 * 100
				bossView:pos(posX, posY)
			end
		end
	elseif self.itemData[1] == 1 then
		self:updateBgView()
		self:updateNextBgView()
		self:updateQiZiView()
	else
		self:updateBgView()
		self:updateQiZiView()
		self:updateUI()
	end  
end 

function ShareBossCompView:registerEvent()
	ShareBossCompView.super.registerEvent(self);

	EventControler:addEventListener(ShareBossEvent.OPEN_ONE_DETAILVIEW, self.setBossViewInvisible, self)
	EventControler:addEventListener(ShareBossEvent.SET_BOSSVIEW_VISIBLE, self.setBossViewVisible, self)
	EventControler:addEventListener(ShareBossEvent.SWITCH_BOSSVIEW, self.setBossViewInvisible, self)

	if self.testArr then
		self:registClickClose("-1")
	end
end

--打开详情界面 需要隐藏掉除展示详情外的所有bossView
function ShareBossCompView:setBossViewInvisible(event)
	local _group = event.params._group
	local _index = event.params._index
	
	if self.bossViews then
		for i,v in ipairs(self.bossViews) do
			if _group == self.group and i == _index then
				v:setVisible(true)
			else
				v:setVisible(false)
			end
		end
	end
end

--关闭详情界面后 显示出所有bossView
function ShareBossCompView:setBossViewVisible()
	if self.bossViews then
		for i,v in ipairs(self.bossViews) do
			v:setVisible(true)
		end
	end
end

function ShareBossCompView:initData()
	
end

function ShareBossCompView:initView()
	self.panel_1:setVisible(false)
end

function ShareBossCompView:initViewAlign()
	-- TODO
end

--加载界面上的黑白棋子
function ShareBossCompView:updateQiZiView()
	if self.group % 2 == 1 then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(2)
	end
end

--加载当前的背景
function ShareBossCompView:updateBgView()
	local landSprite = display.newSprite(FuncRes.iconBg("dreamland_bg_dabeijing.png"))
	landSprite:addto(self.ctn_1)
	landSprite:pos(0, -40)
end

--加载当前的背景  最后一屏往右多加一张背景 防止穿帮
function ShareBossCompView:updateNextBgView()
	local landSprite2 = display.newSprite(FuncRes.iconBg("dreamland_bg_dabeijing.png"))
	landSprite2:addto(self.ctn_1)
	landSprite2:pos(1136, -40)
end

--加载当前的背景 第一屏往左多加一张背景 防止穿帮
function ShareBossCompView:updatePreviousBgView()
	local landSprite1 = display.newSprite(FuncRes.iconBg("dreamland_bg_dabeijing.png"))
	landSprite1:addto(self.ctn_1)
	landSprite1:pos(-1136, -40)
end

function ShareBossCompView:updateUI()
	--如果是第一页需要在左侧加一张背景  以防滑动时穿帮
	if self.group == 1 then
		self:updatePreviousBgView()
	end

	--根据每一页的数据加载spine
	for i,v in ipairs(self.itemData) do
		local bossView = UIBaseDef:cloneOneView(self.panel_1)

		self:updateBossView(bossView, v)
		bossView:addto(self._root)
		local posX = 130 + (i - 1) * 340

		--高度需要有一定的差异 中间的那个需要高于两边的
		local posY = -200 + (i - 1) % 2 * 100
		bossView:pos(posX, posY)
		bossView:setTouchedFunc(c_func(self.showBossDetailView, self, v, self.group, i))
		self.bossViews[i] = bossView
		local currentDetailData = ShareBossModel:getCurrentDetailData()
		if currentDetailData and currentDetailData._id ~= v._id then
			bossView:setVisible(false)
		else
			bossView:setVisible(true)
		end
	end
end

--获取当前的所有的bossView
function ShareBossCompView:getBossViews()
	return self.bossViews
end

--获取当前组件的数据
function ShareBossCompView:getBossDatas()
	return self.itemData
end

--点击spine弹出boss详情界面
function ShareBossCompView:showBossDetailView(bossData, _group, _index)
	local params = {
		_data = bossData,
		_group = _group,
		_index = _index
	}
	EventControler:dispatchEvent(ShareBossEvent.OPEN_ONE_DETAILVIEW, params) 
end

function ShareBossCompView:testBossView(bossView, id)
	local bossData = FuncShareBoss.getBossDataById(id)
	bossView.panel_name.txt_1:setString(GameConfig.getLanguage(bossData.name))

	local frame = math.floor((tonumber(bossData.star) - 1) / 2) + 1
	local addition = tonumber(bossData.star) % 2
	bossView.mc_star:showFrame(frame)
	for i = 1, frame do
		local mc_satr = bossView.mc_star.currentView["mc_"..i]
		if i == frame and addition == 1 then
			mc_satr:showFrame(1)
		else
			mc_satr:showFrame(2)
		end
	end

	local str_table = string.split(bossData.spineId[1], ",")
	local spineId = str_table[1]
	local scale = str_table[2] or 1
	local sourceCfg = FuncTreasure.getSourceDataById(spineId)
	local viewSize = sourceCfg.viewSize

	local bossSpine = FuncRes.getSpineViewBySourceId(spineId, nil, false, sourceCfg)
	bossSpine:addto(bossView.ctn_1)
	bossSpine:setScale(scale)

	bossView.panel_name:pos(20, -(363 - viewSize[2] * scale) + 100)
	bossView.mc_star:pos(90, -(363 - viewSize[2] * scale) + 60)
	bossView.panel_1:pos(40, -(363 - viewSize[2] * scale) + 20)
	bossView.mc_1:showFrame(1)
	bossView.mc_1.currentView.txt_1:setString("id:"..spineId.." h:"..viewSize[2].." s:"..scale)
end

--加载每一个界面上的每一个boss spine
function ShareBossCompView:updateBossView(bossView, data)
	local bossData = FuncShareBoss.getBossDataById(tostring(data.bossId))
	bossView.panel_name.txt_1:setString(GameConfig.getLanguage(bossData.name))

	local frame = math.floor((tonumber(bossData.star) - 1) / 2) + 1
	local addition = tonumber(bossData.star) % 2
	bossView.mc_star:showFrame(frame)
	for i = 1, frame do
		local mc_satr = bossView.mc_star.currentView["mc_"..i]
		if i == frame and addition == 1 then
			mc_satr:showFrame(1)
		else
			mc_satr:showFrame(2)
		end
	end

	local str_table = string.split(bossData.spineId[1], ",")
	local spineId = str_table[1]
	local scale = str_table[2] or 1
	local sourceCfg = FuncTreasure.getSourceDataById(spineId)
	local viewSize = sourceCfg.viewSize

	local bossSpine = FuncRes.getSpineViewBySourceId(spineId, nil, false, sourceCfg)
	bossSpine:addto(bossView.ctn_1)
	bossSpine:setScale(scale)

	bossView.panel_name:pos(20, -(363 - viewSize[2] * scale) + 100)
	bossView.mc_star:pos(90, -(363 - viewSize[2] * scale) + 60)
	bossView.panel_1:pos(40, -(363 - viewSize[2] * scale) + 20)

	local totalHp, curDamage = ShareBossModel:updateHpStatus(data)
	local currentHp = totalHp - curDamage

	--已击杀的boss 置灰 并且隐藏血条
	bossView.panel_1:setVisible(true)
	if data.isDead then
		currentHp = 0
		FilterTools.setGrayFilter(bossSpine)
		bossView.panel_1:setVisible(false)
	end
	
	bossView.panel_1.progress_1:setPercent((currentHp * 100 / totalHp))

	--未开启的幻境显示第一帧 点击按钮调用开启幻境接口
	if data.open == 0 then
		bossView.mc_1:showFrame(1)
		bossView.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.openOneShareBoss, self))
	else
		if data.isDead then
			bossView.mc_1:showFrame(3)
			local curPanel = bossView.mc_1.currentView
		else
			bossView.mc_1:showFrame(2)
			local curPanel = bossView.mc_1.currentView
			curPanel.rich_1:setString(data.findUserName)
			local time = math.ceil((data.expireTime - TimeControler:getServerTime() - 1) / 60)
			curPanel.txt_3:setString(" "..time)
			
			--参战后的幻境显示已参战
			local canzhanCount = 0
			if data.challengeCounts and table.length(data.challengeCounts) > 0 then
				for k,v in pairs(data.challengeCounts) do
					if k == UserModel:rid() then
						canzhanCount = v
						break
					end
				end	
			end
			if canzhanCount > 0 then
				curPanel.panel_1:setVisible(true)
			else
				curPanel.panel_1:setVisible(false)
			end
		end
	end
end

function ShareBossCompView:openOneShareBoss()
	ShareBossServer:openOneShareBoss(c_func(self.updateSelfBossStatus, self))
end

function  ShareBossCompView:updateSelfBossStatus(event)
	if event.error then
		echoError("————————开启幻境协战返回报错————————")
	else
		local open = event.result.data.open
		local expireTime = event.result.data.expireTime
		ShareBossModel:setOpendShareBossData(open, expireTime)
	end
end

function ShareBossCompView:deleteMe()
	-- TODO

	ShareBossCompView.super.deleteMe(self);
end

return ShareBossCompView;
