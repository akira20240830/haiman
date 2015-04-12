--
-- ���������Ŀ��������ʾ�������Σ�
--

HM_TargetFace = {
	bTargetFace = true,			-- �Ƿ񻭳�Ŀ������
	bFocusFace = false,			-- �Ƿ񻭳����������
	nSectorDegree = 110,		-- ���νǶ�
	nSectorRadius = 6,				-- ���ΰ뾶���ߣ�
	nSectorAlpha = 80,				-- ����͸����
	tTargetFaceColor = { 255, 0, 128 },		-- Ŀ��������ɫ
	tFocusFaceColor = { 0, 128, 255 },		-- ����������ɫ
	bTargetShape = false,		-- Ŀ��ŵ�ȦȦ
	bFocusShape = true,			-- ����ŵ�ȦȦ
	nShapeRadius = 2,				-- �ŵ�ȦȦ�뾶
	nShapeAlpha = 100,				-- �ŵ�ȦȦ͸����
	tTargetShapeColor = { 255, 0, 0 },
	tFocusShapeColor = { 0, 0, 255 },
}
HM.RegisterCustomData("HM_TargetFace")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_TargetFace = {
	szIniFile = "interface\\HM\\HM_TargetFace\\HM_TargetFace.ini",
	dwFocusID = 0,
	bLockFocus = false,
}

-- draw shape
_HM_TargetFace.DrawShape = function(tar, sha, nDegree, nRadius, nAlpha, col)
	nRadius = nRadius * 64
	local nFace = math.ceil(128 * nDegree / 360)
	local dwRad1 = math.pi * (tar.nFaceDirection - nFace) / 128
	if tar.nFaceDirection > (256 - nFace) then
		dwRad1 = dwRad1 - math.pi - math.pi
	end
	local dwRad2 = dwRad1 + (nDegree / 180 * math.pi)
	local nAlpha2 = 0
	if nDegree == 360 then
		nAlpha, nAlpha2 = nAlpha2, nAlpha
		dwRad2 = dwRad2 + math.pi / 16
	end
	-- orgina point
	sha:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	sha:SetD3DPT(D3DPT.TRIANGLEFAN)
	sha:ClearTriangleFanPoint()
	sha:AppendCharacterID(tar.dwID, false, col[1], col[2], col[3], nAlpha)
	sha:Show()
	-- relative points
	local sX, sZ = Scene_PlaneGameWorldPosToScene(tar.nX, tar.nY)
	repeat
		local sX_, sZ_ = Scene_PlaneGameWorldPosToScene(tar.nX + math.cos(dwRad1) * nRadius, tar.nY + math.sin(dwRad1) * nRadius)
		sha:AppendCharacterID(tar.dwID, false, col[1], col[2], col[3], nAlpha2, { sX_ - sX, 0, sZ_ - sZ })
		dwRad1 = dwRad1 + math.pi / 16
	until dwRad1 >= dwRad2
end

-------------------------------------
-- ���ں���
-------------------------------------
-- create
function HM_TargetFace.OnFrameCreate()
	-- shadows
	for _, v in ipairs({ "TargetFace", "TargetShape", "FocusFace", "FocusShape" }) do
		_HM_TargetFace["h" .. v]  = this:Lookup("", "Shadow_" .. v)
	end
	-- events
	this:RegisterEvent("TARGET_CHANGE")
	this:RegisterEvent("HM_ADD_FOCUS_TARGET")
	this:RegisterEvent("HM_DEL_FOCUS_TARGET")
end

-- breathe
function HM_TargetFace.OnFrameBreathe()
	local _t, t, tar = _HM_TargetFace, HM_TargetFace, nil
	-- target face
	tar = HM.GetTarget()
	if t.bTargetFace and tar then
		_t.DrawShape(tar, _t.hTargetFace, t.nSectorDegree, t.nSectorRadius, t.nSectorAlpha, t.tTargetFaceColor)
	else
		_t.hTargetFace:Hide()
	end
	-- foot shape
	if _t.bReRender then
		if t.bTargetShape and tar then
			_t.DrawShape(tar, _t.hTargetShape, 360, t.nShapeRadius / 2, t.nShapeAlpha, t.tTargetShapeColor)
		else
			_t.hTargetShape:Hide()
		end
	end
	-- focus face
	local bIsTarget = tar and _t.dwFocusID == tar.dwID
	tar = HM.GetTarget(_t.dwFocusID)
	if t.bFocusFace and tar and (not t.bTargetFace or not bIsTarget) then
		_t.DrawShape(tar, _t.hFocusFace, t.nSectorDegree, t.nSectorRadius, t.nSectorAlpha, t.tFocusFaceColor)
	else
		_t.hFocusFace:Hide()
	end
	-- focus shape
	if _t.bReRender then
		if t.bFocusShape and tar and (not t.bTargetShape or not bIsTarget) then
			_t.DrawShape(tar, _t.hFocusShape, 360, t.nShapeRadius / 2, t.nShapeAlpha, t.tFocusShapeColor)
		else
			_t.hFocusShape:Hide()
		end
	end
	_t.bReRender = false
end

-- event
function HM_TargetFace.OnEvent(event)
	if event == "TARGET_CHANGE" then
		_HM_TargetFace.bReRender = true
	elseif event == "HM_ADD_FOCUS_TARGET" and (arg1 or not _HM_TargetFace.bLockFocus) then
		_HM_TargetFace.dwFocusID = arg0
		_HM_TargetFace.bLockFocus = arg1
		_HM_TargetFace.bReRender = true
	elseif event == "HM_DEL_FOCUS_TARGET" and arg0 == _HM_TargetFace.dwFocusID then
		_HM_TargetFace.dwFocusID = 0
		_HM_TargetFace.bLockFocus = false
		_HM_TargetFace.bReRender = true
	end
end

-------------------------------------
-- ���ý���
-------------------------------------
_HM_TargetFace.PS = {}

-- init panel
_HM_TargetFace.PS.OnPanelActive = function(frame)
	local ui, t, _t = HM.UI(frame), HM_TargetFace, _HM_TargetFace
	ui:Append("Text", { txt = _L["Options"], font = 27 })
	-- face
	local nX = ui:Append("WndCheckBox", { txt = _L["Display the sector of target facing, change color"], checked = t.bTargetFace })
	:Pos(10, 28):Click(function(bChecked)
		t.bTargetFace = bChecked
		_HM_TargetFace.bReRender = true
	end):Pos_()
	ui:Append("Shadow", "Color_TargetFace", { x = nX + 2, y = 32, w = 18, h = 18 })
	:Color(unpack(t.tTargetFaceColor)):Click(function()
		OpenColorTablePanel(function(r, g, b)
			ui:Fetch("Color_TargetFace"):Color(r, g, b)
			t.tTargetFaceColor = { r, g, b }
			_HM_TargetFace.bReRender = true
		end)
	end)
	nX = ui:Append("WndCheckBox", { txt = _L["Display the sector of focus facing, change color"], checked = t.bFocusFace })
	:Pos(10, 56):Enable(HM_TargetList ~= nil):Click(function(bChecked)
		t.bFocusFace = bChecked
		_HM_TargetFace.bReRender = true
	end):Pos_()
	ui:Append("Shadow", "Color_FocusFace", { x = nX + 2, y = 60, w = 18, h = 18 })
	:Color(unpack(t.tFocusFaceColor)):Click(function()
		OpenColorTablePanel(function(r, g, b)
			ui:Fetch("Color_FocusFace"):Color(r, g, b)
			t.tFocusFaceColor = { r, g, b }
			_HM_TargetFace.bReRender = true
		end)
	end)
	nX = ui:Append("Text", { txt = _L["The sector angle"], x = 37, y = 84}):Pos_()
	ui:Append("WndTrackBar", { x = nX, y = 88, txt = _L[" degree"] })
	:Range(30, 180, 30):Value(t.nSectorDegree):Change(function(nVal)
		t.nSectorDegree = nVal
		_HM_TargetFace.bReRender = true
	end)
	nX = ui:Append("Text", { txt = _L["The sector radius"], x = 37, y = 112 }):Pos_()
	ui:Append("WndTrackBar", { x = nX, y = 116, txt = _L[" feet"] })
	:Range(1, 26, 26):Value(t.nSectorRadius):Change(function(nVal)
		t.nSectorRadius = nVal
		_HM_TargetFace.bReRender = true
	end)
	nX = ui:Append("Text", { txt = _L["The sector transparency"], x = 37, y = 140 }):Pos_()
	ui:Append("WndTrackBar", { x = nX, y = 144 })
	:Range(0, 100, 50):Value(math.ceil((200 - t.nSectorAlpha)/2)):Change(function(nVal)
		t.nSectorAlpha = (100 - nVal) * 2
		_HM_TargetFace.bReRender = true
	end)
	-- foot shape
	nX = ui:Append("WndCheckBox", { txt = _L["Display the foot shape of target, change color"], checked = t.bTargetShape })
	:Pos(10, 168):Click(function(bChecked)
		t.bTargetShape = bChecked
		_HM_TargetFace.bReRender = true
	end):Pos_()
	ui:Append("Shadow", "Color_TargetShape", { x = nX + 2, y = 172, w = 18, h = 18 })
	:Color(unpack(t.tTargetShapeColor)):Click(function()
		OpenColorTablePanel(function(r, g, b)
			ui:Fetch("Color_TargetShape"):Color(r, g, b)
			t.tTargetShapeColor = { r, g, b }
			_HM_TargetFace.bReRender = true
		end)
	end)
	nX = ui:Append("WndCheckBox", { txt = _L["Display the foot shape of focus, change color"], checked = t.bFocusShape })
	:Pos(10, 196):Enable(HM_TargetList ~= nil):Click(function(bChecked)
		t.bFocusShape = bChecked
		_HM_TargetFace.bReRender = true
	end):Pos_()
	ui:Append("Shadow", "Color_FocusShape", { x = nX + 2, y = 200, w = 18, h = 18 })
	:Color(unpack(t.tFocusShapeColor)):Click(function()
		OpenColorTablePanel(function(r, g, b)
			ui:Fetch("Color_FocusShape"):Color(r, g, b)
			t.tFocusShapeColor = { r, g, b }
			_HM_TargetFace.bReRender = true
		end)
	end)
	nX = ui:Append("Text", { txt = _L["The foot shape radius"], x = 37, y = 228 }):Pos_()
	ui:Append("WndTrackBar", { x = nX, y = 232, txt = "/2" .. _L[" feet"] })
	:Range(1, 26, 26):Value(t.nShapeRadius):Change(function(nVal)
		t.nShapeRadius = nVal
		_HM_TargetFace.bReRender = true
	end)
	nX = ui:Append("Text", { txt = _L["The foot shape transparency"], x = 37, y = 256 }):Pos_()
	ui:Append("WndTrackBar", { x = nX, y = 260 })
	:Range(0, 100, 50):Value(math.ceil((200 - t.nShapeAlpha)/2)):Change(function(nVal)
		t.nShapeAlpha = (100 - nVal) * 2
		_HM_TargetFace.bReRender = true
	end)
	-- tips
	ui:Append("Text", { x = 0, y = 284, txt = _L["Tips"], font = 27 })
	ui:Append("Text", { x = 10, y = 312, txt = _L["Only show the facing and foot shape of the last added focus target"] })
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- add to HM panel
HM.RegisterPanel(_L["Target face"], 2136, _L["Target"], _HM_TargetFace.PS)

-- open hidden window
local frame = Station.Lookup("Lowest/HM_TargetFace")
if frame then Wnd.CloseWindow(frame) end
Wnd.OpenWindow(_HM_TargetFace.szIniFile, "HM_TargetFace")
