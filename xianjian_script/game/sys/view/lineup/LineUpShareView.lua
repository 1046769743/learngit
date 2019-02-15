--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-分享界面
]]
local LineUpShareView = class("LineUpShareView", UIBase)

function LineUpShareView:ctor( winName, params )
	LineUpShareView.super.ctor(self, winName)

	self._texture = params.texture -- 图的texture
	self._power = params.power -- 战力
	self._tsec = params.tsec -- 区服
end

function LineUpShareView:registerEvent()
    self.panel_back.btn_back:setTap(c_func(self.press_btn_close, self))
end

function LineUpShareView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function LineUpShareView:setViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_back, UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_ding, UIAlignTypes.RightTop)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_enjoy, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao.txt_qufu, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao.panel_power, UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao.panel_1, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao.panel_ma, UIAlignTypes.LeftBottom)

    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1, UIAlignTypes.MiddleBottom, 1, 0)
end

function LineUpShareView:updateUI()
	-- ctn容器
	self.panel_bao:zorder(-1)
	local _ctn = self.panel_bao.ctn_daBg
	_ctn:removeAllChildren()

	local _sp = display.newSprite(self._texture, 0, 0)
	_sp:addTo(_ctn):setFlippedY(true)

	-- 战力
	self.panel_bao.panel_power.UI_number:setPower(self._power) 
	self.panel_bao.txt_qufu:setString(GameConfig.getLanguage("tid_common_2051") .. self._tsec)
end

function LineUpShareView:press_btn_close()
	self:startHide()
end

return LineUpShareView