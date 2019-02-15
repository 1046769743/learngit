--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-FuncLineUp
]]
FuncLineUp = FuncLineUp or {}

local bgData = nil

function FuncLineUp.init()
	bgData = Tool:configRequire("teaminfo.Teaminfo")
end

function FuncLineUp.test()
	dump(bgData, "bgData")
end

function FuncLineUp.getConditionById( id )
	local data = bgData[tostring(id)] or {}
	return table.copy(data.condition or {})
end

function FuncLineUp.getImageById( id )
	local data = bgData[tostring(id)] or {}
	return FuncRes.iconBg(data.scene)
end

function FuncLineUp.getContentById( id )
	local data = bgData[tostring(id)] or {}
	if data.content then
		return GameConfig.getLanguage(data.content)
	else
		return  ""
	end
end

function FuncLineUp.getBgNameById( id )
	local data = bgData[tostring(id)] or {}
	if data.name then
		return GameConfig.getLanguage(data.name)
	else
		return ""
	end
end

function FuncLineUp.getIconById( id )
	local data = bgData[tostring(id)] or {}
	return FuncRes.iconLineUp( data.icon )
end
-- 检查条件
function FuncLineUp._checkConditionVaild( condition )
	local t,v = condition.t,condition.v
	local funcs = { -- 检查函数
		[10001] = function( v ) -- 集赞数量
			return tonumber(LineUpModel:getMaxPraiseNum()) >= tonumber(v)
		end,
	}
	if not funcs[t] then
		echoError("FuncLineUp._checkConditionVaild 没有对应条件", condition.t)
		return false
	end
	return funcs[t](v)
end
-- 检查一组条件
function FuncLineUp.checkConditionVaild( conditions )
	for i,v in ipairs(conditions) do
		if not FuncLineUp._checkConditionVaild(v) then return false end
	end

	return true
end
-- 检查某背景是否拥有
function FuncLineUp.checkHasBg( id )
	local conditions = FuncLineUp.getConditionById(id)
	local conCommon = {} -- 通用条件
	local conSelf = {} -- 自用条件（t > 10000）
	-- 过滤
	for i,v in ipairs(conditions) do
		if v.t > 10000 then
			table.insert(conSelf, v)
		else
			table.insert(conCommon, v)
		end
	end

	return ((UserModel:checkCondition( conCommon ) == nil) and FuncLineUp.checkConditionVaild(conSelf))
end

function FuncLineUp.getBgList()
	local list = {}

	for k,v in pairs(bgData) do
		table.insert(list, table.copy(v))
	end

	table.sort(list, function( a,b )
		return tonumber(a.id) < tonumber(b.id)
	end)

	return list
end

function FuncLineUp.initNpc( data )
	local sp = nil
	if data.isChar then
		if data.isSelf then
			sp = GarmentModel:getCharGarmentSpine()
		else
			sp = GarmentModel:getSpineViewByAvatarAndGarmentId(data.avatar, data.garmentId)
		end
		-- FuncChar.getSpineAni(data.avatar, data.level)
	else
		-- sp = FuncPartner.getHeroSpine(data.id)
		local sourceId = FuncPartner.getPartnerSourceidByIdAndSkin(tostring(data.id),data.skin)
		local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
		local spineName = sourceCfg.spine
		local charView = ViewSpine.new(spineName, {}, nil, spineName)
		charView.actionArr = sourceCfg
		charView:playLabel(charView.actionArr.stand, true)
		sp = charView
	end
	
	-- sp:setScale(1.7)
	-- PartnerModel:initNpc(_partnerId)
	return sp
end

-- 获取一个容器内的节点的texture（用于截屏）
function FuncLineUp.getViewTexture( view )
	local render_texture = cc.RenderTexture:create(GameVars.width, GameVars.height)

	render_texture:begin()
	view:visit()
	render_texture:endToLua()

	local texture = render_texture:getSprite():getTexture()

	return texture
end