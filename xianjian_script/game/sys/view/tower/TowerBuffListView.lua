--[[
	Author: ZhangYanguang
	Date:2017-08-11
	Description: buff属性展示界面
]]

local TowerBuffListView = class("TowerBuffListView", UIBase);

function TowerBuffListView:ctor(winName)
    TowerBuffListView.super.ctor(self, winName)
end

function TowerBuffListView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initListParams()
	self:initView()
	self:updateUI()
end 

function TowerBuffListView:registerEvent()
	TowerBuffListView.super.registerEvent(self);
    self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.clickClose,self))
	self.UI_1.mc_1.currentView:setTouchedFunc(c_func(self.clickClose,self))
end

function TowerBuffListView:initData()
	local attrArr = TowerMainModel:getBuffAttrList()
	local attrs = self:formatAttribute(attrArr)
	self.attrDesList = {}
	for k,v in pairs(attrs) do
		local item = {}
		item.des = v.name .. "+" .. v.value
		item.key = FuncPartner.ATTR_KEY_MC[tostring(v.key)]
		self.attrDesList[#self.attrDesList+1] = item
	end

	-- 五灵属性对应名 映射
	self.mapPropertyToName = {
	        "风抗性",
	        "雷抗性",
	        "水抗性",
	        "火抗性",
	        "土抗性",
	}
	local soulBuffList = TowerMainModel:getOwnWulingProperty() or {}
	for k,v in pairs(soulBuffList) do
		local item = {}
		item.des = self.mapPropertyToName[tonumber(k)] .. "+" .. string.format("%.0f", v/100).."%"
		item.key = 1
		self.attrDesList[#self.attrDesList+1] = item
	end
end 

function TowerBuffListView:initListParams()
	self.panel_1:setVisible(false)

	local createAttrItemView = function(attrDes)
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		itemView.txt_1:setString(attrDes.des)
		itemView.mc_1:showFrame(attrDes.key)
		return itemView
	end

	self.listParams = 
	{
		{
			data = self.attrDesList,
	        createFunc = createAttrItemView,
	        itemRect = {x=0,y=0,width = 210,height = 60},
	        perNums= 2,
	        offsetX = 20,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = -13,
	        perFrame = 2,p
		}
	}
end

-- 获取格式化的战斗属性值 比如 是免伤率  attrValue 传进来的是500 那就 返回 5%  如果是 攻击力 返回500
function TowerBuffListView:formatAttribute(attrInfoArr)
    local attrDatas = {}
    for k,v in pairs(attrInfoArr) do
        local attrData =  FuncBattleBase.getAttributeData(v.key)
        local attrName = FuncBattleBase.getAttributeName(v.key)
        local attrOrderId = attrData.order

        local info = {}
        info.name = attrName
        info.value = FuncBattleBase.getFormatFightAttrValueByMode(v.key,v.value,v.mode)
        info.attrOrderId = attrOrderId
        info.mode = v.mode
        info.key = v.key
        -- 小于0的属性不显示
        if info.attrOrderId > 0 then
            attrDatas[#attrDatas+1] = info 
        end
    end

    table.sort(attrDatas , function(a,b) 
        if a.attrOrderId < b.attrOrderId then
            return true
        end
    end)

    return attrDatas
end

function TowerBuffListView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_003")) 
	self.panel_upkong:setVisible(false)
end

function TowerBuffListView:updateUI()
	if #self.attrDesList == 0 then
		self.panel_upkong:setVisible(true)
	else
		self.scroll_1:styleFill(self.listParams)
	end
end

function TowerBuffListView:clickClose()
	self:startHide()
end


function TowerBuffListView:deleteMe()
	-- TODO

	TowerBuffListView.super.deleteMe(self);
end

return TowerBuffListView;
