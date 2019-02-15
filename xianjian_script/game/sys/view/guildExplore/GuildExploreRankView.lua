-- GuildExploreRankView
--[[
	Author: wk
	Date:2018-07-06
	Description: 仙盟探索排行
]]
-- FuncGuildExplore.rankType
-- resRank
-- mineRank

local GuildExploreRankView = class("GuildExploreRankView", UIBase);
local maxlistNum = 10
function GuildExploreRankView:ctor(winName,allData)
    GuildExploreRankView.super.ctor(self, winName)

    self.select_type = allData.type or FuncGuildExplore.rankType.resRank
    self.allData  = allData
    self.getrankTab = {
		rank = 1,
		rankEnd = maxlistNum,
	}
end



function GuildExploreRankView:loadUIComplete()
	self:registerEvent()

	self:showButtonIsSelect()

	self:initData()
	self:setMySelfData()
end 

function GuildExploreRankView:getRankData()
	---获取排行榜的数据

	 local function callBack(_param)
        
        if (_param.result ~= nil) then
        	-- _cell:setVisible(true)
            dump(_param.result," 探索的排行榜数据 ====",7)
            local data = _param.result.rankList
            self:getPaiHangBangDataSorting(data)
            local myselfdata = {
            	rank = data.rank or 0,
   --          	score = data.score or 0,
   --          	name = UserModel:name(),
   --          	rid = UserModel:rid(),
   --          	ability = 0,--自身的战力  --
        	}
   --          self:setMySelfData(myselfdata)
   -- --          self.allData = {}
			self:initData()
        end
    end

	local params = {
		type = self.select_type,
		startRank = self.getrankTab.rank,
		endRank = self.getrankTab.rankEnd,
	}

	GuildExploreServer:getguildExploreRankData(params,callBack)

end
--数据排序
function GuildExploreRankView:getPaiHangBangDataSorting(data)
	if table.length(data) ~= 0 then
		for k,v in pairs(data) do
			table.insert(self.allData.rankList,v)
		end
	end
	-- dump(self.allData.rankList,"55555555555555")
end

function GuildExploreRankView:registerEvent()
	GuildExploreRankView.super.registerEvent(self);
	self.panel_1.panel_2:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_105"))
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self:registClickClose("out")
	self.mc_1:setTouchedFunc(c_func(self.setButton, self,FuncGuildExplore.rankType.resRank),nil,true);
	self.mc_2:setTouchedFunc(c_func(self.setButton, self,FuncGuildExplore.rankType.mineRank),nil,true);



end

function GuildExploreRankView:setButton(index)
	if self.select_type == index then
		return 
	end
	
	self.getrankTab = {
		rank = 1,
		rankEnd = maxlistNum,
	}
	self.allData.rankList = {}
	self.select_type = index
	self:showButtonIsSelect()
	self.selectYQRefresh = true
	self:getRankData()

end
function GuildExploreRankView:showButtonIsSelect()
	local _type = self.select_type
	if _type == FuncGuildExplore.rankType.resRank then
		self.mc_1:showFrame(2)
		self.mc_2:showFrame(1)
		-- self.mc_3:showFrame(1)
	elseif _type == FuncGuildExplore.rankType.mineRank then
		self.mc_1:showFrame(1)
		self.mc_2:showFrame(2)
		-- self.mc_3:showFrame(2)
	end
end


function GuildExploreRankView:initData()

	-- dump(self.allData,"2222222222222222222")

	local data = self.allData.rankList



	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1.panel_2);
        self:setCell(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:setCell(view, itemData)
	end
	-- dump(data,"333333333333333")


    local  _scrollParams = {
        {
            data =  data,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -70, width = 527, height = 70},
            perFrame = 1,
        }
    }    
    self.panel_1.scroll_1:refreshCellView( 1 )
    self.panel_1.scroll_1:styleFill(_scrollParams);
    self.panel_1.scroll_1:hideDragBar()
    self.panel_1.scroll_1:onScroll(c_func(self.onMyListScroll, self))
    if self.selectYQRefresh then
    	self.panel_1.scroll_1:gotoTargetPos(1,1 ,0)
    	self.selectYQRefresh = false
    end

end


function GuildExploreRankView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    local maxnum = 50--FuncWonderland.getMaxlistNum()
    local num = maxlistNum
    if event.name == "scrollEnd" then
    	local rankList = self.allData.rankList
    	if #rankList < maxnum then
	    	local groupIndex,posIndex =  self.panel_1.scroll_1:getGroupPos(2)
	    	-- echo("=======groupIndex=========",groupIndex)
	        if groupIndex == 1 then 
	        	-- echo("========#self.allData=======",#self.allData,num)
	        	if math.fmod(#rankList, num) == 0  then  
	        		if #rankList >= maxlistNum then
	        			-- echo("========#self.allData=======",posIndex)
			            if posIndex == #rankList then
			                self.getrankTab = {
								rank = self.getrankTab.rank + maxlistNum,
								rankEnd = self.getrankTab.rankEnd + maxlistNum,
							}
							self:getRankData()
			            end
			        end
		        end
	        end
	    end
    elseif event.name == "moved" then

    end
end




function GuildExploreRankView:setCell(baseCell,itemData)
	-- if 1 then
	-- 	return 
	-- end

	local rid = itemData.id
	if rid == UserModel:rid() then
		baseCell.panel_ziji:setVisible(true)
	else
		baseCell.panel_ziji:setVisible(false)
	end
	local rank = itemData.rank or 1
	if rank <= 3 then
		baseCell.mc_2:showFrame(rank)
	else
		baseCell.mc_2:showFrame(4)
		local txt_1 = baseCell.mc_2:getViewByFrame(4).txt_1
		txt_1:setString(rank)
	end

	baseCell.UI_1:setPlayerInfo(itemData)
	local name = itemData.name or "仙剑"
	baseCell.txt_name:setString(name)

	local ability = itemData.ability.formationTotal or 100000 ---战力

	baseCell.txt_lv:setString(ability)
end

function GuildExploreRankView:setMySelfData()
	self.panel_1.panel_4.panel_ziji:setVisible(true)
	local rank = self.allData.selfRank.rank or 0
	if rank and rank ~= 0 then
		if rank <= 3 then
			self.panel_1.panel_4.mc_1:showFrame(rank)
		else
			self.panel_1.panel_4.mc_1:showFrame(4)
			local txt_1 = self.panel_1.panel_4.mc_1:getViewByFrame(4).txt_1
			txt_1:setString(rank)
		end
	else
		self.panel_1.panel_4.mc_2:showFrame(5)
	end

	local name = UserModel:name()
	self.panel_1.panel_4.txt_name:setString(name)
	local ability = UserModel:getcharSumAbility()
	self.panel_1.panel_4.txt_lv:setString(ability)
	local playerData = {
			level = UserModel:level(),
			head = UserModel:head(),
			avatar = UserModel:avatar(),
			frame = UserModel:frame(),
		}
	self.panel_1.panel_4.UI_1:setPlayerInfo(playerData)
end





function GuildExploreRankView:deleteMe()
	-- TODO

	GuildExploreRankView.super.deleteMe(self);
end

return GuildExploreRankView;
