require("lfs")

local FS = FS or {}
FS.__cache = {}


--传递一个文件路径返回他所在的目录
function FS.getDir(path)
	local index = 0
	local pos
	while(true) do
		index = string.find(path,'/',index+1)
		if index == nil then
			break
		end
		pos = index
	end
	if pos and pos>1 then
		return string.sub(path,1,pos-1)
	end
end

--传递一个文件路径返回文件名
function FS.getName(path)
	local index = 0
	local pos
	while(true) do
		index = string.find(path,'/',index+1)
		if index == nil then
			break
		end
		pos = index
	end
	if pos and pos<string.len(path)  then
		return string.sub(path,pos+1)
	end
end

--判定文件存在
function FS.exists(path)
	if FS.__cache[path] then
		return true
	end
	local res = cc.FileUtils:getInstance():isFileExist(path)
	if res then
		FS.__cache[path] = true
	end
	return res
end

--创建目录
function FS.mkDir(path)
	path = string.gsub(path,'\\','/')
	cc.FileUtils:getInstance():createDirectory(path)
	
	--[[
	if device.platform == "windows" then
		os.execute("mkdir "..string.gsub(path, '/', '\\'))
    else
		os.execute("mkdir -p "..path)
	end
	--]]
end

--删除文件
function FS.removeFile(filePath)
	os.remove(filePath);
end

--删除目录及子目录
function FS.removeDir(path)
	path = string.gsub(path,'\\','/')
	if FS.exists(path) then
		local function _rmDir(path)
			local iter, dir_obj = lfs.dir(path)
			while true do
				local dir = iter(dir_obj)
				if dir == nil then break end
				if dir ~= "." and dir ~= ".." then
					local curDir = path.."/"..dir
					local mode = lfs.attributes(curDir, "mode")
					if mode == "directory" then
						_rmDir(curDir)
					elseif mode == "file" then
						os.remove(curDir)
					end
				end
			end
			lfs.rmdir(path)
			FS.__cache[path] = nil
		end
		_rmDir(path)
	end
--[[
	if device.platform == "windows" then
		os.execute("rd /s /q ".. string.gsub(path, '/', '\\'))
	else
		os.execute("rm -rf " .. path)
	end
--]]
end

--[[
	复制文件
	source: 源路径
	target:目标路径
 ]]
function FS.copy(source,target)
	echo("@FS.copy source",source,"target",target)
	local sourceFile = io.open(source,"rb")
	if not sourceFile then
		return false
	end
	local sourceStr = sourceFile:read("*a")
	local prePath = FS.getDir(target)
	if prePath then
		FS.mkDir(prePath)
	end
	local targetFile = io.open(target,"wb")
	if not targetFile then
		return false
	end
	targetFile:write(sourceStr)
	sourceFile:close()
	targetFile:close()
	return true
end


--获取指定目录的所有文件夹
function FS.getDirList(path)
	-- body
end

--获取指定目录的所有文件(不包括文件夹)
function FS.getFileList(path)
	local fileArray = {};
	for file in lfs.dir(path) do
		-- echo("---file---", file);
		local curDir = path..file
		local mode = lfs.attributes(curDir, "mode")
		if mode == "file" then
			table.insert(fileArray, curDir);
		end
	end
	return fileArray;
end

--读文件内容
function FS.readFileContent(path)
	-- local sourceFile =  io.open(path,"rb");
	
	-- if not sourceFile then

	-- 	return false
	-- end
	-- local sourceStr = sourceFile:read("*a")
	-- sourceFile:close()

	-- return sourceStr;
	return  cc.FileUtils:getInstance():getStringFromFile(path)
end

return FS








