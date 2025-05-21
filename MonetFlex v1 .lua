-- MonetFlex v1.0
-- Разработчик: MonetMobile

script_name("MonetFlex")
script_author("MonetMobile")

local imgui = require "mimgui"
local encoding = require "encoding"
encoding.default = "CP1251"
local u8 = encoding.UTF8
local new = imgui.new
local ImVec2 = imgui.ImVec2
local MainWindow = imgui.new.bool(true)
local sampev = require "samp.events"
local isExpanded = imgui.new.bool(false)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    imgui.GetStyle().FrameRounding = 20.0
end)

local rX, rY = getScreenResolution()
local size = imgui.ImVec2(50 * MONET_DPI_SCALE, 50 * MONET_DPI_SCALE)

local function hideButtons()
    isExpanded[0] = false
end

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(78, 475), imgui.Cond.Always)
        imgui.SetNextWindowSize(ImVec2(isExpanded[0] and (600 * MONET_DPI_SCALE) or (120 * MONET_DPI_SCALE), 60 * MONET_DPI_SCALE), imgui.Cond.Always)

        if imgui.Begin("MainWindow", MainWindow, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoBackground) then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.2, 0.2, 0.2, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))

            if imgui.Button("ALT", size) then
                local data = samp_create_sync_data(isCharOnFoot(PLAYER_PED) and "player" or "vehicle")
                data.keysData = data.keysData + (isCharOnFoot(PLAYER_PED) and 1024 or 4)
                data.send()
                hideButtons()
            end
            imgui.SameLine()

            if imgui.Button(isExpanded[0] and "<<" or ">>", size) then
                isExpanded[0] = not isExpanded[0]
            end
            imgui.SameLine()

            if isExpanded[0] then
                if imgui.Button("F", size) then
                    local data = samp_create_sync_data(isCharOnFoot(PLAYER_PED) and "player" or "vehicle")
                    data.keysData = data.keysData + 16
                    data.send()
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("H", size) then
                    local data = samp_create_sync_data(isCharOnFoot(PLAYER_PED) and "player" or "vehicle")
                    if isCharOnFoot(PLAYER_PED) then
                        data.quaternion[4] = 1.7632555392181e-38
                    else
                        data.keysData = data.keysData + 2
                    end
                    data.send()
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("2", size) then
                    if isCharInAnyCar(PLAYER_PED) then
                        local data = samp_create_sync_data("vehicle")
                        data.keysData = data.keysData + 512
                        data.send()
                    end
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("SPC", size) then
                    local data = samp_create_sync_data(isCharOnFoot(PLAYER_PED) and "player" or "vehicle")
                    data.keysData = data.keysData + (isCharOnFoot(PLAYER_PED) and 32 or 128)
                    data.send()
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("Y", size) then
                    sampSendChat("/invent")
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("N", size) then
                    if isCharOnFoot(PLAYER_PED) then
                        local data = samp_create_sync_data("player")
                        data.quaternion[4] = 1.1755083638069e-38
                        data.send()
                    else
                        sampSendChat("/engine")
                    end
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("MASK", size) then
                    sampSendChat("/mask")
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button("ARM", size) then
                    sampSendChat("/armour")
                    hideButtons()
                end
                imgui.SameLine()

                if imgui.Button(u8"REPC", size) then
                    sampSendChat("/repcar")
                    hideButtons()
                end
            end

            imgui.PopStyleColor(3)
            imgui.End()
        end
    end
)

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end



function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('kostil', function()
        MainWindow[0] = not MainWindow[0]
    end)
    wait(-1)
end