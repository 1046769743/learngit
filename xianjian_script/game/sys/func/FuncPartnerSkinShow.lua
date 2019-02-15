FuncPartnerSkinShow= FuncPartnerSkinShow or {}

local partnerSkinShow = nil


function FuncPartnerSkinShow.init()
	partnerSkinShow = require("partner.PartnerFirstMeet")
    
end



function FuncPartnerSkinShow.getPartnerSkinShowDataById(partnerId)
	local data = partnerSkinShow[tostring(partnerId)]
	if not data then
		echoError("\nPartnerFirstMeet中没有配置该奇侠的信息，partnerId==", partnerId)
	end
	return data
end

function FuncPartnerSkinShow.getDataByParIdAndType(partnerId, _type)
    -- body
    local data = partnerSkinShow[tostring(partnerId)]
    if not _type or _type == "" then
        _type = "1"
    end
    data = data[tostring(_type)]

    return data
end


--获取伙伴第一次show的时候坐标偏移
function FuncPartnerSkinShow.getFirstShowPos(partnerId  )
    local data = FuncPartnerSkinShow.getPartnerSkinShowDataById(partnerId)
    return data.pos or {0,0}
end
