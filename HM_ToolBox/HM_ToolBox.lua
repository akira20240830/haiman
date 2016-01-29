--
-- ���������ʵ��С����
--

local _i = Table_GetItemName
HM_ToolBox = {
	bAutoRepair = true,	-- �� NPC ���Զ�����
	bSellGray = true,		-- �� NPC ���Զ�������ɫ��Ʒ
	bSellWhiteBook2 = false,	-- �Զ������Ѷ�����
	bSellGreenBook = false,	-- �Զ������Ѷ�����
	bSellBlueBook = false,	-- �Զ������Ѷ�����
	tSellItem = {
		[_i(3098)--[[��Ҷ��]]] = true,
		[_i(7954)--[[����Ҷ��]]] = true,
		[_i(7955)--[[��Ƭ����Ҷ��]]] = true,
		[_i(7956)--[[���ĩ]]] = true,
		[_i(7957)--[[��Ҷ��]]] = true,
		[_i(7958)--[[��Ƭ��Ҷ��]]] = true,
		[_i(69697)--[[����]]] = true,
		[_i(69698)--[[���]]] = true,
		[_i(69699)--[[��ש]]] = true,
		[_i(70471)--[[��Ҷ�ӡ�����֮��]]] = true,
		[_i(151712)--[[����Ľ�����]]] = true,
	},
	bBuyMore = true,		-- ��ø���
	bDurability = true,			-- ��ʾװ���;ö�
	bShiftAuction = true,	-- �� shift һ������
	bAutoStack = true,	-- һ���ѵ�������+�ֿ⣩
	bAutoDiamond2 = false,	-- ����ʯ������ɺ��Զ��ٰ��ϴβ���
	-- bAnyDiamond = false,	-- ��������ʯ��ɫ��ֻ���ǵȼ�
	bChatTime = true,		-- ���츴�Ƶ�
	bWhisperAt = true,	-- ��¼��������
	bSplitter2 = false,	-- ������
	bGuildBankSort = true,	-- ���ֿ�����
	nBroadType = 0,
	szBroadText = "Hi, nihao",
}
HM.RegisterCustomData("HM_ToolBox")

-- �ݲ���¼��ѡ��
HM_ToolBox.bIgnoreRaid = false

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_ToolBox = {}

-- ��ȡ�Զ��������ò˵�
_HM_ToolBox.GetSellMenu = function()
	local m0 = {
		{ szOption = _L["Sell grey items"], bCheck = true, bChecked = HM_ToolBox.bSellGray,
			fnAction = function(d, b) HM_ToolBox.bSellGray = b end,
		}, { szOption = _L["Sell white books"], bCheck = true, bChecked = HM_ToolBox.bSellWhiteBook2,
			fnAction = function(d, b) HM_ToolBox.bSellWhiteBook2 = b end,
			fnDisable = function() return not HM_ToolBox.bSellGray end
		}, { szOption = _L["Sell green books"], bCheck = true, bChecked = HM_ToolBox.bSellGreenBook,
			fnAction = function(d, b) HM_ToolBox.bSellGreenBook = b end,
			fnDisable = function() return not HM_ToolBox.bSellGray end
		}, { szOption = _L["Sell blue books"], bCheck = true, bChecked = HM_ToolBox.bSellBlueBook,
			fnAction = function(d, b) HM_ToolBox.bSellBlueBook = b end,
			fnDisable = function() return not HM_ToolBox.bSellGray end
		}, {
			bDevide = true,
		},
	}
	local m1 = { szOption = _L["Sell specified items"], fnDisable = function() return not HM_ToolBox.bSellGray end,
		{ szOption = _L["* New *"],
			fnAction = function()
				GetUserInput(_L["Name of item"], function(szText)
					local szText =  string.gsub(szText, "^%s*%[?(.-)%]?%s*$", "%1")
					if szText ~= "" then
						HM_ToolBox.tSellItem[szText] = true
					end
				end)
			end
		}, {
			bDevide = true,
		},
	}
	for k, v in pairs(HM_ToolBox.tSellItem) do
		table.insert(m1, {
			szOption = k, bCheck = true, bChecked = v, fnAction = function(d, b) HM_ToolBox.tSellItem[k] = b end,
			{ szOption = _L["Remove"], fnAction = function() HM_ToolBox.tSellItem[k] = nil end }
		})
	end
	table.insert(m0, m1)
	return m0
end

-- �Զ�����ɫ����Ʒ
_HM_ToolBox.SellGrayItem = function(nNpcID, nShopID)
	local me = GetClientPlayer()
	for dwBox = 1, BigBagPanel_nCount do
		local dwSize = me.GetBoxSize(dwBox) - 1
		for dwX = 0, dwSize do
			local item = me.GetItem(dwBox, dwX)
			if item and item.bCanTrade then
				local bSell = item.nQuality == 0
				local szName = GetItemNameByItem(item)
				if not bSell and item.nGenre == ITEM_GENRE.BOOK
					and me.IsBookMemorized(GlobelRecipeID2BookID(item.nBookID))
				then
					if (HM_ToolBox.bSellWhiteBook2 and item.nQuality == 1)
						or (HM_ToolBox.bSellGreenBook and item.nQuality == 2)
						or (HM_ToolBox.bSellBlueBook and item.nQuality == 3)
					then
						bSell = true
					end
				end
				if bSell or HM_ToolBox.tSellItem[szName] then
					local nCount = 1
					if item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.ARROW then --Զ������
						nCount = item.nCurrentDurability
					elseif item.bCanStack then
						nCount = item.nStackNum
					end
					SellItem(nNpcID, nShopID, dwBox, dwX, nCount)
				end
			end
		end
	end
end

-- �����û��Ȩ��
_HM_ToolBox.HasBroadPerm = function()
	local tong, me = GetTongClient(), GetClientPlayer()
	if me and me.dwTongID ~= 0 and tong then
		local info = tong.GetMemberInfo(me.dwID)
		return tong.CheckBaseOperationGroup(info.nGroupID, 1)
	end
	return false
end

-- Ⱥ���Ŷ�����
_HM_ToolBox.SendBroadRaid = function()
	local team, me = GetClientTeam(), GetClientPlayer()
	if not team or not me or not me.IsInParty() then
		return
	end
	for _, dwID in ipairs(team.GetTeamMemberList()) do
		if dwID ~= me.dwID then
			local info = team.GetMemberInfo(dwID)
			if info and info.bIsOnLine and dwID ~= me.dwID then
				HM.Talk(info.szName, _L["[Party BC] "] .. HM_ToolBox.szBroadText)
			end
		end
	end
end

-- Ⱥ���㲥
_HM_ToolBox.SendBroadCast = function()
	if HM_ToolBox.nBroadType == 3 then
		return _HM_ToolBox.SendBroadRaid()
	end
	local tong, me = GetTongClient(), GetClientPlayer()
	if not tong or not me or me.dwTongID == 0 then
		return
	end
	local dwMapID, szText, nType = me.GetScene().dwMapID, HM_ToolBox.szBroadText, HM_ToolBox.nBroadType
	HM.BgTalk(PLAYER_TALK_CHANNEL.TONG, "HM_BROAD", nType, dwMapID, szText)
	HM.Sysmsg(_L["[Guild BC] "] .. szText)
	-- UI������: 1���ť�ָ�����������һֱ����������ˢ����
	local btn = this
	btn:Enable(false)
	HM.DelayCall(1000, function()
		if btn and btn:IsValid() then
			btn:Enable(true)
		end
	end)
	--[[
	local aPlayer = tong.GetMemberList(false, "name", false, -1, -1)
	for _, v in pairs(aPlayer) do
		local info = tong.GetMemberInfo(v)
		if nType == 0 or (nType == 1 and dwMapID ~= info.dwMapID) or (nType == 2 and dwMapID == info.dwMapID) then
			HM.Talk(info.szName, _L["[Guild BC] "] .. szText)
		end
	end
	--]]
end

-- һ���ϼܽ�����
_HM_ToolBox.GetAuctionPrice = function(h, g, s, c)
	local t = {}
	t.nGold = tonumber(h:Lookup(g):GetText()) or 0
	t.nSliver = tonumber(h:Lookup(s):GetText()) or 0
	t.nGoldB = tonumber(h:Lookup(c):GetText()) or 0
	return t
end

-- ת��Ϊ����
_HM_ToolBox.GetSinglePrice = function(t, nNum)
	local t2 = {}
	local nSliver = math.floor((t.nGoldB * 1000000 + t.nGold * 100 + t.nSliver) / nNum)
	t2.nGold = math.floor(nSliver / 100)
	t2.nSliver = nSliver % 100
	return t2
end

_HM_ToolBox.IsSameItem = function(item, item2)
	if not item2 or not item2.bCanTrade then
		return false
	end
	if GetItemNameByItem(item) == GetItemNameByItem(item2) and item.nGenre == item2.nGenre then
		return true
	end
	if item.nGenre == ITEM_GENRE.BOOK and item2.nGenre == ITEM_GENRE.BOOK and item.nQuality == item2.nQuality then
		return true
	end
	return false
end

_HM_ToolBox.AuctionSell = function(frame)
	local wnd = frame:Lookup("PageSet_Totle/Page_Auction/Wnd_Sale")
	local box = wnd:Lookup("", "Box_Item")
	local szTime = wnd:Lookup("", "Text_Time"):GetText()
	local nTime = tonumber(string.sub(szTime, 1, 2))
	-- check item
	local me = GetClientPlayer()
	local item = me.GetItem(box.dwBox, box.dwX)
	if not item or item.szName ~= box.szName then
		AuctionPanel.ClearBox(box)
		AuctionPanel.UpdateSaleInfo(frame, true)
		return RemoveUILockItem("Auction")
	end
	-- count price
	box.tBidPrice = _HM_ToolBox.GetAuctionPrice(wnd, "Edit_OPGold", "Edit_OPSilver", "Edit_OPGoldB")
	box.tBuyPrice = _HM_ToolBox.GetAuctionPrice(wnd, "Edit_PGold", "Edit_PSilver", "Edit_PGoldB")
	box.szTime = szTime
	local nStackNum = item.nStackNum
	if not item.bCanStack then
		nStackNum = 1
	end
	local tSBidPrice = _HM_ToolBox.GetSinglePrice(box.tBidPrice, nStackNum)
	local tSBuyPrice = _HM_ToolBox.GetSinglePrice(box.tBuyPrice, nStackNum)
	local AtClient = GetAuctionClient()
	FireEvent("SELL_AUCTION_ITEM")
	for i = 1, BigBagPanel_nCount do
		if me.GetBoxSize(i) > 0 then
			for j = 0, me.GetBoxSize(i) - 1 do
				local item2 = me.GetItem(i, j)
				if _HM_ToolBox.IsSameItem(item, item2) then
					local nNum = item2.nStackNum
					if not item2.bCanStack then
						nNum = 1
					end
					AtClient.Sell(AuctionPanel.dwTargetID, i, j,
						math.floor(tSBidPrice.nGold * nNum), math.floor(tSBidPrice.nSliver * nNum), 0,
						math.floor(tSBuyPrice.nGold * nNum), math.floor(tSBuyPrice.nSliver * nNum), 0,
						nTime)
				end
			end
		end
	end
	PlaySound(SOUND.UI_SOUND, g_sound.Trade)
end

-- �滻�ϼܺ���
_HM_ToolBox.AuctionPanel_AuctionSell = AuctionPanel.AuctionSell
AuctionPanel.AuctionSell = function(...)
	if not _HM_ToolBox.CheckUnLock() then  -- û�н���ʱ ʹ�ùٷ��ĺ����жϽ���
		return _HM_ToolBox.AuctionPanel_AuctionSell(...)
	end
	if IsShiftKeyDown() and HM_ToolBox.bShiftAuction then
		_HM_ToolBox.AuctionSell(...)
	else
		_HM_ToolBox.AuctionPanel_AuctionSell(...)
	end
end

-- ��ȡ����ʯ����
_HM_ToolBox.GetDiamondData = function(dwBox, dwX)
	if not dwX then
		dwBox, dwX = select(2, dwBox:GetObjectData())
	end
	local d, item = {}, GetClientPlayer().GetItem(dwBox, dwX)
	d.dwBox, d.dwX = dwBox, dwX
	if item then
		d.level = string.match(item.szName, _L["DiamondRegex"])
		d.id, d.bind, d.num, d.detail = item.nUiId, item.bBind, item.nStackNum, item.nDetail
		d.dwTabType, d.dwIndex = item.dwTabType, item.dwIndex
	end
	return d
end

-- get refine
_HM_ToolBox.GetRefineHandle = function()
	local handle = Station.Lookup("Normal/CastingPanel/PageSet_All/Page_Refine", "")
	return assert(handle, "Can not find handle")
end

-- ��������ʯ��������
_HM_ToolBox.SaveDiamondFormula = function()
	local t = {}
	local handle = _HM_ToolBox.GetRefineHandle()
	local box, hL = handle:Lookup("Handle_BoxItem/Box_Refine"), handle:Lookup("Handle_RefineExpend")
	table.insert(t, _HM_ToolBox.GetDiamondData(box))
	for i = 1, 16 do
		local box = hL:Lookup("Box_RefineExpend_" .. i)
		if box:IsObjectEnable() and box:GetObjectData() ~= -1 then
			table.insert(t, _HM_ToolBox.GetDiamondData(box))
		end
	end
	_HM_ToolBox.dFormula = t
end

-- ɨ�豳��ʯͷ����λ��Ϣ������ buggy cache��
_HM_ToolBox.LoadBagDiamond = function()
	local me, t = GetClientPlayer(), {}
	for dwBox = 1, BigBagPanel_nCount do
		for dwX = 0, me.GetBoxSize(dwBox) - 1 do
			local d = _HM_ToolBox.GetDiamondData(dwBox, dwX)
			if not d.id or d.level then
				for _, v in ipairs(_HM_ToolBox.dFormula) do
					if v.dwBox == dwBox and v.dwX == dwX then
						d = nil
					end
				end
				if d then
					table.insert(t, d)
				end
			end
		end
	end
	_HM_ToolBox.tBagCache = t
end

-- ��ԭ�����������ʯͷ��ʧ�ܷ��� false���ɹ����� true
_HM_ToolBox.RestoreBagDiamond = function(d)
	local me = GetClientPlayer()
	local tBag = _HM_ToolBox.tBagCache
	-- move box item
	local item = me.GetItem(d.dwBox, d.dwX)
	-- to stack
	if item then
		for k, v in ipairs(tBag) do
			if v.id == item.nUiId and v.bind == item.bBind and (v.num + item.nStackNum) <= item.nMaxStackNum then
				v.num = v.num + item.nStackNum
				me.ExchangeItem(d.dwBox, d.dwX, v.dwBox, v.dwX)
				item = nil
				break
			end
		end
	end
	-- to empty
	if item then
		for k, v in ipairs(tBag) do
			if not v.id then
				local v2 = _HM_ToolBox.GetDiamondData(d.dwBox, d.dwX)
				v2.dwBox, v2.dwX = v.dwBox, v.dwX
				tBag[k] = v2
				me.ExchangeItem(d.dwBox, d.dwX, v.dwBox, v.dwX)
				item = nil
				break
			end
		end
	end
	-- no freebox
	if item then
		return false
	end
	-- group bag by type/bind: same type, same bind, ... others
	local tBag2, nLeft = {}, d.num
	for _, v in ipairs(tBag) do
		if v.level == d.level and (v.bind == d.bind or v.bind == false) then
			local vt = nil
			for _, vv in ipairs(tBag2) do
				if vv.bind == v.bind then
					vt = vv
					break
				end
			end
			if not vt then
				vt = { num = 0, bind = v.bind }
				local vk = #tBag2 + 1
				if vk > 1 then
					if v.bind ~= d.bind then
						vk = 2
					else
						vk = 1
					end
				end
				table.insert(tBag2, vk, vt)
			end
			vt.num = vt.num + v.num
			table.insert(vt, v)
		end
	end
	-- select diamond1 (same type)
	for _, v in ipairs(tBag2) do
		if v.num >= nLeft then
			for _, vv in ipairs(v) do
				if vv.num >= nLeft then
					me.ExchangeItem(vv.dwBox, vv.dwX, d.dwBox, d.dwX, nLeft)
					vv.num = vv.num - nLeft
					break
				elseif vv.num > 0 then
					me.ExchangeItem(vv.dwBox, vv.dwX, d.dwBox, d.dwX, vv.num)
					nLeft = nLeft - vv.num
					vv.num = 0
				end
			end
			return true
		end
	end
	return false
end

-- �ѵ�һ�� box
_HM_ToolBox.DoBoxStack = function(i, tList)
	local me = GetClientPlayer()
	for j = 0, me.GetBoxSize(i) - 1 do
		local item = me.GetItem(i, j)
		if item and item.bCanStack and item.nStackNum < item.nMaxStackNum then
			--local szKey = tostring(item.nUiId) .. tostring(item.bBind)
			local szKey = tostring(item.dwTabType) .. "_" .. tostring(item.dwIndex)
			local t = tList[szKey]
			if not t then
				tList[szKey] = { nLeft = item.nMaxStackNum - item.nStackNum, dwBox = i, dwX = j }
			elseif item.nStackNum <= t.nLeft then
				me.ExchangeItem(i, j, t.dwBox, t.dwX, item.nStackNum)
				if t.nLeft == item.nStackNum then
					tList[szKey] = nil
				else
					t.nLeft = t.nLeft - item.nStackNum
				end
			else
				local nLeft = item.nStackNum - t.nLeft
				me.ExchangeItem(i, j, t.dwBox, t.dwX, t.nLeft)
				t.nLeft, t.dwBox, t.dwX = nLeft, i, j
			end
		end
	end
end

-- �����ѵ�
_HM_ToolBox.DoBagStack = function()
	if IsBagInSort() then
		return
	end
	local tList = {}
	for i = 1, BigBagPanel_nCount do
		_HM_ToolBox.DoBoxStack(INVENTORY_INDEX.PACKAGE + i - 1, tList)
	end
end

-- �ֿ�ѵ�
_HM_ToolBox.DoBankStack = function()
	if IsBankInSort() then
		return
	end
	local tList = {}
	for i = 1, 6 do
		_HM_ToolBox.DoBoxStack(INVENTORY_INDEX.BANK + i - 1, tList)
	end
end

-- ������Ӷѵ���Ŧ
_HM_ToolBox.BindStackButton = function()
	-- bag
	local btn1 = Station.Lookup("Normal/BigBagPanel/Btn_Split")
	local btn2 = Station.Lookup("Normal/BigBagPanel/Btn_Stack2")
	if not HM_ToolBox.bAutoStack then
		if btn2 then
			btn2:Destroy()
			btn1.nX, btn1.nY = nil, nil
		end
	elseif btn1 then
		local nX, nY = btn1:GetRelPos()
		if nX ~= btn1.nX or nY ~= btn1.nY then
			btn1.nX, btn1.nY = nX, nY
			if not btn2 then
				local w, h = btn1:GetSize()
				btn2 = HM.UI("Normal/BigBagPanel"):Append("WndButton", "Btn_Stack2", { txt = _L["Stack"], w = w, h = h }):Raw()
				btn2.OnLButtonClick = _HM_ToolBox.DoBagStack
			end
			btn2:SetRelPos(nX + btn1:GetSize(), nY)
		end
	end
	-- bank
	local btn1 = Station.Lookup("Normal/BigBankPanel/Btn_CU")
	local btn2 = Station.Lookup("Normal/BigBankPanel/Btn_Stack2")
	if not HM_ToolBox.bAutoStack then
		if btn2 then
			btn2:Destroy()
			btn1.nX, btn1.nY = nil, nil
		end
	elseif btn1 then
		local nX, nY = btn1:GetRelPos()
		if nX ~= btn1.nX or nY ~= btn1.nY then
			btn1.nX, btn1.nY = nX, nY
			if not btn2 then
				local w, h = btn1:GetSize()
				btn2 = HM.UI("Normal/BigBankPanel"):Append("WndButton", "Btn_Stack2", { txt = _L["Stack"], w = w, h = h }):Raw()
				btn2.OnLButtonClick = _HM_ToolBox.DoBankStack
			end
			btn2:SetRelPos(nX + btn1:GetSize(), nY)
		end
	end
	-- guild bank sort/stack
	local btn1 = Station.Lookup("Normal/GuildBankPanel/Btn_Refresh")
	local btn2 = Station.Lookup("Normal/GuildBankPanel/Btn_Sort2")
	local btn3 = Station.Lookup("Normal/GuildBankPanel/Btn_Stack2")
	if not HM_ToolBox.bGuildBankSort then
		if btn2 then
			btn2:Destroy()
		end
		if btn3 then
			btn3:Destroy()
		end
	elseif btn1 then
		if not btn2 then
			local x, y = btn1:GetRelPos()
			local w, h = btn1:GetSize()
			btn2 = HM.UI("Normal/GuildBankPanel"):Append("WndButton", "Btn_Sort2", { txt = _L["Sort"], w = w, h = h }):Raw()
			btn2:SetRelPos(x - btn1:GetSize(), y)
			btn2.OnLButtonClick = _HM_ToolBox.SortGuildBank
		end
		if not btn3 then
			local x, y = btn2:GetRelPos()
			local w, h = btn2:GetSize()
			btn3 = HM.UI("Normal/GuildBankPanel"):Append("WndButton", "Btn_Stack2", { txt = _L["Stack"], w = w, h = h }):Raw()
			btn3:SetRelPos(x - btn2:GetSize(), y)
			btn3.OnLButtonClick = _HM_ToolBox.StackGuildBank
		end
	end
end

-- ���ֿ�ѵ�
_HM_ToolBox.StackGuildBank = function()
	local frame = Station.Lookup("Normal/GuildBankPanel")
	if not frame then
		return
	end
	local nPage = frame.nPage or 0
	local bTrigger
	local fnFinish = function()
		local btn = Station.Lookup("Normal/GuildBankPanel/Btn_Stack2")
		if btn then
			btn:Enable(1)
			Station.Lookup("Normal/GuildBankPanel/Btn_Sort2"):Enable(1)
		end
		HM.RegisterEvent("TONG_EVENT_NOTIFY.stack", nil)
		HM.RegisterEvent("UPDATE_TONG_REPERTORY_PAGE.stack", nil)
	end
	local fnLoop = function()
		local me, tList = GetClientPlayer(), {}
		bTrigger = true
		for i = 1, INVENTORY_GUILD_PAGE_SIZE do
			local dwX = nPage * INVENTORY_GUILD_PAGE_SIZE + i - 1
			local item = GetPlayerItem(me, INVENTORY_GUILD_BANK, dwX)
			if item and item.bCanStack and item.nStackNum < item.nMaxStackNum then
				local szKey = tostring(item.dwTabType) .. "_" .. tostring(item.dwIndex)
				local dwX2 = tList[szKey]
				if not dwX2 then
					tList[szKey] = dwX
				else
					OnExchangeItem(INVENTORY_GUILD_BANK, dwX, INVENTORY_GUILD_BANK, dwX2)
					return
				end
			end
		end
		fnFinish()
	end
	frame:Lookup("Btn_Stack2"):Enable(0)
	frame:Lookup("Btn_Sort2"):Enable(0)
	HM.RegisterEvent("UPDATE_TONG_REPERTORY_PAGE.stack", fnLoop)
	HM.RegisterEvent("TONG_EVENT_NOTIFY.stack", function()
		-- TONG_EVENT_CODE.TAKE_REPERTORY_ITEM_PERMISSION_DENY_ERROR
		if arg0 == 61 then
			fnFinish()
		end
	end)
	HM.DelayCall(1000, function()
		if not bTrigger then
			fnFinish()
		end
	end)
	fnLoop()
	bTrigger = false
end

-- ���ֿ�����
_HM_ToolBox.SortGuildBank = function()
	local frame = Station.Lookup("Normal/GuildBankPanel")
	if not frame then
		return
	end
	local nPage = frame.nPage or 0
	local dwBagBox, dwBagX = HM.GetFreeBagBox()
	if not dwBagBox then
		return OutputMessage("MSG_ANNOUNCE_RED", g_tStrings.GUILD_BANK_ERROR_BAG_IS_FULL)
	end
	-- compare func
	local aGenre = {
		[ITEM_GENRE.TASK_ITEM] = 1,
		[ITEM_GENRE.EQUIPMENT] = 2,
		[ITEM_GENRE.BOOK] = 3,
		[ITEM_GENRE.POTION] = 4,
		[ITEM_GENRE.MATERIAL] = 5
	}
	local aSub = {
		[EQUIPMENT_SUB.HORSE] = 1,
		[EQUIPMENT_SUB.PACKAGE] = 2,
		[EQUIPMENT_SUB.MELEE_WEAPON] = 3,
		[EQUIPMENT_SUB.RANGE_WEAPON] = 4,
	}
	local fnCompare = function(A, B)
		local a, b = A.item, B.item
		local gA, gB = aGenre[a.nGenre] or (100 + a.nGenre), aGenre[b.nGenre] or (100 + b.nGenre)
		if gA == gB then
			if b.nUiId == a.nUiId and b.bCanStack then
				return a.nStackNum > b.nStackNum
			elseif a.nGender == ITEM_GENRE.EQUIPMENT then
				local sA, sB = aSub[a.nSub] or (100 + a.nSub), aSub[b.nSub] or (100 + b.nSub)
				if sA == sB then
					if b.nSub == EQUIPMENT_SUB.MELEE_WEAPON or b.nSub == EQUIPMENT_SUB.RANGE_WEAPON then
						if a.nDetail < b.nDetail then
							return true
						end
					elseif b.nSub == EQUIPMENT_SUB.PACKAGE then
						if a.nCurrentDurability > b.nCurrentDurability then
							return true
						elseif a.nCurrentDurability < b.nCurrentDurability then
							return false
						end
					end
				end
			end
			return a.nQuality > b.nQuality or (a.nQuality == b.nQuality and (a.dwTabType < b.dwTabType or (a.dwTabType == b.dwTabType and a.dwIndex < b.dwIndex)))
		else
			return gA < gB
		end
	end
	-- load bank items
	local me, aItem = GetClientPlayer(), {}
	for i = 1, INVENTORY_GUILD_PAGE_SIZE do
		local dwX = nPage * INVENTORY_GUILD_PAGE_SIZE + i - 1
		local item = GetPlayerItem(me, INVENTORY_GUILD_BANK, dwX)
		if item then
			table.insert(aItem, { item = item, dwX = dwX })
		end
	end
	if #aItem == 0 then
		return
	elseif #aItem > 1 then
		table.sort(aItem, fnCompare)
	end
	-- exchange them
	local aIndex, nDst, dwBankX, dwBankX2, bTrigger = {}, 1, nil, nil, false
	for k, v in ipairs(aItem) do
		aIndex[v.dwX] = k
	end
	local fnLoop = function()
		bTrigger = true
		-- swap to empty pos & restore from bagbox
		if dwBankX then
			OnExchangeItem(INVENTORY_GUILD_BANK, dwBankX2, INVENTORY_GUILD_BANK, dwBankX)
			dwBankX = nil
			return
		elseif dwBankX2 then
			OnExchangeItem(dwBagBox, dwBagX, INVENTORY_GUILD_BANK, dwBankX2)
			dwBankX2 = nil
			return
		end
		while nDst <= #aItem do
			local dwX = nPage * INVENTORY_GUILD_PAGE_SIZE + nDst - 1
			local dwX2 = aItem[nDst].dwX
			if dwX ~= dwX2 then
				local nSrc, bChange = aIndex[dwX], true
				if nSrc then
					local item1 = aItem[nDst].item
					local item2 = aItem[nSrc].item
					if item1.nUiId == item2.nUiId then
						if item1.bCanStack and item1.nStackNum ~= item2.nStackNum then
							-- exchange via bagbox
							OnExchangeItem(INVENTORY_GUILD_BANK, dwX, dwBagBox, dwBagX)
							dwBankX, dwBankX2 = dwX, dwX2
						else
							bChange = false
						end
					end
				end
				if bChange then
					if nSrc then
						aItem[nSrc].dwX = dwX2
					end
					aIndex[dwX2] = nSrc
					if not dwBankX then
						OnExchangeItem(INVENTORY_GUILD_BANK, dwX2, INVENTORY_GUILD_BANK, dwX)
					end
					break
				end
			end
			nDst = nDst + 1
		end
		-- finish
		if nDst >= #aItem then
			local btn = Station.Lookup("Normal/GuildBankPanel/Btn_Sort2")
			if btn then
				btn:Enable(1)
				Station.Lookup("Normal/GuildBankPanel/Btn_Stack2"):Enable(1)
			end
			HM.RegisterEvent("TONG_EVENT_NOTIFY.sort", nil)
			HM.RegisterEvent("UPDATE_TONG_REPERTORY_PAGE.sort", nil)
		else
			nDst = nDst + 1
		end
	end
	frame:Lookup("Btn_Sort2"):Enable(0)
	frame:Lookup("Btn_Stack2"):Enable(0)
	HM.RegisterEvent("UPDATE_TONG_REPERTORY_PAGE.sort", fnLoop)
	HM.RegisterEvent("TONG_EVENT_NOTIFY.sort", function()
		-- TONG_EVENT_CODE.TAKE_REPERTORY_ITEM_PERMISSION_DENY_ERROR
		if arg0 == 61 then
			nDst = #aItem + 1
			fnLoop()
		end
	end)
	HM.DelayCall(1000, function()
		if not bTrigger then
			nDst = #aItem + 1
			fnLoop()
		end
	end)
	fnLoop()
	bTrigger = false
end

-- װ�����ڵ� box �б�
_HM_ToolBox.tEquipBox = {
	["Wnd_Equit"] = {
		[EQUIPMENT_INVENTORY.HELM] = "Box_Helm",	-- ñ��
		[EQUIPMENT_INVENTORY.CHEST] = "Box_Chest",	-- ����
		[EQUIPMENT_INVENTORY.BANGLE] = "Box_Bangle",	-- ����
		[EQUIPMENT_INVENTORY.WAIST] = "Box_Waist",	-- ����
		[EQUIPMENT_INVENTORY.PANTS] = "Box_Pants",	-- ��װ
		[EQUIPMENT_INVENTORY.BOOTS] = "Box_Boots",	-- Ь��
	},
	["Wnd_Weapon"] = {
		[EQUIPMENT_INVENTORY.MELEE_WEAPON] = "Box_MeleeWeapon",	-- ��������
		[EQUIPMENT_INVENTORY.RANGE_WEAPON] = "Box_RangeWeapon",	-- Զ������
		--[EQUIPMENT_INVENTORY.ARROW] = "Box_AmmoPouch",	-- ����
	},
	["Wnd_CangJian"] = {
		[EQUIPMENT_INVENTORY.MELEE_WEAPON] = "Box_LightSword",	-- �ὣ
		[EQUIPMENT_INVENTORY.BIG_SWORD] = "Box_HeavySword",	-- �ؽ�
		[EQUIPMENT_INVENTORY.RANGE_WEAPON] = "Box_RangeWeaponCJ",	-- Զ������
		--[EQUIPMENT_INVENTORY.ARROW] = "Box_AmmoPouchCJ",	-- ����
	},
}

-- ������ʾװ���;ö�
_HM_ToolBox.UpdateDurability = function(dwPlayer)
	local me, page
	if dwPlayer then
		me = GetPlayer(dwPlayer)
		page = Station.Lookup("Normal/PlayerView/Page_Main/Page_Battle")
	else
		me = GetClientPlayer()
		page = Station.Lookup("Normal/CharacterPanel/Page_Main/Page_Battle")
	end
	if not me or not page then
		return
	end
	if HM_ToolBox.bDurability then
		for k, v in pairs(_HM_ToolBox.tEquipBox) do
			local wnd = page:Lookup(k)
			if wnd:IsVisible() then
				for kk, vv in pairs(v) do
					local box = wnd:Lookup("", vv)
					if box then
						local item = GetPlayerItem(me, INVENTORY_INDEX.EQUIP, kk)
						if item then
							local dwDur = item.nCurrentDurability / item.nMaxDurability
							local nFont = 16
							if dwDur < 0.33 then
								nFont = 159
							elseif dwDur < 0.66 then
								nFont = 168
							end
							box:SetOverText(1, string.format("%d%%", dwDur * 100))
							box:SetOverTextFontScheme(1, nFont)
						else
							box:SetOverText(1, "")
						end
					end
				end
			end
		end
		page.bDurability = true
	elseif page.bDurability then
		page.bDurability = nil
		for k, v in pairs(_HM_ToolBox.tEquipBox) do
			local wnd = page:Lookup(k)
			if wnd:IsVisible() then
				for kk, vv in pairs(v) do
					local box = wnd:Lookup("", vv)
					if box then
						box:SetOverText(1, "")
					end
				end
			end
		end
	end
end

-- ���츴�Ʋ�����
_HM_ToolBox.RepeatChatLine = function(hTime)
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	if not edit then
		return
	end
	_HM_ToolBox.CopyChatLine(hTime)
	local tMsg = edit:GetTextStruct()
	if #tMsg == 0 then
		return
	end
	local nChannel, szName = EditBox_GetChannel()
	if HM.CanTalk(nChannel) then
		GetClientPlayer().Talk(nChannel, szName or "", tMsg)
		edit:ClearText()
	end
end

-- ��������ʼ�� (frame, group)
_HM_ToolBox.InitFaceIcon = function()
	-- frame = image, group = animate
	local t = { frame = {}, group = {} }
	for i = 1, g_tTable.FaceIcon:GetRowCount() do
		local tLine = g_tTable.FaceIcon:GetRow(i)
		local tEmotion = { dwID = tLine.dwID, szCmd = tLine.szCommand, szImageFile = string.lower(tLine.szImageFile) }
		local nFrame = tLine.nFrame
		local tt = (tLine.szType == "animate" and t.group) or t.frame
		if not tt[nFrame] then
			tt[nFrame] = tEmotion
		else
			table.insert(tt[nFrame],  tEmotion)
		end
	end
	_HM_ToolBox.tFacIcon = t
end

-- ����·�������͡�֡�λ�ȡ���� ID��ҳ��
_HM_ToolBox.GetEmotionID = function(szFile, szType, nFrame)
	local t = _HM_ToolBox.tFacIcon[szType]
	if t and t[nFrame] then
		local tt = t[nFrame]
		szFile = string.lower(string.gsub(string.gsub(szFile, "/", "\\"), "\\\\", "\\"))
		if tt.szImageFile == szFile then
			return tt.dwID
		end
		for _, v in ipairs(tt) do
			if v.szImageFile == szFile then
				return v.dwID
			end
		end
	end
	return nil
end

-- ���ݱ���ָ���ȡ ID
_HM_ToolBox.EmotionCommandToID = function(szCmd)
	for _, v in pairs(_HM_ToolBox.tFacIcon) do
		for _, vv in pairs(v) do
			if vv.szCmd == szCmd then
				return vv.dwID
			end
			for _, vvv in ipairs(vv) do
				if vvv.szCmd == szCmd then
					return vvv.dwID
				end
			end
		end
	end
	return nil
end

-- ���� ID ��ȡ����ָ��, ��ҳ
_HM_ToolBox.GetEmotionCommand = function(dwID)
	local tLine = g_tTable.FaceIcon:GetRow(dwID + 1)
	if tLine then
		return tLine.szCommand, tLine.dwPageID
	end
end

-- ���츴�ƹ���
_HM_ToolBox.CopyChatLine = function(hTime)
	local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
	if not edit then
		return
	end
	edit:ClearText()
	local h, i, bBegin = hTime:GetParent(), hTime:GetIndex(), nil
	-- loop
	for i = i + 1, h:GetItemCount() - 1 do
		local p = h:Lookup(i)
		if p:GetType() == "Text" then
			local szName = p:GetName()
			if szName ~= "timelink" and szName ~= "copylink" and szName ~= "msglink" and szName ~= "time" then
				local szText, bEnd = p:GetText(), false
				if StringFindW(szText, "\n") then
					szText = StringReplaceW(szText, "\n", "")
					bEnd = true
				end
				if szName == "itemlink" then
					edit:InsertObj(szText, { type = "item", text = szText, item = p:GetUserData() })
				elseif szName == "iteminfolink" then
					edit:InsertObj(szText, { type = "iteminfo", text = szText, version = p.nVersion, tabtype = p.dwTabType, index = p.dwIndex })
				elseif string.sub(szName, 1, 8) == "namelink" then
					if bBegin == nil then
						bBegin = false
					end
					edit:InsertObj(szText, { type = "name", text = szText, name = string.match(szText, "%[(.*)%]") })
				elseif szName == "questlink" then
					edit:InsertObj(szText, { type = "quest", text = szText, questid = p:GetUserData() })
				elseif szName == "recipelink" then
					edit:InsertObj(szText, { type = "recipe", text = szText, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
				elseif szName == "enchantlink" then
					edit:InsertObj(szText, { type = "enchant", text = szText, proid = p.dwProID, craftid = p.dwCraftID, recipeid = p.dwRecipeID })
				elseif szName == "skilllink" then
					local o = clone(p.skillKey)
					o.type, o.text = "skill", szText
					edit:InsertObj(szText, o)
				elseif szName =="skillrecipelink" then
					edit:InsertObj(szText, { type = "skillrecipe", text = szText, id = p.dwID, level = p.dwLevelD })
				elseif szName =="booklink" then
					edit:InsertObj(szText, { type = "book", text = szText, tabtype = p.dwTabType, index = p.dwIndex, bookinfo = p.nBookRecipeID, version = p.nVersion })
				elseif szName =="achievementlink" then
					edit:InsertObj(szText, { type = "achievement", text = szText, id = p.dwID })
				elseif szName =="designationlink" then
					edit:InsertObj(szText, { type = "designation", text = szText, id = p.dwID, prefix = p.bPrefix })
				elseif szName =="eventlink" then
					if szText and #szText > 0 then -- ���˲����Ϣ
						edit:InsertObj(szText, { type = "eventlink", name = p.szName, linkinfo = p.szLinkInfo })
					end
				else
					-- NPC �������⴦��
					if bBegin == nil then
						local r, g, b = p:GetFontColor()
						if r == 255 and g == 150 and b == 0 then
							bBegin = false
						end
					end
					if bBegin == false then
						local nB, nE = StringFindW(szText, g_tStrings.STR_TALK_HEAD_SAY1)
						if nE then
							szText, bBegin = string.sub(szText, nE + 1), true
							edit:ClearText()
						end
					end
					if szText ~= "" and (table.getn(edit:GetTextStruct()) > 0 or szText ~= g_tStrings.STR_FACE) then
						edit:InsertText(szText)
					end
				end
				if bEnd then
					break
				end
			end
		elseif p:GetType() == "Image" or p:GetType() == "Animate" then
			local dwFaceID = tonumber(string.sub(p:GetName(), 9))
			if dwFaceID then
				local szCmd, dwPage = _HM_ToolBox.GetEmotionCommand(dwFaceID)
				if szCmd then
					if dwPage > 0 and not HM.HasVipEmotion(dwPage) then
						szCmd = string.gsub(szCmd, "[a-z]", "")
						dwFaceID = _HM_ToolBox.EmotionCommandToID(szCmd)
					end
					if dwFaceID then
						edit:InsertObj(szCmd, { type = "emotion", text = szCmd, id = dwFaceID })
					else
						edit:InsertText(szCmd)
					end
				end
			end
		end
	end
	Station.SetFocusWindow(edit)
end

-- �����������ݵ� HOOK �����ˡ�����ʱ�� ��
_HM_ToolBox.AppendChatItem = function(h, szMsg, szChannel, dwTime, r, g, b, ...)
	local i = h:GetItemCount()
	-- normal append
	h:__AppendItemFromString(szMsg, szChannel, dwTime, r, g, b, ...)
	-- add chat time
	if HM_ToolBox.bChatTime and i ~= h:GetItemCount() then
		-- get msg rgb
		if not r or not g or not b then
			r, g, b = 255, 255, 0
			for j = i, h:GetItemCount() - 1 do
				local h2 = h:Lookup(j)
				if not h2 then
					return
				elseif h2:GetType() == "Text" and h2:GetName():sub(1, 8) ~= 'namelink' then
					r, g, b = h2:GetFontColor()
					break
				end
			end
		end
		if szChannel == "MSG_SYS" then
			return
		end
		local t = TimeToDate(dwTime or GetCurrentTime())
		local szTime = GetFormatText(string.format("[%02d:%02d.%02d]", t.hour, t.minute, t.second), 10, r, g, b, 515, "this.OnItemLButtonDown=function() HM_ToolBox.CopyChatLine(this) end\nthis.OnItemRButtonDown=function() HM_ToolBox.RepeatChatLine(this) end", "timelink")
		h:InsertItemFromString(i, false, szTime)
	end
end

-------------------------------------
-- �¼�����
-------------------------------------
_HM_ToolBox.OnOpenShop = function()
	local nNpcID, nShopID = arg4, arg0
	if arg3 and HM_ToolBox.bAutoRepair then
		if GetRepairAllItemsPrice(nNpcID, nShopID) > 0 then
			RepairAllItems(nNpcID, nShopID)
		end
	end
	if HM_ToolBox.bSellGray then
		_HM_ToolBox.SellGrayItem(nNpcID, nShopID)
	end
	_HM_ToolBox.nShopNpcID = nNpcID
end

-- check unlock
_HM_ToolBox.CheckUnLock = function()
	local state = Lock_State()
	return state == "NO_PASSWORD" or state == "PASSWORD_UNLOCK"
end

_HM_ToolBox.OnShopUpdateItem = function()
	if not HM_ToolBox.bBuyMore then
		return
	end
	-- �ų�δ�����û�
	if not _HM_ToolBox.CheckUnLock() then
		return
	end
	-- ���� ShopPanel ���¼���ע�ᣬ�����Ҫ�ӳ�һ֡����
	local nShopID, dwShopIndex = arg0, arg1
	HM.DelayCall(50, function()
		local hI = Station.Lookup("Normal/ShopPanel", "Handle_ItemList/Handle_ListBox/Goods_" .. nShopID .. "_" .. dwShopIndex)
		if not hI then
			return
		end
		local box = hI:Lookup("Box_Item")
		if not box or box:GetType() ~= "Box" or box:IsEmpty() or not box:IsObjectEnable() then
			return
		end
		hI.OnItemRButtonClick = function()
			local item = GetItem(GetShopItemID(nShopID, dwShopIndex))
			if IsShiftKeyDown() and item.nMaxDurability > 1
				and (item.nGenre ~= ITEM_GENRE.EQUIPMENT or item.nSub == EQUIPMENT_SUB.ARROW)
			then
				local nMax = (item.bCanStack and item.nMaxDurability) or 1
				local x, y = this:GetAbsPos()
				local w, h = this:GetSize()
				local fnSure = function(nNum)
					while nNum > 0 do
						if nNum < nMax then
							nMax = nNum
						end
						BuyItem(_HM_ToolBox.nShopNpcID, nShopID, dwShopIndex, nMax)
						nNum = nNum - nMax
					end
				end
				GetUserInputNumber(nMax, 10000, { x, y, x + w, y + h }, fnSure)
			else
				local nCount = 1
				if item.bCanStack then
					nCount = item.nCurrentDurability
				end
				BuyItem(_HM_ToolBox.nShopNpcID, nShopID, dwShopIndex, nCount)
			end
		end
		box.OnItemRButtonClick = hI.OnItemRButtonClick
	end)
end

_HM_ToolBox.OnAutoConfirm = function()
	if HM_ToolBox.bAutoDiamond2 then
		local frame = Station.Lookup("Topmost/MB_CastingPanelConfirm")
		if frame then
			_HM_ToolBox.ProduceDiamond = frame:Lookup("Wnd_All/Btn_Option1").fnAction
			_HM_ToolBox.SaveDiamondFormula()
		end
	end
	_HM_ToolBox.BindStackButton()
end

-- �Զ�������ʯ����
_HM_ToolBox.OnDiamondUpdate = function()
	if not HM_ToolBox.bAutoDiamond2 or not _HM_ToolBox.dFormula or arg0 ~= 1 then
		return
	end
	local box = _HM_ToolBox.GetRefineHandle():Lookup("Handle_BoxItem/Box_Refine")
	if not box then
		_HM_ToolBox.dFormula = nil
		return
	end
	-- �Ƴ��������ӳ�һ֡��
	HM.DelayCall(50, function()
		local dwBox, dwX = select(2, box:GetObjectData())
		RemoveUILockItem("CastingPanel:" .. dwBox .. "," .. dwX)
		box:SetObject(UI_OBJECT_NOT_NEED_KNOWN, 0)
		box:SetObjectIcon(3388 - GetClientPlayer().nGender)
	end)
	-- ���·����䷽���ӳ�8ִ֡�У�ȷ�� unlock��
	HM.DelayCall(200, function()
		_HM_ToolBox.LoadBagDiamond()
		for _, v in ipairs(_HM_ToolBox.dFormula) do
			if not _HM_ToolBox.RestoreBagDiamond(v) then
				box:ClearObject()
				_HM_ToolBox.dFormula = nil
				_HM_ToolBox.tBagCache = nil
				return
			end
		end
		_HM_ToolBox.ProduceDiamond()
	end)
end

-- chat time/copy
_HM_ToolBox.OnChatPanelInit = function()
	for i = 1, 10 do
		_HM_ToolBox.HookChatPanel(i)
	end
end

_HM_ToolBox.HookChatPanel = function(i)
	local h = Station.Lookup("Lowest2/ChatPanel" .. i .. "/Wnd_Message", "Handle_Message")
	local ttl = Station.Lookup("Lowest2/ChatPanel" .. i .. "/CheckBox_Title", "Text_TitleName")
	if h and (not ttl or ttl:GetText() ~= g_tStrings.CHANNEL_MENTOR) and not h.__AppendItemFromString then
		h.__AppendItemFromString = h.AppendItemFromString
		h.AppendItemFromString = _HM_ToolBox.AppendChatItem
		if ttl and ttl:GetText() == g_tStrings.PRIVATE_TALK then
			_HM_ToolBox.hWhisperMsg = h
		end
	end
end

_HM_ToolBox.OnReloadUIAddon = function()
	for i = 1, 10 do
		_HM_ToolBox.UnhookChatPanel(i)
	end
end

_HM_ToolBox.UnhookChatPanel = function(i)
	local h = Station.Lookup("Lowest2/ChatPanel" .. i .. "/Wnd_Message", "Handle_Message")
	local ttl = Station.Lookup("Lowest2/ChatPanel" .. i .. "/CheckBox_Title", "Text_TitleName")
	if h and (not ttl or ttl:GetText() ~= g_tStrings.CHANNEL_MENTOR) and h.__AppendItemFromString then
		h.AppendItemFromString = h.__AppendItemFromString
		h.__AppendItemFromString = nil
		if ttl and ttl:GetText() == g_tStrings.PRIVATE_TALK then
			_HM_ToolBox.hWhisperMsg = nil
		end
	end
end

-- ��¼�������쵽���ģ��Ŷӡ����硢С�ӡ���Ӫ����ͼ�����ѡ�����ȫ����
_HM_ToolBox.OnRecordWhisperAt = function(szMsg)
	local me, hM = GetClientPlayer(), _HM_ToolBox.hWhisperMsg
	if not me or not HM_ToolBox.bWhisperAt or not hM then
		return
	end
	for _, v in ipairs(me.GetTalkData() or {}) do
		if v.type == "name" and v.name == me.szName then
			hM:AppendItemFromString(szMsg)
			hM:FormatAllItemPos()
			local _, h = hM:GetSize()
			local _, hA = hM:GetAllItemSize()
			local scroll = hM:GetParent():GetParent():Lookup("Scroll_Msg")
			scroll:SetStepCount((hA - h) / 10)
			scroll:ScrollEnd()
			return PlaySound(SOUND.UI_SOUND,g_sound.Whisper)
		end
	end
end

-- ��̨�㲥��via ���Ƶ������nType, dwMapID, szText
_HM_ToolBox.OnBgBroad = function(nChannel, dwID, szName, data, bSelf)
	if not data or not data[3] or bSelf or nChannel ~= PLAYER_TALK_CHANNEL.TONG then
		return
	end
	local me, dwMapID = GetClientPlayer(), tonumber(data[2])
	if data[1] == 0 or (data[1] == 1 and dwMapID ~= me.GetMapID()) or (data[1] == 2 and dwMapID == me.GetMapID()) then
		local szFont = GetMsgFontString("MSG_WHISPER")
		local szMsg = "<text>text=" .. EncodeComponentsString("[" .. szName .. "]") .. szFont.." name=\"namelink\" eventid=515</text>"
		szMsg = szMsg .. "<text>text=" .. EncodeComponentsString(g_tStrings.STR_TALK_HEAD_WHISPER .. _L["[Guild BC] "] .. data[3] .. "\n") .. szFont .. "</text>"
		OutputMessage("MSG_WHISPER", szMsg, true)
		PlaySound(SOUND.UI_SOUND, g_sound.Whisper)
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
_HM_ToolBox.PS = {}

-- init
_HM_ToolBox.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	ui:Append("Text", { txt = _L["Shop NPC"], x = 0, y = 0, font = 27 })
	nX = ui:Append("WndCheckBox", { txt = _L["When shop open repair equipments"], x = 10, y = 28, checked = HM_ToolBox.bAutoRepair })
	:Click(function(bChecked)
		HM_ToolBox.bAutoRepair = bChecked
	end):Pos_()
	ui:Append("WndComboBox", { txt = _L["Sell some items"], x = nX + 10, y = 28 }):Menu(_HM_ToolBox.GetSellMenu)
	ui:Append("WndCheckBox", { txt = _L["Enable to buy more numbers of item at a time"], x = 10, y = 56, checked = HM_ToolBox.bBuyMore })
	:Click(function(bChecked)
		HM_ToolBox.bBuyMore = bChecked
	end)
	-- auto confirm
	ui:Append("Text", { txt = _L["Auto feature"], x = 0, y = 92, font = 27 })
	-- shift-auction
	ui:Append("WndCheckBox", { txt = _L["Press SHIFT fast auction sell"], x = 10, y = 120, checked = HM_ToolBox.bShiftAuction })
	:Click(function(bChecked)
		HM_ToolBox.bShiftAuction = bChecked
	end)
	-- auto stack
	ui:Append("WndCheckBox", { txt = _L["Enable stack items by button"], x = nX + 10, y = 120, checked = HM_ToolBox.bAutoStack })
	:Click(function(bChecked)
		HM_ToolBox.bAutoStack = bChecked
	end)
	-- put diamond
	ui:Append("WndCheckBox", { txt = _L["Produce diamond as last formula"], x = 10, y = 148, checked = HM_ToolBox.bAutoDiamond2, font = 57 })
	:Click(function(bChecked)
		HM_ToolBox.bAutoDiamond2 = bChecked
		_HM_ToolBox.dFormula = nil
		--ui:Fetch("Check_Any"):Enable(bChecked)
	end)
	-- ui:Append("WndCheckBox", "Check_Any", { txt = _L["Only consider diamond level"], x = nX + 10, y = 148, checked = HM_ToolBox.bAnyDiamond, enable = HM_ToolBox.bAutoDiamond2 })
	-- :Click(function(bChecked)
	-- 	HM_ToolBox.bAnyDiamond = bChecked
	-- end)
	-- split item
	ui:Append("WndCheckBox", { txt = _L["Enable to split bag item into groups"], x = 10, y = 176, checked = HM_ToolBox.bSplitter2 })
	:Click(function(bChecked)
		HM_ToolBox.bSplitter2 = bChecked
		HM_Splitter.Switch(bChecked)
	end)
	-- guild bank sort
	ui:Append("WndCheckBox", { txt = _L["Enable to guild bank item sort/stack"], x = nX + 10, y = 176, checked = HM_ToolBox.bGuildBankSort })
	:Click(function(bChecked)
		HM_ToolBox.bGuildBankSort = bChecked
	end)
	-- chat copy
	ui:Append("WndCheckBox", { txt = _L["Show time and support copy in chat panel"], x = 10, y = 204, checked = HM_ToolBox.bChatTime })
	:Click(function(bChecked)
		HM_ToolBox.bChatTime = bChecked
	end)
	-- record
	ui:Append("WndCheckBox", { txt = _L["Record @message into whisper panel"], x = nX + 10, y = 204, checked = HM_ToolBox.bWhisperAt })
	:Click(function(bChecked)
		HM_ToolBox.bWhisperAt = bChecked
	end)
	-- show equip durability
	ui:Append("WndCheckBox", { txt = _L["Display equipment durability"], x = nX + 10, y = 148, checked = HM_ToolBox.bDurability })
	:Click(function(bChecked)
		HM_ToolBox.bDurability = bChecked
		_HM_ToolBox.UpdateDurability()
	end)
	--
	-- tong broadcast
	ui:Append("Text", { txt = _L["Group whisper oline (Guild perm required)"], x = 0, y = 268, font = 27 })
	ui:Append("WndEdit", "Edit_Msg", { x = 10, y = 296, limit = 1024, multi = true, h = 50, w = 480, txt = HM_ToolBox.szBroadText })
	:Change(function(szText) HM_ToolBox.szBroadText = szText end)
	local nX = ui:Append("WndRadioBox", { txt = _L["Online"], checked = HM_ToolBox.nBroadType == 0, group = "Broad" })
	:Pos(10, 352):Click(function(b) if b then HM_ToolBox.nBroadType = 0  end end):Pos_()
	nX = ui:Append("WndRadioBox", { txt = _L["Other map"], checked = HM_ToolBox.nBroadType == 1, group = "Broad" })
	:Pos(10 + nX, 352):Click(function(b) if b then HM_ToolBox.nBroadType = 1  end end):Pos_()
	nX = ui:Append("WndRadioBox", { txt = _L["Current map"], checked = HM_ToolBox.nBroadType == 2, group = "Broad" })
	:Pos(10 + nX, 352):Click(function(b) if b then HM_ToolBox.nBroadType = 2 end end):Pos_()
	nX = ui:Append("WndRadioBox", { txt = _L["Team"], checked = HM_ToolBox.nBroadType == 3, group = "Broad" })
	:Pos(10 + nX, 352):Click(function(b) if b then HM_ToolBox.nBroadType = 3 end end):Pos_()
	ui:Append("WndButton", { txt = _L["Submit"], x = nX + 10, y = 353 })
	:Enable(_HM_ToolBox.HasBroadPerm()):Click(_HM_ToolBox.SendBroadCast)
end

-- conflict
_HM_ToolBox.PS.OnConflictCheck = function()
	if MY_Chat and HM_ToolBox.bChatTime then
		MY_Chat.bChatTime = false
	end
	_HM_ToolBox.InitFaceIcon()
	HM_Splitter.Switch(HM_ToolBox.bSplitter2)
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
HM.RegisterEvent("DIAMON_UPDATE", _HM_ToolBox.OnDiamondUpdate)
HM.RegisterEvent("SHOP_OPENSHOP", _HM_ToolBox.OnOpenShop)
HM.RegisterEvent("SHOP_UPDATEITEM", _HM_ToolBox.OnShopUpdateItem)
HM.BreatheCall("AutoConfirm", _HM_ToolBox.OnAutoConfirm, 130)

HM.RegisterEvent("EQUIP_ITEM_UPDATE", _HM_ToolBox.UpdateDurability)
HM.RegisterEvent("EQUIP_CHANGE", _HM_ToolBox.UpdateDurability)
HM.RegisterEvent("UNEQUIPALL", _HM_ToolBox.UpdateDurability)
HM.RegisterEvent("CHARACTER_PANEL_BRING_TOP", _HM_ToolBox.UpdateDurability)
HM.RegisterEvent("PEEK_OTHER_PLAYER", function()
	if arg0 == 1 then
		_HM_ToolBox.UpdateDurability(arg1)
	end
end)
HM.RegisterEvent("CHAT_PANEL_INIT", function()
	_HM_ToolBox.PS.OnConflictCheck()
	_HM_ToolBox.OnChatPanelInit()
end)
HM.RegisterEvent("CHAT_PANEL_OPEN", function() _HM_ToolBox.HookChatPanel(arg0) end)
-- ��ReloadUIAddon()ʱע��������ע��HOOK
HM.RegisterEvent("RELOAD_UI_ADDON_BEGIN", _HM_ToolBox.OnReloadUIAddon)
HM.RegisterEvent("RELOAD_UI_ADDON_END", _HM_ToolBox.OnChatPanelInit)
-- ��¼��������
RegisterMsgMonitor(_HM_ToolBox.OnRecordWhisperAt, {
	"MSG_NORMAL", "MSG_MAP", "MSG_BATTLE_FILED", "MSG_PARTY", "MSG_SCHOOL",
	"MSG_GUILD", "MSG_WORLD", "MSG_CAMP", "MSG_TEAM", "MSG_FRIEND"
})
HM.RegisterBgMsg("HM_BROAD", _HM_ToolBox.OnBgBroad)

-- add to HM collector
HM.RegisterPanel(_L["Misc toolbox"], 352, _L["Others"], _HM_ToolBox.PS)
HM_ToolBox.CopyChatLine = _HM_ToolBox.CopyChatLine
HM_ToolBox.RepeatChatLine = _HM_ToolBox.RepeatChatLine
