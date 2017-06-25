--
-- �����������ɫ����
-- ���ݵ�ǰ���е���ۡ�ͷ�����ɾ�װ���� ��ɫ���ݽ��й���
--
-- �Ż��ƺź͹Ҽ����ݣ���Ҫȫ���ϴ���
--
HM_Price = {}

---------------------------------------------------------------------
-- ���غ����ͱ���
---------------------------------------------------------------------
local ROOT_URL = HM.szRemoteHost
local _HM_Price = {
	szName = "��ɫ����",
	nBagCount = 6,
	nBankCount = 6,
}

-- ɨ��װ�����������ֿ����
_HM_Price.WalkInventory = function(dwBox, fnAction)
	local me = GetClientPlayer()
	local dwSize = me.GetBoxSize(dwBox)
	for dwX = 0, dwSize - 1, 1 do
		local item = GetPlayerItem(me, dwBox, dwX)
		if item and item.bBind then
			pcall(fnAction, item)
		end
	end
end

_HM_Price.WalkAllItems = function(fnAction, bEquip, bBag, bBank)
	local me = GetClientPlayer()
	if bEquip ~= false then
		_HM_Price.WalkInventory(INVENTORY_INDEX.EQUIP, fnAction)
	end
	if bBag ~= false then
		for i = 1, _HM_Price.nBagCount, 1 do
			local dwBox = INVENTORY_INDEX.PACKAGE + i - 1
			_HM_Price.WalkInventory(dwBox, fnAction)
		end
	end
	if bBank ~= false then
		for i = 1, _HM_Price.nBankCount, 1 do
			local dwBox = INVENTORY_INDEX.BANK + i - 1
			_HM_Price.WalkInventory(dwBox, fnAction)
		end
	end
end

_HM_Price.ConvertToForce = function(dwSchool)
	local szName = Table_GetSkillSchoolName(dwSchool)
	for k, v  in pairs(g_tStrings.tForceTitle) do
		if v == szName then
			return k
		end
	end
end

-- ������Ϣ��gid, name, server, shcool, camp, body, pet, score, point, camp ...
_HM_Price.GetBasicInfo = function()
	local me = GetClientPlayer()
	-- ����
	local t = {
		gid = me.GetGlobalID(),
		reward = me.GetRewards(),
		coin = me.nCoin,
		gold = me.GetMoney().nGold,
	}
	-- װ����ȫ��¼
	t.scores = _HM_Price.scores
	-- ����
	t.slaves = {}
	local _exists = {}
	_exists[me.dwForceID] = true
	for k, v in pairs(me.GetAllMountKungfu() or {}) do
		local skill = GetSkill(k, v)
		local nForce = _HM_Price.ConvertToForce(skill.dwBelongSchool)
		if not _exists[nForce] then
			_exists[nForce] = true
			table.insert(t.slaves, nForce)
		end
	end
	return t
end

-- ��ȡ���䡢����
_HM_Price.LoadBestItems = function(t)
	local nMaxLevel = GetClientPlayer().nMaxLevel
	t.oranges = {}
	_HM_Price.WalkAllItems(function(item)
		if item.nGenre == ITEM_GENRE.EQUIPMENT 
			and (item.nSub == EQUIPMENT_SUB.MELEE_WEAPON or item.nSub == EQUIPMENT_SUB.RANGE_WEAPON)
			and item.nQuality == 5
		then
			-- weapon
			table.insert(t.oranges, item.nUiId)
		elseif item.nQuality == 5 and item.nGenre == ITEM_GENRE.MATERIAL and item.dwTabType == ITEM_TABLE_TYPE.OTHER then
			-- material **����
			local info = GetItemInfo(ITEM_TABLE_TYPE.OTHER, 6630)
			local szPattern = string.sub(info.szName, math.ceil(string.len(info.szName) / 2) + 1) .. "$"
			if string.find(item.szName, szPattern) then
				table.insert(t.oranges, item.nUiId)
			end
		end
	end)
end

-- ��ȡ������
_HM_Price.LoadHorses = function(t)
	t.horses = {}
	local fnAction = function(item)
		if item.nGenre == ITEM_GENRE.EQUIPMENT and item.nSub == EQUIPMENT_SUB.HORSE then
			table.insert(t.horses, item.nUiId)
		end
	end
	_HM_Price.WalkInventory(INVENTORY_INDEX.HORSE, fnAction)
	_HM_Price.WalkInventory(INVENTORY_INDEX.RARE_HORSE1, fnAction)
	_HM_Price.WalkInventory(INVENTORY_INDEX.RARE_HORSE2, fnAction)
	_HM_Price.WalkAllItems(fnAction, false, true, false)
	-- ���, >= 5%
	t.horse_equips = {}
	for _, v in ipairs(GetClientPlayer().GetAllHorseEquip() or {}) do
		local info = GetItemInfo(ITEM_TABLE_TYPE.CUST_TRINKET, v.dwItemIndex)
		local attr = GetItemMagicAttrib(info.GetMagicAttribIndexList())
		if attr[1] and attr[1].nID == 2 and attr[1].Param0 >= 50 then
			table.insert(t.horse_equips, info.nUiId)
		end
	end
end

-- ��ȡ���硢�Ҽ���������ͷ������ӡ
_HM_Price.LoadExteriors = function(t)
	local me = GetClientPlayer()
	t.weapon_collect_num = table.getn(me.GetAllWeaponExterior())	-- ��������
	t.face_collect_num = table.getn(me.GetAllHair(HAIR_STYLE.FACE)) -- ������������̫��ȷ��
	t.hairs = me.GetAllHair(HAIR_STYLE.HAIR) -- ����
	-- ʱװ����ӡ
	t.exteriors = {}
	for _, v in ipairs(me.GetAllExterior() or {}) do
		if v.nTimeType == 0 and v.nEndTime == 0 then
			table.insert(t.exteriors, v.dwExteriorID)
		end
	end
	-- ����
	t.cloaks = {}
	for _, v in ipairs(me.GetAllBackCloakPendent() or {}) do
		table.insert(t.cloaks, v.dwItemIndex)
	end
	-- �Ҽ�
	t.back_pendants = {}
	t.waist_pendants = {}
	for _, v in ipairs(me.GetAllBackPendent() or {}) do
		table.insert(t.back_pendants, v.dwItemIndex)
	end
	for _, v in ipairs(me.GetAllWaistPendent() or {}) do
		table.insert(t.waist_pendants, v.dwItemIndex)
	end
	t.back_pendant_num = table.getn(t.back_pendants)
	t.waist_pendant_num = table.getn(t.waist_pendants)
	t.face_pendant_num = table.getn(me.GetAllFacePendent() or {})
	t.lshoulder_pendant_num = table.getn(me.GetAllLShoulderPendent() or {})
	t.rshoulder_pendant_num = table.getn(me.GetAllRShoulderPendent() or {})	
end

-- ��ȡ�ƺš�������
_HM_Price.LoadAdventures = function(t)
	local me = GetClientPlayer()
	-- ǰ׺��300=������, 120=��������, 266=�쳾,  158=�Ͻ���, new: id > 360
	-- ��׺��251=����,  194=׷����, new: id > 268
	t.designations = {}
	for _, v in ipairs(me.GetAcquiredDesignationPrefix() or {}) do
		if v == 300 or v == 120 or v == 266 or v == 158 or v > 360 then
			table.insert(t.designations, v)
		end
	end
	for _, v in ipairs(me.GetAcquiredDesignationPostfix() or {}) do
		if v == 251 or v == 194 or v > 268 then
			table.insert(t.designations, v + 10000)
		end
	end
	-- ����
	t.adventures = {}
	local tab = g_tTable.Adventure
	for i = 2, tab:GetRowCount(), 1 do
		local row = tab:GetRow(i)
		if row.dwFinishID ~= 0 then
			if me.GetAdventureFlag(row.dwFinishID) then
				table.insert(t.adventures, row.dwID)
			end
		elseif row.nFinishQuestID ~= 0 then
			if me.GetQuestPhase(row.nFinishQuestID) == 3 then
				table.insert(t.adventures, row.dwID)
			end
		end
	end	
end

-- ��ȡ��������ȫ����Ϣ
_HM_Price.GetAllInfo = function()
	local t = _HM_Price.GetBasicInfo()
	_HM_Price.LoadBestItems(t)
	_HM_Price.LoadHorses(t)
	_HM_Price.LoadExteriors(t)
	_HM_Price.LoadAdventures(t)
	return t
end

-- ��ȡȫ��װ����
_HM_Price.GetCurrentScore = function()
	-- �ķ�װ�����ͣ�����ħ������ID
	-- AttributeStringToID("atDecriticalDamagePowerBase") = 100
	-- AttributeStringToID("atDecriticalDamagePowerPercent") = 101
	-- AttributeStringToID("atToughnessBase") = 97
	-- AttributeStringToID("atToughnessPercent") = 98
	local me = GetClientPlayer()
	local item = me.GetItem(INVENTORY_INDEX.EQUIP, EQUIPMENT_INVENTORY.MELEE_WEAPON)
	if not item then
		return
	end
	-- pvp or pve
	local pvx = "PVE"
	local attrib = item.GetMagicAttrib()
	for _, v in pairs(attrib) do
		if v.nID == 100 or v.nID == 97 or v.nID == 101 or v.nID == 98 then
			pvx = "PVP"
			break
		end
	end
	-- fir for kungfu
	local info = GetItemInfo(item.dwTabType, item.dwIndex)
	local school = GetForceTitle(me.dwForceID)
	if info.nRecommendID and g_tTable.EquipRecommend then
		local t = g_tTable.EquipRecommend:Search(info.nRecommendID)
		if StringFindW(t.szDesc, school) == 1 then
			local skill = GetSkill(tonumber(t.kungfu_ids), 1)
			if skill then
				local score = me.GetTotalEquipScore()
				local name = skill.szSkillName
				local s = _HM_Price.scores
				if not s[name] then
					s[name] = {}
				end
				if not s[name][pvx] or s[name][pvx] < score then
					s[name][pvx] = score
				end
			end
		end
	end
end

_HM_Price.GetScoreAndNext = function()
	local nCur = GetClientPlayer().GetEquipIDArray(0)
	local nNext = (nCur + 1) % 4
	_HM_Price.GetCurrentScore()
	_HM_Price.nCurSuit = nNext
	if nNext == _HM_Price.nOrgSuit then
		HM.UnRegisterEvent("EQUIP_CHANGE.p")
		if _HM_Price.ui then
			_HM_Price.ui:Fetch("Btn_Submit"):Enable(true)
		end
	end
	PlayerChangeSuit(nNext + 1)
end

_HM_Price.GetAllScores = function()
	_HM_Price.scores = {}
	_HM_Price.nCurSuit = GetClientPlayer().GetEquipIDArray(0)
	_HM_Price.nOrgSuit = _HM_Price.nCurSuit
	HM.RegisterEvent("EQUIP_CHANGE.p", _HM_Price.GetScoreAndNext)
	_HM_Price.GetScoreAndNext()
end
-------------------------------------
-- �¼�����
-------------------------------------

-------------------------------------
-- ���ý���
-------------------------------------
_HM_Price.PS = {}

-- deinit
_HM_Price.PS.OnPanelDeactive = function(frame)
	HM.UnRegisterEvent("EQUIP_ITEM_UPDATE.p")
	_HM_Price.ui = nil
end

-- init
_HM_Price.PS.OnPanelActive = function(frame)
	local ui, nX = HM.UI(frame), 0
	ui:Append("Text", { x = 0, y = 0, txt = "����ԭ��", font = 27 })
	ui:Append("Text", { x = 0, y = 28, txt = "��������ǰװ�����ɾ͡��̳���۷��͵Ƚ�ɫ���ݣ�����г��ϵĲο��۸��ۺ϶�̬���⡣", multi = true, w = 520, h = 50 })
	local bY = 90
	ui:Append("Text", { x = 0, y = bY, txt = GetUserRoleName() .. "��" .. select(6, GetUserServer()) .. "���ļ�ֵ��ԼΪ��", font = 27 })
	nX = ui:Append("Text", "Text_Price", { x = 3, y = bY + 45, txt = "???", font = 24 }):Pos_()
	ui:Append("Text", "Text_Unit", { x = nX + 5, y = bY + 45, txt = "Ԫ" })
	nX = ui:Append("WndButton", "Btn_Submit", { x = 0, y =  bY + 90, txt = "��ȡ����", enable = false }):Click(function()
		-- check level
		local me = GetClientPlayer()
		if me.nLevel ~= me.nMaxLevel then
			ui:Fetch("Text_Unit"):Toggle(false)
			return ui:Fetch("Text_Price"):Text("��������")
		end
		-- update role
		local data = HM_About.GetSyncData()
		data.__qrcode = "0"
		HM.PostJson(ROOT_URL .. "/api/jx3/roles", data):done(function(res)
			if not res or  res.errcode ~= 0 then
				ui:Fetch("Text_Price"):Text(res and res.errmsg or "Unknown")
			else
				local data = _HM_Price.GetAllInfo()
				HM.PostJson(ROOT_URL .. "/api/jx3/price-records", HM.JsonEncode(data)):done(function(res)
					local _nX = ui:Fetch("Text_Price"):Text(res.nPrice or res.errmsg):Pos_()
					ui:Fetch("Text_Unit"):Pos(_nX + 5, bY + 45)
					if res.errcode == 0 then
						ui:Fetch("Btn_Scan"):Enable(true)
					else
						HM.Debug(res.data or res.errmsg)
					end
				end)
			end
		end)
	end):Pos_()
	ui:Append("WndButton", "Btn_Scan", { x = nX + 10, y =  bY + 90, txt = "����ͼƬ", enable = false }):Click(function()
		HM.GetJson(ROOT_URL .. "/api/jx3/price-images/" .. GetClientPlayer().GetGlobalID()):done(function(res)
			if res.errcode == 0 and res.qrcode then
				HM.ViewQrcode(res.qrcode, "��ȡ��ɫ����ͼƬ")
			else
				HM.Alert(res.errmsg)
			end
		end)
	end)
	ui:Append("Text", { x = 3, y = bY + 130, font = 218, txt = "ע1�����۲�����δ����Ʒ��ͨ�������ֵ�" })
	ui:Append("Text", { x = 3, y = bY + 155, font = 218, txt = "ע2���г��۸񲨶��Ͽ죬�����ֵ������ʱ�ο�" })
	ui:Append("Text", { x = 3, y = bY + 180, font = 218, txt = "ע3���ܶԹ������ṩ���ۻ�Ľ�����ģ����QȺ��???" })
	-- load equip scores
	_HM_Price.ui = ui
	_HM_Price.GetAllScores()
end

---------------------------------------------------------------------
-- ע���¼�����ʼ��
---------------------------------------------------------------------

-- add to HM collector
HM.RegisterPanel(_HM_Price.szName, 2490, _L["Recreation"], _HM_Price.PS)
