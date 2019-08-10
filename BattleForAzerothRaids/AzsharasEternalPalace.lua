--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...
local L = core.L

------------------------------------------------------
---- Azshara's Eternal Palace
------------------------------------------------------
core._2164 = {}
core._2164.Events = CreateFrame("Frame")

------------------------------------------------------
---- Abyssal Commander Sivara
------------------------------------------------------
local garvalTheVanquisherFound = false
local tideshaperKorvessFound = false
local gorjeshTheSmasherFound = false

------------------------------------------------------
---- Blackwater Behemoth
------------------------------------------------------
local collectSampleUID = {}
local samplesCollected = 0
local initialScan = false
local playersWithTracking = 0

------------------------------------------------------
---- Radiance of Azshara
------------------------------------------------------
local playersCompletedAchievement = 0
local playersWithFunRun = {}

------------------------------------------------------
---- The Queen's Court
------------------------------------------------------
local playersWithQueenFavour = {}
local salutePlayers = {}
local curtseyPlayers = {}
local grovelPlayers = {}
local kneelPlayers = {}
local applausePlayers = {}
local queenInititalSetup = false
local saluteAnnounce = false
local curtseyAnnounce = false
local grovelAnnounce = false
local kneelAnnounce = false
local applauseAnnounce = false

------------------------------------------------------
---- Orgozoa
------------------------------------------------------
local eggFound = false
local eggFoundPlayer = nil

function core._2164:AbyssalCommanderSivara()
	--Defeat Abyssal Commander Sivara in The Eternal Palace while all three of her lieutenants are alive and engaged in the fight on Normal difficulty or higher.
	
	if core.type == "SWING_DAMAGE" and core.sourceID == "155277" then
		gorjeshTheSmasherFound = true
	end

	if core.type == "SWING_DAMAGE" and core.sourceID == "155275" then
		tideshaperKorvessFound = true
	end

	if core.type == "SWING_DAMAGE" and core.sourceID == "155273" then
		garvalTheVanquisherFound = true
	end

	if gorjeshTheSmasherFound == true and tideshaperKorvessFound == true and garvalTheVanquisherFound == true then
		core:getAchievementSuccess()
	end

    --Blizzard tracking gone red so fail achievement
	if core:getBlizzardTrackingStatus(13684) == false then
		core:getAchievementFailed()
	end
end

function core._2164:BlackwaterBehemoth()
	--Defeat the Blackwater Behemoth in The Eternal Palace after collecting 50 samples of sea life from within the Darkest Depths on Normal Difficulty of higher.

	InfoFrame_SetHeaderCounter(L["Shared_TrackingStatus"],playersWithTracking,core.groupSize)
	InfoFrame_UpdatePlayersOnInfoFrame(false)
	
	--Request which players are currently tracking this achievement
	--Sync Message, Major Version, Minor Version, update Infoframe
	if initialScan == false then
		core:sendMessage(L["Shared_PlayersRunningAddon2"],true)
		core.IATInfoFrame:SetText1(L["AzsharasEternalPalace_SamplesCollected"] .. " " .. samplesCollected,"GameFontHighlightLarge")
		core.IATInfoFrame:SetSubHeading2(L["Shared_Notes"])
		core.IATInfoFrame:SetText2(L["Shared_PlayersRunningAddon2"],200)
		initialScan = true
		--Set all players to fail initially as we have not determined yet if they have the addon installed
		for player,status in ipairs(core.InfoFrame_PlayersTable) do
			InfoFrame_SetPlayerFailed(player)
		end
		C_Timer.After(3, function()
			--Ask all other addons in the group to see if they are running the addon and tracking this achievement
			C_ChatInfo.SendAddonMessage("Whizzey", "reqIAT,2,38,true", "RAID")		

			--Wait 1 second for a response from other addon in the group
			C_Timer.After(2, function() 
				local playersStr = L["Shared_TrackingAchievementFor"] .. ": "
				for player, status in pairs(core.InfoFrame_PlayersTable) do
					--For all players that have the addon running, increment the counter by 1
					core:sendDebugMessage(status) 
					if status == 2 then
						playersStr = playersStr .. player .. ", "
						playersWithTracking = playersWithTracking + 1
					end
				end
				--core:sendMessageSafe(playersStr,true)
			end)
		end)
	end	

	if core.type == "SPELL_CAST_SUCCESS" and core.spellId == 302005 and collectSampleUID[core.spawn_uid_dest] == nil then
		collectSampleUID[core.spawn_uid_dest] = core.spawn_uid_dest
		samplesCollected = samplesCollected + 1
		core:sendMessage(core:getAchievement() .. samplesCollected .. " " .. L["AzsharasEternalPalace_SamplesCollected"])
		
		--Send message to other addon users
		local messageStr = core.type .. "," .. core.spellId .. "," .. core.spawn_uid_dest
		C_ChatInfo.SendAddonMessage("Whizzey", "syncMessage" .. "-" .. messageStr, "RAID")
	end

	--Check for message in the sync queue
	for k,message in ipairs(core.syncMessageQueue) do
		if message ~= nil then
			core:sendDebugMessage("Found Message:" .. message)
			local spellType, spellid, spawnUIDDest = strsplit(",", message)
			if spellType == "SPELL_CAST_SUCCESS" and spellid == "302005" and collectSampleUID[spawnUIDDest] == nil then
				--Recieved sample from another addon user. Increment counter
				collectSampleUID[spawnUIDDest] = spawnUIDDest
				samplesCollected = samplesCollected + 1
				core:sendMessage(core:getAchievement() .. samplesCollected .. " " .. L["AzsharasEternalPalace_SamplesCollected"])
			end
			core.syncMessageQueue[k] = nil
		end
	end

	if samplesCollected >= 50 then
		core:getAchievementSuccess()
	end
end

function core._2164:LadyAshvane()
	--Defeat Lady Ashvane in The Eternal Palace after having each cast of Arcing Azerite pass through her on Normal difficulty or higher.

	--Blizzard tracking gone red so fail achievement
	if core:getBlizzardTrackingStatus(13629) == false then
		core:getAchievementFailed()
	end
end

function core._2164:Zaqul() 
    --Defeat Za'qul in the Eternal Palace after killing ten Twinklehoof Bovine on Normal difficulty or higher.

    --Blizzard tracking gone white so complete achievement
	if core:getBlizzardTrackingStatus(13716, 1) == true then
		core:getAchievementSuccess()
	end
end

function core._2164:QueenAzshara()
	--Defeat Queen Azshara in The Eternal Palace with one player still alive who is currently affected by Essence of Azeroth on Normal difficulty or higher.

	if core.type == "UNIT_DIED" and core.currentDest == "Player" then
		--Loop through all players in the group and check if just 1 player is alive
		local playersAlive = 0
		local lastPlayerAlive = nil
        for i = 1, core.groupSize do
            local unit = nil
            if core.chatType == "PARTY" then
                if i < core.groupSize then
                    unit = "party" .. i
                else
                    unit = "player"
                end
            elseif core.chatType == "RAID" then
                unit = "raid" .. i
            elseif core.chatType == "SAY" then
                unit = "player"
            end
        
			if UnitIsDead(unit) == false then
				playersAlive = playersAlive + 1
				local name = UnitName(unit)
				lastPlayerAlive = name
			end
		end
		
		if playersAlive == 1 then
			for i=1,40 do
                local _, _, _, _, _, _, _, _, _, spellId = UnitDebuff(unit, i)
				if spellId == 300866 then
					core:getAchievementSuccess()
				end
			end
		end
	end
end

function core._2164:RadianceOfAzshara()
	--Defeat Radiance of Azshara in The Eternal Palace after running 6 consecutive complete laps around her arena without falling into the water on Normal difficulty on higher.

	InfoFrame_UpdatePlayersOnInfoFramePersonal()
	InfoFrame_SetHeaderCounter(L["Shared_PlayersWhoNeedAchievement"],playersCompletedAchievement,#core.currentBosses[1].players)
	
	--Achievement Completed
	if playersCompletedAchievement == #core.currentBosses[1].players then
		core:getAchievementSuccess()
		core.achievementsFailed[1] = false
	end

	--Achievement Completed but has since failed
	if playersCompletedAchievement ~= #core.currentBosses[1].players and core.achievementsCompleted[1] == true then
		core:getAchievementFailed()
		core.achievementsCompleted[1] = false 
	end
end

function core._2164:TheQueensCourt()
	--Perform various emotes to earn Queen Azshara's Favor in the Eternal Palace, then defeat The Queen's Court on Normal Difficulty or higher.

	--Announce when players should do each of the emotes
	--Form Ranks - Salute
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 303188 and saluteAnnounce == false then
		saluteAnnounce = true
		core:sendMessage(GetSpellLink(303188) .. " /" .. L["AzsharasEternalPalace_Salute"] .. " " .. L["Shared_NOW"], true)
		C_Timer.After(20, function() 
			saluteAnnounce = false
		end)
	end
	--Repeat Performance - Curtsey
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 304409 and curtseyAnnounce == false then
		curtseyAnnounce = true
		core:sendMessage(GetSpellLink(304409) .. " /" .. L["AzsharasEternalPalace_Curtsey"] .. " " .. L["Shared_NOW"], true)
		C_Timer.After(20, function() 
			curtseyAnnounce = false
		end)
	end
	--Deferred Sentance - Grovel
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 304128 and grovelAnnounce == false then
		grovelAnnounce = true
		core:sendMessage(GetSpellLink(304128) .. " /" .. L["AzsharasEternalPalace_Grovel"] .. " " .. L["Shared_NOW"], true)
		C_Timer.After(20, function() 
			grovelAnnounce = false
		end)
	end
	--Obey or Suffer - Kneel
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 297585 and kneelAnnounce == false then
		kneelAnnounce = true
		core:sendMessage(GetSpellLink(297585) .. " /" .. L["AzsharasEternalPalace_Kneel"] .. " " .. L["Shared_NOW"], true)
		C_Timer.After(20, function() 
			kneelAnnounce = false
		end)
	end
	--Stand Alone - Applause
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 297656 and applauseAnnounce == false then
		applauseAnnounce = true
		core:sendMessage(GetSpellLink(297656) .. " /" .. L["AzsharasEternalPalace_Applause"] .. " " .. L["Shared_NOW"], true)
		C_Timer.After(20, function() 
			applauseAnnounce = false
		end)
	end

	InfoFrame_UpdatePlayersOnInfoFrameWithAdditionalInfoPersonal()
	InfoFrame_SetHeaderCounter(L["Shared_PlayersWhoNeedAchievement"],playersCompletedAchievement,#core.currentBosses[1].players)

	--Initital Setup
	if queenInititalSetup == false then
		queenInititalSetup = true
		--Set emotes for all players
		local messageStr = ""
		local colourWhite = "|cffFFFFFF"
		for player, status in pairs(core.InfoFrame_PlayersTable) do
			InfoFrame_SetPlayerNeutralWithMessage(player,L["AzsharasEternalPalace_Salute"] .. ", " .. L["AzsharasEternalPalace_Curtsey"] .. ", " ..  L["AzsharasEternalPalace_Applause"] .. ", " ..  L["AzsharasEternalPalace_Grovel"] .. ", " .. L["AzsharasEternalPalace_Kneel"])
		end
	end
	
	--When players gains Queen Favour debuff mark player as complete
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 302029 then
		InfoFrame_SetPlayerCompleteWithMessage(core.destName, "")
		core:getAchievementSuccessPersonalWithName(1, core.destName, false)
		playersCompletedAchievement = playersCompletedAchievement + 1

		--Reset failed variable
		core.playersFailedPersonal[core:getNameOnly(core.destName)] = nil
	end

	--If player looses Queen Favour Debuff
	if core.type == "SPELL_AURA_REMOVED" and core.spellId == 302029 and core.inCombat == true then
		local name = core.destName
		InfoFrame_SetPlayerFailedWithMessage(name, L["AzsharasEternalPalace_SaluteShort"] .. ", " .. L["AzsharasEternalPalace_CurtseyShort"] .. ", " .. L["AzsharasEternalPalace_ApplauseShort"] .. ", " .. L["AzsharasEternalPalace_GrovelShort"] .. ", " .. L["AzsharasEternalPalace_KneelShort"])

		--Reset tables
		kneelPlayers[core:getNameOnly(name)] = nil
		grovelPlayers[core:getNameOnly(name)] = nil
		applausePlayers[core:getNameOnly(name)] = nil
		salutePlayers[core:getNameOnly(name)] = nil
		curtseyPlayers[core:getNameOnly(name)] = nil

		--Announce fail and reset complete
		core:getAchievementFailedPersonalWithName(1, name, false)
		playersCompletedAchievement = playersCompletedAchievement - 1
		core.playersSuccessPersonal[core:getNameOnly(name)] = nil
	end

	--If player dies reset counters
	if core.type == "UNIT_DIED" and UnitIsPlayer(core.destName) then
		--Reset tables
		kneelPlayers[core:getNameOnly(core.destName)] = nil
		grovelPlayers[core:getNameOnly(core.destName)] = nil
		applausePlayers[core:getNameOnly(core.destName)] = nil
		salutePlayers[core:getNameOnly(core.destName)] = nil
		curtseyPlayers[core:getNameOnly(core.destName)] = nil

		InfoFrame_SetPlayerNeutralWithMessage(core.destName, L["AzsharasEternalPalace_SaluteShort"] .. ", " .. L["AzsharasEternalPalace_CurtseyShort"] .. ", " .. L["AzsharasEternalPalace_ApplauseShort"] .. ", " .. L["AzsharasEternalPalace_GrovelShort"] .. ", " .. L["AzsharasEternalPalace_KneelShort"])
	end

	--Check for message in the sync queue
	for k,message in ipairs(core.syncMessageQueue) do
		if message ~= nil then
			core:sendDebugMessage("Found Message:" .. message)
			local sender, emoteStr = strsplit(",", message)
			if sender ~= nil and emoteStr ~= nil and core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
				InfoFrame_SetPlayerNeutralWithMessage(sender,emoteStr)
			end
			core.syncMessageQueue[k] = nil
		end
	end

	--Achievement Completed
	if playersCompletedAchievement == #core.currentBosses[1].players then
		core:getAchievementSuccess()
		core.achievementsFailed[1] = false
	end

	--Achievement Completed but has since failed
	if playersCompletedAchievement ~= #core.currentBosses[1].players and core.achievementsCompleted[1] == true then
		core:getAchievementFailed()
		core.achievementsCompleted[1] = false 
	end
end

function core._2164:ClearVariables()
	------------------------------------------------------
	---- Radiance of Azshara
	------------------------------------------------------
	playersCompletedAchievement = 0
	playersWithFunRun = {}
	
	------------------------------------------------------
	---- Blackwater Behemoth
	------------------------------------------------------
	collectSampleUID = {}
	samplesCollected = 0
	initialScan = false
	playersWithTracking = 0

	------------------------------------------------------
	---- The Queen's Court
	------------------------------------------------------
	playersWithQueenFavour = {}
	salutePlayers = {}
	curtseyPlayers = {}
	grovelPlayers = {}
	kneelPlayers = {}
	applausePlayers = {}
	queenInititalSetup = false
	saluteAnnounce = false
	curtseyAnnounce = false
	grovelAnnounce = false
	kneelAnnounce = false
	applauseAnnounce = false

	------------------------------------------------------
	---- Orgozoa
	------------------------------------------------------
	eggFound = false
	eggFoundPlayer = nil
end

function core._2164:InstanceCleanup()
    core._2164.Events:UnregisterEvent("UNIT_AURA")
    core._2164.Events:UnregisterEvent("CHAT_MSG_TEXT_EMOTE")
end

core._2164.Events:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, event, ...)
end)

function core._2164:InitialSetup()
    core._2164.Events:RegisterEvent("UNIT_AURA")
    core._2164.Events:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
end

function core._2164.Events:UNIT_AURA(self, unitID)
	if next(core.currentBosses) ~= nil then
		if core.currentBosses[1].encounterID == 2305 then
			--Fun Run
			local foundFunRunDebuff = false
			local name, realm = UnitName(unitID)
			for i=1,40 do
				local _, _, count2, _, _, _, _, _, _, spellId = UnitDebuff(unitID, i)
				if spellId == 305173 then
					foundFunRunDebuff = true
					if name ~= nil then
						if playersWithFunRun[name] == nil then
							playersWithFunRun[name] = name
							InfoFrame_SetPlayerComplete(name)
							playersCompletedAchievement = playersCompletedAchievement + 1
							core:sendMessage(core:getAchievement() .. " " .. name .. " " .. L["Shared_HasCompleted"] .. " " .. GetSpellLink(305173) .. " " .. L["Core_Counter"] .. " (" .. playersCompletedAchievement .. "/" .. #core.currentBosses[1].players .. ")",true)
						end
					end
				end
			end

			--Check if player has completed the achievement already and if so do they still have the debuff or not
			if core.InfoFrame_PlayersTable[name] ~= nil and foundFunRunDebuff == false then
				if core.InfoFrame_PlayersTable[name] == 2 then
					if playersWithFunRun[name] ~= nil then
						--Player has lost debuff. Update InfoFrame
						InfoFrame_SetPlayerFailed(name)
						playersWithFunRun[name] = nil
						playersCompletedAchievement = playersCompletedAchievement - 1
						core:sendMessage(core:getAchievement() .. " " .. name .. " " .. L["Shared_HasFailed"] .. " " .. GetSpellLink(305173) .. " " .. L["Core_Counter"] .. " (" .. playersCompletedAchievement .. "/" .. #core.currentBosses[1].players .. ")",true)
					end
				end
			end
		elseif core.currentBosses[1].encounterID == 2303 then
			--A Smack of Jellyfish
			--Incubation Fluid: 298306
			--Incubating Zoatroid: 305322
			local incubationFluidFound = false
			local incubatingZoatroidFound = false
			local incubationFluidPlayer = ""
			local incubatingZoatroidPlayer = ""
			local name, realm = UnitName(unitID)
			for i=1,40 do
				local _, _, count2, _, _, _, _, _, _, spellId = UnitDebuff(unitID, i)
				if spellId == 298306 then
					--Incubation Fluid
					if name ~= nil then
						incubationFluidFound = true
						incubationFluidPlayer = name

						--Check requirements have been met
						if incubationFluidFound == true and incubatingZoatroidFound == true then
							if incubationFluidPlayer == incubatingZoatroidPlayer then
								core:getAchievementSuccess()
							end
						end
					end
				elseif spellId == 305322 then
					--Incubating Zoatroid
					if name ~= nil then
						incubatingZoatroidFound = true
						incubatingZoatroidPlayer = name
						eggFound = true
						eggFoundPlayer = name

						--Check requirements have been met
						if incubationFluidFound == true and incubatingZoatroidFound == true then
							if incubationFluidPlayer == incubatingZoatroidPlayer then
								core:getAchievementSuccess()
							end
						end
					end
				end
			end

			--Check if player has dropped the egg or not
			if eggFound == true and incubatingZoatroidFound == false and eggFoundPlayer == name and core.inCombat and core:getHealthPercent("boss1") > 2 then
				core:getAchievementFailed()
			end
		end
	end	
end

function core._2164.Events:CHAT_MSG_TEXT_EMOTE(self, message, sender, lineID, senderGUID)
	if next(core.currentBosses) ~= nil then
		if core.currentBosses[1].encounterID == 2311 then
			--Form Ranks - Salute
			--Repeat Performance - Curtsey
			--Deferred Sentance - Grovel
			--Obey or Suffer - Kneel
			--Stand Alone - Applause

			sender = core:getNameOnly(sender)

			if UnitIsPlayer(sender) then
				if string.match(message, format(L["AzsharasEternalPalace_SaluteSelf"], getNPCName(152910))) or string.match(message, L["AzsharasEternalPalace_CurtseySelf"]) or string.match(message, L["AzsharasEternalPalace_GrovelSelf"]) or string.match(message, L["AzsharasEternalPalace_KneelSelf"]) or string.match(message, L["AzsharasEternalPalace_ApplauseSelf"]) or string.match(message, L["AzsharasEternalPalace_SaluteSelf"]) or string.match(message, L["AzsharasEternalPalace_CurtseyOther"]) or string.match(message, L["AzsharasEternalPalace_GrovelOther"]) or string.match(message, L["AzsharasEternalPalace_KneelOther"]) or string.match(message, L["AzsharasEternalPalace_ApplauseOther"]) then
					core:sendDebugMessage("Detected compatible emote")
					if string.match(message, getNPCName(152910)) and core.playersSuccessPersonal[sender] == nil then
						core:sendDebugMessage("Detected Queen Azshara")
						--They have praised the correct npc. Check if they have the correct buff
						local updateInfoFrameForPlayer = false
						for i=1,40 do
							local _, _, _, _, _, _, _, _, _, spellId = UnitDebuff(sender, i)
							
							--Form Ranks (In Formation) 303188
							if spellId == 303188 and salutePlayers[sender] == nil then
								--Check if the player actually needs the achievement since it is personal
								core:sendDebugMessage("Found player who Salute Queen with In Formation")
								core:sendDebugMessage(sender)
								core:sendDebugMessage(spellId)
								--Add player to appropriate table and update InfoFrame
								if core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
									core:sendDebugMessage("Updating personal achievement on InfoFrame for: " .. sender)
									updateInfoFrameForPlayer = true
								end
								salutePlayers[sender] = true
							end

							--Repeat Performance 304409
							if spellId == 304409 and curtseyPlayers[sender] == nil then
								--Check if the player actually needs the achievement since it is personal
								core:sendDebugMessage("Found player who Curtsey Queen with Repeat Perforamance")
								core:sendDebugMessage(sender)
								core:sendDebugMessage(spellId)
								--Add player to appropriate table and update InfoFrame
								if core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
									core:sendDebugMessage("Updating personal achievement on InfoFrame for: " .. sender)
									updateInfoFrameForPlayer = true
								end
								curtseyPlayers[sender] = true
							end

							--Deferred Sentence 304128
							if spellId == 304128 and grovelPlayers[sender] == nil then
								--Check if the player actually needs the achievement since it is personal
								core:sendDebugMessage("Found player who grovel Queen with Deferred Sentence")
								core:sendDebugMessage(sender)
								core:sendDebugMessage(spellId)
								--Add player to appropriate table and update InfoFrame
								if core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
									core:sendDebugMessage("Updating personal achievement on InfoFrame for: " .. sender)
									updateInfoFrameForPlayer = true
								end
								grovelPlayers[sender] = true
							end

							--Obey or Suffer 297585
							if spellId == 297585 and kneelPlayers[sender] == nil then
								--Check if the player actually needs the achievement since it is personal
								core:sendDebugMessage("Found player who kneel Queen with Obey or Suffer")
								core:sendDebugMessage(sender)
								core:sendDebugMessage(spellId)
								--Add player to appropriate table and update InfoFrame
								if core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
									core:sendDebugMessage("Updating personal achievement on InfoFrame for: " .. sender)
									updateInfoFrameForPlayer = true
								end
								kneelPlayers[sender] = true
							end

							--Stand Alone 297656
							if spellId == 297656 and applausePlayers[sender] == nil then
								--Check if the player actually needs the achievement since it is personal
								core:sendDebugMessage("Found player who applause Queen with Stand Alone")
								core:sendDebugMessage(sender)
								core:sendDebugMessage(spellId)
								--Add player to appropriate table and update InfoFrame
								if core.playersSuccessPersonal[sender] == nil and core:has_value(core.currentBosses[1].players, sender) then
									core:sendDebugMessage("Updating personal achievement on InfoFrame for: " .. sender)
									updateInfoFrameForPlayer = true
								end
								applausePlayers[sender] = true
							end
						end

						if updateInfoFrameForPlayer == true then		
							--Update InfoFrame to show missing emotes
							local emoteStr = ""
							if salutePlayers[sender] ~= true then
								emoteStr = emoteStr ..  L["AzsharasEternalPalace_SaluteShort"] .. ", "
							end
							if curtseyPlayers[sender] ~= true then
								emoteStr = emoteStr ..  L["AzsharasEternalPalace_CurtseyShort"] .. ", "
							end
							if applausePlayers[sender] ~= true then
								emoteStr = emoteStr ..  L["AzsharasEternalPalace_ApplauseShort"] .. ", "
							end
							if grovelPlayers[sender] ~= true then
								emoteStr = emoteStr ..  L["AzsharasEternalPalace_GrovelShort"] .. ", "
							end
							if kneelPlayers[sender] ~= true then
								emoteStr = emoteStr ..  L["AzsharasEternalPalace_KneelShort"]
							end
							InfoFrame_SetPlayerNeutralWithMessage(sender,emoteStr)

							--Send message to other addon users
							local messageStr = sender .. "," .. emoteStr
							C_ChatInfo.SendAddonMessage("Whizzey", "syncMessage" .. "-" .. messageStr, "RAID")
						end
					end
				end
			end
		end
	end
end

