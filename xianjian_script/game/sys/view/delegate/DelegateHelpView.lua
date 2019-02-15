
--[[
	Author: pangkanging
	Date:2018-05-28
	Description:挂机帮助界面
]]

local DelegateHelpView = class("DelegateHelpView", UIBase);

function DelegateHelpView:ctor(winName)
    DelegateHelpView.super.ctor(self, winName)
end

function DelegateHelpView:loadUIComplete()
	self:registerEvent()
	self:initView()
end 

function DelegateHelpView:registerEvent()
	DelegateHelpView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
	self.UI_1.mc_1:visible(false)
	self.UI_1.panel_1:visible(false)
	self.UI_1.txt_1:visible(false)
	-- self.UI_1.mc_1:setTouchedFunc(c_func(self.press_btn_close, self))
end

function DelegateHelpView:initView()
	self.txt_1:setString(GameConfig.getLanguage("#tid_delegate_2014"))
	self.rich_1:visible(false)
	local tmpView = UIBaseDef:cloneOneView(self.rich_1)
	local w,h = self.rich_1:setStringByAutoSize(GameConfig.getLanguage("#tid_delegate_2012"))
    local function createLeftFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.rich_1)
        _view:setStringByAutoSize(GameConfig.getLanguage("#tid_delegate_2012"))
        return _view
    end
    local leftParam = {
        data  = {{}},
        createFunc = createLeftFunc,
        offsetX =0,
        offsetY = 0,
        widthGap =0,
        heighGap =0,
        perFrame =1,
        perNums =1,
        itemRect = {x =0, y= -h+5,width = w,height = h},
    }
    self.scroll_1:styleFill({leftParam})
end

function DelegateHelpView:press_btn_close()
	self:startHide()
end

return DelegateHelpView;
