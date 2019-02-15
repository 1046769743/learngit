--[[
	Author: TODO
	Date:2017-11-02
	Description: TODO
]]

local WuXingAllTreasureView = class("WuXingAllTreasureView", UIBase);

function WuXingAllTreasureView:ctor(winName,params)
    WuXingAllTreasureView.super.ctor(self, winName)
    self.tempPos = params
end

function WuXingAllTreasureView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingAllTreasureView:registerEvent()
	WuXingAllTreasureView.super.registerEvent(self);
	self:registClickClose("out")
end

function WuXingAllTreasureView:initData()
	-- TODO
end

function WuXingAllTreasureView:initView()
    self._root:setPosition(self.tempPos.x-320,self.tempPos.y+80)
	self:initScrollView()
end

function WuXingAllTreasureView:initScrollView()
	local tempFrontRowData= TeamFormationModel:getFrontRowNature(1)
	local tempMiddleRowData= TeamFormationModel:getFrontRowNature(2)
	local tempBackRowData= TeamFormationModel:getFrontRowNature(3)
	self.txt_name1:visible(false)
	self.txt_name2:visible(false)
	self.txt_name3:visible(false)
	self.txt_1:visible(false)
	self.txt_2:visible(false)
	self.txt_3:visible(false)


	local createRankItemFuncOne = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self["txt_name"..itemData]);
        return baseCell;
	end
	local createRankItemFuncTwo = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.txt_1);
    	if itemData == 1 then
    		baseCell:setString(GameConfig.getLanguage("tid_common_2059")) 
		else
			self:updataItemText(itemData,baseCell)
		end
        return baseCell;
	end


	 local  _scrollParams = {
        {
            data = {1},
            createFunc = createRankItemFuncOne,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 8,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 97, height = 40},
            perFrame = 1,
        },
        {
            data = tempFrontRowData,
            createFunc = createRankItemFuncTwo,
            -- updateFunc= updateFunc,
            perNums = 2,
            offsetX = 20,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 135, height = 40},
            perFrame = 1,
        },
        {
            data = {2},
            createFunc = createRankItemFuncOne,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 8,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 97, height = 40},
            perFrame = 1,
        },
        {
            data = tempMiddleRowData,
            createFunc = createRankItemFuncTwo,
            -- updateFunc= updateFunc,
            perNums = 2,
            offsetX = 20,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 135, height = 40},
            perFrame = 1,
        },
        {
            data = {3},
            createFunc = createRankItemFuncOne,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 8,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 97, height = 40},
            perFrame = 1,
        },
        {
            data = tempBackRowData,
            createFunc = createRankItemFuncTwo,
            -- updateFunc= updateFunc,
            perNums = 2,
            offsetX = 20,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 135, height = 40},
            perFrame = 1,
        }
    } 
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(_scrollParams);
end

function WuXingAllTreasureView:initViewAlign()
	-- TODO
end

function WuXingAllTreasureView:updataItemText(data,view)
   local tempType = TeamFormationModel:isCanConVert(data.key)
	if data.mode == 3 and tempType then
		view:setString(data.name.."+"..data.value)
	else	
		local textValue = data.value/100
        textValue = string.format("%0.1f", textValue) 
		view:setString(data.name.."+"..textValue.."%")
	end		
end

function WuXingAllTreasureView:updateUI()
	-- TODO
end

function WuXingAllTreasureView:press_close()
    self:startHide()
end

function WuXingAllTreasureView:deleteMe()
	-- TODO

	WuXingAllTreasureView.super.deleteMe(self);
end

return WuXingAllTreasureView;
