--
-- Author: XD
-- Date: 2014-07-11 11:32:08
--
EventEx= EventEx or {}

EventEx.eventListenerArr = {}

--事件类  发送消息以后立即执行 不用等到下一帧
local eventClass = class("eventEx")
function eventClass:ctor(eventName, target, params )
	self.params= params
	self.name = eventName
	self.target = target



	

end

--侦听一个消息						消息名称, 侦听函数	 
--[[	
	obj 如果有obj表示侦听的是实例方法  否则就是静态方法 到时清除侦听的依据就会依据这个obj

	prior 优先级，数越大优先级越高, 优先级相同先注册的大于后注册的 eg: prior = 4 先于 prior = 2 执行 默认值是0
	isSwallowEvent 是否拦截这个事件，优先级在它之下的注册将收不到事件 默认是fase不拦截
]]
function EventEx:addEventListener(eventName, listener, obj, prior, isSwallowEvent)
	isSwallowEvent = isSwallowEvent or false;
	prior = prior or 0;

	if not eventName then
		echoError("注册的是空事件")
		return
	end
	if not self.eventListenerArr[eventName] then
		self.eventListenerArr[eventName] = {}
	end


	if not obj then
		echoError("没有注入对象")
		return
	end

	if not listener then
		echoError("没有注入函数")
		return
	end

	local arr =  self.eventListenerArr[eventName]
	if obj then
		for i=1,#arr do
			if arr[i][1] == listener and arr[i][2] == obj then
				return
			end
		end
	end

	table.insert(arr, {listener, obj, prior, isSwallowEvent,obj.__cname});
end

--发送一个消息					eventName消息名称	params消息参数(任意类型,消息参数 返回在event.params里面)
--注意：此函数内不能用echo()!!!
function EventEx:dispatchEvent( eventName,params )
	
	--游戏销毁期间不能发送事件
	if GameLuaLoader:isGameDestory(  ) then
		return
	end

	
	local eventArr = self.eventListenerArr[eventName]
	if not eventArr or #eventArr == 0 then
		return
	end
	local event = {name = eventName,target = self,params = params}  --eventClass.new(eventName,self,params)

	if self ~= FightEvent then
		--由小到大排序
		local function sortFunc(a, b)
			return a[3] < b[3];
		end
		table.sort(eventArr, sortFunc);
	end

	-- print(eventName);
	-- dump(eventArr, "__eventArr")
	local info 
	for i=#eventArr,1,-1 do
		info = eventArr[i]
		--这里可能会出现 在回调函数里面 移除了另外的对象注册的 这个事件,然后 就会报错
		if info then
			if info[2] then
				if type(info[2])=="userdata" and tolua.isnull(info[2]) then
					echo("target is null so clear Event,uiname:",info[5],eventName)
					table.remove(eventArr,i)
				else
					if DEBUG_SERVICES then
						info[1](info[2], event)
					else
						local time1 = os.clock()
						info[1](info[2], event)
						local time2 = os.clock()
						local cost = time2 - time1
						if cost >= GameVars.costTimeCfg[device.platform] then
							echoWarn("\nevent事件耗时=",cost,eventName,info[5])
						end
					end
					
				end
			else
				info[1](event)
			end

			if info[4] == true then 
				break;
			end 
		end
		
	end

	--然后销毁event
	event.target = nil
	event.params=nil
end

--如果带obj表示清除的是 实例方法 否则清除的是 静态方法 区分标准就是是否  侦听事件的时候 会传入self
function EventEx:removeEventListener( eventName,listener,obj )
	local eventArr = self.eventListenerArr[eventName]
	if not eventArr or #eventArr ==0 then
		return
	end
	local info
	for i=#eventArr,1,-1 do
		info = eventArr[i]
		if info[2] ==  obj and info[1] == listener then
			table.remove(eventArr,i)
		end
		
	end

end

--清楚某个对象 在 EventEx注册的侦听
function EventEx:clearOneObjEvent( obj )
	for k,v in pairs(self.eventListenerArr) do
		local eventArr = v
		local info
		for i=#eventArr,1,-1 do
			info = eventArr[i]
			if info[2] == obj then
				table.remove(eventArr,i)
			end
		end
	end
end


--清除某一种类型的事件
function EventEx:clearEvent( eventName )
	self.eventListenerArr[eventName] = nil
end

--初始化注册一个事件 这里既可以采用全局侦听 也可以给某个对象自己注册侦听  调用方式 EventEx.initEvent(fromObj)
function EventEx:initEvent( )
	self.eventListenerArr = {}
end

--清除所有事件
function EventEx:clearAllEvent(  )
	self.eventListenerArr = {}
end

--给一个对象绑定侦听
function EventEx.extend( obj )
	EventEx.initEvent(obj)
	obj.addEventListener = EventEx.addEventListener
	obj.dispatchEvent = EventEx.dispatchEvent
	obj.removeEventListener = EventEx.removeEventListener
	obj.clearEvent = EventEx.clearEvent
	obj.clearOneObjEvent = EventEx.clearOneObjEvent
	obj.clearAllEvent = EventEx.clearAllEvent
end











