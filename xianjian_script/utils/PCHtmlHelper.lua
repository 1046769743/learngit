--
-- Author: ZhangYanguang
-- Date: 2018-08-07
-- HTML解析工具类

PCHtmlHelper = {}

--[[
	通过html库解析
	返回的结果时数据结构
	例如： 
	content=  <p>张燕广测试公告内容</p>
	解析后如下：
	 1 = {
         1       = "张燕广测试公告内容"
         "_attr" = {
         }
         "_tag"  = "p"
     }
     "_attr" = {
     }
     "_tag"  = "#document"
]]
function PCHtmlHelper:parseHtmlStr(htmlStr)
	local resultArr = html.parsestr(htmlStr)
	-- local htmlObjList = self:convertToHtmlObj(resultArr)
	-- dump(htmlObjList,"htmlObjList-------------")
	-- return htmlObjList

	return resultArr
end

function PCHtmlHelper:getMaxNumKey(resultArr)
	local maxNum = 0

	for k,v in pairs(resultArr) do
		if type(k) == "number" then
			if tonumber(k) > maxNum then
				maxNum = tonumber(k)
			end
		end
	end

	return maxNum
end


--[[
	html数组结构转为HtmlObj
]]
function PCHtmlHelper:convertToHtmlObj(resultArr)
	-- dump(resultArr,"resultArr----------------")

	local htmlObjList = {}
	local maxNum = self:getMaxNumKey(resultArr)
	for i=1,maxNum do
		local data = resultArr[i]
		local htmlObjArr = {}

		self:convertOneData(htmlObjArr,data)
		
		for i=1,#htmlObjArr do
			htmlObjList[#htmlObjList+1] = htmlObjArr[i]
		end
	end

	-- dump(htmlObjList,"htmlObjList--------------")
	return htmlObjList
end

--[[
	TODO 代码稳定后转到model中
	处理html解析结果中的一条数据
]]
function PCHtmlHelper:convertOneData(htmlObjArr,data)
	if data == nil or type(data) ~= "table" then
		return
	end

	local attr = data._attr
	for k,v in pairs(data) do
		local htmlObj = {}
		local content = nil
		local color = nil
		local isBr = nil

		local href = nil
		local hrefTitle = nil

		if type(k) == "number" then
			if type(v) == "string" then
				content = v
				-- 文本颜色
				if attr then
					if attr.style then
						-- 颜色
						color = attr.style
						color = PCHtmlHelper:convertHtmlColor(color)
				    -- 超级链接
				    elseif attr.href then
						href = attr.href
						hrefTitle = attr.title or ""
						color = "0000AA"
					end
				end
			-- 递归遍历
			elseif type(v) == "table" then
				self:convertOneData(htmlObjArr,v)
			end
		elseif type(k) == "string" then
			if k == "_tag" then
				if v == "p" then
					content = "\n"
				elseif v == "br" then
					isBr = true
				end
			end
		end

		htmlObj.content = content
		htmlObj.isBr = isBr
		htmlObj.color = color
		htmlObj.href = href
		htmlObj.hrefTitle = hrefTitle

		if table.length(htmlObj) > 0 then
			htmlObjArr[#htmlObjArr+1] = htmlObj
		end
	end
end

--[[
	转换html颜色值
]]
function PCHtmlHelper:convertHtmlColor(color)
	color = string.gsub(color,"color: rgb%(","")
	-- echo("color====",color)
	index = string.find(color,"%)")
	if not index then
		return nil
	end

	color = string.sub(color,1,index-1)
	arr = string.split(color,",")

	-- echo("color===",color)
	newColor = ""
	for i=1,#arr do
		local value = string.format("%x",arr[i])
		if string.len(value) == 1 then
			value = "0" .. value
		end
		newColor = newColor .. value
	end

	return newColor
end

return PCHtmlHelper
