--[[
	guan
	2017.2.27
]]

FuncGarment = FuncGarment or {}

local build = nil
FuncGarment.DefaultGarmentId = "100" --

function FuncGarment.init()
	garment = Tool:configRequire("garment.Garment");
end

function FuncGarment.isDefaultGarmentId(id )
    if not id  or id == "" or  id == FuncGarment.DefaultGarmentId then
        return true
    end
    return false
end



function FuncGarment.getGarment()
	return garment;
end
function FuncGarment.getValueByKeyFromBiao(id1, id2, key)
    local t1 = garment[tostring(id1)];
    if t1 == nil then 
        echoError("FuncGarment.getValueByKey id1 not found " , id1);
        return nil;
    end 

    local t2 = t1[tostring(id2)];
    if t2 == nil then 
        echoError("FuncGarment.getValueByKey id2 not found " , id2);
        return nil;
    end 

    local value = t2[tostring(key)]


    if value == nil then 
        echo("FuncGarment.getValueByKey key not found " , key);
        return nil;
    end 

    return value;
end
function FuncGarment.getValueByKey(id1, id2, key)
	if (not id1) or (id1 == "") or (id1 == "nil") then
        echo("00000000000------------00000000000")
        id1 = FuncGarment.DefaultGarmentId
    end
    if id2 == nil then
        echoError("主角性别 未负值 默认使用 101  " , id2);
        id2 = "101"
    end
    return FuncGarment.getValueByKeyFromBiao(id1, id2, key)
end

function FuncGarment.getStoryStr(id,_sex)
	local avatarId = _sex or UserModel:avatar();

	local tid = FuncGarment.getValueByKey(id, avatarId, "desTranslate");
	local str = GameConfig.getLanguage(tid);

	return str;
end

function FuncGarment.getGarmentName(id,_sex)
	local avatarId = _sex or UserModel:avatar();

	local tid = FuncGarment.getValueByKey(id, avatarId, "name");
	local str = GameConfig.getLanguage(tid);

	return str;
end

function FuncGarment.getGarmentOrder(id)
	local avatarId = UserModel:avatar();

	local order = FuncGarment.getValueByKey(id, avatarId, "showOrder");

	return order;
end


function FuncGarment.getGarmentdesGetWay(id)
	local avatarId = UserModel:avatar();

	local tid = FuncGarment.getValueByKey(id, avatarId, "desGetWay");
	local str = GameConfig.getLanguage(tid);

	return str;
end

function FuncGarment.getGarmentSource(id, avatarId)
	if id == "" or not id  then
        id = FuncGarment.DefaultGarmentId
    end

	local sourceId = FuncGarment.getValueByKey(id, avatarId, "sourceId");

	return sourceId;
end

function FuncGarment.getGarmentTreasure(id, avatarId)
    if id == "" then
        id = FuncGarment.DefaultGarmentId
    end
	local sourceId = FuncGarment.getValueByKey(id, avatarId, "treasureId");

	return sourceId;
end

function FuncGarment.getGarmentIsOpen(id)
	local avatarId = UserModel:avatar();

	local isOpen = FuncGarment.getValueByKey(id, avatarId, "isOpen");

	if isOpen == nil then 
		return true;
	else 
		return false;
	end 
end


-- 通过时装ID 和 avatara 获取时装头像icon
-- 奇侠系统
function FuncGarment.getGarmentIcon( garmentId,avatar )
    if garmentId == "" or not garmentId then
        garmentId = FuncGarment.DefaultGarmentId   
    end
    local iconName = FuncGarment.getValueByKey(garmentId, avatar, "iconId");
    local iconPath = FuncRes.iconHero( iconName )--FuncRes.iconGarment(iconName)
    echo("#############  头像路路径为=== ",iconPath)
    local iconSp = display.newSprite(iconPath);

    return iconSp
end

-- 时装系统显示头像
function FuncGarment.getGarmentIconSp(id)
	local avatarId = UserModel:avatar();
	local iconName = FuncGarment.getValueByKey(id, avatarId, "icon");
    local iconPath = FuncRes.iconHero( iconName )--FuncRes.iconGarment(iconName)
    local iconSp = display.newSprite(iconPath);

	return iconSp;
end
function FuncGarment.getGarmentSpinName(id ,_sex)
	if id == nil or id == "" then
		id = FuncGarment.DefaultGarmentId
	end
	
 	local avatarId = _sex or UserModel:avatar();
	local iconName = FuncGarment.getValueByKey(id, avatarId, "gramentImg");
	return iconName
end
function FuncGarment.getGarmentArtSp(id ,_sex)
	local avatarId = _sex or UserModel:avatar();
    if not id or id == "" then
        id = FuncGarment.DefaultGarmentId
    end
	local iconName = FuncGarment.getValueByKey(id, avatarId, "gramentImg");


	local sp = FuncRes.getArtSpineAni(iconName)
	return sp;
end

--[[
"<var>" = {
    1 = {
        "k" = 7
        "t" = "24"
        "v" = 100
    }
    2 = {
        "k" = 30
        "t" = "24"
        "v" = 400
    }
    3 = {
        "k" = -1
        "t" = "24"
        "v" = 500
    }
}

]]
function FuncGarment.getGarmentCost(id)
	local avatarId = UserModel:avatar();
	local cost = FuncGarment.getValueByKey(id, avatarId, "cost");
	return cost;
end

function FuncGarment.getPermanentGarmentCost(id)
    local avatarId = UserModel:avatar();
    local cost = FuncGarment.getValueByKey(id, avatarId, "cost");
    for k,v in ipairs(cost) do
        if v["k"] == -1 then
            return v["v"]
        end
    end
    return 0
end

function FuncGarment.getRank(id)
	local avatarId = UserModel:avatar();
	local rank = FuncGarment.getValueByKey(id, avatarId, "rank");
	return rank;
end

function FuncGarment.getCondition(id)
	local avatarId = UserModel:avatar();
	local condition = FuncGarment.getValueByKey(id, avatarId, "condition");
	return condition;
end

function FuncGarment.getOpen(id)
	local avatarId = UserModel:avatar();
	local open = FuncGarment.getValueByKey(id, avatarId, "open");
	if open == nil then 
		return nil
	else 
		return string.split(open, ";");
	end 
end

function FuncGarment.getActivity(id, avatar)
    local avatarId = avatar
    local activityld = FuncGarment.getValueByKey(id, avatarId, "activityld")
    return activityld
end

--[[
	ret = {
		1 = {},
		2 = {},
		3 = {}
	}
]]
function FuncGarment.getAllGarmentByAvatar(avatar)
	local retArray = {}
	for k, v in pairs(garment) do
		local value = v[tostring(avatar)];
        retArray[k] = value        		
	end
	return retArray;
end
function FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId,iswhole,data)
    if (not garmentId) or garmentId == ""  then
        garmentId = FuncGarment.DefaultGarmentId   
    end
    
    local soucreId = FuncGarment.getGarmentSource(garmentId, avatar);

    local sourceCfg = FuncTreasure.getSourceDataById(soucreId);
    local spineName = sourceCfg.spine;

    local spbName = spineName
    if not iswhole then
        spbName = spbName .. "Extract";
    end

    charView = ViewSpine.new(spineName, {}, nil, spineName,nil,sourceCfg)
    charView.actionArr = sourceCfg;
    
    charView:playLabel(charView.actionArr.stand, true);

    if garmentId == FuncGarment.DefaultGarmentId and data then
        
        local awaken = FuncPartner.checkWuqiAwakeSkill(data)

        if awaken then
            local awakenWeapon = FuncPartner.getPartnerAwakenWeapon( data.id )
            if awakenWeapon then
                charView:changeAttachmentByFrame(awakenWeapon)
            end
        end

    end

    return charView;
end

-- 通过时装ID 和 avatara 获取时装立绘
-- notReversal 默认不传 为nil 即默认翻转180度
function FuncGarment.getGarmentLihui( garmentId,avatar,LihuiType,notReversal,label )
    if garmentId == "" or not garmentId then
        garmentId = FuncGarment.DefaultGarmentId   
    end
    if LihuiType == nil then 
        LihuiType = "dynamic"
    end
    
    local bossConfig = FuncGarment.getValueByKey(garmentId, avatar, LihuiType);

    local arr = string.split(bossConfig, ",");
--    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncRes.getArtSpineAni(arr[1],label)
--    local sp = FuncPartner.getHeroSpine(_partnerId)
    if not notReversal and arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    
    if arr[4] ~= nil then -- 缩放
        local scaleNum = tonumber(arr[4])
        if scaleNum > 0 then
            scaleNum = 0 - scaleNum    
        end
        sp:setScaleX(scaleNum)
        sp:setScaleY(-scaleNum)
    end
    if arr[5] ~= nil then -- x轴偏移
        -- sp:setPositionX(tonumber(arr[5]))
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        -- sp:setPositionY(tonumber(arr[6]))
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    return sp
end

function FuncGarment.getCharGarmentBg(garmentId, avatar)
    if garmentId == "" or not garmentId then
        garmentId = FuncGarment.DefaultGarmentId   
    end

    local bg = FuncGarment.getValueByKey(garmentId, avatar, "garmetBg")
    return bg
end
-- 通过时装ID 和 avatar 获取主角时装立绘配置信息
function FuncGarment.getCharGarmentLihuiCfg(garmentId,avatar )
    if garmentId == "" or not garmentId then
        garmentId = FuncGarment.DefaultGarmentId   
    end
    local bossConfig = FuncGarment.getValueByKey(garmentId, avatar, "art");
    local str = bossConfig[1]..","..bossConfig[2]..","..bossConfig[3]..","..bossConfig[4]
    
    return str
end
-- 通过时装ID 和 avatar 获取主角时装立绘
function FuncGarment.getCharGarmentLihui( garmentId,avatar )
	if garmentId == "" or not garmentId then
        garmentId = FuncGarment.DefaultGarmentId   
    end
    local bossConfig = FuncGarment.getValueByKey(garmentId, avatar, "dynamicPartner");

    local arr = string.split(bossConfig, ",");
    local sp = FuncRes.getArtSpineAni(arr[1])
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    if arr[4] ~= nil then -- 缩放
        local scaleX = tonumber(arr[4])
        local scaleY = scaleX
        if scaleY < 0 then
            scaleY = 0 - scaleY  
        end
        sp:setScaleX(-scaleX)
        sp:setScaleY(scaleY)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end

    return sp
end

function FuncGarment.getGarmentAttr( charId,garments )
    local garmentT = {}
    if not garments or table.length(garments) == 0 then
        table.insert(garmentT,FuncGarment.DefaultGarmentId)
    else
        garmentT = garments  
    end
    local attrT = {}
    for i,v in pairs(garmentT) do
        local attr = FuncGarment.getValueByKey(v, charId, "attr")
        table.insert(attrT, attr)
    end
    
    return attrT
end

-- 需要通过model取得ownGarments
function FuncGarment.getEnabledGarments(ownGarments,isInsert)
    local enabledGarments = {}
    for k,v in pairs(ownGarments) do
        local data = v._data or v
        -- 新需求 时装过期 时装战力也在
        -- if data.status == 1 and data.buyDuration == -1 then
        --     table.insert(enabledGarments, data.id)
        -- elseif data.status == 2 and (data.expireTime > 0 or data.expireTime == -1)  then
        --     table.insert(enabledGarments, data.id)
        -- elseif isInsert then
        --     table.insert(enabledGarments, data.id)
        -- end
        table.insert(enabledGarments, data.id)
    end
    -- dump(enabledGarments, "\n\nenabledGarments")
    return enabledGarments
end

function FuncGarment.getEnabledGarmentAttr(charId, ownGarments)
    local enabledGarments = FuncGarment.getEnabledGarments(ownGarments)
    local enabledAttrs = {}
    if table.length(enabledGarments) == 0 then
        table.insert(enabledGarments, FuncGarment.DefaultGarmentId)
    end
    for k,v in pairs(enabledGarments) do
        local attr = FuncGarment.getValueByKey(v, charId, "attr")
        if atrr ~= nil then
            table.insert(enabledAttrs, attr)
        end       
    end
    return enabledAttrs
end

function FuncGarment.getEnabledGarmentsAddAbility(ids, avatarId)
    local addedAbility = 0
    for k,v in pairs(ids) do
        local ability = FuncGarment.getGarmentPowerAddAbility(v, avatarId)
        addedAbility = addedAbility + ability
    end
    return addedAbility
end
-- 返回int 的固定值战力增值
function FuncGarment.getGarmentPowerAddAbility(id, avatarId)
    if id == "" or not id then
        id = FuncGarment.DefaultGarmentId
    end
    local powerAbility = FuncGarment.getValueByKey(tostring(id), tostring(avatarId), "addAbility") or 0;

    return powerAbility;
end

-- 返回int 的万分比战力增值
function FuncGarment.getGarmentRatioAddAbility(id, avatarId)
    -- if id == "" then
    --     id = FuncGarment.DefaultGarmentId
    -- end
    -- local ratioAbility = FuncGarment.getValueByKey(tostring(id), tostring(avatarId), "ratioAddAbility") or 0;
    -- 皮肤表里暂时没有 ratioAddAbility 万分比 没有了 
    return 0 ;
end

function FuncGarment.getWorldSpineById(_sex, id)
    local avatarId = ""
    if _sex == FuncChar.SEX_MAP.MAN then
        avatarId = FuncChar.SEX_MAP.MAN_ID
    elseif _sex == FuncChar.SEX_MAP.FEMALE then
        avatarId = FuncChar.SEX_MAP.FEMALE_ID
    end
    local worldSpineName = FuncGarment.getValueByKey(tostring(id), tostring(avatarId), "worldSpine") or ""
    return worldSpineName
end

function FuncGarment.garmentIsFinish( garments,garmentId )
    if not garmentId or garmentId == "" or garmentId == FuncGarment.DefaultGarmentId then
        return false
    end
    if garments and type(garments) == "table" then
        for i,v in pairs(garments) do
            if tostring(v.id) == garmentId then
                if v.buyDuration == -1 or v.expireTime == -1 then
                    return false
                elseif v.expireTime then
                    local expireTime = v.expireTime
                    local curTime = TimeControler:getServerTime();

                    local retLeft = expireTime - curTime;
                    if retLeft > 0 then 
                        return false;
                    else 
                        return true
                    end
                end
            end
        end
    end

    return false
end
function FuncGarment.getAllGarmentByAvatar(avatar)
    local data = {}
    for i,v in pairs(garment) do
        for ii,vv in pairs(v) do
            if tostring(vv.avatar) == tostring(avatar) then
                table.insert(data, vv)
            end
        end
    end

    return data
end

function FuncGarment.getGarmentCostById(partnerId,garmentId)
    local costArray
    local isChar = false
    if FuncPartner.isChar(partnerId) then
        costArray = FuncGarment.getGarmentCost(garmentId)
        isChar = true
    else
        costArray = FuncPartnerSkin.getCostInfo(garmentId)
    end

    local need = 0
    if isChar then
        local buyTime = costArray[1].k
        need = costArray[1].v 
    else
        local str_table = string.split(costArray[1], ",")
        need = str_table[3]
    end

    return need
end
















