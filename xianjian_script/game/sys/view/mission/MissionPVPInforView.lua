local MissionPVPInforView = class("MissionPVPInforView",UIBase)

function MissionPVPInforView:ctor(_window_name,_playerInfo,callback)
    MissionPVPInforView.super.ctor(self,_window_name)
    self._playerInfo = _playerInfo
    self.callback = callback
end

function MissionPVPInforView:loadUIComplete()
    self:registerEvent()
    self:updatePlayerDetail()

    -- 标题 
    self.UI_di.txt_1:setString(GameConfig.getLanguage("#tid_mission_2000"))

end



function MissionPVPInforView:registerEvent()
    MissionPVPInforView.super.registerEvent(self)
    self:registClickClose("out")
    self.UI_di.btn_close:setTap(c_func(self.closeUI,self))
    self.UI_di.mc_1:showFrame(1)
    local btn = self.UI_di.mc_1.currentView.btn_1

    btn:setTap(function (  )
        if self.callback then
            self.callback()
        end
        self:closeUI()
    end)
end
function MissionPVPInforView:closeUI( )
    self:startHide()
end

--update ui,真实玩家
function MissionPVPInforView:updatePlayerDetail()
    dump(self._playerInfo, "玩家信息---------", 6)
    local _playerInfo = self._playerInfo

    local headId = _playerInfo.head
    local frame = _playerInfo.frame
    local ctnTou = self.ctn_tou
    local avatar = _playerInfo.avatar
    UserHeadModel:setPlayerHeadAndFrame(ctnTou,avatar,headId,frame)
    

    --player name
    self.txt_name_1:setString(_playerInfo.name)
    -- 等级
    -- self.txt_lv2:setString(_playerInfo.level)
    --战力
    -- local ability = _playerInfo.ability
    -- if PVPModel:getUserRank() == _playerInfo.rank then
    --     ability = UserModel:getPvpAbility(FuncTeamFormation.formation.pvp_defend)
    -- end
    self.panel_zhanli:visible(false)
    self.UI_comp_powerNum:visible(false)
    -- 排名
    self.txt_rank_2:visible(false)
    self.txt_rank_1:visible(false)

    -- 隐藏仙盟图标和名字
    self.panel_xm:setVisible(false)
    self.txt_2:setVisible(false)

    --伙伴出战阵容
    --判断是否有阵容信息
    local treasureId = "404"
    if _playerInfo.formations and _playerInfo.formations["1"] then
        local partnerFormation = _playerInfo.formations["1"].partnerFormation
        for _index =1,6  do
            local _panel = self.panel_1["panel_fbiconnew".._index] 
            local _partnerData = partnerFormation["p".._index]
            local _partnerId = _partnerData.partner.partnerId
            echo("_partnerId ==== ",_partnerId,_index)
            if tostring(_partnerId) == "0" then
                _panel:setVisible(false)
            else
                _panel:setVisible(true)
                local skinId = ""
                if tonumber(_partnerId) == 1 then
                    _partnerId = _playerInfo.avatar
                    skinId = self:getGarmentId(  )
                else
                    skinId = self:getSkinId( _partnerId )
                end
                _panel.mc_2:showFrame(1)
                local panelCtn = _panel.mc_2.currentView.ctn_1

                local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(_partnerId,skinId)

                local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
                headMaskSprite:pos(-1,0)

                local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
                _spriteIcon:scale(1.2)
                panelCtn:removeAllChildren()
                panelCtn:addChild(_spriteIcon)
                _panel.mc_dou:visible(false)
                _panel.txt_3:visible(false)
                _panel.panel_level:visible(false)
            end
        end
        local treasureFormation = _playerInfo.formations["1"].treasureFormation
        treasureId = treasureFormation["p1"]
    else
        -- 没有 默认主角在第一个位置
        for i=2,6 do
            local _panel = self.panel_1["panel_fbiconnew"..i] 
            _panel:visible(false)
        end
        local _panel = self.panel_1["panel_fbiconnew"..1] 
        _panel:setVisible(true)
        _partnerId = _playerInfo.avatar
        _panel.mc_2:showFrame(1)
        local panelCtn = _panel.mc_2.currentView.ctn_1
        local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(_partnerId,"")
        panelCtn:removeAllChildren()
        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:pos(-1,0)

        local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
        _spriteIcon:scale(1.2)
        panelCtn:addChild(_spriteIcon)
        _panel.mc_dou:visible(false)
        _panel.txt_3:visible(false)
        _panel.panel_level:visible(false)
    end

    -- 法宝
    local _iconPath = FuncRes.iconTreasureNew(treasureId)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:setScale(0.6)
    local fbPanel = self.panel_1.panel_fbicon1
    fbPanel.panel_1.ctn_1:removeAllChildren()
    fbPanel.panel_1.ctn_1:addChild(_iconSprite)
    fbPanel.txt_3:visible(false)
    fbPanel.mc_dou:visible(false)
end

function MissionPVPInforView:getSkinId( partnerId )
    local skins = self._playerInfo.skins
    local partnerSkins = self._playerInfo.partnerSkins
    -- dump(partnerSkins, "---c---", 4)
    local onSkinId = partnerSkins[tostring(partnerId)]
    -- echo(" ---111111--- onSkinId ==  ",onSkinId,partnerId)
    if onSkinId then
        -- 判断是否过期
        if FuncGarment.garmentIsFinish( skins,onSkinId ) then
            onSkinId = ""
            -- echo(" ---222222222--- onSkinId ==  ",onSkinId)
        end
    else
        onSkinId = ""
    end

    return onSkinId
end


function MissionPVPInforView:getGarmentId(  )
    local garmentId = ""
    local _playerInfo = self._playerInfo
    if _playerInfo.userExt and _playerInfo.userExt.garmentId then
        garmentId = _playerInfo.userExt.garmentId
    end
    if FuncGarment.garmentIsFinish( _playerInfo.garments,garmentId ) then
        garmentId = FuncGarment.DefaultGarmentId
    end

    return garmentId
end

return MissionPVPInforView