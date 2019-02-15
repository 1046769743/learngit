--
--Author:      zhuguangyuan
--DateTime:    2018-05-04 09:09:02
--Description: 道具快捷购买小弹窗
--
-- 1.购买经验药
-- 2.购买强化石

local QuickBuyItemMainView = class("QuickBuyItemMainView", UIBase);

function QuickBuyItemMainView:ctor(winName,itemId,countId)
    -- itemId = "3009"
    -- countId = nil
    QuickBuyItemMainView.super.ctor(self, winName)
    self.curItemId = itemId
    self.countId = countId

    

end


function QuickBuyItemMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function QuickBuyItemMainView:registerEvent()
	QuickBuyItemMainView.super.registerEvent(self);
	self.panel_1.btn_close:setTap(c_func(self.startHide, self))
    self:registClickClose("out")

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.stoneChanged,self)
end

function QuickBuyItemMainView:stoneChanged()
    self.canChooseMaxNum = self:updateCanBuyMaxNum() 
    self:updateCostAndBtn()
end

function QuickBuyItemMainView:initData()
	self.itemData = FuncItem.getItemData(self.curItemId)
    dump(self.itemData, "道具数据 ")
    
    if self.countId then
        

    else
       self.itemQuickBuyData = FuncItem.getQuickBuyItemData( self.curItemId )
    end
	
    
	self.curChooseNum = 1   -- 当前选中的购买数量
    self.canChooseMaxNum = self:updateCanBuyMaxNum() --
    self:updateShowChooseNum()

    self.isLongTouch = false
end

-- 能选择的最大购买数量(跳到其他界面时,本界面会关闭,否则回来需重新计算)
function QuickBuyItemMainView:updateCanBuyMaxNum()
    local nums = 1
    if self.countId then
        nums = CountModel:getCanBuyMaxCount( self.countId )
    else
        local curHaveMoney = self:getCostResNums(  )
        local costMoney = self.itemQuickBuyData.cost or 1
        local moneyCanBuyNum = math.floor(curHaveMoney/costMoney) 
        local configCanBuyMaxNum = self.itemQuickBuyData.buymax
        if moneyCanBuyNum > configCanBuyMaxNum then
            moneyCanBuyNum = configCanBuyMaxNum
        end
        nums = moneyCanBuyNum
    end
    if nums < 1 then
        nums = 1
    end
    return nums
end

function QuickBuyItemMainView:initView()
	self.panel_1.txt_1:setString("快捷购买")
    -- self.panel_baoji:visible(false)
    -- 道具展示
    local itemName = GameConfig.getLanguage(self.itemData.name)
    local desc = GameConfig.getLanguage(self.itemData.des)
    self.panel_2.mc_1:showFrame(self.itemData.quality or 1)
    self.panel_2.mc_1:getCurFrameView().txt_1:setString(itemName)
    self.txt_1:setString(itemName)
    self.panel_2.txt_2:setString(desc)
    self.panel_2.txt_2:setVisible(false)
    self.panel_2.UI_1:setResItemData({itemId = self.curItemId,itemNum = ""})

	-- 最大最小按钮
	-- self.panel_2.panel_2.btn_1:setTap(c_func(self.chooseMinNum,self))
 --    self.panel_2.panel_2.btn_4:setTap(c_func(self.chooseMaxNum,self))
    self:registerInputCallback()
    self:registerLongTapFunc()
    self:updateCostAndBtn()
end

function QuickBuyItemMainView:updateCostAndBtn()
    -- 购买花费及购买按钮
    
    local oneitemCost = self:getPriceBuyNums(self.curChooseNum)
    self.panel_3.panel_1.txt_1:setString(oneitemCost)

    if not self:checkCanByOnce() then
        self.panel_3.panel_1.txt_1:setColor(cc.c3b(255,0,0))
        FilterTools.setGrayFilter(self.panel_3.btn_buy)
        local function gotoCharge()
            WindowControler:showWindow("CompGotoRechargeView")
            -- WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
        end
        self.panel_3.btn_buy:setTap(c_func(gotoCharge))
    else
        self.panel_3.panel_1.txt_1:setColor(self.panel_3.panel_1.txt_1.params.color)
        FilterTools.clearFilter(self.panel_3.btn_buy)
        self.panel_3.btn_buy:setTap(c_func(self.buyItem,self))
    end
end
function QuickBuyItemMainView:registerInputCallback()
    local function inputCallBack()
        local num = self.panel_2.panel_2.panel_1.input_1:getText()
        self.panel_2.panel_2.panel_1.input_1:setText("")

        local inputNum = tonumber(num)
        -- 输入非数字 显示之前的
        if not inputNum then
            inputNum = self.curChooseNum
        end
        if not self:checkCanByOnce()  then
            inputNum = 1
        end

        if inputNum <= 0 then
            inputNum = 1
        end
        if inputNum>=self.canChooseMaxNum and self.canChooseMaxNum > 0 then
            inputNum = self.canChooseMaxNum
        end   
        self.curChooseNum = inputNum
        self:updateShowChooseNum()
    end
    self.panel_2.panel_2.panel_1.input_1:setInputEndCallback(inputCallBack)
end

function QuickBuyItemMainView:registerLongTapFunc()
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
    self.panel_2.panel_2.btn_2:setLongTouchFunc(decreaseNum,nil,false,0.1,0)
    self.panel_2.panel_2.btn_3:setLongTouchFunc(increaseNum,nil,false,0.1,0)

    self.panel_2.panel_2.btn_1:setLongTouchFunc(decreaseNum10,nil,false,0.1,0)
    self.panel_2.panel_2.btn_4:setLongTouchFunc(increaseNum10,nil,false,0.1,0)

end

--通用长按回调
function QuickBuyItemMainView:longRepeatEndFunc(nums,isEnd )
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
    self:updateShowChooseNum()
end


function QuickBuyItemMainView:goldNotEnoughTips()
    if not self:checkCanByOnce() then
        if not self.hasPopupTips then
            self.hasPopupTips = true
            WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_04"),1)
        end
    else
        return true
    end
end
function QuickBuyItemMainView:chooseMinNum()
    self.hasPopupTips = false
    if self:goldNotEnoughTips() and self.curChooseNum == 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_02"),1)
    end
	self.curChooseNum = 1
    self:updateShowChooseNum()
end

function QuickBuyItemMainView:chooseMaxNum()
    self.hasPopupTips = false
    if self:goldNotEnoughTips() and self.curChooseNum == self.canChooseMaxNum then
        WindowControler:showTips(GameConfig.getLanguage("#tid_quick_buy_item_03"),1)
    end
	self.curChooseNum = self.canChooseMaxNum 
    if self.curChooseNum <= 0 then
        self.curChooseNum = 1
    end
    self:updateShowChooseNum()
end

-- 更新显示选中的数量
function QuickBuyItemMainView:updateShowChooseNum()
    self.panel_2.panel_2.panel_1.txt_xx:setString(self.curChooseNum)
    local oneitemCost = self:getPriceBuyNums(self.curChooseNum)
    self.panel_3.panel_1.txt_1:setString(oneitemCost)
end

function QuickBuyItemMainView:buyItem()
    if not self.curChooseNum then
        return
    end

    if not self.hasSentRequest then
        self.hasSentRequest = true
        local function buyCallBack( serverData )
            self.hasSentRequest = false
            if serverData.error then
                return
            else
                local data = serverData.result.data
                -- dump(data, "购买道具返回")
                self:updateCostAndBtn()
                self:addBuySucceedAni()

            end
        end
        if not self.countId then
            ItemServer:quickBuyItem( self.curItemId,self.curChooseNum,buyCallBack )
        else
            ItemServer:quickBuyItemByCount( self.countId,self.curChooseNum,buyCallBack )
        end
    end
end

-- 购买成功后的动画
function QuickBuyItemMainView:addBuySucceedAni()
        WindowControler:showWindow("QuickBuyItemBuySucceedView",self.curItemId,self.curChooseNum);
        self:startHide()
end

function QuickBuyItemMainView:initViewAlign()
	-- TODO
end

function QuickBuyItemMainView:updateUI()
	-- TODO
end

function QuickBuyItemMainView:deleteMe()
	-- TODO

	QuickBuyItemMainView.super.deleteMe(self);
end



function QuickBuyItemMainView:getCostResNums(  )
    if not self.countId then
        return UserModel:getGold()
    else
        local resId = FuncCount.getCountCostMapData( self.countId ).costResId
        local _,hasNums = UserModel:getResInfo(resId)
        return hasNums
    end
end

--判断能否购买1次
function QuickBuyItemMainView:checkCanByOnce(  )
    local price = self:getPriceBuyNums(1)
    return price <= self:getCostResNums(  ) 
end

--获取购买1次的价格
function QuickBuyItemMainView:getPriceBuyNums(nums )
    local rt
    nums = nums < 1 and 1 or nums
    if not self.countId then
        rt = self.itemQuickBuyData.cost*nums
    else
        rt = CountModel:getBuyCountCost( self.countId,nums ) 
    end
    echo(rt,nums,self.countId,'___getPriceBuyNums___')

    return rt
end

return QuickBuyItemMainView;
