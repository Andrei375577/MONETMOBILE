-- NeoCalc v1.0
-- Разработчик: MonetMobile

script_name("NeoCalc")
script_author("MonetMobile")

local imgui = require 'mimgui'
local isOpen = imgui.new.bool(false)

local input = imgui.new.float(0.0)
local lastInput = imgui.new.float(0.0)
local operation = imgui.new.int(-1)
local decimalAdded = imgui.new.bool(false)

local function setNumber(target, number)
    if decimalAdded[0] then
        target[0] = tonumber(target[0] .. tostring(number))
    else
        if target[0] == 0 then
            target[0] = number -- Заменяем 0 при первом вводе
        else
            target[0] = target[0] * 10 + number
        end
    end
end 

local function calculate()
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
    operation[0] = -1
    decimalAdded[0] = false
end

local newFrame = imgui.OnFrame(
    function() return isOpen[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(400, 550))
        imgui.Begin("Калькулятор", isOpen, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar) -- Запрет изменения размера и скролла
        imgui.PushStyleColor(imgui.Col.TitleBg, imgui.ImVec4(0, 0, 0, 1)) -- Чёрный заголовок
        imgui.PushStyleColor(imgui.Col.TitleBgActive, imgui.ImVec4(0, 0, 0, 1)) -- Чёрный цвет при активном окне
        
        imgui.GetStyle().FrameRounding = 20.0
        imgui.GetStyle().WindowRounding = 20.0 -- Скругляем углы окна

        local textSize = imgui.CalcTextSize(tostring(input[0])).x
        imgui.SetCursorPosX(390 - textSize - 10) -- Двигаем текст влево
        imgui.Text(tostring(input[0]))

        -- Серые кнопки
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.5, 0.5, 1))
        if imgui.Button("C", imgui.ImVec2(90, 90)) then input[0] = 0 decimalAdded[0] = false end imgui.SameLine()
        if imgui.Button("%", imgui.ImVec2(90, 90)) then input[0] = input[0] / 100 end imgui.SameLine()
        if imgui.Button("⌫", imgui.ImVec2(90, 90)) then input[0] = math.floor(input[0] / 10) end imgui.PopStyleColor() imgui.SameLine()

        -- Оранжевые кнопки
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
