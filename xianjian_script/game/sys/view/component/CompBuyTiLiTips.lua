-- CompBuyTiLiTips
--//体力获得展示界面
local  CompBuyTiLiTips=class("CompBuyTiLiTips",UIBase);

function CompBuyTiLiTips:ctor(_name)
  CompBuyTiLiTips.super.ctor(self, _name);

end

function CompBuyTiLiTips:loadUIComplete()
	self:registClickClose("out")
	self.scale9_1:setScaleY(-1)
	self.scale9_1:setPositionY(-165)
	self:inidData()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end

function CompBuyTiLiTips:inidData()

	local  buyTimes = CountModel:getSpBuyCount();
    local  maxTimes = UserModel:getSpMaxBuyTimes();
	self.rich_1:setString(GameConfig.getLanguage("#tid_shop_1006").."<color = 00ff00>"..buyTimes.."/"..maxTimes.."<->")
	-- self.rich_2:setString()
	-- self.rich_3:setString()
	local secondInterval = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
	local time = (secondInterval/60)..GameConfig.getLanguage("#tid_shop_1008")
	self.rich_4:setString(GameConfig.getLanguage("#tid_shop_1007").."<color = 00ff00>"..time.."<->")
	
	local maxSpLimit = UserModel:getMaxSpLimit()   --最大体力
	local curSp = UserExtModel:sp() --当前体力
	local shengyusp  =  maxSpLimit - curSp  
	local sumtime =  shengyusp * secondInterval
	local secondInterval = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
    local upSpTime = UserExtModel:upSpTime()
	local dt = TimeControler:getServerTime()- upSpTime
	local times =  math.fmod(dt, secondInterval)
	local zuisongtime =  sumtime - times
	local showStime = self:getTimeType(zuisongtime)
	if zuisongtime <=  0 then
		showStime = "00:00:00"
	end
	self.rich_3:setString(GameConfig.getLanguage("#tid_shop_1009").."<color = 00ff00>"..showStime.."<->")

	local maxSpLimit = UserModel:getMaxSpLimit()
    local curSp = UserExtModel:sp()
    if curSp <  maxSpLimit then
	    local upSpTime = UserExtModel:upSpTime()
		local dt = TimeControler:getServerTime()- upSpTime
		self.daojitime =  secondInterval - math.fmod(dt, secondInterval)
		local showStime = self:getTimeType(self.daojitime)
		self.rich_2:setString(GameConfig.getLanguage("#tid_shop_1010").."<color = 00ff00>"..showStime.."<->")
	else
		local _str = GameConfig.getLanguage("#tid_shop_1011")
		self.rich_2:setString(GameConfig.getLanguage("#tid_shop_1010").."<color = 00ff00>".._str.."<->")
	end
	self.index = 1

end

function CompBuyTiLiTips:updateFrame()
	self.index = self.index + 1
	if math.fmod(self.index,GameVars.GAMEFRAMERATE) == 0 then
		local maxSpLimit = UserModel:getMaxSpLimit()
	    local curSp = UserExtModel:sp()
	    if self.daojitime ~= nil then
		    if curSp <  maxSpLimit then
		    	self.daojitime = self.daojitime - 1
		    	if self.daojitime > 0 then
		    		local showStime = self:getTimeType(self.daojitime)
					self.rich_2:setString(GameConfig.getLanguage("#tid_shop_1010").."<color = 00ff00>"..showStime.."<->")
				else
					self.daojitime = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")
				end
			else
				local _str = GameConfig.getLanguage("#tid_shop_1011")
				self.rich_2:setString(GameConfig.getLanguage("#tid_shop_1010").."<color = 00ff00>".._str.."<->")
			end
		end
	end
end


function CompBuyTiLiTips:getTimeType(time)
    local h = math.floor(time/3600)
    local s = math.floor((time-h*3600)/60)
    local m = math.fmod(time,60)
    local timestring = ""
    if  string.len(m) ~= 2 then
        m = "0"..m
    end
    if  string.len(s) ~= 2 then
        s = "0"..s
    end
    if h ~= 0 then
        if  string.len(h) ~= 2 then
            h = "0"..h
        end
        if s ~= 0 then
            timestring = h..":"..s..":"..m
        end
    else
        if s ~= 0 then
            timestring = "00:"..s..":"..m
        else
            timestring = "00:00:"..m
        end
    end
    return timestring
end

return CompBuyTiLiTips;