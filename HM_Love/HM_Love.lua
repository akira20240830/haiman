--
-- �������������������ȱ��Ե
--
HM_Love = {
	bQuiet = false,				-- ����ţ��ܾ������˵Ĳ鿴����
	szNone = _L["Singleton"],		-- û��Եʱ��ʾ����
	szJabber = _L["Hi, I seem to meet you somewhere ago"],	-- ��ڨ����
	bAutoFocus = true,	-- �Զ�����
}
HM.RegisterCustomData("HM_Love")
HM_Love.szTitle = _L["Lover of JX3"]

--[[
������Ե��
========
1. ÿ����ɫֻ������һ����Ե����Ե�����Ǻ���
2. ��Ҫ̹��������Ե��Ϣ�޷����أ����ѿ�ֱ�Ӳ鿴�������������ȷ�ϣ�
3. ����˫����Ե��Ҫ�����غ�����Ӳ���5���ڣ�������Ҫ�����֮�ģ���ѡ��ΪĿ�꣬�ٵ���ȷ��
4. ������Ե������ѡ��һ�� 3�غø����ϵ����ߺ��ѣ��Է����յ�����֪ͨ
5. ��Ե������ʱ����������������֪ͨ�Է���������Ե����������֪ͨ��
6. ��ɾ����Ե�������Զ������Ե��ϵ


�Ķ���Ե��
	XXXXXXXXX (198����� ...) [ն��˿]
	���ͣ�����/˫��  ʱ����X��XСʱX����X��

	�����ض��ѽ�����[___________] ������4���ڣ���һ�����֮�ģ�
	����ĳ�����غ��ѣ�[___________] ��Ҫ�����ߣ�����֪ͨ�Է���
	û��Եʱ��ʾʲô��[___________]  [**] ���������ģʽ

	��Ե���ԣ� [________________________________________________________]
	��ڨ��� [________________________________________________________]

С��ʾ��
	1. ����װ���������Ҳ����໥��������
	2. ��Ե���Ե�����ɾ����˫����Ե��ͨ�����ĸ�֪�Է�
	3. �Ƕ��Ѳ鿴��ԵʱĿ�ᵯ��ȷ�Ͽ򣨿ɿ�����������Σ�
--]]

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _i = Table_GetItemName
local _HM_Love = {
	dwID = 0,				-- ��Ե ID
	szName = "",		-- ��Ե����
	dwAvatar = 0,		-- ��Եͷ��
	nRoleType = 0,	-- ��Ե���ͣ�0������Ե��
	nLoveType = 0,	-- ��Ե���ͣ�����0��˫��1��
	nStartTime = 0,	-- ��Ե��ʼʱ�䣨��λ���룩
	szSign = "",			-- ��Ե���ԣ�����ǩ����
	tOther = {},			-- �鿴����Ե���ݣ�[0] = szName, [1] = dwAvatar,  [2] = szSign, [3] = nRoletype, [4] = nLoveType��
	tViewer = {},			-- �Ⱥ�鿴��������б�
	dwRoot = 8949795,		-- root user id: 8949795
}

-- ���ر�����������ף�˫����ȡ������֪ͨ��
_HM_Love.tAutoSay = {
	_L["Some people fancy you"],
	_L["Other side terminate love you"],
	_L["Some people fall in love with you"],
	_L["Other side gave up love you"],
}

-- ��ȡ����ָ��������Ʒ
_HM_Love.GetBagItemPos = function(szName)
	local me = GetClientPlayer()
	for dwBox = 1, BigBagPanel_nCount do
		for dwX = 0, me.GetBoxSize(dwBox) - 1 do
			local it = me.GetItem(dwBox, dwX)
			if it and GetItemNameByItem(it) == szName then
				return dwBox, dwX
			end
		end
	end
end

-- ���ݱ��������ȡ��Ʒ������
_HM_Love.GetBagItemNum = function(dwBox, dwX)
	local item = GetPlayerItem(GetClientPlayer(), dwBox, dwX)
	if not item then
		return 0
	elseif not item.bCanStack then
		return 1
	else
		return item.nStackNum
	end
end

-- �Ƿ�ɽ�˫����ѣ����������֮�ĵ�λ��
_HM_Love.GetDoubleLoveItem = function(aInfo)
	if aInfo then
		local tar = HM.GetPlayer(aInfo.id)
		if aInfo.attraction >= 800 and tar and HM.IsParty(tar.dwID) and HM.GetDistance(tar) <= 4 then
			return _HM_Love.GetBagItemPos(_i(67291))
		end
	end
end

-- ��ȡͷ���ļ�·����֡���Ƿ񶯻�
_HM_Love.GetAvatarFile = function(dwAvatar, nRoleType)
	-- mini avatar
	if dwAvatar > 0 then
		local tInfo = g_tTable.RoleAvatar:Search(dwAvatar)
		if tInfo then
			if nRoleType == ROLE_TYPE.STANDARD_MALE then
				return tInfo.szM2Image, tInfo.nM2ImgFrame, tInfo.bAnimate
			elseif nRoleType == ROLE_TYPE.STANDARD_FEMALE then
				return tInfo.szF2Image, tInfo.nF2ImgFrame, tInfo.bAnimate
			elseif nRoleType == ROLE_TYPE.STRONG_MALE then
				return tInfo.szM3Image, tInfo.nM3ImgFrame, tInfo.bAnimate
			elseif nRoleType == ROLE_TYPE.SEXY_FEMALE then
				return tInfo.szF3Image, tInfo.nF3ImgFrame, tInfo.bAnimate
			elseif nRoleType == ROLE_TYPE.LITTLE_BOY then
				return tInfo.szM1Image, tInfo.nM1ImgFrame, tInfo.bAnimate
			elseif nRoleType == ROLE_TYPE.LITTLE_GIRL then
				return tInfo.szF1Image, tInfo.nF1ImgFrame, tInfo.bAnimate
			end
		end
	end
	-- force avatar
	local tForce = { "shaolin", "wanhua", "tiance", "chunyang", "qixiu", "wudu", "tangmen", "cangjian", "gaibang", "mingjiao", "cangyun", "changge" }
	local szForce = tForce[0 - dwAvatar] or "jianghu"
	return "ui\\Image\\PlayerAvatar\\" .. szForce .. ".tga", -2, false
end

-- �����������
_HM_Love.SaveFellowRemark = function(id, remark)
	if not remark or remark == "" then
		remark = " "
	end
	GetClientPlayer().SetFellowshipRemark(id, remark)
	--[[
	Wnd.CloseWindow("PartyPanel")
	local frame = Wnd.OpenWindow("PartyPanel")
	local page = frame:Lookup("Wnd_FriendInfo")
	if not page then return end
	local edit = page:Lookup("Edit_Name")
	if not edit then return end
	page.dwID = id
	edit:SetLimit(128)
	Station.SetFocusWindow(edit)
	edit:SetText(remark)
	Station.SetFocusWindow(frame)
	Wnd.CloseWindow("PartyPanel")
	--]]
end

-- ���� ID ��ȡ���ݺ�����Ϣ
_HM_Love.GetFellowDataByID = function(id)
	local me = GetClientPlayer()
	local aGroup = me.GetFellowshipGroupInfo() or {}
	table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
	for _, v in ipairs(aGroup) do
		local aFriend = me.GetFellowshipInfo(v.id) or {}
		for _, vv in ipairs(aFriend) do
			if vv.id == id then
				return vv
			end
		end
	end
	return nil
end

-- ����У���ȷ�����ݲ����۸ģ�0-255��
_HM_Love.EncodeString = function(szData)
	local nCrc = 0
	for i = 1, string.len(szData) do
		nCrc = (nCrc + string.byte(szData, i)) % 255
	end
	return string.format("%02x", nCrc) .. szData
end

-- �޳�У�����ȡԭʼ����
_HM_Love.DecodeString = function(szData)
	if string.len(szData) > 2 then
		local nCrc = 0
		for i = 3, string.len(szData) do
			nCrc = (nCrc + string.byte(szData, i)) % 255
		end
		if nCrc == tonumber(string.sub(szData, 1, 2), 16) then
			return string.sub(szData, 3)
		end
	end
end

-- ����ֵ�������ݵ����ѱ�ע���ɹ� true��ʧ�� false��
-- FIXME��ͨ�� ID ��������ʱ���ܻḲ������������������ݣ�����
_HM_Love.SetFellowDataByKey = function(szKey, szData, dwID, bEnc)
	local szKey, me, slot, card = "#HM#" .. szKey .. "#", GetClientPlayer(), nil, nil
	if not me then return Output("not me") end
	local aGroup = me.GetFellowshipGroupInfo() or {}
	table.insert(aGroup, 1, { id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND })
	if bEnc and szData then
		szData = _HM_Love.EncodeString(szData)
	end
	for _, v in ipairs(aGroup) do
		local aFriend = me.GetFellowshipInfo(v.id) or {}
		for i = #aFriend, 1, -1 do
			local info = aFriend[i]
			local bMatch = string.sub(info.remark, 1, string.len(szKey)) == szKey
			if not szData then
				-- fetch data
				if bMatch then
					local szData = string.sub(info.remark, string.len(szKey) + 1)
					if bEnc then
						szData = _HM_Love.DecodeString(szData)
					end
					local fellowClient = GetFellowshipCardClient()
					if fellowClient then
						card = fellowClient.GetFellowshipCardInfo(info.id)
						if not card or card.dwMapID == 0 then
							fellowClient.ApplyFellowshipCard(255, {info.id})
						end
					end
					return szData, info, card
				end
			elseif not dwID then
				-- set by Key
				if bMatch then
					_HM_Love.SaveFellowRemark(info.id, szKey .. szData)
					return true, info
				end
				-- find slot
				if string.sub(info.remark, 1, 4) ~= "#HM#" and (not slot or info.attraction < slot.attraction) then
					slot = info
				end
			else
				-- set by ID (unique key)
				if dwID == info.id then
					slot = info
				elseif bMatch then
					_HM_Love.SaveFellowRemark(info.id, "")
				end
			end
		end
	end
	if slot then
		local fellowClient = GetFellowshipCardClient()
		if fellowClient then
			card = fellowClient.GetFellowshipCardInfo(slot.id)
		end
	end
	-- last result
	if szData then
		if slot then
			_HM_Love.SaveFellowRemark(slot.id, szKey .. szData)
			return true, slot, card
		else
			return false, nil, nil
		end
	end
end

-- ����ֵ�Ӻ��ѱ�ע����ȡ���ݣ��ɹ��������� + rawInfo��ʧ�� nil��
_HM_Love.GetFellowDataByKey = function(szKey, bEnc)
	return _HM_Love.SetFellowDataByKey(szKey, nil, nil, bEnc)
end

-- ת��������ϢΪ��Ե��Ϣ
_HM_Love.ToLocalLover = function(aInfo, aCard)
	if not aInfo then
		_HM_Love.dwID = 0
		_HM_Love.szName = ""
		_HM_Love.dwAvatar = 0
		_HM_Love.nRoleType = 0
		_HM_Love.nLoveType = 0
		_HM_Love.nStartTime = 0
	else
		_HM_Love.dwID = aInfo.id
		_HM_Love.szName = aInfo.name
		_HM_Love.dwAvatar = aCard.dwMiniAvatarID
		_HM_Love.nRoleType = aCard.nRoleType
		if not aCard.dwMiniAvatarID or aCard.dwMiniAvatarID == 0 then
			_HM_Love.dwAvatar = 0 - aCard.dwForceID
		end
	end
end

-- ��ȡ��Ե����
_HM_Love.GetLoverType = function(nType)
	nType = nType or _HM_Love.nLoveType
	if nType == 1 then
		return _L["Mutual love"]
	else
		return _L["Blind love"]
	end
end

-- ��ȡ��Եʱ��
_HM_Love.GetLoverTime = function(nTime)
	nTime = nTime or _HM_Love.nStartTime
	local nSec = GetCurrentTime() - nTime
	local szTime = ""
	if nSec <= 60 then
		return nSec .. _L["sec"]
	elseif nSec < 3600 then	-- X����X��
		return _L("%d min %d sec", nSec / 60, nSec % 60)
	elseif nSec < 86400 then	-- XСʱX����
		return _L("%d hour %d min", nSec / 3600, (nSec % 3600) / 60)
	elseif nSec < 31536000 then	-- X��XСʱ
		return _L("%d day %d hour", nSec / 86400, (nSec % 86400) / 3600)
	else	-- X��X��
		return _L("%d year %d day", nSec / 31536000, (nSec % 31536000) / 86400)
	end
end

-- ������Ե
_HM_Love.SaveLover = function(aInfo, nType, nTime)
	nTime = nTime or GetCurrentTime()
	local _, _, aCard = _HM_Love.SetFellowDataByKey("LOVER", nType .. "#" .. nTime, aInfo.id, true)
	_HM_Love.ToLocalLover(aInfo, aCard or {})
	_HM_Love.nLoveType = nType
	_HM_Love.nStartTime = nTime
	_HM_Love.PS.Refresh()
	HM.Talk(PLAYER_TALK_CHANNEL.TONG, _L("From now on, my heart lover is [%s]", aInfo.name))
end

-- ������Ե
_HM_Love.SetLover = function(dwID, nType)
	if not dwID then
		-- ȡ����Ե
		if _HM_Love.nLoveType == 1 then			-- ˫������������
			HM.Talk(_HM_Love.szName, _L["Sorry, I decided to just a swordman, bye my plugin lover"])
		elseif _HM_Love.nLoveType == 0 then	-- ����ֻ֪ͨ���ߵ�
			local aInfo = _HM_Love.GetFellowDataByID(_HM_Love.dwID)
			if aInfo and aInfo.isonline then
				HM.BgTalk(_HM_Love.szName, "HM_LOVE", "REMOVE0")
			end
		end
		-- �������
		HM.Talk(PLAYER_TALK_CHANNEL.TONG, _L("A blade and cut, no longer meet with [%s]", _HM_Love.szName))
		_HM_Love.SaveFellowRemark(_HM_Love.dwID, "")
		_HM_Love.ToLocalLover(nil)
		_HM_Love.PS.Refresh()
		HM.Sysmsg(_L["Congratulations, do not repeat the same mistakes ah"])
	else
		-- ���ó�Ϊ��Ե�����ߺ��ѣ�
		local aInfo = _HM_Love.GetFellowDataByID(dwID)
		if not aInfo or not aInfo.isonline then
			return HM.Alert(_L["Lover must be a online friend"])
		end
		if nType == 0 then
			-- ������Ե���򵥣�
			_HM_Love.SaveLover(aInfo, nType)
			HM.BgTalk(aInfo.name, "HM_LOVE", "LOVE0")
		else
			-- ˫����Ե�����ߣ����һ�𣬲�����4���ڣ����𷽴���һ�����֮�ģ�
			if not _HM_Love.GetDoubleLoveItem(aInfo) then
				return HM.Alert(_L("Inadequate conditions, requiring Lv6 friend/party/4-feet distance/%s", _i(67291)))
			end
			HM.BgTalk(aInfo.name, "HM_LOVE", "LOVE_ASK")
			HM.Sysmsg(_L("Love request has been sent to [%s], wait please", aInfo.name))
		end
	end
end

-- ɾ����Ե
_HM_Love.RemoveLover = function()
	if _HM_Love.dwID ~= 0 then
		local nTime = GetCurrentTime() - _HM_Love.nStartTime
		if nTime < 3600 then
			return HM.Alert(_L("Love can not run a red-light, [%d] seconds left", 3600 - nTime))
		end
		HM.Confirm(_L("Are you sure to cut love with [%s]?", _HM_Love.szName), function()
			HM.DelayCall(50, function() HM.Confirm(_L["Past five hundred times looking back only in exchange for a chance encounter this life, you really decided?"], function()
				HM.DelayCall(50, function() HM.Confirm(_L["You do not really want to cut off love it, really sure?"], function()
					_HM_Love.SetLover(nil)
				end) end)
			end) end)
		end)
	end
end

-- �޸�˫����Ե
_HM_Love.FixLover = function()
	if _HM_Love.nLoveType ~= 1 then
		return HM.Alert(_L["Repair feature only supports mutual love!"])
	end
	if not HM.IsParty(_HM_Love.dwID) then
		return HM.Alert(_L["Both sides must in a team to be repaired!"])
	end
	HM.BgTalk(_HM_Love.szName, "HM_LOVE", "FIX1", _HM_Love.nStartTime)
	HM.Sysmsg(_L["Repair request has been sent, wait please"])
end

-- ��ȡ����Ե�����б�
_HM_Love.GetLoverMenu = function(nType)
	local me, m0 = GetClientPlayer(), {}
	local aGroup = me.GetFellowshipGroupInfo() or {}
	table.insert(aGroup, 1, {id = 0, name = g_tStrings.STR_FRIEND_GOOF_FRIEND})
	for _, v in ipairs(aGroup) do
		local aFriend = me.GetFellowshipInfo(v.id) or {}
		for _, vv in ipairs(aFriend) do
			if vv.attraction >= 200 and (nType ~= 1 or vv.attraction >= 800) then
				table.insert(m0, {
					szOption = vv.name,
					fnDisable = function() return not vv.isonline end,
					fnAction = function()
						HM.Confirm(_L("Do you want to love with [%s]?", vv.name), function()
							_HM_Love.SetLover(vv.id, nType)
						end)
					end
				})
			end
		end
	end
	if #m0 == 0 then
		table.insert(m0, { szOption = _L["<Non-avaiable>"] })
	end
	return m0
end

-- ����ǩ��
_HM_Love.SetSign = function(szSign)
	szSign = HM.Trim(szSign)
	_HM_Love.szSign = szSign
	HM.DelayCall(3000, function()
		if szSign == _HM_Love.szSign then
			local szPart1, szPart2 = "", ""
			if string.len(szSign) > 22 then
				-- �ָ�ȷ��������
				local i = 1
				while i < 21 do
					if string.byte(szSign, i) < 128 then
						i = i + 1
					else
						i = i + 2
					end
				end
				szPart1 = string.sub(szSign, 1, i - 1)
				szPart2 = string.sub(szSign, i)
			else
				szPart1, szPart2 = szSign, " "
			end
			if not _HM_Love.SetFellowDataByKey("S1", szPart1) then
				return HM.Alert(_L["Save signature failed, please add some friends."])
			end
			_HM_Love.SetFellowDataByKey("S2", szPart2)
		end
	end)
end

-- ������Ե�����Ϣ
_HM_Love.UpdatePage = function()
	local p = Station.Lookup("Normal/PlayerView/Page_Main/Page_Love")
	if not p then return end
	local tar = HM.GetPlayer(p:GetParent().dwPlayer)
	if not tar then
		return p:GetRoot():Hide()
	end
	local h, t = p:Lookup("", ""), _HM_Love.tOther
	-- t = {  szName, dwAvatar, szSign, nRoleType, nLoveType, nStartTime }
	h:Lookup("Text_LTitle"):SetText(tar.szName .. _L["'s Lover"])
	-- lover
	local txt = h:Lookup("Text_Lover")
	txt:SetText(t[1] or _L["...Loading..."])
	txt.szPlayer = t[1]
	-- avatar
	local dwAvatar = tonumber(t[2]) or 0
	local img, ani = h:Lookup("Image_Lover"), h:Lookup("Animate_Lover")
	if dwAvatar == 0 then
		img:Hide()
		ani:Hide()
		txt:SetRelPos(42, 92)
		txt:SetSize(300, 25)
		txt:SetHAlign(1)
	else
		local szFile, nFrame, bAnimate = _HM_Love.GetAvatarFile(dwAvatar, tonumber(t[4]) or 1)
		if bAnimate then
			ani:SetAnimate(szFile, nFrame)
			--ani:SetAnimateType(ANIMATE.FLIP_HORIZONTAL)
			ani:Show()
			img:Hide()
			ani.szPlayer = t[1]
		else
			if nFrame < 0 then
				img:FromTextureFile(szFile)
			else
				img:FromUITex(szFile, nFrame)
			end
			if nFrame == -2 then
				img:SetImageType(IMAGE.NORMAL)
			else
				img:SetImageType(IMAGE.FLIP_HORIZONTAL)
			end
			ani:Hide()
			img:Show()
			img.szPlayer = t[1]
		end
		txt:SetRelPos(130, 92)
		txt:SetSize(200, 25)
		txt:SetHAlign(0)
	end
	-- lover info
	local inf = h:Lookup("Text_LoverInfo")
	if t[5] and t[6] and t[6] > 0 then
		local szText = _HM_Love.GetLoverType(tonumber(t[5]) or 0) .. "   " .. _HM_Love.GetLoverTime(tonumber(t[6]) or 0)
		inf:SetText(szText)
	else
		inf:SetText("")
	end
	-- sign title
	h:Lookup("Text_SignTTL"):SetText(tar.szName .. _L["'s Love signature:"])
	-- sign
	local szSign = t[3]
	if not szSign then
		szSign = _L["If it is always loading, the target may not install plugin or turn on quiet mode, strongly recommend to query after team up."]
	elseif szSign == "" then
		szSign = _L["This guy is very lazy, nothing left!"]
	end
	h:Lookup("Text_Sign"):SetText(szSign)
	-- btn
	local txt = p:Lookup("Btn_LoveYou"):Lookup("", "Text_LoveYou")
	if tar.nGender == 2 then
		txt:SetText(_L["Strike up her"])
	else
		txt:SetText(_L["Strike up him"])
	end
	h:FormatAllItemPos()
end

-- ��̨������˵���Ե����
_HM_Love.AskOtherData = function(dwID)
	local tar = HM.GetPlayer(dwID)
	if not tar then
		return
	end
	_HM_Love.tOther = {}
	_HM_Love.UpdatePage()
	if tar.bFightState and not HM.IsParty(tar.dwID) then
		_HM_Love.bActiveLove = false
		return HM.Sysmsg("[" .. tar.szName .. "] " .. _L[" in fighting, no time for you"])
	end
	HM.BgTalk(tar.szName, "HM_LOVE", "VIEW")
end

-------------------------------------
-- �¼�����
-------------------------------------
-- �������ݸ��£���ʱ�����Ե�仯��ɾ�����Ѹı�ע�ȣ�
_HM_Love.OnFellowUpdate = function()
	-- ������Ե
	local szData, aInfo, aCard = _HM_Love.GetFellowDataByKey("LOVER", true)
	if not szData and _HM_Love.dwID ~= 0 then
		_HM_Love.ToLocalLover(nil)
		_HM_Love.PS.Refresh()
	end
	if aInfo and aCard and aCard.dwMapID ~= 0 and _HM_Love.dwID ~= aInfo.id then
		local data = SplitString(szData, "#")
		_HM_Love.ToLocalLover(aInfo, aCard or {})
		_HM_Love.nLoveType = tonumber(data[1]) or 0
		_HM_Love.nStartTime = tonumber(data[2]) or GetCurrentTime()
		_HM_Love.PS.Refresh()
		-- ������ʾ
		if not _HM_Love.bLoaded and aInfo.isonline then
			local szMsg = _L["Warm tip: Your "] .. _HM_Love.GetLoverType() .. _L("Lover <link0> is happy in [%s].\n", Table_GetMapName(aCard.dwMapID))
			_HM_Love.OnLoverMsg(szMsg)
		end
	else
		return
	end
	-- ��һ�μ��أ�ǩ��
	if not _HM_Love.bLoaded then
		local szData, _ = _HM_Love.GetFellowDataByKey("S1")
		if szData then
			_HM_Love.szSign =szData
			local szData, _ = _HM_Love.GetFellowDataByKey("S2")
			if szData then
				_HM_Love.szSign = _HM_Love.szSign .. szData
			end
			_HM_Love.szSign = HM.Trim(_HM_Love.szSign)
		end
		_HM_Love.bLoaded = true
	end
end

-- �鿴����װ������Ե
_HM_Love.OnPeekOtherPlayer = function()
	if arg0 ~= 1 then return end
	local mPage = Station.Lookup("Normal/PlayerView/Page_Main")
	if not mPage then
		return
	end
	-- attach page
	if not mPage.bLoved then
		local frame = Wnd.OpenWindow("interface\\HM\\HM_Love\\HM_Love.ini", "HM_Love")
		local pageset = frame:Lookup("Page_Main")
		local checkbox = pageset:Lookup("CheckBox_Love")
		local page = pageset:Lookup("Page_Love")
		checkbox:ChangeRelation(mPage, true, true)
		page:ChangeRelation(mPage, true, true)
		Wnd.CloseWindow(frame)
		checkbox:SetRelPos(270, 510)
		page:SetRelPos(0, 0)
		mPage:AddPage(page, checkbox)
		checkbox:Show()
		mPage.bLoved = true
		-- events
		mPage.OnActivePage = function()
			PlaySound(SOUND.UI_SOUND, g_sound.OpenFrame)
			if this:GetActivePage():GetName() == "Page_Love" then
				_HM_Love.AskOtherData(this.dwPlayer)
			end
		end
		page:Lookup("Btn_LoveYou").OnLButtonClick = function()
			local mp = this:GetParent():GetParent()
			local tar = HM.GetPlayer(mp.dwPlayer)
			if tar then
				HM.Talk(tar.szName, HM_Love.szJabber)
			end
		end
		page:Lookup("Btn_LoveYou").OnRButtonClick = function()
			local mp = this:GetParent():GetParent()
			local tar = HM.GetPlayer(mp.dwPlayer)
			if tar then
				local m0, me = {}, GetClientPlayer()
				InsertInviteTeamMenu(m0, tar.szName)
				if me.IsInParty() and me.dwID == GetClientTeam().GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) then
					InsertMarkMenu(m0, tar.dwID)
				end
				if me.IsInParty() and me.IsPlayerInMyParty(tar.dwID) then
					InsertTeammateLeaderMenu(m0, tar.dwID)
				end
				if #m0 > 0 then
					table.insert(m0, { bDevide = true })
				end
				InsertPlayerCommonMenu(m0, tar.dwID, tar.szName)
				PopupMenu(m0)
			end
		end
		page:Lookup("", "Image_Lover").OnItemRButtonDown = function()
			if this.szPlayer then
				local m0 = {}
				InsertPlayerCommonMenu(m0, 0, this.szPlayer)
				PopupMenu(m0)
			end
		end
		page:Lookup("", "Text_Lover").OnItemRButtonDown = page:Lookup("", "Image_Lover").OnItemRButtonDown
		page:Lookup("", "Animate_Lover").OnItemRButtonDown = page:Lookup("", "Image_Lover").OnItemRButtonDown
		page:Lookup("", "Text_LTitle"):SetText(_L["Lover"])
		page:Lookup("", "Text_SignTTL"):SetText(_L["Love signature:"])
		page:Lookup("", "Text_Lover"):SetFontColor(255, 128, 255)
		checkbox:Lookup("", "Text_LoveCaptical"):SetText(_L["Lover"])
	end
	-- update page
	mPage.dwPlayer = arg1
	-- active page
	if _HM_Love.bActiveLove then
		_HM_Love.bActiveLove = false
		mPage:ActivePage("Page_Love")
	end
end

-- �ظ���Ե��Ϣ
_HM_Love.ReplyLove = function(bCancel)
	local szName, bRoot = _HM_Love.szName, false
	local root = nil
	if _HM_Love.dwID == 0 then
		szName = "<" .. HM_Love.szNone .. ">"
		bRoot = GetClientPlayer().szName == _L["HMM5"]
		if not bRoot then
			root = HM.GetPlayer(_HM_Love.dwRoot)
		end
	elseif bCancel then
		szName = _L["<Not tell you>"]
	end
	for k, v in pairs(_HM_Love.tViewer) do
		if bRoot or root then
			local p = root or HM.GetPlayer(k)
			if p then
				szName = p.szName
				_HM_Love.dwAvatar = p.dwMiniAvatarID
				_HM_Love.nRoleType = p.nRoleType
				_HM_Love.nLoveType = 1
				_HM_Love.nStartTime =  GetCurrentTime() - 1173600
				if not p.dwMiniAvatarID or p.dwMiniAvatarID == 0 then
					_HM_Love.dwAvatar = 0 - p.dwForceID
				end
			end
		end
		HM.BgTalk(v, "HM_LOVE", szName,
			_HM_Love.dwAvatar or 0, _HM_Love.szSign, _HM_Love.nRoleType or 0,
			_HM_Love.nLoveType, _HM_Love.nStartTime)
	end
	_HM_Love.tViewer = {}
end

-- ��̨ͬ��
_HM_Love.OnBgTalk = function(nChannel, dwID, szName, data, bSelf)
	if not bSelf then
		if data[1] == "VIEW" then
			if HM.IsParty(dwID) then
				_HM_Love.tViewer[dwID] = szName
				_HM_Love.ReplyLove()
			elseif not GetClientPlayer().bFightState and not HM_Love.bQuiet then
				_HM_Love.tViewer[dwID] = szName
				HM.Confirm(
					"[" .. szName .. "] " .. _L["want to see your lover info, OK?"],
					function() _HM_Love.ReplyLove() end,
					function() _HM_Love.ReplyLove(true) end
				)
			end
		elseif data[1] == "LOVE0" or data[1] == "REMOVE0" then
			local i = math.random(1, math.floor(table.getn(_HM_Love.tAutoSay)/2)) * 2
			if data[1] == "LOVE0" then
				i = i - 1
			end
			OutputMessage("MSG_WHISPER", _L["[Mystery] quietly said:"] .. _HM_Love.tAutoSay[i] .. "\n")
			PlaySound(SOUND.UI_SOUND,g_sound.Whisper)
		elseif data[1] == "LOVE_ASK" then
			-- ������Եֱ�Ӿܾ�
			if _HM_Love.dwID ~= 0 and (_HM_Love.dwID ~= dwID or _HM_Love.nLoveType == 1) then
				return HM.BgTalk(szName, "HM_LOVE", "LOVE_ANS", "EXISTS")
			end
			-- ѯ�����
			HM.Confirm("[" .. szName .. "] " .. _L["want to mutual love with you, OK?"], function()
				HM.BgTalk(szName, "HM_LOVE", "LOVE_ANS", "YES")
			end, function()
				HM.BgTalk(szName, "HM_LOVE", "LOVE_ANS", "NO")
			end)
		elseif data[1] == "FIX1" then
			if _HM_Love.dwID == 0 or (_HM_Love.dwID == dwID and _HM_Love.nLoveType ~= 1) then
				local aInfo = _HM_Love.GetFellowDataByID(dwID)
				if aInfo then
					HM.Confirm("[" .. aInfo.name .. "] " .. _L["want to repair love relation with you, OK?"], function()
						_HM_Love.SaveLover(aInfo, 1, tonumber(data[2]))
						HM.Sysmsg(_L("Congratulations, love relation with [%s] has been fixed!", aInfo.name))
					end)
				end
			else
				HM.BgTalk(szName, "HM_LOVE", "LOVE_ANS", "EXISTS")
			end
		elseif data[1] == "LOVE_ANS" then
			if data[2] == "EXISTS" then
				local szMsg = _L["Unfortunately the other has lover, but you can still blind love him!"]
				HM.Sysmsg(szMsg)
				HM.Alert(szMsg)
			elseif data[2] == "NO" then
				local szMsg = _L["The other refused you without reason, but you can still blind love him!"]
				HM.Sysmsg(szMsg)
				HM.Alert(szMsg)
			elseif data[2] == "YES" then
				local aInfo = _HM_Love.GetFellowDataByID(dwID)
				local dwBox, dwX = _HM_Love.GetDoubleLoveItem(aInfo)
				if dwBox then
					local nNum = _HM_Love.GetBagItemNum(dwBox, dwX)
					SetTarget(TARGET.PLAYER, aInfo.id)
					OnUseItem(dwBox, dwX)
					HM.DelayCall(500, function()
						if _HM_Love.GetBagItemNum(dwBox, dwX) ~= nNum then
							_HM_Love.SaveLover(aInfo, 1)
							HM.BgTalk(aInfo.name, "HM_LOVE", "LOVE_ANS", "CONF")
							HM.Sysmsg(_L("Congratulations, success to attach love with [%s]!", aInfo.name))
						end
					end)
				end
			elseif data[2] == "CONF" then
				local aInfo = _HM_Love.GetFellowDataByID(dwID)
				if aInfo then
					_HM_Love.SaveLover(aInfo, 1)
					HM.Sysmsg(_L("Congratulations, success to attach love with [%s]!", aInfo.name))
				end
			end
		else
			_HM_Love.tOther = data
			_HM_Love.UpdatePage()
		end
	end
end

-- ��Ե��������֪ͨ
_HM_Love.OnLoverMsg = function(szMsg)
	local szChannel = "MSG_SYS"
	local szFont = GetMsgFontString(szChannel)
	szMsg = FormatLinkString(szMsg, szFont, MakeNameLink("[" .. _HM_Love.szName .. "]", szFont))
	OutputMessage(szChannel, szMsg, true)
end

-- ���ߣ�����֪ͨ��bOnLine, szName, bFoe
_HM_Love.OnFriendLogin = function()
	if not arg2 and arg1 == _HM_Love.szName and _HM_Love.szName ~= "" then
		local szMsg = _L["Warm tip: Your "] .. _HM_Love.GetLoverType() .. _L["Lover <link0>"]
		if arg0 then
			szMsg = szMsg .. _L["online, hurry doing needy doing.\n"]
			OnBowledCharacterHeadLog(GetClientPlayer().dwID, _L["Love Tip: "] .. arg1 .. _L["onlines now"], 199, { 255, 0, 255 })
			PlaySound(SOUND.UI_SOUND, g_sound.LevelUp)
		else
			szMsg = szMsg .. _L["offline, hurry doing like doing.\n"]
		end
		_HM_Love.OnLoverMsg(szMsg)
	end
end

-- ��ֹ�޸���Ե���ѱ�ע����ֹ��ʾ��ע
_HM_Love.OnBreathe = function()
	-- social list
	local hL = Station.Lookup("Normal/SocialPanel/PageSet_Company/Page_Friend/WndScroll_Friend", "")
	if hL and hL:IsVisible() then
		for i = 0, hL:GetItemCount() - 1, 1 do
			local hI = hL:Lookup(i)
			if hI.bPlayer and hI.info and hI.info.remark
				and (hI.info.remark == " " or string.sub(hI.info.remark, 1, 4) == "#HM#")
			then
				hI:Lookup("Text_N"):SetText(hI.info.name)
			end
		end
		local input = Station.Lookup("Topmost/GetNamePanel")
		if input and not input.bChecked
			and input:Lookup("", "Text_Msg"):GetText() == g_tStrings.STR_FRIEND_INPUT_MARK
		then
			local edit = input:Lookup("Edit_Input")
			if string.sub(edit:GetText(), 1, 10) == "#HM#LOVER#" then
				edit:Enable(0)
				input:Lookup("Btn_Sure"):Enable(false)
			end
			input.bChecked = true
		end
	end
	-- friendrank
	local hL = Station.Lookup("Normal/FriendRank/Wnd_PRanking", "Handle_RankingMes")
end

-- player enter
_HM_Love.OnPlayerEnter = function()
	if HM_Love.bAutoFocus and arg0 == _HM_Love.dwID then
		if HM_TargetList and HM_TargetList.AddFocus and not IsInArena() then
			HM_TargetList.AddFocus(arg0)
		end
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Love.PS = {}

-- refresh
_HM_Love.PS.Refresh = function()
	if _HM_Love.ui then
		HM.OpenPanel(HM_Love.szTitle)
	end
end

-- get map
_HM_Love.GetLoverMap = function()
	local fellowClient = GetFellowshipCardClient()
	if fellowClient then
		local aInfo = _HM_Love.GetFellowDataByID(_HM_Love.dwID)
		local aCard = fellowClient.GetFellowshipCardInfo(_HM_Love.dwID)
		fellowClient.ApplyFellowshipCard(255, {_HM_Love.dwID})
		if aInfo and aInfo.isonline and  aCard and aCard.dwMapID ~= 0 then
			return Table_GetMapName(aCard.dwMapID)
		end
	end
end

-- init
_HM_Love.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	ui:Append("Text", { txt = _L["Heart lover"], x = 0, y = 0, font = 27 })
	-- lover info
	if _HM_Love.dwID == 0 then
		ui:Append("Text", { txt = _L["No lover :-("], font = 19, x = 10, y = 36 })
		-- create lover
		nX = ui:Append("Text", { txt = _L["Mutual love friend Lv.6: "], x = 10, y = 72 }):Pos_()
		nX = ui:Append("WndComboBox", { txt = _L["- Select plz -"], x = nX + 5, y = 72, w = 200, h = 25 })
		:Menu(function() return _HM_Love.GetLoverMenu(1) end):Pos_()
		ui:Append("Text", { txt = _L("(4-feets, +%s)", _i(67291)), x = nX + 5, y = 72 })
		nX = ui:Append("Text", { txt = _L["Blind love friend Lv.2: "], x = 10, y = 100 }):Pos_()
		nX = ui:Append("WndComboBox", { txt = _L["- Select plz -"], x = nX + 5, y = 100, w = 200, h = 25 })
		:Menu(function() return _HM_Love.GetLoverMenu(0) end):Pos_()
		ui:Append("Text", { txt = _L["(Online required, notify anonymous)"], x = nX + 5, y = 100 })
	else
		-- sync social data
		Wnd.OpenWindow("SocialPanel")
		Wnd.CloseWindow("SocialPanel")
		-- show lover
		nX = ui:Append("Text", { txt = _HM_Love.szName, font = 19, x = 10, y = 36 }):Color(255, 128, 255):Pos_()
		local szMap = _HM_Love.GetLoverMap()
		if not szMap then
			ui:Append("Text", { txt = "(" .. g_tStrings.STR_GUILD_OFFLINE .. ")", font = 62, x= nX + 10, y = 36 })
		else
			ui:Append("Text", { txt = "(" .. g_tStrings.STR_GUILD_ONLINE .. ": " .. szMap .. ")", font = 80, x= nX + 10, y = 36 })
		end
		nX = ui:Append("Text", { txt = _HM_Love.GetLoverType(), font = 2, x = 10, y = 72 }):Pos_()
		nX = ui:Append("Text", { txt = _HM_Love.GetLoverTime(), font = 2, x = nX + 10, y = 72 }):Pos_()
		nX = ui:Append("Text", { txt = _L["[Break love]"], x = nX + 10, y = 72 })
		:Click(_HM_Love.RemoveLover, { 128, 255, 255 }, { 0, 255, 255 }):Pos_()
		if _HM_Love.nLoveType == 1 then
			nX = ui:Append("Text", { txt = _L["[Recovery]"], x = nX + 10, y = 72 }):Click(_HM_Love.FixLover, { 128, 255, 255 }, { 0, 255, 255 }):Pos_()
		end
		ui:Append("WndCheckBox", { txt = _L["Auto focus lover"], x = nX + 10, y = 72, checked = HM_Love.bAutoFocus })
		:Click(function(bChecked)
			HM_Love.bAutoFocus = bChecked
			if not bChecked and _HM_Love.dwID ~=0 and HM_TargetList and HM_TargetList.DelFocus then
				HM_TargetList.DelFocus(_HM_Love.dwID)
			end
		end)
	end
	-- local setting
	nX = ui:Append("Text", { txt = _L["Non-love display: "], x = 10, y = 128 }):Pos_()
	nX = ui:Append("WndEdit", { x = nX + 5, y = 128, limit = 20, w = 198, h = 25, txt = HM_Love.szNone })
	:Change(function(szText) HM_Love.szNone = szText end):Pos_()
	ui:Append("WndCheckBox", { txt = _L["Enable quiet mode"], x = nX + 5, y = 128, checked = HM_Love.bQuiet  })
	:Click(function(bChecked) HM_Love.bQuiet = bChecked end)
	-- jabber
	nX = ui:Append("Text", { txt = _L["Quick to accost text: "], x = 10, y = 156 }):Pos_()
	ui:Append("WndEdit", { x = nX + 5, y = 156, limit = 128, w = 340, h = 25, txt = HM_Love.szJabber })
	:Change(function(szText) HM_Love.szJabber = szText end)
	-- signature
	nX = ui:Append("Text", { txt = _L["Love signature: "], x = 10, y = 192, font = 27 }):Pos_()
	ui:Append("WndEdit", { x = nX + 5, y = 192, limit = 42, w = 340, h = 48, multi = true, txt = _HM_Love.szSign }):Change(_HM_Love.SetSign)
	-- tips
	ui:Append("Text", { txt = _L["Tips"], x = 0, y = 228, font = 27 })
	ui:Append("Text", { txt = _L["1. Amuse only, both sides need to install this plug-in"], x = 10, y = 253 })
	ui:Append("Text", { txt = _L["2. You can break love one-sided"], x = 10, y = 278 })
	ui:Append("Text", { txt = _L["3. Non-party views need to confirm (enable quiet to avoid)"], x = 10, y = 303 })
	_HM_Love.ui = ui
end

-- deinit
_HM_Love.PS.OnPanelDeactive = function()
	_HM_Love.ui = nil
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
HM.RegisterEvent("PEEK_OTHER_PLAYER", _HM_Love.OnPeekOtherPlayer)
HM.RegisterEvent("PLAYER_FELLOWSHIP_LOGIN", _HM_Love.OnFriendLogin)
HM.RegisterEvent("PLAYER_FELLOWSHIP_UPDATE", _HM_Love.OnFellowUpdate)
HM.RegisterEvent("FELLOWSHIP_CARD_CHANGE", _HM_Love.OnFellowUpdate)
HM.RegisterEvent("UPDATE_FELLOWSHIP_CARD", _HM_Love.OnFellowUpdate)
HM.RegisterEvent("PLAYER_ENTER_SCENE", _HM_Love.OnPlayerEnter)
HM.BreatheCall("HM_Love", _HM_Love.OnBreathe)
HM.RegisterBgMsg("HM_LOVE", _HM_Love.OnBgTalk)
-- add to HM collector
HM.RegisterPanel(HM_Love.szTitle, 329, _L["Recreation"], _HM_Love.PS)

-- view other lover by dwID
function HM_Love.PeekOther(dwID)
	ViewInviteToPlayer(dwID)
	_HM_Love.bActiveLove = true
	if not HM.IsParty(dwID) then
		_HM_Love.AskOtherData(dwID)
	end
end

-- add target menu
Target_AppendAddonMenu({ function(dwID)
	return {{
		szOption = _L["View love info"],
		fnDisable = function() return dwID == GetClientPlayer().dwID or not IsPlayer(dwID) end,
		fnAction = function() HM_Love.PeekOther(dwID) end
	}}
end })

