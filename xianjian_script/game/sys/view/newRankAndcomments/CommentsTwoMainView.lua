-- CommentsTwoMainView
--[[
	Author: wk
	Date:2018-01-15
]]

local CommentsTwoMainView = class("CommentsTwoMainView", UIBase);

function CommentsTwoMainView:ctor(winName)
    CommentsTwoMainView.super.ctor(self, winName)
end

function CommentsTwoMainView:loadUIComplete()
	self:registerEvent()
end 

function CommentsTwoMainView:registerEvent()
	CommentsTwoMainView.super.registerEvent(self);
	self.panel_2:setVisible(false) 
	self.panel_2.panel_sl:setVisible(false) 
	self.panel_2.panel_tishi:setVisible(false)
	-- self.UI_1:setVisible(false)
	self.txt_1:setVisible(false)
	self.panel_2.panel_kai:setVisible(false)
	-- self.panel_2.btn_close:setTouchedFunc(c_func(self.close, self))
	EventControler:dispatchEvent(BarrageEvent.BARRAGE_RANK_COMMENT_UI_EVENT);
end
function CommentsTwoMainView:clickClose()

	self:registClickClose("out")
	-- self.UI_1.btn_close:setTouchedFunc(c_func(self.close, self))
	-- self.UI_1.mc_1:setVisible(false)
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_newRank_001")) 
	-- self.UI_1:setVisible(true)
	self.panel_2.panel_kai:setVisible(true)
	local _type = FuncBarrage.BarrageSystemName.comments
	self.barrageOffOn = BarrageModel:getshowBarrage(_type)  ----获得弹幕开关
	self:setBarrageUI()
end

function CommentsTwoMainView:setBarrageUI()
	local frame = 1
	if self.barrageOffOn then
		frame = 1
	else
		frame = 2
	end
	self.panel_2.panel_kai.mc_1:showFrame(frame)
	self.panel_2.panel_kai:setTouchedFunc(c_func(self.setBarrageButton, self))
end

function CommentsTwoMainView:setBarrageButton()
	local panel =  self.panel_2.panel_kai
	local _type = FuncBarrage.BarrageSystemName.comments
	if self.barrageOffOn then
		panel.mc_1:showFrame(2)
		self.barrageOffOn = false
		EventControler:dispatchEvent(BarrageEvent.BARRAGE_UI_IS_NOT_SHOW);
		BarrageModel:setbarrageModeData(_type,false)
	else
		panel.mc_1:showFrame(1)
		EventControler:dispatchEvent(BarrageEvent.BARRAGE_UI_IS_SHOW);
		self.barrageOffOn = true
		BarrageModel:setbarrageModeData(_type,true)
	end



end

function CommentsTwoMainView:initData(arrayData,commentsInfo)

	self.panel_2:setVisible(true) 
	self.panel_2.panel_sl:setVisible(true) 
	local data = commentsInfo or RankAndcommentsModel:getAllCommentsInfoData() --用model里面的数据
	self.arrayData = arrayData 

	-- dump(data,"111111111111111111111")
	local commentsnum = table.length(data) -- 评论数量
	local sumnum = FuncRankAndcomments.COMMENTSSUMNUM
	if commentsnum > sumnum then
		commentsnum = sumnum
	end
	self.panel_2.panel_sl.txt_1:setString(GameConfig.getLanguage("#tid_newRank_002")..commentsnum)

	self:setScrollData(data)
	self:setInputButton()
end

--设置输入框
function CommentsTwoMainView:setInputButton()
	
	self.panel_2.btn_1:setTouchedFunc(c_func(self.sendServerData, self))
end

function CommentsTwoMainView:sendServerData()
		local sysName = FuncCommon.SYSTEM_NAME.COMMENT
		local isopen,level = FuncCommon.isSystemOpen(sysName)
		if not isopen then 
			WindowControler:showTips(level..GameConfig.getLanguage("#tid_newRank_003"));
			return 
		end
		local system = self.arrayData.systemName
		local diffID  = self.arrayData.diifID
		local count = RankAndcommentsModel:getNumBySystemAndDiffID(system,diffID)
		local suncount =  FuncRankAndcomments.getCommentNumber(system)
		if count - suncount >= 0 then
			WindowControler:showTips(FuncRankAndcomments.STR_EVERYDAY);
			return 
		end

	    local _text = self.panel_2.input_1:getText()
	    if string.find(_text," ") ~= nil then 
	    	WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_004"));	
	    	return 
	    end
        local  _size=string.len(_text);
        local  _other_size=string.len4cn2(_text);
        --//字数过少
        if(_other_size<=0)then
            WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_005"))--GameConfig.getLanguage("chat_words_too_little_1002"));
            return;
        end
		--//字数过多
        if(_other_size>100)then
           WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_006"))--GameConfig.getLanguage("chat_words_too_long_1003"));
           return;
        end

        local isbadword,_text = Tool:checkIsBadWords(_text)
        if isbadword == true then
            _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
            WindowControler:showTips(_tipMessage);
        else   
        	self.panel_2.input_1:setText("");
            self:sendContentToServer(_text);
        end
end
function CommentsTwoMainView:sendContentToServer(_text)
	-- echo("=====发送评论到服务器===",_text)

	local function _callback(param)
        if param.result ~= nil then
        	-- dump(param.result,"评论的返回数据====")
			local data = param.result.data
			local abandonIds = data.abandonIds
			local  commentData = {
				comment   = _text,
				dissCount = 0,
				doIDiss   = 0,
				doILike   = 0,
				id        = data.postId,
				likeCount = 0,
				name      = UserModel:name(),
				time      = TimeControler:getServerTime(),
				hot       = 0,
			}
			EventControler:dispatchEvent(BarrageEvent.COMMENTS_TO_BARRAGE_UI,commentData);
			RankAndcommentsModel:updateComments(commentData,abandonIds)
			WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_007"))
			self:initData(self.arrayData)
			local alldata = RankAndcommentsModel:getAllCommentsInfoData()
			self.panel_2.scroll_1:gotoTargetPos(table.length(alldata),1);
		end
    end

	local params = {
		system = self.arrayData.systemName,
		systemInnerIndex  = self.arrayData.diifID,
		content = _text,
	}

	RankAndcommentsServer:addCommentsToserver(params, _callback)

end



--设置滚动条数据
function CommentsTwoMainView:setScrollData(data)
		
	local alldata = data

	if table.length(alldata) == 0 then
		self.txt_1:setVisible(true)
	else
		self.txt_1:setVisible(false)
	end

	data = RankAndcommentsModel:commentsBuzzSort(data)

    self.panel_2.panel_tishi:setVisible(false)
    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(self.panel_2.panel_tishi);
        self:setCellView(baseCell, itemData)
        return baseCell;
    end
    local  function updateCellFunc(itemData,baseCell)
        self:setCellView(baseCell,itemData);
    end

    local  _scrollParams = {
        {
            data = data,
            createFunc = createRankItemFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 15,
            offsetY = 35,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -140, width = 750, height = 140},
            perFrame = 0,
        }
    }    


    self.panel_2.scroll_1:styleFill(_scrollParams);
    self.panel_2.scroll_1:hideDragBar()

end


function CommentsTwoMainView:setCellView(baseCell, itemData)
	-- dump(itemData,"2222222222222")
	local name = itemData.name or "玩蟹"
	baseCell.txt_name:setString(name)

	--是不是热评
	local isbuzz = false 
	if itemData.hot ~= nil and itemData.hot ~= 0 then
		isbuzz = true
	end
	
	baseCell.panel_hot:setVisible(isbuzz)


	local panel = baseCell.panel_zc
	local goodnum = itemData.likeCount or 0 ---赞的数量
	local sumcount = FuncRankAndcomments.GOODANDNOTGOOD
	if goodnum > sumcount then
		goodnum = "999+"
	end
	panel.txt_1:setString(goodnum)

	local poor = itemData.dissCount or 0 ---踩的数量
	if poor > sumcount then
		poor = "999+"
	end
	panel.txt_2:setString(poor)

	local mygood = itemData.doILike  --自己是赞
	local mypoor = itemData.doIDiss  --自己是踩
	local goodframe = 2
	local poorframe = 2
	if mygood == 1 then
		goodframe = 1
	end
	if mypoor == 1 then
		poorframe = 1
	end
	-- echo("=======goodframe========",goodframe,poorframe)
	panel.mc_1:showFrame(goodframe)
	panel.mc_2:showFrame(poorframe)

	--赞
	panel.mc_1:setTouchedFunc(c_func(self.buttonGood, self,itemData,panel));
	--踩
	panel.mc_2:setTouchedFunc(c_func(self.buttonPoor, self,itemData,panel));


	local content = itemData.comment or "临时用的数据"
	baseCell.rich_1:setString(content)

	baseCell.btn_jb:setVisible(false)
	baseCell.rich_1:setTouchedFunc(c_func(self.showReportButton, self,baseCell,itemData));

end

function CommentsTwoMainView:showReportButton(baseCell,itemData)
	-- echo("======举报======")
	baseCell.btn_jb:setVisible(true)
	baseCell.btn_jb:setTouchedFunc(c_func(self.SendReportButton, self,itemData));
end
function CommentsTwoMainView:SendReportButton(itemData)
	-- dump(itemData," \n\n显示玩家评论的数据 ====== ")

	
	WindowControler:showWindow("RankAndComentsTwoView",self.arrayData,itemData);

end


function CommentsTwoMainView:buttonGood(itemData,panel)
	echo("=======赞=======")

	local function _callback(param)
        if param.result ~= nil then
        	-- dump(param.result,"点赞的返回数据====")
			local commentData = param.result.data
			commentData.id = itemData.id
			local num = 0 
			if commentData.doILike == 1 then --点赞
				num = 1
				panel.mc_1:showFrame(1)
			else  --取消
				num = -1
				panel.mc_1:showFrame(2)
			end
			local sumNum =  itemData.likeCount
			local showNum = sumNum + num
			if showNum > FuncRankAndcomments.GOODANDNOTGOOD then
				showNum = "999+"
			end
			-- echo("=======showNum=======",itemData.likeCount,showNum)
			panel.txt_1:setString(showNum)
			RankAndcommentsModel:setPraiseAndStopOnData(1,commentData,num)
 			

			-- self:initData(self.arrayData)
		end
    end

	local params = {
		system  = self.arrayData.systemName,
		systemInnerIndex  = self.arrayData.diifID,
		postId = itemData.id,  
		type = 1,
	}
	RankAndcommentsServer:goodAndStopOnToServer(params, _callback)
end


function CommentsTwoMainView:buttonPoor(itemData,panel)
	local function _callback(param)
        if param.result ~= nil then
        	dump(param.result,"点踩的返回数据====")
			local commentData = param.result.data
			commentData.id = itemData.id
			local num = 0 
			if commentData.doIDiss == 1 then --踩
				num = 1
				panel.mc_2:showFrame(1)
			else  --取消
				num = -1
				panel.mc_2:showFrame(2)
			end
			local sumNum =  itemData.dissCount
			local showNum = sumNum + num
			if showNum > FuncRankAndcomments.GOODANDNOTGOOD then
				showNum = "999+"
			end
			panel.txt_2:setString(showNum)
			RankAndcommentsModel:setPraiseAndStopOnData(2,commentData,num)
			-- self:initData(self.arrayData)
			
		end
    end

	local params = {
		system  = self.arrayData.systemName,
		systemInnerIndex  = self.arrayData.diifID,
		postId = itemData.id,  
		type = 2,
	}
	RankAndcommentsServer:goodAndStopOnToServer(params, _callback)
end



function CommentsTwoMainView:close()

	self:startHide()
end

function CommentsTwoMainView:deleteMe()
	-- TODO
	CommentsTwoMainView.super.deleteMe(self);
end

return CommentsTwoMainView;
