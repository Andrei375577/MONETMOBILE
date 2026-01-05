---@diagnostic disable: undefined-global, need-check-nil, lowercase-global, cast-local-type, unused-local

script_name("MTG MODS Installer")
script_author("MTG MODS")
script_version("1.0")
script_description('Script for installed other scripts')

require("lib.moonloader")
require('encoding').default = 'CP1251'
local u8 = require('encoding').UTF8
local ffi = require('ffi')
local effil = require('effil')
local memory = require('memory')

function isMonetLoader() 
	return MONET_VERSION ~= nil 
end
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

local imgui = require('mimgui')
local fa = require('fAwesome6_solid')
local sizeX, sizeY = getScreenResolution()
local MainWindow = imgui.new.bool()


local dir = getWorkingDirectory():gsub('\\','/')
local configDirectory = dir .. '/MTG Installer'
if not doesDirectoryExist(configDirectory) then
	createDirectory(configDirectory)
end

local all_scripts = {}
local support_scripts = {}

function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand('mtg', get_all_scripts)

    repeat wait(0) until sampIsLocalPlayerSpawned()
    msg('Р”Р»СЏ Р°РІС‚Рѕ-СѓСЃС‚Р°РЅРѕРІРєРё СЃРєСЂРёРїС‚РѕРІ/С…РµР»РїРµСЂРѕРІ РёСЃРїРѕР»СЊР·СѓР№С‚Рµ РєРѕРјР°РЅРґСѓ {00ccff}/mtg')

    wait(-1)

end

function msg(text)
    sampAddChatMessage('{00ccff}[MTG MODS Installer] {ffffff}' .. text, -1)
end
function downloadToFile(url, path, callback, progressInterval)
	callback = callback or function() end
	progressInterval = progressInterval or 0.1

	local effil = require("effil")
	local progressChannel = effil.channel(0)

	local runner = effil.thread(function(url, path)
	local http = require("socket.http")
	local ltn = require("ltn12")

	local r, c, h = http.request({
		method = "HEAD",
		url = url,
	})

	if c ~= 200 then
		return false, c
	end
	local total_size = h["content-length"]

	local f = io.open(path, "wb")
	if not f then
		return false, "failed to open file"
	end
	local success, res, status_code = pcall(http.request, {
		method = "GET",
		url = url,
		sink = function(chunk, err)
		local clock = os.clock()
		if chunk and not lastProgress or (clock - lastProgress) >= progressInterval then
			progressChannel:push("downloading", f:seek("end"), total_size)
			lastProgress = os.clock()
		elseif err then
			progressChannel:push("error", err)
		end

		return ltn.sink.file(f)(chunk, err)
		end,
	})

	if not success then
		return false, res
	end

	if not res then
		return false, status_code
	end

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
	if checkStatus() then
		return
	end

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
				--print(("РЎРєР°С‡РёРІР°РЅРёРµ %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				lua_thread.create(function ()
					msg('Р—Р°РіСЂСѓР·РєР° СЃРєСЂРёРїС‚Р° ' .. path:gsub(dir .. '/','') .. ' Р·Р°РєРѕРЅС‡РµРЅР°! РџРµСЂРµР·Р°РїСѓСЃРє СЃРєСЂРёРїС‚РѕРІ С‡РµСЂРµР· 3 СЃРµРєСѓРЅРґС‹...')
					wait(3000)
					reloadScripts()
				end)
			elseif type == "error" then
				msg('РћС€РёР±РєР° Р·Р°РіСЂСѓР·РєРё: ' .. pos)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				lua_thread.create(function ()
					msg('Р—Р°РіСЂСѓР·РєР° СЃРєСЂРёРїС‚Р° ' .. path:gsub(dir .. '/','') .. ' Р·Р°РєРѕРЅС‡РµРЅР°! РџРµСЂРµР·Р°РїСѓСЃРє СЃРєСЂРёРїС‚РѕРІ С‡РµСЂРµР· 3 СЃРµРєСѓРЅРґС‹...')
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
	local url = "https://raw.githubusercontent.com/Andrei375577/MONETMOBILE/refs/heads/main/scripts.json"
	os.remove(path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "finished" then
				local array = readJsonFile(path)
				if array ~= nil then
					all_scripts = array
					sort()
				end
			elseif type == "error" then
				msg('РћС€РёР±РєР° Р·Р°РіСЂСѓР·РєРё: ' .. pos)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				local array = readJsonFile(path)
				if array ~= nil then
					all_scripts = array
					sort()
				end
			end
		end)
	end
	function readJsonFile(filePath)
		if not doesFileExist(filePath) then
			msg("РћС€РёР±РєР°: Р¤Р°Р№Р» РЅРµ СЃСѓС‰РµСЃС‚РІСѓРµС‚")
			return nil
		end
		local file = io.open(filePath, "r")
		local content = file:read("*a")
		file:close()
		local cjson = require("cjson") -- РёР»Рё "cjson"
		local status, jsonData = pcall(cjson.decode, content)
		if not status then
			msg("РћС€РёР±РєР°: РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON: " .. tostring(err))
			return nil
		end
		return jsonData
	end
	function sort()
		for index, value in ipairs(all_scripts) do
			if tostring(value.platform):find("MOBILE") then
				table.insert(support_scripts, value)
			end
		end
		MainWindow[0] = true
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
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2 * MONET_DPI_SCALE, 2 * MONET_DPI_SCALE)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().GrabMinSize = 10 * MONET_DPI_SCALE
    imgui.GetStyle().WindowBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().ChildBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().PopupBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().FrameBorderSize = 1 * MONET_DPI_SCALE
    imgui.GetStyle().TabBorderSize = 1 * MONET_DPI_SCALE
	imgui.GetStyle().WindowRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ChildRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().PopupRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().GrabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().TabRounding = 8 * MONET_DPI_SCALE
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 0.25, 0.25, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.60, 0.20, 0.20, 1.00)
	imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.15, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.15, 0.00, 0.00, 0.85)
	imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.20, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.80, 0.15, 0.15, 0.90)
	imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.30, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.55, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.75, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.25, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.35, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.20, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.25, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.20, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.55, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.75, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 0.20, 0.20, 1.00)
	imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.65, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.85, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.35, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.65, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.35, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.65, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.35, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.65, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 0.20, 0.20, 0.25)
	imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 0.20, 0.20, 0.67)
	imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 0.20, 0.20, 0.95)
	imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.35, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.65, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.20, 0.00, 0.00, 0.97)
	imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.40, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.85, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.30, 0.30, 1.00)
	imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.95, 0.00, 0.00, 1.00)
	imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.40, 0.40, 1.00)
	imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
	imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 0.20, 0.20, 0.90)
	imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(1.00, 0.25, 0.25, 1.00)
	imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 0.30, 0.30, 0.70)
	imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.50, 0.00, 0.00, 0.20)
	imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.25, 0.00, 0.00, 0.95)
end) 

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
		imgui.Begin(fa.GEAR .." MTG Installer " .. fa.GEAR, MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		if imgui.BeginChild('##1', imgui.ImVec2(660 * MONET_DPI_SCALE, (36*#support_scripts) * MONET_DPI_SCALE), true) then
			imgui.Columns(3)
			imgui.CenterColumnText(u8"РќР°Р·РІР°РЅРёРµ Рё РІРµСЂСЃРёСЏ")
			imgui.SetColumnWidth(-1, 200 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.CenterColumnText(u8"РљСЂР°С‚РєРѕРµ РѕРїРёСЃР°РЅРёРµ")
			imgui.SetColumnWidth(-1, 360 * MONET_DPI_SCALE)
			imgui.NextColumn()
			imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
			imgui.CenterColumnText(u8("Р”РµР№СЃС‚РІРёРµ"))
			imgui.Columns(1)
			imgui.Separator()
			for index, value in ipairs(support_scripts) do
				imgui.Columns(3)
				imgui.CenterColumnText(u8(value.name .. " [" .. value.ver .. "]"))	
				imgui.NextColumn()
				imgui.CenterColumnText(u8(value.info))	
				imgui.NextColumn()
				if doesFileExist(dir .. '/' .. value.name .. '.lua') then
					if imgui.CenterColumnButton(fa.TRASH_CAN .. u8(" РЈРґР°Р»РёС‚СЊ##") .. index) then
						os.remove(dir .. '/' .. value.name .. '.lua')
						lua_thread.create(function ()
							msg('РЎРєСЂРёРїС‚ ' .. value.name .. '.lua СѓСЃРїРµС€РЅРѕ СѓРґР°Р»С‘РЅ! РџРµСЂРµР·Р°РїСѓСЃРє СЃРєСЂРёРїС‚РѕРІ С‡РµСЂРµР· 3 СЃРµРєСѓРЅРґС‹...')
							MainWindow[0] = false
							wait(3000)
							reloadScripts()
						end)
					end
				else
					if imgui.CenterColumnButton(fa.DOWNLOAD .. u8(" РЎРєР°С‡Р°С‚СЊ##") .. index) then
						downloadFileFromUrlToPath(value.link, dir .. '/' .. value.name .. '.lua')
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
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
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
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() 
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count)
end
