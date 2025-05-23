-- NeoCalc v1.1 Improved
-- Разработчик: MonetMobile

script_name("NeoCalc")
script_author("MonetMobile")

local imgui = require 'mimgui'
local isOpen = imgui.new.bool(false)
local isDarkTheme = imgui.new.bool(true)
local input = imgui.new.float(0.0)
local lastInput = imgui.new.float(0.0)
local operation = imgui.new.int(-1)
local decimalAdded = imgui.new.bool(false)
local history = {}

local function addToHistory(expr, result)
    table.insert(history, 1, expr .. " = " .. result)
    if #history > 5 then table.remove(history, 6) end
end

local function setNumber(target, number)
    if decimalAdded[0] then
        target[0] = tonumber(tostring(target[0]) .. tostring(number))
    else
        if target[0] == 0 then
            target[0] = number
        else
            target[0] = target[0] * 10 + number
        end
    end
end

local function opToStr(op)
    return ({"+", "-", "*", "/"})[op + 1] or ""
end

local function calculate()
    local expr = tostring(lastInput[0]) .. " " .. opToStr(operation[0]) .. " " .. tostring(input[0])
    if operation[0] == 0 then input[0] = lastInput[0] + input[0] end
    if operation[0] == 1 then input[0] = lastInput[0] - input[0] end
    if operation[0] == 2 then input[0] = lastInput[0] * input[0] end
    if operation[0] == 3 then
        if input[0] ~= 0 then
            input[0] = lastInput[0] / input[0]
        else
            input[0] = 0
        end
    end
    addToHistory(expr, input[0])
    operation[0] = -1
    decimalAdded[0] = false
end

local function applyTheme()
    if isDarkTheme[0] then
        imgui.StyleColorsDark()
    else
        imgui.StyleColorsLight()
    end
end

local newFrame = imgui.OnFrame(
    function() return isOpen[0] end,
    function(player)
        applyTheme()
        imgui.SetNextWindowSize(imgui.ImVec2(400, 620), imgui.Cond.FirstUseEver)
        imgui.Begin("NeoCalc", isOpen, imgui.WindowFlags.NoCollapse)

        -- Кнопка закрытия
        imgui.SameLine(370)
        if imgui.Button("×") then isOpen[0] = false end

        -- Переключатель темы
        if imgui.Checkbox("Тёмная тема", isDarkTheme) then
            applyTheme()
        end
        imgui.Separator()

        -- История вычислений
        if #history > 0 then
            imgui.Text("История:")
            for i, v in ipairs(history) do
                imgui.BulletText(v)
            end
            imgui.Separator()
        end

        -- Основной дисплей
        local textSize = imgui.CalcTextSize(tostring(input[0])).x
        imgui.SetCursorPosX(390 - textSize - 10)
        imgui.Text(tostring(input[0]))

        -- Серые кнопки
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.5, 0.5, 1))
        if imgui.Button("C", imgui.ImVec2(90, 90)) then input[0] = 0 decimalAdded[0] = false end imgui.SameLine()
        if imgui.Button("%", imgui.ImVec2(90, 90)) then input[0] = input[0] / 100 end imgui.SameLine()
        if imgui.Button("⌫", imgui.ImVec2(90, 90)) then input[0] = math.floor(input[0] / 10) end imgui.PopStyleColor() imgui.SameLine()

        -- Оранжевая кнопка
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.5, 0, 1))
        if imgui.Button("/", imgui.ImVec2(90, 90)) then lastInput[0] = input[0] operation[0] = 3 input[0] = 0 decimalAdded[0] = false end imgui.PopStyleColor()

        for i = 7, 9 do
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.1, 0.1, 0.1, 1))
            if imgui.Button(tostring(i), imgui.ImVec2(90, 90)) then setNumber(input, i) end imgui.PopStyleColor() imgui.SameLine()
        end

        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.5, 0, 1))
        if imgui.Button("*", imgui.ImVec2(90, 90)) then lastInput[0] = input[0] operation[0] = 2 input[0] = 0 decimalAdded[0] = false end imgui.PopStyleColor()

        for i = 4, 6 do
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.1, 0.1, 0.1, 1))
            if imgui.Button(tostring(i), imgui.ImVec2(90, 90)) then setNumber(input, i) end imgui.PopStyleColor() imgui.SameLine()
        end

        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.5, 0, 1))
        if imgui.Button("-", imgui.ImVec2(90, 90)) then lastInput[0] = input[0] operation[0] = 1 input[0] = 0 decimalAdded[0] = false end imgui.PopStyleColor()

        for i = 1, 3 do
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.1, 0.1, 0.1, 1))
            if imgui.Button(tostring(i), imgui.ImVec2(90, 90)) then setNumber(input, i) end imgui.PopStyleColor() imgui.SameLine()
        end

        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.5, 0, 1))
        if imgui.Button("+", imgui.ImVec2(90, 90)) then lastInput[0] = input[0] operation[0] = 0 input[0] = 0 decimalAdded[0] = false end imgui.PopStyleColor()

        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.1, 0.1, 0.1, 1))
        if imgui.Button(".", imgui.ImVec2(90, 90)) and not decimalAdded[0] then input[0] = tostring(input[0]) .. "." decimalAdded[0] = true end imgui.PopStyleColor() imgui.SameLine()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.1, 0.1, 0.1, 1))
        if imgui.Button("0", imgui.ImVec2(90, 90)) then setNumber(input, 0) end imgui.PopStyleColor() imgui.SameLine()

        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 0.5, 0, 1))
        if imgui.Button("=", imgui.ImVec2(190, 90)) then calculate() end imgui.PopStyleColor()

        imgui.End()
    end
)

function main()
    sampRegisterChatCommand("calc", function()
        isOpen[0] = not isOpen[0]
    end)
    wait(-1)
end
