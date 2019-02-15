local TreasureWanNengSuiPianView = class("TreasureWanNengSuiPianView", UIBase)

function TreasureWanNengSuiPianView:ctor(winName,treasureId,needCount)
	TreasureWanNengSuiPianView.super.ctor(self, winName)
    self.treasureId = treasureId
    self.needCount = tonumber(needCount)
    self.changeNums = 0
end

function TreasureWanNengSuiPianView:loadUIComplete()
	self:registerEvent()
    self:initUI()
end


function TreasureWanNengSuiPianView:setAlignment()
	--设置对齐方式
end

function TreasureWanNengSuiPianView:initUI()
    -- 
    self.UI_tc.txt_1:setString(GameConfig.getLanguage("#tid_treature_title_888"))
    -- 万能碎片
    self.wnFragId = "4050"
    local wnFragNum = ItemsModel:getItemNumById("4050") or 0
    local haveFragNum = wnFragNum
    if wnFragNum > self.needCount then
        wnFragNum = self.needCount
    end
    self.wnFragNum = wnFragNum
    self.UI_tou1:setResItemData({itemId = self.wnFragId,resNum = self.wnFragNum})
    -- self.mc_1.currentView.ctn_1:removeAllChildren()
    -- local wnSpr = display.newSprite(FuncRes.iconItemWithImage(FuncItem.getIconPathById(self.wnFragId)))
    -- self.mc_1.currentView.ctn_1:addChild(wnSpr)
    -- self.txt_num1:setString(haveFragNum)
    
    -- 法宝碎片
    local fragNum = ItemsModel:getItemNumById(self.treasureId) 
    self.UI_tou2:setResItemData({itemId = self.treasureId,resNum = fragNum})

    self.UI_tou1:setResItemNum(haveFragNum)
    self.UI_tou2:setResItemNum(fragNum)
    -- self.mc_2:showFrame(1)
    -- self.mc_2.currentView.ctn_1:removeAllChildren()
    -- local fbSpr = FuncRes.iconTreasureNew(self.treasureId)
    -- local treasureIcon = display.newSprite(fbSpr);
    -- treasureIcon:setScale(0.5)
    -- self.mc_2.currentView.ctn_1:addChild(treasureIcon)
    -- self.txt_num2:setString(fragNum)
    self.fragNum = fragNum

    local sliderChange = function (...)
        self:delayCall(function ()
            local num = self.slider_r:getTxtPercent() 
            self.changeNums = num
            self.txt_5:setString(num .." / "..wnFragNum)
            self.UI_tou1:setResItemNum(haveFragNum -  num)
            self.UI_tou2:setResItemNum(fragNum +  num)
        end,0.1)
    end
    -- 滑动条
    self.slider_r:setMinMax(0, wnFragNum);
    self.slider_r:onSliderChange(sliderChange);
    self.slider_r:setPercent(0)
    self.slider_r.txt_percent:visible(false)
    self.txt_5:setString(0 .." / "..wnFragNum)

    if wnFragNum <= 0 then
        self.slider_r:setTouchEnabled(false)
    else
        self.slider_r:setTouchEnabled(true)
    end

end

function TreasureWanNengSuiPianView:registerEvent()
    TreasureWanNengSuiPianView.super.registerEvent();
    self:registClickClose("out");
    self.UI_tc.btn_close:setTap(c_func(function ()
        self:startHide()
    end, self))


    self.btn_jia:setTap(c_func(self._changnum, self,1))
    self.btn_jian:setTap(c_func(self._changnum, self,-1))
    self.UI_tc.mc_1:showFrame(1)
    local btn_1 = self.UI_tc.mc_1.currentView.btn_1
    btn_1:setTap(c_func(function ()
        local callBackFunc = function ()
           
            local name = FuncTreasureNew.getTreasureDataByKeyID(self.treasureId,"name")
            name = GameConfig.getLanguage(name)
            
            local _str = string.format(GameConfig.getLanguage("#tid_treature_ui_012"),tostring(self.changeNums),name)
            WindowControler:showTips(_str)
            self:startHide()
        end
        if tonumber(self.changeNums) > 0 then
            TreasureNewServer:treasureDuihuan(self.treasureId,self.changeNums,callBackFunc)
        else
            --#tid_treature_45204    当选择的万能碎片数量为0时，点击转化按钮
            local tips = GameConfig.getLanguage("#tid_treature_45204");
            WindowControler:showTips(tips)
        end
        
    end, self))
end
function TreasureWanNengSuiPianView:_changnum(_num)
    local wnFragNum = ItemsModel:getItemNumById("4050") or 0
    if _num > 0 then
        if tonumber(self.changeNums) >= self.needCount then
            --#tid_treature_45203    进度条最大，碎片数量已经足够升星时，再次点击“+”
            local tips = GameConfig.getLanguage("#tid_treature_45203");
            WindowControler:showTips(tips)
        elseif wnFragNum == tonumber(self.changeNums) and tonumber(self.changeNums) < self.needCount then 
            --#tid_treature_45202   进度条最大，且万能碎片不足时，再次点击“+”
            local tips = GameConfig.getLanguage("#tid_treature_45202");
            WindowControler:showTips(tips)
        else
            self:chuangNum(1)
        end
    else
        if tonumber(self.changeNums) == 0 then
            --#tid_treature_45201  进度条最小时，再次点击“-”号
            local tips = GameConfig.getLanguage("#tid_treature_45201");
            WindowControler:showTips(tips)
        else
            self:chuangNum(-1)
        end
    end
end
function TreasureWanNengSuiPianView:chuangNum(count)
    local num = self.changeNums+count
    local wnFragNum = ItemsModel:getItemNumById("4050") or 0
    if wnFragNum > self.needCount then
        wnFragNum = self.needCount
    end
    if num >= 0 and num <= wnFragNum then
        self.changeNums = num

        self.slider_r:setPercent(self.changeNums/self.wnFragNum*100)
        self.txt_5:setString(self.changeNums .." / "..self.wnFragNum)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_treature_ui_013")) 
    end
end


return TreasureWanNengSuiPianView
