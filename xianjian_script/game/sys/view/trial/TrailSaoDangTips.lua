
local TrailSaoDangTips = class("TrailSaoDangTips", UIBase);


local intervalTime = 0.7;

function TrailSaoDangTips:ctor(winName,Trailid,point)
    TrailSaoDangTips.super.ctor(self, winName);
    self.Trailid =Trailid
    self.point = point
    dump(point,"11111111111")
end

function TrailSaoDangTips:loadUIComplete()
	self:registClickClose(0, c_func( function()
            self:startHide()
    end , self))
	
	self:setpoint()
    self:initUI()
end 
function TrailSaoDangTips:setpoint()
	
	self.panel_1:setPosition(cc.p(self.point.x-80,self.point.y+170))


end
function TrailSaoDangTips:initUI()

	local sumtime = TrailModel:getSweepFinishTime(self.Trailid)
	local day = 0
	local alltime = 0
	if sumtime ~= 0 then
		alltime = sumtime-TimeControler:getServerTime()
	 	day = math.floor((alltime)/(24*3600))
	end
	if day == 0 then
		time = math.floor(alltime/3600) 
		if time == 0 then
			time = "1小时"
		else
			time = time.."小时"
		end
	else
		time = day .."天"

	end
	self.panel_1.txt_1:setString(time..GameConfig.getLanguage("#tid_trail_004"))

end





return TrailSaoDangTips;






