--购买转盘抽奖券

local BuyRouletteCoinView = class("BuyRouletteCoinView", UIBase);

function BuyRouletteCoinView:ctor(winName)
    BuyRouletteCoinView.super.ctor(self, winName);
end

function BuyRouletteCoinView:loadUIComplete()
    self:registerEvent();
    self:registClickClose("out")
    self:initData()
    self:initView()
    
end 

function BuyRouletteCoinView:registerEvent()
    BuyRouletteCoinView.super.registerEvent();
    EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.updateCostAndBtn, self)
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self));
end

function BuyRouletteCoinView:initData()
    self.curItemId = "9001"
    self.itemData = FuncItem.getItemData(self.curItemId)
    
    self.curChooseNum = 1   -- 当前选中的购买数量
    self.canChooseMaxNum = 100   --最大数量
    self:updateShowChooseNum()

    self.isLongTouch = false
end

function BuyRouletteCoinView:initView()
    self.UI_1.txt_1:setString("购买")
    self.UI_1.mc_1:visible(false)
    -- 道具展示
    local itemName = GameConfig.getLanguage(self.itemData.name)
    self.txt_3:setString(itemName)
    self.txt_4:setString("探宝符")

    -- self.btn_5:setTap(c_func(self.chooseDecTen,self))
 --    self.btn_4:setTap(c_func(self.chooseAddTen,self))
    -- self:registerInputCallback()
    self:registerLongTapFunc()
    self:updateCostAndBtn()
end

function BuyRouletteCoinView:updateCostAndBtn()
    -- 购买花费及购买按钮
    -- local oneitemCost = FuncDataSetting.getDataByConstantName("RouletteCoinPrice")*60  
    local oneitemCost = FuncDataSetting.getLuckyGuyGreenStonePrice()  --买一个经验药水需要多少仙玉
    local coupon = FuncDataSetting.getLuckyGuyGreenStoneHandselCoin() --买一个经验药赠送多少点券
    self.cost = oneitemCost   --- 单价
    local allitemCost = oneitemCost*self.curChooseNum   --选中经验药水的数量的总价
    local allCoupon = coupon*self.curChooseNum          --赠送点券的总额
    self.totalPrice = allitemCost
    self.txt_6:setString(allitemCost)
    local reward = "22,"..allCoupon
    self.UI_3:setResItemData({reward = reward});
    echo("仙玉 = = == = = = == ",UserModel:getGold())
    echo("总价= = = = == = = = =",self.totalPrice)
    if self.totalPrice > UserModel:getGold() then   -- 总价大于玩家仙玉数量
        self.txt_6:setColor(cc.c3b(255,0,0))
        -- FilterTools.setGrayFilter(self.btn_1)   -- 按钮置灰
        local function gotoCharge()
            WindowControler:showWindow("CompGotoRechargeView")
        end
        self.btn_1:setTap(c_func(gotoCharge))
    else
        self.txt_6:setColor(cc.c3b(0,0,0))
        -- FilterTools.clearFilter(self.btn_1)     -- 解除置灰
        self.btn_1:setTap(c_func(self.buyItem,self))
    end
    self.txt_7:setString(self.curChooseNum)
    self.UI_2:setResItemData({itemId = self.curItemId,itemNum = tostring(self.curChooseNum)})
end

function BuyRouletteCoinView:registerInputCallback()
    local function inputCallBack()
        local num = self.txt_7:getText()
        self.txt_7:setText("")

        local inputNum = tonumber(num)
        -- 输入非数字 显示之前的
        if not inputNum then
            inputNum = self.curChooseNum
        end
        if self.cost > UserModel:getRouletteCoin() then
            inputNum = 1
        end

        if inputNum<=0 then
            inputNum = 1
        end
        if inputNum>=self.canChooseMaxNum and self.canChooseMaxNum >0 then
            inputNum = self.canChooseMaxNum
        end   
        self.curChooseNum = inputNum
        self:updateShowChooseNum()
    end
    self.txt_7:setInputEndCallback(inputCallBack)
end
--[[
function BuyRouletteCoinView:registerLongTapFunc()
    -- 增减按钮
    local decreaseNum = {
        endFunc = function()
            -- echo("________ 结束函数 _____________")
            if not self.isLongTouch then
                if self.curChooseNum > 1 then
                    self.curChooseNum = self.curChooseNum - 1
                else
                    if self:goldNotEnoughTips() then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_02"),1)
                    end
                end
            end
            -- self:updateShowChooseNum()
            self:updateCostAndBtn()
            self.isLongTouch = false
            self.hasPopupTips = false
        end,
        repeatFunc = function()
            -- echo("________ 重复函数 _____________")
            self.isLongTouch = true
            if self.curChooseNum > 1 then
                self.curChooseNum = self.curChooseNum - 1
            else
                if self:goldNotEnoughTips() and not self.hasPopupTips then
                    self.hasPopupTips = true
                    WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_02"),1)
                end
            end
            -- self:updateShowChooseNum()
            self:updateCostAndBtn()
        end,
    }
    local increaseNum = {
        endFunc = function()
            -- echo("________ 结束函数2 _____________")
            if not self.isLongTouch then
                if self.curChooseNum < self.canChooseMaxNum then
                    self.curChooseNum = self.curChooseNum + 1
                else
                    if self:goldNotEnoughTips() then
                        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_03"),1)
                    end
                end
            end
            if self.curChooseNum <= 0 then
                self.curChooseNum = 1
            end
            -- self:updateShowChooseNum()
            self:updateCostAndBtn()
            self.isLongTouch = false
            self.hasPopupTips = false
        end,
        repeatFunc = function()
            -- echo("________ 重复函数2 _____________")
            self.isLongTouch = true
            if self.curChooseNum < self.canChooseMaxNum then
                self.curChooseNum = self.curChooseNum + 1
            else
                if self:goldNotEnoughTips() and not self.hasPopupTips then
                    self.hasPopupTips = true
                    WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_03"),1)
                end
            end
            if self.curChooseNum <= 0 then
                self.curChooseNum = 1
            end
            -- self:updateShowChooseNum()
            self:updateCostAndBtn()
        end,
    }
    self.btn_3:setLongTouchFunc(decreaseNum,nil,false,0.1,0)
    self.btn_2:setLongTouchFunc(increaseNum,nil,false,0.1,0)
end
]]--

function BuyRouletteCoinView:registerLongTapFunc()
    -- 增减按钮
    local decreaseNum = {
        endFunc = c_func(self.longRepeatEndFunc,self,-1,true),
        repeatFunc = c_func(self.longRepeatEndFunc,self,-1,false),
    }

    local decreaseNum10 = {
        endFunc = c_func(self.longRepeatEndFunc,self,-10,true),
        repeatFunc = c_func(self.longRepeatEndFunc,self,-10,false),
    }

    local increaseNum = {
        endFunc = c_func(self.longRepeatEndFunc,self,1,true),
        repeatFunc = c_func(self.longRepeatEndFunc,self,1,false),
    }

    local increaseNum10 = {
        endFunc = c_func(self.longRepeatEndFunc,self,10,true),
        repeatFunc = c_func(self.longRepeatEndFunc,self,10,false),
    }
    self.btn_3:setLongTouchFunc(decreaseNum,nil,false,0.1,0)
    self.btn_2:setLongTouchFunc(increaseNum,nil,false,0.1,0)

    self.btn_5:setLongTouchFunc(decreaseNum10,nil,false,0.1,0)
    self.btn_4:setLongTouchFunc(increaseNum10,nil,false,0.1,0)

end

--通用长按回调
function BuyRouletteCoinView:longRepeatEndFunc(nums,isEnd )
    self.curChooseNum = self.curChooseNum + nums
    if  self.curChooseNum >self.canChooseMaxNum  then
         self.curChooseNum =  self.canChooseMaxNum
         if self:goldNotEnoughTips() and not self.hasPopupTips then
            self.hasPopupTips = true
            WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_03"),1)
        end
    elseif self.curChooseNum < 1 then
        self.curChooseNum = 1
        if  not self.hasPopupTips  then
            self.hasPopupTips = true
           if self:goldNotEnoughTips() then
                WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_02"),1)
            end
        end
        
    else
        --todo
    end
    --如果是结束的
    if  isEnd then
        self.hasPopupTips = false
    end
    -- self:updateShowChooseNum()
    self:updateCostAndBtn()
end

function BuyRouletteCoinView:goldNotEnoughTips()
    if self.cost > UserModel:getGold() then
        if not self.hasPopupTips then
            self.hasPopupTips = true
            WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_04"),1)
        end
    else
        return true
    end
end
--[[
function BuyRouletteCoinView:chooseDecTen()
    self.hasPopupTips = false
    if self:goldNotEnoughTips() and self.curChooseNum == 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_02"),1)
    end
    self.curChooseNum = self.curChooseNum - 10
    if self.curChooseNum <= 1 then
        self.curChooseNum = 1
    end
    -- self:updateShowChooseNum()
    self:updateCostAndBtn()
end

function BuyRouletteCoinView:chooseAddTen()
    self.hasPopupTips = false
    if self:goldNotEnoughTips() and self.curChooseNum == self.canChooseMaxNum then
        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_03"),1)
    end
    self.curChooseNum = self.curChooseNum + 10
    if self.curChooseNum >= self.canChooseMaxNum then
        self.curChooseNum = self.canChooseMaxNum 
    end
    -- self:updateShowChooseNum()
    self:updateCostAndBtn()
end
]]--

-- 更新显示选中的数量
function BuyRouletteCoinView:updateShowChooseNum()
    self.txt_7:setString(self.curChooseNum)
    local oneitemCost = self.cost or 1
    oneitemCost = oneitemCost*self.curChooseNum
    self.txt_6:setString(oneitemCost)
end

function BuyRouletteCoinView:buyItem()
    if not self.curChooseNum then
        return
    end
    LuckyGuyModel:bugTicket(self.curChooseNum)
    self:startHide()
end


function BuyRouletteCoinView:press_btn_close()
    self:startHide()
end

return BuyRouletteCoinView;
