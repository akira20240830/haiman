--
-- ����������嶾�����ƶ���ʾ���Զ���
--

HM_Guding = {
	bEnable = true,			-- �ܿ���
	bAutoUse = true,		-- ·��ʱ�Զ���
	nAutoMp = 80,			-- �Զ��Ե� MP �ٷֱ�
	nAutoHp = 80,			-- �Զ��Ե� HP �ٷֱ�
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
	szIniFile = "interface\\HM\\ui\\HM_Guding.ini",
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
	-- can use or not
	local bCanUse = false
	if HM_Guding.bAutoUse and a > 199
		and not me.bOnHorse and me.nMoveState == MOVE_STATE.ON_STAND and me.GetOTActionState() == 0
		and ((me.nCurrentMana / me.nMaxMana) <= (HM_Guding.nAutoMp / 100)
			or (me.nCurrentLife / me.nMaxLife) <= (HM_Guding.nAutoHp / 100))
	then
		bCanUse = true
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
				--  check to use
				if bCanUse and HM.GetDistance(tar) < 6 then
					bCanUse = false
					InteractDoodad(tar.dwID)
					_HM_Guding.Sysmsg(_L["Auto use GUDING"])
				end
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

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Guding.PS = {}

-- init panel
_HM_Guding.PS.OnPanelActive = function(frame)
	local ui = HM.UI(frame)
	ui:Append("Text", { txt = _L["Options"], font = 27 })
	local nX = ui:Append("WndCheckBox", { txt = _L["Display GUDING of teammate, change color"], checked = HM_Guding.bEnable })
	:Pos(10, 28):Click(function(bChecked)
		HM_Guding.bEnable = bChecked
		ui:Fetch("Check_Use"):Enable(bChecked)
		ui:Fetch("Check_Say"):Enable(bChecked)
		ui:Fetch("Track_MP"):Enable(bChecked)
		ui:Fetch("Track_HP"):Enable(bChecked)
	end):Pos_()
	nX = ui:Append("Shadow", "Shadow_Color", { x = nX + 2, y = 32, w = 18, h = 18 })
	:Color(unpack(HM_Guding.color)):Click(function()
		OpenColorTablePanel(function(r, g, b)
			ui:Fetch("Shadow_Color"):Color(r, g, b)
			HM_Guding.color = { r, g, b }
		end)
	end):Pos_()
	ui:Append("WndCheckBox", "Check_Use", { txt = _L["Auto use GUDING in some condition (only when standing)"], checked = HM_Guding.bAutoUse })
	:Pos(10, 56):Enable(HM_Guding.bEnable):Click(function(bChecked)
		HM_Guding.bAutoUse = bChecked
		ui:Fetch("Track_MP"):Enable(bChecked)
		ui:Fetch("Track_HP"):Enable(bChecked)
	end)
	nX = ui:Append("Text", { txt = _L["While MP less than"], x = 38, y = 84 }):Pos_()
	ui:Append("WndTrackBar", "Track_MP", { x = nX, y = 88, enable = HM_Guding.bAutoUse })
	:Range(0, 100, 50):Value(HM_Guding.nAutoMp):Change(function(nVal) HM_Guding.nAutoMp = nVal end)
	nX = ui:Append("Text", { txt = _L["While HP less than"], x = 38, y = 112 }):Pos_()
	ui:Append("WndTrackBar", "Track_HP", { x = nX, y = 116, enable = HM_Guding.bAutoUse })
	:Range(0, 100, 50):Value(HM_Guding.nAutoHp):Change(function(nVal) HM_Guding.nAutoHp = nVal end)
	ui:Append("WndCheckBox", "Check_Say", { txt = _L["Auto talk in team channel after puting GUDING"], checked = HM_Guding.bAutoSay })
	:Pos(10, 140):Enable(HM_Guding.bEnable):Click(function(bChecked)
		HM_Guding.bAutoSay = bChecked
		ui:Fetch("Edit_Say"):Enable(bChecked)
	end)
	ui:Append("Text", { txt = _L["Talk message"], font = 27, x = 0, y = 176 })
	ui:Append("WndEdit", "Edit_Say", { x = 14, y = 204, multi = true, limit = 512, w = 430, h = 60 })
	:Text(HM_Guding.szSay):Enable(HM_Guding.bAutoSay):Change(function(szText)
		HM_Guding.szSay = szText
	end)
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- add to HM panel
HM.RegisterPanel(_L["5D GUDING"], 2747, nil, _HM_Guding.PS)

-- open hidden window
local frame = Station.Lookup("Lowest/HM_Guding")
if frame then Wnd.CloseWindow(frame) end
Wnd.OpenWindow(_HM_Guding.szIniFile, "HM_Guding")
