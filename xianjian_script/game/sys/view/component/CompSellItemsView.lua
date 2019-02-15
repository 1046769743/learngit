
local CompSellItemsView = class("CompSellItemsView", UIBase);
function CompSellItemsView:ctor(_winName,itemDatas)
    CompSellItemsView.super.ctor(self, _winName);
--    self.itemDatas = {
--        [1] = { id = "9051", num = 10 },
--        [2] = { id = "9052", num = 10 },
--        [3] = { id = "9053", num = 10 },
--        [4] = { id = "9054", num = 10 },
--        [5] = { id = "9055", num = 10 },
--    }
    self.itemDatas = itemDatas
end

function CompSellItemsView:loadUIComplete()
    self.iii = 0
    self:registerEvent();
    self:initView()
end
function CompSellItemsView:initView()
    self.UI_tc.txt_1:setString("自动出售")
    local _template_panel = self.UI_1
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(_template_panel)
        self:updateItemView(_item,_view)
        return _view
    end
    --updateCellFunc
    local function updateCellFunc(_item,_view,_index)
        self:updateItemView(_item,_view)
    end
    --param
    local _param = {
        data = self.itemDatas,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        perNums = 3,
        offsetX = 40,
        offsetY = 20,
        widthGap = 5,
        heightGap = 0,
        itemRect = {x=0,y=-132.3, width = 135,height = 132.2},
        perFrame = 2,
    }
    self.scroll_1:styleFill({_param})
    _template_panel:visible(false)

    local num = 0
    for i,v in pairs(self.itemDatas) do
        local itemData = FuncItem.getItemData(v.id);
        num = num + v.num * tonumber(itemData.useEffect)
    end
    
    self.panel_1.txt_2:setString(self:getDisplayNumStr(num))
end
function CompSellItemsView:updateItemView(itemData,view)
    local data = {
        itemId = itemData.id,          --道具ID
        itemNum = itemData.num,         --道具数量
    }
    view:setResItemData(data)
    view:showResItemName(true,true,nil,true)
    view:showResItemNameWithQuality()
end
function CompSellItemsView:registerEvent()
    CompSellItemsView.super.registerEvent(self);
    self:registClickClose("out");
    self.UI_tc.btn_close:setTap(c_func(self.clickButtonClose, self));
    self.UI_tc.mc_1:showFrame(1)
    self.UI_tc.mc_1.currentView.btn_1:setTap(c_func(self.sellItemsClick, self));
end
--出售银票
function CompSellItemsView:sellItemsClick()
    local data = {}
    for i,v in pairs(self.itemDatas) do
        data[tostring(v.id)] = v.num          
    end
    ShopServer:sellItem({items = data},c_func(self.sellItemsClickCallBack,self))
end
function CompSellItemsView:sellItemsClickCallBack(event)
    echo("出售成功")
    self:clickButtonClose()
end
function CompSellItemsView:getDisplayNumStr(displayNum, isFloor)
	local suffix = ""
	local final = displayNum
	if isFloor == nil then isFloor = true end
	
	if displayNum/10^6 > 1 then --万
		suffix = "万"
		displayNum = math.floor(displayNum/10^3)
		final = string.format("%.1f", displayNum/10^1)
		if isFloor then
			local newNum = math.ceil(tonumber(final))
			if newNum == tonumber(final) then
				final = newNum
			end
		end
	else
		final = displayNum
	end
	return final..suffix
end
function CompSellItemsView:clickButtonClose()
    self:startHide();
end


return CompSellItemsView;
