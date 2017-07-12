--
-- �������������/Secret������������ѵ����ܣ������ռ䡭����
--
HM_Secret = {
	bShowButton = true,
	bAutoSync = false,
}
HM.RegisterCustomData("HM_Secret")

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local _HM_Secret = {
	szName = _L["Haiman Site"],
	szIniFile = "interface\\HM\\HM_Secret\\HM_Secret.ini",
}

-------------------------------------
-- �¼�����
-------------------------------------
local ROOT_URL = HM.szRemoteHost
local CLIENT_LANG = HM.szClientLang

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Secret.PS = {}

-- init
_HM_Secret.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	-- Tips
	ui:Append("Text", { x = 0, y = 0, txt = "���ڹ���", font = 27 })
	ui:Append("Text", { x = 0, y = 28, txt = "������������ɺ����������Ŷӿ�����ά�����뽣��3��Ϸ�ٷ��޹ء�����Ϸ֮���ṩ��ظ������ܣ��������ݲ�ѯ���ɾͰٿơ��ƾٴ��⡢������ء��ճ����ѡ���Ե֤�顢��ҽ����ȡ�", multi = true, w = 520, h = 70 })
	ui:Append("WndEdit", { x = 0, y = 100 , w = 240, h = 28, txt = ROOT_URL, color = { 255, 255, 200 } })
	local bY = 142
	ui:Append("Text", { x = 0, y = bY, txt = "�������", font = 27 })
	nX = ui:Append("Text", { x = 0, y = bY + 28, txt = "Ͷ��������������¡��������ۣ����ע΢�Ź��ںš�" }):Pos_()
	nX = ui:Append("Text", { x = nX, y = bY + 28, txt = "�������", font = 51 }):Pos_()
	ui:Append("Text", { x = nX, y = bY + 28, txt = "��" })
	-- verify
	bY = 212
	ui:Append("Text", { x = 0, y = bY, txt = "������֤", font = 27 })
	ui:Append("Text", "Text_Verify", { x = 0, y = bY + 28, txt = "loading...", font = 47 }):Color(6, 204, 178)
	nX = ui:Append("Text", { x= 0, y = bY + 56, txt = "��֤ѡ�" }):Pos_()
	nX = ui:Append("WndCheckBox", "Check_Basic", { x = nX, y = bY + 56, txt = "��������", checked = true, enable = false }):Pos_()
	nX = ui:Append("WndCheckBox", "Check_Name", { x = nX + 10, y = bY + 56, txt = "��ɫ��", checked = true }):Pos_()
	nX = ui:Append("WndCheckBox", "Check_Equip", { x = nX + 10, y = bY + 56, txt = "����&����", checked = true }):Pos_()
	nX = ui:Append("WndButton", "Btn_Delete", { x = 0, y =  bY + 90, txt = "�����֤", enable = false }):Click(function()
		HM.Confirm("ȷ��Ҫ�����֤��", function()
			local data = {
				gid = GetClientPlayer().GetGlobalID(),
				isOpenVerify = false
			}
			HM.PostJson(ROOT_URL .. "/api/jx3/game-roles", HM.JsonEncode(data)):done(function(res)
				HM_Secret.bAutoSync = false
				HM.OpenPanel(_HM_Secret.szName)
			end)
		end)
	end):Pos_()
	nX = ui:Append("WndButton", "Btn_Submit", { x = nX + 10, y =  bY + 90, txt = "������֤" }):Click(function()
		local btn = ui:Fetch("Btn_Submit")
		local data = HM_About.GetSyncData()
		data.isOpenName = ui:Fetch("Check_Name"):Check() and 1 or 0
		data.isOpenEquip = ui:Fetch("Check_Equip"):Check() and 1 or 0
		data.__qrcode = 1
		btn:Enable(false)
		if GetClientPlayer().nLevel < 95 then
			return HM.Alert(g_tStrings.tCraftResultString[CRAFT_RESULT_CODE.TOO_LOW_LEVEL])
		end
		HM.PostJson(ROOT_URL .. "/api/jx3/game-roles", HM.JsonEncode(data)):done(function(res)
			HM_Secret.bAutoSync = true
			if not res or res.errcode ~= 0 then
				ui:Fetch("Text_Verify"):Text(res and res.errmsg or "Unknown"):Color(255, 0, 0)
			elseif res.data and res.data.qrcode then
				HM.ViewQrcode(res.data.qrcode, "΢��ɨ�������֤")				
				--ui:Fetch("Image_Wechat"):Toggle(false)
				ui:Fetch("Text_Verify"):Text("ɨ����������˵�ˢ��")
			end
			btn:Text("������֤")
			btn:Enable(true)
		end)
	end):Pos_()
	-- /api/jx3/roles/{gid}
	_HM_Secret.PS.active = true
	HM.GetJson(ROOT_URL .. "/api/jx3/game-roles/" .. GetClientPlayer().GetGlobalID()):done(function(res)
		if not _HM_Secret.PS.active then
			return
		end
		if res.data and res.data.verify then
			local data = res.data
			local szText = data.verify .. " (" .. FormatTime("%Y/%m/%d %H:%M", data.time_update) .. ")"
			ui:Fetch("Text_Verify"):Text(szText)
			ui:Fetch("Check_Name"):Check(data.open_name == true)
			ui:Fetch("Check_Equip"):Check(data.open_equip == true)
			ui:Fetch("Btn_Delete"):Enable(true)
			ui:Fetch("Btn_Submit"):Text("������֤")
			HM_Secret.bAutoSync = true
		else
			ui:Fetch("Text_Verify"):Text("<δ��֤>"):Color(255, 0, 0)
		end
	end):fail(function()
		if not _HM_Secret.PS.active then
			return
		end
		ui:Fetch("Text_Verify"):Text(_L["Request failed"]):Color(255, 0, 0)
	end)
end

_HM_Secret.PS.OnPanelDeactive = function()
	_HM_Secret.PS.active = nil
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------
-- sync events
HM.RegisterEvent("FIRST_LOADING_END", function()
	if HM_Secret.bAutoSync then
		local data = HM_About.GetSyncData()
		HM.PostJson(ROOT_URL .. "/api/jx3/game-roles", HM.JsonEncode(data))
	end
end)

-- add to HM collector
HM.RegisterPanel(_HM_Secret.szName, 244, _L["Recreation"], _HM_Secret.PS)
