-- SummaryGenerator.lua
-- This script runs Path of Building in headless mode, loads an XML file,
-- and extracts its core statistics and items into a summary text file.
-- Note: Must be run from the root of PathOfBuilding directory with:
-- runtime\luajit.exe AI_Scripts\SummaryGenerator.lua

-- 1. Switch working directory to src/ so HeadlessWrapper works correctly
-- (This should be done via terminal before running the script)

-- Add runtime and runtime/lua to paths so lua5.1.exe can find modules
package.path = package.path .. ";../runtime/lua/?.lua;../runtime/lua/?/init.lua"
package.cpath = package.cpath .. ";../runtime/?.dll"

-- Provide a fake 'jit' global if running on standard Lua 5.1 to bypass Launch.lua checks
if not jit then
    jit = { 
        version = "LuaJIT 2.1.0-beta3", 
        version_num = 20100, 
        os = "Windows", 
        arch = "x86",
        opt = { start = function() end }
    }
end

-- Mock missing functions from HeadlessWrapper
function GetVirtualScreenSize() return 1920, 1080 end

-- 2. Extract arguments before they are overwritten by Launch.lua via HeadlessWrapper
local buildName = arg[1] or "AMa_PoisonSRS"
-- Remove .xml extension if the user includes it in the argument
buildName = buildName:gsub("%.[xX][mM][lL]$", "")

-- Load the Headless Wrapper
dofile("HeadlessWrapper.lua")

-- 3. Read the XML file
local xmlPath = "../Builds/" .. buildName .. ".xml"
local xmlFile = io.open(xmlPath, "r")
if not xmlFile then
    print("Cannot open " .. xmlPath .. ". Please ensure the file exists.")
    os.exit(1)
end
local xmlText = xmlFile:read("*a")
xmlFile:close()

-- 4. Load the build into PoB
print("Loading build: " .. buildName)
loadBuildFromXML(xmlText, buildName)

-- 5. Force calculation by running a few frames
print("Calculating stats...")
build.buildFlag = true
for i = 1, 20 do
    runCallback("OnFrame")
end

-- 6. Extract Information
local summary = "[Character Options]\n"
summary = summary .. "Level: " .. build.characterLevel .. "\n"
summary = summary .. "Class: " .. (build.spec.curClassName or "Unknown") .. "\n"
summary = summary .. "Ascendancy: " .. (build.spec.curAscendClassName or "None") .. "\n"

summary = summary .. "\n[Main Statistics]\n"
local env = build.calcsTab.mainEnv
local out = build.calcsTab.mainOutput

if out then
    summary = summary .. "Life: " .. tostring(out.Life or 0) .. "\n"
    summary = summary .. "Mana: " .. tostring(out.Mana or 0) .. "\n"
    summary = summary .. "Energy Shield: " .. tostring(out.EnergyShield or 0) .. "\n"
    summary = summary .. "Armour: " .. tostring(out.Armour or 0) .. "\n"
    summary = summary .. "Evasion: " .. tostring(out.Evasion or 0) .. "\n"
    
    local dps = out.TotalDPS or out.CombinedDPS or out.MinionTotalDPS or 0
    summary = summary .. "Main Skill DPS: " .. tostring(dps) .. "\n"
    
    summary = summary .. "\n[Defense Statistics]\n"
    summary = summary .. "Effective Hit Pool (EHP): " .. tostring(out.EffectiveHitPool or 0) .. "\n"
    summary = summary .. "Fire Res: " .. tostring(out.FireResist or 0) .. "% (Uncapped: " .. tostring(out.FireResistTotal or 0) .. "%) | "
    summary = summary .. "Cold Res: " .. tostring(out.ColdResist or 0) .. "% (Uncapped: " .. tostring(out.ColdResistTotal or 0) .. "%) | "
    summary = summary .. "Light Res: " .. tostring(out.LightningResist or 0) .. "% (Uncapped: " .. tostring(out.LightningResistTotal or 0) .. "%) | "
    summary = summary .. "Chaos Res: " .. tostring(out.ChaosResist or 0) .. "% (Uncapped: " .. tostring(out.ChaosResistTotal or 0) .. "%)\n"
    summary = summary .. "Phys Damage Reduction: " .. tostring(out.PhysicalDamageReduction or 0) .. "%\n"
    summary = summary .. "Block Chance: " .. tostring(out.BlockChance or 0) .. "% | Spell Block: " .. tostring(out.SpellBlockChance or 0) .. "%\n"
    summary = summary .. "Spell Suppression: " .. tostring(out.SpellSuppressionChance or 0) .. "%\n"
    summary = summary .. "Evade Chance: " .. tostring(out.EvadeChance or 0) .. "%\n"
    
    summary = summary .. "\n[Offense & Misc Statistics]\n"
    summary = summary .. "Hit Chance: " .. tostring(out.HitChance or 0) .. "%\n"
    summary = summary .. "Crit Chance: " .. tostring(out.CritChance or 0) .. "% | Crit Multi: " .. tostring(out.CritMultiplier or 0) .. "\n"
    summary = summary .. "Life Regen: " .. tostring(out.LifeRegen or 0) .. " | Mana Regen: " .. tostring(out.ManaRegen or 0) .. "\n"
    summary = summary .. "Max Leech Rate: " .. tostring(out.MaxLifeLeechRate or 0) .. " (" .. tostring(out.MaxLifeLeechRatePercent or 0) .. "%)\n"
    summary = summary .. "Speed: " .. tostring(out.Speed or 0) .. "\n"
    
    summary = summary .. "\n[Charges]\n"
    summary = summary .. "Endurance Charges: " .. tostring(out.EnduranceCharges or 0) .. " / " .. tostring(out.EnduranceChargesMax or 0) .. "\n"
    summary = summary .. "Frenzy Charges: " .. tostring(out.FrenzyCharges or 0) .. " / " .. tostring(out.FrenzyChargesMax or 0) .. "\n"
    summary = summary .. "Power Charges: " .. tostring(out.PowerCharges or 0) .. " / " .. tostring(out.PowerChargesMax or 0) .. "\n"
else
    summary = summary .. "Failed to calculate stats.\n"
end

summary = summary .. "\n[Active Skill Groups]\n"
for _, socketGroup in ipairs(build.skillsTab.socketGroupList) do
    if socketGroup.enabled then
        local gems = {}
        for _, gem in ipairs(socketGroup.gemList) do
            if gem.enabled then
                table.insert(gems, gem.nameSpec .. " (Lv " .. gem.level .. ")")
            end
        end
        if #gems > 0 then
            summary = summary .. "- " .. table.concat(gems, " + ") .. "\n"
        end
    end
end

summary = summary .. "\n[Equipped Items]\n"
for slotName, slot in pairs(build.itemsTab.slots) do
    if slot.selItemId and slot.selItemId > 0 then
        local item = build.itemsTab.items[slot.selItemId]
        if item then
            summary = summary .. slotName .. ":\n"
            local lines = {}
            for s in string.gmatch(item.raw or "", "[^\r\n]+") do
                table.insert(lines, s)
            end
            for _, line in ipairs(lines) do
                summary = summary .. "  >>> " .. line .. "\n"
            end
            summary = summary .. "\n"
        end
    end
end

summary = summary .. "\n[Allocated Passive Nodes]\n"
local passiveCount = 0
for id, node in pairs(build.spec.allocNodes) do
    if node.type ~= "ClassStart" and node.type ~= "AscendClassStart" and node.name then
        passiveCount = passiveCount + 1
        summary = summary .. "- " .. node.name .. "\n"
        if node.sd then
            for _, line in ipairs(node.sd) do
                summary = summary .. "   >>> " .. line .. "\n"
            end
        end
    end
end
summary = summary .. "\nTotal Passives Allocated: " .. passiveCount .. "\n"

-- 7. Write to Output File
local outPath = "../Builds/" .. buildName .. "_Summary.txt"
local outFile = io.open(outPath, "w")
if outFile then
    outFile:write(summary)
    outFile:close()
    print("Successfully generated summary at " .. outPath)
else
    print("Failed to write to " .. outPath)
end

os.exit(0)
