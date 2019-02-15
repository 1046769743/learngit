--
--Author:      zhuguangyuan
--DateTime:    2017-12-22 11:19:27
--Description: 锁妖塔npc类型 雇佣兵 可花钱买入己方队伍
--


local TowerNpcMercenaryView = class("TowerNpcMercenaryView", UIBase);

function TowerNpcMercenaryView:ctor(winName,_isDead,npcID,npcPos)
    TowerNpcMercenaryView.super.ctor(self, winName)
    self.npcId = npcID or 1003
    self.npcPos = npcPos 
    self.isDead = _isDead
end

function TowerNpcMercenaryView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerNpcMercenaryView:registerEvent()
	TowerNpcMercenaryView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
end

function TowerNpcMercenaryView:initData()
	-- if not self.isDead then
		self.npcData = FuncTower.getNpcData(self.npcId)
		self.npcEventData = FuncTower.getNpcEvent(self.npcData.event[1])
		dump(self.npcEventData, "self.npcEventData")
		if not self.mercenaryId then
			self:randomMercenaryId()
		end
	-- end
end

function TowerNpcMercenaryView:initView()
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage(self.npcData.name))
end

function TowerNpcMercenaryView:initViewAlign()
	-- TODO
end

function TowerNpcMercenaryView:updateUI()
	if not self.isDead then
		-- self.mc_1:showFrame(1)
		local mercenaryData = ObjectCommon.getPrototypeData( "level.EnemyInfo",self.mercenaryId ) 
		local mercenaryName = GameConfig.getLanguage(mercenaryData.name)
		self.txt_1:setString(GameConfig.getLanguageWithSwap(self.npcData.des,mercenaryName))

		-- 雇佣兵气泡
		local scaleto_1 = act.scaleto(0.1,1.2,1.2)
		local scaleto_2 = act.scaleto(0.05,1.0,1.0)
		local delaytime_2 = act.delaytime(2.5)
			local scaleto_3 = act.scaleto(0.1,0)
			local delaytime_3 = act.delaytime(0.5)
			local callfun = act.callfunc(function ()
				self.panel_qipao.txt_1:setString(GameConfig.getLanguage(self.npcData.qipao1[1]))
			end)
		local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
		self.panel_qipao:runAction(act._repeat(seqAct))

		-- local spineData = FuncTreasure.getSourceDataById(mercenaryData.baseTrea)
		-- local mercenaryMonster = mercenaryData.baseTrea
		-- monsterData = ObjectCommon.getPrototypeData( "level.EnemyInfo",mercenaryMonster )
		local spineName = FuncTreasure.getSourceDataById(self.npcData.spine)
		dump(spineName, "desciption")
		local npcSpine = FuncRes.getArtSpineAni(spineName.spine)--monsterData.baseTrea)
		-- npcSpine:setPositionY(0)
		-- npcSpine:gotoAndStop(1)
		self.ctn_ren:addChild(npcSpine)

		local mercenaryPrice = self.npcEventData.cost
		-- dump(mercenaryPrice, "雇佣兵的价格 mercenaryPrice")
		local moneyArr = string.split(mercenaryPrice[1],",")
		echo("________moneyType____________",moneyArr[1])
		local moneyType = tostring(moneyArr[1])
		local needNum = tonumber(moneyArr[2])
		local moneyIcon = display.newSprite(FuncRes.iconRes(moneyType))
		moneyIcon:scale(0.5)
		moneyIcon:setPositionX(-10)
		self.ctn_b:addChild(moneyIcon)
		self.txt_2:setString(moneyArr[2])
		self.btn_1:setTouchedFunc(c_func(self.buyTheMercenary,self,needNum))
		self.btn_2:setTouchedFunc(c_func(self.bypassMercenary,self))
	-- else
	-- 	self.mc_1:showFrame(2)
	-- 	self.panel_qipao.txt_1:setString(GameConfig.getLanguage(self.npcData.qipao2[1]))
	-- 	self.btn_1:setTouchedFunc(c_func(self.press_btn_close,self))
	end
end

function TowerNpcMercenaryView:buyTheMercenary(needNum)
	if UserModel:tryCost(FuncDataResource.RES_TYPE.DIMENSITY, needNum, true) then
		local params = {
			-- eventId = self.npcId,
			x = self.npcPos.x,
			y = self.npcPos.y,
			employeeId = self.mercenaryId,
		}
		TowerServer:employMercenary(params,c_func(self.buyMercenaryCallback,self))
	end
end

function TowerNpcMercenaryView:bypassMercenary()
	local params = {
		x = self.npcPos.x,
		y = self.npcPos.y,
	}
	TowerServer:byPassLocation(params,c_func(self.byPassCallback,self))
end

function TowerNpcMercenaryView:byPassCallback(event)
	if event.error then
		-- WindowControler:showTips("绕过道具失败")
	else
		dump(event.result.data, "绕过雇佣兵服务器返回")
		local passItemData ={
			itemId=self.itemId,
			x = self.npcPos.x,
			y = self.npcPos.y,
		}
		TowerMainModel:updateData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_SKIP_MONSTER,passItemData)
		self:startHide()
	end	
end

function TowerNpcMercenaryView:randomMercenaryId()
	local mercenaryList = self.npcEventData.parameter
	dump(mercenaryList, "mercenaryList")

	local weightArr = {}
	local mercenaryArr = {}
	for k,v in ipairs(mercenaryList) do
		local tempArr = string.split(v,",")
		weightArr[#weightArr + 1] = tonumber(tempArr[1])
		mercenaryArr[#mercenaryArr + 1] = tonumber(tempArr[2])
	end
	local index1 = RandomControl.getOneIndexByGroup( weightArr )
	self.mercenaryId = mercenaryArr[index1]

	-- self.mercenaryId = string.split(mercenaryList[1],",")[1]
	echo("________随机到的雇佣兵id self.mercenaryId ________",self.mercenaryId)
end
function TowerNpcMercenaryView:buyMercenaryCallback( event )
	if event.error then 
		 WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_051"))
	else
		local mercenaryData = ObjectCommon.getPrototypeData( "level.EnemyInfo",self.mercenaryId ) 
		local mercenaryName = GameConfig.getLanguage(mercenaryData.name)
		local txt = mercenaryName..GameConfig.getLanguage("#tid_tower_ui_052")
		WindowControler:showTips( { text = txt } )
		TowerMainModel:updateData(event.result.data)
		-- self:updateUI()
		-- TowerMainModel:saveMercenaryId(self.mercenaryId)
	end
	self:startHide()
end



function TowerNpcMercenaryView:press_btn_close()
	self:startHide()
end

function TowerNpcMercenaryView:deleteMe()
-- TODO
	TowerNpcMercenaryView.super.deleteMe(self);
end


return TowerNpcMercenaryView;
