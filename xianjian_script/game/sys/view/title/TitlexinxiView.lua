-- TitlexinxiView
--aouth wk
--time 2017/7/12

local TitlexinxiView = class("TitlexinxiView", UIBase);


function TitlexinxiView:ctor(winName)
    TitlexinxiView.super.ctor(self, winName);
end

function TitlexinxiView:loadUIComplete()
	self:registerEvent();

	self:setUIData()

	self:updateUI()
end 
function TitlexinxiView:setUIData()
	self.UI_1.btn_close:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_title_010")) 
	self.UI_1.mc_1:setVisible(false)
	self.UI_1:setTouchEnabled(true)
	self:registClickClose(-1, c_func( function()
            self:clickButtonBack()
    end , self))
	
end

	

function TitlexinxiView:updateUI()
	self.panel_1:setVisible(false)
	self.panel_2:setVisible(false)
    
    local attribute,notattribute =  TitleModel:battletostring()
    local newattribute = {}
    local newindex = 1
    if attribute ~= nil then
	    if #attribute ~= 0 then
	    	for i=1,#attribute do  --math.floor(i/2)
	    		if math.fmod(i,2) ~= 0 then
	    			newattribute[newindex] = {}
	    			newattribute[newindex][1] = attribute[i]
	    		else
	    			newattribute[newindex] = newattribute[newindex]   --.."   "..attribute[i]  ---空格表示位置
	    			newattribute[newindex][2] = attribute[i]
	    			newindex = newindex + 1
	    		end
	    	end
	    end
	end
    local createaddItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:updateListCellone(baseCell, itemData)
        return baseCell;
    end
    local createnotaddItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_2);
        self:updateListCelltwo(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = newattribute,
            createFunc = createaddItemFunc,
            perNums = 1,
            offsetX = 55,
            offsetY = 15,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = 0, width = 400, height = 40},
            perFrame = 1,
        }
    }    
    if notattribute ~= nil then
	    if #notattribute ~= 0 then
	    	local Params = {
	            data = notattribute,
	            createFunc = createnotaddItemFunc,
	            perNums = 1,
	            offsetX = 55,
	            offsetY = 15,
	            widthGap = 0,
	            heightGap = 0,
	            itemRect = {x = 0, y = -40, width = 400, height = 40},
	            perFrame = 1,
	        }
	        table.insert(_scrollParams,Params)
	    end
	end

    self.scroll_1:styleFill(_scrollParams);
    -- local _X = self.scroll_1:getPositionX()
    -- local _Y = self.scroll_1:getPositionY()
    -- self.scroll_1:setPosition(cc.p(_X - 50,_Y + 40))
end
function TitlexinxiView:updateListCellone(baseCell,itemData)
	-- echo("=====111111=====",itemData)
	baseCell.rich_1:setVisible(false)
	baseCell.rich_2:setVisible(false)
	if itemData[1] ~= nil then
		baseCell.rich_1:setVisible(true)
		baseCell.rich_1:setString(itemData[1])
	end
	if itemData[2] ~= nil then
		baseCell.rich_2:setVisible(true)
		baseCell.rich_2:setString(itemData[2])
	end

end
function TitlexinxiView:updateListCelltwo(baseCell,itemData)
	-- echo("=====222=====",itemData)
	baseCell.txt_1:setString(itemData)
end

function TitlexinxiView:clickButtonBack()
    self:startHide();

end




return TitlexinxiView;
