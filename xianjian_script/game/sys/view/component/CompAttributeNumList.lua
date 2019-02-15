-- CompAttributeNumList.lua




local CompAttributeNumList = class("CompAttributeNumList", UIBase);

----params = {text = {},isAnimation  = ,isEffect = }
function CompAttributeNumList:ctor(_winName)
    CompAttributeNumList.super.ctor(self, _winName);
    -- self.params = params
    self.panel_arr  = {}
end
--
function CompAttributeNumList:loadUIComplete()
    self:registerEvent();
   	self.panel_1:setVisible(false)
    self.icon_scale_size = self.panel_1.scale9_1:getContentSize()
    self.icon_scale_posY = self.panel_1.scale9_1:getPositionY()
    self.rich_1_x  = self.panel_1.rich_1:getPositionX()
    self.rich_1_y  = self.panel_1.rich_1:getPositionY()
    self.rich_1_size = self.panel_1.rich_1:getContainerBox()
    dump(self.rich_1_size,"11111111111111")
end

function CompAttributeNumList:registerEvent()
    CompAttributeNumList.super.registerEvent(self);
    


end

function CompAttributeNumList:initData(params)

	self.params = params
	self:createCell()
end

function CompAttributeNumList:createCell()

	-- if  self.panel_arr then

	-- dump(self.params,"九宫格大小====")
	self.params._ctn:stopAllActions()
	self.params._ctn:setVisible(true)
	local num = table.length(self.params.text)

	if self.panel_arr then
		for i=1,#self.panel_arr do
			if self.panel_arr[i] then
				self.panel_arr[i]:setVisible(false)
			end
		end
	end


	if #self.panel_arr == 0 then
		for i=1,num do
			local panel = UIBaseDef:cloneOneView(self.panel_1)
			self.panel_arr[i] = panel
			panel:setPosition(cc.p(0,((i-1)*-45 + num/2*50)))
			if self.params.scale_Size then
				panel.scale9_1:setContentSize(self.params.scale_Size.width,self.params.scale_Size.height)
			end
			self.panel_arr[i]:addTo(self)
			-- self.panel_arr[i]:setVisible(true)
			self:setData(self.params.text[i],self.panel_arr[i])
		end
	else
		for i=1,num do
			if not self.panel_arr[i] then
				local panel = UIBaseDef:cloneOneView(self.panel_1)
				self.panel_arr[i] = panel
				panel:setPosition(cc.p(0,(i-1)*-45+ num/2*50))
				self.panel_arr[i]:addTo(self)
				if self.params.scale_Size then
					panel.scale9_1:setContentSize(self.params.scale_Size.width,self.params.scale_Size.height)
				end
			else
				self.panel_arr[i]:setPosition(cc.p(0,(i-1)*-45+ num/2*50))
			end
			-- self.panel_arr[i]:setVisible(true)
			self:setData(self.params.text[i],self.panel_arr[i])
		end
	end

	self.params._ctn:setOpacity(255)
	self.params._ctn:runAction(act.sequence(act.delaytime(2),act.fadeto(0.2,0),act.callfunc(function ()
		self.params._ctn:setVisible(false)
		if self.params.callBack then
			self.params.callBack()
		end
	end)))
end

function CompAttributeNumList:setData(data,cell)
	--添加特效，暂时没有
	if self.params.scale then
		cell.rich_1:setScale(1.3)
    	local x = self.rich_1_size.width/7
    	local y = self.rich_1_size.height/6
		cell.rich_1:setPosition(cc.p(self.rich_1_x - x,self.rich_1_y + y))
	else
		cell.rich_1:setScale(1)
		cell.rich_1:setPosition(cc.p(self.rich_1_x,self.rich_1_y))
	end

	cell.rich_1:setString(data)
	cell.scale9_1:setContentSize(380,42)
	cell:setVisible(true)
	cell.scale9_1:setPositionY(self.icon_scale_posY)
	local newheight,lengthnum = FuncCommUI.getStringHeightByFixedWidth(data,22,nil,360)

	if not self.params.cellNoOffsetY and lengthnum > 1 then
		cell.scale9_1:setContentSize(self.icon_scale_size.width,self.icon_scale_size.height+18)
		cell.scale9_1:setPositionY(self.icon_scale_posY+9)
		local y = cell:getPositionY()
		cell:setPositionY(y - 9)
	end

	local children = cell.ctn_1:getChildByName("UI_common")
	if not children then
		children = self:createUIArmature("UI_common", "UI_common_zhanlitisheng" ,cell, false ,function ()
			-- cell.ctn_1:removeFromParent()
			-- cell:setVisible(false)
		end )
		
		children:setName("UI_common")
	end
	-- cell.rich_1:setPosition(cc.p(-100,15))
	-- FuncArmature.changeBoneDisplay(children, "node2",cell.rich_1)
	children:startPlay(false,true)
	-- cell.rich_1:setPosition(cc.p(-100,15))
	-- FuncArmature.changeBoneDisplay(children, "node2",cell.rich_1)
	-- cell:setOpacity(255)
	-- cell:setVisible(true)
	-- cell:runAction(act.sequence(act.delaytime(2),act.fadeto(0.2,0),act.callfunc(function ()
	-- 	-- cell:setVisible(false)
	-- 	if self.params.callBack then
	-- 		self.params.callBack()
	-- 	end
	-- 	-- if self.params._ctn then
	-- 	-- 	self.params._ctn:removeAllChildren()
	-- 	-- end
	-- end)))
end




return CompAttributeNumList;
