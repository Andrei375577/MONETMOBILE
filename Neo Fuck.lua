--========================================================--
--  Script: Neo Fuck
--  Author: Anonymous
--  Version: 1.0
--========================================================--

local script_ver = 'v2.0'

-- Проверка окружения
function isMonetLoader()
    return MONET_VERSION ~= nil
end

-- Масштабирование для разных загрузчиков
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end
local scale  = isMonetLoader() and 1.4 or 1
local scale1 = isMonetLoader() and 1.7 or 1
local scale2 = isMonetLoader() and 0.59 or 1

-- Подключение библиотек (работает и в MonetLoader, и в MoonLoader)
pcall(function() require("lib.moonloader") end)  -- MoonLoader
require("sampfuncs")
require("lib.samp.events")

-- Условное подключение модулей (для MoonLoader)
local wm, vkeys
pcall(function()
    wm    = require("windows.message")
    vkeys = require("vkeys")
end)

local memory  = require("memory")
local ffi     = require("ffi")
local effil   = require("effil")
local imgui   = require("mimgui")
local fa      = require("fAwesome6_solid")
local inicfg  = require("inicfg")
local sampev  = require("samp.events")
local events  = require("samp.events")
local screen_resX, screen_resY = getScreenResolution()

-- Кодировка
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

-- Разрешение экрана
local sizeX, sizeY = getScreenResolution()

-- Данные кнопок
local buttons = {
    {label = "обновлений", action = function() checkUpdate() end},
    {label = "Настройки",  action = function() sampAddChatMessage("Заглушка: настройки", -1) end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход", -1) end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход", -1) end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход", -1) end},
    {label = "Выход",      action = function() sampAddChatMessage("Заглушка: выход", -1) end},
}

-- Цвета
local colors = {
    blue   = imgui.ImVec4(0, 0.5, 1, 1),
    white  = imgui.ImVec4(1, 1, 1, 1),
    red    = imgui.ImVec4(1, 0, 0, 1),
    orange = imgui.ImVec4(1, 0.5, 0, 1),
    yellow = imgui.ImVec4(1, 0.8, 0, 1),
    green  = imgui.ImVec4(0, 1, 0, 1),
}

-- Настройки по умолчанию
local defaultIni = {
	config = {
		cjRun = false, 
        showTime  = false, 
		watermark = false,
        lastCommit = "",
	}
}


-- Загрузка конфигурации
local ini = inicfg.load(defaultIni, "NeoFuck")
if not ini then
    inicfg.save(defaultIni, "NeoFuck")
    ini = defaultIni
end

-- Переменные ImGui
local new        = imgui.new
local ui_open    = new.bool(false)
local currentTab = new.int(1)
local watermark  = imgui.new.bool(ini.config.watermark)
local showTime   = imgui.new.bool(ini.config.showTime)
local cjRun      = imgui.new.bool(ini.config.cjRun)
local offsetY    = 60 * scale
local idskin = nil  -- переменная для хранения исходного скина
local openbutton = new.bool(false) -- дефолт для MoonLoader

if MONET_VERSION ~= nil then
    openbutton[0] = true -- или openbutton = new.bool(true), если хочешь пересоздать
end

local update_window_open = imgui.new.bool(false)
local update_status = imgui.new.char[512]("Нажмите кнопку для проверки")
local update_checking = imgui.new.bool(false)
local update_result_color = imgui.ImVec4(1, 1, 1, 1)
local update_url = "https://raw.githubusercontent.com/Andrei375577/MONETMOBILE/refs/heads/main/Neo%20Fuck.lua"
local repo_owner = "Andrei375577"
local repo_name  = "MONETMOBILE"
local repo_file  = "Neo%20Fuck.lua"
local latest_remote_sha = nil

-- Опции
local function setCJRun(state)
    cjRun[0] = state
    ini.config.cjRun = state
    inicfg.save(ini, "NeoFuck")

    if state then
        setAnimGroupForChar(PLAYER_PED, "PLAYER")
        
    else
        setAnimGroupForChar(PLAYER_PED,
            usePlayerAnimGroup and "PLAYER" or isCharMale(PLAYER_PED) and "MAN" or "WOMAN")
        
    end
end
-- Шрифт
local font = renderCreateFont("Arial Black", 28 * scale, 12 * scale)

-- Неиспользуемые переменные (оставлены для совместимости)
local oX, oY = 250, 430

-- Названия вкладок
local labels = {
    fa.HOUSE_MEDICAL .. " Основное",
    fa.COMPUTER_MOUSE .. " Кнопки",
    fa.CAR .. " Авто",
    fa.BUG .. " Читы",
    fa.BOX_ARCHIVE .. " Остальное",
    fa.GEAR .. " Настройки"
}
local btnSize = imgui.ImVec2(147.5 * MONET_DPI_SCALE, 46.5 * MONET_DPI_SCALE)

-- Контент вкладок

-- Основная вкладка
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

-- Вкладка кнопок
function buttonsTab()
    for i, btn in ipairs(buttons) do
        if imgui.Button(btn.label, btnSize) then
            btn.action()
        end
        if i % 6 ~= 0 then imgui.SameLine() end
    end
end

-- Вкладка авто
function carTab()
    -- Заглушка для вкладки "Авто"
end

-- Вкладка читов
function cheatsTab()
    imgui.SetCursorPos(imgui.ImVec2(15, 10 * MONET_DPI_SCALE))
    if imgui.Checkbox("Бег CJ", cjRun) then
        setCJRun(cjRun[0])
    end
end


-- Вкладка остального
function otherTab()
    imgui.SetCursorPos(imgui.ImVec2(15, 10 * MONET_DPI_SCALE))
    if imgui.Checkbox("Watermark", watermark) then
        ini.config.watermark = watermark[0]
        inicfg.save(ini, "NeoFuck")
    end
    imgui.SetCursorPos(imgui.ImVec2(15, 40 * MONET_DPI_SCALE))
    if imgui.Checkbox("Time", showTime) then
        ini.config.showTime = showTime[0]
        inicfg.save(ini, "NeoFuck")
    end
end

-- Вкладка настроек
function settingsTab()

end


-- Таблица контента вкладок
local tabContent = {
    mainTab,
    buttonsTab,
    carTab,
    cheatsTab,
    otherTab,
    settingsTab
}

-- Основной рендер интерфейса
local render = imgui.OnFrame(
    function() return ui_open[0] end,
    function()
        local main_hovered = false
        local logo_hovered = false
        local winW, winH = 930 * MONET_DPI_SCALE, 490 * MONET_DPI_SCALE

        -- Настройка окна
        imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Once)
        local screenW, screenH = getScreenResolution()
        local posX = (screenW - winW) / 2
        local posY = (screenH - winH) / 2
        imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Once)

        local flags = imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar

        -- Основное окно
        if imgui.Begin("UltraFuck by MaksQ V2.36", ui_open, flags) then
            -- Верхняя панель вкладок
            if imgui.BeginChild("TopButtons", imgui.ImVec2(0, 60 * MONET_DPI_SCALE), true, flags) then
                local style = imgui.GetStyle()
                local oldX, oldY = style.ItemSpacing.x, style.ItemSpacing.y
                style.ItemSpacing.x = 15
                style.ItemSpacing.y = 5

                local availWidth  = imgui.GetContentRegionAvail().x
                local availHeight = imgui.GetContentRegionAvail().y
                local spacing     = style.ItemSpacing.x
                local count       = #labels
                local btnWidth    = (availWidth - (count - 1) * spacing) / count
                local btnHeight   = availHeight
                local autoSize    = imgui.ImVec2(btnWidth, btnHeight)

                -- Отрисовка вкладок
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
                    if i < count then imgui.SameLine() end
                end

                style.ItemSpacing.x = oldX
                style.ItemSpacing.y = oldY
                imgui.EndChild()
            end

            -- Нижняя область контента
            if imgui.BeginChild("BottomFunc", imgui.ImVec2(0, 0), true) then
                tabContent[currentTab[0]]()
                imgui.EndChild()
            end

            if imgui.IsWindowHovered() then main_hovered = true end
            imgui.End()
        end

        -- Окно логотипа
        local logoW, logoH = 400 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE
        local margin = 10 * MONET_DPI_SCALE
        local logoX = screenW - logoW - margin
        local logoY = screenH - logoH - margin
        imgui.SetNextWindowPos(imgui.ImVec2(logoX, logoY), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(logoW, logoH), imgui.Cond.Always)

        if imgui.Begin("##logo", ui_open, flags) then
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

        -- Закрытие окна при клике вне его отключено
    end
)
-- Окно watermark
imgui.OnFrame(
    function() return watermark[0] end,
    function(player)
        local scrx, scry = getScreenResolution()
        local winW, winH = 485 * scale, 40 * scale1
        local flags = imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar
        local margin1 = 42 * scale
        local margin2 = 7 * scale
        imgui.SetNextWindowPos(imgui.ImVec2(margin1, scry - winH - margin2), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(winW, winH), imgui.Cond.Always)

        if not isMonetLoader() and not sampIsChatInputActive() then
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
                imgui.SetWindowFontScale(1.4 * scale2)
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

-- Полоска
imgui.OnFrame(function() return openbutton[0] end, function(self)
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.SetNextWindowSize(imgui.ImVec2(300, 50), imgui.Cond.Always)
    local scrx, scry = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(scrx / 2, scry - 27), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('##poloska', openbutton, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
    imgui.SetCursorPos(imgui.ImVec2(0, 30))
    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    dl:AddRectFilled(p, imgui.ImVec2(p.x + 293, p.y + 10), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.00, 1.00, 1.00, 1.00)), 10, 10)
    imgui.SetCursorPos(imgui.ImVec2(0, 0))
    if imgui.InvisibleButton('##hidemenu', imgui.GetWindowSize()) then
        ui_open[0] = not ui_open[0]
    end
    imgui.PopStyleColor(2)
    imgui.End()
end)

-- Функция отрисовки времени сервера
function drawServerTime(screenW, screenH, font, offsetY)
    if showTime[0] then
        local timer = os.time()
        local timeStr = os.date("%H:%M:%S", timer)
        local label = "Server-Time"
        local text = label .. " " .. timeStr
        local x = (screenW / 2) - (renderGetFontDrawTextLength(font, text) / 2)
        local y = screenH - offsetY
        renderFontDrawText(font, label, x, y, 0xFFE1E1E1)
        renderFontDrawText(font, timeStr, x + renderGetFontDrawTextLength(font, label .. " "), y, 0xFFFF6347)
    end
end

-- Основной цикл
function mainLoop(screenW, screenH)
    drawServerTime(screenW, screenH, font, offsetY)
end


-- Инициализация ImGui
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    if isMonetLoader() then
        fa.Init(14 * MONET_DPI_SCALE)
    else
        fa.Init()
    end
    imgui.SwitchContext()

    -- Стили интерфейса
    local style = imgui.GetStyle()
    style.WindowPadding     = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.FramePadding      = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.ItemSpacing       = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    style.ItemInnerSpacing  = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    style.TouchExtraPadding = imgui.ImVec2(0, 0)
    style.IndentSpacing     = 0
    style.ScrollbarSize     = 10 * MONET_DPI_SCALE
    style.GrabMinSize       = 10 * MONET_DPI_SCALE
    style.WindowBorderSize  = 0
    style.ChildBorderSize   = 1 * MONET_DPI_SCALE
    style.PopupBorderSize   = 0
    style.FrameBorderSize   = 0
    style.TabBorderSize     = 0
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

    -- Цвета (красная тема)
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
end)

---------------------------------------------------------------------------------------------------------------------------------------------------function checkUpdate()
function checkUpdate()
    update_checking[0] = true
    ffi.copy(update_status, "Проверка обновлений...")
    lua_thread.create(function()
        local ok, result, resp_headers = pcall(function()
            local req = require("requests")
            local response_text, response_headers = nil, nil
            for i = 1, 5 do
                local request_url = update_url .. (update_url:find("%?") and "&" or "?") .. "_=" .. tostring(os.time())
                local response = req.get(request_url)
                if response and response.status_code == 200 and response.text and #response.text > 0 then
                    response_text = response.text
                    response_headers = response.headers or {}
                    break
                end
                wait(2000) -- 2 seconds pause between attempts
            end
            return response_text, response_headers
        end)

        if ok and result then
            -- Try to get latest commit info from GitHub API (commits endpoint)
            local okc, remote_sha, remote_date, remote_msg = pcall(function()
                local req = require("requests")
                local cjson = require("cjson")
                for i = 1, 3 do
                    local url = string.format("https://api.github.com/repos/%s/%s/commits?path=%s&per_page=1&_=%s", repo_owner, repo_name, repo_file, tostring(os.time()))
                    local r = req.get(url)
                    if r and r.status_code == 200 and r.text and #r.text > 0 then
                        local tbl = cjson.decode(r.text)
                        if type(tbl) == 'table' and #tbl >= 1 then
                            local item = tbl[1]
                            return item.sha, item.commit and item.commit.committer and item.commit.committer.date or nil, item.commit and item.commit.message or nil
                        end
                    end
                    wait(1000)
                end
                return nil, nil, nil
            end)

            local file = io.open(thisScript().path, "r")
            if file then
                local local_code = file:read("*a")
                file:close()
                -- Normalize line endings to LF for consistent comparison across loaders
                local local_norm = local_code:gsub("\r\n", "\n"):gsub("\r", "\n")
                local result_norm = result:gsub("\r\n", "\n"):gsub("\r", "\n")

                -- If we have remote commit info, prefer it for quick checks
                if okc and remote_sha then
                    if ini.config.lastCommit == remote_sha then
                        local msg = "✅ У вас актуальная версия (commit: " .. string.sub(remote_sha, 1, 7) .. ")"
                        local etag = resp_headers and (resp_headers['etag'] or resp_headers['ETag']) or nil
                        if etag then msg = msg .. " ETag: " .. tostring(etag) end
                        ffi.copy(update_status, msg)
                        update_result_color = imgui.ImVec4(0, 1, 0, 1)
                    else
                        -- first run: if lastCommit not set, check content equality and set lastCommit if equal
                        if ini.config.lastCommit == "" then
                            if local_norm == result_norm then
                                ini.config.lastCommit = remote_sha
                                inicfg.save(ini, "NeoFuck")
                                local msg = "✅ У вас актуальная версия (commit: " .. string.sub(remote_sha, 1, 7) .. ")"
                                ffi.copy(update_status, msg)
                                update_result_color = imgui.ImVec4(0, 1, 0, 1)
                            else
                                local msg = "⚠ Обнаружено обновление: commit " .. string.sub(remote_sha, 1, 7)
                                if remote_date then msg = msg .. " " .. remote_date end
                                ffi.copy(update_status, msg)
                                update_result_color = imgui.ImVec4(1, 0.6, 0, 1)
                                update_window_open[0] = true
                                latest_remote_sha = remote_sha
                            end
                        else
                            -- known lastCommit is different -> show update
                            if ini.config.lastCommit ~= remote_sha then
                                local msg = "⚠ Обновление: commit " .. string.sub(remote_sha, 1, 7)
                                if remote_date then msg = msg .. " " .. remote_date end
                                ffi.copy(update_status, msg)
                                update_result_color = imgui.ImVec4(1, 0.6, 0, 1)
                                update_window_open[0] = true
                                latest_remote_sha = remote_sha
                            else
                                local msg = "✅ У вас актуальная версия (commit: " .. string.sub(remote_sha, 1, 7) .. ")"
                                ffi.copy(update_status, msg)
                                update_result_color = imgui.ImVec4(0, 1, 0, 1)
                            end
                        end
                    end
                else
                    -- Fallback: compare file contents
                    if local_norm == result_norm then
                        local msg = "✅ У вас актуальная версия (код совпадает)"
                        local etag = resp_headers and (resp_headers['etag'] or resp_headers['ETag']) or nil
                        if etag then msg = msg .. " ETag: " .. tostring(etag) end
                        ffi.copy(update_status, msg)
                        update_result_color = imgui.ImVec4(0, 1, 0, 1)
                    else
                        local msg = "⚠ Обнаружено обновление: код отличается от GitHub"
                        local etag = resp_headers and (resp_headers['etag'] or resp_headers['ETag']) or nil
                        if etag then msg = msg .. " ETag: " .. tostring(etag) end
                        ffi.copy(update_status, msg)
                        update_result_color = imgui.ImVec4(1, 0.6, 0, 1)
                        update_window_open[0] = true
                    end
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
        local ok, result, resp_headers = pcall(function()
            local req = require("requests")
            local response_text, response_headers = nil, nil
            for i = 1, 5 do
                local request_url = update_url .. (update_url:find("%?") and "&" or "?") .. "_=" .. tostring(os.time())
                local response = req.get(request_url)
                if response and response.status_code == 200 and response.text and #response.text > 0 then
                    response_text = response.text
                    response_headers = response.headers or {}
                    break
                end
                wait(2000)
            end
            return response_text, response_headers
        end)

        if ok and result then
            local file = io.open(thisScript().path, "w+")
            if file then
                -- Normalize line endings to LF before writing to prevent extra blank lines
                local to_write = result:gsub("\r\n", "\n"):gsub("\r", "\n")
                file:write(to_write)
                file:close()
                -- After successful write, record the commit SHA if we have it
                if latest_remote_sha and latest_remote_sha ~= "" then
                    ini.config.lastCommit = latest_remote_sha
                    inicfg.save(ini, "NeoFuck")
                else
                    -- Try to fetch commit SHA once more and save it
                    local okc, remote_sha = pcall(function()
                        local req = require("requests")
                        local cjson = require("cjson")
                        local url = string.format("https://api.github.com/repos/%s/%s/commits?path=%s&per_page=1&_=%s", repo_owner, repo_name, repo_file, tostring(os.time()))
                        local r = req.get(url)
                        if r and r.status_code == 200 and r.text and #r.text > 0 then
                            local tbl = cjson.decode(r.text)
                            if type(tbl) == 'table' and #tbl >= 1 then
                                return tbl[1].sha
                            end
                        end
                        return nil
                    end)
                    if okc and remote_sha then
                        ini.config.lastCommit = remote_sha
                        inicfg.save(ini, "NeoFuck")
                    end
                end
                local msg = "✅ Скрипт обновлён. Перезапустите его вручную."
                local etag = resp_headers and (resp_headers['etag'] or resp_headers['ETag']) or nil
                if etag then msg = msg .. " ETag: " .. tostring(etag) end
                ffi.copy(update_status, msg)
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

-- Окно обновления
imgui.OnFrame(function() return update_window_open[0] end, function()
    local scrx, scry = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(scrx / 2, scry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(700, 435), imgui.Cond.FirstUseEver)
    
    if imgui.Begin("Обновление NeoFuck", update_window_open, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar) then
        imgui.BeginChild("update_child", imgui.ImVec2(0, 0), true)

        -- Собираем текст и измеряем ширину
    local text1 = "Neo "
    local text2 = "Fuck "
    local text3 = "Обнаружено обновление!"
    local total_width =
    imgui.CalcTextSize(text1).x +
    imgui.CalcTextSize(text2).x +
    imgui.CalcTextSize(text3).x - 8 -- учтём сдвиг

    -- Центрируем по ширине окна
    local window_width = imgui.GetWindowSize().x
    local start_x = (window_width - total_width) / 2
    imgui.SetCursorPosX(start_x)

        -- Рисуем по частям
        imgui.TextColored(colors.blue, text1)
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() - 8)
        imgui.TextColored(colors.red, text2)
        imgui.SameLine()
        imgui.Text(text3)
        imgui.Separator()
        imgui.Spacing()
        imgui.CenterText("Найдена новая версия скрипта.")
        imgui.CenterText("Чтобы продолжить работу,")
        imgui.CenterText("выберите один из вариантов ниже.")
        imgui.Spacing()
        imgui.Spacing()
        if imgui.Button(fa.FORWARD .. " ПРОПУСТИТЬ", imgui.ImVec2(325, 70)) then
            update_window_open[0] = false
        end
			imgui.SameLine()
        if imgui.Button(fa.DOWNLOAD .. " ОБНОВИТЬ", imgui.ImVec2(325, 70)) and not update_checking[0] then
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

-- Главная функция
function main()
    while not isSampAvailable() do wait(100) end
    local screenW, screenH = getScreenResolution()
	checkUpdate()
    -- команда для ручного вызова
    sampRegisterChatCommand("update", function()
		update_window_open[0] = true
	end)
    -- Единая обработка команды для обоих загрузчиков
    if isMonetLoader() then
        -- MonetLoader: используем sampev.onSendCommand
        sampev.onSendCommand = function(cmd)
            if cmd == "/gg" then
                ui_open[0] = not ui_open[0]
                imgui.ShowCursor = ui_open[0]
                print("[NeoFuck] Окно переключено")
                return false
            end
		    if cmd == "/cj" then
		        setCJRun(not cjRun[0])
		        return false
		    end
        end
    else
        -- MoonLoader: используем sampRegisterChatCommand
        sampRegisterChatCommand("gg", function()
            ui_open[0] = not ui_open[0]
            imgui.ShowCursor = ui_open[0]
            sampAddChatMessage("{FF0000}[NeoFuck]{FFFFFF} Окно переключено", -1)
        end)

        sampRegisterChatCommand("cj", function()
            applyCJState(not ini.config.cjRun)
        end)

        -- Обработка клавиш для MoonLoader
        if vkeys then
            addEventHandler('onWindowMessage', function(msg, wparam, lparam)
                if msg == 0x100 then
                    if wparam == vkeys.VK_ESCAPE and ui_open[0] and not isPauseMenuActive() then
                        consumeWindowMessage(true, false)
                        ui_open[0] = false
                        imgui.ShowCursor = false
                        return 0
                    end
                    if wparam == vkeys.VK_F12 then
                        ui_open[0] = not ui_open[0]
                        imgui.ShowCursor = ui_open[0]
                        return 0
                    end
                end
            end)
        end
    end

    -- Основной цикл (единый для обоих загрузчиков)
    while true do
        mainLoop(screenW, screenH)

        -- Всегда обновляем флаг памяти для совместимости (безопасно через pcall),
        -- чтобы изменения из UI применялись немедленно без перезахода.
        

        wait(0)
    end

end




