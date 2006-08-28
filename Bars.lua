﻿
assert( BigWigs, "BigWigs not found!")


------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.0"):new("BigWigsBars")
local paint = AceLibrary("PaintChips-2.0")
local minscale, maxscale = 0.25, 2


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Bars"] = true,

	["bars"] = true,
	["anchor"] = true,
	["scale"] = true,
	["up"] = true,

	["Options for the timer bars."] = true,
	["Show the bar anchor frame."] = true,
	["Set the bar scale."] = true,
	["Group upwards"] = true,
	["Toggle bars grow upwards/downwards from anchor."] = true,

	["Timer bars"] = true,
	["Show anchor"] = true,
	["Grow bars upwards"] = true,
	["Scale"] = true,
	["Bar scale"] = true,

	["Bars now grow %2$s"] = true,
	["Scale is set to %2$s"] = true,

	["Up"] = true,
	["Down"] = true,
	
	["Test"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["bars"] = "바",
	["anchor"] = "위치",
	["scale"] = "크기",
	["up"] = "방향",

	["Options for the timer bars."] = "Timer 바 옵션 조정.",
	["Show the bar anchor frame."] = "바 위치 조정 프레임 보이기.",
	["Set the bar scale."] = "바 크기 조절.",
	["Toggle bars grow upwards/downwards from anchor."] = "바 표시 순서를 위/아래로 조정.",

	["Timer bars"] = "타이머 바",
	["Show anchor"] = "앵커 보이기",
	["Grow bars upwards"] = "바 위로 자라기",
	["Scale"]= "크기",
} end)

L:RegisterTranslations("zhCN", function() return {
	["Bars"] = "计时条",

	["Options for the timer bars."] = "计时条设置/",
	["Show the bar anchor frame."] = "显示计时条框体锚点。",
	["Set the bar scale."] = "设置计时条缩放比例。",
	["Group upwards"] = "向上排列",
	["Toggle bars grow upwards/downwards from anchor."] = "切换计时条从锚点向下/向上排列。",

	["Timer bars"] = "计时条",
	["Show anchor"] = "显示锚点",
	["Grow bars upwards"] = "向上延展",
	["Scale"] = "缩放",
	["Bar scale"] = "计时条缩放",

	["Bars now grow %2$s"] = "计时条设置为向%2$s延展。",
	["Scale is set to %2$s"] = "缩放比例设置为%2$s",

	["Up"] = "上",
	["Down"] = "下",
} end)

L:RegisterTranslations("deDE", function() return {
	["Bars"] = "Anzeigebalken",

	-- ["bars"] = true,
	-- ["anchor"] = true,
	-- ["scale"] = true,
	-- ["up"] = true,

	["Options for the timer bars."] = "Optionen f\195\188r die Timer Anzeigebalken.",
	["Show the bar anchor frame."] = "Zeige die Verankerung der Anzeigebalken.",
	["Set the bar scale."] = "W\195\164hle die Skalierung der Anzeigebalken.",
	["Group upwards"] = "Nach oben fortsetzen",
	["Toggle bars grow upwards/downwards from anchor."] = "Anzeigebalken von der Verankerung aus nach Oben/Unten fortsetzen.",

	["Timer bars"] = "Timer Anzeigebalken",
	["Show anchor"] = "Zeige Verankerung",
	["Grow bars upwards"] = "Anzeigebalken nach oben fortsetzen lassen",
	["Scale"] = "Skalierung",
	["Bar scale"] = "Anzeigebalken Skalierung",

	["Bars now grow %2$s"] = "Anzeigebalken werden nun fortgesetzt nach %2$s",
	["Scale is set to %2$s"] = "Skalierung jetzt %2$s",

	["Up"] = "Oben",
	["Down"] = "Unten",
	
	["Test"] = "Test",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBars = BigWigs:NewModule(L"Bars")
BigWigsBars.revision = tonumber(string.sub("$Revision$", 12, -3))
BigWigsBars.defaultDB = {
	growup = false,
	scale = 1.0,
}
BigWigsBars.consoleCmd = L["bars"]
BigWigsBars.consoleOptions = {
	type = "group",
	name = L["Bars"],
	desc = L["Options for the timer bars."],
	args   = {
		[L["anchor"]] = {
			type = "execute",
			name = L["Show anchor"],
			desc = L["Show the bar anchor frame."],
			func = function() BigWigsBars:BigWigs_ShowAnchors() end,
		},
		[L["up"]] = {
			type = "toggle",
			name = L["Group upwards"],
			desc = L["Toggle bars grow upwards/downwards from anchor."],
			get = function() return BigWigsBars.db.profile.growup end,
			set = function(v) BigWigsBars.db.profile.growup = v end,
			message = L["Bars now grow %2$s"],
			current = L["Bars now grow %2$s"],
			map = {[true] = L["Up"], [false] = L["Down"]},
		},
		[L["scale"]] = {
			type = "range",
			name = L["Bar scale"],
			desc = L["Set the bar scale."],
			min = 0.2,
			max = 2.0,
			step = 0.1,
			get = function() return BigWigsBars.db.profile.scale end,
			set = function(v) BigWigsBars.db.profile.scale = v end,
		},
	},
}


------------------------------
--      Initialization      --
------------------------------

function BigWigsBars:OnInitialize()
	self.anchorframe = BigWigsBarsAnchorFrame
end


function BigWigsBars:OnEnable()
	self:RegisterEvent("BigWigs_ShowAnchors")
	self:RegisterEvent("BigWigs_HideAnchors")
	self:RegisterEvent("BigWigs_StartBar")
	self:RegisterEvent("BigWigs_StopBar")
end


------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBars:BigWigs_ShowAnchors()
	self.anchorframe:Show()
end


function BigWigsBars:BigWigs_HideAnchors()
	self.anchorframe:Hide()
end

function BigWigsBars:BigWigs_StartBar(module, text, time, icon, otherc, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
	if not text or not time then return end
	local id = "BigWigsBar "..text
	local u = self.db.profile.growup

	-- yes we try and register every time, we also set the point every time since people can change their mind midbar.
	module:RegisterCandyBarGroup("BigWigsGroup")
	module:SetCandyBarGroupPoint("BigWigsGroup", u and "BOTTOM" or "TOP", "BigWigsBarsAnchorFrame", u and "TOP" or "BOTTOM", 0, 0)
	module:SetCandyBarGroupGrowth("BigWigsGroup", u)

	if type(otherc) ~= "boolean" or not otherc then c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = BigWigsColors:BarColor(time) end
	local bc, balpha = BigWigsColors.db.profile.bgc, BigWigsColors.db.profile.bga
	local txtc = BigWigsColors.db.profile.txtc

 	module:RegisterCandyBar(id, time, text, icon, c1, c2, c3, c4, c5, c6, c8, c9, c10)
 	module:RegisterCandyBarWithGroup(id, "BigWigsGroup")
	if bc then module:SetCandyBarBackgroundColor(id, bc, balpha) end
	if txtc then module:SetCandyBarTextColor(id, txtc) end

	module:SetCandyBarScale(id, self.db.profile.scale or 1)
	module:SetCandyBarFade(id, .5)
	module:StartCandyBar(id, true)
end

function BigWigsBars:BigWigs_StopBar(module, text)
	if not text then return end
	module:UnregisterCandyBar("BigWigsBar "..text)
end

------------------------------
--      Slash Handlers      --
------------------------------

function BigWigsBars:SetScale(msg, supressreport)
	local scale = tonumber(msg)
	if scale and scale >= minscale and scale <= maxscale then
		self.db.profile.scale = scale
		if not supressreport then self.core:Print(L["Scale is set to %s"], scale) end
	end
end

function BigWigsBars:ToggleUp(supressreport)
	self.db.profile.growup = not self.db.profile.growup
	local t = self.db.profile.growup
	if not supressreport then self.core:Print(L["Bars now grow %s"], (t and L["Up"] or L["Down"])) end
end


