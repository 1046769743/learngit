
--竞技场挑战5次
--2017-1-14 10:14:38
--@Author:xiaohuaxiong
local ArenaChallenge5View = class("ArenaChallenge5View",UIBase)
--角色自己的信息,
--对手的信息
--战斗的结果(5次)
function ArenaChallenge5View:ctor(_window_name,_playerInfo,_enemyInfo,_result_array)
    ArenaChallenge5View.super.ctor(self,_window_name) 
    self._playInfo = _playerInfo
    self._playInfo.garmentId = GarmentModel:getOnGarmentId()
    self._enemyInfo = _enemyInfo  

    if tostring(self._enemyInfo.types) == "2" and self._enemyInfo.star == nil then
        self:initRobotData(self._enemyInfo)
    end
    self._resultInfo = _result_array
    self._dataSource = {}
    self._dataSource[1] = _result_array[1]
end
--
function ArenaChallenge5View:loadUIComplete()
    self.UI_di.txt_1:setString(GameConfig.getLanguage("#tid_pvp_004")) 
    self:registerEvent()
    self:updateChallengeView()
end
--
function ArenaChallenge5View:registerEvent()
    ArenaChallenge5View.super.registerEvent(self)
    self:registClickClose("out")
    self.UI_di.btn_close:setTap(c_func(self.clickButtonClose,self))
    self.UI_di.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonClose,self))
end

function ArenaChallenge5View:clickButtonClose()
    self:startHide()
end

function ArenaChallenge5View:startHide()
    ArenaChallenge5View.super.startHide(self)
end


function ArenaChallenge5View:initRobotData(_enemyInfo)
    local robotData = FuncPvp.getRobotDataById(_enemyInfo.rid_back)
    local _partnerId = robotData.formation.partnerFormation["p".._enemyInfo.charPos]
    self._enemyInfo.quality = robotData.partners[_partnerId].quality
    self._enemyInfo.star = robotData.partners[_partnerId].star
    -- self._enemyInfo.garmentId = robotData.garmentId
end

function ArenaChallenge5View:updateChallengeView()
    self.panel_1:setVisible(false)
    local _data_source = self._dataSource
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateChallengeItemView(_view,_index)
        return _view
    end
    local function updateCellFunc(_item,_view,_index)
        self:updateChallengeItemView(_view,_index)
    end
    local _param = {
        data = _data_source,
        createFunc = createFunc,
  --      updateCellFunc = updateCellFunc,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap =0,
        perNums =1,
        perFrame =1,
        itemRect = {x =0,y = -138, width = 418,height = 138,},
    }
    self.scroll_1:styleFill({_param})
    self.scroll_1:gotoTargetPos(#_data_source,1,0,0.4)
    self:onGenStep()
end

--逐步生成组件
function ArenaChallenge5View:onGenStep()
    if #self._dataSource< #self._resultInfo then
        table.insert(self._dataSource,self._resultInfo[#self._dataSource+1])
        self:delayCall(c_func(self.updateChallengeView,self),0.5)
    end
end

--更新结果
function ArenaChallenge5View:updateChallengeItemView(_view,_index)
    --第N回
    _view.txt_1:setString(GameConfig.getLanguage("pvp_challenge_times_1005"):format(_index))
    --self
    self:updatePlayer(_view.panel_fbiconnew2,self._playInfo)
    --enemy
    self:updatePlayer(_view.panel_fbiconnew,self._enemyInfo)
    --win of failed
    self.UI_di.mc_1:showFrame(self._resultInfo[_index])
end

--更新角色信息
function ArenaChallenge5View:updatePlayer(_view,_playerInfo)
    --品质
    local border = tonumber(FuncChar.getBorderFramByQuality(_playerInfo.quality))
    _view.mc_2:showFrame(border or 1)
    --icon
    local _char_item = FuncChar.getHeroData(_playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_char_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    if _playerInfo.garmentId then
        _iconSprite = FuncGarment.getGarmentIcon(_playerInfo.garmentId, _playerInfo.avatar)
    end
    _iconSprite:setScale(1.1)
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --star
    _view.mc_dou:showFrame(_playerInfo.star or 1)
    --level
    _view.txt_3:setString(tostring(_playerInfo.level))
end

return ArenaChallenge5View