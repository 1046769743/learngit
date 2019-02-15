-- RankTwoMainView
--[[
	Author: wk
	Date:2018-01-15
]]

local RankTwoMainView = class("RankTwoMainView", UIBase);

function RankTwoMainView:ctor(winName)
    RankTwoMainView.super.ctor(self, winName)
end

function RankTwoMainView:loadUIComplete()
	self:registerEvent()
	-- self.panel_1.btn_1:setTouchedFunc(c_func(self.close, self))
	-- self.UI_1:setVisible(false)
	self.panel_1:setVisible(false)
	self.panel_1.panel_1:setVisible(false)
	self.panel_1.panel_2:setVisible(false)
	-- self.txt_1:setVisible(false)
end 


function RankTwoMainView:clickClose()
	self:registClickClose("out")

	-- self.UI_1.btn_close:setTouchedFunc(c_func(self.close, self))
	-- self.UI_1.mc_1:setVisible(false) 
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_newRank_012"))
	-- self.UI_1:setVisible(true)
end


function RankTwoMainView:registerEvent()
	RankTwoMainView.super.registerEvent(self);
end

function RankTwoMainView:initData(arrayData,rankInfo)
	self.panel_1:setVisible(true)
	self.panel_1.panel_1:setVisible(true)
	self.panel_1.panel_2:setVisible(true)
	self.allData = rankInfo or RankAndcommentsModel:getAllRankInfoData()

	self.arrayData = arrayData
	local isshow = FuncRankAndcomments.showStarBySystemName(arrayData.systemName)

	self.panel_1.panel_name.panel_star_1:setVisible(isshow)

	if self.allData == nil or #self.allData == 0  then
		self.panel_1:setVisible(false)
		-- self.txt_1:setVisible(true)
		-- self.txt_1:setString(GameConfig.getLanguage("#tid_newRank_013")) 
	end
			--战力最低的数据
	self:downViewInitData(self.allData)
	self:upViewInitData(self.allData)

	
end

function RankTwoMainView:downViewInitData(data)

	data = data[1]
	local panel = self.panel_1.panel_1
	if data ~= nil then
		-- self.downplayData = data[1]
		-- dump(data,"33333333333")
		for k,v in pairs(data) do
			if v.id == "1" then
				self.downplayData = v
			end
		end
		if not self.downplayData then
			self.downplayData = RankAndcommentsModel:getPlayInfoMinAbilityData()
		end

		self:setplayerData(panel,self.downplayData)
		self:setPartnerData(panel,data) --暂时用
		panel.btn_guankan:setTouchedFunc(c_func(self.buttonVideo, self));
	else
		panel.btn_guankan:setVisible(false)
		panel.panel_tou:setVisible(false)
		-- for i=1,6 do
		-- 	panel["UI_"..i]:setVisible(false)
		-- end
		self.panel_1.panel_1:setVisible(false)
	end

end
function RankTwoMainView:upViewInitData(data)
	data = data[2] 
	local panel = self.panel_1.panel_2
	if data ~= nil then
		-- self.upPlayData = data[1]
		for k,v in pairs(data) do
			if v.id == "1" then
				self.upPlayData = v
			end
		end
		if not self.upPlayData then
			self.upPlayData = RankAndcommentsModel:getPlayInfoLeastShotData()
		end
		self:setplayerData(panel,self.upPlayData)
		self:setPartnerData(panel,data) --暂时用
		panel.btn_guankan:setTouchedFunc(c_func(self.buttonVideo, self));
	else
		panel.btn_guankan:setVisible(false)
		panel.panel_tou:setVisible(false)
		-- for i=1,6 do
		-- 	panel["UI_"..i]:setVisible(false)
		-- end
		self.panel_1.panel_2:setVisible(false)
	end
end

function RankTwoMainView:setplayerData(view,data)
	local panelView = view
	self.charData = data
	-- dump(data,"排行数据=1111111111111111====")
	if not self.charData then
		panelView.panel_tou:setVisible(false)
		return 
	end
	if panelView.panel_power ~= nil then
		--战力
		local ability  = data.num or 0
		panelView.panel_power.UI_number:setPower(ability)
	end

	-- 出手次数
	if panelView.mc_17 ~= nil then
		local items = data.num or 0
		-- if items >= 99 then
		-- 	items = 99
		-- end
		panelView.mc_17:showFrame(1)
		local numUI =  panelView.mc_17:getViewByFrame(1).UI_number
		numUI:setPower(items)
		if items >= 20  then
			local x =  numUI:getPositionX()
			numUI:setPositionX(x-20)
		end
	end


	--玩家信息
	local playinfoname = data.name
	local level = data.level
	local playinfo_panel =  panelView.panel_tou
	playinfo_panel.txt_name:setString(playinfoname)
	playinfo_panel.txt_level:setString(level)
	playinfo_panel:setTouchedFunc(c_func(self.findFriendInfoData, self,data));
	local _node = playinfo_panel.ctn_1
	_node:removeAllChildren()
	local avatar = data.avatar or "101"
	local head =  data.head or "101"


	local icon = FuncUserHead.getHeadIcon(head,avatar)
    icon = FuncRes.iconHero( icon )
    local iconSprite = display.newSprite(icon)
    iconSprite:setScale(0.65)
    -- _node:addChild(iconSprite)
    local frame = data.frame or ""
    local frameicon = FuncUserHead.getHeadFramIcon(frame)
    local iconK = FuncRes.iconHero( frameicon )

    local frameSprite = display.newSprite(iconK)
    frameSprite:setScale(0.65)
    frameSprite:setPosition(cc.p(-1,2))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    headMaskSprite:setScale(0.65)
    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
    _node:addChild(spritesico)
    _node:addChild(frameSprite)



	-- ChatModel:setPlayerIcon(_node,head,avatar,0.6)
end




function RankTwoMainView:setPartnerData(view,partnerData)
	local otherData = {}--左边列表的数据
	-- local index = 1 
	local data = partnerData
	-- for i=1,#data do
	-- 	if  data[i].id == "1" then   --主角
	-- 		local isTheBattle = data[i].notInFormationFlag 
	-- 		if isTheBattle == nil or isTheBattle ==  0 then  --上阵
	-- 			table.insert(otherData,1,data[i])
	-- 		end
	-- 	else
	-- 		-- otherData[i] = data[i]
	-- 		table.insert(otherData,data[i])
	-- 	end
	-- end	

	view.UI_1:setVisible(false)

	-- dump(partnerData,"444444444444")

	local newData1 = {}
	local newData2 = {}
	local cunIndex  = nil
	for i=1,#partnerData do
		if partnerData[i].id == "0" then
			cunIndex = i
		elseif  partnerData[i].id ~= "0" then
			if cunIndex ~= nil then
				table.insert(newData2,partnerData[i])
			else
				table.insert(newData1,partnerData[i])
			end
		end
	end

	for i=1,6 do
		if not newData1[i] then
			local data = {id = "0"}
			table.insert(newData1,data)
		end
		if not newData2[i] then
			local data = {id = "0"}
			table.insert(newData2,data)
		end
	end
	local allData = {}
	for i=1,#newData1 do
		table.insert(allData,newData1[i])
	end
	for i=1,#newData2 do
		table.insert(allData,newData2[i])
	end

	local createItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(view.UI_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = allData,
            createFunc = createItemFunc,
            perNums = 3,
            offsetX = 5,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -58, width = 70, height = 58},
            perFrame = 0,
        }
    }    
    -- self.panel_1.scroll_1:cancleCacheView();
    view.scroll_1:styleFill(_scrollParams);
    view.scroll_1:hideDragBar()


end

function RankTwoMainView:cellviewData(view,partnerData)
	-- dump(partnerData,"1111111111111")
	-- local posIndex = {
	-- 	p1 = 1,
	-- 	p2 = 2,
	-- 	p3 = 3,
	-- 	p4 = 4,
	-- 	p5 = 5,
	-- 	p6 = 6,
	-- }
	-- local data = partnerData
	-- for i=1,6 do
	-- 	view["UI_"..i]:setVisible(false)
	-- end
	-- local isshowchar = true 
	-- local monsterID = nil



	-- local playinfor = nil  ---主角的数据
	-- local otherData = {}--左边列表的数据
	-- -- local index = 1 
	-- for i=1,#data do
	-- 	if  data[i].id == "1" then   --主角
	-- 		local isTheBattle = data[i].notInFormationFlag 
	-- 		if isTheBattle == nil or isTheBattle ==  0 then  --上阵
	-- 			table.insert(otherData,1,data[i])
	-- 		end
	-- 	else
	-- 		-- otherData[i] = data[i]
	-- 		table.insert(otherData,data[i])
	-- 	end
	-- end
	-- if self.arrayData.systemName == FuncRankAndcomments.SYSTEM.wonderLand then
	-- 	monsterID = FuncWonderland:getNPCByLevelID(self.arrayData.diifID) 
	-- end
		local otherData = {[1] = partnerData}
	-- for i=1,#otherData do
		local i = 1
		if otherData[i].id == "0" then
			view:setVisible(false)
			return 
		end
		-- local pos = otherData[i].pos
		-- local index = posIndex[pos]
		local _partnerId = otherData[i].id
		local _quality = otherData[i].quality or 1
		local _level = otherData[i].level or 1
		local _star = otherData[i].star or 1
		local skin = otherData[i].skin or ""
		local avatar = otherData[i].avatar or "101"
		local partnerView = view --["UI_"..index]
		partnerView:setVisible(true)
		
		if _partnerId == "1" then  --主角
			local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
	        headMaskSprite:pos(-1,0)
	        headMaskSprite:setScale(0.99)
			local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(avatar,skin)
	        _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
	        local _ctn = partnerView.ctn_1
	        _ctn:removeAllChildren()
	        _ctn:addChild(_spriteIcon)
	        _spriteIcon:scale(1.2)	
		else
			partnerView:updataUI(_partnerId,skin)
		end

		partnerView:setTouchedFunc(c_func(self.findFriendInfoData, self,self.charData));
		partnerView:setStar( _star )
		partnerView:setQulity( _quality )
		partnerView.panel_lv.txt_3:setString(tostring(_level))
	-- end
	-- if self.arrayData.systemName == FuncRankAndcomments.SYSTEM.wonderLand then
	-- 	if monsterID ~= nil then
	-- 		local index = #otherData+1
	-- 		monsterView = view["UI_1"]
	-- 		monsterView:setVisible(true)
	-- 		self:showMonster(monsterView,monsterID)
	-- 		monsterView:setTouchedFunc(c_func(self.findFriendInfoData, self,data[1]));
	-- 	end
	-- end

end

--显示怪物icon
function RankTwoMainView:showMonster(view,_partnerId)
	view:updataUI(_partnerId, nil, true)
end

function RankTwoMainView:showPlayerInfoView()


	-- if false then

	-- 	local systemname = FuncCommon.SYSTEM_NAME.LINEUP
	--     local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(systemname)
	--     if isopen then
	--         LineUpViewControler:showMainWindow({
	--             trid = self.params._id,
	--             tsec = self.params.sec or LoginControler:getServerId(),
	--             formationId = FuncTeamFormation.formation.pve,
	--         })
	--     else
	--     	 if is_sy_screening then
	--             WindowControler:showTips(FuncCommon.screeningstring);
	--         end
	--     end
	-- else
	-- 	WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve)
	-- end
end


function RankTwoMainView:findFriendInfoData(data)
	-- echo("=======查看=玩家信息=====")
	dump(data,"查看=玩家信息 ======")
	FriendViewControler:showPlayer(data.rid, data)
end



function RankTwoMainView:buttonVideo()
	echo("=======观看==level ID ====",RankAndcommentsModel.levelId)
	WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_014"))
end



function RankTwoMainView:close()
	self:startHide()
end

function RankTwoMainView:deleteMe()
	-- TODO
	RankTwoMainView.super.deleteMe(self);
end

return RankTwoMainView;
