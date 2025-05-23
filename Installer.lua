local imgui = require 'mimgui'
local lfs = require 'lfs'

-- Получаем путь к скрипту
local function getScriptDir()
    local info = debug.getinfo(1, 'S')
    local scriptPath = info.source:sub(2)
    return scriptPath:match("^(.*)[/\\]") or '.'
end

local scriptDir = getScriptDir()
local scriptsPath = scriptDir .. "/scripts"

local scriptFiles = {}
local selectedFile = nil
local fileContent = imgui.new.char[4096]()
local isEditing = imgui.new.bool(false)

function updateScriptList()
    scriptFiles = {}
    local attr = lfs.attributes(scriptsPath)
    if not attr or attr.mode ~= "directory" then
        return
    end
    for file in lfs.dir(scriptsPath) do
        if file:match("%.lua$") then
            table.insert(scriptFiles, file)
        end
    end
end

function loadFileContent(filename)
    local f = io.open(scriptsPath .. "/" .. filename, "r")
    if f then
        local content = f:read("*a") or ""
        f:close()
        imgui.setValue(fileContent, content)
    else
        imgui.setValue(fileContent, "")
    end
end

function saveFileContent(filename)
    local f = io.open(scriptsPath .. "/" .. filename, "w")
    if f then
        f:write(imgui.getValue(fileContent))
        f:close()
    end
end

imgui.OnFrame(
    function() return true end,
    function()
        imgui.Begin("Lua Script Editor")
        if imgui.Button("Обновить список файлов") then
            updateScriptList()
        end
        imgui.Separator()
        for i, file in ipairs(scriptFiles) do
            if imgui.Selectable(file, selectedFile == file) then
                selectedFile = file
                loadFileContent(file)
                imgui.setValue(isEditing, false)
            end
        end
        imgui.Separator()
        if selectedFile then
            imgui.Text("Файл: " .. selectedFile)
            if not isEditing[0] then
                if imgui.Button("Edit") then
                    imgui.setValue(isEditing, true)
                end
            else
                if imgui.Button("Сохранить") then
                    saveFileContent(selectedFile)
                    imgui.setValue(isEditing, false)
                end
                imgui.SameLine()
                if imgui.Button("Отмена") then
                    loadFileContent(selectedFile)
                    imgui.setValue(isEditing, false)
                end
                imgui.InputTextMultiline("##edit", fileContent, imgui.ImVec2(500, 300))
            end
        end
        imgui.End()
    end
)

-- Команда активации edit
function onEditCommand()
    if selectedFile then
        imgui.setValue(isEditing, true)
    end
end

function main()
    updateScriptList()
    if type(sampRegisterChatCommand) == "function" then
        sampRegisterChatCommand("edit", onEditCommand) -- Регистрируем команду /edit
    end
    while true do wait(0) end
end
