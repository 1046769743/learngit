--
--Author:      zhuguangyuan
--DateTime:    2018-05-10 16:58:04
--Description: 快捷购买成功弹出的动画
--


local QuickBuyItemBuySucceedView = class("QuickBuyItemBuySucceedView", UIBase);

function QuickBuyItemBuySucceedView:ctor(winName,curItemId,curChooseNum)
    QuickBuyItemBuySucceedView.super.ctor(self, winName)
    self.curItemId = curItemId or "10101"
	self.curChooseNum = curChooseNum or 1

	echo("______curItemId,curChooseNum_____",curItemId,curChooseNum)
end

function QuickBuyItemBuySucceedView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function QuickBuyItemBuySucceedView:registerEvent()
	QuickBuyItemBuySucceedView.super.registerEvent(self);
end

function QuickBuyItemBuySucceedView:initData()
	-- TODO
end

function QuickBuyItemBuySucceedView:initView()
	self.panel_baoji:visible(false)
    local _flutter_label = UIBaseDef:cloneOneView(self.panel_baoji)
    local itemIcon = display.newSprite(FuncRes.iconItem(self.curItemId))
    _flutter_label.ctn_1:addChild(itemIcon)
    itemIcon:pos(0,-20)
    _flutter_label:visible(true)

    local arrnumber = FuncCommUI.byNumberGetNumberArr(tostring(self.curChooseNum))
    _flutter_label.mc_1:showFrame(#arrnumber)
    for i=1,#arrnumber do
      _flutter_label.mc_1:getViewByFrame(#arrnumber)["mc_"..i]:showFrame(tonumber(arrnumber[i]+1))
    end
    local x = _flutter_label:getPositionX()
    local y = _flutter_label:getPositionY()
    local size = _flutter_label:getContentSize()
    _flutter_label:setPosition(cc.p(130,0))
    local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,true,_remove_self);
    FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);
    self.ctn_ss:addChild(_ani);

	function animCallBack()
		self:startHide()
	end
    _ani:doByLastFrame(true,true,c_func(animCallBack))
end

function QuickBuyItemBuySucceedView:initViewAlign()
	-- TODO
end

function QuickBuyItemBuySucceedView:updateUI()
	-- TODO
end

function QuickBuyItemBuySucceedView:deleteMe()
	-- TODO

	QuickBuyItemBuySucceedView.super.deleteMe(self);
end

return QuickBuyItemBuySucceedView;
