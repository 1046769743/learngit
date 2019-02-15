-- ArtifactPreviewView
-- Author: Wk
-- Date: 2017-11-9
local ArtifactPreviewView = class("ArtifactPreviewView", UIBase);

function ArtifactPreviewView:ctor(winName)
    ArtifactPreviewView.super.ctor(self, winName);
end

function ArtifactPreviewView:loadUIComplete()
	self:registerEvent()
	self:initData()
end 

function ArtifactPreviewView:registerEvent()
	self:registClickClose("out")
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_012"))
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self,itemData),nil,true);
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
	-- self.btn_guize:setVisible(false)
end
function ArtifactPreviewView:paixuData(rewarddata)
	local newtable = {}
	-- dump(rewarddata,"11111111")
	for i=1,#rewarddata do
		local itemData = rewarddata[i]
		local itemtype = tostring(itemData[1])
		local itemid = itemData[2]

		local quality = FuncDataResource.getQualityById( itemtype,itemid )
		itemData[3] = quality

		newtable[i] = {
			_type = itemData[1],
			id = itemData[2],
			quality = quality,
		}
	end


	newtable = self:tableSort(newtable)

	return newtable
end
function ArtifactPreviewView:tableSort(arrdata)

   	table.sort(arrdata,function(a,b)

                local rst = false
                if a.quality > b.quality then
                    rst = true
                else
                    rst = false
                end 
                return rst
    end)
   return arrdata
end


function ArtifactPreviewView:initData()
	local alldata = FuncArtifact.getAllLotteryReward()
	local newData = {}
	-- dump(alldata,"1111111122222")
	for i=1,#alldata do
		local reward = alldata[i].reward
		if reward then
			for i=1,#reward do
				local rewards = string.split(reward[i], ",");
				if #rewards > 3 then
					rewards = {rewards[2],rewards[3]}
				end
				local pam = {
					[1] = rewards[1],
					[2] = rewards[2],

				}
				local iserve = false
				for _x = 1,#newData do
					if tonumber(pam[1]) == 1 then
						if newData[_x][2] == pam[2] then
							iserve = true
						end
					else
						if newData[_x][1] == pam[1] then
							iserve = true
						end
					end
				end
				if not iserve then
					table.insert(newData,pam)
				end
			end
		else
			for k,v in pairs(alldata[i]) do
				local reward = v.reward
				if reward then
					for i=1,#reward do
						local rewards = string.split(reward[i], ",");
						if #rewards > 3 then
							rewards = {rewards[2],rewards[3]}
						end
						local pam = {
							[1] = rewards[1],
							[2] = rewards[2],

						}
						local iserve = false
						for _x = 1,#newData do
							if tonumber(pam[1]) == 1 then
								if newData[_x][2] == pam[2] then
									iserve = true
								end
							else
								if newData[_x][1] == pam[1] then
									iserve = true
								end
							end
						end
						if not iserve then
							table.insert(newData,pam)
						end
					end
				end
			end
		end
	end

	newData = self:paixuData(newData)

	self.panel_kuang1:setVisible(false)
	local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_kuang1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = newData,
            createFunc = createRankItemFunc,
            perNums = 6,
            offsetX = 50,
            offsetY = 50,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -110, width = 100, height = 110},
            perFrame = 0,
        }
    }    

    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()

end

function ArtifactPreviewView:cellviewData(baseCell, itemData)

	-- local rewards = string.split(itemData, ",");
	local itemtype = itemData._type  ---tostring(itemData[1])
	local itemid = itemData.id


	-- newtable[i] = {
	-- 		_type = itemData[1],
	-- 		id = itemData[2],
	-- 		quality = quality,
	-- 	}


	local name = FuncDataResource.getResNameById(itemtype,itemid)
	local quality = FuncDataResource.getQualityById( itemtype,itemid )
	baseCell.mc_name:showFrame(quality)
	baseCell.mc_name:getViewByFrame(quality).txt_1:setString(name)
	baseCell.mc_kuang2:showFrame(quality)
	baseCell.mc_kuang:showFrame(quality)
	local icon = nil
	local scale = 1
	if itemtype == FuncDataResource.RES_TYPE.ITEM then
		local itemdata = FuncItem.getItemData(itemid)
		-- dump(itemdata,"3333333333333",7)
		if tonumber(itemdata.subType) == FuncArtifact.ItemsubType.CONSUME then
			icon = FuncRes.iconItem(itemid)
			scale = 102/80
		else
			icon = FuncRes.iconCimelia( itemdata.icon)
			scale = 0.6
		end
		
	else
		icon = FuncRes.iconRes(itemtype,itemid)
	end
	
	local sprite = display.newSprite(icon)
	sprite:setScale(scale)
	baseCell.ctn_2:addChild(sprite)

end


function ArtifactPreviewView:press_btn_close()

	self:startHide()
end


return ArtifactPreviewView;
