--[[
	Author: 张燕广
	Date:2018-08-06
	Description: 公告系统数据类
]]

local NoticeModel = class("NoticeModel",BaseModel)

function NoticeModel:init(d)
	self.modelName = "notice"
	NoticeModel.super.init(self, d)
	
	self:initData()
	self:registerEvent()
end

function NoticeModel:initData()
	
end

--更新数据
function NoticeModel:updateData(data)
	NoticeModel.super.updateData(self,data);
end

--删除数据
function NoticeModel:deleteData( data ) 
	NoticeModel.super.deleteData(self,data);
	
end

function NoticeModel:registerEvent()

end

--[[
	公告标题列表排序
	1.sort排序，大的显示在前面
	2.ctime创建时间排序,大的显示在前面
]]
function NoticeModel:sortNoticeTitleList(noticeList)
	table.sort(noticeList,function(a,b)
		local sort1 = a.sort or 0
		local sort2 = b.sort or 0

		local ctime1 = a.ctime
		local ctime2 = b.ctime

		if sort1 > sort2 then
			return true
		elseif sort1 == sort2 then
			if ctime1 > ctime2 then
				return true
			else
				return false
			end
		end
	end)
end

--[[
	htmlObjList转换为富文本textCfgList格式
]]
function NoticeModel:convertToRichTextCfgList(htmlObjList)
	local textCfgList = {}
	for i=1,#htmlObjList do
		local curCfg = {}

		local htmlObj = htmlObjList[i]
		local curContent = htmlObj.content
		local color = htmlObj.color

		if htmlObj.isBr then
			curContent = nil
			curCfg.br = true
		end

		if htmlObj.href then
			curCfg.line = true
		end

		-- 解决公告内容显示口字符的问题
		if curContent then
			curContent = string.gsub(curContent, "\r", "")
		end

		curCfg.char = curContent
		curCfg.color = color
		textCfgList[#textCfgList+1] = curCfg
	end

	-- dump(textCfgList,"textCfgList-----------------")

	return textCfgList
end

NoticeModel:init({})

return NoticeModel

