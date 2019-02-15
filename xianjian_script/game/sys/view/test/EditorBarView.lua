
--[[
    Author: pangkangning
    Date:2018-07-02
    Description: 地形编辑器工具栏
]]


local EditorBarView = class("EditorBarView", UIBase);

function EditorBarView:ctor(winName)
    EditorBarView.super.ctor(self, winName)
end
function EditorBarView:loadUIComplete()
	self.panel_dixing:visible(false)
	self.panel_dikuai:visible(false)
	self:addCoverInfo()

	self.btn_xingzou:setTouchedFunc(c_func(self.xingzouBtnClick,self))
	self.btn_dimian:setTouchedFunc(c_func(self.dimianBtnClick,self))
	self.btn_none:setTouchedFunc(c_func(self.noneBtnClick,self))
	self.btn_dikuai:setTouchedFunc(c_func(self.areaBtnClick,self))
	-- 此顺序和EditorControler.handleType 值一致
	self.handBtnArr= {
			self.btn_xingzou,
			self.btn_dimian,
			self.btn_none,
			self.btn_dikuai,
		}

	self.btn_shezhi:setTouchedFunc(c_func(self.shezhiBtnClick,self))

    EventControler:addEventListener(EditorEvent.EDITOR_GRID_CLICK,self.updateGridPosTxt,self)
    EventControler:addEventListener(EditorEvent.EDITOR_HANDLE_CHANGE,self.updateHandleStatus,self)
    EventControler:addEventListener(EditorEvent.EDITOR_REVIEW,self.reviewMap,self)


	-- WindowControler:showWindow("EditorOpenView")

	self:updateHandleStatus({params = EditorControler.handleData})
end
function EditorBarView:xingzouBtnClick()
	local view = self.panel_cover
	if view:isVisible() then
		view:visible(false)
	else
		view:visible(true)
		-- view.btn_0:getUpPanel().txt_1:setTextColor(cc.c3b(0,0,0))
		-- view.btn_1:getUpPanel().txt_1:setTextColor(cc.c3b(0,0,0))
		-- 显示当前选择的颜色(现在是写死的两个按钮)
		if EditorControler.handleData.type == EditorControler.handleType.cover then
			for k,v in pairs(self.coverBtnArr) do
				if EditorControler.handleData.value == k - 1 then
					v:getUpPanel().txt_1:setTextColor(cc.c3b(255,0,0))
				else
					v:getUpPanel().txt_1:setTextColor(cc.c3b(0,0,0))
				end
			end
		end
	end
end
function EditorBarView:dimianBtnClick()
	self:chkCloseReView()
	self:addTerrainItem()
	local view = self.panel_dixing
	if view:isVisible() then
		view:visible(false)
	else
		view:visible(true)
	end
end
function EditorBarView:noneBtnClick( )
	self:chkCloseReView()
	EditorControler:updateHandleInfo(EditorControler.handleType.none,nil)
end
function EditorBarView:reviewMap( )
	EditorControler:updateHandleInfo(EditorControler.handleType.none,nil)
	self:chkCloseReView()
	require("game.sys.view.guildExplore.init")
	self.reviewController = ExploreControler.new(self)
end
function EditorBarView:chkCloseReView( )
	if self.reviewController then
		self.reviewController:deleteMe()
	end
end
function EditorBarView:areaBtnClick()
	self:chkCloseReView()
	self:addAreaItem()
	local view = self.panel_dikuai
	if view:isVisible() then
		view:visible(false)
	else
		view:visible(true)
	end
end
function EditorBarView:shezhiBtnClick()
	self:chkCloseReView()
	WindowControler:showWindow("EditorSettingView")
end
-- 更新按钮高亮与否
function EditorBarView:updateHandleStatus(event)
	for k,v in pairs(self.handBtnArr) do
		local txtLab = v:getUpPanel().txt_1
		if event.params.type == k then
			txtLab:setTextColor(cc.c3b(255,0,0))
		else
			txtLab:setTextColor(cc.c3b(0,0,0))
		end
	end
end
-- 更新显示的坐标
function EditorBarView:updateGridPosTxt(event )
	local str = string.format("s : %s x : %s y : %s ",event.params.s,event.params.x,event.params.y)
	self.txt_info:setString(str)
end
-- 添加行走判定
function EditorBarView:addCoverInfo()
	local view = self.panel_cover
	if not self.coverBtnArr then
		self.coverBtnArr = {}
		for i=0,3 do
			local tmpBtn = view["btn_"..i]
			tmpBtn:setTouchedFunc(function()
				EditorControler:updateHandleInfo(EditorControler.handleType.cover,i)
				view:visible(false)
			end)
			table.insert(self.coverBtnArr,tmpBtn)
		end
	end
	-- view.btn_0:setTouchedFunc(function( )
	-- 	EditorControler:updateHandleInfo(EditorControler.handleType.cover,0)
	-- 	view:visible(false)
	-- end)
	-- view.btn_1:setTouchedFunc(function( )
	-- 	EditorControler:updateHandleInfo(EditorControler.handleType.cover,1)
	-- 	view:visible(false)
	-- end)
	self.panel_cover:visible(false)
end
-- 添加地面图片显示
function EditorBarView:addTerrainItem( )
	if self._isTerrainInit then
		return
	end
	self._isTerrainInit = true
	local x,y = self.btn_dimian:getPosition()
	local tmpView = self.panel_dixing
	tmpView:pos(x,y-80)
	tmpView.scroll_md:setTouchSwallowEnabled(true)
	tmpView.btn_item:visible(false)

    local tmpData = table.values(FuncGuildExplore.getAllDecorateMaterials())
    
    table.sort(tmpData,function( a,b )
    	return tonumber(a.id) < tonumber(b.id)
    end)
    local function createLeftFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(tmpView.btn_item)
        _view:getUpPanel().txt_1:setString(_item.id)
        _view:pos(0,0)
        local iconView = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_".._item.id)
		if iconView then
			-- 对图标缩放
			local size = iconView:getContainerBox()
			local sx,sy = size.width/104,size.height/51
			iconView:setScaleX(1/sx)
			iconView:setScaleY(1/sy)
			iconView:pos(70,25)
			iconView:addTo(_view:getUpPanel().rect_1)
		end
		_view:setTouchedFunc(c_func(self.backBtnClick,self,_item.id))
        return _view
    end
    local params = {
        data  = tmpData,
        createFunc = createLeftFunc,
        offsetX = 0,
        offsetY = 0,
        widthGap= 0,
        heighGap= 0,
        perFrame= 1,
        perNums = 1,
        itemRect= {x =0, y= -30,width = 131,height = 60},
    }
    tmpView.scroll_md:styleFill({params})
    tmpView:visible(false)
end
-- 地形数据变化
function EditorBarView:backBtnClick( id )
	EditorControler:updateHandleInfo(EditorControler.handleType.terrain,id)
	self.panel_dixing:visible(false)
end
-- 区块

-- 添加地面图片显示
function EditorBarView:addAreaItem( )
	if self._isAreaInit then
		return
	end
	self._isAreaInit = true
	local x,y = self.btn_dikuai:getPosition()
	local tmpView = self.panel_dikuai
	tmpView:pos(x,y-80)
	tmpView.scroll_md:setTouchSwallowEnabled(true)
	tmpView.btn_item:visible(false)

    local tmpData = table.values(FuncGuildExplore.getAllArea())
    table.sort(tmpData,function( a,b )
    	return tonumber(a.id) < tonumber(b.id)
    end)
    local function createLeftFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(tmpView.btn_item)
        _view:getUpPanel().txt_1:setString(_item.id)
        _view:pos(0,0)
		_view:setTouchedFunc(c_func(self.areaItemBtnClick,self,_item.id))
        return _view
    end
    local params = {
        data  = tmpData,
        createFunc = createLeftFunc,
        offsetX = 0,
        offsetY = 0,
        widthGap= 0,
        heighGap= 0,
        perFrame= 1,
        perNums = 1,
        itemRect= {x =0, y= -30,width = 131,height = 60},
    }
    tmpView.scroll_md:styleFill({params})
    tmpView:visible(false)
end
-- 地形数据变化
function EditorBarView:areaItemBtnClick( id )

	EditorControler:updateHandleInfo(EditorControler.handleType.area,id)
	self.panel_dikuai:visible(false)
end

function EditorBarView:deleteMe(  )
	 cc.Director:getInstance():getEventDispatcher():removeEventListener(self.keyListener)
end

return EditorBarView