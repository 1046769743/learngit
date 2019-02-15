--[[
	法宝激活
	author: lcy
	add: 2018.08.14
]]

local TreasureJihuoView = class("TreasureJihuoView", UIBase)

function TreasureJihuoView:ctor(winName, params)
	TreasureJihuoView.super.ctor(self, winName)

	self._treasureId = params.treasureId or "404"
	self._callBack = params.callBack
end

function TreasureJihuoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function TreasureJihuoView:registerEvent()

end

function TreasureJihuoView:initData()
	
end

function TreasureJihuoView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.LeftTop)

	-- 任意位置关闭
	self:registClickClose(999,function()
		if self._callBack then self._callBack() end
		self:startHide()
	end)
end

function TreasureJihuoView:initView()
	-- body
end

function TreasureJihuoView:updateUI()
	-- 标题特效
    FuncCommUI.addCommonBgEffect(self.ctn_2,12)

    self:updateLihui()
    self:updateIcon()
    self:updateAttrList()
end

-- 处理左侧立绘显示
function TreasureJihuoView:updateLihui()
	-- 立绘spine
	local ctn = self.panel_2.ctn_1
	ctn:removeAllChildren()
	local sp = FuncTreasureNew.getTreasLihui(self._treasureId):addTo(ctn)

	-- 名字
	local namemc = self.panel_2.mc_1
	namemc:showFrame(FuncTreasureNew.getNameColorFrame(self._treasureId))
	namemc.currentView.txt_1:setString(GameConfig.getLanguage(FuncTreasureNew.getTreasureDataById(self._treasureId).name))
end

-- 处理法宝信息
function TreasureJihuoView:updateIcon()
	local data = self._treasureId
	local dataCfg = FuncTreasureNew.getTreasureDataById(data)
	-- 星级
	local star = dataCfg.initStar
	-- 策划说 头像框颜色 资质对应颜色
	local quality = FuncTreasureNew.getKuangColorFrame(data)
	-- icon
	local iconPath = FuncRes.iconTreasureNew(data)

	-- 处理两个图标
	for i=1,2 do
		local view = self.panel_3["mc_"..i]
		view:showFrame(1)
		-- 选中框
		view.currentView.panel_1:visible(false)
		-- 红点
		view.currentView.panel_red:visible(false)
		-- 角标
		view.currentView.mc_pj:visible(false)
		-- 星级
		view.currentView.mc_dou:showFrame(star)
		-- 品质
		view.currentView.mc_2:showFrame(quality)
		-- 图标
		view.currentView.mc_2.currentView.ctn_1:removeAllChildren()
		local treasureIcon = display.newSprite(iconPath)
		view.currentView.mc_2.currentView.ctn_1:addChild(treasureIcon)
		-- 置灰
		if i == 1 then
			FilterTools.setViewFilter(treasureIcon,FilterTools.colorMatrix_gray)
		else
			FilterTools.clearFilter(treasureIcon)
		end
	end

	-- 战力0->此法宝战力
	self.panel_3.UI_1:setPower(0)

	-- 箭头
	local arrow = self:createUIArmature("UI_common","UI_common_jiantou",self.panel_3.ctn_jiantou,false,function ()
		
	end)

	-- 右侧
	local power = 0
	local data = TreasureNewModel:getTreasureData(tostring(self._treasureId))
	local level = UserModel:level()

	if data and level then
		power = FuncTreasureNew.getTreasureAbility(data,level)
	end
	self.panel_3.UI_2:setPower(power)
end

-- 处理属性信息
function TreasureJihuoView:updateAttrList()
	self.panel_t1:visible(false)
	self.panel_t2:visible(false)

	local function createFunc(panelidx)
		local view = UIBaseDef:cloneOneView(self["panel_t"..panelidx])
		self:updateItem(view, panelidx)
		return view
	end

	local dataCfg = FuncTreasureNew.getTreasureDataById(self._treasureId)
	-- 计算永久激活高
	local gao = (math.ceil(dataCfg.initStar/2) + 1) < 4 and (math.ceil(dataCfg.initStar/2) + 1) or 4
	gao = 40 + gao * 30

	local offsetX = 10
	local scrollParams = {
		{
			data = {1},
			createFunc = createFunc,
			perFrame = 1,
			offsetX = offsetX,
			offsetY = 0,
			itemRect = {x=0,y= -105,width=440,height = 105},
			widthGap = 0,
			heightGap = 0,
			perNums = 1,
		},
		{
		    data = {2},
		    createFunc= createFunc,
		    perFrame = 1,
		    offsetX =offsetX,
		    offsetY = 0,
		    itemRect = {x=0,y= -gao,width=440,height = gao},
		    widthGap = 0,
		    heightGap = 0,
		    perNums = 1,
		},
	}

	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end

function TreasureJihuoView:updateItem(view,panelidx)
	local dataCfg = FuncTreasureNew.getTreasureDataById(self._treasureId)
	if panelidx == 1 then -- 佩戴属性
		local key = "attribute" .. dataCfg.initStar
		--显示基础属性
		local sxArra = FuncTreasureNew.getTreasureDataByKeyID(self._treasureId, key)
		for i,v in ipairs(sxArra) do
		    if i <= 4 then
		    	local panel = view["panel_"..i]
		        local des = FuncTreasureNew.getAttrDesTable(v)
		        panel.txt_1:setString(des)
		        panel.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
		    end
		end
	elseif panelidx == 2 then -- 上阵奇侠属性
		-- 标题
		view.txt_1:setString(GameConfig.getLanguage(dataCfg.xianshiweizhi))
		-- 属性UI上，只显示前4个
		for i=1, 4 do
			local panel = view["panel_"..i]
			if i <= tonumber(dataCfg.initStar) then
				local attr = FuncTreasureNew.getTreaPermanentAttr(self._treasureId, i, 0)
				local des = FuncTreasureNew.getTreaStarAttr(self._treasureId, i, 0 )
				panel.txt_1:setString(des)
				panel.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attr.key)])
			else
				panel:visible(false)
			end
		end
	end
end

function TreasureJihuoView:onClickBack()
	self:startHide()
end

return TreasureJihuoView