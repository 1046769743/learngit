--
-- Author: xd
-- Date: 2016-01-14 10:49:54
--

local MailServer = {}

--2013  邮件测试id 和测试参数
--{"all":1,"tempId":2,"reward":["3,1000001"],"param":["dev_30",20001,11369]}
--{"all":0,"tempId":2,"param":["dev_30",20001,11369]}

function MailServer:init(  )
	EventControler:addEventListener("notify_mail_receive_1506", self.notify_mail_receive_1506, self)
end



--收到邮件通知后 立即请求 邮件列表
function MailServer:notify_mail_receive_1506( e )
	echo("收到邮件通知----")
	self:requestMail()
end







--获取邮件
function MailServer:requestMail(  )
	Server:sendRequest({}, MethodCode.mail_requestMail_1501 , c_func(self.requestMailBack, self))
end

--请求邮件列表返回
function MailServer:requestMailBack( result )
	if not result.result then
		return
	end


	--发送有新邮件的事件  通知view处理
	EventControler:dispatchEvent(MailEvent.MAILEVENT_NEWMAIL)

	MailModel:updateData(result.result.data.data)
	
end

--获取附件  type  是否删除 0表示 改变为已读 1表示删除邮件
function MailServer:getAttachment(mailId,type,callBack,isall)
	if isall == nil then
		isall = 0
	end
	Server:sendRequest( {mailId = mailId,type = type,isAll = isall}, MethodCode.mail_getAttachment_1503 ,c_func(self.getAttachmentBack,self,mailId,isDel,callBack or GameVars.emptyFunc))
end

--改变邮件可读已读状态
function MailServer:readMail( mailId )
	MailModel:readMail(mailId)
	Server:sendRequest( {mailId = mailId,type = 0}, MethodCode.mail_getAttachment_1503 )
end


--获取附件返回
function MailServer:getAttachmentBack(mailId,isDel, callBack,result )
	--获取邮件后 那么需要更新邮件列表 同时发送邮件通知

	if isDel and isDel ~= 0  then
		--MailModel:deleteMail(mailId)
	else
		-- local data = result.result.data
	end
	if callBack then
		callBack()
	end
	--EventControler:dispatchEvent(MailEvent.MAILEVENT_RECEIVE, {self._mailDatas})
end

--获取当前所有的邮件
function MailServer:getMailDatas(  )
	return self._mailDatas
end

MailServer:init()

return MailServer