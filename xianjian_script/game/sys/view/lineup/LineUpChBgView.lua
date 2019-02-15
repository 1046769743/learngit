--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-更换背景
]]
local LineUpChBgView = class("LineUpChBgView", UIBase)

--[[
	self.txt_1
	self.panel_1
	self.scroll_list3
]]

function LineUpChBgView:ctor( winName, params )
	LineUpChBgView.super.ctor(self, winName)
	self._callBack = params.callBack
end

function LineUpChBgView:registerEvent()
	LineUpChBgView.super.registerEvent(self)
    self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function LineUpChBgView:loadUIComplete()
	self:registerEvent()
	-- 标题
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_teaminfo_1004"))
	-- 隐藏需要复制的item
	self.mc_1:visible(false)
	self:updateUI()
end

function LineUpChBgView:updateUI()
	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(self.mc_1)

		self:updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		self:updateItem(view, itemData, idx)
	end

	local scrollParams = {
		{
			data = FuncLineUp.getBgList(),
			createFunc = createFunc,
			updateCellFunc = updateCellFunc,
			perFrame = 1,
			perNums = 3,
			widthGap = 50,
			offsetX = 65,
			offsetY = 0,
			itemRect = {x = 0,y = -428,width = 258,height = 428},
		}
	}

	local scrollList = self.scroll_1
	scrollList:styleFill(scrollParams)
end

function LineUpChBgView:updateItem(view, itemData, idx )
	local check = FuncLineUp.checkHasBg(itemData.id)
	-- 拥有此界背景
	if check then
		-- 是否是当前正在使用的背景
		if tonumber(itemData.id) == tonumber(LineUpModel:getBackground()) then
			view:showFrame(3)
		else
			view:showFrame(1)
			-- 更换背景
			view.currentView.btn_1:setTap(function()
				LineUpModel:bgChange(itemData.id)
				self:startHide()
			end)
		end
		-- 背景图
		local _ctn = view.currentView.ctn_1
		_ctn:removeAllChildren()
		local _sp = display.newSprite(FuncLineUp.getIconById( itemData.id ))
		_sp:addTo(_ctn)
		
	else -- 没有此背景
		view:showFrame(2)
		-- 置灰背景图
		-- 背景图
		local _ctn = view.currentView.ctn_1
		_ctn:removeAllChildren()
		local _sp = display.newSprite(FuncLineUp.getIconById( itemData.id ))
		_sp:addTo(_ctn)
		FilterTools.setGrayFilter(_sp)
		-- 预览界面
		view.currentView.btn_1:setTap(function()
			-- WindowControler:showWindow("LineUpMainView")
			LineUpViewControler:showMainWindowInPrewiew()
			self._callBack(true, itemData.id)
		end)

		-- 开启条件
		view.currentView.txt_2:setString(FuncLineUp.getContentById(itemData.id))
	end

	-- 名称
	view.currentView.txt_1:setString(FuncLineUp.getBgNameById( itemData.id ))
end

function LineUpChBgView:press_btn_close()
	self:startHide()
end

return LineUpChBgView