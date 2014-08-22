--
-- ����������ؼ����ң�֧���ı��Ͱ�Ŧ��
--

HM_FindStation = {}

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
_HM_FindStation = {
	bButton = false,
	szQuery = "",
	szResult = "",
	tLayer = { "Lowest", "Lowest1", "Lowest2", "Normal", "Normal1", "Normal2", "Topmost", "Topmost1", "Topmost2" },
}

_HM_FindStation.UpdateButton = function()
	_HM_FindStation.bButton = not _HM_FindStation.bButton
	local function fnApply(wnd)
		if wnd and wnd:IsVisible() then
			-- update mouse tips
			if wnd:GetType() == "WndButton" or wnd:GetType() == "WndCheckBox" then
				if _HM_FindStation.bButton then
					wnd._OnMouseEnter = wnd.OnMouseEnter
					wnd.OnMouseEnter = function()
						local nX, nY = wnd:GetAbsPos()
						local nW, nH = wnd:GetSize()
						local szTip = GetFormatText("<HM���ؼ�·��>\n", 101)
						szTip = szTip .. GetFormatText(string.sub(wnd:GetTreePath(), 1, -2), 106)
						OutputTip(szTip, 400, { nX, nY, nW, nH })
					end
				else
					wnd.OnMouseEnter = wnd._OnMouseEnter
					wnd._OnMouseEnter = nil
				end
			end
			-- update childs
			local cld = wnd:GetFirstChild()
			while cld ~= nil do
				fnApply(cld)
				cld = cld:GetNext()
			end
		end
	end
	for _, v in ipairs(_HM_FindStation.tLayer) do
		fnApply(Station.Lookup(v))
	end
end

_HM_FindStation.UpdateBox = function()
	_HM_FindStation.bBox = not _HM_FindStation.bBox
	local function fnApply(wnd)
		if wnd and wnd:IsVisible() then
			-- update mouse tips
			if wnd:GetType() == "Box" then
				if _HM_FindStation.bBox then
					wnd._OnItemMouseEnter = wnd.OnItemMouseEnter
					wnd.OnItemMouseEnter = function()
						local nX, nY = wnd:GetAbsPos()
						local nW, nH = wnd:GetSize()
						local szTip = GetFormatText("<HM���ؼ�·��>\n", 101)
						szTip = szTip .. GetFormatText(string.sub(wnd:GetTreePath(), 1, -2), 106)
						OutputTip(szTip, 400, { nX, nY, nW, nH })
					end
				else
					wnd.OnItemMouseEnter = wnd._OnItemMouseEnter
					wnd._OnItemMouseEnter = nil
				end
			elseif wnd:GetType() == "Handle" then
				-- handle traverse
				for i = 0, wnd:GetItemCount() - 1, 1 do
					fnApply(wnd:Lookup(i))
				end
			elseif wnd:GetType() == "WndFrame" or wnd:GetType() == "WndWindow" then
				-- main handle
				fnApply(wnd:Lookup("", ""))
				-- update childs
				local cld = wnd:GetFirstChild()
				while cld ~= nil do
					fnApply(cld)
					cld = cld:GetNext()
				end
			end
		end
	end
	for _, v in ipairs(_HM_FindStation.tLayer) do
		fnApply(Station.Lookup(v))
	end
end

_HM_FindStation.SearchText = function(szText)
	local tResult = {}
	local function fnSearch(wnd)
		if not wnd or not wnd:IsVisible() then
			return
		end
		local hnd = wnd
		if wnd:GetType() ~= "Handle" and wnd:GetType() ~= "TreeLeaf" then
			hnd = wnd:Lookup("", "")
		end
		if hnd then
			for i = 0, hnd:GetItemCount() - 1, 1 do
				local hT = hnd:Lookup(i)
				if hT:GetType() == "Handle" or hT:GetType() == "TreeLeaf" then
					fnSearch(hT)
				elseif hT:GetType() == "Text" and hT:IsVisible() and string.find(hT:GetText(), szText) then
					local p1, p2 = hT:GetTreePath()
					table.insert(tResult, { p1 = string.sub(p1, 1, -2), p2 = p2, txt = hT:GetText() })
				end
			end
		end
		if hnd ~= wnd then
			local cld = wnd:GetFirstChild()
			while cld ~= nil do
				fnSearch(cld)
				cld = cld:GetNext()
			end
		end
	end
	-- lookup
	if szText ~= "" then
		for _, v in ipairs(_HM_FindStation.tLayer) do
			fnSearch(Station.Lookup(v))
		end
	end
	-- concat result
	local szResult = ""
	for _, v in ipairs(tResult) do
		szResult = szResult .. v.p1 .. ", " .. v.p2 .. ": " .. v.txt .. "\n"
	end
	if szResult == "" then
		szResult = "NO-RESULT"
	end
	return szResult
end

---------------------------------------------------------------------
-- ���ý���
---------------------------------------------------------------------
-- init panel
_HM_FindStation.OnPanelActive = function(frame)
	local ui = HM.UI(frame)
	ui:Append("Text", { txt = "�ؼ�����", x = 0, y = 0, font = 27 })
	ui:Append("WndCheckBox", { x = 10, y = 28, checked = _HM_FindStation.bButton })
	:Text("���ð�ť���ң�������ϻ���ʾ�ؼ�·��"):Click(_HM_FindStation.UpdateButton)
	ui:Append("WndCheckBox", { x = 10, y = 56, checked = _HM_FindStation.bBox })
	:Text("����BOX���ң�������ϻ���ʾ�ؼ�·��"):Click(_HM_FindStation.UpdateBox)
	ui:Append("Text", { txt = "�ı�����", x = 0, y = 92, font = 27 })
	local nX = ui:Append("Text", { txt = "�ؼ��ʣ�", x = 10, y = 120 }):Pos_()
	nX = ui:Append("WndEdit", "Edit_Query", { x = nX + 5, y = 120, limit = 256, h = 27, w = 200 })
	:Text(_HM_FindStation.szQuery):Pos_()
	nX = ui:Append("WndButton", { x = nX + 5, y = 120, txt = "�� ��" })
	:Click(function()
		ui:Fetch("Edit_Result"):Text("���ڼ��������Ժ򡭡�")
		_HM_FindStation.szQuery = ui:Fetch("Edit_Query"):Text()
		_HM_FindStation.szResult = _HM_FindStation.SearchText(_HM_FindStation.szQuery)
		ui:Fetch("Edit_Result"):Text(_HM_FindStation.szResult)
	end):Pos_()
	ui:Append("Text", { x = nX + 5, y = 120, txt = "��֧�� Lua ����" })
	ui:Append("WndEdit", "Edit_Result", { x = 10, y = 150, limit = 9999, h = 200, w = 480, multi = true })
	:Text(_HM_FindStation.szResult)
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- add to HM panel
HM.RegisterPanel("����ؼ�����", 2791, "����", _HM_FindStation)

