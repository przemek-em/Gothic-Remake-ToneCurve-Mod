local UEHelpers = require("UEHelpers")

local MOD_NAME = "ToneCurveShowToggleMod"

local INITIAL_DELAY_MS = 1500
local RETRY_DELAY_MS = 1000
local RETRY_COUNT = 10

local Commands = {
    { command = "show ToneCurve", done = false },
}

local EngineCache = CreateInvalidObject()
local KismetSystemLibraryCache = CreateInvalidObject()

local function Log(Message)
    print(string.format("[%s] %s\n", MOD_NAME, Message))
end

local function SafeIsValid(Object)
    return Object and Object.IsValid and Object:IsValid()
end

local function SafeFindFirstOf(ClassName)
    local Ok, Object = pcall(FindFirstOf, ClassName)
    if Ok and SafeIsValid(Object) then return Object end
    return CreateInvalidObject()
end

local function SafeStaticFindObject(ObjectFullName)
    local Ok, Object = pcall(StaticFindObject, ObjectFullName)
    if Ok and SafeIsValid(Object) then return Object end
    return CreateInvalidObject()
end

local function GetEngine()
    if SafeIsValid(EngineCache) then return EngineCache end
    EngineCache = SafeFindFirstOf("Engine")
    return EngineCache
end

local function GetKismetSystemLibrary()
    if SafeIsValid(KismetSystemLibraryCache) then return KismetSystemLibraryCache end

    local Ok, Object = pcall(function()
        return UEHelpers.GetKismetSystemLibrary()
    end)

    if Ok and SafeIsValid(Object) then
        KismetSystemLibraryCache = Object
        return KismetSystemLibraryCache
    end

    KismetSystemLibraryCache = SafeStaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
    return KismetSystemLibraryCache
end

local function GetGameViewportClient()
    local Ok, Object = pcall(function()
        if UEHelpers.GetGameViewportClient then
            return UEHelpers.GetGameViewportClient()
        end
        return CreateInvalidObject()
    end)

    if Ok and SafeIsValid(Object) then return Object end

    local Engine = GetEngine()
    if SafeIsValid(Engine) then
        local ViewportOk, Viewport = pcall(function()
            return Engine.GameViewport
        end)
        if ViewportOk and SafeIsValid(Viewport) then return Viewport end
    end

    return CreateInvalidObject()
end

local function GetGameInstance()
    local Ok, Object = pcall(function()
        if UEHelpers.GetGameInstance then
            return UEHelpers.GetGameInstance()
        end
        return CreateInvalidObject()
    end)

    if Ok and SafeIsValid(Object) then return Object end
    return SafeFindFirstOf("GameInstance")
end

local function GetConsoleContext()
    local GameViewport = GetGameViewportClient()
    if SafeIsValid(GameViewport) then return GameViewport, "GameViewportClient" end

    local GameInstance = GetGameInstance()
    if SafeIsValid(GameInstance) then return GameInstance, "GameInstance" end

    local Engine = GetEngine()
    if SafeIsValid(Engine) then return Engine, "Engine" end

    return CreateInvalidObject(), "none"
end

local function ExecuteViaKismet(Command, Context, ContextLabel)
    local SystemLibrary = GetKismetSystemLibrary()
    if not SafeIsValid(SystemLibrary) then return false, "KismetSystemLibrary not ready" end

    local Ok, ErrorMessage = pcall(function()
        SystemLibrary:ExecuteConsoleCommand(Context, Command, nil)
    end)

    if Ok then return true end
    return false, "Kismet " .. tostring(ContextLabel) .. " failed: " .. tostring(ErrorMessage)
end

local function ExecuteViaProcessConsoleExec(Command, Engine)
    if not SafeIsValid(Engine) then return false, "Engine not ready" end

    local Ok, Result = pcall(function()
        return Engine:ProcessConsoleExec(Command, nil, Engine)
    end)

    if Ok and Result == true then return true end
    if Ok then return false, "ProcessConsoleExec returned " .. tostring(Result) end
    return false, "ProcessConsoleExec failed: " .. tostring(Result)
end

local function ExecuteConsoleCommand(Command)
    local Engine = GetEngine()
    local Context, ContextLabel = GetConsoleContext()
    if not SafeIsValid(Context) then
        return false, "no console context"
    end

    local KismetOk, KismetReason = ExecuteViaKismet(Command, Context, ContextLabel)
    if KismetOk then return true end

    local ExecOk, ExecReason = ExecuteViaProcessConsoleExec(Command, Engine)
    if ExecOk then return true end

    return false, KismetReason .. "; " .. ExecReason
end

local function ExecuteShowCommand(Command)
    return ExecuteConsoleCommand(Command)
end

local function AllDone()
    for _, Entry in ipairs(Commands) do
        if not Entry.done then return false end
    end
    return true
end

local function ApplyOnce(Attempt)
    Attempt = Attempt or 1

    ExecuteInGameThread(function()
        for _, Entry in ipairs(Commands) do
            if not Entry.done then
                local Ok, Reason = ExecuteShowCommand(Entry.command)
                if Ok then
                    Entry.done = true
                    Log("Executed once: " .. Entry.command)
                else
                    Log("Waiting to execute '" .. Entry.command .. "': " .. tostring(Reason))
                end
            end
        end

        if AllDone() then
            Log("All one-shot show commands completed.")
            return
        end

        if Attempt < RETRY_COUNT then
            ExecuteInGameThreadWithDelay(RETRY_DELAY_MS, function()
                ApplyOnce(Attempt + 1)
            end)
        else
            Log("Stopped retrying before all commands completed.")
        end
    end)
end

ExecuteInGameThreadWithDelay(INITIAL_DELAY_MS, function()
    ApplyOnce(1)
end)

Log("Loaded. Will run show ToneCurve once when the viewport is ready.")
