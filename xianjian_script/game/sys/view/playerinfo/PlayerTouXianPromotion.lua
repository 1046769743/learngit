-- PlayerTouXianPromotion
--2017-09-08 10:40
--@Author:wk

local PlayerTouXianPromotion = class("PlayerTouXianPromotion", UIBase);

function PlayerTouXianPromotion:ctor(winName)
    PlayerTouXianPromotion.super.ctor(self, winName);
end

function PlayerTouXianPromotion:loadUIComplete()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_jixu, UIAlignTypes.MiddleBottom)
    
    self.panel_sp:setVisible(false)
    self.txt_2:setVisible(false)
    self.mc_1:setVisible(false)
    self.panel_jian:setVisible(false)
    self.mc_2:setVisible(false)
    local _type = FuncCommUI.EFFEC_TTITLE.HOISTING
    local _bgctn = self.ctn_biaoti
    local function _callback()
        self.mc_1:setVisible(true)
        self.mc_2:setVisible(true)
         self.panel_jian:setVisible(true)
        self:initData()
        self:registClickClose(-1, c_func( function()
                self:press_btn_close()
        end , self))
    end
    FuncCommUI.addCommonBgEffect(_bgctn,_type,_callback)
    

end 
function PlayerTouXianPromotion:initData()
	local touxianID =  UserModel:crown()
	self.mc_1:showFrame(touxianID-1)
	self.mc_2:showFrame(touxianID)
end

function PlayerTouXianPromotion:press_btn_close()
    self:startHide()
end



return PlayerTouXianPromotion
