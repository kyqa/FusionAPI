--[[
This module contains a lot of utility functions, as well as the central team database.

This file contains the following features:
* College Teams Database
* Config File Reading/Saving/Updating

Created by Supermrk (@supermrk)
]]

local Services = {
    HTTP = game:GetService("HttpService")
}

-----------------------------------------------------------------------
-- Script API Declarations
-----------------------------------------------------------------------
local isfile = isfile
local readfile = readfile
local writefile = writefile

local module = {}

function module:GetTeam(teamName)
    if (string.lower(teamName) == "south carolina") then
        return {
            City = "South Carolina",
            Name = "Gamecocks",
            Abbreviation = "SC",
            Colors = {
                Normal = {
                    Main = "#73000A",
                    Light = "#B2000F"
                },
                Alternate = {
                    Main = "#171717",
                    Light = "#2E2E2E"
                },
                Endzone = "#000000",
                Jersey = {
                    Home = {
                        NumberInner = "#FFFFFF",
                        NumberStroke = "#000000",
                        Helmet = "#FFFFFF",
                        Jersey = "#73000A",
                        Stripe = "#FFFFFF",
                        Pants = "#FFFFFF"
                    },
                    Away = {
                        NumberInner = "#73000A",
                        NumberStroke = "#000000",
                        Helmet = "#FFFFFF",
                        Jersey = "#FFFFFF",
                        Stripe = "#000000",
                        Pants = "#73000A"
                    }
                }
            },
        }
    elseif (string.lower(teamName) == "michigan state") then
        return {
            City = "Michigan State",
            Name = "Spartans",
            Abbreviation = "MSU",
            Colors = {
                Normal = {
                    Main = "#18453B",
                    Light = "#2E8572"
                },
                Alternate = {
                    Main = "#808080",
                    Light = "#ABABAB"
                },
                Endzone = "#297362",
                Jersey = {
                    Home = {
                        NumberInner = "#FFFFFF",
                        NumberStroke = "#18453B",
                        Helmet = "#18453B",
                        Jersey = "#18453B",
                        Stripe = "#FFFFFF",
                        Pants = "#18453B"
                    },
                    Away = {
                        NumberInner = "#18453B",
                        NumberStroke = "#FFFFFF",
                        Helmet = "#18453B",
                        Jersey = "#FFFFFF",
                        Stripe = "#FFFFFF",
                        Pants = "#18453B"
                    }
                }
            },
        }
    end
    return nil
end

local RSPNChannels = {
    ["RoSportProgrammingNetwork"] = "730050166",
    ["RSPN_2"] = "846285089",
    ["RSPN3"] = "846285510",
    ["RSPN4"] = "875247498",
    ["RSPN_5"] = "875247935",
    ["RSPNDeportes"] = "875248189"
}

function module:GetRSPNChannels()
    return RSPNChannels
end

function module:GetChannelID(channel)
    return RSPNChannels[channel]
end

function module:FormatClock(seconds : number)
    local minutes = (seconds - seconds%60)/60
    seconds = seconds-minutes*60
    local zero = ""
    if (seconds < 10) then
        zero = "0"
    end

    return minutes .. ":" .. zero .. seconds
end

function module:FormatNumber(number : number)
    if (number == 1) then
        return "1st"
    elseif (number == 2) then
        return "2nd"
    elseif (number == 3) then
        return "3rd"
    elseif (number == 4) then
        return "4th"
    elseif (number >= 5) then
        return "OT " .. number-4
    end
end

local DefaultConfig = {
    GameInfo = {
        Away = "AWAY_TEAM_HERE",
        AwayRank = 0,
        Home = "HOME_TEAM_HERE",
        HomeRank = 0,
        Primetime = "false",
        Series = "SERIES_HERE",
        Season = "SEASON_HERE",
        League = "LEAGUE_HERE"
    },
    Settings = {
        AssetsFilePath = "",
        AutoTwitchClipping = "false",
        AutoTwitchUpdates = "false",
        Channel = "",
        SendToWebhook = "false",
        TwitchAuthCode = "",
        UploadStatsToDatabase = "false",
        UploadToRealtimeAPI = "false"
    }
}
function ReadConfigArray(default, compare)
    local returnTable = {}

    for i,v in pairs(compare) do
        if (default[i] and type(default[i]) == type(v)) then
            if (type(v) == "table") then
                returnTable[i] = ReadConfigArray(default[i], v)
            else
                returnTable[i] = v
            end
        elseif (default[i]) then
            returnTable[i] = default[i]
        end
    end

    for i,v in pairs(default) do
        if not (returnTable[i]) then
            returnTable[i] = v
        end
    end

    return returnTable
end

function module:GetConfig()
    local succ,result = pcall(function()
        return readfile("config.json")
    end)
    if (succ) then
        succ,result = pcall(function()
            return Services["HTTP"]:JSONDecode(result)
        end)
    end
    if not (succ) then
        writefile("config.json", Services["HTTP"]:JSONEncode(DefaultConfig))
        print("[Utilities] Failed to get the config file. We returned the default config.")
        return DefaultConfig
    end

    local config = ReadConfigArray(DefaultConfig,result)
    writefile("config.json", Services["HTTP"]:JSONEncode(config))
    print("[Utilities] Successfully got the config file.")
    return config
end

return module
