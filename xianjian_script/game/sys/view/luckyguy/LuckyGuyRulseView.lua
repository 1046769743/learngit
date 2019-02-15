-- 幸运转盘规则
local LuckyGuyRulseView = class("LuckyGuyRulseView", UIBase);

function LuckyGuyRulseView:ctor(winName)
    LuckyGuyRulseView.super.ctor(self, winName);
end

function LuckyGuyRulseView:loadUIComplete()
	self:registClickClose("out")
	
	self.UI_diban.panel_1:setVisible(false)
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.mc_1:setVisible(false)
	self.UI_diban.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:initScrollUI()
end

function LuckyGuyRulseView:initScrollUI()
    self.rich_1:setVisible(false);

        local createRankItemFunc = function(itemData)
            local view = UIBaseDef:cloneOneView(self.rich_1);
            self:updateItem(view, itemData)
            return view;
        end
        self._scrollParams = {
            {
                    data = {1},
                    createFunc= createRankItemFunc,
                    perNums= 1,
                    offsetX =15,
                    offsetY = 20,
                    itemRect = {x=0,y=-290,width=530,height = 290},
                    perFrame = 1,
                    heightGap = 0
                }
        }
        
    self.scroll_huadong:styleFill(self._scrollParams);
end

function LuckyGuyRulseView:updateItem(view, itemData)
    local str = GameConfig.getLanguage("#tid_activity_30002004")
	view:setString(str)
end


function LuckyGuyRulseView:press_btn_close()
	
	self:startHide()
end


return LuckyGuyRulseView;
