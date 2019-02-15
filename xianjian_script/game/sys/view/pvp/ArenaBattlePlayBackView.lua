--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- 竞技场战斗回放界面

local ArenaBattlePlayBackView = class("ArenaBattlePlayBackView", UIBase)

function ArenaBattlePlayBackView:ctor(winName,_battleInfo)
    ArenaBattlePlayBackView.super.ctor(self, winName)
    self._battleInfo = _battleInfo

end

function ArenaBattlePlayBackView:loadUIComplete()
	self:registerEvent()
	self.mc_battles.currentView.panel_dianfeng:visible(false)
	-- 隐藏item
	self.panel_battle_item:setVisible(false)
    self.mc_battles:setVisible(false)
--	self:initData()
	self:setViewAlign()
--	self:pullBattleRecord()
    self:updateBattleView()
end 

function ArenaBattlePlayBackView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
end

function ArenaBattlePlayBackView:registerEvent()
	ArenaBattlePlayBackView.super.registerEvent()
    self.btn_close:setTap(c_func(self.close,self))
	-- EventControler:addEventListener(BattleEvent.BATTLEEVENT_REPLAY_GAME, self.onReplayEnd, self)
end

function ArenaBattlePlayBackView:onReplayEnd()
	--目前正在播放的战报数据
	local data = PVPModel:getCurrentReplayBattleData()
	if not data then
		return
	end
	--local result = Fight.result_win
	--if self:isUserSuccess(data) then
	--    result = Fight.result_lose
	--end
	WindowControler:showBattleWindow("ArenaBattleReplayResult")
	echo("ArenaBattlePlayBackView:onReplayEnd--------------------------------------------------")
end

function ArenaBattlePlayBackView:initData()
	self.normalBattleDatas = {}
end

-- 拉取战斗记录
function ArenaBattlePlayBackView:pullBattleRecord()
	PVPServer:pullBattleRecord(c_func(self.pullBattleRecordCallBack, self))
end

-- 拉取战斗记录回调
function ArenaBattlePlayBackView:pullBattleRecordCallBack(event)
	if event.result ~= nil then
		local serverData = event.result.data	
        self._battleInfo = event.result.data
        self:updateBattleView()
	else 
		WindowControler:showTips(GameConfig.getLanguage("#tid_pvp_001"))
	end
end
--从得到的战斗记录创建视图
function ArenaBattlePlayBackView:updateBattleView()
    local _battleInfo = self._battleInfo
    self.panel_battle_item:setVisible(false)
    if not _battleInfo then
        echo("----------没有战报信息----------")
        return 
    end
    self._scrollView = self.mc_battles.currentView.scroll_list
    self.mc_battles:setVisible(true)   
    if not _battleInfo.peakPvpBattle or table.length(_battleInfo.peakPvpBattle) <=0 then --如果没有巅峰之战

        if not _battleInfo or not _battleInfo.commonPvpBattle or table.length(_battleInfo.commonPvpBattle) <=0 then
            self.mc_battles:showFrame(3)
            return
        else
            self.mc_battles:showFrame(2)
            self._scrollView = self.mc_battles.currentView.scroll_list
        end
    else --如果有巅峰之战,则初始化视图组件
        local _, isInvalid = FuncPvp.formatPvpBattleTime(TimeControler:getServerTime() - _battleInfo.peakPvpBattle.bTime)
        if isInvalid then
            self.mc_battles:showFrame(2)
            self._scrollView = self.mc_battles.currentView.scroll_list

        else
            self:initTopBattle(_battleInfo.peakPvpBattle)
        end
        --如果没有普通PVP,则返回
        if not _battleInfo.commonPvpBattle or table.length(_battleInfo.commonPvpBattle) <=0 then
            --隐藏 我的战斗 文字
            self.mc_battles.currentView.panel_1:setVisible(false)
            return
        end      
    end

    local _data_source = {}
    if _battleInfo.commonPvpBattle then
        for _key,_value in pairs(_battleInfo.commonPvpBattle)do
            table.insert(_data_source,_value)
        end
        local sortByTime = function(a, b)
            return a.bTime > b.bTime
        end
        table.sort(_data_source,sortByTime)
    end
    
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_battle_item)
        self:initNormalBattleItem(_view,_item,_index)
        return _view
    end
    local _param1 = {
        data  = _data_source,
        createFunc = createFunc,
        offsetX =0,
        offsetY = 0,
        widthGap =0,
        heighGap =2,
        perFrame =1,
        perNums =1,
        itemRect = {x =0, y= -152,width = 836,height = 148},
    }
    self._scrollView:styleFill({_param1})
end
function ArenaBattlePlayBackView:checkShowRightView(serverData)
	if not serverData then
		self.mc_battles:showFrame(3)
		return
	end
	if not serverData.peakPvpBattle or next(serverData.peakPvpBattle)==nil then
		self.mc_battles:showFrame(2)
	else
		self.mc_battles:showFrame(1)
	end
	self.scroll_list = self.mc_battles.currentView.scroll_list
end

-- 更新巅峰之战item
function ArenaBattlePlayBackView:initTopBattle(data)
	if not data then return end
	self.panel_dianfeng = self.mc_battles.currentView.panel_dianfeng
	self.panel_dianfeng:visible(true)
	local battleData = data
    local _attackInfo = json.decode(battleData.attackerInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
    if _attackInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _attackInfo = FuncPvp.getRobotDataById(_attackInfo._id)
    end
    if _defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _defenderInfo = FuncPvp.getRobotDataById(_defenderInfo._id)
    end
	local attackerName = _attackInfo.name ~= "" and _attackInfo.name or GameConfig.getLanguage("tid_common_2001")
    local  attackerLevel = _attackInfo.level --self:getPvpPlayerNameAndLevel(json.decode(battleData.attackerInfo))
--	local defenderName, defenderLevel = self:getPvpPlayerNameAndLevel(json.decode(battleData.defenderInfo))
    local defenderName= _defenderInfo.name ~= "" and _defenderInfo.name or GameConfig.getLanguage("tid_common_2001")
    local defenderLevel = _defenderInfo.level
	-- 攻击方名字
	self.panel_dianfeng.txt_name_1:setString(attackerName)
	self.panel_dianfeng.txt_level_1:setString(attackerLevel..'级')

	-- 防守方名字
	self.panel_dianfeng.txt_name_2:setString(defenderName)
	self.panel_dianfeng.txt_level_2:setString(defenderLevel..'级')
	-- 重播战斗
	--self.panel_dianfeng.btn_1:setTap(c_func(self.replayBattle, self, battleData))
    self.panel_dianfeng.btn_1:setTap(c_func(self.clickCellButtonPVPReport, self, battleData))
end

-- 更新普通战斗item
function ArenaBattlePlayBackView:initNormalBattleItem(itemView, data, index)
    -- 隐藏分享按钮
    itemView.btn_2:setVisible(false)

	local battleData = data
	local mcView = itemView.mc_result
	local isUserSuccess = self:isUserSuccess(battleData)
	-- 如果玩家胜利
	if isUserSuccess then
		mcView:showFrame(1)
	else
		mcView:showFrame(2)
	end
	local deltaRank = math.abs(battleData.attackerRank - battleData.defenderRank)
	-- 名次变化
	mcView.currentView.txt_1:setString(deltaRank)

	local enemyUsedTreasures = {}
	local level
	local info 
    --法宝数据
    local _treasure_source = {}
    --伙伴数据
    local _partner_source = {}
    local _formation
    local _rid=UserModel:rid();
    local charPos = nil
	if UserModel:rid() == battleData.attackerId then
		local defenderInfo = json.decode(battleData.defenderInfo)
		info = defenderInfo
        _formation = defenderInfo

        --如果对方是机器人,则合成数据
        if defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            info = FuncPvp.getRobotDataById(defenderInfo._id)
            -- dump(info, "\n\ninfo==")
            charPos = info.charPos or 1
            _formation = info
            local replacedPartnerId = _formation.formation.partnerFormation["p"..charPos]
            --加一个猪脚  star quality level
            local charMainTable = {
                ["star"] = info.partners[tostring(replacedPartnerId)].star,
                ["quality"] = info.partners[tostring(replacedPartnerId)].quality,
                ["avatarId"] = info.avatar,
                ["level"] = info.level,
                ["id"] = 1,
                ["garmentId"] = info.garmentId,
            }
            table.insert(_partner_source, charMainTable)
            local key = replacedPartnerId
            _formation.partners[key] = nil
        else 
            --加一个猪脚  star quality level
            local charMainTable = {
                ["star"] = info.star,
                ["quality"] = info.quality,
                ["avatarId"] = info.avatar,
                ["level"] = info.level,
                ["id"] = 1,
            };
            table.insert(_partner_source, charMainTable)
        end

		if not isUserSuccess then
			mcView.currentView.txt_1:visible(false)
			mcView.currentView.panel_rank:visible(false)
		end
	else

		if isUserSuccess then
			mcView.currentView.txt_1:visible(false)
			mcView.currentView.panel_rank:visible(false)
		end
		-- 对方是攻击方
		local attackerInfo = json.decode(battleData.attackerInfo)
        if attackerInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            attackerInfo = FuncPvp.getRobotDataById(attackerInfo._id)
        end
		info = attackerInfo
        _formation = attackerInfo
        --加一个猪脚  star quality level
        local charMainTable = {
            ["star"] = info.star,
            ["quality"] = info.quality,
            ["avatarId"] = info.avatar,
            ["level"] = info.level,
            ["id"] = 1,
        };
        table.insert(_partner_source, charMainTable)

		-- 对方使用的法宝
		--enemyUsedTreasures = self:getUsedTreasureList(attackerInfo, treasureLists.attacker)
	end

    local name = info.name 
    if string.len(name) == 0 then 
        name = "少侠";
    end 

    local level = info.level
--	local name, level = self:getPvpPlayerNameAndLevel(info)
	--level
	itemView.txt_3:setString(level..'级')
	--name 
	itemView.txt_2:setString(name)
	
	-- 时间
	local battleTimeStr = FuncPvp.formatPvpBattleTime(TimeControler:getServerTime() - battleData.bTime)
	--local battleTimeStr = "12小时前"
	itemView.txt_4:setString(battleTimeStr)
    itemView.btn_1:setTap(c_func(self.clickCellButtonPVPReport, self, battleData))


    --集合法宝跟伙伴
    if _formation.treasures then
        for _key,_value in pairs(_formation.treasures)do
            local _temp = _value
            _temp.id = _key
            table.insert(_treasure_source, _value)
            -- 固定只能带一个法宝
            if #_treasure_source >= 1 then
                break
            end
        end
    end

    -- for k, v in pairs(_formation.formation.partnerFormation) do
    --     print(k,v)
    -- end
    if _formation.partners then
        for _key, _value in pairs(_formation.partners) do
            if _value then
                local _temp = _value
                table.insert(_partner_source, _temp)
            end            
        end
    end

    self:updateFormation(itemView, _partner_source, _treasure_source)
end
--更新伙伴,法宝的阵列
function ArenaBattlePlayBackView:updateFormation(_view,_partner_source,_treasure_source)
    --隐藏掉模板
    _view.panel_fbicon1:setVisible(false)
    _view.panel_fbiconnew:setVisible(false)
    --更新法宝图标
    local function createFunc(_item,_index)
        local _sub_view = UIBaseDef:cloneOneView(_view.panel_fbicon1)
        self:updateTreasureView(_sub_view,_item)
        return _sub_view
    end
    local _param1 = {
        data = _treasure_source,
        createFunc = createFunc,
        offsetX =0,
        offsetY =0,
        widthGap =0,
        heightGap =0,
        perFrame =1,
        perNums = 1,
        itemRect = {x =0, y = -76,width = 82, height =76},
    }
    local function createFunc2(_item,_index)
        local _sub_view = UIBaseDef:cloneOneView(_view.panel_fbiconnew)
        self:updatePartnerView(_sub_view,_item)
        return _sub_view
    end
    local _param2 = {
        data = _partner_source,
        createFunc = createFunc2,
        offsetX =0,
        offsetY =0,
        widthGap =0,
        heightGap =0,
        perFrame = 1,
        perNums =1,
        itemRect = {x=0,y = -77, width = 85,height = 77,},
    }
    _view.scroll_1:styleFill({_param1,_param2})
end
--更新法宝图标
function ArenaBattlePlayBackView:updateTreasureView(_view,_item)
    --icon
    local _item_item = FuncTreasure.getTreasureById(_item.id)
    local _iconPath = FuncRes.iconTreasureNew(_item.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:setScale(0.6)
    _view.panel_1.ctn_1:removeAllChildren()
    _view.panel_1.ctn_1:addChild(_iconSprite)
    -- TODO level
    _view.txt_3:setString(" ")
    
    _view.mc_dou:showFrame(_item.star or 1)
end

--更新伙伴图标 
function ArenaBattlePlayBackView:updatePartnerView(_view, _item)
    -- 边框颜色
    local border = tonumber(FuncChar.getBorderFramByQuality(_item.quality))

    --是主角的话
    if tonumber(_item.id) == 1 then
        local avatarId = nil
        if _item.avatarId then
            avatarId = _item.avatarId
        else
            avatarId = UserModel:avatar()..''
        end
        
        local iconSprite = FuncGarment.getGarmentIcon(_item.garmentId, tostring(avatarId))
        _view.mc_2:showFrame(border)
        _view.mc_2.currentView.ctn_1:removeAllChildren()
        iconSprite:setScale(1.1)
        _view.mc_2.currentView.ctn_1:addChild(iconSprite)
        --level
        _view.txt_3:setString(tostring(_item.level))
        --star
        _view.mc_dou:showFrame(_item.star or 1)
    else 
        local _partner_item = FuncPartner.getPartnerById(_item.id)
        --icon
        local _iconPath = FuncRes.iconHead(_partner_item.icon)
        local _iconSprite = cc.Sprite:create(_iconPath)
        _view.mc_2:showFrame(border)
        _view.mc_2.currentView.ctn_1:removeAllChildren()
        _iconSprite:setScale(1.1)
        _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
        --level
        _view.txt_3:setString(tostring(_item.level))
        --star
        _view.mc_dou:showFrame(_item.star or 1)
    end
end

--获取战报
function ArenaBattlePlayBackView:clickCellButtonPVPReport(battleData)
     --这里做版本校验判断
    if BattleControler:checkBattleVersionIsOld( battleData ) then 
        return;
    end
    PVPServer:requestPVPreport(battleData.reportId, c_func(self.onPVPReportEvent, self, battleData))
end
--返回
function ArenaBattlePlayBackView:onPVPReportEvent(originBattleData, _event)
    if _event.result ~= nil then

        local _battleData = _event.result.data.report

        local _battleDetail = json.decode(_battleData)

        if table.length(_battleDetail) == 0 then
            echo("--------------战报已过期--------------")
            return 
        end
        -- dump(_battleDetail, "----_battleDetail---");
        -- dump(originBattleData, "----originBattleData---");

        local _attackData = _battleDetail.battleUsers[1]

        local _defenderData = _battleDetail.battleUsers[2]

        --检测是否有机器人
        if _attackData.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            _attackData =FuncPvp.getRobotDataById(_attackData._id)
        end
        if _defenderData.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
            _defenderData = FuncPvp.getRobotDataById(_defenderData._id)
        end
        
        _attackData.rank = originBattleData.attackerRank;
        _defenderData.rank = originBattleData.defenderRank;


        _battleDetail.battleUsers[1] = _attackData
        _battleDetail.battleUsers[2] = _defenderData
        _battleDetail.gameMode = Fight.gameMode_pvp
		_battleDetail.battleLabel = GameVars.battleLabels.pvp
        _battleDetail.battleId = "1"    --竞技场战斗battle暂时给1
        _battleDetail.levelId = "103"


        -- dump(_defenderData, "----_defenderData----");
        -- dump(_attackData, "----_attackData----");


        -- WindowControler:showBattleWindow("ArenaBattleLoading", _defenderData, _attackData)
	    PVPModel:setCurrentReplayBattleData(_battleDetail)
	    BattleControler:replayLastGame(_battleDetail)
    else
        echo("------ArenaBattlePlayBackView:onPVPReportEvent--------",_event.error.message)
    end
end
-- 重播战斗
function ArenaBattlePlayBackView:replayBattle(battleData)
--	battleData = self:decodeBattleData(battleData)
	local battleInfo = PVPModel:composeBattleInfoForReplay(battleData)
	
    local enemyCamp = battleInfo.battleUsers[2]
	local playerCamp = battleInfo.battleUsers[1]

    dump(enemyCamp, "----enemyCamp----");
    dump(playerCamp, "----playerCamp----");


	-- WindowControler:showBattleWindow("ArenaBattleLoading", enemyCamp, playerCamp)
	PVPModel:setCurrentReplayBattleData(battleData)
	BattleControler:replayLastGame(battleInfo)
end

-- 分享视频
function ArenaBattlePlayBackView:shareVideo()
	WindowControler:showTips(GameConfig.getLanguage("#tid_pvp_002"))
end

function ArenaBattlePlayBackView:decodeBattleData(battleData)
--	local ret = {}
--	for k,v in pairs(battleData) do
--		ret[k] = json.decode(v)
--	end
--	return ret
    local   _ret = table.deep(battleData)
    --attack
    local  _attackInfo = json.decode(battleData.attackInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
end

function ArenaBattlePlayBackView:isRobot(info)
	return info.userBattleType == Fight.people_type_robot
end

function ArenaBattlePlayBackView:getPvpPlayerNameAndLevel(info)
	local name
	local level 
	if self:isRobot(info) then 
		local nameId = info.name
		level = info.lv
		name = GameConfig.getLanguage(nameId)
	else
		level = info.level
		name = info.name
	end
	if not level then level = 0 end
	return name,level
end

-- 是否是玩家胜利
function ArenaBattlePlayBackView:isUserSuccess(battleData)
	-- 玩家战斗是否成功
	local isSuccess = false

	-- 1表示成功 2表示失败
	-- 攻击方胜利
	if battleData.result == 1 then
		-- 玩家为攻击方
		if battleData.attackerId == UserModel:rid() then
			isSuccess = true
		end
	-- 防守方胜利
	else 
		-- 玩家为防守方
		if battleData.defenderId == UserModel:rid() then
			isSuccess = true
		end
	end
	return isSuccess
end

function ArenaBattlePlayBackView:getUsedTreasureList(info, usedTreasureIds)
	local t = info.treasures
	local newt = {}
	if info.userBattleType == Fight.people_type_robot then
		for _, treasure in ipairs(info.treasures) do
			newt[treasure.id] = treasure
		end
		t = newt
	else
		newt = t
	end
	local used = {}
	usedTreasureIds = usedTreasureIds or {}
	for _,id in ipairs(usedTreasureIds) do
		if string.len(id) ~= 1 and newt[id]~=nil then
			table.insert(used, newt[id])
		end
	end
	return used
end

function ArenaBattlePlayBackView:close()
    self:startHide()
end

return ArenaBattlePlayBackView
