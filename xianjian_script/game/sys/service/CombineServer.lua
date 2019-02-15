-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
local CombineServer = { }

function CombineServer:ctor()

end 
function CombineServer:requestCombineData( id ,_cllback )
    Server:sendRequest( { treasureId = id }, MethodCode.treasure_combine_409, _cllback)
end 

return CombineServer

-- endregion
