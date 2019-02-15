-- 伙伴系统
-- 2016-12-6 15:38:32
-- Author:狄建彬
-- 注意,在以下的函数中,如果只需要传入一个参数的,可以直接传入相关参数
-- 如果需要传入多个参数的,需要在外部自己填写相关的数据结构,然后吧参数传入
local PartnerServer = class("PartnerServer")

function PartnerServer:init()

end
-- 获取所有的伙伴
-- function PartnerServer:getAllPartners( )

-- end
-- 伙伴合成
function PartnerServer:partnerCombineRequest(_partnerId, _funcCall)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_combine_4201, _funcCall);
    -- local cbData = PartnerModel:getPartnerCombineCallBackData(_partnerId)
    -- Server:updateBaseData(cbData)
    -- _funcCall(_partnerId)
end
-- 伙伴升级
function PartnerServer:levelupRequest(_param, _funcCall)
    Server:sendRequest(_param, MethodCode.partner_equipment_levelup_4203, _funcCall)
--    local cbData = PartnerModel:getUpLevelCallBackData(_param)
--    Server:updateBaseData(cbData) 
--    _funcCall() 
end
-- 伙伴升星
function PartnerServer:starLevelupRequest(_partnerId, _funcCall)
    -- local cbData = PartnerModel:getUpStarCallBackData(_partnerId)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_star_leveup_4205, _funcCall)
    -- Server:updateBaseData(cbData) 
--    _funcCall() 
end
-- 伙伴升品
function PartnerServer:qualityLevelupRequest(_partnerId, _callFunc,data)
    Server:sendRequest( { partnerId = _partnerId }, MethodCode.partner_quality_levelup_4207, _callFunc)
--     local cbData = PartnerModel:getQualityCombineCallBackData(data)
--     Server:updateBaseData(cbData) 
-- --    _callFunc()
end
-- 伙伴技能升级
function PartnerServer:skillLevelupRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.partner_skill_levelup_4209, _callFunc)
    -- local cbData = PartnerModel:getUpSkillCallBackData(_param)
    -- Server:updateBaseData(cbData) 

--    _callFunc() -- 这个暂时先注掉
end
-- 仙魂升级
function PartnerServer:soulLevelupRequest(_param, _callFunc)
    -- Server:sendRequest(_param, MethodCode.partner_soul_levelup_4211, _callFunc, nil, nil, true)
end
-- 碎片兑换
function PartnerServer:fragExchangeRequest(_param, _callFunc)
    dump(_param,"—————碎片兑换-----")
    Server:sendRequest(_param, MethodCode.partner_fragment_exchange_4217, nil, true, true, true)
    local cbData = PartnerModel:getWanNengSuiPianCallBackData(_param)
    Server:updateBaseData(cbData) 
--    _callFunc()
end
-- 升品道具合成
function PartnerServer:qualityItemLevelupRequest(_itemId, _callFunc)
    ItemServer:composeItemPieces(_itemId, 1, _callFunc)
--    Server:sendRequest( { itemId = _itemId }, MethodCode.partner_quality_item_combine_4219, nil, true, true, true)
--    local cbData = PartnerModel:getQualityItemCombineCallBackData(_itemId)
--    Server:updateBaseData(cbData) 
--    _callFunc()
end
-- 升品道具装备
function PartnerServer:qualityItemEquipRequest(_param, _callFunc,_item)
    Server:sendRequest( _param, MethodCode.partner_quality_item_equip_4213, _callFunc)
    -- _param["_item"] = _item
    -- local cbData = PartnerModel:getQualityItemUsedCallBackData(_param)
    -- Server:updateBaseData(cbData) 
    -- _callFunc()
end
-- 技能点购买
function PartnerServer:skillPointBuyrequest(_callFunc)
    Server:sendRequest( { }, MethodCode.partner_skill_point_buy_4215, nil, true, true, true)
    local cbData = PartnerModel:getBuySkillCallBackData()
    Server:updateBaseData(cbData) 
    _callFunc()
end
-- 伙伴装备升级 
function PartnerServer:equipUpgradeRequest(_param, _callFunc)
    Server:sendRequest( _param, MethodCode.partner_equipment_upgrade_4221, _callFunc)
    -- local cbData = PartnerModel:getEquipUpLevelCallBackData(_param)
    -- Server:updateBaseData(cbData) 
    -- _callFunc()
end
function PartnerServer:equipAwakeRequest(_param, _callFunc)
    Server:sendRequest( _param, MethodCode.partner_equipment_awake_4223 , _callFunc)
end
-- function PartnerServer:equipAwakeRequest(_param, _callFunc)
--     Server:sendRequest( _param, MethodCode.partner_equipment_awake_4223 , _callFunc)
-- end


return PartnerServer;