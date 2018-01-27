--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

------------------------------------------------------
---- Halls of Stone Bosses
------------------------------------------------------
core.HallsOfStone = {}

------------------------------------------------------
---- Maiden of Grief
------------------------------------------------------
local timer
local timerStarted = false

------------------------------------------------------
---- Sjonnir The Ironshaper
------------------------------------------------------
local ironSludgeKilled = 0

function core.HallsOfStone:MaidenOfGrief()
    if timerStarted == false then
        timerStarted = true
        timer = C_Timer.NewTimer(61, function() 
            core:getAchievementFailed()
        end)
    end
end

function core.HallsOfStone:TribunalOfAges()
    core:getAchievementToTrack()

    if core.type == "SWING_DAMAGE" or core.type == "SPELL_DAMAGE" and core.destID == "28070" then
        core:getAchievementFailed()
    end
end

function core.HallsOfStone:SjonnirTheIronshaper()
    if core.type == "UNIT_DIED" and core.destID == "28165" and ironSludgeKilled < 5 then
        ironSludgeKilled = ironSludgeKilled + 1
        core:sendMessage(core:getAchievement() .. " Iron Sludge Killed (" .. ironSludgeKilled .. "/5)")
    end

    if ironSludgeKilled >= 5 then
        core:getAchievementSuccess()
    end
end

function core.HallsOfStone:ClearVariables()
    ------------------------------------------------------
    ---- Maiden of Grief
    ------------------------------------------------------
    timerStarted = false
    if timer ~= nil then
        timer:Cancel()
    end

    ------------------------------------------------------
    ---- Sjonnir The Ironshaper
    ------------------------------------------------------
    ironSludgeKilled = 0
end