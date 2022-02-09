
local awful = require("awful")
local naughty = require("naughty")

local animations = require("animations")
local screenshot_folder = "/home/dani/Screenshots/"
local script_folder = "/home/dani/.config/awesome/scripts/"
local brightness_step = 2400
local volume_step = 2

local function set_brightness(change) 
	awful.spawn.easy_async(script_folder .. "brightness.sh " .. change, function(stdout)
        naughty.emit_signal("state::change", "brightness", tonumber(stdout))
    end)
end

local function set_volume(change)
    awful.spawn.easy_async((change >= 0 and "pamixer -i " .. change or "pamixer -d " .. -change) .. " && pamixer --get-volume", function(stdout)
        naughty.emit_signal("state::change", "volume", tonumber(stdout))
    end)
end

local function toggle_prompt(prompt_call, s)
    local fx = s.prompt_widget.x < 0 and 0 or -s.prompt_widget.width
    animations.slide(s.prompt_widget, fx, s.prompt_widget.y, 0.3, function()
        if fx >= 0 then
            prompt_call(s)  -- Prompt is now visible
        end
    end, nil)
end

local function trim_output(stdout)
    return stdout:gsub("\n", "")
end

local utilities = {
    raise_brightness = function() set_brightness(brightness_step) end,
    lower_brightness = function() set_brightness(-brightness_step) end,
    raise_volume = function() set_volume(volume_step) end,
    lower_volume = function() set_volume(-volume_step) end,
    mute_volume = function() 
        awful.spawn.easy_async_with_shell("pamixer --get-mute && pamixer --unmute || pamixer --mute", function(stdout)
            naughty.emit_signal("state::change", "mute", trim_output(stdout) == "false")
        end) 
    end,
    media_play_pause = function()
        awful.spawn("playerctl play-pause")
        -- TODO Add notification signal
    end,
    media_prev = function()
        awful.spawn("playerctl previous")
        -- TODO Add notification signal
    end,
    media_next = function()
        awful.spawn("playerctl next")
        -- TODO Add notification signal
    end,
    take_screenshot = function()
        awful.spawn.easy_async("date", function(stdout)
            local screenshot_file = screenshot_folder .. trim_output(stdout)
            awful.spawn.easy_async_with_shell('scrot --select --line mode=edge --delay 0 --file "' .. screenshot_file .. '"', function(stdout, stderr, exitreason, exitcode)
                if exitcode == 0 then
                    naughty.emit_signal("screenshot", screenshot_file)  -- Screenshot was successfully taken
                end
            end)
        end)
    end,

    toggle_prompt_widget = function(s)
        s.prompt_icon.image = s.prompt.icon
        toggle_prompt(function(s) s.prompt:run() end, s)
    end,

    toggle_lua_widget = function(s)
        s.prompt_icon.image = s.lua_prompt.icon
        toggle_prompt(function(s) s.lua_prompt.run() end, s)
    end,

    set_trimmed_output = function(widget, stdout)
        widget:set_text(trim_output(stdout))
    end,

    focus_next_client = function(c)
        c = c or client.focus
        local clients = client.get()
        local index = 0
        if c ~= nil then
            local i = 1
            while index == 0 and i <= #clients do
                if clients[i] == c then
                    index = i
                else
                    i = i + 1
                end
            end
        end
        client.focus = nil
        awful.spawn.easy_async_with_shell("sleep 0.005", function()     -- Lets Picom remove the blur
            if clients[index % #clients + 1] ~= nil then
                clients[index % #clients + 1]:jump_to()
            end
        end)
    end
}

return utilities
