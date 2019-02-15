--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机奖励界面-view
]]

local DelegateRewardView = class("DelegateRewardView", UIBase)

function DelegateRewardView:ctor( winName, params)
	DelegateRewardView.super.ctor(self, winName)
	self.__data = params
end

function DelegateRewardView:registerEvent()
	DelegateRewardView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    -- self.btn_close:setTap(c_func(self.press_btn_close, self))
    self:registClickClose()
end

function DelegateRewardView:loadUIComplete()
	self.__data.taskData = FuncDelegate.getTask(self.__data.taskId)
	-- dump(self.__data, "奖励界面数据组织的对不对")
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
	DelegateModel:setCurTaskId(nil)
end

-- 适配
function DelegateRewardView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function DelegateRewardView:updateUI()

    local bgAni = self:createUIArmature("UI_tongyongjiesuan", "UI_tongyongjiesuan_wanchengweituo", self.ctn_1, false,function( )
    end);
    bgAni:getBone("di1"):visible(false)
    bgAni:getBone("di2"):visible(false)
    bgAni:getBoneDisplay("di3"):getBone("renyi"):visible(false)
    bgAni:getBoneDisplay("layer2"):getBoneDisplay("node2"):playWithIndex(12)
	bgAni:registerFrameEventCallFunc(70,1,function ()
        bgAni:pause()
        bgAni:getBoneDisplay("layer2"):playWithIndex(0, true)
        bgAni:getBoneDisplay("layer10"):playWithIndex(0, true)
    end);

	local panel = self
	-- 完成委托的伙伴
	local partners = self.__data.partners

	local pNums = #partners
	panel.mc_1:showFrame(pNums)
	for i=1,pNums do
		local itemData = partners[i]
		local idx = i
		local view = panel.mc_1.currentView["panel_" .. i]
		self:updatePartner(view, itemData, idx)
	end

	-- 奖励
	local rewards = self.__data.bonusReward or self.__data.taskData.specialReward

	if not rewards then return end
	self.mc_2:showFrame(#rewards)
	local view = self.mc_2.currentView
	for i=1,#rewards do
		local v = rewards[i]
		local tmpView = view["UI_"..i]
		tmpView:setResItemData({reward = v})
		self:registClick(tmpView, v)
	end

	-- panel.UI_1:visible(false)
	-- local function createFunc( itemData, idx )
	-- 	local view = UIBaseDef:cloneOneView(panel.UI_1)

	-- 	panel:updateItem(view, itemData, idx)
	-- 	return view
	-- end

	-- local function updateCellFunc( itemData, view, idx )
	-- 	panel:updateItem(view, itemData, idx)
	-- end

	-- --[[
	-- {
	-- 	"1,5013,2",
	-- 	"1,9241,1",
	-- 	"1,9234,1",
	-- 	"1,9243,1",
	-- 	"1,9239,1",
	-- 	"1,9232,1"
	-- }
	-- ]]
	-- local scrollParams = {
	-- 	{
	-- 		data = rewards,
	-- 		createFunc = createFunc,
	-- 		updateCellFunc = updateCellFunc,
	-- 		perFrame = 1,
	-- 		perNums = 6,
	-- 		offsetX = 40,
	-- 		offsetY = 0,
	-- 		itemRect = {x = 0,y = -100,width = 80,height = 110},
	-- 	}
	-- }

	-- local scrollList = panel.scroll_1
	-- scrollList:styleFill(scrollParams)
end
-- 给一个物品加点击
function DelegateRewardView:registClick( UI, sReward )
	local reward = string.split(sReward, ",")
	local rewardType = reward[1]
	local rewardNum = reward[#reward]
	local rewardId = reward[#reward - 1]

	FuncCommUI.regesitShowResView(UI, rewardType, rewardNum, rewardId, sReward, true, true)
end
-- 更新奖励
function DelegateRewardView:updateItem(view, itemData, idx)
	view:setResItemData({reward = itemData})
	self:registClick(view, itemData)
end
-- 更新伙伴头像
function DelegateRewardView:updatePartner( view, itemData, idx )
	local panel = view
	panel._idx = idx
	-- 经验 
	panel.txt_3:setString(GameConfig.getLanguage("#tid_delegate_2004") .. self.__data.taskData.expReward)
	-- 蒙灰
	panel.panel_hui:visible(false)

    local _iconPath = nil

	-- 品质
	local _frame = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
	panel.mc_2:showFrame(_frame) 
	-- 伙伴的表格
	local _partnerInfo = FuncPartner.getPartnerById(itemData.id)
	_iconPath = _partnerInfo.icon

    -- 伙伴的Icon
    local _ctn = panel.mc_2.currentView.ctn_1
    local _spriteIcon = display.newSprite(FuncRes.iconHero(_iconPath))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)

    -- 通过遮罩实现头像裁剪
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if tonumber(itemData.star) == 0 then
    	panel.mc_dou:visible(false)
    else
    	panel.mc_dou:visible(true)
    	panel.mc_dou:showFrame(itemData.star)
    end
end

function DelegateRewardView:press_btn_close()
	self:startHide()
end

return DelegateRewardView