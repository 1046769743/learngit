--
-- Author: XD
-- Date: 2014-07-24 10:44:47
--
ObjectCommon = class("ObjectCommon")


--一些通用的配置  比如 特效 影子  血条 残片 子弹 等的配置

ObjectCommon.prototypeData = {
    id = "600001"
   
}


--实例属性
ObjectCommon.level = 10

--[[
    datas = {
        level = 10, 目前只需要有级别的概念  到后面会扩展
    }
]]
-- local globalCfg = require("GlobalCfg")
local sourceEx = require("level.SourceEx")


--获取静态数据
function ObjectCommon.getPrototypeData( fullFile,id )
    local allData = require(fullFile)
    if not allData then
        echoError("找策划,这个模块不存在配置数据,"..tostring(fullFile),id)
    end

    local strId = tostring(id)
    local data = allData[strId]
    
    if not data then
        for k,v in pairs(allData) do
            echoError("这个模块不存在这个id数据,id="..tostring(id).."    模块="..tostring(fullFile) .."__用"..k.."代替" )
            return v
        end
    end
    
    return data
end


-- 直接字段映射函数。其中 encryptKey 为加密的字段的key表
function ObjectCommon.mapFunction(obj,keyArr)
    if not obj then -- 还有好多需要改，目前这样是保证程序能运行起来
        return 
    end
    for i,v in ipairs(keyArr) do
        if v ~= "hid" then
            obj["sta_"..v] = function(_self)
                if not _self.__staticData then
                    echoWarn("___没有对应的静态数据_",_self.__cname,_self.hid)
                    return 0
                end
                return _self.__staticData[v]
            end
        end
    end

end


function ObjectCommon:getSourceEx(hid)
    return sourceEx[hid]
end



-- 上阵英雄的属性
function ObjectCommon:getHeroCfg()
    local herodata = require("testConfig.Hero")
    return herodata
end

--获取关卡怪物数据
function ObjectCommon:getLevelEnemys()
    return require("testConfig.Enemy")
end

function ObjectCommon:getServerData()
    local herodata = require("testConfig.ServerData")
    if UserModel and UserModel:rid() then
        herodata[1]._id = UserModel:rid()
    else
        herodata[1]._id = "1"
    end
    
    return herodata
end

-- 获取测试的仙界对决数据
function ObjectCommon:getCrossPeakData()
    local herodata = require("testConfig.CrossPeakData")
    return herodata
end

return  ObjectCommon
