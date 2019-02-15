
local sqlite = {
	_dbname = false,
	_db = false,
}

if DEBUG_SERVICES then
	return {}
end

local lsqlite3 = require("lsqlite3")


function sqlite:init(dbname)
	self._dbname = dbname
	--self._db = lsqlite3.open(device.writablePath.."res/d/"..dbname)
	self._db = lsqlite3.open(device.writablePath..dbname)
	if not self._db then
		echoWarn("@sqlite:init(dbname) failed.")
		echo("path:",device.writablePath..dbname)
	end
	if S and S.DEBUG_TRACE_SQLITE then
		self._db:trace( function(ud, sql)
			echo("[Sqlite Trace]:", sql)
		end )
	end
end

function sqlite:exec(sql)
	self:assert_valid()
	self._db:exec(sql)
	local error_msg = self._db:errmsg()
	if error_msg ~= "not an error" then
		echo("!!!!! [Sqlite ERROR] !!!: "..sql.."\n"..error_msg)
	end
end


function sqlite:close(  )
	if self._db then
		self._db:close()
		self._db = nil
	end
	
end

function sqlite:assert_valid()
	assert(self._db,"sqlite need init.")
end


return sqlite
