--[[
	Author: TODO
	Date:2017-08-14
	Description: TODO
]]

local TowerChooseBuffTarget = class("TowerChooseBuffTarget", UIBase);

function TowerChooseBuffTarget:ctor(winName,chooseType,BuffId,targetPos,targetType,viewPos,tempTeam,isHasHero)
    TowerChooseBuffTarget.super.ctor(self, winName)
    self.buffId = BuffId
    self.targetPos = targetPos
    self.viewType = chooseType
    if self.viewType == FuncTower.CHOOSEHERO_TYPE.FORMATION_VIEW then
        self.targetType = targetType
        self.viewPos = viewPos
        self.tempTeam = tempTeam
        self.hasHero  = isHasHero
    end
end

function TowerChooseBuffTarget:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerChooseBuffTarget:registerEvent()
    self:registClickClose("out")
	TowerChooseBuffTarget.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
end

function TowerChooseBuffTarget:initData()
    if self.viewType == FuncTower.CHOOSEHERO_TYPE.SHOP_VIEW then
    	local shopData = FuncTower.getShopBuffData(self.buffId)
    	self.buffData = shopData.recovery[1]
    	self.buffData = string.split(self.buffData,",")
    	self.BuffType = self.buffData[1]
        self.teamData = TowerMainModel:getBruiseTeamFormation(tonumber(self.BuffType),true,0)
    elseif self.viewType == FuncTower.CHOOSEHERO_TYPE.GOODS_VIEW then
        local viewData = FuncTower.getGoodsData(self.buffId)
        self.buffData = viewData.attribute[1]
        self.buffData = string.split(self.buffData,",")
        tempType = self.buffData[1]
        if tonumber(tempType)  == 1 then
            self.BuffType = 3 
        else
            self.BuffType = 1
        end
        self.teamData = TowerMainModel:getBruiseTeamFormation(tonumber(self.BuffType),true,0)
    else
        self.teamData = TowerMainModel:getBruiseTeamFormation(nil,self.hasHero,self.targetType,true)
    end    
    dump(self.teamData,"self.teamData")
end

function TowerChooseBuffTarget:initView()

    if self.viewType == FuncTower.CHOOSEHERO_TYPE.SHOP_VIEW or self.viewType == FuncTower.CHOOSEHERO_TYPE.GOODS_VIEW then
        if tonumber(self.BuffType) == 1 then
    		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_008")) 
    	elseif tonumber(self.BuffType) == 2 then
    		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_009"))
        else
    		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_012"))
    	end
    else
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_011"))
    end

	self:createBruiseScroll()
end

function TowerChooseBuffTarget:initViewAlign()
	-- TODO
end

function TowerChooseBuffTarget:updateUI()
	-- TODO
end

function TowerChooseBuffTarget:deleteMe()
	-- TODO

	TowerChooseBuffTarget.super.deleteMe(self);
end

function TowerChooseBuffTarget:press_btn_close()
    self:startHide()
end

function TowerChooseBuffTarget:createBruiseScroll()
    if table.length(self.teamData) == 0 then
        self.mc_1:showFrame(2)
        self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.press_btn_close,self))
    else
        self.UI_1.mc_1.currentView.btn_1:visible(false)
    	self.mc_1.currentView.panel_1:visible(false)
    	local createCellFunc = function(itemData)
            local view = UIBaseDef:cloneOneView(self.mc_1.currentView.panel_1);
            self:updateItem(view, itemData)
            return view
        end
        local updateCellFunc = function ( data,view )
            self:updateItem(view, data)
        end

        self.scrollParams = {
            {
                data = self.teamData,
                createFunc = createCellFunc,
                perNums = 1,
                offsetX = 18,
                offsetY = 10,
                widthGap = 0,
                updateCellFunc = updateCellFunc,
                heightGap = 0,
                itemRect = {x = 0, y = -130, width = 575, height =130},
                perFrame = 1,
            }
            
        }
        self.mc_1.currentView.scroll_1:styleFill(self.scrollParams)
     end   
end

function TowerChooseBuffTarget:updateItem(view, itemData)
	local star = itemData.star
    view.UI_1.mc_dou:visible(true)
    if star ==0 then
        view.UI_1.mc_dou:visible(false)
    else
        view.UI_1.mc_dou:showFrame(star)
    end
	local quality = itemData.quality
    local qualityNum = nil
    if tonumber(itemData.id) == 101 or tonumber(itemData.id) ==104 then
        qualityNum = FuncChar.getCharQualityDataById(quality).border
    else
        qualityNum = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
    end
    view.UI_1.mc_di:showFrame(tonumber(qualityNum))
    view.UI_1.mc_kuang:showFrame(tonumber(qualityNum))
    local icon = itemData.icon

    --这里应该判断是否是主角
    if tonumber(itemData.id) == 101 or tonumber(itemData.id) ==104 then
        local avatarId = UserModel:avatar()
        -- local iconid = UserModel:head()
        local charSkin = GarmentModel:getOnGarmentId()
        icon = FuncPartner.getPartnerIconByIdAndSkin(avatarId, charSkin) --FuncUserHead.getHeadIcon(iconid,avatarId)
        icon:setScale(1.2)
        view.txt_1:setString(itemData.name)
    else
        view.txt_1:setString(GameConfig.getLanguage(itemData.name))
        icon = display.newSprite( FuncRes.iconHero(icon) ):scale(1.2)
    end

    view.UI_1.ctn_1:removeAllChildren()
    view.UI_1.txt_1:visible(false)
    view.UI_1.panel_lv:visible(false)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:setScale(1.2)

    -- 通过遮罩实现头像裁剪
    local  _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite, icon)

    view.UI_1.ctn_1:addChild(_spriteIcon)
    view.panel_p1.progress_1:setPercent(itemData.HpPercent/100)
    if tonumber(itemData.HpPercent)> 0 then
        view.panel_wang:visible(false)
    else
        view.panel_wang:visible(true)
    end   
    -- view.panel_p2.progress_1:setPercent(itemData.fury/100)
    if self.viewType == FuncTower.CHOOSEHERO_TYPE.SHOP_VIEW  or self.viewType == FuncTower.CHOOSEHERO_TYPE.GOODS_VIEW then
        if tonumber(self.BuffType) == 3 then
            view.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_010"))
            if tonumber(itemData.HpPercent) <= 0 then
                view.mc_1.currentView.btn_1:setTap(c_func(self.useBuff,self,itemData.id))
            else
                view.mc_1.currentView.btn_1:setTap(c_func(self.stopBuffEffect,self))
            end    
    	elseif tonumber(self.BuffType) == 2 then
          --   view.mc_1:showFrame(2)
          --   view.mc_1.currentView.btn_1:getUpPanel().txt_1:setString("增加")
          --   if tonumber(itemData.fury) <= 10000 and tonumber(itemData.HpPercent) > 0 then
        		-- view.mc_1.currentView.btn_1:setTap(c_func(self.useBuff,self,itemData.id))
          --   else
          --       view.mc_1.currentView.btn_1:setTap(c_func(self.stopBuffEffect,self))
          --   end   
    	else 
    		view.mc_1:showFrame(2) 
    		view.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_012"))	
            if tonumber(itemData.HpPercent) <= 10000 and tonumber(itemData.HpPercent) > 0 then
                view.mc_1.currentView.btn_1:setTap(c_func(self.useBuff,self,itemData.id))
            else
                view.mc_1.currentView.btn_1:setTap(c_func(self.stopBuffEffect,self))
            end   
    	end
    else
        view.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_013"))
        if tonumber(itemData.HpPercent) <= 10000 and tonumber(itemData.HpPercent) > 0 then
            view.mc_1.currentView.btn_1:setTap(c_func(self.goIntoPos,self,self.viewPos,itemData))
        else
            view.mc_1.currentView.btn_1:setTap(c_func(self.stopBuffEffect,self))
        end   
    end
end	

function TowerChooseBuffTarget:stopBuffEffect()
     WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_014")) 
end

function TowerChooseBuffTarget:useBuff(userId)
	local params = {}
	params.buffId = self.buffId
	params.partnerId = userId
    if self.viewType ~= FuncTower.CHOOSEHERO_TYPE.GOODS_VIEW then 
        params.x = self.targetPos.x
        params.y = self.targetPos.y
        TowerServer:buyShopBuff(params,c_func(self.useBuffEffect,self))
    else
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=self.buffId,partnerId = userId})  
        self:startHide()
    end    
	
end

function TowerChooseBuffTarget:goIntoPos(viewPos,heroData)
    local params = {}
    params.pos = viewPos
    params.heroData = heroData
    EventControler:dispatchEvent(TowerEvent.TOWEREVENT_GOINTO_MATRIXMETHOD,params)
    self:startHide()
end

function TowerChooseBuffTarget:useBuffEffect(event)
	if event.error then

	else
		TowerMainModel:updateData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BUYBUFF_TOWER_SUCCESS,{id = self.buffId})
		self:startHide()
	end
end

return TowerChooseBuffTarget;
