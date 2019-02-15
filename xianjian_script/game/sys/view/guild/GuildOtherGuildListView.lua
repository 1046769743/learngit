-- GuildOtherGuildListView
-- Author: Wk
-- Date: 2017-11-22
-- 其它公会界面
local GuildOtherGuildListView = class("GuildOtherGuildListView", UIBase);
---1 公会列表第一界  2 查找界面  3 受邀界面

function GuildOtherGuildListView:ctor(winName)
    GuildOtherGuildListView.super.ctor(self, winName);
    self.selectAll = GuildModel.selectShowAll
    self.page = 1
    self.selectpage = 1  --默认选择是公会列表第一页

end

function GuildOtherGuildListView:loadUIComplete()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildMemberList_002")) 
	self.UI_1.btn_1:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registerEvent()
	self:initData()
	self:registClickClose("out")
end 

function GuildOtherGuildListView:registerEvent()

end

function GuildOtherGuildListView:initData()

	self.cellData = GuildModel:getAddGuildData()
	self:initScrollList(self.cellData)
end


--初始化滚动列表
function GuildOtherGuildListView:initScrollList(data)
	local alldata = data
	local newalldata = {} 
	local index = 1
	for i=1,#alldata do
		if alldata[i]._id ~= "0" then
			newalldata[index] = alldata[i]
			index = index + 1
		end
	end

	self.panel_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view        
    end


 	local params =  {
        {
            data = newalldata,
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 25,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 900, height =120},
            perFrame = 0,
        }
        
    }
    self.scroll_1:styleFill(params)
    self.scroll_1:onScroll(c_func(self.onMyListScroll, self))
    if #alldata > FuncGuild.pageNum then
    	self.scroll_1:gotoTargetPos(#alldata - FuncGuild.pageNum,1,2);
    end
end
function GuildOtherGuildListView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    if event.name == "scrollEnd" then
        -- echo("111111111111111111111111111111111111111111111'")
        local groupIndex,posIndex =  self.scroll_1:getGroupPos(2)
        -- echo("=======groupIndex========posIndex=========",groupIndex,posIndex)
        if groupIndex == 1 then 
        	if math.fmod(#self.cellData, FuncGuild.pageNum) == 0  then  
	            if posIndex == #self.cellData then
	                self.page = self.page + 1
	                self:getpageDataList()
	            end
	        end
        end
    end
end
function GuildOtherGuildListView:getpageDataList()
	local function _callback(_param)
		-- dump(_param.result,"公会列表数据",8)
		if _param.result then
			local datalist = _param.result.data.guild
			-- GuildModel:setguildAllList(datalist)
			for k,v in pairs(datalist) do
				table.insert(GuildModel.guildAllList,v)
			end
			local addnum = table.length(datalist)
			if addnum < 10 then
				self.addnum = true
			end
			self.cellData = GuildModel.guildAllList
			self:initScrollList(self.cellData)
		end
	end

	local params = {
		page = self.page,
		all = 1,
	};
	if not self.addnum then
		GuildServer:listGuild(params,_callback)
	end
end
function GuildOtherGuildListView:dataListSort(datalist)
	datalist = self:allsortList(datalist)
	return datalist
end

--全部仙盟排序
function GuildOtherGuildListView:allsortList(datalist)
	table.sort(datalist,function(a,b)
        local rst = false
        if a.level > b.level then
            rst = true
        elseif a.level == b.level then
            if a._id > b._id then
                rst = true
            else
                rst = false
            end
        else
            rst = false
        end 
        return rst
	end)
	return datalist
end


function GuildOtherGuildListView:updateItem(view,itemdata)

	local level = itemdata.level
	local guildname = itemdata.name
	local guilddata = FuncGuild.getGuildLevelByPreserve(level)
	local sumpeoplenum =  tonumber(guilddata.nop)
	local hasnum = itemdata.members  or 0--有几个成员
	local des = itemdata.desc
	if des == nil or des == "" then
		des = FuncGuild.getdefaultDec()--仙盟描述
	end

	local frame = itemdata.afterName or 1  ---那个盟

	local panel = view
	local guildIcon =  {
		borderId = itemdata.logo or 1,
		bgId = itemdata.color or 1,
		iconId = itemdata.icon or 1,
	}
	panel.UI_1:initData(guildIcon)
	--等级
	local levelpanel = panel.txt_1
	levelpanel:setString(level..GameConfig.getLanguage("#tid_guildAddCell_001")) 
	--描述
	local describe = panel.txt_4
	describe:setString(des)

	local peoplenumber = panel.txt_3
	peoplenumber:setString(hasnum.."/"..sumpeoplenum)


	local guildName = GuildModel.guildName
	local data = FuncGuild.getguildType()
	
	local namestid  = data[tostring(frame)].afterName
	local names = GameConfig.getLanguage(namestid)
		--仙盟名称
	local name = panel.txt_2
	name:setString(guildname..names)


end

function GuildOtherGuildListView:press_btn_close()
	
	self:startHide()
end


return GuildOtherGuildListView;
