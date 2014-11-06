--[[

---//==================================================\\---
--|| Infomation                                         ||--
---\\==================================================//---

	Library:	GodLib
	Version:	0.01
	Author:		Devn
	
--]]

---//==================================================\\---
--|| Print Functions                                    ||--
---\\==================================================//---

function PrintMessage(message)
	PrintChat("<font color=\"#81BEF7\">"..GodLib.ScriptName..":</font> <font color=\"#00FF00\">"..message.."</font>")
end

---//==================================================\\---
--|| Initialization                                     ||--
---\\==================================================//---

class "__GodLib"

function __GodLib:__init()
	
	self.Loaded			= true

	self.AutoUpdate		= true
	self.AllowTracker	= true
	self.ScriptName		= "GodSeries - Unknown Name"
	self.ScriptVersion	= 0.00
	self.TrackerID		= 0
	self.TrackerHWID	= Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
	self.SetupVariables	= nil
	self.SetupConfig	= nil
	self.TargettingMode	= STS_LESS_CAST_PHYSICAL
	
	self.__CustomDrawing	= { }
	self.__DrawingGroups	= { }
	self.__SpellCallbacks	= { }
	self.__VariableTracker	= { }
	
end

GodLib = __GodLib()

function LoadLibraries(libs)

	libs = libs and libs or { }
	
	local downloadCount	= 0
	local loaded		= true
	
	local requiredLibs	= {
		["SourceLib"]	= "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua",
		["VPrediction"]	= "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
		["SOW"]			= "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua"
	}
	
	for name, link in pairs(libs) do
		libs[name] = link
	end
	
	for name, link in pairs(requiredLibs) do
		if (FileExist(LIB_PATH..name)) then
			require(name)
		else
			DownloadFile(link, LIB_PATH..name, function()
				downloadCount = downloadCount - 1
				if (downloadCount == 0) then
					PrintMessage("Downloaded all required libraries! Please reload the script (double F9).")
				end
			end)
			loaded = false
			downloadCount = downloadCount + 1
		end
	end
	
	return loaded
end

if (not LoadLibraries()) then
	GodLib.Loaded = false
	return
end

---//==================================================\\---
--|| Script Setup                                       ||--
---\\==================================================//---

function __CheckForUpdate()

	if (GodLib.AutoUpdate) then
		SourceUpdater(GodLib.ScriptName, GodLib.ScriptVersion, "raw.githubusercontent.com", "/DevnScripts/BoL-Scripts/master/"..GodLib.ScriptName..".lua", LIB_PATH..GetCurrentEnv().FILE_NAME, "/DevnScripts/BoL-Scripts/master/Versions/"..GodLib.ScriptName..".version"):CheckUpdate()
	end

end

function StartScript()

	__CheckForUpdate()
	__SetupTracker()
	
	__SetupVariables()
	GodLib:SetupVariables()
	
	__SetupConfig()
	GodLib:SetupConfig()
	
	__SetupExtras()
	
	PrintMessage("Version "..GodLib.ScriptVersion.." loaded successfully!")

end

function __SetupTracker()
	if (GodLib.AllowTracker) then
		assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
		UpdateWeb(true, GodLib.ScriptName, GodLib.TrackerID, GodLib.TrackerHWID)
	end
end

function __SetupVariables()

	Spells			= { }
	Minions			= { }
	TargetSelector	= SimpleTS()
	Prediction		= VPrediction()
	Orbwalker		= SOW(Prediction)
	DamageCalc		= DamageLib()
	
	PriorityTable	= {
		["ADC"]		= { "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir", "Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo","Zed" },
		["APC"]		= { "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus", "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra" },
		["Support"]	= { "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum" },
		["Bruiser"]	= { "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy", "Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao" },
		["Tank"]	= { "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear", "Warwick", "Yorick", "Zac" }
	}
	
	PriorityOrder	= {
		[1]			= { 5, 5, 5, 5, 5 },
        [2]			= { 5, 5, 4, 4, 4 },
        [3]			= { 5, 5, 4, 3, 3 },
		[4]			= { 5, 4, 3, 2, 2 },
        [5]			= { 5, 4, 3, 2, 1 }
    }

end

function __SetupConfig()

	Config	= scriptConfig(GodLib.ScriptName.." (Version "..GodLib.ScriptVersion..")", "GodLib_"..GodLib.ScriptName)
	
	AddConfigSubMenu("Target Selector", "TargetSelector")
	TargetSelector:AddToMenu(Config.TargetSelector)
	
	AddConfigSubMenu("Orbwalker", "Orbwalker")
	Orbwalker:LoadToMenu(Config.Orbwalker)
	
	--[[
	AddConfigSubMenu("Drawing", "Drawing")
	Config.Drawing:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	AddEmptyRow(Config.Drawing)
	AddTitleRow(Config.Drawing, "Heroes")
	Config.Drawing:addParam("MyRange", "My Range", SCRIPT_PARAM_ONOFF, true)
	if (#GodLib.__DrawingGroups > 0) then
		for _, data in ipairs(GodLib.__DrawingGroups) do
			AddEmptyRow(Config.Drawing)
			AddTitleRow(Config.Drawing, data.Name)
			for i, drawing in ipairs(GodLib.__CustomDrawing[data.SafeName]) do
				Config.Drawing:addParam("CustomDrawing0"..data.SafeName.."0"..tostring(i), drawing.Name, SCRIPT_PARAM_ONOFF, drawing.Default)
			end
		end
	end
	--]]
	
	AddConfigSubMenu("Extra", "Extra")
	Config.Extra:addParam("VariableTracker", "Show Variable Tracker", SCRIPT_PARAM_ONOFF, false)
	
	--[[
	AddEmptyRow(Config)
	AddTitleRow(Config, "Auto-Level")
	Config:addParam("AutoLevel", "Enabled", SCRIPT_PARAM_ONOFF, false)
	Config["AutoLevel"] = false
	Config:addParam("AutoLevelRoute", "Skill Order", SCRIPT_PARAM_LIST, 1, { "R > Q > W > E", "R > W > Q > E", "Mixed" })
	--]]
	
end

function __SetupExtras()

	local heroCount = #GetEnemyHeroes()
	for i = 1, heroCount do
		local enemy = heroManager:getHero(i)
		if (table.contains(PriorityTable["ADC"], enemy.charName)) then
			STS_MENU[enemy.hash] = PriorityOrder[heroCount][1]
		elseif (table.contains(PriorityTable["APC"], enemy.charName))then
			STS_MENU[enemy.hash] = PriorityOrder[heroCount][2]
		elseif (table.contains(PriorityTable["Support"], enemy.charName)) then
			STS_MENU[enemy.hash] = PriorityOrder[heroCount][3]
		elseif (table.contains(PriorityTable["Bruiser"], enemy.charName)) then
			STS_MENU[enemy.hash] = PriorityOrder[heroCount][4]
		elseif (table.contains(PriorityTable["Tank"], enemy.charName)) then
			STS_MENU[enemy.hash] = PriorityOrder[heroCount][5]
		else
			PrintMessage("Champion "..enemy.charName.." could not be found in priority table. Please manually set the priority for this champion!")
		end
	end
	
	AddTickCallback(function() __OnTick() end)
	AddDrawCallback(function() __OnDraw() end)
	
end

---//==================================================\\---
--|| Script Setup Functions                             ||--
---\\==================================================//---

function SetupTargetSelector(mode)
	if (TargetSelector.menu) then
		TargetSelector.menu["mode"] = mode.id
	else
		GodLib.TargettingMode = mode
	end
end

function SetupSpell(id, name, range, radius, delay, speed, stype, collision, aoe)
	Spells[id] = __SpellData(id, name, range, radius, delay, speed, stype, collision, aoe)
end

function AddDrawing(group, name, location, range, default, condition)
	local safeGroupName = RemoveAllSpaces(group)
	if (not GodLib.__CustomDrawing[safeGroupName]) then
		table.insert(GodLib.__DrawingGroups, { Name = group, SafeName = safeGroupName })
		GodLib.__CustomDrawing[safeGroupName] = { }
	end
	table.insert(GodLib.__CustomDrawing[safeGroupName], { Name = name, Location = location, Range = range, Default = default, Condition = condition })
end

function AddSpellCallback(cb)
	table.insert(GodLib.__SpellCallbacks, cb)
end

function AddVariableTracker(text, func)
	table.insert(GodLib.__VariableTracker, { Text = text, Function = func, Value = "" })
end

function AddMinionManager(name, mtype, range, location, sort)
	Minions[name] = minionManager(mtype, range, location, sort)
end

function RegisterDamageSource(p1, p2, p3, p4, p5, p6, p7, p8, p9)
	DamageCalc:RegisterDamageSource(p1, p2, p3, p4, p5, p6, p7, p8, p9)
end

---//==================================================\\---
--|| BoL Callback Functions                             ||--
---\\==================================================//---

function __OnTick()

	-- Reset orbwalker mode.
	Orbwalker.mode = -1

	-- Update variable tracker.
	if (Config.Extra.VariableTracker) then
		for i, variable in ipairs(GodLib.__VariableTracker) do
			local object = variable.Function()
			if (type(object) == "table") then
				local buffer = "{ "
				local count = 1
				for key, value in pairs(object) do
					buffer = buffer..key.." = \""..value.."\""..(count == GetTableCount(object) and " }" or ", ")
					count = count + 1
				end
				GodLib.__VariableTracker[i].Value = buffer
			else
				GodLib.__VariableTracker[i].Value = tostring(object)
			end
		end
	end
	
	-- Update minions.
	for _, manager in pairs(Minions) do
		manager:update()
	end

end

function __OnDraw()

	-- Draw variable tracker.
	if (Config.Extra.VariableTracker) then
		local position = 100
		for _, variable in ipairs(GodLib.__VariableTracker) do
			DrawText(variable.Text.." = "..variable.Value, 15, 100, position, ARGB(255, 10, 190, 20))
			position = position + 15
		end
	end

	-- Check if hero is dead or drawing is disabled.
	if (myHero.dead or not Config.Drawing.Enabled) then return end
				
	if (Config.Drawing.MyRange) then
		--DrawCircle(myHero.x, myHero.y, myHero.z, myHero.Range, ARGB(255, 0, 255, 0))
	end
	
	for _, data in pairs(GodLib.__DrawingGroups) do
		for i, drawing in ipairs(GodLib.__CustomDrawing[data.SafeName]) do
			if (Config.Drawing["CustomDrawing0"..data.SafeName.."0"..tostring(i)]) then
				if ((type(drawing.Condition) == "function" and drawing:Condition()) or (type(drawing.Condition) == "boolean" and drawing.Condition)) then
					local point
					if (type(drawing.Location) == "function") then
						point = drawing:Location()
					else
						point = drawing.Location
					end
					--DrawCircle(point.x, point.y, point.z, drawing.Range, 0xF7FE2E)
				end
			end
		end
	end

end

---//==================================================\\---
--|| Misc Script Functions                              ||--
---\\==================================================//---

function AddConfigSubMenu(text, name)
	Config:addSubMenu("Settings: "..text, name)
end

function AddTitleRow(config, title)
	config:addParam("nil", "----- "..title.." -----", SCRIPT_PARAM_INFO, "")
end

function AddEmptyRow(config)
	config:addParam("nil", "", SCRIPT_PARAM_INFO, "")
end

function RemoveAllSpaces(str)
	return string.gsub(str, "%s+", "")
end

function GetTableCount(tbl)

	local count = 0
	
	for _, _ in pairs(tbl) do
		count = count + 1
	end
	
	return count
	
end

function Orbwalk(mode, target)
	
	if (not Config.Orbwalker.Enabled) then return end
	
	if (not mode and not target) then
		Orbwalker:OrbWalk()
	end
	
	if (mode == 0) then
	
		if (Config.Orbwalker.Attack == 2) then
			Orbwalker:OrbWalk(target)
		else
			Orbwalker:OrbWalk()
		end
		
		Orbwalker.mode = 0
		
	elseif (mode == 1) then
	
		Orbwalker:Farm(1)
		Orbwalker.mode = 1
		
	elseif (mode == 2) then
	
		Orbwalker:Farm(2)
		Orbwalker.mode = 2
		
	elseif (mode == 3) then
	
		Orbwalker:Farm(3)
		Orbwalker.mode = 3
		
	end
	
end

function CastSpells(spells, param1, param2)
	
	Orbwalker:DisableAttacks()
	
	for _, spell in ipairs(spells) do
		Spells[spell]:Cast(param1, param2)
	end
	
	Orbwalker:EnableAttacks()
	
end

---//==================================================\\---
--|| Custom Classes                                     ||--
---\\==================================================//---

class "__SpellData" --{
	
	function __SpellData:__init(id, name, range, radius, delay, speed, stype, collision, aoe)
	
		self.ID		= id
		self.Name	= name
		self.Range	= range
		self.Radius	= radius
		self.Delay	= delay
		self.Speed	= speed
		self.Key	= (id == _Q and "Q") or (id == _W and "W") or (id == _E and "E") or (id == _R and "R") or ""
		self.__Base	= Spell(id, range)
		
		if (stype) then
			self.__Base:SetSkillshot(Prediction, stype, radius, delay, speed, collision or false)
			self.__Base:SetAOE(aoe, false)
		end
		
	end
	
	function __SpellData:IsReady()
		return self.__Base:IsReady()
	end
	
	function __SpellData:InRange(target)
		return self.__Base:InRange(target)
	end
	
	function __SpellData:Cast(param1, param2)
	
		self.__Base:Cast(param1, param2)
		
		for _, callback in ipairs(GodLib.__SpellCallbacks) do
			callback(self.ID, param1, param2)
		end
		
	end
	
--}

---//==================================================\\---
--|| Custom Functions                                   ||--
---\\==================================================//---

function STS_GET_PRIORITY(target)

    if (not STS_MENU or not STS_MENU[target.hash]) then
        return 1
    else
        return STS_MENU[target.hash]
    end
	
end

function SimpleTS:AddToMenu(menu)

	menu:addParam("nil", "----- Priorities -----", SCRIPT_PARAM_INFO, "")
	
	local reachedMin = false
	for _, target in ipairs(GetEnemyHeroes()) do
		reachedMin = true
		menu:addParam(target.hash, target.charName, SCRIPT_PARAM_SLICE, 1, 1, 5)
	end
	
	if (not reachedMin) then
		menu:addParam("nil", "No enemy champions found.", SCRIPT_PARAM_INFO, "")
	else
		menu:addParam("nil", "Note: 5 is highest priority.", SCRIPT_PARAM_INFO, "")
	end
	
	menu:addParam("nil", "", SCRIPT_PARAM_INFO, "")
	menu:addParam("nil", "----- Settings -----", SCRIPT_PARAM_INFO, "")
	
	local modelist = { }
	for _, mode in ipairs(STS_AVAILABLE_MODES) do
		table.insert(modelist, mode.name)
	end
	
	menu:addParam("mode", "Targetting Mode", SCRIPT_PARAM_LIST, 1, modelist)
	menu["mode"] = GodLib.TargettingMode.id
	
	menu:addParam("Selected", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
	
	STS_MENU = menu
	self.menu = menu
	
end

function SOW:LoadToMenu(menu)

	self.STS = TargetSelector
	self.STS.VP = Prediction
	
	menu:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	menu:addParam("Attack", "Enable Attacks", SCRIPT_PARAM_LIST, 2, { "Only Farming", "Farming & Fighting" })
	menu:addParam("Mode", "Orbwalking Mode", SCRIPT_PARAM_LIST, 1, { "To Mouse", "To Target" })
	menu:addParam("nil", "", SCRIPT_PARAM_INFO, "")
	menu:addParam("nil", "----- Settings -----", SCRIPT_PARAM_INFO, "")
	menu:addParam("FarmDelay", "Farm Delay", SCRIPT_PARAM_SLICE, -150, 0, 150)
	menu:addParam("ExtraWindUpTime", "Extra WindUp Time", SCRIPT_PARAM_SLICE, -150, 0, 150)
	
	menu.FarmDelay = GetSave("SOW").FarmDelay
	menu.ExtraWindUpTime = GetSave("SOW").ExtraWindUpTime
	
	AddTickCallback(function()
		GetSave("SOW").FarmDelay = self.Menu.FarmDelay
		GetSave("SOW").ExtraWindUpTime = self.Menu.ExtraWindUpTime
	end)
	
	self.Menu = menu
	
end
