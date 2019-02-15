-- GuildExploreHippBuffView
--[[
	Author: wk
	Date:2018-07-11
	Description: buff列表
]]

local GuildExploreHippBuffView = class("GuildExploreHippBuffView", UIBase);

function GuildExploreHippBuffView:ctor(winName)
    GuildExploreHippBuffView.super.ctor(self, winName)
end

function GuildExploreHippBuffView:loadUIComplete()
	self:registerEvent()
end 

function GuildExploreHippBuffView:registerEvent()
	GuildExploreHippBuffView.super.registerEvent(self);
	self.panel_1:setVisible(false)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.Right)
    self.scroll_1._touchBg:setTouchedFunc(c_func(self.nullCellfun,self), nil, false)
end
function GuildExploreHippBuffView:nullCellfun()
end

function GuildExploreHippBuffView:initData(data)
    self._currentUpData = data
	local isok,buffArr = GuildExploreModel:getbuffList()  --buff列表
    -- local newArr = {}
    -- for i=1,#buffArr do
    --     local count = buffArr[i].count
    --     if count then
    --         for index = 1, count do
    --             local data = {
    --                 count = index,
    --                 index = buffArr[i].index,
    --                 tid   = buffArr[i].tid,
    --             }
    --             table.insert(newArr,data)
    --         end
    --     end
    -- end

	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:setCell(baseCell, itemData)
        return baseCell;
    end
     local updateFunc = function (itemData,view)
    	self:setCell(view, itemData)
	end
    self.indexCount = 1

    local  _scrollParams = {
        {
            data = buffArr ,
            createFunc = createFunc,
            updateCellFunc= updateFunc,
            perNums = 1,
            offsetX = 30,
            offsetY = 2,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 251, height = 40},
            perFrame = 0,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
    self.scroll_1:setCanScroll( false )

end

function GuildExploreHippBuffView:setCell( baseCell, itemData )


    -- dump(itemData,"32333333")

	local buffId = itemData.tid  ---itemData.key
	local effectData =  self:getFuncData( buffId, "effect" )
	local res = string.split(effectData[itemData.index], ",")
	local _type = res[1] --itemData.key --res[1]
	local valuerMore = tonumber(res[2]) --tonumber(itemData.model) --res[2]
	local value = tonumber(res[3]) --tonumber(itemData.value) --res[3]

	local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(_type)].name)
    local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
        Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist
    }
    if valuerMore == 2 then   ---万分比
	    value = (value/100).."%"
    else
        if table.indexof(percentKeyArr, buteData[tostring(_type)].keyName) then
            value = (value/100).."%"
        end
	end
	baseCell.rich_2:setString(buteName.."<color=008c0d>+"..value.."<->")

	local num = itemData.count
	baseCell.rich_1:setString("下<color=008c0d>"..num.."<->场:")


    if self._currentUpData then
        for k,v in pairs(self._currentUpData) do
            if v.tid ==itemData.tid  and v.count > 0 then
                if not baseCell.enterAni then
                    baseCell.enterAni = self:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_tigaoshuju", baseCell, false, GameVars.emptyFunc)
                    baseCell.enterAni:pos(125,-11)
                end
                baseCell.enterAni:startPlay(false, false, true)
                break
            end
            
        end
    end
    

    
    -- self.indexCount = self.indexCount + 1
end
function GuildExploreHippBuffView:getFuncData( buffId, key )
	local cfgsName = "ExploreBuff"
	local buffId = buffId
	local keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,buffId,key)
	return keyData
end


return GuildExploreHippBuffView;
