--
--Author:      zhuguangyuan
--DateTime:    2017-07-31 22:07:02
--Description: 时装购买小窗口
--


local GarmentBuyView = class("GarmentBuyView", UIBase);

function GarmentBuyView:ctor(winName, partnerId, garmentId)
    GarmentBuyView.super.ctor(self, winName)
    self.partnerId = partnerId
    self.garmentId = garmentId
    -- echo("\n\n################ 购买id为 ###################",garmentId)
end

function GarmentBuyView:loadUIComplete()
	self:initData()
	self:initView()

	self:registerEvent()
	self:initViewAlign()

	self:updateUI()
end 



function GarmentBuyView:initData()
    if FuncPartner.isChar(self.partnerId) then
        self.isChar = true
        self.costArray = FuncGarment.getGarmentCost(self.garmentId)
    else
        self.isChar = false
        self.costArray = FuncPartnerSkin.getCostInfo(self.garmentId)
    end
	
    self.length = table.length(self.costArray)
end



function GarmentBuyView:initView() 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Garment_001"))
    if self.isChar then
        self.mc_ziyuan:showFrame(1)
    else
        self.mc_ziyuan:showFrame(2)
    end
end



function GarmentBuyView:registerEvent()
	GarmentBuyView.super.registerEvent(self)
    self.UI_1.btn_close:setTap(c_func(self.close, self))
    self:registClickClose("out", c_func(self.close, self))

    self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.clickConfirm, self));
end
function GarmentBuyView:clickConfirm()
    echo("\nself.curSelectIndex=", self.curSelectIndex)
    if self.isChar then
        local buyTime = self.costArray[self.curSelectIndex].k
        local need = self.costArray[self.curSelectIndex].v
        local have = UserModel:getGarment()

        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GARMENT) then
            if tonumber(need) <= tonumber(have) then 
                local isOwn = GarmentModel:isOwnOrNot(self.garmentId)  -- 是否已经拥有此服装
                GarmentServer:buyGarment(self.garmentId, buyTime, c_func(self.buyGarmentCallback, self, isOwn))
            else 
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2019"))
            end
        end

    else
        local str_table = string.split(self.costArray[self.curSelectIndex], ",")
        local need = str_table[3]
        local have = UserModel:getSkinCoin()

        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNERSKIN) then
            if tonumber(need) <= tonumber(have) then 
                -- 去购买 发消息
                PartnerSkinServer:buySkinServer(self.garmentId,c_func(self.buySkinCallback,self))
                -- self:buyCallback()
            else 
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2018"));
            end
        end
        
    end
     
end

function GarmentBuyView:buySkinCallback()
    echo("\n\n--buySkinCallback---")
    
    WindowControler:showWindow("GarmentRewardView", self.partnerId, self.garmentId);

    EventControler:dispatchEvent(PartnerSkinEvent.SKIN_BUY_SUCCESS_EVENT, 
         {garmentId = self.garmentId})
    self:startHide()
end

function GarmentBuyView:buyGarmentCallback(isOwn, event)
    echo("\n\n--buyGarmentCallback---")
    if event.error ~= nil then
        self:startHide() -- 隐藏购买界面
        return 
    end

    WindowControler:showWindow("GarmentRewardView", self.partnerId, self.garmentId) 
    -- 分发购买成功消息
    EventControler:dispatchEvent(GarmentEvent.GARMENT_BUY_SUCCESS_EVENT, {garmentId = self.garmentId})
    self:startHide() -- 隐藏购买界面
end
 


function GarmentBuyView:initViewAlign()

end

function GarmentBuyView:updateUI()
    -- 时装名字
    local nameStr = ""
    if self.isChar then
        nameStr = FuncGarment.getGarmentName(self.garmentId, UserModel:avatar())
    else
        nameStr = FuncPartnerSkin.getSkinName(self.garmentId)
    end

    self.txt_name:setString(GameConfig.getLanguage("#tid_Garment_002")..nameStr)

    self.mc_1:showFrame(self.length)
    local panel = self.mc_1.currentView
    for i = 1, self.length do
        local dayStr
        if self.isChar then
            if self.costArray[i].k == -1 then 
                dayStr = GameConfig.getLanguage("#tid_Garment_003")
            else
                dayStr = tostring(self.costArray[i].k)..GameConfig.getLanguage("#tid_Garment_004")
            end 
        else
            local str_table = string.split(self.costArray[i], ",")
            if tonumber(str_table[1]) == -1 then
                dayStr = GameConfig.getLanguage("#tid_Garment_003")
            else
                dayStr = tostring(str_table[1])..GameConfig.getLanguage("#tid_Garment_004")
            end
        end
        
        panel["txt_"..tostring(i)]:setString(dayStr);
        panel["panel_"..tostring(i)]:setTouchedFunc(c_func(self.mcClick, self, i))
    end
    -- for i = 1, 3 do
    --     if costArray[i] == nil then 
    --         self["txt_"..tostring(i)]:setVisible(false);
    --         self["panel_"..tostring(i)]:setVisible(false);
    --     else 
    --         local dayStr = tostring(costArray[i].k) .. "天";
    --         if costArray[i].k == -1 then 
    --             dayStr = "永久";
    --         end 

    --         self["txt_"..tostring(i)]:setString( dayStr );
    --         self["panel_"..tostring(i)]:setTouchedFunc(c_func(self.mcClick, self, i));
    --     end 
    -- end
    self:mcClick(1)  -- 默认选中第一项
end

function GarmentBuyView:mcClick(index)
    --隐藏其他的
    for i = 1, self.length do
        self.mc_1:getViewByFrame(self.length)["panel_"..tostring(i)].panel_1:setVisible(false)
    end

    self.mc_1:getViewByFrame(self.length)["panel_"..tostring(index)].panel_1:setVisible(true)

    local costNum = 0

    if self.isChar then
        costNum = self.costArray[index].v
    else
        local str_table = string.split(self.costArray[index], ",")
        costNum = tostring(str_table[3])
    end

    self.txt_1:setString(costNum)

    self.curSelectIndex = index

    -- --五彩金丝线足不足
    -- local costArray = FuncGarment.getGarmentCost(self.garmentId);
    -- local buyTime = costArray[self.curSelectIndex].k;

    -- local need = costArray[self.curSelectIndex].v;
    -- local have = UserModel:getGarment();

    -- if need <= have then 
    --     self.txt_num:setColor( cc.c3b(123, 85, 59) );       
    -- else 
    --     self.txt_num:setColor( cc.c3b(255, 0, 0) );
    -- end 
end

function GarmentBuyView:close()
    self:startHide()
end

function GarmentBuyView:deleteMe()
	-- TODO
	GarmentBuyView.super.deleteMe(self);
end

return GarmentBuyView;
