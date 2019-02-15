--
-- Author: Your Name
-- Date: 2018-02-06 10:30:23
--
local GameFeedBackControler = GameFeedBackControler or {}


function GameFeedBackControler:enterGameFeedBackView()
	local params =  {
		uid = UserModel:uid(),
		platform = AppInformation:getAppPlatform(),
		fields = "status,uid,content,op_content,create_time,op_datetime,vip,rid"
	}
	local url = FuncSetting.FEEDBACK_URL
	local dateStr = os.date("%Y-%m-%d %X")
	local token = crypto.md5(string.format("PlayCrab%s%s", FuncSetting.FEEDBACK_PRIKEY, dateStr))
	local signature = string.format("PLAYCRAB %s:%s", FuncSetting.FEEDBACK_PUBKEY, token)
	--httpheader
	local headers = {
		string.format("Authorization: %s", signature),
		string.format("Date: %s", dateStr),
	}

	WebHttpServer:sendRequest(params, url, WebHttpServer.POST_TYPE.GET, headers, c_func(self.getFeedBack, self))
	 
end

function GameFeedBackControler:getFeedBack(serverData)
	if serverData.data and serverData.data.code ~= "403" then
		local data = serverData.data
		self.talkDatas = {}
		if data and table.length(data) > 0 then
			for i,v in ipairs(data) do
				if v.status == 1 then
					local talkData = {
						avatar = UserModel:avatar(),
						level = UserModel:level(),
						name = UserModel:name(),
						_type = 1,
						rid = v.rid,
						content = v.content,
						vip = v.vip,
						time = v.create_time,
					} 
					table.insert(self.talkDatas, talkData)
				elseif v.status == 2 then
					local talkData1 = {
						avatar = UserModel:avatar(),
						level = UserModel:level(),
						name = UserModel:name(),
						_type = 1,
						rid = v.rid,
						content = v.content,
						vip = v.vip,
						time = v.create_time,
					}
					table.insert(self.talkDatas, talkData1)
					local talkData2 = {
						name = "【小仙】",
						_type = 2,
						content = v.op_content,
						time = v.op_datetime,
					}
					table.insert(self.talkDatas, talkData2)
				end
			end
		end
		WindowControler:showWindow("GameFeedBackView", self.talkDatas)
	end	
end

return GameFeedBackControler