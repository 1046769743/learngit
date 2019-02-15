--
--Author:      zhuguangyuan
--DateTime:    2018-03-10 10:21:53
--Description: 散灵法阵界面
-- 法阵id self.runeTempleId
-- 生效符文id self.curRuneId
--1. 展示该层聚灵格子的属性
--2. 改变该层聚灵格子的属性,有次数限制

local TowerRuneTempleView = class("TowerRuneTempleView", UIBase);

function TowerRuneTempleView:ctor(winName,runeTempleId,curRuneId,gridPos)
    TowerRuneTempleView.super.ctor(self, winName)
    self.runeTempleId = runeTempleId
    self.curRuneId = curRuneId
    self.gridPos = gridPos
    self.runeTempleData = FuncTower.getRuneTempleDataByID(runeTempleId) 
end

function TowerRuneTempleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerRuneTempleView:registerEvent()
	TowerRuneTempleView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function TowerRuneTempleView:initData()
	-- TODO
end

function TowerRuneTempleView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_065"))
	local leftTimes = self.runeTempleData.runeChgNum - TowerMainModel:getHasActiveRuneTimes()
	self.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_066"," "..leftTimes.." "))
	self:initScrollCfg()
end

function TowerRuneTempleView:initScrollCfg()
	self.panel_1:visible(false)
    -- 竖直滚动条
    local createItemFunc = function ( itemData )
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		self:setRuneData(itemData,itemView)
        return itemView
    end
    local updateItemFunc = function(itemData,itemView)
		self:setRuneData(itemData,itemView)
        return itemView
    end
    -- itemView参数配置
    self.scrollParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-250,width = 250,height = 230},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 90,
	        offsetY = 70,
	        widthGap = 40,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }
end

function TowerRuneTempleView:setRuneData( itemData,itemView )
	local runeId = itemData
	local runeData = FuncTower.getRuneDataByID(runeId)

	itemView.txt_1:setString(GameConfig.getLanguage(runeData.runeInstrunction))

	-- 无动画时的做法
	-- local runeSprite = display.newSprite(FuncRes.iconTowerEvent(runeData.runePng))
	-- runeSprite:pos(0,-30)
	-- itemView.ctn_1:removeAllChildren()
	-- itemView.ctn_1:addChild(runeSprite)

	local runeType = runeData.runeEventType
	if runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.SWORD then
        if not self.runeAniSword then
            self.runeAniSword = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_gongji", itemView.ctn_1, true, GameVars.emptyFunc) 
            self.runeAniSword:pos(0,-90)
        end
    elseif runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN then
        if not self.runeAniBloodRecovery then
            self.runeAniBloodRecovery = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_caoyao", itemView.ctn_1, true, GameVars.emptyFunc) 
            self.runeAniBloodRecovery:pos(0,-90)
        end
    elseif runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.ANGER_REGAIN then
        if not self.runeAniEnergyRecovery then
            self.runeAniEnergyRecovery = self:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_nuqi", itemView.ctn_1, true, GameVars.emptyFunc) 
            self.runeAniEnergyRecovery:pos(0,-90)
        end
    end

	if tostring(runeId) == tostring(self.curRuneId) then
		itemView.mc_1:showFrame(2)
	else
		itemView.mc_1:showFrame(1)
		local contentView = itemView.mc_1:getCurFrameView()
		contentView.btn_1:setTap(c_func(self.changeActivedRune,self,runeId))
	end
end

-- 变更生效的符文
function TowerRuneTempleView:changeActivedRune( _toActiveRuneId )
	echo("_______ 点击了 变更符文 按钮 ___________",_toActiveRuneId)
	if tostring(self.curRuneId) ~= tostring(_toActiveRuneId) 
        and TowerMainModel:getHasActiveRuneTimes() < self.runeTempleData.runeChgNum 
    then
        local params = {
        	runeId = _toActiveRuneId,
        	x = self.gridPos.x,
			y = self.gridPos.y,
        }
        local function changeRuneTypeCallback( serverData )
		    if serverData and serverData.error then
		    else
		    	local data = serverData.result.data
		    	-- dump(data, "改变聚灵格子属性请求返回的数据")
		        TowerMainModel:updateData(data)
		        local runeId = _toActiveRuneId
		        -- 通知model变更 生效符文id
		        EventControler:dispatchEvent(TowerEvent.TOWER_CHANGE_RUNE_SUCCEED,{newRuneId = runeId})
		        self.curRuneId = runeId 
		        self:updateScrollView()
		        local leftTimes = self.runeTempleData.runeChgNum - TowerMainModel:getHasActiveRuneTimes()
				self.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_066",leftTimes))
		    end
        end
        TowerServer:changeRuneTempleType(params,c_func(changeRuneTypeCallback))
    else
    	WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_124"))
    end
end

function TowerRuneTempleView:initViewAlign()
	-- TODO
end

function TowerRuneTempleView:updateUI()
	self.allRuneList = self.runeTempleData.runeEventTypeContain
	self:updateScrollView()
end

function TowerRuneTempleView:updateScrollView()
	if not self.hasInitScrollView then
		self.scrollParams[1].data = self.allRuneList
		self.scroll_1:styleFill(self.scrollParams)
		self.hasInitScrollView = true
	else
		self.scroll_1:refreshCellView(1)
	end
end
function TowerRuneTempleView:deleteMe()
	-- TODO

	TowerRuneTempleView.super.deleteMe(self);
end

function TowerRuneTempleView:press_btn_close()
	self:startHide()
end


return TowerRuneTempleView;
