
--在str前面加上 重复 len -string.len(str) 次的 padding 
string.ljust = function(str, len, padding)
	if not str then return nil end
	len = len or 2
	padding = padding or "0"
	return string.rep(padding, len - string.len(str)) .. str
end

--在str后面加上 重复 len -string.len(str) 次的 padding 
string.rjust = function(str, len, padding)
	if not str then return nil end
	len = len or 2
	padding = padding or "0"
	return str .. string.rep(padding, len - string.len(str))
end

--获取某个位置的字符 
string.getChar = function(str,idx,def)
	def = def or "0"
	if not str then return def end
	if string.len(str)<idx then return def end
	return string.sub(str,idx,idx)
end

--设置某个位置的字符
string.setChar = function(chr,str,idx,def)
	def = def or "0"
	str = str or ""
	if string.len(str)<idx then str = string.rjust(str,idx,def) end --长度不够，右补齐
	return string.sub(str,1,idx-1)..chr..string.sub(str,idx+1)
end


--把字符串进行二次拆分 如果字符的最后一个字符串是 
-- 比如  a,b;c,d;e,f; 和  a,b;c,d;e,f  返回的结果是一样的
string.split2d = function(str,sep1,sep2)
	sep1 = sep1 or ";"
	sep2 = sep2 or ","
	local arr = string.split(str,sep1)
	if arr[#arr] == "" then
		table.remove(arr,#arr)
	end
	for i=1,#arr do

		local tmp = string.split(arr[i],sep2)
		arr[i] = tmp
	end
	return arr
end


local str = "a,b;c,d;e,f"
local arr = string.split2d(str,";",",")


--进行二次拆分同时把每个元素转化成 number
string.split2dN = function( str,sep1,sep2 )
	sep1 = sep1 or ";"
	sep2 = sep2 or ","
	local num
	local arr = string.split(str,sep1)
	for i=1,#arr do
		local tmp = string.split(arr[i],sep2)
		
		--先进行num转化
		if tmp then
			for k,v in ipairs(tmp) do
				num = tonumber(v)
				if num ==0  or not num then
					if v=="0" then
						tmp[k] = 0
					end
				else
					tmp[k] = num
				end
			end
		end
		arr[i] = tmp
		
	end
	return arr
end

--//截断count个字符,一个汉字设定为两个字节
--//从pos个字符开始
string.subcn=function (_text,pos,count)
    local  _size=string.len(_text);
    local  _index=1;
    local  _real_index=1
    local  _char_count=0;
    local  _real_count=0
    while(_real_index<pos)do
           local  _char=string.byte(_text,_index);
           if(_char<128)then
                   _index=_index+1;
           else
                   _index=_index+3;
           end
 --          assert(_char<=255,"out of bound");
           _real_index=_real_index+1;
           if(_real_index>=pos)then
                  break;
           end
    end
    _real_index=_index;
    while(_index<=_size)do
            local  _char=string.byte(_text,_index);
            local  _step=0;
            local  _inc=0;
            if(_char<128)then
                    _step=1;
                    _inc=1;
            elseif(_char<=255)then
                   _step=3;
                   _inc=2;
            end
            if(_real_count+1>count)then--可以肯定,这个必然是是一个汉字
--//需要精确截断
                   _index=_index-1;
                   break;
            elseif(_real_count+1==count)then
--//如果当前是汉字
                   if(_inc==2)then
                            _index=_index+2;
                   end
                   break;
            end
            _index=_index+_step;
            _char_count=_char_count+_inc;
 --           if(_real_count>=count) then  break end
            _real_count=_real_count+1;
    end
--//截断
   return  string.sub(_text,_real_index,_index);
end

string.len4cn2 = function(str)
	return #(string.gsub(str,'[\128-\255][\128-\255][\128-\255]','??'))
end

string.lenword=function(str)
   return  #(string.gsub(str,'[\128-\255][\128-\255][\128-\255]','?'))
end

-- 将字符串分割成数组，每个字符为一个元素
string.split2Array = function(str)
	local tab = {}
    for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do 
        tab[#tab+1] = uchar 
    end

    return tab
end

string.utf8to32 = function(utf8str)
	assert(type(utf8str) == "string")
	local res, seq, val = {}, 0, nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			table.insert(res, val)
			seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
			c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
			error("invalid UTF-8 character sequence")
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	table.insert(res, val)
	return res
end

--转化时间格式
function fmtSecToMMSS(sec)
	sec = checkint(sec)
	if sec<0 then sec = 0 end
	local str_sec =string.ljust(sec%60)
	local str_min =string.ljust(math.floor(sec/60))
	return string.format("%s:%s",str_min,str_sec)
end

--转化时间格式
function fmtSecToHHMM(sec)
	sec = checkint(sec)
	if sec<0 then sec = 0 end
	local str_hour = string.ljust(math.floor(sec/(60*60)))
	local str_min =string.ljust(math.floor(sec%(60*60)/60))
	return string.format("%s:%s",str_hour,str_min)
end


function fmtSecToHHMMSS(sec)
	sec = checkint(sec)
	if sec<0 then sec = 0 end
	local str_sec =string.ljust(sec%60)
	local str_min =string.ljust(math.floor(sec%(60*60)/60))
	local str_hour = string.ljust(math.floor(sec/(60*60)))
	return string.format("%s:%s:%s",str_hour,str_min,str_sec)
end

function fmtSecToLnDHHMMSS(sec)
	sec = checkint(sec)
	if sec<0 then sec = 0 end
	local str_sec =string.ljust(sec%60)
	local str_min =string.ljust(math.floor(sec%(60*60)/60))
	local str_hour = string.ljust(math.floor(sec%(60*60*24)/(60*60)))
	local int_day = math.floor(sec/(60*60*24))
	if int_day>0 then
		return string.format("%s天%s:%s:%s",tostring(int_day),str_hour,str_min,str_sec)
	else
		return string.format("%s:%s:%s",str_hour,str_min,str_sec)
	end
end
function fmtSecToLnDHM(sec)
	sec = checkint(sec)
	if sec<0 then sec = 0 end
	local str_min = (math.ceil(sec%(60*60)/60))
	local str_hour = (math.floor(sec%(60*60*24)/(60*60)))
	local int_day = math.floor(sec/(60*60*24))
	if int_day>0 then
		return string.format("%s天%s:%s",tostring(int_day),str_hour,str_min)
	else
		return string.format("%s:%s",str_hour,str_min)
	end
end

--转化字节
function fmtBytes(bytes)
	if bytes < 1024 then
		return string.format("%.2f B",bytes)
	end
	bytes = bytes / 1024
	if bytes < 1024 then
		return string.format("%.2f KB",bytes)
	end
	bytes = bytes / 1024
	return string.format("%.2f MB",bytes)
end

--是否是email
function string.isEmail(str)
	if string.len(str or "") < 6 then return false end
	local b,e = string.find(str or "", '@')
	local bstr = ""
	local estr = ""
	if b then
		bstr = string.sub(str, 1, b-1)
		estr = string.sub(str, e+1, -1)
	else
		return false
	end

	-- check the string before '@'
	local p1,p2 = string.find(bstr, "[%w_%-%.]+")
	if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

	-- check the string after '@'
	if string.find(estr, "^[%.]+") then return false end
	if string.find(estr, "%.[%.]+") then return false end
	if string.find(estr, "@") then return false end
	if string.find(estr, "[%.]+$") then return false end

	local _,count = string.gsub(estr, "%.", "")
	if (count < 1 ) or (count > 3) then
		return false
	end

	return true
end



--中文匹配符
local chiReq = "[\128-\255][\128-\255][\128-\255]"
function string.splitCharsStr( input, lineChars )
	local pos,arr = 1, {}
	local len = string.len(input)
	local resultArr = {}
	if len ==0 then
		return resultArr
	end
    -- 先把这个字符串按照字符拆分 中文字符也算一个字符拆分 同时记录长度
    for st,sp in function() return string.find(input, chiReq, pos) end do
    	if st >1 and pos < st then

    		for i=pos,st-1 do
    			table.insert(arr, { string.sub(input, i, i)  ,1 } )
    		end
    	end
        table.insert(arr, {string.sub(input, st, sp) ,2 } )
        pos = sp + 1
    end

    if pos <= len then
    	for i=pos,len do
			table.insert(arr, {string.sub(input, i, i) ,1 })
		end
    end


    local utfLength =0

    local tempStr = ""

    local arrleng = #arr

    for i,v in ipairs(arr) do
    	local str = v[1]
    	local len =v[2]
    	--如果大于一行的长度了
    	--echo(i,str,len, arrleng,"___aa",tempStr,utfLength)
    	if utfLength + len > lineChars then
    		table.insert(resultArr, tempStr)
    		tempStr = str
    		utfLength = len
    	else
    		
    		utfLength = utfLength + len
    		tempStr = tempStr ..str
    	end

    	if i == arrleng then
			table.insert(resultArr, tempStr)
		end
    end

    return resultArr
end


--现在是560像素宽度 18号尺寸,可以显示62个 通过比例 向下取余计算 一行文本可以显示多少个字符 24号 是 46个
--计算一行文本应该可以显示多少个字符,中文算2个 英文算一个 

local lineObj = {
	x1 = 18,
	y1 = 62,
	z1 = 560,

	x2 = 24,
	y2 = 45,
	z2 = 560,


	x3 = 18,
	y3 = 10,
	z3 = 96,

	x4 = 24,
	y4 = 70,
	z4 = 844,

}

lineObj.k = (lineObj.y2 - lineObj.y1) / (lineObj.x2-lineObj.x1)
lineObj.kz =(lineObj.y3 - lineObj.y1) / (lineObj.z3-lineObj.z1)


function string.countTextLineLength( textWid,textSize )
	--斜率k =(y2-y1)/(x2-x1) = -16/6
	--y = k*(x-x1) - y1
	local b = lineObj.k*(textSize   - lineObj.x1) + lineObj.y1
	--local bk = lineObj.kz *(textWid - lineObj.z1) + lineObj.y1
	local length = math.floor( b * textWid/ lineObj.z1 ) -1
	--echo(length,textSize,textWid,"____textSize")
	return length
end



--将文本转化成带换行符的字符串
function string.turnStrToLineStr( resStr,lineLength )
	local arr = string.turnStrToLineGroup(  resStr,lineLength)
	local resultStr = table.concat(arr,"\n")
	--echo(#arr,"____长度",resStr,lineLength)
	return resultStr

end


--转化字符串为数组
function string.turnStrToLineGroup(  resStr,lineLength)
	resStr = string.gsub(resStr, "\\n", "\n")
	local arr = string.split(resStr, "\n")
	local result ={}

	for i,v in ipairs(arr) do
		local tempArr =  string.splitCharsStr(v,lineLength) --self:splitOneStr(v)
		for k,s in ipairs(tempArr) do
			table.insert(result, s)
		end
	end
	return result
end


--把字符串转化成 自定义的 rich string
string.turnRichStr = function ( str,numColor )
	return "<color="..numColor ..  ">" .. str .."<->"
end

--[[
	str 中 是不是包含 subStr 包含返回true 否则返回false
]]
function string.isContainSubStr(str, subStr)
	return string.match(str, subStr) ~= nil and true or false;
end

--[[
	去空格
]]
function string.strip(str)
	return string.gsub(str," ","");
end

--[[
	去空格并且变小写
]]
function string.stripAndLower(str)
	local ret = string.gsub(str," ","");
	return string.lower(ret);
end



















