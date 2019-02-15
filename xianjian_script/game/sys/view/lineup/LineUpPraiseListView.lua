--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-赞我的人
]]
local LineUpPraiseListView = class("LineUpPraiseListView", UIBase)

--[[
	self.txt_1
	self.panel_1
	self.scroll_list3
]]

function LineUpPraiseListView:ctor( winName )
	LineUpPraiseListView.super.ctor(self, winName)
end

function LineUpPraiseListView:registerEvent()
	LineUpPraiseListView.super.registerEvent(self)
	EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function LineUpPraiseListView:loadUIComplete()
	self:registerEvent()

	-- 标题
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_teaminfo_1006"))
	-- 隐藏需要复制的item
	self.panel_1:visible(false)
	self:updateUI()
end

function LineUpPraiseListView:updateUI()
	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(self.panel_1)

		self:updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		self:updateItem(view, itemData, idx)
	end

	local praiseList = LineUpModel:getPraiseList()
	-- 是否有赞
	self.panel_sannv:visible(#praiseList == 0)
	local scrollParams = {
		{
			data = praiseList,
			createFunc = createFunc,
			updateCellFunc = updateCellFunc,
			perFrame = 1,
			offsetX = 0,
			offsetY = 0,
			itemRect = {x = -20,y = -116,width = 815,height = 116},
		}
	}
	-- echo("拉取信息")
	local scrollList = self.scroll_list3
	-- scrollList:setFillEaseTime(0.3)
	-- scrollList:setItemAppearType(1, true)
	scrollList:styleFill(scrollParams)
end

-- function LineUpPraiseListView:updateScroll( ... )
-- 	-- body
-- end

function LineUpPraiseListView:updateItem(view, itemData, idx )
	local panel = view
	-- 头像
	local _icon = FuncChar.icon(itemData.avatar)
	local _node = panel.panel_1.ctn_1
	_node:removeAllChildren()
	local _sprite = display.newSprite(_icon)
	local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)

	FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
	-- 玩家等级
	panel.panel_1.txt_1:setString(itemData.level)
	-- 玩家名字
	local _name = itemData.name
	if _name == "" then _name = GameConfig.getLanguage("tid_common_2001") end
	panel.txt_1:setString(_name)
	-- 区服
	panel.txt_2:setString(itemData.sec .. GameConfig.getLanguage("tid_common_2050")) 
	-- 赞的次数
	panel.txt_3:setString(itemData.times)

	-- 动态加载列表（暂时拉倒底部刷新）
	local pullPage = LineUpModel:getNeedPullPage(idx)
	if pullPage then -- 需要拉取
		LineUpServer:getPraiseList(pullPage, nil, false)
	end

	if UserModel:_id() == itemData.rid then -- 是自己
		_node:setTouchedFunc(function()
			self:startHide()
		end)
	else
		-- 查看阵容入口
    	local isOpen, lvl = LineUpModel:isLineUpOpen( itemData.level )
		_node:setTouchedFunc(function()
			if isOpen then
				LineUpViewControler:showMainWindow({
					trid = itemData.rid, 
					tsec = itemData.sec, 
					formationId = FuncTeamFormation.formation.pve
				})
			else
				local xtname = GameConfig.getLanguage(FuncCommon.getSysOpenxtname(FuncCommon.SYSTEM_NAME.LINEUP))
				WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_teaminfo_1001", lvl, xtname))
			end
		end)
	end
end

function LineUpPraiseListView:press_btn_close()
	self:startHide()
end

return LineUpPraiseListView