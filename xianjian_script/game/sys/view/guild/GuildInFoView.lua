-- GuildInFoView
-- Author: Wk
-- Date: 2017-10-10
-- 仙盟详情界面
local GuildInFoView = class("GuildInFoView", UIBase);

function GuildInFoView:ctor(winName)
    GuildInFoView.super.ctor(self, winName);
end

function GuildInFoView:loadUIComplete()

	-- local panle = self.panel_1
	-- panle.rich_1:setVisible(false)
	-- self:viewAlign()
	GuildModel:getRinkGuildTaskData()
	self:initViewAlign()
	self:registerEvent()
    self:setButton()
    -- self:setGuildIconAndInfo()  --11
    -- self:showAnnouncement()  --11
    -- self:setchatInfo()
    -- self:getchatInfo()  --11
	-- self:initData()

	self:setBgUI()
	self:leafSignInitButton()
 	self:showButtonRed()

 	--获取仙盟红包数据
 	GuildRedPacketModel:getServeData()
 	--获取仙盟排行数据
 	GuildModel:getRankAllData()


end

function GuildInFoView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_t, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)

end


function GuildInFoView:showButtonRed()
	local issignred = GuildModel:signShowRed()
	local isbonusred = GuildModel:refreshGuildBaoKuRed()--GuildModel:bonusListRed() or GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed()
	local isblesred  = GuildModel:blessingRed() or GuildModel:bonusListRed() or GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed()
	local isapplyred = GuildModel:applysDataRed()
	local isdonationred = GuildModel:donationRed()
	local taskRed = GuildModel:getTaskRed()
	local redtable = {
		[1] = issignred,
		[2] = isbonusred,--isbonusred,  --红红利的   改成宝库了
		[3] = isblesred,
		[4] = false,
		[5] = false,
		[6] = isapplyred,
		[7] = isdonationred,
		[8] = taskRed,
		[9] = false,
	}

	local panel = self.panel_4
	for i=1,#redtable do
		if panel["btn_"..i] ~=  nil then
			panel["btn_"..i]:getUpPanel().panel_red:setVisible(redtable[i])
		end
	end
	echo("======self.select_type=====",self.select_type)
	local yeqian = self.panel_1
	for i=1,4 do
		-- 没有index为3的页签
		if i ~= 3 then
			local isshow = false
			yeqian["panel_yeqianred"..i]:setVisible(false)
			-- if i == self.select_yeqian_state then
			-- 	isshow = false
			-- 	yeqian["panel_yeqianred"..i]:setVisible(isshow)
			-- else
			if i == FuncGuild.Leaf_Sign_Type.INFO then
				isshow = isbonusred or isblesred or isdonationred
				-- echoError("\n=====isshow=======",isshow,"\nissignred====",issignred,"\nisblesred====",isblesred,"\nisdonationred====",isdonationred,"\nisdonationred====",isbonusred)
				yeqian["panel_yeqianred"..i]:setVisible(isshow)
			elseif i == FuncGuild.Leaf_Sign_Type.MEMBERS then
				isshow = isapplyred
				yeqian["panel_yeqianred"..i]:setVisible(isshow)
			elseif i == FuncGuild.Leaf_Sign_Type.APPLY then
				isshow = isapplyred
				yeqian["panel_yeqianred"..i]:setVisible(isshow)
			elseif i == FuncGuild.Leaf_Sign_Type.ACTIVE then
				-- local isGVEbossred  = GuildActMainModel:isShowGuildActRedPoint()
				local isShowGve = GuildActMainModel:isShowGuildActRedPoint()
				-- local isShowEctype = GuildBossModel:isShowGuildBossRedPoint()
				local guildExploreRed = GuildExploreModel:getEntranceRed()

				echo("========11111111======",isShowGve or isShowEctype or guildExploreRed or false)
				yeqian["panel_yeqianred"..i]:setVisible(isShowGve or isShowEctype or guildExploreRed or false)
			end
		end
	end

end

function GuildInFoView:registerEvent()
	-- EventControler:addEventListener(GuildEvent.AMEND_STR_EVENT, self.showAnnouncement, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_EVENT, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.REFRESH_SIGN_EVENT, self.showButtonRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_BOUNS_EVENT, self.showButtonRed, self)
	EventControler:addEventListener(GuildEvent.GET_QIFU_REWARD, self.showButtonRed, self)
	EventControler:addEventListener(GuildEvent.CLOSE_INFO_VIEW_EVENT, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.GUILD_AGREEANDNOTA_UI, self.showButtonRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_GUILD_WOOD_EVENT, self.showButtonRed, self)

	EventControler:addEventListener(GuildBossEvent.GUILDBOSS_REFRESH_BOSS_RED, self.showButtonRed, self)

	EventControler:addEventListener(GuildEvent.GUILD_REDPACKET_SHOW_RED, self.showButtonRed, self)
	
	EventControler:addEventListener(UIEvent.UIEVENT_STARTHIDE ,self.onUIShowComp,self)

	EventControler:addEventListener(GuildEvent.SHOW_APPLIST_VIEW ,self.showAppList,self)
	EventControler:addEventListener(GuildEvent.SHOW_MEMBLE_VIEW ,self.showMemberList,self)

	EventControler:addEventListener(GuildEvent.REFRESH_TASK_RED_UI ,self.showButtonRed,self)

	EventControler:addEventListener(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED, self.showButtonRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_TREASURE_MAIN_VIEW, self.showButtonRed,self)

	EventControler:addEventListener(GuildExploreEvent.GUILDE_EXPLORE_ROKOU_RED_FRESISH, self.showButtonRed, self)
end

function GuildInFoView:showMemberList()
	self:leafSignCellFung(2)
	
	
end

function GuildInFoView:onUIShowComp()
	GuildModel:sendHomeMainViewRed()
end

function GuildInFoView:showAppList()
	self:leafSignCellFung(3)
end



function GuildInFoView:setBgUI()

	-- self.UI_1.txt_1:setString("仙盟详情")
    self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
    -- self.UI_1:setTouchEnabled(true)
    -- self:registClickClose(-1, c_func( function()
    --     self:press_btn_close()
    -- end , self))
    -- self:registClickClose("out")
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_t,UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close,UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res,UIAlignTypes.LeftTop)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_t,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res,UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)





end

function GuildInFoView:getchatInfo()
	self:setchatInfo()
	-- GuildControler:getEvent(c_func(self.setchatInfo, self))
end




function GuildInFoView:setchatInfo()

	local chatdata = self:findType()

	local panle = self.panel_1
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
-- function GuildInFoView:updateFrame()

--  	if	math.fmod(self.updatetime,30) == 0 then
--  		local chatdata = self:findType()
--  		self.oneindexcell = self.oneindexcell  + 1
--  		if self.oneindexcell <= #chatdata then
-- 			self.panel_1.scroll_1:gotoTargetPos(self.oneindexcell + 9,1,2,1.0);
-- 		else
-- 			if self.twoeTestindes == false then
-- 				self:addItemCell()
-- 			else
-- 				if self.twoindexcell <= #chatdata then
-- 					self.panel_1.scroll_1:gotoTargetPos(self.twoindexcell,2,2,1.0);
-- 					self.twoindexcell = self.twoindexcell + 1
-- 				else
-- 					self.twoeTestindes = false
-- 					self.twoindexcell = 1
-- 				end
-- 			end
-- 		end
-- 	end

-- 	self.updatetime = self.updatetime + 1
-- end

-- function GuildInFoView:addItemCell()
-- 	self.twoeTestindes = true
-- 	local panle = self.panel_1
-- 	local createCellFunc = function ( itemData )
--         local view = UIBaseDef:cloneOneView(panle.rich_1);
--         self:updatechatItem(view,itemData)
--         return view        
--     end

-- 	local chatdata = self:findType()
-- 	local  params =  {
--         {
--             data = chatdata,  ---alldata
--             createFunc = createCellFunc,
--             -- updateCellFunc = updateCellFunc,
--             perNums = 1,
--             offsetX = 5,
--             offsetY = 0,
--             widthGap = 0,
--             heightGap = 3,
--             itemRect = {x = 0, y = -35, width = 640, height =35},
--             perFrame = 0,
--         },
--         {
--             data = chatdata,  ---alldata
--             createFunc = createCellFunc,
--             -- updateCellFunc = updateCellFunc,
--             perNums = 1,
--             offsetX = 5,
--             offsetY = 0,
--             widthGap = 0,
--             heightGap = 3,
--             itemRect = {x = 0, y = -35, width = 640, height =35},
--             perFrame = 0,
--         }
        
--     }
--     self.panel_1.scroll_1:cancleCacheView();
-- 	self.panel_1.scroll_1:styleFill(params)
-- 	panle.scroll_1:gotoTargetPos(#chatdata,1,2);

-- end

function GuildInFoView:updatechatItem(view,itemData)

	local str = GuildModel:paramGuildEvent(itemData)
	view:setString(str)
end




--设置仙盟图标
function GuildInFoView:setGuildIconAndInfo()
	local panel = self.panel_2
	panel.UI_1:initData()

	local guildName = GuildModel.guildName 
	
	---少一个仙盟类型后期加上去

	local guildchar = GuildModel._guildcharinfo
	local leadername = GuildModel._guildcharinfo.name or GameConfig.getLanguage("tid_common_2001") 
	local level = GuildModel:getGuildLevel()
	panel.txt_2:setString((level or 1)..GameConfig.getLanguage("#tid_guildAddCell_001")) 
	local guildType = guildName._type
	local postype = GuildModel:gettMyselfpos()
	local str = FuncGuild.byIdAndPosgetName(guildType,1)
	panel.txt_3:setString(GameConfig.getLanguage("#tid_guild_031")..str..":")  
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
	panel.txt_8:setString("  "..peoplenum.."/"..sumnum)



end

--显示公告
function GuildInFoView:showAnnouncement()
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

function GuildInFoView:modificationNotice()
	echo("修改公告按钮")
	-- local isboos = GuildModel:judgmentIsForZBoos()
	local declaration = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"declaration")
	if declaration == 1 then
		WindowControler:showWindow("GuildAnnouncement",2);
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001")) 
	end
end

function GuildInFoView:updateTextItem(view)
	local text = GuildModel._baseGuildInfo
	view:setString(text.notice)
end



--设置所有按钮
function GuildInFoView:setButton()
	self:setSixCallfun();
	local sixbutton = self.panel_4;
	-- local Windownames =  WindowControler:getWindow( "GuildMainView" )
	local Windownames = WindowControler:checkCurrentViewName( "GuildMainView" )
	if Windownames then
		self.mc_btn:showFrame(2)
	else
		self.mc_btn:showFrame(1)
	end

	self.mc_btn:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.goingGuild, self),nil,true);
	self.mc_btn:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.otherGuildList, self),nil,true);
	for i=1,9 do
		local btn = sixbutton["btn_"..i];
		if btn ~= nil then
			FilterTools.clearFilter(btn);
			btn:getUpPanel().panel_red:setVisible(false);
			btn:setTouchedFunc(c_func(self.callfun[i], self),nil,true);
			if i == 6 then
				local isboos = GuildModel:judgmentIsBoos()   --是否是盟主 
				if not isboos then
					FilterTools.setGrayFilter(btn);
					btn:setTouchedFunc(c_func(self.notpermissions, self),nil,true);
				end
			end
		end
	end
end
function GuildInFoView:otherGuildList()
	echo("============查看其它仙盟==========")
	GuildControler:getAddGuildDataList()
end
function GuildInFoView:notpermissions()
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_032")) 
end

--叶签按钮初始化
function GuildInFoView:leafSignInitButton()
	local panel = self.panel_1

	for i=1,4 do
		if i ~= 3 then
			panel["mc_yeqian"..i]:setTouchedFunc(c_func(self.leafSignCellFung, self,i),nil,true);
		end
	end

	self:leafSignCellFung(1)

end

function GuildInFoView:leafSignCellFung(_type)

	-- if _type == 3 then
	-- 	local isok = self:clickApply(callfun)
	-- 	if not isok then
	-- 		return 
	-- 	end
	-- end



	local isok = self:mc_Show(_type)

	if not isok then
		return
	end

	local uiTable = {
		[1] = self.UI_x,
		[2] = self.UI_2,
		[3] = self.UI_3,
		[4] = self.UI_4,
	}
	if _type == 3 then
		self.select_yeqian_state = 2
	else
		self.select_yeqian_state = _type
	end

	for i=1,#uiTable do
		if i == 3 and _type == 3 then
			local function callfun()
				-- if i == _type then
					uiTable[i]:setVisible(true)
					uiTable[i]:createGuildData()
				-- end
			end
			self:clickApply(callfun)
		elseif _type == 4 and i == 4 then
			uiTable[i]:setVisible(true)
			uiTable[i]:initCellView()
			-- 发一个到了活动页的消息
			EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.guildTabActivity})
		else
			if i == _type then
				uiTable[i]:setVisible(true)
			else
				uiTable[i]:setVisible(false)
			end
			if i == 2 then
				uiTable[i]:setButtonRed()
			end
		end
	end

	self:showButtonRed()
end




--叶签的显示
function GuildInFoView:mc_Show(_type)
	-- self.select_type   --选中的第几个叶签
	if self.select_type == _type then
		return false
	end
	local _types = _type
	local panel = self.panel_1
	for i=1,4 do
		if _type == 3 then
			_types = 2
		end
		if i ~= 3 then
			if i == _types then
				panel["mc_yeqian"..i]:showFrame(2)
			else
				panel["mc_yeqian"..i]:showFrame(1)
			end
		end
	end
	local str = FuncGuild.Leaf_Sign_Type_Str[_type]
	self.UI_1.txt_1:setString(str)


	
	if _type == FuncGuild.Leaf_Sign_Type.INFO then
		self:upIsShow(true)
	elseif _type == FuncGuild.Leaf_Sign_Type.MEMBERS then
		self:upIsShow(false)
	elseif _type == FuncGuild.Leaf_Sign_Type.APPLY then
		self:upIsShow(false)
	elseif _type == FuncGuild.Leaf_Sign_Type.ACTIVE then
		self:upIsShow(false)
	end


	self.select_type = _type 	
	echo("========_type=======_type====",_type,self.select_type)
	return true
end

function GuildInFoView:upIsShow(ishow)
	self.panel_4:setVisible(ishow)
	self.mc_btn:setVisible(ishow)
end




function GuildInFoView:setSixCallfun()
	self.callfun = {
		[1] = self.clickSign,
		[2] = self.clickRewards,
		[3] = self.clickBlessing,
		[4] = self.clickShop,
		[5] = self.clickMembers,
		[6] = self.clickApply,
		[7] = self.clickDonation,
		[8] = self.clickTask,
		[9] = self.clickSkill,
	}
end

--仙盟科技
function GuildInFoView:clickSkill()
	WindowControler:showWindow("GuildSkillMainView")
end

--仙盟任务
function GuildInFoView:clickTask()
	WindowControler:showWindow("GuildTaskMainView")

end
--捐献按钮
function GuildInFoView:clickDonation()
	echo("======进入仙盟捐献=====")
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildMainBuildView")
end

--进入仙盟
function GuildInFoView:goingGuild()
	echo("======进入仙盟主城=====")
	if not GuildControler:touchToMainview() then
		return 
	end
	GuildControler:getMemberList(2)

	self:press_btn_close()
end

--签到
function GuildInFoView:clickSign()
	echo("======签到=====")
	if not GuildControler:touchToMainview() then
		return 
	end
	local count = CountModel:getGuildSignCount()
	if count ~= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_047"))
		return 
	end
	
	
	WindowControler:showWindow("GuildSignView");
end

--红利
function GuildInFoView:clickRewards()
	echo("======红利=====") 
	if not GuildControler:touchToMainview() then
		return 
	end
	----获取地图数据  刷新地图的状态
    local function _callback( event )
        if event.result then
            local digTool = event.result.data.digTool or 0
            WindowControler:showWindow("GuildTreasureMainView",nil,digTool)
        end
    end
    GuildServer:getGuildDigList(_callback)
end

--祈福
function GuildInFoView:clickBlessing()
	echo("======祈福=====")
	if not GuildControler:touchToMainview() then
		return 
	end
	-- GuildControler:getWishList()
	WindowControler:showWindow("GuildWelfareMainView");
	-- WindowControler:showWindow("GuildBlessingView");
end

--商店
function GuildInFoView:clickShop()
	echo("======商店=====")
	-- WindowControler:showTips("旋光殿暂未开启")
	WindowControler:showWindow("ShopView",FuncShop.SHOP_TYPES.GUILD_SHOP)
end

--成员
function GuildInFoView:clickMembers()
	echo("======成员=====")
	if not GuildControler:touchToMainview() then
		return 
	end
	GuildControler:getMemberList()

end

--申请
function GuildInFoView:clickApply(callfun)
	echo("======申请=====")
	-- if not GuildControler:touchToMainview() then
	-- 	return
	-- end
	local apply = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"apply")
	-- local isok = GuildModel:judgmentIsBoos()
	if apply == 1 then
		GuildControler:getAppList(callfun)
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
	end
	-- return isok 

end



-- function GuildInFoView:initData()
-- 	--创建
-- 	self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
-- 	--加入
-- 	self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
-- end


function GuildInFoView:press_btn_close()
	GuildModel:sendHomeMainViewRed()
	self:startHide()
end

return GuildInFoView;
