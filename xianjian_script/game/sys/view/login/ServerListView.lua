local ServerListView = class("ServerListView", UIBase)
local SERVER_NUM_OF_SECTION = 10
local MAX_HISTORY_SERVERS=LoginControler.MAX_HISTORY_SERVERS

local SERVER_LIST_TITLE = {
	HISTORY = "history",
	SELECT = "select",
	RECOMMAND = "recommand",
}

local sortBySortId = function(a, b)
	return tonumber(a.sortId) < tonumber(b.sortId)
end

function ServerListView:ctor(winName)
	ServerListView.super.ctor(self, winName)
end

function ServerListView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:initServerSections()
end

function ServerListView:initView()
	-- 选择服务器
	local msgTip = GameConfig.getLanguage("tid_login_1039")
	self.UI_1.txt_1:setString(msgTip)
	self.mc_server_section:visible(false)
	self.mc_server_id:visible(false)
end

function ServerListView:initData()
	--local data = self:getFakeServerInfos()
	self.paramsList = {
		{
			data = {},
			createFunc = nil,
			itemRect = {x=0,y=-111,width = 298,height = 69},
			perNums= 2,
			offsetX = 7,
			offsetY = 45,
			widthGap = 72,
			heightGap = 15,
			perFrame = 2
		}
	}

	local data = self:getServerInfos()
	self.history_servers = data.roleHistorys
	self.all_servers = data.secList

	--sort by sort id
	table.sort(self.all_servers, sortBySortId)

	self.serverid_map = {}
	local all_sections = {}

	local historyList = LoginControler:getHistoryLoginServers(true)
	local latestList = self:getLastestServers()

	local recommandInfo = {
		history = historyList,
		section_index = SERVER_LIST_TITLE.HISTORY
	}

	table.insert(all_sections, recommandInfo)
	recommandInfo = {
		latest = latestList,
		section_index = SERVER_LIST_TITLE.RECOMMAND
	}

	table.insert(all_sections, recommandInfo)

	local serverListLen = #self.all_servers
	for i=1, serverListLen, SERVER_NUM_OF_SECTION do
		local secs = {}
		for j=i,i+SERVER_NUM_OF_SECTION-1 do
			if j<= serverListLen then
				local oneServerInfo = self.all_servers[j] 
				table.insert(secs, oneServerInfo)
				self.serverid_map[oneServerInfo._id] = j
			end
		end

		local info = {
			secs = secs,
			section_index = i,
		}
		table.insert(all_sections, 3, info)
	end
	self.all_sections = all_sections
end

function ServerListView:getLastestServers()
	local ret = {}
	for _,info in pairs(self.all_servers) do
		if info.new_open then
			table.insert(ret, info)
		end
	end
	return ret
end

--侧边栏服务器大区
function ServerListView:initServerSections()
	self.sectionViews = {}
	local createFunc = function(info, i)
		local view = UIBaseDef:cloneOneView(self.mc_server_section)
		view:setTouchedFunc(c_func(self.onPressServerSection, self, info, view))
		self:initOneSectionView(view, info, i)
		table.insert(self.sectionViews, view)
		return view
	end

	local params = {
		{
			data = self.all_sections,
	        createFunc = createFunc,
	        itemRect = {x=0,y=-68,width = 255,height = 76},
	        perNums= 1,
	        offsetX = 2,
	        offsetY = -8,
	        widthGap = 0,
	        heightGap = -11,
	        perFrame = 1
		}
	}
	self.scroll_server_section:styleFill(params)
	self.scroll_server_section:easeMoveto(0,0,0)
	--默认选择第一个
	self:selectServerSection(self.all_sections[1], self.sectionViews[1])
end

--初始化一个左侧栏服务器大区按钮
function ServerListView:initOneSectionView(view, info, index)
	local str = GameConfig.getLanguage("tid_login_1004")
	if index == 1 then
		-- 我的服务器
		str = GameConfig.getLanguage("tid_login_1040")
	elseif index == 2 then

	else
		local marklast = info.secs[#info.secs].mark
		local markfirst = info.secs[1].mark

		-- "%s-%s服"
		local msgTip = GameConfig.getLanguage("tid_login_1041")
		-- TODO
		msgTip = "%s-%s"
		str = string.format(msgTip, markfirst, marklast)
	end
	view:getViewByFrame(1).btn_1:setBtnStr(str)
	view:getViewByFrame(2).btn_1:setBtnStr(str)
end

--显示右边服务器列表
function ServerListView:showServerList(info)
	-- if info.section_index ~= "my" and info.section_index ~= "latest" then
	if info.section_index == SERVER_LIST_TITLE.RECOMMAND then
		self:showRecommandedServers(info,info.latest)
	elseif info.section_index == SERVER_LIST_TITLE.HISTORY then
		self:showMyServers(info,info.history)
	else
		self:showNormalServers(info)
	end
end

function ServerListView:showMyServers(info,serverList)
	local createHistoryFunc = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.mc_server_id)
		self:initOneServerPanel(view, itemInfo, true)
		return view
	end

	self.paramsList[1].data = serverList
	self.paramsList[1].createFunc = createHistoryFunc
	self.scroll_server_list:styleFill(self.paramsList)

	self.scroll_server_list:cancleCacheView()
	self.scroll_server_list:easeMoveto(0,0,0)
end

function ServerListView:showRecommandedServers(info,serverList)
	local createHistoryFunc = function(itemInfo)
		local view = UIBaseDef:cloneOneView(self.mc_server_id)
		self:initOneServerPanel(view, itemInfo, false)
		return view
	end

	self.paramsList[1].data = serverList
	self.paramsList[1].createFunc = createHistoryFunc
	self.scroll_server_list:styleFill(self.paramsList)
end

function ServerListView:showNormalServers(info)
	local secs = info.secs
	local createFunc = function(info)
		local view = UIBaseDef:cloneOneView(self.mc_server_id)

		if self:isHistoryServerId(info._id) then
			info.sec = info._id
			self:initOneServerPanel(view, info,true)
		else
			self:initOneServerPanel(view, info)
		end
		
		return view
	end
	table.sort(secs, function(a, b) return tonumber(a.sortId)>tonumber(b.sortId) end)

	self.paramsList[1].data = secs
	self.paramsList[1].createFunc = createFunc
	self.scroll_server_list:styleFill(self.paramsList)

	self.scroll_server_list:easeMoveto(0,0,0)
	self.scroll_server_list:cancleCacheView()
end

function ServerListView:initOneServerPanel(view, info, isHistory)
	local server_id = nil
	local historyInfo = nil
	if isHistory then
		server_id = info.sec
		historyInfo = self.history_servers[server_id]
		local index = self.serverid_map[server_id]

		if self.all_servers[index] then
			info = self.all_servers[index]
		else
			-- 我的服务器列表中有已不存在的服务器
			echoError("server_id=",server_id," is not found")
		end
	end
	
	local index = info.sortId or ""
	-- "%s服"
	local indexStr = string.format(GameConfig.getLanguage("tid_login_1042"), info.mark)
	local serverName = info.name or ""
	--头像为空则不显示
	if isHistory and LoginControler:checkShowRoleInfo() and historyInfo.avatar~=nil and historyInfo.avatar ~= "" and tonumber(historyInfo.avatar) ~= 0 then
		view:showFrame(2)
		local level = historyInfo.level or 1
		-- local levelStr = GameConfig.getLanguageWithSwap("tid_common_2015",level)
		-- 去掉“等级”文字信息，仅显示数字
		local levelStr = level
		view.currentView.btn_1:getUpPanel().panel_avatar.txt_1:setString(levelStr)

		local avatarId = historyInfo.avatar..''
		-- echo("avatarId======",avatarId)
		if string.len(avatarId) == 3 then
			--icon
			local icon = FuncRes.iconAvatarHead(avatarId)
			local iconSprite = display.newSprite(icon)
			local avatarCtn = view.currentView.btn_1:getUpPanel().panel_avatar.ctn_1
			local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", avatarCtn, false, GameVars.emptyFunc)
			FuncArmature.changeBoneDisplay(iconAnim, "node", iconSprite);
			iconSprite:setScale(0.7)
		end
	else
		view:showFrame(1)
	end

	view.currentView.btn_1:setBtnStr(indexStr, 'txt_1')
	view.currentView.btn_1:setBtnStr(" " .. serverName, 'txt_2')
	view.currentView.btn_1:setTap(c_func(self.onServerSelected, self, info))
	--显示服务器状态
	local mc_status = view.currentView.btn_1:getUpPanel().mc_status
	local status_frame = LoginControler:getServerStatusKey(info)
	mc_status:showFrame(status_frame)
end

function ServerListView:isHistoryServerId(serverId)
	return self.history_servers[serverId] ~= nil
end

function ServerListView:onServerSelected(info)
	LoginControler:setServerInfo(info)	
	self:startHide()
end

function ServerListView:onPressServerSection(info, view)
	if self.scroll_server_section:isMoving() then
		return
	end
	local last_select_section = self._last_select_section
	if last_select_section == info.section_index then
		return
	else
		self._last_select_section = info.section_index
	end

	self:selectServerSection(info, view)
end

function ServerListView:selectServerSection(info, view)
	if self.currentSectionView == nil then
		self.currentSectionView = view
	else
		self.currentSectionView:showFrame(1)
		self.currentSectionView = view
	end
	view:showFrame(2)
	self:showServerList(info)
end

function ServerListView:getServerInfos()
	local data = {
		secList = LoginControler:getServerList(),
		roleHistorys = LoginControler:getHistoryLoginServers(),
	}
	return data
end

--function ServerListView:getFakeServerInfos()
--    local num = 95
--    local secList = {}
--    for i=1,num do
--        local oneInfo = {
--            _id = "id"..i, 
--            name = "test"..i, 
--            mark="s"..i,
--            sortId = i,
--            status = math.random(0,1),
--            link = "www.baidu.com",
--            openTime = os.time(),
--        }
--        table.insert(secList, oneInfo)
--    end
--    local data = {
--        secList = secList, 
--        roleHistorys = {
--            id1 = {
--                sec = "id1",
--                name = "最近1",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            },
--            id2 = {
--                sec = "id2",
--                name = "最近2",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            },
--            id3 = {
--                sec = "id3",
--                name = "最近3",
--                level = 1,
--                avatar = 1,
--                logoutTime = os.time()
--            }
--        }
--    }
--    return data
--end

function ServerListView:registerEvent()
	self:registClickClose("out")
	self.UI_1.btn_1:setTap(c_func(self.startHide, self))
end

return ServerListView

