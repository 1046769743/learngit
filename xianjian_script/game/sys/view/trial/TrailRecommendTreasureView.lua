--2016.2.25
--guan

local TrailRecommendTreasureView = class("TrailRecommendTreasureView", UIBase);

--[[
    self.panel_Bg,
    self.panel_Bg.btn_1,
    self.panel_Bg.btn_close,
    self.panel_Bg.scale9_1,
    self.panel_Bg.scroll_list,
    self.panel_fb1.UI_fb1,
    self.panel_fb1.txt_1,
    self.scroll_huadong,
    self.txt_mingcheng,
]]

function TrailRecommendTreasureView:ctor(winName, treasureIds)
    TrailRecommendTreasureView.super.ctor(self, winName);
    self._treasureIds = treasureIds;
end

function TrailRecommendTreasureView:loadUIComplete()
	self:registerEvent();
    self:initScrollUI();
end 

function TrailRecommendTreasureView:registerEvent()
	TrailRecommendTreasureView.super.registerEvent();
    self:registClickClose("out")
    self.panel_Bg.btn_close:setTap(c_func(self.press_panel_Bg_btn_close, self));
    self.panel_Bg.btn_1:setTap(c_func(self.press_panel_Bg_btn_1, self));

    self:setTouchedFunc(c_func(self.startHide, self));

    self.panel_Bg:setTouchedFunc(GameVars.emptyFunc, nil, true);
end

function TrailRecommendTreasureView:initScrollUI()
    self.panel_fb1:setVisible(false);

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_fb1);
        self:updateItem(view, itemData)
        return view;
    end

    self._scrollParams = {
        {
            data = self._treasureIds,
            createFunc = createRankItemFunc,
            perFrame = 0,
        },
    }

    self.scroll_huadong:styleFill(self._scrollParams);
end

function TrailRecommendTreasureView:updateItem(view, itemData)
    local treasureId = itemData;
    local treasureUI = view.UI_fb1;

    --图标
    -- treasureUI.ctn_icon:removeAllChildren();
    local icon = FuncRes.iconRes(UserModel.RES_TYPE.TREASURE, treasureId);
    -- echo("icon " .. tostring(icon));
    local sprite =  display.newSprite(icon); 
    treasureUI.ctn_icon:addChild(sprite);

    sprite:size(treasureUI.ctn_icon.ctnWidth, treasureUI.ctn_icon.ctnHeight);
    --前中后
    local posId = FuncTreasure.getValueByKeyTD(treasureId, "label1");
    if posId > 2 then 
        treasureUI.mc_biaoqian:setVisible(false);
    else 
        treasureUI.mc_biaoqian:setVisible(true);
        treasureUI.mc_biaoqian:showFrame(posId);
    end 
    --品质框
    local quality = FuncTreasure.getValueByKeyTD(treasureId, "quality");
    treasureUI.mc_di:showFrame(quality);

    --名字
    local name = FuncTreasure.getName(treasureId);
    view.txt_1:setString(name);

    view:setTouchedFunc(c_func(self.goToTreasureInfo, self, treasureId) );
end

function TrailRecommendTreasureView:goToTreasureInfo( treasureId )
    if self.scroll_huadong:isMoving() == false then 
        -- WindowControler:showWindow("LotteryTreasureDetail", 
        --     treasureId)
    end 
end

function TrailRecommendTreasureView:press_panel_Bg_btn_close()
    self:startHide();
end

function TrailRecommendTreasureView:press_panel_Bg_btn_1()
    self:startHide();
end


function TrailRecommendTreasureView:updateUI()
	
end


return TrailRecommendTreasureView;









