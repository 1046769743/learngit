--guan
--2017.5.4
--
--Author:      zhuguangyuan
--DateTime:    2017-09-07 17:48:15
--Description: 
-- 时装开启是需要等级的，然而用户刚开始玩游戏时就有默认的时装，所以服务端默认时装为""
-- 考虑到时装到期或者其他情况下主角穿的其他时装变回默认时装时，是需要一个id才能找到的
-- 所以客户端自己维护一个默认时装的id 为 100 所以才有下列语句
-- GarmentModel.DefaultGarmentId = "100" --素颜时装id
-- 其他地方要获取用户正在穿戴的时装只能通过 GarmentModel:getOnGarmentId() 进行获取
-- 此函数返回的id 一定不为空 根据此id可以获取时装立绘 等数据
-- 若通过 UserExtModel:garmentId() 获取，则是默认时装时得到的是""

local Garment = class("Garment", BaseModel)

--[[
    package ms.entity;
    message EntityGarment
    {
        /* 时装id */
        optional string id = 1;
        /* 状态: 1,购买过但未穿戴 2.穿戴过 */
        optional int32 status = 2;
        /*购买时长 status=1时这个字段存在*/
        optional int32 buyDuration = 3;
        /*超时时间戳 status=2时这个字段存在*/
        optional int32 expireTime = 4;
    }
]]
function Garment:init( d )
    Garment.super.init(self, d)

    --注册函数 keyData
    self._datakeys = {
        id = "" ,     
        status = 0,     
        buyDuration = 0,     
        expireTime = 0,     
    };

    self:createKeyFunc();
end

local GarmentModel = class("GarmentModel", BaseModel);


function GarmentModel:ctor()

end


GarmentModel.DefaultGarmentId = "100" --素颜时装id
GarmentModel.eventName = "garmentEvent";


function GarmentModel:init(data)
    GarmentModel.super.init(self, data)
    
    self._garments = {}

    self._datakeys = {
        garments = nil,              
    }
    --所有的到时事件
    self._allEvent = {},
    self:updateData(data, true)

    self:registAllGarmentEvent();
end



--更新数据
function GarmentModel:updateData(data, isInit )
    GarmentModel.super.updateData(data)
    -- dump(data,"更新的时装数据",6)

    -- dump(self._garments,"\n\n\n处理前时装数据self._garments",6)
    if not isInit then
        table.deepMerge(self._dada, data);
    end    
    for k, v in pairs(data) do
        if self._garments[k] == nil then
            self._garments[k] = Garment.new()
            self._garments[k]:init(v)
        else
            self._garments[k]:updateData(v)
        end
    end
    -- dump(self._garments,"\n\n\n处理后时装数据self._garments",6)
end

function GarmentModel:deleteData( data )
    -- 当返回的数据为"number"时删除的是服装id
    GarmentModel.super.deleteData(data)
    -- dump(data,"删除的时装数据",6)
    -- dump(self._garments,"处理前时装数据self._garments",6)
    for k,v in pairs(data) do
        -- 服务器删除某件服装
        if type(data[k]) == "number" and self._garments[k] ~= nil then
            self._garments[k] = nil
            EventControler:dispatchEvent(GarmentEvent.GARMENT_SERVER_DATA_CHANGE)
        end
    end
    -- dump(self._garments,"处理后时装数据self._garments",6)
end

function GarmentModel:getGarmentById(garmentId)
    return self._garments[tostring(garmentId)];
end

--所有有的时装
function GarmentModel:getAllOwnGarments()
    local retArray = {};
    for k, v in pairs(self._garments) do
        if self:isExpire(k) == false then 
            table.insert(retArray, v);
        end 
    end
    return retArray;
end
-- 服务器 返回的所有时装
function GarmentModel:getAllServerGarments()
    local retArray = {};
    for k, v in pairs(self._garments) do
        table.insert(retArray, v);
    end
    return retArray;
end

function GarmentModel:getAllGarmentsByOrder()
    local avatar = UserModel:avatar();
    local all = FuncGarment.getAllGarmentByAvatar(avatar);
    local garments = {}
    local ret = {}

    for k, v in pairs(all) do
        if v.isOpen == nil or (v.isOpen and v.isOpen ~= "0") then
            table.insert(garments, v)
        end       
    end

    local sort = function (a, b)
        return tonumber(a.showOrder) < tonumber(b.showOrder)
    end

    if table.length(garments) > 0 then
        table.sort(garments, sort)
    end
    
    for i,v in ipairs(garments) do
        table.insert(ret, v.id)
    end

    return ret
end

--所有的时装
function GarmentModel:getAllGarments()
    local avatar = UserModel:avatar();
    local all = FuncGarment.getAllGarmentByAvatar(avatar);

    local ret = {};

    for k, v in pairs(all) do
        if v.isOpen == nil or (v.isOpen and v.isOpen ~= "0") then
            table.insert(ret, k);
        end       
    end
    return ret;
end


function GarmentModel:getAllGarmentsAfterSort()
    --已经有的在前面 然后是默认显示顺序
    local allId = GarmentModel:getAllGarments();

    local function sortFunc(id1, id2)

        local isOwn1 = self:isOwnOrNot(id1);
        local isOwn2 = self:isOwnOrNot(id2);
        isOwn1 = isOwn1 == true and 1 or 0;
        isOwn2 = isOwn2 == true and 1 or 0;

        if isOwn1 > isOwn2 then 
            return true;
        elseif isOwn1 == isOwn2 then 
            local sort1 = FuncGarment.getGarmentOrder(id1);
            local sort2 = FuncGarment.getGarmentOrder(id2);

            if tonumber(sort1) < tonumber(sort2) then 
                return true  
            else 
                return false;
            end 

        else 
            return false;
        end 

    end
    table.sort(allId, sortFunc);

    return allId;
end

--是不是正在穿 
function GarmentModel:isOn(garmentId)
    local onGarmentId = self:getOnGarmentId()

    if self:isExpire(onGarmentId) == true then 
        return false;
    end 

    if tonumber(garmentId) == tonumber(onGarmentId) then 
        return true;
    else 
        return false;
    end 

end

function GarmentModel:isForeverOwn(garmentId)
    if garmentId == GarmentModel.DefaultGarmentId then 
        return true;
    end 

    local garment = self:getGarmentById(garmentId);
    if garment == nil then 
        return false;
    end 

    local buyDuration = garment:buyDuration();
    local expireTime = garment:expireTime();

    if buyDuration == -1 or expireTime == -1 then 
        return true;
    else 
        return false;
    end 
end

-- 获取某时装的剩余有效时间
-- garment:expireTime()在点击穿戴按钮，向服务器发送了穿戴请求后
-- 才会返回的字段
-- 所以如果是只买了没穿的时装 得到的expireTime为0
function GarmentModel:getLeftTime(garmentId)
    local garment = self:getGarmentById(garmentId);

    if garment == nil then 
        return 0;
    end 

    local expireTime = garment:expireTime();
    local curTime = TimeControler:getServerTime();

    local retLeft = expireTime - curTime;
    if retLeft > 0 then 
        return retLeft;
    else 
        return 0;
    end 
end


-- 主角皮肤 资源ID
function GarmentModel:getGarmentSourcrId()
    local onGarmentId = GarmentModel:getOnGarmentId()
    
    if tonumber(UserModel:sex()) == 1 then
        return FuncGarment.getValueByKey(onGarmentId, "101", "sourceId")
    else
        return FuncGarment.getValueByKey(onGarmentId, "104", "sourceId")
    end
end

-- 取得正在穿的时装id
function GarmentModel:getOnGarmentId()
    local onGarmentId = UserExtModel:garmentId();
    -- dump(onGarmentId,"\n\n onGarmentId ---- ")
    
    if onGarmentId == "" or self:getGarmentById(onGarmentId):status() == 1 
             or self:isExpire(onGarmentId) == true then 
        onGarmentId = GarmentModel.DefaultGarmentId;
    end  
    return onGarmentId;
end

-- 判断是否穿着除了默认时装之外的时装
-- 若有则返回相应的id 否则返回nil
-- 六界调用到 WorldAerialMapView
function GarmentModel:isOwnOtherGarmentId()
    local onGarmentId = UserExtModel:garmentId();
    
    if onGarmentId == "" or self:getGarmentById(onGarmentId):status() == 1 
             or self:isExpire(onGarmentId) == true then 
        return nil
    end  
    return onGarmentId
end


--有没有这个时装
function GarmentModel:isOwnOrNot(garmentId)
    if  tonumber(GarmentModel.DefaultGarmentId) == tonumber(garmentId) then 
        return true;
    else 
        if self:getGarmentById(garmentId) ~= nil and self:isExpire(garmentId) == false then 
            return true;
        else 
            return false;
        end 
    end 
end

--是不是没有穿过
function GarmentModel:isBrandNew(garmentId)
    local garment = self:getGarmentById(garmentId);
    if garment == nil then 
        return false;
    end 

    if tonumber( garment:status() ) == 1 then 
        return true;
    else    
        return false;
    end 
end

--是不是过期了
--没有这个衣服算过期
function GarmentModel:isExpire(garmentId)
    local garment = self:getGarmentById(garmentId);
    if garment == nil then 
        return false;
    end 

    if tonumber( garment:status() ) == 1 then
        return false;
    else 
        local expireTime = garment:expireTime();
        local curTime = TimeControler:getServerTime();

        if tonumber(expireTime) == -1 then 
            return false;
        end 

        if curTime >= expireTime then 
            return true;
        else 
            return false;
        end 
    end 
end

--注册所有过期时装
--所有的到期都发个事件
function GarmentModel:registAllGarmentEvent()
    local allOwnGarments = self:getAllOwnGarments();

    -- 为所有时装开启计时
    -- 实际实现时根据永久拥有、已穿戴、买了未穿戴等情况会有不同的处理
    -- 所以实际上是为已经穿戴过的时装开启计时
    -- 以便到期时 TimeControler 发送消息
    for k, v in pairs(allOwnGarments) do
        self:addTimeEventByGarmentId(v:id());
    end

    -- 注册皮肤到期监听消息
    -- 注意监听的这些消息是由 TimeControler 发送的
    -- 监听到到期事件后 发送穿戴默认衣服的请求给服务器 并更新本地显示
    local allGarmentEvent = GarmentModel:getAllEvent();
    for k, v in pairs(allGarmentEvent) do
        EventControler:addEventListener(k, self.garmentTimeOver, self);     
    end

    EventControler:addEventListener(GarmentEvent.GARMENT_SHARE_UI, 
        self.showUI, self);   
end

function GarmentModel:garmentTimeOver(event )
    echo(" model 里监听到时装到期事件 ---- ",event.name)
    local garmentId = string.gsub(event.name, GarmentModel.eventName, "");
    if not GarmentModel:isExpire(garmentId) then
        return
    end

    -- 告诉服务器换素颜
    self:dressGarment(GarmentModel.DefaultGarmentId)

    -- 衣服时间到期向系统发消息 提示已到期
    local str1 = "<color = 000000>你的霓裳<->"
    if tonumber( UserModel:sex() )== 1 then 
        str1 = "<color = 000000>你的战袍<->"
    end
    local str2 = "【"..FuncGarment.getGarmentName(garmentId).."】"
    local garment = self:getGarmentById(garmentId);
    local timeData = os.date("*t",garment:expireTime())
    local str3 = timeData.month .."月"..timeData.day.."日"..timeData.hour.."时"..timeData.min.."分"

    local str = str1.."<color = 00ff00>"..str2..str3.."<->".."已到期"
    local data = {
            param1 = str,
            param2 = "5020",
            time   = 1495765517,
            type   = 1,
            chattype = 9,
        }

    -- dump(data,"到期显示数据")
    ChatModel:updateSystemMessage(data)
    ChatServer:sendMainChatMessage(data)
end

-- 告诉服务器穿哪件衣服
function GarmentModel:dressGarment( garmentId )
    GarmentServer:onGarment(garmentId, c_func(self.putOnGarmentCallBack, self, garmentId));
end

-- 穿衣服回调
function GarmentModel:putOnGarmentCallBack(garmentId)
    echo(" 给服务器发送穿戴请求之后 回调 putOnGarmentCallBack --- UserExtModel:garmentId()--- ",UserExtModel:garmentId())
    -- 分发时装变化事件
    EventControler:dispatchEvent(GarmentEvent.GARMENT_CHANGE_ONE, {garmentId = garmentId} )
end




function GarmentModel:showUI(params)
    local skinId = params.params.id
    local sex = params.params.sex

    WindowControler:showWindow("GarmentShowView", skinId,"see",sex);
end

-- 为id为 garmentId 的时装开启计时
function GarmentModel:addTimeEventByGarmentId(garmentId)

    local eventName = GarmentModel.eventName .. tostring(garmentId);

    local garment = self:getGarmentById(garmentId);
    if garment == nil or garmentId == GarmentModel.DefaultGarmentId
             or self:isExpire(onGarmentId) == true then 
        return ;
    end 

    --永久的删除计时器
    if garment:expireTime() == -1 then 
        self:removeTimeEventByGarmentId(garmentId); 
        return
    end 

    local leftTime = self:getLeftTime(garmentId);
    -- 多1s，省的发消息的时候还没有更新
    -- TimeControler:startOneCd(eventName, 15 + 1);
    echo("\n\n\n\n 开启时装计时器 ---- ",garmentId)
    echo(" 剩余时间为 ---- ",leftTime)

    TimeControler:startOneCd(eventName, leftTime + 1);

    self._allEvent[eventName] = garmentId;
end

function GarmentModel:removeTimeEventByGarmentId(garmentId)
   local eventName = GarmentModel.eventName .. tostring(garmentId);
   TimeControler:removeOneCd( eventName );

    self._allEvent[eventName] = nil;
end

function GarmentModel:getAllEvent()
    return self._allEvent;
end

function GarmentModel:isDataInRange(garmentId)
    local openArray = FuncGarment.getOpen(garmentId);
    if openArray == nil then 
        return true;
    else 
        local curTime = TimeControler:getServerTime();
        if tonumber( openArray[1] )> curTime then 
            return false, 1;
        elseif tonumber( openArray[2] ) < curTime then 
            return false, 2;
        else 
            return true;
        end 
    end 
end


function GarmentModel:getSpineViewByAvatarAndGarmentId(avatar, garmentId)
    local charData = CharModel:getCharData()
    return FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId,true,charData)
end

-- 获取当前主角正在穿戴的时装的spine动画
function GarmentModel:getCharGarmentSpine()
    local garmentId = GarmentModel:getOnGarmentId();
    local charView = GarmentModel:getSpineViewByAvatarAndGarmentId(UserModel:avatar(), garmentId);
    return charView;
end

return GarmentModel;






















