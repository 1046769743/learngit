-- RankMainView
--[[
	Author: wk
	Date:2018-01-15
]]

local RankMainView = class("RankMainView", UIBase);

function RankMainView:ctor(winName)
    RankMainView.super.ctor(self, winName)
end

function RankMainView:loadUIComplete()
	self:registerEvent()
	-- self.panel_1.btn_1:setTouchedFunc(c_func(self.close, self))
	self.panel_di:setVisible(false)
	self.panel_1:setVisible(false)
	self.panel_1.panel_1:setVisible(false)
	self.panel_1.panel_2:setVisible(false)
	self.txt_1:setVisible(false)
end 


function RankMainView:clickClose()
	-- self:registClickClose("out")

	self.panel_di.btn_1:setTouchedFunc(c_func(self.close, self))
	-- self.panel_di.mc_1:setVisible(false) 
	self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_newRank_012"))
	self.panel_di:setVisible(true)
end


function RankMainView:registerEvent()
	RankMainView.super.registerEvent(self);
	self:registClickClose("out")
end

function RankMainView:initData(arrayData,rankInfo)
	self.panel_1:setVisible(true)
	self.panel_1.panel_1:setVisible(true)
	self.panel_1.panel_2:setVisible(true)
	self.allData = rankInfo or RankAndcommentsModel:getAllRankInfoData()

	self.arrayData = arrayData
	-- local isshow = FuncRankAndcomments.showStarBySystemName(arrayData.systemName)

	-- self.panel_1.panel_name.panel_star_1:setVisible(isshow)

	-- dump(self.allData,"=======0000000000======")

	if self.allData == nil or #self.allData == 0  then
		self.panel_1:setVisible(false)
		self.txt_1:setVisible(true)
		self.txt_1:setString(GameConfig.getLanguage("#tid_newRank_013")) 
	end
			--战力最低的数据
	self:downViewInitData(self.allData)
	self:upViewInitData(self.allData)

	
end

function RankMainView:downViewInitData(data)

	data = data[1]
	local panel = self.panel_1.panel_1
	if data ~= nil then
		-- self.downplayData = data[1]
		for k,v in pairs(data) do
			if v.id == "1" then
				self.downplayData = v
			end
		end

		if not self.downplayData then
			self.downplayData = RankAndcommentsModel:getPlayInfoMinAbilityData()
		end
		self:setplayerData(panel,self.downplayData)
		-- self:setPartnerData(panel,data) --暂时用'

		self:setScrollData(panel,data)

		panel.btn_guankan:setTouchedFunc(c_func(self.buttonVideo, self));
	else
		panel.btn_guankan:setVisible(false)
		panel.panel_tou:setVisible(false)
		self.panel_1.panel_1:setVisible(false)
	end

end
function RankMainView:upViewInitData(data)
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
		-- self.charData
		-- self:setPartnerData(panel,data) --暂时用
		self:setScrollData(panel,data)
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

function RankMainView:setplayerData(view,data)
	local panelView = view
	-- dump(data,"排行数据=====")
	self.charData = data
	if panelView.panel_power ~= nil then
		--战力
		local ability  = data.num or 0
		panelView.panel_power.UI_number:setPower(ability)
	end

	-- 出手次数
	if panelView.mc_17 ~= nil then
		local items = data.num or 0

		panelView.mc_17:showFrame(1)
		local numUI =  panelView.mc_17:getViewByFrame(1).UI_number
		local panel_x = panelView.mc_17:getViewByFrame(1).panel_x

		numUI:setPower(items)
		local strItem = tostring(items)  
		local num  = string.len(strItem)
	
		local x =  panel_x:getPositionX()
		panel_x:setPositionX(x+ 20 * num)
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
    iconSprite:setScale(0.85)
    -- _node:addChild(iconSprite)
    local frame = data.frame or ""
    local frameicon = FuncUserHead.getHeadFramIcon(frame)
    local iconK = FuncRes.iconHero( frameicon )

    local frameSprite = display.newSprite(iconK)
    frameSprite:setScale(0.85)
    frameSprite:setPosition(cc.p(-1,2))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    headMaskSprite:setScale(0.85)
    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
    _node:addChild(spritesico)
    _node:addChild(frameSprite)



	-- ChatModel:setPlayerIcon(_node,head,avatar,0.6)
end



function RankMainView:setScrollData(view,partnerData)
	local otherData = {}
	local data = partnerData


	-- --dump(partnerData,"44444444444444444")
	-- for i=1,#data do
	-- 	if  data[i].id == "1" then   --主角
	-- 		local isTheBattle = data[i].notInFormationFlag 
	-- 		if isTheBattle == nil or isTheBattle ==  0 then  --上阵
	-- 			table.insert(otherData,1,data[i])
	-- 		end
	-- 	else
	-- 		table.insert(otherData,data[i])
	-- 	end
	-- end

	view.UI_1:setVisible(false)
	local createItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(view.UI_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = partnerData,
            createFunc = createItemFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -80, width = 80, height = 80},
            perFrame = 0,
        }
    }    
    -- self.panel_1.scroll_1:cancleCacheView();
    view.scroll_1:styleFill(_scrollParams);
    view.scroll_1:hideDragBar()
end









function RankMainView:cellviewData(view,partnerData)
	-- dump(partnerData,"1111111111111===========")
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
	local i = 1

	if otherData[i].id == "0" then
		view:setVisible(false)
		return 
	end
	-- for i=1,#otherData do
		-- local pos = otherData[i].pos
		local index = i ---posIndex[i]
		local _partnerId = otherData[i].id
		local _quality = otherData[i].quality or 1
		local _level = otherData[i].level or 1
		local _star = otherData[i].star or 1
		local skin = otherData[i].skin or ""
		local avatar = otherData[i].avatar or "101"
		local partnerView = view--["UI_"..index]
		partnerView:setVisible(true)
		-- partnerView:setTouchedFunc(c_func(self.findFriendInfoData, self,data[1]));
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
function RankMainView:showMonster(view,_partnerId)
	view:updataUI(_partnerId, nil, true)
end


function RankMainView:findFriendInfoData(data)

dump(data,"222222222222")
	FriendViewControler:showPlayer(data.rid, data)
end



function RankMainView:buttonVideo()
	echo("=======观看==level ID ====",RankAndcommentsModel.levelId)
	WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_014"))
end



function RankMainView:close()
	self:startHide()
end

function RankMainView:deleteMe()
	-- TODO
	RankMainView.super.deleteMe(self);
end

return RankMainView;
