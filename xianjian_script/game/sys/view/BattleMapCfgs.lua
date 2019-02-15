
local viewsPackage = "game.sys.view"

local BattleMapCfgs = {
    --BattleMap = {ui="UI_map_1", package ="battle",},
    BattleMap_1 = {ui="map_zhongruishi", package ="battle",},
    --BattleMap_2 = {ui="UI_map_2", package ="battle",},
}

BattleMapTools= {
}



function BattleMapTools:getWindowNameByUIName(uiName )
    return "BattleMap"  -- 默认战斗场景的windowName
end


--根据UIname获取windowName
function BattleMapTools:getClassByUIName( uiName )
    
    return require(viewsPackage ..".battle.BattleMap")
end



--创建Window 
function BattleMapTools:createWindow(mapId,...)
    return UIBaseDef:createUIByName(mapId,nil,...)
end
