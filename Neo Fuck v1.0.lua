--========================================================--
--  Script:  
--  Author:   Anonymous
--  Version:  1.0

--========================================================--
local script_ver = 'v1.0'

-- проверка окружения
function isMonetLoader()
    return MONET_VERSION ~= nil
end

if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

local scale = MONET_DPI_SCALE  -- используем MONET_DPI_SCALE для масштабирования

if not isMonetLoader() then
    require("lib.moonloader")
end
require ("sampfuncs")
require ("lib.samp.events")

-- условное подключение
local wm, vkeys
if not isMonetLoader() then
    -- MoonLoader: подключаем стандартные модули
    wm    = require("windows.message")
    vkeys = require("vkeys")
else
    -- MonetLoader: модули не нужны или адаптированы
end

local memory  = require("memory")
local ffi     = require("ffi")
local effil   = require("effil")
local imgui   = require("mimgui")
local fa      = require("fAwesome6_solid")
local inicfg  = require("inicfg")
local sampev  = require("samp.events")
local events  = require("samp.events")
local screen_resX, screen_resY = getScreenResolution()

require("encoding").default = "CP1251"
local u8 = require("encoding").UTF8

local sizeX, sizeY = getScreenResolution()

local buttons = {
    {label = "Старт",      action = function() sampAddChatMessage(u8("Заглушка: старт")) end},
    {label = "Настройки",  action = function() sampAddChatMessage("Заглушка: настройки") end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход") end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход") end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход") end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход") end},
}

local colors = {
    blue = imgui.ImVec4(0, 0.5, 1, 1),
    white = imgui.ImVec4(1, 1, 1, 1),
    red = imgui.ImVec4(1, 0, 0, 1),
    orange = imgui.ImVec4(1, 0.5, 0, 1),
    yellow = imgui.ImVec4(1, 0.8, 0, 1),
    green = imgui.ImVec4(0, 1, 0, 1),
}

--Настройки по умолчанию
local defaultIni = {
    config = {
        watermark   = false,
        showTime    = false,
        offsetY     = 60,
    }
}


-- Загружаем ini (файл будет лежать в moonloader/config/NeoFuck.ini)
local ini = inicfg.load(defaultIni, "NeoFuck")
if not ini then
    inicfg.save(defaultIni, "NeoFuck")
    ini = defaultIni
end

local new            = imgui.new
local ui_open        = new.bool(false)
local currentTab     = new.int(1)
local watermark      = imgui.new.bool(ini.config.watermark)
local showTime       = imgui.new.bool(ini.config.showTime)
local offsetY        = imgui.new.int(ini.config.offsetY)

local alwaysRun      = false  -- опция для постоянного бега, можно добавить в настройки позже


local font = renderCreateFont("Arial Black", 28, 12)




local oX, oY = 250, 430
local piska  = 0

local labels = {
    fa.HOUSE_MEDICAL .. " Основное",
    fa.COMPUTER_MOUSE .. " Кнопки",
    fa.CAR .. " Авто",
    fa.BUG .. " Читы",
    fa.BOX_ARCHIVE .. " Остальное",
    fa.GEAR .. " Настройки"
}
local btnSize = imgui.ImVec2(147.5 * scale, 46.5 * scale)

-- контент вкладок

function mainTab()
    local columnWidth = imgui.GetContentRegionAvail().x / 4.05

    imgui.BeginChild("Column1", imgui.ImVec2(columnWidth, 0), true)
    imgui.EndChild()

    imgui.SameLine()

    imgui.BeginChild("Column2", imgui.ImVec2(columnWidth, 0), true)
    imgui.EndChild()

    imgui.SameLine()

    imgui.BeginChild("Column3", imgui.ImVec2(columnWidth, 0), true)
    imgui.EndChild()

    imgui.SameLine()

    imgui.BeginChild("Column4", imgui.ImVec2(columnWidth, 0), true)
    imgui.EndChild()
end


function buttonsTab()
    for i, btn in ipairs(buttons) do
        if imgui.Button(btn.label, btnSize) then
            btn.action() -- вызываем готовую функцию
        end
        if i % 6 ~= 0 then imgui.SameLine() end
    end
end



function autoTab()
    -- код для вкладки "Авто"
end

function cheatsTab()
    -- код для вкладки "Читы"
end

function otherTab()
    imgui.SetCursorPos(imgui.ImVec2(15, 10))
    if imgui.Checkbox("Watermark", watermark) then
        ini.config.watermark = watermark[0]
        inicfg.save(ini, "NeoFuck")
    end

    imgui.SetCursorPos(imgui.ImVec2(15, 40)) -- второй элемент ниже
    if imgui.Checkbox("Time", showTime) then
        ini.config.showTime = showTime[0]
        inicfg.save(ini, "NeoFuck")
    end
end

function settingsTab()
    -- код для вкладки "Настройки"
end

-- теперь кладём их в таблицу
local tabContent = {
    mainTab,
    buttonsTab,
    autoTab,
    cheatsTab,
    otherTab,
    settingsTab
}

-- основной рендер
local render = imgui.OnFrame(
    function() return ui_open[0] end,
    function()
        local winW, winH = 930 * scale, 490 * scale

        imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Once)

        -- получаем размер экрана
        local screenW, screenH = getScreenResolution()
        -- вычисляем центр
        local posX = (screenW - winW) / 2
        local posY = (screenH - winH) / 2
        imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Once)

        local flags = imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar

        -- === основное окно ===
        if imgui.Begin("UltraFuck by MaksQ V2.36", ui_open, flags) then
            
            -- верхний блок кнопок
            if imgui.BeginChild("TopButtons", imgui.ImVec2(0, 60), true, flags) then
                local style = imgui.GetStyle()
                local oldX, oldY = style.ItemSpacing.x, style.ItemSpacing.y
                style.ItemSpacing.x = 15
                style.ItemSpacing.y = 5
            
                local availWidth  = imgui.GetContentRegionAvail().x
                local availHeight = imgui.GetContentRegionAvail().y
                local spacing     = style.ItemSpacing.x
                local count       = #labels
            
                local btnWidth  = (availWidth - (count - 1) * spacing) / count
                local btnHeight = availHeight
                local autoSize  = imgui.ImVec2(btnWidth, btnHeight)
            
                for i, label in ipairs(labels) do
                    if currentTab[0] == i then
                        imgui.PushStyleColor(imgui.Col.Button,        imgui.ImVec4(1, 0, 0, 1))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1, 0.2, 0.2, 1))
                        imgui.PushStyleColor(imgui.Col.ButtonActive,  imgui.ImVec4(0.8, 0, 0, 1))
                        if imgui.Button(label, autoSize) then
                            currentTab[0] = i
                        end
                        imgui.PopStyleColor(3)
                    else
                        if imgui.Button(label, autoSize) then
                            currentTab[0] = i
                        end
                    end
            
                    if i < count then
                        imgui.SameLine()
                    end
                end
            
                style.ItemSpacing.x = oldX
                style.ItemSpacing.y = oldY
                imgui.EndChild()
            end
            
            -- нижний блок контента
            if imgui.BeginChild("BottomFunc", imgui.ImVec2(0, 0), true) then
                tabContent[currentTab[0]]()
                imgui.EndChild()
            end

            imgui.End()
        end

        -- === отдельное окно-логотип (правый нижний угол) ===
        local logoW, logoH = 400 * scale, 30 * scale
        
        local margin = 10 * MONET_DPI_SCALE
        local logoX = screenW - logoW - margin
        local logoY = screenH - logoH - margin
        imgui.SetNextWindowPos(imgui.ImVec2(logoX, logoY), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(logoW, logoH), imgui.Cond.Always)
        
        if imgui.Begin("##logo", ui_open, flags) then
            imgui.SetWindowFontScale(1.8) -- увеличиваем текст в 3 раза
        
            imgui.TextColored(colors.blue, "     Neo ")
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
            imgui.TextColored(colors.red, "Fuck ")
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
            imgui.Text("| "..script_ver.." | @мойтгканал | ")
        
            imgui.SetWindowFontScale(1.0) -- возвращаем стандартный масштаб
        end
        
        imgui.End()
    end
)

-- окно ватермарка
imgui.OnFrame(function() return watermark[0] end, function(player)
    local scrx, scry = getScreenResolution()
    local winW, winH = 485 * MONET_DPI_SCALE, 40 * MONET_DPI_SCALE  -- размеры окна
    
    local margin1 = 42 * MONET_DPI_SCALE           -- отступ от края
    local margin2 = 7 * MONET_DPI_SCALE
    -- позиция: левый нижний угол
    imgui.SetNextWindowPos(imgui.ImVec2(margin1, scry - winH - margin2), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Always)
    
    if not isMonetLoader() and not sampIsChatInputActive() then
        player.HideCursor = true
    else
        player.HideCursor = false
    end
    
    local fpsColor, pingColor = colors.white, colors.white
    local fps = imgui.GetIO().Framerate
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local ping = id and sampGetPlayerPing(id) or 0

    fpsColor = fps <= 5 and colors.red or fps <= 10 and colors.orange or fps <= 30 and colors.yellow or colors.green
    pingColor = ping <= 60 and colors.green or ping <= 120 and colors.yellow or colors.red

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.93, 0.85))
    
    if imgui.Begin("##minet", watermark, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoInputs + imgui.WindowFlags.NoScrollbar) then
        if imgui.BeginChild("TopButtons", imgui.ImVec2(0, 0), true, flags) then   
            imgui.SetWindowFontScale(1.4)
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
end)

-- отдельная функция для отрисовки времени
function drawServerTime(screenW, screenH, font, offsetY)
    if showTime[0] then
        local timer = os.time()
        local timeStr = os.date("%H:%M:%S", timer)
        local label = "Server-Time"
        local text = label .. " " .. timeStr

        local x = (screenW / 2) - (renderGetFontDrawTextLength(font, text) / 2)
        local y = screenH - offsetY[0]

        renderFontDrawText(font, label, x, y, 0xFFE1E1E1)
        renderFontDrawText(font, timeStr, x + renderGetFontDrawTextLength(font, label .. " "), y, 0xFFFF6347)
    end
end

-- отдельная функция для основного цикла
function mainLoop(screenW, screenH)
    drawServerTime(screenW, screenH, font, offsetY)
end

function main()
    while not isSampAvailable() do wait(100) end
    local screenW, screenH = getScreenResolution()

    if isMonetLoader() then
        -- === MonetLoader ===
        sampev.onSendCommand = function(cmd)
            if cmd == "/gg" then
                ui_open[0] = not ui_open[0]
                imgui.ShowCursor = ui_open[0]
                print("[NeoFuck] Окно переключено через MonetLoader команду /gg")
                return false -- предотвращаем отправку команды в чат
            end
        end
    else
        -- === MoonLoader ===
        sampRegisterChatCommand("gg", function()
            ui_open[0] = not ui_open[0]
            imgui.ShowCursor = ui_open[0]
            sampAddChatMessage("{FF0000}[NeoFuck]{FFFFFF} Окно переключено через MoonLoader команду /gg", -1)
        end)

        -- обработка ESC и F12 только для MoonLoader
        addEventHandler('onWindowMessage', function(msg, wparam, lparam)
            -- WM_KEYDOWN = 0x100
            if msg == 0x100 then
                -- ESC закрывает окно
                if wparam == vkeys.VK_ESCAPE and ui_open[0] and not isPauseMenuActive() then
                    consumeWindowMessage(true, false)
                    ui_open[0] = false
                    imgui.ShowCursor = false
                    return 0
                end

                -- F12 переключает окно
                if wparam == vkeys.VK_F12 then
                    ui_open[0] = not ui_open[0]
                    imgui.ShowCursor = ui_open[0]
                    return 0
                end
            end
        end)
    end

    -- основной цикл
    while true do
        mainLoop(screenW, screenH)
        if alwaysRun and doesCharExist(PLAYER_PED) then
            setCharRunning(PLAYER_PED, true)
        end
        wait(0)
    end
end



imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init(18 * MONET_DPI_SCALE)
    imgui.SwitchContext()
    local style = imgui.GetStyle()

    -- базовые отступы и размеры
    style.WindowPadding                     = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.FramePadding                      = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.ItemSpacing                       = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.ItemInnerSpacing                  = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    style.TouchExtraPadding                 = imgui.ImVec2(0, 0)

    style.IndentSpacing                     = 0
    style.ScrollbarSize                     = 10 * MONET_DPI_SCALE
    style.GrabMinSize                       = 10 * MONET_DPI_SCALE
    style.WindowBorderSize                  = 0
    style.ChildBorderSize                   = 1 * MONET_DPI_SCALE
    style.PopupBorderSize                   = 0
    style.FrameBorderSize                   = 0
    style.TabBorderSize                     = 0
    style.WindowRounding                    = 8 * MONET_DPI_SCALE
    style.ChildRounding                     = 8 * MONET_DPI_SCALE
    style.FrameRounding                     = 8 * MONET_DPI_SCALE
    style.PopupRounding                     = 8 * MONET_DPI_SCALE
    style.ScrollbarRounding                 = 8 * MONET_DPI_SCALE
    style.GrabRounding                      = 8 * MONET_DPI_SCALE
    style.TabRounding                       = 8 * MONET_DPI_SCALE

    style.WindowTitleAlign                  = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign                   = imgui.ImVec2(0.5, 0.5)
    style.SelectableTextAlign               = imgui.ImVec2(0.5, 0.5)

    style.Colors[imgui.Col.FrameBg]         = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    style.Colors[imgui.Col.FrameBgHovered]  = imgui.ImVec4(0.35, 0.35, 0.35, 1.0)
    style.Colors[imgui.Col.FrameBgActive]   = imgui.ImVec4(0.6, 0.0, 0.0, 1.0)
    style.Colors[imgui.Col.CheckMark]       = imgui.ImVec4(1.0, 0.0, 0.0, 1.0)
    style.Colors[imgui.Col.WindowBg]        = imgui.ImVec4(0.0, 0.0, 0.0, 0.0)
    style.Colors[imgui.Col.ChildBg]         = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
    style.Colors[imgui.Col.Button]        = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    style.Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(1.0, 0.2, 0.2, 1.0)
    style.Colors[imgui.Col.ButtonActive]  = imgui.ImVec4(0.8, 0.0, 0.0, 1.0)
    style.Colors[imgui.Col.Text]            = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
end)

---------------------------------------------------------------------------------------------------------------------------------------------------
