aura_env = {"config", "healers", "affPlayers", "display"}

function UnitName(player)
  return "Zandal", "Azralon"
end

aura_env.config = {
  ["option1"] = "Musaxinha",
  ["option2"] = "Zandal",
  ["option3"] = "Jackroberto",
  ["option4"] = "Pedrilho",
  ["option5"] = "Niitrana",
}

raid = {"Rademonaka", "Ohanassauro", "Kaohunt", "Pheiona", "Bonnie", "Doxie", "Quietstep", "Scav", "Caernn", "Hëllz", "Wakurp", "Zandal", "Mulff", "Jackroberto", "Luidz", "Pedrilho", "Musaxinha", "Niitrana"}
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

aura_env.affPlayers = {"p1", "p2", "p3"}

function startVars()
    for _, v in pairs(aura_env.healers) do
	      v[2] = true
	  end
	
	  aura_env.affPlayers = {"p1", "p2", "p3"}
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
    local i = 0
    
    for k, v in pairs(aura_env.healers) do
        if v[2] then
            i = i + 1
            if v[1] == UnitName("player") then
                return "DISPEL " .. aura_env.affPlayers[i%3]
            end
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

t = function (event, ...)
    if event == "ENCOUNTER_START" then
	      control = 0 -- control variable to trigger the WA once the WG is cast, 3 players are afflicted by Discombobulation and 3 players are thrown up
		    counter = 0
        startVars()
    elseif event == "ENCOUNTER_END" then
        control = 0
        counter = 0
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local msg = select(2, ...)
        local spellID = select(12, ...)
		    local sourceName = select(5, ...)
        local destName = select(9, ...)
        control = control or 0
        counter = counter or 0
        if msg == "SPELL_CAST_SUCCESS" and spellID == 287952 then --check for Wormhole Generator
		        control = 0
			      counter = 0
            
        elseif msg == "SPELL_AURA_APPLIED" then
		        if spellID == 287167 then --check for Discombobulation
                counter = counter + 1
				        changeHealerState(destName, false)
				        aura_env.affPlayers[counter] = destName	
            elseif spellID == 287114 then --check for Miscalculated Teleport
			          changeHealerState(destName, false)
		            control = control + 1
		            if control == 3 then
                    aura_env.display = playerDispelDecision()
				            return true
			          end
		        end
			
        elseif msg == "SPELL_AURA_REMOVED" then
            if spellID == 287167 or spellID == 287114 then --check for Discombobulation
            changeHealerState(destName, true)
            end
		    end
	  end
end

t("ENCOUNTER_START")

--Wormhole Generator cast
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_CAST_SUCCESS", _, _, "High Tinker Mekkatorque", _, _, _, "target", _, _, 287952)

--Discombobulation x3 applications
target = raid[3]
print("Discombobulation 1 on " .. target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)
target = raid[8]
print("Discombobulation 2 on " .. target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)
target = raid[17]
print("Discombobulation 3 on " .. target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)

--Miscalculated Teleport x3 applications
target = raid[5]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)
target = raid[11]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)
target = raid[16]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_APPLIED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)

for k, v in pairs(aura_env.healers) do
    print("Healer: " .. v[1])
    print(v[2])
end

for k, v in pairs(aura_env.affPlayers) do
    print("Debuff em " .. v)
end

--Discombobulation x3 de-applications
target = raid[3]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)
target = raid[8]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)
target = raid[17]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287167)

--Miscalculated Teleport x3 de-applications
target = raid[5]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)
target = raid[11]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)
target = raid[16]
print(target)
t("COMBAT_LOG_EVENT_UNFILTERED", _, "SPELL_AURA_REMOVED", _, _, "High Tinker Mekkatorque", _, _, _, target, _, _, 287114)

print(aura_env.display)
