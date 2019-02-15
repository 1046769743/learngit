--
--Author:      zhuguangyuan
--DateTime:    2017-09-25 19:28:56
--Description: 新版情缘系统主界面
--


local NewLoveMainView = class("NewLoveMainView", UIBase);

function NewLoveMainView:ctor(winName)
    NewLoveMainView.super.ctor(self, winName)
end

function NewLoveMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:initViewAlign()
	self:updateUI()
	-- self:addQuestAndChat()
end 
-- --添加聊天和目标按钮
-- function NewLoveMainView:addQuestAndChat()
--     local arrData = {
--         systemView = FuncCommon.SYSTEM_NAME.LOVE,--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end


function NewLoveMainView:registerEvent()
	NewLoveMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回
	-- 一条情缘升级成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE, self.updateUI, self)
   	-- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, self.updateUI, self)
    -- 某一个伙伴升级/升品/升星成功
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT, self.updateUI, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT, self.updateUI, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT, self.updateUI, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_HECHENG_SUCCESS_EVENT, self.updateUI, self)
end

--关闭按钮
function NewLoveMainView:onClose()
	NewLoveModel:saveLoveChooseId(self.selectedThemeId)
	self:startHide()
end

function NewLoveMainView:initData()
	-- 获取所有主题信息
	self.allThemes = FuncNewLove.getAllThemeData()
	-- dump(self.allThemes, "所有主题列表")

	local sequenceThemes = {}
	self.mapIndex2ThemeId = {}
	self.numOfTheme = 0
	for k,v in pairs(self.allThemes) do
		sequenceThemes[tonumber(k)] = v
		self.numOfTheme = self.numOfTheme + 1
		self.mapIndex2ThemeId[self.numOfTheme] = v.id
	end
	self.allThemes = nil
	self.allThemes = sequenceThemes
	dump(self.allThemes, "所有主题列表")

	local temptype = true
	self.hasRedId = tostring(self.numOfTheme)
	local realChooseId = NewLoveModel:getLoveChooseId()
	if realChooseId == "" or realChooseId == nil then	
		self.selectedThemeId = self.allThemes[1].id
	else
		self.selectedThemeId = realChooseId		
	end	
	for k,v in pairs(self.allThemes) do
		local isShow = NewLoveModel:isShowThemeRedPoint(v.id)
		if isShow and tonumber(self.hasRedId) >= tonumber(v.id) then
			self.hasRedId = v.id
			self.selectedThemeId = v.id
		end
	end
	self.hasRedId = self.selectedThemeId

	self.currentThemePartners = FuncNewLove.getPartnersByThemeId(self.selectedThemeId)
	self.currentThemePartners = NewLoveModel:questNowHasPartner(self.currentThemePartners)
	self.isMovingPartner = false
end


function NewLoveMainView:initView()
	self.themeScroll = self.scroll_2
	self.partnerScroll = self.panel_bg.scroll_1
	self.themeScroll:hideDragBar()
	self.partnerScroll:hideDragBar()

	self.mc_1:setVisible(false)
	self.panel_1:setVisible(false)
 
	self:initThemeScrollCfg()
	self:initPartnerScrollCfg()
	--- 镜子里的背景
	local bgSprite = display.newSprite(FuncRes.iconBg("partner_bg_huobanbeijing"))
	bgSprite:anchor(0.5,0.5)
	bgSprite:pos(GameVars.halfResWidth,-GameVars.halfResHeight)
    self.panel_bg.scroll_1:addChild(bgSprite,-1)
    -- 镜子遮罩
	local artMaskSprite = display.newSprite(FuncRes.iconOther("love_img_zhezhao"))
	artMaskSprite:anchor(0.5,0.5)
	artMaskSprite:pos(516,-286)
	local headSprite = FuncCommUI.getMaskCan(artMaskSprite,self.panel_bg.scroll_1)
    self.panel_bg:addChild(headSprite)
    self.panel_bg.panel_jingzi:zorder(1000)
    -- self.panel_bg.ctn_love:addChild(headSprite)
	-- self.mc_logo:showFrame(tonumber(self.selectedThemeId))

	-- 寻缘入口
    -- self.btn_xun:setTap(c_func(self.openSearchMainView,self))
    -- self:updateSearchRedPoint()
end

-- 寻缘入口
function NewLoveMainView:openSearchMainView()
	WindowControler:showWindow("NewLoveGlobalPropertyMainView")
end


-- =================================================================
-- =================================================================
-- 初始化主题滚动条
function NewLoveMainView:initThemeScrollCfg()
	local function createThemeFunc(themeData)
		local itemView = UIBaseDef:cloneOneView(self.mc_1)
		self:updateThemeScroll(themeData,itemView)
		return itemView
	end
	local function updateThemeFunc(themeData,itemView)
		self:updateThemeScroll(themeData,itemView)
		return itemView
	end

	-- self.btn_up:setTouchedFunc(c_func(self.scrollMoveUp,self))
	-- self.btn_down:setTouchedFunc(c_func(self.scrollMoveDown,self))

	self.themeListParams =  {
		{
		   	data = self.allThemes,
	        createFunc = createThemeFunc,
	        updateCellFunc = updateThemeFunc,
	        perNums= 1,
	        offsetX = 243,
	        offsetY = 60,
	        widthGap = 0,
	        heightGap = 0,
	        itemRect = {x = 0,y = -110,width = 214,height = 110},
	        perFrame = 1,
	        cellWithGroup = 1	
		}
	}
    -- self.themeScroll:setScrollPage(1, 104, 1,{scale = 0.5,wave = 0.38},c_func(self.scrollMoveEndCallBack, self))
	self.themeScroll:styleFill(self.themeListParams)
    self.themeScroll:hideDragBar()
end

-- -- 滑动滚动条选中 某个条目的回调
-- function NewLoveMainView:scrollMoveEndCallBack(itemIndex,groupIndex)
-- 	if itemIndex < 1 then
--         itemIndex = 1
--     end
--     echo("\n-------- 当前选中的index为 "..itemIndex)
--    	if tostring(itemIndex) ~= self.selectedThemeId then
-- 	    self.selectedThemeId = tostring(itemIndex) --self.mapIndex2ThemeId[itemIndex]
-- 		self.themeScroll:gotoTargetPos(tonumber(self.selectedThemeId),1,1,0.3)
-- 		self:updateUI(1)
-- 	end
-- end

-- 更新一个主题item
function NewLoveMainView:updateThemeScroll( themeData,itemView )
	local themeName = themeData.loveButtonName
	themeName = GameConfig.getLanguage(themeName)
	-- 点击事件响应
	local btnView = nil
	if themeData.id == self.selectedThemeId then
		itemView:showFrame(2)
		-- itemView.currentView.panel_red:setVisible(false)
		local isShow = NewLoveModel:isShowThemeRedPoint(themeData.id)    ---选中了也要加红点  罗鑫让加的
		itemView.currentView.panel_red:setVisible(isShow)
		-- itemView.currentView.btn_1:getUpPanel().mc_1:showFrame(tonumber(themeData.id))
		-- itemView.currentView.btn_1:getDownPanel().mc_1:showFrame(tonumber(themeData.id))
		itemView.currentView.mc_logo:showFrame(tonumber(themeData.id))
		-- itemView.currentView.btn_1:setBtnStr( themeName,"txt_1")
	else
		itemView:showFrame(1)
		-- 红点更新
		local isShow = NewLoveModel:isShowThemeRedPoint(themeData.id)
		itemView.currentView.panel_red:setVisible(isShow)
		itemView.currentView.mc_logo:showFrame(tonumber(themeData.id))
		-- itemView.currentView.btn_1:setBtnStr( themeName,"txt_1")
		-- itemView.currentView.btn_1:getUpPanel().mc_1:showFrame(tonumber(themeData.id))
		-- itemView.currentView.btn_1:getDownPanel().mc_1:showFrame(tonumber(themeData.id))
		itemView.currentView.btn_1:setTap(function()
			self.selectedThemeId = themeData.id
			self.themeScroll:gotoTargetPos(tonumber(self.selectedThemeId),1,1,0.3)
			self:updateUI(1)
		end)
	end
end

-- 初始化伙伴滚动条
function NewLoveMainView:initPartnerScrollCfg()
	local function createPartnerFunc(partnerData)
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		local partnerId = partnerData.id
		self:updatePartnerScroll( partnerId,itemView )
		return itemView
	end
	local function updatePartnerFunc(partnerData,itemView)
		local partnerId = partnerData.id
		self:updatePartnerScroll( partnerId,itemView )
		return itemView
	end
	self.partnerListParams =  {
		{
	    	data = self.currentThemePartners,
	        createFunc = createPartnerFunc,
        	-- updateCellFunc = updatePartnerFunc,
	        perNums= 1,
	        offsetX = 100,--self:calculateOffset(),
	        offsetY = -20,
	        widthGap = 0,
	        heightGap = 0,
	        itemRect = {x = 0,y = -350,width = 180,height = 449},
	        perFrame = 1,
	        cellWithGroup = 1
		}
	}
	-- echoError ("1111")
    self.partnerScroll:styleFill(self.partnerListParams)
    self.partnerScroll:onScroll(c_func(self.qusetNowScrollType,self))

end

-- 根据一个主题下的伙伴数量
-- 设置滚动条内的item 的初始偏移值
-- 让伙伴较少的主题 将伙伴item显示在滚动条中间,而不是左侧
function NewLoveMainView:calculateOffset(_curThemePartners)
local tempX = 20
	local scrollSize = self.partnerScroll:getContainerBox()
	local itemSize = self.panel_1:getContainerBox()

	if table.length(_curThemePartners) < 5 then
		tempX = (scrollSize.width- table.length(_curThemePartners)*itemSize.width)/2+20	
		self.partnerScroll:setScrollBorder(0)
	else
		self.partnerScroll:setScrollBorder(-65)
	end
	return tempX
end

-- 更新一个伙伴item
function NewLoveMainView:updatePartnerScroll( partnerId,itemView )
	-- echo("_self.selectedThemeId,partnerId,____________",self.selectedThemeId,partnerId)
	-- 伙伴立绘
	local partnerStaticData = FuncPartner.getPartnerById(partnerId)
	-- local sourceCfg = FuncTreasure.getSourceDataById(partnerStaticData.sourceld)
	-- local spineName = sourceCfg.spine
	-- local bossView = ViewSpine.new(spineName, {}, spineName)
	-- bossView:playLabel("stand", true)
	-- bossView:setScaleX(-1)
	local bossConfig = partnerStaticData.dynamic
	local arr = string.split(bossConfig, ",");
    local bossSpine = FuncRes.getArtSpineAni(arr[1])
	local headMaskSprite =  display.newSprite(FuncRes.iconOther("love_img_zhezhao2"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(1,122)
    itemView.panel_2.ctn_1:removeAllChildren()
   	local itemIcon = FuncCommUI.getMaskCan(headMaskSprite,bossSpine)
    itemView.panel_2.ctn_1:addChild(itemIcon)
	-- bossView:pos(10,-80)
	bossSpine:setScale(0.5)
	-- 某些奇侠立绘比较矮,需要往下移以避免穿帮
	local needToMove = {"5009","5014"}
	if table.isValueIn(needToMove,tostring(partnerId)) then
		bossSpine:pos(0,-30)
	else
		bossSpine:pos(0,0)
	end
	bossSpine:anchor(0.5,0)
	bossSpine:setAnimation(0, "ui", true); 

	-- 情缘相关名字 
	local name = FuncNewLove.getNameBypartnerId(partnerId)
	name = GameConfig.getLanguage(name)
	itemView.panel_2.txt_1:setString(name)

	-- 共鸣阶颜色
	local resonanceLv = nil
	local partnerDynamicData = PartnerModel:getPartnerDataById(partnerId)
	if not partnerDynamicData then
		resonanceLv = 0
	else
		resonanceLv = partnerDynamicData.resonanceLv
	end
	if resonanceLv < 1 then
		resonanceLv = 1
	end
	itemView.panel_2.mc_1:showFrame(resonanceLv)
	
	-- 红点更新
	local isShow = NewLoveModel:isShowMainPartnerRedPoint(partnerId)
	itemView.panel_2.panel_red:setVisible(isShow)
		
	-- 还没拥有伙伴则情缘肯定不能升级
	local isHavePartner = PartnerModel:isHavedPatnner(partnerId)
	if isHavePartner then
		itemView.panel_2:setTouchedFunc(function()
			WindowControler:showWindow("NewLovePartnerView",partnerId)
		end)
	else
		FilterTools.setViewFilter(itemIcon,FilterTools.colorTransform_talentPointLight)
		itemView.panel_2.panel_red:setVisible(false)
		itemView.panel_2:setTouchedFunc(function()
			WindowControler:showWindow("NewLovePartnerView",partnerId)
		end)
	end
	-- 删除错落效果
	-- if not self.nowPageNum then
	-- 	self.nowPageNum = 1
	-- end
	-- local tempNum = self.nowPageNum%2
	-- if tempNum == 1 then
	-- 	local tempHeight = 60*GameVars.height/768
	-- 	itemView.panel_2:setPositionY(tempHeight)
	-- end
	-- self.nowPageNum = self.nowPageNum +1
end

function NewLoveMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_logo,UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shu1,UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shu3,UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shu2,UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shu4,UIAlignTypes.RightBottom)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_guang,UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_xun,UIAlignTypes.RightTop)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_left,UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_right,UIAlignTypes.Right)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_topright,UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_down,UIAlignTypes.RightBottom)
	-- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1,UIAlignTypes.Right,nil,1,1)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_2,UIAlignTypes.Right)
    FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_2,UIAlignTypes.Middle,nil,1,1)
    -- FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1,UIAlignTypes.Middle,1,nil,1)
end

function NewLoveMainView:updateUI()
	self:updataThemeUI()
	self:updataPartnerUI()
    -- self:updateSearchRedPoint()
end

function NewLoveMainView:updataThemeUI( )
    self.themeScroll:refreshCellView(1)
    if tonumber(self.hasRedId) >4 and tonumber(self.hasRedId) ==  tonumber(self.selectedThemeId) then
    	self.themeScroll:gotoTargetPos(tonumber(self.hasRedId),1,0,0.5)	
    end	
    -- self.themeScroll:setOnCreateCompFunc( c_func(self.setCurChapterInListCenter,self) )
end

function NewLoveMainView:updataPartnerUI( )
	-- self.mc_logo:showFrame(tonumber(self.selectedThemeId))
	self.currentThemePartners = FuncNewLove.getPartnersByThemeId(self.selectedThemeId)
	self.currentThemePartners = NewLoveModel:questNowHasPartner(self.currentThemePartners)
	-- 是否显示左右移动的箭头
	self:isScrollNumByInfeed()
	self.nowPageNum = 1
	self.partnerListParams[1].data = self.currentThemePartners
	self.partnerListParams[1].offsetX = self:calculateOffset(self.currentThemePartners)
	self.partnerScroll:styleFill(self.partnerListParams)
    self.partnerScroll:onScroll(c_func(self.qusetNowScrollType,self))
end

--进度条滑动
function NewLoveMainView:scrollMoveRight()
	self.infeedNum = self.infeedNum +1
	self.isMovingPartner = true
	self.partnerScroll:gotoTargetPos(self.infeedNum,1,0,0.2)
	self:upDataScrollBtnType()
end

function NewLoveMainView:scrollMoveLeft()
	self.infeedNum = self.infeedNum -1
	self.isMovingPartner = true
	self.partnerScroll:gotoTargetPos(self.infeedNum,1,0,0.2)
	self:upDataScrollBtnType()
end

function NewLoveMainView:qusetNowScrollType(event)
	if event.name == "scrollEnd" then
		local groupIndex,posIndex =  self.partnerScroll:getGroupPos(0)
		if self.isMovingPartner then
			self.isMovingPartner = false
		else
			self.infeedNum = posIndex
			if table.length(self.currentThemePartners) > 5 then
				self:upDataScrollBtnType()
			end	
		end	
	end	
end

-- 是否显示左右移动的箭头
function NewLoveMainView:isScrollNumByInfeed()
	if table.length(self.currentThemePartners) <= 5 then
		self.btn_right:visible(false)
		self.btn_left:visible(false)
	else
		self.infeedNum = 1
		self.btn_right:visible(true)
		self.btn_right:setTouchedFunc(c_func(self.scrollMoveRight,self))
		self.btn_left:visible(false)
		self.btn_left:setTouchedFunc(c_func(self.scrollMoveLeft,self))
	end
end

function NewLoveMainView:upDataScrollBtnType()
	self.btn_right:visible(true)
	self.btn_left:visible(true)
	if self.infeedNum <= 1 then
		self.btn_left:visible(false)
	elseif self.infeedNum == table.length(self.currentThemePartners) -4 then
		self.btn_right:visible(false)
	end
end

function NewLoveMainView:scrollMoveUp()
	-- 缓动到第一组第1个 
	self.themeScroll:gotoTargetPos(1,1,0,0.3)
end

function NewLoveMainView:scrollMoveDown()
	-- 缓动到第一组第3个 
	self.themeScroll:gotoTargetPos(3,1,0,0.3)
end

function NewLoveMainView:deleteMe()
	NewLoveMainView.super.deleteMe(self);
end

return NewLoveMainView;
