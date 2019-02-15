--
--Author:      zhuguangyuan
--DateTime:    2017-07-31 22:07:30
--Description: 时装主界面，下方滚动条展示所有时装
-- 注意定时器的使用
-- 或者在时间显示的刷新函数里调用


local GarmentMainView = class("GarmentMainView", UIBase);

function GarmentMainView:ctor(winName, _id, _callBack)
    GarmentMainView.super.ctor(self, winName)
    if _id == nil then
        self.id = UserModel:avatar()
    else
        self.id = _id
    end
    self._callBack = _callBack
    
end

function GarmentMainView:loadUIComplete()
	-- 初始化主角数据
	self:initData()
	self:initView()

	self:registerEvent()
	self:initViewAlign()

	self:updateUI()
end 



----------------------------------------------
--1 初始化数据
----------------------------------------------
function GarmentMainView:initData()
	self.indexDataMap = {}

    self.TabStatus = {
        ATTRIBUTE = 1,
        STORY = 2,
    }
    self.frameCount = 0
    --还剩多少秒
    self.leftTime = 0

    --得到性别
    self.chatacterSex = tonumber(UserModel:sex())

    if FuncPartner.isChar(self.id) then
        self.isChar = true
        -- 获得滚动条数据--当前avatar的排序后的所有时装的数据
        self.allGarments = GarmentModel:getAllGarmentsByOrder()

        -- 获取正在穿的时装
        self.dressingGarmentId = GarmentModel:getOnGarmentId()
    else
        self.isChar = false
        self.allGarments = PartnerSkinModel:getAllSkinByPartnerId(self.id)
        if PartnerModel:isHavedPatnner(self.id) then
            self.dressingGarmentId = PartnerSkinModel:getOnPartnerSkin(self.id)
        else
            self.notOwnPartner = true
            self.dressingGarmentId = self.allGarments[1]
        end
        
    end
    						 
    self.selectedGarmentId = self.dressingGarmentId
end

----------------------------------------------
--4 屏幕适配
----------------------------------------------
function GarmentMainView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_ren, UIAlignTypes.MiddleBottom);
end

----------------------------------------------
--2 初始化view 初始化滚动条
----------------------------------------------
function GarmentMainView:initView()
    if self.isChar then
        self.mc_res:showFrame(1)
    else
        self.mc_res:showFrame(2)
    end
	-- 中
	self.mcGarmentStatus = self.panel_1.mc_3	  -- 穿戴中、购买、超时等服装状态
	self.ctn_lihui = self.ctn_ren
	-- 右
    self.btn_add = self.panel_1.mc_3:getViewByFrame(3).btn_1
    self.panel_1.mc_3:getViewByFrame(3).txt_1:visible(false)
	self.ctnStandAnimation = self.panel_1.ctn_ren  -- 站立动画占位符

    self.anim = self:createUIArmature("UI_shizhuang", "UI_shizhuangtai", self.panel_1.ctn_comic, true)
    self.anim:setPosition(-4, 26.5)
	-- 下
	self.mcGarment = self.panel_2.panel_huayu            -- 时装单元
    self.mcGarment:setVisible(false)

	self.scrollGarments = self.panel_2.scroll_1
    self.mc_desc = self.panel_1.mc_2
    self:initScrollCfg() -- 初始化滚动条
end

----------------------------------------------
--3 注册事件
----------------------------------------------
function GarmentMainView:registerEvent()
    GarmentMainView.super.registerEvent(self)
    self.btn_back:setTouchedFunc(c_func(self.close, self))
    -- self.btnClose:setTap(c_func(self.startHide, self))
    self.panel_1.mc_shuxing:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.touchedTab, self))
    self.panel_1.mc_gushi:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.touchedTab, self))
    self.panel_2.btn_right:setTouchedFunc(c_func(self.touchedLeftBtn, self))
    self.panel_2.btn_left:setTouchedFunc(c_func(self.touchedRightBtn, self))
    -- 监听购买成功事件
    EventControler:addEventListener(GarmentEvent.GARMENT_BUY_SUCCESS_EVENT, self.buySuccessCall, self);
    EventControler:addEventListener(GarmentEvent.GARMENT_CHANGE_ONE,self.changeGarment, self); 
    EventControler:addEventListener(PartnerSkinEvent.SKIN_BUY_SUCCESS_EVENT, self.buySuccessCall, self)
    -- 时钟更新
    -- self.updateFrame 会间隔0秒循环调用
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0);

    -- 监听到服务器数据发生变化事件
    EventControler:addEventListener(GarmentEvent.GARMENT_SERVER_DATA_CHANGE, self.serverDataChange, self);
end

function GarmentMainView:close()
    EventControler:dispatchEvent(GarmentEvent.GARMENT_CLOSE_MAIN_UI, self.id) 
    self:startHide()
end
function GarmentMainView:touchedTab()
    if self.tapStatus == self.TabStatus.STORY then
        self.tapStatus = self.TabStatus.ATTRIBUTE
        self.descStatus = self.TabStatus.STORY
        
        self.mc_desc:showFrame(self.descStatus)
        self:updateDesc()
        self.panel_1.mc_shuxing:showFrame(1)
        self.panel_1.mc_gushi:showFrame(2)
    else
        self.tapStatus = self.TabStatus.STORY
        self.descStatus = self.TabStatus.ATTRIBUTE
        self.mc_desc:showFrame(self.descStatus)
        self:updateDesc()
        self.panel_1.mc_shuxing:showFrame(2)
        self.panel_1.mc_gushi:showFrame(1)
    end
end
-- 初始化滚动条
function GarmentMainView:initScrollCfg()
    local count = table.length(self.allGarments)
    local offset_x
    if count == 2 then
        offset_x = 120
    elseif count == 3 then
        offset_x = 70
    else
        offset_x = 10
    end
    local createItemFunc = function (itemData,itemIndex)
        local itemView = UIBaseDef:cloneOneView(self.mcGarment);
        self.indexDataMap[itemIndex] = itemData
        self:createOneGarmentCell(itemView, itemData)
        return itemView
    end

    local createOneGarmentCellFunc = function (itemData,itemView,itemIndex)
        self:createOneGarmentCell(itemView, itemData);
        self.indexDataMap[itemIndex] = itemData
        return itemView
    end

    self.GarmentListParams = { 
        {
            data = self.allGarments,
            createFunc = createItemFunc,
            updateCellFunc = createOneGarmentCellFunc,
            offsetX = offset_x,
            offsetY = 0,
            widthGap = 5,
            heightGap = 0,
            itemRect = {x = -10, y = -150, width = 110, height = 150},
        }
    };


    self.scrollGarments:styleFill(self.GarmentListParams)
    self.scrollGarments:hideDragBar();
end

----------------------------------------------
--5 更新ui
----------------------------------------------
function GarmentMainView:updateUI()
    local name = ""
    if self.isChar then
        name = UserModel:name()
    else
        name = FuncPartner.getPartnerName(self.id)
    end
    -- local params = {
    --     str = name,
    --     space = 1,
    --     txt = self.panel_name.txt_1
    -- }
    -- FuncCommUI.setVerTicalTXT(params)
    self.panel_name.rich_1:setString(name)
    -- 展示滚动条数据
    
    self.scrollGarments:refreshCellView(1)
    self.tapStatus = self.TabStatus.ATTRIBUTE
    self.descStatus = self.TabStatus.ATTRIBUTE
    -- self.mc_tab:showFrame(self.tapStatus)
    self.mc_desc:showFrame(self.descStatus)

    self:updateBg()
    
    -- 设置当前选中的时装
    self:updateGeneralView(self.selectedGarmentId);   --根据 garmentId 更改主版面
    self:updateGarmentStatus(self.selectedGarmentId); --根据 garmentId 更改服装状态显示
    self:updateDesc()

    self:touchedTab()
end

function GarmentMainView:updateBg()
    -- 设置背景
    local garmentId = self.selectedGarmentId
    local garmentBg = "garment_bg_beijing"
    local bg
    if self.isChar then        
        bg = FuncGarment.getCharGarmentBg(garmentId, UserModel:avatar())
        
    else
        bg = FuncPartnerSkin.getPartnerSkinBg(self.id, garmentId)  
    end


    if bg then
        garmentBg = bg
    end
    self:changeBg(garmentBg) 
end
-- 更新一个时装单元
function GarmentMainView:createOneGarmentCell(itemView, itemData)
    local garmentId = itemData;

    --时装名字
    local nameStr = ""
    local icon = nil
    if self.isChar then
        --是不是正在穿
        -- if GarmentModel:isOn(garmentId) == true then 
        --     self.dressingGarmentCell = itemView;
        -- end
        nameStr = FuncGarment.getGarmentName(garmentId)
        icon = FuncGarment.getGarmentIconSp(garmentId)
    else
        -- if PartnerSkinModel:getSkinStage(self.id, garmentId) == 1 then
        --     self.dressingGarmentCell = itemView;
        -- end
        nameStr = FuncPartnerSkin.getSkinName(garmentId)
        icon = FuncPartnerSkin.getPartnerIcon(garmentId)
    end
    
    --是否是选中的时装（亮色方框）
    if garmentId == self.selectedGarmentId then
        itemView.mc_xuan:showFrame(2)
    else
        itemView.mc_xuan:showFrame(1)
    end

    itemView.txt_name:setString(nameStr);

    itemView.ctn_ren:removeAllChildren();
    itemView.ctn_ren:addChild(icon);

    itemView:setTouchedFunc(c_func(self.touchedItemView, self, itemData))
end

function GarmentMainView:touchedItemView(garmentId)
    self.selectedGarmentId = garmentId
    self:updateUI()
end

-- 通过ID找到index
function GarmentMainView:getIndexById(_id)
    local index = 1
    -- dump(self.indexDataMap, "\n\nself.indexDataMap")
    for i,v in pairs(self.indexDataMap) do
        if v == self.selectedGarmentId then
            index = i
            break
        end
    end
    return index
end

function GarmentMainView:touchedLeftBtn()
    local selectIndex = self:getIndexById(self.selectedGarmentId)   
    if selectIndex <= 1 then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_Garment_005"))
        return
    else
        self:slideScrollToChooseItem(selectIndex - 1, 1)
    end   
end

function GarmentMainView:touchedRightBtn()
    local selectIndex = self:getIndexById(self.selectedGarmentId)
    local garmentNums = table.length(self.allGarments)
    if selectIndex >= garmentNums then
        WindowControler:showTips(GameConfig.getLanguage("#tid_Garment_005"))
        return
    else
        self:slideScrollToChooseItem(selectIndex + 1, 1)
    end
    
end
-- 滑动或点击选中滚动条中的某个item
function GarmentMainView:slideScrollToChooseItem(itemIndex,groupIndex)
    if itemIndex < 1 then
        itemIndex = 1
    end
     
    -- 根据索引得到对应的garmentId
    local garmentId = self.indexDataMap[itemIndex]

    self.selectedGarmentId = garmentId
    -- local count = table.length(self.allGarments)
    self.scrollGarments:gotoTargetPos(itemIndex, 1 , 1, false) 

    self:updateUI()  
end

--根据 garmentId 更改主版面
function GarmentMainView:updateGeneralView(garmentId)
    --动画
    local ani = nil
    if self.isChar then
        local charData = CharModel:getCharData()
        ani = FuncGarment.getSpineViewByAvatarAndGarmentId(UserModel:avatar(), garmentId,charData)
    else
        ani = FuncPartnerSkin.getSpineViewByAvatarAndPartnerId(garmentId)
        FilterTools.clearFilter(ani)
        self.anim:setVisible(true)
        if self.notOwnPartner and not PartnerSkinModel:isOwnOrNot(garmentId) then
            FilterTools.setGrayFilter(ani)
            self.anim:setVisible(false)
        end
    end
    ani:setScale(1.2)
    self.ctnStandAnimation:removeAllChildren()
    self.ctnStandAnimation:addChild(ani)
    ani:playLabel("stand")

    --立绘
    local avatarId = UserModel:avatar();
    local artSp = nil
    if self.isChar then
        artSp = FuncGarment.getGarmentLihui(garmentId, avatarId, "dynamic")
    else
        artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(self.id, garmentId)
        FilterTools.clearFilter(artSp)
        if self.notOwnPartner and not PartnerSkinModel:isOwnOrNot(garmentId) then
            FilterTools.setGrayFilter(artSp)
        end
    end
    -- artSp:setScale(1.2)
    self.ctn_lihui:removeAllChildren()
    self.ctn_lihui:addChild(artSp)
    -- self.ctnIcon:removeAllChildren();
    -- self.ctnIcon:addChild(artSp);
end

--根据 garmentId 更改服装状态显示
function GarmentMainView:updateGarmentStatus(garmentId)
    -- 判断当前时装是不是素颜时装(不用购买自动拥有) 再设置是否穿上
    -- 若不是素颜时装 则判断是否在穿 若在穿则显示在穿帧,并显示计时或永久 
    -- 若不在穿 则检查是否拥有时装
    -- 若不拥有时装则判断能否购买
    -- 服装过期
    if (self.isChar and tonumber(garmentId) == tonumber(GarmentModel.DefaultGarmentId)) 
        or (not self.isChar and tonumber(garmentId) == tonumber(PartnerSkinModel:getSuYanSkinId(self.id))) then 
        if self.isChar then
            if GarmentModel:isOn(garmentId) == true then 
                self.mcGarmentStatus:showFrame(3);  --穿戴中
                self.btn_add:setVisible(false)
            else 
                self.mcGarmentStatus:showFrame(2);  --穿戴
                local mc_chuandai = self.mcGarmentStatus.currentView.mc_1
                mc_chuandai:showFrame(3)

                --穿衣服btn
                local onBtn = self.mcGarmentStatus.currentView.btn_1
                onBtn:setVisible(true)
                onBtn:setTouchedFunc(c_func(self.onPutOnGarment, self, garmentId))
            end
        else
            --分为两种情况  拥有了奇侠和未拥有奇侠
            if self.notOwnPartner then
                self.mcGarmentStatus:showFrame(4)
                local partnerName = FuncPartner.getPartnerName(self.id)
                self.mcGarmentStatus.currentView.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_partner_skintips_01", partnerName))
            else
                if PartnerSkinModel:getSkinStage(self.id, garmentId) == 1 then 
                    self.mcGarmentStatus:showFrame(3);  --穿戴中
                    self.btn_add:setVisible(false)
                else 
                    self.mcGarmentStatus:showFrame(2);  --穿戴

                    local mc_chuandai = self.mcGarmentStatus.currentView.mc_1
                    mc_chuandai:showFrame(3)
                    --穿衣服btn
                    local onBtn = self.mcGarmentStatus.currentView.btn_1
                    onBtn:setVisible(true)
                    onBtn:setTouchedFunc(c_func(self.onPutOnGarment, self, garmentId))
                end
            end     
        end       
    elseif (self.isChar and GarmentModel:isOn(garmentId) == true) or 
        (not self.isChar and PartnerSkinModel:isOn(self.id, garmentId) == true) then 
        self.mcGarmentStatus:showFrame(3);  --穿戴中
        if (self.isChar and GarmentModel:isForeverOwn(garmentId) == true) or (not self.isChar) then
            self.btn_add:setVisible(false)
        else 
            self.btn_add:setVisible(true)
            self.mcGarmentStatus.currentView.mc_1:showFrame(1)  
            -- 倒计时开始
            -- 注意要服务端返回有效的过期时间才能调用此函数 不然没法正确开启计时
            GarmentModel:addTimeEventByGarmentId(garmentId)  
            self:countDown(garmentId)   --倒计时显示
            self.btn_add:setTouchedFunc(c_func(self.onBtnBuy, self, garmentId))
        end 

    elseif (self.isChar and GarmentModel:isOwnOrNot(garmentId) == true) or
        (not self.isChar and PartnerSkinModel:isOwnOrNot(garmentId) == true) then
        if self.notOwnPartner then
            self.mcGarmentStatus:showFrame(4)
            local partnerName = FuncPartner.getPartnerName(self.id)
            self.mcGarmentStatus.currentView.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_partner_skintips_03", partnerName))
        else
            self.mcGarmentStatus:showFrame(2);  --穿戴
            local mc_chuandai = self.mcGarmentStatus.currentView.mc_1
            if (self.isChar and GarmentModel:isForeverOwn(garmentId) == true) or (not self.isChar) then
                mc_chuandai:showFrame(3)
            else
                if GarmentModel:isBrandNew(garmentId) == true then
                    mc_chuandai:showFrame(1)
                    mc_chuandai.currentView.txt_1:setVisible(true)
                else 
                    mc_chuandai:showFrame(3)
                    mc_chuandai.currentView.txt_1:setVisible(true)
                end             
            end 
            --穿衣服btn
            local onBtn = self.mcGarmentStatus.currentView.btn_1 
            onBtn:setTouchedFunc(c_func(self.onPutOnGarment, self, garmentId))
        end    
    elseif (self.isChar and FuncGarment.getCondition(garmentId) == nil and FuncGarment.getActivity(garmentId, UserModel:avatar()) == nil) or 
        (not self.isChar and PartnerSkinModel:getSkinStage(self.id, garmentId) == 3) then
        self.mcGarmentStatus:showFrame(1);  --购买
        local buyBtn = self.mcGarmentStatus.currentView.btn_1
        buyBtn:setTouchedFunc(c_func(self.onBtnBuy, self, garmentId))

        if self.isChar then
            self.mcGarmentStatus.currentView.panel_huafei.mc_ziyuan:showFrame(1)
        else
            self.mcGarmentStatus.currentView.panel_huafei.mc_ziyuan:showFrame(2)
        end
        -- 显示 花费
        local txtCost = self.mcGarmentStatus.currentView.panel_huafei.txt_1
        local cost = FuncGarment.getGarmentCostById(self.id,garmentId)
        txtCost:setString(cost)

    elseif (not self.isChar and PartnerSkinModel:getSkinStage(self.id, garmentId) == 8) then
        self.mcGarmentStatus:showFrame(4)
        -- local partnerName = FuncPartner.getPartnerName(self.id)
        self.mcGarmentStatus.currentView.txt_1:setString("")
    elseif (self.isChar and FuncGarment.getActivity(garmentId, UserModel:avatar())) or 
        (not self.isChar and PartnerSkinModel:getSkinStage(self.id, garmentId) == 7) then
        self.mcGarmentStatus:showFrame(4)
        -- local partnerName = FuncPartner.getPartnerName(self.id)
        self.mcGarmentStatus.currentView.txt_1:setString("")
    else
        local buyBtn = self.mcGarmentStatus.currentView.btn_1
        buyBtn:setTouchedFunc(c_func(self.onBtnBuy, self, garmentId)) 
    end 

    local nameStr = ""
    if self.isChar then
        nameStr = FuncGarment.getGarmentName(garmentId)
    else
        nameStr = FuncPartnerSkin.getSkinName(garmentId)
    end
    
    self:updateDesc()
end

-- 展示id为garmentId的时装的故事
function GarmentMainView:onStoryShow(garmentId)
    WindowControler:showWindow("GarmentStoryView", garmentId);
end

-- 购买id为garmentId的时装
function GarmentMainView:onBtnBuy(garmentId)
    WindowControler:showWindow("GarmentBuyView", self.id, garmentId);
end

-- 点击穿戴按钮的响应函数
function GarmentMainView:onPutOnGarment(garmentId)
    self:addAnim( )
    if self.isChar then
        GarmentModel:dressGarment(garmentId)
    else
        local onSkinId = PartnerSkinModel:getDefaltSkinByPartnerId(self.id)
        -- self.dressingGarmentCell
        local suyanId = PartnerSkinModel:getSuYanSkinId(self.id)
        -- self.dressingGarmentCell = self.scrollGarments:getViewByData(self.dressingGarmentId)
        self.dressingGarmentId = garmentId
        if garmentId == suyanId then
            PartnerSkinServer:skinOnServer(self.id, "", c_func(self.clickOnCallBack, self))
        else
            PartnerSkinServer:skinOnServer(self.id, garmentId, c_func(self.clickOnCallBack, self))
        end
    end
end

function GarmentMainView:clickOnCallBack()
    self.selectedGarmentId = self.dressingGarmentId
    -- 隐藏上一个选中的cell的“穿戴中”panel
    -- 更新当前正在穿的cell--dressingGarmentCell并显示本cell的“穿戴中”panel
    -- self.dressingGarmentCell = self.scrollGarments:getViewByData(self.dressingGarmentId)

    self:updateUI()
end

--开始倒计时
function GarmentMainView:countDown(garmentId)
    -- 后面的时间变化显示靠 self.updateFrame 进行
    self.leftTime = GarmentModel:getLeftTime(garmentId)
    -- echo(" countDown 剩余时间为 ---- ",self.leftTime)
    local str = TimeControler:turnTimeSec( self.leftTime, TimeControler.timeType_dhhmmss)
    self.btn_add:setVisible(true)

    -- self.panelAdd:setVisible(true)
    self.mcGarmentStatus:getViewByFrame(3).mc_1:setVisible(true)
    -- self.panelAdd.mc_1:showFrame(2)  --显示剩余日时分秒
    self.mcGarmentStatus:getViewByFrame(3).mc_1:getViewByFrame(1).txt_1:setString(str) --设置文本框显示日时分秒
end
function GarmentMainView:updateDesc(garmentId)
    if not garmentId then
        garmentId = self.selectedGarmentId
    end
    -- 属性加成
    self.mc_desc:visible(false)

    local map1 = {"", "生命", "", "", "", 
                "", "", "", "", "攻击",
                "物防", "法防", "", "", ""
            }
    local attr = nil
    -- dump(attr, "\nattr")
    local strotyStr = ""
    if self.isChar then
        strotyStr = FuncGarment.getStoryStr(garmentId, UserModel:avatar())
        attr = FuncGarment.getValueByKey(garmentId, UserModel:avatar(), "attr")
    else
        strotyStr = FuncPartnerSkin.getStoryStr(garmentId)
        attr = FuncPartnerSkin.getAttr(garmentId)
    end
    local count = 1
    if self.descStatus == self.TabStatus.STORY then
        self.mc_desc:visible(true)
        local storyTxt = self.mc_desc.currentView.txt_1
        storyTxt:setString(strotyStr)
    else
        if attr then
            count = table.length(attr)
            -- echo("\n\ncount", count)
            self.mc_desc:visible(true)
            self.mc_desc:showFrame(self.descStatus)

            for i = 1, 4 do
                if i <= count then
                    self.mc_desc.currentView["txt_"..i]:setVisible(true)
                else
                    self.mc_desc.currentView["txt_"..i]:setVisible(false)
                end
            end

            for i,v in pairs(attr) do
                if v.mode == 3 or v.mode == "3" then
                    local str1 = map1[tonumber(v.key)]
                    local value = v.value
                    str1 = str1..": +"..value         
                    self.mc_desc.currentView["txt_"..i]:setString(str1)
                elseif v.mode == 2 or v.mode == "2" then
                    local str1 = map1[tonumber(v.key)]
                    local value = math.floor(v.value / 10000 * 100)
                    str1 = str1..": +"..value.."%"         
                    self.mc_desc.currentView["txt_"..i]:setString(str1)
                end                                  
            end
                       
        else
            self.mc_desc:visible(true)
            -- self.mc_desc:showFrame(1)
            self.mc_desc.currentView["txt_"..count]:setString(GameConfig.getLanguage("#tid_Garment_des_21703"))
            for i = count + 1, 4 do
                self.mc_desc.currentView["txt_"..i]:setVisible(false)
            end
        end
    end
    

    -- 判断属性是否已添加
    local has = false
    if self.isChar then
        has = GarmentModel:isOwnOrNot(garmentId)
    else
        has = PartnerSkinModel:isOwnOrNot(garmentId)
    end    
    
    if self.descStatus == self.TabStatus.ATTRIBUTE then
        self.mc_desc.currentView.mc_goumai:setVisible(true)
        self.mc_desc.currentView.panel_xian:setVisible(true)
        if self.notOwnPartner then
            if has then
                self.mc_desc.currentView.mc_goumai:showFrame(1)
                self.mc_desc.currentView.mc_goumai.currentView.txt_5:setString(GameConfig.getLanguage("#tid_partner_skintips_02"))
            else
                self.mc_desc.currentView.mc_goumai:setVisible(false)
                self.mc_desc.currentView.panel_xian:setVisible(false)
            end
        else
            if has then
                self.mc_desc.currentView.mc_goumai:showFrame(2)
            else
                self.mc_desc.currentView.mc_goumai:showFrame(1)
            end
        end
        
    end
end

-- 服装购买成功回调
function GarmentMainView:buySuccessCall(event)
    -- 更新当前选中的服装的id
    self.selectedGarmentId = event.params.garmentId
    self:updateUI()
end

-- 点击穿戴或者衣服时间到了
function GarmentMainView:changeGarment(event)
    local garmentId = event.params.garmentId
    -- 是穿着的衣服到期了
    if tonumber(garmentId) == tonumber(UserExtModel:garmentId()) then 
        self.dressingGarmentId = garmentId
        self.selectedGarmentId = garmentId

    else
        -- 不是正在穿戴的衣服到期
        -- 由于服务端有记录到期时间，故到期后他将自动将衣服置为可购买状态服
        -- 但是要更新本地滚动条的服装状态及排序 所以也要刷新 self:updateUI()
    end
    -- 更新当前正在穿的cell--dressingGarmentCell并显示本cell的“穿戴中”panel
    -- self.dressingGarmentCell = self.scrollGarments:getViewByData(self.dressingGarmentId)

    self:updateUI()
end

function GarmentMainView:serverDataChange()
    if UserExtModel:garmentId() ~= GarmentModel:getOnGarmentId() then
        GarmentModel:dressGarment( GarmentModel:getOnGarmentId() )
    end
end

-- 更新时装有效时间并显示
-- 注意此函数只负责显示
-- 到期事件是 TimeControler:startOneCd 启动后到期 TimeControler发的
function GarmentMainView:updateFrame()
    if self.leftTime == 0 then
        return;
    end

    if self.frameCount % GameVars.GAMEFRAMERATE == 0 then 
        local str = TimeControler:turnTimeSec( self.leftTime, TimeControler.timeType_dhhmmss )
        self.mcGarmentStatus:getViewByFrame(3).mc_1:setVisible(true)
        self.mcGarmentStatus:getViewByFrame(3).mc_1:getViewByFrame(1).txt_1:setString(str) 
        -- self.panelAdd.mc_1:showFrame(2);
        -- self.panelAdd.mc_1.currentView.txt_time:setString(str);

        self.leftTime = self.leftTime - 1;
        if self.leftTime < 0 then 
            self.leftTime = 0;
        end 
    end 
    self.frameCount = self.frameCount + 1;
end

function GarmentMainView:deleteMe()
	-- TODO
	GarmentMainView.super.deleteMe(self);
end

-- 穿戴成功之后的特效
function GarmentMainView:addAnim( )
    local anim = self:createUIArmature("UI_shizhuang", "UI_shizhuangtai_chuandaichenggongb", self.panel_1.ctn_comic, false)
    anim:setPosition(-4, 26.5)

    self:delayCall(function ( ... )
        local anim1 = self:createUIArmature("UI_shizhuang", "UI_shizhuangtai_chuandaichenggong", nil, false)
        self.ctn_lihui:addChild(anim1) 
        anim1:zorder(10)
        anim1:pos(50,500)
    end,1.0)
end

return GarmentMainView;






