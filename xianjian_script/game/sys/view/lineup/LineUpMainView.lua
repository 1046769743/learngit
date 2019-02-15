--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-主界面
]]
local LineUpMainView = class("LineUpMainView", UIBase)

function LineUpMainView:ctor( winName )
	LineUpMainView.super.ctor(self, winName)

	self._centerParnters = {} -- 存放中间的人物
end

function LineUpMainView:registerEvent()
	LineUpMainView.super.registerEvent(self)
	EventControler:addEventListener(LineUpEvent.PRAISE_UPDATE_EVENT, self.updateHeart, self)
    EventControler:addEventListener(LineUpEvent.PARTNER_FORMATION_UPDATE_EVENT, self.updateCenterHero, self)
    EventControler:addEventListener(GarmentEvent.GARMENT_CHANGE_ONE, self.updateCenterHero, self)
    EventControler:addEventListener(LineUpEvent.TREASURE_FORMATION_UPDATE_EVENT, self.updateCenterTreasure, self)
    EventControler:addEventListener(LineUpEvent.BG_UPDATE_EVENT, self.updateBg, self)
    self.panel_back.btn_back:setTap(c_func(self.press_btn_close, self))
end

-- 适配
function LineUpMainView:setViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zan, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightBottom)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1, UIAlignTypes.MiddleBottom, 1, 0)
end

function LineUpMainView:loadUIComplete()
	self:initVar()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

function LineUpMainView:updateUI()
	self:updateBottom()
	self:updateCenter()
	self:updateBg()
end
-- 背景(有previewId时认为是预览情况强行显示)
function LineUpMainView:updateBg(previewId)
	local bgId = previewId or LineUpModel:getBackground()
	-- 更换操作
	self.panel_bao.ctn_daBg:removeAllChildren()
	-- 图片
	local _img = FuncLineUp.getImageById(bgId)
	local _sp = display.newSprite(_img)
	_sp:addTo(self.panel_bao.ctn_daBg)
	-- 预览情况点任何地方给反馈
	if previewId then
		_sp:setTouchedFunc(function()
			WindowControler:showTips(GameConfig.getLanguage("tid_teaminfo_1002"))
		end)
	end
end
-- 管理中间的人物
function LineUpMainView:updateCenterHero(isPreview)
	local partners = LineUpModel:getDetailList()
	local charPanel = self.panel_bao.panel_zhujue
	for i=1,6 do
	-- for i, v in ipairs(partners) do
		local v = partners[i] -- 策划说是一定有6个，但是为了防止不足6个这样处理
		local panel = self._centerParnters[i]
		if not panel then
			if v and v.isChar then
				panel = self.panel_bao.panel_zhujue
			else
				panel = UIBaseDef:cloneOneView(self.panel_bao.panel_huoban)
				self.panel_bao:addChild(panel)
			end
			self._centerParnters[i] = panel
			-- 隐藏底座
			panel.panel_p:visible(false)
		end

		if v then
			panel:visible(true)
			local _name = nil
			
			if v.isChar then
				_name = v.name
			else
				-- 伙伴的表格
			    local _partnerInfo = FuncPartner.getPartnerById(v.id)
				_name = GameConfig.getLanguage(_partnerInfo.name)
			end

			if _name == "" then _name = "少侠" end

			-- 人物
			local _sprite = FuncLineUp.initNpc(v)
			_sprite:setScaleX(-1)
			panel.panel_1.txt_1:setString(_name)
			panel.ctn_1:removeAllChildren()
			panel.ctn_1:addChild(_sprite)
			-- 触摸层
			if not panel.panel_click then
				local panel_click = display.newNode()
				panel_click:anchor(0.5, 0)
				panel_click:size(120, 160)
				panel_click:addTo(panel)
				panel.panel_click = panel_click
			end
			local panel_click = panel.panel_click
			-- 伙伴根据阵容里的位置填坑
		 	local posId = LineUpModel:getPosInFormationById(v.id)
			
			if not v.isChar then
				local x = charPanel:getPositionX() - (posId - 1) * 110 - 40
				local y = three(posId % 2 == 0, -100, 100)
				y = charPanel:getPositionY() + y

				panel:pos(x, y)
			end
			panel:zorder(posId)

			if self._isSelf and not isPreview then -- 是自己可以点击更换伙伴，并且不是预览
				if v.isChar then 
					panel_click:setTouchedFunc(function()

						if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GARMENT) == true then 
							WindowControler:showWindow("CharMainView", 4)
						else 
							WindowControler:showTips(GameConfig.getLanguage("tid_teaminfo_1003"))
						end 						
					end)
				else-- 不是主角
					panel_click:setTouchedFunc(function()
						WindowControler:showWindow("LineUpChPartnerView", v.id)
					end)
				end
			else
				panel_click:setTouchEnabled(false)
			end
		else
			panel:visible(false)
		end
	end
end
-- 中间法宝
function LineUpMainView:updateCenterTreasure(isPreview)
	-- 法宝
	local treasureData = LineUpModel:getTreasure()
	local treasurePanel = self.panel_bao.panel_Fb
	-- icon
	local _sp = display.newSprite(FuncRes.iconTreasure(treasureData.id)):size(80,70)
	treasurePanel.ctn_1:removeAllChildren()
	treasurePanel.ctn_1:addChild(_sp)
	-- 品质
	-- treasurePanel.mc_1:showFrame(TreasuresModel:getTreasureQualityById(treasureData.id))
	-- 名字
	-- treasurePanel.mc_zi:showFrame(TreasuresModel:getTreasureQualityById(treasureData.id))
	-- treasurePanel.mc_zi.currentView.txt_1:setString(GameConfig.getLanguage(TreasuresModel:getTreasureName(treasureData.id)))
	-- 等级（隐藏）
	-- treasurePanel.txt_goodsshuliang:visible(false)
	-- treasurePanel.txt_goodsshuliang:setString(treasureData.level)
	-- 星级
	-- treasurePanel.mc_dou:showFrame(treasureData.star)
	-- 使层级高于人物
	-- self.panel_bao.UI_1:zorder(7)

	if self._isSelf and not isPreview then
		-- 点击法宝
		_sp:setTouchedFunc(function()
			WindowControler:showWindow("LineUpChTreasureView")
		end)
	else
		_sp:setTouchEnabled(false)
	end
end
-- 处理中间区域
function LineUpMainView:updateCenter()
	-- 隐藏部件
	self.panel_bao.panel_huoban:visible(false)

	-- 中间人物
	self:updateCenterHero()

	-- 中间法宝
	self:updateCenterTreasure()
end

-- 处理底部的条
function LineUpMainView:updateBottom(isPreview)
	self.scale9_1:visible(not isPreview)
	self.scale9_1:zorder(9)
	self.panel_zan:visible(not isPreview)
	self.panel_zan:zorder(10)
	self.panel_power:visible(not isPreview)
	self.panel_power:zorder(10)
	self.mc_1:visible(not isPreview)
	self.mc_1:zorder(10)
	self.mc_2:visible(not isPreview)
	self.mc_2:zorder(10)
	self.panel_yulan:visible(tobool(isPreview))

	if isPreview then
		-- self.mc_1:showFrame(3)
	else
		if self._isSelf then -- 查看自己
			self.mc_1:showFrame(2)
			self.mc_2:showFrame(2)
			-- 换背景按钮
			local btnBg = self.mc_1.currentView.btn_1
			-- 分享按钮
			local btnShare = self.mc_2.currentView.btn_2
			
			btnBg:setTap(c_func(self.onBgChClick, self))
			btnShare:setTap(c_func(self.onShareClick, self))
		else -- 查看他人
			self.mc_1:showFrame(1)
			self.mc_2:showFrame(1)
			-- 好友
			local btnFriend = self.mc_1.currentView.btn_1
			-- 详情
			local btnDetail = self.mc_2.currentView.btn_2

			if LineUpModel:isFriend() then -- 是好友
				btnFriend:visible(false)
			else
				btnFriend:visible(true)
				btnFriend:setTap(c_func(self.onFriendClick, self))
			end

			btnDetail:setTap(c_func(self.onDetailClick, self))
		end
		-- 红心
		self:updateHeart()
		-- 总战力
		self.panel_power.UI_number:setPower(LineUpModel:getTotalPower())
	end
end

-- 更新心的显示
function LineUpMainView:updateHeart()
	-- 红心
	local _heart = self.panel_zan.mc_xin
	_heart:showFrame(three(LineUpModel:hasPraised(), 2, 1))
	_heart:setTouchedFunc(c_func(self.onHeartClick, self, _heart))
	-- 点赞的数量
	self.panel_zan.txt_1:setString(LineUpModel:getPraisedNum())
	if self._isSelf then -- 查看自己
		-- 查看赞我的人
		self.panel_zan.txt_1:setTouchedFunc(function()
			LineUpViewControler:showPraiseListWindow()
		end)
	else
		self.panel_zan.txt_1:setTouchedFunc(GameVars.emptyFunc)
	end
end

-- 加好友按钮点击事件
function LineUpMainView:onFriendClick()
	local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end
	if LineUpModel:isRobot() then
		WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"))
	else
		local trid,tsec = LineUpModel:getServerInfo()
		local _param = {}
		_param.ridInfos = {}
		_param.ridInfos[1] = {[tsec] = trid}
		FriendServer:sendapplyFriend(_param)
	end
end

-- 详情按钮点击事件
function LineUpMainView:onDetailClick()
	WindowControler:showWindow("LineUpDetailView")
end

-- 换背景按钮点击事件
function LineUpMainView:onBgChClick()
	WindowControler:showWindow("LineUpChBgView", {callBack = c_func(self.switchToPreview, self)})
end

-- 分享按钮点击事件
function LineUpMainView:onShareClick()
    local texture = FuncLineUp.getViewTexture(self.panel_bao)
    local _,tsec = LineUpModel:getServerInfo()
    WindowControler:showWindow("LineUpShareView", {
    	texture = texture,
    	power = LineUpModel:getTotalPower(),
    	tsec = tsec,
    })
end

-- 心的点击事件
function LineUpMainView:onHeartClick(view)
	if LineUpModel:hasPraised() then -- 赞过
		LineUpServer:cancelPraise()
	else -- 没赞过
		-- echo("点赞")
		LineUpServer:givePraise()
	end
end

-- 初始化变量
function LineUpMainView:initVar()
	self._isSelf = LineUpModel:isSelf() -- 是否是自己
end

function LineUpMainView:press_btn_close()
	if LineUpModel:hasCacheOwnInfo() then -- 有缓存信息，
		LineUpViewControler:showMainWindow()
	else
		-- 同步查看阵容的信息
		LineUpModel:syncFormation()
		self:startHide()
	end
end

function LineUpMainView:onBecomeTopView()
	self:initVar()
	self:registerEvent()
	-- self:setViewAlign()
	self:updateUI()
end

-- 切换为预览状态
function LineUpMainView:switchToPreview( isPreview, bgId )
	-- 背景
	self:updateBg(bgId)
	-- 底部条
	self:updateBottom(isPreview)
	-- 法宝的点击
	self:updateCenterTreasure(isPreview)
	-- 人物
	self:updateCenterHero(isPreview)
	-- 返回按钮
	if isPreview then
		self.panel_back.btn_back:setTap(function()
			-- 切换回正常界面
			self:switchToPreview(false)
			-- 打开更换背景界面
			WindowControler:showWindow("LineUpChBgView")
		end)
	else
		self.panel_back.btn_back:setTap(c_func(self.press_btn_close, self))
	end
end

return LineUpMainView