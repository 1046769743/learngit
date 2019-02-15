-- TitleDataView
--aouth wk
--time 2017/7/12

local TitleDataView = class("TitleDataView", UIBase);


function TitleDataView:ctor(winName,titletype)
    TitleDataView.super.ctor(self, winName);
    self.titletype = titletype ---称号类型
    self.selectindex = 1 ---默认选中第一个index
end

function TitleDataView:loadUIComplete()
	self:registerEvent();

	
	self.panel_ren.btn_huifang:setTouchedFunc(c_func(self.resetButton, self),nil,true);
	self.mc_1:setTouchedFunc(c_func(self.buttonTipsview, self),nil,true);
	self.panel_chenghao:setVisible(false)
	self.mc_1:showFrame(2)
	self:charGarmentview()
	self:SumAtter()
	self:updateUI()
	self:Addattribute()
	self:attributeandtitleicon(TitleModel:gettitleids())


	self:scheduleUpdateWithPriorityLua(c_func(self.updataTime,self),0)

end 
--刷新主角的称号和战力变化，以及属性添加
function TitleDataView:refreshCharData(titleid)
	self:attributeandtitleicon(titleid)
	self:Addattribute()
	self:SumAtter()
end
--所有属性加成
function TitleDataView:Addattribute()
	local attribute,notattribute =  TitleModel:battletostring()
	if attribute ~= nil then
		if #attribute ~= 0 then
			self.mc_1:showFrame(1)
			for i=1,6 do
				self.mc_1:getViewByFrame(1).panel_jiacheng["rich_"..i]:setVisible(false)
			end
			for i=1,#attribute do
				if self.mc_1:getViewByFrame(1).panel_jiacheng["rich_"..i] ~= nil then
					self.mc_1:getViewByFrame(1).panel_jiacheng["rich_"..i]:setVisible(true)
					self.mc_1:getViewByFrame(1).panel_jiacheng["rich_"..i]:setString(attribute[i])
				end
			end
		end 
	end

end
function TitleDataView:buttonTipsview()
	WindowControler:showWindow("TitlexinxiView");
end
function TitleDataView:registerEvent()
	TitleDataView.super.registerEvent();
	EventControler:addEventListener(TitleEvent.TitleEvent_TOUCH_NOTTYPE, self.touchindex, self)
	EventControler:addEventListener(TitleEvent.TitleEvent_ONTIME_CALLBACK, self.ontimeCallback, self)
	EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.updateUI, self);
	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.updateUI, self);
	EventControler:addEventListener(TitleEvent.HONOR_GET_COM ,self.updateUI,self)

end
--时间到了，接受刷新问题
function TitleDataView:ontimeCallback()
	-- echo("222222222222222222222222222222222")
	self:attributeandtitleicon(TitleModel:gettitleids())
	self:Addattribute()
	self:SumAtter()
end

function TitleDataView:touchindex(event)
	-- echo("222222222222=========",event.params)
	self.titletype = event.params
	self:updateUI()
end

function TitleDataView:updateUI()
	
	-- self.titletype
	-- echo("===========11111==========",self.titletype)
	-- self.datalist = FuncTitle.bytypegetData(self.titletype)
	
	self.datalist = TitleModel:byTtetypegetTteData(self.titletype)


	-- dump(self.datalist,"称号的列表数据",10)

    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(self.panel_chenghao);
        self:updateListCell(baseCell, itemData)
        return baseCell;
    end
 --    local updateFunc = function (itemData,view)
 --    	self:updateListCell(view, itemData)
	-- end


    local  _scrollParams = {
        {
            data = self.datalist,
            createFunc = createRankItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 15,
            offsetY = 15,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -132, width = 628, height = 132},
            perFrame = 1,
        }
    }    
    self.indexitem = 0
    -- self.scroll_1:setItemAppearType(1, true);
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(_scrollParams);
end
--[[

4 = {
    "BattleAttribute" = {
        1 = *MAX NESTING*
    }
    "condition"       = 100001
    "id"              = 102
    "taskDescription" = "#tid_quest_100001"
    "titlePng"        = "title_1_1"
    "titleQuality"    = 1
    "conditionType"    = 14
    "titleType"       = 1
}
]]
function TitleDataView:updateListCell(_cell,itemData)

	-- dump(itemData,"=========1=1111===========")
	_cell:setVisible(true)
	_cell.panel_peidaizhong:setVisible(false)
	_cell.scale9_xuanzhong:setVisible(false)
	self.indexitem = self.indexitem + 1
	--ctn_1  称号图片 添加
	_cell.ctn_1:removeAllChildren()
	local titlesprite = FuncTitle.bytitleIdgetpng(itemData.id)
	local titleicon = display.newSprite(titlesprite)
	titleicon:setScale(0.8)
	_cell.ctn_1:addChild(titleicon)

	local titleInfo = FuncTitle.byIdgettitledata(itemData.id)
	-- dump(titleInfo,"=======",6)

	--添加战力
	local addAbility = itemData.addAbility
	if addAbility then 
		_cell.UI_number:setPower(addAbility)
	end
	
	local filetid =  itemData.taskDescription
	if filetid ~= nil then
		_cell.rich_1:setString(GameConfig.getLanguage(filetid));
	end

	if itemData.titleType == FuncTitle.titlettype.title_limit  then  --限时的
		
		self:setlimitview(_cell,itemData)  --local cost = UserModel:totalCostGold();  消耗仙玉

	else                              --其他三种类型
		_cell.mc_txt:showFrame(1)
		local des =  titleInfo.battleAttribute[1]   --称号的战斗属性

		if des ~= nil then
			local str = TitleModel:getDesStaheTable(des)
			_cell.mc_txt:getViewByFrame(1).rich_2:setString(str)
			if itemData.privilege ~= nil then
				_cell.mc_txt:getViewByFrame(1).rich_3:setVisible(true)
				local des = itemData.privilege[1]
				if des ~= nil then
					_cell.mc_txt:getViewByFrame(1).rich_3:setString()  ---称号的非战斗属性
				else
					_cell.mc_txt:getViewByFrame(1).rich_3:setString("")
				end
			else
				_cell.mc_txt:getViewByFrame(1).rich_3:setVisible(false)
			end
		end
	end

	self:allitembutton(_cell,itemData)
	_cell:setTouchedFunc(c_func(self.selectitem, self,self.indexitem),nil,true);


	if self.indexitem == self.selectindex then
		_cell.scale9_xuanzhong:setVisible(true)
	end

end
function TitleDataView:CallfuncNil()
	-- body
end

--设置消耗显示的问题
function TitleDataView:setCostText(_cell,itmedata)
	
	if itmedata.conditionType == TargetQuestModel.Type.COIN then
		local completeCondition = itmedata.completeCondition[1]
		local cost = UserModel:getCoinTotal() - UserModel:getCoin();
		_cell.mc_btn:showFrame(5) 
		_cell.mc_btn:getViewByFrame(5).txt_1:setString(GameConfig.getLanguage("tid_common_2062")..cost.." / "..completeCondition)
		if tonumber(cost) >= tonumber(completeCondition) then
			_cell.mc_btn:showFrame(1)
		end
		_cell.mc_btn:setTouchEnabled(false)
		-- _cell.mc_btn:setTouchedFunc(c_func(self.CallfuncNil, self),nil,true);
	elseif itmedata.conditionType == TargetQuestModel.Type.GOLD then
		local completeCondition = itmedata.completeCondition[1]
		local cost = UserModel:totalCostGold();
		_cell.mc_btn:showFrame(5)
		_cell.mc_btn:getViewByFrame(5).txt_1:setString(GameConfig.getLanguage("tid_common_2063")..cost.." / "..completeCondition)
		if tonumber(cost) >= tonumber(completeCondition) then
			_cell.mc_btn:showFrame(1)
		end
		-- _cell.mc_btn:setTouchedFunc(c_func(self.CallfuncNil, self),nil,true);
		_cell.mc_btn:setTouchEnabled(false)
	else
		-- _cell.mc_btn:showFrame(5)
		-- _cell.mc_btn:getViewByFrame(5).txt_1:setString("消耗:0/0")
		if itmedata.completeCondition == nil then
				echoError("表中没配获取称号的条件，，==找策划  罗鑫  ,titleid = ",itmedata.id)
		end
	end
end
-- 选中第几个控件
function TitleDataView:selectitem(indexitem)

	local allViewArr = self.scroll_1:getAllView()
	for i,v in ipairs(allViewArr) do
		if i == indexitem then
			v.scale9_xuanzhong:visible(true)
		else
			v.scale9_xuanzhong:visible(false)
		end
	end
	local itemdata = self.datalist[indexitem]
	if itemdata ~= nil then
		self:touchItemrefreshchar(itemdata)
	end

end
--点击空件刷新主角数据
function TitleDataView:touchItemrefreshchar(itemdata)
	-- dump(itemdata,"点击空件刷新主角数据")

	self:attributeandtitleicon(itemdata.id)
end
--限时处理
function TitleDataView:setlimitview(_cell,itemData)
	-- dump(itemData,"限时称号",7)
	if itemData.title ~= nil then
		if itemData.title.isAction ~= 1 then  --isAction  0 获得未激活  1 获得已激活
			_cell.mc_txt:showFrame(3)
			if  itemData.time ~= nil then
				local times =  math.floor(itemData.time/3600)
				local _str = string.format(GameConfig.getLanguage("#tid_title_005"),tostring(times))
				_cell.mc_txt:getViewByFrame(3).rich_1:setString(_str)
			end
			_cell.mc_btn:showFrame(1)
			_cell.mc_btn:setTouchedFunc(c_func(self.getactive, self,itemData.id),nil,true);
		else
			if itemData.title.isAction == 1 then 
				if TitleModel:gettitleids() ~= nil then
					if tonumber(TitleModel:gettitleids()) == tonumber(itemData.id) then  --已穿戴
						_cell.panel_peidaizhong:setVisible(true)
						_cell.mc_btn:showFrame(2)
						_cell.mc_btn:setTouchedFunc(c_func(self.uninstallbutton, self,itemData.id),nil,true);
					else   --可以穿戴
						_cell.mc_btn:showFrame(3)
						_cell.mc_btn:setTouchedFunc(c_func(self.wearButton, self,itemData.id),nil,true);
					end
				else
					_cell.mc_btn:showFrame(3)
					_cell.mc_btn:setTouchedFunc(c_func(self.wearButton, self,itemData.id),nil,true);
				end
			end
			_cell.mc_txt:showFrame(2)--限时倒计时的时间
			local time = self:parsingtime(itemData.title.expireTime)
			if time ~= nil then
				_cell.mc_txt:getViewByFrame(2).txt_1:setString(GameConfig.getLanguage("#tid_title_006")..time)
			end
		end
	else
		_cell.mc_txt:showFrame(3)
		if  itemData.time ~= nil then
			local times =  math.floor(itemData.time/3600)
			local _str = string.format(GameConfig.getLanguage("#tid_title_005"),tostring(times))
			_cell.mc_txt:getViewByFrame(3).rich_1:setString(_str)
		end
		_cell.mc_btn:showFrame(5)
		_cell.mc_btn:getViewByFrame(5).txt_1:setString("0/1")
		_cell.mc_btn:setTouchedFunc(function () end,nil,true);
		-- self:setCostText(_cell,itemData)
	end
end

--空件上按钮的处理
function TitleDataView:allitembutton(_cell,itemData)
	-- dump(itemData,"0000000000")
	if itemData.titleType ~= FuncTitle.titlettype.title_limit then
		if itemData.title == nil then
			_cell.mc_btn:showFrame(4)  ---都是获取
			_cell.mc_btn:setTouchEnabled(true)
			_cell.mc_btn:setTouchedFunc(c_func(self.getbuttonclbck, self,itemData.id),nil,true);
			self:setCostText(_cell,itemData)
		else
			if itemData.title.isAction == 0 then  --isAction  0 获得未激活  1 获得已激活
				_cell.mc_btn:showFrame(1)
				_cell.mc_btn:setTouchedFunc(c_func(self.getactive, self,itemData.id),nil,true);
			else
				-- echo("=========当前穿戴Id=====",TitleModel:gettitleids())
				if TitleModel:gettitleids() ~= nil then
					if tonumber(TitleModel:gettitleids()) == tonumber(itemData.id) then  --已穿戴
						_cell.panel_peidaizhong:setVisible(true)
						_cell.mc_btn:showFrame(2)
						_cell.mc_btn:setTouchedFunc(c_func(self.uninstallbutton, self,itemData.id),nil,true);
					else   --可以穿戴
						_cell.mc_btn:showFrame(3)
						_cell.mc_btn:setTouchedFunc(c_func(self.wearButton, self,itemData.id),nil,true);
					end
				else
					_cell.mc_btn:showFrame(3)
					_cell.mc_btn:setTouchedFunc(c_func(self.wearButton, self,itemData.id),nil,true);
				end
			end
		end

	end
end
--点击激活按钮
function TitleDataView:getactive(titleid)
	-- echo("=======获得未激活 奖励====titleid====",titleid)

	local function _callback(_param)
		if (_param.result ~= nil) then
			local cellindex = self:bytitleIdgetCell(titleid)
			if cellindex ~= nil then
				local titlelist = _param.result.data.dirtyList.u.titles
				TitleModel:setalltitledataisAction(titlelist)
				local allViewArr = self.scroll_1:getAllView()
				local cellview = allViewArr[cellindex]
				cellview.mc_btn:showFrame(3)
				cellview.mc_btn:setTouchedFunc(c_func(self.wearButton, self,titleid),nil,true);
				WindowControler:showWindow("TitleRewardView",titleid);
				self:Addattribute()

				local  total = AbilityModel:getTotalAbility() or 0
				self:SumAtter(total - UserModel:getcharSumAbility())
				-- WindowControler:showTips("激活成功");
				EventControler:dispatchEvent(TitleEvent.TitleEvent_C_X_CALLBACK)
				self:updateUI()
				-- EventControler:dispatchEvent(TitleEvent.REFRESH_POWER_CHANRE_UI)
			end
		else
			
   		end
    end
 	local params = {}
   	params.titleId = tostring(titleid)
	TitleServer:sendActivation(params,_callback)
end

--卸载
function TitleDataView:uninstallbutton(titleid)
	-- echo("=======卸载====titleid====",titleid)
	local function _callback(_param)
		-- dump(_param.result,"卸载结果",10)
		if (_param.result ~= nil) then
			local cellindex = self:bytitleIdgetCell(titleid)
			if cellindex ~= nil then
				local allViewArr = self.scroll_1:getAllView()
				for k,v in pairs(allViewArr) do
					v.panel_peidaizhong:setVisible(false)
				end
				local cellview = allViewArr[cellindex]
				cellview.mc_btn:showFrame(3)
				cellview.mc_btn:setTouchedFunc(c_func(self.wearButton, self,titleid),nil,true);
				cellview.panel_peidaizhong:setVisible(false)
				TitleModel:settitleid("")
				self:attributeandtitleicon("")
				EventControler:dispatchEvent(TitleEvent.TitleEvent_C_X_CALLBACK)
				if self.titletype == FuncTitle.titlettype.title_limit  then  --限时的
					TitleModel:ontimesenghome()
					self:updateUI()
				end
				WindowControler:showTips(GameConfig.getLanguage("#tid_title_007"));
			end
		else
			
   		end
    	end
  	local params = {}
   	params.titleId = ""
    TitleServer:senduninstall(params,_callback)
end
--佩戴
function TitleDataView:wearButton(titleid)
	-- echo("=======佩戴====titleid====",titleid)
	local function _callback(_param)
		-- dump(_param.result,"佩戴结果",10)
		if (_param.result ~= nil) then
			local cellindex = self:bytitleIdgetCell(titleid)
			if cellindex ~= nil then
				local allViewArr = self.scroll_1:getAllView()
				local celloldindex = nil
				if TitleModel:gettitleids() ~= "" then
					celloldindex = self:bytitleIdgetCell(TitleModel:gettitleids())
				end
				for k,v in pairs(allViewArr) do
					v.panel_peidaizhong:setVisible(false)
					if celloldindex ~= nil then
						if tonumber(k) == celloldindex then
							v.mc_btn:showFrame(3)
							local titleid = self.datalist[celloldindex].id
							v.mc_btn:setTouchedFunc(c_func(self.wearButton, self,titleid),nil,true);
						end
					end
				end
				local cellview = allViewArr[cellindex]
				cellview.mc_btn:showFrame(2)
				cellview.mc_btn:setTouchedFunc(c_func(self.uninstallbutton, self,titleid),nil,true);
				cellview.panel_peidaizhong:setVisible(true)
				self:attributeandtitleicon(titleid)
				TitleModel:settitleid( titleid )
				EventControler:dispatchEvent(TitleEvent.TitleEvent_C_X_CALLBACK)
				if self.titletype == FuncTitle.titlettype.title_limit  then  --限时的
					TitleModel:ontimesenghome()
				end
				WindowControler:showTips(GameConfig.getLanguage("#tid_title_008"));
			end
		else
			
   		end
    end
  	local params = {}
  	params.titleId = tostring(titleid)
	TitleServer:sendwear(params,_callback)
end
--根据titleId获得第几个控件
function TitleDataView:bytitleIdgetCell(titleid)

	for k,v in pairs(self.datalist) do
		if tonumber(titleid) == v.id then
			return tonumber(k)
		end
	end
	return nil
end
--获取按钮点击跳转
function TitleDataView:getbuttonclbck(titleid)
	echo("===========点击获取的的  title  id ==============",titleid)

	FuncTitle.bytitleIdgetcondition(titleid)
end
--穿时装的主角
function TitleDataView:charGarmentview()
	local node = GarmentModel:getCharGarmentSpine();  --穿时装的主角
	self.panel_ren.ctn_1:addChild(node);
end
--主角战力总战力
function TitleDataView:SumAtter(addnumer)
	if addnumer == nil then
		addnumer = 0
	end
	local data =  TitleModel.servetitlelist
	-- local sumatter = UserModel:getAbility()
	local sumatter = FuncTitle.byTitleUIdGetsumbattl(data)
	self.panel_ren.UI_number:setPower(sumatter)
end

---主角称号图标
function TitleDataView:attributeandtitleicon(titleid)
	-- echo("=======主角的称号 ID ============",titleid)
	self.panel_ren.ctn_name:removeAllChildren()
	if titleid ~= ""  then
		---加称号图标
		local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
		local titleicon = display.newSprite(titlesprite)
		self.panel_ren.ctn_name:addChild(titleicon)
	end


end
--重置按钮
function TitleDataView:resetButton()
	echo("======称号重置======")


	local titleid =  TitleModel:gettitleids()
	self:attributeandtitleicon(titleid)

end
function TitleDataView:updataTime()
	if self.titletype == FuncTitle.titlettype.title_limit  then  --限时的
		local allViewArr = self.scroll_1:getAllView()
		-- dump(self.datalist,"222",6)
		for i=1,#self.datalist do
			if self.datalist[i].title ~= nil then
				-- if self.datalist[i].title.isAction ~= 0 then
					local times =  self.datalist[i].title.expireTime
					local stringtime  = self:parsingtime(times)
					if stringtime ~= nil then
						allViewArr[i].mc_txt:showFrame(2)
						allViewArr[i].mc_txt:getViewByFrame(2).txt_1:setString(GameConfig.getLanguage("#tid_title_006")..stringtime)
					else
						if allViewArr[i] ~= nil then
							allViewArr[i].mc_txt:showFrame(3)
							if  self.datalist[i].time ~= nil then
								local times =  math.floor(self.datalist[i].time/3600)
								local _str = string.format(GameConfig.getLanguage("#tid_title_005"),tostring(times))
								allViewArr[i].mc_txt:getViewByFrame(3).rich_1:setString(_str)
							end 
							-- allViewArr[i].panel_peidaizhong:setVisible(false)
							if tonumber(TitleModel:gettitleids()) == tonumber(self.datalist[i].id) then
								if HomeModel:getHonorDataRid() ~= UserModel:rid() then
									allViewArr[i].panel_peidaizhong:setVisible(false)
									TitleModel:settitleid("")  --设置空的称号id
									self:refreshCharData()
								end
								-- WindowControler:showTips("限时称号时限已到");
							end
							if HomeModel:getHonorDataRid() ~= UserModel:rid() then
								allViewArr[i].mc_btn:showFrame(5)
								allViewArr[i].mc_btn:getViewByFrame(5).txt_1:setString("0/1")
								allViewArr[i].mc_btn:setTouchedFunc(function ()  end,nil,true);
							end
						end
					end
				-- end
			end
		end
	end
end

function TitleDataView:parsingtime(_time)
	local timestring = ""
	local localtime = TimeControler:getServerTime()
	-- echo("=============time===========",time,localtime)
	local time =  _time - localtime
	if time > 0 then
		local h = math.floor(time/3600)
        local s = math.floor((time-h*3600)/60)
        local m = math.fmod(time,60)
       
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
                timestring = h..":"..s..":"..m
            end
        else
            if s ~= 0 then
                timestring = s..":"..m
            else
                timestring = m
            end
        end
        return timestring
	end
	return nil
end



return TitleDataView;
