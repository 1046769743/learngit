--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-更换伙伴
]]
local LineUpChPartnerView = class("LineUpChPartnerView", UIBase)

function LineUpChPartnerView:ctor( winName, replaceId )
	LineUpChPartnerView.super.ctor(self, winName)
	self._replaceId = replaceId
end

function LineUpChPartnerView:registerEvent()
	LineUpChPartnerView.super.registerEvent(self)
    self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function LineUpChPartnerView:loadUIComplete()
	self:registerEvent()

	-- 更换伙伴
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_teaminfo_1007"))
	-- 隐藏需要复制的item
	self.panel_1:visible(false)
	self:updateUI()
end

function LineUpChPartnerView:updateUI()
	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(self.panel_1)

		self:updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		self:updateItem(view, itemData, idx)
	end

	local partners = LineUpModel:getPartnerList()
	local scrollParams = {
		{
			data = partners,
			createFunc = createFunc,
			updateCellFunc = updateCellFunc,
			perFrame = 1,
			perNums = 7,
			widthGap = 15,
			offsetX = 40,
			offsetY = 0,
			itemRect = {x = 0,y = -131,width = 120,height = 141},
		}
	}

	local scrollList = self.scroll_1
	scrollList:styleFill(scrollParams)
end

function LineUpChPartnerView:updateItem(view, itemData, idx )
	local panel = view

	-- 是否在阵
	panel.panel_dui:visible(itemData.inTeam == 1)
	-- 伙伴的表格
    local _partnerInfo = FuncPartner.getPartnerById(itemData.id)
    panel.txt_1:setString(GameConfig.getLanguage(_partnerInfo.name))
    -- 品质
    local _frame = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
	panel.mc_1:showFrame(_frame)
    -- 伙伴的Icon
    local _ctn = panel.mc_1.currentView.ctn_1
    local _iconPath = FuncRes.iconHero(_partnerInfo.icon)
    local _spriteIcon = cc.Sprite:create(_iconPath)

    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)

    -- 通过遮罩实现头像裁剪
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- -- 星级
    panel.mc_dou:showFrame(itemData.star)
    -- 等级
    panel.txt_level:setString(itemData.level)
    -- -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onTouchCallFunc, self, itemData) )
    panel:setTouchSwallowEnabled(true)
end

function LineUpChPartnerView:onTouchCallFunc( itemData )
	-- echo("Id", itemData.id, "交换Id", self._replaceId)
	LineUpModel:partnerFormationChange(self._replaceId, itemData.id)
	self:startHide()
end

function LineUpChPartnerView:press_btn_close()
	self:startHide()
end

return LineUpChPartnerView