local script_ver = 'BETA v1.0'
script_name('Neo Fuck')
script_author('Anonymous')
script_version('BETA v1.0')
--[[-----------------------------------------------------------------------------------------------------------------------------------------
------- MONETLOADER --------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------]]
if MONET_VERSION ~= nil then

    if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
    local imgui = require 'mimgui'
    local fa      = require("fAwesome6_solid")
    
    local currentPage = imgui.new.int(1)
    local windowVisible = imgui.new.bool(false)
    
    local newFrame = imgui.OnFrame(
        function()
            return windowVisible[0]
        end,
    
        function(player)
            local winW, winH = 1860, 980
            imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Always)
            
            imgui.Begin(
                "",
                nil,
                imgui.WindowFlags.NoResize +
                imgui.WindowFlags.NoTitleBar +
                imgui.WindowFlags.NoScrollbar
            )
            if firstOpen then
                local screenX, screenY = getScreenResolution()
    
                imgui.SetWindowPos(
                    imgui.ImVec2(
                        (screenX - winW) / 2,
                        (screenY - winH) / 2
                    ),
                    imgui.Cond.Always   
                )
    
                firstOpen = false
            end
            local topHeight    = 120
            local buttonHeight = 100
    
            imgui.BeginChild("TopMenu", imgui.ImVec2(0, topHeight), true)
    
                imgui.SetCursorPosY((topHeight - buttonHeight) / 2)
    
                local totalWidth  = 1792.5 
                local buttonCount = 6
                local buttonWidth = totalWidth / buttonCount
    
                local function MenuButton(name, id, last)
                    local isActive = (currentPage[0] == id)
    
                    if isActive then
                        imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1, 0, 0, 1))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1, 0.2, 0.2, 1))
                        imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.8, 0, 0, 1))
                    end
    
                    if imgui.Button(name, imgui.ImVec2(buttonWidth - 5, buttonHeight)) then
                        currentPage[0] = id
                    end
    
                    if isActive then
                        imgui.PopStyleColor(3)
                    end
    
                    if not last then imgui.SameLine() end
                end
    
                MenuButton(fa.HOUSE    .. "  Основное",   1)
                MenuButton(fa.KEYBOARD .. "  Кнопки",     2)
                MenuButton(fa.CAR      .. "  Авто",       3)
                MenuButton(fa.BOLT     .. "  Читы",       4)
                MenuButton(fa.BOX      .. "  Остальное",  5)
                MenuButton(fa.GEAR     .. "  Настройки",  6, true)
    
            imgui.EndChild()
            imgui.BeginChild("Content", imgui.ImVec2(0, 0), true)
    
                if currentPage[0] == 1 then imgui.Text("Страница: Основное")
                elseif currentPage[0] == 2 then imgui.Text("Страница: Кнопки")
                elseif currentPage[0] == 3 then imgui.Text("Страница: Авто")
                elseif currentPage[0] == 4 then imgui.Text("Страница: Читы")
                elseif currentPage[0] == 5 then imgui.Text("Страница: Остальное")
                elseif currentPage[0] == 6 then imgui.Text("Страница: Настройки")
                end
    
            imgui.EndChild()
    
            imgui.End()

        end
    )
    
    function main()
        checkUpdate()
        sampRegisterChatCommand("rr", function()
            windowVisible[0] = not windowVisible[0]
        end)
    
        wait(-1)
    end
    
    imgui.OnInitialize(function()
        imgui.GetIO().IniFilename = nil
        fa.Init(28)
        imgui.SwitchContext()
        local style = imgui.GetStyle()
        style.WindowPadding     = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
        style.FramePadding      = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
        style.ItemSpacing       = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
        style.ItemInnerSpacing  = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
        style.TouchExtraPadding = imgui.ImVec2(0 * MONET_DPI_SCALE, 0 * MONET_DPI_SCALE)
        style.IndentSpacing     = 0 * MONET_DPI_SCALE
        style.ScrollbarSize     = 20 * MONET_DPI_SCALE
        style.GrabMinSize       = 10 * MONET_DPI_SCALE
        style.WindowBorderSize  = 0 * MONET_DPI_SCALE
        style.ChildBorderSize   = 1 * MONET_DPI_SCALE 
        style.PopupBorderSize   = 0 * MONET_DPI_SCALE
        style.FrameBorderSize   = 0 * MONET_DPI_SCALE
        style.TabBorderSize     = 0 * MONET_DPI_SCALE
        style.WindowRounding    = 8 * MONET_DPI_SCALE
        style.ChildRounding     = 8 * MONET_DPI_SCALE
        style.FrameRounding     = 8 * MONET_DPI_SCALE
        style.PopupRounding     = 8 * MONET_DPI_SCALE
        style.ScrollbarRounding = 8 * MONET_DPI_SCALE
        style.GrabRounding      = 8 * MONET_DPI_SCALE
        style.TabRounding       = 8 * MONET_DPI_SCALE
        style.WindowTitleAlign  = imgui.ImVec2(0.5, 0.5)
        style.ButtonTextAlign   = imgui.ImVec2(0.5, 0.5)
        style.SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
        style.Colors[imgui.Col.FrameBg]         = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
        style.Colors[imgui.Col.FrameBgHovered]  = imgui.ImVec4(0.35, 0.35, 0.35, 1.0)
        style.Colors[imgui.Col.FrameBgActive]   = imgui.ImVec4(0.6, 0.0, 0.0, 1.0)
        style.Colors[imgui.Col.CheckMark]       = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
        style.Colors[imgui.Col.WindowBg]        = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
        style.Colors[imgui.Col.ChildBg]         = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
        style.Colors[imgui.Col.Button]          = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
        style.Colors[imgui.Col.ButtonHovered]   = imgui.ImVec4(1.0, 0.2, 0.2, 1.0)
        style.Colors[imgui.Col.ButtonActive]    = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
        style.Colors[imgui.Col.Text]            = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
        style.Colors[imgui.Col.PopupBg]			 = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
        style.Colors[imgui.Col.Header]          = imgui.ImVec4(0.6, 0.0, 0.0, 1.0)
        style.Colors[imgui.Col.HeaderHovered]   = imgui.ImVec4(1.0, 0.2, 0.2, 1.0)
        style.Colors[imgui.Col.HeaderActive]    = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
    end)
    
end


--[[-----------------------------------------------------------------------------------------------------------------------------------------
------- MOONLOADER --------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------]]
if MONET_VERSION == nil then

if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
local imgui = require 'mimgui'
local fa      = require("fAwesome6_solid")
local vkeys = require("vkeys")
local inicfg  = require("inicfg")

local defaultIni = {
    config = {
        watermark = false,
        showTime  = false
    }
}

local ini = inicfg.load(defaultIni, "NeoFuck")
if not ini then
    inicfg.save(defaultIni, "NeoFuck")
    ini = defaultIni
end

local currentPage   = imgui.new.int(1)
local windowVisible = imgui.new.bool(false)
local watermark     = imgui.new.bool(ini.config.watermark)
local showTime      = imgui.new.bool(ini.config.showTime)


local colors = {
    blue   = imgui.ImVec4(0, 0.5, 1, 1),
    white  = imgui.ImVec4(1, 1, 1, 1),
    red    = imgui.ImVec4(1, 0, 0, 1),
    orange = imgui.ImVec4(1, 0.5, 0, 1),
    yellow = imgui.ImVec4(1, 0.8, 0, 1),
    green  = imgui.ImVec4(0, 1, 0, 1),
}

local newFrame = imgui.OnFrame(
    function()
        return windowVisible[0]
    end,

    function(player)
        local winW, winH = 930, 490
        imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Always)
        local screen_w, screen_h = getScreenResolution()
        imgui.SetNextWindowPos(
            imgui.ImVec2(
                (screen_w - winW) / 2,  
                (screen_h - winH) / 2   
            ),
            imgui.Cond.FirstUseEver
        )
		imgui.Begin("", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
        if firstOpen then
            local screenX, screenY = getScreenResolution()

            imgui.SetWindowPos(
                imgui.ImVec2(
                    (screenX - winW) / 2,
                    (screenY - winH) / 2
                ),
                imgui.Cond.Always   
            )

            firstOpen = false
        end
        local topHeight    = 60
        local buttonHeight = 50

        imgui.BeginChild("TopMenu", imgui.ImVec2(0, topHeight), true)

            imgui.SetCursorPosY((topHeight - buttonHeight) / 2)

            local totalWidth  = getScreenResolution()
            local buttonCount = 12.6
            local buttonWidth = totalWidth / buttonCount

            local function MenuButton(name, id, last)
                local isActive = (currentPage[0] == id)

                if isActive then
                    imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1, 0, 0, 1))
                    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1, 0.2, 0.2, 1))
                    imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.8, 0, 0, 1))
                end

                if imgui.Button(name, imgui.ImVec2(buttonWidth - 5, buttonHeight)) then
                    currentPage[0] = id
                end

                if isActive then
                    imgui.PopStyleColor(3)
                end

                if not last then imgui.SameLine() end
            end

            MenuButton(fa.HOUSE    .. "  Основное",   1)
            MenuButton(fa.KEYBOARD .. "  Кнопки",     2)
            MenuButton(fa.CAR      .. "  Авто",       3)
            MenuButton(fa.BOLT     .. "  Читы",       4)
            MenuButton(fa.BOX      .. "  Остальное",  5)
            MenuButton(fa.GEAR     .. "  Настройки",  6, true)

        imgui.EndChild()
        imgui.BeginChild("Content", imgui.ImVec2(0, 0), true)

            if currentPage[0] == 1 then 
                 imgui.Text("Страница: Основное")
            elseif currentPage[0] == 2 then 
                 imgui.Text("Страница: Кнопки")
            elseif currentPage[0] == 3 then 
                 imgui.Text("Страница: Авто")
            elseif currentPage[0] == 4  then 
                 imgui.Text("Страница: Читы")
            elseif currentPage[0] == 5 then 
                imgui.SetCursorPos(imgui.ImVec2(10, 10))
                if imgui.Checkbox("Watermark", watermark) then
                    ini.config.watermark = watermark[0]
                    inicfg.save(ini, "NeoFuck")
                imgui.SetCursorPos(imgui.ImVec2(15, 40 * MONET_DPI_SCALE))
                if imgui.Checkbox("Time", showTime) then
                    ini.config.showTime = showTime[0]
                    inicfg.save(ini, "NeoFuck")
                end
            end
            elseif currentPage[0] == 6 then
                 imgui.Text("Страница: Настройки")
            end

        imgui.EndChild()

        imgui.End()

            local logoW, logoH = 450, 30
            local margin = 10
            local screenW, screenH = getScreenResolution()
            local logoX = screenW - logoW - margin
            local logoY = screenH - logoH - margin
            imgui.SetNextWindowPos(imgui.ImVec2(logoX, logoY), imgui.Cond.Always)
            imgui.SetNextWindowSize(imgui.ImVec2(logoW, logoH), imgui.Cond.Always)

            if imgui.Begin("##logo", windowVisible, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar) then
                imgui.SetWindowFontScale(1.8)
                imgui.TextColored(colors.blue, "     Neo ")
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
                imgui.TextColored(colors.red, "Fuck ")
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
                imgui.Text("| "..script_ver.." | @мойтгканал | ")
                imgui.SetWindowFontScale(1.0)
            end

            if imgui.IsWindowHovered() then logo_hovered = true end
            imgui.End()
    end
)

function main()
    checkUpdate()
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if msg == 0x100 then  
            if wparam == vkeys.VK_ESCAPE and windowVisible[0] and not isPauseMenuActive() then
                windowVisible[0] = false
                imgui.ShowCursor = false
                consumeWindowMessage(true, false) 
                return 0
            end
        end
    end)
    
    function isMonetLoader()
        return MONET_VERSION ~= nil
    end
    sampRegisterChatCommand("rr", function()
        windowVisible[0] = not windowVisible[0]
    end)
    if showTime[0] then local font=renderCreateFont("Arial Black",28,12) renderFontDrawText(font,"Server-Time ",(getScreenResolution()/2)-(renderGetFontDrawTextLength(font,"Server-Time "..os.date("%H:%M:%S"))/2),select(2,getScreenResolution())-60,0xFFE1E1E1) renderFontDrawText(font,os.date("%H:%M:%S"),(getScreenResolution()/2)-(renderGetFontDrawTextLength(font,"Server-Time "..os.date("%H:%M:%S"))/2)+renderGetFontDrawTextLength(font,"Server-Time "),select(2,getScreenResolution())-60,0xFFFF6347) end
    wait(-1)
end

imgui.OnFrame(
    function() return watermark[0] end,
    function(player)
        local scrx, scry = getScreenResolution()
        local winW, winH = 540, 40
        local flags = imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar
        local margin1 = 42
        local margin2 = 7
        imgui.SetNextWindowPos(imgui.ImVec2(margin1, scry - winH - margin2), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Always)

        if not sampIsChatInputActive() then
            player.HideCursor = true
        else
            player.HideCursor = false
        end

        local fpsColor, pingColor = colors.white, colors.white
		local fps = imgui.GetIO().Framerate

		local id, ping = nil, 0
		if isSampAvailable() and PLAYER_PED and doesCharExist(PLAYER_PED) then
		local ok, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		    if ok then
		        id = pid
		        ping = sampGetPlayerPing(id)
		    end
		end

fpsColor = fps <= 5 and colors.red
    or fps <= 10 and colors.orange
    or fps <= 30 and colors.yellow
    or colors.green

pingColor = ping <= 60 and colors.green
    or ping <= 120 and colors.yellow
    or colors.red
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.93, 0.85))

        if imgui.Begin("##minet", watermark, flags) then
            if imgui.BeginChild("TopButtons", imgui.ImVec2(0, 0), true, flags) then
                imgui.SetWindowFontScale(1.42)
                imgui.TextColored(colors.blue, "     Neo ")
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
                imgui.TextColored(colors.red, "Fuck ")
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
                imgui.Text("| "..script_ver.." | @мойтгканал | ")
                imgui.SameLine()
                imgui.TextColored(fpsColor, string.format("FPS: %.0f", fps))
                imgui.SameLine()
                imgui.SetCursorPosY(imgui.GetCursorPosY() - 1)
                imgui.TextColored(pingColor, string.format("ping: %.0f", ping))
                imgui.PopStyleColor()
                imgui.EndChild()
                imgui.SetWindowFontScale(1.0)
            end
        end
        imgui.End()
    end
)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    
    fa.Init(16)
    
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    style.WindowPadding     = imgui.ImVec2(5, 5)
    style.FramePadding      = imgui.ImVec2(5, 5)
    style.ItemSpacing       = imgui.ImVec2(5, 5)
    style.ItemInnerSpacing  = imgui.ImVec2(2, 2)
    style.TouchExtraPadding = imgui.ImVec2(0, 0)
    style.IndentSpacing     = 0
    style.ScrollbarSize     = 20
    style.GrabMinSize       = 10
    style.WindowBorderSize  = 0
    style.ChildBorderSize   = 1
    style.PopupBorderSize   = 0
    style.FrameBorderSize   = 0
    style.TabBorderSize     = 0
    style.WindowRounding    = 8
    style.ChildRounding     = 8
    style.FrameRounding     = 8
    style.PopupRounding     = 8
    style.ScrollbarRounding = 8
    style.GrabRounding      = 8
    style.TabRounding       = 8
    style.WindowTitleAlign  = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign   = imgui.ImVec2(0.5, 0.5)
    style.SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
	style.Colors[imgui.Col.FrameBg]         = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
	style.Colors[imgui.Col.FrameBgHovered]  = imgui.ImVec4(0.35, 0.35, 0.35, 1.0)
	style.Colors[imgui.Col.FrameBgActive]   = imgui.ImVec4(0.6, 0.0, 0.0, 1.0)
	style.Colors[imgui.Col.CheckMark]       = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
	style.Colors[imgui.Col.WindowBg]        = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
	style.Colors[imgui.Col.ChildBg]         = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
	style.Colors[imgui.Col.Button]          = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
	style.Colors[imgui.Col.ButtonHovered]   = imgui.ImVec4(1.0, 0.2, 0.2, 1.0)
	style.Colors[imgui.Col.ButtonActive]    = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
	style.Colors[imgui.Col.Text]            = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
	style.Colors[imgui.Col.PopupBg]			 = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
	style.Colors[imgui.Col.Header]          = imgui.ImVec4(0.6, 0.0, 0.0, 1.0)
	style.Colors[imgui.Col.HeaderHovered]   = imgui.ImVec4(1.0, 0.2, 0.2, 1.0)
	style.Colors[imgui.Col.HeaderActive]    = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
end)

 


end
--[[----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------]]
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
local memory  = require("memory")
local ffi     = require("ffi")
local imgui   = require("mimgui")
local fa      = require("fAwesome6_solid")
local update_status = imgui.new.char[512]("Нажмите кнопку для проверки")
local update_window_open = imgui.new.bool(false)
local update_checking = imgui.new.bool(false)
local update_url = "https://raw.githubusercontent.com/Andrei375577/MONETMOBILE/refs/heads/main/Neo%20Fuck.lua"
local colors = {
    blue   = imgui.ImVec4(0, 0.5, 1, 1),
    white  = imgui.ImVec4(1, 1, 1, 1),
    red    = imgui.ImVec4(1, 0, 0, 1),
    orange = imgui.ImVec4(1, 0.5, 0, 1),
    yellow = imgui.ImVec4(1, 0.8, 0, 1),
    green  = imgui.ImVec4(0, 1, 0, 1),
}
imgui.OnFrame(function() return update_window_open[0] end, function()
    local scrx, scry = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(scrx / 2, scry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(300 * MONET_DPI_SCALE, 151 * MONET_DPI_SCALE), imgui.Cond.FirstUseEver)
    if imgui.Begin("Обновление NeoFuck", update_window_open, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar) then
        imgui.BeginChild("update_child", imgui.ImVec2(0, 0), true)
        local text1, text2, text3 = "Neo ", "Fuck ", "Обнаружено обновление!"
        local total_width = imgui.CalcTextSize(text1).x + imgui.CalcTextSize(text2).x + imgui.CalcTextSize(text3).x - 8
        local window_width = imgui.GetWindowSize().x
        local startx = (window_width - total_width) / 2
        imgui.SetCursorPosX(startx)
        imgui.TextColored(colors.blue, text1)
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
        imgui.TextColored(colors.red, text2)
        imgui.SameLine()
        imgui.Text(text3)
        imgui.Separator()
        imgui.CenterText("Найдена новая версия скрипта.")
        imgui.CenterText("Чтобы продолжить работу,")
        imgui.CenterText("выберите один из вариантов ниже.")
        local bh = 50 * MONET_DPI_SCALE
        local bx = 137.5 * MONET_DPI_SCALE
        if imgui.Button(fa.FORWARD .. " ПРОПУСТИТЬ", imgui.ImVec2(bx, bh)) then
            update_window_open[0] = false
        end
        imgui.SameLine()
        if imgui.Button(fa.DOWNLOAD .. " ОБНОВИТЬ", imgui.ImVec2(bx, bh)) and not update_checking[0] then
            downloadAndReplaceScript()
        end
        imgui.EndChild()
    end
    imgui.End()
end)
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function checkUpdate()
    update_checking[0] = true
    ffi.copy(update_status, "Проверка обновлений...")
    lua_thread.create(function()
        local ok, result = pcall(function()
            local req = require("requests")
            local response = req.get(update_url)
            if response.status_code == 200 then
                return response.text
            else
                return nil
            end
        end)

        if ok and result then
            local file = io.open(thisScript().path, "r")
            if file then
                local local_code = file:read("*a")
                file:close()
                -- Normalize line endings to LF for consistent comparison across loaders
                local local_norm = local_code:gsub("\r\n", "\n"):gsub("\r", "\n")
                local result_norm = result:gsub("\r\n", "\n"):gsub("\r", "\n")
                if local_norm == result_norm then
                    ffi.copy(update_status, "✅ У вас актуальная версия (код совпадает)")
                    update_result_color = imgui.ImVec4(0, 1, 0, 1)
                else
                    ffi.copy(update_status, "⚠ Обнаружено обновление: код отличается от GitHub")
                    update_result_color = imgui.ImVec4(1, 0.6, 0, 1)
                    update_window_open[0] = true
                end
            else
                ffi.copy(update_status, "❌ Ошибка чтения локального скрипта")
                update_result_color = imgui.ImVec4(1, 0, 0, 1)
            end
        else
            ffi.copy(update_status, "❌ Ошибка загрузки с GitHub")
            update_result_color = imgui.ImVec4(1, 0, 0, 1)
        end
        update_checking[0] = false
    end)
end
function downloadAndReplaceScript()
    update_checking[0] = true
    ffi.copy(update_status, "Загрузка новой версии...")
    lua_thread.create(function()
        local ok, result = pcall(function()
            local req = require("requests")
            local response = req.get(update_url)
            if response.status_code == 200 then
                return response.text
            else
                return nil
            end
        end)

        if ok and result then
            local file = io.open(thisScript().path, "w+")
            if file then
                -- Normalize line endings to LF before writing to prevent extra blank lines
                local to_write = result:gsub("\r\n", "\n"):gsub("\r", "\n")
                file:write(to_write)
                file:close()
                ffi.copy(update_status, "✅ Скрипт обновлён. Перезапустите его вручную.")
                update_result_color = imgui.ImVec4(0, 1, 0, 1)
            else
                ffi.copy(update_status, "❌ Не удалось записать файл")
                update_result_color = imgui.ImVec4(1, 0, 0, 1)
            end
        else
            ffi.copy(update_status, "❌ Ошибка загрузки обновления")
            update_result_color = imgui.ImVec4(1, 0, 0, 1)
        end
        update_checking[0] = false
    end)
end

