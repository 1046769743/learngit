--
-- Author: xd
-- Date: 2018-01-23 17:10:42
--

ClientTagData = {}
--战斗服错误标签
ClientTagData.battleServerError = "battleServerError"
--服务器推送的战斗错误
ClientTagData.battlePushServerError = "battlePushServerError"
--本地战斗校验失败
ClientTagData.battleCheckError = "battleCheckError"
--因为错误终止战斗校验的标签
ClientTagData.battleErrorCancelCheck = "battleErrorCancelCheck"

-- 仙界对决卡死问题
ClientTagData.battleCrossPeakError = "battleCrossPeakError"


ClientTagData.socketServerError = "socketServerError"
ClientTagData.httpRequestError = "httpRequestError"
ClientTagData.webHttpRequestError = "webHttpRequestError"

-- 引导触发容错机制
ClientTagData.tutorialAvoidStuck = "tutorialAvoidStuck"

return ClientTagData