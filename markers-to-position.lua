aura_env = {"config", "ret", "me"}

function UnitName(player)
    return "Zandal", "Azralon"
end

function GetTime()
    return os.clock()
end

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

function GetTargetRaidIndex(player)
  for k, v in ipairs(markers) do
      if v == player then return k end
  end
  return nil
end

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

raid = {"Rademonaka", "Ohanassauro", "Kaohunt", "Pheiona", "Bonnie", "Doxie", "Quietstep", "Scav", "Caernn", "Hëllz", "Wakurp", "Zandal", "Mulff", "Jackroberto", "Luidz", "Pedrilho", "Musaxinha", "Niitrana"}

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
    alreadyRolled = {}
end

--[[
---------------
--           --
--   onInit  --
--           --
--------------- 
]]--
aura_env.me, _ = UnitName("player")

positions = {
    [1] = { --star
        "star wave1",
        "star wave2",
        "star wave3",
        "star wave4",
        "star wave5",
    },
    
    [2] = { --orange
        "circle wave1", 
        "circle wave2",
        "circle wave3",
        "circle wave4",
        "circle wave5",
    },
    
    [3] = { --diamond
        "diamond wave1",
        "diamond wave2",
        "diamond wave3",
        "diamond wave4",
        "diamond wave5",
    }
}

function markerToPositions(wave)
    now = GetTime()    
    while GetTime() - now < 0.5 do
    end
  
    index = GetTargetRaidIndex(aura_env.me)
    return positions[index][wave]
end

t = function(event, ...)
    if event == "ENCOUNTER_START" then
        counter = 0
        wave = 0
        flagged = false
    elseif event == "ENCOUNTER_END" then
        counter = 0
        wave = 0
        flagged = false
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local msg = select(2, ...)
        local spellID = select(12, ...)
        local sourceName = select(5, ...)
        local destName = select(9, ...)
        if msg == "SPELL_AURA_APPLIED" and spellID == 286646 then --check for Discombobulation
            counter = counter + 1
            if destName == aura_env.me then flagged = true end
            print("counter: " .. counter .. "\nresto: " .. counter % 3)
            if counter % 3 == 0 then 
                wave = wave + 1
                print(wave)
                if flagged then 
                    aura_env.ret = markerToPositions(wave)
                    flagged = false
                    return true
                end
            end
        end
    end
end


t("ENCOUNTER_START")

while true do
    math.randomseed(math.random() + os.clock())

    raidIndex = rollUnique()
    target1 = raid[raidIndex]
    SetRaidTarget(target1, 1)
    t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target1, _, _, 286646)

    raidIndex = rollUnique()
    target2 = raid[raidIndex]
    SetRaidTarget(target2, 2)
    t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target2, _, _, 286646)

    raidIndex = rollUnique()
    target3 = raid[raidIndex]
    SetRaidTarget(target3, 3)
    trig = t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target3, _, _, 286646)

    if trig then print(aura_env.ret) end

    io.read()
    resetRolls()
end