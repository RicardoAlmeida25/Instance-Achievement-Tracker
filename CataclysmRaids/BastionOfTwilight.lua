--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
local L = core.L

------------------------------------------------------
---- Bastion of Twilight Bosses
------------------------------------------------------
core._671 = {}
core._671.Events = CreateFrame("Frame")

------------------------------------------------------
---- Halfus Wyrmbreaker
------------------------------------------------------
local timerStarted = false
local drakesKilled = 0
local whelpsKilled = 0

------------------------------------------------------
---- Valiona And Theralion
------------------------------------------------------
local TwilightFiendsKilled = 0

function core._671:HalfusWyrmbreaker()
	--Defeat Halfus Wyrmbreaker after defeating two drakes within 10 seconds of each other. The Emerald Whelp pack counts as one drake for this purpose.
	--Nether Scion: 44645
	--Slate Dragon: 44652
	--Storm Rider: 44650
	--Time Warden: 44797
	--Orphaned Emerald Whelp: 44641 

	if core.achievementsCompleted[1] == false then
		--Dragons
		if core.type == "UNIT_DIED" and (core.destID == "44650" or core.destID == "44797" or core.destID == "44645" or core.destID == "44652") then
			drakesKilled = drakesKilled + 1
			if timerStarted == false then
				timerStarted = true
				core:sendMessage(L["Shared_Timer10"])
				C_Timer.After(10, function() 
					if drakesKilled >= 2 then
						core:getAchievementSuccess()
					else
						core:getAchievementFailed()
						drakesKilled = 0
						timerStarted = false
					end
				end)
			else
				if drakesKilled >= 2 then
					core:getAchievementSuccess()
				end
			end
		end

		--Whelps
		if core.type == "UNIT_DIED" and core.destID == "44641" then
			whelpsKilled = whelpsKilled + 1
			if whelpsKilled == 8 then
				drakesKilled = drakesKilled + 1
				if timerStarted == false then
					timerStarted = true
					core:sendMessage(L["Shared_Timer10"])
					C_Timer.After(10, function() 
						if drakesKilled >= 2 then
							core:getAchievementSuccess()
						else
							core:getAchievementFailed()
							drakesKilled = 0
							timerStarted = false
						end
					end)
				else
					if drakesKilled >= 2 then
						core:getAchievementSuccess()
					end
				end
			end
		end
	end
end

function core._671_ValionaAndTheralion()
	if core.type == "UNIT_DIED" and core.destID == "49864" then
		TwilightFiendsKilled = TwilightFiendsKilled + 1
		core:sendMessage("(" .. TwilightFiendsKilled .. " /6) Twilight Fiends Killed")
	end

	if TwilightFiendsKilled == 6 then
		core:getAchievementSuccess()
	end
end

function core._671:InstanceCleanup()
    core._671.Events:UnregisterEvent("UNIT_POWER_UPDATE")
end

function core._671:InitialSetup()
    core._671.Events:RegisterEvent("UNIT_POWER_UPDATE")
end

core._671.Events:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, event, ...)
end)

function core._671.Events:UNIT_POWER_UPDATE(self, unit, powerType)
	if core.Instances[core.expansion][core.instanceType][core.instance]["boss4"].enabled == true then
		if powerType == "ALTERNATE" then
			if UnitPower(unit, ALTERNATE_POWER_INDEX) > 30 then
				core:getAchievementFailedWithMessageAfter("by (" .. UnitName(unit) .. ")")
			end
		end
    end
end

function core._671:ClearVariables()
	------------------------------------------------------
	---- Halfus Wyrmbreaker
	------------------------------------------------------
	timerStarted = false
	drakesKilled = 0
	whelpsKilled = 0

	------------------------------------------------------
	---- Valiona And Theralion
	------------------------------------------------------
	TwilightFiendsKilled = 0
end