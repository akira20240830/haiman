--
-- ���������ְҵ��ɫ��ǿ������������м��������������ܶ��Լ���̫����
--

HM_Force = {
	bHorsePage = true,	-- �������л�������������ߣ�
	bSelfTaiji = true,			-- ���ܶ��Լ���̫������������
	bSelfTaiji2 = false,		-- ��Զֻ���Լ���̫��
	bAlertPet = true,			-- �嶾������ʧ����
	bMarkPet = true,			-- �嶾������
	bAutoDance = true,	-- �����Զ�����
	bAutoXyz = true,		-- �Զ���Ŀ��ִ�з�Χָ����
	bAutoXyzSelf = true,	-- �Զ����Լ���
	bShowJW = true,			-- ��ʾ�������
	tSelfQC = { [358] = true },	-- Ĭ��ֻ����̫��
	bWarningDebuff = true,	-- ����  debuff ����
	nDebuffNum = 3,			-- debuff ���ʹﵽ����ʱ����
	bActionTime = true,	-- ��ʾ����������ʱ
	bAlertWanted = true,	-- ���߱�����ʱ�����Լ�
	bHorseReplace = true,	-- ս���������滻ս��
}
HM.RegisterCustomData("HM_Force")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Force = {
	nFrameXJ = 0,
	-- nActionTotal, nActionEnd, bActionDec
	nFrameMP = 0,
}

-- qichang
_HM_Force.tQC = {
	[357] = { dwBuffID = 373 },
	[358] = { dwBuffID = 374 },
	[359] = { dwBuffID = 375 },
	[360] = { dwBuffID = 376 },
	[361] = { dwBuffID = 561 },
	[362] = { dwBuffID = 378 },
}

-- get qc menu
_HM_Force.GetQCMenu = function()
	local m0 = {}
	for k, v in pairs(_HM_Force.tQC) do
		table.insert(m0, { szOption = HM.GetSkillName(k), bCheck = true, bChecked = HM_Force.tSelfQC[k],
			fnAction = function (d, b) HM_Force.tSelfQC[k] = b end
		})
	end
	return m0
end

-- use non-target skill
_HM_Force.OnUseEmptySkill = function(dwID)
	local me = GetClientPlayer()
	if me and HM.CanUseSkill(dwID) then
		local tarType, tarID = me.GetTarget()
		if tarID ~= 0 and tarType == TARGET.PLAYER then
			HM.SetInsTarget(TARGET.NO_TARGET, 0)
		end
		OnAddOnUseSkill(dwID, 1)
		HM.SetTarget(tarType, tarID)
		return true
	end
end

-- update pet mark
_HM_Force.UpdatePetMark = function(bMark)
	local pet = GetClientPlayer().GetPet()
	if pet then
		local dwEffect = 13
		if not bMark then
			dwEffect = 0
		end
		SceneObject_SetTitleEffect(TARGET.NPC, pet.dwID, dwEffect)
	end
end

-- check horse page
_HM_Force.OnRideHorse = function()
	if HM_Force.bHorsePage then
		local me = GetClientPlayer()
		if me then
			local mnt = me.GetKungfuMount()
			if mnt and mnt.dwSkillID == 10026 then
				local nPage = GetUserPreferences(1390, "c")
				if me.bOnHorse and nPage ~= 3 then
					SelectMainActionBarPage(3)
				elseif not me.bOnHorse and nPage ~= 1 then
					SelectMainActionBarPage(1)
				end
			end
		end
	end
end

-- check to mark pet
_HM_Force.OnNpcEnter = function()
	if HM_Force.bMarkPet then
		local pet = GetClientPlayer().GetPet()
		if pet and arg0 == pet.dwID then
			HM.DelayCall(500, function()
				_HM_Force.UpdatePetMark(true)
			end)
		end
	end
end
_HM_Force.OnNpcUpdate = _HM_Force.OnNpcEnter

-- check pet of 5D ��XJ��2226��
_HM_Force.OnNpcLeave = function()
	if HM_Force.bAlertPet then
		local me = GetClientPlayer()
		if me then
			local pet = me.GetPet()
			if pet and pet.dwID == arg0 and (GetLogicFrameCount() - _HM_Force.nFrameXJ) >= 32 then
				OutputWarningMessage("MSG_WARNING_YELLOW", _L("Your pet [%s] disappeared!",  pet.szName))
				PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
			end
		end
	end
end

-- check to prepare self qc
_HM_Force.OnPrepareQC = function(dwID)
	local me, qc = GetClientPlayer(), _HM_Force.tQC[dwID]
	if HM_Force.bSelfTaiji2 or not HM.HasBuff(qc.dwBuffID, true) then
		local tarType, tarID = me.GetTarget()
		if tarID ~= 0 and tarID ~= me.dwID then -- and GetCharacterDistance(me.dwID, tarID) <= 1280 then
			HM.SetInsTarget(TARGET.NO_TARGET, 0)
			_HM_Force.ReTarget = { tarType, tarID, GetLogicFrameCount() }
		end
	end
end

-- restore target
_HM_Force.RestoreTarget = function()
	-- restore target
	if _HM_Force.ReTarget then
		local dwType, dwID = _HM_Force.ReTarget[1], _HM_Force.ReTarget[2]
		HM.SetTarget(dwType, dwID)
		_HM_Force.ReTarget = nil
	end
end

-- auto xyz
_HM_Force.UserSelect_SelectPoint = UserSelect.SelectPoint
UserSelect.SelectPoint = function(...)
	_HM_Force.UserSelect_SelectPoint(...)
	if HM_Force.bAutoXyz then
		local tar = GetTargetHandle(GetClientPlayer().GetTarget())
		if tar and (HM_Force.bAutoXyzSelf or tar.dwID ~= GetClientPlayer().dwID) then
			UserSelect.DoSelectPoint(tar.nX, tar.nY, tar.nZ)
		end
	end
end

-- breathe loop
_HM_Force.OnBreathe = function()
	local me = GetClientPlayer()
	if not me or not me.GetKungfuMount() or me.GetOTActionState() ~= 0 then
		return
	end
	-- 7x
	if me.GetKungfuMount().dwMountType == 4 then
		-- auto dance
		if HM_Force.bAutoDance and me.nAccumulateValue == 0
			and (me.nMoveState == MOVE_STATE.ON_STAND or me.nMoveState == MOVE_STATE.ON_FLOAT)
		then
			return HM_Force.OnUseEmptySkill(537)
		end
	end
end

-- bind QX button
_HM_Force.BindQXBtn = function()
	local btn = Player_GetFrame():Lookup("", "Handle_QiXiu"):Lookup("Image_QX_Btn")
	if btn then
		btn.OnItemLButtonDown = function()
			HM_Force.bAutoDance = not HM_Force.bAutoDance
			if HM_Force.bAutoDance then
				HM.Sysmsg(_L["Enable auto sword dance"])
			else
				local me = GetClientPlayer()
				local nCount = me.GetBuffCount()
				for i = 1, nCount do
					local dwID, _, bCanCancel, _, nIndex = me.GetBuff(i - 1)
					if dwID == 409 and bCanCancel then
						me.CancelBuff(nIndex)
						break
					end
				end
				HM.Sysmsg(_L["Disable auto sword dance"])
			end
			this.bClickDown = true
		end
	end
end

-- show jw or not
_HM_Force.ShowJWBuff = function()
	for i = 1, 99 do
		local buff = Table_GetBuff(409, i)
		if buff then
			if HM_Force.bShowJW then
				buff.bShow = 1
			else
				buff.bShow = 0
			end
		end
	end
end

-- warning buff type
_HM_Force.WarningDebuff = function(nType, nNum)
	local szText = _L("Your debuff of type [%s] reached [%d]", g_tStrings.tBuffDetachType[nType], nNum)
	OutputWarningMessage("MSG_WARNING_GREEN", szText)
	PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
end

-- buff update��
-- arg0��dwPlayerID��arg1��bDelete��arg2��nIndex��arg3��bCanCancel
-- arg4��dwBuffID��arg5��nStackNum��arg6��nEndFrame��arg7����update all?
-- arg8��nLevel��arg9��dwSkillSrcID
_HM_Force.OnBuffUpdate = function()
	if arg0 ~= GetClientPlayer().dwID or not HM_Force.bWarningDebuff or (not arg7 and arg3) then
		return
	end
	local t, t2 = {}, {}
	HM.WalkAllBuff(GetClientPlayer(), function(dwID, nLevel, bCanCancel)
		if not bCanCancel and not t2[dwID] then
			local info = GetBuffInfo(dwID, nLevel, {})
			if info and info.nDetachType > 2 then
				if not t[info.nDetachType] then
					t[info.nDetachType] = 1
				else
					t[info.nDetachType] = t[info.nDetachType] + 1
				end
				t2[dwID] = true
			end
		end
	end)
	for k, v in pairs(t) do
		if v >= HM_Force.nDebuffNum then
			_HM_Force.WarningDebuff(k, v)
		end
	end
end

-- record otaction
_HM_Force.SaveOTAction = function(nTotal, bDec)
	if HM_Force.bActionTime then
		_HM_Force.nActionTotal = nTotal
		_HM_Force.nActionEnd = GetLogicFrameCount() + nTotal
		_HM_Force.bActionDec = bDec
	end
end

-- update otaction bar
_HM_Force.UpdateOTActionBar = function()
	if not HM_Force.bActionTime or not _HM_Force.nActionTotal then
		return
	end
	local frame = Station.Lookup("Topmost/OTActionBar")
	if not frame or not frame.bShow then
		_HM_Force.nActionTotal = nil
		return
	end
	local nFrame = _HM_Force.nActionEnd - GetLogicFrameCount()
	local nTotal = _HM_Force.nActionTotal
	if nFrame < 0 then
		_HM_Force.nActionTotal = nil
		nFrame = 0
	end
	local handle = frame:Lookup("", "Handle_Common")
	local hText = handle:Lookup("Text_Name")
	if not handle:IsVisible() then
		hText = frame:Lookup("", "Handle_GaiBang"):Lookup("Text_GBName")
	end
	local szText = string.gsub(hText:GetText(), " %(.-%)$", "")
	if not _HM_Force.bActionDec then
		nFrame = nTotal - nFrame
	end
	hText:SetText(szText .. string.format(" (%.2g/%.2g)", nFrame / 16, nTotal / 16))
end

-- on wanted msg
_HM_Force.OnMsgAnnounce = function(szMsg)
    local _, _, sM, sN = string.find(szMsg, "������Ը��(%d+)�𣬶�(.-)��������")
	if sM and sN == GetClientPlayer().szName then
		local fW = function()
			OutputWarningMessage("MSG_WARNING_RED", "��ϲ�㱻���� [" .. sM .. "]����ˮ�Լ��Ȱ�����")
			PlaySound(SOUND.UI_SOUND, g_sound.CloseAuction)
        end
        SceneObject_SetTitleEffect(TARGET.PLAYER, GetClientPlayer().dwID, 47)
        fW()
        HM.DelayCall(2000, fW)
		HM.DelayCall(4000, fW)
		_HM_Force.bWanted = true
    end
end

-- try to replace horse via UUID
_HM_Force.tPlayHorse = {
	[3278] = true,	-- Сë¿
	[5781] = true,	-- ����
	[7722] = true,	-- �����ľ��
	[12160] = true,	-- ̫����¹
	[13605] = true,	-- ̫����¹
	[49667] = true,	-- ˫���ա�����
	[58147] = true,	-- ��ɽ�ر�����λ����
	[58148] = true,	-- ��ɽ�ر�����ս���
	[60358] = true,	-- ����
	[63440] = true,	-- �
}
_HM_Force.ReplaceHorse = function()
	-- is now a play horse
	local me = GetClientPlayer()
	local item = me.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
	-- find fastest horse to replace it
	if not item or _HM_Force.tPlayHorse[item.nUiId] then
		local dwBox, dwX, nSpeed
		for i = 1, BigBagPanel_nCount do
			local dwSize = me.GetBoxSize(i) or 0
			for j = 0, dwSize - 1 do
				local item = me.GetItem(i, j)
				if item and not _HM_Force.tPlayHorse[item.nUiId]
					and item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.HORSE
				then
					local _nSpeed = nil
					OutputItemTip(UI_OBJECT_ITEM, i, j)
					local hM = Station.Lookup("Topmost1/TipPanel_Normal", "Handle_Message")
					for x = 0, hM:GetItemCount() - 1, 1 do
						local hT = hM:Lookup(x)
						if hT:GetType() == "Text" then
							local szSpeed = string.match(hT:GetText(), "(%d+)%%$")
							if szSpeed then
								_nSpeed = tonumber(szSpeed)
								break
							end
						end
					end
					HideTip(false)
					if _nSpeed and not dwBox or _nSpeed > nSpeed then
						dwBox, dwX, nSpeed = i, j, _nSpeed
					end
				end
			end
		end
		if dwBox then
			me.ExchangeItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.HORSE)
		end
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Force.PS = {}

-- init panel
_HM_Force.PS.OnPanelActive = function(frame)
	local ui = HM.UI(frame)
	-- cy
	ui:Append("Text", { txt = _L["Gas field"], x = 0, y = 0, font = 27 })
	ui:Append("WndCheckBox", { txt = _L["Enable smart cast gas skill to myself"], checked = HM_Force.bSelfTaiji })
	:Pos(10, 28):Click(function(bChecked)
		HM_Force.bSelfTaiji = bChecked
		ui:Fetch("Check_Only"):Enable(bChecked)
		ui:Fetch("Combo_QC"):Enable(bChecked)
	end)
	local nX = ui:Append("WndCheckBox", "Check_Only", { txt = _L["Always cast gas skill to myself (for QC)"], checked = HM_Force.bSelfTaiji2 })
	:Pos(10, 56):Enable(HM_Force.bSelfTaiji):Click(function(bChecked)
		HM_Force.bSelfTaiji2 = bChecked
	end):Pos_()
	local nX = ui:Append("WndComboBox", "Combo_QC", { txt = _L["Select gas skill"], w = 150, h = 25 })
	:Pos(nX + 10, 56):Enable(HM_Force.bSelfTaiji):Menu(_HM_Force.GetQCMenu)
	-- other
	ui:Append("Text", { txt = _L["Others"], x = 0, y = 92, font = 27 })
	nX = ui:Append("Text", { txt = _L["Commands to jump back, small dodge: "], x = 12, y = 120 }):Pos_()
	ui:Append("Text", { txt = "/" .. _L["JumpBack"] .. "   /" .. _L["SmallDodge"], x = nX, y = 120, font = 57 })
	ui:Append("WndCheckBox", { txt = _L["Auto swith actionbar page of horse states (for TC, bind to P.1/3)"], checked = HM_Force.bHorsePage })
	:Pos(10, 148):Click(function(bChecked)
		HM_Force.bHorsePage = bChecked
	end)
	ui:Append("WndCheckBox", { txt = _L["Alert when pet disappear unexpectedly (for 5D)"], checked = HM_Force.bAlertPet })
	:Pos(10, 176):Click(function(bChecked)
		HM_Force.bAlertPet = bChecked
	end)
	ui:Append("WndCheckBox", { txt = _L["Auto enter dance status (Click fan on player panel to switch)"], checked = HM_Force.bAutoDance })
	:Pos(10, 204):Click(function(bChecked)
		HM_Force.bAutoDance = bChecked
	end)
	nX = ui:Append("WndCheckBox", { txt = _L["Cast area skill to current target directly"], checked = HM_Force.bAutoXyz })
	:Pos(10, 232):Click(function(bChecked)
		HM_Force.bAutoXyz = bChecked
		ui:Fetch("Check_XyzSelf"):Enable(bChecked)
	end):Pos_()
	ui:Append("WndCheckBox", "Check_XyzSelf", { txt = _L["Except own"], checked = not HM_Force.bAutoXyzSelf })
	:Pos(nX + 10, 232):Enable(HM_Force.bAutoXyz):Click(function(bChecked)
		HM_Force.bAutoXyzSelf = not bChecked
	end)
	-- replace horse
	ui:Append("WndCheckBox", { txt = _L["Replace horse in fighting"], checked = HM_Force.bHorseReplace })
	:Pos(nX + 10, 148):Click(function(bChecked)
		HM_Force.bHorseReplace = bChecked
	end)
	-- mark pet
	ui:Append("WndCheckBox", { txt = _L["Mark pet"], checked = HM_Force.bMarkPet })
	:Pos(nX + 10, 176):Click(function(bChecked)
		HM_Force.bMarkPet = bChecked
		_HM_Force.UpdatePetMark(bChecked)
	end)
	ui:Append("WndCheckBox", { txt = _L["Show dance buff and its stack num of 7X"], checked = HM_Force.bShowJW })
	:Pos(10, 260):Click(function(bChecked)
		HM_Force.bShowJW = bChecked
		_HM_Force.ShowJWBuff()
	end)
	-- debuff type num
	nX = ui:Append("WndCheckBox", { txt = _L["Alert when my same type of debuff reached a certain number "], checked = HM_Force.bWarningDebuff })
	:Pos(10, 288):Click(function(bChecked)
		HM_Force.bWarningDebuff = bChecked
		ui:Fetch("Combo_DebuffNum"):Enable(bChecked)
	end):Pos_()
	ui:Append("WndComboBox", "Combo_DebuffNum", { x = nX + 10, y = 288, w = 50, h = 25 })
	:Enable(HM_Force.bWarningDebuff):Text(tostring(HM_Force.nDebuffNum)):Menu(function()
		local m0 = {}
		for i = 1, 10 do
			table.insert(m0, { szOption = tostring(i), fnAction = function()
				HM_Force.nDebuffNum = i
				ui:Fetch("Combo_DebuffNum"):Text(tostring(i))
			end })
		end
		return m0
	end)
	-- otaction time
	ui:Append("WndCheckBox", { txt = _L["Show time description of OTActionBar"], checked = HM_Force.bActionTime })
	:Pos(10, 316):Click(function(bChecked)
		HM_Force.bActionTime = bChecked
		if not bChecked then
			_HM_Force.nActionTotal = nil
		end
	end)
	-- be wanted alert
	ui:Append("WndCheckBox", { txt = _L["Alert when I am wanted publishing online"], checked = HM_Force.bAlertWanted })
	:Pos(10, 344):Click(function(bChecked)
		HM_Force.bAlertWanted = bChecked
		if bChecked then
			RegisterMsgMonitor(_HM_Force.OnMsgAnnounce, {"MSG_GM_ANNOUNCE"})
		else
			UnRegisterMsgMonitor(_HM_Force.OnMsgAnnounce, {"MSG_GM_ANNOUNCE"})
		end
	end)
end

-- conflict check
_HM_Force.PS.OnConflictCheck = function()
	if Ktemp and HM_Force.bHorsePage then
		Ktemp.bchange = false
	end
	if OTAPlus and HM_Force.bActionTime then
		OTAPlus.bTime = false
	end
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- horse
HM.RegisterEvent("NPC_ENTER_SCENE", _HM_Force.OnNpcEnter)
HM.RegisterEvent("NPC_LEAVE_SCENE", _HM_Force.OnNpcLeave)
HM.RegisterEvent("NPC_DISPLAY_DATA_UPDATE", _HM_Force.OnNpcUpdate)
HM.RegisterEvent("SYNC_ROLE_DATA_END", function()
	_HM_Force.OnRideHorse()
	_HM_Force.BindQXBtn()
	_HM_Force.ShowJWBuff()
	if HM_Force.bAlertWanted then
		RegisterMsgMonitor(_HM_Force.OnMsgAnnounce, {"MSG_GM_ANNOUNCE"})
	end
end)
HM.RegisterEvent("PLAYER_STATE_UPDATE", function()
	if arg0 == GetClientPlayer().dwID then
		_HM_Force.OnRideHorse()
		if _HM_Force.bWanted then
			SceneObject_SetTitleEffect(TARGET.PLAYER, arg0, 47)
		end
	end
end)
HM.RegisterEvent("SYS_MSG", function()
	local me = GetClientPlayer()
	if arg0 == "UI_OME_SKILL_CAST_LOG" then
		if HM_Force.bSelfTaiji and arg1 == me.dwID and HM_Force.tSelfQC[arg2] then
			_HM_Force.OnPrepareQC(arg2)
		end
		-- on prepare �γ۳�
		if HM_Force.bHorseReplace and arg1 == me.dwID and arg2 == 433 and me.bFightState then
			_HM_Force.ReplaceHorse()
		end
	end
	-- ���˺�ɾ��ͷ��Ч��
	if arg0 == "UI_OME_DEATH_NOTIFY" then
		if _HM_Force.bWanted and arg1 == me.dwID then
			_HM_Force.bWanted = nil
			SceneObject_SetTitleEffect(TARGET.PLAYER, arg1, 0)
		end
	end
end)
HM.RegisterEvent("DO_SKILL_CAST", function()
	if arg0 == GetClientPlayer().dwID then
		-- �׼��������ٻ���2965��2221 ~ 2226
		if arg1 == 2965 or (arg1 >= 2221 and arg1 <= 2226) then
			_HM_Force.nFrameXJ = GetLogicFrameCount()
		end
		_HM_Force.RestoreTarget()
	end
end)
HM.RegisterEvent("OT_ACTION_PROGRESS_BREAK", function()
	if arg0 == GetClientPlayer().dwID then
		_HM_Force.nActionTotal = nil
		_HM_Force.RestoreTarget()
	end
end)
HM.RegisterEvent("OT_ACTION_PROGRESS_UPDATE", function()
	if _HM_Force.nActionTotal then
		_HM_Force.nActionTotal = _HM_Force.nActionTotal + arg0
		_HM_Force.nActionEnd = _HM_Force.nActionEnd + arg0
	end
end)
HM.RegisterEvent("DO_SKILL_PREPARE_PROGRESS", function()
	_HM_Force.SaveOTAction(arg0, false)
end)
HM.RegisterEvent("DO_SKILL_CHANNEL_PROGRESS", function()
	_HM_Force.SaveOTAction(arg0, true)
end)
HM.RegisterEvent("DO_SKILL_HOARD_PROGRESS", function()
	_HM_Force.SaveOTAction(arg0, false)
end)
HM.RegisterEvent("DO_PICK_PREPARE_PROGRESS", function()
	_HM_Force.SaveOTAction(arg0, false)
end)
HM.RegisterEvent("DO_CUSTOM_OTACTION_PROGRESS ", function()
	_HM_Force.SaveOTAction(arg0, arg2 ~= 0)
end)
HM.RegisterEvent("DO_RECIPE_PREPARE_PROGRESS", function()
	_HM_Force.SaveOTAction(arg0, false)
end)
HM.RegisterEvent("BUFF_UPDATE", _HM_Force.OnBuffUpdate)

-- breathe
HM.BreatheCall("HM_Force", _HM_Force.OnBreathe, 200)
HM.BreatheCall("HM_OTAction", _HM_Force.UpdateOTActionBar)

-- add to HM panel
HM.RegisterPanel(_L["School feature"], 327, nil, _HM_Force.PS)

-- macro command
AppendCommand(_L["JumpBack"], function() _HM_Force.OnUseEmptySkill(9007) end)
AppendCommand(_L["SmallDodge"], function()
	if HM.HasBuff(535) then	-- �벽��
		return
	end
	for _, v in ipairs({ 9004, 9005, 9006 }) do
		if _HM_Force.OnUseEmptySkill(v) then
			break
		end
	end
end)

-- init global caller
HM_Force.OnUseEmptySkill = _HM_Force.OnUseEmptySkill
