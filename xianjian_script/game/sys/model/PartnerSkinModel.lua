--
--
--

local PartnerSkinModel = class("PartnerSkinModel", BaseModel);
function PartnerSkinModel:init(data)
    PartnerSkinModel.super.init(self, data)
    dump(data, "奇侠皮肤", nesting)
    self.hisData ={}
    table.deepMerge(self.hisData,data)
    self.skinInfos = data or {}
    if table.length(self.skinInfos) > 0 then
        for k,v in pairs(self.skinInfos) do
            if tonumber(v) ~= -1 and (tonumber(v) == 0 or TimeControler:getServerTime() - tonumber(v) > 0)  then
                self.skinInfos[k] = nil
            end
        end
    end
    EventControler:addEventListener(PartnerSkinEvent.SKIN_FRINED_SHOW_EVENT, 
        self.showUI, self);    
end
function PartnerSkinModel:showUI(params)
    local skinId = params.params.id

    WindowControler:showWindow("PartnerSkinShowView", skinId,"see");
end
function PartnerSkinModel:updateData(data)
    table.deepMerge(self.hisData,data)
    PartnerSkinModel.super.updateData(self, data)
    for i,v in pairs(data) do
        self.skinInfos[i] = v
    end
    -- dump(data,"发过来的数据")
    -- dump(self.skinInfos,"更新后的数据")

end

function PartnerSkinModel:getEnableSkins()
    return self.skinInfos
end
-- 对带皮肤伙伴进行排序 
function PartnerSkinModel:getPartnerSort()
    local allSkinPartners = {}
    local allPartners = PartnerModel:getAllPartner()
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    for i,v in pairs(allPartners) do
        if partnerSkinT[tostring(v.id)] then
            table.insert(allSkinPartners,v)
        end
    end
    --对伙伴排序
    if table.length(allSkinPartners) > 0 then
        table.sort(allSkinPartners,c_func(PartnerModel.partner_table_sort,PartnerModel))
    end

    return allSkinPartners
end

-- 通过伙伴ID 获得该伙伴所以皮肤数据
function PartnerSkinModel:getAllSkinByPartnerId(partnerId)
    partnerId = tostring(partnerId)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local allData = partnerSkinT[partnerId]
    local data = {}
    for k,v in pairs(allData) do
        local skinInfo = FuncPartnerSkin.getPartnerSkinById(tostring(v))
        if skinInfo.isOpen == nil or (skinInfo.isOpen and skinInfo.isOpen ~= "0") then
            table.insert(data, v)
        end
    end
    local haveData = PartnerSkinModel:getSkinsByPartnerId(partnerId)
    --  现在 showOrder 有空的情况
    -- 排序 按照showOrder
    local skin_sort = function (a,b)
        -- local isOwn1 = self:isOwnOrNot(a);
        -- local isOwn2 = self:isOwnOrNot(b);
        -- isOwn1 = isOwn1 == true and 1 or 0;
        -- isOwn2 = isOwn2 == true and 1 or 0;

        -- if isOwn1 > isOwn2 then 
        --     return true;
        -- elseif isOwn1 == isOwn2 then 
            local dataA = FuncPartnerSkin.getPartnerSkinById(a)
            local dataB = FuncPartnerSkin.getPartnerSkinById(b)

            if tonumber(dataA.showOrder) < tonumber(dataB.showOrder) then 
                return true  
            else 
                return false;
            end 

        -- else 
        --     return false;
        -- end 
    end
    table.sort(data,skin_sort)
    -- echo("伙伴 ID === ",partnerId)
    -- dump(data,"伙伴皮肤信息")
    return data
end

-- 是不是正在穿戴中
function PartnerSkinModel:isOn(partnerId, id)
    if PartnerModel:isHavedPatnner(partnerId) then
        local onPartnerSkin = self:getOnPartnerSkin(partnerId)

        if tonumber(onPartnerSkin) == tonumber(id) then
            return true
        else
            return false
        end
    else
        return false
    end 
end

-- 判断是否拥有
function PartnerSkinModel:isOwnOrNot(id)
    if FuncPartnerSkin.isSuYanSkinById(id) then
        return true
    end
    
    if self.skinInfos[id] then
        return true
    else
        return false
    end
end
-- 通过伙伴ID 获得该伙伴拥有的皮肤(即已激活属性的皮肤)
function PartnerSkinModel:getSkinsByPartnerId(partnerId)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        local skins = {}
        for i,v in pairs(data) do
            if self.skinInfos[v] then
                table.insert(skins,v)
            end
        end
    
        return skins
    else
        return nil
    end
    
end

function PartnerSkinModel:getPartenrHisSkins(partnerId)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        local skins = {}
        for i,v in pairs(data) do
            if self.hisData[v] then
                table.insert(skins,v)
            end
        end
    
        return skins
    else
        return nil
    end
end

-- 通过伙伴ID 获得伙伴皮肤
function PartnerSkinModel:getSkinSourceId(partnerId)
    -- 判断是否 有皮肤
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        local skinId = PartnerSkinModel:getDefaltSkinByPartnerId(partnerId)
        local skinData = FuncPartnerSkin.getPartnerSkinById(skinId)
        return skinData.sourceID
    else
        local partnerData = FuncPartner.getPartnerById(partnerId)
        return partnerData.sourceld
    end
end
-- 通过伙伴ID 获得该伙伴默认显示皮肤
function PartnerSkinModel:getDefaltSkinByPartnerId(partnerId)
    -- 默认显示穿戴中的
    local partnerData = PartnerModel:getPartnerDataById(partnerId)
    if partnerData.skin ~= "" then
        return partnerData.skin
    else
        -- 素颜皮肤
        return PartnerSkinModel:getSuYanSkinId(partnerId)
    end
end
-- 取 伙伴素颜皮肤ID
function PartnerSkinModel:getSuYanSkinId(partnerId)
    local allSkin = PartnerSkinModel:getAllSkinByPartnerId(partnerId)
    for i,v in pairs(allSkin) do
        local skinLihui = FuncPartnerSkin.getValueByKey(v,"type") 
        if skinLihui == 1 then
            return v
        end
    end
        
    echoWarn("没找到素颜皮肤，去对表  partnerid ==== "..partnerId)
    return "1"   
end

-- 获得正在穿的皮肤
function PartnerSkinModel:getOnPartnerSkin(partnerId)
    local ownSkins = self:getSkinsByPartnerId(partnerId)
    if ownSkins == nil then
        return self:getDefaltSkinByPartnerId(partnerId)
    else
        for i,v in ipairs(ownSkins) do
            if self:getSkinStage(partnerId, v) == 1 then
                return v
            end
        end
    end
    return self:getDefaltSkinByPartnerId(partnerId)
end
--给 伙伴ID 和 皮肤ID 判断皮肤状态 
-- 返回参数  皮肤状态 1穿戴中 2穿戴 3购买 4限时 5预售 6解锁 7活动获取 8未拥有奇侠
function PartnerSkinModel:getSkinStage(partnerId,skinId)
    --未拥有奇侠 但可能拥有皮肤 所以调用该方法时需要先判断是否拥有该皮肤
    if not PartnerModel:isHavedPatnner(partnerId) then
        return 8
    end
    -- 判断是否已拥有
    local partnerData = PartnerModel:getPartnerDataById(partnerId)
    if self.skinInfos[skinId] then -- 已拥有
        local skinZT = tonumber(self.skinInfos[skinId])
        -- 判断是否是 穿戴状态
        
        if partnerData.skin == skinId then -- 穿戴中
            return 1
        else
            --  是否是限时皮肤
            if skinZT == -1 then 
                return 2 --永久
            else
                return 4 --限时
            end
        end
        
    else  -- 未拥有

        -- 首先判断是否是 素颜皮肤
        if FuncPartnerSkin.getValueByKey( skinId,"type") == 1 then
            -- 判断是否穿戴中
            if partnerData.skin == "" then
                return 1
            else
                return 2
            end
        end
        -- 判断是购买还是活动 或者 预售
        local skinCfg = FuncPartnerSkin.getPartnerSkinById(skinId)
        if skinCfg.activityId then
            return 7
        end
        -- if skinCfg.activityId then -- 活动获取
        --     return 7
        -- elseif tonumber(skinCfg.isOpen) == 0 then -- 预售
        --     return 5
        -- elseif skinCfg.condition then  -- 条件购买
        --     -- 判断条件是否满足
        --     local isTrue = true
        --     for i,v in pairs(skinCfg.condition) do
        --         local condition = string.split(v,",")
        --         if tonumber(condition[1]) == 1 then -- 等级
        --             if tonumber(condition[2]) > partnerData.level then
        --                 isTrue = false 
        --                 break
        --             end
        --         elseif tonumber(condition[1]) == 2 then -- 星级
        --             if tonumber(condition[2]) > partnerData.star then
        --                 isTrue = false
        --                 break
        --             end
        --         elseif tonumber(condition[1]) == 3 then --品质
        --             if tonumber(condition[2]) > partnerData.quality then
        --                 isTrue = false
        --                 break
        --             end
        --         end
        --     end
        --     if isTrue then
        --         return 3
        --     else    
        --         return 6
        --     end
            
            
        -- else  -- 购买
            return 3
        -- end
    end
end

return PartnerSkinModel;





















