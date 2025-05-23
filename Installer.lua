local imgui = require 'imgui'
local lfs = require 'lfs'

-- Получаем путь к директории, где находится этот скрипт
local function getScriptDir()
    local info = debug.getinfo(1, 'S')
    local scriptPath = info.source:sub(2)
    return scriptPath:match("^(.*)[/\\]") or '.'
end

local scriptDir = getScriptDir()
local scriptsPath = scriptDir .. "/scripts"

local scriptFiles = {}
local selectedFile = nil
local fileContent = ""
local isEditing = false

function updateScriptList()
    scriptFiles = {}
    for file in lfs.dir(scriptsPath) do
        if file:match("%.lua$") then
            table.insert(scriptFiles, file)
        end
    end
end

function loadFileContent(filename)
    local f = io.open(scriptsPath .. "/" .. filename, "r")
    if f then
        fileContent = f:read("*a")
        f:close()
    else
        fileContent = ""
    end
end

function saveFileContent(filename, content)
    local f = io.open(scriptsPath .. "/" .. filename, "w")
    if f then
        f:write(content)
        f:close()
    end
end

imgui.OnDraw(function()
    imgui.Begin("Lua Script Editor")
    if imgui.Button("Обновить список файлов") then
        updateScriptList()
    end
    imgui.Separator()
    for i, file in ipairs(scriptFiles) do
        if imgui.Selectable(file, selectedFile == file) then
            selectedFile = file
            loadFileContent(file)
            isEditing = true
        end
    end
    imgui.Separator()
    if selectedFile then
        imgui.Text("Редактирование: " .. selectedFile)
        changed, fileContent = imgui.InputTextMultiline("##edit", fileContent, 4096, imgui.ImVec2(500, 300))
        if imgui.Button("Сохранить") then
            saveFileContent(selectedFile, fileContent)
        end
    end
    imgui.End()
end)

updateScriptList()
