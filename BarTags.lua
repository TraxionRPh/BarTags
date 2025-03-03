local BarTags = LibStub("AceAddon-3.0"):NewAddon("BarTags", "AceConsole-3.0", "AceEvent-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local defaults = {
    profile = {
        groups = {},
        defaultColor = { r = 0.5, g = 0.5, b = 0.5 },
        showGroupTagTooltip = true,
        showActionBarIDs = true,
        minimap = {
            hide = false,
            minimapPos = 180,
        }
    },
}

local barMapping = {
    [1] = "ActionButton",
    [2] = "MultiBarBottomLeftButton",
    [3] = "MultiBarBottomRightButton",
    [4] = "MultiBarRightButton",
    [5] = "MultiBarLeftButton",
    [6] = "MultiBar5Button",
    [7] = "MultiBar6Button",
    [8] = "MultiBar7Button"
}

local containerMapping = {
    [1] = "MainMenuBar",
    [2] = "MultiBarBottomLeft",
    [3] = "MultiBarBottomRight",
    [4] = "MultiBarRight",
    [5] = "MultiBarLeft",
    [6] = "MultiBar5",
    [7] = "MultiBar6",
    [8] = "MultiBar7",
}


local function GetButtonIndex(button)
    local name = button:GetName()
    if name then
        return tonumber(name:match("%d+$"))
    end
end

function BarTags:GetGroupFromButton(button)
    local btnIndex = GetButtonIndex(button)
    if not btnIndex then
        return nil
    end
    for key, group in pairs(self.db.profile.groups or {}) do
        if group and group.bars then
            for barID, selected in pairs(group.bars) do
                if selected then
                    local prefix = barMapping[barID]
                    if prefix and button:GetName():find(prefix) then
                        if btnIndex >= (group.start or 1) and btnIndex <= (group["end"] or 12) then
                            return group
                        end
                    end
                end
            end
        end
    end
    return nil
end

local GroupTagTooltip = CreateFrame("GameTooltip", "GroupTagTooltip", UIParent, "GameTooltipTemplate")
GroupTagTooltip:SetScale(1)
GroupTagTooltip:SetFrameStrata("TOOLTIP")
GroupTagTooltip.ignoreFramePositionManager = true

local function ShowGroupTagTooltip(self)
    if not BarTags.db.profile.showGroupTagTooltip then
        return
    end
    local group = BarTags:GetGroupFromButton(self)
    if group and group.name and group.name ~= "" then
        if GameTooltip:IsShown() then
            GroupTagTooltip:SetOwner(GameTooltip, "ANCHOR_NONE")
            GroupTagTooltip:ClearAllPoints()
            GroupTagTooltip:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 0 , 3)
        end
        local color = group.color or BarTags.db.profile.defaultColor
        GroupTagTooltip:SetText(group.name, color.r, color.g, color.b)
        GroupTagTooltip:Show()
    end
end


local function HideGroupTagTooltip(self)
    GroupTagTooltip:Hide()
end

local function HighlightActionButton(button, r, g, b)
    if not button then return end
    local normalTexture = button:GetNormalTexture() or _G[button:GetName() .. "NormalTexture"]
    if normalTexture then
        normalTexture:SetVertexColor(r, g, b)
    end
end

function BarTags:UpdateActionButtonHighlights()
    local db = self.db and self.db.profile
    if not (db and db.defaultColor and db.groups) then
        print("BarTags: Configuration not loaded properly.")
        return
    end

    local currentPage = GetActionBarPage()
    
    for barID, prefix in pairs(barMapping) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button then
                HighlightActionButton(button, db.defaultColor.r, db.defaultColor.g, db.defaultColor.b)
            end
        end
    end

    for key, group in pairs(db.groups) do
        if group and group.bars and group.bars[1] and group.start and group["end"] and group.color then
            if group.page and group.page == currentPage then
                for i = group.start, group["end"] do
                    local button = _G["ActionButton"..i]
                    if button then
                        HighlightActionButton(button, group.color.r, group.color.g, group.color.b)
                    end
                end
            end
        end
    end
    for barID, prefix in pairs(barMapping) do
        if barID ~= 1 then
            for key, group in pairs(db.groups) do
                if group and group.bars and group.bars[barID] and group.start and group["end"] and group.color then
                    for i = group.start, group["end"] do
                        local button = _G[prefix .. i]
                        if button then
                            HighlightActionButton(button, group.color.r, group.color.g, group.color.b)
                        end
                    end
                end
            end
        end
    end
end

local function GetOrCreateBarIDLabelFrame(barID, containerFrame)
    BarTags.barIDLabels = BarTags.barIDLabels or {}
    local frame = BarTags.barIDLabels[barID]
    if not frame then
        frame = CreateFrame("Frame", "BarTags_GroupIDLabelFrame"..barID, UIParent)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetFrameLevel(99)
        frame:SetSize(50, 20)
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        fs:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
        fs:SetAllPoints(frame)
        frame.fontString = fs
        BarTags.barIDLabels[barID] = frame
    end
    return frame
end

function BarTags:UpdateActionBarIDLabels()
    if not self.db.profile.showActionBarIDs or not self.selectedGroup then
        if self.barIDLabels then
            for _, frame in pairs(self.barIDLabels) do
                frame:Hide()
            end
        end
        return
    end

    local orderedIDs = {1, 2, 3, 4, 5, 6, 7, 8}
    for _, barID in ipairs(orderedIDs) do
        local containerName = containerMapping[barID]
        local containerFrame = _G[containerName]
        if containerFrame and containerFrame:IsShown() then
            local labelFrame = GetOrCreateBarIDLabelFrame(barID, containerFrame)
            labelFrame.fontString:SetText(tostring(barID))
            labelFrame:ClearAllPoints()
            labelFrame:SetPoint("RIGHT", containerFrame, "LEFT", -5, 0)
            labelFrame:Show()
        else
            if self.barIDLabels and self.barIDLabels[barID] then
                self.barIDLabels[barID]:Hide()
            end
        end
    end
end

local function GetActiveBarToggles(group)
    local toggles = {}
    local orderedIDs = {1, 2, 3, 4, 5, 6, 7, 8}
    local order = 1
    for _, barID in ipairs(orderedIDs) do
        local containerName = containerMapping[barID]
        local containerFrame = _G[containerName]
        if containerFrame and containerFrame:IsShown() then
            local displayName
            if barID == 1 then
                displayName = "Action Bar 1"
            elseif barID == 2 then
                displayName = "Action Bar 2"
            elseif barID == 3 then
                displayName = "Action Bar 3"
            elseif barID == 4 then
                displayName = "Action Bar 4"
            elseif barID == 5 then
                displayName = "Action Bar 5"
            elseif barID == 6 then
                displayName = "Action Bar 6"
            elseif barID == 7 then
                displayName = "Action Bar 7"
            elseif barID == 8 then
                displayName = "Action Bar 8"
            else
                displayName = "Bar " .. barID
            end

            toggles["bar" .. barID] = {
                type = "toggle",
                name = displayName,
                order = order,
                get = function(info)
                    return group.bars and group.bars[barID] or false
                end,
                set = function(info, value)
                    group.bars = group.bars or {}
                    group.bars[barID] = value
                    BarTags:UpdateActionButtonHighlights()
                    AceConfigRegistry:NotifyChange("BarTags")
                end,
            }
            order = order + 1
        end
    end
    return toggles
end

function BarTags:HideActionBarIDLabels()
    if self.barIDLabels then
        for barID, frame in pairs(self.barIDLabels) do
            frame:Hide()
        end
    end
end

local function GetGroupOptions(key, group)
    local options = {
        type = "group",
        name = group.name ~= "" and group.name or key,
        order = 10,
        args = {
            name = {
                type = "input",
                name = "Group Name",
                order = 1,
                get = function(info)
                    return group.name or ""
                end,
                set = function(info, value)
                    group.name = value
                    BarTags.selectedGroup = key
                    BarTags:UpdateActionButtonHighlights()
                    AceConfigRegistry:NotifyChange("BarTags")
                end,
            },
            bars = {
                type = "group",
                name = "Action Bars",
                inline = true,
                order = 2,
                args = GetActiveBarToggles(group),
            },
            start = (function()
                local endValue = group["end"] or 12
                return {
                    type = "range",
                    name = "Start Button",
                    order = 3,
                    desc = "Starting button index (cannot be greater than End)",
                    min = 1,
                    max = endValue,
                    step = 1,
                    get = function(info)
                        return group.start or 1
                    end,
                    set = function(info, value)
                        group.start = value
                        if (group["end"] or 12) < value then
                            group["end"] = value
                        end
                        BarTags:UpdateActionButtonHighlights()
                        AceConfigRegistry:NotifyChange("BarTags")
                    end,
                }
            end)(),
            ["end"] = (function()
                local startVal = group.start or 1
                return {
                    type = "range",
                    name = "End Button",
                    order = 4,
                    desc = "Ending button index (cannot be less than Start)",
                    min = startVal,
                    max = 12,
                    step = 1,
                    get = function(info)
                        return group["end"] or 12
                    end,
                    set = function(info, value)
                        group["end"] = value
                        if (group.start or 1) > value then
                            group.start = value
                        end
                        BarTags:UpdateActionButtonHighlights()
                        AceConfigRegistry:NotifyChange("BarTags")
                    end,
                }
            end)(),
            color = {
                type = "color",
                name = "Group Color",
                order = 5,
                hasAlpha = false,
                get = function(info)
                    local c = group.color or { r = 0.5, g = 0.5, b = 0.5 }
                    return c.r, c.g, c.b
                end,
                set = function(info, r, g, b)
                    group.color = { r = r, g = g, b = b }
                    BarTags:UpdateActionButtonHighlights()
                end,
            },
            remove = {
                type = "execute",
                name = "Remove Group",
                order = 6,
                func = function()
                    BarTags.db.profile.groups[key] = nil
                    AceConfigRegistry:NotifyChange("BarTags")
                    BarTags:UpdateActionButtonHighlights()
                end,
            },
        },
    }

    if group.bars and group.bars[1] then
        options.args.page = {
            type = "select",
            name = "Main Action Bar Page",
            desc = "Which page of the main action bar should this group apply to?",
            order = 2.5,
            values = { [1] = "Page 1", [2] = "Page 2" },
            get = function(info)
                return group.page or 1
            end,
            set = function(info, value)
                group.page = value
                BarTags:UpdateActionButtonHighlights()
                AceConfigRegistry:NotifyChange("BarTags")
            end,
        }
    end

    return options
end

local function GetGroupsOptions()
    local groupsOptions = {
        type = "group",
        name = "Groups",
        args = {},
    }

    for key, group in pairs(BarTags.db.profile.groups) do
        groupsOptions.args[key] = GetGroupOptions(key, group)
        if not BarTags.selectedGroup then
            BarTags.selectedGroup = key
        end
    end

    groupsOptions.args.addGroup = {
        type = "execute",
        name = "Add Group",
        order = 100,
        func = function()
            local newKey = "group" .. tostring(math.random(1000000))
            BarTags.db.profile.groups[newKey] = {
                name = "New Group",
                bars = { [1] = true },
                page = 1,
                start = 1,
                ["end"] = 12,
                color = { r = 0.5, g = 0.5, b = 0.5 },
            }
            AceConfigRegistry:NotifyChange("BarTags")
            BarTags:UpdateActionButtonHighlights()
        end,
    }

    return groupsOptions
end

function BarTags:EnsureSelectedGroup()
    if not self.selectedGroup then
        for key, group in pairs(self.db.profile.groups) do
            self.selectedGroup = key
            break
        end
    end
end


local function BuildOptions()
    return {
        name = "Bar Tags",
        type = "group",
        args = {
            showGroupTagTooltip = {
                type = "toggle",
                name = "Show Group Tooltip",
                desc = "Display the group name above a spell when mousing over it",
                order = 2,
                set = function(info, val)
                    BarTags.db.profile.showGroupTagTooltip = val
                end,
                get = function(info)
                    return BarTags.db.profile.showGroupTagTooltip
                end,
            },
            groups = GetGroupsOptions(),
        },
    }
end

function BarTags:OpenOptions()
    AceConfigDialog:Open("BarTags")
    BarTags.optionsOpen = true
    BarTags:UpdateActionBarIDLabels()

    local optionsWidget = AceConfigDialog.OpenFrames["BarTags"]
    if optionsWidget and optionsWidget.frame then
        optionsWidget.frame:HookScript("OnHide", function(self)
            BarTags:CloseOptions()
        end)
    end
end

function BarTags:CloseOptions()
    BarTags.optionsOpen = false
    BarTags:HideActionBarIDLabels()
    AceConfigDialog:Close("BarTags")
end

function BarTags:OnInitialize()
    self.db = AceDB:New("BarTagsDB", defaults, true)

    AceConfig:RegisterOptionsTable("BarTags", BuildOptions)
    local optionsFrame = AceConfigDialog:AddToBlizOptions("BarTags", "Bar Tags")
    optionsFrame:HookScript("OnShow", function(self)
        BarTags.optionsOpen = true
        BarTags:UpdateActionBarIDLabels()
    end)
    optionsFrame:HookScript("OnHide", function(self)
        BarTags.optionsOpen = false
        BarTags:HideActionBarIDLabels()
    end)

    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("BarTags", {
        type = "launcher",
        icon = "Interface\\AddOns\\BarTags\\Images\\barcode.png",
        OnClick = function(self, button)
            if button == "LeftButton" then
                BarTags:OpenOptions()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("BarTags")
            tooltip:AddLine("Left-click to edit groups")
        end,
    })

    local icon = LibStub("LibDBIcon-1.0")
    icon:Register("BarTags", ldb, self.db.profile.minimap)

    self:RegisterChatCommand("bartags", "OpenOptions")
    self:RegisterChatCommand("bt", "OpenOptions")

    self:UpdateActionButtonHighlights()
end

function BarTags:OnEnable()
    self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "UpdateActionButtonHighlights")
    for barID, prefix in pairs(barMapping) do
        for i = 1, 12 do
            local button = _G[prefix .. i]
            if button then
                button:EnableMouse(true)
                button:HookScript("OnEnter", function(self, ...)
                    C_Timer.After(0, function()
                        ShowGroupTagTooltip(self)
                    end)
                end)
                button:HookScript("OnLeave", HideGroupTagTooltip)
            end
        end
    end
    self:UpdateActionButtonHighlights()
end