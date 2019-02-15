local BaseInspect = class()
function BaseInspect:ctor()
end

function BaseInspect:run()
	self:initConfig()

	if self.action_before_run then
		self:action_before_run()
	end

	local className = self.__cname
	for k,v in pairs(self.class) do
		if string.match(k, "run_") then
			self:log(string.format("===================[%s]begin: %s===================", className, k))
			v(self)
			self:log(string.format("===================[%s]end  : %s===================\n", className, k))
		end
	end
	self:log(string.format("==================%s : check end=================\n", className))
end

function BaseInspect:initConfig()
	if not self.getConfigItems then return end
	local configs = self:getConfigItems()
	for _, key in pairs(configs) do
		local strArr = string.split(key, '.')
		local config_key = strArr[#strArr]
		self['config_'..config_key] = require(key)
	end
end

function BaseInspect:log(message)
	echo(string.format("[ECHO]:%s", message))
end

function BaseInspect:logError(message)
	echo(string.format("[ERROR]:%s", message))
end

function BaseInspect:logWarning(message)
	echo(string.format("[WARING]:%s", message))
end

return BaseInspect
