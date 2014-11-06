--[[

---//==================================================\\---
--|| Infomation                                         ||--
---\\==================================================//---

	Script:		AnnieGod
	Version:	0.01
	Author:		Devn
	
--]]

---//==================================================\\---
--|| User Variables (You Can Change These)              ||--
---\\==================================================//---

local AutoUpdate		= true			-- Disables auto updating when the script is first loaded.
local AllowTracker		= true			-- Stops BoL Tracker from being loaded (only added to know how many people use script).

---//==================================================\\---
--|| Check Hero Name and GodLib Exists                  ||--
---\\==================================================//---

if (myHero.charName ~= "Annie") then return end

if (FileExist(LIB_PATH.."GodLib.lua")) then
	require("GodLib")
	if (not GodLib.Loaded) then return end
else
	DownloadFile("https://raw.githubusercontent.com/DevnScripts/BoL-Scripts/master/Commom/GodLib.lua", LIB_PATH.."GodLib.lua", function()
		PrintChat("AnnieGod: GodLib downloaded succesfully! Please reload the script (double F9).")
	end)
	PrintChat("AnnieGod: Downloading GodLib...")
	return
end

---//==================================================\\---
--|| Setup Script Functions                             ||--
---\\==================================================//---

function SetupVariables()

	Tibbers		= nil
	StunReady	= false

	SetupTargetSelector(STS_PRIORITY_LESS_CAST_MAGIC)
	
	SetupSpell(_Q, "Disintegrate", 625, -1, 0.25, 1400)
	SetupSpell(_W, "Incinerate", 625, 50 * math.pi / 180, 0.25, math.huge, SKILLSHOT_CONE, false, true)
	SetupSpell(_E, "Molten Shield", -1, -1, 0.5, -1)
	SetupSpell(_R, "Summon: Tibbers", 600, 290, 0.25, math.huge, SKILLSHOT_CIRCULAR, false, true)
	
	AddDrawing("Spell Ranges", "Draw "..Spells[_Q].Name.." (Q) Range", myHero, Spells[_Q].Range, true, function() Spells[_Q]:IsReady() end)
	AddDrawing("Spell Ranges", "Draw "..Spells[_R].Name.." (R) Range", myHero, Spells[_R].Range + (Spells[_R].Radius / 2), true, function() Spells[_Q]:IsReady() end)
	
	AddMinionManager("Enemy", MINION_ENEMY, Spells[_Q].Range, myHero, MINION_SORT_HEALTH_ASC)
	
	RegisterDamageSource(_Q, _MAGIC, 45, 35, _MAGIC, _AP, 0.8, function() return Spells[_Q]:IsReady() end)
	RegisterDamageSource(_W, _MAGIC, 25, 45, _MAGIC, _AP, 0.85, function() return Spells[_W]:IsReady() end)
	RegisterDamageSource(_R, _MAGIC, 85, 125, _MAGIC, _AP, 1.0, function() return Spells[_R]:IsReady() and not Tibbers end)
	
	-- Setup variable trackers.
	AddVariableTracker("Stun Ready", function() return StunReady end)
	
end

function SetupConfig()

	AddConfigSubMenu("Auto Spells", "AutoSpells")
	AddTitleRow(Config.AutoSpells, "Charge Stun")
	Config.AutoSpells:addParam("ChargeStunBase", "Use W and E to Charge Stun in Base", SCRIPT_PARAM_ONOFF, true)
	
	--AddConfigSubMenu("Auto-Interrupt", "AutoInterrupt")
	
	--AddConfigSubMenu("Killstealing", "Killstealing")
	
	--AddConfigSubMenu("Combo Mode", "Combo")
	
	--AddConfigSubMenu("Harass Mode", "Harass")
	
	AddConfigSubMenu("Last-Hit Mode", "LastHit")
	AddTitleRow(Config.LastHit, "Spells")
	Config.LastHit:addParam("UseQ", "Use "..Spells[_Q].Name.." (Q)", SCRIPT_PARAM_ONOFF, true)
	
	--AddConfigSubMenu("Mixed Mode", "Mixed")
	
	--AddConfigSubMenu("Lane-Clear Mode", "LaneClear")
	
	AddEmptyRow(Config)
	AddTitleRow(Config, "Hotkeys")
	--Config:addParam("ComboActive", "Combo Mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--Config:addParam("HarassActive", "Harass Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
	Config:addParam("LastHitActive", "Last-Hit Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	--Config:addParam("MixedActive", "Mixed Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	--Config:addParam("LaneClearActive", "Lane-Clear Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

end

---//==================================================\\---
--|| BoL Callback Functions                             ||--
---\\==================================================//---

function OnCreateObj(object)

	-- Check if hero gained stun proc.
	if (object.name:find("StunReady") and GetDistance(object, myHero) < 1) then
		StunReady = true
	end

end

function OnProcessSpell(unit, spell)

	-- Check if spell is from hero and check if lost stun proc.
	if (unit and unit.valid and unit.isMe and spell and spell.name) then
		if (StunReady) then
			if (spell.name:lower() == Spells[_Q].Name:lower() or spell.name:lower() == Spells[_W].Name:lower() or spell.name:lower() == Spells[_R].Name:lower()) then
				StunReady = false
			end
		end
	end

end

---//==================================================\\---
--|| Main Script Functions                              ||--
---\\==================================================//---

function ChargeStun()

	-- Check if stun is ready, hero is dead, setting is enabled or in fountain.
	if (StunReady or myHero.dead or not Config.AutoSpells.ChargeStunBase or not InFountain()) then return end
	
	-- Check if E is ready and cast it.
	-- Cast E first because it is not needed for a fight and if only one stack is required E is better then W.
	if (Spells[_E]:IsReady()) then
		Spells[_E]:Cast()
	end
	
	-- Double check stun is not ready, then make sure W is ready and cast it.
	if (not StunReady and Spells[_W]:IsReady()) then
		Spells[_W]:Cast(myHero.x, myHero.z)
	end

end

function HandlePerforms()

	if (Config.LastHitActive) then
		PerformLastHit()
	end

end

function PerformLastHit()

	-- Get lowest HP minion near target.
	local targetMinion
	for _, minion in ipairs(Minions["Enemy"].objects) do
		if (ValidTarget(minion)) then
			if (not targetMinion) then
				targetMinion = minion
			else
				if (minion.health < targetMinion.health) then
					targetMinion = minion
				end
			end
		end
	end
	
	-- Make sure there is a valid minion near hero.
	if (not targetMinion) then return end
	
	-- Check if user wants to use Q to farm and if it can be used and will kill minion.
	if (Config.LastHit.UseQ and Spells[_Q]:IsReady()) then
		local delay = Spells[_Q].Delay + GetDistance(targetMinion.visionPos, myHero.visionPos) / Spells[_Q].Speed - 0.07
		local predictedHealth = Prediction:GetPredictedHealth(targetMinion, delay)
		if (predictedHealth <= DamageCalc:CalcSpellDamage(targetMinion, _Q) and predictedHealth > 0) then
			CastSpells({ _Q }, targetMinion)
		end
	end

	-- Do SOW orbwalk.
	Orbwalk(3)

end

---//==================================================\\---
--|| Setup GodLib                                       ||--
---\\==================================================//---

-- Variables required by GodLib to run the script correctly.
GodLib.ScriptName		= "AnnieGod"
GodLib.ScriptVersion	= 0.01
GodLib.TrackerID		= 25
GodLib.AutoUpdate		= AutoUpdate
GodLib.AllowTracker		= AllowTracker
GodLib.SetupVariables	= SetupVariables
GodLib.SetupConfig		= SetupConfig

-- Start the script through the library.
StartScript()

-- Start script functions with appropriate frequencies.
TickLimiter(function() ChargeStun() end, 2)			-- Frequency of 2 because it won't be called that much and is a waste of resources.
TickLimiter(function() HandlePerforms() end, 10)
