local imgui = require 'mimgui'
local lfs = require 'lfs'

-- Получаем путь к скрипту
local function getScriptDir()
    local info = debug.getinfo(1, 'S')
    local scriptPath = info.source:sub(2)
    return scriptPath:match("^(.*)[/\\]") or '.'
end

local scriptDir = getScriptDir()
-- local scriptsPath = scriptDir .. "/scripts" -- больше не нужен

local scriptFiles = {}
local selectedFile = nil
local fileContent = imgui.new.char[4096]()
local isEditing = imgui.new.bool(false)

function updateScriptList()
    scriptFiles = {}
    local attr = lfs.attributes(scriptDir)
    if not attr or attr.mode ~= "directory" then
        return
    end
    for file in lfs.dir(scriptDir) do
        if file:match("%.lua$") and file ~= "Install.lua" then
            table.insert(scriptFiles, file)
        end
    end
end

function loadFileContent(filename)
    local f = io.open(scriptDir .. "/" .. filename, "r")
    if f then
        local content = f:read("*a") or ""
        f:close()
        local len = math.max(#content + 1, 4096)
        fileContent = imgui.new.char[len]()
        for i = 1, #content do
            fileContent[i - 1] = content:byte(i)
        end
        fileContent[#content] = 0
    else
        fileContent = imgui.new.char[4096]()
        fileContent[0] = 0
    end
end

function saveFileContent(filename)
    local f = io.open(scriptDir .. "/" .. filename, "w")
    if f then
        local str = ""
        local i = 0
        while fileContent[i] ~= nil and fileContent[i] ~= 0 do
            str = str .. string.char(fileContent[i])
            i = i + 1
        end
        f:write(str)
        f:close()
    end
end

imgui.OnFrame(
    function() return true end,
    function()
        imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
        imgui.Begin("Lua Script Editor")
        if imgui.Button("Обновить список файлов") then
            updateScriptList()
        end
        imgui.Separator()
        for i, file in ipairs(scriptFiles) do
            if imgui.Selectable(file, selectedFile == file) then
                selectedFile = file
                loadFileContent(file)
                isEditing[0] = true
            end
        end
        imgui.Separator()
        if selectedFile then
            imgui.Text("Файл: " .. selectedFile)
            if not isEditing[0] then
                if imgui.Button("Edit") then
                    isEditing[0] = true
                end
            else
                if imgui.Button("Сохранить") then
                    saveFileContent(selectedFile)
                    isEditing[0] = false
                end
                imgui.SameLine()
                if imgui.Button("Отмена") then
                    loadFileContent(selectedFile)
                    isEditing[0] = false
                end
                imgui.InputTextMultiline("##edit", fileContent, 500, 300)
            end
        end
        imgui.End()
    end
)

-- Команда активации edit
function onEditCommand()
    if selectedFile then
        isEditing[0] = true
    end
end

function main()
    updateScriptList()
    if type(sampRegisterChatCommand) == "function" then
        sampRegisterChatCommand("edit", onEditCommand) -- Регистрируем команду /edit
    end
    while true do wait(0) end
end
