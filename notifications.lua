
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local ruled = require("ruled")

local assets_folder = gears.filesystem.get_configuration_dir() .. "assets/"

-- TODO Make volume notifications show muted state as well
-- TODO Add media notifications

local progress_bar = function()
    return wibox.widget {
        color = "#FFFFFF",
        background_color = "#000000",
        max_value = 100,
        shape = gears.shape.rounded_bar,
        forced_height = 20,
        forced_width = 128,
        widget = wibox.widget.progressbar
    }
end

local icons = {
    brightness = function() return assets_folder .. "notifications/brightness.svg" end,
    mute = function(state) return state and assets_folder .. "notifications/mute.svg" or assets_folder .. "notifications/volume.svg" end,
    screenshot = function() return assets_folder .. "notifications/screenshot.svg" end,
    volume = function() return assets_folder .. "notifications/volume.svg" end
}

local state_notification = function(property, state)
    naughty.notification {
        title = property,
        state = state,
        icon = icons[property](state),
        icon_size = 96,
        timeout = 1
    }
end

local progress_bars = {
    brightness = progress_bar(),
    volume = progress_bar()
}

local layouts = {
    brightness = function(n)
        naughty.layout.box {
            notification = n,
            shape = n.shape,
            widget_template = {
                {
                    {
                        nil,
                        {
                            image = n.icon,
                            resize = true,
                            valign = "center",
                            halign = "center",
                            stylesheet = "* { fill: #FFFFFF }",
                            forced_width = n.icon_size,
                            forced_height = n.icon_size,
                            widget = wibox.widget.imagebox
                        },
                        progress_bars[n.title] ~= nil and {
                            {
                                nil,
                                progress_bars[n.title],
                                nil,
                                layout = wibox.layout.align.horizontal
                            },
                            top = 20,
                            widget = wibox.container.margin
                        } or nil,
                        layout = wibox.layout.align.vertical 
                    },
                    -- TODO Change margin to be dynamically adjustable
                    margins = 20,
                    widget = wibox.container.margin
                },
                widget = wibox.container.constraint,
                height = 300,
                width = 100,
                strategy = "max"
            },
        }
    end,
    default = function(n)
        naughty.layout.box {
            notification = n
        }
    end,
    -- TODO Add padding
    screenshot = function(n)
        naughty.layout.box {
            notification = n,
            shape = n.shape,
            widget_template = {
                {
                    {
                        {
                            {
                                nil,
                                {
                                    {
                                        image = n.icon,
                                        resize = true,
                                        valign = "center",
                                        halign = "center",
                                        stylesheet = "* { fill: #FFFFFF }",
                                        forced_width = 24,
                                        forced_height = 24,
                                        widget = wibox.widget.imagebox
                                    },
                                    naughty.widget.message,
                                    spacing = 6,
                                    layout = wibox.layout.fixed.horizontal
                                },
                                nil,
                                expand = "outside",
                                layout = wibox.layout.align.horizontal
                            },
                            bottom = n.margin,
                            widget = wibox.container.margin
                        },
                        {
                            image = n.image,
                            resize = true,
                            halign = "center",
                            valign = "center",
                            widget = wibox.widget.imagebox
                        },
                        nil,
                        layout = wibox.layout.align.vertical
                    },
                    margins = n.margin,
                    widget = wibox.container.margin
                },
                widget = wibox.container.constraint,
                height = 2000,
                width = 2000,
                strategy = "max"
            }
        }
    end,
}

layouts.mute = layouts.brightness
layouts.volume = layouts.brightness

naughty.connect_signal("state::change", function(property, state)
    local found = false
    for _, i in pairs(naughty.active) do
        if i.title == property and i.icon == icons[property](state) then
            i:reset_timeout(i.timeout)
            found = true
        elseif i.position == "bottom_middle" then
            i:destroy("dismissed_by_command")
        end
    end
    if not found then
        state_notification(property, state)
    end
    if progress_bars[property] ~= nil then
        progress_bars[property].value = state
    end
end)

naughty.connect_signal("screenshot", function(file)
    naughty.notification {
        title = "screenshot",
        icon = icons["screenshot"](),
        message = "Screenshot taken!",
        margin = 14,
        position = "top_right",
        shape = gears.shape.rounded_rect,
        image = file,
        timeout = 2
    }
end)

naughty.connect_signal("request::display", function(n)
    if(layouts[n.title] ~= nil) then
        layouts[n.title](n)
    else
        layouts["default"](n)
    end
end)


ruled.notification.connect_signal('request::rules', function()

    ruled.notification.append_rule {
        rule_any = {
            title = { "brightness", "mute", "volume" }
        },
        properties = {
            position = "bottom_middle"
        }
    }

    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

