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
local StyleWindow = imgui.new.bool(false)

function isMonetLoader() 
	return MONET_VERSION ~= nil 
end
if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end


local dir = getWorkingDirectory():gsub('\\','/')
local configDirectory = dir .. '/MONETMOBILE Installer'
if not doesDirectoryExist(configDirectory) then
	createDirectory(configDirectory)
end

local all_scripts = {}
local support_scripts = {}

function main()

    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand('install', get_all_scripts)

    repeat wait(0) until sampIsLocalPlayerSpawned()
    msg('��� ����-��������� ��������/�������� ����������� ������� {00ccff}/monet')

    wait(-1)

end

function msg(text)
    sampAddChatMessage('{00ccff}[MONETMOBILE Installer] {ffffff}' .. text, -1)
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
				--print(("���������� %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				lua_thread.create(function ()
					msg('�������� ������� ' .. path:gsub(dir .. '/','') .. ' ���������! ���������� �������� ����� 3 �������...')
					wait(3000)
					reloadScripts()
				end)
			elseif type == "error" then
				msg('������ ��������: ' .. pos)
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				lua_thread.create(function ()
					msg('�������� ������� ' .. path:gsub(dir .. '/','') .. ' ���������! ���������� �������� ����� 3 �������...')
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
				if array ~= nil then
					all_scripts = array
					sort()
				end
			elseif type == "error" then
				msg('������ ��������: ' .. pos)
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
			msg("������: ���� �� ����������")
			return nil
		end
		local file = io.open(filePath, "r")
		local content = file:read("*a")
		file:close()
		local cjson = require("cjson") -- ��� "cjson"
		local status, jsonData = pcall(cjson.decode, content)
		if not status then
			msg("������: �������� ������ JSON: " .. tostring(err))
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

    -- Исходные значения стиля
    imgui.GetStyle().WindowPadding = imgui.ImVec2(8 * MONET_DPI_SCALE, 8 * MONET_DPI_SCALE)
    imgui.GetStyle().FramePadding = imgui.ImVec2(6 * MONET_DPI_SCALE, 6 * MONET_DPI_SCALE)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(6 * MONET_DPI_SCALE, 6 * MONET_DPI_SCALE)
    imgui.GetStyle().WindowRounding = 12 * MONET_DPI_SCALE
    imgui.GetStyle().FrameRounding = 10 * MONET_DPI_SCALE
    imgui.GetStyle().ScrollbarRounding = 10 * MONET_DPI_SCALE

    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    local baseColor = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
    local accentColor = imgui.ImVec4(0.40, 0.10, 0.70, 1.00)
    local hoverColor = imgui.ImVec4(0.60, 0.20, 0.90, 1.00)

    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = baseColor
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = baseColor
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = hoverColor
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = accentColor
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = baseColor
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = accentColor
    imgui.GetStyle().Colors[imgui.Col.Button]                 = accentColor
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = hoverColor
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = baseColor
    imgui.GetStyle().Colors[imgui.Col.Border]                 = hoverColor
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = baseColor
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = hoverColor
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = accentColor
end)

imgui.OnFrame(
    function() return MainWindow[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 600), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.GEAR .." MONETMOBILE Installer " .. fa.GEAR, MainWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        -- Кнопка-шестерёнка в левом верхнем углу
        if imgui.Button(fa.GEAR .. "##style") then
            StyleWindow[0] = not StyleWindow[0]
        end
        if StyleWindow[0] then
            imgui.Separator()
            imgui.Text(u8"Настройки...")
            imgui.Separator()
        end
        if imgui.BeginChild('##1', imgui.ImVec2(660 * MONET_DPI_SCALE, (36*#support_scripts) * MONET_DPI_SCALE), true) then
            imgui.Columns(3)
            imgui.CenterColumnText(u8" ")
            imgui.SetColumnWidth(-1, 200 * MONET_DPI_SCALE)
            imgui.NextColumn()
            imgui.CenterColumnText(u8" ")
            imgui.SetColumnWidth(-1, 360 * MONET_DPI_SCALE)
            imgui.NextColumn()
            imgui.SetColumnWidth(-1, 100 * MONET_DPI_SCALE)
            imgui.CenterColumnText(u8(""))
            imgui.Columns(1)
            imgui.Separator()
            for index, value in ipairs(support_scripts) do
                imgui.Columns(3)
                imgui.CenterColumnText(u8(value.name .. " [" .. value.ver .. "]"))	
                imgui.NextColumn()
                imgui.CenterColumnText(u8(value.info))	
                imgui.NextColumn()
                if doesFileExist(dir .. '/' .. value.name .. '.lua') then
                    if imgui.CenterColumnButton(fa.TRASH_CAN .. u8(" ##") .. index) then
                        os.remove(dir .. '/' .. value.name .. '.lua')
                        lua_thread.create(function ()
                            msg(' ' .. value.name .. '.lua  !    3 �������...')
                            MainWindow[0] = false
                            wait(3000)
                            reloadScripts()
                        end)
                    end
                else
                    if imgui.CenterColumnButton(fa.DOWNLOAD .. u8(" ##") .. index) then
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
