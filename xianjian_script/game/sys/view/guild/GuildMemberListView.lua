-- GuildMemberListView
-- Author: Wk
-- Date: 2017-10-10
-- 公会成员列表界面
local GuildMemberListView = class("GuildMemberListView", UIBase);

function GuildMemberListView:ctor(winName)
    GuildMemberListView.super.ctor(self, winName);
end

function GuildMemberListView:loadUIComplete()


	-- self.txt_1:setString(GameConfig.getLanguage("#tid_guildMemberList_001")) 
	-- self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);


    self:registerEvent()
	self:initData()

    self:setButton()
    self:selectaddGuild()
    
end 


function GuildMemberListView:registerEvent()
    
    EventControler:addEventListener(GuildEvent.REFRESH_MEMBERS_LIST_EVENT, self.initData, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_EVENT, self.press_btn_close, self)
    EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)

    EventControler:addEventListener(GuildEvent.REFRESH_SIGN_EVENT,self.setButtonRed, self)

    self.btn_2:setTouchedFunc(c_func(self.exitButton, self),nil,true);

    local isok = false--GuildModel:judgmentIsForZBoos()
    local isshowApp = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"addRight")
     local apply = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"apply")
    -- echoError("=====isshowApp========",GuildModel:getMyRight(),isshowApp)
    if isshowApp == 1 then
        isok = true
    end
    if isok then
        self.btn_1:setVisible(true)
        self.panel_4:setVisible(true)
       
    else
        self.btn_1:setVisible(false)
        self.panel_4:setVisible(false)
        
    end

    if apply == 1 then
        self.btn_1:setVisible(true)
    else
        self.btn_1:setVisible(false)
    end

    self.btn_1:setTouchedFunc(c_func(self.showAppListView, self),nil,true);
    
    self:setButtonRed()
end



function GuildMemberListView:setButton()
    self.panel_4.btn_1:setTouchedFunc(c_func(self.quickToJoin, self),nil,true);
    -- self.panel_4.btn_2:setTouchedFunc(c_func(self.declaration, self),nil,true);
end

--快速加入
function GuildMemberListView:quickToJoin()
    -- echo("快速邀请 =======还未开发")
    -- if 1 then
    --  WindowControler:showTips("等待合并，即可使用")
    --  return 
    -- end
    if not GuildControler:touchToMainview() then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_007")) 
        return 
    end
    local function cellfunc()
        if not self.sendquickJoin then
            GuildModel:sendWorldInvite()
            self.sendquickJoin = true
        end
    end

    self:declaration(cellfunc)
end


--宣言
function GuildMemberListView:declaration(cellfunc)
    if not GuildControler:touchToMainview() then
        return 
    end
    -- echo("宣言 =======还未开发")
    local addRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"addRight")
    if addRight ~= 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001")) 
        return 
    end
    WindowControler:showWindow("GuildAnnouncement",1,cellfunc);
end


function GuildMemberListView:selectaddGuild()
    self._select = GuildModel.selectAddGuildType
    local panel = self.panel_4
    panel.panel_select:setTouchedFunc(c_func(self.selectbutton, self),nil,true);
    if  self._select == 0 then
        panel.panel_select.panel_dui:setVisible(false)
    else
        panel.panel_select.panel_dui:setVisible(true)
    end
end
function GuildMemberListView:selectbutton()
    if not GuildControler:touchToMainview() then
        return 
    end
    -- if not GuildModel:judgmentIsForZBoos() then
    local addRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"addRight")
    if addRight ~= 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
        return 
    end


     local addRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"addRight")
    -- echoError("=====isshowApp========",GuildModel:getMyRight(),isshowApp)
    if addRight ~= 1 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
        return 
    end


    local panel = self.panel_4
    if self._select == 0 then 
        self._select = 1
        panel.panel_select.panel_dui:setVisible(true)
    else
        self._select = 0
        panel.panel_select.panel_dui:setVisible(false)
    end
    GuildModel.selectAddGuildType = self._select 
    self:sendServer()
end
function GuildMemberListView:sendServer()
    local function _callback(_param)
        
        if _param.result then
            dump(_param.result,"配置修改数据返回",8)
            GuildModel:setneedApply(self._select)
        end
    end 

    local params = {
        needApply = self._select
    };

    GuildServer:modifyConfig(params,_callback)
end





--设置按钮的红点
function GuildMemberListView:setButtonRed()
    local isshow = GuildModel:applysDataRed()

    self.btn_1:getUpPanel().panel_red:setVisible(isshow)
end

function GuildMemberListView:showAppListView()
    EventControler:dispatchEvent(GuildEvent.SHOW_APPLIST_VIEW)
end

function GuildMemberListView:initData()
	self:setButtonRed()
    self.memberdata = GuildModel:membersPaiXuData()
	local number = FuncGuild.getGuildMemNUm()
    -- dump(self.memberdata,"2222222222222",9)
	self.panel_2:setVisible(false)
	self.panel_3:setVisible(false)

	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_2);
            self:updateItem(view,itemData)
        return view
    end
    local textCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_3);
        self:updateItemtime(view)
        return view        
    end

 	local params =  {
        {
            data = self.memberdata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = -2,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -80, width = 626, height = 80},
            perFrame = 1,
        }
        
    }
    local creatreGuildTime = GuildModel:getcreateguildtime()
    -- echoError("=======creatreGuildTime=======",creatreGuildTime)
    if creatreGuildTime > 0 and #self.memberdata < number then
    	local text = {
    		data = {1},  ---alldata
            createFunc = textCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = -3,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -65, width = 626, height = 70},
            perFrame = 0,
    	}
    	table.insert(params,text)
    end

    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(params)

end


function GuildMemberListView:updateItemtime(view)
    --创建时间
    self.sumtime = GuildModel:getcreateguildtime()
    local str  = nil
    -- echo("==========time==111111111111====",self.sumtime)
    local  strtime = math.floor(self.sumtime/(3600*24))
    self.shengyutime = 0
   
    if strtime ~= 0 then  
        local  min = math.fmod(self.sumtime-(strtime*3600*24), 3600)
        if min > 0 then
            strtime = strtime + 1
        end
        str = "注："..strtime.."天后不满7人，仙盟自动解散"
        view.txt_1:setString(str)
    else
        local shengyutime = math.fmod(self.sumtime, (3600*24))
        if  shengyutime~= 0 then
            self.shengyutime = shengyutime
            local strtime =  self:timeToLanTime(shengyutime)
            local str =  "注："..strtime.."后不满7人，仙盟自动解散"
            view.txt_1:setString(str)
            self.strview = view
            self.indextime = 1
            self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)  --300533
        end
    end
    
end

function GuildMemberListView:updateFrame()
    self.indextime = self.indextime + 1
    if math.fmod(self.indextime, 30) == 0 then
        local time = self.shengyutime
        if time > 0 then
            local timestring = self:timeToLanTime(time)
            
            local str =  "注："..timestring.."后不满7人，仙盟自动解散"
            if self.strview.txt_1 then
                self.strview.txt_1:setString(str)
            end
            self.shengyutime = self.shengyutime - 1
        else
            UserModel._data.guildId = ""
            self.shengyutime = 0
            self:unscheduleUpdate()
            self:press_btn_close()
            WindowControler:showTips(FuncGuild.disbandStr)
            EventControler:dispatchEvent(GuildEvent.CLOSE_INFO_VIEW_EVENT)
        end

    end

end

function GuildMemberListView:timeToLanTime(time)
    local h = math.floor(time/3600)
    local s = math.floor((time-h*3600)/60)
    local m = math.fmod(time,60)
    local timestring = ""
    if  string.len(m) ~= 2 then
        m = "0"..m
    end
    if  string.len(s) ~= 2 then
        s = "0"..s
    end
    if h ~= 0 then
        if  string.len(h) ~= 2 then
            h = "0"..h
        end
        if s ~= 0 then
            timestring = h.."时"..s.."分"..m.."秒"
        end
    else
        if s ~= 0 then
            timestring = s.."分"..m.."秒"
        else
            timestring = m.."秒"
        end
    end
    return timestring
end
function GuildMemberListView:updateItem(view,itemData)

    -- dump(itemData,"成员玩家数据",8)
    local guildID = GuildModel.guildName._type
    local postype = itemData.right or 4

	local zhiwei = FuncGuild.byIdAndPosgetName(guildID,postype)
    local woodTotal = itemData.woodTotal or 0
    local contribute = woodTotal   ----贡献
	view.txt_1:setString(itemData.name)
	view.txt_2:setString(itemData.level)
	view.txt_3:setString(zhiwei)
	view.txt_4:setString(contribute)
	if itemData._id ==  UserModel:rid() then
		-- view.mc_1:showFrame(1)
		-- view.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.exitButton, self),nil,true);
        view.mc_bg:showFrame(2)
        itemData.head = UserModel:head()
        itemData.avatar = UserModel:avatar()
	else
		-- view.mc_1:showFrame(2)
		-- view.mc_1:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.particulars, self,itemData),nil,true);
        view.mc_bg:showFrame(1)
	end
	-- local _node = view.panel_1.ctn_1
	-- view.panel_1.txt_1:setString(itemData.level)
    view:setTouchedFunc(c_func(self.particulars, self,itemData),nil,true);
	-- ChatModel:setPlayerIcon(_node,itemData.head,itemData.avatar ,0.6)
    view.UI_1:setPlayerInfo(itemData)
end

--退出界面
function GuildMemberListView:exitButton()
    if not GuildControler:touchToMainview() then
        return 
    end
	WindowControler:showWindow("GuildExitGuildView");

end

--详情
function GuildMemberListView:particulars(itemData)
    if not GuildControler:touchToMainview() then
        return 
    end
    if itemData._id ==  UserModel:rid() then
        -- WindowControler:showTips("自身不能点击")
        return
    end
	--//查询任意一个角色信息
    dump(itemData,"玩家详情数据",9)
    WindowControler:showWindow("GuildPlayerInfoView",itemData);

end

function GuildMemberListView:press_btn_close()
	
	self:startHide()
end


return GuildMemberListView;
