������������������� API
==========================

ǰ��
----

����������е� `HM.lua` �����˴������õĺ������װ���Լ���̬����������������
�� UI Ԫ���ķ�����Ϊ�����Լ����飬�Լ�����˽���Щ API �����д�����˵����

��Ҫʹ����Щ�����⣬������ JX3 �ͻ�����װ�к���������°汾�����ʵ�ڲ��밲װ
��������������Ը��Ʋ��Ŀ¼�е� `HM.lua` ���ڵ���������ɡ�


���� API
---------

1.  `HM.szTitle` - ��̬���ԣ����������


2.  `HM.szBuildDate` - ��̬���ԣ�������´�����ڣ���ʽ��YYYYMMDD


3.  `HM.bDebug` - ��̬���ԣ����ڱ�ʾ�Ƿ��� DEBUG ��Ϣ����Ϊ *true* ����ͷ��˵����� DEBUG ��Ϣ����
    ����Խ�ߣ����3�������������ϢԽ�࣬�μ���`HM.Debug() HM.Debug2() HM.Debug3()`


4.  `(string, number) HM.GetVersion()` - ȡ���ַ����汾�ź����Ͱ汾��


5.  `(bool) HM.IsPanelOpened()` - �ж���������Ƿ��Ѵ򿪣��Ѵ򿪷��� *true*


6.  `(void) HM.OpenPanel([string szTitle])` - ������Ϊ *szTitle* �Ĳ����������ý��棬
    ��ʡ�Բ������������塣���磺
    ```lua
    HM.OpenPanel("����")  -- �򿪡�����������
    HM.OpenPanel("�Ŷӱ��/����") -- �򿪡��Ŷӱ��/���𡱹������ý���
    ```

7. `(void) HM.ClosePanel([bool real = false])` - ����������壬���� *real* ��Ϊ *true* �򳹵��������


8.  `(void) HM.TogglePanel()` - ��ʾ/�����������


9.  `(void) HM.RegisterTempTarget(number dwID)` - �Ǽ���Ҫ��ʱ��ΪĿ�����ң�
    �ڷ�ս��״̬����ʱ�л�Ŀ��Ȼ���ٻ�ԭ֮ǰ��Ŀ�꣬���Ի�ȡĿ����ҵ��ڹ���

    > ���� *dwID* -- ��Ҫ��ע����� ID�����֣�


10. `(void) HM.AppendPlayerMenu(table|func menu)` - �Ǽ���Ҫ��ӵ�ͷ��˵�����Ŀ��
    �÷�����ӵ�Ϊ�����˵�������Ŀ��Ҫ��Ӷ�����Ŀ���ùٷ��� `Player_AppendAddonMenu()`��

    > ���� *menu* -- ����Ϊ`table`��ʾҪ����ĵ����˵������Ϊ`function`��Ҫ�󷵻�ֵ��һ���˵��

    ```lua
    HM.AppendPlayerMenu({ szOption = "Test1" }) -- ��̬
    HM.AppendPlayerMenu(function() return { szOption = "Test2" } end) -- ��̬
    ```

11. `(void) HM.Sysmsg(string szMsg[, string szHead])` - �����������һ�λ��֣�ֻ�е�ǰ�û��ɼ���

    > ���� *szMsg* -- Ҫ�������������
	> ��ѡ *szHead* --  ���ǰ׺���Զ����������ţ�Ĭ��Ϊ��`�������`

12. `(void) HM.Debug(string szMsg[, string szHead])`
    `(void) HM.Debug2(string szMsg[, string szHead])`
    `(void) HM.Debug3(string szMsg[, string szHead])` - ���������Ϣ������ `HM.Sysmsg`��������2����ǡ�

13.  `(void) HM.Alert(string szMsg, func fnAction[, string szSure])` - ����Ļ���е�����һ���ı���һ��ȷ����Ŧ�ľ�ʾ��

	> ���� *szMsg* -- ��ʾ��������
	> ���� *fnAction* -- ����ȷ�ϰ�Ŧ�󴥷��Ļص�����
	> ��ѡ *szSure* -- ȷ�ϰ�Ŧ�����֣�Ĭ��ֵ��`ȷ��`

14. `(void) HM.Confirm(string szMsg, func fnAction, func fnCancel[, string szSure[, string szCancel]])` - ����Ļ�м䵯����������Ŧ��ȷ�Ͽ򣬲�����һ���ı���ʾ

	> ���� *szMsg* -- ��ʾ��������
	> ���� *fnAction* -- ����ȷ�ϰ�Ŧ�󴥷��Ļص�����
	> ���� *fnCancel* -- ����ȡ����Ŧ�󴥷��Ļص�����
	> ��ѡ *szSure* -- ȷ�ϰ�Ŧ�����֣�Ĭ�ϣ�`ȷ��`
	> ��ѡ *szCancel* -- ȡ����Ŧ�����֣�Ĭ�ϣ�`ȡ��`

15. `(void) HM.AddHotKey(string szName, string szTitle, func fnAction)` - ����ϵͳ��ݼ�����

    > ���� *szName* -- ���Ʊ�ʶ��Ĭ�ϻ��Զ����� HM_ ��ͷ
    > ���� *szTitle* -- ��������������
	> ���� *fnAction* -- ���º󴥷��Ļص�����

16. `(string) HM.GetHotKey(string szName[, boolean bBracket[, boolean bShort]])` - ȡ�ÿ�ݼ�����

	> ���� *szName* -- ���Ʊ�ʶ��Ĭ�ϻ��Զ����� HM_ ��ͷ
	> ��ѡ *bBracket* -- �Ƿ����С���ţ����磺(`Ctrl-W)`
	> ��ѡ *bShort* -- �Ƿ񷵻���д�����磺`C-W` ���� `Ctrl-W`

17. `(void) HM.SetHotKey([string szGroup])` - �򿪿�ݼ��������

    > ��ѡ *szGroup* -- Ҫ�򿪵ķ������ƣ�Ĭ��Ϊ `HM.szTitle`

    ```lua
	HM.SetHotKey("���濪��")	-- �򿪡����濪�ء��Ŀ�ݼ�����
	```

18. `(void) HM.BreatheCall(string szKey, func fnAction[, number nTime])` - ע�����ѭ�����ú���

	> ���� *szKey* -- �������ƣ�����Ψһ���ظ��򸲸�
	> ���� *fnAction* -- ѭ���������ú�������Ϊ nil ���ʾȡ����� key �µĺ���������
    > ��ѡ *nTime* -- ���ü������λ�����룬Ĭ��Ϊ 62.5����ÿ����� 16�Σ���ֵ�Զ�������� 62.5 ��������

19. `(void) HM.DelayCall(number nDelay, func fnAction)` - �ӳٵ���

	> ���� *nTime* -- �ӳٵ���ʱ�䣬��λ�����룬ʵ�ʵ����ӳ��ӳ��� 62.5 ��������
    > ���� *fnAction* -- ���ú���

20. `(void) HM.RemoteRequest(string szUrl, func fnAction)` - ����Զ�� HTTP ����

	> ���� *szUrl* -- ��������� URL������ http:// �� https://��
    > ���� *fnAction* -- ������ɺ�Ļص��������ص�ԭ�ͣ�`function(szTitle)`

21. `(KObject) HM.GetTarget()` - ȡ�õ�ǰĿ���������

22. `(KObject) HM.GetTarget([number dwType, ]number dwID)` - ���� dwType ���ͺ� dwID ȡ�ò�������

	> ��ѡ *dwType* Ŀ�����ͣ�`TARGET.xxx`
	> ���� *dwID* Ŀ������� ID

23. `(string) HM.GetTargetName(userdata KNpc/KPlayer)` - ����Ŀ�������ʾ�����֣�֧�ֳ���������

24. `(void) HM.Talk(string szTarget, string szText[, boolean bNoEmotion])`
    `(void) HM.Talk([number nChannel, ] string szText[, boolean bNoEmotion])` - ��������

	> ���� *szTarget* -- ���ĵ�Ŀ���ɫ��
	> ��ѡ *nChannel* -- ����Ƶ����PLAYER_TALK_CHANNLE.xxx��Ĭ��Ϊ����
    > ���� *szText* -- �������ݣ������Ϊ���� KPlayer.Talk �� table��
    > ��ѡ *bNoEmotion* -- ���������������еı���ͼƬ��Ĭ��Ϊ false
	> **�ر�ע��** `nChannel`, `szText` ���ߵĲ���˳����Ե������Ŷ�Ƶ����ս���������л�Ϊս��Ƶ��

	```lua
	HM.Talk("������", "��ð���") -- ���� [������]
	HM.Talk("��ð���")	-- �ڽ��ķ���
	HM.Talk(PLAYER_TALK_CHANNEL.TONG, "��ð���#õ��") -- �ڰ��Ƶ������
	```

25. `(void) HM.BgTalk(string szTarget, ...)`
    `(void) HM.BgTalk(number nChannel, ...)` - ������̨����ͨѶ����

    > ���� *szTarget* -- ���ĵ�Ŀ���ɫ��
	> ���� *nChannel*  -- ����Ƶ����PLAYER_TALK_CHANNLE.xxx��Ĭ��Ϊ����
	> ���� *...* -- ���ɸ��ַ���������ɣ���ԭ�������յ�����ΪͨѶ����

26. `(table) HM.BgHear([string szKey])` - ��ȡ��̨�������ݣ��� `ADDON_BG_TALK`
    �¼���������ʹ�ò�������

	> ��ѡ *szKey* -- ͨѶ���ͣ�Ҳ���� `HM.BgTalk` �ĵ�һ���ݲ���������ƥ�������
	> ����ֵ������ͨѶ������ɵ� table
    > **�ر�˵��** arg0: dwTalkerID, arg1: nChannel, arg2: bEcho, arg3: szName

27. `(boolean) HM.IsDps([KPlayer tar])` - �������Ƿ�Ϊ DPS �ڹ���ʡ���ж����ж�����

28. `(boolean) HM.IsParty(number dwID)` - ������� ID �ж��Ƿ�Ϊ����

29. `(table) HM.GetAllPlayer([number nLimit])` - ��ȡ�����ڵ�������Ҷ���

	> ��ѡ *nLimit* -- �������ޣ�Ĭ�ϲ���

30. `(table) HM.GetAllNpc([number nLimit])` -- ��ȡ�����ڵ����� NPC����

    > ��ѡ *nLimit* -- �������ޣ�Ĭ�ϲ���

32. `(number) HM.GetDistance(KObject tar)`
    `(number) HM.GetDistance(number nX, number nY[, number nZ])` -  ����Ŀ��������ľ���

	> ���� *tar* -- ���� nX��nY��nZ �����Ե� table �� KPlayer��KNpc��KDoodad
    > ���� *nX* -- ��������ϵ�µ�Ŀ��� X ֵ
    > ���� *nY* -- ��������ϵ�µ�Ŀ��� Y ֵ
    > ��ѡ *nZ* -- ��������ϵ�µ�Ŀ��� Z ֵ
    > ����ֵ -- �����С����λ�ǳ�

	```lua
	local nDis = HM.GetDistance(GetTargetHandle(GetClientPlayer().GetTarget())) -- ���㵱ǰĿ�����
	```

33. `(number, number) HM.GetScreenPoint(KObject tar)`
    `(number, number) HM.GetScreenPoint(number nX, number nY, number nZ)` - ����Ŀ������λ�á�
	����������������Ļ�ϵ���Ӧλ��

    > ���� *tar* -- ���� nX��nY��nZ �����Ե� table �� KPlayer��KNpc��KDoodad
    > ���� *nX* -- ��������ϵ�µ�Ŀ��� X ֵ
    > ���� *nY* -- ��������ϵ�µ�Ŀ��� Y ֵ
    > ��ѡ *nZ* -- ��������ϵ�µ�Ŀ��� Z ֵ
    > ����ֵ -- ��Ļ����� X��Y ֵ��ת��ʧ�ܷ��� nil

34. `(number, number) HM.GetTopPoint(KObject tar[, number nH])`
    `(number, number) HM.GetTopPoint(number dwID[, number nH])` - ����Ŀ������λ�ü�������Ļ�ϵ�ͷ����Ӧλ��

	> ���� *tar* -- Ŀ����� KPlayer��KNpc��KDoodad
    > ���� *dwID* -- Ŀ�� ID
    > ��ѡ *nH* -- �߶ȣ���λ�ǣ���*64��Ĭ�϶��� NPC/PLAYER �����ܼ���ͷ��

35. `(table) HM.Split(string szFull, string szSep)` - ���� szSep �ָ��ַ��� szFull����֧�ֱ��ʽ���͹ٷ��� `SplitString` һ��

36. `(string) HM.Trim(string szText)` - ����ַ�����β�Ŀհ��ַ�

37. `(string) HM.UrlEncode(string szText)` - ת��Ϊ URL ���룬%xx%xx ...

38. `(string, number) HM.GetSkillName(number dwSkillID[, number dwLevel])` - ���ݼ��� ID ���ȼ���ȡ���ܵ����Ƽ�ͼ�� ID�����û��洦��

39. `(string, number) HM.GetBuffName(number dwBuffID[, number dwLevel])` - ����Buff ID ���ȼ���ȡ BUFF �����Ƽ�ͼ�� ID�����û��洦��

40. `(void) HM.RegisterEvent(string szEvent, func fnAction)` - ע���¼�����ϵͳ���������ڿ���ָ��һ�� KEY ��ֹ��μ���

	> ���� *szEvent* -- �¼������ں����һ���㲢����һ����ʶ�ַ������ڷ�ֹ�ظ���ȡ���󶨣��� LOADING_END.xxx
    > ���� *fnAction* -- �¼����� arg0 ~ arg9������ nil �൱��ȡ�����¼�
    > **�ر�ע��** �� `fnAction` Ϊ nil ʱ��ȡ������ͨ��������ע����¼�������

41. `(void) HM.UnRegisterEvent(string szEvent)` - ȡ���¼�������

42. `(bool) HM.CanUseSkill(number dwSkillID)` - ���ݼ��� ID �жϵ�ǰ�û��Ƿ����ĳ�����ܣ����Է��� true ���� false

43. `(class) HM.HandlePool(userdata handle, string szXml)` - ��������Ԫ������أ��ԣ�

44. `(void) HM.RegisterCustomUpdater(func fnAction, number nUpdateDate)` - Role Custom Data ���غ��жϱȽ� nUpdateDate Ȼ����� fnAction


��Ӳ��������
---------------

1. ���������������������һ�����ð�Ŧ����ͨ������ĺ��������׵���ɣ��뿴ԭ�ͣ�
   ```
   (void) HM.RegisterPanel(string szTitle, number dwIcon, string szClass, table fn)
   ```
   > ���� *szTitle* -- �������
   > ���� *dwIcon* -- ���ͼ�� ID
   > ���� *szClass* -- �������ƣ���Ϊ nil ������
   > ���� *fn* -- ���������� (table)
   > ```lua
   > local fn = {
   >   OnPanelActive = (void) function(WndWindow frame),   -- ������弤��ʱ���ã�����Ϊ���û���Ĵ������
   >   OnPanelDeactive = (void) function(WndWindow frame), -- *��ѡ* ������屻�г�ʱ���ã�����ͬ��
   >   OnConflictCheck = (void) function(),                -- *��ѡ* �����ͻ��⺯����ÿ�����ߺ����һ�Σ�
   >   OnPlayerMenu = (table) function(),                  -- *��ѡ* ���ظ��ӵ�ͷ��˵��б�����
   >   GetAuthorInfo = (string) function(),                -- *��ѡ* ���ظò�������ߡ���Ȩ��Ϣ
   > }
   > ```

2. ��������޸���ע�ả����������еĴ����������������溯����ȡ��������
   ```lua
   (table) HM.GetPanelFunc(szTitle)	-- ���� szTitle �ǲ������
   ```
   ���൱�ڵõ���ע��� fn ������Ȼ����Զ������ HOOK ��������ʵ�ֲ��������


������ UI ��װ
---------------

�����������������ʱ������Ϊ�˼򻯲�����Գ��õ� UI Ԫ�������˶����װ���������� jQuery ��˼·��
�� setter/getter �����˺������ƺϲ������������ĵ��ñ�ʾ���ã���������ʱ���ʾȡֵ������ÿ������
���������ض��������Ա�ʵ�ִ��ӡ�

�ȿ�����һ�������ӣ����û�ͷ���·����һ����Ŧ������������ڴ���ʾһ�����֣��ǲ��Ǻܼ��أ�

```lua
HM.UI(Player_GetFrame()):Append("WndButton", {x=50,y=100,txt="��������"}):Click(function() HM.Sysmsg("���ã�����") end)
```

** С��ʾ** Ϊ���Է�����Խ��˶δ���ǰ���� /script �������촰��ִ�м��ɣ���


### �����ж�������ȡ UI ��װ���� ###

1.  `HM.UI.Fetch(userdata hRaw)` - ��һ��ԭʼ UI ����ת��Ϊ HM.UI ��װ����֧�ָ��� WndXXX �� �������

2.  `HM.UI.Fetch(userdata hParent, szName)` - ��ԭʼ���� *hParent* ����ȡ��Ϊ *szName* ����Ԫ����ת��Ϊ `HM.UI` ����

3.  `HM.UI(...)` - ͨ��Ԫ��Ϸ���������� HM.UI() ������ HM.UI.Fetch() ����������ͨ�õ�  HM.UI ����
    ��ֱ�ӵ��÷�װ������ʧ�ܻ������ nil


### �򿪿հ׶Ի����壬������ HM.UI ��װ���� ###

```
HM.UI.OpenFrame([[string szName, ]table tArg])
```

> ��ѡ *szName* -- ����Ψһ���ƣ���ʡ�����Զ�����ţ�ͬ���ظ����û��ȹرմ��ڵ�
> ��ѡ *tArg* -- ��ʼ�����ò������Զ�������Ӧ�ķ�װ�������������Ծ���ѡ
> ```lua
> local tArg = {
>     w = 234, h = 200,   -- ��͸ߣ��ɶԳ�������ָ����С��ע���Ȼ��Զ����ͽ�����Ϊ��770/380/234���߶���С 200
>     x = 0, y = 0,       -- λ�����꣬Ĭ������Ļ���м�
>     title = "�ޱ���",   -- �������
>     drag = true,        -- ���ô����Ƿ���϶���true/false
>     close = false,      -- ����رհ�Ŧ���Ƿ������رմ��壨��Ϊ false �������ط��㸴�ã�
>     empty = false,      -- �����մ��壬����������ȫ͸����ֻ�ǽ�������Ĭ��Ϊ false
>     fnCreate = function(frame) end,	    -- �򿪴����ĳ�ʼ��������frame Ϊ���ݴ��壬�ڴ���� UI
>     fnDestroy = function(frame) end,    -- �ر����ٴ���ʱ���ã�frame Ϊ���ݴ��壬���ڴ��������
> }
> ```

### ��������/������� INI �����ļ��������� HM.UI ��װ���� ###

```
HM.UI.Append(userdata hParent, string szIniFile, string szTag, string szName)
```

> ���� *hParent* -- �����������ԭʼ����HM.UI ������ֱ����  :Append ������
> ���� *szIniFile* --  INI �ļ�·��
> ���� *szTag* -- Ҫ��ӵĶ���Դ�����������ڵĲ��� [XXXX]������ hParent ƥ����� Wnd ���������
> ��ѡ��*szName* -- �������ƣ�����ָ��������ԭ����
> ����ֵ��ͨ�õ�  HM.UI ���󣬿�ֱ�ӵ��÷�װ������ʧ�ܻ������ nil


### ��������/������� UI Ԫ���������� HM.UI ��װ���� ###

```
HM.UI.Append(userdata hParent, string szType[, string szName], table tArg)
```

> ���� *hParent* -- �����������ԭʼ����HM.UI ������ֱ����  :Append ������
> ���� *szType* -- Ҫ��ӵ�������ͣ��磺WndWindow��WndEdit��Handle��Text ������
> ��ѡ *szName* -- Ԫ�����ƣ���ʡ�����Զ������
> ��ѡ *tArg* -- ��ʼ�����ò������Զ�������Ӧ�ķ�װ�������������Ծ���ѡ
> ```lua
> local tArg = {
>     w = 100, h = 100,       -- ��͸ߣ��ɶԳ�������ָ����С
>     x = 0, y = 0,           -- λ�����꣬�ɶԳ���
>
>     txt = "",               -- �ı�����
>     font = 27,              -- �ı�����
>     multi = false,          -- �Ƿ�����ı���true/false
>     limit = 1024,           -- ���ֳ�������
>     align = 0,              -- ���뷽ʽ��0����1���У�2���ң�
>
>     color = {255,255,255},	-- ��ɫ { nR, nG, nB }
>     alpha = 100,            -- ��͸���ȣ�0 - 255
>     checked	= false,        -- �Ƿ�ѡ��WndCheckBox/WndRadioBox/WndTabBox ר��
>     enable = true,          -- �Ƿ����ã�Ĭ�� true
>
>     file = "", icon = 1, type = 0,  -- ͼƬ�ļ���ַ��ͼ���ţ�����
>     group = nil,                    -- ��ѡ��������ã��μ� checked
> }
> ```
> ����ֵ -- ͨ�õ�  HM.UI ���󣬿�ֱ�ӵ��÷�װ������ʧ�ܻ������ nil


### HM.UI ��װ��Ԫ�������б� ###

UI Ԫ�����ͣ�Ҳ���� HM.UI.Append �� szType ������ֵ��Ŀǰ�ѷ�װ�İ�����

1.  **���弶����*** �������ֻ����Ϊ `WndFrame` �� `WndWindow` �������Ԫ��
    - `WndActionWindow` ���¼�֧�ֵ��鴰��
    - `WndWindow`       α�鴰��
    - `WndButton`       ��Ŧ
    - `WndCheckBox`     ���θ�ѡ��
    - `WndRadioBox`     Բ�θ�ѡ��
    - `WndTabBox`       ��Ŧ��ѡ��
    - `WndComboBox`     �����˵�ѡ����
    - `WndEdit`         �༭��
    - `WndTrackBar`     ˮƽ������
    - `WndWebPage`      Ƕ����ҳ

2.  ����Ԫ�����������ֻ����Ϊ `Handle` ��������Ԫ��
    - `Handle2`         ����������Ϊ Handle
    - `Box`             ��������
    - `BoxButton`       ��ͼ��İ�Ŧ
    - `TxtButton`       ���ְ�Ŧ
    - `Text`            ����
    - `Label`           ���ű�ʶ���� Text ���ͣ�����һ������
    - `Shadow`          ��Ӱ����
    - `Image`           ͼƬ

### HM.UI ��װ�Ķ��󷽷��б� ###

���еķ�װ����ͨ����������ķ�ʽ���ã�������ķ��������Դ��ӵ��ã�����Ϊʾ�����룺

```lua
-- ��ͷ���������һ���������
local ui = HM.UI(Player_GetFrame()):Append("Text")
ui:Pos(10, 100):Text("text2"):Color(255, 0, 0)

-- ��ȡ��������
local szText = ui:Text()
```

1. ͨ�÷����ӿڣ��ʺϸ������͵�Ԫ����
   - `ui:Raw()` ���� userdata ԭʼ����
   - `ui:Remove()` ɾ����ǰ����
   - `ui:Name([szName])` ��ȡ/����Ԫ������
   - `ui:Toggle([bShow])` �л�/��ʾ/����Ԫ��
   - `ui:Size([nW, nH])` ��ȡ/����Ԫ����С
   - `ui:Pos([nX, nY])` ��ȡ/����Ԫ��λ��
   - `ui:Pos_()` ��ȡԪ�������½�����λ��

   - `ui:CPos_()` ��ȡ������������һ��Ԫ�ص����½����ֻ֧꣬�� Handle/WndFrame
   - `ui:Append(szType, ...)` �ڵ�ǰԪ���������Ԫ����ֻ֧�� Handle/WndFrame���μ� HM.UI.Append()
   - `ui:Fetch(szName)` �������ƻ�ȡ��ǰԪ������Ԫ����ֻ֧�� Handle/WndFrame���μ� HM.UI.Fetch()

   - `ui:Align([nHAlign[, nVAlign]])` ��ȡ/����Ԫ���е����ֶ��뷽ʽ������Ϊ�ֱ�Ϊˮƽ�ʹ�ֱ����Ķ���
   - `ui:Font([nFont])` ��ȡ/������������
   - `ui:Color([nR, nG, nB])` ��ȡ/����Ԫ����ɫ
   - `ui:Alpha([nAlpha])` ��ȡ/����Ԫ���Ĳ�͸����

2. WndFrame ���з�����HM.UI.OpenFrame() �ķ���ֵ
   - `ui:Size([nW, nH])` ��ȡ/���ô��ڴ�С����С�߶� 200������Զ����ӽ�ȡ 234/380/770
   - `ui:Title[szTitle])` ��ȡ/���ô��ڱ���
   - `ui:Drag([bEnable])` ��ȡ/�����Ǵ����Ƿ����϶�
   - `ui:Relation(szName)` �ı䴰�ڵĸ����������磺Normal/Topmost/Lowest ...
   - `ui:Lookup(...)` �ڴ���ԭʼ�����м�����Ԫ��

3. WndXXX �Ĵ������ר�÷���
   - `ui:Enable([bEnable])` ��ȡ/���ô����Ƿ���ã����ú���ǻ�ɫ��
   - `ui:AutoSize([hPad, vPad])` �Զ�����ĳЩԪ���Ŀ�͸ߣ�ֻ֧�� WndTabBox/WndButton/WndComboBox��������Ϊ������
   - `ui:Check([bCheck])` �ж��Ƿ�ѡ��/ѡ�С�ȡ����ѡ��ֻ֧�� WndTabBox/WndRadioBox/WndCheckBox��
   - `ui:Group([szName])` ��ȡ/���ø�ѡ��ķ������ƣ�ͬ���ѡ��ֻ��һ���ܱ�ѡ�У�ֻ֧�� WndTabBox/WndRadioBox/WndCheckBox��
   - `ui:Url([szUrl])` ��ȡ/���� WndWebPage Ԫ���ĵ�ǰ��ַ
   - `ui:Range([nMin, nMax[, nStep])` ��ȡ/���� WndTracBar ����Сֵ�����ֵ��������Ĭ��Ϊ 0,100,100
   - `ui:Value([nVal])` ��ȡ/���� WndTracBar �ĵ�ǰֵ
   - `ui:Text([szText])` ��ȡ/�����ı�������
   -` ui:Mutli([bEnable])` ��ȡ/�����ı��Ƿ�Ϊ����
   - `ui:Limit([nLimit])` ��ȡ/�����ı���������

   - `ui:Change([func fnAction])` ִ��/���� WndEdit/WndTrackBar �����ı�ʱ���¼�����
   - `ui:Menu((table|func)` menu)` ���� WndComboBox �������˵������������ǲ˵����Ƿ��ز˵��ĺ���
   - `ui:Click([fnAction])` ִ��/����Ԫ�������������ʱ�Ļص�����
   - `ui:Hover(fnEnter[, fnLeave])` ����Ԫ����������ʱ�Ĵ�������fnLeave Ϊ��ѡ��������ʡ����ʹ�� fnEnter��
     ���뺯������ true ��Ϊ�������뿪�������� false Ϊ������

4. ���������ר�÷���
   - `ui:Zoom(bEnable)` ���� BoxButton �Ƿ��ڵ�����ʵ��Ŵ�ֵΪ true/false
   - `ui:Text([szText])` ��ȡ/�����ı�������
   - `ui:Mutli([bEnable])` ��ȡ/�����ı��Ƿ�Ϊ����
   - `ui:File(szFile[, nFrame])` ���� Image Ԫ����ͼƬ·����֡����֡������ʡ��ֱ��ʹ�� TGA ͼƬ
   - `ui:Icon([dwIcon])` ���� Image �� BoxButton �� Box Ԫ����ͼ�� ID
   - `ui:Type([nType])` ��ȡ/���� Image ���ͣ�BoxButton �ı���ͼƬ���ͣ�1,2,3���֣�

   - `ui:Click([fnAction])` ִ��/����Ԫ�������������ʱ�Ļص�����
   - `ui:Hover(fnEnter[, fnLeave])` ����Ԫ����������ʱ�Ĵ�������fnLeave Ϊ��ѡ��������ʡ����ʹ�� fnEnter
   ���뺯������ true ��Ϊ�������뿪�������� false Ϊ������


�򵥵�ʾ������
---------------

API ˵���Ѿ�д���ˣ����˴��Ӧ�û��ǻ�Ƚ��Ժ����ڴ����г�����ϵͳͼ��Ϊ����д����Χ��
ϵͳͼ�� ID ��Լ�� 1 - 3481������Ϊ���Դ��뽲�⡣

1. ���� interface Ŀ¼�´���һ�� HM_ListIcon Ŀ¼

2. �� HM_ListIcon Ŀ¼�´��� info.ini �������£����ǲ�������Ļ�����������͡�
```ini
[HM_ListIcon]
name=������ϵͳͼ���б�
desc=�г�ϵͳ����ͼ�� -- by ��������
version=0.8
default=1
lua_0=interface\HM_ListIcon\HM_ListIcon.lua
```

3. �� HM_ListIcon Ŀ¼�´��� HM_ListIcon.lua ��Ϊ�������ļ����������ݼ�ע�����£�

<pre>
-- ȫ�ֱ�����
HM_ListIcon = {
    szTitle = "ϵͳͼ���б�",
}

-- ���ر�����
local _HM_ListIcon = {
    nCur = 0,            -- ͼ�� ID ��Сֵ
    nMax = 3481,    -- ͼ�� ID ���ֵ
}

-- ��ȡ����������Ϣ
_HM_ListIcon.GetAuthorInfo = function()
    return "������@���Ŷ���ݶ���� (v1.0b)"
end

-- �ӵ�ͷ��˵��б�
_HM_ListIcon.OnPlayerMenu = function()
    -- �˵��е����ֱ�Ӵ��������
    return { szOption = "�鿴ϵͳͼ��", fnAction = function() HM.OpenPanel(HM_ListIcon.szTitle) end }
end

-- ��ͻ��⺯�����״�����ʱִ��
_HM_ListIcon.OnConflictCheck = function()
    HM.Sysmsg("ִ�� HM_ListIcon ��ͻ��⺯�� ����")
end

-- ���ý����ʼ������
_HM_ListIcon.OnPanelActive = function(frame)
    -- ��������崰��ת��Ϊ ��װ�õ� HM.UI ����
    local ui = HM.UI(frame)
    local imgs, txts = {}, {}

    -- �ڽ�������ӻ�ɫ�ı������֣�����Ϊ 27 ��
    ui:Append("Text", { txt = "ϵͳͼ���ȫ", x = 0, y = 0, font = 27 })

    -- ��������Ϊ ÿҳ 40����ÿҳ 4�У�ÿ�� 10�� ͼ��
    for i = 1, 40 do
        local x = ((i - 1) % 10) * 50
        local y = math.floor((i - 1) / 10) * 70 + 40
        -- ���һ�� 48x48 ��ͼƬ
        imgs[i] = ui:Append("Image", { w = 48, h = 48, x = x, y = y})
        -- ��ͼƬ�·���� 48x20 �����֣����ж���
        txts[i] = ui:Append("Text", { w = 48, h = 20, x = x, y = y + 48, align = 1 })
    end

    -- ���·���� 2 ����Ŧ
    local btn1 = ui:Append("WndButton", { txt = "��һҳ", x = 0, y = 320 })
    local nX, _ = btn1:Pos_()
    local btn2 = ui:Append("WndButton", { txt = "��һҳ", x = nX, y = 320 })
    -- ������һҳ�ĵ��������
    btn1:Click(function()
        _HM_ListIcon.nCur = _HM_ListIcon.nCur - #imgs
        if _HM_ListIcon.nCur <= 0 then
            _HM_ListIcon.nCur = 0
            -- �Ѿ��ǵ�һҳ������Ŧ��Ϊ���ɵ��
            btn1:Enable(false)
        end
        -- ��һҳ�϶�Ҫ��Ϊ���Ե��
        btn2:Enable(true)
        -- ˢ��ͼƬ�����ֵ�����
        for k, v in ipairs(imgs) do
            local i = _HM_ListIcon.nCur + k - 1
            if i > _HM_ListIcon.nMax then
                break
            end
            imgs[k]:Icon(i)
            txts[k]:Text(tostring(i))
        end
    end):Click()
    -- ������һҳ��Ŧ�Ĵ�����
    btn2:Click(function()
        _HM_ListIcon.nCur = _HM_ListIcon.nCur + #imgs
        if (_HM_ListIcon.nCur + #imgs) >= _HM_ListIcon.nMax then
            -- �Ѿ����һҳ������Ŧ��Ϊ���ɵ��
            btn2:Enable(false)
        end
        -- ��һҳ�϶�Ҫ��Ϊ���Ե��
        btn1:Enable(true)
        -- ˢ��ͼƬ�����ֵ�����
        for k, v in ipairs(imgs) do
            local i = _HM_ListIcon.nCur + k - 1
            if i > _HM_ListIcon.nMax then
                break
            end
            imgs[k]:Icon(i)
            txts[k]:Text(tostring(i))
        end
    end)
end

-- �����ý�����ӵ����������������Ϊ����������ͼ�� ID��591������������ _HM_ListIcon
HM.RegisterPanel(HM_ListIcon.szTitle, 591, "����", _HM_ListIcon)
</pre>

4. С�˽���Ϸ������������~_~


����
----

���ˣ�HM ����� API ˵��д���ˡ�������Ŀǰ������߲����࣬�󲿷�Ҳ�����Լ��Ŀ��������⣬
��д�����Ҫ����Ϊ���Լ���¼��һֱ������һ��С��Ը��

�������Ǻܻ�ӭ�����������Ұ��Լ������Ĳ����ӵ��������������ͳһ����^o^

2012/7/17 - by HM


