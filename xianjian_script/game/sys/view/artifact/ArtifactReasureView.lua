--[[
	Author: TODO
	Date:2018-03-20
	Description: TODO
]]

local ArtifactReasureView = class("ArtifactReasureView", UIBase);

function ArtifactReasureView:ctor(winName,ccid)
    ArtifactReasureView.super.ctor(self, winName)
    self.attrList = ArtifactModel:getSingleInitAttr(ccid)
    self.ccListdata = ArtifactModel:getCCAttrlistTable(202)
end

function ArtifactReasureView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ArtifactReasureView:registerEvent()
	ArtifactReasureView.super.registerEvent(self);
	self:registClickClose("out")
	self.btn_close:setTouchedFunc(c_func(self.startHide, self),nil,true)
	-- self.mc_1.currentView.btn_1:setTap(c_func(self.startHide, self))
end

function ArtifactReasureView:initData()

	local itemData = ArtifactModel:getAllData()

	local showData = {}
	for i=1,#itemData do
		local id = tostring(itemData[i].id)
		local data = ArtifactModel:getSingleInitAttr(id)
		-- dump(data,"神器数据")
		for k,v in pairs(data) do
			local noData = true
			for h,j in pairs(showData) do
				if j.key == v.key then
					showData[h].value = showData[h].value + v.value
					noData = false
				end 
			end
			if noData then
				showData[#showData+1] = v
			end
		end
	end

	dump(showData,"神器总数据")

	local newData = {}
	for k,v in pairs(self.ccListdata) do
		local quality = ArtifactModel:getCimeliaCombinequality(v.ccid)
		if quality >= v.quality then 
			table.insert(newData,v)
		end
	end

	local createLeftItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_ewtx);
        self:cellLeftviewData(baseCell, itemData)
        return baseCell;
    end

    local createLeftItemFunc2 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_ewtx);
        self:cellLeftviewData2(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = showData,
            createFunc = createLeftItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = -150, y = -40, width = 150, height = 40},
            perFrame = 0,
        },
        -- {
        --     data = newData,
        --     createFunc = createLeftItemFunc2,
        --     -- updateFunc= updateFunc,
        --     perNums = 1,
        --     offsetX = 0,
        --     offsetY = 10,
        --     widthGap = 0,
        --     heightGap = 0,
        --     itemRect = {x = 0, y = -40, width = 150, height = 40},
        --     perFrame = 0,
        -- }
    }
    self.scroll_2:styleFill(_scrollParams);
    self.panel_ewtx:setVisible(false)
end

function ArtifactReasureView:initView()
	-- TODO
end

function ArtifactReasureView:initViewAlign()
	-- TODO
end

function ArtifactReasureView:updateUI()
	-- TODO
end

function ArtifactReasureView:cellLeftviewData( baseCell,itemData )
	local des = ArtifactModel:getDesStaheTable(itemData,false)
		-- dump(des,"22222222222222222222")
	baseCell:setVisible(true)
	baseCell.rich_1:setString(des)
	local str = itemData.value
	local attrKey = itemData.key
	local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
        Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist,
    }
    local attrData = FuncBattleBase.getAttributeData(attrKey)
    local attrKeyName = attrData.keyName
 	if table.indexof(percentKeyArr,attrKeyName ) then
 		local desvalue = itemData.value/100
		str = desvalue.."%"
    else
    	if itemData.mode == 2 then   ---万分比
		    local desvalue = itemData.value/100
		    str = desvalue.."%"
		end
    end

    
	baseCell.rich_2:setString("<color=008c0d>"..str.."<->")
end

function ArtifactReasureView:cellLeftviewData2( baseCell,itemData )
	local quality = ArtifactModel:getCimeliaCombinequality(itemData.ccid)
	local des = GameConfig.getLanguage(itemData.skillUpDes)
	local namestr =  "等级"..itemData.quality
	local _str = des--attrname.."+"..valuer.."("..des..")"
	local color = "<color=8C9695>"
	if quality >= itemData.quality then 
		-- Frame = 1
		-- baseCell:showFrame(Frame)
		color = "<color=008c0d>"
	elseif itemData.quality == (quality + 1) then  --下一个阶级显示黄色
		-- Frame  = 2
		-- baseCell:showFrame(Frame)
		color = "<color=89674B>"
	end
	baseCell.rich_1:setString(namestr)
	baseCell.rich_2:setString(color.._str.."<->")
end

function ArtifactReasureView:deleteMe()
	-- TODO

	ArtifactReasureView.super.deleteMe(self);
end

return ArtifactReasureView;
