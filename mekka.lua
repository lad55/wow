aura_env = {"config", "healers", "affPlayers", "display", "me"}

function UnitName(player)
    return "Luidz", "Azralon"
end

aura_env.config = {
    ["option1"] = "Musaxinha",
    ["option2"] = "Niitrana",
    ["option3"] = "Jackroberto",
    ["option4"] = "Pedrilho",
    ["option5"] = "Luidz",
}

raid = {"Rademonaka", "Ohanassauro", "Kaohunt", "Pheiona", "Bonnie", "Doxie", "Quietstep", "Scav", "Caernn", "Hëllz", "Wakurp", "Zandal", "Mulff", "Jackroberto", "Luidz", "Pedrilho", "Musaxinha", "Niitrana"}

markers = {
    [1] = "",
    [2] = "",
    [3] = "",
    [4] = "",
    [5] = "",
    [6] = "",
    [7] = "",
    [8] = "", 
}

function SetRaidTarget(player, mark)
    if mark == 0 then 
        for k, v in ipairs(markers) do
            if v == player then
              markers[k] = ""
              print(player .. " foi desmarcado.")
            end
        end
    else
        markers[mark] = player
        print(player .. " foi marcado com " .. mark)
    end
end

alreadyRolled = {}

function isIn(t, val)
    for k, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end

function rollUnique()
    local flag = true
    while flag do
        r = math.random(1, 18)
        if not isIn(alreadyRolled, r) then
            table.insert(alreadyRolled, r)
            return r
        end
    end
end

function resetRolls()
    math.randomseed(os.time())
    alreadyRolled = {}
end
--[[
---------------
--           --
--   onInit  --
--           --
--------------- 
]]--

aura_env.healers = {
    {aura_env.config["option1"], true},
    {aura_env.config["option2"], true},
    {aura_env.config["option3"], true},
    {aura_env.config["option4"], true},
    {aura_env.config["option5"], true},
}

aura_env.affPlayers = {}

aura_env.me, _ = UnitName("player")

function startVars()
    for _, v in pairs(aura_env.healers) do
        v[2] = true
    end
    aura_env.affPlayers = {}
end

function changeHealerState(healer, newState)
    for k, v in pairs(aura_env.healers) do
        if v[1] == healer then
            v[2] = newState
            return true
        end
    end
    return false
end

function playerDispelDecision()
    c = 0
    
    for k, v in pairs(aura_env.healers) do
        if v[2] then
            if v[1] == aura_env.me then
                print("índice da tabela: " .. c%#aura_env.affPlayers + 1)
                return "DISPEL " .. aura_env.affPlayers[c%#aura_env.affPlayers + 1]
            end
            c = c + 1
        end    
    end
end

--[[
---------------
--           --
--  Trigger  --
--           --
--------------- 
]]--

t = function(event, ...)
    if event == "ENCOUNTER_START" then
        control = 0 -- control variable to trigger the WA once the WG is cast, 3 players are afflicted by Discombobulation and 3 players are thrown up
        counter = 0
        flagged = false
        startVars()
    elseif event == "ENCOUNTER_END" then
        control = 0
        counter = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local msg = select(2, ...)
        local spellID = select(12, ...)
        local sourceName = select(5, ...)
        local destName = select(9, ...)
        flagged = false or flagged
        control = control or 0
        counter = counter or 0
        if msg == "SPELL_CAST_SUCCESS" and spellID == 287952 then --check for Wormhole Generator
            startVars()
            control = 0
            counter = 0
            flagged = false
            
        elseif msg == "SPELL_AURA_APPLIED" then
            if spellID == 287167 then --check for Discombobulation
                counter = counter + 1
                changeHealerState(destName, false)
                aura_env.affPlayers[counter] = destName
                if destName == aura_env.me then flagged = true end
                -- SetRaidTarget(destName, counter+3)
                
            elseif spellID == 287114 then --check for Miscalculated Teleport
                changeHealerState(destName, false)
                control = control + 1
                if destName == aura_env.me then flagged = true end
                if control == 3 and not flagged then
                    aura_env.display = playerDispelDecision()
                    return true
                end
            end
			
        elseif msg == "SPELL_AURA_REMOVED" then
            if spellID == 287167 or spellID == 287114 then --check for Discombobulation
            changeHealerState(destName, true)
            -- SetRaidTarget(destName, 0)
            end
        end
    end
end

trigger = false
t("ENCOUNTER_START")

resetRolls()
--Wormhole Generator cast
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_CAST_SUCCESS", _, _, "High Tinker Mekkatorque", _, _, _, "target", _, _, 287952)

--Discombobulation x3 applications
raidIndex = rollUnique()
target1 = raid[raidIndex]
print("Discombobulation 1 on " .. target1)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target1, _, _, 287167)
raidIndex = rollUnique()
target2 = raid[raidIndex]
print("Discombobulation 2 on " .. target2)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target2, _, _, 287167)
raidIndex = rollUnique()
target3 = raid[raidIndex]
print("Discombobulation 3 on " .. target3)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target3, _, _, 287167)

--Miscalculated Teleport x3 applications
raidIndex = rollUnique()
target4 = raid[raidIndex]
print("Miscalculated Teleport 1 on " .. target4)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target4, _, _, 287114)
raidIndex = rollUnique()
target5 = raid[raidIndex]
print("Miscalculated Teleport 2 on " .. target5)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target5, _, _, 287114)
raidIndex = rollUnique()
target6 = raid[raidIndex]
print("Miscalculated Teleport 3 on " .. target6)
trigger = t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target6, _, _, 287114)

for k, v in pairs(aura_env.healers) do
    print("Healer: " .. v[1])
    print(v[2])
end

--Discombobulation x3 de-applications
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target1, _, _, 287167)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target2, _, _, 287167)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target3, _, _, 287167)

--Miscalculated Teleport x3 de-applications

t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target4, _, _, 287114)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target5, _, _, 287114)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target6, _, _, 287114)

if trigger then
    print(aura_env.display)
end
resetRolls()
---------------------------------------------------------------------------------------------------------------------------------
print("#################################")
print("########### WAVE 2 ##############")
trigger = false
--Wormhole Generator cast
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_CAST_SUCCESS", _, _, "High Tinker Mekkatorque", _, _, _, "target", _, _, 287952)

--Discombobulation x3 applications
raidIndex = rollUnique()
target1 = raid[raidIndex]
print("Discombobulation 1 on " .. target1)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target1, _, _, 287167)
raidIndex = rollUnique()
target2 = raid[raidIndex]
print("Discombobulation 2 on " .. target2)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target2, _, _, 287167)
--raidIndex = rollUnique()
--target3 = raid[raidIndex]
--print("Discombobulation 3 on " .. target3)
--t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target3, _, _, 287167)

--Miscalculated Teleport x3 applications
raidIndex = rollUnique()
target4 = raid[raidIndex]
print("Miscalculated Teleport 1 on " .. target4)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target4, _, _, 287114)
raidIndex = rollUnique()
target5 = raid[raidIndex]
print("Miscalculated Teleport 2 on " .. target5)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target5, _, _, 287114)
raidIndex = rollUnique()
target6 = raid[raidIndex]
print("Miscalculated Teleport 3 on " .. target6)
trigger = t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target6, _, _, 287114)

for k, v in pairs(aura_env.healers) do
    print("Healer: " .. v[1])
    print(v[2])
end

--Discombobulation x3 de-applications
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target1, _, _, 287167)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target2, _, _, 287167)
--t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target3, _, _, 287167)

--Miscalculated Teleport x3 de-applications

t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target4, _, _, 287114)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target5, _, _, 287114)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target6, _, _, 287114) 

if trigger then
    print(aura_env.display)
end
resetRolls()