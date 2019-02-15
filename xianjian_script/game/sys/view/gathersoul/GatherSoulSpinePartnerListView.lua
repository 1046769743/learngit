-- GatherSoulSpinePartnerListView.lua

--[[
	Author: wk
	Date:2018-08-2
	Description: TODO
]]

local GatherSoulSpinePartnerListView = class("GatherSoulSpinePartnerListView", UIBase);


function GatherSoulSpinePartnerListView:ctor(winName,pantnerId)
    GatherSoulSpinePartnerListView.super.ctor(self, winName)
    self.pantnerId = pantnerId
end

function GatherSoulSpinePartnerListView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:cerateView(self.pantnerId)
end 

function GatherSoulSpinePartnerListView:registerEvent()
	GatherSoulSpinePartnerListView.super.registerEvent(self);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.MiddleBottom)
	self:registClickClose("out")
end

function GatherSoulSpinePartnerListView:initData()
	self.allpantner = {}
	self.alldata = NewLotteryModel:getallPreviewData()
	for i=1,#self.alldata do
		if self.alldata[i]._type == "18" then
			table.insert(self.allpantner,self.alldata[i])
		end
	end

	self.panel_2.panel_1:setVisible(false)
	local createCellFunc = function ( itemData )
    	local view = UIBaseDef:cloneOneView(self.panel_2.panel_1);
        self:updateItem(view,itemData)
        return view        
    end


    local updateCellFunc = function (itemData,view )
        self:updateItem(view,itemData)
    end

	local params = {
		{
            data = self.allpantner,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc, 
            -- perNums = 5,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 2,
            itemRect = {x = 0, y = -150, width = 130, height =150},
            perFrame = 1,
    	}
    }

    self.panel_2.scroll_1:styleFill(params)
    self.panel_2.scroll_1:hideDragBar()
    local posIndex = 1
    for k,v in pairs(self.allpantner) do
    	if v.itemID == self.pantnerId then
    		posIndex = tonumber(k)
    	end
    end

    self.panel_2.scroll_1:gotoTargetPos(posIndex, 1 ,1)

end

function GatherSoulSpinePartnerListView:updateItem(view,itemData)

	local _partnerId = itemData.itemID
	view.UI_1:updataUI(_partnerId)

	view.panel_1:setVisible(false)
	if _partnerId == self.pantnerId then
		view.panel_1:setVisible(true)
	end
	view:setTouchedFunc(c_func(self.selectCerateView, self,itemData),nil,true);

end

function GatherSoulSpinePartnerListView:selectCerateView(itemData)

	self.pantnerId = itemData.itemID
	for k,v in pairs(self.allpantner) do
		local _cell = self.panel_2.scroll_1:getViewByData(v)
		if _cell then
			_cell.panel_1:setVisible(false)
			if v.itemID == itemData.itemID then
				_cell.panel_1:setVisible(true)
			end
		end
	end
	self:cerateView(itemData.itemID)

end

function GatherSoulSpinePartnerListView:cerateView(pantnerId)
	echo("==========pantnerId=======",pantnerId)
	local function cellFunc()
		self:button_close()
	end
	if not self.compInfoView then
		self.compInfoView  = WindowsTools:createWindow("PartnerCompInfoView",{id = pantnerId},{},false,nil,cellFunc)
		self.compInfoView:setPositionY(40)
		self:addChild(self.compInfoView)
	else
		self.compInfoView:frishUIData({id = pantnerId},UserModel:data(),false,nil,true)
	end
end

function GatherSoulSpinePartnerListView:initView()
	-- TODO
end

function GatherSoulSpinePartnerListView:initViewAlign()
	-- TODO
end
function GatherSoulSpinePartnerListView:button_close()
	self:startHide()
end

function GatherSoulSpinePartnerListView:deleteMe()
	-- TODO

	GatherSoulSpinePartnerListView.super.deleteMe(self);
end

return GatherSoulSpinePartnerListView;
