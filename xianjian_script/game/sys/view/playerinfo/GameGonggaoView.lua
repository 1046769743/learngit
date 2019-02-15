--
--Author:      zhuguangyuan
--DateTime:    2017-07-14 10:46:02
--Description: 获取服务器公告信息
--
local GameGonggaoView = class("GameGonggaoView", UIBase)

function GameGonggaoView:ctor(winName, data,type)
	GameGonggaoView.super.ctor(self, winName)
	self.gonggaoData = data
	-- 是否是维护公告
	-- self.isMaintain = isMaintain
	-- 1 普通公告(登录弹出的公告)
	-- 2 主城公告
	-- 3 维护公告
	self.gonggaoType = type
end

function GameGonggaoView:loadUIComplete()
	self.txt_item:visible(false)
	self:registerEvent()
	self:setGonggaoContent()

    -- 标题名
    if self.gonggaoType == LoginControler.GONGGAO_TYPE.MAINTAIN then
    	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_game_gonggao_002"))
    else
    	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_game_gonggao_001")) 
    end

    EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = true})
end

function GameGonggaoView:setGonggaoContent()
	local params = self.txt_item.params

	local width = params.dimensions.width
	local fontName = GameVars.systemFontName --"gameFont1"
	local fontSize = params.size

	local params = {}
	local gonggao = self:getGonggaoContents()
	for index, oneGonggao in ipairs(gonggao) do
		local strContent = oneGonggao[1].content
		local height = FuncCommUI.getStringHeightByFixedWidth(strContent, fontSize, fontName, width)
		local createFunc = function(gonggaoInfo)
			local view = UIBaseDef:cloneOneView(self.txt_item)
			view.baseLabel:setDimensions(width, height)

			local content = string.gsub(gonggaoInfo.content, "\r", "")
			view:setString(content)
			return view
		end

		local oneParam = {
			data = oneGonggao,
			createFunc = createFunc,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 15,
			offsetY = 1,
			widthGap = 0,
			heightGap = 10,
			itemRect = {x=0,y= -height, width = width,height = height},
		}
		table.insert(params, oneParam)
	end

	self.scroll_content:initDragBarVisible(true)
	self.scroll_content:keepDragBar()
	self.scroll_content:styleFill(params)
end

function GameGonggaoView:setGonggaoContent_new()
	local width = 980
	local fontName = GameVars.systemFontName --"gameFont1"
	local fontSize = 24
	local offset = 0

	local gonggaoList = {}

	local params = {}
	local gonggao = self:getGonggaoContents()
	for index, oneGonggao in ipairs(gonggao) do
		local strContent = oneGonggao[1].content
		
		strContent = string.gsub(strContent, "\r", "")
		local contentArr = string.split(strContent, "\n")
		for i=1,#contentArr do
			local curContent = contentArr[i]
			local curContentArr = FuncCommUI.splitStringByWidth(curContent, fontSize,fontName,width,offset)
			for j=1,#curContentArr do
				gonggaoList[#gonggaoList+1] = curContentArr[j]
			end
		end
	end

	local createFunc = function(itemData)
		local view = UIBaseDef:cloneOneView(self.txt_item)
		view:setString("")
		-- view.baseLabel:setDimensions(width, height)
		view:setString(itemData)
		return view
	end

	local params = 
	{
		{
			data = gonggaoList,
			createFunc = createFunc,
			perNums =1,
			--perFrame=1, --不要分帧
			offsetX = 13,
			offsetY = 50,
			widthGap = 0,
			heightGap = -2,
			itemRect = {x=0,y= -96, width = width,height = 40},
		}
	}

	self.scroll_content:styleFill(params)
end

function GameGonggaoView:getGonggaoContents()
	local defaultStr = GameConfig.getLanguage("tid_setting_1002")
	local str = self.gonggaoData.NoticeContent or defaultStr
	local gonggao = { {{content = str}}, }
	return gonggao
end

function GameGonggaoView:registerEvent()
	self:registClickClose("out")

	self.UI_1.btn_1:setVisible(false)
	self.UI_1.btn_1:setTap(c_func(self.onCloseTap, self))
	self.btn_confirm:setTap(c_func(self.onConfirmTap, self))
end

function GameGonggaoView:onCloseTap()
	self:close()
end

function GameGonggaoView:onConfirmTap()
	self:close()
end

function GameGonggaoView:close()
	self:startHide()
end

function GameGonggaoView:startHide()
	GameGonggaoView.super.startHide(self)
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = false})

	-- 如果是维护公告
	if self.gonggaoType  == LoginControler.GONGGAO_TYPE.HOME then
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_CLOSE_HOME_GONGGAO)
	end
end

return GameGonggaoView

