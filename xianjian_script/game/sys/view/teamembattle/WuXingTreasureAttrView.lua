--[[
	Author: TODO
	Date:2018-05-14
	Description: TODO
]]

local WuXingTreasureAttrView = class("WuXingTreasureAttrView", UIBase);

function WuXingTreasureAttrView:ctor(winName)
    WuXingTreasureAttrView.super.ctor(self, winName)
end

function WuXingTreasureAttrView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingTreasureAttrView:registerEvent()
	WuXingTreasureAttrView.super.registerEvent(self);

	self.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
	EventControler:addEventListener(TeamFormationEvent.TEAMVIEW_HAS_CLOSED, self.startHide, self)
end

function WuXingTreasureAttrView:initData()
	self.tempFrontRowData = TeamFormationModel:getFrontRowNature(1)
	self.tempMiddleRowData = TeamFormationModel:getFrontRowNature(2)
	self.tempBackRowData = TeamFormationModel:getFrontRowNature(3)
	-- dump(self.tempFrontRowData, "\n\nself.tempFrontRowData====")
	-- dump(self.tempMiddleRowData, "\n\nself.tempMiddleRowData====")
	-- dump(self.tempBackRowData, "\n\nself.tempBackRowData====")
end

function WuXingTreasureAttrView:initView()
	-- TODO
end

function WuXingTreasureAttrView:initViewAlign()
	-- TODO
end

function WuXingTreasureAttrView:updateUI()
	local len1 = #self.tempFrontRowData
	local len2 = #self.tempMiddleRowData
	local len3 = #self.tempBackRowData

	local offsetY1 = math.floor((len1 - 1) / 2) * 46
	local offsetY2 = math.floor((len2 - 1) / 2) * 46
	local offsetY3 = math.floor((len3 - 1) / 2) * 46


	self.panel_1:setVisible(false)
	local createFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateAttrItem(view, itemData)
		return view
	end

	local params = {
		{
			data = {1},
            createFunc = createFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(100 + offsetY1), width = 300, height = 100 + offsetY1},
            perFrame = 1,
            cellWithGroup = 1,
		},
		{
			data = {2},
            createFunc = createFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(100 + offsetY2), width = 300, height = 100 + offsetY2},
            perFrame = 1,
            cellWithGroup = 1,
		},
		{
			data = {3},
            createFunc = createFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(100 + offsetY3), width = 300, height = 100 + offsetY3},
            perFrame = 1,
            cellWithGroup = 1,
		},
	}

	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function WuXingTreasureAttrView:updateAttrItem(view, itemData)
	view.panel_1:setVisible(false)
	local attrs = {}
	if itemData == 1 then
		attrs = self.tempFrontRowData
		view.txt_1:setString(GameConfig.getLanguage("#tid_team_des_001"))
	elseif itemData == 2 then
		attrs = self.tempMiddleRowData
		view.txt_1:setString(GameConfig.getLanguage("#tid_team_des_002"))
	else
		attrs = self.tempBackRowData
		view.txt_1:setString(GameConfig.getLanguage("#tid_team_des_003"))
	end

	for i,v in ipairs(attrs) do
		local txt_attr = UIBaseDef:cloneOneView(view.panel_1)
		if v == 1 then
			txt_attr.mc_1:setVisible(false)
	        txt_attr.txt_2:setString(GameConfig.getLanguage("#tid_team_des_004"))
	    else
	    	txt_attr.mc_1:setVisible(true)
	        local tempType = TeamFormationModel:isCanConVert(v.key)
	        if v.mode == 3 and tempType then
	            txt_attr.txt_2:setString(v.name.."+"..v.value)
	        else    
	            local textValue = v.value/100
	            textValue = string.format("%0.1f", textValue) 
	            txt_attr.txt_2:setString(v.name.."+"..textValue.."%")
	        end
	        txt_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
	    end
	    local offsetX = ((i - 1) % 2) * 200
	    local offsetY = math.floor((i - 1) / 2) * 40
	    txt_attr:addto(view)
	    txt_attr:pos(30 + offsetX, -(45 + offsetY))
	end
	view.panel_2:pos(6, -80 - math.floor((#attrs - 1) / 2) * 40)
end

function WuXingTreasureAttrView:deleteMe()
	-- TODO

	WuXingTreasureAttrView.super.deleteMe(self);
end

return WuXingTreasureAttrView;
