-- GuildInfoUIView
-- Author: Wk
-- Date: 2017-09-30
-- 公会详情ui界面
local GuildInfoUIView = class("GuildInfoUIView", UIBase);

function GuildInfoUIView:ctor(winName)
    GuildInfoUIView.super.ctor(self, winName);
end

function GuildInfoUIView:loadUIComplete()
	self:registerEvent()
	self:setGuildIconAndInfo()
	self:showAnnouncement()
	self:setchatInfo()

end 

function GuildInfoUIView:registerEvent()
	EventControler:addEventListener(GuildEvent.AMEND_STR_EVENT, self.showAnnouncement, self)

	EventControler:addEventListener(GuildEvent.REFRESH_MEMBERS_LIST_EVENT, self.setGuildIconAndInfo, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

--设置仙盟图标
function GuildInfoUIView:setGuildIconAndInfo()
	local panel = self.panel_2
	panel.UI_1:initData()

	local guildName = GuildModel.guildName 
	
	---少一个仙盟类型后期加上去

	local guildchar = GuildModel._guildcharinfo
	local leadername = GuildModel._guildcharinfo.name or "少侠"
	local level = GuildModel:getGuildLevel()
	panel.txt_2:setString((level or 1).."级")
	local guildType = guildName._type
	local postype = GuildModel:gettMyselfpos()
	local str = FuncGuild.byIdAndPosgetName(guildType,1)
	panel.txt_3:setString("当前"..str..":")
	local guildName = GuildModel.guildName
	local data = FuncGuild.getguildType()
	local namestid  = data[tostring(guildType)].afterName
	local names = GameConfig.getLanguage(namestid)
	panel.txt_4:setString("  "..leadername)
	panel.txt_1:setString(guildName.name..names)

	local _baseGuildInfo = GuildModel._baseGuildInfo
	panel.txt_6:setString("  ".._baseGuildInfo.markId)
	local sumnum = FuncGuild.getGuildLevelByPreserve(level).nop 
	local peoplenum = GuildModel._baseGuildInfo.members
	-- echo("=====peoplenum================",peoplenum)
	panel.txt_8:setString("  "..peoplenum.."/"..sumnum)

	local groupId = GuildModel:getGroupID()
	if groupId == nil or  tonumber(groupId) == 0 then
		groupId = GameConfig.getLanguage("#tid_group_guild_1506")
	end

	panel.txt_10:setString("  "..groupId)
	self:setGropuIdButton()
end

function GuildInfoUIView:setGropuIdButton()
	local panel = self.panel_2
	-- local isboos = GuildModel:judgmentIsBoos()
	-- if isboos then
	-- 	panel.btn_gai:setVisible(true)
		panel.btn_gai:setTouchedFunc(c_func(self.modifyGroupID, self),nil,true);
	-- else
	-- 	panel.btn_gai:setVisible(false)
	-- end
end

function GuildInfoUIView:modifyGroupID()
	echo("=====修改群号的按钮==============")
	local isboos = GuildModel:judgmentIsBoos()
	if isboos then
		WindowControler:showWindow("GuildAnnouncement",3);
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
	end
end

--显示公告
function GuildInfoUIView:showAnnouncement()
	local notice = GuildModel._baseGuildInfo
	local panle = self.panel_3
	panle.txt_2:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panle.txt_2);
        self:updateTextItem(view)
        return view        
    end
	local params =  {
        {
            data = {1},  ---alldata
            createFunc = createCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -280, width = 193, height =280},
            perFrame = 1,
        }
        
    }
    panle.scroll_2:cancleCacheView();
    panle.scroll_2:styleFill(params)
    panle.scroll_2:initDragBarVisible(false)
    panle.btn_gai:setTouchedFunc(c_func(self.modificationNotice, self),nil,true);

end

function GuildInfoUIView:updateTextItem(view)
	local text = GuildModel._baseGuildInfo
	view:setString(text.notice)
end





function GuildInfoUIView:modificationNotice()
	echo("修改公告按钮")
	-- local isboos = GuildModel:judgmentIsForZBoos()
	local declaration = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"declaration")
	if declaration == 1 then
		WindowControler:showWindow("GuildAnnouncement",2);
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
	end
end

function GuildInfoUIView:setchatInfo()

	local chatdata = self:findType()

	local panle = self.panel_1
	panle.rich_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panle.rich_1);
        self:updatechatItem(view,itemData)
        return view        
    end


	self.params =  {
        {
            data = chatdata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 3,
            itemRect = {x = 0, y = -35, width = 640, height =35},
            perFrame = 0,
        }
        
    }
    panle.scroll_1:cancleCacheView();
    panle.scroll_1:styleFill(self.params)
    panle.scroll_1:initDragBarVisible(false)
    panle.scroll_1:gotoTargetPos(tonumber(#chatdata),1,2);
    -- self.oneindexcell = 1
    -- self.twoindexcell = 1
    -- self.updatetime = 1
    -- self.twoeTestindes = false
    -- self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end

function GuildInfoUIView:updatechatItem(view,itemData)
	-- dump(itemData,"111111111111111")
	local str = GuildModel:paramGuildEvent(itemData)
	view:setString(str)
end


function GuildInfoUIView:findType()
	local chatdata = GuildModel.allchatEventData 
	local newchatdata = {}

	local index = 1
	-- dump(chatdata,"4444444444444")
	for i=1,table.length(chatdata) do
		if chatdata[i] ~= nil then
			if chatdata[i].type ~= FuncGuild.GuildEventType.Donate 
				and chatdata[i].type ~= FuncGuild.GuildEventType.FinishTask 
				and chatdata[i].type ~= FuncGuild.GuildEventType.Pay
				then
				-- echo("=======chatdata[i].type=====2222=====",chatdata[i].type)
				newchatdata[index] = chatdata[i]
				index = index + 1
			end
		end
	end
	local lastchat = {}
	local newIndex = 1
	for i=1,#newchatdata do
		local itemData = newchatdata[i]
		local str = GuildModel:paramGuildEvent(itemData)
		if str ~= "" then
			lastchat[newIndex] = itemData
			newIndex = newIndex  + 1
		end
	end

	lastchat = self:sortList( lastchat )

	return lastchat
end
function GuildInfoUIView:sortList( arrdata )
	table.sort(arrdata,function(a,b)
        local rst = false
        if a.time < b.time then
            rst = true
        end 
        return rst
   	end)
   	return arrdata
end


function GuildInfoUIView:press_btn_close()
	
	self:startHide()
end


return GuildInfoUIView;
