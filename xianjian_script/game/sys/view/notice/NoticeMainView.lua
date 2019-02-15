--[[
	Author: 张燕广
	Date:2018-08-06
	Description: 游戏公告主界面
]]

local NoticeMainView = class("NoticeMainView", UIBase);

function NoticeMainView:ctor(winName,noticeData)
    NoticeMainView.super.ctor(self, winName)

    self.notcieData = noticeData
end

function NoticeMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function NoticeMainView:registerEvent()
	NoticeMainView.super.registerEvent(self);
	-- self.UI_1.btn_1:setTap(c_func(self.onClickClose,self))
	self.UI_1.btn_1:setVisible(false)
	self.btn_1:setTap(c_func(self.onClickClose,self))
end

function NoticeMainView:initData()
	self.IS_RICH_TEXT = true
	self.IS_DEBUG = false

	if self.IS_DEBUG then
		local cfg = {
			NoticeModel = "game.sys.model.NoticeModel",
			PCHtmlHelper = "utils.PCHtmlHelper"
		}

		for k,v in pairs(cfg) do
			package.loaded[v] = nil
			_G[k] = nil
			_G[k] = require(v)
		end
	end

	self.noticeList = self.notcieData.NoticeContent
	NoticeModel:sortNoticeTitleList(self.noticeList)

	self.curSelectIndex = 1
end

function NoticeMainView:initViewAlign()
	
end

function NoticeMainView:initView()
	-- 公告
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_login_1067"))

	-- 标题栏滚动条
	self.noticeTitleScroll = self.scroll_1
	self:initScrollCfg()
end

function NoticeMainView:initScrollCfg()
	self.mc_1:setVisible(false)

	local createItemFunc = function(notice)
		local itemView = UIBaseDef:cloneOneView(self.mc_1)

		self:setItemView(itemView,notice)

		return itemView
	end

	-- itemView参数配置
    self.titleViewParams = {
        {
        	data = self.noticeList,
	        itemRect = {x=0,y=-109,width = 166,height = 57},
	        createFunc = createItemFunc,
	        perNums = 1,
	        offsetX = 3,
	        offsetY = 79,
	        widthGap = 4,
	        heightGap = 5,
	        perFrame = 1,
    	}
    }

    local createContentItemFunc = function(notice)
		local itemView = UIBaseDef:cloneOneView(self.rich_comm)
		self:setNoticeContent(itemView,notice)
		return itemView
	end

	self.rich_comm:setVisible(false)
	self.contentRect = {x=0,y=0,width = 630,height = 0}
    -- 公告内容参数配置
    self.contentParams = {
    	{
	    	data = {},
	        itemRect = nil,
	        createFunc = createContentItemFunc,
	        perNums = 1,
	        offsetX = 20,
	        offsetY = 10,
	        widthGap = 4,
	        heightGap = -10,
	        perFrame = 1,
	    }
	}
end

function NoticeMainView:setItemView(itemView,notice)
	local index = self:getDataIndex(notice)
	if index == self.curSelectIndex then
		itemView:showFrame(2)
	else
		itemView:showFrame(1)
	end

	local btn = itemView.currentView.btn_1

	local titleName = notice.type
	local btn = itemView.currentView.btn_1
	btn:setBtnStr(titleName)

	btn:setTap(c_func(self.onClickNoticeTitle,self,index))
end

--[[
	设置公告内容
]]
function NoticeMainView:setNoticeContent(txtView,notice)
	local richContent = txtView

	local htmlObjList = notice.htmlObjList

	local textCfgList = NoticeModel:convertToRichTextCfgList(htmlObjList)
	richContent:setTextCfgList(textCfgList)
end

function NoticeMainView:onClickNoticeTitle(index)
	if index == self.curSelectIndex then
		return
	end

	self.curSelectIndex = index
	self:updateNotice()
end

--[[
	更新公告内容
]]
function NoticeMainView:updateNotice()
	self.mc_x1:showFrame(1)
	local contentScroll = self.mc_x1.currentView.scroll_1

	local index = self.curSelectIndex
	local notice = self.noticeList[index]

	-- self:setNoticeContent(notice)
	self:updateTitleList()

	if notice.htmlObjList == nil then
		local resultArr = PCHtmlHelper:parseHtmlStr(notice.content)
		resultArr = PCHtmlHelper:convertToHtmlObj(resultArr)
		notice.htmlObjList = resultArr
	end

	-- 提前预估计算出富文本高度，设置给滚动条
	if notice.richHeight == nil then
		notice.richHeight = self:caclNoticeRichHeight(self.rich_comm,notice.htmlObjList)
		-- echo("\n\n--------notice.richHeight==",notice.richHeight)
	end

	local itemRect = table.copy(self.contentRect)
	itemRect.height = notice.richHeight

	self.contentParams[1].data = {notice}
	self.contentParams[1].itemRect = itemRect

	-- contentScroll:initDragBarVisible(true)
	-- contentScroll:keepDragBar()
	contentScroll:styleFill(self.contentParams)
	contentScroll:gotoTargetPos(1,1,0)
end

function NoticeMainView:caclNoticeRichHeight(richTemplate,htmlObjList)
	local width = richTemplate._wid
	local height = richTemplate._hei
	local fontName = GameVars.systemFontName --"gameFont1"
	local fontSize = richTemplate.defaultFontSize

	local totalHeight = 0
	local content = ""
	local offsetY = 0

	-- dump(htmlObjList,"htmlObjList------------")
	for k,v in pairs(htmlObjList) do
		local curHeight = 0
		if v.content == "\n" then
			if content ~= "" then
				curHeight = FuncCommUI.getStringHeightByFixedWidth(content, fontSize, fontName, width)
				content = ""
			end
		elseif v.isBr then
			curHeight = height
		else
			content = content .. v.content
			-- echo("curHeight==",curHeight,k)
		end

		totalHeight = totalHeight + curHeight
	end

	totalHeight = totalHeight + offsetY
	return totalHeight
end

--[[
	更新标题页签状态
]]
function NoticeMainView:updateTitleList()
	for k,v in pairs(self.noticeList) do
		local itemView = self.noticeTitleScroll:getViewByData(v)
		self:setItemView(itemView, v)
	end
end

function NoticeMainView:getDataIndex(notice)
	for k,v in pairs(self.noticeList) do
		if notice == v then
			return k
		end
	end

	return nil
end

function NoticeMainView:updateUI()
	local onCreateComp = function()
		self:updateNotice()
	end

	self.noticeTitleScroll:setOnCreateCompFunc(c_func(onCreateComp))
	self.noticeTitleScroll:styleFill(self.titleViewParams)
end

function NoticeMainView:onClickClose()
	echo("点击了公告关闭")
	self:startHide()
end

return NoticeMainView;
