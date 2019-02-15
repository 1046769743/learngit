-- FuncTitle
FuncTitle= FuncTitle or {}

local PlayerTitle = nil
FuncTitle.titlettype = {
	title_cultivate = 1,   --培养
	title_challenge = 2,   --挑战
	title_other = 3,       ---其它
	title_limit = 4,       --限
}

function FuncTitle.init()
	PlayerTitle = Tool:configRequire("title.PlayerTitle")
end
function FuncTitle.getAllTitleData()
	return PlayerTitle
end
function FuncTitle.gettitletype(titleid,titleType)
	return PlayerTitle[tostring(titleid)][titleType]
end
function FuncTitle.titletypegettable()
	local typedata = {}
	for i=1,4 do
		typedata[i] = {}
	end
	for k,v in pairs(PlayerTitle) do
		v.id = tonumber(k)
		table.insert(typedata[tonumber(v.titleType)],v)
	end
	return typedata
end
function FuncTitle.bytypegetData(_type)
	if _type == nil then
		echoError("=====不存该称号 类型 =====",_type)
		return
	end
	local Titletable  = table.copy(FuncTitle.titletypegettable())

	return Titletable[tonumber(_type)]
end
--根据称号ID获得表里的数据
function FuncTitle.byIdgettitledata(titleId)
	-- dump(titleId,"2222222222222222222222222222222222")
	if titleId == nil or PlayerTitle[tostring(titleId)] == nil then
		echoError("=====不存该称号11 Id ==找西元 或者 罗鑫 ===",titleId)
		return
	end
	return PlayerTitle[tostring(titleId)]
end

--- 根据称号ID获得任务ID --跳转到摸个系统
function FuncTitle.bytitleIdgetcondition(titleId)
	if titleId == nil or PlayerTitle[tostring(titleId)] == nil then
		echoError("=====不存该称号22 Id =====",titleId)
		return nil
	end
	local questType = PlayerTitle[tostring(titleId)].conditionType

	FuncTitle.goToTargetView(questType,titleId)
end



function FuncTitle.goToTargetView(questType,titleId)
    echo("goToView " .. tostring(questType));
    -- local questType =  --FuncQuest.readMainlineQuest(questId, "conditionType");

    local jumpInfo = TargetQuestModel.JUMP_VIEW[tostring(questType)];

    if jumpInfo ~= nil then 
        if jumpInfo.viewName ~= nil then
            local systemname = jumpInfo.systemname
            if FuncTitle.issystemUpOpen(systemname) then
                if systemname == "partner" then
                    pames1 = UserModel:avatar()
                    pames2 = FuncPartner.PartnerIndex.PARTNER_QUALILITY
                end
                WindowControler:showWindow(jumpInfo.viewName,pames2,pames1)
            else
            	local xtname = FuncCommon.getSysOpenValue(systemname, "xtname")
            	-- echo("==============xtname=========",xtname)
                WindowControler:showTips(GameConfig.getLanguage(xtname)..GameConfig.getLanguage("#tid1565"));
            end


        elseif jumpInfo.funName ~= nil  then 
        	local questId = PlayerTitle[tostring(titleId)].titleJump   ---任务ID 稍后改
			jumpInfo.funName( questId);
        end  
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_tiaozhuan_01"));
    end 
end
function FuncTitle.issystemUpOpen(systemname)
    local level =  UserModel:level()
    local openData = FuncCommon.isSystemOpen(tostring(systemname))
    if openData then
    	return true
    else
    	return false
    end

end
function FuncTitle.sopenviewName(jumpInfo)
	if jumpInfo.viewName == "partner" then

	elseif jumpInfo.viewName == "char" then

	elseif jumpInfo.viewName == "trial" then

	end
end

--获得称号png  sprite
function FuncTitle.bytitleIdgetpng(titleId)
	if titleId == nil  or FuncTitle.byIdgettitledata(titleId) == nil then
		return nil
	end
	local titledata = FuncTitle.byIdgettitledata(titleId)

	--资源出来了，在funRec中配置
	local titlesprite = FuncRes:icontitleImg( titledata.titlePng ) 
	return titlesprite --titledata.titlePng
end

--属性
function FuncTitle.getInitAttr(titledata)
    local  battle,notbattle,sumbattl = FuncTitle.ByTitleIdgetbattle(titledata)
    local dataMap = {}
    for _key,_value in pairs(battle) do
        local _data = {
            key = _value.attr,
            value = _value.value,
            mode = _value.type,
        }
        dataMap[_key] = _data
    end
    -- dump(dataMap,"称号属性",7)
    return dataMap
end
--总战力
function FuncTitle.byTitleUIdGetsumbattl(titledata)
    local  battle,notbattle,sumbattl = FuncTitle.ByTitleIdgetbattle(titledata)
    return  sumbattl
end
--万分比战力
function FuncTitle.byTitleIdgetsumWBbattl(titledata)
	local  battle,notbattle,sumbattl,sumaddAbility = FuncTitle.ByTitleIdgetbattle(titledata)
    return  sumaddAbility or 0
end
function FuncTitle.ByTitleIdgetbattle(titledata)
    local battle = {}
    local notbattle = {}
    local sumbattle = 0
    local sumratioAddAbility = 0
    local battleindex = 1
    local notbattleindex = 1
    for k,v in pairs(titledata) do
        local active = v.isActivate or v.isAction or  0
        if active ~= 0 then
            local titleid = tonumber(k)
            local titledatas = table.deepCopy(FuncTitle.byIdgettitledata(titleid))
            local des = titledatas.battleAttribute
            if des ~= nil then
                for i=1,#titledatas.battleAttribute do
                    if active ~= 0 then
                        local Attribute = titledatas.battleAttribute[i]
                        if #battle == 0 then
                            battle[battleindex] = Attribute
                            battleindex = battleindex + 1
                        else
                            local servedata = false
                            for index=1,#battle do
                                if battle[index].attr == Attribute.attr and battle[index].type == Attribute.type then
                                    battle[index].value = battle[index].value + Attribute.value
                                    servedata = true
                                end
                            end
                            if servedata == false then
                                battle[battleindex] = Attribute
                                battleindex = battleindex + 1
                            end
                        end
                    end
                end
            end
            if titledatas.privileges ~= nil then
                for i=1,#titledatas.privileges do
                    local Attribute = titledatas.privileges[i]
                    if notbattle[notbattleindex] == nil then
                        notbattle[notbattleindex] = Attribute
                    else
                        local isserveattr = false
                        for k,v in pairs(notbattle) do
                            if v.attr == Attribute.id and v.type == Attribute.type then
                                isserveattr = true
                                v.value = v.value + Attribute.value
                            end
                        end
                        if isserveattr == false then
                            notbattle[notbattleindex] = Attribute
                        end
                    end
                    notbattleindex = notbattleindex + 1
                end
            end
            if active ~= 0 then 
                local addAbility = titledatas.addAbility   --战力添加
                if addAbility ~= nil then
                    sumbattle = sumbattle + addAbility
                end
                local addratioAbility = titledatas.ratioAddAbility   --万分比
                if addratioAbility ~= nil then
                	sumratioAddAbility = sumratioAddAbility + addratioAbility
                end
            end
        end
    end
    return battle,notbattle,sumbattle,sumratioAddAbility
end

function FuncTitle.getTitleAbility( titledata )
    local ability = 0
    if not titledata then
        return 0
    end
    for k,v in pairs(titledata) do
        local data = PlayerTitle[tostring(k)]
        if not data then
            echoError("头衔表中没有 id == ",k)
        else
            -- 只判断是否已激活
            if v.hasActivate then
                ability = ability + data.addAbility
            else
                if v.isActivate then
                    ability = ability + data.addAbility 
                end    
            end
        end
    end
    return ability
end
