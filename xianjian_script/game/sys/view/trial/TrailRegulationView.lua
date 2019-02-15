--guan
--2016.2.25

local TrailRegulationView = class("TrailRegulationView", UIBase);

--[[
    self.UI_diban,
    self.panel_1,
    self.panel_back,
    self.scroll_huadong,
    self.txt_1,
]]

function TrailRegulationView:ctor(winName,openType)
    TrailRegulationView.super.ctor(self, winName);
    self.openType = openType
end

function TrailRegulationView:loadUIComplete()
	self:registerEvent();

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_back, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.LeftTop);
    self.UI_diban.mc_1:setVisible(false)
    self:registClickClose(-1, c_func( function()
            self:press_btn_back()
    end , self))

    self.UI_diban.txt_1:setVisible(false)
    self.UI_diban.panel_1:setVisible(false)
    -- self.txt_1:setString(GameConfig.getLanguage("#tid_trail_003"));
    -- self:initData();
    self:initScrollUI()
end 
function TrailRegulationView:initData()
    local LanguageID =  FuncTrail.getTrialResourcesData(self.openType, "rule")
    local str = GameConfig.getLanguage(LanguageID);
    self.rich_1:setString(str);
end

function TrailRegulationView:registerEvent()
	TrailRegulationView.super.registerEvent();
	self.UI_diban.btn_close:setTap(c_func(self.press_btn_back, self));
end

function TrailRegulationView:initScrollUI()
    self.rich_1:setVisible(false);
    -- echo("111111111============",self.openType)

    if self.openType ~= nil then
        -- self._scrollParams = {}
        -- local createRankItemFunc = function(itemData)
        -- --     local view = UIBaseDef:cloneOneView(self.rich_1);
        --     self:updateItem(view, itemData)
        --     return view;
        -- end
        -- local trialResources = FuncTrail.gettrialResources()
        -- -- dump(trialResources)
        -- for i=1,#trialResources do
        --     local Params = {
        --             data = {1},
        --             createFunc= createRankItemFunc,
        --             perNums= 1,
        --             offsetX =100,
        --             offsetY = 20,
        --             itemRect = {x=0,y=-110,width=740,height = 110},
        --             perFrame = 1,
        --             heightGap = 0
        --         }
        --     self._scrollParams[i] = Params
        -- end
        -- self.indexID = 1
    -- else
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
        self.indexID = self.openType
    end
    -- dump(self._scrollParams)
    
    self.scroll_huadong:styleFill(self._scrollParams);
end

function TrailRegulationView:updateItem(view, itemData)
    echo("====试炼类型==========",self.indexID)
 --    local LanguageID =  FuncTrail.getTrialResourcesData(self.indexID, "rule")
	-- local str = GameConfig.getLanguage(LanguageID);
	-- view:setString(str);


    local LanguageID =  FuncTrail.getTrialResourcesData(self.openType, "rule")
    local str = GameConfig.getLanguage(LanguageID);
    view:setString(str);

end

function TrailRegulationView:press_btn_back()
	self:startHide();
end

function TrailRegulationView:updateUI()
	
end


return TrailRegulationView;
