script_name("MONETMOBILE Installer")
script_author("MONETMOBILE")
script_version("1.0")
script_description('Script for installing other scripts')

require("lib.moonloader")
require('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')
local effil = require('effil')
local memory = require('memory')
local imgui = require('mimgui')
local fa = require('fAwesome6_solid')

local sizeX, sizeY = getScreenResolution()
local MainWindow = imgui.new.bool()

local function isMonetLoader()
	return MONET_VERSION ~= nil
end
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

local dir = getWorkingDirectory():gsub('\\','/')
local configDirectory = dir .. '/MONETMOBILE Installer'
if not doesDirectoryExist(configDirectory) then
	createDirectory(configDirectory)
end

local all_scripts, support_scripts = {}, {}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand('monet', get_all_scripts)
	repeat wait(0) until sampIsLocalPlayerSpawned()
	msg('Для установки/удаления используйте команду {00ccff}/monet')
	wait(-1)
end

function msg(text)
	sampAddChatMessage('{00ccff}[MONETMOBILE Installer] {ffffff}' .. text, -1)
end

local function readJsonFile(filePath)
	if not doesFileExist(filePath) then
		msg("Ошибка: файл не найден")
		return nil
	end
	local file = io.open(filePath, "r")
	local content = file:read("*a")
	file:close()
	local cjson = require("cjson")
	local status, jsonData = pcall(cjson.decode, content)
	if not status then
		msg("Ошибка: не удалось прочитать JSON: " .. tostring(jsonData))
		return nil
	end
	return jsonData
end

local function sortScripts()
	support_scripts = {}
	for _, value in ipairs(all_scripts) do
		if tostring(value.platform):find("MOBILE") then
			table.insert(support_scripts, value)
		end
	end
	MainWindow[0] = true
end

function downloadToFile(url, path, callback, progressInterval)
	callback = callback or function() end
	progressInterval = progressInterval or 0.1
	local effil = require("effil")
	local progressChannel = effil.channel(0)
	local runner = effil.thread(function(url, path)
		local http = require("socket.http")
		local ltn = require("ltn12")
		local r, c, h = http.request({ method = "HEAD", url = url })
		if c ~= 200 then return false, c end
		local total_size = h["content-length"]
		local f = io.open(path, "wb")
		if not f then return false, "failed to open file" end
		local lastProgress = os.clock()
		local success, res, status_code = pcall(http.request, {
			method = "GET",
			url = url,
			sink = function(chunk, err)
				local clock = os.clock()
				if chunk and (not lastProgress or (clock - lastProgress) >= progressInterval) then
					progressChannel:push("downloading", f:seek("end"), total_size)
					lastProgress = os.clock()
				elseif err then
					progressChannel:push("error", err)
				end
				return ltn.sink.file(f)(chunk, err)
			end,
		})
		if not success then return false, res end
		if not res then return false, status_code end
		return true, total_size
	end)
	local thread = runner(url, path)
	local function checkStatus()
		local tstatus = thread:status()
		if tstatus == "failed" or tstatus == "completed" then
			local result, value = thread:get()
			if result then
				callback("finished", value)
			else
				callback("error", value)
			end
			return true
		end
	end
	lua_thread.create(function()
		if checkStatus() then return end
		while thread:status() == "running" do
			if progressChannel:size() > 0 then
				local type, pos, total_size = progressChannel:pop()
				callback(type, pos, total_size)
			end
			wait(0)
		end
		checkStatus()
	end)
end

function downloadFileFromUrlToPath(url, path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "downloading" then
				-- print(("Загрузка %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				lua_thread.create(function()
					msg('Файл ' .. path:gsub(dir .. '/', '') .. ' загружен! Перезагрузка скриптов через 3 секунды...')
					wait(3000)
					reloadScripts()
				end)
			elseif type == "error" then
				msg('Ошибка загрузки: ' .. pos)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				lua_thread.create(function()
					msg('Файл ' .. path:gsub(dir .. '/', '') .. ' загружен! Перезагрузка скриптов через 3 секунды...')
					MainWindow[0] = false
					wait(3000)
					reloadScripts()
				end)
			end
		end)
	end
end

function get_all_scripts()
	all_scripts = {}
	support_scripts = {}
	local path = configDirectory .. "/scripts.json"
	local url = "https://github.com/MTGMODS/lua_scripts/raw/refs/heads/main/scripts.json"
	os.remove(path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "finished" then
				local array = readJsonFile(path)
				if array then
					all_scripts = array
					sortScripts()
				end
			elseif type == "error" then
				msg('Ошибка загрузки: ' .. pos)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then
				local array = readJsonFile(path)
				if array then
					all_scripts = array
					sortScripts()
				end
			end
		end)
	end
end

imgui.OnInitialize(function()
	imgui.GetIO().IniFilename = nil
	if isMonetLoader() then
		fa.Init(14 * MONET_DPI_SCALE)
	else
		fa.Init()
	end
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	style.WindowPadding = imgui.ImVec2(8 * MONET_DPI_SCALE, 8 * MONET_DPI_SCALE)
	style.FramePadding = imgui.ImVec2(6 * MONET_DPI_SCALE, 6 * MONET_DPI_SCALE)
	style.ItemSpacing = imgui.ImVec2(6 * MONET_DPI_SCALE, 6 * MONET_DPI_SCALE)
	style.WindowRounding = 12 * MONET_DPI_SCALE
	style.FrameRounding = 10 * MONET_DPI_SCALE
	style.ScrollbarRounding = 10 * MONET_DPI_SCALE
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	local baseColor = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
	local accentColor = imgui.ImVec4(0.40, 0.10, 0.70, 1.00)
	local hoverColor = imgui.ImVec4(0.60, 0.20, 0.90, 1.00)
	style.Colors[imgui.Col.WindowBg] = baseColor
	style.Colors[imgui.Col.FrameBg] = baseColor
	style.Colors[imgui.Col.FrameBgHovered] = hoverColor
	style.Colors[imgui.Col.FrameBgActive] = accentColor
	style.Colors[imgui.Col.TitleBg] = baseColor
	style.Colors[imgui.Col.TitleBgActive] = accentColor
	style.Colors[imgui.Col.Button] = accentColor
	style.Colors[imgui.Col.ButtonHovered] = hoverColor
	style.Colors[imgui.Col.ButtonActive] = baseColor
	style.Colors[imgui.Col.Border] = hoverColor
	style.Colors[imgui.Col.Tab] = baseColor
	style.Colors[imgui.Col.TabHovered] = hoverColor
	style.Colors[imgui.Col.TabActive] = accentColor
end)

imgui.OnFrame(
	function() return MainWindow[0] end,
	function(player)
		imgui.Begin(fa.GEAR .." MONETMOBILE Installer " .. fa.GEAR, MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		if imgui.BeginChild('##1', imgui.ImVec2(660 * MONET_DPI_SCALE, (36*#support_scripts) * MONET_DPI_SCALE), true) then
			imgui.Columns(3)
			imgui.CenterColumnText(u8"Название и версия")
			imgui.SetColumnWidth(-1, 200 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8"Описание скрипта")
			imgui.SetColumnWidth(-1, 360 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
			imgui.CenterColumnText(u8("Действие"))
			imgui.Columns(1)
			imgui.Separator()
			for index, value in ipairs(support_scripts) do
				imgui.Columns(3)
				imgui.CenterColumnText(u8(value.name .. " [" .. value.ver .. "]"))
				imgui.NextColumn()
				imgui.CenterColumnText(u8(value.info))
				imgui.NextColumn()
				local scriptPath = dir .. '/' .. value.name .. '.lua'
				if doesFileExist(scriptPath) then
					if imgui.CenterColumnButton(fa.TRASH_CAN .. u8(" Удалить##") .. index) then
						os.remove(scriptPath)
						lua_thread.create(function()
							msg('Файл ' .. value.name .. '.lua удалён! Перезагрузка скриптов через 3 секунды...')
							MainWindow[0] = false
							wait(3000)
							reloadScripts()
						end)
					end
				else
					if imgui.CenterColumnButton(fa.DOWNLOAD .. u8(" Скачать##") .. index) then
						downloadFileFromUrlToPath(value.link, scriptPath)
						MainWindow[0] = false
					end
				end
				imgui.Columns(1)
				imgui.Separator()
			end
			imgui.EndChild()
		end
		imgui.End()
	end
)

function imgui.CenterText(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX(width / 2 - calc.x / 2)
	imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX(width / 2 - calc.x / 2)
	imgui.TextDisabled(text)
end
function imgui.CenterColumnText(text)
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterButton(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX(width / 2 - calc.x / 2)
	return imgui.Button(text)
end
function imgui.CenterColumnButton(text)
	if text:find('(.+)##(.+)') then
		local text1 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	return imgui.Button(text)
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
	return imgui.SmallButton(text)
end
function imgui.GetMiddleButtonX(count)
	local width = imgui.GetWindowContentRegionWidth()
	local space = imgui.GetStyle().ItemSpacing.x
	return count == 1 and width or width / count - ((space * (count - 1)) / count)
end
