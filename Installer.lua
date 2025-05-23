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

local BUTTON_SIZE = imgui.ImVec2(85, 70)
local BUTTON_MARGIN = 8
local DISPLAY_HEIGHT = 80
local DISPLAY_BG = imgui.ImVec4(0.13, 0.14, 0.18, 1)
local DISPLAY_BORDER = imgui.ImVec4(0.25, 0.25, 0.28, 1)
local COLOR_NUM = imgui.ImVec4(0.92, 0.92, 0.92, 1)
local COLOR_NUM_HOVER = imgui.ImVec4(0.98, 0.98, 0.98, 1)
local COLOR_OP = imgui.ImVec4(1, 0.6, 0.1, 1)
local COLOR_OP_HOVER = imgui.ImVec4(1, 0.7, 0.3, 1)
local COLOR_SPEC = imgui.ImVec4(0.2, 0.6, 0.9, 1)
local COLOR_SPEC_HOVER = imgui.ImVec4(0.3, 0.7, 1, 1)
local COLOR_EQ = imgui.ImVec4(0.2, 0.8, 0.4, 1)
local COLOR_EQ_HOVER = imgui.ImVec4(0.3, 0.9, 0.5, 1)

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

local function ButtonEx(label, color, color_hover, size)
    imgui.PushStyleColor(imgui.Col.Button, color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, color_hover)
    local pressed = imgui.Button(label, size)
    imgui.PopStyleColor(2)
    return pressed
end

local newFrame = imgui.OnFrame(
    function() return isOpen[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(390, 500))
        imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 12)
        imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
        imgui.Begin("Калькулятор", isOpen, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)

        -- Дисплей
        imgui.PushStyleColor(imgui.Col.ChildBg, DISPLAY_BG)
        imgui.PushStyleColor(imgui.Col.Border, DISPLAY_BORDER)
        imgui.BeginChild("display", imgui.ImVec2(0, DISPLAY_HEIGHT), true, imgui.WindowFlags.NoScrollbar)
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 18)
        imgui.PushFont and imgui.PushFont(imgui.GetIO().Fonts:AddFontFromFileTTF("C:/Windows/Fonts/arialbd.ttf", 36))
        local text = tostring(input[0])
        local textSize = imgui.CalcTextSize(text).x
        imgui.SetCursorPosX(imgui.GetWindowWidth() - textSize - 24)
        imgui.TextColored(imgui.ImVec4(1,1,1,1), text)
        if imgui.PopFont then imgui.PopFont() end
        imgui.EndChild()
        imgui.PopStyleColor(2)

        imgui.Dummy(imgui.ImVec2(0, 10))

        -- Кнопки
        local function Row(btns)
            for i, btn in ipairs(btns) do
                local color, color_hover = btn.color, btn.color_hover
                if ButtonEx(btn.label, color, color_hover, BUTTON_SIZE) then btn.action() end
                if i < #btns then imgui.SameLine(nil, BUTTON_MARGIN) end
            end
        end

        Row({
            {label = "C", color = COLOR_SPEC, color_hover = COLOR_SPEC_HOVER, action = function() input[0] = 0 decimalAdded[0] = false end},
            {label = "%", color = COLOR_SPEC, color_hover = COLOR_SPEC_HOVER, action = function() input[0] = input[0] / 100 end},
            {label = "⌫", color = COLOR_SPEC, color_hover = COLOR_SPEC_HOVER, action = function() input[0] = math.floor(input[0] / 10) end},
            {label = "/", color = COLOR_OP, color_hover = COLOR_OP_HOVER, action = function() lastInput[0] = input[0] operation[0] = 3 input[0] = 0 decimalAdded[0] = false end},
        })
        imgui.Dummy(imgui.ImVec2(0, BUTTON_MARGIN))
        Row({
            {label = "7", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 7) end},
            {label = "8", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 8) end},
            {label = "9", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 9) end},
            {label = "*", color = COLOR_OP, color_hover = COLOR_OP_HOVER, action = function() lastInput[0] = input[0] operation[0] = 2 input[0] = 0 decimalAdded[0] = false end},
        })
        imgui.Dummy(imgui.ImVec2(0, BUTTON_MARGIN))
        Row({
            {label = "4", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 4) end},
            {label = "5", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 5) end},
            {label = "6", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 6) end},
            {label = "-", color = COLOR_OP, color_hover = COLOR_OP_HOVER, action = function() lastInput[0] = input[0] operation[0] = 1 input[0] = 0 decimalAdded[0] = false end},
        })
        imgui.Dummy(imgui.ImVec2(0, BUTTON_MARGIN))
        Row({
            {label = "1", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 1) end},
            {label = "2", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 2) end},
            {label = "3", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 3) end},
            {label = "+", color = COLOR_OP, color_hover = COLOR_OP_HOVER, action = function() lastInput[0] = input[0] operation[0] = 0 input[0] = 0 decimalAdded[0] = false end},
        })
        imgui.Dummy(imgui.ImVec2(0, BUTTON_MARGIN))
        Row({
            {label = ".", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() if not decimalAdded[0] then input[0] = tostring(input[0]) .. "." decimalAdded[0] = true end end},
            {label = "0", color = COLOR_NUM, color_hover = COLOR_NUM_HOVER, action = function() setNumber(input, 0) end},
            {label = "=", color = COLOR_EQ, color_hover = COLOR_EQ_HOVER, action = function() calculate() end},
        })

        imgui.PopStyleVar(2)
        imgui.End()
    end
)

function main()
    sampRegisterChatCommand("calc", function()
        isOpen[0] = not isOpen[0]
    end)
    wait(-1)
end
