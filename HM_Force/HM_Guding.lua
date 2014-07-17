--
-- ����������嶾�����ƶ���ʾ
--

HM_Guding = {
	bEnable = true,			-- �ܿ���
	bAutoSay = true,			-- �ڶ����Զ�˵��
	szSay = _L["I have put the GUDING, hurry to eat if you lack of mana. *la la la*"],
	color = { 255, 0, 128 },	-- ������ɫ��Ĭ����ɫ
}
HM.RegisterCustomData("HM_Guding")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Guding = {
	nMaxDelay = 500,	-- �ͷźͳ��ֵ����ʱ���λ����
	nMaxTime = 60000, -- ���ڵ����ʱ�䣬��λ����
	dwSkillID = 2234,
	dwTemplateID = 2418,
	szIniFile = "interface\\HM\\HM_Force\\HM_Guding.ini",
	tList = {},					-- ��ʾ��¼ (#ID => nTime)
	tCast = {},				-- �����ͷż�¼
	nFrame = 0,			-- �ϴ��Զ��Զ�������֡��
}

-- sysmsg
_HM_Guding.Sysmsg = function(szMsg)
	HM.Sysmsg(szMsg, _L["HM_Guding"])
end

-- debug
_HM_Guding.Debug = function(szMsg)
	HM.Debug2(szMsg, _L["HM_Guding"])
end

-- add to list
_HM_Guding.AddToList = function(tar, dwCaster, dwTime, szEvent)
	_HM_Guding.tList[tar.dwID] = { dwCaster = dwCaster, dwTime = dwTime }
	-- bg notify
	local me = GetClientPlayer()
	if szEvent == "DO_SKILL_CAST" and me.IsInParty() then
		HM.BgTalk(PLAYER_TALK_CHANNEL.RAID, "HM_GUDING_NOTIFY", tar.dwID, dwCaster)
	end
	if HM_Guding.bAutoSay and me.dwID == dwCaster then
		local nChannel = PLAYER_TALK_CHANNEL.RAID
		if not me.IsInParty() then
			nChannel = PLAYER_TALK_CHANNEL.NEARBY
		end
		HM.Talk(nChannel, HM_Guding.szSay)
	end
end

-- remove record
_HM_Guding.RemoveFromList = function(dwID)
	_HM_Guding.tList[dwID] = nil
end

-------------------------------------
-- �¼�������
-------------------------------------
-- skill cast log
_HM_Guding.OnSkillCast = function(dwCaster, dwSkillID, dwLevel, szEvent)
	local myID, player = GetClientPlayer().dwID, GetPlayer(dwCaster)
	if player and dwSkillID == _HM_Guding.dwSkillID and (dwCaster == myID or HM.IsParty(dwCaster)) then
		table.insert(_HM_Guding.tCast, { dwCaster = dwCaster, dwTime = GetTime(), szEvent = szEvent })
		_HM_Guding.Debug("[" .. player.szName .. "] cast [" .. HM.GetSkillName(dwSkillID, dwLevel) .. "#" .. szEvent .. "]")
	end
end

-- doodad enter
_HM_Guding.OnDoodadEnter = function()
	local tar = GetDoodad(arg0)
	if not tar or _HM_Guding.tList[arg0] or tar.dwTemplateID ~= _HM_Guding.dwTemplateID then
		return
	end
	_HM_Guding.Debug("[" .. tar.szName .. "] enter scene")
	-- find caster
	for k, v in ipairs(_HM_Guding.tCast) do
		local nTime = GetTime() - v.dwTime
		_HM_Guding.Debug("checking [#" .. v.dwCaster .. "], delay [" .. nTime .. "]")
		if nTime < _HM_Guding.nMaxDelay then
			table.remove(_HM_Guding.tCast, k)
			_HM_Guding.AddToList(tar, v.dwCaster, v.dwTime, v.szEvent)
			return _HM_Guding.Debug("matched [" .. tar.szName .. "] casted by [#" .. v.dwCaster .. "]")
		end
	end
	-- purge
	for k, v in pairs(_HM_Guding.tCast) do
		if (GetTime() - v.dwTime) > _HM_Guding.nMaxDelay then
			table.remove(_HM_Guding.tCast, k)
		end
	end
end

-- notify
_HM_Guding.OnSkillNotify = function()
	local data = HM.BgHear("HM_GUDING_NOTIFY")
	if data then
		local dwID = tonumber(data[1])
		if not _HM_Guding.tList[dwID] then
			_HM_Guding.tList[dwID] = { dwCaster = tonumber(data[2]), dwTime = GetTime() }
			_HM_Guding.Debug("received notify from [#" .. data[2] .. "]")
		end
	end
end

-------------------------------------
-- ���ں���
-------------------------------------
-- create
function HM_Guding.OnFrameCreate()
	_HM_Guding.pLabel = this:Lookup("", "Shadow_Label")
	this:RegisterEvent("SYS_MSG")
	this:RegisterEvent("DO_SKILL_CAST")
	this:RegisterEvent("DOODAD_ENTER_SCENE")
	this:RegisterEvent("ON_BG_CHANNEL_MSG")
end

-- breathe
function HM_Guding.OnFrameBreathe()
	-- skip frame
	local nFrame = GetLogicFrameCount()
	if nFrame >= _HM_Guding.nFrame and (nFrame - _HM_Guding.nFrame) < 8 then
		return
	end
	_HM_Guding.nFrame = nFrame
	-- check empty
	local sha, me = _HM_Guding.pLabel, GetClientPlayer()
	if not me or not HM_Guding.bEnable or IsEmpty(_HM_Guding.tList) then
		return sha:Hide()
	end
	-- color, alpha
	local r, g, b = unpack(HM_Guding.color)
	local a = 200
	if HM.HasBuff(3448, false) then
		a = 120
	end
	-- shadow text
	sha:SetTriangleFan(GEOMETRY_TYPE.TEXT)
	sha:ClearTriangleFanPoint()
	sha:Show()
	for k, v in pairs(_HM_Guding.tList) do
		local nLeft = v.dwTime + _HM_Guding.nMaxTime - GetTime()
		if nLeft < 0 then
			_HM_Guding.RemoveFromList(k)
		else
			local tar = GetDoodad(k)
			if tar then
				--  show name
				local szText = _L["-"] .. math.floor(nLeft / 1000)
				local player = GetPlayer(v.dwCaster)
				if player then
					szText = player.szName .. szText
				else
					szText = tar.szName .. szText
				end
				sha:AppendDoodadID(tar.dwID, r, g, b, a, 192, 199, szText, 0, 1)
			end
		end
	end
end

-- event
function HM_Guding.OnEvent(event)
	if not HM_Guding.bEnable then
		return
	elseif event == "SYS_MSG" then
		if arg0 == "UI_OME_SKILL_HIT_LOG" then
			_HM_Guding.OnSkillCast(arg1, arg4, arg5, arg0)
		elseif arg0 == "UI_OME_SKILL_EFFECT_LOG" then
			_HM_Guding.OnSkillCast(arg1, arg5, arg6, arg0)
		end
	elseif event == "DO_SKILL_CAST" then
		_HM_Guding.OnSkillCast(arg0, arg1, arg2, event)
	elseif event == "DOODAD_ENTER_SCENE" then
		_HM_Guding.OnDoodadEnter()
	elseif event == "ON_BG_CHANNEL_MSG" then
		_HM_Guding.OnSkillNotify()
	end
end

-- get doodad list
function HM_Guding.GetDoodadList()
	return _HM_Guding.tList
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- open hidden window
local frame = Station.Lookup("Lowest/HM_Guding")
if frame then Wnd.CloseWindow(frame) end
Wnd.OpenWindow(_HM_Guding.szIniFile, "HM_Guding")
