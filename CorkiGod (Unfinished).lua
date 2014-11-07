--[[

---//==================================================\\---
--|| Infomation                                         ||--
---\\==================================================//---

	Script:		CorkiGod
	Version:	0.00
	Author:		Devn
	
--]]

---//==================================================\\---
--|| User Variables                                     ||--
---\\==================================================//---

-- These variables can be changes safely as they are to help make your use of this script more enoyable.
local AutoUpdate		= true
local AllowBoLTracker	= true

---//==================================================\\---
--|| Check Hero Name and GodLib Exists                  ||--
---\\==================================================//---

-- Make sure hero is Corki.
if (myHero.charName ~= "Corki") then return end

-- Load GodLib if it is found, otherwise download it and stop loading the script.
if (FileExist(LIB_PATH.."GodLib.lua")) then
	require("GodLib")
	if (not GodLib.Loaded) then return end
else
	DownloadFile("https://raw.githubusercontent.com/DevnScripts/BoL-Scripts/master/Common/GodLib.lua", LIB_PATH.."GodLib.lua", function()
		PrintChat("CorkiGod: GodLib downloaded succesfully! Please reload the script (double F9).")
	end)
	PrintChat("CorkiGod: Downloading GodLib...")
	return
end

---//==================================================\\---
--|| Setup Script Functions                             ||--
---\\==================================================//---

function SetupVariables()

	-- Create script variables.
	IsBigMissile = false

	-- Setup target selector.
	SetupTargetSelector(STS_PRIORITY_LESS_CAST_PHYSICAL)
	
	-- Setup hero spells.
	SetupSpell(_Q, "Phosphorus Bomb", 825 , 450, 0.5 , 1125, SKILLSHOT_CIRCULAR, false, true )
	SetupSpell(_W, "Valkyrie"       , 800 , -1 , -1  , -1  , SKILLSHOT_LINEAR  , false, false)
	SetupSpell(_E, "Gatling Gun"    , 600 , -1 , -1  , -1                                    )
	SetupSpell(_R, "Missile Barrage", 1225, 75 , 0.25, 2000, SKILLSHOT_LINEAR  , true , false)
	
	-- Register hero spell damages.
	RegisterDamageSource(_Q, _MAGIC, 30 , 50, { _MAGIC, _MAGIC }, { _AD, _AP }, { 0.5, 0.5 }, function() return Spells[_Q]:IsReady() end)
	RegisterDamageSource(_R, _MAGIC, 0  , 0 , { _MAGIC, _MAGIC }, { _AP, _AD }, { 0.0, 0.0 }, function() return Spells[_R]:IsReady() end, function(target) return getDmg("R", target, myHero) end)

	-- Add minion managers.
	AddMinionManager("Enemy", MINION_ENEMY, Spells[_R].Range, myHero, MINION_SORT_HEALTH_ASC)
	
	-- Setup library variables.
	ScoutRange = Spells[_Q].Range
	
	-- Setup combos.
	Combos = {
		{ Text = "AA"    , Range = GetTrueRange(myHero), Sequence = { _AA        } },
		{ Text = "R"     , Range = Spells[_R].Range    , Sequence = { _R         } },
		{ Text = "R>AA"  , Range = GetTrueRange(myHero), Sequence = { _R, _AA    } },
		{ Text = "Q"     , Range = Spells[_Q].Range    , Sequence = { _Q         } },
		{ Text = "Q>AA"  , Range = GetTrueRange(myHero), Sequence = { _Q, _AA    } },
		{ Text = "Q>R"   , Range = Spells[_Q].Range    , Sequence = { _Q, _R     } },
		{ Text = "Q>R>AA", Range = GetTrueRange(myHero), Sequence = { _Q, _R, AA } }
	}
	
	-- Setup variable trackers.
	AddVariableTracker("Is Big Missile", function() return IsBigMissile end)
	
end

function SetupConfig()

	-- Setup "Settings: Combo Mode" section.
	AddSubMenu(Config, "Combo Mode", "Combo")
	AddTitleRow(Config.Combo, "W Settings")
	Config.Combo:addParam("UseW", "Use "..Spells[_W].Name.." (W)", SCRIPT_PARAM_LIST, 1, { "To Mouse", "To Target" })
	
	-- Setup "Settings: Harass Mode" section.
	AddSubMenu(Config, "Harass Mode", "Harass")
	AddTitleRow(Config.Harass, "Spells")
	Config.Harass:addParam("UseQ", "Use "..Spells[_Q].Name.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.Harass:addParam("UseR", "Use "..Spells[_R].Name.." (R)", SCRIPT_PARAM_ONOFF, true)
	AddEmptyRow(Config.Harass)
	AddTitleRow(Config.Harass, "Mana Conditions")
	Config.Harass:addParam("MinMana", "Minimum Mana Percent" SCRIPT_PARAM_SLICE, 50, 0, 100)
	
	-- Setup "Settings: Lane-Clear Mode" section.
	AddSubMenu(Config, "Lane-Clear Mode", "LaneClear")
	AddTitleRow(Config.LaneClear, "Spells")
	Config.LaneClear:addParam("UseQ", "Use "..Spells[_Q].Name.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.LaneClear:addParam("UseR", "Use "..Spells[_R].Name.." (R)", SCRIPT_PARAM_ONOFF, true)
	
	-- Setup "Settings: Jungle Clear Mode" section.
	AddSubMenu(Config, "Jungle-Clear Mode", "JungleClear")
	AddTitleRow(Config.JungleClear, "Spells")
	Config.JungleClear:addParam("UseQ", "Use "..Spells[_Q].Name.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Config.JungleClear:addParam("UseR", "Use "..Spells[_R].Name.." (R)", SCRIPT_PARAM_ONOFF, true)
	
	-- Setup "Killstealing" section.
	AddEmptyRow(Config)
	AddTitleRow(Config, "Killstealing")
	Config:addParam("EnableKillstealing", "Enable Smart Killstealing", SCRIPT_PARAM_ONOFF, true)
	
	-- Setup "Hotkeys" section.
	AddEmptyRow(Config)
	AddTitleRow(Config, "Hotkeys")
	Config:addParam("ComboActive", "Combo Mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("HarassActive", "Harass Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Config:addParam("LastHitActive", "Last-Hit Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	Config:addParam("LaneClearActive", "Lane-Clear Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	Config:addParam("JungleClearActive", "Jungle-Clear Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	Config:addParam("MixedActive", "Mixed Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))

end
