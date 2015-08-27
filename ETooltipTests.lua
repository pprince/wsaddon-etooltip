-----------------------------------------------------------------------------------------------
-- Client Lua Script for TooltipTests
-- Copyright (c) NCsoft. All rights reserved
-- Writen by dullone
-----------------------------------------------------------------------------------------------
require "Apollo"
require "Window"
require "AttributeMilestonesLib"
require "GameLib"
require "Item"
 
-----------------------------------------------------------------------------------------------
-- TooltipTests Module Definition
-----------------------------------------------------------------------------------------------
local TooltipTests = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local tDefaultSettings = {
    ["bShowItemPower"]                                      = true,
    ["bShowMileStones"]                                     = true,
    ["bShowWeaponPower"]                                    = false,
    ["bShowItemLevel"]                                      = false,
    ["bArmor"]                                              = false,
    [Unit.CodeEnumProperties.ResistPhysical]                = true,
    [Unit.CodeEnumProperties.ResistMagic]                   = true,
    [Unit.CodeEnumProperties.ResistTech]                    = true,
    [Unit.CodeEnumProperties.AssaultPower]                  = true,
    [Unit.CodeEnumProperties.SupportPower]                  = true,
    [Unit.CodeEnumProperties.Rating_AvoidReduce]            = true,
    [Unit.CodeEnumProperties.Rating_CritChanceIncrease]     = true,
    [Unit.CodeEnumProperties.RatingCritSeverityIncrease]    = true,
    [Unit.CodeEnumProperties.Rating_AvoidIncrease]          = true,
    [Unit.CodeEnumProperties.Rating_CritChanceDecrease]     = true,
    [Unit.CodeEnumProperties.ManaPerFiveSeconds]            = true,
    [Unit.CodeEnumProperties.BaseHealth]                    = true,
    [Unit.CodeEnumProperties.ShieldCapacityMax]             = true,
    ["bShowRating"]                                         = false,
    ["bShowConvertedRating"]                                = true,
    ["bExcludeRunes"]                                       = false,
    [Unit.CodeEnumProperties.PvPDefensiveRating]            = true,
    [Unit.CodeEnumProperties.PvPOffensiveRating]            = true,
    ["PvPHealing"]                                          = true,
    ["bShowRuneValues"]                                     = true,
    ["bShowItemID"]                                         = false,

}

local tMilestonesStatConvert =  
    {
        [Unit.CodeEnumProperties.Strength]   = "strength",
        [Unit.CodeEnumProperties.Dexterity]  = "dexterity",
        [Unit.CodeEnumProperties.Technology] = "technology",
        [Unit.CodeEnumProperties.Magic]      = "magic",
        [Unit.CodeEnumProperties.Wisdom]     = "wisdom",
        [Unit.CodeEnumProperties.Stamina]    = "stamina",
    }

local ktAttributeToText =
{
    [Unit.CodeEnumProperties.Dexterity]                     = Apollo.GetString("CRB_Finesse"),
    [Unit.CodeEnumProperties.Technology]                    = Apollo.GetString("CRB_Tech_Attribute"),
    [Unit.CodeEnumProperties.Magic]                         = Apollo.GetString("CRB_Moxie"),
    [Unit.CodeEnumProperties.Wisdom]                        = Apollo.GetString("UnitPropertyInsight"),
    [Unit.CodeEnumProperties.Stamina]                       = Apollo.GetString("CRB_Grit"),
    [Unit.CodeEnumProperties.Strength]                      = Apollo.GetString("CRB_Brutality"),

    [Unit.CodeEnumProperties.Armor]                         = Apollo.GetString("CRB_Armor") ,
    [Unit.CodeEnumProperties.ShieldCapacityMax]             = Apollo.GetString("CBCrafting_Shields"),

    [Unit.CodeEnumProperties.AssaultPower]                  = Apollo.GetString("CRB_Assault_Power"),
    [Unit.CodeEnumProperties.SupportPower]                  = Apollo.GetString("CRB_Support_Power"),
    [Unit.CodeEnumProperties.Rating_AvoidReduce]            = Apollo.GetString("CRB_Strikethrough_Rating"),
    [Unit.CodeEnumProperties.Rating_CritChanceIncrease]     = Apollo.GetString("CRB_Critical_Chance"),
    [Unit.CodeEnumProperties.RatingCritSeverityIncrease]    = Apollo.GetString("CRB_Critical_Severity"),
    [Unit.CodeEnumProperties.Rating_AvoidIncrease]          = Apollo.GetString("CRB_Deflect_Rating"),
    [Unit.CodeEnumProperties.Rating_CritChanceDecrease]     = Apollo.GetString("CRB_Deflect_Critical_Hit_Rating"),
    [Unit.CodeEnumProperties.ManaPerFiveSeconds]            = Apollo.GetString("CRB_Attribute_Recovery_Rating"),
    [Unit.CodeEnumProperties.HealthRegenMultiplier]         = Apollo.GetString("CRB_Health_Regen_Factor"),
    [Unit.CodeEnumProperties.BaseHealth]                    = Apollo.GetString("CRB_Health_Max"),

    [Unit.CodeEnumProperties.ResistTech]                    = Apollo.GetString("Tooltip_ResistTech"),
    [Unit.CodeEnumProperties.ResistMagic]                   = Apollo.GetString("Tooltip_ResistMagic"),
    [Unit.CodeEnumProperties.ResistPhysical]                = Apollo.GetString("Tooltip_ResistPhysical"),

    [Unit.CodeEnumProperties.PvPOffensiveRating]            = Apollo.GetString("Character_PvPOffenseLabel"),
    ["PvPHealing"]                                          = Apollo.GetString("Character_PvPHealLabel"), --not in enum
    [Unit.CodeEnumProperties.PvPDefensiveRating]            = Apollo.GetString("Tooltip_PvPDefense"),
}

local tSecondaryAttributeToText = {
    [Unit.CodeEnumProperties.Rating_AvoidReduce]            = Apollo.GetString("Character_StrikethroughLabel"),
    [Unit.CodeEnumProperties.Rating_CritChanceIncrease]     = Apollo.GetString("Character_CritChanceLabel"),
    [Unit.CodeEnumProperties.RatingCritSeverityIncrease]    = Apollo.GetString("Character_CritSeverityLabel"),
    [Unit.CodeEnumProperties.Rating_AvoidIncrease]          = Apollo.GetString("Character_DeflectLabel"),
    [Unit.CodeEnumProperties.Rating_CritChanceDecrease]     = Apollo.GetString("Character_DeflectCritLabel"),
    [Unit.CodeEnumProperties.Armor]                         = Apollo.GetString("Character_PhysicalMitLabel") .. ", " .. Apollo.GetString("Character_TechMitLabel") .. ", " .. Apollo.GetString("Character_MagicMitLabel"), --unused
    [Unit.CodeEnumProperties.ResistPhysical]                = Apollo.GetString("Character_PhysicalMitLabel"),
    [Unit.CodeEnumProperties.ResistMagic]                   = Apollo.GetString("Character_MagicMitLabel"),
    [Unit.CodeEnumProperties.ResistTech]                    = Apollo.GetString("Character_TechMitLabel"),
    [Unit.CodeEnumProperties.ShieldCapacityMax]             = Apollo.GetString("CBCrafting_Shields"),
}

local tMitigationStats = {
    Unit.CodeEnumProperties.ResistPhysical,
    Unit.CodeEnumProperties.ResistMagic,
    Unit.CodeEnumProperties.ResistTech,
}

local tStatConverstionFuncs = {
    --holds function pointers
}

local tPercentageStats = {
    [Unit.CodeEnumProperties.Rating_CritChanceIncrease]  = "%",
    [Unit.CodeEnumProperties.Rating_AvoidReduce]         = "%",
    [Unit.CodeEnumProperties.RatingCritSeverityIncrease] = "%",
    [Unit.CodeEnumProperties.Rating_AvoidIncrease]       = "%",
    [Unit.CodeEnumProperties.Rating_CritChanceDecrease]  = "%",
    [Unit.CodeEnumProperties.PvPOffensiveRating]         = "%",
    [Unit.CodeEnumProperties.PvPDefensiveRating]         = "%",
    ["PvPHealing"]                                       = "%",

}

local tStatColors ={
    --holds the stat colors if any are changed
}

--sort order for stats in the tooltip
local tStatSortOrder ={
    [Unit.CodeEnumProperties.Rating_AvoidReduce] = 18,
}

--defaults, *should* never be used
local nCritPerRating          = 0.0464
local nCritSevPerRating       = 0.032
local nStrikePerRating        = 0.0263
local nDeflectPerRating       = 0.014
local nDeflectCritPerRating   = 0.026
local nFocusRegPerRating      = 0.01 --Used frequently, only acurate near lvl30
local nFocusRegPerRatingFifty = .00643
local nPvPOffDefPerRating     = .006  --at 50
local nPvPHealingperRating    = .0053  --at 50
local nPvPRoughPerPoint       = .0095  --at lvl 25
local nPvPHealRoughPerPoint   = .0084  --~lvl 250

--PvP base values
local nPvPBaseDamageTaken           = .75 --PvPInstances (100 - 25)
local nPvPBaseDamageTakenOpenWorld  = .85 --open world
local nPvPBaseDamageDone            = .75 --PvPInstances
local nPvPBaseDamageDoneOpenWorld   = .85 

local kUIRed = "ffda2a00" 
local kUIGreen = "ff42da00" 
local kUIBody = "ff39b5d4"

--Spacing
local nItemIDSpacing = 4 --extra spacing if itemID is enabled

local origItemToolTipForm  = nil

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function TooltipTests:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
    o.tSettings = {}
    setmetatable(o.tSettings, {__index = tDefaultSettings})
    return o
end

function TooltipTests:Init()
    local bHasConfigureFunction = true
    local strConfigureButtonText = "ETooltip"
    local tDependencies = {
        "ToolTips",
    }
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
 function TooltipTests:OnDependencyError(strDep, strError)
    if strDep == "ToolTips" then
        local tReplacements = Apollo.GetReplacement(strDep)
        if #tReplacements ~= 1 then
            return false
        end
        self.TTReplacement = tReplacements[1]
        return true
    end
    return false
end

-----------------------------------------------------------------------------------------------
-- TooltipTests OnLoad
-----------------------------------------------------------------------------------------------
function TooltipTests:OnLoad()
    -- load our form file
    self.xmlDoc = XmlDoc.CreateFromFile("ETooltipTests.xml")
    self.xmlDoc:RegisterCallback("OnDocLoaded", self)

    --tooltip hooking
    local tt = Apollo.GetAddon("ToolTips")
    if tt then
        self:HookToolTip(tt)
    end
end

function TooltipTests:HookToolTip(aAddon)
    local origCreateCallNames = aAddon.CreateCallNames
    if not origCreateCallNames then Apollo.AddAddonErrorText(self, "EToolTip ERROR: Tooltip addon not compatiable with Etooltip") return false end
    aAddon.CreateCallNames = function(luaCaller)
        origCreateCallNames(luaCaller) 
        origItemToolTipForm = Tooltip.GetItemTooltipForm
        Tooltip.GetItemTooltipForm  = function (luaCaller, wndControl, item, bStuff, nCount)
            return self.ItemToolTip(luaCaller, wndControl, item, bStuff, nCount)
        end
    end
    return true
end

-----------------------------------------------------------------------------------------------
-- TooltipTests OnDocLoaded
-----------------------------------------------------------------------------------------------
function TooltipTests:OnDocLoaded()
    aGeminiColor = Apollo.GetPackage("GeminiColor").tPackage
    if self.TTReplacement then
        self:HookToolTip(Apollo.GetAddon(self.TTReplacement))
    end
    if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
        self.wndOptions = Apollo.LoadForm(self.xmlDoc, "TooltipTestsForm", nil, self)
        Apollo.LoadForm(self.xmlDoc, "ListAdditionalOptions", self.wndOptions:FindChild("ListOptions"), self)
        self.wndOptions:FindChild("ListOptions"):ArrangeChildrenVert()
        if self.wndOptions  == nil then
            Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
            return
        end
        
        -- Register handlers for events, slash commands and timer, etc.
        Apollo.RegisterSlashCommand("ett", "OnConfigure", self)
        Apollo.RegisterSlashCommand("ETT", "OnConfigure", self)
        Apollo.RegisterSlashCommand("ETooltip", "OnConfigure", self)

        tStatConverstionFuncs[Unit.CodeEnumProperties.Rating_CritChanceIncrease]  = self.ConvertCritRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.Rating_AvoidReduce]         = self.ConvertStrikeRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.RatingCritSeverityIncrease] = self.ConvertCritSevRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.Rating_AvoidIncrease]       = self.ConvertDeflectRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.Rating_CritChanceDecrease]  = self.ConvertDeflectCritRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.ManaPerFiveSeconds]         = self.ConvertFocusRegRating
        --PvP
        tStatConverstionFuncs[Unit.CodeEnumProperties.PvPOffensiveRating]         = self.ConvertPvPOffenseRating
        tStatConverstionFuncs[Unit.CodeEnumProperties.PvPDefensiveRating]         = self.ConvertPvPDefenseRating
        tStatConverstionFuncs["PvPHealing"]                                       = self.ConvertPvPHealingRating
    end
    self.ChatLogAddon    = Apollo.GetAddon(Apollo.GetReplacement("ChatLog")[1])
    --self.MasterLootAddon = Apollo.GetAddon(Apollo.GetReplacement("MasterLoot")[1])
end

-----------------------------------------------------------------------------------------------
-- TooltipTests Functions
-----------------------------------------------------------------------------------------------
-- on SlashCommand "/TTT" and configure
function TooltipTests:OnConfigure()
    self:SetupOptions()
    self.wndOptions:Show(true)
    self.wndOptions:ToFront()
end

function TooltipTests:DefaultSettings()
    self.tSettings = {}
    for idx,setting in pairs(tDefaultSettings) do
        self.tSettings[idx] = tDefaultSettings[idx]
    end
    for idx,color in pairs(tStatColors) do
        tStatColors[idx] = kUIBody
    end
end

function TooltipTests:ItemToolTip (wndControl, item, bStuff, nCount)
    local this = Apollo.GetAddon("ETooltip")
    wndControl:SetTooltipDoc(nil)
    local wndTooltip, wndTooltipComp = origItemToolTipForm(self, wndControl, item, bStuff, nCount)

    if wndTooltip then
        local wndTypeTxt = wndTooltip:FindChild("ItemTooltip_Header_Types")
        if this.tSettings["bShowItemPower"] then
            if wndTooltip then
                this:AttachRight(" - Power: " .. item:GetItemPower(), wndTypeTxt) --.. " id - " .. item:GetItemId()
            end
            if wndTooltipComp then
                this:AttachRight(" - Power: " .. bStuff.itemCompare:GetItemPower(), wndTooltipComp:FindChild("ItemTooltip_Header_Types"))
            end
        end
        if this.tSettings["bShowItemID"] then
            if wndTooltip then
                local ItemId = item:GetItemId()
                local strItemId = string.format("Item ID: %d &lt;i%x&gt;", ItemId, ItemId)
                this:AttachBelow(strItemId, wndTooltip:FindChild("ItemTooltip_Header"))
            end
            if wndTooltipComp then
                local ItemId = bStuff.itemCompare:GetItemId()
                local strItemId = string.format("Item ID: %d &lt;i%x&gt;", ItemId, ItemId)
                this:AttachBelow(strItemId, wndTooltipComp:FindChild("ItemTooltip_Header"))
            end
        end
        --Linked item check for mouseover - we put compare into the permanant tooltip, so we ignore the mousever one
        if wndControl:GetName() == "TooltipWindow" then --self == Apollo.GetAddon("ChatLog") or self == this.ChatLogAddon then
            if wndControl:GetName() == "TooltipWindow" then --this is a tooltip of the tooltip window, do not display summary as its already present
                return wndTooltip, wndTooltipComp
            end
        end
        --Chatlog linked item check and default behavior 
        if bStuff.bPermanent and not bStuff.itemCompare and wndControl:GetName() == "ChatLine" then --(self == Apollo.GetAddon("ChatLog") or self == this.ChatLogAddon) then
            bStuff.itemCompare = item:GetEquippedItemForItemType()
            this:CreateSummary(wndControl, wndTooltip, item, bStuff.itemCompare)
        elseif not (bStuff.bPermanent and bStuff.bPermanent == true) then
            this:CreateSummary(wndControl, wndTooltip, item, bStuff.itemCompare)
        end
    end
    return wndTooltip, wndTooltipComp
end

function TooltipTests:AttachRight(strText, wnd)
    wnd:SetText(wnd:GetText() .. strText)
end

function TooltipTests:AttachBelow(strText, wndHeader)
    wndAML = Apollo.LoadForm(self.xmlDoc, "MLItemID", wndHeader, self)
    wndAML:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>",kUIBody, strText))
    local nWidth, nHeight = wndAML:SetHeightToContentHeight()
    local nLeft, nTop, nRight, nBottom = wndHeader:GetAnchorOffsets()
    --Set BGart to not strech to fit so we have extra space for the ItemID; not ideal
    local BGArt = wndHeader:FindChild("ItemTooltip_HeaderBG")   local QBar = wndHeader:FindChild("ItemTooltip_HeaderBar")
    local nQLeft, nQTop, nQRight, nQBottom = QBar:GetAnchorOffsets()
    QBar:SetAnchorOffsets(nQLeft, nQTop - nItemIDSpacing, nQRight, nQBottom - nItemIDSpacing) -- move up with the rest
    BGArt:SetAnchorPoints(0,0,1,0) --set to no longer stretch to fit
    BGArt:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
    wndHeader:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + nItemIDSpacing) -- add space
    self:ArrangeChildrenVertAndResize(wndHeader:GetParent())
    --set itemID position
    wndAML:SetAnchorPoints(0,1,1,1)
    wndAML:SetAnchorOffsets(25, 2 - nHeight, 3, 0)

end

function TooltipTests:ResizeTooltip(wndControl, additionalHeight)
    wndControl:FindChild("Items"):ArrangeChildrenVert()
    wndControl:Move(0, 0, wndControl:GetWidth(), wndControl:GetHeight() + additionalHeight)
end

function TooltipTests:CreateSummary(wndPar, wndControl, item, itemComp)
    if not GameLib.GetPlayerUnit() then return end --fix for a rare error where the UnitPlayer can be nil
    local itemComparison = {}
    if itemComp then
        itemComparison = Item.GetDetailedInfo(item, itemComp)
    else
        itemComparison = Item.GetDetailedInfo(item)
    end

    if not (itemComparison.tPrimary.arBudgetBasedProperties or itemComparison.tPrimary.tRunes) then return end --not an item with character stats

    local wndSummary = Apollo.LoadForm(self.xmlDoc, "FormToolTipSummary", wndControl:FindChild("Items"), self)

    local wndList = wndSummary:FindChild("ListTooltipSummary")
    local tStatsChanged = {}
    local tStats = {}
    local tStatsComp = {}

    --Get a table of stats from item
    self:DerivedStatsHelper(itemComparison.tPrimary.arBudgetBasedProperties, tStats)
    if item:GetDetailedInfo().tPrimary.arInnateProperties then
        self:DerivedStatsHelper(item:GetDetailedInfo().tPrimary.arInnateProperties, tStats)
    end
    if itemComparison.tPrimary.tRunes then
        self:RuneStatsHelper(itemComparison.tPrimary.tRunes, tStats)
    end
    --Get a table of stats from compare item
    if itemComp then
        --local tCompProps = itemComp:GetDetailedInfo().tPrimary.arBudgetBasedProperties
        if itemComparison.tCompare.arBudgetBasedProperties or itemComparison.tCompare.tRunes then --does this item have character stats?
            self:DerivedStatsHelper(itemComparison.tCompare.arBudgetBasedProperties, tStatsComp)
            if itemComparison.tCompare.arInnateProperties then
                self:DerivedStatsHelper(itemComparison.tCompare.arInnateProperties, tStatsComp)
            end
            if itemComparison.tCompare.tRunes then
                self:RuneStatsHelper(itemComparison.tCompare.tRunes, tStatsComp)
            end
        end
    end 

--Check for stat changes
    for idx,stat in pairs(tStats) do
        if tStatsComp[idx] then 
            if stat.nValue >=  tStatsComp[idx].nValue then
                tStatsChanged[idx] = {bIncrease = true,  nValue = stat.nValue - tStatsComp[idx].nValue, nSortOrder = stat.nSortOrder}
            else
                tStatsChanged[idx] = {bIncrease = false, nValue = stat.nValue - tStatsComp[idx].nValue, nSortOrder = stat.nSortOrder}
            end
        else --Stat not in itemcomp
            tStatsChanged[idx] = {bIncrease = true, nValue = stat.nValue, nSortOrder = stat.nSortOrder} 
        end
    end
    if itemComp then --add stats not present in item
        for idx,stat in pairs(tStatsComp) do
            if not tStats[idx] then
                tStatsChanged[idx] = {bIncrease = false, nValue = tStatsComp[idx].nValue * -1, nSortOrder = tStatsComp[idx].nSortOrder} 
            end
        end
    end
    
    --Milestones check
    local milestones = {}
    local bMilestone = false
    if itemComp or item:GetEquippedCount() ~= 1 then -- don't check for milestones if no compare item
        for idx,stat in pairs(tStatsChanged) do
            if tMilestonesStatConvert[idx] then
                local MS = self:CheckForMilestone(idx,stat.nValue)
                if MS then
                    bMilestone = true
                    milestones[idx] = MS
                    for idx2,mStone in pairs(MS) do --for more than one milestone reached
                        --TODO: find a good way to locate tooltip sort order and use that rather than defaulting to nSortOrder = 99
                        if not tStatsChanged[mStone.eStat] then tStatsChanged[mStone.eStat] = {nValue = 0, nSortOrder =(tStatSortOrder[mStone.eStat] or 99) } end 
                        tStatsChanged[mStone.eStat].nValue = tStatsChanged[mStone.eStat].nValue + mStone.fIncrease
                        if tStatsChanged[mStone.eStat].nValue > 0 then -- check if milestone brought us into the positive
                            tStatsChanged[mStone.eStat].bIncrease = true 
                        else
                            tStatsChanged[mStone.eStat].bIncrease = false
                        end 
                    end
                end
            end
        end
    end


    --Armor
    local ArmorDelta = {nValue = 0, bIncrease = false}
    if itemComp then
        --ArmorDelta.nValue = item:GetArmor() - itemComp:GetArmor()
        if tStatsChanged[Unit.CodeEnumProperties.Armor] then
            ArmorDelta.nValue = ArmorDelta.nValue + tStatsChanged[Unit.CodeEnumProperties.Armor].nValue --add in bonus armor on item
        end
        ArmorDelta.bIncrease = ArmorDelta.nValue >= 0
    end
    -------Add items to the summary window--------
    --Milestones
    if self.tSettings["bShowMileStones"] then
        if bMilestone then
            local wndTitle = Apollo.LoadForm(self.xmlDoc,"Header", wndList, self)
            wndTitle:SetText("Milestones reached or lost with item")
        end
        for idx,MSs in pairs(milestones) do
            for idx2,MS in pairs(MSs) do
                local wndSum = Apollo.LoadForm(self.xmlDoc, "ListSummaryItem", wndList, self)
                wndSum:SetAML(string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s, </T><T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s </T><T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s%.0f</T>", 
                    kUIBody, ktAttributeToText[idx], tStatColors[MS.eStat]~=nil and tStatColors[MS.eStat] or kUIBody,ktAttributeToText[MS.eStat], MS.bIncrease and kUIGreen or kUIRed, MS.bIncrease and "+" or "" ,MS.fIncrease))
                wndSum:SetHeightToContentHeight()
            end
        end
    end

    local wndSumHead = Apollo.LoadForm(self.xmlDoc, "Header", wndList, self)
    if itemComp then --if we are comparing an item, we include milestones, otherwise we just show a stat summary, so let the user know.
        wndSumHead:SetText("Stat summary (milestones included)")
    else
        wndSumHead:SetText("Stat summary")
    end
    --Armor entry
    if self.tSettings["bArmor"] then
        for idx, enumResist in pairs(tMitigationStats) do
            if self.tSettings[enumResist] then --if option to show is true
                local nResistChange = self:ConvertResistToDamageReduction(ArmorDelta.nValue, tStatsChanged[enumResist] and tStatsChanged[enumResist].nValue or 0,enumResist)
                if nResistChange ~= 0 then
                    local bResistIncrease = nResistChange >= 0
                    local strline = string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s%.2f%s </T><T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>",
                        bResistIncrease and kUIGreen or kUIRed, bResistIncrease and "+" or "", nResistChange, "%",
                        kUIBody, tSecondaryAttributeToText[enumResist])
                    local wndSum = Apollo.LoadForm(self.xmlDoc, "ListSummaryItem", wndList, self)
                    wndSum:SetAML(strline)
                    wndSum:SetHeightToContentHeight()
                end
            end
        end
    end

    --Sort the stats to keep consistant display order
    local tSortedStatsChanged = {}
    for k, d in pairs(tStatsChanged) do table.insert(tSortedStatsChanged, {key = k, nSortOrder = d.nSortOrder, nValue = d.nValue, bIncrease = d.bIncrease}) end
    table.sort(tSortedStatsChanged, function (a,b) return a.nSortOrder < b.nSortOrder end )

    --Secondary stats: crit hit, avoidance, focus regen, etc
    for idx,stat in pairs(tSortedStatsChanged) do
        local key = stat.key
        local wndSum = Apollo.LoadForm(self.xmlDoc, "ListSummaryItem", wndList, self)
        if not tMilestonesStatConvert[key] and self.tSettings[key] and math.abs(tStatsChanged[key].nValue) > .002 then --Don't display primary attributes or filtered items and make sure the change is significant
            local strline = self:FormatStat(key,tStatsChanged[key].nValue,tStatsChanged[key].bIncrease)
            wndSum:SetAML(strline)
            wndSum:SetHeightToContentHeight()
            if key == Unit.CodeEnumProperties.PvPOffensiveRating and self.tSettings["PvPHealing"] then --do it again for pvp healing TODO: make this less awkward, less repeated code
                local wndSum = Apollo.LoadForm(self.xmlDoc, "ListSummaryItem", wndList, self)
                strline = self:FormatStat("PvPHealing",tStatsChanged[key].nValue,tStatsChanged[key].bIncrease)
                wndSum:SetAML(strline)
                wndSum:SetHeightToContentHeight()
            end
        end
    end

    --Rune slot valuation
    if self.tSettings["bShowRuneValues"] then
        local arRunes = self:RuneArrayHelper(item)
        local arRunesComp = self:RuneArrayHelper(itemComp)
        local strBudgets = ""
        local nRunes = #arRunes > #arRunesComp and #arRunes or #arRunesComp
        for idx=1, nRunes do
            local nBudget = arRunes[idx] and math.floor(arRunes[idx].nBudget) or "0"
            local diff = (arRunes[idx] and math.floor(arRunes[idx].nBudget) or 0) - (arRunesComp[idx] and math.floor(arRunesComp[idx].nBudget) or 0)
            if itemComp then
                nBudget = string.format("%s<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">[%s%s]</T>",nBudget, 
                    diff >= 0 and kUIGreen or kUIRed, diff > 0 and "+" or "", math.floor(diff))
            end
            if idx > 1 then strBudgets = strBudgets .. ", " end
            strBudgets = string.format("%s<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>", strBudgets, kUIBody,tostring(nBudget))
        end
        local wndSum = Apollo.LoadForm(self.xmlDoc, "ListSummaryItem", wndList, self)
        local strline = string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">Rune slot valuation: </T>%s",
            kUIBody, strBudgets) 
        wndSum:SetAML(strline)
        wndSum:SetHeightToContentHeight()

    end
    --Adjust tooltip hieght to fit content
    local sumHeight = wndList:ArrangeChildrenVert()
    wndSummary:SetAnchorOffsets(0, 0, 0, sumHeight)
    wndControl:FindChild("Items"):ArrangeChildrenVert()
    wndControl:Move(0, 0, wndControl:GetWidth(), wndControl:GetHeight() + sumHeight + (self.tSettings["bShowItemID"] and nItemIDSpacing or 0))
end

function TooltipTests:FormatStat(key, nValue, bIncrease)
    local convert = tStatConverstionFuncs[key] or function (a,b) return b end --use converstion function or if not present use raw value
    
    local strline = string.format("<T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s%.2f%s </T><T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\">%s</T>",
            bIncrease and kUIGreen or kUIRed, bIncrease and "+" or "" ,convert(self,nValue),
            tPercentageStats[key] or "", tStatColors[key]~=nil and tStatColors[key] or kUIBody, tSecondaryAttributeToText[key] or ktAttributeToText[key])
    if self.tSettings["bShowRating"] and tStatConverstionFuncs[key] then --if setting is true and there is a conversion
        strline = string.format("%s <T Font=\"CRB_InterfaceSmall\" TextColor=\"%s\"> [%.1f rating]</T>", strline, bIncrease and kUIGreen or kUIRed,
            nValue)
    end
    return strline
end

function TooltipTests:CheckForMilestone(stat, increase)
    if increase == 0 then return end
    local tMilestones = AttributeMilestonesLib.GetAttributeMilestoneInfo().tMilestones[tMilestonesStatConvert[stat]].tAttributeMilestones
    local CurrentValue = GameLib.GetPlayerUnit():GetUnitProperty(stat).fValue
    local floor = 1
    local roof = nil
    --find location in milestones
    for idx,MS in pairs(tMilestones) do
        if MS.bIsMini then
            if CurrentValue < MS.nRequiredAmount then
                roof = idx
                break
            elseif CurrentValue >= MS.nRequiredAmount then
                floor = idx
            end
        end
    end
    --get stat increases
    local tMilestonesIncreases = nil
    if roof and increase > 0 then
        local nNewValue = CurrentValue + increase
        for idx = roof,#tMilestones do --check if we hit more than one milestone
            if nNewValue >= tMilestones[idx].nRequiredAmount then
                if not tMilestonesIncreases then tMilestonesIncreases = {} end
                if tMilestones[idx].bIsMini then
                    table.insert(tMilestonesIncreases, {fIncrease = tMilestones[idx].fModifier, eStat = tMilestones[idx].eUnitProperty, bIncrease = true})
                end
            else
                break
            end
        end
    end
    if floor and increase < 0 then
        local nNewValue = CurrentValue + increase
        for idx = floor, 1,-1 do
            if nNewValue < tMilestones[idx].nRequiredAmount then
                if not tMilestonesIncreases then tMilestonesIncreases = {} end
                if tMilestones[idx].bIsMini then
                    table.insert(tMilestonesIncreases, {fIncrease = tMilestones[idx].fModifier * -1, eStat = tMilestones[idx].eUnitProperty, bIncrease = false})
                end
            end
        end
    end

    return tMilestonesIncreases
end

--creates associatative table of primary and secondary stats in tStats
function TooltipTests:DerivedStatsHelper(tProps, tStats)
    if not tProps then return end
    for idx,stat in pairs(tProps) do
        if stat.arDerived then
            if tStats[stat.eProperty] then 
                tStats[stat.eProperty].nValue = tStats[stat.eProperty].nValue + stat.nValue --add to existing stat
            else tStats[stat.eProperty] = stat --add non-derived stat: strength, etc
            end
            for idx2,inner in pairs(stat.arDerived) do
                if tStats[inner.eProperty] then
                    tStats[inner.eProperty].nValue = tStats[inner.eProperty].nValue + inner.nValue
                else
                    tStats[inner.eProperty] = inner 
                end
            end
        elseif stat.nValue then --secondary stat ex. crit, focusregen. Check made for stats without a value like an empty rune slot
            if tStats[stat.eProperty] then --already exsits
                tStats[stat.eProperty].nValue = tStats[stat.eProperty].nValue + stat.nValue
            else
                tStats[stat.eProperty] = stat
            end
        end
    end
end

function TooltipTests:RuneStatsHelper(tRuneData, tStats )
    if self.tSettings["bExcludeRunes"] then return end -- option to not include runes in summary
    if tRuneData.arRuneSlots then
        self:DerivedStatsHelper(tRuneData.arRuneSlots, tStats)
    end
end

function TooltipTests:RuneArrayHelper(item)
    local arRunes = {}
    if not item then return arRunes end
    local tRunes = item:GetDetailedInfo().tPrimary.tRunes
    if tRunes and tRunes.arRuneSlots then
        arRunes = tRunes.arRuneSlots
    end
    return arRunes
end

----------Ratings to secondary stats converstions-----------
function TooltipTests:ConvertCritRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.BaseCritChance).fValue --adjusted base with amps, etc included
    local nCritTotal = UnitPlayer:GetCritChance()
    local nCritRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Rating_CritChanceIncrease).fValue --total crit rating
    if nCritRating <= 0 then return nCritPerRating * nValue end -- this should never happen, but just in case return default
    nCritPerRating = (nCritTotal - nBase)/nCritRating * 100
    return nCritPerRating * nValue
end

function TooltipTests:ConvertCritSevRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.CriticalHitSeverityMultiplier).fValue --adjusted base with amps, etc included
    local nCritSevTotal = UnitPlayer:GetCritSeverity()
    local nCritSevRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.RatingCritSeverityIncrease).fValue 
    if nCritSevRating <= 0 then return nValue * nCritSevPerRating end -- this should never happen, but just in case return default
    nCritSevPerRating = (nCritSevTotal - nBase)/nCritSevRating * 100
    if UnitPlayer:GetBasicStats().nLevel == 50 then
        return  ((nCritSevRating + nValue)/(1.4*(nCritSevRating + nValue) + 2825) - nCritSevRating/(1.4*nCritSevRating + 2825)) * 100 --credit to AGrue on the wildstar forums for this fomula
    else 
        return nValue * nCritSevPerRating * .8 
    end
end

function TooltipTests:ConvertStrikeRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.BaseAvoidReduceChance).fValue --adjusted base with amps, etc included
    local nStrikeTotal = UnitPlayer:GetStrikethroughChance()
    local nStrikeRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Rating_AvoidReduce).fValue
    if nStrikeRating <= 0 then return nValue * nStrikePerRating end -- this should never happen, but just in case return default
    nStrikePerRating = (nStrikeTotal - nBase)/nStrikeRating * 100
    return nValue * nStrikePerRating
end

function TooltipTests:ConvertDeflectRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.BaseAvoidChance).fValue --adjusted base with amps, etc included
    local nAvoidTotal = UnitPlayer:GetDeflectChance()
    local nAvoidRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Rating_AvoidIncrease).fValue
    if nAvoidRating <= 0 then return nValue * nDeflectPerRating end -- this should never happen, but just in case return default
    nDeflectPerRating = (nAvoidTotal - nBase)/nAvoidRating * 100
    return nValue * nDeflectPerRating
end

function TooltipTests:ConvertDeflectCritRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.BaseAvoidCritChance).fValue --adjusted base with amps, etc included
    local nAvoidCritTotal = UnitPlayer:GetDeflectCritChance()
    local nAvoidCritRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Rating_CritChanceDecrease).fValue 
    if nAvoidCritRating <= 0 then return nValue * nDeflectCritPerRating end -- this should never happen, but just in case return default
    nDeflectCritPerRating = (nAvoidCritTotal - nBase)/nAvoidCritRating * 100
    return nValue * nDeflectCritPerRating
end

function TooltipTests:ConvertFocusRegRating(nValue)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nBase = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.ManaRegenInCombat).fValue * 2000 -- given in focus per half second
    local nManaRegenTotal = UnitPlayer:GetManaRegenInCombat() * 2 --again in half seconds
    local nManaRegenRating = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.ManaPerFiveSeconds).fValue 
    if nManaRegenRating <= 0 then 
        if UnitPlayer:GetBasicStats().nLevel == 50 then
            return nValue * nFocusRegPerRatingFifty -- This may likely happen
        else
            return nValue * nFocusRegPerRating -- This may likely happen
        end
    end
    nFocusRegPerRating = (nManaRegenTotal - nBase)/nManaRegenRating
    return nValue * nFocusRegPerRating
end

function TooltipTests:ConvertArmorToDamageReduction(nValue)
    --Known: does not consider individual resistances, will be inacurate in the rare case a player has resistances
    --TODO: add another funcion to call in place of this one should resist > 0
    local UnitPlayer = GameLib.GetPlayerUnit()
    local armor = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Armor).fValue
    local level = UnitPlayer:GetBasicStats().nLevel
    local DRBefore = armor /(armor + ((250*level)+200))
    local DRAfter = (armor + nValue)/(armor + nValue + ((250*level)+200))
    return (DRAfter - DRBefore) * 100
end

function TooltipTests:ConvertResistToDamageReduction(nArmor, nValue, enumResist) --nValue = increase in enumResist, nArmor increase in armor
    if not nValue then nValue = 0 end --nil check
    local UnitPlayer = GameLib.GetPlayerUnit()
    local armor = UnitPlayer:GetUnitProperty(Unit.CodeEnumProperties.Armor).fValue
    local resist = UnitPlayer:GetUnitProperty(enumResist).fValue
    local level = UnitPlayer:GetBasicStats().nLevel
    local DRBefore = (armor + resist)/((armor + resist) + ((250*level)+200))
    local DRAfter = (armor + resist + nValue + nArmor)/((armor + resist + nValue + nArmor) + ((250*level)+200))
    return (DRAfter - DRBefore) * 100
end

function TooltipTests:ConvertPvPOffenseRating(nValue)
    return self:PvPRating(nValue)
end

function TooltipTests:ConvertPvPHealingRating(nValue)
    if GameLib.GetPlayerUnit():GetBasicStats().nLevel == 50 then
        return nValue * nPvPHealingperRating
    end
    return nValue * nPvPHealRoughPerPoint
end

function TooltipTests:ConvertPvPDefenseRating(nValue)
    return self:PvPRating(nValue)
end

function  TooltipTests:PvPRating(nValue)
    if GameLib.GetPlayerUnit():GetBasicStats().nLevel == 50 then
        return nValue * nPvPOffDefPerRating
    end
    return nValue * nPvPRoughPerPoint
end

function TooltipTests:PvPOffenseCombinedRatings(nValue)
    local strHealing = Apollo.GetString("Character_PvPHealLabel")
    local strDamage  = Apollo.GetString("Character_PvPOffenseLabel")
    local strCombined = ""
    strCombined = strCombined .. self:ConvertPvPOffenseRating(nValue) .. "% " .. strDamage
    if self.tSettings["bShowPvPHealing"] then
        strCombined = strCombined .. self:ConvertPvPHealingRating(nValue) .. "% " .. strHealing
    end
    return strCombined
end

--Not used currently, for future use
function TooltipTests:GenericAssaultDPS(nHitChance, nArmor, enumAssaultOrSupport)
    local UnitPlayer = GameLib.GetPlayerUnit()
    local nStrike = UnitPlayer:GetStrikethroughChance()
    local nCritSev = UnitPlayer:GetCritSeverity()
    local nCrit = UnitPlayer:GetCritChance()
    local nHaste = UnitPlayer:GetCooldownReductionModifier()
    local nArmorPen = UnitPlayer:GetIgnoreArmorBase()
    local nAssault = unitPlayer:GetAssaultPower()
    local nSupport = UnitPlayer:GetSupportPower()
    local nDamage = 0
    if enumAssaultOrSupport == 1 then -- assault
        nDamage = nAssault
    elseif enumAssaultOrSupport == 2 then -- suppport
        nDamage = nSupport
    else -- both
        nDamage = .5 * nSupport + .5 * nAssault
    end
    local nDamageReduce = self:ConvertArmorToDamageReduction(nArmor * nArmorPen)
    local DPS = (.90 + nStrike) * (nDamage(1 - nCrit)+ nDamage * nCrit * nCritSev) * nDamageReduce * nHaste
    return DPS
end

function TooltipTests:OnGeminiColor(strColor, strWindow)
    if strColor and strWindow then
        local wnd = self.wndOptions:FindChild(strWindow)
        tStatColors[wnd:GetData()] = strColor
        wnd:SetBGColor(strColor)
    end
    self.bPickingColor = false
end

-----------------------------------------------------------------------------------------------
-- TooltipTestsForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function TooltipTests:OnOK()
    self.wndOptions:Close() -- hide the window
end

function TooltipTests:OnDefaultSettings(wndHandler, wndControl, eMouseButton)
    self:DefaultSettings()
    self:RefreshOptions()
end

function TooltipTests:OnColorPicker(wndHandler, wndControl, eMouseButton)
    if wndHandler ~= wndControl or eMouseButton ~= GameLib.CodeEnumInputMouse.Left or self.bPickingColor then return end --only launch on left click
    --force a callback on cancel
    local oldCancel = aGeminiColor.OnCancel
    aGeminiColor.OnCancel = function (wndH, wndC, eM)
        oldCancel(wndH, wndC, eM)
        self:OnGeminiColor(nil, nil)
    end
    self.bPickingColor = true --we don't want to launch more than one color picker at once
    aGeminiColor:ShowColorPicker(self, self.OnGeminiColor, true, tStatColors[wndControl:GetData()] or kUIBody, wndControl:GetName())
end

function TooltipTests:RefreshOptions()
    self.wndOptions:FindChild("ChkShowItemPower"):SetCheck(self.tSettings["bShowItemPower"])
    self.wndOptions:FindChild("ChkShowMilestones"):SetCheck(self.tSettings["bShowMileStones"])
    self.wndOptions:FindChild("ChkShowCrit"):SetCheck(self.tSettings[Unit.CodeEnumProperties.Rating_CritChanceIncrease])
    self.wndOptions:FindChild("ChkShowCritSev"):SetCheck(self.tSettings[Unit.CodeEnumProperties.RatingCritSeverityIncrease])
    self.wndOptions:FindChild("ChkShowStrikeThrough"):SetCheck(self.tSettings[Unit.CodeEnumProperties.Rating_AvoidReduce])
    self.wndOptions:FindChild("ChkShowDeflect"):SetCheck(self.tSettings[Unit.CodeEnumProperties.Rating_AvoidIncrease])
    self.wndOptions:FindChild("ChkShowDeflectCrit"):SetCheck(self.tSettings[Unit.CodeEnumProperties.Rating_CritChanceDecrease])
    self.wndOptions:FindChild("ChkShowFocusRegen"):SetCheck(self.tSettings[Unit.CodeEnumProperties.ManaPerFiveSeconds])
    self.wndOptions:FindChild("ChkHealth"):SetCheck(self.tSettings[Unit.CodeEnumProperties.BaseHealth])
    self.wndOptions:FindChild("ChkSupportPower"):SetCheck(self.tSettings[Unit.CodeEnumProperties.SupportPower])
    self.wndOptions:FindChild("ChkAssultPower"):SetCheck(self.tSettings[Unit.CodeEnumProperties.AssaultPower])
    self.wndOptions:FindChild("ChkArmor"):SetCheck(self.tSettings["bArmor"])
    self.wndOptions:FindChild("ChkShield"):SetCheck(self.tSettings[Unit.CodeEnumProperties.ShieldCapacityMax])
    self.wndOptions:FindChild("ChkShowRating"):SetCheck(self.tSettings["bShowRating"])
    self.wndOptions:FindChild("ChkRunes"):SetCheck(self.tSettings["bExcludeRunes"])
    self.wndOptions:FindChild("ChkPvPOffense"):SetCheck(self.tSettings[Unit.CodeEnumProperties.PvPOffensiveRating])
    self.wndOptions:FindChild("ChkPvPDefense"):SetCheck(self.tSettings[Unit.CodeEnumProperties.PvPDefensiveRating])
    self.wndOptions:FindChild("ChkPvPHealing"):SetCheck(self.tSettings["PvPHealing"])
    self.wndOptions:FindChild("ChkRuneValuation"):SetCheck(self.tSettings["bShowRuneValues"])
    self.wndOptions:FindChild("ChkItemID"):SetCheck(self.tSettings["bShowItemID"])  
    self.wndOptions:FindChild("ChkPhysResist"):SetCheck(self.tSettings[Unit.CodeEnumProperties.ResistPhysical])
    self.wndOptions:FindChild("ChkTechResist"):SetCheck(self.tSettings[Unit.CodeEnumProperties.ResistTech])
    self.wndOptions:FindChild("ChkMagicResist"):SetCheck(self.tSettings[Unit.CodeEnumProperties.ResistMagic])

    self.wndOptions:FindChild("AssaultColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.AssaultPower] or kUIBody)
    self.wndOptions:FindChild("SupportColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.SupportColor] or kUIBody)
    self.wndOptions:FindChild("CritColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.Rating_CritChanceIncrease] or kUIBody)
    self.wndOptions:FindChild("CritSevColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.RatingCritSeverityIncrease] or kUIBody)
    self.wndOptions:FindChild("StrikeColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.Rating_AvoidReduce] or kUIBody)
    self.wndOptions:FindChild("DeflectColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.Rating_AvoidIncrease] or kUIBody)
    self.wndOptions:FindChild("DeflectCritColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.Rating_CritChanceDecrease] or kUIBody)
    self.wndOptions:FindChild("FocusRegenColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.ManaPerFiveSeconds] or kUIBody) 
    self.wndOptions:FindChild("HealthColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.BaseHealth] or kUIBody)
    self.wndOptions:FindChild("ShieldColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.ShieldCapacityMax] or kUIBody)
    self.wndOptions:FindChild("PvPOffenseColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.PvPOffensiveRating] or kUIBody)
    self.wndOptions:FindChild("PvPDefenseColor"):SetBGColor(tStatColors[Unit.CodeEnumProperties.PvPDefensiveRating] or kUIBody)

end

function TooltipTests:SetupOptions()
    self.wndOptions:FindChild("ChkShowItemPower"):SetData("bShowItemPower")
    self.wndOptions:FindChild("ChkShowMilestones"):SetData("bShowMileStones")
    self.wndOptions:FindChild("ChkShowCrit"):SetData(Unit.CodeEnumProperties.Rating_CritChanceIncrease)
    self.wndOptions:FindChild("ChkShowCritSev"):SetData(Unit.CodeEnumProperties.RatingCritSeverityIncrease)
    self.wndOptions:FindChild("ChkShowStrikeThrough"):SetData(Unit.CodeEnumProperties.Rating_AvoidReduce)
    self.wndOptions:FindChild("ChkShowDeflect"):SetData(Unit.CodeEnumProperties.Rating_AvoidIncrease)
    self.wndOptions:FindChild("ChkShowDeflectCrit"):SetData(Unit.CodeEnumProperties.Rating_CritChanceDecrease)
    self.wndOptions:FindChild("ChkShowFocusRegen"):SetData(Unit.CodeEnumProperties.ManaPerFiveSeconds)
    self.wndOptions:FindChild("ChkHealth"):SetData(Unit.CodeEnumProperties.BaseHealth)
    self.wndOptions:FindChild("ChkSupportPower"):SetData(Unit.CodeEnumProperties.SupportPower)
    self.wndOptions:FindChild("ChkAssultPower"):SetData(Unit.CodeEnumProperties.AssaultPower)
    self.wndOptions:FindChild("ChkArmor"):SetData("bArmor")
    self.wndOptions:FindChild("ChkShield"):SetData(Unit.CodeEnumProperties.ShieldCapacityMax)
    self.wndOptions:FindChild("ChkRunes"):SetData("bExcludeRunes")
    self.wndOptions:FindChild("ChkPvPOffense"):SetData(Unit.CodeEnumProperties.PvPOffensiveRating)
    self.wndOptions:FindChild("ChkPvPDefense"):SetData(Unit.CodeEnumProperties.PvPDefensiveRating)
    self.wndOptions:FindChild("ChkShowRating"):SetData("bShowRating")
    self.wndOptions:FindChild("ChkPvPHealing"):SetData("PvPHealing")
    self.wndOptions:FindChild("ChkRuneValuation"):SetData("bShowRuneValues")
    self.wndOptions:FindChild("ChkItemID"):SetData("bShowItemID")
    self.wndOptions:FindChild("ChkPhysResist"):SetData(Unit.CodeEnumProperties.ResistPhysical)
    self.wndOptions:FindChild("ChkTechResist"):SetData(Unit.CodeEnumProperties.ResistTech)
    self.wndOptions:FindChild("ChkMagicResist"):SetData(Unit.CodeEnumProperties.ResistMagic)
    --Colors
    self.wndOptions:FindChild("AssaultColor"):SetData(Unit.CodeEnumProperties.AssaultPower)
    self.wndOptions:FindChild("SupportColor"):SetData(Unit.CodeEnumProperties.SupportPower)
    self.wndOptions:FindChild("CritColor"):SetData(Unit.CodeEnumProperties.Rating_CritChanceIncrease)
    self.wndOptions:FindChild("CritSevColor"):SetData(Unit.CodeEnumProperties.RatingCritSeverityIncrease)
    self.wndOptions:FindChild("StrikeColor"):SetData(Unit.CodeEnumProperties.Rating_AvoidReduce)
    self.wndOptions:FindChild("DeflectColor"):SetData(Unit.CodeEnumProperties.Rating_AvoidIncrease)
    self.wndOptions:FindChild("DeflectCritColor"):SetData(Unit.CodeEnumProperties.Rating_CritChanceDecrease)
    self.wndOptions:FindChild("FocusRegenColor"):SetData(Unit.CodeEnumProperties.ManaPerFiveSeconds)
    self.wndOptions:FindChild("HealthColor"):SetData(Unit.CodeEnumProperties.BaseHealth)
    self.wndOptions:FindChild("ShieldColor"):SetData(Unit.CodeEnumProperties.ShieldCapacityMax)
    self.wndOptions:FindChild("PvPOffenseColor"):SetData(Unit.CodeEnumProperties.PvPOffensiveRating)
    self.wndOptions:FindChild("PvPDefenseColor"):SetData(Unit.CodeEnumProperties.PvPDefensiveRating)

    self:RefreshOptions()
    self:ArrangeChildrenVertAndResize(self.wndOptions:FindChild("MiscContainer"))
    self:ArrangeChildrenVertAndResize(self.wndOptions:FindChild("OffensiveContainer"))
    self:ArrangeChildrenVertAndResize(self.wndOptions:FindChild("DefensiveContainer"))
    self:ArrangeChildrenVertAndResize(self.wndOptions:FindChild("ListDisplayOptions"), 15)
    self.wndOptions:FindChild("ListOptions"):ArrangeChildrenVert()
end

function TooltipTests:ArrangeChildrenVertAndResize(wnd, additionalHeight)
    local height = wnd:ArrangeChildrenVert()
    local x,y,x2,y2 = wnd:GetAnchorOffsets()
    wnd:SetAnchorOffsets(x,y,x2,y + height + (additionalHeight or 0))
end

function TooltipTests:OnDisplayCheckedChange( wndHandler, wndControl, eMouseButton )
    self.tSettings[wndHandler:GetData()] = wndControl:IsChecked()
end

function TooltipTests:OnArmorCheckedChange(wndHandler, wndControl)
    if wndHandler ~= wndControl then return end
    self.tSettings[wndHandler:GetData()] = wndControl:IsChecked()
    local bEnable = wndControl:IsChecked()
    self.wndOptions:FindChild("ChkPhysResist"):Enable(bEnable)
    self.wndOptions:FindChild("ChkTechResist"):Enable(bEnable)
    self.wndOptions:FindChild("ChkMagicResist"):Enable(bEnable)
end

-----------------------------------------------------------------------------------------------
-- Save/restore
-----------------------------------------------------------------------------------------------

function TooltipTests:OnSave(eType)
    if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return
    end
    tData = {}
    tData.tRatingConverstions = {
        dCritPerRating        = nCritPerRating,
        dCritSevPerRating     = nCritSevPerRating,
        dStrikePerRating      = nStrikePerRating,
        dDeflectPerRating     = nDeflectPerRating,
        dDeflectCritPerRating = nDeflectCritPerRating,
        dFocusRegPerRating    = nFocusRegPerRating
    }
    tData.tSettings = self.tSettings
    tData.tStatColors = tStatColors
    return tData
end

function TooltipTests:OnRestore(eType, tData)
    if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
      return
    end
    if not tData then return end
    if tData.tRatingConverstions then
        nCritPerRating        = tData.tRatingConverstions.dCritPerRating
        nCritSevPerRating     = tData.tRatingConverstions.dCritSevPerRating
        nStrikePerRating      = tData.tRatingConverstions.dStrikePerRating
        nDeflectPerRating     = tData.tRatingConverstions.dDeflectPerRating
        nDeflectCritPerRating = tData.tRatingConverstions.dDeflectCritPerRating
        nFocusRegPerRating    = tData.tRatingConverstions.dFocusRegPerRating
    end
    if tData.tSettings then
        self.tSettings = tData.tSettings
        setmetatable(self.tSettings, {__index = tDefaultSettings}) -- set metatable so we use defaults for missing entries
    end
    if tData.tStatColors then
        tStatColors = tData.tStatColors
    end
end
-----------------------------------------------------------------------------------------------
-- TooltipTests Instance
-----------------------------------------------------------------------------------------------
local TooltipTestsInst = TooltipTests:new()
TooltipTestsInst:Init()
