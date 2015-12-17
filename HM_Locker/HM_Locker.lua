--
-- ���������Ŀ��������TAB ��ǿ
--

HM_Locker = {
	bLockLeave = true,	-- ���������ٻع����ߵ�Ŀ��
	bLockFight = true,	-- ս���е���治��Ŀ��
	bLockDuel  = true, -- ���������Ĳ���
	bWhisperSel = true,	-- ���Ŀ���ѡ�����ģ�11 �ٶ�ѡ����ˣ�������ߣ�
	------------
	bSelectEnemy = true,
	bSelectNeutrality = false,
	bLowerNPC = true,
	tLowerForce = {},
	bPriorHP = true,
	bPriorDis = true,
	bPriorAxis = true,
	bPriorParty = true,
	--------
	tSearchTarget = { OnlyPlayer = false, OnlyNearDis = true, MidAxisFirst = false, Weakness = false },
}
HM.RegisterCustomData("HM_Locker")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Locker = {
	bLeave = false,	-- Ŀ���Ƿ��뿪����
	bDuelBuff = false, -- ���ƾ���BUFF
	nTigerFrame = 0,	-- ������Ŀ���֡��
	dwLastID = 0,		-- �����Ŀ��
	dwPrevID = 0,		-- �ϴε�Ŀ��
	nLastFrame = 0,	-- ���Ŀ��ı�֡��
	nLastSys = 0,
	tLocker = {},
	nScoffFrame = 0,	-- ���������е�֡�Σ����ܣ�
	dwScoffer = 0,
	nScoffFrame2 = 0,	-- ���� BUFF ֡��
	dwScoffer2 = 0,	-- ���� BUFF Դ
	nLastCancel = 0,	-- �ϴ�ȡ��Ŀ���ʱ��
}

-- sysmsg
_HM_Locker.Sysmsg = function(szMsg)
	HM.Sysmsg(szMsg, _L["HM_Locker"])
end

-- debug
_HM_Locker.Debug = function(szMsg)
	HM.Debug(szMsg, _L["HM_Locker"])
end

-- set prev target
_HM_Locker.SetPrevTarget = function()
	local nFrame = GetLogicFrameCount() - _HM_Locker.nLastFrame
	if _HM_Locker.dwPrevID ~= 0 and nFrame >= 0 and nFrame < 16 then
		local tar = HM.GetTarget(_HM_Locker.dwPrevID)
		if tar and tar.nMoveState ~= MOVE_STATE.ON_DEATH then
			HM.SetTarget(tar.dwID)
			_HM_Locker.dwPrevID = tar.dwID
			return _HM_Locker.Sysmsg(_L("Restore previous target [%s]", tar.szName))
		end
	end
end

-- check to lock target
-- fnAction = function(dwCurID, dwLastID)
_HM_Locker.AddLocker = function(fnAction)
	table.insert(_HM_Locker.tLocker, fnAction)
end

-- check lock fight
_HM_Locker.CheckLockFight = function(dwCurID, dwLastID)
	local me = GetClientPlayer()
	if HM_Locker.bLockFight and dwCurID == 0 and me.bFightState and me.nMoveState ~= MOVE_STATE.ON_JUMP then
		local nFrame = GetLogicFrameCount()
		if HM.IsDps(me) then
			if IsEnemy(me.dwID, dwLastID) then
				if (nFrame - _HM_Locker.nLastCancel) < 9 then
					return false
				elseif nFrame < _HM_Locker.nLastSys or (nFrame - _HM_Locker.nLastSys) > 12 then
					_HM_Locker.nLastSys = nFrame
					_HM_Locker.nLastCancel = nFrame
					_HM_Locker.Sysmsg(_L["Keep attack target in fighting"])
				end
				return true
			end
		else
			if not IsEnemy(me.dwID, dwLastID) then
				if (nFrame - _HM_Locker.nLastCancel) < 9 then
					return false
				elseif nFrame < _HM_Locker.nLastSys or (nFrame - _HM_Locker.nLastSys) > 12 then
					_HM_Locker.nLastSys = nFrame
					_HM_Locker.nLastCancel = nFrame
					_HM_Locker.Sysmsg(_L["Keep heal target in fighting"])
				end
				return true
			end
		end
	end
end

-- check cangyun duel
_HM_Locker.CheckDuel = function(dwCurID, dwLastID)
	if _HM_Locker.dwDuelID then
		if HM.HasBuff(10212) then
			if dwCurID ~= _HM_Locker.dwDuelID then
				_HM_Locker.dwLastID = _HM_Locker.dwDuelID
				_HM_Locker.Sysmsg(_L["Keep attack target in duel"])
				return true
			end
		else
			_HM_Locker.dwDuelID = nil
			return false
		end
	end
end

-- update enemy search options
_HM_Locker.UpdateSearchTarget = function()
	if not SearchTarget_IsOldVerion() then
		for k, v in pairs(HM_Locker.tSearchTarget) do
			SearchTarget_SetOtherSettting(k, v, "Enmey")
			SearchTarget_SetOtherSettting(k, v, "Ally")
		end
	end
end

-- only search player
_HM_Locker.SearchOnlyPlayer = function(bEnable)
	if bEnable == nil then
		bEnable = not  HM_Locker.tSearchTarget.OnlyPlayer
		if _HM_Locker.OnlyPlayerBox then
			return _HM_Locker.OnlyPlayerBox:Check(bEnable)
		end
	end
	HM_Locker.tSearchTarget.OnlyPlayer = bEnable
	_HM_Locker.UpdateSearchTarget()
	if bEnable then
		HM.Sysmsg(_L["Enable TAB only select player"])
	else
		HM.Sysmsg(_L["Disable TAB only select player"])
	end
end

-------------------------------------
-- �¼�����
-------------------------------------
_HM_Locker.OnCheckDuel = function()
	if arg0 == "UI_OME_SKILL_EFFECT_LOG" and arg2 == UI_GetClientPlayerID() and arg5 == 15196 then
		_HM_Locker.dwDuelID = arg1
		HM.SetTarget(TARGET.PLAYER, arg1)
	end
end

-- update target
_HM_Locker.OnUpdateTarget = function()
	if TargetPanel_GetOpenState() then
		return
	end
	local me = GetClientPlayer()
	local dwType, dwID = me.GetTarget()
	if _HM_Locker.dwLastID ~= dwID then
		HM.Debug2("update target [#" .. dwType .. "#" .. dwID .. "]")
		-- always allowed to selectself
		if dwID ~= me.dwID and _HM_Locker.dwLastID ~= 0 then
			local tar0 = HM.GetTarget(_HM_Locker.dwLastID)
			if tar0 and tar0.nMoveState ~= MOVE_STATE.ON_DEATH then
				for _, v in ipairs(_HM_Locker.tLocker) do
					if v(dwID, _HM_Locker.dwLastID) then
						return HM.SetTarget(_HM_Locker.dwLastID)
						--return _HM_Locker.Sysmsg(_L("Keep locked target [%s]", tar0.szName))
					end
				end
			end
		end
		-- save new last
		if not _HM_Locker.bLeave or dwID ~= 0 then
			_HM_Locker.bLeave, _HM_Locker.nLastFrame = false, GetLogicFrameCount()
			_HM_Locker.dwPrevID, _HM_Locker.dwLastID = _HM_Locker.dwLastID, dwID
		end
	end
end

-- target levave
 _HM_Locker.OnLeave = function()
	if HM_Locker.bLockLeave and _HM_Locker.dwLastID == arg0 then
		_HM_Locker.Debug("target leave scene [#" .. arg0 .. "]")
		_HM_Locker.bLeave = true
	end
end

-- target enter
_HM_Locker.OnEnter = function()
	if HM_Locker.bLockLeave and _HM_Locker.dwLastID == arg0 then
		_HM_Locker.Debug("locked target enter scene [#" .. arg0 .. "]")
		_HM_Locker.bLeave = false
		HM.SetTarget(_HM_Locker.dwLastID)
	end
end

-- player talk to quick select target
-- arg0��dwTalkerID��arg1��nChannel��arg2��bEcho��arg3��szName
_HM_Locker.OnPlayerTalk = function()
	if not HM_Locker.bWhisperSel then return end
	local me = GetClientPlayer()
	if me and arg0 == me.dwID and arg1 == PLAYER_TALK_CHANNEL.WHISPER and arg2 == true then
		local t = me.GetTalkData()
		if #t == 1 and t[1].type == "text" and (t[1].text == "11" or (HM_TargetList and t[1].text == "33")) then
			local szName = arg3
			for _, v in ipairs(HM.GetAllPlayer()) do
				if v.szName == arg3 then
					if t[1].text == "11" then
						HM.SetTarget(TARGET.PLAYER, v.dwID)
					else
						HM_TargetList.AddFocus(v.dwID)
					end
					break
				end
			end
		elseif #t == 1 and t[1].type == "text" and t[1].text == "66" and arg3 == me.szName then
			HM_Locker.tLowerForce[21] = not HM_Locker.tLowerForce[21]
		end
	end
end

-- register locker
_HM_Locker.AddLocker(_HM_Locker.CheckLockFight)
_HM_Locker.AddLocker(_HM_Locker.CheckDuel)
-------------------------------------
-- Ŀ�����ѡ��
-- 1. ��ѡĿ�� ��NPC ��50 ����������
-- 2. ����ĳЩְҵ�����
-- 3. �ۺ�����Ѫ�������򡢾���
-------------------------------------
_HM_Locker.IsFarDps = function(me)
	-- TC,MJ,CJ,GB
	if me.dwForceID == 0 or me.dwForceID == 1 or me.dwForceID == 3 or me.dwForceID == 8 or me.dwForceID == 10 then
		return false
	end
	-- JC
	local mnt = me.GetKungfuMount()
	if mnt and mnt.dwSkillID == 10015 then
		return false
	end
	return HM.IsDps(me)
end

_HM_Locker.CalcFace = function(me, tar, nDis)
	local nX = tar.nX - me.nX
	local nY = tar.nY - me.nY
	local nFace =  me.nFaceDirection / 256 * 360
	local nDeg = 0
	if nY == 0 then
		if nX < 0 then
			nDeg = 180
		end
	elseif nX == 0 then
		if nY > 0 then
			nDeg = 90
		else
			nDeg = 270
		end
	else
		nDeg = math.deg(math.atan(nY / nX))
		if nX < 0 then
			nDeg = 180 + nDeg
		elseif nY < 0 then
			nDeg = 360 + nDeg
		end
	end
	local nAngle = nFace - nDeg
	if nAngle < -180 then
		nAngle = nAngle + 360
	elseif nAngle > 180 then
		nAngle = nAngle - 360
	end
	nAngle = math.abs(nAngle)
	if nAngle > 85 then
		return 2
	elseif nAngle < 30 and (nDis < 6 or (nDis < 15 and _HM_Locker.IsFarDps(me))) then
		return 0
	else
		return 1
	end
end

local tJustList = {}
local nJustFrame = 0
local LOWER_DIS = 35
local LOWER_DIS2 = 45
local tLowerNpc = {
	[12944] = true, -- �̵�
	[9998]  = true, -- ����
	[9999]  = true, -- ���
	[9997]  = true, -- ����
	[9956]  = true, -- ʥЫ
	[46140] = true, -- ����Ӱ�� ���Ӱ��
	[46297] = true, -- ����Ӱ�� ��Ӱ��б
}

_HM_Locker.SearchTarget = function()
	local nFrame = GetLogicFrameCount()
	if (nFrame - nJustFrame) > 12 then
		tJustList = {}
	end
	nJustFrame = nFrame
	local me = GetClientPlayer()
	local _, dwTarget = me.GetTarget()
	local bBattle = IsInBattleField()
	-- load player
	local tList, tList2 = {}, {}
	for _, v in ipairs(HM.GetAllPlayer()) do
		if v.dwID == dwTarget or v.nMoveState == MOVE_STATE.ON_DEATH then
			-- skip current target
		elseif (HM_Locker.bSelectEnemy and IsEnemy(me.dwID, v.dwID))
			or (not HM_Locker.bSelectEnemy and IsAlly(me.dwID, v.dwID))
		then
			local nDis = HM.GetDistance(v)
			if  nDis > LOWER_DIS and not IsEmpty(tList) then
				-- need not far target
			else
				local item = { dwID = v.dwID, nType = TARGET.PLAYER }
				item.nSel = tJustList[v.dwID] or 0
				if v.dwID == _HM_Locker.dwDuelID then
					item.nSel = -1
				end
				if HM_Locker.bSelectEnemy and HM_Locker.tLowerForce[v.dwForceID] then
					item.nForce = 1
				else
					item.nForce = 0
				end
				if HM_Locker.bPriorDis then
					item.nDis = math.floor(nDis / 4)
				end
				if HM_Locker.bPriorHP then
					item.nHP = math.floor(10 * v.nCurrentLife / math.max(1, v.nMaxLife))
				end
				if HM_Locker.bPriorAxis then
					if v.szName == _L["HMM5"] then
						if HM_Locker.bSelectEnemy then
							item.nFace = 2
						elseif nDis < 15 then
							item.nFace = 0
						else
							item.nFace = 1
						end
					else
						item.nFace = _HM_Locker.CalcFace(me, v, nDis)
					end
				end
				if (item.nDis == 0 or (item.nHP and item.nHP < 4)) and item.nFace == 0 then
					item.nForce = 0
				end
				if HM_Locker.bPriorParty then
					if not HM_Locker.bSelectEnemy and IsParty(me.dwID, v.dwID) then
						item.nParty = 0
					else
						item.nParty = 1
					end
				end
				if nDis > LOWER_DIS then
					table.insert(tList2, item)
				else
					table.insert(tList, item)
				end
			end
		end
	end
	local bEmptyPlayer = IsEmpty(tList)
	local bEmptyPlayer2 = IsEmpty(tList2)
	-- load npc
	if not HM_Locker.bLowerNPC or bEmptyPlayer or bBattle then
		for _, v in ipairs(HM.GetAllNpc()) do
			if v.dwID == dwTarget or v.nMoveState == MOVE_STATE.ON_DEATH or not v.IsSelectable() then
				-- skip current target
			elseif (HM_Locker.bSelectEnemy and IsEnemy(me.dwID, v.dwID))
				or (not HM_Locker.bSelectEnemy and IsAlly(me.dwID, v.dwID))
				or (HM_Locker.bSelectNeutrality and IsNeutrality(me.dwID, v.dwID))
			then
				local nDis = HM.GetDistance(v)
				if  nDis > LOWER_DIS2 and not IsEmpty(tList) then
					-- need not far target
				else
					local item = { dwID = v.dwID, nType = TARGET.NPC }
					item.nSel = tJustList[v.dwID] or 0
					item.nForce = HM_Locker.bLowerNPC and 1 or 0
					item.nNpc = 0
					if GetNpcIntensity(v) ~= 4 then
						item.nNpc = item.nNpc + 1
					end
					------
					-- ս���ڵ� boss ����Ҿ���ͬ�����ȼ�
					-- 474=���˹���̽��475=��������̽��476=��һ��ʬ����6962/6963=˿����ڳ�
					if bBattle and (v.dwTemplateID == 474 or v.dwTemplateID == 475 or v.dwTemplateID == 476
						or v.dwTemplateID == 6962 or v.dwTemplateID == 6963)
					then
						item.nRealType = TARGET.NPC
						item.nType = TARGET.PLAYER
						item.nForce = 0
						item.nNpc = 0
					end
					if tLowerNpc[v.dwTemplateID] then -- ������͵�NPC �嶾���ﳪ��Ӱ��֮���
						item.nForce = 2
					end
					------
					if IsNeutrality(me.dwID, v.dwID) then
						item.nNpc = item.nNpc + 1
					end
					if HM_Locker.bPriorDis then
						item.nDis = math.floor(nDis / 4)
					end
					if HM_Locker.bPriorHP then
						item.nHP = math.floor(5 * v.nCurrentLife / math.max(1, v.nMaxLife))
					end
					if HM_Locker.bPriorAxis then
						item.nFace = _HM_Locker.CalcFace(me, v, nDis)
					end
					if HM_Locker.bPriorParty then
						item.nParty = 1
					end
					if nDis > LOWER_DIS2 then
						table.insert(tList2, item)
					else
						table.insert(tList, item)
					end
				end
			end
		end
	end
	-- sort list
	if IsEmpty(tList) then
		tList = tList2
	end
	table.sort(tList, function(a, b)
		-- just list
		if a.nSel ~= b.nSel then
			return a.nSel < b.nSel
		end
		-- npc lower
		if HM_Locker.bLowerNPC and a.nType ~= b.nType then
			return a.nType > b.nType
		end
		-- force lower
		if a.nForce ~= b.nForce then
			return a.nForce < b.nForce
		end
		-- face
		if a.nFace and a.nFace ~= b.nFace then
			return a.nFace < b.nFace
		end
		-- npc
		if a.nNpc and b.nNpc and a.nNpc ~= b.nNpc then
			return a.nNpc < b.nNpc
		end
		-- near(<16, hp dis >= 40%)
		if a.nDis and a.nHp and a.nDis < 4 and b.nDis < 4 and math.abs(a.nDis - b.nDis) < 2 and math.abs(a.nHp - b.nHp) >= 3 then
			return a.nHp < b.nHp
		end
		-- dist
		if a.nDis and a.nDis ~= b.nDis then
			return a.nDis < b.nDis
		end
		-- nHp
		if a.nHp and a.nHp ~= b.nHp then
			return a.nHp < b.nHp
		end
		-- party
		if a.nParty then
			return a.nParty < b.nParty
		end
		return false
	end)
	if not IsEmpty(tList) then
		-- select firt target
		local dwTarget = tList[1].dwID
		tJustList[dwTarget] = 1
		SetTarget(tList[1].nRealType or tList[1].nType, dwTarget)
	end
end

-- �Ƿ������˲�� Tab
--[[
local KEY_TAB = 9
_HM_Locker.EnableSmartTab = function(bEnable)
	if bEnable == nil then
		-- is enabled or not
		for i = 1, 2 do
			local nKey, bShift, bCtrl, bAlt = Hotkey.Get("HM_SmartTarget", i)
			if nKey == KEY_TAB and not bShift and not bCtrl and not bAlt then
				return true
			end
		end
		return false
	elseif bEnable == true then
		-- enable smart tab
		Hotkey.Set("HM_SmartTarget", 1, KEY_TAB, false, false, false)
	else
		-- disable smart tab
		if HM_Locker.bSelectEnemy then
			Hotkey.Set("SEARCH_ENEMY", 1, KEY_TAB, false, false, false)
		else
			Hotkey.Set("SEARCH_ALLIES", 1, KEY_TAB, false, false, false)
		end
	end
end
--]]

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Locker.PS = {}

-- deinit panel
_HM_Locker.PS.OnPanelDeactive = function(frame)
	_HM_Locker.OnlyPlayerBox = nil
end

-- init panel
_HM_Locker.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	-- locker
	ui:Append("Text", { txt = _L["Target locker"], font = 27 })
	nX = ui:Append("WndCheckBox", { txt = _L["Lock target when it leave scene"], x = 10, y = 28, checked = HM_Locker.bLockLeave })
	:Click(function(bChecked)
		HM_Locker.bLockLeave = bChecked
	end):Pos_()
	ui:Append("Text", { txt = _L["(Auto select on entering scene)"], x = nX, y = 28, font = 161 })
	ui:Append("WndCheckBox", { x = 10, y = 56, checked = HM_Locker.bLockFight })
	:Text(_L["Keep current attack/heal target in fighting when click ground"]):Click(function(bChecked)
		HM_Locker.bLockFight = bChecked
	end)
	ui:Append("WndCheckBox", { x = 10, y = 84, checked = HM_Locker.bLockDuel })
	:Text(_L["Keep attack target in duel"]):Click(function(bChecked)
		HM_Locker.bLockDuel = bChecked
	end)
	-- whisper select
	--ui:Append("Text", { txt = _L["Select target by whisper"], x = 0, y = 92, font = 27 })
	ui:Append("WndCheckBox", { x = 10, y = 120, checked = HM_Locker.bWhisperSel })
	:Text(_L["Select as target when you send 11 to around player"]):Click(function(bChecked)
		HM_Locker.bWhisperSel = bChecked
	end)
	-- tab enhance
	local bNew, tOption = not SearchTarget_IsOldVerion(), HM_Locker.tSearchTarget
	ui:Append("Text", { txt = _L["Offical TAB enhancement (must enable new target policy)"], x = 0, y = 156, font = 27 })
	_HM_Locker.OnlyPlayerBox = ui:Append("WndCheckBox", { x = 10, y = 184, enable = bNew, checked = tOption.OnlyPlayer })
	nX = _HM_Locker.OnlyPlayerBox:Text(_L["Player only (not NPC, "]):Click(_HM_Locker.SearchOnlyPlayer):Pos_()
	nX = ui:Append("Text", { x = nX, y = 184, txt = _L["Hotkey"] }):Click(HM.SetHotKey):Pos_()
	ui:Append("Text", { x = nX , y = 184, txt = HM.GetHotKey("OnlyPlayer") .._L[") "] })
	nX = ui:Append("WndRadioBox", { x = 10, y = 212, checked = tOption.Weakness, group = "-tab" })
	:Text(_L["Priority less HP"]):Enable(bNew):Click(function(bChecked)
		tOption.Weakness = bChecked
		_HM_Locker.UpdateSearchTarget()
	end):Pos_()
	nX = ui:Append("WndRadioBox", { x = nX + 20, y = 212, checked = tOption.OnlyNearDis, group = "-tab" })
	:Text(_L["Priority closer"]):Enable(bNew):Click(function(bChecked)
		tOption.OnlyNearDis = bChecked
		_HM_Locker.UpdateSearchTarget()
	end):Pos_()
	nX = ui:Append("WndRadioBox", { x = nX + 20, y = 212, checked = tOption.MidAxisFirst, group = "-tab" })
	:Text(_L["Priority less face angle"]):Enable(bNew):Click(function(bChecked)
		tOption.MidAxisFirst = bChecked
		_HM_Locker.UpdateSearchTarget()
	end):Pos_()
	-- HM smart tab
	ui:Append("Text", { txt = _L["HM target search (used to replace TAB)"], x = 0, y = 248, font = 27 })
	nX = ui:Append("WndRadioBox", { x = 10, y = 276, checked = HM_Locker.bSelectEnemy, group = "tabs" })
	:Text(_L["Enemy"]):Click(function(bChecked)
		HM_Locker.bSelectEnemy = bChecked
		ui:Fetch("Check_Party"):Enable(not bChecked)
	end):Pos_()
	nX = ui:Append("WndRadioBox", { x = nX + 10, y = 276, checked = not HM_Locker.bSelectEnemy, group = "tabs" })
	:Text(_L["Ally"]):Click(function(bChecked)
		HM_Locker.bSelectEnemy = not bChecked
	end):Pos_()
	nX = ui:Append("Text", { x = nX + 20, y = 275, txt = _L["To use smart TAB, please set "] }):Pos_()
	nX = ui:Append("Text", { x = nX, y = 275, txt = _L["Hotkey"] }):Click(HM.SetHotKey):Pos_()
	ui:Append("Text", { x = nX , y = 275, txt = HM.GetHotKey("SmartTarget", true) })
	nX = ui:Append("WndCheckBox", { x = 10, y = 304, checked = HM_Locker.bLowerNPC })
	:Text(_L["Lower select NPC"]):Click(function(bChecked)
		HM_Locker.bLowerNPC = bChecked
	end):Pos_()
	nX = ui:Append("WndCheckBox", "Check_Party", { x = nX + 20, y = 304, checked = HM_Locker.bPriorParty })
	:Text(_L["Priority party player"]):Enable(not HM_Locker.bSelectEnemy):Click(function(bChecked)
		HM_Locker.bPriorParty = bChecked
	end):Pos_()
	nX = ui:Append("WndCheckBox", { x = nX + 20, y = 304, checked = HM_Locker.bSelectNeutrality })
	:Text(_L["Select neutral NPC"]):Click(function(bChecked)
		HM_Locker.bSelectNeutrality = bChecked
	end):Pos_()
end

-- player menu
_HM_Locker.PS.OnPlayerMenu = function()
	return {
		szOption = _L["Enable TAB select player only"] .. HM.GetHotKey("OnlyPlayer", true),
		bCheck = true, bChecked = HM_Locker.tSearchTarget.OnlyPlayer,
		fnDisable = SearchTarget_IsOldVerion,
		fnAction = function(d, b) _HM_Locker.SearchOnlyPlayer(b) end
	}
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
HM.RegisterEvent("SYNC_ROLE_DATA_END", _HM_Locker.UpdateSearchTarget)
HM.RegisterEvent("TARGET_CHANGE",  _HM_Locker.OnUpdateTarget)
HM.RegisterEvent("NPC_LEAVE_SCENE", _HM_Locker.OnLeave)
HM.RegisterEvent("PLAYER_LEAVE_SCENE", _HM_Locker.OnLeave)
HM.RegisterEvent("NPC_ENTER_SCENE", _HM_Locker.OnEnter)
HM.RegisterEvent("PLAYER_ENTER_SCENE", _HM_Locker.OnEnter)
HM.RegisterEvent("PLAYER_TALK", _HM_Locker.OnPlayerTalk)
HM.RegisterEvent("SYS_MSG", _HM_Locker.OnCheckDuel)

-- add to HM panel
HM.RegisterPanel(_L["Lock/Select"], 3353, _L["Target"], _HM_Locker.PS)

-- hotkey
HM.AddHotKey("SmartTarget", _L["Smart select target"], _HM_Locker.SearchTarget)
HM.AddHotKey("OnlyPlayer", _L["TAB player only"],  _HM_Locker.SearchOnlyPlayer)

-- public api
HM_Locker.AddLocker = _HM_Locker.AddLocker
HM_Locker.SetPrevTarget = _HM_Locker.SetPrevTarget
